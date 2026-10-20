import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['export-encoding-delimiter-preflight', 'microphone-permission-sample-contract', 'batch-change-record-retention'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave13 guides keep bilingual structure, source references and reachable local links', { skip: !built }, () => {
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
test('synthetic JSON/UTF-8 examples and manual contract checks do not assert native conversion or archive features', () => {
  // Illustrative syntax/encoding checks only, not native App decoder or device acceptance.
  assert.equal(Array.from('样例A').length, 3);
  assert.equal(Buffer.byteLength('样例A', 'utf8'), 7);
  for (const prefix of ['', 'en/']) {
    const encoding = read('src/pages/' + prefix + 'guides/export-encoding-delimiter-preflight.md');
    const fixture = JSON.parse(encoding.match(/```json\n([\s\S]*?)\n```/)[1]);
    assert.equal(fixture.title, 'Sample, A');
    assert.equal(fixture.next, 'Line1\nLine2');
    assert.equal(Object.hasOwn(fixture, 'decisions'), false);
    assert.ok(encoding.includes(prefix ? 'not a complete Radar snapshot' : '不是完整Radar快照'));
    assert.ok(encoding.includes('3000') && encoding.includes('Swift Character'));
    const permission = read('src/pages/' + prefix + 'guides/microphone-permission-sample-contract.md');
    assert.ok(permission.includes('16 kHz') && permission.includes('partial'));
    assert.ok(permission.includes(prefix ? 'No user downgrade-sampling switch' : '不提供降低采样率绕过检查'));
    const archive = read('src/pages/' + prefix + 'guides/batch-change-record-retention.md');
    for (const field of ['raw_batch_before', 'raw_batch_after', 'producer_revision', 'consumer_revision', 'comparison_rule', 'review_scope', 'decision_reference', 'archive_access']) assert.ok(archive.includes(field));
    assert.ok(archive.includes(prefix ? 'not Radar imports or an app archive API' : '不是Radar导入格式或App归档API'));
  }
});
