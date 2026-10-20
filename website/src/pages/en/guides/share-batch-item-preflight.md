---
layout: ../../../layouts/Wave3Guide.astro
title: "Review every item before sharing a mixed batch of text, links and attachments"
description: "Tray counts do not establish per-item content/permission review. Files-first and later text insertion are separate stages, not bulk sending, atomic rollback or batch approval."
lang: en
---

<h2 id="first-answer">A batch is a staging container, not per-item validation or atomic delivery</h2>

The share tray can retain multiple batches containing text, links and files. Its total is a count. Existing placement handles files first, updates/removes their staged items after attachment, then inserts non-file text. Errors can stop at a stage. Review each item's content, type, authority and destination instead of calling one placement business acceptance, a transaction or bulk message sending.

## Different from multi-note review and completion auditing

Multi-note review concerns originals/edits/order; completion auditing concerns final claims. Here **mixed items may have reached different stages**. No sharing is performed and no bulk sender, approver, per-item scanner or global rollback service is added.

## Per-item and stage checks

<div role="region" aria-label="Mixed-batch item/stage checks, scroll horizontally" tabindex="0">

| Item/stage | Existing boundary | Inspect individually | Does not establish |
| --- | --- | --- | --- |
| Total | itemCount sums staged items | Original, type and necessity beyond the count | N items means N validated |
| Text | Non-file text joined with newlines before insertion | Meaning, order, source and instruction boundaries | Structured item semantics survive joining |
| Link | Actual target/disclosure scope still matters | Source, path/query and authorized destination | Clickable means trusted/redacted |
| File | Page-owned upload control is separate | Every attachment's content, type and copies | Approved prose approves attachments |
| Files attached first | Staged file entries updated/removed before text | A remote copy may exist | Later text failure means no file uploaded |
| Multi-file limit | Page can report one file at a time | Actual control limits/remaining items | Every page supports arbitrary bulk files |
| Text insertion failure | Can stop after an earlier stage | Destination content and remaining tray | Replaying everything is duplicate-free |
| Batch leaves tray | Placement is not sending | Draft, attachments and actual service state | Atomic transaction, business approval or receipt |

</div>

This is source-described sequential handling, not acceptance of every website. Neither tray count nor presence provides automatic content/permission review for each item.

## Synthetic staged review

```text
A: Synthetic text, content/destination reviewed.
B: Synthetic attachment, content unreviewed.
Decision: A passing does not approve the batch; stop and review B.
If file handling already occurred: Inspect destination/remaining tray; failure did not necessarily recall everything.
```

This is not an upload log and uses no page/customer data. Joined paragraphs are not original task IDs or a server bulk protocol. Preserve original item relationships within existing permissions.

## Gaps do not authorize replaying a batch

Review every item before adoption. One-file limits, missing controls or unsupported types require actual-entry handling, not guessed hidden upload support.

After an attempt, inspect possible uploads, inserted text and remaining items. Local counts do not prove no remote copy exists. Note reservations and target guards remain; edits, splits or renamed files do not erase markers or authorize resending.

## FAQ

<h3 id="faq-count">Does six items mean six reviewed and ready to send?</h3>

No. Count does not establish content, permission, destination, sending or business approval.

<h3 id="faq-atomic">Is one placement atomic for the whole batch?</h3>

No such claim follows. Files precede text and earlier stages can occur before an error. No transaction rollback is added.

<h3 id="faq-attachments">Does prose approval replace reviewing every attachment?</h3>

No. Each file's contents, type, sensitive layers and destination need independent review.

<h3 id="faq-one">Does a one-file page automatically gain bulk support?</h3>

No. Follow actual page restrictions. No universal bulk upload interface is added.

<h3 id="faq-failure">Does failed text insertion mean earlier files were never uploaded?</h3>

No. Inspect target/tray state; a local failure does not undo every prior stage.

<h3 id="faq-send">Does an empty tray mean the recipient read or handled the task?</h3>

No. Placement, sending, receipt and business handling differ and require their own evidence.

## Reading and source

[Multi-note review](/en/guides/multi-note-review-handoff/) · [Carrier redaction scope](/en/guides/carrier-redaction-archive-matrix/) · [Completion audit](/en/guides/handoff-evidence-audit-checklist/) · [Multi-role confirmation](/en/guides/multi-role-approval-receipt-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [tray counts/files-first flow](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShareTray.swift), [staged batch model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift).
