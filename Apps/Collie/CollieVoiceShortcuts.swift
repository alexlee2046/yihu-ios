import AppIntents
import Observation

/// Hands shortcut requests (Action Button, Shortcuts, Back Tap, Siri, keyboard)
/// to the visible workbench. iOS only records in the foreground, so a request
/// waits until the shell is active and the voice controller is ready.
@MainActor
@Observable
final class CollieVoiceShortcutCenter {
    static let shared = CollieVoiceShortcutCenter()
    private(set) var pendingToggle = false
    private var requestedAt: ContinuousClock.Instant?
    /// A request that cannot run soon (busy, not set up) is dropped rather than
    /// starting the microphone much later without a fresh user action.
    /// Long enough for a cold launch to connect and load the model.
    static let lifetime: Duration = .seconds(30)

    func requestToggle(now: ContinuousClock.Instant = .now) {
        pendingToggle = true
        requestedAt = now
    }

    /// Returns true once per live request; the caller then starts or stops recording.
    func consumeToggle(now: ContinuousClock.Instant = .now) -> Bool {
        guard pendingToggle else { return false }
        pendingToggle = false
        defer { requestedAt = nil }
        guard let requestedAt else { return false }
        return requestedAt.duration(to: now) <= Self.lifetime
    }
}

struct ToggleVoiceInputIntent: AppIntent {
    static let title: LocalizedStringResource = "一呼语音输入"
    static let description = IntentDescription("打开一呼开始录音；录音时再次运行则结束，并把文字填入当前工作台（不会发送）。")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        CollieVoiceShortcutCenter.shared.requestToggle()
        return .result()
    }
}

struct CollieAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleVoiceInputIntent(),
            phrases: ["\(.applicationName) 语音输入", "用\(.applicationName)语音输入"],
            shortTitle: "语音输入",
            systemImageName: "mic.fill"
        )
    }
}
