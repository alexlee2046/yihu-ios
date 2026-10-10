import Foundation
import WebKit

/// The thin, optional host bridge plus guarded DOM adapter for unmodified pages.
/// An observed bridge refusal is final. Without a bridge, only the user's last
/// focused editable receives text; known Collie composers must prove draft mode.
/// Unknown layouts fail closed and leave the transcript in the native UI.
@MainActor
enum CollieTextInsertion {
    /// Tracks the last focused editable element, including inside shadow roots.
    static func userScript(origin: String) -> WKUserScript? {
        guard let data = try? JSONEncoder().encode(origin),
              let literal = String(data: data, encoding: .utf8) else { return nil }
        let source = """
        (() => {
          if (window.location.origin !== \(literal)) return;
          const textTypes = new Set(['', 'text', 'search', 'url', 'email']);
          const editable = el => el instanceof HTMLTextAreaElement ||
            (el instanceof HTMLInputElement && textTypes.has(el.type)) ||
            (el instanceof HTMLElement && el.isContentEditable);
          let last = null;
          let focusedURL = null;
          document.addEventListener('focusin', event => {
            const target = event.composedPath()[0];
            last = editable(target) ? new WeakRef(target) : null;
            focusedURL = last ? window.location.href : null;
          }, true);
          const usable = el => !!el && el.isConnected && editable(el) &&
            !el.matches(':disabled') && !el.readOnly &&
            !el.closest('[inert], [aria-disabled="true"], [aria-busy="true"]') &&
            el.getClientRects().length > 0 && getComputedStyle(el).visibility === 'visible';
          // Stock Collie v1.19.2 exposes locking on the textarea and sending / live
          // terminal typing on the Type control. Require the full known shape:
          // a missing or newly ambiguous control is NOT evidence of draft mode.
          const isSafeDraft = el => {
            const collieFields = document.querySelectorAll('textarea[data-slot="chat-input"]');
            const colliePage = document.querySelector('meta[name="apple-mobile-web-app-title"]')?.content === 'Collie' ||
              document.querySelector('[data-slot="composer-box"], [data-slot="composer-controls"]') !== null;
            if (!collieFields.length) return !colliePage;
            if (collieFields.length !== 1 || collieFields[0] !== el ||
                el.enterKeyHint !== 'enter') return false;
            const box = el.closest('[data-slot="composer-box"]');
            if (!box) return false;
            let scope = box.parentElement;
            while (scope && !scope.querySelector('[data-slot="composer-controls"]')) {
              scope = scope.parentElement;
            }
            if (!scope || scope.querySelectorAll('textarea[data-slot="chat-input"]').length !== 1 ||
                scope.querySelectorAll('[data-slot="composer-controls"]').length !== 1) return false;
            const modes = scope.querySelectorAll('[data-slot="composer-controls"] button[aria-pressed]');
            return modes.length === 1 && modes[0].getAttribute('aria-pressed') === 'false' &&
              !modes[0].matches(':disabled') && modes[0].getAttribute('aria-disabled') !== 'true';
          };
          // Only between two Latin letters/digits; never after CJK text or punctuation.
          const needsSpace = (before, text) =>
            /[A-Za-z0-9]$/u.test(before) && /^[A-Za-z0-9]/u.test(text);
          // Shared files arrive in base64 chunks, then go to the page's own upload input.
          const incoming = new Map();
          window.collieNativeFileBegin = (id, name, type) => {
            incoming.set(id, { name, type, parts: [] }); return true;
          };
          window.collieNativeFileChunk = (id, chunk) => {
            const file = incoming.get(id);
            if (!file) return false;
            const binary = atob(chunk);
            const bytes = new Uint8Array(binary.length);
            for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
            file.parts.push(bytes);
            return true;
          };
          window.collieNativeFileDiscard = ids => { ids.forEach(id => incoming.delete(id)); return true; };
          const admits = (input, file) => {
            const accept = (input.accept || '').split(',').map(a => a.trim().toLowerCase()).filter(Boolean);
            if (!accept.length) return true;
            const ext = '.' + (file.name.split('.').pop() || '').toLowerCase();
            const type = (file.type || '').toLowerCase();
            return accept.some(a => a === ext || a === type || (a.endsWith('/*') && type.startsWith(a.slice(0, -1))));
          };
          window.collieNativeAttachFiles = ids => {
            const files = ids.map(id => {
              const f = incoming.get(id); incoming.delete(id);
              return f ? new File(f.parts, f.name, { type: f.type || 'application/octet-stream' }) : null;
            }).filter(Boolean);
            if (!files.length) return 'failed';
            const inputs = Array.from(document.querySelectorAll('input[type="file"]')).filter(i => !i.disabled);
            const fits = input => files.length === 1 || input.multiple;
            // Only an input whose accept list admits every file; never force a mismatched type.
            const target = inputs.find(i => fits(i) && files.every(f => admits(i, f)));
            if (!target) {
              const singles = files.length > 1 && files.every(f => inputs.some(i => admits(i, f)));
              return singles ? 'single-only' : 'no-input';
            }
            const transfer = new DataTransfer();
            files.forEach(f => transfer.items.add(f));
            target.files = transfer.files;
            target.dispatchEvent(new Event('input', { bubbles: true }));
            target.dispatchEvent(new Event('change', { bubbles: true }));
            return 'attached';
          };
          window.collieNativeInsertText = async text => {
            if (window.location.origin !== \(literal) || document.hidden ||
                typeof text !== 'string' || !text || focusedURL !== window.location.href) return false;
            const el = last?.deref();
            if (!usable(el) || !isSafeDraft(el)) return false;
            el.focus({ preventScroll: true });
            // Focus handlers can change the route, mode or editability.
            if (last?.deref() !== el || focusedURL !== window.location.href ||
                !usable(el) || !isSafeDraft(el)) return false;
            const isField = el instanceof HTMLTextAreaElement || el instanceof HTMLInputElement;
            const originalValue = isField ? el.value : null;
            const start = isField ? el.selectionStart ?? el.value.length : 0;
            const end = isField ? el.selectionEnd ?? start : 0;
            const before = isField ? originalValue.slice(0, start) : '';
            const inserted = needsSpace(before, text) ? ' ' + text : text;
            const expectedValue = isField ? before + inserted + originalValue.slice(end) : null;
            let ok = false;
            try { ok = document.execCommand('insertText', false, inserted); } catch (_) { ok = false; }
            if (!ok && isField) {
              // Frameworks track value through the native setter plus an input event.
              const setter = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(el), 'value')?.set;
              if (!setter) return false;
              // Do not duplicate an edit a browser performed despite reporting failure.
              if (el.value !== originalValue) return false;
              setter.call(el, expectedValue);
              // Some input types (e.g. email) reject selection APIs; the value is already set.
              try { el.setSelectionRange(start + inserted.length, start + inserted.length); } catch (_) {}
              el.dispatchEvent(new InputEvent('input', {
                bubbles: true, composed: true, inputType: 'insertText', data: inserted
              }));
              ok = true;
            }
            // Let controlled inputs commit/reject the normal edit before acknowledging.
            await new Promise(resolve => setTimeout(resolve, 0));
            return ok && el.isConnected && focusedURL === window.location.href &&
              (!isField || el.value === expectedValue);
          };
        })();
        """
        return WKUserScript(source: source, injectionTime: .atDocumentStart,
                            forMainFrameOnly: true, in: .defaultClient)
    }

    /// Optional synchronous bridge. Track reads as well as acknowledgement:
    /// the legacy listener reads `accepted` before its locked/sending checks.
    /// This distinguishes its refusal from stock Collie's absent listener without
    /// patching page globals, registering a fake bridge or persisting capabilities.
    static let collieBridgeScript = """
    if (window.location.origin !== origin || document.hidden) return 'refused';
    let observed = false;
    let accepted = false;
    const detail = {
      get text() { observed = true; return text; },
      get accepted() { observed = true; return accepted; },
      set accepted(value) { observed = true; accepted = value === true; }
    };
    const event = new CustomEvent('collie:native-transcript', { detail, cancelable: true });
    window.dispatchEvent(event);
    if (accepted) return 'accepted';
    return observed || event.defaultPrevented ? 'refused' : 'unavailable';
    """

    /// Runs only when no host bridge handled the event; never after a refusal.
    static let insertScript = """
    if (window.location.origin !== origin) return false;
    return (await window.collieNativeInsertText?.(text)) === true;
    """
}
