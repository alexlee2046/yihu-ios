import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const slugs = ['first-trial-go-no-go-checklist', 'bluetooth-audio-input-troubleshooting', 'app-group-inbox-access-evidence'];
const store = JSON.parse(read('src/data/app-store.json'));
const forbidden = new RegExp(['SYNTHETIC_' + 'EXAMPLE', 'not_' + 'run', 'SYN' + '-'].join('|'));

test('Wave3 clean bilingual reading exports match their built public copies', () => {
  for (const name of ['llms.txt', 'llms-full.txt']) {
    const source = read('public/' + name);
    assert.equal(read('dist/' + name), source);
    assert.ok(!forbidden.test(source), name);
    for (const prefix of ['', 'en/']) for (const slug of slugs) {
      const url = `https://getyihu.com/${prefix}guides/${slug}/`;
      assert.equal(source.includes(url), slug !== 'app-group-inbox-access-evidence', url);
    }
  }
});

for (const prefix of ['', 'en/']) for (const slug of slugs) {
  test(`Wave3 ${prefix || 'zh'} ${slug} opens with same-language trial, download and privacy`, () => {
    const source = read(`src/pages/${prefix}guides/${slug}.md`);
    const html = read(`dist/${prefix}guides/${slug}/index.html`);
    assert.ok(!forbidden.test(source));
    assert.ok(!forbidden.test(html));
    assert.ok(source.includes('privacyPreview: true'));
    assert.match(source, /^description: ".{60,}"$/m);
    assert.match(html, /<title>[^<]+<\/title>/);
    assert.ok(html.includes(`rel="canonical" href="https://getyihu.com/${prefix}guides/${slug}/"`));
    const retired = slug === 'app-group-inbox-access-evidence';
    assert.equal(html.includes('content="noindex,follow"'), retired);
    assert.equal(html.includes('hreflang="en"'), !retired);
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)[0];
    const pillar = slug === 'bluetooth-audio-input-troubleshooting' ? slug : 'iphone-agent-voice-drafts';
    assert.ok(block.includes(`href="/${prefix}guides/${pillar}/#interactive-preview"`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes('id="privacy-preview"'));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(block.includes(prefix ? 'installed version' : '已安装版本'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    assert.equal((html.match(/data-preview=/g) || []).length, slug === 'bluetooth-audio-input-troubleshooting' ? 1 : 0);
    if (slug === 'bluetooth-audio-input-troubleshooting') {
      assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="interactive-preview"'));
      assert.ok(html.includes(prefix ? 'while parked' : '停车'));
    }
    assert.ok(!block.includes('27'));
  });
}
