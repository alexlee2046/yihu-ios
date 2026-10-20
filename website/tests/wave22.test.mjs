import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["note-radar-draft-candidate-preflight","audio-recovery-debounce-boundaries","local-file-protection-scope"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave22 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('draft candidates, debounce windows and local options are not capability, SLA or certification', () => {
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const candidate = guide('note-radar-draft-candidate-preflight');
    for (const item of ['writableDraftCandidates', 'reply_supported', 'eligible=false', 'submitted=false', 'reserveHandOff']) assert.ok(candidate.includes(item));
    assert.ok(candidate.includes(prefix ? 'does not additionally establish reply_supported or freshness' : '不额外证明reply_supported或快照时效'));
    const debounce = guide('audio-recovery-debounce-boundaries');
    for (const item of ['expectedToken', 'deadline', 'gracePeriod']) assert.ok(debounce.includes(item));
    assert.ok(debounce.includes(prefix ? 'genuine same-route/format changes can be ignored' : '真实同路由/格式变化可能被忽略'));
    const protection = guide('local-file-protection-scope');
    for (const item of ['atomic', 'completeFileProtection', 'macOS']) assert.ok(protection.includes(item));
    assert.ok(protection.includes(prefix ? 'Absent explicit options do not prove plaintext' : '没有显式保护选项也不能直接宣布明文'));
  }
});
