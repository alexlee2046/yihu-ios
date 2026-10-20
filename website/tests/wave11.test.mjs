import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['follow-up-context-preflight', 'radar-summary-claim-provenance', 'vehicle-exhibition-microphone-preflight'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave11 bilingual guides preserve structure, fixed-source evidence and reachable links', { skip: !built }, () => {
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
test('context, provenance and pre-capture guidance avoid memory, summary-engine and noise-performance claims', () => {
  for (const prefix of ['', 'en/']) {
    const context = read('src/pages/' + prefix + 'guides/follow-up-context-preflight.md');
    assert.ok(context.includes(prefix ? 'no universal Agent backend' : '不提供通用Agent后端'));
    assert.ok(context.includes(prefix ? 'not backend context' : '不能互相替代'));
    const provenance = read('src/pages/' + prefix + 'guides/radar-summary-claim-provenance.md');
    for (const field of ['status', 'next', 'priority', 'date_str', 'evidence', 'tasks', 'decisions']) assert.ok(provenance.includes(field));
    assert.ok(provenance.includes(prefix ? 'adds no opportunity-summary engine' : '不由本文新增商机摘要引擎'));
    assert.ok(provenance.includes(prefix ? 'Reject sentence 1' : '句1不采用'));
    const external = read('src/pages/' + prefix + 'guides/vehicle-exhibition-microphone-preflight.md');
    assert.ok(external.includes(prefix ? 'Do not operate the phone while driving' : '不得在驾驶'));
    assert.ok(external.includes(prefix ? 'no high-noise test' : '没有高噪实测'));
    assert.ok(external.includes(prefix ? 'before starting' : '开始前'));
  }
});
