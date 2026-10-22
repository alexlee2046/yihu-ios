import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["file-chunk-bridge-not-upload-receipt","recognition-pass-parameter-budget","attachment-name-metadata-provenance"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave27 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('chunk transfer, pass snapshots and case-insensitive names do not certify delivery, accuracy or revisions', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const chunks = guide('file-chunk-bridge-not-upload-receipt');
    for (const item of ['768 KiB', 'parts', 'File', 'attached']) assert.ok(chunks.includes(item));
    assert.ok(chunks.includes(prefix ? 'not remote completion or sending' : '不是远端完成或消息发送回执'));
    const pass = guide('recognition-pass-parameter-budget');
    for (const item of ['448', '64', '1024', 'usesTerms', 'maxTokens', 'contextTerms']) assert.ok(pass.includes(item));
    assert.ok(pass.includes(prefix ? 'does not directly improve accuracy' : '不直接证明准确率'));
    const names = guide('attachment-name-metadata-provenance');
    for (const item of ['uniqueName', 'usedNames', 'contentType', 'byteCount', 'SAMPLE 2.TXT']) assert.ok(names.includes(item));
    assert.ok(names.includes(prefix ? 'case-insensitively' : '不区分大小写检测命名冲突'));
  }
});
