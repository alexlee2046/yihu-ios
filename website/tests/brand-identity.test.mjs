import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root=new URL('../',import.meta.url),read=p=>readFileSync(new URL(p,root),'utf8');
const store=JSON.parse(read('src/data/app-store.json'));
const built=existsSync(new URL('dist/index.html',root));
const official='https://apps.apple.com/us/app/yihu/id6819057500';
test('brand identity pins the observed public Apple listing, not a guessed app or source-to-binary mapping',()=>{
 assert.equal(store.name,'Yihu');assert.equal(store.alternateName,'一呼');assert.equal(store.appId,'6819057500');
 assert.equal(store.bundleId,'com.qm.agent.collie');assert.equal(store.url,official);assert.equal(store.version,'0.1.0');
 assert.equal(store.minimumOSVersion,'18.0');assert.equal(store.observedOn,'2026-10-24');
 assert.equal(store.releaseDate,'2026-10-19T20:13:21Z');
 assert.equal(store.publicLookup,'https://itunes.apple.com/lookup?id=6819057500&country=us');
 assert.ok(!('sourceCommit' in store));assert.ok(!('globalAvailability' in store));
});
test('both homepage graphs identify the same app, with genuine store metadata and no invented ratings',{skip:!built},()=>{
 for(const prefix of ['','en/']){
  const html=read('dist/'+prefix+'index.html');
  const graphs=[...html.matchAll(/<script\b[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/g)].flatMap(x=>JSON.parse(x[1]));
  assert.equal(graphs.length,4);const app=graphs.find(x=>x['@type']==='SoftwareApplication');
  assert.equal(app['@id'],'https://getyihu.com/#software');assert.equal(app.name,store.name);assert.equal(app.alternateName,store.alternateName);
  assert.equal(app.installUrl,official);assert.equal(app.softwareVersion,store.version);assert.equal(app.identifier,store.bundleId);
  assert.equal(app.datePublished,store.releaseDate);assert.equal(app.author.name,store.sellerName);
  assert.ok(app.sameAs.includes(official));assert.ok(!app.aggregateRating && !app.review && !app.offers && !app.license);
  const org=graphs.find(x=>x['@type']==='Organization');assert.equal(org.name,'Yihu');assert.equal(org.alternateName,'一呼');
  const faq=graphs.find(x=>x['@type']==='FAQPage'),copy=JSON.parse(read('src/data/home-answers.json'))[prefix?'en':'zh'];
  assert.deepEqual(faq.mainEntity.map(x=>x.name),copy.faqs.map(x=>x.question));
  assert.deepEqual(faq.mainEntity.map(x=>x.acceptedAnswer.text),copy.faqs.map(x=>x.answer));
  for(const item of copy.faqs)assert.ok(html.includes(item.question));
  assert.ok(html.includes('class="button button-text app-store-link"'));
  assert.ok(html.includes(prefix?'Source development':'源码')||html.includes(prefix?'source work':'源码'));
 }
});
test('installation splits App Store users from source developers before signing prerequisites',{skip:!built},()=>{
 for(const prefix of ['','en/']){
  const html=read('dist/'+prefix+'start/index.html');
  assert.ok(html.indexOf('id="store-start"')<html.indexOf('id="source-setup"'));
  assert.match(html,/<details id="source-setup"[^>]*>/);assert.ok(!/<details id="source-setup"[^>]*\bopen(?:\s|>|=)/.test(html));
  const section=html.match(/<section id="store-start"[\s\S]*?<\/section>/)[0];
  assert.ok(section.includes('href="'+official+'"'));assert.ok(section.includes(store.version));assert.ok(section.includes('950 MB'));
  assert.ok(section.includes(prefix?'no Mac or personal signing':'不需要 Mac 或自行签名'));
  for(const id of ['origin','network','build','models','editor','synthetic'])assert.ok(html.includes('id="check-'+id+'"'));
  assert.ok(html.includes(prefix?'Source developers:':'源码开发者：'));
 }
});
test('current entry points no longer claim there is no App Store release; source paths remain explicit',{skip:!built},()=>{
 for(const prefix of ['','en/'])for(const route of ['','start/','guides/iphone-agent-voice-drafts/']){
  const html=read('dist/'+prefix+route+'index.html');
  for(const stale of ['not an App Store binary','currently a source release','Currently a source release','没有可直接下载的 App Store 成品','不是 App Store 安装成品','当前提供源码：'])assert.ok(!html.includes(stale),route+stale);
  assert.ok(html.includes('href="'+official+'"'));assert.ok(html.includes('0.1.0'));
  assert.ok(html.includes(prefix?'regional availability':'地区供应')||html.includes(prefix?'availability follows':'地区供应'));
 }
 const intro=read('tools/export-llms.py');assert.ok(!intro.includes('No App Store listing'));
 const readme=read('../README.md');assert.ok(readme.includes(official));assert.ok(readme.includes('Source signing and build prerequisites below are not requirements'));
});
test('brand answers explain optional model size and source-version boundaries without claiming downloads or new models',()=>{
 const d=JSON.parse(read('src/data/home-answers.json'));
 for(const lang of ['zh','en']){
  const answer=d[lang].faqs.find(x=>x.id==='models').answer;assert.ok(answer.includes('950 MB')&&answer.includes(store.version));
  for(const id of ['notes','radar'])assert.match(d[lang].faqs.find(x=>x.id===id).answer,/源码|source/);
 }
});
