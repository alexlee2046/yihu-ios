import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["attention-filter-identity-boundaries","pcm-stream-end-boundaries","share-manifest-visibility-review"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave23 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('attention matches, stream endings and manifests retain display/local evidence scope', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const attention = guide('attention-filter-identity-boundaries');
    for (const item of ['requiresMyAttention', 'next', 'Alex', 'matchingActions']) assert.ok(attention.includes(item));
    assert.ok(attention.includes(prefix ? 'does not read the signed-in account' : '没有在这个getter中读取当前登录账户'));
    const stream = guide('pcm-stream-end-boundaries');
    for (const item of ['noDataNow', 'endOfStream', 'finish', '16']) assert.ok(stream.includes(item));
    assert.ok(stream.includes(prefix ? 'not file transcoding' : '不是文件转码工具'));
    const manifest = guide('share-manifest-visibility-review');
    for (const item of ['manifest.json', 'pending', '3600', 'distantPast']) assert.ok(manifest.includes(item));
    assert.ok(manifest.includes(prefix ? 'not a minimum hour after creation' : '不是从创建起至少保留一小时'));
  }
});
