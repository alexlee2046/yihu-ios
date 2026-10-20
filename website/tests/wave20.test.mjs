import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["history-reference-integrity-review","capture-completion-token-review","reply-draft-restoration-scope"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave20 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('history association, completion tokens and local drafts retain limited evidence scope', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const history = guide('history-reference-integrity-review');
    for (const item of ['references', 'request_id', 'position', 'draft']) assert.ok(history.includes(item));
    assert.ok(history.includes(prefix ? 'not reading, completion or truth certification' : '不是已读、业务完成或真实性认证'));
    const audio = guide('capture-completion-token-review');
    for (const item of ['activeToken', 'captureCompleted', 'stop', 'cancel']) assert.ok(audio.includes(item));
    assert.ok(audio.includes(prefix ? 'not authentication' : '不是身份认证'));
    const draft = guide('reply-draft-restoration-scope');
    for (const item of ['submitted=false', 'requestID', 'target', 'prepare']) assert.ok(draft.includes(item));
    assert.ok(draft.includes(prefix ? 'missing/unclear state conservatively restores pending' : '缺失等情况保守按待核处理'));
  }
});
