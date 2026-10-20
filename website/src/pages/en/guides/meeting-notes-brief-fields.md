---
layout: ../../../layouts/Wave3Guide.astro
title: "From transcript to reviewable minutes and briefs: fields, evidence and open questions"
description: "A manual meeting/brief editorial template separates originals, facts, proposals and confirmed decisions. Not automatic Yihu minutes, an import API or the PM Radar JSON model."
lang: en
---

<h2 id="first-answer">Retain the original, then organize fields; a template is not automatic minutes</h2>

Yihu source provides local recording notes, segmented transcription and user-selected draft/attachment handoff, not guaranteed accurate automatic minutes. The following is a manual editorial template separating sources, review state, facts, proposals and unanswered questions. It is not an app import format, API contract or PM Radar JSON model. Transcription, summarization, approval and execution remain different states.

## Four layers between text and decisions

1. **Original transcript** retains recognition risk and context, especially names, numbers, negations and segment joins. Do not shorten away “uncertain” or “not approved.”
2. **Reviewed quotations/facts** identify evidence locations and the reviewed scope. Leave unverifiable material pending; fluent prose is not factual evidence.
3. **Proposals/open questions** identify what needs confirmation through which existing process. Do not rewrite “suggested” or “could consider” as “decided.”
4. **Handoff/handling** records where text went and the actual completed step. A draft or attachment does not prove sending, reading or execution.

## Manual editorial field table

<div role="region" aria-label="Manual minutes and brief fields, scroll horizontally" tabindex="0">

| Editorial field | Content | Synthetic example | Verification/missing-data rule |
| --- | --- | --- | --- |
| source_note | Location in the original/authorized record | Sample note A, paragraph 2 | Retain the original; do not publish audio or private paths |
| source_time | Source time, explicitly unknown when absent | Not provided | Do not substitute editing/publication time |
| review_state | Unreviewed, partially reviewed or the actual reviewed scope | Only the synthetic passage checked | Transcribed does not mean reviewed |
| observed_facts | Facts directly supported by the source | Three open questions in a sample checklist | Unverified facts stay pending; no invented numbers/conclusions |
| unconfirmed_proposals | Suggestions without approval | Suggest reviewing fields at a future meeting | Preserve proposal wording; do not execute |
| confirmed_decisions | Decisions with separate confirmation evidence | None | Leave empty without approval evidence; do not infer tone |
| open_questions | Questions needing further answers | Which existing process confirms the sample field? | A question is not an assigned task |
| next_step | Authorized manual next action | Save for review only; do not send | Separate it from automatic execution, ordering, merging or deployment |
| handoff_target | Verified destination and content scope | Empty draft in own workbench | No account/token values; stop if unclear |
| handoff_state | Local, staged, visible draft or uncertain | Retained locally; not handed off | saved/queued or a draft is not delivery |

</div>

These keys are editorial labels for paper, a controlled local document or an already authorized tool. This page adds no database, automatic annotation, parser or app persistence behavior. Storage/sync/backup depend on the chosen tool and account.

## A brief draft that executes nothing

```text
Topic: Sample checklist discussion (synthetic, not a real meeting)
source_note: Sample note A, paragraph 2
source_time: Not provided
review_state: Only this synthetic passage reviewed
observed_facts: Three sample questions; no real business data
unconfirmed_proposals: Suggest checking fields at a future meeting; no execution
confirmed_decisions: Empty; no independent confirmation
open_questions: Which role confirms through the existing workflow?
next_step: Save for review only; do not send or execute
handoff_target: Not selected
handoff_state: Retained locally; not handed off
```

If you use a model to assist summarization, still check every item against the original and confirmation evidence. This page calls no Agent/model and reports no generation-quality, diarization or meeting-accuracy result. A synthetic example is not an approval record from a real meeting.

## Distinguish editorial fields from PM Radar

Radar uses model fields such as `date_str`, `tasks`, `decisions` and `active/stale/cold`; a task's `project` corresponds to a project record's `path`. The editorial labels above cannot replace those import keys. Naming minutes as a JSON file does not make them model-compatible.

A team with an existing authorized export/transformation process must validate sources, fields and permissions through that process. Legacy exports missing `tasks` fall back to a pending subset. This page implements no minutes-to-task conversion, automatic writeback or trade-data collection. A brief's proposal is not automatically an approved decision, and read permission is not reply-write authority.

## A subtraction checklist before handoff

Only hand off necessary authorized text. Do not use original audio, private participant details or customer content as a public example. Check workbench/page and existing destination text. Direct note insertion currently has a 3,000 Swift Character threshold and eligibility checks; longer content uses existing Markdown staging, which does not attach original audio. The length rule is not a meeting-duration or model limit.

Choose one handoff path. Each note reserves one marker before explicit insertion/staging; failure or uncertainty retains originals rather than clearing a marker or switching routes to resend. Keep visible drafts, staged attachments, sent messages and handled work separate. Completing a field table is not proof any of those occurred.

## FAQ

<h3 id="faq-automatic">Do these fields make Yihu generate minutes automatically?</h3>

No. This is editorial guidance, not new app functionality, hosted summarization or background tasks. Existing recording, transcription and explicit handoff still require manual review and a separately authorized next workflow.

<h3 id="faq-approval">Can a summary saying decided populate confirmed_decisions?</h3>

Not merely because the summary says so. Find separate confirmation and retain its location. A suggestion or conditional statement belongs under proposals/questions; leave a decision empty without evidence.

<h3 id="faq-import">Can I save this template as JSON and import it into Radar?</h3>

No. These fields are not Radar's model or an import API. Actual JSON must match the existing contract and authorized source process. This page supplies no converter or task-creation automation.

<h3 id="faq-times">Can a missing source time be replaced with now?</h3>

Do not fabricate it. Preserve unknown and label editing time separately. Radar's `date_str` is the last successful source-read time, not a phone-refresh/cache-hit timestamp.

<h3 id="faq-copy">Can a shorter brief bypass the one-handoff limit?</h3>

No. Editing text does not remove uncertainty about an original handoff. Inspect destination content first; a different summary is neither a sanctioned automatic retry nor duplicate prevention.

<h3 id="faq-retention">Does deleting a local template withdraw all meeting material?</h3>

No. Notes, clipboard, document accounts, workbenches and later attachments can retain separate copies. Follow actual destination policies; this guide does not guarantee deletion, backup exclusion or third-party retention outcomes.

## Guides and source evidence

[Recording notes and explicit handoff](/en/guides/recording-notes-handoff/) · [Weak-network handoff/cache diagnosis](/en/guides/offline-workbench-handoff-troubleshooting/) · [Radar JSON and Watch](/en/guides/multi-project-radar-watch/) · [Voice-draft path choices](/en/guides/iphone-agent-voice-drafts/) · [Privacy](/en/privacy/) · [Start](/en/start/)

Existing implementation: [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md), [note model/one marker](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift), [Radar model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift). The editorial template is a suggestion from this article, not a source field schema or device acceptance.
