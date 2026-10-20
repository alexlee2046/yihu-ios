---
layout: ../../../layouts/Wave3Guide.astro
title: "Review multiple voice notes: sources, conflicts and unconfirmed to-dos"
description: "A manual checklist for multiple notes separates audio segments, transcripts, summaries and approved actions. It adds no Yihu merge feature or bypass of one-handoff guards."
lang: en
---

<h2 id="first-answer">An editorial summary is not automatic merging or deduplication</h2>

Existing Yihu notes retain their own local audio, transcript and handoff state. This guide suggests manually comparing sources, marking repetition/conflicts/gaps and checking unconfirmed to-dos before organizing text in an already authorized tool. It does not implement audio joining, cross-note merging, task extraction or deduplication. A new summary cannot erase uncertainty about an original handoff.

## Three meanings of multiple segments

- **Recognition segments within one recording**: current processing divides audio frames into windows, still within one note. It does not automatically identify speakers or topics.
- **Independent notes**: each can have different times, targets, text states and a one-handoff marker. Similar titles do not establish the same discussion.
- **An edited summary**: a manual document that must distinguish facts, proposals and open questions; it is neither original app audio nor an approved task list.

## Multi-record review table

<div role="region" aria-label="Manual multiple-note review table, scroll horizontally" tabindex="0">

| Dimension | Retain per source | Editorial rule | Stop condition |
| --- | --- | --- | --- |
| Source location | Non-sensitive sample label and passage location | Trace each conclusion back to its original | Mark unknown rather than inventing quotations |
| Time/order | Explicit source time or unknown | Separate recording order, event time and editing time | File ordering is not event chronology |
| Transcript completion | Pending/failed/completed state and actual reviewed scope | Check joins, numbers and negations separately | Incomplete passages are not complete minutes |
| Repeated wording | Both passages with context | Manually flag possible repetition and preserve locations | Do not automatically delete a source based on similarity |
| Conflicting versions | Each original statement and confirmation status | Put conflicts into a separate confirmation queue | Last-mentioned or assertive wording is not approval |
| Candidate to-dos | Suggested action and existing confirmation evidence | Keep unapproved items pending, without execution | Stop without authority, destination or a confirmation process |
| Prior handoff | Each note's insertion/staging attempt and result | Inspect destination content before further organizing | Do not clear markers, retry automatically or evade guards with summaries |
| Copies/destination | Local, clipboard, document and workbench scope | Hand off only necessary authorized content | Deleting a summary does not recall every copy |

</div>

## A conflict in two synthetic notes

**Sample A**: “Suggest checking three sample items first; no owner has been decided.”

**Sample B**: “The sample might become two items; confirm next time, do not execute.”

A faithful summary is “two unconfirmed counts, three versus two; owner undecided; next step is review only,” not “two items approved and scheduled.” These phrases are not a real meeting, real people or a completed device test. This page does not record, invoke an Agent or supply a merge button.

If using an existing document tool, check its account, sync and permissions first. Do not upload originals/private content to an unauthorized service. The manual minutes template can organize fields, but it is not an app import schema either.

## From a summary to a candidate action

1. Locate the candidate action in its source and retain conditions, unknowns and conflicts.
2. Find separate confirmation and an authorized destination. Without them, keep it pending rather than inferring owners or deadlines.
3. Inspect prior handoff attempts and destination text before creating another copy through summarization.
4. Continue only through an existing authorized workflow. Task-like prose is not permission to create ledger items or call reply endpoints.
5. Record the actual stage: organized locally, awaiting review, visible draft or uncertain. Sent, recorded and handled each need their own evidence.

## One handoff and length limits still apply

Each note reserves one marker before explicit insertion or share-tray staging; failure to reserve refuses handoff. A failed/uncertain attempt retains originals without automatic redirection. Direct insertion currently has a 3,000 Swift Character threshold; longer text uses existing Markdown staging. Combining notes into a summary is not a way to bypass markers or eligibility.

Manual copying creates another copy and can duplicate content. Editorial review does not establish automatic deduplication or end-to-end exactly-once delivery. Audio segmentation, editorial summaries, attachment staging, sending and execution remain distinct boundaries.

## FAQ

<h3 id="faq-merge-feature">Can Yihu merge several notes with one button?</h3>

This page makes no such claim. Existing source covers single-note recording, segmented transcription, retained originals and explicit handoff. The comparison workflow is manual guidance, not new functionality.

<h3 id="faq-audio-join">Does putting transcripts together join audio seamlessly?</h3>

No. Text editing does not modify original audio or establish continuous timing, the same speaker or lossless joins. Preserve each audio record and its state separately.

<h3 id="faq-conflict">Can the last conflicting note be treated as the final decision?</h3>

Not merely because of its order. Preserve both versions and locations until separate confirmation. Proposals, updates and approvals are different facts.

<h3 id="faq-todo">Can an action sentence automatically create a to-do?</h3>

No task-creation automation is supplied here. A candidate still needs source evidence, destination, authority and an existing confirmation process. Conditional suggestions do not authorize execution.

<h3 id="faq-rehandoff">Can renaming a summary permit another handoff of attempted content?</h3>

Do not rename to bypass one-handoff or uncertain-stop guards. Inspect the destination first; manual copying can duplicate. New editorial text does not prove an old attempt never happened.

<h3 id="faq-delete">Does a summary guarantee originals can be removed without losing evidence?</h3>

No. Summaries may omit context/negations, while deletion, backup and copies are separate. Follow actual retention needs and rules; this page guarantees neither recovery nor recall.

## Reading and evidence

[Manual minutes/brief fields](/en/guides/meeting-notes-brief-fields/) · [Explicit recording-note handoff](/en/guides/recording-notes-handoff/) · [Web read-aloud/input transition](/en/guides/web-read-aloud-microphone-boundaries/) · [Radar JSON/null checks](/en/guides/radar-json-null-validation/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Sources: [note model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift), [processing/one-handoff reservation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift), [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
