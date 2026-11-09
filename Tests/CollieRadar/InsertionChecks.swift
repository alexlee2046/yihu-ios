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
        // Collie 1.25+/1.26+ layout: Screen + Type toggles in composer-controls and mic-draft + primary in composer-box.
        const box = document.querySelector('[data-slot="composer-box"]');
        const controls = document.createElement('div');
        controls.setAttribute('data-slot', 'composer-controls');
        controls.innerHTML = '<button type="button" aria-pressed="true">Screen</button><button type="button" aria-pressed="false">Type</button>';
        document.body.prepend(controls);
        primary.setAttribute('data-slot', 'composer-primary');
        const micDraft = document.createElement('button');
        micDraft.setAttribute('data-slot', 'composer-mic-draft');
        micDraft.setAttribute('aria-pressed', 'false');
        box.insertBefore(micDraft, primary);
        await new Promise(resolve => setTimeout(resolve, 0));
        if (!window.collieNativePrepareInsert('v126-multi-toggle')) throw Error('v1.26 multi-toggle draft rejected');
        if (!(await window.collieNativeInsertText('v126 draft', 'v126-multi-toggle')) || other.value !== 'v126 draft') {
          throw Error('v1.26 multi-toggle insert failed');
        }
        // Durable composer layout: no aria-pressed buttons, primary Send disabled while empty.
        other.value = '';
        controls.innerHTML = '<button type="button" aria-expanded="false">Display</button>';
        micDraft.remove();
        primary.removeAttribute('aria-pressed');
        primary.disabled = true;
        if (!window.collieNativePrepareInsert('v126-durable')) throw Error('durable composer draft rejected');
        if (!(await window.collieNativeInsertText('durable draft', 'v126-durable')) || other.value !== 'durable draft') {
          throw Error('durable composer insert failed');
        }
        // In-flight send spinner blocks insertion even without aria-pressed.
        primary.innerHTML = '<span class="animate-spin"></span>';
        if (window.collieNativePrepareInsert('v126-sending')) throw Error('in-flight send accepted');
        primary.innerHTML = 'Send';
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

        // BLE Hotspot Wake protocol & proximity/cooldown checks.
        let offlineStatus = CollieHotspotMacStatus(state: .offline, host: "dev-macbook", ssid: "AL IPower", ts: 1_780_000_000)
        let onlineStatus = CollieHotspotMacStatus(state: .online, host: "dev-macbook", ssid: "AL IPower", ts: 1_780_000_010)
        let now = Date(timeIntervalSince1970: 1_780_000_020)
        precondition(CollieHotspotBLEProtocol.shouldAutoTriggerWake(status: offlineStatus, rssi: -65, lastWakeAt: nil, now: now))
        precondition(!CollieHotspotBLEProtocol.shouldAutoTriggerWake(status: offlineStatus, rssi: -88, lastWakeAt: nil, now: now))
        precondition(!CollieHotspotBLEProtocol.shouldAutoTriggerWake(status: onlineStatus, rssi: -55, lastWakeAt: nil, now: now))
        precondition(!CollieHotspotBLEProtocol.shouldAutoTriggerWake(status: offlineStatus, rssi: -65, lastWakeAt: now.addingTimeInterval(-10), now: now))
        precondition(CollieHotspotBLEProtocol.shouldAutoTriggerWake(status: offlineStatus, rssi: -65, lastWakeAt: now.addingTimeInterval(-30), now: now))
        precondition(CollieHotspotBLEProtocol.shortcutURL(named: "WakeHotspot")?.absoluteString == "shortcuts://run-shortcut?name=WakeHotspot")
        precondition(CollieHotspotBLEProtocol.shortcutURL(named: "  ") == nil)

        print("Synthetic WKWebView insertion checks passed: route binding and changed retry; focus redirection zero edits; native readonly, receipts, detached/background/refusal, disabled and host readonly guards; v1.26 multi-toggle/durable composer compatibility; BLE hotspot wake protocol; zero submit")
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
