import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ['cross-device-field-presentation', 'audio-route-recovery-matrix', 'followup-evidence-minimization'];
const built = existsSync(new URL('dist/index.html', root));

test('Wave10 six guides include complete structural contracts and reachable contextual links', { skip: !built }, () => {
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
test('payload/recovery parameters are source limits, and minimization is not an app redaction feature', () => {
  for (const prefix of ['', 'en/']) {
    const fields = read('src/pages/' + prefix + 'guides/cross-device-field-presentation.md');
    for (const term of ['160', '80', '600', '50000', '200', 'sourceDate', 'capturedAt']) assert.ok(fields.includes(term));
    assert.ok(fields.includes(prefix ? 'not bandwidth, latency' : '不是网络吞吐、响应时间'));
    const audio = read('src/pages/' + prefix + 'guides/audio-route-recovery-matrix.md');
    for (const term of ['oldDeviceUnavailable', 'noSuitableRouteForCategory', 'CollieAudioRecorder.swift', 'CollieNoteRecorder.swift']) assert.ok(audio.includes(term));
    assert.ok(audio.includes(prefix ? 'two seconds' : '2秒'));
    assert.ok(audio.includes(prefix ? 'not reconnection latency' : '不是重连耗时'));
    const privacy = read('src/pages/' + prefix + 'guides/followup-evidence-minimization.md');
    assert.ok(privacy.includes('safeEvidenceURLs') && privacy.includes('example.invalid'));
    assert.ok(privacy.includes(prefix ? 'not a CRM' : '不是CRM'));
    assert.ok(privacy.includes(prefix ? 'not an automatic redactor' : '不是自动脱敏工具'));
    assert.ok(privacy.includes(prefix ? 'use fully synthetic' : '使用完全合成'));
  }
});
