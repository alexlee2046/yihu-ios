import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
const read = p => readFileSync(new URL('../' + p, import.meta.url), 'utf8');
const slug = 'p27-audio-level-not-accuracy-review';
const active = 'audio-level-not-accuracy-review';
const retired = 'capture-completion-token-review';
const base = `public/samples/${slug}/`;
const zh = JSON.parse(read(base + 'preflight.zh.json'));
const en = JSON.parse(read(base + 'preflight.en.json'));
test('P27 exact three public resources, bilingual inputs and no real acoustic/identity/receipt evidence', () => {
  assert.deepEqual(readdirSync(new URL('../' + base, import.meta.url)).sort(), ['README.md', 'preflight.en.json', 'preflight.zh.json']);
  assert.deepEqual(zh.cases.map(({check, boundary, ...c}) => c), en.cases.map(({check, boundary, ...c}) => c));
  for (const d of [zh, en]) {
    assert.equal(d.cases.length, 24); assert.equal(d.manual_boundary_reviews.length, 6);
    assert.equal(d.cases.filter(c => c.kind === 'vector').length, 20);
    assert.equal(d.cases.filter(c => c.kind === 'state').length, 4);
    assert.equal(d.source.commit, 'd58dd159e3306d9d46643e0eaa78be26a4679e2b');
    assert.equal(d.source.tree, 'c4db73b78f85357165e95fa27b1a7a0e5f4793bc');
    for (const c of [...d.cases, ...d.manual_boundary_reviews]) {
      assert.equal(c.classification, 'SYNTHETIC_EXAMPLE'); assert.equal(c.state, 'pending'); assert.equal(c.real_runtime, 'not_run');
      assert.equal(c.network_fetch, false); assert.ok(c.check && c.boundary);
      for (const key of ['real_audio_reference','calibrated_db_spl','wind_rating','asr_confidence','speaker_identity','actual_permission','final_transcript','remote_receipt']) assert.equal(c[key], null);
    }
    for (const c of d.cases) {
      assert.ok(Number.isFinite(c.expected_note_level) && c.expected_note_level >= 0 && c.expected_note_level <= 1);
      assert.equal(c.absolute_tolerance, 0.00001);
      if (c.kind === 'vector') assert.ok(c.samples.every(Number.isFinite));
    }
  }
  assert.notEqual(zh.cases[0].check, en.cases[0].check);
});
test('P27 independent mathematical oracle and explicit stale/closed-state expectations', () => {
  for (const c of zh.cases.filter(c => c.kind === 'vector')) {
    const rms = c.samples.length ? Math.sqrt(c.samples.reduce((s,x) => s+x*x, 0)/c.samples.length) : 0;
    assert.ok(Math.abs(c.expected_short_level-Math.min(1,rms*2)) < c.absolute_tolerance);
    assert.ok(Math.abs(c.expected_note_level-Math.min(1,rms*12)) < c.absolute_tolerance);
    assert.equal(c.expected_note_frames, c.samples.length);
  }
  const c = id => zh.cases.find(c => c.id === id);
  assert.equal(c('L07').expected_note_level, 1);
  assert.equal(c('S01').expected_note_level, 0.6);
  assert.equal(c('S02').expected_note_level, 0);
  assert.equal(c('S03').expected_note_frames, 2);
  assert.equal(c('S04').expected_note_frames, 0);
});
for (const prefix of ['', 'en/']) {
  test(`P27 ${prefix || 'zh'} active has resources/table/LLM discovery while P12 forwarding remains`, () => {
    const md = read(`src/pages/${prefix}guides/${active}.md`);
    assert.ok(!md.includes('indexable: false'));
    assert.equal((md.match(/\| [LSM]\d\d \|/g) || []).length, 30);
    assert.ok(md.includes('SYN-LEVEL-35'));
    assert.ok(md.includes(`/${prefix}guides/outdoor-store-voice-preflight/#syn-level-35`));
    const html = read(`dist/${prefix}guides/${active}/index.html`);
    assert.ok(html.includes('role="region"') && html.includes('tabindex="0"'));
    for (const name of ['README.md', 'preflight.zh.json', 'preflight.en.json']) {
      assert.ok(html.includes(`/samples/${slug}/${name}`));
      assert.equal(read(`dist/samples/${slug}/${name}`), read(base + name));
    }
    for (const file of ['llms.txt', 'llms-full.txt']) {
      const llm = read('public/' + file);
      const route = `https://getyihu.com/${prefix}guides/${active}/`;
      const section = llm.slice(llm.indexOf(route)).split('\n### ')[0];
      for (const name of ['README.md', 'preflight.zh.json', 'preflight.en.json']) assert.ok(section.includes(`/samples/${slug}/${name}`));
      if (file === 'llms-full.txt') assert.ok(section.includes('L20') && section.includes('M06'));
    }
  });
  test(`P27 ${prefix || 'zh'} retired keeps P10 forwarding/noindex, no sample/new Store card; historical Chinese P4 block intact`, () => {
    const md = read(`src/pages/${prefix}guides/${retired}.md`);
    assert.ok(md.includes('indexable: false') && md.includes('SYN-TOKEN-33'));
    assert.ok(md.includes(`/${prefix}guides/interruption-recapture-preflight/#syn-token-33`));
    assert.ok(md.includes(`/${prefix}guides/${active}/`));
    assert.ok(!md.includes('/samples/') && !md.includes('apps.apple.com'));
    assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for (const file of ['llms.txt', 'llms-full.txt']) {
      const llm = read('public/' + file);
      assert.ok(!llm.includes(`Canonical: https://getyihu.com/${prefix}guides/${retired}/`));
      assert.ok(!new RegExp(`^### .*\\(https://getyihu.com/${prefix}guides/${retired}/\\)`, 'm').test(llm));
    }
    const html = read(`dist/${prefix}guides/${retired}/index.html`);
    assert.ok(html.includes('noindex,follow'));
    const article = html.match(/<article\b[^>]*>([\s\S]*?)<\/article>/)[1];
    assert.ok(!article.includes('/samples/'));
    // The baseline P4 map intentionally includes this ZH retired page, not EN.
    assert.equal((article.match(/data-guide-conversion/g) || []).length, prefix ? 0 : 1);
    assert.equal((article.match(/app-store-link/g) || []).length, prefix ? 0 : 1);
    assert.equal((article.match(/https:\/\/apps\.apple\.com\/us\/app\/yihu\/id6819057500/g) || []).length, prefix ? 0 : 1);
  });
}
