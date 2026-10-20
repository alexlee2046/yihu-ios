---
layout: ../../../layouts/Wave3Guide.astro
title: "After noisy dictation: manual text correction and draft-copy checks"
description: "Separate original transcription, editorial corrections and destination drafts. Editing text is not another authorized handoff, synchronization of every copy or noise-accuracy evidence."
lang: en
---

<h2 id="first-answer">Work from existing text; editing does not repair audio or every retained copy</h2>

Noise can produce incorrect words, but Yihu audio settings do not guarantee recognition accuracy in noisy conditions. For an existing transcript, retain reviewable original wording, identify an authorized editing location and compare the corrected version with the destination draft. This workflow does not request repeated recording, add correction/version-sync/noise-reduction features or authorize another handoff merely because text changed.

## A different task from capture diagnosis and passage review

With no audio or recognized text, use input troubleshooting first. For quantities, negations and joins within a longer recording, use passage review. Here the task is **which text objects actually changed after manual correction**. Retained text, a controlled document, clipboard, web draft and attachment can be separate copies. Updating one does not establish updates elsewhere.

## Correction objects and copy checks

<div role="region" aria-label="Manual correction and retained-copy checks, scroll horizontally" tabindex="0">

| Object/stage | Retain first | Safe check | Not established |
| --- | --- | --- | --- |
| Original transcript | Original wording and genuinely reviewed scope | Check authorized audio/text; mark unknown without evidence | Editing changes original audio |
| Corrected draft | Before/after wording and reason | Edit only in an existing authorized editable location | A universal app correction screen or automatic version archive |
| Inserted draft | Actual destination and existing unsent text | Check whether insertion already happened before editing there | Another automatic insertion is duplicate-free |
| Clipboard | Whether an old version was copied | Inspect only necessary content in an authorized location | New text replaces prior clipboard copies |
| Staged attachment | Actual text/Markdown in the tray | Check the specific version/target and original handoff state | Local correction recalls an uploaded attachment |
| Unclear wording | Unverified unit, name or negation | Keep pending through an existing confirmation process | Fluent/plausible wording establishes truth |
| Host refusal | Explicit refusal/unknown-editor state | Retain originals and stop that path | Rewording bypasses host guards |
| Uncertain result | Original note's reservation and destination content | Inspect before creating another delivered copy | Rephrasing is new permission, deduplication or exactly-once delivery |

</div>

## One synthetic correction

```text
Unreviewed recognition: Send two sample checklist items.
Authorized original evidence: Do not send the sample checklist; item count is unconfirmed.
Proposed manual correction: Do not send; item count pending confirmation.
Still unknown: Whether the destination already contains the old sentence.
```

Do not retain two just to make a sentence complete, or assume an old web draft changed when the local correction exists. This is not an actual recording result. Do not publish customer conversations, orders or private meeting material to reproduce it. Without evidence, mark unknown rather than inventing the correct sentence.

## One path from correction to possible handoff

1. Confirm a safe stationary environment and text source. End unnecessary playback/capture you started; repeated recording or volume increases do not establish unmeasured performance.
2. Distinguish the original retained for review from proposed replacement wording, with reasons. This page specifies no native editing control.
3. Inspect existing destination text and confirm an authorized unsent draft, not a terminal, sending interface or unknown editor.
4. If manual destination editing is appropriate, check that host's save/sync rules first. Do not force insertion or press Send automatically.
5. Keep one-handoff and uncertain-stop state for an already attempted note. Correction does not clear it, and manual copying can still duplicate.

## FAQ

<h3 id="faq-noise">Does corrected text prove robust noisy recognition?</h3>

No. Editorial correction is different from model recognition results. There are no headset/noise-level/accuracy/wind-noise benchmarks here.

<h3 id="faq-editor">Does Yihu provide the automatic correction or sentence editor described here?</h3>

No such feature is asserted. Work manually only in actually available authorized editable tools/drafts, without inferring new app controls.

<h3 id="faq-sync">Does a local correction update web drafts and attachments?</h3>

Do not assume that. Check original, clipboard, draft and attachment separately. Each destination controls save/sync; this page adds no cross-copy updater.

<h3 id="faq-resend">Can correction permit clearing a marker and inserting again?</h3>

No. Do not bypass one-handoff guards through editing. Inspect destination text and retain uncertain-stop state; copying is not a deduplication guarantee.

<h3 id="faq-unknown">What if a quantity or name cannot be confirmed?</h3>

Leave it pending rather than guessing from context. Use authorized evidence/confirmation, not an inference labeled verified or approved.

<h3 id="faq-remote">Does deleting the old local draft recall data received remotely?</h3>

Not as a general promise. Uploaded, synced or sent copies follow destination policies. Local deletion and remote recall are different operations.

## Reading and evidence

[Input diagnosis](/en/guides/bluetooth-audio-input-troubleshooting/) · [Single-record passage review](/en/guides/recording-segment-review-labels/) · [Originals and one handoff](/en/guides/recording-notes-handoff/) · [Department ownership/archive checks](/en/guides/department-minutes-ownership-archive/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [draft/refusal guards](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift), [note handoff model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift), [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
