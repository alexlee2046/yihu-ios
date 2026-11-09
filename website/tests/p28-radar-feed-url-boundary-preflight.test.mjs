import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
const read = p => readFileSync(new URL('../' + p, import.meta.url), 'utf8');
const slug = 'p28-radar-feed-url-boundary-preflight';
const active = 'radar-feed-url-boundary-preflight';
const retired = 'reminder-link-pending-origin-routing';
const base = `public/samples/${slug}/`;
const zh = JSON.parse(read(base + 'preflight.zh.json'));
const en = JSON.parse(read(base + 'preflight.en.json'));
test('P28 exact three public resources, bilingual URL vectors and unknown real authority', () => {
  assert.deepEqual(readdirSync(new URL('../' + base, import.meta.url)).sort(), ['README.md', 'preflight.en.json', 'preflight.zh.json']);
  assert.deepEqual(zh.cases.map(({check,boundary,...c}) => c), en.cases.map(({check,boundary,...c}) => c));
  for (const d of [zh,en]) {
    assert.equal(d.cases.length,24); assert.equal(d.manual_boundary_reviews.length,6);
    assert.equal(d.source.commit,'7fa4ce027c66985f4bfde809e3261b0b349bbf15');
    assert.equal(d.source.tree,'87a67f5ed798093819b3dafe278d12330b33452b');
    for (const c of [...d.cases,...d.manual_boundary_reviews]) {
      assert.equal(c.classification,'SYNTHETIC_EXAMPLE'); assert.equal(c.state,'pending'); assert.equal(c.real_runtime,'not_run');
      assert.equal(c.network_fetch,false); assert.ok(c.check && c.boundary);
      for (const key of ['source_identity','access_authorization','read_receipt','snapshot_validation','device_draft_capability','remote_receipt']) assert.equal(c[key],null);
    }
    for (const c of d.cases) assert.equal(c.expected_supports_watch_drafts_flag,c.expected_feed_absolute_string !== null);
  }
  assert.notEqual(zh.cases[0].check,en.cases[0].check);
});
test('P28 parsers remain different: empty query, punctuation, root normalization and no automatic repair', () => {
  const c = id => zh.cases.find(c => c.id === id);
  for (const id of ['U07','U08','U09','U10']) {
    assert.equal(c(id).expected_feed_absolute_string,null);
    assert.equal(c(id).expected_evidence_absolute_strings.length,1);
  }
  assert.equal(c('U05').expected_origin_absolute_string,null);
  assert.equal(c('U17').expected_origin_absolute_string,'https://example.invalid');
  assert.equal(c('U18').expected_feed_absolute_string,'https://EXAMPLE.invalid:443');
  assert.equal(c('U20').expected_feed_absolute_string,'https://example.invalid/a,b');
  assert.deepEqual(c('U20').expected_evidence_absolute_strings,['https://example.invalid/a']);
  assert.equal(c('U22').expected_evidence_absolute_strings.length,2);
  assert.equal(c('U23').expected_feed_absolute_string,'https://localhost/radar.json');
});
for (const prefix of ['', 'en/']) {
  test(`P28 ${prefix || 'zh'} active has three resources, accessible 30-row table and original LLM discovery`, () => {
    const md = read(`src/pages/${prefix}guides/${active}.md`);
    assert.ok(!md.includes('indexable: false'));
    assert.equal((md.match(/\| [UM]\d\d \|/g)||[]).length,30);
    const html = read(`dist/${prefix}guides/${active}/index.html`);
    assert.ok(html.includes('role="region"') && html.includes('tabindex="0"'));
    for (const name of ['README.md','preflight.zh.json','preflight.en.json']) {
      assert.ok(html.includes(`/samples/${slug}/${name}`));
      assert.equal(read(`dist/samples/${slug}/${name}`),read(base+name));
    }
    for (const file of ['llms.txt','llms-full.txt']) {
      const llm=read('public/'+file),route=`https://getyihu.com/${prefix}guides/${active}/`;
      const section=llm.slice(llm.indexOf(route)).split('\n### ')[0];
      for (const name of ['README.md','preflight.zh.json','preflight.en.json']) assert.ok(section.includes(`/samples/${slug}/${name}`));
      if (file==='llms-full.txt') assert.ok(section.includes('U24') && section.includes('M06'));
    }
  });
  test(`P28 ${prefix || 'zh'} retired keeps P25 forwarding, noindex and no new downloads/Store cards`, () => {
    const md=read(`src/pages/${prefix}guides/${retired}.md`);
    assert.ok(md.includes('indexable: false') && md.includes('SYN-ELA-46'));
    assert.ok(md.includes(`/${prefix}guides/evidence-link-admission-preflight/`));
    assert.ok(md.includes(`/${prefix}guides/${active}/`));
    assert.ok(!md.includes('/samples/') && !md.includes('apps.apple.com'));
    assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for (const file of ['llms.txt','llms-full.txt']) {
      const llm=read('public/'+file);
      assert.ok(!llm.includes(`Canonical: https://getyihu.com/${prefix}guides/${retired}/`));
      assert.ok(!new RegExp(`^### .*\\(https://getyihu.com/${prefix}guides/${retired}/\\)`,'m').test(llm));
    }
    const html=read(`dist/${prefix}guides/${retired}/index.html`);
    assert.ok(html.includes('noindex,follow'));
    const article=html.match(/<article\b[^>]*>([\s\S]*?)<\/article>/)[1];
    for (const forbidden of ['data-guide-conversion','apps.apple.com','/samples/','app-store-link']) assert.ok(!article.includes(forbidden));
    // Existing ZH Store blocks on OTHER retired routes are deliberately not removed.
  });
}
