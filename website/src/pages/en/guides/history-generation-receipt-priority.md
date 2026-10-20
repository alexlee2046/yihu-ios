---
layout: ../../../layouts/Wave3Guide.astro
title: "Does closing history undo a submit? Late reads, generations and confirmed receipts"
description: "Review history generations and recorded-state priority. Closing read-only views does not recall writes; late responses are not new evidence or archive certificates."
lang: en
---

<h2 id="first-answer">Closing history does not recall a submit; earlier reads cannot supersede a confirmed receipt</h2>

History reads capture historyGeneration and recheck historyActive, current source, generation and cancellation after awaiting. cancelHistory changes local state/generation; reply complete also invalidates old history reads so pre-submit results do not win over confirmed receipts. This is not server recall or permission to treat late/ignored history as current absent/business state.

## Different from retrieval, references and request identity

Retrieval checks coverage, references check structure, request IDs associate writes. Here **asynchronous history versus confirmed-write ordering** matters. No actual network submit/cancel, record cleanup or prior-reply modification occurs.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Generation | Captured for each read | Query lifecycle | Server version/request_id |
| Return guard | Active/source/generation/cancellation | Response still applicable | Any response is latest |
| cancelHistory | Inactive/increment generation/clear local busy | View versus submit state | Recall issued POST/service write |
| Old-read defer | Clear busy only for matching generation | New read not overtaken by old cleanup | All network canceled |
| Complete | Invalidate old reads, recorded=true | Receipt versus new history | Business handling/approval done |
| Late response | Do not apply failed guards | Original scope/unknowns | Absent, therefore safely resend |
| Failure/no history | Actual error/prior result still matters | Not displayed differs from never written | Record never existed |
| Editorial retention | Read/submit/receipt scopes separate | Real associations/times | Local counter is permanent audit certificate |

</div>

## Synthetic ordering review

Read A starts, then a submit receives recorded; A returns later. A is not a new post-confirmation whole view or a resend basis. Generation guards protect local ordering, while actual requests/originals still need review.

Closing does not establish no network happened or server effects recalled. A generation is neither account credential, source epoch nor durable ledger. No concurrency/service regression ran; no universal race-free guarantee follows.

## FAQ

<h3 id="faq-1">Does closing history undo a reply?</h3>

No. Read-only view state and writes/service outcomes differ.

<h3 id="faq-2">Is historyGeneration request_id?</h3>

No. Local read generations differ from write-request identity.

<h3 id="faq-3">Is the last arriving response newest truth?</h3>

No. Scope/generation/event order matter, not arrival alone.

<h3 id="faq-4">Can an old query declare absent after recorded?</h3>

Do not supersede confirmation with invalidated old reads or infer resend authority from missing display.

<h3 id="faq-5">Does cancelHistory kill every network request?</h3>

No such guarantee is asserted. Local invalidation differs from issued requests/effects.

<h3 id="faq-6">Are these permanent archives/race-free certificates?</h3>

No. Local guards do not replace service/concurrency/retention acceptance.

## Reading and source

[Retrieval scope](/en/guides/history-retrieval-manual-comparison/) · [Reference structure](/en/guides/history-reference-integrity-review/) · [Requests/receipts](/en/guides/reply-request-receipt-mapping/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[History lifecycle/complete](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift)
