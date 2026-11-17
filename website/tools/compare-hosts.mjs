import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

function origin(value) {
  const url = new URL(value);
  if (!['http:', 'https:'].includes(url.protocol) || url.username || url.password
      || url.pathname !== '/' || url.search || url.hash) {
    throw new Error('Use an HTTP(S) origin without credentials, path, query or fragment.');
  }
  return url.origin;
}

async function each(paths, run) {
  let next = 0;
  await Promise.all(Array.from({ length: 2 }, async () => {
    while (next < paths.length) await run(paths[next++]);
  }));
}

function mediaType(headers) {
  const type = (headers.get('content-type') ?? '').split(';')[0].trim().toLowerCase();
  return ['application/javascript', 'text/javascript'].includes(type) ? 'javascript' : type;
}

// Astro's hydration UID includes its build context. Preserve repeated-ID relationships,
// but ignore the opaque values; all other HTML, SEO and linked asset names stay exact.
function htmlPayload(body) {
  const ids = new Map();
  return body.toString().replace(/(<astro-island\b[^>]*\buid=")([^"]+)(")/g, (_match, start, id, end) => {
    if (!ids.has(id)) ids.set(id, ids.size);
    return `${start}island-${ids.get(id)}${end}`;
  });
}

/** Read-only parity checks. Never follows a redirect or sends credentials/cookies. */
export async function compareHosts(baselineValue, candidateValue, options = {}) {
  const baseline = origin(baselineValue);
  const candidate = origin(candidateValue);
  const fetchImpl = options.fetchImpl ?? fetch;
  const sitemap = options.routes ? null : await readFile(new URL('../public/sitemap.xml', import.meta.url), 'utf8');
  const routes = options.routes ?? [...sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)]
    .map((match) => new URL(match[1]).pathname);
  const rewrites = options.retiredPaths ? null : JSON.parse(await readFile(new URL('../vercel.json', import.meta.url), 'utf8')).rewrites;
  const retired = options.retiredPaths ?? rewrites.map(({ source }) => source.replace('/:path*', ''));
  if (!routes.length) throw new Error('Sitemap contains no routes.');

  async function request(host, path) {
    const response = await fetchImpl(new URL(path, host), {
      redirect: 'manual',
      credentials: 'omit',
      signal: AbortSignal.timeout(15_000),
    });
    return { status: response.status, headers: response.headers, body: Buffer.from(await response.arrayBuffer()) };
  }

  async function pair(path, expectedStatus, compareBody = true) {
    const a = await request(baseline, path);
    const b = await request(candidate, path);
    if (a.status !== expectedStatus || b.status !== a.status) {
      throw new Error(`Status differs at ${path}: baseline=${a.status}, candidate=${b.status}, expected=${expectedStatus}`);
    }
    if (compareBody && a.status === 200 && a.headers.get('cache-control') !== b.headers.get('cache-control')) {
      throw new Error(`Cache policy differs at ${path}`);
    }
    if (compareBody && mediaType(a.headers) !== mediaType(b.headers)) throw new Error(`Media type differs at ${path}`);
    const sameBody = mediaType(a.headers) === 'text/html'
      ? htmlPayload(a.body) === htmlPayload(b.body) : a.body.equals(b.body);
    if (compareBody && !sameBody) throw new Error(`Body differs at ${path}`);
    return [a, b];
  }

  const health = await request(candidate, '/health');
  if (health.status !== 200 || health.body.toString() !== 'ok\n'
      || health.headers.get('x-robots-tag') !== 'noindex' || health.headers.get('cache-control') !== 'no-store') throw new Error('Candidate /health contract failed.');

  const resources = new Set(['/sitemap.xml', '/robots.txt', '/llms.txt', '/llms-full.txt']);
  await each(routes, async (path) => {
    const [page] = await pair(path, 200);
    for (const match of page.body.toString().matchAll(/\b(?:href|src)=["'](\/[^"']*)["']/g)) {
      if (match[1].startsWith('//')) continue;
      const resource = new URL(match[1], baseline).pathname;
      if (!routes.includes(resource)) resources.add(resource);
    }
  });
  await each([...resources], async (path) => { await pair(path, 200); });

  const retiredFiles = [...retired.map((path) => `${path}/retired-probe.json`), '/api/retired-sample/'];
  await each(retiredFiles, async (path) => {
    const responses = await pair(path, 410);
    if (responses.some(({ headers }) => headers.get('x-robots-tag') !== 'noindex')) {
      throw new Error(`Retired route lost noindex at ${path}`);
    }
  });

  const redirects = new Set(['/en', '/en?from=shadow-check', '/__yihu_missing_route__', '/api/retired-sample', ...retired]);
  const guide = routes.find((path) => path.includes('/guides/'));
  if (guide) redirects.add(guide.replace(/\/$/, ''));
  await each([...redirects], async (path) => {
    const responses = await pair(path, 308, false);
    const targets = responses.map(({ headers }, i) => {
      const host = [baseline, candidate][i];
      const location = headers.get('location');
      if (!location) throw new Error(`Missing redirect location at ${path}`);
      const target = new URL(location, host);
      if (target.origin !== host) throw new Error(`Redirect leaves its host or downgrades HTTPS at ${path}`);
      return target.pathname + target.search;
    });
    if (targets[0] !== targets[1]) throw new Error(`Redirect target differs at ${path}`);
  });

  const missing = ['/__yihu_missing_route__/', '/.well-known/__yihu_missing_route__'];
  await each(missing, async (path) => { await pair(path, 404, false); });
  return { pages: routes.length, resources: resources.size, retired: retiredFiles.length, redirects: redirects.size, missing: missing.length, health: true };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [, , baseline, candidate] = process.argv;
  if (!baseline || !candidate) {
    console.error('Usage: npm run container:compare -- https://getyihu.com http://127.0.0.1:8080');
    process.exitCode = 1;
  } else {
    try { console.log(JSON.stringify(await compareHosts(baseline, candidate))); }
    catch (error) { console.error(error.message); process.exitCode = 1; }
  }
}
