import CryptoKit
import Foundation
import Observation
import SwiftUI
import UIKit
import WebKit

@MainActor
@Observable
final class CollieWebSession {
    fileprivate(set) var isLoading = false
    fileprivate(set) var errorMessage: String?
    private(set) var pageTitle: String?
    private(set) var keyboardEnabled = false
    private(set) var keyboardVisible = false
    private(set) var keyboardNotice: String?
    private var keyboardRequest = 0
    private var keyboardTask: Task<Bool, Never>?

    let baseURL: URL
    fileprivate let websiteDataStore: WKWebsiteDataStore
    private(set) weak var webView: WKWebView?
    private(set) var isInvalidated = false

    init(baseURL: URL, websiteDataStore: WKWebsiteDataStore? = nil) {
        self.baseURL = baseURL
        self.websiteDataStore = websiteDataStore ?? Self.persistentDataStore(for: baseURL)
    }

    var isConnected: Bool {
        !isLoading && errorMessage == nil && isTrusted(webView?.url)
    }

    var connectionStatusLabel: String {
        if isLoading { return NSLocalizedString("正在连接", tableName: "Yihu", comment: "") }
        if errorMessage != nil { return NSLocalizedString("连接失败", tableName: "Yihu", comment: "") }
        return isConnected ? NSLocalizedString("已连接", tableName: "Yihu", comment: "") : NSLocalizedString("未连接", tableName: "Yihu", comment: "")
    }

    fileprivate func notePageTitle(_ title: String?, url: URL?) {
        guard !isInvalidated, isTrusted(url), let title, !title.isEmpty else { return }
        if pageTitle != title { pageTitle = title }
    }

    fileprivate func attach(_ webView: WKWebView) {
        guard !isInvalidated else { return }
        self.webView = webView
        guard webView.url == nil else { return }
        webView.load(URLRequest(url: baseURL))
    }

    /// Stops callbacks from an old connection before the root view installs a
    /// new session. No website data is deleted; each origin has its own store.
    func invalidate() {
        guard !isInvalidated else { return }
        isInvalidated = true
        keyboardRequest += 1
        keyboardTask?.cancel()
        keyboardTask = nil
        let oldWebView = webView
        webView = nil
        oldWebView?.endEditing(true)
        oldWebView?.stopLoading()
        oldWebView?.navigationDelegate = nil
        oldWebView?.uiDelegate = nil
    }

    static func isSupersededNavigation(_ error: Error) -> Bool {
        let error = error as NSError
        return (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled)
            // WebKitErrorFrameLoadInterruptedByPolicyChange: a navigation handed off, e.g. to Safari.
            || (error.domain == "WebKitErrorDomain" && error.code == 102)
    }

    static func userFacingMessage(for error: Error) -> String {
        let error = error as NSError
        guard error.domain == NSURLErrorDomain else { return "工作台页面加载失败，请重新加载。" }
        switch error.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost, NSURLErrorDataNotAllowed:
            return "这台 iPhone 目前没有网络连接。"
        case NSURLErrorTimedOut:
            return "工作台响应超时，请稍后重试。"
        case NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed:
            return "找不到这个工作台地址，请检查地址是否正确。"
        case NSURLErrorCannotConnectToHost:
            return "工作台没有响应，请确认服务正在运行。"
        case NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateUntrusted,
             NSURLErrorServerCertificateHasBadDate, NSURLErrorServerCertificateHasUnknownRoot,
             NSURLErrorServerCertificateNotYetValid, NSURLErrorClientCertificateRejected,
             NSURLErrorClientCertificateRequired:
            return "无法建立安全连接，请检查工作台的 HTTPS 证书。"
        default:
            return "暂时无法访问工作台，请检查网络后重试。"
        }
    }

    fileprivate func isTrusted(_ url: URL?) -> Bool {
        guard !isInvalidated, let url else { return false }
        return url.scheme?.lowercased() == baseURL.scheme?.lowercased()
            && url.host?.lowercased() == baseURL.host?.lowercased()
            && effectivePort(of: url) == effectivePort(of: baseURL)
    }

    func setKeyboardEnabled(_ enabled: Bool) async {
        keyboardRequest += 1
        let request = keyboardRequest
        keyboardNotice = nil
        keyboardEnabled = enabled
        keyboardVisible = enabled
        if !enabled { webView?.endEditing(true) }
        let accepted = await enqueueKeyboard(enabled, request: request).value
        guard request == keyboardRequest else { return }
        keyboardTask = nil
        keyboardEnabled = enabled && accepted
        if enabled && !accepted {
            keyboardVisible = false
            keyboardNotice = "进入会话后再启用键盘"
        }
    }

    /// UIKit closes immediately; a busy web process must not delay microphone
    /// startup. The queued disable runs after any already-dispatched enable.
    func dismissKeyboard() {
        keyboardRequest += 1
        keyboardEnabled = false
        keyboardVisible = false
        keyboardNotice = nil
        webView?.endEditing(true)
        _ = enqueueKeyboard(false, request: keyboardRequest)
    }

    func setKeyboardVisible(_ visible: Bool) {
        keyboardVisible = visible
    }

    private func enqueueKeyboard(_ enabled: Bool, request: Int) -> Task<Bool, Never> {
        let previous = keyboardTask
        let task = Task { @MainActor [weak self] in
            _ = await previous?.value
            guard let self, request == self.keyboardRequest,
                  let webView = self.webView, self.isTrusted(webView.url) else { return false }
            // DOM focus alone need not activate the native input session and
            // present the software keyboard on a physical iPhone.
            if enabled { webView.becomeFirstResponder() }
            do {
                let result = try await webView.callAsyncJavaScript(
                    CollieKeyboardPolicy.setEnabledScript,
                    arguments: ["enabled": enabled, "origin": self.trustedOrigin],
                    in: nil, contentWorld: .defaultClient
                )
                return (result as? Bool) == true
            } catch { return false }
        }
        keyboardTask = task
        return task
    }

    func reload() {
        errorMessage = nil
        isLoading = true
        guard let webView else {
            isLoading = false
            errorMessage = "工作台页面尚未准备好。"
            return
        }
        if isTrusted(webView.url) {
            webView.reload()
        } else {
            webView.load(URLRequest(url: baseURL))
        }
    }

    struct SharedFile: Sendable {
        let url: URL
        let name: String
        let contentType: String?
    }

    enum AttachResult { case attached, noUploadControl, oneAtATime, failed }

    /// Hands shared files to the page's own upload input (never submits). Data
    /// crosses in base64 chunks so large videos don't need one giant JS string.
    func attachFiles(_ files: [SharedFile]) async -> AttachResult {
        guard let webView, isTrusted(webView.url) else { return .failed }
        var ids: [String] = []
        func discard() async {
            _ = try? await webView.callAsyncJavaScript(
                "return window.collieNativeFileDiscard?.(ids)", arguments: ["ids": ids],
                in: nil, contentWorld: .defaultClient)
        }
        do {
            for file in files {
                let id = UUID().uuidString
                ids.append(id)
                _ = try await webView.callAsyncJavaScript(
                    "return window.collieNativeFileBegin?.(id, name, type) === true",
                    arguments: ["id": id, "name": file.name, "type": file.contentType ?? ""],
                    in: nil, contentWorld: .defaultClient)
                var offset: UInt64 = 0
                while let chunk = try await Self.base64Chunk(of: file.url, at: offset) {
                    guard isTrusted(webView.url) else { await discard(); return .failed }
                    let accepted = try await webView.callAsyncJavaScript(
                        "return window.collieNativeFileChunk?.(id, chunk) === true",
                        arguments: ["id": id, "chunk": chunk.base64],
                        in: nil, contentWorld: .defaultClient)
                    guard (accepted as? Bool) == true else { await discard(); return .failed }
                    offset += UInt64(chunk.byteCount)
                }
            }
            guard isTrusted(webView.url) else { await discard(); return .failed }
            let result = try await webView.callAsyncJavaScript(
                "if (window.location.origin !== origin) return 'failed'; return window.collieNativeAttachFiles?.(ids) ?? 'failed'",
                arguments: ["ids": ids, "origin": trustedOrigin],
                in: nil, contentWorld: .defaultClient) as? String
            switch result {
            case "attached": return .attached
            case "no-input": return .noUploadControl
            case "single-only": return .oneAtATime
            default: return .failed
            }
        } catch {
            await discard()
            return .failed
        }
    }

    /// Reads and encodes one chunk off the main actor so large files don't stall the UI.
    private nonisolated static func base64Chunk(of url: URL, at offset: UInt64) async throws
        -> (base64: String, byteCount: Int)? {
        try await Task.detached(priority: .userInitiated) {
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }
            try handle.seek(toOffset: offset)
            guard let data = try handle.read(upToCount: 768 * 1024), !data.isEmpty else { return nil }
            return (data.base64EncodedString(), data.count)
        }.value
    }

    /// Sends text through Collie's explicit native bridge, then (for other
    /// workbenches) into the field the user last focused. It never submits, and
    /// the origin check prevents navigation from receiving speech.
    func insertTranscript(_ transcript: String) async -> Bool {
        guard let webView, isTrusted(webView.url) else { return false }
        let arguments: [String: Any] = ["text": transcript, "origin": trustedOrigin]
        do {
            let result = try await webView.callAsyncJavaScript(
                CollieTextInsertion.collieBridgeScript, arguments: arguments, in: nil, contentWorld: .page
            )
            if (result as? Bool) == true { return true }
        } catch {
            // A failed text handoff is not a navigation failure. The voice bar
            // retains the result for retry; never cover the working page here.
            return false
        }
        // Not a Collie composer: insert into the field the user last focused
        // (OpenClaw, Hermes or any other workbench page).
        guard isTrusted(webView.url) else { return false }
        do {
            let result = try await webView.callAsyncJavaScript(
                CollieTextInsertion.insertScript, arguments: arguments, in: nil, contentWorld: .defaultClient
            )
            return (result as? Bool) == true
        } catch {
            return false
        }
    }

    private static func persistentDataStore(for url: URL) -> WKWebsiteDataStore {
        let origin = normalizedOrigin(for: url)
        let bytes = Array(SHA256.hash(data: Data(origin.utf8)).prefix(16))
        let identifier = UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
        ))
        return WKWebsiteDataStore(forIdentifier: identifier)
    }

    private static func normalizedOrigin(for url: URL) -> String {
        var components = URLComponents()
        components.scheme = url.scheme?.lowercased()
        components.host = url.host?.lowercased()
        let defaultPort = url.scheme?.lowercased() == "https" ? 443 : 80
        if let port = url.port, port != defaultPort { components.port = port }
        return components.string ?? url.absoluteString
    }

    fileprivate var trustedOrigin: String {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        let defaultPort = baseURL.scheme?.lowercased() == "https" ? 443 : 80
        components.port = baseURL.port == defaultPort ? nil : baseURL.port
        return components.string ?? ""
    }

    private func effectivePort(of url: URL) -> Int? {
        if let port = url.port { return port }
        switch url.scheme?.lowercased() {
        case "https": return 443
        case "http": return 80
        default: return nil
        }
    }
}

struct CollieWebView: UIViewRepresentable {
    let session: CollieWebSession
    var pageReady: @MainActor () -> Void = {}
    var openNotificationSettings: @MainActor () -> Void = {}
    var requestKeyboard: @MainActor () async -> Void = {}

    func makeCoordinator() -> Coordinator {
        Coordinator(session: session, requestKeyboard: requestKeyboard,
                    pageReady: pageReady, openNotificationSettings: openNotificationSettings)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = session.websiteDataStore
        configuration.applicationNameForUserAgent = "CollieNative/1.0"
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController.add(context.coordinator, contentWorld: .defaultClient, name: "collieKeyboardRequested")
        configuration.userContentController.add(context.coordinator, contentWorld: .page, name: "collieNativeNotifications")
        configuration.userContentController.add(context.coordinator, contentWorld: .page, name: "collieNativePushCapability")
        if let insertion = CollieTextInsertion.userScript(origin: session.trustedOrigin) {
            configuration.userContentController.addUserScript(insertion)
        }
        if let policy = CollieKeyboardPolicy.userScript(origin: session.trustedOrigin) {
            configuration.userContentController.addUserScript(policy)
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.observeURL(of: webView)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .interactive
        session.attach(webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.requestKeyboard = requestKeyboard
        context.coordinator.pageReady = pageReady
        context.coordinator.openNotificationSettings = openNotificationSettings
        session.attach(webView)
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "collieKeyboardRequested", contentWorld: .defaultClient)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "collieNativeNotifications", contentWorld: .page)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "collieNativePushCapability", contentWorld: .page)
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        private let session: CollieWebSession
        private var lastProcessTermination: ContinuousClock.Instant?
        var requestKeyboard: @MainActor () async -> Void
        var pageReady: @MainActor () -> Void
        var openNotificationSettings: @MainActor () -> Void
        private var urlObservation: NSKeyValueObservation?
        private var titleObservation: NSKeyValueObservation?

        func observeURL(of webView: WKWebView) {
            // URL KVO also sees same-document pushState/popstate navigation.
            urlObservation = webView.observe(\.url, options: [.new]) { [weak self] _, _ in
                Task { @MainActor in self?.session.dismissKeyboard() }
            }
            titleObservation = webView.observe(\.title, options: [.new]) { [weak self, weak webView] _, _ in
                Task { @MainActor in
                    guard let self, let webView else { return }
                    self.session.notePageTitle(webView.title, url: webView.url)
                }
            }
        }

        init(session: CollieWebSession, requestKeyboard: @escaping @MainActor () async -> Void = {},
             pageReady: @escaping @MainActor () -> Void = {}, openNotificationSettings: @escaping @MainActor () -> Void = {}) {
            self.session = session
            self.requestKeyboard = requestKeyboard
            self.pageReady = pageReady
            self.openNotificationSettings = openNotificationSettings
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.frameInfo.isMainFrame,
                  session.isTrusted(message.frameInfo.request.url),
                  session.isTrusted(message.webView?.url) else { return }
            if message.name == "collieKeyboardRequested" {
                Task { @MainActor [weak self] in await self?.requestKeyboard() }
            } else if message.name == "collieNativeNotifications",
                      let body = message.body as? [String: String], body["action"] == "open-settings" {
                openNotificationSettings()
            } else if message.name == "collieNativePushCapability" {
                // Handler presence is the native-only capability signal. The page retains
                // its random token; no command or credential crosses this handler.
                return
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            guard navigationAction.targetFrame?.isMainFrame == true else { return .allow }
            guard session.isTrusted(navigationAction.request.url) else {
                if let url = navigationAction.request.url, ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
                    await UIApplication.shared.open(url)
                }
                return .cancel
            }
            return .allow
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation?) {
            session.dismissKeyboard()
            session.isLoading = true
            session.errorMessage = nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
            guard session.isTrusted(webView.url) else { return }
            session.dismissKeyboard()
            session.isLoading = false
            session.errorMessage = nil
            session.notePageTitle(webView.title, url: webView.url)
            pageReady()
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation?,
            withError error: Error
        ) {
            navigationFailed(error, in: webView)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation?,
            withError error: Error
        ) {
            navigationFailed(error, in: webView)
        }

        private func navigationFailed(_ error: Error, in webView: WKWebView) {
            // A superseded load reports "cancelled" while its replacement keeps going;
            // only clear the spinner when nothing else is loading.
            guard !CollieWebSession.isSupersededNavigation(error) else {
                // WebKit may still report isLoading during this callback; recheck once it settles.
                Task { @MainActor [weak webView, session] in
                    try? await Task.sleep(for: .milliseconds(500))
                    guard let webView, !webView.isLoading, session.errorMessage == nil else { return }
                    session.isLoading = false
                }
                return
            }
            session.isLoading = false
            session.errorMessage = CollieWebSession.userFacingMessage(for: error)
        }

        /// iOS may reclaim the web process while the app is in the background, which
        /// otherwise leaves a blank page with no error. Reload the workbench instead.
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            let now = ContinuousClock.now
            defer { lastProcessTermination = now }
            // A page that keeps crashing must not reload forever; let the user decide.
            if let last = lastProcessTermination, last.duration(to: now) < .seconds(15) {
                session.isLoading = false
                session.errorMessage = "工作台页面意外关闭，请重新加载。"
                return
            }
            session.reload()
        }

        func webView(
            _ webView: WKWebView,
            decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
            initiatedBy frame: WKFrameInfo,
            type: WKMediaCaptureType
        ) async -> WKPermissionDecision {
            .deny
        }
    }
}
