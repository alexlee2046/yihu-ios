import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['multilingual-terms-preflight', 'timezone-timestamp-review', 'carrier-redaction-archive-matrix'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave12 bilingual pages retain structural, source and local-link contracts', { skip: !built }, () => {
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
test('term/image limits and explicit-offset examples retain implementation scope, not feature certification', () => {
  assert.equal(new Date('2026-10-18T09:00:00+08:00').toISOString(), '2026-10-18T01:00:00.000Z');
  assert.equal(new Date('2026-10-18T00:30:00+08:00').toISOString(), '2026-10-17T16:30:00.000Z');
  for (const prefix of ['', 'en/']) {
    const terms = read('src/pages/' + prefix + 'guides/multilingual-terms-preflight.md');
    for (const term of ['80', '40', 'automatic', 'chinese', 'english']) assert.ok(terms.includes(term));
    assert.ok(terms.includes(prefix ? 'dropped, not truncated' : '丢弃而非截断'));
    const time = read('src/pages/' + prefix + 'guides/timezone-timestamp-review.md');
    for (const term of ['date_str', 'timestamp', 'sourceDate', 'capturedAt', 'UTC+08', '2026-10-17 16:30']) assert.ok(time.includes(term));
    assert.ok(time.includes(prefix ? 'not arbitrary ISO8601 acceptance' : '不等于任意ISO8601接受器'));
    const carrier = read('src/pages/' + prefix + 'guides/carrier-redaction-archive-matrix.md');
    for (const term of ['32 MiB', '128 MiB', '2048', 'CollieDiagnosticImage']) assert.ok(carrier.includes(term));
    assert.ok(carrier.includes(prefix ? 'not every file' : '不能扩展成对整个系统分享收件箱里所有文件'));
    assert.ok(carrier.includes(prefix ? 'not pixel-text redaction' : '不是去画面里的敏感文字'));
  }
});
