---
layout: ../../../layouts/Wave3Guide.astro
title: "Trace a manual opportunity-task summary: sentence-to-field provenance"
description: "Map each editorial summary sentence to authorized source fields, distinguishing attributed status, proposals and independent conclusions. No summary engine, opportunity feed or automatic citations."
lang: en
---

<h2 id="first-answer">Shorter wording must not expand evidence; trace each sentence to its source</h2>

Teams supplying existing inquiry/follow-up tasks as PM Radar JSON may write manual summaries; this article adds no opportunity-summary engine. Establish source/scope, then map sentences to fields and retain unknowns. Waiting for acceptance cannot become accepted, and a link cannot turn a proposal into approval or an independently verified external fact.

## Different from second checks and batch comparison

Second checks assess evidence for one anomaly claim; batch comparison establishes comparability of exports. Here **compressing several fields into a sentence must preserve conditions, attribution and scope**. Sentence numbers, source labels and citation tables are editorial aids, not app-generated reference IDs or an audit feature.

## Sentence-to-field provenance table

<div role="region" aria-label="Manual Radar summary provenance, scroll horizontally" tabindex="0">

| Summary content | Source field/evidence | Supported attribution | Do not rewrite as |
| --- | --- | --- | --- |
| Project/item identity | project, existing id and reviewed source | Sample item in this source | Same title proves the same customer/order |
| Item title | Original title/context | Source says review is needed | Wording proves an actual urgent event |
| Current state | Explicit status if supplied | Source labels waiting for acceptance | Accepted, approved or complete |
| Proposed next step | Conditions, negations and proposals in next | Source suggests review first | Execution authorized or sending scheduled |
| Priority | priority and source explanation | Supplied P0/P1 or unknown | Specific loss/deadline or unknown means unimportant |
| Source time | date_str plus read/cache state | Within that source-read scope | A current live fact or refresh tap means fresh |
| Evidence reference | evidence and authorized original record | A reference exists; content needs review | HTTPS means true, non-private or approved |
| Unknowns/conclusion | Absent fields and unmapped claims | Pending review or remove unsupported sentence | Invented details to complete a summary |

</div>

## A synthetic sentence map

```text
Editorial source S-A: Sample item; status=waiting for acceptance; next=suggest review next time, not approved; priority absent.
Candidate sentence 1: The sample was accepted and execution authorized.
Mapping: Status does not support accepted; next explicitly lacks approval. Reject sentence 1.
Supported rewrite: Source marks the sample pending acceptance; next is an unapproved review suggestion, priority unknown.
```

S-A and sentence 1 are manual examples, not real task IDs, JSON fields or executed detector output. No real customer text/private evidence address or model call is involved. An authorized external summarizer still requires the same review; fluent prose is not evidence.

## Attribution, scope and reference locations

Retain original wording/location before writing attributed text such as source labels rather than a global assertion. Identify whether material is full `tasks`, a `decisions` subset, current filters or a Watch summary. Subset evidence cannot establish a whole-ledger conclusion.

Review private originals within existing permissions rather than copying full tasks or parameterized links into public summaries. A supplied field establishes a source value, not authority, truth or write permission. Unmapped sentences remain unreviewed or unused; do not fabricate decorative references.

## FAQ

<h3 id="faq-engine">Does Yihu automatically generate opportunity summaries/citations?</h3>

No engine is asserted or added. Existing source reads task JSON and summary carriers; sentence writing, numbering and mapping here are manual guidance.

<h3 id="faq-status">Can waiting for acceptance be shortened to accepted?</h3>

No. Waiting and completion are opposite states. Preserve status/attribution without turning a subset label into approval.

<h3 id="faq-title">Can a customer-like title establish the same customer record?</h3>

Not by title similarity. Verify source/stable item identity, and do not copy personal information into a public example.

<h3 id="faq-url">Is an HTTPS citation per sentence enough?</h3>

No. Review which claim the reference supports, permission, version and scope. Link shape alone validates neither truth nor approval.

<h3 id="faq-unknown">Can missing priority/time simply disappear from a summary?</h3>

Do not let omission imply verification. Mark unknown or omit conclusions that depend on absent evidence, without invented current time/low priority.

<h3 id="faq-write">Can a reviewed summary automatically be sent to a customer?</h3>

No automated sending/write authority is supplied. Text review, handoff approval and customer communication are different operations under original permissions.

## Reading and evidence

[Second-check evidence](/en/guides/radar-evidence-second-check/) · [Batch comparison](/en/guides/radar-snapshot-batch-comparison/) · [Format compatibility](/en/guides/brief-format-change-compatibility/) · [Follow-up minimization](/en/guides/followup-evidence-minimization/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [Radar fields/link parsing](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [README collection/reply limits](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
