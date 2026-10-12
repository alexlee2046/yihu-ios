@preconcurrency import AVFoundation
import CryptoKit
import Foundation
import Observation
import WatchConnectivity

@MainActor
@Observable
final class YihuWatchVoiceCapture: NSObject, AVAudioRecorderDelegate {
    private struct Pending: Codable {
        var request: YihuWatchVoiceRequest
        var result: YihuWatchVoiceResult?
        var recording: Bool? = nil
    }
    private(set) var pending: YihuWatchVoiceRequest?
    private(set) var result: YihuWatchVoiceResult?
    private(set) var recording = false
    private(set) var sending = false
    private(set) var blocked = false
    var foreground = false
    var notice: String?
    private var recorder: AVAudioRecorder?
    private var timer: Task<Void, Never>?
    private var item: YihuWatchSnapshot.Item?
    private var recordingID: UUID?
    private var directory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WatchVoice", isDirectory: true)
    }
    private var audioFile: URL { directory.appendingPathComponent("audio.m4a") }
    private var pendingFile: URL { directory.appendingPathComponent("pending.json") }
    var hasAudio: Bool { pending != nil || blocked }

    func attach(_ item: YihuWatchSnapshot.Item) {
        self.item = item
        guard !recording, pending == nil || blocked else { return }
        blocked = false
        guard FileManager.default.fileExists(atPath: pendingFile.path) else {
            blocked = FileManager.default.fileExists(atPath: audioFile.path)
            if blocked { notice = "原录音编号无法读取，副本保留；请在手机核对" }
            return
        }
        do {
            let handle = try FileHandle(forReadingFrom: pendingFile); defer { try? handle.close() }
            let data = try handle.read(upToCount: 28_001) ?? Data()
            guard data.count <= 28_000 else { throw CocoaError(.fileReadTooLarge) }
            let saved = try JSONDecoder().decode(Pending.self, from: data)
            _ = try YihuWatchVoiceRequest.decode(JSONEncoder().encode(saved.request))
            if let result = saved.result {
                _ = try YihuWatchVoiceResult.decode(JSONEncoder().encode(result))
                guard result.request == saved.request, result.outcome == .ready else { throw CocoaError(.fileReadCorruptFile) }
            }
            pending = saved.request; result = saved.result
            if saved.recording == true {
                // Recording was never sent. Recover the bounded clip under its start-time target.
                pending?.audioDigest = Self.digest(try readAudio())
                try persist()
            }
            notice = "已恢复原录音，可用原编号重试手机本地识别"
        } catch { blocked = true; notice = "原录音记录无法读取，副本已保留" }
    }

    func matches(_ item: YihuWatchSnapshot.Item) -> Bool {
        guard let p = pending else { return !blocked }
        return p.workbench == item.workbench && p.task == item.task &&
            p.sourceToken == item.sourceToken && p.taskToken == item.taskToken
    }

    func start(_ item: YihuWatchSnapshot.Item, requestID: UUID) async {
        guard foreground, !recording, !sending, !hasAudio, item.canDraft == true,
              let source = item.sourceToken, let task = item.taskToken else { return }
        self.item = item; recordingID = requestID
        sending = true
        let allowed = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { continuation.resume(returning: $0) }
        }
        sending = false
        guard allowed, foreground, recordingID == requestID else {
            notice = allowed ? "已离开前台，未开始录音" : "请在手表设置允许一呼使用麦克风"; return
        }
        do {
            try prepareDirectory()
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            let r = try AVAudioRecorder(url: audioFile, settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 16_000,
                AVNumberOfChannelsKey: 1, AVEncoderBitRateKey: 32_000
            ])
            r.delegate = self
            pending = .init(requestID: requestID, workbench: item.workbench, task: item.task,
                sourceToken: source, taskToken: task, audioDigest: String(repeating: "0", count: 64))
            recording = true
            try persist()
            guard r.record() else { throw CocoaError(.fileWriteUnknown) }
            recorder = r; notice = "正在录音，最多10秒；停止后交手机本地识别"
            timer = Task { [weak self] in
                try? await Task.sleep(for: .seconds(YihuWatchVoiceRequest.maximumDuration))
                guard !Task.isCancelled else { return }
                self?.stop(send: self?.foreground == true)
            }
        } catch {
            recording = false; recorder = nil
            try? AVAudioSession.sharedInstance().setActive(false)
            notice = "录音未能开始；请检查麦克风权限，副本保持原样"
        }
    }

    func stop(send: Bool) {
        guard recording, let item, let id = recordingID else { recordingID = nil; return }
        recorder?.delegate = nil; recorder?.stop(); recorder = nil; recording = false
        timer?.cancel(); timer = nil
        try? AVAudioSession.sharedInstance().setActive(false)
        do {
            try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: audioFile.path)
            let data = try readAudio()
            guard let source = item.sourceToken, let task = item.taskToken else { throw CocoaError(.fileReadCorruptFile) }
            let request = YihuWatchVoiceRequest(requestID: id, workbench: item.workbench, task: item.task,
                sourceToken: source, taskToken: task, audioDigest: Self.digest(data))
            _ = try YihuWatchVoiceRequest.decode(JSONEncoder().encode(request))
            pending = request; result = nil
            try persist()
            notice = "录音已保留，等待手机本地识别"
            if send { retry() }
        } catch { blocked = true; notice = "录音过长或未能安全保存，原副本保留" }
    }

    func retry() {
        guard !recording, !sending, !blocked, let pending,
              let item, matches(item), result == nil else { return }
        guard foreground, WCSession.default.activationState == .activated, WCSession.default.isReachable else {
            notice = "录音已保留；请解锁并打开手机一呼后重试"; return
        }
        do {
            let data = try readAudio()
            guard Self.digest(data) == pending.audioDigest else { throw CocoaError(.fileReadCorruptFile) }
            sending = true
            WCSession.default.sendMessage(["kind": "voice", "request": try JSONEncoder().encode(pending), "audio": data], replyHandler: { [weak self] response in
                let queued = response["queued"] as? Bool == true
                Task { @MainActor in
                    self?.sending = false
                    if self?.result == nil { self?.notice = queued ? "手机本地识别中；结果会返回此手表草稿" : "手机忙碌或来源变化，录音保留" }
                }
            }, errorHandler: { [weak self] _ in
                Task { @MainActor in self?.sending = false; self?.notice = "传输结果待核，录音及原编号保留；可重试" }
            })
        } catch { notice = "原录音无法读取，副本保留" }
    }

    func receive(_ data: Data) -> Bool {
        guard let value = try? YihuWatchVoiceResult.decode(data), value.request == pending else { return false }
        do {
            if value.outcome == .ready {
                if let result, result != value { return false }
                let previous = result
                result = value
                do { try persist() } catch { result = previous; throw error }
                notice = "手机本地识别完成，尚未提交台账"
            } else {
                switch value.outcome {
                case .busy: notice = "手机忙碌或有待回传结果；录音保留，稍后重试"
                case .changed: notice = "事项或来源已变化；录音保留，请在手机核对"
                case .modelUnavailable: notice = "请先在手机准备好端侧语音模型；录音保留"
                case .voiceprintBlocked: notice = "手机声纹校验未通过；录音保留，未填入文字"
                default: notice = "手机识别未完成；录音保留，可重试"
                }
            }
            sending = false
            return value.outcome == .ready
        } catch { notice = "识别结果未能安全保存，录音保留"; return false }
    }

    /// Only called after the same-ID watch text draft was safely saved.
    func consumed() {
        guard result?.outcome == .ready else { return }
        clearLocal()
    }

    func discard() {
        guard !recording, !sending, let pending, !blocked else { return }
        guard WCSession.default.activationState == .activated, WCSession.default.isReachable else {
            notice = "请先连接手机核对识别结果，再丢弃录音"; return
        }
        guard let data = try? JSONEncoder().encode(pending) else { return }
        sending = true
        WCSession.default.sendMessage(["kind": "voiceDiscard", "request": data], replyHandler: { [weak self] response in
            let discarded = response["discarded"] as? Bool == true
            Task { @MainActor in
                guard let self, self.pending == pending else { return }
                self.sending = false
                if discarded { self.clearLocal(); self.notice = "录音副本已丢弃；不撤回已有文字草稿" }
                else { self.notice = "手机仍在识别，请等待结果后再丢弃" }
            }
        }, errorHandler: { [weak self] _ in
            Task { @MainActor in self?.sending = false; self?.notice = "丢弃结果待核，原录音仍保留" }
        })
    }

    private func prepareDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: directory.path)
        var url = directory; var values = URLResourceValues(); values.isExcludedFromBackup = true
        try url.setResourceValues(values)
    }
    private func persist() throws {
        guard let pending else { return }
        try prepareDirectory()
        try JSONEncoder().encode(Pending(request: pending, result: result, recording: recording)).write(to: pendingFile, options: [.atomic, .completeFileProtection])
    }
    private func readAudio() throws -> Data {
        let handle = try FileHandle(forReadingFrom: audioFile); defer { try? handle.close() }
        let data = try handle.read(upToCount: YihuWatchVoiceRequest.maximumAudioBytes + 1) ?? Data()
        guard !data.isEmpty, data.count <= YihuWatchVoiceRequest.maximumAudioBytes else { throw CocoaError(.fileReadTooLarge) }
        return data
    }
    private func clearLocal() {
        do {
            for url in [audioFile, pendingFile] where FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
            pending = nil; result = nil; blocked = false
        } catch { notice = "录音副本未能清除，原编号保留" }
    }
    private static func digest(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor [weak self] in self?.stop(send: false) }
    }
}
