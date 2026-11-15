import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const slugs = ['meeting-notes-brief-fields', 'recording-notes-handoff', 'offline-workbench-handoff-troubleshooting'];
const store = JSON.parse(read('src/data/app-store.json'));
const forbidden = new RegExp(['SYNTHETIC_' + 'EXAMPLE', 'not_' + 'run', 'SYN' + '-'].join('|'));

test('Wave5 preserves two-worker tests, 150-route discovery and clean reading exports', () => {
  assert.equal(JSON.parse(read('package.json')).scripts.test, 'node --test --test-concurrency=2 tests/*.test.mjs');
  assert.equal((read('public/sitemap.xml').match(/<loc>/g) || []).length, 150);
  for (const name of ['llms.txt', 'llms-full.txt']) {
    const text = read('public/' + name);
    assert.ok(!forbidden.test(text));
    assert.equal(read('dist/' + name), text);
    for (const prefix of ['', 'en/']) for (const slug of slugs) {
      assert.ok(text.includes(`https://getyihu.com/${prefix}guides/${slug}/`));
    }
  }
});

for (const prefix of ['', 'en/']) for (const slug of slugs) {
  test(`Wave5 ${prefix || 'zh'} ${slug} offers actionable notes, trial, privacy and store`, () => {
    const source = read(`src/pages/${prefix}guides/${slug}.md`);
    const html = read(`dist/${prefix}guides/${slug}/index.html`);
    assert.ok(source.includes('privacyPreview: true'));
    assert.ok(!forbidden.test(source) && !forbidden.test(html));
    assert.ok(!html.includes('content="noindex,follow"'));
    assert.ok(html.includes(`rel="canonical" href="https://getyihu.com/${prefix}guides/${slug}/"`));
    assert.ok(html.includes('hreflang="en"') && html.includes('hreflang="zh-CN"'));
    assert.equal((html.match(/<h1\b/g) || []).length, 1);
    const answer = html.match(/id="first-answer"[^>]*>([^<]+)<\/h2>\s*<p>([\s\S]*?)<\/p>/);
    assert.ok(answer && answer[2].length > 60);
    assert.match(answer[1], prefix ? /Check|Keep/ : /先/);
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)[0];
    const pillar = slug === 'offline-workbench-handoff-troubleshooting' ? 'iphone-agent-voice-drafts' : 'recording-notes-handoff';
    assert.ok(block.includes(`href="/${prefix}guides/${pillar}/#interactive-preview"`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes('<details class="privacy-preview" id="privacy-preview">'));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(block.includes(prefix ? 'installed version' : '已安装版本'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    const recording = slug === 'recording-notes-handoff';
    assert.equal((html.match(/data-preview=/g) || []).length, recording ? 1 : 0);
    if (recording) {
      assert.ok(html.includes('data-preview="voice"'));
      assert.ok(html.includes(prefix ? 'no owner or deadline was agreed' : '还没约定负责人和时间'));
      assert.ok(html.includes('id="compare"') && html.includes('id="same-task"'));
      assert.ok(!source.includes(prefix ? 'model/signing setup' : '先准备模型与签名'));
    }
    assert.ok(!block.includes('GSC'));
  });
}
