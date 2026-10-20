import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["host-bridge-outcome-boundaries","audio-busy-state-admission","history-generation-receipt-priority"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave25 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('bridge states, local busy gates and history generations are not delivery or global authority', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const bridge = guide('host-bridge-outcome-boundaries');
    for (const item of ['collieBridgeScript', 'accepted', 'refused', 'unavailable', 'defaultPrevented']) assert.ok(bridge.includes(item));
    assert.ok(bridge.includes(prefix ? 'only for explicit unavailable' : '只有明确unavailable'));
    const busy = guide('audio-busy-state-admission');
    for (const item of ['primaryActionEnabled', 'canCancel', 'canRecord', 'canTranscribe', 'pendingTranscript']) assert.ok(busy.includes(item));
    assert.ok(busy.includes(prefix ? 'not global concurrency/latency certification' : '不是全局并发安全或延迟SLA'));
    const history = guide('history-generation-receipt-priority');
    for (const item of ['historyGeneration', 'historyActive', 'cancelHistory', 'recorded']) assert.ok(history.includes(item));
    assert.ok(history.includes(prefix ? 'not server recall' : '不是服务器撤回'));
  }
});
