import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const notes = 'recording-notes-handoff';
const guides = [
  ['note-radar-draft-candidate-preflight', notes, /eligible=false.*submitted=false/s, /(?:本地筛选.*可以回复|local filters.*replies are allowed)/],
  ['note-removal-retention-boundaries', notes, /recordingID.*deleted.*try\?/s, /(?:不能证明文件已擦除.*不会撤回|doesn’t prove disk erasure or recall)/],
  ['note-segment-join-provenance', notes, /28.*1600.*ASCII/s, /ASCII.*(?:空格不证明原话|isn’t evidence of the original wording)/],
];
const store = JSON.parse(read('src/data/app-store.json'));
const discovery = ['sitemap.xml', 'llms.txt', 'llms-full.txt'].map(name => read(`public/${name}`));

for (const prefix of ['', 'en/']) for (const [slug, pillar, boundary, summary] of guides) {
  test(`Wave16B ${prefix || 'zh'} ${slug}: first answer, privacy and trial handoff`, () => {
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
    const excerpt = discovery[1].split(`](${canonical})\n\n`)[1]?.split('\n\n')[0];
    assert.match(excerpt ?? '', summary);
  });
}
