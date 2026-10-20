---
layout: ../../../layouts/Wave3Guide.astro
title: "iPhone recording notes: segmented transcription and explicit handoff"
description: "Separate recording, segmented transcription, local storage and explicit draft or attachment handoff. Check the target and uncertainty without promising long-session performance."
lang: en
---

<h2 id="first-answer">First answer</h2>

Yihu keeps recording notes on the phone, transcribes them in segments when foreground processing is available, and lets you review the text before explicitly inserting a draft or staging a text attachment. Stopping a recording is not handing it to an Agent; insertion is not sending, and staging is not a successful upload. This guide describes the current code path, not a new device guarantee for long sessions, lock-screen continuity, speed or battery use.

## Five separate actions: recording is not handoff
1. **Prepare**: use your own signed app, available local model and microphone permission. Web access needs your own reachable, trusted HTTPS workbench. Notes are not a hosted recording service or a promise of an App Store binary.
2. **Record**: explicitly start and stop. The current UI describes lock-screen recording, but this task did not test locked screens, interruptions, low storage or long sessions on a device. No supported duration is inferred.
3. **Transcribe and review**: stopping moves into pending/transcription, not the automatic delivery attempt used by short dictation. Keep the app foregrounded and free of conflicts. Check names, numbers, negations and segment joins. Recognized text is not automatically generated meeting minutes.
4. **Choose explicitly**: verify the workbench/page captured when notes opened. Insert eligible short text into a draft, or stage a longer Markdown attachment in the share tray before a separate attachment handoff. An independently gated Radar-item draft path also exists; it is not interchangeable with web insertion or a sent reply.
5. **Inspect the result**: verify the draft/attachment and destination before any further action. On uncertainty, stop automatic actions and inspect before copying manually. Do not reset the one-handoff marker to force another attempt.

<div role="region" aria-label="Implementation boundaries (scroll horizontally)" tabindex="0">

| Stage | Current implementation | Does not establish |
| --- | --- | --- |
| Recording | Local audio.caf; system microphone permission | Unlimited length or immunity to interruption |
| Segmentation | 16 kHz frames; up to 28-second windows; final-eight-second energy search | Semantic segmentation, speaker diarization, accuracy or speed |
| Recovery | note.json text/state/transcribedFrames; interrupted states reload as pending | Continued transcription after process death or lossless recovery |
| Insertion | Completion, character threshold, reservation and captured-page checks | Insertion into any current page or automatic Send |
| Share tray | Text or Markdown, not original audio | Automatic upload or remote deletion when a note is deleted |
| Retained original | Readable/copyable on uncertainty | Duplicate-free copying, receipt or execution |

</div>

**Synthetic walkthrough, no recording**: use an imaginary completed note saying “Summarize the three demo discussion questions; take no action.” Verify the target, then choose one handoff. ASCII lengths 3000 and 3001 explain the existing boundary, not a recording-duration test. The source uses Swift Character counts; do not substitute UTF-8 bytes or Unicode scalar counts. Even manual copying can duplicate content: check the destination first.

## Detailed questions and answers

<a id="faq-note-segmentation"></a>
## How can longer phone recordings be transcribed in on-device segments rather than as one entire clip?

The current segmenter counts 16 kHz frames in windows of up to 28 seconds, searches the final eight seconds for a low-energy cut, and may retain the final window whole before joining recognized text. This is an implementation strategy, not a guarantee against split words, an accuracy or battery benchmark, or support for arbitrary recording durations. No long-recording device benchmark was performed here.


<a id="faq-note-resume"></a>
## How should I check saved progress and continue after recording transcription is interrupted?

Note metadata stores the transcribed frame position. On reload, leftover recording/transcribing states become pending; processing can continue in the foreground when transcription is allowed. Distinguish pending, failed and done, and review text around the interruption. This does not promise continuous background transcription, automatic minutes or lossless crash recovery.


<a id="faq-note-preservation"></a>
## If audio and transcripts are stored locally on my phone, can backups or handoff copies still exist?

Audio and metadata live in the phone's VoiceNotes directory as audio.caf and note.json. The code attempts to exclude that directory from backups; success has not been verified on every device. Copying, share-tray staging and web handoff can create other copies. Deleting a local note does not delete workbench, clipboard or server copies.


<a id="faq-note-target-binding"></a>
## How can I avoid inserting a recording note into the wrong workbench page?

Focus the intended draft composer before opening notes, and verify the page. Explicit insertion is bound to the session and page captured when notes opened, with connection, target and busy-state checks before handoff. Do not assume switching a source or page retargets an open note view. Unknown editors and refusals are not bypassed, and Send is never pressed automatically.


<a id="faq-note-handoff-choice"></a>
## When should a recording transcript be inserted directly versus staged as a file in the share tray?

The current note UI limits direct insertion to 3,000 transcript characters, with transcription complete, no prior handoff and valid target checks. Longer transcripts use the existing staged Markdown attachment path; the shared content is text, not the raw recording. This is not a duration or model limit. Staging is not uploading or sending, although later attachment handoff may upload to the workbench.


<a id="faq-note-handoff-uncertainty"></a>
## Why should an uncertain recording-note handoff not be retried automatically or restaged?

Each note atomically reserves one handoff marker before explicit insertion or share-tray staging. If the reservation cannot be written, handoff is refused. A failed or uncertain attempt retains the original text but is not automatically retried or redirected through another handoff path. Inspect the destination before deciding whether to copy manually. The marker is not proof of workbench receipt or Agent execution.


Related reading: [Get started](https://getyihu.com/en/start/) · [Privacy](https://getyihu.com/en/privacy/) · [Short voice drafts](https://getyihu.com/en/guides/iphone-agent-voice-drafts/)
