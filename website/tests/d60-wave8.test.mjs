import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const slugs = ['first-trial-go-no-go-checklist', 'department-minutes-ownership-archive', 'offline-workbench-handoff-troubleshooting'];
const store = JSON.parse(read('src/data/app-store.json'));
const forbidden = new RegExp(['SYNTHETIC_' + 'EXAMPLE', 'not_' + 'run', 'SYN' + '-'].join('|'));

test('Wave8 keeps two-worker tests, 150 canonical routes and clean committed exports', () => {
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
  test(`Wave8 ${prefix || 'zh'} ${slug} has a task-specific trial and private review path`, () => {
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
    assert.match(answer[1], prefix ? /Preview|Check|Keep/ : /先/);
    const label = source.match(/^trialLabel: "([^"]+)"$/m)?.[1];
    assert.ok(label && label.trim());
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)[0];
    const pillar = slug === 'department-minutes-ownership-archive' ? 'recording-notes-handoff' : 'iphone-agent-voice-drafts';
    assert.ok(block.includes(`href="/${prefix}guides/${pillar}/#interactive-preview">${label}</a>`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes('<details class="privacy-preview" id="privacy-preview">'));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(block.includes(prefix ? 'keeps edits only in the open page' : '编辑仅留在当前打开的页面'));
    assert.ok(block.includes(prefix ? 'browser’s voice service' : '浏览器语音服务'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    assert.ok(!html.includes('<astro-island'), 'guides link to the existing preview instead of adding new islands');
    if (slug === 'department-minutes-ownership-archive') assert.ok(source.includes(prefix ? 'Silence is not consent' : '不推断未回应者同意'));
    if (slug === 'offline-workbench-handoff-troubleshooting') assert.ok(answer[2].includes(prefix ? 'same request' : '同一次请求'));
    if (slug === 'first-trial-go-no-go-checklist') assert.ok(answer[2].includes('950 MB'));
  });
}
