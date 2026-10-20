---
layout: ../../../layouts/Wave3Guide.astro
title: "Does waiting mean approval? Archive raw status, display aliases and reply eligibility"
description: "Review trimmed/lowercase explicit status aliases. waiting/done icons are not approval/execution evidence, source rewrites or a new workflow engine."
lang: en
---

<h2 id="first-answer">A display category is not a source rewrite, approval or reply permission</h2>

CollieRadarTaskState.classify trims/lowercases then matches explicit aliases. waiting/pending can map to waiting; done/completed to completed; unmatched stays unknown. Display meaning neither rewrites source text into another status nor independently proves approval, completion or reply eligibility.

## Different from missing defaults, roles and batch review

Defaults concern placeholders, roles concern who confirms, batches concern original inputs. Here **nonempty raw status versus derived display categories** need separate retention. No source edit/enum migration or relabeling to unlock writes is performed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Raw status | Actual supplied string | Original/source/version | Category is the raw value |
| Classification | Trim/lowercase explicit aliases | Derived versus raw | Every control/write path normalizes identically |
| waiting/pending | Can map to waiting | What is awaited | Your approval/acceptance necessarily awaited |
| done/completed | Can map to completed | Source claim versus actual evidence | Execution or PM acceptance proven |
| Unknown alias | Falls to unknown | Keep original/gap | Nearest known state guessed |
| Reply eligibility | Actual target/capability/version separately | Original entry/fresh target | Waiting icon grants writes |
| Translation/editing | Label editorial presentation | Original versus explanation | Relabeling creates approval |
| Comparison/retention | Raw status/category/reason | Same category/different source/scope | Same category means same event |

</div>

## Synthetic status record

A has raw pending and derived waiting. B has raw 等你验收, also waiting. Shared category does not establish the same recipient, operation authority or approval. Do not replace A with B's source wording.

Source status is still a source claim requiring truth/completion evidence. Reply availability depends on the original flow/current target; classification alone establishes neither always writable nor never writable, and cannot bypass guards.

## FAQ

<h3 id="faq-1">Can pending be treated as 等你验收?</h3>

No. Grouping does not equate original text, awaited person or approval scope.

<h3 id="faq-2">Does done prove backend execution?</h3>

Not independently. It classifies explicit source state; execution/acceptance need evidence.

<h3 id="faq-3">Does unknown guess the nearest state?</h3>

Unmatched classification stays unknown; invent no business conclusion.

<h3 id="faq-4">Does display trimming apply to every write path?</h3>

No inference follows. Inspect each entry's conditions.

<h3 id="faq-5">Can relabeling status grant reply eligibility?</h3>

No. Target/capability/version/identity authority is not granted by edited labels.

<h3 id="faq-6">Can shared category merge history or approvals?</h3>

No such feature is added. Retain raw values/events/scopes instead of replacing associations with categories.

## Reading and source

[Placeholders](/en/guides/empty-field-display-defaults/) · [Roles/confirmation](/en/guides/multi-role-approval-receipt-checklist/) · [Batch scope](/en/guides/radar-snapshot-batch-comparison/) · [Request identity](/en/guides/reply-request-receipt-mapping/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Explicit classification](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [Raw display/entry](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift) · [Current reply guards](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift)
