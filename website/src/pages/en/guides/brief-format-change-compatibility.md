---
layout: ../../../layouts/Wave3Guide.astro
title: "Before changing a structured-note or Radar brief format: compatibility and meaning"
description: "Separate editorial-template revisions from actual PM Radar export contracts. Review required keys, types, scope and approval semantics without adding migration or field-conversion features."
lang: en
---

<h2 id="first-answer">A revision label is not compatibility evidence, and a note template is not the Radar protocol</h2>

An editorial structured note can have its own revision, but that does not make it an app import schema. Radar reads the contract in the actual source version. Review editorial meaning and producer JSON changes separately. Renaming keys to resemble `tasks`, or writing v2 in a file, does not establish migration, feature support or execution approval.

## A separate task from types and batch values

Single-file checks inspect shape; batch comparison inspects source-record differences. Here the question is **whether changing a producer/template would change consumer compatibility or confirmation meaning**. Do not make universal promises for old/future clients; compare the actual intended source/build and existing workflow.

## Format-change review table

<div role="region" aria-label="Brief-format compatibility review, scroll horizontally" tabindex="0">

| Change | Existing contract to inspect | Risk example | Go/stop evidence |
| --- | --- | --- | --- |
| Editorial key name | An editorial label, not an app field | proposals renamed decisions implies approval | Preserve meaning; renaming grants no authority |
| Required root keys | Existing date_str, decisions, active/stale/cold types | Replacing arrays with projects loses required fields | Stop on missing keys; no invented defaults |
| Optional tasks | Missing/null fallback versus explicitly empty [] | Adding [] changes interpreted scope | Record scope/meaning rather than claiming all tasks vanished |
| Field type | Actual String/Double/Bool/array declarations | Number becomes text; Bool becomes string | No assumed coercion; validate the actual consumer |
| Added fields | Fields recognized/validated by the intended version | New key assumed to provide UI/capability | Key presence is not support; inspect implementation |
| Time meaning | Source read, task update and editorial time | date_str becomes export time | Keep source meaning explicit, not artificially fresh |
| Identity/scope | project/path/id and permissions | Renaming/changing sources treated as the same tasks | Do not match automatically; retain unknown provenance |
| Reply meaning | Read access, reply_supported and write authority differ | New true flag triggers real replies | Original eligibility, phone confirmation and receipt gates remain |

</div>

## One synthetic editorial revision

```text
Old editorial label: unconfirmed_proposals = Suggest reviewing a sample checklist.
Proposed label: confirmed_decisions = Suggest reviewing a sample checklist.
Risk: Renaming falsely turns an unapproved proposal into a decision.
Review decision: Reject this meaning change; retain an unconfirmed proposal. Create no task.
```

These labels are not importable JSON or an executed migration test. A team with an authorized exporter must maintain its actual contract through that process. This page neither converts templates into Radar records nor supplies scripts to modify a live source.

## Fix the consumer version first

Record the intended source/build, then compare its snapshot fields instead of declaring the new format compatible. Keep non-sensitive synthetic before/after fixtures identifying required keys, types, absence and meaning. Parsing is not post-decode size/date/identity/timestamp acceptance, much less device, permission or production acceptance.

On a mismatch, do not fill now, copied tasks or completed status merely to hide an error. Stop adoption and report through the existing producer-maintenance workflow. Do not alter source permissions or bypass validation. No schema negotiation, automatic downgrade or migration database is added.

## FAQ

<h3 id="faq-template">Does changing the minutes template update Yihu fields?</h3>

No. Editorial labels and app models are different contracts. A template revision creates no interface, import field or service capability.

<h3 id="faq-version">Does a v2 label establish version negotiation?</h3>

No. Inspect actual source support; a file declaration does not certify the consumer supports a new contract. This guide implements no negotiation.

<h3 id="faq-rename">Can proposals simply be renamed decisions without changing content?</h3>

Names can change interpretation. Without separate approval, unconfirmed suggestions cannot become decisions or execution authority by renaming.

<h3 id="faq-new-key">Does an added producer key work with every client?</h3>

No blanket claim follows. Recognition, ignoring and validation depend on the actual version. A new key also supplies no UI/native enhancement without implementation evidence.

<h3 id="faq-empty">Is adding empty tasks only formatting?</h3>

No. Missing/null trigger legacy fallback, while [] explicitly supplies an empty ledger. Scope meaning can change and needs source confirmation.

<h3 id="faq-test">Does this replace Swift decoding and device acceptance?</h3>

No. It is manual revision review, not execution of app decoding or checks of real permissions/data. Tests must bind to an actual consumer version and scope.

## Reading and evidence

[Single-file types/nulls](/en/guides/radar-json-null-validation/) · [Same-source batch values](/en/guides/radar-snapshot-batch-comparison/) · [Editorial minutes fields](/en/guides/meeting-notes-brief-fields/) · [Degraded-handoff decision](/en/guides/degraded-handoff-go-no-go/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [Radar fields/decode](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [README source/write boundaries](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
