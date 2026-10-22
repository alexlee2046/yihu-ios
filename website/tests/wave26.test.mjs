import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["keyboard-acknowledgement-scope","note-transcription-retry-checkpoint","privacy-declaration-evidence-scope"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave26 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('keyboard intent, retry positions and privacy declarations do not substitute for runtime evidence', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const keyboard = guide('keyboard-acknowledgement-scope');
    for (const item of ['keyboardRequest', 'enqueueKeyboard', 'keyboardEnabled', 'keyboardVisible']) assert.ok(keyboard.includes(item));
    assert.ok(keyboard.includes(prefix ? 'before awaiting' : '再等enqueueKeyboard'));
    const retry = guide('note-transcription-retry-checkpoint');
    for (const item of ['transcribedFrames', 'transcript', 'pending', 'retry', 'handOffAttempted']) assert.ok(retry.includes(item));
    assert.ok(retry.includes(prefix ? 'without clearing transcript/transcribedFrames' : '未在此清空transcript或transcribedFrames'));
    const privacy = guide('privacy-declaration-evidence-scope');
    for (const item of ['NSPrivacyAccessedAPITypes', 'CA92.1', 'C617.1', 'Info.plist']) assert.ok(privacy.includes(item));
    assert.ok(privacy.includes(prefix ? 'not audits of every runtime entry' : '不是运行时所有入口'));
  }
});
