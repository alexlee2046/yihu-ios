---
layout: ../../../layouts/Wave3Guide.astro
title: "Retrieve and compare history: pagination, omitted text and no-match boundaries"
description: "Read-only source history differs from authorized external archives. Five-item pages and 100 loaded entries are not a full index; no match does not prove no event."
lang: en
---

<h2 id="first-answer">Check saved material before deciding to record or compare again</h2>

Source reply history is not a local full-archive search engine. Current target history loads read-only in pages of at most five; UI loads at most 100 entries. Longer text can be text_omitted with a pointer to the original. Existing authorized tools handle external archives. No match does not establish that an operation, material or feedback never existed.

## Different from change-material retention

Retention maps conclusions to originals. Here **retrieval coverage and manual comparison of matches** matter. No index, archive database, restore service or full-text API is created.

<div role="region" aria-label="Review matrix, scroll horizontally" tabindex="0">

| Check | Existing boundary | Review | Not established |
| --- | --- | --- | --- |
| Source history | Target/current-source checks before loading | Identity, target and access | Global organization/task search |
| Pages | Up to five with cursor rules | Loaded/total and remaining pages | First page is complete |
| UI cap | At most 100 loaded | Unloaded scope/original entries | Nothing exists beyond cap |
| Omitted text | text_omitted can indicate longer original | Authorized original full text | Empty display means empty original |
| Version consistency | Paging checks totals/target version | Recheck changes through original entry point | Arbitrary-time pages form a stable whole |
| External archive | Separate authorized tools | Locations/date/version/alias coverage | App has cross-account global indexing |
| Manual comparison | Original references/version/actual text | Same names, conditions and unknowns | Similar prose means same approval/execution |
| No match | Access/omission/loading/scope can limit results | Record coverage and gaps | Never occurred or safe to retry |

</div>

## Synthetic retrieval record

Location: loaded history for one sample target. Coverage: first five entries. Unknown: remaining pages/omitted text. Result: no match within this scope only.

Query/location/version/coverage are editorial labels, not app-issued search certificates. Do not publish private archives or expand third-party access to find full text. Similar words are not receipts, retrieval time is not event time, and no match cannot justify retrying uncertain operations.

## FAQ

<h3 id="faq-1">Does a 100-entry cap mean only 100 exist at the source?</h3>

No. UI loading differs from source total/unloaded scope. Unloaded is not absent.

<h3 id="faq-2">Does a five-entry page include every task?</h3>

No. It is target history pagination, not global task search or a complete archive.

<h3 id="faq-3">Can empty text with text_omitted be treated as an empty original?</h3>

No. Content was omitted; inspect the authorized original.

<h3 id="faq-4">Can pages from different versions be freely combined?</h3>

No. Existing paging checks consistency. Mark cross-version manual material instead of claiming a stable whole.

<h3 id="faq-5">Does no match prove nothing was sent?</h3>

No. Check coverage/prior evidence; no match bypasses neither reservations nor uncertainty.

<h3 id="faq-6">Does Yihu supply archive full-text search and restore?</h3>

No such capability is added. External archives use existing authorized tools; source history remains read-only.

## Reading and source

[Change-material retention](/en/guides/batch-change-record-retention/) · [Completion evidence](/en/guides/handoff-evidence-audit-checklist/) · [Time meanings](/en/guides/timezone-timestamp-review/) · [Confirmation scope](/en/guides/multi-role-approval-receipt-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Loading cap/omission UI](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [Pagination/consistency model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
