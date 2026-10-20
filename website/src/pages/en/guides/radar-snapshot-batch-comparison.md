---
layout: ../../../layouts/Wave3Guide.astro
title: "Compare two task-brief JSON batches: source, scope and field changes"
description: "Manually compare authorized PM Radar exports after source/scope/identity checks. Nulls or absent records do not establish deletion or completion; no snapshot version store or automatic diff feature."
lang: en
---

<h2 id="first-answer">Establish comparability before calling records added, changed or missing</h2>

Two decodable JSON files can have different sources, permissions or export scopes. Yihu reads your Radar snapshots and bounded cache; this guide does not assert a historical snapshot store or automatic diff interface. For two already authorized exports, first check source/scope, then identities and fields. A record absent from a later batch does not prove deletion, completion or handling.

## A separate task from JSON type validation

Type checks concern one file's shape; batch comparison asks whether two files are comparable and which differences have evidence within that scope. Parsing both does not waive source checks, and filtered page results are not full source diffs. For inquiry/follow-up teams this remains generic ledger interpretation, not a trade-intelligence feed, customer-history tracker or notification service.

## Comparison prerequisites

<div role="region" aria-label="Manual Radar batch-comparison prerequisites, scroll horizontally" tabindex="0">

| Dimension | Check first | Common misreading | Conclusion boundary |
| --- | --- | --- | --- |
| Source identity | Same authorized workbench/export process | Same filename implies same source | No definite add/remove conclusion without identity evidence |
| Permission/scope | Same account scope, projects, history and export options | Invisible records were deleted | Record scope differences separately, not as business events |
| Collection | tasks supplied in both versus legacy decisions-only scope | Subtract pending subset from the full ledger | Match scope before making total-count claims |
| Identity | Source task id and project meaning | Same title means same task | Keep unlinked without stable evidence; do not invent IDs |
| Source time | date_str plus failed/refreshing state | Later file save means later source data | Separate source read from local export/edit time |
| Null fields | Original/new values and absence/null | P1 becomes null, so unimportant or complete | Report not supplied, not an inferred state |
| Sorting/filtering | Priority/time/search/status/history display | Changed position means changed task | Display order and source-field changes are different |
| Receipt/handling | Original item and separate confirmation | Field changes prove reply delivery/execution | Reading differences grants no writes, approval or execution |

</div>

## Two synthetic observation batches

This is a **manual comparison record, not a Radar import format**, real business data or output from an executed diff tool.

| Item | Earlier sample batch | Later sample batch | Supported wording only |
| --- | --- | --- | --- |
| Source scope | Claims sample scope; unverified | Claims sample scope; unverified | Observations remain pending until source/permission checks |
| date_str | 2026-10-18 09:00 | 2026-10-18 10:00 | Fixed historical illustration, not made fresh by publication |
| sample-A priority | P1 | null | Later example provides no priority; no inferred downgrade/completion |
| sample-A status | In progress | null | Later status is unknown, not an inferred outcome |
| sample-B | Present | Absent | Could be scope/permission/collection difference; deletion unproven |
| Display order | sample-B first | sample-A first | Position alone proves neither modification nor priority change |

After obtaining actual source evidence, compare raw fields only within the verified common scope. This page fetches no real data, writes no fields and sends no notifications. Do not retain customer content or credentials for a public demo. Source files and comparison notes still need authorized storage/access rules.

## A useful manual change record

Record verified/unverified source, batch scope, matching basis, old value, new value, unknowns and the role that confirms through an existing process. Do not turn differences directly into execution tasks. Same-named projects or field changes do not supply server authority. Label legacy missing-`tasks` scope as a subset rather than calculating completion against a full ledger.

When reading through the existing interface, check identical filters. Source priority/time/title sorting can alter positions, and missing timestamps have source-order fallback rules; this does not establish modified records. A Watch receives existing phone summaries, not proof of independent historical-batch reads.

## FAQ

<h3 id="faq-built-in-diff">Does Yihu automatically retain every snapshot and show diffs?</h3>

No such capability is asserted or added. This is comparison of two exports you already have permission to use. Existing offline cache and optional reply history are not a complete snapshot version history.

<h3 id="faq-missing-record">Can an absent later record be marked deleted or complete?</h3>

Not from absence alone. Check source, permission, collection and filters first. Missing from a batch is not a business-state receipt; seek independent source evidence.

<h3 id="faq-no-id">Can matching titles substitute for a stable ID?</h3>

Do not treat similarity as reliable identity. Leave unmatched and ask the existing export process for stable evidence. A temporary invented ID is not source identity.

<h3 id="faq-null-change">Can null priority/status mean canceled?</h3>

No. An unsupplied optional field stays unknown; do not automatically map it to canceled, complete, low priority or deleted.

<h3 id="faq-date-order">Does later filesystem modification establish newer source contents?</h3>

No. Copy/export/edit times differ from `date_str` and task timestamps. Failed reads and clock problems also need separate inspection.

<h3 id="faq-writeback">Can a detected change automatically email a brief or update a task?</h3>

No automated email, notification or writeback is supplied. Difference reading, server authority, phone confirmation and receipts are separate capabilities; observations do not replace approval.

## Reading and implementation

[JSON types/nulls](/en/guides/radar-json-null-validation/) · [Multi-project Radar/Watch](/en/guides/multi-project-radar-watch/) · [Weak-network/cache diagnosis](/en/guides/offline-workbench-handoff-troubleshooting/) · [Editorial brief fields](/en/guides/meeting-notes-brief-fields/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [fields/filtering/sorting](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [source/bounded cache](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift), [README read/reply boundaries](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
