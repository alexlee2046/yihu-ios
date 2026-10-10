import CryptoKit
import Foundation

private func notifyText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}
import Observation
import Security
import SwiftUI
import UIKit
import UserNotifications
import WebKit

// MARK: - Web bridge contract

/// The value returned by the page's authenticated `api.ts` wrapper. Native
/// code deliberately knows no access token: the page owns authentication.
struct CollieNativePushResponse: Codable, Equatable, Sendable {
    let ok: Bool
    let reason: String?
    let available: Bool?
    let environment: String?
    let topic: String?
    let registrationId: String?
    let expiresAt: String?

    init(
        ok: Bool,
        reason: String? = nil,
        available: Bool? = nil,
        environment: String? = nil,
        topic: String? = nil,
        registrationId: String? = nil,
        expiresAt: String? = nil
    ) {
        self.ok = ok
        self.reason = reason
        self.available = available
        self.environment = environment
        self.topic = topic
        self.registrationId = registrationId
        self.expiresAt = expiresAt
    }
}

@MainActor
protocol CollieNativePushWebClient: Sendable {
    func request(
        operation: String,
        payload: [String: String],
        in session: CollieWebSession?
    ) async -> CollieNativePushResponse
}

@MainActor
private final class CollieNativePushSessionClient: CollieNativePushWebClient {
    func request(
        operation: String,
        payload: [String: String],
        in session: CollieWebSession?
    ) async -> CollieNativePushResponse {
        guard let session else {
            return CollieNativePushResponse(ok: false, reason: "web session unavailable")
        }
        return await session.nativePushRequest(operation: operation, payload: payload)
    }
}

// MARK: - Secure local binding storage

struct CollieNativePushBinding: Codable, Equatable, Sendable {
    let installationId: String
    let secret: String
    var registrationId: String?
    var expiresAt: String?
    var unregisterPending: Bool
}

@MainActor
protocol CollieNativePushKeychain {
    func load(origin: String) -> CollieNativePushBinding?
    @discardableResult
    func save(_ binding: CollieNativePushBinding, origin: String) -> Bool
}

/// One generic-password item per normalized HTTPS origin. Secrets and the
/// installation identifier never enter UserDefaults, logs, or notification
/// payloads.
@MainActor
final class CollieNativePushKeychainStore: CollieNativePushKeychain {
    private let service: String

    init(bundleIdentifier: String? = Bundle.main.bundleIdentifier) {
        service = "collie.native-push.v1.\(bundleIdentifier ?? "unknown")"
    }

    func load(origin: String) -> CollieNativePushBinding? {
        var query = baseQuery(origin: origin)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(CollieNativePushBinding.self, from: data)
    }

    @discardableResult
    func save(_ binding: CollieNativePushBinding, origin: String) -> Bool {
        guard let data = try? JSONEncoder().encode(binding) else { return false }
        let query = baseQuery(origin: origin)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var add = query
            attributes.forEach { add[$0.key] = $0.value }
            return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
        }
        return status == errSecSuccess
    }

    private func baseQuery(origin: String) -> [String: Any] {
        let digest = SHA256.hash(data: Data(origin.utf8))
        let account = digest.map { String(format: "%02x", $0) }.joined()
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

// MARK: - Injectable system dependencies

enum CollieNativePushAuthorizationStatus: Equatable, Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    var isUsable: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral: return true
        case .notDetermined, .denied: return false
        }
    }
}

@MainActor
protocol CollieNativePushNotificationCenter {
    func settings() async -> CollieNativePushAuthorizationStatus
    func requestAuthorization() async -> Bool
}

@MainActor
private struct SystemCollieNativePushNotificationCenter: CollieNativePushNotificationCenter {
    func settings() async -> CollieNativePushAuthorizationStatus {
        let value = await UNUserNotificationCenter.current().notificationSettings()
        switch value.authorizationStatus {
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .ephemeral
        case .denied: return .denied
        default: return .notDetermined
        }
    }

    func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }
}

@MainActor
protocol CollieNativePushRemoteRegistrar {
    func registerForRemoteNotifications()
}

@MainActor
private struct SystemCollieNativePushRemoteRegistrar: CollieNativePushRemoteRegistrar {
    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
}

// MARK: - Route and configuration validation

enum CollieNativeNotificationRoute {
    /// Returns a URL on `origin` only for a strict absolute-path route. This
    /// rejects encoded origin escapes, traversal, schemes, credentials, and
    /// backslashes before WebKit's normal navigation policy gets involved.
    static func resolve(_ rawPath: String, relativeTo origin: URL) -> URL? {
        guard !rawPath.isEmpty,
              rawPath.first == "/",
              !rawPath.hasPrefix("//"),
              rawPath.unicodeScalars.allSatisfy({ $0.value >= 0x20 && $0.value != 0x7f })
        else { return nil }

        guard let decoded = rawPath.removingPercentEncoding,
              decoded.unicodeScalars.allSatisfy({ $0.value >= 0x20 && $0.value != 0x7f }),
              !decoded.contains("\\"),
              !decoded.hasPrefix("//"),
              !decoded.contains("://"),
              !decoded.split(separator: "/").contains(where: { $0 == "." || $0 == ".." })
        else { return nil }

        guard let components = URLComponents(string: rawPath),
              components.scheme == nil,
              components.host == nil,
              components.user == nil,
              components.password == nil,
              components.path.first == "/",
              !components.path.hasPrefix("//"),
              let validOrigin = CollieConnectionOrigin.validate(origin.absoluteString)
        else { return nil }

        var route = URLComponents()
        route.scheme = "https"
        route.host = validOrigin.host?.lowercased()
        if let port = validOrigin.port { route.port = port }
        route.percentEncodedPath = components.percentEncodedPath
        route.percentEncodedQuery = components.percentEncodedQuery
        route.fragment = components.fragment
        guard let url = route.url,
              sameOrigin(url, validOrigin)
        else { return nil }
        return url
    }

    private static func sameOrigin(_ lhs: URL, _ rhs: URL) -> Bool {
        lhs.scheme?.lowercased() == rhs.scheme?.lowercased()
            && lhs.host?.lowercased() == rhs.host?.lowercased()
            && effectivePort(lhs) == effectivePort(rhs)
    }

    private static func effectivePort(_ url: URL) -> Int? {
        if let port = url.port { return port }
        return url.scheme?.lowercased() == "https" ? 443 : nil
    }
}

enum CollieNativePushStatus: Equatable, Sendable {
    case disabled
    case checkingService
    case requestingPermission
    case waitingForDeviceToken
    case registering
    case refreshing
    case enabled
    case authorizationDenied
    case serviceUnavailable
    case needsPairing
    case unregistering
    case unbindPending
    case error(String)

    var title: String {
        switch self {
        case .disabled: return notifyText("通知未开启")
        case .checkingService, .requestingPermission, .waitingForDeviceToken, .registering: return notifyText("正在开启通知…")
        case .refreshing: return notifyText("正在更新通知…")
        case .enabled: return notifyText("通知已开启")
        case .authorizationDenied: return notifyText("系统通知已关闭")
        case .serviceUnavailable: return notifyText("当前无法开启通知")
        case .needsPairing: return notifyText("需要先完成工作台配对")
        case .unregistering: return notifyText("正在完成停用…")
        case .unbindPending: return notifyText("上一次停用未完成")
        case .error(let reason): return reason
        }
    }
}

// MARK: - Controller

@MainActor
@Observable
final class CollieNativeNotificationsController {
    private let defaults: UserDefaults
    @ObservationIgnored private let keychain: CollieNativePushKeychain
    @ObservationIgnored private let notificationCenter: CollieNativePushNotificationCenter
    @ObservationIgnored private let registrar: CollieNativePushRemoteRegistrar
    @ObservationIgnored private let webClient: CollieNativePushWebClient
    @ObservationIgnored private let apnsConfiguration: APNSConfiguration?
    @ObservationIgnored private let requestTimeout: Duration
    @ObservationIgnored private var refreshTask: Task<Void, Never>?

    private(set) var status: CollieNativePushStatus = .disabled
    private(set) var notice: String?
    private(set) var navigationNotice: String?
    private(set) var activeOrigin: URL?
    private weak var activeSession: CollieWebSession?
    private var generation = 0
    private var pendingDeviceToken: Data?
    private var registrationGeneration: Int?
    private var pendingNotification: CollieNativeNotificationPayload?
    private var pendingReceivedAt: Date?
    @ObservationIgnored var now: @MainActor () -> Date = Date.init
    var canNavigate: @MainActor () -> Bool = { true }
    var navigationBlockReason: @MainActor () -> String? = { nil }
    var knownOrigins: @MainActor () -> [URL] = { [] }
    /// nil on success; otherwise the reason to show in the home header.
    var onSwitchOrigin: (@MainActor (URL) -> String?)?
    /// Reveal the browser workspace after a validated notification opens there.
    var onOpenWorkbench: (@MainActor () -> Void)?

    func clearNavigationNotice() {
        if notice == navigationNotice { notice = nil }
        navigationNotice = nil
    }

    private func blockNavigation(_ reason: String) {
        notice = reason
        navigationNotice = reason
    }

    var hasPendingUnregister: Bool {
        guard let activeOrigin else { return false }
        let binding = keychain.load(origin: activeOrigin.absoluteString)
        return status == .unbindPending || binding?.unregisterPending == true
            || (!isEnabled && binding?.registrationId != nil)
    }

    init(
        defaults: UserDefaults = .standard,
        keychain: CollieNativePushKeychain = CollieNativePushKeychainStore(),
        notificationCenter: CollieNativePushNotificationCenter = SystemCollieNativePushNotificationCenter(),
        registrar: CollieNativePushRemoteRegistrar = SystemCollieNativePushRemoteRegistrar(),
        webClient: CollieNativePushWebClient = CollieNativePushSessionClient(),
        apnsConfiguration: APNSConfiguration? = APNSConfiguration.current(),
        requestTimeout: Duration = .seconds(10)
    ) {
        self.defaults = defaults
        self.keychain = keychain
        self.notificationCenter = notificationCenter
        self.registrar = registrar
        self.webClient = webClient
        self.apnsConfiguration = apnsConfiguration
        self.requestTimeout = requestTimeout
    }

    var isEnabled: Bool {
        guard let activeOrigin else { return false }
        return isEnabled(for: activeOrigin)
    }

    func isEnabled(for origin: URL) -> Bool {
        guard let key = originKey(for: origin) else { return false }
        return defaults.bool(forKey: key)
    }

    /// The Settings → Change Workbench flow explicitly unbinds an old origin.
    /// The home quick-switch never calls disable() and keeps bindings for all origins.
    var isBusy: Bool {
        return switch status {
        case .checkingService, .requestingPermission, .waitingForDeviceToken, .registering, .refreshing, .unregistering: true
        default: false
        }
    }
    func canChangeOrigin(from origin: URL) -> Bool { !isEnabled(for: origin) && !isBusy }
    var canChangeOrigin: Bool { !isEnabled && !isBusy }

    /// Installs the current web session and invalidates every result belonging
    /// to the previous origin. An already-enabled binding is refreshed without
    /// asking for permission again.
    func activate(session: CollieWebSession) {
        generation += 1
        refreshTask?.cancel()
        refreshTask = nil
        activeSession = session
        activeOrigin = canonicalOrigin(session.baseURL)
        clearNavigationNotice()
        notice = nil
        guard let origin = activeOrigin else {
            status = .serviceUnavailable
            notice = notifyText("当前工作台地址不支持通知，请使用 HTTPS 地址。")
            return
        }
        if isEnabled(for: origin) {
            status = .enabled
        } else if let binding = keychain.load(origin: origin.absoluteString), binding.unregisterPending || binding.registrationId != nil {
            status = .unbindPending
            notice = notifyText("为避免通知发错工作台，当前还不能开启通知。原工作台可能最多继续收到 7 天通用提醒。")
        } else {
            status = .disabled
        }
        processPendingNotificationIfPossible()
    }

    func applicationDidBecomeActive(session: CollieWebSession) {
        processPendingNotificationIfPossible()
        guard !isBusy, activeSession === session, let origin = activeOrigin, isEnabled(for: origin) else { return }
        refreshTask?.cancel()
        let requestGeneration = generation
        status = .refreshing
        refreshTask = Task { @MainActor [weak self, weak session] in
            guard let self, let session else { return }
            await self.refreshExisting(session: session, origin: origin, generation: requestGeneration)
        }
    }

    /// Explicit user action. The server is checked before iOS presents its
    /// permission sheet, and local enabled is committed only after registration.
    func enable(session: CollieWebSession) async {
        guard activeSession === session, let origin = activeOrigin,
              canonicalOrigin(session.baseURL) == origin else { return }
        guard !isEnabled(for: origin) else { return }
        generation += 1
        let requestGeneration = generation
        refreshTask?.cancel()
        notice = nil
        status = .checkingService

        guard let configuration = apnsConfiguration else {
            fail(.serviceUnavailable, notifyText("当前工作台暂时无法开启通知。"))
            return
        }
        guard let service = await webRequest("status", payload: [:], session: session, timeout: .seconds(10)) else {
            guard isCurrent(requestGeneration, session: session) else { return }
            fail(.serviceUnavailable, notifyText("当前工作台暂时无法开启通知。"))
            return
        }
        guard isCurrent(requestGeneration, session: session) else { return }
        guard service.ok,
              service.available == true,
              service.environment == configuration.environment.rawValue,
              service.topic == configuration.topic else {
            fail(.serviceUnavailable, notifyText("当前工作台暂时无法开启通知。"))
            return
        }

        var authorization = await notificationCenter.settings()
        if authorization == .notDetermined {
            status = .requestingPermission
            let granted = await notificationCenter.requestAuthorization()
            guard isCurrent(requestGeneration, session: session) else { return }
            guard granted else {
                fail(.authorizationDenied, notifyText("请在 iPhone“设置”中允许一呼发送通知。"))
                return
            }
            authorization = await notificationCenter.settings()
            guard isCurrent(requestGeneration, session: session) else { return }
        }
        guard isCurrent(requestGeneration, session: session) else { return }
        guard authorization.isUsable else {
            fail(.authorizationDenied, notifyText("请在 iPhone“设置”中允许一呼发送通知。"))
            return
        }

        status = .waitingForDeviceToken
        pendingDeviceToken = nil
        registrationGeneration = requestGeneration
        registrar.registerForRemoteNotifications()
        guard let token = await waitForDeviceToken(generation: requestGeneration, session: session) else {
            guard isCurrent(requestGeneration, session: session) else { return }
            registrationGeneration = nil
            fail(.error(notifyText("无法开启通知，请稍后重试。")), nil)
            return
        }
        guard isCurrent(requestGeneration, session: session) else { return }
        await completeRegistration(
            token: token, origin: origin, configuration: configuration,
            session: session, generation: requestGeneration, enabling: true
        )
    }

    /// Marks local disabled before touching the network. The old binding is
    /// retained in Keychain so an offline unregister can be retried later.
    func disable(session: CollieWebSession? = nil) async {
        let oldSession = session ?? activeSession
        let oldOrigin = oldSession.flatMap { canonicalOrigin($0.baseURL) } ?? activeOrigin
        guard let origin = oldOrigin else { return }
        guard isEnabled(for: origin) || isBusy || keychain.load(origin: origin.absoluteString)?.unregisterPending == true else {
            status = .disabled
            return
        }

        generation += 1
        refreshTask?.cancel()
        refreshTask = nil
        registrationGeneration = nil
        pendingDeviceToken = nil
        defaults.set(false, forKey: originKey(for: origin)!)
        status = .unbindPending
        notice = notifyText("为避免通知发错工作台，当前还不能开启通知。原工作台可能最多继续收到 7 天通用提醒。")

        guard let binding = keychain.load(origin: origin.absoluteString) else {
            status = .disabled
            notice = nil
            return
        }
        var retained = binding
        retained.unregisterPending = true
        _ = keychain.save(retained, origin: origin.absoluteString)

        let response = await webRequest(
            "unregister",
            payload: ["installationId": binding.installationId, "secret": binding.secret],
            session: oldSession,
            timeout: .seconds(10)
        )
        guard let response, response.ok else {
            if activeSession === oldSession { status = .unbindPending }
            return
        }
        guard rotateUnregisteredBinding(binding, origin: origin) else { return }
        if activeSession === oldSession, !isEnabled(for: origin) {
            status = .disabled
            notice = nil
        }
    }

    /// Retries a previously failed best-effort unregister while the old
    /// session is still available. The local disabled decision is unchanged.
    func retryUnregister(session: CollieWebSession) async {
        guard let origin = canonicalOrigin(session.baseURL),
              let binding = keychain.load(origin: origin.absoluteString),
              !isEnabled(for: origin) else { return }
        generation += 1
        status = .unregistering
        notice = notifyText("正在联系原工作台，请稍候。")
        let response = await webRequest(
            "unregister",
            payload: ["installationId": binding.installationId, "secret": binding.secret],
            session: session,
            timeout: .seconds(10)
        )
        guard activeSession === session else { return }
        guard let response else {
            status = .unbindPending
            notice = notifyText("无法连接工作台，请保持工作台已加载后重试。")
            return
        }
        guard response.ok else {
            status = .unbindPending
            notice = response.reason?.localizedPushReason ?? notifyText("无法完成停用，请稍后重试。")
            return
        }
        guard rotateUnregisteredBinding(binding, origin: origin) else {
            status = .unbindPending
            notice = notifyText("停用已在工作台完成，但本机还未保存结果。请重试。")
            return
        }
        status = .disabled
        notice = nil
    }

    func didRegister(deviceToken: Data) {
        guard let registrationGeneration, registrationGeneration == generation else { return }
        pendingDeviceToken = deviceToken
    }

    func didFailToRegister(error: Error) {
        guard registrationGeneration == generation else { return }
        registrationGeneration = nil
        notice = nil
        status = .error(notifyText("无法开启通知，请稍后重试。"))
    }

    func shouldPresent(notificationUserInfo: [AnyHashable: Any]) -> Bool {
        guard let payload = CollieNativeNotificationPayload(userInfo: notificationUserInfo) else { return false }
        return shouldPresent(payload: payload)
    }

    private func origin(for payload: CollieNativeNotificationPayload) -> URL? {
        var seen = Set<String>()
        let candidates = ([activeOrigin].compactMap { $0 } + knownOrigins()).compactMap(canonicalOrigin)
            .filter { seen.insert($0.absoluteString).inserted }
        let matches = candidates.filter { origin in
            isEnabled(for: origin)
                && keychain.load(origin: origin.absoluteString)?.registrationId == payload.registrationId
        }
        // Prefer the already active binding; never switch for other ambiguity.
        if let activeOrigin, matches.contains(activeOrigin) { return activeOrigin }
        return matches.count == 1 ? matches[0] : nil
    }

    func shouldPresent(payload: CollieNativeNotificationPayload) -> Bool {
        origin(for: payload) != nil
    }

    /// Handles warm and cold-start taps. Only a locally registered, enabled
    /// known workbench can be selected; its route is validated before switching.
    func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let payload = CollieNativeNotificationPayload(userInfo: userInfo) else { return }
        handleNotification(payload: payload)
    }

    func handleNotification(payload: CollieNativeNotificationPayload) {
        pendingNotification = payload
        pendingReceivedAt = now()
        processPendingNotificationIfPossible()
    }

    private func processPendingNotificationIfPossible() {
        guard let payload = pendingNotification, let receivedAt = pendingReceivedAt else { return }
        guard now().timeIntervalSince(receivedAt) < 300 else {
            pendingNotification = nil
            pendingReceivedAt = nil
            return
        }
        guard let activeOrigin else { return }
        // Select a verified destination immediately; its WebView alone awaits loading.
        if origin(for: payload) == activeOrigin {
            guard let session = activeSession, session.webView != nil, !session.isLoading else { return }
        }
        pendingNotification = nil
        pendingReceivedAt = nil
        resolve(payload, receivedAt: receivedAt)
    }

    private func resolve(_ payload: CollieNativeNotificationPayload, receivedAt: Date) {
        guard let origin = origin(for: payload),
              let route = CollieNativeNotificationRoute.resolve(payload.path, relativeTo: origin) else { return }
        guard canNavigate() else {
            blockNavigation(navigationBlockReason() ?? notifyText("请先完成语音输入或处理保留文字。"))
            return
        }
        if activeOrigin != origin {
            guard let onSwitchOrigin else {
                blockNavigation(notifyText("无法切换到通知所属的工作台，请手动检查。"))
                return
            }
            if let reason = onSwitchOrigin(origin) {
                blockNavigation(reason)
                return
            }
            guard activeOrigin == origin else {
                blockNavigation(notifyText("无法切换到通知所属的工作台，请手动检查。"))
                return
            }
            pendingNotification = payload
            pendingReceivedAt = receivedAt
            processPendingNotificationIfPossible() // New session may still be loading.
            return
        }
        guard let session = activeSession else { return }
        // Normal page loading still goes through Collie's existing authentication.
        guard session.openNativeNotification(route) else { return }
        onOpenWorkbench?()
    }

    private func refreshExisting(session: CollieWebSession, origin: URL, generation: Int) async {
        guard isCurrent(generation, session: session), isEnabled(for: origin),
              keychain.load(origin: origin.absoluteString) != nil else {
            if isCurrent(generation, session: session), !isEnabled(for: origin) { status = .disabled }
            return
        }
        guard let configuration = apnsConfiguration else {
            if isCurrent(generation, session: session) {
                status = .serviceUnavailable
                notice = notifyText("当前工作台暂时无法开启通知。")
            }
            return
        }
        guard let service = await webRequest("status", payload: [:], session: session, timeout: .seconds(10)),
              isCurrent(generation, session: session), service.ok,
              service.available == true,
              service.environment == configuration.environment.rawValue,
              service.topic == configuration.topic else {
            if isCurrent(generation, session: session) {
                status = .serviceUnavailable
                notice = notifyText("当前工作台暂时无法开启通知。")
            }
            return
        }
        let authorization = await notificationCenter.settings()
        guard authorization.isUsable else {
            if isCurrent(generation, session: session) { status = .authorizationDenied }
            return
        }
        pendingDeviceToken = nil
        registrationGeneration = generation
        registrar.registerForRemoteNotifications()
        guard let token = await waitForDeviceToken(generation: generation, session: session) else {
            if isCurrent(generation, session: session) {
                status = .error(notifyText("无法开启通知，请稍后重试。"))
            }
            return
        }
        await completeRegistration(
            token: token, origin: origin, configuration: configuration,
            session: session, generation: generation, enabling: false
        )
    }

    private func completeRegistration(
        token: Data,
        origin: URL,
        configuration: APNSConfiguration,
        session: CollieWebSession,
        generation: Int,
        enabling: Bool
    ) async {
        guard isCurrent(generation, session: session) else { return }
        status = .registering
        let existing = keychain.load(origin: origin.absoluteString)
        let binding = existing ?? CollieNativePushBinding(
            installationId: UUID().uuidString.lowercased(),
            secret: Self.randomSecret(),
            registrationId: nil,
            expiresAt: nil,
            unregisterPending: false
        )
        var pending = binding
        pending.unregisterPending = true
        if !keychain.save(pending, origin: origin.absoluteString) {
            fail(.error(notifyText("无法保存通知设置，请稍后重试。")), nil)
            return
        }
        let response = await webRequest(
            "register",
            payload: [
                "installationId": binding.installationId,
                "secret": binding.secret,
                "deviceToken": token.map { String(format: "%02x", $0) }.joined(),
                "environment": configuration.environment.rawValue,
                "topic": configuration.topic
            ],
            session: session,
            timeout: .seconds(10)
        )
        guard isCurrent(generation, session: session) else { return }
        guard let response, response.ok,
              let registrationId = response.registrationId,
              let expiresAt = response.expiresAt,
              Self.isValidExpiry(expiresAt) else {
            let reason = response?.reason ?? "network"
            if response == nil || response?.ok == true || reason == "network" {
                status = .unbindPending
                notice = notifyText("通知开启未完成。为避免通知发错工作台，请先重试停用；原工作台可能最多继续收到 7 天通用提醒。")
                return
            }
            _ = keychain.save(binding, origin: origin.absoluteString)
            if reason.lowercased().contains("pair") || reason.lowercased().contains("auth") {
                fail(.needsPairing, reason.localizedPushReason)
            } else {
                fail(.error(reason.localizedPushReason), nil)
            }
            return
        }
        var committed = binding
        committed.registrationId = registrationId
        committed.expiresAt = expiresAt
        committed.unregisterPending = false
        guard keychain.save(committed, origin: origin.absoluteString) else {
            fail(.error(notifyText("无法保存通知设置，请稍后重试。")), nil)
            return
        }
        defaults.set(true, forKey: originKey(for: origin)!)
        status = .enabled
        notice = nil
    }

    private func rotateUnregisteredBinding(_ old: CollieNativePushBinding, origin: URL) -> Bool {
        // Ignore duplicate/late acknowledgements for an older binding.
        guard keychain.load(origin: origin.absoluteString)?.installationId == old.installationId else { return false }
        return keychain.save(CollieNativePushBinding(
            installationId: UUID().uuidString.lowercased(), secret: Self.randomSecret(),
            registrationId: nil, expiresAt: nil, unregisterPending: false
        ), origin: origin.absoluteString)
    }

    private static func isValidExpiry(_ value: String) -> Bool {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: value) != nil || ISO8601DateFormatter().date(from: value) != nil
    }

    private func waitForDeviceToken(generation: Int, session: CollieWebSession) async -> Data? {
        for _ in 0..<150 {
            guard isCurrent(generation, session: session) else { return nil }
            if let token = pendingDeviceToken {
                pendingDeviceToken = nil
                registrationGeneration = nil
                return token
            }
            try? await Task.sleep(for: .milliseconds(100))
        }
        registrationGeneration = nil
        return nil
    }

    private func webRequest(
        _ operation: String,
        payload: [String: String],
        session: CollieWebSession?,
        timeout: Duration
    ) async -> CollieNativePushResponse? {
        guard ["status", "register", "unregister"].contains(operation) else { return nil }
        return await boundedRequest(operation, payload: payload, session: session, timeout: timeout)
    }

    private func boundedRequest(_ operation: String, payload: [String: String], session: CollieWebSession?, timeout: Duration) async -> CollieNativePushResponse? {
        await withCheckedContinuation { continuation in
            let reply = ColliePushReply(continuation)
            Task { @MainActor in
                reply.finish(await webClient.request(operation: operation, payload: payload, in: session))
            }
            reply.deadline = Task { @MainActor in
                try? await Task.sleep(for: timeout)
                reply.finish(nil)
            }
        }
    }

    private func isCurrent(_ expectedGeneration: Int, session: CollieWebSession) -> Bool {
        !session.isInvalidated && generation == expectedGeneration && activeSession === session
            && activeOrigin == canonicalOrigin(session.baseURL)
    }

    private func fail(_ status: CollieNativePushStatus, _ message: String?) {
        self.status = status
        notice = message
    }

    private func canonicalOrigin(_ url: URL) -> URL? {
        CollieConnectionOrigin.validate(url.absoluteString)
    }

    private func originKey(for origin: URL) -> String? {
        guard let normalized = canonicalOrigin(origin) else { return nil }
        let digest = SHA256.hash(data: Data(normalized.absoluteString.utf8))
        return "collie.nativePush.enabled.\(digest.map { String(format: "%02x", $0) }.joined())"
    }

    private static func randomSecret() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            return Data((0..<32).map { _ in UInt8.random(in: 0...255) })
                .map { String(format: "%02x", $0) }.joined()
        }
        return Data(bytes).map { String(format: "%02x", $0) }.joined()
    }
}

private extension String {
    var localizedPushReason: String {
        let lower = lowercased()
        if lower.contains("pair") || lower.contains("auth") || lower.contains("credential") {
            return notifyText("请先在当前工作台完成配对，再开启通知。")
        }
        if lower.contains("available") || lower.contains("config") {
            return notifyText("当前工作台暂时无法开启通知。")
        }
        return notifyText("无法连接工作台，请保持工作台已加载后重试。")
    }
}

@MainActor
private final class ColliePushReply {
    private var continuation: CheckedContinuation<CollieNativePushResponse?, Never>?
    var deadline: Task<Void, Never>?
    init(_ continuation: CheckedContinuation<CollieNativePushResponse?, Never>) { self.continuation = continuation }
    func finish(_ response: CollieNativePushResponse?) {
        guard let continuation else { return }
        self.continuation = nil
        deadline?.cancel()
        deadline = nil
        continuation.resume(returning: response)
    }
}

// MARK: - APNs payload / AppDelegate

struct CollieNativeNotificationPayload: Equatable, Sendable {
    let registrationId: String
    let path: String

    init?(userInfo: [AnyHashable: Any]) {
        guard let collie = userInfo["collie"] as? [AnyHashable: Any],
              (collie["version"] as? Int) == 1,
              let registrationId = collie["registrationId"] as? String,
              !registrationId.isEmpty,
              let path = collie["path"] as? String,
              path.utf8.count <= 2048
        else { return nil }
        self.registrationId = registrationId
        self.path = path
    }
}

struct APNSConfiguration: Equatable, Sendable {
    enum Environment: String, Sendable { case development, production }
    let environment: Environment
    let topic: String

    static func current(bundle: Bundle = .main) -> APNSConfiguration? {
        guard let raw = bundle.object(forInfoDictionaryKey: "CollieAPNSEnvironment") as? String,
              let environment = Environment(rawValue: raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()),
              let topic = bundle.bundleIdentifier?.trimmingCharacters(in: .whitespacesAndNewlines),
              !topic.isEmpty,
              !topic.contains("$(") else { return nil }
        return APNSConfiguration(environment: environment, topic: topic)
    }
}

@MainActor
final class CollieNativePushAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    weak var controller: CollieNativeNotificationsController?
    private var pendingLaunchPayload: CollieNativeNotificationPayload?

    override init() { super.init() }

    init(controller: CollieNativeNotificationsController) {
        self.controller = controller
        super.init()
    }

    func bind(controller: CollieNativeNotificationsController) {
        self.controller = controller
        if let pendingLaunchPayload {
            controller.handleNotification(payload: pendingLaunchPayload)
            self.pendingLaunchPayload = nil
        }
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        if let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            if let payload = CollieNativeNotificationPayload(userInfo: userInfo) {
                if let controller { controller.handleNotification(payload: payload) }
                else { pendingLaunchPayload = payload }
            } else {
                _ = CollieHermesPush.shared.handleTap(userInfo: userInfo)
            }
        }
        CollieHermesPush.shared.resumeIfEnabled()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task { @MainActor [weak self] in
            self?.controller?.didRegister(deviceToken: deviceToken)
            CollieHermesPush.shared.didRegister(deviceToken: deviceToken)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Task { @MainActor [weak self] in
            self?.controller?.didFailToRegister(error: error)
            CollieHermesPush.shared.didFailToRegister()
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        // Hermes task reminders (relay payload with a WebUI "url") always show.
        guard let payload = CollieNativeNotificationPayload(userInfo: userInfo) else {
            // Only the URL string crosses to the main actor; userInfo is not Sendable.
            let url = userInfo["url"] as? String
            let hermes = await MainActor.run {
                CollieHermesPush.shared.shouldPresent(userInfo: url.map { ["url": $0] } ?? [:])
            }
            return hermes ? [.banner, .sound] : []
        }
        let shouldPresent = await MainActor.run { [weak self] in
            self?.controller?.shouldPresent(payload: payload) == true
        }
        return shouldPresent ? [.banner, .sound] : []
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let payload = CollieNativeNotificationPayload(userInfo: userInfo) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let controller { controller.handleNotification(payload: payload) }
                else { pendingLaunchPayload = payload }
            }
        } else if let raw = userInfo["url"] as? String {
            Task { @MainActor in CollieHermesPush.shared.handleTap(userInfo: ["url": raw]) }
        }
        completionHandler()
    }
}

// MARK: - CollieWebSession bridge and guarded navigation

@MainActor
extension CollieWebSession {
    func nativePushRequest(operation: String, payload: [String: String], timeout: Duration = .seconds(10)) async -> CollieNativePushResponse {
        guard ["status", "register", "unregister"].contains(operation),
              !isInvalidated,
              let webView,
              let currentURL = webView.url,
              Self.nativePushSameOrigin(currentURL, baseURL) else {
            return CollieNativePushResponse(ok: false, reason: "untrusted web frame")
        }
        let origin = Self.nativePushOrigin(baseURL)
        let script = """
        return await (async function(operation, payload, expectedOrigin) {
          if (window.location.origin !== expectedOrigin ||
              typeof window.collieNativePush?.request !== 'function') {
            return JSON.stringify({ok: false, reason: 'native push bridge unavailable'});
          }
          try {
            return JSON.stringify(await window.collieNativePush.request(operation, payload));
          } catch (_) {
            return JSON.stringify({ok: false, reason: 'native push request failed'});
          }
        })(operation, payload, expectedOrigin)
        """
        let response = await withCheckedContinuation { continuation in
            let reply = ColliePushReply(continuation)
            webView.callAsyncJavaScript(
                script,
                arguments: ["operation": operation, "payload": payload, "expectedOrigin": origin],
                in: nil, in: .page
            ) { [weak self, weak webView] result in
                guard let self, !self.isInvalidated, let webView,
                      let url = webView.url, Self.nativePushSameOrigin(url, self.baseURL),
                      case .success(let value) = result,
                      let json = value as? String, let data = json.data(using: .utf8),
                      let decoded = try? JSONDecoder().decode(CollieNativePushResponse.self, from: data)
                else { reply.finish(CollieNativePushResponse(ok: false, reason: "native push request failed")); return }
                reply.finish(decoded)
            }
            reply.deadline = Task { @MainActor in
                try? await Task.sleep(for: timeout)
                reply.finish(nil)
            }
        }
        return response ?? CollieNativePushResponse(ok: false, reason: "network")
    }

    /// Keeps route validation local and leaves the existing navigation delegate
    /// as the final main-frame policy check.
    @discardableResult
    func openNativeNotification(_ url: URL) -> Bool {
        guard !isInvalidated, let webView, Self.nativePushSameOrigin(url, baseURL),
              Self.nativePushOrigin(url) == Self.nativePushOrigin(baseURL) else { return false }
        webView.load(URLRequest(url: url))
        return true
    }

    private static func nativePushOrigin(_ url: URL) -> String {
        var components = URLComponents()
        components.scheme = url.scheme?.lowercased()
        components.host = url.host?.lowercased()
        let defaultPort = url.scheme?.lowercased() == "https" ? 443 : 80
        if let port = url.port, port != defaultPort { components.port = port }
        return components.string ?? ""
    }

    private static func nativePushSameOrigin(_ lhs: URL, _ rhs: URL) -> Bool {
        lhs.scheme?.lowercased() == rhs.scheme?.lowercased()
            && lhs.host?.lowercased() == rhs.host?.lowercased()
            && nativePushEffectivePort(lhs) == nativePushEffectivePort(rhs)
    }

    private static func nativePushEffectivePort(_ url: URL) -> Int? {
        if let port = url.port { return port }
        switch url.scheme?.lowercased() {
        case "https": return 443
        case "http": return 80
        default: return nil
        }
    }
}

// MARK: - SwiftUI section

struct CollieNativeNotificationsSection: View {
    let controller: CollieNativeNotificationsController
    let session: CollieWebSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Section {
            HStack(spacing: 12) {
                if controller.isBusy {
                    ProgressView()
                    Text(controller.status.title)
                        .font(.body.weight(.medium))
                } else {
                    Label(controller.status.title, systemImage: controller.isEnabled ? "bell.badge.fill" : "bell.slash")
                        .font(.body.weight(.medium))
                }
            }
            .padding(.vertical, 6)
            .frame(minHeight: 44)
            .accessibilityIdentifier("collie-native-notifications-status")

            Text(controller.notice ?? guidance)
                .font(.footnote)
                .foregroundStyle(controller.status == .enabled || controller.status == .disabled ? Color.secondary : Color.orange)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("collie-native-notifications-notice")

            if !controller.isBusy {
                switch controller.status {
                case .enabled:
                    Button(notifyText("关闭通知"), role: .destructive) {
                        Task { await controller.disable(session: session) }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("collie-native-notifications-disable")
                case .unbindPending:
                    Button(notifyText("重试停用")) {
                        Task { await controller.retryUnregister(session: session) }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("collie-native-notifications-retry-unregister")
                case .authorizationDenied:
                    Button(notifyText("去系统设置允许通知")) {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("collie-native-notifications-system-settings")
                case .needsPairing:
                    Button(notifyText("返回工作台完成配对")) { dismiss() }
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .contentShape(Rectangle())
                        .accessibilityIdentifier("collie-native-notifications-return-to-workbench")
                case .serviceUnavailable, .error:
                    if controller.isEnabled {
                        Button(notifyText("关闭通知"), role: .destructive) {
                            Task { await controller.disable(session: session) }
                        }
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .contentShape(Rectangle())
                        .accessibilityIdentifier("collie-native-notifications-disable")
                    } else {
                        Button(notifyText("重试检查")) {
                            Task { await controller.enable(session: session) }
                        }
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .contentShape(Rectangle())
                        .accessibilityIdentifier("collie-native-notifications-enable")
                    }
                case .disabled:
                    Button(notifyText("开启通知")) {
                        Task { await controller.enable(session: session) }
                    }
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("collie-native-notifications-enable")
                case .checkingService, .requestingPermission, .waitingForDeviceToken, .registering, .refreshing, .unregistering:
                    EmptyView()
                }
            }
        } header: {
            Text(notifyText("通知"))
        }
    }

    private var guidance: String {
        switch controller.status {
        case .disabled:
            return notifyText("开启后，在当前工作台接收通用提醒。\n不会自动发送消息。")
        case .checkingService, .requestingPermission, .waitingForDeviceToken, .registering:
            return notifyText("正在准备本机通知，请稍候。")
        case .refreshing:
            return notifyText("正在确认当前工作台的通知设置。")
        case .enabled:
            return notifyText("当前工作台会发送通用提醒。\n不会自动发送消息。")
        case .authorizationDenied:
            return notifyText("请在 iPhone“设置”中允许一呼发送通知。")
        case .serviceUnavailable:
            return notifyText("请检查工作台连接后重试。")
        case .needsPairing:
            return notifyText("请先在当前工作台完成配对，再开启通知。")
        case .unregistering:
            return notifyText("正在联系原工作台，请稍候。")
        case .unbindPending:
            return notifyText("为避免通知发错工作台，当前还不能开启通知。")
        case .error:
            return notifyText("请稍后重试。")
        }
    }
}

// App ownership/lifecycle: CollieShellApp. Main-frame trust/navigation: CollieWebView.
// No background mode or Notification Service Extension is required.
