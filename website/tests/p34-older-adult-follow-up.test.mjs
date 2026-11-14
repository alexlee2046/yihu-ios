import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
const read=p=>readFileSync(new URL('../'+p,import.meta.url),'utf8');
const active='degraded-handoff-go-no-go',retired='audio-recovery-debounce-boundaries';
const base='public/samples/p34-older-adult-follow-up/';
const files=['README.md','checklist.en.json','checklist.zh.json'];
const sha='9397057f1b1e61942b39e08c77aa3ee744d3b108';
test('P34 twelve equivalent blank checks, no personal information or implied authority',()=>{
  assert.deepEqual(readdirSync(new URL('../'+base,import.meta.url)).sort(),files);
  const docs=['zh','en'].map(l=>JSON.parse(read(base+`checklist.${l}.json`)));
  assert.deepEqual(docs[0].items.map(({label,...i})=>i),docs[1].items.map(({label,...i})=>i));
  assert.notEqual(docs[0].items[0].label,docs[1].items[0].label);
  for(const d of docs){
    assert.equal(d.is_app_import_schema,false);assert.equal(d.is_approval_record,false);assert.equal(d.contains_patient_information,false);
    assert.equal(d.items.length,12);assert.equal(new Set(d.items.map(i=>i.key)).size,12);
    for(const i of d.items){assert.equal(i.review_state,'unfilled');for(const k of ['checked_reference','checked_scope','unresolved'])assert.equal(i[k],null);}
    for(const key of ['document_custody','outbound_transport','return_transport','companion_roles','acknowledgement_and_duplicates'])assert.ok(d.items.some(i=>i.key===key));
  }
});
for(const prefix of ['', 'en/']){
  test(`P34 ${prefix||'zh'} practical companion page at unchanged canonical with twelve-row table and six FAQs`,()=>{
    const md=read(`src/pages/${prefix}guides/${active}.md`),html=read(`dist/${prefix}guides/${active}/index.html`);
    assert.ok(md.includes(sha));assert.ok(!md.includes('indexable: false'));
    assert.ok(!new RegExp("SYNTHETIC_" + "EXAMPLE|SYN" + "-|not_" + "run|Wave P|SOURCE PASS|actual-M").test(md));
    assert.equal((html.match(/<h1\b/g)||[]).length,1);assert.equal((html.match(/id="faq-/g)||[]).length,6);
    assert.ok(html.includes('role="region"')&&html.includes('tabindex="0"'));
    assert.equal(html.match(/<tbody>([\s\S]*?)<\/tbody>/)[1].match(/<tr>/g).length,12);
    assert.ok(html.includes(`rel="canonical" href="https://getyihu.com/${prefix}guides/${active}/"`));
    assert.ok(html.includes('hreflang="zh-CN"')&&html.includes('hreflang="en"'));assert.ok(!html.includes('content="noindex,follow"'));
    for(const term of (prefix?['not clinical handover','not an app import','New operations do not prove old ones','no offline outbox','Do not use attachments to bypass refusal','not driver acceptance','hospital-accepted']:['不是医疗交班','不是App导入格式','新操作不能证明旧操作','没有新增离线待发箱','不能把附件路径当绕过拒绝的方法','不等接送人接受','医院认可']))assert.ok(md.includes(term),term);
    for(const name of files){const path=`/samples/p34-older-adult-follow-up/${name}`;assert.ok(html.includes(path));assert.equal(read('dist'+path),read(base+name));assert.ok(read('public/llms-full.txt').includes(path));}
    const section=read('public/llms.txt').split(`](https://getyihu.com/${prefix}guides/${active}/)`)[1].split('\n### ')[0];
    assert.ok(section.includes(prefix?'follow-up':'复诊'));assert.ok(!new RegExp("SYN" + "-|Wave P|not_" + "run").test(section));
  });
  test(`P34 ${prefix||'zh'} retired reference preserves noindex and existing busy-state forwarding`,()=>{
    const md=read(`src/pages/${prefix}guides/${retired}.md`),html=read(`dist/${prefix}guides/${retired}/index.html`);
    assert.ok(md.includes('indexable: false'));assert.ok(html.includes('content="noindex,follow"'));assert.ok(!html.includes('hreflang='));
    assert.ok(md.includes(`/${prefix}guides/${active}/`));assert.ok(md.includes(`/${prefix}guides/audio-busy-state-admission/`));
    assert.ok(!md.includes('/samples/p34-'));assert.ok(!read('public/sitemap.xml').includes(`/${prefix}guides/${retired}/`));
    for(const file of ['llms.txt','llms-full.txt'])assert.ok(!read('public/'+file).includes(`https://getyihu.com/${prefix}guides/${retired}/`));
  });
}
