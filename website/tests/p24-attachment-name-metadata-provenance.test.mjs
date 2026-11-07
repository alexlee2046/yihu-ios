import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
const read = p => readFileSync(new URL('../' + p, import.meta.url), 'utf8');
const slug = 'p24-attachment-name-metadata-provenance';
const active = 'attachment-name-metadata-provenance';
const retired = 'app-group-inbox-access-evidence';
const base = `public/samples/${slug}/`;
const zh = JSON.parse(read(base + 'preflight.zh.json'));
const en = JSON.parse(read(base + 'preflight.en.json'));
test('P24 exactly three public resources, bilingual case parity and unknown real evidence', () => {
  assert.deepEqual(readdirSync(new URL('../' + base, import.meta.url)).sort(), ['README.md', 'preflight.en.json', 'preflight.zh.json']);
  assert.deepEqual(zh.cases.map(c => c.id), en.cases.map(c => c.id));
  for (const d of [zh, en]) {
    assert.equal(d.cases.length, 16);
    assert.equal(d.source.commit, 'f9d7303ff7b0622a6d52324dd99d69fe1f5205d7');
    assert.equal(d.source.tree, '3d29bc1d7e5aeb04c77e0ba6e3c6d94413a5a1f8');
    for (const c of d.cases) {
      assert.equal(c.classification, 'SYNTHETIC_EXAMPLE');
      assert.equal(c.state, 'pending'); assert.equal(c.real_runtime, 'not_run');
      for (const key of ['original_reference', 'confirmed_business_version', 'actual_content_sha256', 'signed_entitlement_evidence', 'system_container_access', 'remote_receipt']) assert.equal(c[key], null);
      assert.equal(c.permission_granted, false); assert.equal(c.source_upload, false);
      assert.ok(c.check && c.synthetic_observation && c.boundary);
    }
  }
  assert.notEqual(zh.cases[0].check, en.cases[0].check);
});
for (const prefix of ['', 'en/']) {
  test(`P24 ${prefix || 'zh'} active page, emitted resources and original exporter output`, () => {
    const md = read(`src/pages/${prefix}guides/${active}.md`);
    assert.ok(!md.includes('indexable: false'));
    assert.equal((md.match(/\| C\d\d \|/g) || []).length, 16);
    const html = read(`dist/${prefix}guides/${active}/index.html`);
    for (const name of ['README.md', 'preflight.zh.json', 'preflight.en.json']) {
      assert.ok(html.includes(`/samples/${slug}/${name}`));
      assert.equal(read(`dist/samples/${slug}/${name}`), read(base + name));
    }
    for (const file of ['llms.txt', 'llms-full.txt']) {
      const llm = read('public/' + file);
      const route = `https://getyihu.com/${prefix}guides/${active}/`;
      const section = llm.slice(llm.indexOf(route)).split('\n### ')[0];
      assert.ok(section.includes(`/samples/${slug}/preflight.zh.json`));
      assert.ok(section.includes(`/samples/${slug}/preflight.en.json`));
      if (file === 'llms-full.txt') assert.ok(section.includes('C16'));
    }
  });
  test(`P24 ${prefix || 'zh'} retired stays excluded and only technical forwarding added`, () => {
    const md = read(`src/pages/${prefix}guides/${retired}.md`);
    assert.ok(md.includes('indexable: false'));
    assert.ok(md.includes(`/${prefix}guides/${active}/`));
    assert.ok(!md.includes('/samples/'));
    assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for (const file of ['llms.txt', 'llms-full.txt']) {
      const llm = read('public/' + file);
      assert.ok(!llm.includes(`Canonical: https://getyihu.com/${prefix}guides/${retired}/`));
      assert.ok(!new RegExp(`^### .*\\(https://getyihu.com/${prefix}guides/${retired}/\\)`, 'm').test(llm));
    }
    assert.ok(read(`dist/${prefix}guides/${retired}/index.html`).includes('noindex,follow'));
  });
}
