import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['noisy-transcript-text-correction', 'department-minutes-ownership-archive', 'radar-evidence-second-check'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave8 six guides provide first answers, semantic tables, FAQs, source references and valid local links', { skip: !built }, () => {
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
test('correction, ownership and evidence checklists remain manual and preserve separate authorities', () => {
  for (const prefix of ['', 'en/']) {
    const correction = read('src/pages/' + prefix + 'guides/noisy-transcript-text-correction.md');
    assert.ok(correction.includes(prefix ? 'Retained text' : '原生保留文字'));
    assert.ok(correction.includes(prefix ? 'no cross-copy updater' : '不提供跨副本自动更新'));
    assert.ok(correction.includes(prefix ? 'Correction does not clear it' : '文本修订不取消既有状态'));
    const ownership = read('src/pages/' + prefix + 'guides/department-minutes-ownership-archive.md');
    for (const field of ['proposed_role', 'acknowledgment_evidence', 'approved_scope', 'archive_location', 'retention_rule_reference', 'handoff_state']) assert.ok(ownership.includes(field));
    assert.ok(ownership.includes(prefix ? 'not app/Radar imports' : '不是App、Radar导入'));
    assert.ok(ownership.includes(prefix ? 'Silence is not consent' : '不推断未回应者同意'));
    const evidence = read('src/pages/' + prefix + 'guides/radar-evidence-second-check.md');
    assert.ok(evidence.includes('safeEvidenceURLs') && evidence.includes('example.invalid'));
    assert.ok(evidence.includes(prefix ? 'does not verify reputation' : '不是站点信誉'));
    assert.ok(evidence.includes(prefix ? 'does not detect prompt injection' : '不会检测提示注入'));
    assert.ok(evidence.includes(prefix ? 'not a detector' : '不是检测器'));
  }
});
