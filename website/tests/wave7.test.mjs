import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['first-trial-go-no-go-checklist', 'recording-segment-review-labels', 'radar-snapshot-batch-comparison'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave7 six guides have first answers, tables, six FAQs, source evidence and reachable local links', { skip: !built }, () => {
  for (const prefix of ['', 'en/']) {
    const home = read('dist/' + prefix + 'index.html');
    for (const slug of slugs) {
      assert.ok(home.includes('id="scenarios"'), 'homepage offers the approved scenario hub, not an exhaustive guide wall');
      const html = read('dist/' + prefix + 'guides/' + slug + '/index.html');
      assert.equal(Array.from(html.matchAll(/<h1\b/g)).length, 1);
      assert.ok(html.includes('id="first-answer"'));
      assert.equal(Array.from(html.matchAll(/id="faq-[^"]+"/g)).length, 6);
      assert.ok(html.includes('<table') && html.includes('<thead>') && html.includes('<tbody>'));
      assert.ok(html.includes('tabindex="0"'));
      assert.ok(html.includes('github.com/alexlee2046/yihu-ios/blob/a59676a'));
      assert.ok(html.includes(`href="/${prefix}start/"`) && html.includes(`href="/${prefix}privacy/"`));
      for (const link of html.matchAll(/href="(\/[^"#?]*)(?:[?#][^"]*)?"/g)) {
        const path = 'dist' + link[1] + (link[1].endsWith('/') ? 'index.html' : '');
        assert.ok(existsSync(new URL(path, root)), path);
      }
    }
  }
});
test('new tasks retain timebox, manual-label and source-scope limits instead of claiming app features', () => {
  for (const prefix of ['', 'en/']) {
    const trial = read('src/pages/' + prefix + 'guides/first-trial-go-no-go-checklist.md');
    assert.ok(trial.includes(prefix ? 'not a setup or performance promise' : '不承诺五分钟装好或接通'));
    assert.ok(trial.includes(prefix ? 'not an app configuration/import format' : '不是App的配置导入格式'));
    const segments = read('src/pages/' + prefix + 'guides/recording-segment-review-labels.md');
    assert.ok(segments.includes(prefix ? 'not native timestamps' : '不是App时间戳'));
    assert.ok(segments.includes('28') && segments.includes(prefix ? 'eight seconds' : '末8秒'));
    assert.ok(segments.includes(prefix ? 'Do not compress' : '不能把A和B缩写'));
    const batches = read('src/pages/' + prefix + 'guides/radar-snapshot-batch-comparison.md');
    for (const term of ['date_str', 'tasks', 'decisions', 'sample-A', 'sample-B', 'null']) assert.ok(batches.includes(term));
    assert.ok(batches.includes(prefix ? 'not a Radar import format' : '不是Radar导入格式'));
    assert.ok(batches.includes(prefix ? 'deletion unproven' : '未证明删除'));
    assert.ok(batches.includes(prefix ? 'snapshot version history' : '完整快照版本历史'));
  }
});
