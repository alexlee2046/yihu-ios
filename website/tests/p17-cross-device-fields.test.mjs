import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => readFileSync(join(root, p), 'utf8');
const prefix = 'public/samples/p17-cross-device-fields/';
const fixture = (lang) => JSON.parse(read(`${prefix}cross-device-fields-preflight.${lang}.json`));
const active = 'cross-device-field-presentation';
const retired = 'watch-voice-queued-ready-boundaries';
const canonical = 'https://getyihu.com/';
const page = (lang, slug) => `src/pages/${lang === 'en' ? 'en/' : ''}guides/${slug}.md`;
const route = (lang, slug) => `${lang === 'en' ? 'en/' : ''}guides/${slug}/`;
const resources = ['cross-device-fields-preflight.zh.json', 'cross-device-fields-preflight.en.json', 'preflight-card.md'];

for (const lang of ['zh', 'en']) {
  test(`P17 ${lang}: synthetic carrier fields, clipping, defaults and codec limits are not delivery or write receipts`, () => {
    const j = fixture(lang);
    assert.equal(j.classification, 'SYNTHETIC_EXAMPLE');
    assert.equal(j.batch, 'SYN-XDEV-38');
    assert.equal(j.language, lang);
    assert.equal(j.source_commit, 'e592f63af7061072d6683f89423b3abf2fee2a7c');
    assert.equal(j.source_tree, 'a278454faf98bab436d238b5433047ef804c33a7');
    assert.equal(j.is_app_import_schema, false);
    assert.equal(j.is_production_capture, false);
    assert.deepEqual(Object.values(j.runtime_checks), Array(10).fill('not_run'));
    assert.deepEqual([j.source_contract.title_character_prefix, j.source_contract.project_character_prefix, j.source_contract.next_character_prefix], [160, 80, 600]);
    assert.equal(j.source_contract.maximum_payload_bytes, 50000);
    assert.equal(j.source_contract.maximum_items, 200);
    assert.equal(j.source_contract.field_clip_sets_truncated, false);
    assert.equal(j.source_contract.empty_tasks_falls_back, false);
    const p = Object.fromEntries(j.publish_cases.map((x) => [x.id, x]));
    assert.equal(p.P2.expected.truncated, false);
    assert.equal(p.P2.expected.next_characters, 600);
    assert.equal(p.P3.expected.title_utf8_greater_than_characters, true);
    assert.equal(p.P4.expected.item_count, 0);
    assert.equal(p.P5.expected.item_count, 1);
    assert.equal(p.P6.expected.phone_attention_count, 2);
    assert.equal(p.P6.expected.item_count, 0);
    assert.equal(p.P7.expected.first_task, ' ');
    assert.equal(p.P8.expected.within_200_items, true);
    assert.equal(p.P9.expected.item_count_less_than_input, true);
    assert.equal(p.P10.expected.source_date_missing, true);
    assert.equal(p.P11.expected.read_failed, true);
    const d = Object.fromEntries(j.codec_cases.map((x) => [x.id, x]));
    for (const id of ['D1', 'D2', 'D4', 'D10']) assert.equal(d[id].accepted, true);
    for (const id of ['D3', 'D5', 'D6', 'D7', 'D8', 'D9', 'D11']) assert.equal(d[id].accepted, false);
    assert.equal(j.presentation_cases[1].expected_next, ' ');
    assert.equal(j.presentation_cases[1].expected_priority_visible, true);
    for (const [group, count] of [['publish_cases', 11], ['codec_cases', 11], ['presentation_cases', 4], ['boundary_reviews', 4]]) {
      assert.equal(j[group].length, count);
      assert.equal(new Set(j[group].map((x) => x.id)).size, count);
    }
    assert.ok(j.boundary_reviews.every((x) => x.runtime === 'not_run'));
  });
}

test('P17: translated descriptions do not change machine inputs or expected cross-carrier differences', () => {
  const normalize = (j) => {
    const v = structuredClone(j);
    delete v.language;
    for (const group of ['publish_cases', 'boundary_reviews']) for (const row of v[group]) delete row.label;
    return v;
  };
  assert.deepEqual(normalize(fixture('zh')), normalize(fixture('en')));
});

test('P17: only active pair gains three real download URLs and accessible field tables; 180/150/30 unchanged', () => {
  const walk = (dir) => readdirSync(join(root, dir), { withFileTypes: true }).flatMap((x) => x.isDirectory() ? walk(`${dir}/${x.name}`) : [`${dir}/${x.name}`]);
  const pages = walk('src/pages').filter((p) => /\.(astro|md)$/.test(p));
  assert.equal(pages.length, 180);
  assert.equal(pages.filter((p) => /^---\n[\s\S]*?\nindexable: false\n[\s\S]*?---/.test(read(p))).length, 30);
  const sitemap = read('public/sitemap.xml');
  assert.equal((sitemap.match(/<loc>/g) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const a = read(page(lang, active));
    const r = read(page(lang, retired));
    assert.ok(!a.split('---')[1].includes('indexable: false'));
    assert.ok(r.split('---')[1].includes('indexable: false'));
    assert.ok(sitemap.includes(canonical + route(lang, active)));
    assert.ok(!sitemap.includes(canonical + route(lang, retired)));
    assert.ok(a.includes('SYNTHETIC_EXAMPLE') && a.includes('SYN-XDEV-38'));
    assert.ok(a.includes('role="region"') && a.includes('tabindex="0"'));
    for (const name of resources) assert.ok(a.includes(`/samples/p17-cross-device-fields/${name}`));
    for (const group of ['publish_cases', 'codec_cases', 'presentation_cases', 'boundary_reviews']) {
      for (const row of fixture(lang)[group]) assert.ok(a.includes(`| ${row.id} |`), `${lang} visible ${row.id}`);
    }
    assert.ok(r.includes(`](/${route(lang, active)})`));
    assert.ok(!r.includes('/samples/p17-cross-device-fields/'));
  }
});

test('P17: built resource bytes and both original-generator LLM entries match active fields; retired has no section', { skip: !existsSync(join(root, 'dist/index.html')) }, () => {
  for (const name of resources) assert.equal(read(`dist/samples/p17-cross-device-fields/${name}`), read(`${prefix}${name}`));
  const short = read('public/llms.txt');
  const full = read('public/llms-full.txt');
  assert.equal((full.match(/^Canonical: https:\/\/getyihu\.com\//gm) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const html = read(`dist/${route(lang, active)}index.html`);
    for (const name of resources) assert.ok(html.includes(`/samples/p17-cross-device-fields/${name}`));
    for (const text of [short, full]) assert.ok(text.includes(`/samples/p17-cross-device-fields/cross-device-fields-preflight.${lang}.json`));
    assert.ok(full.includes(`Canonical: ${canonical}${route(lang, active)}\n`));
    assert.ok(!full.includes(`Canonical: ${canonical}${route(lang, retired)}\n`));
    assert.ok(!short.includes(`](${canonical}${route(lang, retired)})\n`));
    const retiredHtml = read(`dist/${route(lang, retired)}index.html`);
    assert.ok(retiredHtml.includes('noindex,follow'));
    assert.ok(!retiredHtml.includes('/samples/p17-cross-device-fields/'));
  }
  assert.ok(full.includes('SYN-XDEV-38') && full.includes('Parameter/comparison tables (HTML)'));
});
