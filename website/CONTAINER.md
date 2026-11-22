# Static container / shadow verification

Build context is `website/`. The runtime is `nginx:alpine` on container port **80**;
base-image welcome/error pages are removed, and only the Astro `dist/` output is
copied from the Node 24 build stage. No Vercel
session or native app files are needed. Committed discovery exports are checked
by the existing website CI before acceptance.

From the repository root, in a local Docker environment:

```sh
docker build --pull -t yihu-website:shadow website
docker run --rm --name yihu-website-shadow -e SHADOW_NOINDEX=1 -p 127.0.0.1:8080:80 yihu-website:shadow
```

In a second terminal:

```sh
docker exec yihu-website-shadow wget -Y off -q -O - http://127.0.0.1/health
cd website
npm run container:compare -- https://getyihu.com http://127.0.0.1:8080 --shadow-noindex
# Stop only the local container created above when verification is complete.
docker stop yihu-website-shadow
```

`/health` returns `200`, `ok\n`, `Cache-Control: no-store` and `X-Robots-Tag: noindex`. Docker's built-in
health check uses `wget -Y off`, so inherited proxy settings cannot redirect the
probe. Keep this path outside the sitemap.

`SHADOW_NOINDEX` defaults to `0`. Set it to `1` only in the shadow runtime: the
nginx entrypoint renders `nginx.conf` as a template, substituting only this flag.
`X-Robots-Tag: noindex` then covers HTML, assets (including immutable cached
assets), redirects and errors. Health and retired downloads always retain their
existing noindex. `--shadow-noindex` checks this header on every candidate
response; without the option the comparator requires the production robots
policy to match. Production promotion must use the default/explicit `0` and
repeat comparison without `--shadow-noindex`. If an ingress emits a redirect
before nginx, the deployment owner must verify that ingress response separately.

The read-only comparator uses two workers and checks:

- Every committed sitemap URL: status 200 and identical HTML after normalizing
  only Astro's opaque build-context hydration UID (preserving repeated-ID
  relationships). Titles, descriptions, canonical/hreflang, structured data,
  consent, App Store links and linked asset names must all match exactly.
- Directly linked same-site assets/downloads and `sitemap.xml`, `robots.txt`,
  `llms.txt`, `llms-full.txt`: identical bytes, compatible media types and the same
  cache policy. HTML/discovery documents revalidate; hashed `/_astro/` assets
  remain immutable for a year. Nginx enables gzip for text responses.
- All 25 retired batches and their API response: 410, the same body and noindex.
- Representative slash redirects and every retired batch's bare path: 308,
  same destination path, no host escape or HTTPS downgrade. Unknown pages stay
  404, including the `.well-known/` slash exception. Platform error-page bodies
  and redirect-page formatting are not site content and are not compared.

Use an existing internal shadow endpoint instead of loopback when coordinating
with the deployment owner. The container preserves the production canonical
origin (`https://getyihu.com`); do not rewrite SEO URLs for a shadow hostname.
Stop at any parity failure and investigate before advancing. This preparation
keeps DNS and Vercel unchanged; a production switch uses the separately approved
devops promotion entry point. Do not create new public ports for this check.
