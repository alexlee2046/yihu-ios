---
layout: ../../../layouts/Wave3Guide.astro
title: "Stop, cancel and late capture callbacks: inspect activeToken ownership"
description: "Review asynchronous completion tokens, stop draining and cancel invalidation. A token is neither authentication nor universal idempotency or automatic recapture."
lang: en
---

<h2 id="first-answer">Stop can yield this capture's drained result; canceled tokens cannot identify a new capture</h2>

Short-speech start creates a UUID; captureCompleted accepts only the matching activeToken. Stop ends admission and drains without immediately invalidating this capture's token. Cancel clears activeToken and cancels the pipeline. Similar UI phases/late callbacks do not establish ownership. This is in-process completion guarding, not authentication or cross-service exactly-once.

## Different from foreground and queue review

Foreground checks lifecycle validity; pressure checks previews/final. Here **which capture owns an asynchronous result and why stop differs from cancel** matters. No capture, cancellation or callback injection ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Start | Per-capture token in completion closure | Current active capture | UUID grants user authority |
| Stop | End admission/engine, drain asynchronously | Actual final/error | Tap means complete cancellation or success |
| Cancel | Clear activeToken/cancel pipeline | Canceled versus committed effects | Remote recall |
| captureCompleted | Compare activeToken/token first | Old result is not a new capture | Same text belongs to current target |
| Cleanup | Clears token/pipeline etc. | Actual completion/error | All call chains duplicate-free |
| Preview/level | Different evidence from final/token | When preview was generated | Late preview proves delivery |
| Delivery | Controller/insertion guards remain | Actual target/permission | Capture token grants writes |
| Recapture | New capture versus prior effects | Gap/version/old attempt | Automatic fill/merge/resend |

</div>

## Synthetic timing review

Capture A was canceled. A's late completion arrives while activeToken no longer identifies A. It cannot be presented as new capture B or automatically handed off. If A merely stopped, its drain can still complete; record the distinction.

No race-free/zero-loss guarantee is made. Tokens are implementation association, not credentials/signatures. Prior effects retain original receipt/uncertainty review.

## FAQ

<h3 id="faq-1">Is stop the same as cancel?</h3>

No. Stop retains asynchronous draining; cancel invalidates the token/pipeline.

<h3 id="faq-2">Can a UUID-bearing old result join a new draft?</h3>

No. Current ownership and target/permission guards still apply.

<h3 id="faq-3">Is activeToken authentication?</h3>

No. Capture association does not grant identity or operation authority.

<h3 id="faq-4">Does stop tapping mean final exists?</h3>

No. Inspect actual completion/error rather than button events.

<h3 id="faq-5">Does cancellation recall prior inserted contents?</h3>

No inference follows. Inspect actual prior/local/remote effects.

<h3 id="faq-6">Does this establish no callback races?</h3>

No device/concurrency test or recovery feature is supplied; fixed guards only.

## Reading and source

[Lifecycle](/en/guides/foreground-audio-rebind-preflight/) · [Queue/final](/en/guides/capture-buffer-pressure-checklist/) · [Recapture scope](/en/guides/interruption-recapture-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Capture lifecycle/token](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift) · [Pipeline stop/cancel](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift)
