import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import { compareHosts } from '../tools/compare-hosts.mjs';

const read = (path) => readFile(new URL(`../${path}`, import.meta.url), 'utf8');

test('container ships only the static build, with a proxy-independent health check', async () => {
  const docker = await read('Dockerfile');
  const ignore = await read('.dockerignore');
  assert.match(docker, /FROM node:24-alpine AS build/);
  assert.match(docker, /RUN npm ci --no-audit --no-fund/);
  assert.match(docker, /RUN npm run build/);
  const runtime = docker.split('FROM nginx:alpine AS runtime')[1];
  assert.ok(runtime);
  assert.match(runtime, /RUN rm -rf \/usr\/share\/nginx\/html/);
  assert.match(runtime, /COPY --from=build \/app\/dist \/usr\/share\/nginx\/html/);
  assert.match(runtime, /COPY nginx\.conf \/etc\/nginx\/conf\.d\/default\.conf/);
  assert.match(runtime, /EXPOSE 80/);
  assert.match(runtime, /HEALTHCHECK[\s\S]*wget -Y off -q -O \/dev\/null http:\/\/127\.0\.0\.1\/health/);
  assert.doesNotMatch(runtime, /npm|node_modules|COPY \. /);
  for (const excluded of ['node_modules', 'dist', '.astro', '.vercel', '.env', '.env.*']) {
    assert.ok(ignore.split('\n').includes(excluded), `Missing Docker exclusion: ${excluded}`);
  }
});

test('nginx mirrors all and only the retired Vercel batches and keeps noindex on 410', async () => {
  const nginx = await read('nginx.conf');
  const vercel = JSON.parse(await read('vercel.json'));
  assert.equal(vercel.trailingSlash, true);
  const retired = new RegExp(nginx.match(/location ~ "([^"\n]*api\/retired-sample[^"\n]*)"/)[1]);
  assert.equal(vercel.rewrites.length, 25);
  for (const { source, destination } of vercel.rewrites) {
    assert.equal(destination, '/api/retired-sample');
    const path = source.replace('/:path*', '');
    for (const suffix of ['', '/', '/example.json', '/nested/example.json']) assert.ok(retired.test(path + suffix));
    assert.equal(retired.test(`${path}-other/example.json`), false);
  }
  for (const path of ['/samples/another-batch/file.json', '/samples/', '/api/retired-sample/extra/', '/en/']) {
    assert.equal(retired.test(path), false);
  }
  assert.ok(retired.test('/api/retired-sample/'));
  assert.match(nginx, /api\/retired-sample[^\n]*\{\s*types \{ \}/);
  assert.match(nginx, /add_header X-Robots-Tag noindex always;\s*return 410/);
  assert.ok(nginx.includes('This sample has been retired. See https://getyihu.com/ for current guides.\\n'));
});

test('nginx preserves 308 slash redirects, HTTPS behind a proxy, health and hard 404s', async () => {
  const nginx = await read('nginx.conf');
  const slash = new RegExp([...nginx.matchAll(/location ~ "([^"\n]+)"/g)].find((match) => match[1].includes("[^/.]+"))[1]);
  for (const path of ['/en', '/unknown', '/api/retired-sample', '/samples/retired/example']) assert.ok(slash.test(path));
  for (const path of ['/', '/en/', '/llms.txt', '/_astro/app.js']) assert.equal(slash.test(path), false);
  assert.match(nginx, /return 308 \/\$1\/\$is_args\$args;/);
  assert.ok(nginx.includes('if ($request_uri ~ "^/+([^?]*)")'));
  assert.match(nginx, /default_type text\/markdown;/);
  assert.match(nginx, /types \{ audio\/mp4 m4a; \}/);
  assert.ok(nginx.includes(String.raw`if ($request_uri ~ "^[^?]*\\\\") { return 400; }`));
  assert.match(nginx, /absolute_redirect off;/);
  assert.match(nginx, /gzip on;/);
  assert.match(nginx, /gzip_vary on;/);
  assert.ok(nginx.includes('add_header Cache-Control "public, max-age=0, must-revalidate" always;'));
  assert.ok(nginx.includes('add_header Cache-Control "public, max-age=31536000, immutable";'));
  assert.match(nginx, /types \{ application\/xml xml; \}/);
  assert.match(nginx, /add_header Cache-Control no-store always;/);
  assert.match(nginx, /location \^~ \/\.well-known\//);
  assert.match(nginx, /location = \/health \{[\s\S]*?return 200 "ok\\n";/);
  assert.match(nginx, /try_files \$uri \$uri\/ =404;/);
  assert.doesNotMatch(nginx, /try_files[^;]*\/index\.html/);
});

function fixture({ changedPath, changedStatus, wrongRedirect = false, missingNoindex = false, cacheDrift = false, duplicateHydrationIDs = false } = {}) {
  let active = 0;
  let peak = 0;
  const fetchImpl = async (url, options) => {
    assert.equal(options.redirect, 'manual');
    assert.equal(options.credentials, 'omit');
    peak = Math.max(peak, ++active);
    await Promise.resolve();
    active--;
    const candidate = url.hostname === 'candidate.example.test';
    const path = url.pathname;
    let status = 200;
    const headers = { 'content-type': 'text/plain', 'cache-control': 'public, max-age=0, must-revalidate' };
    let body = 'same';
    if (path === '/health') {
      assert.ok(candidate, 'Health must not be requested from the live baseline');
      body = 'ok\n'; headers['x-robots-tag'] = 'noindex'; headers['cache-control'] = 'no-store';
    } else if (path.startsWith('/.well-known/')) {
      status = 404;
    } else if (!path.endsWith('/') && !path.split('/').at(-1).includes('.')) {
      status = 308;
      headers.location = wrongRedirect && candidate ? `https://elsewhere.example.test${path}/` : `${path}/${url.search}`;
    } else if (path.startsWith('/samples/') || path === '/api/retired-sample/') {
      status = 410;
      if (!missingNoindex || !candidate) headers['x-robots-tag'] = 'noindex';
    } else if (path.includes('__yihu_missing_route__')) {
      status = 404;
      // Platform-generated error bodies may differ; public page bodies may not.
      body = candidate ? 'nginx error' : 'platform error';
    } else if (['/', '/en/'].includes(path)) {
      headers['content-type'] = 'text/html; charset=utf-8';
      body = `<html><link rel="canonical" href="https://getyihu.com/"><a href="/en/">English</a><img src="/icon.svg"><astro-island uid="${candidate ? 'build-b' : 'build-a'}"></astro-island><astro-island uid="${candidate ? (duplicateHydrationIDs ? 'build-b' : 'build-d') : 'build-c'}"></astro-island></html>`;
    }
    if (candidate && path === changedPath) {
      if (changedStatus) status = changedStatus;
      else body = 'changed';
    }
    if (candidate && cacheDrift && path === '/llms.txt') headers['cache-control'] = 'public, max-age=120';
    return new Response(body, { status, headers });
  };
  return { fetchImpl, peak: () => peak };
}

const settings = { routes: ['/', '/en/'], retiredPaths: ['/samples/retired-check'] };
const compare = (fixtureOptions) => {
  const probe = fixture(fixtureOptions);
  return { run: () => compareHosts('https://baseline.example.test', 'http://candidate.example.test', { ...settings, fetchImpl: probe.fetchImpl }), probe };
};

test('host comparison covers exact public payloads, resources, 410/noindex, 308s, 404s and health with two workers', async () => {
  const { run, probe } = compare();
  const result = await run();
  assert.deepEqual(result, { pages: 2, resources: 5, retired: 2, redirects: 5, missing: 2, health: true });
  assert.ok(probe.peak() <= 2);
});

test('host comparison fails on body, asset, status, host redirect and noindex drift without logging page bodies', async () => {
  await assert.rejects(compare({ changedPath: '/health' }).run(), /Candidate \/health contract failed/);
  await assert.rejects(compare({ changedPath: '/' }).run(), /Body differs at \//);
  await assert.rejects(compare({ changedPath: '/llms.txt' }).run(), /Body differs at \/llms\.txt/);
  await assert.rejects(compare({ changedPath: '/icon.svg' }).run(), /Body differs at \/icon\.svg/);
  await assert.rejects(compare({ changedPath: '/en/', changedStatus: 404 }).run(), /Status differs at \/en\//);
  await assert.rejects(compare({ wrongRedirect: true }).run(), /Redirect leaves its host or downgrades HTTPS/);
  await assert.rejects(compare({ missingNoindex: true }).run(), /Retired route lost noindex/);
  await assert.rejects(compare({ cacheDrift: true }).run(), /Cache policy differs at \/llms\.txt/);
  await assert.rejects(compare({ duplicateHydrationIDs: true }).run(), /Body differs at \//);
});

test('comparison rejects credential-bearing or non-root origins', async () => {
  for (const value of ['https://user:password@example.test', 'file:///tmp/', 'https://example.test/path', 'https://example.test/?key=value']) {
    await assert.rejects(compareHosts(value, 'http://candidate.example.test', settings), /HTTP\(S\) origin/);
  }
});
