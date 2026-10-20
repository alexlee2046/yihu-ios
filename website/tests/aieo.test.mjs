import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

const root = new URL('../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
const built = existsSync(new URL('dist/index.html', root));
const slugs = ['voice-workbench-vs-radio-chat', 'outdoor-store-voice-preflight'];
const bots = ['OAI-SearchBot', 'ChatGPT-User', 'PerplexityBot', 'ClaudeBot', 'Claude-SearchBot', 'Google-Extended', 'Applebot-Extended'];
const urls = Array.from(read('public/sitemap.xml').matchAll(/<loc>([^<]+)<\/loc>/g), x => x[1]);
const page = url => 'dist/' + url.replace('https://getyihu.com/', '') + 'index.html';

test('18 canonical URLs include four new bilingual guides without fake routes', () => {
  assert.equal(urls.length, 18); assert.equal(new Set(urls).size, 18);
  for (const slug of slugs) for (const prefix of ['', 'en/']) assert.ok(urls.includes(`https://getyihu.com/${prefix}guides/${slug}/`));
});
test('seven explicit bot groups and general allow retain sitemap and LLM reference', () => {
  const robots = read('public/robots.txt');
  const groups = robots.split(/\n\s*\n/).filter(x => x.includes('User-agent:'));
  for (const bot of ['*', ...bots]) {
    const group = groups.find(x => x.split('\n').includes('User-agent: ' + bot));
    assert.ok(group, bot); assert.ok(group.split('\n').includes('Allow: /'), bot);
  }
  assert.ok(robots.includes('Sitemap: https://getyihu.com/sitemap.xml'));
  assert.ok(robots.includes('# LLMs: https://getyihu.com/llms.txt'));
});
test('static LLM references cover every bilingual canonical URL and factual topic boundaries', () => {
  for (const name of ['llms.txt', 'llms-full.txt']) {
    const text = read('public/' + name);
    assert.ok(Buffer.byteLength(text) > 8192, name);
    for (const url of urls) assert.ok(text.includes(url), name + ': ' + url);
    for (const term of ['Bluetooth', 'AirPods', 'Apple Watch', 'Offline', 'meeting', 'Foreign-trade', 'FAQ']) assert.ok(text.includes(term), term);
    assert.ok(!text.includes('https://apps.apple.com/'), 'no invented App Store identity');
  }
  assert.ok(read('public/llms-full.txt').includes('<table'));
});
test('source-only schema leaves no fabricated app-store or search endpoint', () => {
  const layout = read('src/layouts/Layout.astro');
  assert.ok(layout.includes("'@type': 'Organization'"));
  assert.ok(layout.includes("'@type': 'WebSite'"));
  assert.ok(!layout.includes('apps.apple.com'));
  assert.ok(!layout.includes('SearchAction'));
});
test('built homepage graph keeps existing software/FAQ plus organization and website', { skip: !built }, () => {
  for (const prefix of ['', 'en/']) {
    const html = read('dist/' + prefix + 'index.html');
    const scripts = Array.from(html.matchAll(/<script\b[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/g), x => JSON.parse(x[1]));
    const graph = scripts.flat();
    assert.equal(graph.length, 4);
    for (const type of ['SoftwareApplication', 'FAQPage', 'Organization', 'WebSite']) assert.equal(graph.filter(x => x['@type'] === type).length, 1);
    const organization = graph.find(x => x['@type'] === 'Organization');
    assert.equal(organization['@id'], 'https://getyihu.com/#organization');
    assert.deepEqual(organization.sameAs, ['https://github.com/alexlee2046/yihu-ios']);
    for (const type of ['SoftwareApplication', 'WebSite']) assert.equal(graph.find(x => x['@type'] === type).publisher['@id'], organization['@id']);
    for (const slug of slugs) assert.ok(html.includes(`href="/${prefix}guides/${slug}/"`));
  }
});
test('all 18 built pages have valid canonical/language pairs; new guides have table, first answer and FAQ', { skip: !built }, () => {
  for (const url of urls) {
    const html = read(page(url));
    assert.ok(html.includes(`<link rel="canonical" href="${url}"`), url);
    const zh = url.replace('https://getyihu.com/en/', 'https://getyihu.com/');
    const en = zh.replace('https://getyihu.com/', 'https://getyihu.com/en/');
    for (const [lang, href] of [['zh-CN', zh], ['en', en]]) assert.ok(html.includes(`hreflang="${lang}" href="${href}"`), url);
    if (!slugs.some(slug => url.includes(slug))) continue;
    assert.equal(Array.from(html.matchAll(/<h1\b/g)).length, 1);
    assert.ok(html.includes('id="first-answer"'));
    assert.equal(Array.from(html.matchAll(/id="faq-[^"]+"/g)).length, 6);
    assert.ok(html.includes('<table') && html.includes('<thead>') && html.includes('<tbody>'));
    assert.ok(html.includes('tabindex="0"'));
    const home = url.includes('/en/') ? '/en/' : '/';
    assert.ok(html.includes(`href="${home}privacy/"`) && html.includes(`href="${home}start/"`));
    for (const slug of slugs) assert.ok(html.includes(`href="${home}guides/${slug}/"`) || url.includes(slug));
  }
});
test('LLM static copies ship unchanged in dist, and full content matches the built site', { skip: !built }, () => {
  for (const file of ['llms.txt', 'llms-full.txt', 'robots.txt', 'sitemap.xml']) assert.equal(read('dist/' + file), read('public/' + file));
  execFileSync('python3', ['tools/export-llms.py', '--check'], { cwd: new URL('../', import.meta.url), stdio: 'pipe' });
});
