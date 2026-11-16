import AuthenticationServices
import Foundation
import Observation
#if canImport(UIKit)
import UIKit
#endif

private func approvalText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

enum CollieApprovalError: Error, Equatable {
    case invalidCallback
    case rejected
    case presentationUnavailable
}

/// Production approval helper and URL policy.
///
/// `WKWebView` does not expose platform passkeys (`navigator.credentials`) for the
/// standalone approval service on port 8443. Matching approval links are handed off to
/// `ASWebAuthenticationSession` with `?app=1` so Face ID / Touch ID completes in-app and
/// returns automatically via `benchside-approval://done`.
enum CollieApproval {
    static let port = 8443
    static let callbackScheme = "benchside-approval"
    static let maxRecentTargets = 6
    private static let rememberedOriginsDefaultsKey = "collie.approval.origins.v1"

    /// Shared multi-tenant or two-label public suffixes that must never match across tenants.
    /// Three-label tenant suffixes beneath these (such as `<tailnet>.ts.net` or `<org>.co.uk`)
    /// remain eligible for sibling matching.
    private static let sharedPublicSuffixes: Set<String> = [
        "ts.net",
        "co.uk", "org.uk", "gov.uk", "ac.uk",
        "com.cn", "net.cn", "org.cn", "gov.cn",
        "com.hk", "com.tw",
        "com.au", "net.au", "org.au",
        "co.jp", "ne.jp", "or.jp",
        "co.kr", "com.sg", "com.my", "com.br", "com.mx",
        "github.io", "gitlab.io", "vercel.app", "pages.dev", "workers.dev",
        "onrender.com", "fly.dev", "railway.app", "netlify.app", "herokuapp.com",
        "ngrok.io", "ngrok.app", "ngrok-free.app", "trycloudflare.com", "amazonaws.com"
    ]

    static func isApprovalURL(_ url: URL?, workbenchURL: URL?) -> Bool {
        guard let workbenchURL, workbenchURL.scheme?.lowercased() == "https" else {
            return false
        }
        return isApprovalURL(url, host: workbenchURL.host)
    }

    static func isApprovalURL(_ url: URL?, host: String?) -> Bool {
        guard let url,
              let host,
              url.scheme?.lowercased() == "https",
              url.port == port,
              url.user == nil,
              url.password == nil,
              isAllowedApprovalPath(url.path),
              let candidateHost = url.host else {
            return false
        }
        return matchesApprovalHost(candidateHost, workbenchHost: host)
    }

    private static func isAllowedApprovalPath(_ path: String) -> Bool {
        path.isEmpty || path == "/" || path == "/approval" || path == "/approval/"
    }

    static func matchesApprovalHost(_ candidateHost: String, workbenchHost: String) -> Bool {
        guard let candidate = normalizedHost(candidateHost),
              let workbench = normalizedHost(workbenchHost) else {
            return false
        }
        if candidate == workbench {
            return true
        }
        guard let candidateLabels = validDomainLabels(candidate),
              let workbenchLabels = validDomainLabels(workbench) else {
            return false
        }

        let sharedSuffixLabels: [Substring]?
        if candidateLabels.count > workbenchLabels.count,
           Array(candidateLabels.suffix(workbenchLabels.count)) == workbenchLabels {
            sharedSuffixLabels = workbenchLabels
        } else if workbenchLabels.count > candidateLabels.count,
                  Array(workbenchLabels.suffix(candidateLabels.count)) == candidateLabels {
            sharedSuffixLabels = candidateLabels
        } else if candidateLabels.count >= 3,
                  workbenchLabels.count >= 3,
                  candidateLabels.dropFirst() == workbenchLabels.dropFirst() {
            sharedSuffixLabels = Array(workbenchLabels.dropFirst())
        } else {
            sharedSuffixLabels = nil
        }

        guard let suffix = sharedSuffixLabels, suffix.count >= 2 else {
            return false
        }
        let joinedSuffix = suffix.joined(separator: ".")
        return !sharedPublicSuffixes.contains(joinedSuffix)
    }

    private static func normalizedHost(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty,
              !trimmed.hasPrefix("."),
              !trimmed.hasSuffix("."),
              !trimmed.contains("..") else {
            return nil
        }
        return trimmed
    }

    /// Returns validated multi-label DNS host labels, rejecting IPv4/IPv6 literals and single-label hosts.
    private static func validDomainLabels(_ host: String) -> [Substring]? {
        guard !host.contains(":"), !host.contains("["), !host.contains("]") else {
            return nil
        }
        let labels = host.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2 else { return nil }
        for label in labels {
            guard !label.isEmpty,
                  label.count <= 63,
                  label.first != "-",
                  label.last != "-",
                  label.allSatisfy({ ($0 >= "a" && $0 <= "z") || ($0 >= "0" && $0 <= "9") || $0 == "-" }) else {
                return nil
            }
        }
        guard let tld = labels.last,
              tld.count >= 2,
              tld.allSatisfy({ $0 >= "a" && $0 <= "z" }) || tld.hasPrefix("xn--") else {
            return nil
        }
        return labels
    }

    /// Ensures `?app=1` so the approval web page redirects back via `callbackScheme` on completion.
    static func inAppURL(_ url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }
        var items = components.queryItems ?? []
        if let index = items.firstIndex(where: { $0.name == "app" }) {
            items[index] = URLQueryItem(name: "app", value: "1")
        } else {
            items.append(URLQueryItem(name: "app", value: "1"))
        }
        components.queryItems = items
        return components.url ?? url
    }

    static func baseURL(for origin: URL) -> URL? {
        guard origin.scheme?.lowercased() == "https",
              let host = normalizedHost(origin.host ?? ""),
              !host.isEmpty else {
            return nil
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.port = port
        components.path = "/"
        return components.url
    }

    static func isSyntheticTestHost(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return true }
        return host == "invalid" || host.hasSuffix(".invalid")
    }

    static func targetApprovalURL(baseURL: URL, target: String?) -> URL? {
        guard let normalizedBase = Self.baseURL(for: baseURL),
              var components = URLComponents(url: normalizedBase, resolvingAgainstBaseURL: false) else {
            return nil
        }
        var items: [URLQueryItem] = []
        if let trimmed = target?.trimmingCharacters(in: .whitespacesAndNewlines),
           !trimmed.isEmpty {
            guard isValidTargetSlug(trimmed) else { return nil }
            items.append(URLQueryItem(name: "target", value: trimmed))
        }
        items.append(URLQueryItem(name: "app", value: "1"))
        components.queryItems = items
        return components.url
    }

    static func isValidTargetSlug(_ raw: String) -> Bool {
        guard let first = raw.first,
              raw.count <= 64,
              (first >= "a" && first <= "z") || (first >= "0" && first <= "9") else {
            return false
        }
        return raw.allSatisfy {
            ($0 >= "a" && $0 <= "z") || ($0 >= "0" && $0 <= "9") || $0 == "." || $0 == "_" || $0 == "-"
        }
    }

    static func parseCallback(_ url: URL) -> Result<String, CollieApprovalError> {
        guard url.scheme?.lowercased() == callbackScheme else {
            return .failure(.invalidCallback)
        }
        let host = url.host?.lowercased()
        guard host == "done" || (host == nil && url.path == "/done") else {
            return .failure(.invalidCallback)
        }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        if let status = items.first(where: { $0.name == "status" })?.value?.lowercased(),
           status != "ok" {
            return .failure(.rejected)
        }
        let rawTarget = items.first(where: { $0.name == "target" })?.value?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let safeTarget = isValidTargetSlug(rawTarget) ? rawTarget : ""
        return .success(safeTarget)
    }

    static func decodeTargets(from data: Data) throws -> [String] {
        guard let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rawTargets = payload["targets"] as? [String] else {
            throw URLError(.cannotParseResponse)
        }
        var seen = Set<String>()
        var result: [String] = []
        for entry in rawTargets {
            let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
            guard isValidTargetSlug(trimmed), seen.insert(trimmed).inserted else { continue }
            result.append(trimmed)
        }
        if result.count > maxRecentTargets {
            result = Array(result.suffix(maxRecentTargets))
        }
        return result
    }

    static func rememberApprovalURL(_ url: URL, defaults: UserDefaults = .standard) {
        guard url.scheme?.lowercased() == "https",
              url.port == port,
              let base = baseURL(for: url),
              !isSyntheticTestHost(base) else {
            return
        }
        var stored = defaults.stringArray(forKey: rememberedOriginsDefaultsKey) ?? []
        stored.removeAll { $0 == base.absoluteString }
        stored.insert(base.absoluteString, at: 0)
        if stored.count > 8 {
            stored = Array(stored.prefix(8))
        }
        defaults.set(stored, forKey: rememberedOriginsDefaultsKey)
    }

    /// Ordered candidate `:8443` base URLs for the current workbench (same host or remembered/recent sibling host).
    static func candidateBaseURLs(
        for workbenchURL: URL,
        recentOrigins: [URL] = [],
        defaults: UserDefaults = .standard
    ) -> [URL] {
        guard workbenchURL.scheme?.lowercased() == "https" else { return [] }
        var seen = Set<String>()
        var candidates: [URL] = []

        func appendIfEligible(_ candidateOrigin: URL) {
            guard let base = baseURL(for: candidateOrigin),
                  isApprovalURL(base, workbenchURL: workbenchURL),
                  seen.insert(base.absoluteString).inserted else {
                return
            }
            candidates.append(base)
        }

        for raw in defaults.stringArray(forKey: rememberedOriginsDefaultsKey) ?? [] {
            if let url = URL(string: raw) {
                appendIfEligible(url)
            }
        }
        appendIfEligible(workbenchURL)
        for origin in recentOrigins {
            appendIfEligible(origin)
        }
        return Array(candidates.prefix(3))
    }

    static func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
            return true
        }
        if let urlError = error as? URLError, urlError.code == .cancelled {
            return true
        }
        let nsError = error as NSError
        if nsError.domain == ASWebAuthenticationSessionErrorDomain,
           nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
            return true
        }
        if nsError.domain == NSURLErrorDomain, nsError.code == URLError.cancelled.rawValue {
            return true
        }
        return false
    }

    static func resultAlertMessage(for result: Result<String, Error>) -> String? {
        switch result {
        case .success(let target):
            if target.isEmpty {
                return approvalText("审批已完成")
            }
            return String(format: approvalText("已批准 %@（24 小时内有效）"), target)
        case .failure(let error):
            if isCancellation(error) {
                return nil
            }
            return approvalText("审批未完成，请重试")
        }
    }
}

#if canImport(UIKit)
@MainActor
@Observable
final class CollieApprovalPresenter: NSObject, ASWebAuthenticationPresentationContextProviding {
    private(set) var isPresenting = false
    var resultMessage: String?
    @ObservationIgnored private var session: ASWebAuthenticationSession?

    func start(url: URL, onApproved: (@MainActor (String) -> Void)? = nil) {
        guard !isPresenting else { return }
        let targetURL = CollieApproval.inAppURL(url)
        CollieApproval.rememberApprovalURL(targetURL)

        let authSession = ASWebAuthenticationSession(
            url: targetURL,
            callback: .customScheme(CollieApproval.callbackScheme)
        ) { [weak self] callbackURL, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.session = nil
                self.isPresenting = false
                let outcome: Result<String, Error>
                if let error {
                    outcome = .failure(error)
                } else if let callbackURL {
                    switch CollieApproval.parseCallback(callbackURL) {
                    case .success(let target):
                        onApproved?(target)
                        outcome = .success(target)
                    case .failure(let callbackError):
                        outcome = .failure(callbackError)
                    }
                } else {
                    outcome = .failure(CollieApprovalError.invalidCallback)
                }
                guard let message = CollieApproval.resultAlertMessage(for: outcome) else {
                    return
                }
                await self.waitForModalTransitionToSettle()
                self.resultMessage = message
            }
        }
        authSession.presentationContextProvider = self
        authSession.prefersEphemeralWebBrowserSession = false
        session = authSession
        isPresenting = true
        if !authSession.start() {
            session = nil
            isPresenting = false
            resultMessage = CollieApproval.resultAlertMessage(
                for: .failure(CollieApprovalError.presentationUnavailable)
            )
        }
    }

    func cancel() {
        session?.cancel()
        session = nil
        isPresenting = false
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .sorted { lhs, rhs in
                (lhs.activationState == .foregroundActive ? 0 : 1) < (rhs.activationState == .foregroundActive ? 0 : 1)
            }
        for scene in windowScenes {
            if let keyWindow = scene.keyWindow {
                return keyWindow
            }
            if let firstWindow = scene.windows.first(where: { !$0.isHidden }) {
                return firstWindow
            }
        }
        if let scene = windowScenes.first {
            return UIWindow(windowScene: scene)
        }
        return ASPresentationAnchor()
    }

    private func waitForModalTransitionToSettle() async {
        for _ in 0..<8 {
            guard isAnyPresentationTransitioning() else { return }
            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    private func isAnyPresentationTransitioning() -> Bool {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        for scene in scenes {
            for window in scene.windows where !window.isHidden {
                var current = window.rootViewController
                while let controller = current {
                    if controller.isBeingDismissed || controller.isBeingPresented {
                        return true
                    }
                    current = controller.presentedViewController
                }
            }
        }
        return false
    }
}
#endif
