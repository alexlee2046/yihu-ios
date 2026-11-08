import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
const read = p => readFileSync(new URL('../' + p, import.meta.url), 'utf8');
const slug = 'p26-export-encoding-delimiter-preflight';
const active = 'export-encoding-delimiter-preflight';
const retired = 'pcm-stream-end-boundaries';
const base = `public/samples/${slug}/`;
const zh = JSON.parse(read(base + 'preflight.zh.json'));
const en = JSON.parse(read(base + 'preflight.en.json'));
test('P26 exactly three public resources, bilingual case parity and unknown live evidence', () => {
  assert.deepEqual(readdirSync(new URL('../' + base, import.meta.url)).sort(), ['README.md', 'preflight.en.json', 'preflight.zh.json']);
  assert.deepEqual(zh.cases.map(({check, boundary, ...c}) => c), en.cases.map(({check, boundary, ...c}) => c));
  for (const d of [zh, en]) {
    assert.equal(d.cases.length, 26); assert.equal(d.manual_boundary_reviews.length, 4);
    assert.equal(d.source.commit, '5d2944b2444fd345407fd37d082393074a4f3db6');
    assert.equal(d.source.tree, 'ebc01e15be8bbe42b406ac7b5fd6a86466e93bbe');
    assert.deepEqual(['text','radar','carrier','reservation'].map(k => d.cases.filter(c => c.kind === k).length), [10,8,4,4]);
    for (const c of [...d.cases, ...d.manual_boundary_reviews]) {
      assert.equal(c.classification, 'SYNTHETIC_EXAMPLE'); assert.equal(c.state, 'pending'); assert.equal(c.real_runtime, 'not_run');
      assert.equal(c.network_fetch, false); assert.ok(c.check && c.boundary);
      for (const key of ['actual_original_reference','actual_source_encoding','actual_consumer_acceptance','actual_permission','remote_receipt']) assert.equal(c[key], null);
    }
  }
  assert.notEqual(zh.cases[0].check, en.cases[0].check);
});
test('P26 codepoint-sensitive fixtures are not silently normalized or treated as universal encoding rules', () => {
  const c = id => zh.cases.find(c => c.id === id);
  assert.equal(c('T02').seed, 'e\u0301'); assert.equal(c('T03').seed, '\u00e9');
  assert.notDeepEqual(Buffer.from(c('T02').seed), Buffer.from(c('T03').seed));
  assert.equal(c('T02').expected_swift_characters, 1); assert.equal(c('T02').expected_utf8_bytes, 3);
  assert.equal(c('T05').seed, 'Line1\nLine2'); assert.equal(c('T06').seed, 'Line1\\nLine2');
  assert.equal(c('T09').repeat, 3000); assert.equal(c('T10').repeat, 3001);
  assert.equal(c('T08').expected_swift_characters, 3); assert.equal(c('T08').expected_utf8_bytes, 4);
  assert.equal(c('D03').expected_accept, false); assert.equal(c('D07').encoding, 'utf16le_bom');
  assert.equal(c('D07').expected_accept, true);
});
for (const prefix of ['', 'en/']) {
  test(`P26 ${prefix || 'zh'} active resources, accessible 30-row table and original LLM exports`, () => {
    const md = read(`src/pages/${prefix}guides/${active}.md`);
    assert.ok(!md.includes('indexable: false'));
    assert.equal((md.match(/\| [TDCHM]\d\d \|/g) || []).length, 30);
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
      if (file === 'llms-full.txt') assert.ok(section.includes('T10') && section.includes('M04'));
    }
  });
  test(`P26 ${prefix || 'zh'} retired keeps original PCM forwarding, noindex and no resource or Store/conversion card`, () => {
    const md = read(`src/pages/${prefix}guides/${retired}.md`);
    assert.ok(md.includes('indexable: false') && md.includes('SYN-PCM-36'));
    assert.ok(md.includes(`/${prefix}guides/pcm-format-admission-review/#syn-pcm-36`));
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
    for (const forbidden of ['data-guide-conversion','apps.apple.com','/samples/','app-store-link']) assert.ok(!article.includes(forbidden));
  });
}
