import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { createHash } from 'node:crypto';

// SYNTHETIC_EXAMPLE: the original Swift-emitted script, not a new file-transfer protocol.
const scripts = {"user_script": "(() => {\n  if (window.location.origin !== \"https:\\/\\/synthetic.invalid\") return;\n  const textTypes = new Set(['', 'text', 'search', 'url', 'email']);\n  const editable = el => el instanceof HTMLTextAreaElement ||\n    (el instanceof HTMLInputElement && textTypes.has(el.type)) ||\n    (el instanceof HTMLElement && el.isContentEditable);\n  let last = null;\n  let focusedURL = null;\n  let prepared = null;\n  const receipts = new Map();\n  document.addEventListener('focusin', event => {\n    const target = event.composedPath()[0];\n    last = editable(target) ? new WeakRef(target) : null;\n    focusedURL = last ? window.location.href : null;\n  }, true);\n  const usable = el => !!el && el.isConnected && editable(el) &&\n    !el.matches(':disabled') && (!el.readOnly || window.collieNativeKeyboard?.canInsert(el) === true) &&\n    !el.closest('[inert], [aria-disabled=\"true\"], [aria-busy=\"true\"]') &&\n    el.getClientRects().length > 0 && getComputedStyle(el).visibility === 'visible';\n  // Stock v1.19.2 keeps its primary Mic/Send/Type action in composer-box;\n  // older layouts expose composer-controls. Both must prove draft mode.\n  const isSafeDraft = el => {\n    const collieFields = document.querySelectorAll('textarea[data-slot=\"chat-input\"]');\n    const colliePage = document.querySelector('meta[name=\"apple-mobile-web-app-title\"]')?.content === 'Collie' ||\n      document.querySelector('[data-slot=\"composer-box\"], [data-slot=\"composer-controls\"]') !== null;\n    if (!collieFields.length) return !colliePage;\n    if (collieFields.length !== 1 || collieFields[0] !== el ||\n        el.enterKeyHint !== 'enter') return false;\n    const box = el.closest('[data-slot=\"composer-box\"]');\n    if (!box) return false;\n    let scope = box.parentElement;\n    while (scope && !scope.querySelector('[data-slot=\"composer-controls\"]')) {\n      scope = scope.parentElement;\n    }\n    const controls = scope ? scope.querySelectorAll('[data-slot=\"composer-controls\"]') : [];\n    if (scope && (scope.querySelectorAll('textarea[data-slot=\"chat-input\"]').length !== 1 ||\n                  controls.length !== 1)) return false;\n    const modes = (scope ? controls[0] : box).querySelectorAll('button[aria-pressed]');\n    return modes.length === 1 && modes[0].getAttribute('aria-pressed') === 'false' &&\n      !modes[0].matches(':disabled') && modes[0].getAttribute('aria-disabled') !== 'true';\n  };\n  window.collieNativePrepareInsert = id => {\n    if (window.location.origin !== \"https:\\/\\/synthetic.invalid\" || document.hidden) return false;\n    const fields = document.querySelectorAll('textarea[data-slot=\"chat-input\"]');\n    const el = fields.length === 1 ? fields[0] : last?.deref();\n    prepared = { id, url: window.location.href,\n      target: usable(el) && isSafeDraft(el) ? new WeakRef(el) : null };\n    return prepared.target !== null;\n  };\n  // Only between two Latin letters/digits; never after CJK text or punctuation.\n  const needsSpace = (before, text) =>\n    /[A-Za-z0-9]$/u.test(before) && /^[A-Za-z0-9]/u.test(text);\n  // Shared files arrive in base64 chunks, then go to the page's own upload input.\n  const incoming = new Map();\n  window.collieNativeFileBegin = (id, name, type) => {\n    incoming.set(id, { name, type, parts: [] }); return true;\n  };\n  window.collieNativeFileChunk = (id, chunk) => {\n    const file = incoming.get(id);\n    if (!file) return false;\n    const binary = atob(chunk);\n    const bytes = new Uint8Array(binary.length);\n    for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);\n    file.parts.push(bytes);\n    return true;\n  };\n  window.collieNativeFileDiscard = ids => { ids.forEach(id => incoming.delete(id)); return true; };\n  const admits = (input, file) => {\n    const accept = (input.accept || '').split(',').map(a => a.trim().toLowerCase()).filter(Boolean);\n    if (!accept.length) return true;\n    const ext = '.' + (file.name.split('.').pop() || '').toLowerCase();\n    const type = (file.type || '').toLowerCase();\n    return accept.some(a => a === ext || a === type || (a.endsWith('/*') && type.startsWith(a.slice(0, -1))));\n  };\n  window.collieNativeAttachFiles = ids => {\n    const files = ids.map(id => {\n      const f = incoming.get(id); incoming.delete(id);\n      return f ? new File(f.parts, f.name, { type: f.type || 'application/octet-stream' }) : null;\n    }).filter(Boolean);\n    if (!files.length) return 'failed';\n    const inputs = Array.from(document.querySelectorAll('input[type=\"file\"]')).filter(i => !i.disabled);\n    const fits = input => files.length === 1 || input.multiple;\n    // Only an input whose accept list admits every file; never force a mismatched type.\n    const target = inputs.find(i => fits(i) && files.every(f => admits(i, f)));\n    if (!target) {\n      const singles = files.length > 1 && files.every(f => inputs.some(i => admits(i, f)));\n      return singles ? 'single-only' : 'no-input';\n    }\n    const transfer = new DataTransfer();\n    files.forEach(f => transfer.items.add(f));\n    target.files = transfer.files;\n    target.dispatchEvent(new Event('input', { bubbles: true }));\n    target.dispatchEvent(new Event('change', { bubbles: true }));\n    return 'attached';\n  };\n  window.collieNativeInsertReceipt = (text, id) => {\n    const previous = receipts.get(id);\n    if (!previous) return null;\n    if (previous.text !== text || previous.url !== window.location.href) return false;\n    const field = previous.target.deref();\n    return previous.accepted || (!!field && field.isConnected && field.value === previous.expected);\n  };\n  window.collieNativeInsertText = async (text, id) => {\n    if (window.location.origin !== \"https:\\/\\/synthetic.invalid\" || document.hidden ||\n        typeof text !== 'string' || !text || typeof id !== 'string') return false;\n    const held = prepared?.id === id ? prepared : null;\n    const url = held?.url ?? focusedURL;\n    if (url !== window.location.href) return false;\n    const previous = window.collieNativeInsertReceipt(text, id);\n    if (previous !== null) return previous;\n    const el = held?.target?.deref() ?? (held?.target ? null : last?.deref());\n    if (!usable(el) || !isSafeDraft(el)) return false;\n    // Native keyboard suppression stays in place. Programmatic value +\n    // input edits do not need focus, keyboard activation or submit keys.\n    if (!el.readOnly) {\n      el.focus({ preventScroll: true });\n      // Page focus handlers may redirect to an unrelated field.\n      // Never let the document-wide edit command follow that redirect.\n      if (document.activeElement !== el) return false;\n    }\n    if (url !== window.location.href || !usable(el) || !isSafeDraft(el)) return false;\n    const isField = el instanceof HTMLTextAreaElement || el instanceof HTMLInputElement;\n    const originalValue = isField ? el.value : null;\n    const start = isField ? el.selectionStart ?? el.value.length : 0;\n    const end = isField ? el.selectionEnd ?? start : 0;\n    const before = isField ? originalValue.slice(0, start) : '';\n    const inserted = needsSpace(before, text) ? ' ' + text : text;\n    const expectedValue = isField ? before + inserted + originalValue.slice(end) : null;\n    const receipt = { text, url, target: new WeakRef(el), expected: expectedValue, accepted: false };\n    if (receipts.size >= 32) {\n      const disposable = Array.from(receipts).find(([key, value]) => key !== prepared?.id && value.accepted);\n      if (!disposable) return false; // Do not evict an uncertain voice edit.\n      receipts.delete(disposable[0]);\n    }\n    receipts.set(id, receipt);\n    let ok = false;\n    if (!el.readOnly) {\n      if (document.activeElement !== el) return false;\n      if (!isField) {\n        const selection = window.getSelection();\n        if (!selection || !el.contains(selection.anchorNode) || !el.contains(selection.focusNode)) return false;\n      }\n      try { ok = document.execCommand('insertText', false, inserted); } catch (_) { ok = false; }\n    }\n    if (!ok && isField) {\n      // Frameworks track value through the native setter plus an input event.\n      const setter = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(el), 'value')?.set;\n      if (!setter) return false;\n      // Do not duplicate an edit a browser performed despite reporting failure.\n      if (el.value !== originalValue) return false;\n      setter.call(el, expectedValue);\n      // Some input types (e.g. email) reject selection APIs; the value is already set.\n      try { el.setSelectionRange(start + inserted.length, start + inserted.length); } catch (_) {}\n      el.dispatchEvent(new InputEvent('input', {\n        bubbles: true, composed: true, inputType: 'insertText', data: inserted\n      }));\n      ok = true;\n    }\n    // Let controlled inputs commit/reject the normal edit before acknowledging.\n    await new Promise(resolve => setTimeout(resolve, 0));\n    receipt.accepted = ok && el.isConnected && url === window.location.href &&\n      (!isField || el.value === expectedValue);\n    return receipt.accepted;\n  };\n})();"};
const sourceFragments = {"complete_insertion_enum": {"path": "Apps/Collie/CollieTextInsertion.swift", "sha256": "581a970697d7917332839c364fb4b0efc27cd11846787b6ffaaf6fa14b597ebf"}, "    struct SharedFile:": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "fce47cf84cd4b0d4921dfbdc61bf57cd20e2812e60f5bdfe780270d084ffe2a8"}, "    enum AttachResult": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "9a002b08ab8be593860b8f43fcd47eb4bdebbc5dffa332c535e1a7323a8f63a5"}, "    func attachFiles(": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "af01a55d12a17bbab0eba422dcccc3234b5a9ce6607718545a5b62561a647b7a"}, "    private nonisolated static func base64Chunk(": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "0984bdf6695d7e68485ace229cfe1d93d842d885b994dc687e9c797c01424c2a"}, "    fileprivate func isTrusted(": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "63e129a1ddbf1ebba0b8214add449882e3f195fa6a10fe918bd80c08560a2a27"}, "    fileprivate var trustedOrigin:": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "717291f9a4259a45f15851cd0c75fdcde444f141a597615a7fb588ba99d29006"}, "    private func effectivePort(": {"path": "Apps/Collie/CollieWebView.swift", "sha256": "38d8c20fa9e5d74852e4c7d19342b78ad2ff574e6a97b76eab5e9de59c7b9ece"}, "complete_inbox": {"path": "Shared/CollieShareInbox.swift", "sha256": "81072d62ab65ce659e03b1ff15ca3235e35ca9e3d5a12b32823e54d7831b3e41"}};
const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => readFileSync(join(root, p), 'utf8');
const prefix = 'public/samples/p19-file-chunk-bridge/';
const fixture = (lang) => JSON.parse(read(`${prefix}preflight.${lang}.json`));
const active = 'file-chunk-bridge-not-upload-receipt';
const retired = 'app-group-inbox-access-evidence';
const canonical = 'https://getyihu.com/';
const page = (lang, slug) => `src/pages/${lang === 'en' ? 'en/' : ''}guides/${slug}.md`;
const route = (lang, slug) => `${lang === 'en' ? 'en/' : ''}guides/${slug}/`;
const resources = ['preflight.zh.json', 'preflight.en.json', 'preflight-card.md'];

test('P19: frozen emitted helper is tied to original Swift attachment/read/inbox source, no mirrored protocol', () => {
  for (const [name, f] of Object.entries(sourceFragments)) {
    const raw = read(`../${f.path}`); let text;
    if (name === 'complete_insertion_enum') text = raw.slice(raw.indexOf('@MainActor\nenum CollieTextInsertion')).trim();
    else if (name === 'complete_inbox') text = raw;
    else {
      const start = raw.indexOf(name); assert.ok(start >= 0);
      let i = raw.indexOf('{', start) + 1; let depth = 1;
      while (depth) { if (raw[i] === '{') depth++; else if (raw[i] === '}') depth--; i++; }
      text = raw.slice(start, i);
    }
    assert.equal(createHash('sha256').update(text).digest('hex'), f.sha256, name);
  }
});

function runVM(mode) {
  const inputs = []; let submits = 0;
  const input = { disabled: false, multiple: false, accept: '', files: [], events: [], dispatchEvent(e) { this.events.push(e.type); return true; }, submit() { submits++; throw new Error('forbidden'); } };
  if (mode !== 'no_input') inputs.push(input);
  if (mode === 'multiple') input.multiple = true;
  if (mode === 'type_mismatch') input.accept = 'image/*';
  class HTMLElement {}
  class HTMLInputElement extends HTMLElement {}
  class HTMLTextAreaElement extends HTMLElement {}
  class Event { constructor(type, props) { this.type = type; Object.assign(this, props); } }
  class File { constructor(parts, name, options) { this.name = name; this.type = options.type; this.bytes = Buffer.concat(parts.map((p) => Buffer.from(p))); this.size = this.bytes.length; } }
  class DataTransfer { constructor() { this.files = []; this.items = { add: (f) => this.files.push(f) }; } }
  const window = { location: { origin: 'https://synthetic.invalid', href: 'https://synthetic.invalid/work' } };
  const document = { addEventListener() {}, querySelectorAll: (s) => s === 'input[type="file"]' ? inputs : [], querySelector: () => null };
  const context = vm.createContext({ window, document, HTMLElement, HTMLInputElement, HTMLTextAreaElement, Event, File, DataTransfer, Uint8Array, WeakRef, atob });
  vm.runInContext(scripts.user_script, context, { timeout: 1000 });
  const begin = (id = 'a', type = 'application/octet-stream') => window.collieNativeFileBegin(id, 'SYNTHETIC.bin', type);
  const chunk = (bytes, id = 'a') => window.collieNativeFileChunk(id, Buffer.from(bytes).toString('base64'));
  const attach = (ids = ['a']) => window.collieNativeAttachFiles(ids);
  const expected = [0, 255, 1, 2, 3]; let result;
  switch (mode) {
    case 'unknown_chunk': result = String(chunk([1], 'unknown')); break;
    case 'invalid_base64': begin(); assert.throws(() => window.collieNativeFileChunk('a', '!')); result = 'throws'; break;
    case 'discard': begin(); chunk([1]); assert.equal(window.collieNativeFileDiscard(['a']), true); result = String(chunk([2])); break;
    case 'duplicate': begin(); chunk([1, 2, 3]); chunk([1, 2, 3]); result = attach(); assert.deepEqual([...input.files[0].bytes], [1, 2, 3, 1, 2, 3]); break;
    case 'reordered': begin(); chunk([3, 4]); chunk([1, 2]); result = attach(); assert.deepEqual([...input.files[0].bytes], [3, 4, 1, 2]); break;
    case 'missing_chunk': begin(); chunk([1]); chunk([3]); result = attach(); assert.deepEqual([...input.files[0].bytes], [1, 3]); break;
    case 'rebegin': begin(); chunk([1]); begin(); chunk([2]); result = attach(); assert.deepEqual([...input.files[0].bytes], [2]); break;
    case 'single_only':
    case 'multiple': begin(); chunk([1]); begin('b'); chunk([2], 'b'); result = attach(['a', 'b']); if (mode === 'multiple') assert.equal(input.files.length, 2); break;
    case 'partial_ids': begin(); chunk([1]); result = attach(['missing', 'a']); assert.equal(input.files.length, 1); break;
    case 'empty_file': begin(); result = attach(); assert.equal(input.files[0].size, 0); break;
    case 'repeat_attach': begin(); chunk([1]); assert.equal(attach(), 'attached'); result = attach(); break;
    case 'empty_mime': begin('a', ''); chunk([1]); result = attach(); assert.equal(input.files[0].type, 'application/octet-stream'); break;
    default:
      begin(); assert.equal(chunk(expected.slice(0, 2)), true); assert.equal(chunk(expected.slice(2)), true);
      result = attach();
      if (['normal', 'binary_split'].includes(mode)) assert.deepEqual([...input.files[0].bytes], expected);
  }
  if (result === 'attached' || mode === 'repeat_attach') assert.deepEqual(input.events, ['input', 'change']);
  if (['no_input', 'single_only', 'type_mismatch'].includes(mode)) assert.equal(chunk([9]), false, 'IDs were consumed, not an automatic retry cache');
  assert.equal(submits, 0);
  return result;
}

for (const lang of ['zh', 'en']) {
  test(`P19 ${lang}: synthetic byte/chunk/inbox and remote receipt levels stay separate`, () => {
    const j = fixture(lang);
    assert.equal(j.classification, 'SYNTHETIC_EXAMPLE'); assert.equal(j.batch, 'SYN-CHK-40'); assert.equal(j.language, lang);
    assert.equal(j.source_commit, '631bb2f6744ffbe573f18a39829c9a72c8d17226'); assert.equal(j.source_tree, 'c6b0fa38020ff30f7f907269f02698842a55621d');
    assert.equal(j.is_app_import_schema, false); assert.equal(j.is_production_capture, false);
    assert.deepEqual(Object.values(j.runtime_checks), Array(10).fill('not_run'));
    assert.equal(j.source_contract.raw_chunk_bytes, 786432); assert.equal(j.source_contract.begin_boolean_is_not_checked_by_native, true);
    assert.equal(j.source_contract.chunk_sequence_or_checksum_protocol, false); assert.equal(j.source_contract.attached_proves_remote_completion, false);
    assert.equal(j.source_contract.pending_decodes_not_payload_validation, true); assert.equal(j.source_contract.real_app_group_entitlement_proved, false);
    for (const [group, count] of [['native_cases', 16], ['read_cases', 5], ['vm_cases', 17], ['inbox_cases', 11], ['boundary_reviews', 4]]) {
      assert.equal(j[group].length, count); assert.equal(new Set(j[group].map((x) => x.id)).size, count);
    }
    assert.equal(j.native_cases.find((x) => x.mode === 'begin_false').expected.result, 'attached');
    assert.equal(j.inbox_cases.find((x) => x.mode === 'missing_payload').expected_pending, 1);
    assert.equal(j.inbox_cases.find((x) => x.mode === 'corrupt_json').expected_pending, 0);
    assert.deepEqual(j.read_cases.find((x) => x.bytes === 786433).expected_chunks, [786432, 1]);
  });
  test(`P19 ${lang}: original JS file helpers reassemble supplied parts but do not certify ordering, completeness or upload`, () => {
    for (const x of fixture(lang).vm_cases) assert.equal(runVM(x.mode), x.expected, x.id);
  });
}

test('P19: translated labels do not alter original-stage machine expectations', () => {
  const normalize = (j) => { const v = structuredClone(j); delete v.language; for (const r of v.boundary_reviews) delete r.label; return v; };
  assert.deepEqual(normalize(fixture('zh')), normalize(fixture('en')));
});

test('P19: exactly3 public resources on active pair, retired false and180/150/30 unchanged', () => {
  const walk = (dir) => readdirSync(join(root, dir), { withFileTypes: true }).flatMap((x) => x.isDirectory() ? walk(`${dir}/${x.name}`) : [`${dir}/${x.name}`]);
  const pages = walk('src/pages').filter((p) => /\.(astro|md)$/.test(p)); assert.equal(pages.length, 180);
  assert.equal(pages.filter((p) => /^---\n[\s\S]*?\nindexable: false\n[\s\S]*?---/.test(read(p))).length, 30);
  assert.deepEqual(readdirSync(join(root, prefix)).sort(), [...resources].sort());
  const sitemap = read('public/sitemap.xml'); assert.equal((sitemap.match(/<loc>/g) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const a = read(page(lang, active)); const r = read(page(lang, retired));
    assert.ok(!a.split('---')[1].includes('indexable: false')); assert.ok(r.split('---')[1].includes('indexable: false'));
    assert.ok(sitemap.includes(canonical + route(lang, active))); assert.ok(!sitemap.includes(canonical + route(lang, retired)));
    assert.ok(a.includes('SYNTHETIC_EXAMPLE') && a.includes('SYN-CHK-40') && a.includes('role="region"') && a.includes('tabindex="0"'));
    for (const name of resources) assert.ok(a.includes(`/samples/p19-file-chunk-bridge/${name}`));
    for (const group of ['native_cases', 'read_cases', 'vm_cases', 'inbox_cases', 'boundary_reviews']) for (const row of fixture(lang)[group]) assert.ok(a.includes(`| ${row.id} |`));
    assert.ok(r.includes(`](/${route(lang, active)})`)); assert.ok(!r.includes('/samples/p19-file-chunk-bridge/'));
  }
});

test('P19: built bytes and original-generator LLMs discover active preflight URLs, not retired sections', { skip: !existsSync(join(root, 'dist/index.html')) }, () => {
  for (const name of resources) assert.equal(read(`dist/samples/p19-file-chunk-bridge/${name}`), read(`${prefix}${name}`));
  const short = read('public/llms.txt'); const full = read('public/llms-full.txt'); assert.equal((full.match(/^Canonical: https:\/\/getyihu\.com\//gm) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const html = read(`dist/${route(lang, active)}index.html`); for (const name of resources) assert.ok(html.includes(`/samples/p19-file-chunk-bridge/${name}`));
    for (const text of [short, full]) assert.ok(text.includes(`/samples/p19-file-chunk-bridge/preflight.${lang}.json`));
    assert.ok(full.includes(`Canonical: ${canonical}${route(lang, active)}\n`)); assert.ok(!full.includes(`Canonical: ${canonical}${route(lang, retired)}\n`));
    assert.ok(!short.includes(`](${canonical}${route(lang, retired)})\n`)); const retiredHtml = read(`dist/${route(lang, retired)}index.html`);
    assert.ok(retiredHtml.includes('noindex,follow')); assert.ok(!retiredHtml.includes('/samples/p19-file-chunk-bridge/'));
  }
});
