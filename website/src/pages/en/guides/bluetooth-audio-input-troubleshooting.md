---
layout: ../../../layouts/Wave3Guide.astro
title: "Bluetooth connected but no recording? Diagnose Yihu audio by layer"
description: "Separate permission, input routing, near-field policy, interruptions, model processing and destination drafts. Pairing is not headset certification or lock-screen hands-free acceptance."
lang: en
---

<h2 id="first-answer">Find the failing layer; paired does not establish the recording input</h2>

Bluetooth pairing, the active input, saved audio, local recognition and a web draft are five separate results. Yihu's near-field capture source requests `playAndRecord`, `voiceChat` and `allowBluetoothHFP`, but those options do not certify a headset or microphone route. In a safely stationary setting, check each layer using a synthetic phrase. Do not change the workbench first when recognition is absent, or blame the microphone first when only the remote draft is missing.

## Identify the symptom first

**No readable text**: inspect whether recording is permitted, microphone permission, actual input and model availability. Starting recording does not prove useful audio, and useful audio does not prove a compatible model is downloaded and verified.

**Text exists but no draft**: retain it, then inspect the current workbench, captured page, editable composer and host refusal. Do not hand off the same recording note repeatedly to diagnose audio.

**Failure after a headset change**: the input route, format or system audio session may have changed. Inspect actual saved/failure states. Retargeting and interruption handlers in source are not guarantees of lossless continuation.

## Parameter and evidence layers

<div role="region" aria-label="Bluetooth audio diagnostic layers, scroll horizontally" tabindex="0">

| Layer | Observable evidence | Condition to inspect | Does not establish |
| --- | --- | --- | --- |
| Pairing | System reports a connected headset | The actual phone, headset and environment | Recording necessarily uses the headset microphone |
| Permission | System microphone authorization and app messages | Explicit user permission; no bypass | Authorization guarantees usable audio |
| Session policy | Near-field requests voiceChat/allowBluetoothHFP; disabled mode differs | Actual app version and selected policy; no blind setting changes | All HFP accessories work or wind/echo targets are met |
| Audio/storage | Recording state, inspectable saved content and error messages | Space, calls/audio-service changes and input switches | Unlimited duration, no interruption or no lost words |
| Transcription | Reviewable text and pending/failed/completed state | Compatible verified local models and an eligible foreground period | Verified minutes or a promised accuracy level |
| Draft target | Text in the intended unsent composer | Same workbench/page, editable composer and host permission | Sent message, uploaded attachment or executed task |
| Watch | Existing phone summary and handoff state | Pairing, phone reachability and original eligibility checks | Correct headset input, standalone intercom or direct Watch writes |

</div>

## Localize with one synthetic phrase

1. In a safe stationary location, choose a workbench that permits drafts and contains no real orders or private content. Use “Prepare a sample reading list; keep a draft without sending.”
2. Inspect input/output and permission through the actual system interface. Note non-sensitive conditions such as headset model, system version and a recent route change, not unique device IDs, accounts or service tokens.
3. Observe recording/storage errors. Stop at capture if there is no usable audio evidence; requesting system processing is not proof sound was captured.
4. With audio but no text, inspect models and transcription state. A longer note can wait for foreground processing. Pending is neither failure nor a guarantee of continuous background work.
5. With text, inspect whether it was already inserted. Short speech may automatically attempt guarded delivery; unknown editors, busy states and host refusal are not solved by changing headsets.
6. On uncertainty, inspect destination content and retain the original. Never clear a note's one-handoff marker to force another attempt.

This is not a completed physical-device test and does not require customer content to reproduce a problem. Stop reproduction if it only occurs while moving, in a dangerous place or where recording is not permitted.

## Useful evidence for a maintainer

Provide the source/build version, system/headset model, failing layer, whether it followed a new recording or input switch, a shareable error category and whether the synthetic phrase became readable text. Do not expose real audio, private tasks, workbench URL parameters, accounts, unique device identifiers or signing material in screenshots/logs. “Audio save failed” is more useful than an unsupported conclusion that Bluetooth is incompatible.

## FAQ

<h3 id="faq-connected">Why does connected not prove the headset microphone is in use?</h3>

Connection describes pairing. System routing and the app's session affect actual input, which needs checking on the device. This page does not promise a dedicated app route-diagnostics screen.

<h3 id="faq-near-field">Is near-field mode a required universal fix?</h3>

No. The source configures different session/processing paths for its two states. Check the actual version and established configuration; this page does not require permanent changes or treat a processing mode as a benchmark result.

<h3 id="faq-call">Can recording always resume completely after a call?</h3>

No such guarantee follows. Note source handles interruptions, media-service resets and input changes separately, and may report retention up to interruption. Inspect saved content and joins; recovery code is not device acceptance.

<h3 id="faq-airpods">Which AirPods model is guaranteed compatible?</h3>

No model-level device matrix was tested in this work, so there is no guaranteed list. Allowing Bluetooth HFP is not acceptance of every model, firmware or audio scenario.

<h3 id="faq-empty-draft">Should I record again when text exists but the draft is empty?</h3>

First inspect the target, captured page, busy/refusal state and existing destination content. Do not repeat insertion blindly after a handoff attempt or uncertainty. Separate audio diagnosis from web-write diagnosis.

<h3 id="faq-lock-screen">Does this certify lock-screen recording and continuous button-free dispatch?</h3>

No. This is layered troubleshooting, not a lock-screen, riding or long-call test. No group voice channel or production-dispatch delivery is promised.

## Continue troubleshooting

[Stationary preflight](/en/guides/outdoor-store-voice-preflight/) · [Offline/weak-network handoff](/en/guides/offline-workbench-handoff-troubleshooting/) · [Short voice drafts](/en/guides/iphone-agent-voice-drafts/) · [Recording notes](/en/guides/recording-notes-handoff/) · [Privacy](/en/privacy/) · [Setup](/en/start/)

Evidence: [audio capture policy](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift), [note interruptions/input changes](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift), [README scope](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
