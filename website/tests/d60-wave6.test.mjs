import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const slugs = ['iphone-agent-voice-drafts', 'mobile-agent-decisions', 'multi-note-review-handoff'];
const store = JSON.parse(read('src/data/app-store.json'));
const forbidden = new RegExp(['SYNTHETIC_' + 'EXAMPLE', 'not_' + 'run', 'SYN' + '-'].join('|'));

test('Wave6 keeps clean 150-route exports and two-worker test execution', () => {
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
  test(`Wave6 ${prefix || 'zh'} ${slug} offers actionable review and privacy/trial/store entry`, () => {
    const html = read(`dist/${prefix}guides/${slug}/index.html`);
    const source = read(`src/pages/${prefix}guides/${slug}.${slug === 'multi-note-review-handoff' ? 'md' : 'astro'}`);
    assert.ok(!forbidden.test(source) && !forbidden.test(html));
    assert.ok(!html.includes('content="noindex,follow"'));
    assert.ok(html.includes(`rel="canonical" href="https://getyihu.com/${prefix}guides/${slug}/"`));
    assert.ok(html.includes('hreflang="en"') && html.includes('hreflang="zh-CN"'));
    assert.equal((html.match(/<h1\b/g) || []).length, 1);
    const answer = html.match(/id="first-answer"[^>]*>([^<]+)<\/h2>\s*<p[^>]*>([\s\S]*?)<\/p>/);
    assert.ok(answer && answer[2].length > 60);
    assert.match(answer[1], prefix ? /Check|Choose|Keep/ : /先/);
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)[0];
    const pillar = slug === 'multi-note-review-handoff' ? 'recording-notes-handoff' : slug === 'mobile-agent-decisions' ? 'multi-project-radar-watch' : slug;
    assert.ok(block.includes(`href="/${prefix}guides/${pillar}/#interactive-preview"`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes('id="privacy-preview"'));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(block.includes(prefix ? 'installed version' : '已安装版本'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    assert.equal((html.match(/data-preview=/g) || []).length, slug === 'iphone-agent-voice-drafts' ? 1 : 0);
    if (slug === 'mobile-agent-decisions') {
      assert.ok(html.includes('id="synthetic-json"'));
      assert.match(read('src/components/MobileDecisionsGuide.astro'), /"reply_supported": false/);
      assert.ok(html.includes(prefix ? 'same request' : '同一次请求'));
    }
    if (slug === 'multi-note-review-handoff') assert.ok(html.includes(prefix ? 'adds no automatic merging' : '不新增自动合并'));
  });
}
