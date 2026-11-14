import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { createServer } from 'node:http';
import retiredSample from '../api/retired-sample.js';

const root = new URL('../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
const walk = path => readdirSync(new URL(path, root), { withFileTypes: true }).flatMap(entry =>
  entry.isDirectory() ? walk(path + '/' + entry.name) : [path + '/' + entry.name]);
const markers = new RegExp(['SYNTHETIC_' + 'EXAMPLE', 'not_' + 'run', 'SYN' + '-'].join('|'));
const retired = JSON.parse(read('vercel.json')).rewrites;

test('source, public text and built reading exports contain no retired sample markers or links', () => {
  for (const dir of ['src', 'public', 'dist', 'tools', 'api']) {
    for (const file of walk(dir).filter(path => /\.(?:astro|tsx?|json|txt|xml|html|md|mjs|js|py)$/.test(path))) {
      const value = read(file);
      assert.ok(!markers.test(value), file);
      for (const { source } of retired) assert.ok(!value.includes(source.replace('/:path*', '/')), file + ' links to retired download');
    }
  }
});

test('retired downloads use exact batch rewrites, while usable samples and all guide URLs stay static', () => {
  assert.equal(retired.length, 25);
  assert.equal(new Set(retired.map(rule => rule.source)).size, 25);
  assert.equal(JSON.parse(read('vercel.json')).trailingSlash, true);
  for (const rule of retired) {
    assert.match(rule.source, /^\/samples\/p(?:[89]|1\d|2\d|3[0-2])-[a-z-]+\/:path\*$/);
    assert.equal(rule.destination, '/api/retired-sample');
    assert.ok(!existsSync(new URL('public' + rule.source.replace('/:path*', '/'), root)));
  }
  for (const file of walk('public/samples')) assert.equal(read('dist/' + file.slice(7)), read(file), file);
});

test('retired sample handler returns HTTP 410 and noindex for GET and HEAD', async () => {
  const server = createServer(retiredSample);
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  try {
    for (const method of ['GET', 'HEAD']) {
      const response = await fetch(`http://127.0.0.1:${server.address().port}/`, { method });
      assert.equal(response.status, 410);
      assert.equal(response.headers.get('x-robots-tag'), 'noindex');
      assert.match(response.headers.get('content-type'), /text\/plain/);
      const body = await response.text();
      assert.ok(method === 'HEAD' ? body === '' : body.includes('retired'));
    }
  } finally { await new Promise(resolve => server.close(resolve)); }
});

test('150 canonical URLs retain content, metadata and paired languages', () => {
  const urls = [...read('public/sitemap.xml').matchAll(/<loc>([^<]+)<\/loc>/g)].map(match => match[1]);
  assert.equal(urls.length, 150);
  assert.equal(new Set(urls).size, 150);
  for (const url of urls) {
    const html = read('dist/' + url.replace('https://getyihu.com/', '') + 'index.html');
    assert.ok(html.includes(`rel="canonical" href="${url}"`), url);
    assert.equal((html.match(/<h1\b/g) || []).length, 1, url);
    assert.ok(!html.includes('content="noindex,follow"'), url);
    assert.match(html, /<title>[^<]+<\/title>/);
    assert.match(html, /name="description" content="[^"]+"/);
    assert.ok(html.includes('hreflang="zh-CN"') && html.includes('hreflang="en"'), url);
  }
});

test('home starts with recording-note material and a direct store action, including without JavaScript', () => {
  const url = JSON.parse(read('src/data/app-store.json')).url;
  for (const prefix of ['', 'en/']) {
    const html = read(`dist/${prefix}index.html`);
    const hero = html.split('class="task-hero wrap"')[1].split('</section>')[0];
    assert.ok(hero.includes(`class="button button-primary app-store-link" href="${url}"`));
    assert.ok(html.includes(prefix ? 'no owner or deadline was agreed' : '还没约定负责人和时间'));
    assert.ok(html.includes('client="load"'));
  }
});
