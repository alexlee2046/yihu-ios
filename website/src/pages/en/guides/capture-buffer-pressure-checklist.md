---
layout: ../../../layouts/Wave3Guide.astro
title: "Capture cannot keep up: short-speech queues, previews and final results"
description: "Review source-frame budget, bufferOverflow, draining and final state. Rough half-second queue admission is not latency SLA, total RAM or a long-note limit."
lang: en
---

<h2 id="first-answer">bufferOverflow is a failure boundary; partial previews are not complete recording</h2>

The short-speech PCM pipeline uses a serial queue and bounded waiting source frames. Exceeding max(ceil(sourceRate / 2), 4096) records bufferOverflow, stops admission and ultimately fails. snapshot does not drain the queue; it captures current output only. Visible previews/levels do not prove complete capture or delivery.

## Different from format and route review

Format admission checks shape; route recovery checks system events. Here **queue, stop, snapshot and final meanings under pressure** matter. This scope is short speech, not long-note limits or hardware performance testing.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Budget | max(ceil(sourceRate / 2), 4096) source frames | Waiting amount/error | Fixed half-second end-to-end SLA |
| Synthetic arithmetic | 48000 Hz → 24000 waiting frames | Frames, not bytes | Exact whole-app RAM cap |
| Overflow | bufferOverflow failure, admission stops | Actual error/incomplete state | Silent drops still count as full success |
| snapshot | Does not drain for preview | Current versus final output | Every queued block included |
| Normal requestStop | Stop admission, process queue/flush tail | Returned final/error | Stop tap proves instant completion |
| Duration | Finite parameter up to 30 seconds | Normal limit stop versus durationExceeded | Every 30-second capture errors or long notes share limit |
| cancel | Clears pending/output and resets | Cancellation versus committed effects | Hidden complete recovery backup |
| Handoff | Final/original guards still apply | Result/target/prior attempt | Tuning or recapture grants resend |

</div>

## Synthetic pressure result

A preview exists, but final reports bufferOverflow. Do not present the preview as complete. Retain failure/gap evidence without arbitrarily growing queues, bypassing model/format checks or diagnosing hardware capability from one result.

Source budgets are not runtime/noise/accuracy evidence. Processing blocks, output and other allocations are not represented by waiting frames alone. No stress test, recording or pipeline modification ran.

## FAQ

<h3 id="faq-1">Does half-second frame budget mean half-second latency?</h3>

No. Waiting admission differs from end-to-end latency/scheduling.

<h3 id="faq-2">Are 24000 frames 24000 bytes?</h3>

No. Frames, channels/layout and total memory differ.

<h3 id="faq-3">Can visible text justify ignoring overflow?</h3>

No. Partial preview does not turn final failure into completeness.

<h3 id="faq-4">Does snapshot wait for every block?</h3>

Not for preview. Distinguish current output from final stop results.

<h3 id="faq-5">Do all long notes have a 30-second limit?</h3>

No. This is short speech; long-note disk recording differs.

<h3 id="faq-6">Is automatic queue tuning/cloud fallback added?</h3>

No. This reviews source failure boundaries, not tuning/fallback/zero-loss guarantees.

## Reading and source

[Format admission](/en/guides/pcm-format-admission-review/) · [Route recovery](/en/guides/audio-route-recovery-matrix/) · [Recapture gaps](/en/guides/interruption-recapture-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Budget/snapshot/stop/failure](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift) · [Short-speech duration entry](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)
