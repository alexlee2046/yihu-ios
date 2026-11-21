---
layout: ../../../layouts/Wave3Guide.astro
title: "Recording interrupted? Check saved audio before a retake | Yihu"
description: "Play back saved audio after a lock, call or low battery. Separate pending transcription from missing audio; rehearse input checks without mic access."
lang: en
privacyPreview: true
trialLabel: "Try input checks before a retake"
---

<h2 id="first-answer">Listen to what was saved and record only the confirmed gap</h2>

Open the original note, play back the saved audio and mark the last passage you can verify. If audio is intact but text is missing, check transcription with Yihu open before recording again. If audio is missing, keep the original and record only that passage as a separate, labeled retake. Don’t ask the model to reconstruct words it never heard.

The long-note interface says recording continues while locked and transcription runs with Yihu open. That is not zero-loss evidence for battery, shutdown or write failures, and short speech has different cancellation rules.

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
