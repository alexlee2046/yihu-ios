import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync,readdirSync } from 'node:fs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
const slug='p31-timezone-timestamp-review',active='timezone-timestamp-review',retired='shortcut-toggle-request-lifetime';
const base=`public/samples/${slug}/`,zh=JSON.parse(read(base+'preflight.zh.json')),en=JSON.parse(read(base+'preflight.en.json'));
test('P31 exact three public resources, bilingual recipes and unknown real event/freshness/permission evidence',()=>{
  assert.deepEqual(readdirSync(new URL('../'+base,import.meta.url)).sort(),['README.md','preflight.en.json','preflight.zh.json']);
  assert.deepEqual(zh.cases.map(({check,boundary,...c})=>c),en.cases.map(({check,boundary,...c})=>c));
  for(const d of [zh,en]){
    assert.equal(d.is_app_import_schema,false);assert.equal(d.cases.length,24);assert.equal(d.manual_boundary_reviews.length,6);
    assert.deepEqual(['source_date','watch_dates','shortcut_lifetime'].map(k=>d.cases.filter(c=>c.kind===k).length),[12,6,6]);
    assert.equal(d.source.commit,'470909f8398e102fed599e37126def258cec82af');assert.equal(d.source.tree,'64ee368b531f5fe54171d975d13d93ed52a5d877');
    for(const c of [...d.cases,...d.manual_boundary_reviews]){
      assert.equal(c.classification,'SYNTHETIC_EXAMPLE');assert.equal(c.state,'pending');assert.equal(c.real_runtime,'not_run');assert.equal(c.network_fetch,false);assert.ok(c.check&&c.boundary);
      for(const key of ['actual_source_read','actual_freshness','actual_task_event','actual_clock_health','actual_device_capture','actual_permission','remote_receipt'])assert.equal(c[key],null);
    }
  }
  assert.notEqual(zh.cases[0].check,en.cases[0].check);
});
test('P31 golden UTC dates, distinct Date reference epoch and inclusive single-use monotonic30s recipes',()=>{
  const c=id=>zh.cases.find(c=>c.id===id);
  assert.equal(c('D01').expected_utc,'2026-10-18T01:00:00Z');assert.equal(c('D02').expected_utc,'2026-10-17T16:30:00Z');
  assert.equal(c('D03').expected_parse,true);for(const id of ['D04','D05','D06','D07','D08','D09','D10','D11'])assert.equal(c(id).expected_parse,false);
  assert.equal(c('W04').source_unix_seconds,0);assert.equal(c('W04').expected_source_reference_seconds,-978307200);
  assert.equal(c('W05').source_unix_seconds,978307200);assert.equal(c('W05').expected_source_reference_seconds,0);
  assert.equal(c('W06').source_unix_seconds,null);assert.equal(c('W06').expected_source_reference_seconds,null);
  assert.deepEqual(c('S02').expected_consumptions,[true,false]);assert.deepEqual(c('S04').expected_consumptions,[true]);
  assert.equal(c('S04').events.at(-1).at_ms,30000);assert.deepEqual(c('S05').expected_consumptions,[false,false]);assert.deepEqual(c('S06').expected_consumptions,[true,false]);
});
for(const prefix of ['', 'en/']){
  test(`P31 ${prefix||'zh'} active resources, accessible30 rows and original LLM discovery`,()=>{
    const md=read(`src/pages/${prefix}guides/${active}.md`);assert.ok(!md.includes('indexable: false'));assert.equal((md.match(/\| [DWSM]\d\d \|/g)||[]).length,30);
    const html=read(`dist/${prefix}guides/${active}/index.html`);assert.ok(html.includes('role="region"')&&html.includes('tabindex="0"'));
    for(const name of ['README.md','preflight.zh.json','preflight.en.json']){assert.ok(html.includes(`/samples/${slug}/${name}`));assert.equal(read(`dist/samples/${slug}/${name}`),read(base+name));}
    for(const file of ['llms.txt','llms-full.txt']){
      const llm=read('public/'+file),route=`https://getyihu.com/${prefix}guides/${active}/`,section=llm.slice(llm.indexOf(route)).split('\n### ')[0];
      for(const name of ['README.md','preflight.zh.json','preflight.en.json'])assert.ok(section.includes(`/samples/${slug}/${name}`));
      if(file==='llms-full.txt')assert.ok(section.includes('D12')&&section.includes('W06')&&section.includes('S06')&&section.includes('M06'));
    }
  });
  test(`P31 ${prefix||'zh'} retired false with original P15 forwarding, no new downloads/Store/conversion cards`,()=>{
    const md=read(`src/pages/${prefix}guides/${retired}.md`);assert.ok(md.includes('indexable: false')&&md.includes('SYN-REBIND-36'));
    assert.ok(md.includes(`/${prefix}guides/foreground-audio-rebind-preflight/`));assert.ok(md.includes(`/${prefix}guides/${active}/`));
    assert.ok(!md.includes('/samples/')&&!md.includes('apps.apple.com'));
    assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for(const file of ['llms.txt','llms-full.txt']){const llm=read('public/'+file);assert.ok(!llm.includes(`Canonical: https://getyihu.com/${prefix}guides/${retired}/`));assert.ok(!new RegExp(`^### .*\\(https://getyihu.com/${prefix}guides/${retired}/\\)`,'m').test(llm));}
    const html=read(`dist/${prefix}guides/${retired}/index.html`);assert.ok(html.includes('noindex,follow'));const article=html.match(/<article\b[^>]*>([\s\S]*?)<\/article>/)[1];
    for(const forbidden of ['data-guide-conversion','apps.apple.com','/samples/','app-store-link'])assert.ok(!article.includes(forbidden));
    // All historical Store blocks and legacy resources on OTHER retired routes stay intact.
  });
}
