import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const retired = ["shortcut-toggle-request-lifetime","notification-disable-unregister-pending","reminder-link-pending-origin-routing","capture-completion-token-review","watch-voice-queued-ready-boundaries","watch-open-request-ui-boundaries","navigation-cancel-process-reload-boundaries","audio-recovery-debounce-boundaries","recognition-pass-parameter-budget","focused-editable-admission-review","pcm-stream-end-boundaries","model-artifact-validation-evidence","app-group-inbox-access-evidence","attention-filter-identity-boundaries","followup-evidence-minimization"];
const hasBuild = existsSync(new URL('dist/index.html', root));
const core = ['iphone-agent-voice-drafts', 'bluetooth-audio-input-troubleshooting', 'recording-notes-handoff', 'multi-project-radar-watch'];
const urls = [...read('public/sitemap.xml').matchAll(/<loc>([^<]+)<\/loc>/g)].map(x => x[1]);
function pages(path = 'dist/') {
  return readdirSync(new URL(path, root), { withFileTypes: true }).flatMap(e => e.isDirectory() ? pages(path + e.name + '/') : e.name === 'index.html' ? [path + e.name] : []);
}
test('180 built routes remain accessible; the 30 approved references leave the 150-page index', { skip: !hasBuild }, () => {
  const built = pages(); assert.equal(built.length, 180);
  assert.equal(urls.length, 150); assert.equal(new Set(urls).size, 150);
  let excluded = 0;
  for (const file of built) {
    const html = read(file), url = 'https://getyihu.com/' + file.slice(5).replace(/index\.html$/, '');
    const isRetired = retired.some(s => url.endsWith('/guides/' + s + '/'));
    assert.ok(html.includes('<link rel="canonical" href="' + url + '"'));
    assert.equal(html.includes('content="noindex,follow"'), isRetired, url);
    assert.equal(urls.includes(url), !isRetired, url);
    if (isRetired) {
      excluded++;
      assert.ok(!html.includes('hreflang='), 'no indexed-language promotion of retired pairs');
      assert.ok(html.includes('Technical reference') || html.includes('技术参考'));
      for (const name of ['llms.txt', 'llms-full.txt']) {
        assert.ok(!read('public/' + name).includes(url), name + ' excludes ' + url);
      }
    }
  }
  assert.equal(excluded, 30);
  assert.ok(!/^Disallow:\s*\/\s*$/m.test(read('public/robots.txt')), 'crawler can see noindex');
});
test('P8 synthetic source downloads preserve reviewed bytes, raw protocol states and no reply capability', () => {
  const hashes = { 'radar-brief.zh.json':'ea93f839dcaaf3644e45d0bf37d42575f6ba8b93134b44ecaf4dcaef505147fe', 'radar-brief.en.json':'1eb1f54bc381eec5bb8f66d7b61c0de69d2340c9fed0bf02b8d452abf29ffdd1', 'buyer-card.md':'8e3a8cb988b85375271a081cbabfc3d3a53000bd2488f9afa9b64e3670dba437' };
  for(const [file,hash] of Object.entries(hashes)) assert.equal(createHash('sha256').update(read('public/samples/p8-opportunity-preflight/'+file)).digest('hex'),hash);
  for(const lang of ['zh','en']) {
    const data=JSON.parse(read('public/samples/p8-opportunity-preflight/radar-brief.'+lang+'.json'));
    assert.equal(data.date_str,'2026-10-31 12:00');assert.equal(data.reply_supported,false);
    assert.equal(data.source_refreshing,false);assert.equal(data.source_refresh_failed,false);
    assert.equal(data.tasks.length,2);assert.deepEqual(data.decisions,data.tasks);assert.equal(data.active.length,1);
    assert.deepEqual(data.stale,[]);assert.deepEqual(data.cold,[]);
    assert.equal(data.tasks[0].status,' 等你决策 ');assert.equal(data.tasks[1].status,'等你验收');
    assert.equal(data.tasks[0].id,'demo-decision');assert.equal(data.tasks[1].id,'demo-acceptance');
    for(const task of data.tasks) assert.equal(new URL(task.url).hostname,'example.invalid');
  }
  const card=read('public/samples/p8-opportunity-preflight/buyer-card.md');
  for(const boundary of ['SYN-LEAD-31','reply_supported:false','No-Go','not_run','950MB','0.1.0']) assert.ok(card.includes(boundary));
});
test('P8 two existing technical sections expose static downloads without restoring retired indexing', {skip:!hasBuild}, () => {
  for(const [route,lang,heading,noindex] of [
    ['en/guides/attention-filter-identity-boundaries/','en','Filled offline example: attention is not identity or write authority',true],
    ['guides/note-radar-draft-candidate-preflight/','zh','已填合成样板申请：需要关注不等于可以写入',false],
  ]) {
    const html=read('dist/'+route+'index.html');assert.ok(html.includes(heading));
    assert.equal(html.includes('content="noindex,follow"'),noindex);
    assert.equal(urls.includes('https://getyihu.com/'+route),!noindex);
    assert.ok(html.includes('rel="canonical" href="https://getyihu.com/'+route+'"'));
    assert.match(html,new RegExp('<a href="/samples/p8-opportunity-preflight/radar-brief\\.'+lang+'\\.json" download'));
    assert.match(html,/<a href="\/samples\/p8-opportunity-preflight\/buyer-card\.md" download/);
    if(noindex) assert.ok(!html.includes('hreflang='));
    for(const name of ['llms.txt','llms-full.txt']) assert.equal(read('public/'+name).includes('https://getyihu.com/'+route),!noindex);
  }
  assert.ok(read('public/llms-full.txt').includes('已填合成样板申请：需要关注不等于可以写入'));
  assert.ok(!read('public/llms-full.txt').includes('Filled offline example: attention is not identity or write authority'));
  for(const file of ['radar-brief.zh.json','radar-brief.en.json','buyer-card.md']) assert.equal(read('dist/samples/p8-opportunity-preflight/'+file),read('public/samples/p8-opportunity-preflight/'+file));
});
test('P9 frozen audio preflight stays synthetic with thirteen helper inputs and eight source-only branches', () => {
  const hashes = { 'audio-preflight.zh.json':'3b7e88759c9f70eed22b99b629d79d141224ff13ad33f56e4c375d930b9b2fb1', 'audio-preflight.en.json':'5edc1cc499a605ef916d625244c855d815fc8ff33ae9ab112249b99e9c5f8632', 'preflight-card.md':'962c211326a95d5b6de90a8aee5ad702f347f46004342ce246fdbb2a7d53f14d' };
  for(const [file,hash] of Object.entries(hashes)) assert.equal(createHash('sha256').update(read('public/samples/p9-audio-preflight/'+file)).digest('hex'),hash);
  for(const lang of ['zh','en']) {
    const d=JSON.parse(read('public/samples/p9-audio-preflight/audio-preflight.'+lang+'.json'));
    assert.equal(d.case_id,'SYN-AUDIO-32');assert.equal(d.language,lang);assert.equal(d.synthetic,true);
    assert.equal(d.source_commit,'bf339e21b5ffad3f899715c285d6c52d3e291a76');
    assert.equal(d.is_app_import_schema,false);assert.equal(d.is_device_log,false);assert.equal(d.hardware_status,'not_run');
    assert.equal(d.observed_audio,null);assert.equal(d.observed_transcript,null);
    assert.equal(d.reference_utterance.spoken_text,d.reference_utterance.ideal_verbatim_text);
    assert.equal(d.debouncer_runs.length,4);assert.equal(d.debouncer_runs.flatMap(r=>r.events).length,13);
    assert.deepEqual(d.debouncer_runs.map(r=>r.events.map(e=>e.expected_should_suppress)),[[true,true,true,false,false],[false,true,false,false],[false,false],[false,false]]);
    assert.deepEqual(d.debouncer_runs[0].events.map(e=>e.at_ms),[200,1000,2000,2001,2100]);
    assert.equal(d.recorder_branches.length,8);
    for(const b of d.recorder_branches) assert.equal(b.evidence_scope,'source_read_only_not_native_engine_execution');
    assert.ok(d.not_proven.includes('actual microphone selection or accessory compatibility'));
    assert.ok(d.not_proven.includes('ASR accuracy or real final transcript'));
  }
});
test('P9 download sections stay on four active guides and never restore retired debounce pairs', {skip:!hasBuild}, () => {
  const full=read('public/llms-full.txt');
  for(const [prefix,lang] of [['','zh'],['en/','en']]) {
    for(const slug of ['audio-route-recovery-matrix','bluetooth-audio-input-troubleshooting']) {
      const route=prefix+'guides/'+slug+'/',html=read('dist/'+route+'index.html');
      assert.ok(urls.includes('https://getyihu.com/'+route));assert.ok(!html.includes('content="noindex,follow"'));
      assert.ok(html.includes('rel="canonical" href="https://getyihu.com/'+route+'"'));assert.ok(html.includes('SYN-AUDIO-32'));
      assert.ok(html.includes('<a href="/samples/p9-audio-preflight/audio-preflight.'+lang+'.json" download'));
      assert.ok(html.includes('<a href="/samples/p9-audio-preflight/preflight-card.md" download'));
      assert.ok(html.includes(lang==='zh'?'不是真机':'not a device') || html.includes(lang==='zh'?'不是App可导入配置':'not an app import format'));
      assert.ok(full.includes('https://getyihu.com/'+route));
    }
    const retiredRoute=prefix+'guides/audio-recovery-debounce-boundaries/',html=read('dist/'+retiredRoute+'index.html');
    assert.ok(html.includes('content="noindex,follow"'));assert.ok(!html.includes('hreflang='));
    assert.ok(!html.includes('/samples/p9-audio-preflight/'));assert.ok(!urls.includes('https://getyihu.com/'+retiredRoute));
    for(const name of ['llms.txt','llms-full.txt']) assert.ok(!read('public/'+name).includes('https://getyihu.com/'+retiredRoute));
  }
  for(const file of ['audio-preflight.zh.json','audio-preflight.en.json','preflight-card.md']) assert.equal(read('dist/samples/p9-audio-preflight/'+file),read('public/samples/p9-audio-preflight/'+file));
});
test('P10 frozen token cases preserve twenty-one adapter operations without device or permission claims', () => {
  const hashes = { 'token-recapture-preflight.zh.json':'9a03fd9e958349b7c0df72763eb5b121e424228e414278f280f95523c7601ece', 'token-recapture-preflight.en.json':'99844069a5f2da24e22e89b652164ea384182c425fbe23b4031b226438c65b8f', 'preflight-card.md':'16b262671ad30c2d9945b6c11a75206944d119bd7bcd7e80343f530e6df87815' };
  for(const [file,hash] of Object.entries(hashes)) assert.equal(createHash('sha256').update(read('public/samples/p10-token-recapture/'+file)).digest('hex'),hash);
  for(const lang of ['zh','en']) {
    const d=JSON.parse(read('public/samples/p10-token-recapture/token-recapture-preflight.'+lang+'.json'));
    assert.equal(d.case_id,'SYN-TOKEN-33');assert.equal(d.language,lang);assert.equal(d.synthetic,true);
    assert.equal(d.source_commit,'318dbfaa9976568ff6c052c011a5e636612f6419');assert.equal(d.is_app_import_schema,false);
    assert.equal(d.device_status,'not_run');assert.equal(d.observed_audio,null);assert.equal(d.observed_transcript,null);
    assert.equal(d.reference_utterance.spoken_text,d.reference_utterance.ideal_verbatim_text);assert.equal(d.reference_utterance.observed_text,null);
    assert.deepEqual(d.runs.map(r=>r.steps.length),[6,8,7]);assert.equal(d.runs.flatMap(r=>r.steps).length,21);
    assert.equal(d.runs[0].steps[2].expect.start_preflight,'busy');
    assert.equal(d.runs[0].steps.at(-1).expect.start_preflight,'would_reach_permission_check');
    assert.equal(d.runs[1].steps.at(-1).expect.callback_count,1);assert.equal(d.runs[1].steps.at(-1).expect.export_spy_calls,1);
    assert.equal(d.runs[2].steps.at(-1).expect.callback_count,2);assert.equal(d.runs[2].steps.at(-1).expect.failure_count,2);
    assert.ok(Object.values(d.runtime_checks).every(v=>v==='not_run'));
    assert.equal(d.recapture_worksheet.actual_file_check,'not_run');assert.equal(d.recapture_worksheet.physical_recapture,'not_run');
  }
});
test('P10 active recapture downloads have stable anchors while retired token references only link to them', {skip:!hasBuild}, () => {
  for(const [prefix,lang] of [['','zh'],['en/','en']]) {
    const active=prefix+'guides/interruption-recapture-preflight/',html=read('dist/'+active+'index.html');
    assert.ok(urls.includes('https://getyihu.com/'+active));assert.ok(!html.includes('content="noindex,follow"'));
    assert.equal([...html.matchAll(/id="syn-token-33"/g)].length,1);
    assert.ok(html.includes('<a href="/samples/p10-token-recapture/token-recapture-preflight.'+lang+'.json" download'));
    assert.ok(html.includes('<a href="/samples/p10-token-recapture/preflight-card.md" download'));
    const retiredRoute=prefix+'guides/capture-completion-token-review/',reference=read('dist/'+retiredRoute+'index.html');
    assert.ok(reference.includes('content="noindex,follow"'));assert.ok(!reference.includes('hreflang='));
    assert.ok(reference.includes('href="/'+active+'#syn-token-33"'));
    assert.ok(!reference.includes('/samples/p10-token-recapture/'));assert.ok(!urls.includes('https://getyihu.com/'+retiredRoute));
    for(const name of ['llms.txt','llms-full.txt']) assert.ok(!read('public/'+name).includes('https://getyihu.com/'+retiredRoute));
    assert.ok(read('public/llms-full.txt').includes('https://getyihu.com/'+active));
  }
  for(const file of ['token-recapture-preflight.zh.json','token-recapture-preflight.en.json','preflight-card.md']) assert.equal(read('dist/samples/p10-token-recapture/'+file),read('public/samples/p10-token-recapture/'+file));
});
test('P11 separates pinned model metadata from tiny-file expectations and memory loading spies', () => {
  const hashes = { 'model-preflight.zh.json':'258aae2172a40b62f7142f795426f3bcc8065580174e4adf6613b7e5b28bf826', 'model-preflight.en.json':'22ce1d52325e185477abb57eb8f4d3e72a424dfa8d582744b5399e2fef30c7bb', 'preflight-card.md':'50ef5253f20f2f0b5ba81d309b0e7f387515354023a11c5daa80d8e16aed4006' };
  for(const [file,hash] of Object.entries(hashes)) assert.equal(createHash('sha256').update(read('public/samples/p11-model-preflight/'+file)).digest('hex'),hash);
  for(const lang of ['zh','en']) {
    const d=JSON.parse(read('public/samples/p11-model-preflight/model-preflight.'+lang+'.json'));
    assert.equal(d.case_id,'SYN-MODEL-34');assert.equal(d.language,lang);assert.equal(d.synthetic,true);
    assert.equal(d.source_commit,'acd44181a445e6c497709ba26b63e4302b21044e');assert.equal(d.is_app_import_schema,false);
    assert.equal(d.pinned_source_manifest.assets.length,24);assert.equal(d.pinned_source_manifest.asset_count,24);
    assert.equal(d.pinned_source_manifest.assets.reduce((s,a)=>s+a.byteCount,0),945583332);
    assert.equal(d.pinned_source_manifest.total_byte_count,945583332);
    assert.equal(d.isolated_test_manifest.marker,'.fixture-revision');assert.equal(d.isolated_test_manifest.assets.length,2);
    for(const a of d.isolated_test_manifest.assets) {
      assert.equal(Buffer.byteLength(a.bytes_utf8),8);assert.equal(a.byteCount,8);
      assert.equal(createHash('sha256').update(a.bytes_utf8).digest('hex'),a.sha256);
    }
    assert.deepEqual(d.integrity_cases.map(c=>c.expected_isInstalled),[false,false,false,false,false,true,true,false]);
    assert.equal(d.load_generation_cases.length,7);
    assert.equal(d.load_generation_cases[3].expected.warm_spy_calls,2);
    assert.equal(d.load_generation_cases[4].expected.load_spy_calls,0);
    assert.equal(d.load_generation_cases[6].expected.integrity_calls,2);assert.equal(d.load_generation_cases[6].expected.load_spy_calls,1);
    assert.equal(d.reference_utterance.spoken_text,d.reference_utterance.ideal_verbatim_text);assert.equal(d.reference_utterance.observed_transcript,null);
    assert.ok(Object.values(d.runtime_checks).every(v=>v==='not_run'));
  }
});
test('P11 first-trial downloads clarify store installation while retired model pages only transfer technically', {skip:!hasBuild}, () => {
  for(const [prefix,lang] of [['','zh'],['en/','en']]) {
    const active=prefix+'guides/first-trial-go-no-go-checklist/',html=read('dist/'+active+'index.html');
    assert.ok(urls.includes('https://getyihu.com/'+active));assert.ok(!html.includes('content="noindex,follow"'));
    assert.equal([...html.matchAll(/id="syn-model-34"/g)].length,1);
    assert.ok(html.includes('<a href="/samples/p11-model-preflight/model-preflight.'+lang+'.json" download'));
    assert.ok(html.includes('<a href="/samples/p11-model-preflight/preflight-card.md" download'));
    assert.ok(html.includes(lang==='zh'?'商店版不需Mac/Xcode/自行签名':'needs no Mac/Xcode/self-signing for installation'));
    const retiredRoute=prefix+'guides/model-artifact-validation-evidence/',ref=read('dist/'+retiredRoute+'index.html');
    assert.ok(ref.includes('content="noindex,follow"'));assert.ok(!ref.includes('hreflang='));
    assert.ok(ref.includes('href="/'+active+'#syn-model-34"'));assert.ok(!ref.includes('/samples/p11-model-preflight/'));
    assert.ok(!urls.includes('https://getyihu.com/'+retiredRoute));
    for(const name of ['llms.txt','llms-full.txt']) assert.ok(!read('public/'+name).includes('https://getyihu.com/'+retiredRoute));
    assert.ok(read('public/llms-full.txt').includes('https://getyihu.com/'+active));
  }
  for(const file of ['model-preflight.zh.json','model-preflight.en.json','preflight-card.md']) assert.equal(read('dist/samples/p11-model-preflight/'+file),read('public/samples/p11-model-preflight/'+file));
});
test('bilingual home offers four buyer scenarios, not the old technical link wall', { skip: !hasBuild }, () => {
  const copy = JSON.parse(read('src/data/home-answers.json'));
  for (const [lang, prefix] of [['zh', ''], ['en', 'en/']]) {
    const html = read('dist/' + prefix + 'index.html');
    assert.equal(copy[lang].scenarios.length, 4);
    assert.deepEqual(copy[lang].scenarios.map(x => x.slug), core);
    for (const slug of core) assert.ok(html.includes('href="/' + prefix + 'guides/' + slug + '/"'));
    for (const slug of [...retired, 'capture-completion-token-review', 'host-bridge-outcome-boundaries']) assert.ok(!html.includes('/guides/' + slug + '/'));
    assert.ok(html.includes('id="scenarios"'));
    assert.ok(html.includes('href="https://apps.apple.com/us/app/yihu/id6819057500"'),'real App Store listing, not an invented download');
    for(const link of html.matchAll(/href="(https:\/\/apps\.apple\.com\/[^\"]+)"/g)) assert.equal(link[1],'https://apps.apple.com/us/app/yihu/id6819057500');
  }
});
test('core pages explain workflow choices and keep practical setup/source links', { skip: !hasBuild }, () => {
  for (const prefix of ['', 'en/']) for (const slug of core) {
    const html = read('dist/' + prefix + 'guides/' + slug + '/index.html');
    assert.equal([...html.matchAll(/<h1\b/g)].length, 1);
    assert.ok(html.includes('id="first-answer"'));
    assert.ok(html.includes('href="/' + prefix + 'start/"'));
    assert.ok(html.includes('a59676a72c1931bb36dc29ef0810b5e6dc9339ea'));
  }
  for (const prefix of ['', 'en/']) {
    assert.ok(read('dist/' + prefix + 'guides/iphone-agent-voice-drafts/index.html').includes('id="compare"'));
    assert.ok(read('dist/' + prefix + 'guides/recording-notes-handoff/index.html').includes('id="compare"'));
  }
});

test('home and four core scenario pairs reuse exactly one three-card preview with appropriate defaults', { skip: !hasBuild }, () => {
  for (const prefix of ['', 'en/']) for (const [path, scene] of [['', 'voice'], ['guides/iphone-agent-voice-drafts/', 'voice'], ['guides/bluetooth-audio-input-troubleshooting/', 'audio'], ['guides/recording-notes-handoff/', 'voice'], ['guides/multi-project-radar-watch/', 'radar']]) {
    const html = read('dist/' + prefix + path + 'index.html');
    assert.equal([...html.matchAll(/data-preview=/g)].length, 1);
    assert.ok(html.includes('data-preview="' + scene + '"'));
    assert.ok(html.includes('class="preview-scenes"'));
    assert.ok(html.includes('aria-controls='));
    if (!path) assert.ok(html.indexOf('class="preview-scenes"') < html.indexOf('id="capabilities-title"'));
    if (path.includes('recording-notes')) assert.ok(html.includes(prefix ? 'no owner or deadline was agreed' : '还没约定负责人和时间'));
  }
});

test('retained practical help opens with an action, not internal lifecycle vocabulary', { skip: !hasBuild }, () => {
  for (const prefix of ['', 'en/']) for (const slug of ["vehicle-exhibition-microphone-preflight","outdoor-store-voice-preflight","voice-workbench-vs-radio-chat","offline-workbench-handoff-troubleshooting","noisy-transcript-text-correction","first-trial-go-no-go-checklist"]) {
    const html = read('dist/' + prefix + 'guides/' + slug + '/index.html');
    assert.ok(urls.includes('https://getyihu.com/' + prefix + 'guides/' + slug + '/'));
    const answer = html.match(/id="first-answer"[^>]*>[^<]*<\/h2>\s*<p>([\s\S]*?)<\/p>/)?.[1];
    assert.ok(answer, slug);
    assert.ok(!/activeToken|queued|endOfStream|source_refreshing|source_refresh_failed|request_id/.test(answer), slug);
    assert.ok(html.includes('href="/' + prefix + 'start/"'));
  }
});
test('same-task buyer comparisons and three-case brief instructions are bilingual', { skip: !hasBuild }, () => {
  for (const prefix of ['', 'en/']) {
    for (const slug of ['iphone-agent-voice-drafts', 'recording-notes-handoff']) assert.ok(read('dist/' + prefix + 'guides/' + slug + '/index.html').includes('id="same-task"'));
    assert.ok(read('dist/' + prefix + 'guides/multi-project-radar-watch/index.html').includes('id="case-guide"'));
  }
});
