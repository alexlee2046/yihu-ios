import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const slugs = ["evidence-link-admission-preflight","capture-buffer-pressure-checklist","note-audio-text-evidence-mapping"];
const built = existsSync(new URL('dist/index.html', root));

test('Wave17 bilingual guides retain structural, fixed-source and local-link contracts', { skip: !built }, () => {
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
test('link shape, queue budgets and note progress are not trust, latency or word accuracy', () => {
  // Source-formula illustration only, not a runtime pressure/device benchmark.
  assert.equal(Math.max(Math.ceil(48000 / 2), 4096), 24000);
  for (const prefix of ['', 'en/']) {
    const guide = slug => read('src/pages/' + prefix + 'guides/' + slug + '.md');
    const links = guide('evidence-link-admission-preflight');
    for (const item of ['absoluteString', 'HTTPS', '65535']) assert.ok(links.includes(item));
    assert.ok(links.includes(prefix ? 'not full Markdown parsing' : '不是完整Markdown解析器'));
    const pressure = guide('capture-buffer-pressure-checklist');
    for (const item of ['bufferOverflow', 'snapshot', 'requestStop', '24000', '4096']) assert.ok(pressure.includes(item));
    assert.ok(pressure.includes(prefix ? 'not long-note limits' : '不把其预算推广为长笔记限制'));
    const notes = guide('note-audio-text-evidence-mapping');
    for (const item of ['audio.caf', 'note.json', 'transcribedFrames', 'emptyTranscript', 'done']) assert.ok(notes.includes(item));
    assert.ok(notes.includes(prefix ? 'handoff shares transcription, not recording files' : '分享转写文字，不含录音文件'));
  }
});
