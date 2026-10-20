---
layout: ../../../layouts/Wave3Guide.astro
title: "Why a Radar feed URL is rejected: paths, queries and evidence-link differences"
description: "Review HTTPS, host, credentials, ports and absent query/fragment. A path is allowed, but URL shape is not authentication, read success or JSON acceptance."
lang: en
---

<h2 id="first-answer">A clickable evidence URL is not automatically a valid Radar feed</h2>

CollieRadarFeed.validate permits a path but requires HTTPS, nonempty host, no embedded user/password, no query/fragment and an explicit port within 1–65535. Evidence uses separate parseSafeEvidenceURLs rules. Passing feed shape proves neither authentication, reachability, a successful read nor valid snapshot. No source service or credential setup is added.

## Different from evidence admission and offline diagnosis

Evidence admission checks clickable candidates; offline review checks failures. Here **whether a configured source address meets consumer boundaries** comes first. No network request or real credentials are used, and shape is not private-source identity verification.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Edge whitespace | Trim before parsing | Original configuration/returned URL | Every internal character cleansed |
| Scheme/host | HTTPS/nonempty host | Actual source identity | Trusted-domain allowlist or TLS test |
| Path | Allowed on feeds | Actual source endpoint | Browser-origin rules interchangeable |
| Credentials | No user/password | Existing authorized auth process | Passwords in URLs are supported |
| Query/fragment | Both absent | Even view=demo differs | Evidence allowance transfers to feeds |
| Port | Explicit 1…65535 | Access/reachability | Every port/source tested |
| Response | URL validation is not JSON decoding | Model/date/size/identity | Any web page is a snapshot |
| Failure | Original guards remain | Category/original configuration | Automatic HTTP/other service/private disclosure |

</div>

## Synthetic address comparison

https://example.com/radar.json illustrates a path only. Adding ?view=demo or #part meets current query/fragment rejection conditions. Nothing is fetched and no real source is established.

Do not remove real authentication conditions or use an unapproved public service to pass a check. Shape, authentication, reading and content acceptance are separate; none silently supplies the others or write access.

## FAQ

<h3 id="faq-1">Can every clickable HTTPS link be a source?</h3>

No. Consumers differ, especially query/fragment rules.

<h3 id="faq-2">Must a feed be a bare domain without path?</h3>

No. A path is allowed; actual endpoint validity still needs authorized evidence.

<h3 id="faq-3">Is a harmless query allowed?</h3>

The current validator requires no query, irrespective of assumed harmlessness.

<h3 id="faq-4">Does validate prove authentication?</h3>

No request occurs there. Identity, permissions and response remain separate.

<h3 id="faq-5">Can failure be bypassed with HTTP?</h3>

Do not bypass HTTPS; inspect actual errors/authorized configuration.

<h3 id="faq-6">Was the example source created or fetched?</h3>

No service registration, credentials or network request occurred.

## Reading and source

[Evidence URL admission](/en/guides/evidence-link-admission-preflight/) · [Offline/source failures](/en/guides/offline-workbench-handoff-troubleshooting/) · [JSON consumer conditions](/en/guides/radar-json-null-validation/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Feed/evidence URL validators](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [Source/workbench boundaries](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)
