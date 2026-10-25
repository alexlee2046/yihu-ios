import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import vm from 'node:vm';
import ts from 'typescript';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const store = JSON.parse(read('src/data/app-store.json'));
const contract = JSON.parse(read('tests/fixtures/p5-contract.json'));
const code = p => ts.transpileModule(read('src/lib/'+p+'.ts'), {compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022,esModuleInterop:true}}).outputText;
const previewCode=code('preview-events'), conversionCode=code('conversion-events');
const selected = {
 '/en/guides/audio-route-recovery-matrix/':'audio', '/guides/audio-level-not-accuracy-review/':'audio',
 '/en/guides/attention-filter-identity-boundaries/':'radar', '/en/guides/radar-evidence-second-check/':'radar',
 '/guides/capture-completion-token-review/':'audio', '/guides/model-artifact-validation-evidence/':'voice',
 '/en/guides/app-group-inbox-access-evidence/':'voice', '/en/guides/audio-busy-state-admission/':'audio',
 '/en/guides/followup-evidence-minimization/':'radar', '/en/guides/mobile-agent-decisions/':'radar',
 '/en/guides/outdoor-store-voice-preflight/':'audio', '/en/guides/pcm-format-admission-review/':'audio',
 '/guides/cross-device-field-presentation/':'radar', '/guides/noisy-transcript-text-correction/':'notes',
};
function harness(opts={}) {
 const path=opts.path??'/en/guides/mobile-agent-decisions/';
 const calls=[], winListeners={}, docListeners={}; let choice='preference' in opts?opts.preference:'granted';
 const browser={location:{origin:opts.origin??'https://getyihu.com',pathname:opts.pathname??path},
  'ga-disable-G-CWT1FWEHCL':opts.disabled??false,
  localStorage:{getItem(k){assert.equal(k,'yihu.analytics-consent.v1');if(opts.storageThrows)throw Error('blocked');return choice;}},
  addEventListener(t,fn){(winListeners[t]??=[]).push(fn);},
  ...(!opts.noTag?{gtag:(...args)=>calls.push(args)}:{}),
 };
 if(opts.missingFlag) delete browser['ga-disable-G-CWT1FWEHCL'];
 const document={querySelector(){return opts.noCanonical?null:{href:opts.canonical??'https://getyihu.com'+path};},addEventListener(t,fn){(docListeners[t]??=[]).push(fn);}};
 browser.document=document;
 class Anchor {
  constructor(href,intro=false){this.href=href;this.intro=intro;}
  closest(s){return s==='a[href]'?this:s==='[data-guide-conversion]'&&this.intro?{}:null;}
 }
 const env={window:browser,document,URL,Element:Anchor};
 const preview={}; vm.runInNewContext(previewCode,{...env,exports:preview});
 const conversion={}; vm.runInNewContext(conversionCode,{...env,exports:conversion,require(p){if(p==='./preview-events')return preview;if(p==='../data/app-store.json')return store;throw Error('unexpected module');}});
 return {calls,browser,preview,conversion,setChoice(v){choice=v;},notify(){for(const fn of winListeners['yihu:analytics-choice']??[])fn();},click(href,intro=false){for(const fn of docListeners.click??[])fn({target:new Anchor(href,intro)});}};
}
const expanded = {...selected,...Object.fromEntries(contract.targets.filter(r=>!r.path.endsWith('/iphone-agent-voice-drafts/')).map(r=>[r.path,r.scenario]))};
test('P4 mapping remains intact; P5 adds only the explicit active guides, not retired siblings',()=>{
 const h=harness();assert.deepEqual(JSON.parse(JSON.stringify(h.conversion.conversionGuides)),expanded);
 assert.deepEqual(Object.fromEntries(Object.keys(selected).map(p=>[p,h.conversion.conversionGuides[p]])),selected);
 assert.equal(h.preview.previewPaths.length,10);assert.equal(h.conversion.conversionPaths.length,153);
 assert.equal(new Set(h.conversion.conversionPaths).size,153);
 assert.equal(h.conversion.guideConversion('/guides/app-group-inbox-access-evidence/'),null);
 assert.equal(h.conversion.guideConversion('/guides/attention-filter-identity-boundaries/'),null);
 assert.equal(h.conversion.guideConversion('/guides/unknown/'),null);
});
for(const [path,scenario] of Object.entries(selected)) test('selected guide keeps language, synthetic sample and store boundary: '+path,()=>{
 const h=harness({path}),c=h.conversion.guideConversion(path),en=path.startsWith('/en/');
 assert.equal(c.scenario,scenario);assert.equal(c.storeHref,'https://apps.apple.com/us/app/yihu/id6819057500');assert.ok(c.demoHref.startsWith(en?'/en/guides/':'/guides/'));
 assert.ok(c.demoHref.endsWith('/#interactive-preview'));assert.match(c.sourceContext,en?/source\/troubleshooting.*do not establish/:/源码\/排障.*不证明/);
 assert.match(c.storeContext,en?/No Mac or self-signing/:/不需 Mac 或自行签名/);assert.ok(c.storeContext.includes('950 MB'));assert.ok(c.storeLabel.includes('0.1.0'));
 assert.equal(h.preview.trackPreviewEvent('preview_complete',scenario,en?'en':'zh','insert'),false,'original preview-only route list unchanged');
 h.conversion.bindConversionEvents();assert.equal(h.calls.length,1);
 assert.deepEqual(JSON.parse(JSON.stringify(h.calls[0])),['event','funnel_entry',{language:en?'en':'zh',scenario,placement:'page_entry',page_group:'guide'}]);
 h.click('https://getyihu.com'+c.demoHref,true);h.click(store.url,true);
 assert.deepEqual(h.calls.map(c=>c[1]),['funnel_entry','guide_demo_click','app_store_click']);
 for(const c of h.calls)assert.deepEqual(Object.keys(c[2]).sort(),['language','page_group','placement','scenario']);
});
for(const opts of [
 {preference:null},{preference:'denied'},{preference:''},{preference:'malformed'},{preference:'GRANTED'},
 {origin:'https://preview.example'},{origin:'http://localhost:4321'},{origin:'https://getyihu.com.evil.example'},
 {disabled:true},{missingFlag:true},{noTag:true},{storageThrows:true},{noCanonical:true},
 {canonical:'https://evil.example/en/guides/mobile-agent-decisions/'},
 {canonical:'https://getyihu.com/private/person/'},{canonical:'https://user@getyihu.com/en/guides/mobile-agent-decisions/'},
 {canonical:'https://getyihu.com/'}, {path:'/guides/unknown/'},
]) test('conversion fails closed exactly like preview eligibility '+JSON.stringify(opts),()=>{
 const h=harness(opts);h.conversion.bindConversionEvents();h.click(store.url,true);h.notify();
 assert.equal(h.conversion.trackConversionEvent('app_store_click','radar','guide_intro'),false);
 assert.equal(h.calls.length,0);
});
test('late explicit grant records current entry once, never replays denied clicks; withdrawal stays authoritative',()=>{
 const h=harness({preference:null});h.conversion.bindConversionEvents();h.click(store.url);assert.equal(h.calls.length,0);
 h.setChoice('granted');h.notify();h.notify();assert.deepEqual(h.calls.map(c=>c[1]),['funnel_entry']);
 h.click(store.url);h.click(store.url);assert.deepEqual(h.calls.map(c=>c[1]),['funnel_entry','app_store_click','app_store_click']);
 h.browser['ga-disable-G-CWT1FWEHCL']=true;h.notify();h.click(store.url);assert.equal(h.calls.length,3,'saved grant cannot undo failed-write refusal');
});
test('correct same-language targets only; no query payload, campaign links, text, or invented runtime values',()=>{
 const h=harness({canonical:'https://getyihu.com/en/guides/mobile-agent-decisions/?private=never#secret'});h.conversion.bindConversionEvents();
 for(const url of [store.url+'?identity=never','https://apps.apple.com/us/app/other/id6761704540','https://getyihu.com/guides/multi-project-radar-watch/#interactive-preview','https://evil.example/en/guides/multi-project-radar-watch/#interactive-preview','https://getyihu.com/en/guides/multi-project-radar-watch/?private=never#interactive-preview','not a URL'])h.click(url);
 assert.equal(h.calls.length,1);
 for(const args of [['customer text','radar','guide_intro'],['app_store_click','raw_json','guide_intro'],['app_store_click','radar','query string'],['funnel_entry','radar','page_link']])assert.equal(h.conversion.trackConversionEvent(...args),false);
 h.click('https://getyihu.com/en/guides/recording-notes-handoff/#interactive-preview');assert.equal(h.calls[1][2].scenario,'notes');
 assert.ok(!JSON.stringify(h.calls).includes('never'));assert.ok(!JSON.stringify(h.calls).includes('secret'));
});
test('www production pages track relative preview links resolved on the www origin',()=>{
 const h=harness({origin:'https://www.getyihu.com'});
 h.conversion.bindConversionEvents();
 const c=h.conversion.guideConversion('/en/guides/mobile-agent-decisions/');
 h.click(new URL(c.demoHref,h.browser.location.origin).href,true);
 assert.deepEqual(h.calls.map(c=>c[1]),['funnel_entry','guide_demo_click']);
 assert.equal(h.calls[1][2].scenario,'radar');
 const denied=harness({origin:'https://www.getyihu.com',preference:'denied'});
 denied.conversion.bindConversionEvents();
 denied.click(new URL(c.demoHref,denied.browser.location.origin).href,true);
 assert.equal(denied.calls.length,0);
});
test('home, scenario and setup denominators share explicit grant without expanding old preview events',()=>{
 const h=harness();for(const path of h.conversion.conversionPaths){
  const x=harness({path});x.conversion.bindConversionEvents();assert.equal(x.calls.length,1,path);
  const denied=harness({path,preference:'denied'});denied.conversion.bindConversionEvents();denied.click(store.url);assert.equal(denied.calls.length,0,path);
 }
});
test('store wording and telemetry do not add permissions, network, storage writes, queues or backend setup',()=>{
 const demo=read('src/components/Demo.tsx'),start=read('src/pages/en/start.astro'),event=read('src/lib/conversion-events.ts');
 assert.ok(demo.includes('Store installation does not require self-signing'));assert.ok(demo.includes('商店安装不需自行签名'));
 assert.ok(!demo.includes('App setup requires your workspace, speech models and signing'));
 assert.ok(start.includes('without self-signing'));assert.ok(read('src/components/Guide.astro').includes('no Mac or personal signing'),'store body still excludes the Mac prerequisite');assert.ok(!start.includes('Check HTTPS access, source signing'));
 for(const forbidden of ['localStorage.setItem','sessionStorage','fetch(','sendBeacon','XMLHttpRequest','setTimeout','preventDefault','user_id','query_string','editor_text'])assert.ok(!event.includes(forbidden),forbidden);
});
const built=existsSync(new URL('dist/index.html',root));
test('built 147 exact paired intro links retain source warnings and unchanged 180/150/30 discovery', {skip:!built},()=>{
 function pages(p='dist/'){return readdirSync(new URL(p,root),{withFileTypes:true}).flatMap(x=>x.isDirectory()?pages(p+x.name+'/'):x.name==='index.html'?[p+x.name]:[]);}
 const all=pages();assert.equal(all.length,180);let count=0,retired=0;
 for(const file of all){const html=read(file),path='/'+file.slice(5).replace(/index\.html$/,'');
  if(html.includes('content="noindex,follow"'))retired++;
  const blocks=[...html.matchAll(/<section\b[^>]*\bdata-guide-conversion\b[^>]*>[\s\S]*?<\/section>/g)];
  assert.equal(blocks.length,Object.hasOwn(expanded,path)?1:0,path);if(!blocks.length)continue;count++;
  const c=harness().conversion.guideConversion(path),block=blocks[0][0];assert.ok(block.includes('href="'+c.demoHref+'"'));assert.ok(block.includes('href="'+store.url+'"'));assert.ok(block.includes(c.sourceContext));
  assert.ok(html.indexOf('<h1')<html.indexOf('data-guide-conversion'));assert.ok(html.indexOf('data-guide-conversion')<html.indexOf('id="first-answer"')||path.endsWith('/mobile-agent-decisions/'));
  const core=harness().preview.previewPaths.includes(path);
  assert.equal([...html.matchAll(/<astro-island\b/g)].length,core?1:0,'core keeps exactly one existing preview; references add no islands');
  const target=read('dist'+c.demoHref.split('#')[0]+'index.html');assert.ok(target.includes('id="interactive-preview"'));
 }
 assert.equal(count,147);assert.equal(retired,30);assert.equal([...read('public/sitemap.xml').matchAll(/<loc>/g)].length,150);
});

// Frozen P5 specifications are expectations, never a substitute for running this source.
for(const row of contract.events) test('P5 exact 180-route eligibility/context: '+row.path,()=>{
 const h=harness({path:row.path});h.conversion.bindConversionEvents();h.notify();
 if(row.context){
  assert.equal(h.calls.length,1);
  assert.deepEqual(JSON.parse(JSON.stringify(h.calls[0])),['event','funnel_entry',{...row.context,placement:'page_entry'}]);
  h.click(store.url);assert.equal(h.calls.length,2);
  assert.deepEqual(JSON.parse(JSON.stringify(h.calls[1][2])),{...row.context,placement:'page_link'});
 } else {h.click(store.url);assert.equal(h.calls.length,0);}
 const denied=harness({path:row.path,preference:'denied'});denied.conversion.bindConversionEvents();denied.click(store.url);denied.notify();assert.equal(denied.calls.length,0);
});
for(const row of contract.p4) test('P4 legacy context/placements preserved: '+row.path,()=>{
 const h=harness({path:row.path});h.conversion.bindConversionEvents();
 h.click(store.url,false);h.click(store.url,true);
 assert.deepEqual(h.calls.map(c=>c[1]),['funnel_entry','app_store_click','app_store_click']);
 for(const [i,placement] of ['page_entry','page_link','guide_intro'].entries())assert.deepEqual(JSON.parse(JSON.stringify(h.calls[i][2])),{...row.context,placement});
});
test('only 127 eligible paths and 133 cards are added, with no original route/context removal',()=>{
 const h=harness(),old=new Set(contract.p4.map(r=>r.path));
 const expected=contract.events.filter(r=>r.context).map(r=>r.path);
 assert.equal(expected.length,153);assert.equal(h.conversion.conversionPaths.length,153);
 assert.deepEqual([...h.conversion.conversionPaths].sort(),expected.sort());
 assert.equal(expected.filter(p=>!old.has(p)).length,127);
 assert.ok([...old].every(p=>expected.includes(p)));
 const newCards=Object.keys(h.conversion.conversionGuides).filter(p=>!Object.hasOwn(selected,p));
 assert.equal(newCards.length,133);assert.deepEqual(newCards.sort(),[...contract.new_cards].sort());
 for(const path of ['/privacy/','/en/privacy/'])assert.ok(!expected.includes(path));
});
test('twelve body changes are store-aware only; metadata retains ten CTR candidates and two retired references',()=>{
 assert.equal(contract.metadata.length,12);assert.equal(contract.metadata.filter(r=>r.ctr).length,10);
 assert.equal(contract.metadata.filter(r=>!r.indexable&&!r.ctr).length,2);assert.equal(contract.content.length,12);
 for(const c of contract.content){const body=read('../'+c.source_file).split('---').slice(2).join('---');assert.ok(body.includes(c.after));assert.ok(!body.includes(c.before));}
});
test('all 144 active guide targets exist in the same language, with no duplicated card/island or retired promotion',{skip:!built},()=>{
 const indexed=[...read('public/sitemap.xml').matchAll(/<loc>([^<]+)<\/loc>/g)].map(m=>m[1]);
 const h=harness();let withCard=0,existingVoice=0;
 for(const r of contract.targets){
  const url='https://getyihu.com'+r.path;assert.ok(indexed.includes(url));
  const html=read('dist'+r.path+'index.html');
  const hrefs=[...html.matchAll(/href="([^"]+)"/g)].map(m=>new URL(m[1].replaceAll('&amp;','&'),url).href);
  assert.ok(hrefs.includes(r.target),r.path+' has exact same-language target');assert.ok(hrefs.includes(store.url));
  const destination=new URL(r.target);assert.equal(destination.pathname.startsWith('/en/'),r.path.startsWith('/en/'));
  const target=read('dist'+destination.pathname+'index.html');assert.equal([...target.matchAll(/id="interactive-preview"/g)].length,1);
  const islandCount=[...html.matchAll(/<astro-island\b/g)].length;
  assert.equal(islandCount,h.preview.previewPaths.includes(r.path)?1:0,r.path+' exactly original islands');
  const cards=[...html.matchAll(/<section\b[^>]*data-guide-conversion\b/g)].length;
  if(r.path.endsWith('/iphone-agent-voice-drafts/')){existingVoice++;assert.equal(cards,0);}else{withCard++;assert.equal(cards,1);}
 }
 assert.equal(withCard,142);assert.equal(existingVoice,2);
 const outside=contract.events.filter(r=>r.context&&!indexed.includes('https://getyihu.com'+r.path)).map(r=>r.path);
 assert.equal(outside.length,5);assert.ok(outside.every(p=>contract.p4.some(r=>r.path===p)));
});
test('built twelve metadata changes keep exact identity and noindex/hreflang policies',{skip:!built},()=>{
 const decode=s=>s.replaceAll('&amp;','&').replaceAll('&quot;','"').replaceAll('&#39;',"'");
 for(const r of contract.metadata){const html=read('dist'+r.path+'index.html');
  assert.equal(decode(html.match(/<title>([^<]*)<\/title>/)[1]),r.title);
  assert.equal(decode(html.match(/<meta name="description" content="([^"]*)"/)[1]),r.description);
  assert.equal(html.includes('content="noindex,follow"'),!r.indexable,r.path);
  assert.equal(html.includes('hreflang='),r.indexable,r.path);
  assert.ok(html.includes('rel="canonical" href="https://getyihu.com'+r.path+'"'));
  if(r.path==='/'||r.path==='/en/'){
   const schema=JSON.parse(html.match(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/)[1]);
   const app=schema.find(x=>x['@type']==='SoftwareApplication');assert.equal(app.identifier,'com.qm.agent.collie');assert.equal(app.softwareVersion,'0.1.0');assert.equal(app.installUrl,store.url);
  }
 }
});
