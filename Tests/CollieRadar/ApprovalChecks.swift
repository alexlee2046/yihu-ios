import AppKit
import AuthenticationServices
import Foundation
import WebKit

@MainActor
private final class ApprovalNavigationProbe: NSObject, WKNavigationDelegate, WKUIDelegate {
    let workbenchURL = URL(string: "https://workbench.example.com")!
    var intercepted: [URL] = []
    var externalBlocked: [URL] = []
    var loadContinuation: CheckedContinuation<Void, Never>?

    private func isTrusted(_ url: URL?) -> Bool {
        guard let url else { return false }
        return url.scheme?.lowercased() == "https"
            && url.host?.lowercased() == "workbench.example.com"
            && (url.port == nil || url.port == 443)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadContinuation?.resume()
        loadContinuation = nil
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        let isMainOrNewWindow = navigationAction.targetFrame?.isMainFrame == true
            || navigationAction.targetFrame == nil
        if isMainOrNewWindow,
           navigationAction.sourceFrame.isMainFrame,
           isTrusted(webView.url) || isTrusted(navigationAction.sourceFrame.request.url),
           let url = navigationAction.request.url,
           CollieApproval.isApprovalURL(url, workbenchURL: workbenchURL) {
            intercepted.append(CollieApproval.inAppURL(url))
            return .cancel
        }
        guard navigationAction.targetFrame?.isMainFrame == true else { return .allow }
        guard isTrusted(navigationAction.request.url) else {
            if let url = navigationAction.request.url {
                externalBlocked.append(url)
            }
            return .cancel
        }
        return .allow
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.sourceFrame.isMainFrame,
           isTrusted(webView.url) || isTrusted(navigationAction.sourceFrame.request.url),
           let url = navigationAction.request.url,
           CollieApproval.isApprovalURL(url, workbenchURL: workbenchURL) {
            intercepted.append(CollieApproval.inAppURL(url))
        }
        return nil
    }
}

@MainActor
private func runApprovalChecks() async throws {
    let workbench = URL(string: "https://workbench.example.com")!

    // 1. Exact host & path checks
    precondition(CollieApproval.isApprovalURL(
        URL(string: "https://workbench.example.com:8443/?target=demo-service"),
        workbenchURL: workbench
    ))
    precondition(CollieApproval.isApprovalURL(
        URL(string: "https://WORKBENCH.EXAMPLE.COM:8443/approval/?target=demo-service"),
        workbenchURL: workbench
    ))
    precondition(CollieApproval.isApprovalURL(
        URL(string: "https://workbench.example.com:8443/"),
        workbenchURL: workbench
    ))

    // 2. Same-suffix / sibling host checks
    precondition(CollieApproval.isApprovalURL(
        URL(string: "https://approver.workbench.example.com:8443/?target=demo-service"),
        workbenchURL: workbench
    ))
    precondition(CollieApproval.isApprovalURL(
        URL(string: "https://workbench.example.com:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://chat.workbench.example.com")
    ))
    precondition(CollieApproval.isApprovalURL(
        URL(string: "https://node-b.team.example.com:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://node-a.team.example.com")
    ))
    precondition(CollieApproval.isApprovalURL(
        URL(string: "https://approver.net-alpha.ts.net:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://lead.net-alpha.ts.net")
    ))

    // 3. Security rejections: public suffixes, cross-tenant tailnets, ports, schemes, credentials, IP suffixes
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://evil.net-beta.ts.net:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://lead.net-alpha.ts.net")
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://tenant-b.ts.net:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://tenant-a.ts.net")
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://other.co.uk:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://first.co.uk")
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://other.github.io:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://first.github.io")
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://evil.other-domain.org:8443/?target=demo-service"),
        workbenchURL: workbench
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "http://workbench.example.com:8443/?target=demo-service"),
        workbenchURL: workbench
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://workbench.example.com:8443/?target=demo-service"),
        workbenchURL: URL(string: "http://workbench.example.com")
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://workbench.example.com:443/?target=demo-service"),
        workbenchURL: workbench
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://workbench.example.com/?target=demo-service"),
        workbenchURL: workbench
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://user:secret@workbench.example.com:8443/?target=demo-service"),
        workbenchURL: workbench
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://workbench.example.com:8443/api/state"),
        workbenchURL: workbench
    ))
    precondition(!CollieApproval.isApprovalURL(
        URL(string: "https://198.51.100.2:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://198.51.100.1")
    ))
    precondition(CollieApproval.isApprovalURL(
        URL(string: "https://198.51.100.1:8443/?target=demo-service"),
        workbenchURL: URL(string: "https://198.51.100.1")
    ))

    // 4. inAppURL normalization & idempotence
    let rawApproval = URL(string: "https://workbench.example.com:8443/?target=demo-service")!
    let inApp = CollieApproval.inAppURL(rawApproval)
    precondition(inApp.absoluteString == "https://workbench.example.com:8443/?target=demo-service&app=1")
    precondition(CollieApproval.inAppURL(inApp) == inApp)
    let overriddenApp = CollieApproval.inAppURL(
        URL(string: "https://workbench.example.com:8443/?target=demo-service&app=0")!
    )
    precondition(overriddenApp.absoluteString == "https://workbench.example.com:8443/?target=demo-service&app=1")

    // 5. Callback parsing & slug sanitization
    precondition(
        CollieApproval.parseCallback(URL(string: "benchside-approval://done?status=ok&target=demo-service")!)
            == .success("demo-service")
    )
    precondition(
        CollieApproval.parseCallback(URL(string: "benchside-approval://done?status=ok")!)
            == .success("")
    )
    precondition(
        CollieApproval.parseCallback(URL(string: "benchside-approval://done?status=failed&target=demo-service")!)
            == .failure(.rejected)
    )
    precondition(
        CollieApproval.parseCallback(URL(string: "https://workbench.example.com:8443/done?status=ok")!)
            == .failure(.invalidCallback)
    )
    precondition(
        CollieApproval.parseCallback(URL(string: "benchside-approval://done?status=ok&target=bad%0Aslug!!")!)
            == .success("")
    )

    // 6. State decoding & cancellation silence
    let stateJSON = Data(#"{"registrationOpen":false,"credentials":2,"targets":["svc-1","bad slug!","svc-2","svc-1","svc-3","svc-4","svc-5","svc-6","svc-7"]}"#.utf8)
    let targets = try CollieApproval.decodeTargets(from: stateJSON)
    precondition(targets == ["svc-2", "svc-3", "svc-4", "svc-5", "svc-6", "svc-7"])

    let canceledAuth = NSError(
        domain: ASWebAuthenticationSessionErrorDomain,
        code: ASWebAuthenticationSessionError.canceledLogin.rawValue
    )
    precondition(CollieApproval.isCancellation(canceledAuth))
    precondition(CollieApproval.resultAlertMessage(for: .failure(canceledAuth)) == nil)
    precondition(CollieApproval.resultAlertMessage(for: .failure(URLError(.cancelled))) == nil)
    precondition(CollieApproval.resultAlertMessage(for: .success("demo-service")) != nil)
    precondition(CollieApproval.resultAlertMessage(for: .failure(CollieApprovalError.rejected)) != nil)

    // 7. Remembered sibling candidate ordering
    let suiteName = "org.example.yihu.approval-checks.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }
    CollieApproval.rememberApprovalURL(
        URL(string: "https://approver.net-alpha.ts.net:8443/?target=demo-service")!,
        defaults: defaults
    )
    let candidates = CollieApproval.candidateBaseURLs(
        for: URL(string: "https://lead.net-alpha.ts.net")!,
        recentOrigins: [
            URL(string: "https://evil.net-beta.ts.net")!,
            URL(string: "https://backup.net-alpha.ts.net")!
        ],
        defaults: defaults
    )
    precondition(candidates.map(\.absoluteString) == [
        "https://approver.net-alpha.ts.net:8443/",
        "https://lead.net-alpha.ts.net:8443/",
        "https://backup.net-alpha.ts.net:8443/"
    ])

    // 8. Real WKWebView chat link interception (same-frame, target="_blank", window.open, foreign block)
    let config = WKWebViewConfiguration()
    config.websiteDataStore = .nonPersistent()
    let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 480, height: 640), configuration: config)
    let probe = ApprovalNavigationProbe()
    webView.navigationDelegate = probe
    webView.uiDelegate = probe
    let window = NSWindow(contentRect: webView.frame, styleMask: .borderless, backing: .buffered, defer: false)
    window.contentView = webView
    defer {
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        window.orderOut(nil)
        window.close()
    }
    await withCheckedContinuation { continuation in
        probe.loadContinuation = continuation
        webView.loadHTMLString("""
        <!doctype html><html><body>
          <a id="same" href="https://workbench.example.com:8443/?target=demo-same">Same</a>
          <a id="blank" href="https://approver.workbench.example.com:8443/?target=demo-blank" target="_blank" rel="noopener noreferrer">Blank</a>
          <a id="foreign" href="https://evil.other-domain.org:8443/?target=demo-foreign">Foreign</a>
        </body></html>
        """, baseURL: workbench)
    }

    _ = try await webView.evaluateJavaScript("document.getElementById('same').click(); true")
    try await Task.sleep(for: .milliseconds(80))
    precondition(probe.intercepted.map(\.absoluteString) == [
        "https://workbench.example.com:8443/?target=demo-same&app=1"
    ])

    _ = try await webView.evaluateJavaScript("document.getElementById('blank').click(); true")
    try await Task.sleep(for: .milliseconds(80))
    precondition(probe.intercepted.map(\.absoluteString) == [
        "https://workbench.example.com:8443/?target=demo-same&app=1",
        "https://approver.workbench.example.com:8443/?target=demo-blank&app=1"
    ])

    _ = try await webView.evaluateJavaScript("window.open('https://workbench.example.com:8443/?target=demo-popup', '_blank'); true")
    try await Task.sleep(for: .milliseconds(80))
    precondition(probe.intercepted.map(\.absoluteString) == [
        "https://workbench.example.com:8443/?target=demo-same&app=1",
        "https://approver.workbench.example.com:8443/?target=demo-blank&app=1",
        "https://workbench.example.com:8443/?target=demo-popup&app=1"
    ])

    _ = try await webView.evaluateJavaScript("document.getElementById('foreign').click(); true")
    try await Task.sleep(for: .milliseconds(80))
    precondition(probe.intercepted.count == 3)
    precondition(probe.externalBlocked.map(\.absoluteString) == [
        "https://evil.other-domain.org:8443/?target=demo-foreign"
    ])

    print("Production approval checks passed: exact & sibling suffix matching, public-suffix isolation, callback validation, state decoding, and WKWebView link interception")
}

@main
struct ApprovalChecksMain {
    @MainActor
    static func main() async {
        _ = NSApplication.shared
        do {
            try await runApprovalChecks()
            exit(0)
        } catch {
            print("Approval checks failed:", error)
            exit(1)
        }
    }
}
