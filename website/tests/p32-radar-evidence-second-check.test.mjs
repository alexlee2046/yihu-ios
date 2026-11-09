import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync,readdirSync } from 'node:fs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
const slug='p32-radar-evidence-second-check',active='radar-evidence-second-check',retired='followup-evidence-minimization';
const base=`public/samples/${slug}/`,zh=JSON.parse(read(base+'preflight.zh.json')),en=JSON.parse(read(base+'preflight.en.json'));
test('P32 exact three public resources, bilingual recipes and unknown real claim/redaction/approval evidence',()=>{
  assert.deepEqual(readdirSync(new URL('../'+base,import.meta.url)).sort(),['README.md','preflight.en.json','preflight.zh.json']);
  assert.deepEqual(zh.cases.map(({check,boundary,...c})=>c),en.cases.map(({check,boundary,...c})=>c));
  for(const d of [zh,en]){
    assert.equal(d.is_app_import_schema,false);assert.equal(d.cases.length,24);assert.equal(d.manual_boundary_reviews.length,6);
    assert.deepEqual(['action_evidence','authorization_record','colab_snapshot'].map(k=>d.cases.filter(c=>c.kind===k).length),[8,8,8]);
    assert.equal(d.source.commit,'402a7f828c47d41c8ebebf9f06f1f4615d5e3ddd');assert.equal(d.source.tree,'572ec6be5841eec57d3f0034fbb0b9551591f233');
    for(const c of [...d.cases,...d.manual_boundary_reviews]){
      assert.equal(c.classification,'SYNTHETIC_EXAMPLE');assert.equal(c.state,'pending');assert.equal(c.real_runtime,'not_run');assert.equal(c.network_fetch,false);assert.ok(c.check&&c.boundary);
      for(const key of ['actual_claim_truth','actual_source_authority','actual_redaction_review','actual_human_approval','actual_remote_execution','remote_receipt'])assert.equal(c[key],null);
    }
  }
  assert.notEqual(zh.cases[0].check,en.cases[0].check);
});
test('P32 unredacted query retention, explicit null budget wire schema and Colab snapshot decode gate',()=>{
  const c=id=>zh.cases.find(c=>c.id===id);
  assert.deepEqual(c('E02').expected_safe_evidence_urls,['https://example.invalid/a','https://example.invalid/b']);
  assert.equal(c('E02').expected_requires_attention,true);assert.equal(c('E02').expected_classified_state,'waiting');
  assert.deepEqual(c('E03').expected_safe_evidence_urls,['https://example.invalid/item?token=SYN-KEEP#sec1']);
  assert.equal(c('E04').expected_requires_attention,true);assert.equal(c('E08').expected_classified_state,'unknown');
  assert.equal(c('A01').expected_valid,true);assert.equal(c('A01').expected_current,true);assert.equal(c('A01').expected_encoded_budget_null,false);
  assert.equal(c('A02').expected_valid,true);assert.equal(c('A02').expected_current,true);assert.equal(c('A02').expected_encoded_budget_null,true);
  assert.equal(c('A03').expected_valid,true);assert.equal(c('A03').expected_current,false);
  for(const id of ['A04','A05','A06','A07','A08']){assert.equal(c(id).expected_valid,false);assert.equal(c(id).expected_current,false);}
  for(const id of ['C01','C02']){assert.equal(c(id).expected_colab_valid,true);assert.equal(c(id).expected_snapshot_decode,true);}
  for(const id of ['C03','C04','C05','C06','C07','C08']){assert.equal(c(id).expected_colab_valid,false);assert.equal(c(id).expected_snapshot_decode,false);}
});
for(const prefix of ['', 'en/']){
  test(`P32 ${prefix||'zh'} active resources, accessible30 rows and original LLM discovery`,()=>{
    const md=read(`src/pages/${prefix}guides/${active}.md`);assert.ok(!md.includes('indexable: false'));assert.equal((md.match(/\| [EACM]\d\d \|/g)||[]).length,30);
    const html=read(`dist/${prefix}guides/${active}/index.html`);assert.ok(html.includes('role="region"')&&html.includes('tabindex="0"'));
    for(const name of ['README.md','preflight.zh.json','preflight.en.json']){assert.ok(html.includes(`/samples/${slug}/${name}`));assert.equal(read(`dist/samples/${slug}/${name}`),read(base+name));}
    for(const file of ['llms.txt','llms-full.txt']){
      const llm=read('public/'+file),route=`https://getyihu.com/${prefix}guides/${active}/`,section=llm.slice(llm.indexOf(route)).split('\n### ')[0];
      for(const name of ['README.md','preflight.zh.json','preflight.en.json'])assert.ok(section.includes(`/samples/${slug}/${name}`));
      if(file==='llms-full.txt')assert.ok(section.includes('E08')&&section.includes('A08')&&section.includes('C08')&&section.includes('M06'));
    }
  });
  test(`P32 ${prefix||'zh'} retired false with original P23 forwarding, no new downloads/Store/conversion cards`,()=>{
    const md=read(`src/pages/${prefix}guides/${retired}.md`);assert.ok(md.includes('indexable: false')&&md.includes('SYN-ESC-53'));
    assert.ok(md.includes(`/${prefix}guides/department-minutes-ownership-archive/`));assert.ok(md.includes(`/${prefix}guides/${active}/`));
    assert.ok(!md.includes('/samples/')&&!md.includes('apps.apple.com'));
    assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for(const file of ['llms.txt','llms-full.txt']){const llm=read('public/'+file);assert.ok(!llm.includes(`Canonical: https://getyihu.com/${prefix}guides/${retired}/`));assert.ok(!new RegExp(`^### .*\\(https://getyihu.com/${prefix}guides/${retired}/\\)`,'m').test(llm));}
    const html=read(`dist/${prefix}guides/${retired}/index.html`);assert.ok(html.includes('noindex,follow'));const article=html.match(/<article\b[^>]*>([\s\S]*?)<\/article>/)[1];
    assert.equal((article.match(/data-guide-conversion/g)||[]).length,prefix?1:0);
    assert.equal((article.match(/app-store-link/g)||[]).length,prefix?1:0);
    assert.equal((article.match(/href="\/samples\//g)||[]).length,0);
    assert.ok(!article.includes(`/samples/${slug}/`));
  });
}
