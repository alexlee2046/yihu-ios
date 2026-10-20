import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["workbench-origin-page-boundaries","replaceable-voice-preview-review","model-artifact-validation-evidence"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave24 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('origin, partials and asset verification do not establish permission, final speech or accuracy', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const origin = guide('workbench-origin-page-boundaries');
    for (const item of ['isTrusted', 'expectedPageURL', 'requestID', '443']) assert.ok(origin.includes(item));
    assert.ok(origin.includes(prefix ? 'not the same page, draft or operation authority' : '不是同页面、同草稿或已获得操作许可'));
    const preview = guide('replaceable-voice-preview-review');
    for (const item of ['onPartialText', 'bufferingNewest(1)', 'sessionID', 'previewUnavailable']) assert.ok(preview.includes(item));
    assert.ok(preview.includes(prefix ? 'complete replaceable strings' : '完整、可替换的部分文字'));
    const model = guide('model-artifact-validation-evidence');
    for (const item of ['isInstalled', 'SHA-256', 'loadIfNeeded', 'installGeneration']) assert.ok(model.includes(item));
    assert.ok(model.includes(prefix ? 'not directory existence alone' : '不只是检查目录存在'));
    assert.ok(model.includes(prefix ? 'reuse a loaded/warmed instance' : '可复用已加载/预热实例'));
  }
});
