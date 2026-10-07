import Foundation
import Observation
import UIKit

private func voiceText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

@MainActor
@Observable
final class CollieVoiceController {
    enum Phase: Equatable {
        case checkingModel, needsModel, downloading, ready, preparing, recording, transcribing, delivering
        case failed(String)
    }

    /// Decides which recovery the failure card offers; the message stays user-facing.
    enum FailureKind: Equatable {
        case microphonePermission, modelDownload, model, recording
    }

    private(set) var phase: Phase = .checkingModel
    private(set) var downloadProgress: Double = 0
    private(set) var level: Float = 0
    private(set) var pendingTranscript: String?
    private(set) var voiceprintBlocked = false
    private(set) var previewText = ""
    private(set) var previewUnavailable = false
    private(set) var isRequestingPermission = false
    private(set) var voiceprintTestMicActive = false
    private(set) var recordingStartedAt: Date?
    private(set) var notice: String?
    private(set) var modelDownloadSource: Qwen3ModelDownloadSource
    private(set) var failureKind: FailureKind = .recording
    private(set) var recognitionTerms: [String]

    /// Only the final pass (or an explicit retry) may use the web bridge.
    var deliverTranscript: ((String) async -> Bool)?

    private let recorder: any CollieAudioCapturing
    private let voiceprintChecker: any CollieVoiceprintChecking
    /// Shared with voice notes so only one copy of the model is ever loaded.
    let transcriber: any CollieTranscribing
    private let previewInterval: Duration
    private let isForeground: () -> Bool
    private let permitsPreview: () -> Bool
    private let userDefaults: UserDefaults
    private static let modelDownloadSourceKey = "collie.qwen3.model-download-source"
    private var sessionID = UUID()
    private var permissionGranted = false
    private var previewTask: Task<Void, Never>?
    private var recognitionTask: Task<Void, Never>?
    private var prewarmTask: Task<Void, Never>?
    private var prewarmID = UUID()
    private var hasAttemptedPrewarm = false

    init(
        recorder: any CollieAudioCapturing = CollieAudioRecorder(),
        transcriber: any CollieTranscribing = Qwen3OnDeviceTranscriber(),
        previewInterval: Duration = .milliseconds(1_500),
        isForeground: @escaping () -> Bool = { UIApplication.shared.applicationState == .active },
        permitsPreview: @escaping () -> Bool = {
            let state = ProcessInfo.processInfo.thermalState
            return state != .serious && state != .critical
        },
        userDefaults: UserDefaults = .standard,
        voiceprintChecker: any CollieVoiceprintChecking = CollieLocalVoiceprintChecker()
    ) {
        self.userDefaults = userDefaults
        self.recognitionTerms = CollieRecognitionTerms.load(from: userDefaults)
        if let savedSource = userDefaults.string(forKey: Self.modelDownloadSourceKey),
           let savedSource = Qwen3ModelDownloadSource(rawValue: savedSource) {
            self.modelDownloadSource = savedSource
        } else {
            // The first release targets markets outside mainland China; keep the
            // domestic source available, but make the likely-to-work choice first.
            self.modelDownloadSource = Locale.current.region?.identifier.uppercased() == "CN"
                ? .modelScope
                : .huggingFace
        }
        self.recorder = recorder
        self.voiceprintChecker = voiceprintChecker
        self.transcriber = transcriber
        self.previewInterval = previewInterval
        self.isForeground = isForeground
        self.permitsPreview = permitsPreview
        recorder.onLevelChanged = { [weak self] level in self?.level = level }
        recorder.onCaptureCompleted = { [weak self] result in self?.captureCompleted(result) }
    }

    /// An empty list turns context off; `nil` restores the built-in developer vocabulary.
    func setRecognitionTerms(_ terms: [String]?) {
        if let terms {
            recognitionTerms = CollieRecognitionTerms.parse(terms.joined(separator: "\n"))
            userDefaults.set(recognitionTerms, forKey: CollieRecognitionTerms.defaultsKey)
        } else {
            recognitionTerms = CollieRecognitionTerms.defaults
            userDefaults.removeObject(forKey: CollieRecognitionTerms.defaultsKey)
        }
    }

    func setModelDownloadSource(_ source: Qwen3ModelDownloadSource) {
        guard phase == .needsModel else { return }
        modelDownloadSource = source
        userDefaults.set(source.rawValue, forKey: Self.modelDownloadSourceKey)
    }

    func retryModelDownload(using source: Qwen3ModelDownloadSource) async {
        guard isFailure else { return }
        modelDownloadSource = source
        userDefaults.set(source.rawValue, forKey: Self.modelDownloadSourceKey)
        await downloadModel()
    }

    var primaryActionEnabled: Bool {
        switch phase {
        case .needsModel, .recording, .failed: return true
        case .ready: return pendingTranscript == nil && !voiceprintTestMicActive
        default: return false
        }
    }

    var showsProgressIndicator: Bool {
        switch phase {
        case .checkingModel, .downloading, .preparing, .transcribing, .delivering: return true
        default: return false
        }
    }

    var isRecording: Bool { phase == .recording }
    var isFailure: Bool { if case .failed = phase { return true }; return false }
    var canRetryDelivery: Bool { pendingTranscript != nil && phase == .ready }
    var canCancel: Bool { phase == .preparing || phase == .recording || phase == .transcribing }

    /// Reserve the one microphone before requesting calibration permission; this
    /// synchronously blocks App Intent, shortcut, and floating-bar recording paths.
    func claimVoiceprintTestMic() -> Bool {
        guard !voiceprintTestMicActive, !canCancel, phase != .delivering else { return false }
        voiceprintTestMicActive = true
        return true
    }

    func releaseVoiceprintTestMic() { voiceprintTestMicActive = false }

    func refreshModelState() async {
        guard phase == .checkingModel || phase == .ready || isFailure else { return }
        let id = sessionID
        phase = .checkingModel
        let installed = await transcriber.isModelDownloaded()
        guard id == sessionID, phase == .checkingModel, !Task.isCancelled else { return }
        phase = installed ? .ready : .needsModel
        prewarmModelIfIdle()
    }

    func validateInstalledModel() async -> String? {
        guard phase == .ready else { return voiceText("模型尚未就绪") }
        cancelPrewarm()
        phase = .checkingModel
        do {
            try await transcriber.validateInstalledModel()
            hasAttemptedPrewarm = true
            phase = .ready
            return nil
        } catch {
            fail(voiceText("语音模型无法加载，请重试。"), kind: .model)
            return error.localizedDescription
        }
    }

    func performPrimaryAction() async {
        switch phase {
        case .needsModel: await downloadModel()
        case .ready:
            guard pendingTranscript == nil, isForeground() else { return }
            guard !voiceprintTestMicActive else {
                notice = voiceText("正在声纹测试，请先结束测试录音")
                return
            }
            sessionID = UUID()
            let id = sessionID
            phase = .preparing
            notice = nil
            previewText = ""
            previewUnavailable = false
            permissionGranted = false
            isRequestingPermission = true
            let allowed = await recorder.requestPermission()
            guard sessionID == id, phase == .preparing else { return }
            isRequestingPermission = false
            guard allowed else {
                fail(voiceText("麦克风权限已关闭，请在系统设置中允许一呼使用麦克风。"), kind: .microphonePermission)
                return
            }
            permissionGranted = true
            transcriber.setRecognitionTerms(recognitionTerms)
            // The system consent sheet can still be dismissing. The next active
            // scene notification retries this without ever starting in background.
            startCaptureIfReady()
        case .recording: recorder.stop()
        case .failed: await refreshModelState()
        default: break
        }
    }

    func applicationDidBecomeActive() {
        startCaptureIfReady()
        prewarmModelIfIdle()
    }

    func applicationDidResignActive(isBackground: Bool) {
        cancelPrewarm()
        // Consent itself makes the scene inactive. A real background transition
        // still invalidates the request, including a late permission response.
        if !isBackground, phase == .preparing, isRequestingPermission { return }
        cancelRecording(reason: voiceText("录音因应用离开前台而取消，请重试。"))
    }

    func cancelRecording(reason: String? = nil) {
        guard canCancel else { return }
        sessionID = UUID()
        permissionGranted = false
        isRequestingPermission = false
        previewTask?.cancel()
        recognitionTask?.cancel()
        previewTask = nil
        recognitionTask = nil
        recorder.cancel()
        previewText = ""
        previewUnavailable = false
        recordingStartedAt = nil
        level = 0
        if let reason {
            fail(reason)
        } else {
            phase = .ready
            showTransientNotice(voiceText("已取消"))
        }
    }

    /// An explicit discard only clears the retained final text, never a web draft.
    func discardPendingTranscript() {
        guard canRetryDelivery else { return }
        pendingTranscript = nil
        voiceprintBlocked = false
        showTransientNotice(voiceText("已放弃"))
    }

    func recordingSeconds(at date: Date) -> Int {
        guard let recordingStartedAt else { return 0 }
        return Int(min(CollieAudioRecorder.maximumDuration, max(0, date.timeIntervalSince(recordingStartedAt))))
    }

    func retryDelivery() async {
        guard phase == .ready, let transcript = pendingTranscript, isForeground() else { return }
        pendingTranscript = nil
        voiceprintBlocked = false // Explicit user override, never re-check the same clip.
        await deliverOrStore(transcript, id: sessionID)
    }

    private func downloadModel() async {
        let source = modelDownloadSource
        phase = .downloading
        downloadProgress = 0
        do {
            try await transcriber.downloadModel(source: source) { [weak self] progress in
                Task { @MainActor in self?.downloadProgress = progress }
            }
            phase = .ready
            hasAttemptedPrewarm = false
            prewarmModelIfIdle()
        } catch { fail(String(format: voiceText("%@下载没有完成，请检查网络后重试，或换一个下载源。"), source.shortLabel), kind: .modelDownload) }
    }

    private func prewarmModelIfIdle() {
        // Loading may overlap initial audio accumulation, never an inference.
        guard (phase == .ready || phase == .recording), isForeground(), permitsPreview(),
              prewarmTask == nil, !hasAttemptedPrewarm else { return }
        hasAttemptedPrewarm = true
        let id = UUID()
        prewarmID = id
        prewarmTask = Task(priority: .utility) { [weak self] in
            guard let self else { return }
            do {
                try Task.checkCancellation()
                try await transcriber.validateInstalledModel()
            } catch {
                // Best effort only. A real recognition still validates/loads
                // normally and reports failures; never download/delete here.
            }
            guard prewarmID == id else { return }
            prewarmTask = nil
        }
    }

    private func cancelPrewarm() {
        guard let prewarmTask else { return }
        prewarmID = UUID()
        prewarmTask.cancel()
        self.prewarmTask = nil
        hasAttemptedPrewarm = false
    }

    private func startCaptureIfReady() {
        guard phase == .preparing, permissionGranted, isForeground() else { return }
        do {
            try recorder.start()
            recordingStartedAt = Date()
            phase = .recording
            prewarmModelIfIdle()
            startPreview(id: sessionID)
        } catch {
            let failure = Self.captureFailure(error, fallback: voiceText("麦克风暂时无法使用，请稍后再试。"))
            fail(failure.message, kind: failure.kind)
        }
    }

    private func startPreview(id: UUID) {
        previewTask = Task { [weak self] in
            var lastSampleCount = 0
            var delay = self?.previewInterval ?? .milliseconds(1_500)
            while !Task.isCancelled {
                guard let self else { return }
                do { try await Task.sleep(for: delay) } catch { return }
                guard sessionID == id, phase == .recording, !Task.isCancelled else { return }
                guard permitsPreview() else {
                    previewUnavailable = true
                    previewText = ""
                    return
                }
                do {
                    let samples = try recorder.snapshot()
                    // Poll briefly if the first 1.5 s tick precedes converter
                    // delivery. Later passes read only the latest cumulative PCM.
                    delay = min(previewInterval, .milliseconds(100))
                    guard samples.count >= 24_000, samples.count > lastSampleCount else { continue }
                    lastSampleCount = samples.count
                    let started = ContinuousClock.now
                    defer {
                        delay = Self.delayAfterPreview(duration: started.duration(to: .now), interval: previewInterval)
                    }
                    let text = try await transcribeForDisplay(samples: samples, id: id, expectedPhase: .recording)
                    guard sessionID == id, phase == .recording, !Task.isCancelled else { return }
                    previewText = text
                } catch is CancellationError { return }
                catch Qwen3TranscriberError.emptyTranscript { continue }
                catch {
                    guard sessionID == id, phase == .recording, !Task.isCancelled else { return }
                    previewUnavailable = true
                    previewText = ""
                    return // Final transcription remains available; never delete the model.
                }
            }
        }
    }

    /// Target start-to-start cadence, not an extra fixed wait after decoding.
    /// Slow/long passes get a proportional breather; never queue obsolete audio.
    static func delayAfterPreview(duration: Duration, interval: Duration) -> Duration {
        max(min(interval, .milliseconds(150)), max(interval - duration, duration / 4))
    }

    private func transcribeForDisplay(samples: [Float], id: UUID, expectedPhase: Phase) async throws -> String {
        cancelPrewarm() // Actual preview/final takes priority over any unfinished warm-up.
        let (stream, continuation) = AsyncStream<String>.makeStream(bufferingPolicy: .bufferingNewest(1))
        let previousLength = previewText.count
        let updates = Task { @MainActor [weak self] in
            for await text in stream {
                guard let self, sessionID == id, phase == expectedPhase, !Task.isCancelled else { return }
                // Each cumulative pass re-decodes its prefix. Don't flash back
                // to one character; the complete return can still correct it.
                if text.count >= previousLength { previewText = text }
            }
        }
        defer { continuation.finish(); updates.cancel() }
        return try await transcriber.transcribe(samples: samples, onPartialText: { text in
            continuation.yield(text)
        })
    }

    private func captureCompleted(_ result: Result<[Float], Error>) {
        guard phase == .recording else { return }
        let id = sessionID
        let previousPreview = previewTask
        previousPreview?.cancel()
        previewTask = nil
        recordingStartedAt = nil
        level = 0
        switch result {
        case .success(let samples):
            phase = .transcribing
            recognitionTask = Task { [weak self] in
                // Cooperative cancellation inside decoding gives the full pass
                // priority without ever running two jobs against one KV cache.
                await previousPreview?.value
                guard let self, sessionID == id, phase == .transcribing, !Task.isCancelled else { return }
                defer { if sessionID == id { recognitionTask = nil } }
                do {
                    let transcript = try await transcribeForDisplay(samples: samples, id: id, expectedPhase: .transcribing)
                    guard sessionID == id, phase == .transcribing, !Task.isCancelled else { return }
                    previewText = ""
                    if voiceprintChecker.isEnabled {
                        let segment = CollieVoiceprint.voicedRange(samples)
                        let decision: CollieVoiceprint.Decision = segment.count < CollieVoiceprint.minimumVoicedSamples
                            ? .unavailable : await voiceprintChecker.decision(for: samples, segment: segment)
                        guard sessionID == id, phase == .transcribing, !Task.isCancelled else { return }
                        switch decision {
                        case .mismatch:
                            pendingTranscript = transcript
                            voiceprintBlocked = true
                            notice = voiceText("这段不像你的声音，未填入")
                            phase = .ready
                            return
                        case .unavailable:
                            pendingTranscript = transcript
                            voiceprintBlocked = true
                            notice = segment.count < CollieVoiceprint.minimumVoicedSamples
                                ? voiceText("有效语音不足约 1 秒，无法核对声纹；文字未填入")
                                : voiceText("声纹不可用，请重新录制；文字未填入")
                            phase = .ready
                            return
                        case .bypass, .match: break
                        }
                    }
                    await deliverOrStore(transcript, id: id)
                } catch is CancellationError { /* Cancel never publishes text. */ }
                catch {
                    guard sessionID == id, phase == .transcribing, !Task.isCancelled else { return }
                    previewText = ""
                    let failure = Self.recognitionFailure(error)
                    fail(failure.message, kind: failure.kind)
                }
            }
        case .failure(let error):
            previewText = ""
            let failure = Self.captureFailure(error, fallback: voiceText("录音中断了，请再录一次。"))
            fail(failure.message, kind: failure.kind)
        }
    }

    private func deliverOrStore(_ transcript: String, id: UUID) async {
        guard sessionID == id else { return }
        // If foreground changed before the scene callback, retain the final text
        // locally for an explicit retry rather than dispatching into a hidden page.
        guard isForeground() else {
            pendingTranscript = transcript
            phase = .ready
            return
        }
        phase = .delivering
        let accepted = await deliverTranscript?(transcript) ?? false
        guard sessionID == id else { return }
        pendingTranscript = accepted ? nil : transcript
        voiceprintBlocked = false
        phase = .ready
        if accepted { showTransientNotice(voiceText("已填入，请确认后发送"), duration: .seconds(2)) }
    }

    private func showTransientNotice(_ message: String, duration: Duration = .seconds(2)) {
        notice = message
        let id = sessionID
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: duration)
            guard let self, self.sessionID == id, self.phase == .ready,
                  self.pendingTranscript == nil, self.notice == message else { return }
            self.notice = nil
        }
    }

    /// Deletes the ~950 MB cache only while nothing is recording, delivering, or retained.
    func removeModel() async {
        guard phase == .ready, pendingTranscript == nil else { return }
        cancelPrewarm()
        phase = .checkingModel
        do {
            try await transcriber.removeModel()
            hasAttemptedPrewarm = false
            phase = .needsModel
        } catch {
            await refreshModelState() // Report whatever actually remains installed.
        }
    }

    /// Only the app's own recorder errors carry vetted Chinese text; system errors never reach the card.
    static func captureFailure(_ error: Error, fallback: String) -> (message: String, kind: FailureKind) {
        switch error {
        case CollieAudioRecorderError.permissionDenied:
            return (voiceText("麦克风权限已关闭，请在系统设置中允许一呼使用麦克风。"), .microphonePermission)
        case let error as CollieAudioRecorderError: return (error.localizedDescription, .recording)
        case let error as ColliePCMError: return (error.localizedDescription, .recording)
        default: return (fallback, .recording)
        }
    }

    static func recognitionFailure(_ error: Error) -> (message: String, kind: FailureKind) {
        switch error {
        case Qwen3TranscriberError.emptyTranscript: return (voiceText("没有识别到语音，请再说一次。"), .recording)
        case Qwen3TranscriberError.modelMissing, Qwen3TranscriberError.modelLoadFailed:
            return (voiceText("语音模型无法加载，请重试。"), .model)
        default: return (voiceText("这段录音没能识别，请再说一次。"), .recording)
        }
    }

    private func fail(_ message: String, kind: FailureKind = .recording) {
        recordingStartedAt = nil
        notice = nil
        failureKind = kind
        phase = .failed(message)
    }
}
