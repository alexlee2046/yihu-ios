import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
const slug='p30-radar-json-null-validation',active='radar-json-null-validation',retired='attention-filter-identity-boundaries';
const base=`public/samples/${slug}/`,zh=JSON.parse(read(base+'preflight.zh.json')),en=JSON.parse(read(base+'preflight.en.json'));
test('P30 exact three public resources, bilingual model cases and unknown real ownership/write authority',()=>{
  assert.deepEqual(readdirSync(new URL('../'+base,import.meta.url)).sort(),['README.md','preflight.en.json','preflight.zh.json']);
  assert.deepEqual(zh.cases.map(({check,boundary,...c})=>c),en.cases.map(({check,boundary,...c})=>c));
  for(const d of [zh,en]){
    assert.equal(d.cases.length,24);assert.equal(d.manual_boundary_reviews.length,6);
    assert.equal(d.cases.filter(c=>c.expected_accept).length,12);
    assert.equal(d.source.commit,'0162ec5d7d98865b4b720d4a90f18287f955fc70');assert.equal(d.source.tree,'9d4ade40785418bb06e06a8c384e22a2ffc2001c');
    for(const c of [...d.cases,...d.manual_boundary_reviews]){
      assert.equal(c.classification,'SYNTHETIC_EXAMPLE');assert.equal(c.state,'pending');assert.equal(c.real_runtime,'not_run');assert.equal(c.network_fetch,false);assert.ok(c.check&&c.boundary);
      for(const key of ['actual_source_identity','actual_ledger_completeness','actual_owner','actual_approval','actual_write_authorization','remote_receipt'])assert.equal(c[key],null);
    }
    for(const c of d.cases)if(!c.expected_accept)for(const key of ['expected_all_task_titles','expected_attention_titles','expected_visible_titles','expected_raw_statuses','expected_reply_supported'])assert.equal(c[key],null);
  }
  assert.notEqual(zh.cases[0].check,en.cases[0].check);
});
test('P30 missing/null/empty tasks, unknown Bool, raw status and multi-filter boundaries stay distinct',()=>{
  const c=id=>zh.cases.find(c=>c.id===id);
  assert.ok(!Object.hasOwn(c('J01').snapshot,'tasks'));assert.equal(c('J02').snapshot.tasks,null);assert.deepEqual(c('J03').snapshot.tasks,[]);
  assert.deepEqual(c('J01').expected_all_task_titles,['SYN-decision']);assert.deepEqual(c('J02').expected_all_task_titles,['SYN-decision']);assert.deepEqual(c('J03').expected_all_task_titles,[]);
  assert.equal(c('J05').expected_reply_supported,null);assert.equal(c('J06').expected_reply_supported,true);
  assert.equal(c('J06').snapshot.tasks[0].status,' 等你验收 ');assert.deepEqual(c('J06').expected_raw_statuses,[' 等你验收 ']);
  assert.deepEqual(c('J07').expected_attention_titles,['SYN-task']);assert.deepEqual(c('J08').expected_attention_titles,[]);
  for(const id of ['J11','J12']){assert.equal(c(id).expected_attention_titles.length,1);assert.deepEqual(c(id).expected_visible_titles,[]);}
  assert.equal(c('J24').input_recipe,'oversize_2mib_plus_1');assert.equal(c('J24').expected_accept,false);
});
for(const prefix of ['', 'en/']){
  test(`P30 ${prefix||'zh'} active resources, accessible30 rows and original LLM discovery`,()=>{
    const md=read(`src/pages/${prefix}guides/${active}.md`);assert.ok(!md.includes('indexable: false'));assert.equal((md.match(/\| [JM]\d\d \|/g)||[]).length,30);
    const html=read(`dist/${prefix}guides/${active}/index.html`);assert.ok(html.includes('role="region"')&&html.includes('tabindex="0"'));
    for(const name of ['README.md','preflight.zh.json','preflight.en.json']){assert.ok(html.includes(`/samples/${slug}/${name}`));assert.equal(read(`dist/samples/${slug}/${name}`),read(base+name));}
    for(const file of ['llms.txt','llms-full.txt']){
      const llm=read('public/'+file),route=`https://getyihu.com/${prefix}guides/${active}/`,section=llm.slice(llm.indexOf(route)).split('\n### ')[0];
      for(const name of ['README.md','preflight.zh.json','preflight.en.json'])assert.ok(section.includes(`/samples/${slug}/${name}`));
      if(file==='llms-full.txt')assert.ok(section.includes('J24')&&section.includes('M06'));
    }
  });
  test(`P30 ${prefix||'zh'} retired false, no new links/cards, historical English P8/P4 and P22 forwarding retained`,()=>{
    const md=read(`src/pages/${prefix}guides/${retired}.md`);assert.ok(md.includes('indexable: false'));assert.ok(md.includes(`/${prefix}guides/empty-field-display-defaults/`));assert.ok(md.includes(`/${prefix}guides/${active}/`));
    const added=md.split('## SYN-RJN-51')[1];assert.ok(added&&!added.includes('/samples/')&&!added.includes('apps.apple.com'));
    if(prefix){assert.ok(md.includes('/samples/p8-opportunity-preflight/radar-brief.en.json'));assert.ok(md.includes('/samples/p8-opportunity-preflight/buyer-card.md'));}
    assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for(const file of ['llms.txt','llms-full.txt']){const llm=read('public/'+file);assert.ok(!llm.includes(`Canonical: https://getyihu.com/${prefix}guides/${retired}/`));assert.ok(!new RegExp(`^### .*\\(https://getyihu.com/${prefix}guides/${retired}/\\)`,'m').test(llm));}
    const html=read(`dist/${prefix}guides/${retired}/index.html`);assert.ok(html.includes('noindex,follow'));const article=html.match(/<article\b[^>]*>([\s\S]*?)<\/article>/)[1];
    assert.equal((article.match(/data-guide-conversion/g)||[]).length,prefix?1:0);
    assert.equal((article.match(/app-store-link/g)||[]).length,prefix?1:0);
    assert.equal((article.match(/href="\/samples\//g)||[]).length,prefix?2:0);
    assert.ok(!article.includes(`/samples/${slug}/`));
  });
}
