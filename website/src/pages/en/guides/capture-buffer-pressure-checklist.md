---
layout: ../../../layouts/Wave3Guide.astro
title: "Recording buffer overflow? Check the final capture, not the preview | Yihu"
description: "A visible preview isn’t a finished recording. Check the final short-capture result before retrying, and rehearse input checks without microphone access."
lang: en
privacyPreview: true
trialLabel: "Try input checks before a capture retry"
---

<h2 id="first-answer">Check the final result before using a partial preview</h2>

Keep any existing material and check the final result after stopping. If it reports `bufferOverflow`, treat the capture as failed; don’t deliver the current preview as a complete recording. Before retrying, check the input and play back a short test in an app with permission. The web preview rehearses input checks only; it doesn’t test queue pressure.

The short-speech PCM pipeline stops accepting frames and ultimately fails above `max(ceil(sourceRate / 2), 4096)` waiting source frames. A `snapshot` shows current output without draining the queue.

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
