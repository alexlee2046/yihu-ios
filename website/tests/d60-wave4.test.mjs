import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const slugs = ['empty-field-display-defaults', 'audio-level-not-accuracy-review', 'foreground-audio-rebind-preflight'];
const store = JSON.parse(read('src/data/app-store.json'));
const forbidden = new RegExp(['SYNTHETIC_' + 'EXAMPLE', 'not_' + 'run', 'SYN' + '-'].join('|'));

test('Wave4 keeps two-worker test execution and clean 150-route reading exports', () => {
  assert.equal(JSON.parse(read('package.json')).scripts.test, 'node --test --test-concurrency=2 tests/*.test.mjs');
  assert.equal((read('public/sitemap.xml').match(/<loc>/g) || []).length, 150);
  for (const name of ['llms.txt', 'llms-full.txt']) {
    const content = read('public/' + name);
    assert.ok(!forbidden.test(content));
    assert.equal(read('dist/' + name), content);
    for (const prefix of ['', 'en/']) for (const slug of slugs) {
      assert.ok(content.includes(`https://getyihu.com/${prefix}guides/${slug}/`));
    }
  }
});

for (const prefix of ['', 'en/']) for (const slug of slugs) {
  test(`Wave4 ${prefix || 'zh'} ${slug} keeps an actionable first answer and trial/privacy/store entry`, () => {
    const source = read(`src/pages/${prefix}guides/${slug}.md`);
    const html = read(`dist/${prefix}guides/${slug}/index.html`);
    assert.ok(!forbidden.test(source) && !forbidden.test(html));
    assert.ok(source.includes('privacyPreview: true'));
    assert.ok(!html.includes('content="noindex,follow"'));
    assert.ok(html.includes(`rel="canonical" href="https://getyihu.com/${prefix}guides/${slug}/"`));
    assert.ok(html.includes('hreflang="en"') && html.includes('hreflang="zh-CN"'));
    assert.equal((html.match(/<h1\b/g) || []).length, 1);
    const answer = html.match(/id="first-answer"[^>]*>([^<]+)<\/h2>\s*<p>([\s\S]*?)<\/p>/);
    assert.ok(answer && answer[2].length > 60);
    assert.match(answer[1], prefix ? /Check|Replay/ : /先/);
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)[0];
    const pillar = slug === 'empty-field-display-defaults' ? 'multi-project-radar-watch' : 'bluetooth-audio-input-troubleshooting';
    assert.ok(block.includes(`href="/${prefix}guides/${pillar}/#interactive-preview"`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes('<details class="privacy-preview" id="privacy-preview">'));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(block.includes(prefix ? 'installed version' : '已安装版本'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    assert.ok(!html.includes('<astro-island'), 'reference pages link to the existing preview instead of adding an island');
    assert.ok(!block.includes('GSC'));
  });
}
