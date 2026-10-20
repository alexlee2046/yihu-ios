---
layout: ../../../layouts/Wave3Guide.astro
title: "No text does not mean a broken model: capture, input, model and empty-result layers"
description: "Review error mapping and different emptyTranscript callers. A notice proves neither silence nor corruption; no recording, model deletion or fallback is performed."
lang: en
---

<h2 id="first-answer">The same missing-text symptom can come from different layers</h2>

The controller separates permission denial, recording/PCM failures and missing/load-model errors. ASR checks nonempty finite samples/length, and empty final text produces emptyTranscript. Short speech maps empty results to recording failure; long notes can skip text and advance frames. Notices are categories, not complete diagnosis or proof the original contained nothing.

## Different from admission, integrity and retry checkpoints

Admission checks input, integrity checks assets/readiness, checkpoints check retry position. Here **error origin and limits of visible categories** matter. No capture/model/retry/file operation ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Permission | captureFailure has microphonePermission case | Actual system state | Every error is permission |
| Recording/PCM | Vetted errors/recording fallback | Format/interruption/input | Model certainly broken |
| ASR array | Nonempty/finite/length checks | Array versus hardware format layers | Valid array proves meaningful speech |
| Model missing/load | Model notice category | Integrity/loading evidence | Only cause is hash tampering |
| emptyTranscript | Empty returned final | Actual audio/meaning/stage | Nobody spoke |
| Caller difference | Short speech/long notes differ | Failure versus skipped-piece progress | Every entry has identical outcomes |
| Notice copy | Arbitrary raw system errors not exposed | Category versus full diagnostics | All causes established |
| Next steps | Original authority/target/pending guards | Minimal nonsensitive scope | Automatic deletion/cloud/replay |

</div>

## Synthetic layered note

emptyTranscript establishes no usable final from this pass, not a corrupt model or empty meeting. A model-load notice likewise needs actual integrity/runtime review instead of a tampering claim.

Advanced frames do not certify every word; notices are not service receipts. No device/real-speech regression ran. Do not publish recordings/system paths/account contents to investigate.

## FAQ

<h3 id="faq-1">Does no text always mean corrupt model?</h3>

No. Input, capture, permission, empty results and loading differ.

<h3 id="faq-2">Does emptyTranscript prove silence?</h3>

Not independently. Actual audio/content need review.

<h3 id="faq-3">Are empty-result callers identical?</h3>

No. Short failure and long-note skip/progress differ.

<h3 id="faq-4">Does load failure prove malicious files?</h3>

No. It is not complete root-cause diagnosis.

<h3 id="faq-5">Are notices full raw system errors?</h3>

No. Classification/fallback differs from full diagnostics.

<h3 id="faq-6">Was a model deleted/recording/cloud fallback invoked?</h3>

No. No automatic deletion/fallback/replay is added; actual operations retain authority/guards.

## Reading and source

[Input format](/en/guides/pcm-format-admission-review/) · [Model evidence](/en/guides/model-artifact-validation-evidence/) · [Retry position](/en/guides/note-transcription-retry-checkpoint/) · [Permission layers](/en/guides/microphone-permission-sample-contract/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Error categories](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift) · [Sample/final checks](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Qwen3OnDeviceTranscriber.swift) · [Empty pieces/progress](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)
