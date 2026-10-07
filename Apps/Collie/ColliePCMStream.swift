@preconcurrency import AVFoundation
import Foundation

/// Errors produced while turning the engine's native PCM stream into the
/// bounded mono stream consumed by the on-device recognizer.
enum ColliePCMError: LocalizedError {
    case unsupportedFormat
    case conversionFailed
    case durationExceeded
    case bufferOverflow
    case cancelled

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return NSLocalizedString("录音格式不受支持，请重试。", tableName: "Yihu", comment: "")
        case .conversionFailed:
            return NSLocalizedString("录音处理失败，请重试。", tableName: "Yihu", comment: "")
        case .durationExceeded:
            return NSLocalizedString("录音超过时长限制，请重试。", tableName: "Yihu", comment: "")
        case .bufferOverflow:
            return NSLocalizedString("录音处理跟不上输入，请重试。", tableName: "Yihu", comment: "")
        case .cancelled:
            return NSLocalizedString("录音已取消。", tableName: "Yihu", comment: "")
        }
    }
}

/// A stateful AVAudioConverter wrapper. The converter is deliberately kept
/// alive for the whole capture: resetting it for every tap block would lose
/// the sample-rate converter's priming/history at block boundaries.
final class ColliePCMStreamConverter {
    static let outputSampleRate: Double = 16_000

    let sourceFormat: AVAudioFormat
    let outputFormat: AVAudioFormat
    private let converter: AVAudioConverter

    init(sourceFormat: AVAudioFormat) throws {
        guard sourceFormat.sampleRate.isFinite, (8_000...192_000).contains(sourceFormat.sampleRate),
              (1...8).contains(sourceFormat.channelCount),
              sourceFormat.commonFormat == .pcmFormatFloat32,
              !sourceFormat.isInterleaved else {
            throw ColliePCMError.unsupportedFormat
        }
        guard let targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: Self.outputSampleRate,
            channels: 1,
            interleaved: false
        ), let converter = AVAudioConverter(
            from: sourceFormat,
            to: targetFormat
        ) else {
            throw ColliePCMError.unsupportedFormat
        }
        self.sourceFormat = sourceFormat
        self.outputFormat = converter.outputFormat
        self.converter = converter
    }

    func convert(_ input: AVAudioPCMBuffer) throws -> [Float] {
        guard input.format.isStandard == sourceFormat.isStandard,
              input.format.sampleRate == sourceFormat.sampleRate,
              input.format.channelCount == sourceFormat.channelCount,
              input.format.commonFormat == .pcmFormatFloat32,
              !input.format.isInterleaved else {
            throw ColliePCMError.unsupportedFormat
        }
        return try convertOnce(input: input, endOfStream: false).samples
    }

    func reset() { converter.reset() }

    /// Flushes the converter's delayed samples once, after all input blocks.
    func finish() throws -> [Float] {
        var result: [Float] = []
        // A rate converter normally drains in one call. Keep a small bounded
        // loop for converters with a longer prime/delay, without risking an
        // accidental infinite loop on a broken audio unit.
        for _ in 0..<16 {
            let converted = try convertOnce(input: nil, endOfStream: true)
            result.append(contentsOf: converted.samples)
            if converted.status == .endOfStream || converted.samples.isEmpty { break }
        }
        return result
    }

    private func convertOnce(
        input: AVAudioPCMBuffer?,
        endOfStream: Bool
    ) throws -> (samples: [Float], status: AVAudioConverterOutputStatus) {
        let inputFrames = Int(input?.frameLength ?? 0)
        let ratio = Self.outputSampleRate / sourceFormat.sampleRate
        let capacity = max(4_096, Int(ceil(Double(inputFrames) * ratio)) + 128)
        guard let output = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: AVAudioFrameCount(capacity)
        ) else {
            throw ColliePCMError.conversionFailed
        }

        var suppliedInput = false
        var conversionError: NSError?
        let status = converter.convert(to: output, error: &conversionError) { _, inputStatus in
            if let input, !suppliedInput {
                suppliedInput = true
                inputStatus.pointee = .haveData
                return input
            }
            // noDataNow is essential between tap blocks. endOfStream is used
            // only by finish(), so converter state survives normal blocks.
            inputStatus.pointee = endOfStream ? .endOfStream : .noDataNow
            return nil
        }

        if status == .error || conversionError != nil {
            throw conversionError ?? ColliePCMError.conversionFailed
        }
        guard let channel = output.floatChannelData?[0] else {
            throw ColliePCMError.conversionFailed
        }
        let count = Int(output.frameLength)
        return (Array(UnsafeBufferPointer(start: channel, count: count)), status)
    }
}

/// Immutable PCM copy made by the tap callback. Only the immutable format
/// descriptor crosses queues; the engine's reusable AVAudioPCMBuffer does not.
struct ColliePCMChunk: @unchecked Sendable {
    let format: AVAudioFormat
    let planes: [[Float]]
    let frameCount: Int

    init(buffer: AVAudioPCMBuffer, frameCount: Int? = nil) throws {
        let count = min(Int(buffer.frameLength), frameCount ?? Int(buffer.frameLength))
        guard count > 0,
              buffer.format.commonFormat == .pcmFormatFloat32,
              !buffer.format.isInterleaved,
              let channels = buffer.floatChannelData,
              buffer.format.channelCount > 0 else {
            throw ColliePCMError.unsupportedFormat
        }
        let channelCount = Int(buffer.format.channelCount)
        var copied: [[Float]] = []
        copied.reserveCapacity(channelCount)
        for channel in 0..<channelCount {
            copied.append(Array(UnsafeBufferPointer(start: channels[channel], count: count)))
        }
        self.format = buffer.format
        self.planes = copied
        self.frameCount = count
    }

    func makeBuffer() throws -> AVAudioPCMBuffer {
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        ), let channels = buffer.floatChannelData else {
            throw ColliePCMError.conversionFailed
        }
        buffer.frameLength = AVAudioFrameCount(frameCount)
        for channel in planes.indices {
            planes[channel].withUnsafeBufferPointer { source in
                channels[channel].update(from: source.baseAddress!, count: frameCount)
            }
        }
        return buffer
    }
}

/// Serial, bounded capture-side pipeline. The audio tap only copies a small
/// block and enqueues it; conversion and all unbounded-looking array work run
/// on this private queue, never on the main actor or the realtime tap thread.
final class ColliePCMRecordingPipeline: @unchecked Sendable {
    enum Completion: @unchecked Sendable {
        case success([Float])
        case failure(Error)
    }

    typealias CompletionHandler = @Sendable (Completion) -> Void

    private let queue = DispatchQueue(label: "org.example.yihu.audio-pcm", qos: .userInitiated)
    private let lock = NSLock()
    private let converter: ColliePCMStreamConverter
    private let maximumFrames: Int
    private let maximumSourceFrames: Int

    private var pending: [ColliePCMChunk] = []
    private var pendingFrames = 0
    private var acceptedSourceFrames = 0
    private var output: [Float] = []
    private var workerScheduled = false
    private var stopRequested = false
    private var accepting = true
    private var cancelled = false
    private var completed = false
    private var failure: Error?
    private var level: Float = 0

    var onCompleted: CompletionHandler?

    init(sourceFormat: AVAudioFormat, maximumDuration: TimeInterval) throws {
        guard maximumDuration.isFinite, maximumDuration > 0, maximumDuration <= 30 else {
            throw ColliePCMError.durationExceeded
        }
        converter = try ColliePCMStreamConverter(sourceFormat: sourceFormat)
        maximumFrames = Int(floor(ColliePCMStreamConverter.outputSampleRate * maximumDuration))
        maximumSourceFrames = Int(floor(sourceFormat.sampleRate * maximumDuration))
        guard maximumFrames > 0, maximumSourceFrames > 0 else {
            throw ColliePCMError.durationExceeded
        }
        // A short queue prevents a slow converter from turning a realtime tap
        // into an unbounded memory sink. Overflow is reported, never dropped.
    }

    var isAccepting: Bool {
        lock.lock(); defer { lock.unlock() }
        return accepting && !cancelled && !completed
    }

    func accept(_ buffer: AVAudioPCMBuffer) {
        let available = Int(buffer.frameLength)
        guard available > 0 else { return }

        lock.lock()
        guard accepting, !cancelled, !completed else {
            lock.unlock()
            return
        }
        let remaining = maximumSourceFrames - acceptedSourceFrames
        guard remaining > 0 else {
            accepting = false
            stopRequested = true
            let shouldSchedule = scheduleWorkerLocked()
            lock.unlock()
            if shouldSchedule { queue.async { [weak self] in self?.processLoop() } }
            return
        }
        let count = min(available, remaining)
        // Keep at most roughly half a second of source audio waiting. This is
        // intentionally a failure boundary rather than a silent drop.
        let queueLimit = max(Int(ceil(converter.sourceFormat.sampleRate / 2)), 4_096)
        guard pendingFrames + count <= queueLimit else {
            accepting = false
            stopRequested = true
            failure = ColliePCMError.bufferOverflow
            let shouldSchedule = scheduleWorkerLocked()
            lock.unlock()
            if shouldSchedule { queue.async { [weak self] in self?.processLoop() } }
            return
        }
        // Publish the bounded copy before stop can enqueue a flush. Releasing
        // the lock between admission and append would let stop lose the last block.
        do {
            let chunk = try ColliePCMChunk(buffer: buffer, frameCount: count)
            acceptedSourceFrames += count
            if count == remaining { accepting = false; stopRequested = true }
            pending.append(chunk)
            pendingFrames += count
            let shouldSchedule = scheduleWorkerLocked()
            lock.unlock()
            if shouldSchedule { queue.async { [weak self] in self?.processLoop() } }
        } catch {
            lock.unlock()
            fail(error)
        }
    }

    func requestStop() {
        lock.lock()
        guard !cancelled, !completed else { lock.unlock(); return }
        accepting = false
        stopRequested = true
        let shouldSchedule = scheduleWorkerLocked()
        lock.unlock()
        if shouldSchedule { queue.async { [weak self] in self?.processLoop() } }
    }

    func fail(_ error: Error) {
        lock.lock()
        guard !cancelled, !completed else { lock.unlock(); return }
        accepting = false
        stopRequested = true
        failure = error
        pending.removeAll(keepingCapacity: false)
        pendingFrames = 0
        let shouldSchedule = scheduleWorkerLocked()
        lock.unlock()
        if shouldSchedule { queue.async { [weak self] in self?.processLoop() } }
    }

    func cancel() {
        lock.lock()
        cancelled = true
        accepting = false
        pending.removeAll(keepingCapacity: false)
        pendingFrames = 0
        output.removeAll(keepingCapacity: false)
        level = 0
        lock.unlock()
        queue.async { [weak self] in
            guard let self else { return }
            self.converterReset()
        }
    }

    func snapshot() throws -> [Float] {
        // A preview need not drain the conversion queue. Never block the main
        // actor behind audio conversion; Array's COW keeps this snapshot immutable.
        lock.lock()
        defer { lock.unlock() }
        if let failure { throw failure }
        if cancelled { throw ColliePCMError.cancelled }
        return output
    }

    func currentLevel() -> Float {
        lock.lock(); defer { lock.unlock() }
        return level
    }

    private func scheduleWorkerLocked() -> Bool {
        guard !workerScheduled else { return false }
        workerScheduled = true
        return true
    }

    private func processLoop() {
        while true {
            lock.lock()
            if cancelled || completed {
                workerScheduled = false
                lock.unlock()
                return
            }
            guard !pending.isEmpty else {
                let shouldFinish = stopRequested
                workerScheduled = false
                lock.unlock()
                if shouldFinish { finishOnQueue() }
                return
            }
            let chunk = pending.removeFirst()
            pendingFrames -= chunk.frameCount
            lock.unlock()

            do {
                let buffer = try chunk.makeBuffer()
                let samples = try converter.convert(buffer)
                lock.lock()
                guard !cancelled, !completed else { lock.unlock(); return }
                guard output.count + samples.count <= maximumFrames else {
                    failure = ColliePCMError.durationExceeded
                    stopRequested = true
                    accepting = false
                    pending.removeAll(keepingCapacity: false)
                    pendingFrames = 0
                    lock.unlock()
                    finishOnQueue()
                    return
                }
                output.append(contentsOf: samples)
                level = rms(samples)
                lock.unlock()
            } catch {
                lock.lock()
                failure = error
                stopRequested = true
                accepting = false
                pending.removeAll(keepingCapacity: false)
                pendingFrames = 0
                lock.unlock()
                finishOnQueue()
                return
            }
        }
    }

    private func finishOnQueue() {
        lock.lock()
        guard !cancelled, !completed else { lock.unlock(); return }
        let error = failure
        lock.unlock()

        if let error {
            complete(.failure(error))
            return
        }
        do {
            let tail = try converter.finish()
            lock.lock()
            guard !cancelled else { lock.unlock(); return }
            guard output.count + tail.count <= maximumFrames else {
                lock.unlock()
                complete(.failure(ColliePCMError.durationExceeded))
                return
            }
            output.append(contentsOf: tail)
            let result = output
            lock.unlock()
            guard !result.isEmpty else {
                complete(.failure(CollieAudioRecorderError.tooShort))
                return
            }
            complete(.success(result))
        } catch {
            complete(.failure(error))
        }
    }

    private func complete(_ completion: Completion) {
        lock.lock()
        guard !cancelled, !completed else { lock.unlock(); return }
        completed = true
        let callback = onCompleted
        lock.unlock()
        callback?(completion)
    }

    private func converterReset() {
        converter.reset()
    }

    private func rms(_ samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }
        var sum: Float = 0
        for sample in samples { sum += sample * sample }
        return min(1, max(0, sqrt(sum / Float(samples.count)) * 2))
    }
}
