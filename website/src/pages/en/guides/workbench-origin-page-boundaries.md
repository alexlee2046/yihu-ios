---
layout: ../../../layouts/Wave3Guide.astro
title: "Same origin but insertion refused: browser origin, page and storage boundaries"
description: "Review scheme/host/effective port, origin-derived WebKit storage and page/request guards. Different workbench names do not establish separate storage or accounts."
lang: en
---

<h2 id="first-answer">Same origin is not the same page, draft or operation authority</h2>

CollieWebSession.isTrusted compares baseURL scheme/host/effective port and invalidation state, not similar-looking titles/domains. Persistent WebKit storage is derived from normalized origin; paths/workbench names do not automatically create separate stores. Insertion can still check expectedPageURL, requestID and adapters. Origin acceptance is not sending permission.

## Different from feed URLs, context and restored drafts

Feed review concerns source addresses, context concerns conversation, drafts concern local ownership. Here **browser-origin comparison, storage keys and page insertion conditions** matter. No page, Cookie or setting is accessed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Native comparison | Lowercased scheme/host and effective port | Configured boundary/current URL | Trusted account/content certification |
| Default ports | HTTPS 443/HTTP 80 per implementation | Implicit/explicit default | Downgrade to HTTP for compatibility |
| Path/title | Not this origin identity key | Actual page/full-URL conditions | Matching appearance grants authority |
| Persistent key | Identifier derived from normalized-origin SHA | Same-origin container reuse | Every workbench name has isolated cookies |
| Store versus account | Cookie path/login separately | Actual account/access | Shared container guarantees one identity |
| Page/request | Optional expectedPageURL/prepared request etc. | Current page/request ownership | Origin bypasses target guards |
| Adapter outcome | Refusal/unknown is not blind fallback | Actual result/draft state | Insertion means sending/approval |
| Other native data | Radar/notes use separate paths | Separate storage surfaces | WebKit is the entire archive |

</div>

## Synthetic origin comparison

https://example.com/a and https://example.com:443/b can derive the same origin storage key without being the same page/draft. A handoff bound to the original page still follows that path's conditions.

isTrusted is not site-safety, account-truth or Agent-memory certification. Shared storage does not establish effective business login. Examples were not fetched and no browsing data was read.

## FAQ

<h3 id="faq-1">Can same origin write into any input?</h3>

No. Original page/request/focus/adapter/caller guards remain.

<h3 id="faq-2">Do different workbench names isolate cookies?</h3>

Not by naming; the cited key derives from normalized origin.

<h3 id="faq-3">Are implicit HTTPS port and explicit 443 necessarily different origins?</h3>

This effective-port comparison relates defaults; full-page conditions are separate.

<h3 id="faq-4">Does one container prove one account?</h3>

No. Actual Cookie scope/login/service authority remain.

<h3 id="faq-5">Is isTrusted security/truth certification?</h3>

No. Implementation conditions do not replace content/identity/permission evidence.

<h3 id="faq-6">Were pages/Cookies checked?</h3>

No login, data access or configuration change occurred; fixed source only.

## Reading and source

[Feed URL differences](/en/guides/radar-feed-url-boundary-preflight/) · [Target/context](/en/guides/follow-up-context-preflight/) · [Native drafts](/en/guides/reply-draft-restoration-scope/) · [Workbench scope](/en/guides/voice-workbench-vs-radio-chat/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Origin/storage/insertion](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift) · [Adapter guards](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift)
