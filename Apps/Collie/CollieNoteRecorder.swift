@preconcurrency import AVFoundation
import Foundation
import Observation
import os

/// Long-form capture for voice notes: the tap only copies each block; a serial
/// queue converts it to 16 kHz mono and appends 16-bit PCM to a CAF on disk, so
/// memory stays flat for hour-long recordings and a crash keeps what was written.
final class CollieNoteWriter: @unchecked Sendable {
    private let queue = DispatchQueue(label: "collie.note.writer", qos: .userInitiated)
    private var converter: ColliePCMStreamConverter
    private var file: AVAudioFile?
    private let state = OSAllocatedUnfairLock(initialState: (frames: Int64(0), level: Float(0), failed: false))

    init(url: URL, sourceFormat: AVAudioFormat) throws {
        converter = try ColliePCMStreamConverter(sourceFormat: sourceFormat)
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: ColliePCMStreamConverter.outputSampleRate,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]
        file = try AVAudioFile(forWriting: url, settings: settings,
                               commonFormat: .pcmFormatFloat32, interleaved: false)
    }

    var frames: Int64 { state.withLock { $0.frames } }
    var level: Float { state.withLock { $0.level } }
    /// True once a write failed (e.g. storage full); the file keeps what came before.
    var failed: Bool { state.withLock { $0.failed } }

    /// The input device changed (headset, Bluetooth): flush the old converter and
    /// continue the same file from the new source format.
    func retarget(to format: AVAudioFormat) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async { [self] in
                do {
                    if let tail = try? converter.finish() { append(tail) }
                    converter = try ColliePCMStreamConverter(sourceFormat: format)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Called on the realtime tap thread: copy and hand off, nothing else.
    func accept(_ buffer: AVAudioPCMBuffer) {
        guard let chunk = try? ColliePCMChunk(buffer: buffer) else { return }
        queue.async { [self] in
            guard let pcm = try? chunk.makeBuffer(), let samples = try? converter.convert(pcm) else { return }
            append(samples)
        }
    }

    /// Flushes the converter and closes the file; returns the total 16 kHz frames.
    func finish() async -> Int64 {
        await withCheckedContinuation { continuation in
            queue.async { [self] in
                if let tail = try? converter.finish() { append(tail) }
                file = nil
                continuation.resume(returning: frames)
            }
        }
    }

    private func append(_ samples: [Float]) {
        guard !samples.isEmpty, let file,
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                            frameCapacity: AVAudioFrameCount(samples.count)),
              let channel = buffer.floatChannelData?[0] else { return }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        samples.withUnsafeBufferPointer { channel.update(from: $0.baseAddress!, count: samples.count) }
        guard (try? file.write(from: buffer)) != nil else {
            state.withLock { $0.failed = true }
            return
        }
        let rms = sqrt(samples.reduce(0) { $0 + $1 * $1 } / Float(samples.count))
        state.withLock { $0.frames += Int64(samples.count); $0.level = min(1, rms * 12) }
    }
}

@MainActor
@Observable
final class CollieNoteRecorder {
    private(set) var isRecording = false
    private(set) var startedAt: Date?
    private(set) var level: Float = 0

    private var engine: AVAudioEngine?
    private var writer: CollieNoteWriter?
    private var meter: Task<Void, Never>?
    private var observers: [NSObjectProtocol] = []
    /// Called when recording had to end early (call, lost input, storage full);
    /// the argument explains why.
    var onInterrupted: ((String) -> Void)?

    func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func start(writingTo url: URL) throws {
        guard !isRecording else { return }
        guard AVAudioApplication.shared.recordPermission == .granted else {
            throw CollieAudioRecorderError.permissionDenied
        }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default, options: [])
        try session.setActive(true)
        let audioEngine = AVAudioEngine()
        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        do {
            let newWriter = try CollieNoteWriter(url: url, sourceFormat: format)
            input.installTap(onBus: 0, bufferSize: 4_096, format: format, block: Self.makeTap(for: newWriter))
            audioEngine.prepare()
            try audioEngine.start()
            engine = audioEngine
            writer = newWriter
        } catch {
            input.removeTap(onBus: 0)
            try? session.setActive(false, options: [.notifyOthersOnDeactivation])
            throw error
        }
        isRecording = true
        startedAt = Date()
        meter = Task { @MainActor [weak self] in
            while let self, self.isRecording, !Task.isCancelled {
                self.level = self.writer?.level ?? 0
                if self.writer?.failed == true {
                    self.onInterrupted?("存储空间不足或写入失败，记录已保存到出错之前。")
                    return
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
        let center = NotificationCenter.default
        observers = [
            center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
                guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                      AVAudioSession.InterruptionType(rawValue: raw) == .began else { return }
                Task { @MainActor in self?.onInterrupted?("录音被来电或其他应用打断，已保存到打断之前。") }
            },
            center.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.onInterrupted?("系统音频服务重置，记录已保存到此前。") }
            },
            center.addObserver(forName: .AVAudioEngineConfigurationChange, object: audioEngine, queue: .main) { [weak self] _ in
                Task { @MainActor in await self?.inputChanged() }
            },
        ]
    }

    /// Headset/Bluetooth changes stop the engine; resume on the new input.
    private func inputChanged() async {
        guard isRecording, let engine, let writer else { return }
        engine.stop()
        let input = engine.inputNode
        input.removeTap(onBus: 0)
        let format = input.outputFormat(forBus: 0)
        do {
            try await writer.retarget(to: format)
            guard isRecording, self.engine === engine else { return }
            input.installTap(onBus: 0, bufferSize: 4_096, format: format, block: Self.makeTap(for: writer))
            engine.prepare()
            try engine.start()
        } catch {
            onInterrupted?("录音设备变化后无法继续，记录已保存到此前。")
        }
    }

    nonisolated static func makeTap(for writer: CollieNoteWriter)
        -> @Sendable (AVAudioPCMBuffer, AVAudioTime) -> Void {
        { [weak writer] buffer, _ in writer?.accept(buffer) }
    }

    /// Stops capture and returns the number of 16 kHz frames written.
    func stop() async -> Int64 {
        guard isRecording else { return 0 }
        isRecording = false
        meter?.cancel()
        meter = nil
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
        // Detach everything before awaiting, so a new start() during the flush
        // can never be torn down by this stop.
        let finishing = writer
        engine?.inputNode.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        writer = nil
        level = 0
        startedAt = nil
        let frames = await finishing?.finish() ?? 0
        if !isRecording {
            try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        }
        return frames
    }
}
