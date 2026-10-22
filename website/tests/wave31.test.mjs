import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["reminder-link-pending-origin-routing","voiceprint-enrollment-profile-version-review","notification-disable-unregister-pending"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave31 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('reminder links, enrollment versions and local disable retain their independent guards', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const link = guide('reminder-link-pending-origin-routing');
    for (const item of ['isHermesSessionURL', 'pendingURL', 'consumePendingURL', 'recentOrigins', 'isConnected']) assert.ok(link.includes(item), item);
    assert.ok(link.includes(prefix ? 'rather than added as servers' : '未知源会丢弃而不新建服务器'));
    const enrollment = guide('voiceprint-enrollment-profile-version-review');
    for (const item of ['32000', '16000', 'enrollmentPhraseCount', 'enrollmentIsConsistent', 'profileCaptureModeMatches', 'v1', 'v2']) assert.ok(enrollment.includes(item), item);
    assert.ok(enrollment.includes(prefix ? 'not arbitrary three-phrase import' : '并非任意三句都能导入'));
    const unbind = guide('notification-disable-unregister-pending');
    for (const item of ['unregisterPending', 'unbindPending', 'rotateUnregisteredBinding', 'installationId', 'Keychain']) assert.ok(unbind.includes(item), item);
    assert.ok(unbind.includes(prefix ? 'Marker writes can fail' : '标记写入有可能失败'));
  }
});
