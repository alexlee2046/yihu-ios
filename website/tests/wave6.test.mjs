import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['web-read-aloud-microphone-boundaries', 'multi-note-review-handoff', 'radar-json-null-validation'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave6 six built pages carry new task boundaries, semantic tables, FAQs and local links', { skip: !built }, () => {
  for (const prefix of ['', 'en/']) {
    const home = read('dist/' + prefix + 'index.html');
    for (const slug of slugs) {
      assert.ok(home.includes('id="scenarios"'), 'homepage offers the approved scenario hub, not an exhaustive guide wall');
      const html = read('dist/' + prefix + 'guides/' + slug + '/index.html');
      assert.ok(html.includes('id="first-answer"'));
      assert.equal(Array.from(html.matchAll(/<h1\b/g)).length, 1);
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
    const voice = read('dist/' + prefix + 'guides/web-read-aloud-microphone-boundaries/index.html');
    assert.ok(voice.includes('WebKit') && voice.includes('TTS'));
    assert.ok(voice.includes(prefix ? 'not universal acceptance' : '不等于所有站点'));
    const notes = read('dist/' + prefix + 'guides/multi-note-review-handoff/index.html');
    assert.ok(notes.includes(prefix ? 'not automatic merging' : '不等于App已经提供自动合并'));
    assert.ok(notes.includes(prefix ? 'three versus two' : '三项/两项'));
  }
});
test('bilingual JSON examples are synthetic typed samples, not a Swift decoder acceptance test', () => {
  for (const prefix of ['', 'en/']) {
    const text = read('src/pages/' + prefix + 'guides/radar-json-null-validation.md');
    const blocks = Array.from(text.matchAll(/```json\n([\s\S]*?)\n```/g));
    assert.equal(blocks.length, 1);
    const sample = JSON.parse(blocks[0][1]);
    assert.equal(sample.date_str, '2026-10-18 09:00');
    for (const key of ['decisions', 'active', 'stale', 'cold']) assert.deepEqual(sample[key], []);
    assert.equal(sample.tasks.length, 1);
    const action = sample.tasks[0];
    for (const key of ['project', 'title', 'next', 'url']) assert.equal(typeof action[key], 'string');
    for (const key of ['status', 'priority', 'timestamp']) assert.equal(action[key], null);
    assert.equal(new URL(action.url).hostname, 'example.invalid');
    for (const key of ['reply_supported', 'source_refreshing', 'source_refresh_failed']) assert.equal(sample[key], false);
    // Contract examples of ?? fallback only; this is not a replacement model validator.
    assert.deepEqual(({ decisions: ['sample-pending'], tasks: null }).tasks ?? ['sample-pending'], ['sample-pending']);
    assert.deepEqual(({ decisions: ['sample-pending'], tasks: [] }).tasks ?? ['sample-pending'], []);
    assert.ok(text.includes('2 MiB'));
    assert.ok(text.includes(prefix ? 'do not replace actual-version Swift decoding' : '不能替代实际版本的Swift解码'));
    assert.ok(!text.includes('api.example.com'));
  }
});
