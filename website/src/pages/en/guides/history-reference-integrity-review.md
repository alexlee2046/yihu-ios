---
layout: ../../../layouts/Wave3Guide.astro
title: "Associate history feedback: target, position and references checks"
description: "Review target components, entry identity and explicit references. Valid structure is not read/handled status, and similar text cannot replace association."
lang: en
---

<h2 id="first-answer">Later text is not necessarily feedback; an explicit link is not completion</h2>

CollieRadarReplyHistory associates only later-position updates whose references explicitly identify the reply's request_id or, outside draft mode, its URL. History also checks target, entry identity, positions and URL components. This read-only structure is not reading, completion or truth certification. No history database/association engine is added.

## Different from retrieval and request receipts

Retrieval checks coverage; receipts check submission. Here **whether fetched history belongs to the target and which records associate with a reply** matters. No original is fetched or private record edited.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Entry identity | Nonempty unique id, reply/update kinds | Actual entries/loaded IDs | Identical text means same record |
| Target URL | Host/port/path/query checks | More than domain appearance | Any cross-task comment can be merged |
| Position | Order/loading counts consistent | Earlier/later relationship | Nearby times establish association |
| request_id | Reply has valid UUID | Actual explicit reference | UUID proves approval/signature |
| references | Count/uniqueness/reference shape | Canonical lowercase UUID or permitted comment reference | Body semantics guessed |
| Feedback | Later update explicitly references reply | Association versus meaning | Read/done/approved |
| Draft history | Specific URL/time-field conditions | Draft versus non-draft | Unconditional mixed history |
| Editorial retention | Target/original links/unknowns | Authorized scope only | Cross-account index/immutable log |

</div>

## Synthetic association review

A later entry says seen but references do not identify the original sample reply. Prose alone does not establish feedback for that reply. Conversely, valid association still needs content review instead of automatic handled status.

Matching target components does not authenticate origin. Keep structural gaps instead of fabricating references. No real history read, account authorization or cross-target merge ran.

## FAQ

<h3 id="faq-1">Does any later mention establish feedback?</h3>

No. Explicit references, position and kind matter; no semantic guessing.

<h3 id="faq-2">Do valid references mean handled?</h3>

No. Association differs from actual feedback, reading and completion.

<h3 id="faq-3">Can all same-domain comments form one history?</h3>

No. Port/path/query, target and entry rules also apply.

<h3 id="faq-4">Does UUID shape prove an approver?</h3>

No. Reference shape provides neither identity nor authority.

<h3 id="faq-5">Can draft and formal history be freely combined?</h3>

No. URL/time and paging consistency need separate review.

<h3 id="faq-6">Can invented references repair a failure?</h3>

Do not fabricate associations. Preserve originals/gaps and use real source maintenance.

## Reading and source

[Retrieval scope](/en/guides/history-retrieval-manual-comparison/) · [Request receipts](/en/guides/reply-request-receipt-mapping/) · [Confirmation scope](/en/guides/multi-role-approval-receipt-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[History validation/feedback](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [Read-only loading](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift)
