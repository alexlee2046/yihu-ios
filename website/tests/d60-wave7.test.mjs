import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const slugs = ['voice-workbench-vs-radio-chat', 'multi-project-radar-watch', 'outdoor-store-voice-preflight'];
const store = JSON.parse(read('src/data/app-store.json'));
const forbidden = new RegExp(['SYNTHETIC_' + 'EXAMPLE', 'not_' + 'run', 'SYN' + '-'].join('|'));

test('Wave7 preserves two-worker tests, 150-route discovery and clean reading exports', () => {
  assert.equal(JSON.parse(read('package.json')).scripts.test, 'node --test --test-concurrency=2 tests/*.test.mjs');
  assert.equal((read('public/sitemap.xml').match(/<loc>/g) || []).length, 150);
  for (const name of ['llms.txt', 'llms-full.txt']) {
    const text = read('public/' + name);
    assert.ok(!forbidden.test(text));
    assert.equal(read('dist/' + name), text);
    for (const prefix of ['', 'en/']) for (const slug of slugs) assert.ok(text.includes(`https://getyihu.com/${prefix}guides/${slug}/`));
  }
});

for (const prefix of ['', 'en/']) for (const slug of slugs) {
  test(`Wave7 ${prefix || 'zh'} ${slug} opens with actionable review, private trial and store entry`, () => {
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
    assert.match(answer[1], prefix ? /Choose|Check|Stop/ : /先/);
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)[0];
    const pillar = slug === 'multi-project-radar-watch' ? slug : slug === 'outdoor-store-voice-preflight' ? 'bluetooth-audio-input-troubleshooting' : 'iphone-agent-voice-drafts';
    assert.ok(block.includes(`href="/${prefix}guides/${pillar}/#interactive-preview"`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes('<details class="privacy-preview" id="privacy-preview">'));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(block.includes(prefix ? 'keeps edits only in the open page' : '编辑仅留在当前打开的页面'));
    assert.ok(block.includes(prefix ? 'browser’s voice service' : '浏览器语音服务'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    assert.equal((html.match(/data-preview=/g) || []).length, slug === 'multi-project-radar-watch' ? 1 : 0);
    if (slug === 'multi-project-radar-watch') {
      assert.ok(html.includes('data-preview="radar"') && html.includes('id="case-guide"'));
      assert.ok(source.includes('yyyy-MM-dd HH:mm') && source.includes('UTC+08:00'));
    } else assert.ok(!source.includes(prefix ? 'models/signing' : '准备模型与签名'));
    if (slug === 'outdoor-store-voice-preflight') assert.ok(source.includes(prefix ? 'Store installation needs no self-signing' : '商店安装无需自行签名'));
  });
}
