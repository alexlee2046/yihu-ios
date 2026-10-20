---
layout: ../../../layouts/Wave3Guide.astro
title: "Map reply evidence to request identity, target version and pending receipts"
description: "Review native persist-before-submit, check and recorded paths. Similar text/timeouts are not retry authority; no universal idempotency or archive service."
lang: en
---

<h2 id="first-answer">Identical text is not request identity, and recorded is not executed</h2>

Native Radar replies persist a pending record with requestID before submit so uncertain writes do not silently become new replies. Unclear network outcomes require check. Recorded means retained/pending handling; authorization-confirmed notices explicitly say not executed. Map evidence to actual request/target rather than similar text, nearby times or transport stages.

## Different from completion claims and role approval

Review **request identity against pending state/receipts**, not content approval or universal exactly-once delivery. No request is sent, local record cleared or backend idempotency service implemented.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| request_id | UUID request association | Same operation/original record | Same text means same ID |
| Target id/version/epoch | Current-target/source guards | Confirmed version/source | Title/URL appearance identifies target |
| Persisted pending | Save submitted state before sending | Successful save/original identity | Permanent archive/backup service |
| Uncertain transport | Keep pending and check | Timeout versus explicit rejection | Timeout means never written |
| check recorded | Recorded path | Original request/actual response | Business execution/every role done |
| check absent | Prepare again, retain same requestID | Original entry/confirmation | Delete markers to manufacture another ID |
| Explicit rejection | Selected branches may clear then renew ID | Actual error/cleanup result | Every failure safely retryable |
| Editorial retention | Request/version/scope/receipt mapping | Authorized necessary data only | New log database or every backend exactly-once |

</div>

## Synthetic mapping review

A: request alpha, unresolved. B: same text, unknown request identity. Do not combine into one success or resend A because B lacks a receipt. Follow original check flow.

Pending records are not hand-edited archive APIs. Source backup exclusion/file protection does not establish permanent retention/recovery. Editorial archives cannot alter request IDs, source epoch or authority to bypass uncertainty.

## FAQ

<h3 id="faq-1">Does identical prose identify one request?</h3>

No. Use actual request/target/source relationships, not text-only deduplication.

<h3 id="faq-2">Can timeout justify a new ID and immediate resend?</h3>

No. Original handling preserves pending and checks first; uncertain transport is not rejection.

<h3 id="faq-3">Does recorded prove execution?</h3>

No. It means retained/pending handling; authorization confirmation explicitly remains unexecuted.

<h3 id="faq-4">Does absent always create a new ID?</h3>

This path keeps the same requestID and prepares again instead of manufacturing another write.

<h3 id="faq-5">Is pending storage a permanent backup?</h3>

No. It supports uncertain-result recovery; file protection/exclusion is not archival or restore SLA.

<h3 id="faq-6">Is exactly-once guaranteed for arbitrary services?</h3>

No. Current client/protocol review does not establish every backend's behavior.

## Reading and source

[Completion claims](/en/guides/handoff-evidence-audit-checklist/) · [Role confirmation](/en/guides/multi-role-approval-receipt-checklist/) · [Material retention](/en/guides/batch-change-record-retention/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Persist/submit/check/recorded](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [Target/history models](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
