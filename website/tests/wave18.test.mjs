import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["radar-feed-url-boundary-preflight","near-field-policy-route-review","note-segment-join-provenance"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave18 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('feed URL, session preference and joining do not establish auth, route selection or word truth', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const feed = guide('radar-feed-url-boundary-preflight');
    for (const item of ['CollieRadarFeed', 'parseSafeEvidenceURLs', 'query', 'fragment', '65535']) assert.ok(feed.includes(item));
    assert.ok(feed.includes(prefix ? 'Passing feed shape proves neither authentication' : '通过源形态校验仍不证明认证'));
    assert.ok(feed.includes(prefix ? 'The port may be omitted; if explicitly specified' : '端口可省略，若显式指定'));
    const policy = guide('near-field-policy-route-review');
    for (const item of ['playAndRecord', 'voiceChat', 'mixWithOthers', 'allowBluetoothHFP']) assert.ok(policy.includes(item));
    assert.ok(policy.includes(prefix ? 'not successful hardware activation' : '不是当前硬件已成功启用'));
    const join = guide('note-segment-join-provenance');
    for (const item of ['28', '1600', 'ASCII', 'join', 'API V2']) assert.ok(join.includes(item));
    assert.ok(join.includes(prefix ? 'not semantic splitting' : '不是语义断句'));
  }
});
