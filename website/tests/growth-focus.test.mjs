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
