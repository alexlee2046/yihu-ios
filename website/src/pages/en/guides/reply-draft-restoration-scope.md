---
layout: ../../../layouts/Wave3Guide.astro
title: "Whose restored reply draft is this? submitted, original target and source binding"
description: "Separate unsent drafts, pending records and current selection. Restored text is not submission or send authority; no cloud sync or background relay."
lang: en
---

<h2 id="first-answer">Restored text is not a receipt and may still belong to the earlier target</h2>

Native replies load per-workbench local records, verify saved source and restore text, target and requestID. Explicit submitted=false denotes an unsent draft; missing/unclear state conservatively restores pending. The target can differ from current selection, with prepare prompting review of the earlier draft. Visible text proves neither server receipt nor authority for a new target.

## Different from pending receipts and material retention

Receipts inspect attempted writes; retention maps review material. Here **local pre-submit restoration and its source/selection relationship** matter. No file is edited/deleted, and no cloud draft/sync/background sender is added.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Local read | Size/decode/source URL conditions | Failure/original retained record | Silently discard bad files and send |
| Source match | saved.source must match | Actual source/state | Same workbench name means same source |
| Restored fields | Text/target/requestID together | Original target/current selection | Text belongs to newly opened task |
| submitted=false | Unsent draft branch | Persistence/current authority | Server recorded or approved |
| Missing submitted | Conservative pending restoration | Original check flow | Definitely unsent, safely retry |
| Prepare | Fresh target read/change notice | Status/next/original target | Old local version always valid |
| Unreadable record | Blocked, original retained | Actual error/maintenance | Rename/delete markers to bypass |
| Editorial archive | Draft/submit/receipt separated | Minimal authorized material/version | Permanent archive/cloud relay |

</div>

## Synthetic restoration review

Task B is selected, but restored targetID identifies earlier task A. Do not reinterpret A's text as B's approval or silently change ownership. Review original/latest target; unknown submitted cannot be filled false.

Saved drafts remain local. Failure notices preserving current-page input are not backup guarantees. Original canSend/source/target/4000-Unicode-scalar conditions remain; no internal-file bypass instructions are supplied.

## FAQ

<h3 id="faq-1">Does restored text mean service receipt?</h3>

No. Draft, pending submit and recorded differ.

<h3 id="faq-2">Must a draft belong to the clicked task?</h3>

No. It can restore an earlier item; inspect target/notices.

<h3 id="faq-3">Does absent submitted mean false?</h3>

Current restoration conservatively treats it pending, not definitely unsent.

<h3 id="faq-4">Do drafts automatically transfer to a changed source?</h3>

Do not infer that. Source checks can block while retaining originals.

<h3 id="faq-5">Is a local draft permanent cloud backup?</h3>

No cloud sync/retention/restore SLA is added.

<h3 id="faq-6">Can internal file edits unlock sending?</h3>

Do not bypass guards or fabricate state. Use actual source/target and existing maintenance.

## Reading and source

[Pending/receipts](/en/guides/reply-request-receipt-mapping/) · [Material retention](/en/guides/batch-change-record-retention/) · [Target/context](/en/guides/follow-up-context-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Restore/prepare/preserveDraft/canSend](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [PendingReply fields](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
