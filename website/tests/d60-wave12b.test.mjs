import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const pillar = 'bluetooth-audio-input-troubleshooting';
const guides = [
  [pillar, false, /手机麦克风|phone mic/],
  ['audio-recovery-debounce-boundaries', true, /expectedToken.*deadline/s],
  ['capture-buffer-pressure-checklist', false, /bufferOverflow.*snapshot/s],
];
const store = JSON.parse(read('src/data/app-store.json'));
const discovery = ['sitemap.xml', 'llms.txt', 'llms-full.txt'].map(name => read(`public/${name}`));

for (const prefix of ['', 'en/']) for (const [slug, reference, boundary] of guides) {
  test(`Wave12B ${prefix || 'zh'} ${slug}: audio trial, safe first answer and discovery`, () => {
    const path = `${prefix}guides/${slug}/`;
    const canonical = `https://getyihu.com/${path}`;
    const source = read(`src/pages/${path.slice(0, -1)}.md`);
    const html = read(`dist/${path}index.html`);
    const answer = source.match(/<h2 id="first-answer">[^<]+<\/h2>([\s\S]+?)(?=\n## |\n<aside)/)?.[1];
    assert.match(answer ?? '', boundary);
    const trial = source.match(/^trialLabel: "([^"]+)"$/m)?.[1];
    assert.ok(trial);
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)?.[0];
    assert.ok(block?.includes(`href="/${prefix}guides/${pillar}/#interactive-preview">${trial}</a>`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(html.includes(`rel="canonical" href="${canonical}"`));
    assert.equal(html.includes('content="noindex,follow"'), reference);
    assert.equal(html.includes('<astro-island'), slug === pillar);
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    for (const text of discovery) assert.equal(text.includes(canonical), !reference);
  });
}
