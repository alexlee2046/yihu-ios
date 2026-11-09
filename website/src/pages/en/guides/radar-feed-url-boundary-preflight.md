---
layout: ../../../layouts/Wave3Guide.astro
title: "Why a Radar feed URL is rejected: paths, queries and evidence-link differences"
description: "Review HTTPS, host, credentials, ports and absent query/fragment. A path is allowed, but URL shape is not authentication, read success or JSON acceptance."
lang: en
---

## SYN-RFU-49 Radar feed URL preflight

SYNTHETIC_EXAMPLE · pending · not_run. Feed/evidence/origin shapes are not identity or authority.

[/samples/p28-radar-feed-url-boundary-preflight/README.md](/samples/p28-radar-feed-url-boundary-preflight/README.md) · [/samples/p28-radar-feed-url-boundary-preflight/preflight.zh.json](/samples/p28-radar-feed-url-boundary-preflight/preflight.zh.json) · [/samples/p28-radar-feed-url-boundary-preflight/preflight.en.json](/samples/p28-radar-feed-url-boundary-preflight/preflight.en.json)

<div role="region" aria-label="SYN-RFU-49" tabindex="0">

| ID | Check | Expectation/boundary |
| --- | --- | --- |
| U01 | Empty | feed=false; evidence=0; origin=false; shape only |
| U02 | Whitespace | feed=false; evidence=0; origin=false; shape only |
| U03 | Bare host | feed=true; evidence=1; origin=true; shape only |
| U04 | Root slash | feed=true; evidence=1; origin=true; shape only |
| U05 | Feed path allowed | feed=true; evidence=1; origin=false; shape only |
| U06 | Edge whitespace trim | feed=true; evidence=1; origin=false; shape only |
| U07 | Feed rejects query | feed=false; evidence=1; origin=false; shape only |
| U08 | Feed rejects fragment | feed=false; evidence=1; origin=false; shape only |
| U09 | Empty query still present | feed=false; evidence=1; origin=false; shape only |
| U10 | Empty fragment still present | feed=false; evidence=1; origin=false; shape only |
| U11 | Reject HTTP | feed=false; evidence=0; origin=false; shape only |
| U12 | Missing host | feed=false; evidence=0; origin=false; shape only |
| U13 | Reject synthetic user info | feed=false; evidence=0; origin=false; shape only |
| U14 | Port zero | feed=false; evidence=0; origin=false; shape only |
| U15 | Out-of-range port | feed=false; evidence=0; origin=false; shape only |
| U16 | Port upper bound | feed=true; evidence=1; origin=true; shape only |
| U17 | Explicit 443 | feed=true; evidence=1; origin=true; shape only |
| U18 | Host normalization differs | feed=true; evidence=1; origin=true; shape only |
| U19 | Encoded comma path | feed=true; evidence=1; origin=false; shape only |
| U20 | Comma path versus tokenization | feed=true; evidence=1; origin=false; shape only |
| U21 | Label is not feed URL | feed=false; evidence=0; origin=false; shape only |
| U22 | One URL versus semicolon tokens | feed=true; evidence=2; origin=false; shape only |
| U23 | Not a domain allowlist | feed=true; evidence=1; origin=false; shape only |
| U24 | Encoded bytes in path | feed=true; evidence=1; origin=false; shape only |
| M01 | Shape is not identity | validate proves neither TLS, identity, auth/read/JSON nor write authority; supportsWatchDrafts is not device acceptance. |
| M02 | Rejection is not auto-repair | Never remove real authentication/query conditions to bypass a gate, even empty/assumed harmless; no HTTP/port rewrite or private-source publication. |
| M03 | Origin is not feed | Origin allows empty/root paths and normalizes host/443; feeds allow paths without authenticating. Review source/account/storage separately. |
| M04 | Reminders have their own gate | Reminder HTTPS/relay-host, origin validation and saved origins are not authorized by feed/evidence admission; unknown origins never add a server. |
| M05 | Pending is not delivery | Keep pending slot, note/speech guards, connected consumption and navigation/login/business receipt separate; retain originals and unknown effects. |
| M06 | Do not fetch examples | example.invalid, localhost and SYN are synthetic strings: no DNS/HTTP/registration, private-source URL/credential collection or blind retry. |

</div>



<h2 id="first-answer">A clickable evidence URL is not automatically a valid Radar feed</h2>

CollieRadarFeed.validate permits a path but requires HTTPS, nonempty host, no embedded user/password, no query/fragment. The port may be omitted; if explicitly specified, it must be within 1–65535. Evidence uses separate parseSafeEvidenceURLs rules. Passing feed shape proves neither authentication, reachability, a successful read nor valid snapshot. No source service or credential setup is added.

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
| Port | Optional; if specified, 1…65535 | Access/reachability | Every port/source tested |
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
