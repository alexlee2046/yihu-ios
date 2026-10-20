---
layout: ../../../layouts/Wave3Guide.astro
title: "Reply timeout or oversized response: transport limits do not prove no write"
description: "Review 20k request bytes, 40k/128 KiB responses and operation-specific timeouts. Client budgets are not service SLAs or permission to resend."
lang: en
---

<h2 id="first-answer">Byte/time limits protect the consumer; they are not business results or response SLAs</h2>

Native reply bodies are capped at 20000 bytes. Non-history responses are capped at 40000 bytes; history at 128 KiB, including streaming enforcement. Request/resource timeouts vary by operation. Hitting limits does not establish that nothing was recorded server-side and cannot automatically authorize resending. No request, new API or tuning feature is supplied.

## Different from URL, identity and retrieval review

URL preflight checks shape, request mapping checks identity/receipts, and retrieval checks coverage. Here **why client transport settings may terminate reading and what that proves** matters. Original models, identity and target checks remain.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Request body | Up to 20000 bytes, including JSON metadata | Encoded total, not text length | 20000 characters always deliverable |
| Non-history response | Up to 40000 bytes | Actual response/decoding | HTTP success means business success |
| History response | Up to 128 KiB | Stream count/model validation | All history in one response |
| Content-Length | Oversize rejected early; stream still bounded | Unknown/untrusted length versus actual bytes | No header means unlimited reading |
| Request timeout | History 45 seconds, others 25 | Client configuration/actual error | Service completion deadline promised |
| Resource timeout | History 60 seconds, others 45 | Separate resource budget | End-to-end handling SLA |
| Session/redirect | Native cookie/credential stores separate; no automatic redirect | Original source/actual authority | Browser login becomes native write access |
| Uncertain submit | Original pending/check path remains | Request identity/real outcome | Failed response read means no effects |

</div>

## Synthetic transport note

Known: response reading timed out after a submit. Unknown: whether the reply was recorded. Preserve pending and use original check; do not invent absent or blindly change URLs/request IDs.

Bytes/times are source settings, not load, uptime, network-latency or cost evidence. Page login/native authority cannot be inferred from each other. Source/epoch/version/confirmation guards remain.

## FAQ

<h3 id="faq-1">Does 20k body mean 20k CJK characters?</h3>

No. It counts JSON-encoded bytes including metadata, not a direct character allowance.

<h3 id="faq-2">Does an oversized response prove no write?</h3>

No. Reading failure differs from server outcome; check the original request.

<h3 id="faq-3">Is reading unlimited without Content-Length?</h3>

No. Streaming enforces byte limits too.

<h3 id="faq-4">Do 45/60 seconds guarantee completion?</h3>

No. They are separate client configurations, not business SLAs.

<h3 id="faq-5">Can redirects automatically continue on another site?</h3>

The native path refuses automatic redirects; compatibility does not relax source/access boundaries.

<h3 id="faq-6">Was an endpoint/load test run?</h3>

No. Fixed source only, without actual requests, performance or availability acceptance.

## Reading and source

[Feed URL](/en/guides/radar-feed-url-boundary-preflight/) · [Request/receipt mapping](/en/guides/reply-request-receipt-mapping/) · [History coverage](/en/guides/history-retrieval-manual-comparison/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Byte/time/redirect boundaries](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [Consumer models](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
