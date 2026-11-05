---
layout: ../../../layouts/Wave3Guide.astro
title: "Capture cannot keep up: short-speech queues, previews and final results"
description: "Review source-frame budget, bufferOverflow, draining and final state. Rough half-second queue admission is not latency SLA, total RAM or a long-note limit."
lang: en
---

<h2 id="syn-buf-37">SYN-BUF-37: pending frames, failures and segmentation boundaries</h2>

SYNTHETIC_EXAMPLE: source pipeline and deterministic memory queue, not device pressure/drop measurements.

[ZH: /samples/p16-buffer-pressure/buffer-pressure-preflight.zh.json](/samples/p16-buffer-pressure/buffer-pressure-preflight.zh.json) · [EN: /samples/p16-buffer-pressure/buffer-pressure-preflight.en.json](/samples/p16-buffer-pressure/buffer-pressure-preflight.en.json) · [Card: /samples/p16-buffer-pressure/preflight-card.md](/samples/p16-buffer-pressure/preflight-card.md)

<div role="region" aria-label="Synthetic capture watermark and completion checks; horizontally scrollable" tabindex="0">

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| D1 | duration=0 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D2 | duration=-1 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D3 | duration=31 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D4 | duration=nan | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D5 | duration=infinity | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D6 | duration=0.000001 | source init accepted=False; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D7 | duration=0.001 | source init accepted=True; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| D8 | duration=30 | source init accepted=True; floor budgets must both be positive | Fake converter/format, not AV initialization or length guarantee |
| Q1 | Preview does not drain; normal stop flushes tail; sourceRate=48000; duration=30 | {'pending_frames': 0, 'accepted_source_frames': 1024, 'output_samples': 3, 'completed': True, 'failure': 'none', 'completion': 'success', 'callback_count': 1, 'snapshot': 'samples:3'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q2 | Exactly24000 waiting source frames admitted; sourceRate=48000; duration=30 | {'accepted_source_frames': 24000, 'output_samples': 2, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q3 | One over limit fails, not circular overwrite success; sourceRate=48000; duration=30 | {'accepted_source_frames': 24000, 'completion': 'bufferOverflow', 'failure': 'bufferOverflow', 'callback_count': 1, 'snapshot': 'error:bufferOverflow'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q4 | 4096 floor at low rate, not universally half a second; sourceRate=8000; duration=30 | {'queue_limit': 4096, 'accepted_source_frames': 4096, 'completion': 'bufferOverflow'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q5 | Ceil rounding with fake format fields only; sourceRate=44100.5; duration=30 | {'queue_limit': 22051, 'accepted_source_frames': 22051, 'completion': 'success'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q6 | Draining frees pending budget, cumulative accepted is distinct; sourceRate=48000; duration=30 | {'accepted_source_frames': 48000, 'output_samples': 2, 'completion': 'success', 'pending_frames': 0} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q7 | Duration clips final block without opening next segment; sourceRate=48000; duration=0.001 | {'maximum_source_frames': 48, 'maximum_output_samples': 16, 'accepted_source_frames': 48, 'output_samples': 16, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q8 | Scripted converted output exceeds budget; sourceRate=48000; duration=0.001 | {'accepted_source_frames': 48, 'output_samples': 0, 'pending_frames': 0, 'failure': 'durationExceeded', 'completion': 'durationExceeded'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q9 | Final tail overflow can coexist with readable snapshot; sourceRate=48000; duration=0.001 | {'output_samples': 16, 'failure': 'none', 'completion': 'durationExceeded', 'snapshot': 'samples:16', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q10 | Empty stop fails; empty snapshot is not final receipt; sourceRate=48000; duration=30 | {'output_samples': 0, 'failure': 'none', 'completion': 'tooShort', 'snapshot': 'samples:0', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q11 | Cancel clears pending/output, no hidden complete backup; sourceRate=48000; duration=30 | {'pending_frames': 0, 'output_samples': 0, 'cancelled': True, 'completed': False, 'callback_count': 0, 'completion': 'none', 'snapshot': 'error:cancelled', 'reset_calls': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q12 | Explicit failure clears pending and reports failure; sourceRate=48000; duration=30 | {'pending_frames': 0, 'output_samples': 0, 'failure': 'conversionFailed', 'completion': 'conversionFailed', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q13 | Scripted converter throw exercises catch path; sourceRate=48000; duration=30 | {'output_samples': 0, 'pending_frames': 0, 'failure': 'conversionFailed', 'completion': 'conversionFailed'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q14 | Scripted chunk-copy failure is not admitted; sourceRate=48000; duration=30 | {'accepted_source_frames': 0, 'pending_frames': 0, 'failure': 'unsupportedFormat', 'completion': 'unsupportedFormat'} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q15 | Post-completion stop/input cannot double-complete; sourceRate=48000; duration=30 | {'accepted_source_frames': 1, 'output_samples': 2, 'completion': 'success', 'callback_count': 1} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| Q16 | Old Swift array snapshot remains separate from later output; sourceRate=48000; duration=30 | {'output_samples': 5, 'completion': 'success', 'snapshot': 'samples:5', 'saved_snapshot_sizes': [2, 5]} | Deterministic fake queue/converter counts; no real-time drop or resampling result |
| B1 | Source is array FIFO, not overwrite-oldest ring | pending:[ColliePCMChunk], pendingFrames, removeFirst; ring head/tail indices not_applicable; overflow final failure, not silent-drop success | Source reading only; runtime not_run |
| B2 | Duration clipping is not automatic segmentation | count=min(available,remaining), accepting=false at limit; no new session/segment or lost-content padding created | Source reading only; runtime not_run |
| B3 | Long notes are separate; watermark is not RAM/latency | CollieNoteRecorder file-writing path is distinct; in-flight chunk/output/channels/other allocations not included in pendingFrames budget | Source reading only; runtime not_run |
| B4 | Decoder token budget cannot repair capture gaps | Per-pass output maxTokens is not source frames, queue size, seconds or guaranteed accuracy; no model/prefs changes or pass execution | Source reading only; runtime not_run |

</div>

Source is bounded array FIFO, not an overwrite-oldest ring; ring indices are not applicable. max(ceil(sourceRate/2),4096) counts waiting source frames, not bytes, total RAM or latency SLA. Overflow failure differs from final duration clipping and creates no automatic next segment. Q9 shows readable snapshot with final tail-budget failure; Q10 empty snapshot is no success receipt. Real conversion/concurrency/hardware drops/ASR/insertion/send are all not_run. Preserve failures and unknown content; no blind rerecord/resend. Decoder token budgets cannot repair capture gaps. Store installation needs no Mac/self-signing; verify your own trusted workspace/model/permission/destination, which may save/sync/auto-process.

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
