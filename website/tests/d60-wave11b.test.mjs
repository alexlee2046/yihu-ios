import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const guides = [
  ['note-audio-text-evidence-mapping', 'recording-notes-handoff', /transcribedFrames.*emptyTranscript.*done/s],
  ['reply-draft-restoration-scope', 'iphone-agent-voice-drafts', /submitted=false/],
  ['radar-summary-claim-provenance', 'multi-project-radar-watch', /等待验收|waiting for acceptance/],
];
const exports = ['llms.txt', 'llms-full.txt'].map(name => read(`public/${name}`));
const store = JSON.parse(read('src/data/app-store.json'));

for (const prefix of ['', 'en/']) for (const [slug, destination, boundary] of guides) {
  test(`Wave11B ${prefix || 'zh'} ${slug}: first answer and local preview handoff`, () => {
    const path = `${prefix}guides/${slug}/`;
    const source = read(`src/pages/${path.slice(0, -1)}.md`);
    const html = read(`dist/${path}index.html`);
    const canonical = `https://getyihu.com/${path}`;
    const answer = source.match(/<h2 id="first-answer">[^<]+<\/h2>\n\n([^\n]+)/)?.[1];
    assert.ok(answer);
    assert.match(answer, boundary);
    const trial = source.match(/^trialLabel: "([^"]+)"$/m)?.[1];
    assert.ok(trial);
    const block = html.match(/<section\b[^>]*data-guide-conversion[^>]*>[\s\S]*?<\/section>/)?.[0];
    assert.ok(block?.includes(`href="/${prefix}guides/${destination}/#interactive-preview">${trial}</a>`));
    assert.ok(block.includes(`href="${store.url}"`));
    assert.ok(block.includes(`href="/${prefix}privacy/"`));
    assert.ok(block.includes(prefix ? 'no login or microphone' : '无需登录或麦克风'));
    assert.ok(html.includes(`rel="canonical" href="${canonical}"`));
    assert.ok(!html.includes('<astro-island'));
    assert.ok(html.indexOf('data-guide-conversion') < html.indexOf('id="first-answer"'));
    assert.ok(exports.every(text => text.includes(canonical)));
  });
}
