import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['brief-format-change-compatibility', 'degraded-handoff-go-no-go', 'handoff-evidence-audit-checklist'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave9 six guides have first answers, tables, FAQs, fixed-source evidence and valid local links', { skip: !built }, () => {
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
test('format revisions, fallback and auditing do not add schema migration, retries or compliance features', () => {
  for (const prefix of ['', 'en/']) {
    const format = read('src/pages/' + prefix + 'guides/brief-format-change-compatibility.md');
    for (const term of ['date_str', 'tasks', 'decisions', 'unconfirmed_proposals', 'confirmed_decisions']) assert.ok(format.includes(term));
    assert.ok(format.includes(prefix ? 'No schema negotiation' : '不新增schema版本协商'));
    const fallback = read('src/pages/' + prefix + 'guides/degraded-handoff-go-no-go.md');
    assert.ok(fallback.includes(prefix ? 'no offline outbox' : '没有新增离线待发箱'));
    assert.ok(fallback.includes(prefix ? 'Do not use attachments to bypass refusal' : '不能把附件路径当绕过拒绝的方法'));
    const audit = read('src/pages/' + prefix + 'guides/handoff-evidence-audit-checklist.md');
    assert.ok(audit.includes(prefix ? 'not a new app audit log' : '不是App新增审计日志'));
    assert.ok(audit.includes(prefix ? 'New operations do not prove old ones' : '新操作不能证明旧操作'));
    assert.ok(audit.includes(prefix ? 'neither legal certification' : '不提供法律认证'));
  }
});
