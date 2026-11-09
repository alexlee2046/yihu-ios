import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
const read = p => readFileSync(new URL('../' + p, import.meta.url), 'utf8');
const slug = 'p29-history-reference-integrity-review';
const active = 'history-reference-integrity-review';
const retired = 'navigation-cancel-process-reload-boundaries';
const base = `public/samples/${slug}/`;
const zh = JSON.parse(read(base + 'preflight.zh.json'));
const en = JSON.parse(read(base + 'preflight.en.json'));
test('P29 exact three public resources, bilingual histories and unknown actual completion/authority', () => {
  assert.deepEqual(readdirSync(new URL('../' + base, import.meta.url)).sort(), ['README.md','preflight.en.json','preflight.zh.json']);
  assert.deepEqual(zh.cases.map(({check,boundary,...c})=>c),en.cases.map(({check,boundary,...c})=>c));
  for (const d of [zh,en]) {
    assert.equal(d.cases.length,24);assert.equal(d.manual_boundary_reviews.length,6);
    assert.equal(d.source.commit,'3f5a931472f2397cba5c2ee043dd9a16957fdda3');
    assert.equal(d.source.tree,'38479771ea33ebaa0a949e9b41498611603a1eac');
    for (const c of [...d.cases,...d.manual_boundary_reviews]) {
      assert.equal(c.classification,'SYNTHETIC_EXAMPLE');assert.equal(c.state,'pending');assert.equal(c.real_runtime,'not_run');
      assert.equal(c.network_fetch,false);assert.ok(c.check && c.boundary);
      for (const key of ['actual_source_identity','actual_read_status','actual_handled_status','actual_approver','actual_permission','remote_receipt']) assert.equal(c[key],null);
    }
    for (const c of d.cases) {
      assert.equal(c.history.target.eligible,false);assert.equal(c.now_unix,10000);
      if (!c.expected_accept) assert.equal(c.expected_feedback_ids,null);
      else assert.ok(Array.isArray(c.expected_feedback_ids));
    }
  }
  assert.notEqual(zh.cases[0].check,en.cases[0].check);
});
test('P29 explicit association, draft and incomplete-page contracts are separate from completion', () => {
  const c=id=>zh.cases.find(c=>c.id===id);
  assert.deepEqual(c('H01').expected_feedback_ids,['SYN-update']);
  assert.deepEqual(c('H02').expected_feedback_ids,['SYN-update']);
  for (const id of ['H03','H04','H05']) assert.deepEqual(c(id).expected_feedback_ids,[]);
  assert.equal(c('H06').history.draft,true);assert.equal(c('H06').expected_accept,true);
  for (const id of ['H07','H08','H09','H15','H16','H17','H18','H19','H20','H21','H22','H23']) assert.equal(c(id).expected_accept,false);
  assert.equal(c('H23').history.before,null);
  assert.equal(c('H24').history.total,6);assert.equal(c('H24').history.entries.length,5);
  assert.ok(c('H24').history.before);assert.equal(c('H24').expected_feedback_ids.length,4);
});
for (const prefix of ['', 'en/']) {
  test(`P29 ${prefix||'zh'} active has resources, accessible 30-row table and original LLM exports`, () => {
    const md=read(`src/pages/${prefix}guides/${active}.md`);
    assert.ok(!md.includes('indexable: false'));assert.equal((md.match(/\| [HM]\d\d \|/g)||[]).length,30);
    const html=read(`dist/${prefix}guides/${active}/index.html`);
    assert.ok(html.includes('role="region"') && html.includes('tabindex="0"'));
    for (const name of ['README.md','preflight.zh.json','preflight.en.json']) {
      assert.ok(html.includes(`/samples/${slug}/${name}`));assert.equal(read(`dist/samples/${slug}/${name}`),read(base+name));
    }
    for (const file of ['llms.txt','llms-full.txt']) {
      const llm=read('public/'+file),route=`https://getyihu.com/${prefix}guides/${active}/`;
      const section=llm.slice(llm.indexOf(route)).split('\n### ')[0];
      for (const name of ['README.md','preflight.zh.json','preflight.en.json']) assert.ok(section.includes(`/samples/${slug}/${name}`));
      if (file==='llms-full.txt') assert.ok(section.includes('H24') && section.includes('M06'));
    }
  });
  test(`P29 ${prefix||'zh'} retired preserves noindex and technical boundary without new downloads/Store cards`, () => {
    const md=read(`src/pages/${prefix}guides/${retired}.md`);
    assert.ok(md.includes('indexable: false'));assert.ok(md.includes(`/${prefix}guides/${active}/`));
    assert.ok(!md.includes('/samples/') && !md.includes('apps.apple.com'));
    assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for (const file of ['llms.txt','llms-full.txt']) {
      const llm=read('public/'+file);
      assert.ok(!llm.includes(`Canonical: https://getyihu.com/${prefix}guides/${retired}/`));
      assert.ok(!new RegExp(`^### .*\\(https://getyihu.com/${prefix}guides/${retired}/\\)`,'m').test(llm));
    }
    const html=read(`dist/${prefix}guides/${retired}/index.html`);assert.ok(html.includes('noindex,follow'));
    const article=html.match(/<article\b[^>]*>([\s\S]*?)<\/article>/)[1];
    for (const forbidden of ['data-guide-conversion','apps.apple.com','/samples/','app-store-link']) assert.ok(!article.includes(forbidden));
    // Historical ZH Store cards on other routes remain unchanged, not removed.
  });
}
