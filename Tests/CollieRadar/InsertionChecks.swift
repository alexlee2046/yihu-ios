import AppKit
import WebKit

@MainActor
final class Checks: NSObject, WKNavigationDelegate {
    let web: WKWebView
    var window: NSWindow?
    var continuation: CheckedContinuation<Void, Never>?
    override init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.userContentController.addUserScript(CollieTextInsertion.userScript(origin: "null")!)
        config.userContentController.addUserScript(CollieKeyboardPolicy.userScript(origin: "null")!)
        web = WKWebView(frame: NSRect(x: 0, y: 0, width: 500, height: 600), configuration: config)
        super.init(); web.navigationDelegate = self
        window = NSWindow(contentRect: web.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window?.contentView = web
        window?.makeKeyAndOrderFront(nil)
        window?.makeFirstResponder(web)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { continuation?.resume(); continuation = nil }
    func run() async throws {
        defer { web.stopLoading(); window?.orderOut(nil); window?.close(); window = nil }
        await withCheckedContinuation { c in
            continuation = c
            web.loadHTMLString("""
            <html><head><meta name="apple-mobile-web-app-title" content="Collie"></head><body>
            <div data-slot="composer-box"><textarea data-slot="chat-input" enterkeyhint="enter"></textarea><button aria-pressed="false">Send</button></div>
            <textarea id="unrelated">untouched</textarea>
            </body></html>
            """, baseURL: nil)
        }
        let setup = """
        // Headless WKWebView has no visible window; mock only this scene gate.
        Object.defineProperty(document, 'hidden', { configurable: true, get: () => false });
        window.field = document.querySelector('textarea'); window.primary = document.querySelector('button');
        window.inputs = 0; window.sends = 0;
        field.addEventListener('input', () => inputs++);
        primary.addEventListener('click', () => sends++);
        """
        _ = try await js(setup)
        let result = try await js("""
        if (!field.readOnly) throw Error('keyboard suppression missing');
        if (!window.collieNativePrepareInsert('one')) throw Error('no unfocused target');
        if (!(await window.collieNativeInsertText('synthetic draft', 'one'))) throw Error('readonly native edit failed');
        if (field.value !== 'synthetic draft' || !field.readOnly || sends !== 0 || inputs !== 1) throw Error('not draft only');
        if (!(await window.collieNativeInsertText('synthetic draft', 'one')) || inputs !== 1) throw Error('duplicate retry');
        field.value = ''; // A manually cleared/sent acknowledged draft is not reinserted.
        if (!(await window.collieNativeInsertText('synthetic draft', 'one')) || field.value !== '') throw Error('repeat after clear');
        if (await window.collieNativeInsertText('changed retry', 'one')) throw Error('changed payload reused receipt');
        if (field.value !== '' || inputs !== 1) throw Error('changed retry edited input');
        primary.setAttribute('aria-pressed', 'true');
        if (window.collieNativePrepareInsert('two')) throw Error('live typing accepted');
        if (await window.collieNativeInsertText('blocked', 'two')) throw Error('live typing mutation');
        primary.setAttribute('aria-pressed', 'false');
        window.collieNativeKeyboard.setEnabled(true);
        field.focus();
        if (!window.collieNativePrepareInsert('redirect')) throw Error('redirect target not captured');
        const foreign = document.querySelector('#unrelated');
        const redirectFocus = () => foreign.focus();
        foreign.focus();
        if (document.activeElement !== foreign) throw Error('headless focus was not activated');
        field.addEventListener('focus', redirectFocus, { once: true });
        const editsBeforeRedirect = inputs;
        if (await window.collieNativeInsertText('must not escape', 'redirect')) throw Error('redirect accepted');
        if (foreign.value !== 'untouched' || field.value !== '' || inputs !== editsBeforeRedirect) throw Error('focus redirect mutated a field');
        field.focus();
        window.collieNativeKeyboard.setEnabled(false);
        field.disabled = true;
        if (window.collieNativePrepareInsert('three')) throw Error('disabled accepted');
        if (await window.collieNativeInsertText('blocked', 'three')) throw Error('disabled mutation');
        field.disabled = false; window.collieNativeKeyboard.setEnabled(true); field.readOnly = true;
        if (window.collieNativePrepareInsert('four')) throw Error('host readonly accepted');
        if (await window.collieNativeInsertText('blocked', 'four')) throw Error('host readonly mutation');
        field.readOnly = false; window.collieNativeKeyboard.setEnabled(false);
        if (!window.collieNativePrepareInsert('detached')) throw Error('capture failed');
        field.remove();
        if (await window.collieNativeInsertText('blocked', 'detached')) throw Error('replacement target edited');
        const other = document.createElement('textarea'); other.setAttribute('data-slot','chat-input'); other.enterKeyHint='enter'; document.querySelector('[data-slot="composer-box"]').prepend(other);
        await new Promise(resolve => setTimeout(resolve, 0));
        if (!window.collieNativePrepareInsert('hidden')) throw Error('second capture failed');
        Object.defineProperty(document, 'hidden', { configurable: true, get: () => true });
        if (await window.collieNativeInsertText('blocked', 'hidden')) throw Error('background edit');
        Object.defineProperty(document, 'hidden', { configurable: true, get: () => false });
        if (!window.collieNativePrepareInsert('route-change')) throw Error('route target capture failed');
        history.replaceState({}, '', '#other-task');
        if (await window.collieNativeInsertText('wrong route', 'route-change')) throw Error('route change accepted');
        if (other.value !== '') throw Error('route change mutated target');
        history.replaceState({}, '', 'about:blank');
        window.addEventListener('collie:native-transcript', event => { void event.detail.text; });
        return true;
        """)
        guard result as? Bool == true else { throw NSError(domain: "Checks", code: 1) }
        let refusal = try await web.callAsyncJavaScript(CollieTextInsertion.collieBridgeScript, arguments: ["origin": "null", "pageURL": "about:blank", "text": "synthetic"], in: nil, contentWorld: .defaultClient)
        guard refusal as? String == "refused" else { throw NSError(domain: "BridgeRefusal", code: 1) }
        let wrongPage = try await web.callAsyncJavaScript(CollieTextInsertion.collieBridgeScript,
            arguments: ["origin": "null", "pageURL": "about:blank#different", "text": "synthetic"],
            in: nil, contentWorld: .defaultClient)
        guard wrongPage as? String == "refused" else { throw NSError(domain: "PageBinding", code: 1) }
        print("Synthetic WKWebView insertion checks passed: route binding and changed retry; focus redirection zero edits; native readonly, receipts, detached/background/refusal, disabled and host readonly guards; zero submit")
    }
    func js(_ source: String) async throws -> Any {
        try await web.callAsyncJavaScript(source, arguments: [:], in: nil, contentWorld: .defaultClient) ?? NSNull()
    }
}
@main struct Main {
    @MainActor static func main() async {
        _ = NSApplication.shared
        do { try await Checks().run(); exit(0) }
        catch { print("WKWebView checks failed:", error); exit(1) }
    }
}
