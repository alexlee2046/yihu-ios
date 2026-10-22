import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const read = p => readFileSync(new URL(p, root), 'utf8');
const retired = ['shortcut-toggle-request-lifetime', 'notification-disable-unregister-pending', 'reminder-link-pending-origin-routing'];
const core = ['iphone-agent-voice-drafts', 'bluetooth-audio-input-troubleshooting', 'recording-notes-handoff', 'multi-project-radar-watch'];
const urls = [...read('public/sitemap.xml').matchAll(/<loc>([^<]+)<\/loc>/g)].map(x => x[1]);
function pages(path = 'dist/') {
  return readdirSync(new URL(path, root), { withFileTypes: true }).flatMap(e => e.isDirectory() ? pages(path + e.name + '/') : e.name === 'index.html' ? [path + e.name] : []);
}
test('180 built routes remain accessible; the approved six alone leave the 174-page index', () => {
  const built = pages(); assert.equal(built.length, 180);
  assert.equal(urls.length, 174); assert.equal(new Set(urls).size, 174);
  let excluded = 0;
  for (const file of built) {
    const html = read(file), url = 'https://getyihu.com/' + file.slice(5).replace(/index\.html$/, '');
    const isRetired = retired.some(s => url.endsWith('/guides/' + s + '/'));
    assert.ok(html.includes('<link rel="canonical" href="' + url + '"'));
    assert.equal(html.includes('content="noindex,follow"'), isRetired, url);
    assert.equal(urls.includes(url), !isRetired, url);
    if (isRetired) {
      excluded++;
      assert.ok(!html.includes('hreflang='), 'no indexed-language promotion of retired pairs');
      assert.ok(html.includes('Technical reference') || html.includes('技术参考'));
      for (const name of ['llms.txt', 'llms-full.txt']) {
        assert.ok(!read('public/' + name).includes(url), name + ' excludes ' + url);
      }
    }
  }
  assert.equal(excluded, 6);
  assert.ok(!/^Disallow:\s*\/\s*$/m.test(read('public/robots.txt')), 'crawler can see noindex');
});
test('bilingual home offers four buyer scenarios, not the old technical link wall', () => {
  const copy = JSON.parse(read('src/data/home-answers.json'));
  for (const [lang, prefix] of [['zh', ''], ['en', 'en/']]) {
    const html = read('dist/' + prefix + 'index.html');
    assert.equal(copy[lang].scenarios.length, 4);
    assert.deepEqual(copy[lang].scenarios.map(x => x.slug), core);
    for (const slug of core) assert.ok(html.includes('href="/' + prefix + 'guides/' + slug + '/"'));
    for (const slug of [...retired, 'capture-completion-token-review', 'host-bridge-outcome-boundaries']) assert.ok(!html.includes('/guides/' + slug + '/'));
    assert.ok(html.includes('id="scenarios"'));
    assert.ok(!html.includes('apps.apple.com/'));
  }
});
test('core pages explain workflow choices and keep practical setup/source links', () => {
  for (const prefix of ['', 'en/']) for (const slug of core) {
    const html = read('dist/' + prefix + 'guides/' + slug + '/index.html');
    assert.equal([...html.matchAll(/<h1\b/g)].length, 1);
    assert.ok(html.includes('id="first-answer"'));
    assert.ok(html.includes('href="/' + prefix + 'start/"'));
    assert.ok(html.includes('a59676a72c1931bb36dc29ef0810b5e6dc9339ea'));
  }
  for (const prefix of ['', 'en/']) {
    assert.ok(read('dist/' + prefix + 'guides/iphone-agent-voice-drafts/index.html').includes('id="compare"'));
    assert.ok(read('dist/' + prefix + 'guides/recording-notes-handoff/index.html').includes('id="compare"'));
  }
});
