import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const slugs = ['degraded-handoff-go-no-go', 'follow-up-context-preflight', 'watch-voice-queued-ready-boundaries'];
const store = JSON.parse(read('src/data/app-store.json'));
const forbidden = new RegExp(['SYNTHETIC_' + 'EXAMPLE', 'not_' + 'run', 'SYN' + '-'].join('|'));

test('Wave9 preserves two-worker tests, 150-route discovery and retired Watch exclusion', () => {
  assert.equal(JSON.parse(read('package.json')).scripts.test, 'node --test --test-concurrency=2 tests/*.test.mjs');
  assert.equal((read('public/sitemap.xml').match(/<loc>/g) || []).length, 150);
  for (const name of ['llms.txt', 'llms-full.txt']) {
    const text = read('public/' + name);
    assert.ok(!forbidden.test(text));
    assert.equal(read('dist/' + name), text);
    for (const prefix of ['', 'en/']) for (const slug of slugs) {
      assert.equal(text.includes(`https://getyihu.com/${prefix}guides/${slug}/`), slug !== 'watch-voice-queued-ready-boundaries');
    }
  }
});

for (const prefix of ['', 'en/']) for (const slug of slugs) {
  test(`Wave9 ${prefix || 'zh'} ${slug} offers scoped action, private trial and store entry`, () => {
    const source = read(`src/pages/${prefix}guides/${slug}.md`);
    const html = read(`dist/${prefix}guides/${slug}/index.html`);
    assert.ok(source.includes('privacyPreview: true'));
    assert.ok(!forbidden.test(source) && !forbidden.test(html));
    const retired = slug === 'watch-voice-queued-ready-boundaries';
    assert.equal(html.includes('content="noindex,follow"'), retired);
    assert.equal(html.includes('hreflang="en"'), !retired);
    assert.ok(html.includes(`rel="canonical" href="https://getyihu.com/${prefix}guides/${slug}/"`));
    assert.equal((html.match(/<h1\b/g) || []).length, 1);
    const answer = html.match(/id="first-answer"[^>]*>([^<]+)<\/h2>\s*<p>([\s\S]*?)<\/p>/);
    assert.ok(answer && answer[2].length > 60);
    assert.match(answer[1], prefix ? /Check|Name/ : /先/);
    const label = source.match(/^trialLabel: "([^"]+)"$/m)?.[1];
    assert.ok(label && label.trim());
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)[0];
    const pillar = slug === 'degraded-handoff-go-no-go' ? 'recording-notes-handoff' : 'iphone-agent-voice-drafts';
    assert.ok(block.includes(`href="/${prefix}guides/${pillar}/#interactive-preview">${label}</a>`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes('<details class="privacy-preview" id="privacy-preview">'));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(block.includes(prefix ? 'keeps edits only in the open page' : '编辑仅留在当前打开的页面'));
    assert.ok(block.includes(prefix ? 'browser’s voice service' : '浏览器语音服务'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    assert.ok(!html.includes('<astro-island'));
    if (retired) {
      for (const field of ['receiveVoice', 'queued', 'ready', '176000', 'sourceToken', 'taskToken']) assert.ok(source.includes(field));
      assert.ok(source.includes(prefix ? 'not a phone reply draft or web insertion' : '不是phone reply草稿或网页插入'));
    }
    if (slug === 'follow-up-context-preflight') assert.ok(source.includes(prefix ? 'no universal Agent backend' : '不提供通用Agent后端'));
    if (slug === 'degraded-handoff-go-no-go') {
      assert.ok(source.includes(prefix ? 'not clinical handover' : '不是医疗交班'));
      assert.ok(source.includes(prefix ? 'in an emergency' : '紧急情况不要等待'));
      assert.ok(source.includes('/samples/p34-older-adult-follow-up/checklist.'));
    }
  });
}
