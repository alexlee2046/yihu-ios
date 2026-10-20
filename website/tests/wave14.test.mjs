import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['empty-field-display-defaults', 'foreground-audio-rebind-preflight', 'multi-role-approval-receipt-checklist'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave14 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('placeholders, foreground callbacks and editorial roles do not imply source repair, continuity or delegated authority', () => {
  for (const prefix of ['', 'en/']) {
    const defaults = read('src/pages/' + prefix + 'guides/empty-field-display-defaults.md');
    for (const field of ['status', 'priority', 'next', 'reply_supported', 'transcript']) assert.ok(defaults.includes(field));
    assert.ok(defaults.includes(prefix ? 'No default-value fixer' : '不提供默认值修复器'));
    const lifecycle = read('src/pages/' + prefix + 'guides/foreground-audio-rebind-preflight.md');
    for (const state of ['inactive', 'background', 'preparing', 'applicationDidBecomeActive', 'resumeTranscription']) assert.ok(lifecycle.includes(state));
    assert.ok(lifecycle.includes(prefix ? 'late permission responses' : '迟到许可结果'));
    assert.ok(lifecycle.includes(prefix ? 'not a promise' : '不是App承诺'));
    const roles = read('src/pages/' + prefix + 'guides/multi-role-approval-receipt-checklist.md');
    for (const field of ['approval_reference', 'content_scope', 'actor_role', 'recipient_confirmation', 'remaining_unknowns']) assert.ok(roles.includes(field));
    assert.ok(roles.includes(prefix ? 'not JSON imports, authorization parameters or a native approval API' : '不是导入JSON、授权参数或原生审批API'));
    assert.ok(roles.includes(prefix ? 'through explicit references' : '按明确引用'));
  }
});
