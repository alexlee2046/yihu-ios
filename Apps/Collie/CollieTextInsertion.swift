import Foundation
import WebKit

/// Workbench-agnostic transcript insertion. Collie pages keep their explicit
/// `collie:native-transcript` bridge (a refusal there stays a refusal); any other
/// trusted page (OpenClaw Control UI, Hermes dashboard, …) receives the text only
/// in the text field the user last focused, through the same editing path as
/// typing. It never guesses a field and never submits.
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
          document.addEventListener('focusin', event => {
            const target = event.composedPath()[0];
            if (editable(target)) last = new WeakRef(target);
          }, true);
          const usable = el => !!el && el.isConnected && !el.disabled && !el.readOnly &&
            el.getClientRects().length > 0;
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
          window.collieNativeInsertText = text => {
            if (typeof text !== 'string' || !text) return false;
            // A Collie composer declined on purpose (locked, sending, …): keep it declined.
            if (document.querySelector('textarea[data-slot="chat-input"]')) return false;
            const el = last?.deref();
            if (!usable(el)) return false;
            el.focus({ preventScroll: true });
            const isField = el instanceof HTMLTextAreaElement || el instanceof HTMLInputElement;
            const before = isField ? el.value.slice(0, el.selectionStart ?? el.value.length) : '';
            const inserted = needsSpace(before, text) ? ' ' + text : text;
            let ok = false;
            try { ok = document.execCommand('insertText', false, inserted); } catch (_) { ok = false; }
            if (!ok && isField) {
              // Frameworks track value through the native setter plus an input event.
              const setter = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(el), 'value')?.set;
              if (!setter) return false;
              const start = el.selectionStart ?? el.value.length;
              const end = el.selectionEnd ?? start;
              setter.call(el, el.value.slice(0, start) + inserted + el.value.slice(end));
              // Some input types (e.g. email) reject selection APIs; the value is already set.
              try { el.setSelectionRange(start + inserted.length, start + inserted.length); } catch (_) {}
              el.dispatchEvent(new InputEvent('input', {
                bubbles: true, composed: true, inputType: 'insertText', data: inserted
              }));
              ok = true;
            }
            return ok;
          };
        })();
        """
        return WKUserScript(source: source, injectionTime: .atDocumentStart,
                            forMainFrameOnly: true, in: .defaultClient)
    }

    /// Collie's explicit bridge, in the page world where its listener lives.
    static let collieBridgeScript = """
    if (window.location.origin !== origin) return false;
    const detail = { text, accepted: false };
    window.dispatchEvent(new CustomEvent('collie:native-transcript', { detail }));
    return detail.accepted === true;
    """

    /// Runs only after Collie's explicit bridge did not take the text.
    static let insertScript = """
    if (window.location.origin !== origin) return false;
    return window.collieNativeInsertText?.(text) === true;
    """
}
