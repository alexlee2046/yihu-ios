import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
const read = p => readFileSync(new URL('../' + p, import.meta.url), 'utf8');
const slug = 'p25-evidence-link-admission-preflight';
const active = 'evidence-link-admission-preflight';
const retired = 'reminder-link-pending-origin-routing';
const base = `public/samples/${slug}/`;
const zh = JSON.parse(read(base + 'preflight.zh.json'));
const en = JSON.parse(read(base + 'preflight.en.json'));
test('P25 exactly three public resources, 24 bilingual parser vectors and 6 manual routing reviews', () => {
  assert.deepEqual(readdirSync(new URL('../' + base, import.meta.url)).sort(), ['README.md', 'preflight.en.json', 'preflight.zh.json']);
  assert.deepEqual(zh.cases.map(c => [c.id, c.input_evidence, c.expected_absolute_strings]), en.cases.map(c => [c.id, c.input_evidence, c.expected_absolute_strings]));
  for (const d of [zh, en]) {
    assert.equal(d.cases.length, 24); assert.equal(d.manual_routing_reviews.length, 6);
    assert.equal(d.source.commit, 'f0661014f9e8127c0be0aa0d4df8d8b92f16a63c');
    assert.equal(d.source.tree, '27e35afef1ef9a4046d817e12fa52a22710fd74f');
    for (const c of [...d.cases, ...d.manual_routing_reviews]) {
      assert.equal(c.classification, 'SYNTHETIC_EXAMPLE');
      assert.equal(c.state, 'pending'); assert.equal(c.real_runtime, 'not_run');
      assert.equal(c.network_fetch, false); assert.ok(c.check && c.boundary);
    }
    for (const c of d.cases) for (const key of ['source_authenticity', 'access_authorization', 'public_disclosure_authorization', 'redaction_review', 'remote_receipt']) assert.equal(c[key], null);
    for (const c of d.manual_routing_reviews) {
      for (const key of ['actual_notification', 'actual_pending_url', 'saved_origin_evidence', 'login_or_session_evidence', 'navigation_receipt', 'business_receipt']) assert.equal(c[key], null);
      assert.equal(c.authority_granted, false);
    }
  }
  assert.notEqual(zh.cases[0].check, en.cases[0].check);
});
test('P25 sensitive query/fragment is retained, labeled Markdown not promised, comma prefix not silently repaired', () => {
  const c = id => zh.cases.find(c => c.id === id);
  assert.deepEqual(c('E19').expected_absolute_strings, [c('E19').input_evidence]);
  assert.deepEqual(c('E17').expected_absolute_strings, []);
  assert.deepEqual(c('E18').expected_absolute_strings, ['https://example.invalid/a']);
  assert.equal(c('E23').expected_absolute_strings.length, 2);
  assert.equal(c('E24').expected_absolute_strings.length, 2);
});
for (const prefix of ['', 'en/']) {
  test(`P25 ${prefix || 'zh'} active page resources, accessible table and original exporter output`, () => {
    const md = read(`src/pages/${prefix}guides/${active}.md`);
    assert.ok(!md.includes('indexable: false'));
    assert.equal((md.match(/\| [ER]\d\d \|/g) || []).length, 30);
    const html = read(`dist/${prefix}guides/${active}/index.html`);
    assert.ok(html.includes('role="region"')); assert.ok(html.includes('tabindex="0"'));
    for (const name of ['README.md', 'preflight.zh.json', 'preflight.en.json']) {
      assert.ok(html.includes(`/samples/${slug}/${name}`));
      assert.equal(read(`dist/samples/${slug}/${name}`), read(base + name));
    }
    for (const file of ['llms.txt', 'llms-full.txt']) {
      const llm = read('public/' + file);
      const route = `https://getyihu.com/${prefix}guides/${active}/`;
      const section = llm.slice(llm.indexOf(route)).split('\n### ')[0];
      for (const name of ['README.md', 'preflight.zh.json', 'preflight.en.json']) assert.ok(section.includes(`/samples/${slug}/${name}`));
      if (file === 'llms-full.txt') assert.ok(section.includes('E24') && section.includes('R06'));
    }
  });
  test(`P25 ${prefix || 'zh'} retired stays excluded, without download or Store/conversion card`, () => {
    const md = read(`src/pages/${prefix}guides/${retired}.md`);
    assert.ok(md.includes('indexable: false'));
    assert.ok(md.includes(`/${prefix}guides/${active}/`));
    assert.ok(!md.includes('/samples/')); assert.ok(!md.includes('apps.apple.com'));
    assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for (const file of ['llms.txt', 'llms-full.txt']) {
      const llm = read('public/' + file);
      assert.ok(!llm.includes(`Canonical: https://getyihu.com/${prefix}guides/${retired}/`));
      assert.ok(!new RegExp(`^### .*\\(https://getyihu.com/${prefix}guides/${retired}/\\)`, 'm').test(llm));
    }
    const html = read(`dist/${prefix}guides/${retired}/index.html`);
    assert.ok(html.includes('noindex,follow'));
    const article = html.match(/<article\b[^>]*>([\s\S]*?)<\/article>/)[1];
    assert.ok(!article.includes('data-guide-conversion'));
    assert.ok(!article.includes('apps.apple.com'));
    assert.ok(!article.includes('/samples/'));
    assert.ok(!article.includes('app-store-link'));
  });
}
