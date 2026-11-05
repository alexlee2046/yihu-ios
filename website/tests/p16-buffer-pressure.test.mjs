import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => readFileSync(join(root, p), 'utf8');
const prefix = 'public/samples/p16-buffer-pressure/';
const fixture = (lang) => JSON.parse(read(`${prefix}buffer-pressure-preflight.${lang}.json`));
const active = 'capture-buffer-pressure-checklist';
const retired = 'recognition-pass-parameter-budget';
const canonical = 'https://getyihu.com/';
const page = (lang, slug) => `src/pages/${lang === 'en' ? 'en/' : ''}guides/${slug}.md`;
const route = (lang, slug) => `${lang === 'en' ? 'en/' : ''}guides/${slug}/`;
const resources = ['buffer-pressure-preflight.zh.json', 'buffer-pressure-preflight.en.json', 'preflight-card.md'];

for (const lang of ['zh', 'en']) {
  test(`P16 ${lang}: synthetic bounded-FIFO pressure and final receipts are not physical ring-buffer or latency results`, () => {
    const j = fixture(lang);
    assert.equal(j.classification, 'SYNTHETIC_EXAMPLE');
    assert.equal(j.batch, 'SYN-BUF-37');
    assert.equal(j.language, lang);
    assert.equal(j.source_commit, 'd51c1bff6d133a4e0617ee1e4f1e20167ee04224');
    assert.equal(j.source_tree, 'd46a435376b99342dd378ccaa5ab3c359c1691d2');
    assert.equal(j.is_app_import_schema, false);
    assert.equal(j.is_production_capture, false);
    assert.deepEqual(Object.values(j.runtime_checks), Array(10).fill('not_run'));
    assert.equal(j.source_contract.queue_shape, 'bounded_array_FIFO_not_ring');
    assert.equal(j.source_contract.ring_head_tail_indices, 'not_applicable_source_has_no_ring');
    assert.equal(j.source_contract.automatic_segmentation, false);
    assert.equal(j.duration_guard_cases.length, 8);
    assert.equal(j.pressure_cases.length, 16);
    assert.equal(j.boundary_reviews.length, 4);
    const q = Object.fromEntries(j.pressure_cases.map((x) => [x.id, x]));
    assert.equal(q.Q2.checkpoints[0].expected.pending_frames, 24000);
    assert.equal(q.Q2.expected.completion, 'success');
    assert.equal(q.Q3.expected.completion, 'bufferOverflow');
    assert.equal(q.Q3.expected.accepted_source_frames, 24000);
    assert.equal(q.Q4.expected.queue_limit, 4096);
    assert.equal(q.Q5.expected.queue_limit, 22051);
    assert.equal(q.Q6.expected.accepted_source_frames, 48000);
    assert.equal(q.Q7.steps[0].frames, 60);
    assert.equal(q.Q7.expected.accepted_source_frames, 48);
    assert.equal(q.Q7.expected.callback_count, 1);
    assert.equal(q.Q8.expected.completion, 'durationExceeded');
    assert.equal(q.Q9.expected.failure, 'none');
    assert.equal(q.Q9.expected.completion, 'durationExceeded');
    assert.equal(q.Q9.expected.snapshot, 'samples:16');
    assert.equal(q.Q10.expected.completion, 'tooShort');
    assert.equal(q.Q11.expected.callback_count, 0);
    assert.equal(q.Q11.expected.snapshot, 'error:cancelled');
    assert.equal(q.Q15.expected.callback_count, 1);
    assert.deepEqual(q.Q16.expected.saved_snapshot_sizes, [2, 5]);
    assert.deepEqual(j.duration_guard_cases.map((x) => x.accepted), [false, false, false, false, false, false, true, true]);
    for (const group of ['duration_guard_cases', 'pressure_cases', 'boundary_reviews']) {
      assert.equal(new Set(j[group].map((x) => x.id)).size, j[group].length);
    }
    assert.ok(j.boundary_reviews.every((x) => x.runtime === 'not_run'));
  });
}

test('P16: bilingual fixtures preserve the same machine scripts/expectations, including preview-final divergence', () => {
  const normalize = (j) => {
    const v = structuredClone(j);
    delete v.language;
    for (const group of ['pressure_cases', 'boundary_reviews']) for (const row of v[group]) delete row.label;
    return v;
  };
  assert.deepEqual(normalize(fixture('zh')), normalize(fixture('en')));
});

test('P16: only active pair gains three download URLs and accessible tables; exact 180/150/30 scope preserved', () => {
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
    assert.ok(a.includes('SYNTHETIC_EXAMPLE') && a.includes('SYN-BUF-37'));
    assert.ok(a.includes('role="region"') && a.includes('tabindex="0"'));
    for (const name of resources) assert.ok(a.includes(`/samples/p16-buffer-pressure/${name}`));
    for (const group of ['duration_guard_cases', 'pressure_cases', 'boundary_reviews']) {
      for (const row of fixture(lang)[group]) assert.ok(a.includes(`| ${row.id} |`), `${lang} visible ${row.id}`);
    }
    assert.ok(r.includes(`](/${route(lang, active)})`));
    assert.ok(!r.includes('/samples/p16-buffer-pressure/'));
  }
});

test('P16: built resources match source bytes and both original-generator LLMs expose active JSON URLs, not retired sections', { skip: !existsSync(join(root, 'dist/index.html')) }, () => {
  for (const name of resources) assert.equal(read(`dist/samples/p16-buffer-pressure/${name}`), read(`${prefix}${name}`));
  const short = read('public/llms.txt');
  const full = read('public/llms-full.txt');
  assert.equal((full.match(/^Canonical: https:\/\/getyihu\.com\//gm) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const html = read(`dist/${route(lang, active)}index.html`);
    for (const name of resources) assert.ok(html.includes(`/samples/p16-buffer-pressure/${name}`));
    for (const text of [short, full]) assert.ok(text.includes(`/samples/p16-buffer-pressure/buffer-pressure-preflight.${lang}.json`));
    assert.ok(full.includes(`Canonical: ${canonical}${route(lang, active)}\n`));
    assert.ok(!full.includes(`Canonical: ${canonical}${route(lang, retired)}\n`));
    assert.ok(!short.includes(`](${canonical}${route(lang, retired)})\n`));
    const retiredHtml = read(`dist/${route(lang, retired)}index.html`);
    assert.ok(retiredHtml.includes('noindex,follow'));
    assert.ok(!retiredHtml.includes('/samples/p16-buffer-pressure/'));
  }
  assert.ok(full.includes('SYN-BUF-37') && full.includes('Parameter/comparison tables (HTML)'));
});
