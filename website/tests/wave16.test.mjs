import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["notification-payload-model-preflight","pcm-format-admission-review","reply-request-receipt-mapping"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave16 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('input-model, PCM prerequisites and recorded-state scopes remain distinct', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const payload = guide('notification-payload-model-preflight');
    for (const field of ['version', 'subscriptionId', 'eventKey', 'yihuRadar']) assert.ok(payload.includes(field));
    assert.ok(payload.includes(prefix ? 'A model alone does not establish' : '不能宣布订阅/推送/点击导航已完整接入'));
    const pcm = guide('pcm-format-admission-review');
    for (const field of ['8000', '192000', 'Float32', 'unsupportedFormat', 'conversionFailed']) assert.ok(pcm.includes(field));
    assert.ok(pcm.includes(prefix ? 'Creation/conversion can still fail' : '仍可能无法创建/转换'));
    const receipt = guide('reply-request-receipt-mapping');
    for (const field of ['request_id', 'requestID', 'epoch', 'recorded', 'absent']) assert.ok(receipt.includes(field));
    assert.ok(receipt.includes(prefix ? 'recorded is not executed' : 'recorded也不代表已执行'));
  }
});
