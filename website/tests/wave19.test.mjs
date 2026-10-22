import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["reply-transport-budget-preflight","voiceprint-filter-not-authorization","status-alias-approval-boundaries"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave19 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('transport budgets, convenience voiceprints and display aliases do not imply business approval', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const transport = guide('reply-transport-budget-preflight');
    for (const item of ['20000', '40000', '128 KiB', 'Content-Length', 'pending']) assert.ok(transport.includes(item));
    assert.ok(transport.includes(prefix ? 'does not establish that nothing was recorded' : '不证明服务端从未记录'));
    const voiceprint = guide('voiceprint-filter-not-authorization');
    for (const item of ['match', 'bypass', 'unavailable', '0.70', '16000']) assert.ok(voiceprint.includes(item));
    assert.ok(voiceprint.includes(prefix ? 'not authentication' : '不是认证'));
    const status = guide('status-alias-approval-boundaries');
    for (const item of ['pending', 'waiting', 'done', 'unknown']) assert.ok(status.includes(item));
    assert.ok(status.includes(prefix ? 'not a source rewrite' : '不是源状态改写'));
  }
});
