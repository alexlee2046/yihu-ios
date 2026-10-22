import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["watch-open-request-ui-boundaries","shortcut-toggle-request-lifetime","note-organization-prompt-not-minutes"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave30 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('open acknowledgement, Intent lifetime and organization prompts do not establish UI or business completion', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const open = guide('watch-open-request-ui-boundaries');
    for (const item of ['queued', 'openRequest', 'sourceToken', 'taskToken', 'nonce']) assert.ok(open.includes(item));
    assert.ok(open.includes(prefix ? 'does not prove the correct task appeared' : '不等手机已经显示正确事项'));
    const shortcut = guide('shortcut-toggle-request-lifetime');
    for (const item of ['ToggleVoiceInputIntent', 'pendingToggle', 'consumeToggle', '30', 'openAppWhenRun']) assert.ok(shortcut.includes(item));
    assert.ok(shortcut.includes(prefix ? 'rather than enqueue N actions' : '不是逐次计数队列'));
    const prompt = guide('note-organization-prompt-not-minutes');
    for (const item of ['instruction', 'transcript', 'Picker', 'Markdown', 'handOffAttempted']) assert.ok(prompt.includes(item));
    assert.ok(prompt.includes(prefix ? 'without rewriting stored transcript' : '不重写保存的transcript'));
  }
});
