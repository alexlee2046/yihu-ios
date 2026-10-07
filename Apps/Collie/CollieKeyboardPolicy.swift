import Foundation
import WebKit

/// Native-only adapter for Collie's stable chat-input slot. It never reads or
/// writes drafts, changes disabled/auth state, or touches search/pairing fields.
/// The isolated content world keeps the switch out of the page's JS namespace.
@MainActor
enum CollieKeyboardPolicy {
    static func userScript(origin: String) -> WKUserScript? {
        guard let data = try? JSONEncoder().encode(origin),
              let literal = String(data: data, encoding: .utf8) else { return nil }
        let source = """
        (() => {
          if (window.location.origin !== \(literal)) return;
          const selector = 'textarea[data-slot="chat-input"]';
          const originals = new WeakMap();
          let enabled = false;
          const fields = () => Array.from(document.querySelectorAll(selector));
          function apply(field) {
            if (enabled) {
              if (originals.has(field)) {
                field.readOnly = originals.get(field);
                originals.delete(field);
              }
            } else {
              if (!originals.has(field)) originals.set(field, field.readOnly);
              if (!field.readOnly) field.readOnly = true;
            }
          }
          function sync() { fields().forEach(apply); }
          new MutationObserver(sync).observe(document, {
            childList: true, subtree: true, attributes: true,
            attributeFilter: ['readonly', 'data-slot']
          });
          document.addEventListener('focusin', event => {
            const field = event.target;
            if (!enabled && field instanceof HTMLTextAreaElement && field.matches(selector)) {
              apply(field);
              field.blur();
            }
          }, true);
          // Ask the native shell to use the same guarded path as its keyboard
          // button. Page scripts cannot synthesize a trusted user click.
          document.addEventListener('click', event => {
            const field = event.target;
            if (!event.isTrusted || enabled || !(field instanceof HTMLTextAreaElement) ||
                !field.matches(selector) || field.disabled ||
                (originals.get(field) ?? field.readOnly)) return;
            window.webkit.messageHandlers.collieKeyboardRequested.postMessage(null);
          }, true);
          function disable() {
            enabled = false;
            sync();
            if (document.activeElement?.matches(selector)) document.activeElement.blur();
          }
          // A back/forward-cached document retains JS and DOM state; do not
          // restore an armed keyboard when it becomes visible again.
          window.addEventListener('pagehide', disable);
          window.addEventListener('pageshow', disable);
          window.addEventListener('popstate', disable);
          window.collieNativeKeyboard = {
            setEnabled(next) {
              if (typeof next !== 'boolean') return false;
              const target = fields().find(field => !field.disabled &&
                !(originals.get(field) ?? field.readOnly) && field.getClientRects().length > 0);
              if (next && !target) return false;
              enabled = next;
              sync();
              if (enabled) target.focus({ preventScroll: true });
              else if (document.activeElement?.matches(selector)) document.activeElement.blur();
              return true;
            }
          };
          sync();
        })();
        """
        return WKUserScript(source: source, injectionTime: .atDocumentStart,
                            forMainFrameOnly: true, in: .defaultClient)
    }

    static let setEnabledScript = """
    if (window.location.origin !== origin || !window.collieNativeKeyboard) return false;
    return window.collieNativeKeyboard.setEnabled(enabled);
    """
}
