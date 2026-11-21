import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const audio = 'bluetooth-audio-input-troubleshooting';
const guides = [
  ['interruption-recapture-preflight', audio, /只另录缺失部分|only that passage/],
  ['microphone-permission-sample-contract', audio, /16 kHz/],
  ['multilingual-terms-preflight', 'iphone-agent-voice-drafts', /80.{0,20}40/],
];
const store = JSON.parse(read('src/data/app-store.json'));
const discovery = ['sitemap.xml', 'llms.txt', 'llms-full.txt'].map(name => read(`public/${name}`));

for (const prefix of ['', 'en/']) for (const [slug, pillar, boundary] of guides) {
  test(`Wave13B ${prefix || 'zh'} ${slug}: first answer, privacy and trial handoff`, () => {
    const path = `${prefix}guides/${slug}/`;
    const canonical = `https://getyihu.com/${path}`;
    const source = read(`src/pages/${path.slice(0, -1)}.md`);
    const html = read(`dist/${path}index.html`);
    const answer = source.match(/<h2 id="first-answer">[^<]+<\/h2>([\s\S]+?)\n## /)?.[1];
    assert.match(answer ?? '', boundary);
    const label = source.match(/^trialLabel: "([^"]+)"$/m)?.[1];
    assert.ok(label);
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)?.[0];
    assert.ok(block?.includes(`href="/${prefix}guides/${pillar}/#interactive-preview">${label}</a>`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(html.includes(`rel="canonical" href="${canonical}"`));
    assert.ok(!html.includes('content="noindex,follow"'));
    assert.ok(!html.includes('<astro-island'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    assert.ok(discovery.every(text => text.includes(canonical)));
  });
}
