import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = path => readFileSync(new URL('../' + path, import.meta.url), 'utf8');
const radar = 'multi-project-radar-watch';
const guides = [
  ['radar-feed-url-boundary-preflight', radar, /HTTPS.*query.*fragment/s, /HTTPS.*(?:查询参数|queries)/],
  ['radar-json-null-validation', radar, /null.*tasks|tasks.*null/s, /null.*(?:空数组|empty arrays)/],
  ['radar-snapshot-batch-comparison', radar, /本批未见|not seen in that batch/, /(?:来源.*范围|source, scope).*(?:删除|deletion)/],
];
const store = JSON.parse(read('src/data/app-store.json'));
const discovery = ['sitemap.xml', 'llms.txt', 'llms-full.txt'].map(name => read(`public/${name}`));

for (const prefix of ['', 'en/']) for (const [slug, pillar, boundary, summary] of guides) {
  test(`Wave15B ${prefix || 'zh'} ${slug}: first answer, privacy and trial handoff`, () => {
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
