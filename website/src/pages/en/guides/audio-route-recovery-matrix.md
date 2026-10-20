---
layout: ../../../layouts/Wave3Guide.astro
title: "Recover or stop after an audio switch? Short speech versus recording-note source matrix"
description: "Review same-format restart, format changes, interruptions and failures by capture path. Recovery code does not certify lossless headset switching or any device combination."
lang: en
---

<h2 id="first-answer">Identify the capture path before interpreting the event</h2>

Short-speech capture and recording notes use different paths. Short speech can attempt to retain its converter/captured PCM after engine configuration changes only with an unchanged input format. Notes try writer retargeting after an input change. Restart failures, calls and some route events can still stop capture or report interruption. This explains fixed source branches, not lossless Bluetooth-switch acceptance or a new recovery button/probe.

## Different from input diagnosis and web switching

Input diagnosis asks why audio/text is absent; web switching separates output and capture. Here **recording has already started and an event selects a source branch**. Do not apply short-speech conditions to notes or infer an uninterrupted web call from writer retargeting.

## Capture path and event matrix

<div role="region" aria-label="Audio capture recovery event matrix, scroll horizontally" tabindex="0">

| Path/event | Current branch | Continuation conditions | Result still needing review |
| --- | --- | --- | --- |
| Short speech: engine configuration change | Rebuild input tap/graph and attempt restart | Same active record, still recording, existing engine/pipeline and unchanged input format | Failure/interruption and text completeness; not delivery |
| Short speech: changed input format | Fail closed rather than reuse an unsafe converter | No format-coercion bypass | Retained result/error, not lossless continuation |
| Short speech: restart failure | Mark interrupted and stop engine | No success inference | Actual state; no repeated recording that duplicates content |
| Short speech: repeated configuration notification | Conditional debounce avoids repeated recovery | Same record, running engine, unchanged format/route within grace period | Not ignoring genuine device changes |
| Short speech: interruption began/media services lost/reset | Corresponding observer fails capture and stops | Actual event/current recording state | No always-resume-after-call promise |
| Short speech: handled route notification | oldDeviceUnavailable/noSuitableRouteForCategory interrupt | Other reasons filtered, but an engine event can also occur | Filtered does not establish valid input/unaffected capture |
| Notes: engine configuration change | Stop tap, try writer retargeting, reinstall tap/start | Same active recording/engine with successful retarget/start | Failure can report retention up to that point; inspect audio/joins |
| Notes: call/media-service reset | Corresponding interruption-message path | Check actual saved state | No continuous-background, arbitrary-duration or no-loss guarantee |

</div>

Short-speech format equality checks sample rate, channel count, common format and interleaving. The debounce's current default grace is two seconds, an internal conditional window, not reconnection latency, a UI wait time or recovery SLA. Waiting two seconds does not prove a headset recovered.

## Manual review after a change

Stop business operations in a safe stationary setting and identify short speech versus notes. Record non-sensitive event categories, such as a call/headset switch, visible before/after states and whether text exists. Do not collect unique route/device identifiers, actual audio or customer text for public reproduction.

Inspect saved/transcription/error state rather than jumping from reconnected to complete recording. Review quantities, negations and joins near interruption, retaining unknowns. If text was already handed off, original target/one-handoff rules remain: audio recovery is not resend permission.

This page does not ask users to disable system protection, alter sample rates, clear records or forcibly restart services. No automatic interruption-generation script is supplied. When safe reproduction is impossible, give the existing maintenance process a minimal error description.

## FAQ

<h3 id="faq-same-path">Can short speech and recording notes share one recovery conclusion?</h3>

No. Their pipelines, format handling and failures differ. Identify the recording entry point and actual version before applying a branch.

<h3 id="faq-format">Can a changed short-speech input forcibly reuse the old converter?</h3>

The source fails closed instead of unsafe reuse. No bypass is supplied, and failing closed is not lossless continuation.

<h3 id="faq-grace">Does waiting two seconds guarantee Bluetooth recovery?</h3>

No. Two seconds is a debounce constant conditional on identity, engine, format and route, not a Bluetooth performance result.

<h3 id="faq-retarget">Does writer retargeting guarantee every headset switches seamlessly?</h3>

No. Retarget/restart can fail; inspect actual retention and joins. This work supplies no device/firmware/scenario recovery acceptance matrix.

<h3 id="faq-reply">Can recovered audio automatically resend the earlier draft?</h3>

No. Capture and handoff are separate states. Prior insertion/refusal/uncertainty keeps original guards and markers.

<h3 id="faq-evidence">Does a report require full route UIDs or real recordings?</h3>

Do not collect them for public feedback. Start with version, model, event category and synthetic-content outcomes; private material stays within existing authorized procedures.

## Reading and source

[Input diagnosis](/en/guides/bluetooth-audio-input-troubleshooting/) · [Web output/capture transition](/en/guides/web-read-aloud-microphone-boundaries/) · [Passage review](/en/guides/recording-segment-review-labels/) · [Fallback permission](/en/guides/degraded-handoff-go-no-go/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [short-speech events/format/debounce](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift), [note retarget/interruption](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift). A source matrix is not browser-visual or device-audio acceptance.
