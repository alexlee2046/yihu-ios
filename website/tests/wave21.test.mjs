import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["source-switch-cache-isolation","audio-level-not-accuracy-review","note-removal-retention-boundaries"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave21 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
  for (const prefix of ['', 'en/']) {
    const home = read('dist/' + prefix + 'index.html');
    for (const slug of slugs) {
      assert.ok(home.includes(`href="/${prefix}guides/${slug}/"`));
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
test('source fences, illustrative meters and removal lists preserve evidence limits', () => {
  // Arithmetic illustration only, not native audio or calibrated acoustic testing.
  const rms = Math.sqrt((0.1 ** 2 + (-0.1) ** 2) / 2);
  assert.ok(Math.abs(Math.min(1, rms * 2) - 0.2) < 1e-9);
  assert.equal(Math.min(1, rms * 12), 1);
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const source = guide('source-switch-cache-isolation');
    for (const item of ['sourceRevisions', 'watchSourceIdentity', 'project', 'priority']) assert.ok(source.includes(item));
    assert.ok(source.includes(prefix ? 'Client-local isolation counter' : '本机内部读取隔离计数'));
    const level = guide('audio-level-not-accuracy-review');
    for (const item of ['RMS', '0.1', '0.2', '1.2']) assert.ok(level.includes(item));
    assert.ok(level.includes(prefix ? 'not recognition confidence' : '不是识别置信度'));
    const remove = guide('note-removal-retention-boundaries');
    for (const item of ['recordingID', 'deleted', 'try?']) assert.ok(remove.includes(item));
    assert.ok(remove.includes(prefix ? 'not a permanent tombstone' : '不是永久墓碑'));
  }
});
