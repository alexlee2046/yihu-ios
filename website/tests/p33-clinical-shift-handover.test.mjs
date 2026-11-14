import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
const active='handoff-evidence-audit-checklist',retired='navigation-cancel-process-reload-boundaries';
const base='public/samples/p33-clinical-shift-handover/';
const files=['README.md','checklist.en.json','checklist.zh.json'];
test('P33 twelve bilingual blank administrative checks, no fabricated approval or patient records',()=>{
  assert.deepEqual(readdirSync(new URL('../'+base,import.meta.url)).sort(),files);
  const variants=['zh','en'].map(lang=>JSON.parse(read(base+`checklist.${lang}.json`)));
  assert.deepEqual(variants[0].items.map(({label,...item})=>item),variants[1].items.map(({label,...item})=>item));
  assert.notEqual(variants[0].items[0].label,variants[1].items[0].label);
  for(const d of variants){
    assert.equal(d.is_app_import_schema,false);assert.equal(d.is_approval_record,false);assert.equal(d.contains_patient_information,false);
    assert.equal(d.items.length,12);assert.equal(new Set(d.items.map(i=>i.key)).size,12);
    for(const i of d.items){assert.equal(i.review_state,'unfilled');for(const k of ['checked_reference','checked_scope','unresolved'])assert.equal(i[k],null);}
    for(const key of ['midnight_boundaries','swap_approval','staff_acknowledgements','uncertainty_and_duplicates'])assert.ok(d.items.some(i=>i.key===key));
  }
});
for(const prefix of ['', 'en/']){
  test(`P33 ${prefix||'zh'} one existing page replaced, practical medical-admin scope, valid index and resources`,()=>{
    const md=read(`src/pages/${prefix}guides/${active}.md`),html=read(`dist/${prefix}guides/${active}/index.html`);
    assert.ok(!md.includes('indexable: false'));assert.ok(md.includes('68b5dace9dad4563ffa667a66e172fbb146bcca5'));
    assert.ok(!new RegExp("SYNTHETIC_" + "EXAMPLE|SYN" + "-|not_" + "run|Wave P|SOURCE PASS|actual-M|pending").test(md));
    assert.equal((html.match(/<h1\b/g)||[]).length,1);assert.equal((html.match(/id="faq-/g)||[]).length,6);
    assert.ok(html.includes('role="region"')&&html.includes('tabindex="0"'));
    assert.ok(html.includes(`rel="canonical" href="https://getyihu.com/${prefix}guides/${active}/"`));
    assert.ok(html.includes('hreflang="zh-CN"')&&html.includes('hreflang="en"'));assert.ok(!html.includes('content="noindex,follow"'));
    assert.ok(md.includes(prefix?'not clinical handover':'不是临床交班工具'));
    assert.ok(md.includes(prefix?'not a roster import file':'不是排班导入文件'));
    assert.ok(md.includes(prefix?'New operations do not prove old ones':'新操作不能证明旧操作'));
    assert.ok(md.includes(prefix?'not a person taking over':'不把服务回执当作人已接班'));
    assert.equal((html.match(/<tbody>([\s\S]*?)<\/tbody>/)||[])[1].match(/<tr>/g).length,12);
    for(const name of files){const path=`/samples/p33-clinical-shift-handover/${name}`;assert.ok(html.includes(path));assert.equal(read('dist'+path),read(base+name));assert.ok(read('public/llms-full.txt').includes(path));}
    const short=read('public/llms.txt'),section=short.split(`](https://getyihu.com/${prefix}guides/${active}/)`)[1].split('\n### ')[0];
    assert.ok(section.includes(prefix?'night-shift':'夜班'));assert.ok(!new RegExp("SYN" + "-|Wave P|not_" + "run").test(section));
  });
  test(`P33 ${prefix||'zh'} retired technical page forwards same-language without new resources or index promotion`,()=>{
    const md=read(`src/pages/${prefix}guides/${retired}.md`),html=read(`dist/${prefix}guides/${retired}/index.html`);
    assert.ok(md.includes('indexable: false'));assert.ok(html.includes('content="noindex,follow"'));assert.ok(!html.includes('hreflang='));
    assert.ok(md.includes(`/${prefix}guides/${active}/`));assert.ok(md.includes(`/${prefix}guides/history-reference-integrity-review/`));
    assert.ok(!md.includes('/samples/p33-'));assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for(const file of ['llms.txt','llms-full.txt'])assert.ok(!read('public/'+file).includes(`https://getyihu.com/${prefix}guides/${retired}/`));
  });
}
