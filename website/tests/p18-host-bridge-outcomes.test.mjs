import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { createHash } from 'node:crypto';

// SYNTHETIC_EXAMPLE: emitted by the original Swift enum, not replacement bridge logic.
const scripts = {"bridge_script": "if (window.location.origin !== origin || window.location.href !== pageURL || document.hidden) return 'refused';\nlet observed = false;\nlet accepted = false;\nconst detail = {\n  get text() { observed = true; return text; },\n  get accepted() { observed = true; return accepted; },\n  set accepted(value) { observed = true; accepted = value === true; }\n};\nconst event = new CustomEvent('collie:native-transcript', { detail, cancelable: true });\nwindow.dispatchEvent(event);\nif (accepted) return 'accepted';\nreturn observed || event.defaultPrevented ? 'refused' : 'unavailable';", "insert_script": "if (window.location.origin !== origin || window.location.href !== pageURL) return false;\nreturn (await window.collieNativeInsertText?.(text, requestID)) === true;", "user_script": "(() => {\n  if (window.location.origin !== \"https:\\/\\/synthetic.invalid\") return;\n  const textTypes = new Set(['', 'text', 'search', 'url', 'email']);\n  const editable = el => el instanceof HTMLTextAreaElement ||\n    (el instanceof HTMLInputElement && textTypes.has(el.type)) ||\n    (el instanceof HTMLElement && el.isContentEditable);\n  let last = null;\n  let focusedURL = null;\n  let prepared = null;\n  const receipts = new Map();\n  document.addEventListener('focusin', event => {\n    const target = event.composedPath()[0];\n    last = editable(target) ? new WeakRef(target) : null;\n    focusedURL = last ? window.location.href : null;\n  }, true);\n  const usable = el => !!el && el.isConnected && editable(el) &&\n    !el.matches(':disabled') && (!el.readOnly || window.collieNativeKeyboard?.canInsert(el) === true) &&\n    !el.closest('[inert], [aria-disabled=\"true\"], [aria-busy=\"true\"]') &&\n    el.getClientRects().length > 0 && getComputedStyle(el).visibility === 'visible';\n  // Stock v1.19.2 keeps its primary Mic/Send/Type action in composer-box;\n  // older layouts expose composer-controls. Both must prove draft mode.\n  const isSafeDraft = el => {\n    const collieFields = document.querySelectorAll('textarea[data-slot=\"chat-input\"]');\n    const colliePage = document.querySelector('meta[name=\"apple-mobile-web-app-title\"]')?.content === 'Collie' ||\n      document.querySelector('[data-slot=\"composer-box\"], [data-slot=\"composer-controls\"]') !== null;\n    if (!collieFields.length) return !colliePage;\n    if (collieFields.length !== 1 || collieFields[0] !== el ||\n        el.enterKeyHint !== 'enter') return false;\n    const box = el.closest('[data-slot=\"composer-box\"]');\n    if (!box) return false;\n    let scope = box.parentElement;\n    while (scope && !scope.querySelector('[data-slot=\"composer-controls\"]')) {\n      scope = scope.parentElement;\n    }\n    const controls = scope ? scope.querySelectorAll('[data-slot=\"composer-controls\"]') : [];\n    if (scope && (scope.querySelectorAll('textarea[data-slot=\"chat-input\"]').length !== 1 ||\n                  controls.length !== 1)) return false;\n    const modes = (scope ? controls[0] : box).querySelectorAll('button[aria-pressed]');\n    return modes.length === 1 && modes[0].getAttribute('aria-pressed') === 'false' &&\n      !modes[0].matches(':disabled') && modes[0].getAttribute('aria-disabled') !== 'true';\n  };\n  window.collieNativePrepareInsert = id => {\n    if (window.location.origin !== \"https:\\/\\/synthetic.invalid\" || document.hidden) return false;\n    const fields = document.querySelectorAll('textarea[data-slot=\"chat-input\"]');\n    const el = fields.length === 1 ? fields[0] : last?.deref();\n    prepared = { id, url: window.location.href,\n      target: usable(el) && isSafeDraft(el) ? new WeakRef(el) : null };\n    return prepared.target !== null;\n  };\n  // Only between two Latin letters/digits; never after CJK text or punctuation.\n  const needsSpace = (before, text) =>\n    /[A-Za-z0-9]$/u.test(before) && /^[A-Za-z0-9]/u.test(text);\n  // Shared files arrive in base64 chunks, then go to the page's own upload input.\n  const incoming = new Map();\n  window.collieNativeFileBegin = (id, name, type) => {\n    incoming.set(id, { name, type, parts: [] }); return true;\n  };\n  window.collieNativeFileChunk = (id, chunk) => {\n    const file = incoming.get(id);\n    if (!file) return false;\n    const binary = atob(chunk);\n    const bytes = new Uint8Array(binary.length);\n    for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);\n    file.parts.push(bytes);\n    return true;\n  };\n  window.collieNativeFileDiscard = ids => { ids.forEach(id => incoming.delete(id)); return true; };\n  const admits = (input, file) => {\n    const accept = (input.accept || '').split(',').map(a => a.trim().toLowerCase()).filter(Boolean);\n    if (!accept.length) return true;\n    const ext = '.' + (file.name.split('.').pop() || '').toLowerCase();\n    const type = (file.type || '').toLowerCase();\n    return accept.some(a => a === ext || a === type || (a.endsWith('/*') && type.startsWith(a.slice(0, -1))));\n  };\n  window.collieNativeAttachFiles = ids => {\n    const files = ids.map(id => {\n      const f = incoming.get(id); incoming.delete(id);\n      return f ? new File(f.parts, f.name, { type: f.type || 'application/octet-stream' }) : null;\n    }).filter(Boolean);\n    if (!files.length) return 'failed';\n    const inputs = Array.from(document.querySelectorAll('input[type=\"file\"]')).filter(i => !i.disabled);\n    const fits = input => files.length === 1 || input.multiple;\n    // Only an input whose accept list admits every file; never force a mismatched type.\n    const target = inputs.find(i => fits(i) && files.every(f => admits(i, f)));\n    if (!target) {\n      const singles = files.length > 1 && files.every(f => inputs.some(i => admits(i, f)));\n      return singles ? 'single-only' : 'no-input';\n    }\n    const transfer = new DataTransfer();\n    files.forEach(f => transfer.items.add(f));\n    target.files = transfer.files;\n    target.dispatchEvent(new Event('input', { bubbles: true }));\n    target.dispatchEvent(new Event('change', { bubbles: true }));\n    return 'attached';\n  };\n  window.collieNativeInsertReceipt = (text, id) => {\n    const previous = receipts.get(id);\n    if (!previous) return null;\n    if (previous.text !== text || previous.url !== window.location.href) return false;\n    const field = previous.target.deref();\n    return previous.accepted || (!!field && field.isConnected && field.value === previous.expected);\n  };\n  window.collieNativeInsertText = async (text, id) => {\n    if (window.location.origin !== \"https:\\/\\/synthetic.invalid\" || document.hidden ||\n        typeof text !== 'string' || !text || typeof id !== 'string') return false;\n    const held = prepared?.id === id ? prepared : null;\n    const url = held?.url ?? focusedURL;\n    if (url !== window.location.href) return false;\n    const previous = window.collieNativeInsertReceipt(text, id);\n    if (previous !== null) return previous;\n    const el = held?.target?.deref() ?? (held?.target ? null : last?.deref());\n    if (!usable(el) || !isSafeDraft(el)) return false;\n    // Native keyboard suppression stays in place. Programmatic value +\n    // input edits do not need focus, keyboard activation or submit keys.\n    if (!el.readOnly) {\n      el.focus({ preventScroll: true });\n      // Page focus handlers may redirect to an unrelated field.\n      // Never let the document-wide edit command follow that redirect.\n      if (document.activeElement !== el) return false;\n    }\n    if (url !== window.location.href || !usable(el) || !isSafeDraft(el)) return false;\n    const isField = el instanceof HTMLTextAreaElement || el instanceof HTMLInputElement;\n    const originalValue = isField ? el.value : null;\n    const start = isField ? el.selectionStart ?? el.value.length : 0;\n    const end = isField ? el.selectionEnd ?? start : 0;\n    const before = isField ? originalValue.slice(0, start) : '';\n    const inserted = needsSpace(before, text) ? ' ' + text : text;\n    const expectedValue = isField ? before + inserted + originalValue.slice(end) : null;\n    const receipt = { text, url, target: new WeakRef(el), expected: expectedValue, accepted: false };\n    if (receipts.size >= 32) {\n      const disposable = Array.from(receipts).find(([key, value]) => key !== prepared?.id && value.accepted);\n      if (!disposable) return false; // Do not evict an uncertain voice edit.\n      receipts.delete(disposable[0]);\n    }\n    receipts.set(id, receipt);\n    let ok = false;\n    if (!el.readOnly) {\n      if (document.activeElement !== el) return false;\n      if (!isField) {\n        const selection = window.getSelection();\n        if (!selection || !el.contains(selection.anchorNode) || !el.contains(selection.focusNode)) return false;\n      }\n      try { ok = document.execCommand('insertText', false, inserted); } catch (_) { ok = false; }\n    }\n    if (!ok && isField) {\n      // Frameworks track value through the native setter plus an input event.\n      const setter = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(el), 'value')?.set;\n      if (!setter) return false;\n      // Do not duplicate an edit a browser performed despite reporting failure.\n      if (el.value !== originalValue) return false;\n      setter.call(el, expectedValue);\n      // Some input types (e.g. email) reject selection APIs; the value is already set.\n      try { el.setSelectionRange(start + inserted.length, start + inserted.length); } catch (_) {}\n      el.dispatchEvent(new InputEvent('input', {\n        bubbles: true, composed: true, inputType: 'insertText', data: inserted\n      }));\n      ok = true;\n    }\n    // Let controlled inputs commit/reject the normal edit before acknowledging.\n    await new Promise(resolve => setTimeout(resolve, 0));\n    receipt.accepted = ok && el.isConnected && url === window.location.href &&\n      (!isField || el.value === expectedValue);\n    return receipt.accepted;\n  };\n})();"};
const sourceFragments = {"complete_insertion_enum": {"path": "Apps/Collie/CollieTextInsertion.swift", "sha256": "22ac311f9267b0c51ce5d54b577381d8cad88adc9cc8353afa5d31423f15e9a0"}, "    func insertTranscript(": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "28be0cf67eab45aa401c74a6d0ad996b04c9e37654d0ee43fd859efd307de6b1"}, "    fileprivate func isTrusted(": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "63e129a1ddbf1ebba0b8214add449882e3f195fa6a10fe918bd80c08560a2a27"}, "    fileprivate var trustedOrigin:": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "717291f9a4259a45f15851cd0c75fdcde444f141a597615a7fb588ba99d29006"}, "    private func effectivePort(": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "38d8c20fa9e5d74852e4c7d19342b78ad2ff574e6a97b76eab5e9de59c7b9ece"}};
const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => readFileSync(join(root, p), 'utf8');
const prefix = 'public/samples/p18-host-bridge-outcomes/';
const fixture = (lang) => JSON.parse(read(`${prefix}host-bridge-outcomes-preflight.${lang}.json`));
const active = 'host-bridge-outcome-boundaries';
const retired = 'focused-editable-admission-review';
const canonical = 'https://getyihu.com/';
const page = (lang, slug) => `src/pages/${lang === 'en' ? 'en/' : ''}guides/${slug}.md`;
const route = (lang, slug) => `${lang === 'en' ? 'en/' : ''}guides/${slug}/`;
const resources = ['host-bridge-outcomes-preflight.zh.json', 'host-bridge-outcomes-preflight.en.json', 'preflight-card.md'];

test('P18: frozen emitted JavaScript is tied to exact original Swift fragments, not a mirror implementation', () => {
  for (const [name, f] of Object.entries(sourceFragments)) {
    const raw = read(`../${f.path}`);
    let text;
    if (name === 'complete_insertion_enum') text = raw.slice(raw.indexOf('@MainActor\nenum CollieTextInsertion')).trim();
    else {
      const start = raw.indexOf(name); assert.ok(start >= 0);
      const body = name.startsWith('    func insertTranscript(') ? raw.indexOf(') async -> Bool {', start) : start;
      let i = raw.indexOf('{', body) + 1; let depth = 1;
      while (depth) { if (raw[i] === '{') depth++; else if (raw[i] === '}') depth--; i++; }
      text = raw.slice(start, i);
    }
    assert.equal(createHash('sha256').update(text).digest('hex'), f.sha256, name);
  }
});

function bridgeResult(mode) {
  let events = 0;
  const document = { hidden: mode === 'hidden' };
  class CustomEvent {
    constructor(type, args) { this.type = type; this.detail = args.detail; this.defaultPrevented = false; }
    preventDefault() { this.defaultPrevented = true; }
  }
  const window = {
    location: { origin: mode === 'wrong_origin' ? 'https://other.invalid' : 'https://synthetic.invalid', href: mode === 'wrong_page' ? 'https://synthetic.invalid/moved' : 'https://synthetic.invalid/work' },
    dispatchEvent(event) {
      events++;
      switch (mode) {
        case 'read_text': void event.detail.text; break;
        case 'read_accepted': void event.detail.accepted; break;
        case 'accept_true': event.detail.accepted = true; break;
        case 'accept_false': event.detail.accepted = false; break;
        case 'accept_string': event.detail.accepted = 'true'; break;
        case 'accept_number': event.detail.accepted = 1; break;
        case 'prevent': event.preventDefault(); break;
        case 'accept_and_prevent': event.detail.accepted = true; event.preventDefault(); break;
        case 'accept_then_refuse': event.detail.accepted = true; event.detail.accepted = false; break;
      }
      return !event.defaultPrevented;
    },
  };
  const sandbox = vm.createContext({ window, document, CustomEvent, origin: 'https://synthetic.invalid', pageURL: 'https://synthetic.invalid/work', text: 'SYNTHETIC_EXAMPLE: draft only' });
  const result = vm.runInContext(`(function(){${scripts.bridge_script}\n})()`, sandbox, { timeout: 1000 });
  return { result, events };
}

async function domResult(mode) {
  // Minimal deterministic objects, not a browser/jsdom/WebKit conformance claim.
  let execCalls = 0; let submitCalls = 0; const listeners = new Map();
  const document = {
    hidden: mode === 'hidden', activeElement: null,
    addEventListener(name, fn) { listeners.set(name, fn); },
    querySelectorAll() { return []; },
    querySelector(selector) { return mode === 'collie_unknown' && selector.startsWith('meta') ? { content: 'Collie' } : null; },
    execCommand(command, _, inserted) {
      assert.equal(command, 'insertText'); execCalls++;
      if (['setter_fallback', 'framework_reject', 'email_selection_throw', 'disconnect_after_setter'].includes(mode)) return false;
      const field = this.activeElement;
      field.value = field.value.slice(0, field.selectionStart) + inserted + field.value.slice(field.selectionEnd);
      return mode !== 'mutated_but_false';
    },
  };
  class HTMLElement {
    constructor() { this.isConnected = true; this.readOnly = mode === 'readonly' || mode === 'readonly_policy'; this.isContentEditable = false; this.selectionStart = mode === 'cjk' ? 2 : 5; this.selectionEnd = this.selectionStart; this._value = mode === 'cjk' ? '你好' : 'alpha'; }
    matches() { return false; }
    closest() { return null; }
    getClientRects() { return [{}]; }
    focus() { document.activeElement = mode === 'focus_redirect' ? new HTMLElement() : this; }
    setSelectionRange(a, b) { if (mode === 'email_selection_throw') throw new Error('synthetic selection unsupported'); this.selectionStart = a; this.selectionEnd = b; }
    dispatchEvent(event) { if (event.type === 'input' && mode === 'framework_reject') this._value = 'alpha'; if (event.type === 'input' && mode === 'disconnect_after_setter') this.isConnected = false; return true; }
    requestSubmit() { submitCalls++; throw new Error('submission forbidden'); }
    submit() { submitCalls++; throw new Error('submission forbidden'); }
  }
  class HTMLTextAreaElement extends HTMLElement { get value() { return this._value; } set value(v) { this._value = v; } }
  class HTMLInputElement extends HTMLElement { constructor() { super(); this.type = mode === 'password' ? 'password' : 'email'; } get value() { return this._value; } set value(v) { this._value = v; } }
  class Event { constructor(type, fields) { this.type = type; Object.assign(this, fields); } }
  class InputEvent extends Event {}
  const field = ['password', 'email_selection_throw'].includes(mode) ? new HTMLInputElement() : new HTMLTextAreaElement();
  const window = { location: { origin: 'https://synthetic.invalid', href: 'https://synthetic.invalid/work' }, collieNativeKeyboard: { canInsert: () => mode === 'readonly_policy' } };
  const sandbox = vm.createContext({ window, document, HTMLElement, HTMLInputElement, HTMLTextAreaElement, Event, InputEvent, WeakRef, getComputedStyle: () => ({ visibility: 'visible' }), setTimeout });
  vm.runInContext(scripts.user_script, sandbox, { timeout: 1000 });
  listeners.get('focusin')({ composedPath: () => [field] });
  window.collieNativePrepareInsert('SYNTHETIC-REQUEST');
  if (mode === 'moved_page') window.location.href = 'https://synthetic.invalid/moved';
  const text = mode === 'cjk' ? '世界' : 'beta';
  const accepted = await window.collieNativeInsertText(text, 'SYNTHETIC-REQUEST');
  const receipt = window.collieNativeInsertReceipt(text, 'SYNTHETIC-REQUEST');
  let retry;
  if (mode === 'same_id') retry = await window.collieNativeInsertText(text, 'SYNTHETIC-REQUEST');
  if (mode === 'different_text') retry = await window.collieNativeInsertText('different', 'SYNTHETIC-REQUEST');
  assert.equal(submitCalls, 0);
  assert.equal(field.readOnly, mode === 'readonly' || mode === 'readonly_policy');
  return { accepted, value: field.value, receipt, retry, execCalls };
}

for (const lang of ['zh', 'en']) {
  test(`P18 ${lang}: synthetic metadata preserves host/native/DOM/business receipt levels`, () => {
    const j = fixture(lang);
    assert.equal(j.classification, 'SYNTHETIC_EXAMPLE'); assert.equal(j.batch, 'SYN-BRG-39'); assert.equal(j.language, lang);
    assert.equal(j.source_commit, 'b4a162d0544d6241bbc60e7949af28f0b1a7a932');
    assert.equal(j.source_tree, '1e75a6af4778fb52abe7db27fe5fa78dddfaf936');
    assert.equal(j.is_app_import_schema, false); assert.equal(j.is_production_capture, false);
    assert.deepEqual(Object.values(j.runtime_checks), Array(10).fill('not_run'));
    assert.equal(j.source_contract.only_unavailable_allows_dom, true);
    assert.equal(j.source_contract.business_submission_proved, false);
    for (const [group, count] of [['native_cases', 19], ['bridge_cases', 13], ['dom_cases', 16], ['boundary_reviews', 4]]) {
      assert.equal(j[group].length, count); assert.equal(new Set(j[group].map((x) => x.id)).size, count);
    }
  });
  test(`P18 ${lang}: original synchronous bridge script observes reads/refusal and literal accepted=true precedence`, () => {
    for (const x of fixture(lang).bridge_cases) {
      const a = bridgeResult(x.mode); assert.equal(a.result, x.expected, x.id);
      if (['hidden', 'wrong_origin', 'wrong_page'].includes(x.mode)) assert.equal(a.events, 0);
    }
  });
  test(`P18 ${lang}: original emitted DOM adapter on synthetic objects preserves values/once receipts without submit`, async () => {
    for (const x of fixture(lang).dom_cases) {
      const a = await domResult(x.mode);
      for (const [key, value] of Object.entries(x.expected)) assert.equal(a[key], value, `${x.id} ${key}`);
      if (x.mode === 'same_id') { assert.equal(a.retry, true); assert.equal(a.execCalls, 1); }
      if (x.mode === 'different_text') { assert.equal(a.retry, false); assert.equal(a.execCalls, 1); }
      if (x.mode === 'readonly_policy') assert.equal(a.execCalls, 0);
    }
    // Execute original isolated-world wrapper too: arbitrary truthiness is not literal true.
    for (const value of [true, false, 1, 'true', null]) {
      const window = { location: { origin: 'https://synthetic.invalid', href: 'https://synthetic.invalid/work' }, collieNativeInsertText: async () => value };
      const context = vm.createContext({ window, origin: 'https://synthetic.invalid', pageURL: 'https://synthetic.invalid/work', text: 'synthetic', requestID: 'synthetic' });
      const actual = await vm.runInContext(`(async function(){${scripts.insert_script}\n})()`, context, { timeout: 1000 });
      assert.equal(actual, value === true);
    }
  });
}

test('P18: languages preserve identical synthetic machine cases, not translated protocol results', () => {
  const normalize = (j) => { const v = structuredClone(j); delete v.language; for (const x of v.boundary_reviews) delete x.label; return v; };
  assert.deepEqual(normalize(fixture('zh')), normalize(fixture('en')));
});

test('P18: active pair gains actual URLs and accessible tables, retired remains false; exact180/150/30', () => {
  const walk = (dir) => readdirSync(join(root, dir), { withFileTypes: true }).flatMap((x) => x.isDirectory() ? walk(`${dir}/${x.name}`) : [`${dir}/${x.name}`]);
  const pages = walk('src/pages').filter((p) => /\.(astro|md)$/.test(p));
  assert.equal(pages.length, 180); assert.equal(pages.filter((p) => /^---\n[\s\S]*?\nindexable: false\n[\s\S]*?---/.test(read(p))).length, 30);
  const sitemap = read('public/sitemap.xml'); assert.equal((sitemap.match(/<loc>/g) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const a = read(page(lang, active)); const r = read(page(lang, retired));
    assert.ok(!a.split('---')[1].includes('indexable: false')); assert.ok(r.split('---')[1].includes('indexable: false'));
    assert.ok(sitemap.includes(canonical + route(lang, active))); assert.ok(!sitemap.includes(canonical + route(lang, retired)));
    assert.ok(a.includes('SYNTHETIC_EXAMPLE') && a.includes('SYN-BRG-39') && a.includes('role="region"') && a.includes('tabindex="0"'));
    for (const name of resources) assert.ok(a.includes(`/samples/p18-host-bridge-outcomes/${name}`));
    for (const group of ['native_cases', 'bridge_cases', 'dom_cases', 'boundary_reviews']) for (const row of fixture(lang)[group]) assert.ok(a.includes(`| ${row.id} |`));
    assert.ok(r.includes(`](/${route(lang, active)})`)); assert.ok(!r.includes('/samples/p18-host-bridge-outcomes/'));
  }
});

test('P18: built samples and regenerated short/full LLM discovery match active pair, not retired sections', { skip: !existsSync(join(root, 'dist/index.html')) }, () => {
  for (const name of resources) assert.equal(read(`dist/samples/p18-host-bridge-outcomes/${name}`), read(`${prefix}${name}`));
  const short = read('public/llms.txt'); const full = read('public/llms-full.txt');
  assert.equal((full.match(/^Canonical: https:\/\/getyihu\.com\//gm) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const html = read(`dist/${route(lang, active)}index.html`);
    for (const name of resources) assert.ok(html.includes(`/samples/p18-host-bridge-outcomes/${name}`));
    for (const text of [short, full]) assert.ok(text.includes(`/samples/p18-host-bridge-outcomes/host-bridge-outcomes-preflight.${lang}.json`));
    assert.ok(full.includes(`Canonical: ${canonical}${route(lang, active)}\n`));
    assert.ok(!full.includes(`Canonical: ${canonical}${route(lang, retired)}\n`)); assert.ok(!short.includes(`](${canonical}${route(lang, retired)})\n`));
    const retiredHtml = read(`dist/${route(lang, retired)}index.html`); assert.ok(retiredHtml.includes('noindex,follow')); assert.ok(!retiredHtml.includes('/samples/p18-host-bridge-outcomes/'));
  }
  assert.ok(full.includes('SYN-BRG-39') && full.includes('Parameter/comparison tables (HTML)'));
});
