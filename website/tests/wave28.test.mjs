import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["focused-editable-admission-review","recognition-error-layer-review","list-preview-not-transcript-archive"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave28 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('editable scope, error categories and preview truncation do not establish authority or lost originals', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const dom = guide('focused-editable-admission-review');
    for (const item of ['forMainFrameOnly', 'readOnly', 'canInsert', 'contenteditable']) assert.ok(dom.includes(item));
    assert.ok(dom.includes(prefix ? 'Focus is one prerequisite' : '有焦点只是一项条件'));
    const errors = guide('recognition-error-layer-review');
    for (const item of ['captureFailure', 'microphonePermission', 'emptyTranscript']) assert.ok(errors.includes(item));
    assert.ok(errors.includes(prefix ? 'not complete diagnosis' : '不是完整底层诊断'));
    const preview = guide('list-preview-not-transcript-archive');
    for (const item of ['displayName', 'prefix(40)', 'lineLimit(2)', 'fileName']) assert.ok(preview.includes(item));
    assert.ok(preview.includes(prefix ? 'neither proves automatic minutes, redaction' : '不是自动纪要、隐私脱敏'));
  }
});
