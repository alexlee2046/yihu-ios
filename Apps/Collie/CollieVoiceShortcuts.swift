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
    private(set) var pendingOpenRadarActions = false
    private var radarRequestedAt: ContinuousClock.Instant?
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

    func requestOpenRadarActions(now: ContinuousClock.Instant = .now) {
        pendingOpenRadarActions = true
        radarRequestedAt = now
    }

    func consumeOpenRadarActions(now: ContinuousClock.Instant = .now) -> Bool {
        guard pendingOpenRadarActions else { return false }
        pendingOpenRadarActions = false
        defer { radarRequestedAt = nil }
        guard let radarRequestedAt else { return false }
        return radarRequestedAt.duration(to: now) <= Self.lifetime
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

struct OpenRadarActionsIntent: AppIntent {
    static let title: LocalizedStringResource = "打开一呼待我处理"
    static let description = IntentDescription("打开一呼并切换到 PM Radar 的「待我处理」视图。")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        CollieVoiceShortcutCenter.shared.requestOpenRadarActions()
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
        AppShortcut(
            intent: OpenRadarActionsIntent(),
            phrases: ["打开\(.applicationName)待我处理", "查看\(.applicationName)待办决策"],
            shortTitle: "待我处理",
            systemImageName: "scope"
        )
    }
}
