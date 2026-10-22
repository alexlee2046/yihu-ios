import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["share-batch-item-preflight","interruption-recapture-preflight","history-retrieval-manual-comparison"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave15 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('batch stages, recapture and history retain their limited meaning', () => {
  for (const prefix of ['', 'en/']) {
    const readGuide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const batch = readGuide('share-batch-item-preflight');
    assert.ok(batch.includes('itemCount'));
    assert.ok(batch.includes(prefix ? 'not per-item validation or atomic delivery' : '不是每条已校验或全有全无发送'));
    const recapture = readGuide('interruption-recapture-preflight');
    assert.ok(recapture.includes(prefix ? 'recording continues while locked' : '锁屏后继续录音'));
    assert.ok(recapture.includes(prefix ? 'not zero-loss' : '不是所有低电量'));
    const history = readGuide('history-retrieval-manual-comparison');
    for (const item of ['100', 'text_omitted']) assert.ok(history.includes(item));
    assert.ok(history.includes(prefix ? 'not a local full-archive search engine' : '不是本地全量归档搜索引擎'));
  }
});
