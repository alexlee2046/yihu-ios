import ActivityKit
import Foundation
import Observation
import UIKit
import UserNotifications

/// Hermes task reminders: registers this iPhone's APNs and Live Activity tokens
/// with the tailnet-only relay on your separately configured server, which pushes progress and completion
/// for tasks started in the Hermes WebUI. The relay authenticates the caller by
/// its Tailscale identity, so no secret lives in the app.
@MainActor
@Observable
final class CollieHermesPush {
    static let shared = CollieHermesPush()
    static let defaultRelay = URL(string: "https://relay.example.invalid")!
    private static let webUIPort = 9444
    private static let enabledKey = "hermes.push.enabled"
    private static let deviceKey = "hermes.push.device-id"
    private static let relayURLKey = "hermes.push.relay-url"

    enum Status: Equatable { case off, registering, on, failed(String) }

    /// Callback providing known trusted origins, decoupling Hermes session matching from Relay host.
    var knownOrigins: (() -> [URL])?

    private(set) var status: Status = .off
    /// What the switch shows: flips immediately, before the permission prompt resolves.
    private(set) var isRequested = false
    /// A notification tap asked to open this Hermes WebUI URL; the shell consumes it.
    private(set) var pendingURL: URL?

    private let defaults: UserDefaults
    private let session: URLSession
    private var apnsToken: String?
    private var pushToStartToken: String?
    private var observers: [Task<Void, Never>] = []
    private var watchedActivities: Set<String> = []
    /// Serializes device registration so the relay always ends with the latest tokens.
    private var registration: Task<Void, Never>?

    init(defaults: UserDefaults = .standard, session: URLSession = .shared) {
        self.defaults = defaults
        self.session = session
        isRequested = defaults.bool(forKey: Self.enabledKey)
    }

    var isEnabled: Bool { defaults.bool(forKey: Self.enabledKey) }

    /// The user-configured relay address string, if any.
    var configuredRelayString: String {
        get { defaults.string(forKey: Self.relayURLKey) ?? "" }
        set {
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                defaults.removeObject(forKey: Self.relayURLKey)
            } else {
                defaults.set(trimmed, forKey: Self.relayURLKey)
            }
        }
    }

    /// The active Relay URL: configured URL takes precedence, followed by suggested URL, then default invalid relay.
    var relayURL: URL? {
        let configured = configuredRelayString
        if !configured.isEmpty, let url = Self.validateRelayURL(configured) {
            return url
        }
        if let suggested = Self.suggestedRelayURL(for: knownOrigins?() ?? []) {
            return suggested
        }
        return Self.defaultRelay
    }

    /// Strictly validates a custom relay URL: requires HTTPS, valid host, no query/fragment/credentials.
    static func validateRelayURL(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let url = URL(string: trimmed),
              url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil,
              url.query == nil, url.fragment == nil else {
            return nil
        }
        return url
    }

    /// Suggests a relay endpoint based on known Hermes or port 9444 origins.
    static func suggestedRelayURL(for origins: [URL]) -> URL? {
        for origin in origins {
            if origin.port == webUIPort || origin.absoluteString.localizedCaseInsensitiveContains("hermes") {
                if let host = origin.host {
                    return URL(string: "https://\(host):\(webUIPort)")
                }
            }
        }
        return nil
    }

    /// Updates the custom relay URL. If reminders are currently enabled, reschedules device registration.
    func updateRelayURL(_ raw: String) {
        configuredRelayString = raw
        if isEnabled {
            scheduleRegistration()
        }
    }

    var deviceID: String {
        if let id = defaults.string(forKey: Self.deviceKey) { return id }
        let id = UUID().uuidString
        defaults.set(id, forKey: Self.deviceKey)
        return id
    }

    /// Resumes observation after launch if the user turned reminders on earlier.
    func resumeIfEnabled() {
        guard isEnabled else { return }
        status = .registering
        startObserving()
        UIApplication.shared.registerForRemoteNotifications()
    }

    /// Retries a failed registration, e.g. when the app returns after Tailscale came back.
    func retryIfNeeded() {
        guard isEnabled, case .failed = status else { return }
        if apnsToken == nil { resumeIfEnabled() } else { scheduleRegistration() }
    }

    func enable() async {
        isRequested = true
        status = .registering
        let granted = (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        guard isRequested else { return } // turned off while the prompt was up
        guard granted else {
            isRequested = false
            status = .failed(NSLocalizedString("请在系统设置中允许一呼发送通知。", tableName: "Yihu", comment: ""))
            return
        }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            isRequested = false
            status = .failed(NSLocalizedString("请在系统设置中允许一呼使用「实时活动」。", tableName: "Yihu", comment: ""))
            return
        }
        defaults.set(true, forKey: Self.enabledKey)
        startObserving()
        UIApplication.shared.registerForRemoteNotifications()
    }

    /// Stops reminders here and on the relay, and ends any task cards on screen.
    func disable() {
        isRequested = false
        defaults.set(false, forKey: Self.enabledKey)
        observers.forEach { $0.cancel() }
        observers = []
        watchedActivities = []
        registration?.cancel()
        registration = nil
        status = .off
        let deviceID = deviceID
        Task {
            await delete(path: "/v1/devices/\(deviceID)")
            for activity in Activity<HermesTaskAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    func didRegister(deviceToken: Data) {
        apnsToken = deviceToken.map { String(format: "%02x", $0) }.joined()
        scheduleRegistration()
    }

    func didFailToRegister() {
        guard isEnabled else { return }
        status = .failed(NSLocalizedString("无法开启推送，请检查网络后重试。", tableName: "Yihu", comment: ""))
    }

    /// Offer owner-only reminders only after that host is saved; retain the
    /// off switch for an existing registration even if its workbench is removed.
    func shouldShowSettings(for origins: [URL]) -> Bool {
        isRequested || isEnabled || !configuredRelayString.isEmpty || origins.contains {
            $0.port == Self.webUIPort || $0.absoluteString.localizedCaseInsensitiveContains("hermes")
        }
    }

    /// Validates whether a raw URL string belongs to a trusted Hermes session over HTTPS.
    /// Decoupled from Relay host: accepts if it matches any known workbench origin,
    /// or if it matches the default webUIPort (9444), or if it matches the configured relay host over HTTPS.
    static func isHermesSessionURL(_ raw: Any?, knownOrigins: [URL]? = nil) -> URL? {
        guard let raw = raw as? String, let url = URL(string: raw),
              url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty else { return nil }
        let origins = knownOrigins ?? shared.knownOrigins?() ?? []
        if !origins.isEmpty {
            let matches = origins.contains { known in
                known.host?.lowercased() == host.lowercased() &&
                (known.port ?? 443) == (url.port ?? 443)
            }
            if matches { return url }
        }
        if url.port == webUIPort { return url }
        if let relay = shared.relayURL, relay.host != "relay.example.invalid",
           host.lowercased() == relay.host?.lowercased() {
            return url
        }
        return nil
    }

    /// Whether a foreground notification is a live Hermes reminder worth showing.
    func shouldPresent(userInfo: [AnyHashable: Any]) -> Bool {
        isEnabled && Self.isHermesSessionURL(userInfo["url"], knownOrigins: knownOrigins?()) != nil
    }

    @discardableResult
    func handleTap(userInfo: [AnyHashable: Any]) -> Bool {
        guard let url = Self.isHermesSessionURL(userInfo["url"], knownOrigins: knownOrigins?()) else { return false }
        pendingURL = url
        return true
    }

    func consumePendingURL() -> URL? {
        defer { pendingURL = nil }
        return pendingURL
    }

    private func startObserving() {
        guard observers.isEmpty else { return }
        observers.append(Task { [weak self] in
            for await data in Activity<HermesTaskAttributes>.pushToStartTokenUpdates {
                guard let self else { return }
                self.pushToStartToken = data.map { String(format: "%02x", $0) }.joined()
                self.scheduleRegistration()
            }
        })
        observers.append(Task { [weak self] in
            for await activity in Activity<HermesTaskAttributes>.activityUpdates {
                self?.watch(activity)
            }
        })
        Activity<HermesTaskAttributes>.activities.forEach(watch)
    }

    private func watch(_ activity: Activity<HermesTaskAttributes>) {
        guard !watchedActivities.contains(activity.id) else { return }
        watchedActivities.insert(activity.id)
        let body = ["device_id": deviceID, "session_id": activity.attributes.sessionId]
        observers.append(Task { [weak self] in
            for await data in activity.pushTokenUpdates {
                var request = body
                request["update_token"] = data.map { String(format: "%02x", $0) }.joined()
                // A lost update token means the card never moves: retry briefly.
                for attempt in 0..<3 {
                    if await self?.post(path: "/v1/activities", body: request) != false { break }
                    try? await Task.sleep(for: .seconds(2 << attempt))
                }
            }
        })
    }

    /// Chains registrations: each one sends every token known at that moment.
    private func scheduleRegistration() {
        let previous = registration
        registration = Task { [weak self] in
            await previous?.value
            await self?.registerDevice()
        }
    }

    private func registerDevice() async {
        guard isEnabled, let apnsToken, !Task.isCancelled else { return }
        guard let relay = relayURL, relay.host != "relay.example.invalid" else {
            status = .failed(NSLocalizedString("请先在设置中填写有效的 HTTPS Hermes Relay 服务地址。", tableName: "Yihu", comment: ""))
            return
        }
        var body: [String: String] = [
            "device_id": deviceID, "apns_token": apnsToken, "environment": Self.environment,
        ]
        if let pushToStartToken { body["push_to_start_token"] = pushToStartToken }
        let ok = await post(path: "/v1/devices", body: body)
        guard isEnabled, !Task.isCancelled else { return }
        status = ok ? .on : .failed(NSLocalizedString("无法连接 Hermes 提醒服务，请确认地址正确并已开启 Tailscale。", tableName: "Yihu", comment: ""))
    }

    @discardableResult
    private func post(path: String, body: [String: String]) async -> Bool {
        guard let relay = relayURL, relay.host != "relay.example.invalid" else { return false }
        var request = URLRequest(url: relay.appending(path: path))
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return await send(request)
    }

    private func delete(path: String) async {
        guard let relay = relayURL, relay.host != "relay.example.invalid" else { return }
        var request = URLRequest(url: relay.appending(path: path))
        request.httpMethod = "DELETE"
        request.timeoutInterval = 15
        _ = await send(request)
    }

    private func send(_ request: URLRequest) async -> Bool {
        guard let (_, response) = try? await session.data(for: request),
              let http = response as? HTTPURLResponse else { return false }
        return (200..<300).contains(http.statusCode)
    }

    /// Development-signed builds talk to the APNs sandbox, like Collie.
    static var environment: String {
        APNSConfiguration.current()?.environment == .production ? "production" : "sandbox"
    }
}
