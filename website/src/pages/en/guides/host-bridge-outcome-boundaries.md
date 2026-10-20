---
layout: ../../../layouts/Wave3Guide.astro
title: "Refused is not unavailable: inspect accepted/refused/unavailable bridge outcomes"
description: "Review protocol observation and native fallback. Only unavailable can continue guarded DOM adaptation; no blind retry, sender or new bridge service."
lang: en
---

<h2 id="first-answer">refused differs from unavailable; accepted is not a backend handling receipt</h2>

collieBridgeScript checks origin/full pageURL/visibility and observes detail reads, accepted writes and event cancellation. It returns accepted/refused/unavailable. Native handling continues to guarded DOM only for explicit unavailable, not refusals, exceptions or arbitrary results. accepted is a protocol report, not sending or business completion.

## Different from origin, reservations and completion review

Origin concerns boundaries, reservations concern attempts, auditing concerns results. Here **optional page-bridge observation and permission to try the next adapter branch** matter. No event injection, fake bridge or global-page modification occurs.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Preconditions | Origin/pageURL/hidden etc. | Actual page/phase | Same title implies trust |
| accepted | Explicit accepted=true wins | Host report versus target content | Server received/executed/approved |
| Observed | Reads text/accepted or writes accepted | Protocol consumption | All site capabilities scanned |
| refused | Without accepted, observed/defaultPrevented etc. | Refusal/boundaries | Treat as absent and bypass |
| unavailable | No observed protocol handling | Only this permits next DOM attempt | No capability anywhere on the page |
| DOM continuation | allowed/adapter guards remain | Focus/draft/page/request | Unconditional writing/sending |
| Exception/unknown | Not automatically unavailable | Effects/unknowns retained | Definitely no write, safely replay |
| Receipt layers | Isolated Bool receipts differ from page bridge | Actual layer/outcome | Any non-Bool means sent |

</div>

## Synthetic bridge note

refused: stop rather than relabel unavailable to try another composer. accepted: report protocol acceptance, inspect actual content, and do not invent sent/executed. No real handoff ran.

The native path makes no submit call, but arbitrary site behavior is not certified. Protocol observation is not scanning, account identity or universal idempotency. Compatibility cannot justify fake bridges or changing locks/sending state.

## FAQ

<h3 id="faq-1">Can refused be treated as absent bridge?</h3>

No. Native refusal does not continue DOM fallback.

<h3 id="faq-2">Does unavailable prove no site capability?</h3>

No. It is this observed protocol outcome; later adaptation remains guarded.

<h3 id="faq-3">Does accepted prove business handling?</h3>

No. Acceptance, placement, sending, receipt and handling differ.

<h3 id="faq-4">Does preventDefault always override accepted?</h3>

No. accepted=true wins; otherwise cancellation can yield refused.

<h3 id="faq-5">Can exceptions trigger another composer/replay automatically?</h3>

Do not blindly downgrade/replay; retain unknown request/target state.

<h3 id="faq-6">Was a bridge configured/tested?</h3>

No. Fixed protocol review only, without page changes/services.

## Reading and source

[Page/origin](/en/guides/workbench-origin-page-boundaries/) · [One handoff](/en/guides/recording-notes-handoff/) · [Completion evidence](/en/guides/handoff-evidence-audit-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Three-state bridge](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift) · [Insertion branches](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift)
