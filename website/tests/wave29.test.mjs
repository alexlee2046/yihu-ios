import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["navigation-cancel-process-reload-boundaries","watch-voice-queued-ready-boundaries","app-group-inbox-access-evidence"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave29 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('navigation guards, Watch result stages and group declarations do not certify recovery or authority', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const nav = guide('navigation-cancel-process-reload-boundaries');
    for (const item of ['isSupersededNavigation', 'NSURLErrorDomain', 'WebKitErrorDomain', '500', '15']) assert.ok(nav.includes(item));
    assert.ok(nav.includes(prefix ? 'do not guarantee network, draft or service-action recovery' : '不是网络、草稿或服务动作恢复保证'));
    const watch = guide('watch-voice-queued-ready-boundaries');
    for (const item of ['receiveVoice', 'queued', 'ready', '176000', 'sourceToken', 'taskToken']) assert.ok(watch.includes(item));
    assert.ok(watch.includes(prefix ? 'not a phone reply draft or web insertion' : '不是phone reply草稿或网页插入'));
    const group = guide('app-group-inbox-access-evidence');
    for (const item of ['YIHU_APP_GROUP', 'YihuAppGroup', 'containerURL', 'com.apple.security.application-groups']) assert.ok(group.includes(item));
    assert.ok(group.includes(prefix ? 'not signed entitlement or real-device access' : '不证明产物签名权限或真实设备可访问'));
  }
});
