---
layout: ../../../layouts/Wave3Guide.astro
title: "Record Button Enabled but No Audio? Check Yihu’s State"
description: "Check the current phase, pending text, model and mic permission before starting again. Try Yihu’s no-mic audio questions, then review privacy and App Store setup."
lang: en
privacyPreview: true
trialLabel: "Try the audio-state questions"
---

<h2 id="first-answer">Check the phase and pending text before recording again</h2>

Check whether the app is preparing a model, capturing, transcribing or handing off, and retain text that still needs review. Prepare the model in needsModel and inspect any pendingTranscript before another capture. Review permissions, test reservations and actual results for the specific entry point. Do not repeatedly tap or discard uncertain text to force a new recording.

## Different from permission, lifecycle and voiceprint decisions

Implementation review follows `primaryActionEnabled`, `canCancel`, and the separate note-entry `canRecord` / foreground `canTranscribe` conditions. Inspect the corresponding phase and result instead of treating these properties as one global ready flag.

Permission checks consent, lifecycle checks foreground, voiceprints check filtering. Here **entry/resource busy meanings and call-chain scope** matter. No recording, calibration, model execution or pending-text clearing occurs.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Primary action | Actions vary across needsModel/recording/failed etc. | Actual phase/action | Enabled means start new recording |
| Ready | pendingTranscript/test flag also matter | Existing text/test state | Everything idle |
| canCancel | Preparing/recording/transcribing | Cancellable versus sampling | Mic continuously active |
| Delivering | Some guards block separately | Actual delivery state | Not cancellable means idle |
| Note capture | canRecord/isStarting and entry checks | Actual chain/permission result | One guard proves every async stage excluded |
| Note transcription | Yields to dictation, foreground required | Processing versus existing capture | Background inference or lost recording |
| Voiceprint test | claimVoiceprintTestMic reserves entry state | Reservation versus capture | Permission/identity passed |
| Shared model | Notes use voice.transcriber | Shared object/yield conditions | Arbitrary parallel models/race freedom |

</div>

## Synthetic busy note

The button is enabled but phase=needsModel: a click is not proof capture started. Ready with pendingTranscript is not no outstanding result. Inspect actual entry/return rather than collapsing every state into one busy flag.

Local guards are not global concurrency/latency certification. Conditions can change across awaits; follow original checks instead of repeated capture, discarding unresolved text or disabling safeguards for throughput.

## FAQ

<h3 id="faq-1">Does enabled prove the mic is capturing?</h3>

No. Phases can correspond to model/preparation/stop and other actions.

<h3 id="faq-2">Does canCancel imply recording only?</h3>

No. Preparation/transcription can also be cancellable.

<h3 id="faq-3">Does ready always permit starting?</h3>

No. Pending text/test state and other conditions remain.

<h3 id="faq-4">Does unavailable note transcription mean no audio?</h3>

No. Capture, foreground and model processing are separate.

<h3 id="faq-5">Does shared transcriber promise parallel inference?</h3>

No. Sharing plus yield policy is not concurrency/performance evidence.

<h3 id="faq-6">Are all entry points proven mutually exclusive?</h3>

No. Local guards/call scope only, without a new scheduler or device/concurrency tests.

## Reading and source

[Permission/sampling](/en/guides/microphone-permission-sample-contract/) · [Foreground](/en/guides/foreground-audio-rebind-preflight/) · [Voiceprint results](/en/guides/voiceprint-filter-not-authorization/) · [Preview/final](/en/guides/replaceable-voice-preview-review/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Action/phase/test reservation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift) · [Note admission closures](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift) · [Capture/worker entry](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)
