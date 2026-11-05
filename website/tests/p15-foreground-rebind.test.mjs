import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => readFileSync(join(root, p), 'utf8');
const prefix = 'public/samples/p15-foreground-rebind/';
const fixture = (lang) => JSON.parse(read(`${prefix}foreground-rebind-preflight.${lang}.json`));
const active = 'foreground-audio-rebind-preflight';
const retired = 'shortcut-toggle-request-lifetime';
const canonical = 'https://getyihu.com/';
const source = '45495e8888618fd1ec26607f7bf3d875549e68c4';
const page = (lang, slug) => `src/pages/${lang === 'en' ? 'en/' : ''}guides/${slug}.md`;
const route = (lang, slug) => `${lang === 'en' ? 'en/' : ''}guides/${slug}/`;
const resources = ['foreground-rebind-preflight.zh.json', 'foreground-rebind-preflight.en.json', 'preflight-card.md'];

for (const lang of ['zh', 'en']) {
  test(`P15 ${lang}: synthetic lifecycle, shortcut lifetime and route/format declarations remain distinct from physical recovery`, () => {
    const j = fixture(lang);
    assert.equal(j.classification, 'SYNTHETIC_EXAMPLE');
    assert.equal(j.batch, 'SYN-REBIND-36');
    assert.equal(j.language, lang);
    assert.equal(j.source_commit, source);
    assert.equal(j.source_tree, '05150cb785391a85ea8d402fb787a026553d1a7f');
    assert.equal(j.is_app_import_schema, false);
    assert.equal(j.is_production_capture, false);
    assert.deepEqual(Object.values(j.runtime_checks), Array(10).fill('not_run'));
    assert.equal(j.lifecycle_cases.length, 10);
    assert.equal(j.shortcut_cases.length, 7);
    assert.equal(j.format_route_cases.length, 7);
    assert.equal(j.buffer_recovery_review.length, 4);
    for (const group of ['lifecycle_cases', 'shortcut_cases', 'format_route_cases', 'buffer_recovery_review']) {
      assert.equal(new Set(j[group].map((x) => x.id)).size, j[group].length);
    }
    const l = Object.fromEntries(j.lifecycle_cases.map((x) => [x.id, x]));
    assert.equal(l.L1.expected.phase, 'preparing');
    assert.equal(l.L1.expected.session_changed, false);
    assert.equal(l.L2.expected.phase, 'failed');
    assert.equal(l.L2.expected.old_permission_guard_passes, false);
    assert.equal(l.L6.pending_transcript, '');
    assert.equal(l.L6.expected.pending_transcript, '');
    assert.equal(l.L7.expected.recorder_cancel_calls, 0);
    assert.equal(l.L8.expected.recorder_start_calls, 0);
    assert.equal(l.L9.expected.recorder_start_calls, 1);
    assert.equal(l.L10.expected.phase, 'failed');
    const s = Object.fromEntries(j.shortcut_cases.map((x) => [x.id, x]));
    assert.deepEqual(s.S3.consume_at_ms, [30000, 30001]);
    assert.deepEqual(s.S3.expected_results, [true, false]);
    assert.deepEqual(s.S4.expected_results, [false]);
    assert.deepEqual(s.S5.expected_results, [true, false]);
    assert.deepEqual(s.S7.expected_results, [true, false, false]);
    const f = Object.fromEntries(j.format_route_cases.map((x) => [x.id, x]));
    assert.deepEqual(f.F2.expected, { format_same: true, route_same: true });
    assert.deepEqual(f.F3.expected, { format_same: true, route_same: false });
    for (const id of ['F4', 'F5', 'F6', 'F7']) assert.equal(f[id].expected.format_same, false);
    assert.ok(j.buffer_recovery_review.every((x) => x.runtime === 'not_run'));
    assert.ok(j.manual_go_no_go.no_go.length >= 5);
  });
}

test('P15: Chinese and English fixtures preserve identical machine expectations, not translated booleans', () => {
  const normalize = (j) => {
    const copy = structuredClone(j);
    delete copy.language;
    for (const row of copy.lifecycle_cases) delete row.label;
    return copy;
  };
  assert.deepEqual(normalize(fixture('zh')), normalize(fixture('en')));
});

test('P15: only active pair gains visible download URLs and accessible case tables; retirement/index sets stay 180/150/30', () => {
  const walk = (dir) => readdirSync(join(root, dir), { withFileTypes: true }).flatMap((x) => x.isDirectory() ? walk(`${dir}/${x.name}`) : [`${dir}/${x.name}`]);
  const pages = walk('src/pages').filter((p) => /\.(astro|md)$/.test(p));
  assert.equal(pages.length, 180);
  const falsePages = pages.filter((p) => /^---\n[\s\S]*?\nindexable: false\n[\s\S]*?---/.test(read(p)));
  assert.equal(falsePages.length, 30);
  const sitemap = read('public/sitemap.xml');
  assert.equal((sitemap.match(/<loc>/g) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const a = read(page(lang, active));
    const r = read(page(lang, retired));
    assert.ok(!a.split('---')[1].includes('indexable: false'));
    assert.ok(r.split('---')[1].includes('indexable: false'));
    assert.ok(sitemap.includes(canonical + route(lang, active)));
    assert.ok(!sitemap.includes(canonical + route(lang, retired)));
    assert.ok(a.includes('SYNTHETIC_EXAMPLE') && a.includes('SYN-REBIND-36'));
    assert.ok(a.includes('role="region"') && a.includes('tabindex="0"'));
    for (const name of resources) assert.ok(a.includes(`/samples/p15-foreground-rebind/${name}`));
    for (const group of ['lifecycle_cases', 'shortcut_cases', 'format_route_cases', 'buffer_recovery_review']) {
      for (const row of fixture(lang)[group]) assert.ok(a.includes(`| ${row.id} |`), `${lang} visible ${row.id}`);
    }
    assert.ok(r.includes(`](/${route(lang, active)})`));
    assert.ok(!r.includes('/samples/p15-foreground-rebind/'));
  }
});

test('P15: built sample bytes and both original-generator LLM discovery entries match active resources; retired is not an export section', { skip: !existsSync(join(root, 'dist/index.html')) }, () => {
  for (const name of resources) {
    assert.equal(read(`dist/samples/p15-foreground-rebind/${name}`), read(`${prefix}${name}`));
  }
  const short = read('public/llms.txt');
  const full = read('public/llms-full.txt');
  assert.equal((full.match(/^Canonical: https:\/\/getyihu\.com\//gm) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const html = read(`dist/${route(lang, active)}index.html`);
    for (const name of resources) assert.ok(html.includes(`/samples/p15-foreground-rebind/${name}`));
    for (const text of [short, full]) {
      assert.ok(text.includes(`/samples/p15-foreground-rebind/foreground-rebind-preflight.${lang}.json`));
    }
    assert.ok(full.includes(`Canonical: ${canonical}${route(lang, active)}\n`));
    assert.ok(!full.includes(`Canonical: ${canonical}${route(lang, retired)}\n`));
    assert.ok(!short.includes(`](${canonical}${route(lang, retired)})\n`));
    const retiredHtml = read(`dist/${route(lang, retired)}index.html`);
    assert.ok(retiredHtml.includes('noindex,follow'));
    assert.ok(!retiredHtml.includes('/samples/p15-foreground-rebind/'));
  }
  assert.ok(full.includes('SYN-REBIND-36') && full.includes('Parameter/comparison tables (HTML)'));
});
