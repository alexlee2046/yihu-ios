@preconcurrency import AVFoundation
import Foundation

enum CollieAudioCapturePreferences {
    struct SessionConfiguration {
        let category: AVAudioSession.Category
        let mode: AVAudioSession.Mode
        let options: AVAudioSession.CategoryOptions
    }

    static let nearFieldCaptureKey = "collie.nearFieldCaptureEnabled"

    static func nearFieldCaptureEnabled(defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: nearFieldCaptureKey) as? Bool ?? true
    }

    static func sessionConfiguration(nearFieldEnabled: Bool) -> SessionConfiguration {
        nearFieldEnabled
            ? SessionConfiguration(category: .playAndRecord, mode: .voiceChat,
                                   options: [.mixWithOthers, .allowBluetoothHFP])
            : SessionConfiguration(category: .record, mode: .default, options: [])
    }
}

struct CollieAudioInputGraphPolicy: Equatable {
    let enablesVoiceProcessing: Bool
    let configuresDucking: Bool
    let mutesMainMixer: Bool
    let connectsInputToMixer: Bool

    init(nearFieldEnabled: Bool) {
        enablesVoiceProcessing = nearFieldEnabled
        configuresDucking = nearFieldEnabled
        mutesMainMixer = nearFieldEnabled
        connectsInputToMixer = nearFieldEnabled
    }
}

struct CollieAudioRecoveryChangeDebouncer {
    static let defaultGracePeriod: TimeInterval = 2
    private let gracePeriod: TimeInterval
    private var expectedToken: UUID?
    private var deadline: Date?

    init(gracePeriod: TimeInterval = defaultGracePeriod) {
        self.gracePeriod = gracePeriod
    }

    mutating func arm(token: UUID, now: Date) {
        expectedToken = token
        deadline = now.addingTimeInterval(gracePeriod)
    }

    mutating func shouldSuppress(token: UUID, now: Date, engineIsRunning: Bool,
                                 inputFormatUnchanged: Bool, routeUnchanged: Bool) -> Bool {
        guard expectedToken == token else { return false }
        guard let deadline, now <= deadline, engineIsRunning, inputFormatUnchanged, routeUnchanged else {
            reset()
            return false
        }
        // Keep the expectation for the whole grace period: one recovery can emit several identical notifications.
        // A real same-route/same-format change in this window is intentionally ignored while capture keeps running.
        return true
    }

    mutating func reset() {
        expectedToken = nil
        deadline = nil
    }
}

@MainActor
final class CollieAudioRecorder: NSObject, CollieAudioCapturing {
    nonisolated static let maximumDuration: TimeInterval = 30

    var onCaptureCompleted: ((Result<[Float], Error>) -> Void)?
    var onLevelChanged: ((Float) -> Void)?

    private var engine: AVAudioEngine?
    private var pipeline: ColliePCMRecordingPipeline?
    private var activeToken: UUID?
    private var timeoutTask: Task<Void, Never>?
    private var meterTimer: Timer?
    private var notificationObservers: [NSObjectProtocol] = []
    private var recordingInputFormat: AVAudioFormat?
    private var recordingInputRouteSignature: [String]?
    private var expectedRecoveryChangeDebouncer = CollieAudioRecoveryChangeDebouncer()
    private var recordingUsesNearField = false
    private var pendingExportNearFieldEnabled = false
    private var recordingActive = false

    var isRecording: Bool { recordingActive }

    func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func start() throws {
        guard !recordingActive else { return }
        guard pipeline == nil else { throw CollieAudioRecorderError.busy }
        guard AVAudioApplication.shared.recordPermission == .granted else {
            throw CollieAudioRecorderError.permissionDenied
        }

        let session = AVAudioSession.sharedInstance()
        let useNearField = CollieAudioCapturePreferences.nearFieldCaptureEnabled()
        let configuration = CollieAudioCapturePreferences.sessionConfiguration(nearFieldEnabled: useNearField)
        // Activate before inspecting the input format; before activation some
        // devices report zero frames. The opt-out retains the old route unchanged.
        do {
            try session.setCategory(configuration.category, mode: configuration.mode, options: configuration.options)
            try session.setActive(true)
        } catch {
            try? session.setActive(false, options: [.notifyOthersOnDeactivation])
            throw error
        }

        let audioEngine = AVAudioEngine()
        let inputNode = audioEngine.inputNode
        let token = UUID()
        recordingUsesNearField = useNearField
        do {
            let format = try configureInputGraph(audioEngine, inputNode: inputNode, nearFieldEnabled: useNearField)
            let newPipeline = try ColliePCMRecordingPipeline(
                sourceFormat: format,
                maximumDuration: Self.maximumDuration
            )
            newPipeline.onCompleted = { [weak self] completion in
                Task { @MainActor [weak self] in
                    self?.captureCompleted(completion, token: token)
                }
            }
            inputNode.installTap(onBus: 0, bufferSize: 1_024, format: format, block: Self.makeTap(for: newPipeline))
            audioEngine.prepare()
            try audioEngine.start()
            pendingExportNearFieldEnabled = useNearField

            engine = audioEngine
            pipeline = newPipeline
            activeToken = token
            recordingInputFormat = format
            recordingInputRouteSignature = Self.inputRouteSignature(for: session)
        } catch {
            pendingExportNearFieldEnabled = false
            inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            recordingUsesNearField = false
            expectedRecoveryChangeDebouncer.reset()
            try? session.setActive(false, options: [.notifyOthersOnDeactivation])
            throw error
        }

        recordingActive = true
        installObservers(for: token)
        startMetering()
        startTimeout(for: token)
    }

    private func configureInputGraph(_ audioEngine: AVAudioEngine, inputNode: AVAudioInputNode,
                                     nearFieldEnabled: Bool) throws -> AVAudioFormat {
        let policy = CollieAudioInputGraphPolicy(nearFieldEnabled: nearFieldEnabled)
        if policy.enablesVoiceProcessing {
            try inputNode.setVoiceProcessingEnabled(true)
        }
        if policy.configuresDucking {
            inputNode.voiceProcessingOtherAudioDuckingConfiguration =
                AVAudioVoiceProcessingOtherAudioDuckingConfiguration(enableAdvancedDucking: false, duckingLevel: .min)
        }
        let format = inputNode.outputFormat(forBus: 0)
        if policy.mutesMainMixer {
            // Duplex render is required by voice processing; muting prevents its output from feeding the mic.
            audioEngine.mainMixerNode.outputVolume = 0
        }
        if policy.connectsInputToMixer {
            audioEngine.connect(inputNode, to: audioEngine.mainMixerNode, format: format)
        }
        return format
    }

    /// AVAudioNodeTapBlock is not annotated Sendable by the SDK. Constructing
    /// its closure in start() inherits MainActor under Swift 6 and traps on the
    /// real RealtimeMessenger queue. Keep this factory explicitly nonisolated.
    nonisolated static func makeTap(
        for pipeline: ColliePCMRecordingPipeline
    ) -> @Sendable (AVAudioPCMBuffer, AVAudioTime) -> Void {
        { [weak pipeline] buffer, _ in pipeline?.accept(buffer) }
    }

    func snapshot() throws -> [Float] {
        guard let pipeline else { throw CollieAudioRecorderError.notRecording }
        return try pipeline.snapshot()
    }

    func stop() {
        guard recordingActive, let pipeline else { return }
        recordingActive = false
        timeoutTask?.cancel()
        timeoutTask = nil
        // Stop accepting tap blocks first, then stop the engine. The pipeline
        // drains blocks already copied by the tap before flushing the converter.
        pipeline.requestStop()
        stopEngine()
    }

    func cancel() {
        timeoutTask?.cancel()
        timeoutTask = nil
        recordingActive = false
        activeToken = nil
        pendingExportNearFieldEnabled = false
        expectedRecoveryChangeDebouncer.reset()
        removeObservers()
        stopEngine()
        pipeline?.cancel()
        pipeline = nil
        finishSession()
    }

    private func captureCompleted(
        _ completion: ColliePCMRecordingPipeline.Completion,
        token: UUID
    ) {
        guard activeToken == token else { return }
        if case .success(let samples) = completion {
            // stop() clears the live flag before asynchronous drain completion; use its saved value.
            CollieCaptureExport.export(samples, nearFieldEnabled: pendingExportNearFieldEnabled)
        }
        pendingExportNearFieldEnabled = false
        activeToken = nil
        recordingActive = false
        expectedRecoveryChangeDebouncer.reset()
        timeoutTask?.cancel()
        timeoutTask = nil
        removeObservers()
        stopEngine()
        pipeline = nil
        finishSession()

        switch completion {
        case .success(let samples):
            onCaptureCompleted?(.success(samples))
        case .failure(let error):
            onCaptureCompleted?(.failure(error))
        }
    }

    private func stopEngine() {
        expectedRecoveryChangeDebouncer.reset()
        recordingUsesNearField = false
        guard let engine else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        self.engine = nil
        recordingInputFormat = nil
        recordingInputRouteSignature = nil
    }

    private func startTimeout(for token: UUID) {
        timeoutTask?.cancel()
        timeoutTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .seconds(Self.maximumDuration))
            } catch {
                return
            }
            guard let self, self.activeToken == token, self.recordingActive else { return }
            self.stop()
        }
    }

    private func startMetering() {
        meterTimer?.invalidate()
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, let pipeline = self.pipeline else { return }
                self.onLevelChanged?(pipeline.currentLevel())
            }
        }
    }

    private func installObservers(for token: UUID) {
        removeObservers()
        let center = NotificationCenter.default
        let names: [Notification.Name] = [
            Notification.Name.AVAudioEngineConfigurationChange,
            AVAudioSession.interruptionNotification,
            AVAudioSession.routeChangeNotification,
            AVAudioSession.mediaServicesWereLostNotification,
            AVAudioSession.mediaServicesWereResetNotification,
        ]
        notificationObservers = names.map { name in
            let source: AnyObject? = name == .AVAudioEngineConfigurationChange ? engine : nil
            let isEngineConfigurationChange = name == .AVAudioEngineConfigurationChange
            return center.addObserver(forName: name, object: source, queue: .main) { [weak recorder = self] notification in
                if name == AVAudioSession.interruptionNotification,
                   let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                   rawType != AVAudioSession.InterruptionType.began.rawValue { return }
                if name == AVAudioSession.routeChangeNotification,
                   let rawReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                   let reason = AVAudioSession.RouteChangeReason(rawValue: rawReason),
                   reason != .oldDeviceUnavailable,
                   reason != .noSuitableRouteForCategory {
                    return
                }
                Task { @MainActor [weak recorder] in
                    guard let recorder, recorder.activeToken == token, recorder.recordingActive else { return }
                    if isEngineConfigurationChange {
                        if recorder.consumeExpectedRecoveryConfigurationChange(for: token) { return }
                        recorder.recoverInputAfterEngineConfigurationChange(for: token)
                        return
                    }
                    recorder.pipeline?.fail(CollieAudioRecorderError.interrupted)
                    recorder.recordingActive = false
                    recorder.stopEngine()
                }
            }
        }
    }

    // The debouncer keeps its token for the whole grace period so duplicate restart notifications
    // do not cascade into repeated stop/start cycles.
    private func consumeExpectedRecoveryConfigurationChange(for token: UUID) -> Bool {
        let engineIsRunning = engine?.isRunning ?? false
        let inputFormatUnchanged: Bool
        if let engine, let recordingInputFormat {
            inputFormatUnchanged = Self.hasSameInputFormat(recordingInputFormat, engine.inputNode.outputFormat(forBus: 0))
        } else {
            inputFormatUnchanged = false
        }
        let routeUnchanged: Bool
        if let recordingInputRouteSignature {
            routeUnchanged = recordingInputRouteSignature == Self.inputRouteSignature(for: AVAudioSession.sharedInstance())
        } else {
            routeUnchanged = false
        }
        return expectedRecoveryChangeDebouncer.shouldSuppress(
            token: token, now: Date(), engineIsRunning: engineIsRunning,
            inputFormatUnchanged: inputFormatUnchanged, routeUnchanged: routeUnchanged)
    }

    private func recoverInputAfterEngineConfigurationChange(for token: UUID) {
        // Keep the converter and already captured PCM when the native input
        // format is unchanged; rebuild the engine tap as CollieNoteRecorder does.
        // A changed format cannot safely feed this converter and fails closed.
        guard activeToken == token, recordingActive,
              let engine, let pipeline, let recordingInputFormat else { return }
        let input = engine.inputNode
        engine.stop()
        input.removeTap(onBus: 0)
        let currentFormat: AVAudioFormat
        do {
            currentFormat = try configureInputGraph(engine, inputNode: input, nearFieldEnabled: recordingUsesNearField)
        } catch {
            failCaptureAfterEngineConfigurationChange(pipeline: pipeline)
            return
        }
        guard Self.hasSameInputFormat(recordingInputFormat, currentFormat) else {
            failCaptureAfterEngineConfigurationChange(pipeline: pipeline)
            return
        }

        input.installTap(onBus: 0, bufferSize: 1_024, format: currentFormat, block: Self.makeTap(for: pipeline))
        engine.prepare()
        expectedRecoveryChangeDebouncer.arm(token: token, now: Date())
        do {
            try engine.start()
            recordingInputRouteSignature = Self.inputRouteSignature(for: AVAudioSession.sharedInstance())
        } catch {
            failCaptureAfterEngineConfigurationChange(pipeline: pipeline)
        }
    }

    private func failCaptureAfterEngineConfigurationChange(pipeline: ColliePCMRecordingPipeline) {
        expectedRecoveryChangeDebouncer.reset()
        recordingActive = false
        pipeline.fail(CollieAudioRecorderError.interrupted)
        stopEngine()
    }

    private static func inputRouteSignature(for session: AVAudioSession) -> [String] {
        session.currentRoute.inputs.map(\.uid).sorted()
    }

    private static func hasSameInputFormat(_ lhs: AVAudioFormat, _ rhs: AVAudioFormat) -> Bool {
        lhs.sampleRate == rhs.sampleRate
            && lhs.channelCount == rhs.channelCount
            && lhs.commonFormat == rhs.commonFormat
            && lhs.isInterleaved == rhs.isInterleaved
    }

    private func removeObservers() {
        let center = NotificationCenter.default
        for observer in notificationObservers { center.removeObserver(observer) }
        notificationObservers.removeAll()
    }

    private func finishSession() {
        meterTimer?.invalidate()
        meterTimer = nil
        onLevelChanged?(0)
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }
}

enum CollieAudioRecorderError: LocalizedError {
    case startFailed
    case interrupted
    case tooShort
    case permissionDenied
    case notRecording
    case busy

    var errorDescription: String? {
        switch self {
        case .startFailed:
            return "无法启动录音，请重试。"
        case .interrupted:
            return "录音被系统中断，请重试。"
        case .tooShort:
            return "录音太短，请按住片刻后再试。"
        case .permissionDenied:
            return "请先允许麦克风权限。"
        case .notRecording:
            return "当前没有录音。"
        case .busy:
            return "上一段录音仍在结束，请稍后重试。"
        }
    }
}
