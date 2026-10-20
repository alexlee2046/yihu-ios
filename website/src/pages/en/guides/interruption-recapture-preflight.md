---
layout: ../../../layouts/Wave3Guide.astro
title: "Low power or screen lock: inspect saved segments before rerecording"
description: "Existing long-note UI permits lock-screen recording with foreground transcription. Not a battery-loss guarantee, automatic repair, recovery or recapture feature."
lang: en
---

<h2 id="first-answer">Check saved material before deciding to record or compare again</h2>

Screen lock does not establish lost long notes. Existing UI says recording continues while locked and transcription runs with Yihu open. Long capture writes to disk and handles calls, resets and write errors. This is not zero-loss evidence for every power, shutdown, storage or accessory condition. Inspect saved material, pending transcription and actual gaps before rerecording; never fabricate missing words.

## Different from foreground and route recovery

Foreground review checks lifecycle requests; route recovery checks engine events. Here **whether a content gap exists and what a new capture should cover** is the decision. No power setting, file cleanup, recording or recovery is performed.

<div role="region" aria-label="Review matrix, scroll horizontally" tabindex="0">

| Check | Existing boundary | Review | Not established |
| --- | --- | --- | --- |
| Locked long notes | UI describes recording continuation, foreground transcription | Actual note/content state | Uninterrupted under every battery/OS condition |
| Short speech | Different cancellation path | Prior request/result validity | Long-note guarantees apply universally |
| No visible text | Transcription differs from capture | Saved audio/pending work | No transcript means no capture |
| Written material | Long capture retains prior writes | Usable file and actual gap | All unwritten buffers survive power loss |
| Call/service reset | Interruption/saved-so-far notices | Saved scope and errors | Continuous audio or every file certified |
| Low power/write error | No automatic downgrade promised here | Power/storage/material state | Automatic power-saving recapture/cloud restore |
| New capture | Permission/safe conditions still apply | Confirmed gap and manually labeled version | Automatic merging/deduplication |
| Later handoff | Original reservations/guards remain | Prior effects and receipts | Rerecording resets old attempts |

</div>

## Synthetic gap note

Known: sample segment A is usable. Unknown: whether B was saved. Pending transcription: lack of text cannot decide. Decision: inspect B before declaring complete loss or generating invented transition words.

No recording or low-power benchmark ran. Label recapture as a new version, not overwrite originals to imply continuity. Retain order/editorial notes separately. Uncertain prior handoffs require review, not repeated delivery.

## FAQ

<h3 id="faq-1">Does locking mean rerecord everything?</h3>

No. Long-note UI describes continued capture; inspect actual saved/pending state without generalizing to every path.

<h3 id="faq-2">Does low-power mode automatically downsample safely?</h3>

No such feature/guarantee is asserted. Actual state/errors need review; no battery compatibility test is claimed.

<h3 id="faq-3">Does no transcript mean no saved audio?</h3>

No. Saving and transcription differ; inspect material and foreground processing separately.

<h3 id="faq-4">Does saved-so-far guarantee zero loss?</h3>

No. It does not establish all-buffer/every-condition recovery. Review actual usable scope.

<h3 id="faq-5">Can a model fill missing meeting quotations?</h3>

Generated text is not recorded speech. Keep gaps and label any new recording/version.

<h3 id="faq-6">Can recapture automatically deduplicate and resend?</h3>

No merging/deduplication/resend authority is added. Reservations and uncertainty rules remain.

## Reading and source

[Foreground state](/en/guides/foreground-audio-rebind-preflight/) · [Audio recovery](/en/guides/audio-route-recovery-matrix/) · [Segment review](/en/guides/recording-segment-review-labels/) · [One handoff](/en/guides/recording-notes-handoff/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Lock/transcription UI](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotesView.swift) · [Disk writes/interruptions](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift) · [Note state/handoff](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)
