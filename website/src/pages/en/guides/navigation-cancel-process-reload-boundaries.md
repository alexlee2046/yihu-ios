---
layout: ../../../layouts/Wave3Guide.astro
title: "Is cancelled navigation offline? Replaced loads, spinner checks and process reloads"
description: "Separate domain/code cancellation from load failure. A 500 ms recheck and 15-second loop guard are not recovery SLAs or restoration of forms/service actions."
lang: en
---

<h2 id="first-answer">Replaced navigation, failed loading and a terminated Web process mean different things</h2>

isSupersededNavigation filters NSURLErrorDomain cancellation and WebKitErrorDomain 102 instead of directly setting failure UI. A 500 ms delayed recheck clears the spinner only when no load/error remains. Process termination tries reload; adjacent terminations less than 15 seconds apart stop automatic reload. These UI rules do not guarantee network, draft or service-action recovery.

## Different from offline, origin and recognition review

Offline reviews chains, origin reviews scope, recognition reviews audio. Here **navigation callbacks/replacement and termination display policy** matter. No actual reload, certificate/network/service change ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Cancellation | Domain and code together | NSURLErrorCancelled domain | All cancellations offline |
| Policy handoff | WebKitErrorDomain/102 | Not HTTP business status | External page opened/service completed |
| 500 ms | Clear spinner only without load/error | Conditions versus scheduling | Half-second recovery SLA |
| Load failures | userFacingMessage categories | Visible class versus root cause | Every error one cause |
| Termination | Reload policy | Web process versus service | Agent task definitely failed/succeeded |
| 15 seconds | Close terminations stop automatic reload | Loop guard versus availability | Unlimited background retries |
| Reload result | Page/draft/action separately | Actual original request | All fields/actions restored |
| Security | Retain HTTPS validation | Original address/authority | Disable security for availability |

</div>

## Synthetic callback note

A replaced load reports cancellation, not necessarily a completely offline workbench. WebKit 102 is not HTTP102/business confirmation. Spinner/error state does not independently establish service effects.

Requests/materials can remain uncertain across reloads. Do not replay blindly or promise restoration. No real page/network/process test ran; source delays are not device performance claims.

## FAQ

<h3 id="faq-1">Does cancellation prove offline?</h3>

No. Replacement/policy handoff can be filtered; inspect domain/code.

<h3 id="faq-2">Is 102 successful HTTP processing?</h3>

No. This WebKit error code is not a business receipt.

<h3 id="faq-3">Does 500 ms mean recovery in half a second?</h3>

No. It schedules a conditional spinner recheck.

<h3 id="faq-4">Must reload succeed after fifteen seconds?</h3>

No. This is a loop guard, not a recovery SLA.

<h3 id="faq-5">Does reload restore drafts/actions?</h3>

Not guaranteed; review actual material/service state instead of replaying.

<h3 id="faq-6">Were network/fault tests performed?</h3>

No. Fixed navigation policy only, without network/visual/device acceptance.

## Reading and source

[Offline chain](/en/guides/offline-workbench-handoff-troubleshooting/) · [Page boundary](/en/guides/workbench-origin-page-boundaries/) · [Recognition errors](/en/guides/recognition-error-layer-review/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Cancellation/failure/termination](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift)
