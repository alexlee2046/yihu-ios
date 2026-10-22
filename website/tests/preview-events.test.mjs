import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import ts from 'typescript';
const root = new URL('../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
const compiled = ts.transpileModule(read('src/lib/preview-events.ts'), {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
}).outputText;
function harness({ origin = 'https://getyihu.com', preference = 'granted', disabled = false, canonical = 'https://getyihu.com/', storageThrows = false, tag = true } = {}) {
  const calls = [], exports = {};
  const browser = {
    location: { origin },
    localStorage: { getItem(key) { assert.equal(key, 'yihu.analytics-consent.v1'); if (storageThrows) throw Error('blocked'); return preference; } },
    document: { querySelector() { return canonical ? { href: canonical } : null; } },
    'ga-disable-G-CWT1FWEHCL': disabled,
    ...(tag ? { gtag: (...args) => calls.push(args) } : {}),
  };
  vm.runInNewContext(compiled, { window: browser, exports, URL });
  return { track: exports.trackPreviewEvent, calls, browser };
}
for (const preference of [null, 'denied', '', 'malformed', 'GRANTED']) test('new preview events fail closed for preference ' + JSON.stringify(preference), () => {
  const h = harness({ preference }); assert.equal(h.track('preview_complete', 'voice', 'zh', 'insert'), false); assert.equal(h.calls.length, 0);
});
for (const origin of ['http://localhost:4321', 'http://127.0.0.1:4321', 'https://preview.example', 'https://getyihu.com.evil.example']) test('new preview events stay off outside production: ' + origin, () => {
  const h = harness({ origin }); assert.equal(h.track('scenario_select', 'audio', 'en', 'select'), false); assert.equal(h.calls.length, 0);
});
for (const opts of [{ storageThrows: true }, { disabled: true }, { disabled: undefined }, { tag: false }, { canonical: null }, { canonical: 'https://evil.example/' }, { canonical: 'https://getyihu.com/private/customer-name/' }]) test('blocked bootstrap/storage/canonical drops events: ' + JSON.stringify(opts), () => {
  const h = harness(opts);
  // Explicitly unset the bootstrap flag; a missing initializer cannot grant consent.
  if ('disabled' in opts && opts.disabled === undefined) delete h.browser['ga-disable-G-CWT1FWEHCL'];
  assert.equal(h.track('setup_click', 'radar', 'en', 'setup'), false); assert.equal(h.calls.length, 0);
});
test('explicit grant emits only four bounded parameters, without query/hash/editor/JSON contents', () => {
  const h = harness({ canonical: 'https://getyihu.com/en/guides/recording-notes-handoff/?private=never-send#draft' });
  assert.equal(h.track('preview_complete', 'voice', 'en', 'insert'), true);
  assert.equal(JSON.stringify(h.calls), JSON.stringify([['event', 'preview_complete', { language: 'en', scenario: 'voice', page: '/en/guides/recording-notes-handoff/', action: 'insert' }]]));
});
test('withdrawal blocks subsequent events even when the saved grant remains after write failure', () => {
  const h = harness();
  assert.equal(h.track('scenario_select', 'voice', 'zh', 'select'), true);
  h.browser['ga-disable-G-CWT1FWEHCL'] = true;
  for (const event of ['scenario_select', 'preview_complete', 'setup_click']) assert.equal(h.track(event, 'voice', 'zh', 'insert'), false);
  assert.equal(h.calls.length, 1);
});
test('unknown runtime parameters and disabled tags cannot leak arbitrary content', () => {
  const h = harness();
  for (const args of [['customer text', 'voice', 'zh', 'select'], ['scenario_select', 'private text', 'zh', 'select'], ['scenario_select', 'voice', 'private text', 'select'], ['scenario_select', 'voice', 'zh', '{"customer":"sample"}']]) assert.equal(h.track(...args), false);
  assert.equal(h.calls.length, 0);
  h.browser.gtag = () => { throw Error('blocked'); };
  assert.equal(h.track('scenario_select', 'voice', 'zh', 'select'), false);
});
test('all three Radar examples use existing native fields and matching project identities in both languages', () => {
  const data = JSON.parse(read('src/data/preview-samples.json'));
  const model = readFileSync(new URL('../Apps/Collie/CollieRadarModel.swift', root), 'utf8');
  for (const lang of ['zh', 'en']) for (const name of ['inquiry', 'market', 'followup']) {
    const sample = data[lang].radar[name];
    assert.deepEqual(Object.keys(sample).sort(), ['active', 'cold', 'date_str', 'decisions', 'stale', 'tasks']);
    assert.equal(typeof sample.date_str, 'string');
    assert.equal(sample.tasks.length, 1);
    for (const [kind, rows] of [['tasks', sample.tasks], ['active', sample.active]]) for (const row of rows) for (const key of Object.keys(row)) assert.ok(new RegExp('(?:let|var)\\s+' + key + '\\s*[:=]').test(model), kind + '.' + key);
    assert.equal(sample.tasks[0].project, sample.active[0].path);
    assert.ok(Number.isFinite(sample.active[0].timestamp));
    assert.equal(new URL(sample.tasks[0].url).hostname, 'example.com');
    assert.ok(sample.tasks[0].evidence.includes(lang === 'en' ? 'Synthetic' : '合成'));
  }
});
test('preview does not add network AI, mic/Bluetooth requests, persistent state or playback on mount', () => {
  const source = read('src/components/Demo.tsx');
  for (const forbidden of ['getUserMedia', 'requestDevice', 'XMLHttpRequest', 'fetch(', 'fetch (', 'localStorage', 'sessionStorage']) assert.ok(!source.includes(forbidden));
  assert.ok(source.includes("window.addEventListener('pagehide'"));
  assert.ok(source.includes("document.addEventListener('visibilitychange'"));
  assert.ok(source.includes('generation.current !== token'));
  assert.ok(source.includes('Browser read-aloud is unavailable'));
  assert.ok(source.includes('<noscript>'));
});
test('recording-note intent is distinct from the web-draft buyer scenario', () => {
  const h = harness({ canonical: 'https://getyihu.com/en/guides/recording-notes-handoff/' });
  assert.equal(h.track('preview_complete', 'notes', 'en', 'insert'), true);
  assert.equal(h.calls[0][2].scenario, 'notes');
});
