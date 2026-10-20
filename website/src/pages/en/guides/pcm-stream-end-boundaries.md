---
layout: ../../../layouts/Wave3Guide.astro
title: "A block ending is not capture ending: noDataNow, endOfStream and converter tails"
description: "Review state across blocks and up to 16 finish drains. Block/tail handling is not semantic segmentation, zero-loss evidence or a general file transcoder."
lang: en
---

<h2 id="first-answer">Temporarily missing another block is not the end of the entire audio stream</h2>

The PCM converter persists across tap blocks, using noDataNow between ordinary blocks rather than endOfStream for each. finish ends the stream and drains delayed samples in a bounded loop, up to 16 calls with early exits. This internal stream processing is not file transcoding, semantic segmentation or completeness certification.

## Different from format, queues and transcription segments

Format checks shape, queues check pressure, segments concern later recognition. Here **cross-block state and whole-stream ending** matter. No conversion/reset/capture is executed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Lifetime | Stateful instance across capture | Original format/block sequence | Rebuilding every block has no boundary effect |
| Ordinary input | Supply block once, then noDataNow | Temporarily unavailable versus ended | Each block is a complete stream |
| endOfStream | Used by finish | Actual stop/drain result | Empty input proves complete processing |
| Tail loop | Up to 16, stop on end/empty samples | Call budget, not time/frames | 16-second/frame SLA |
| Reset | Original cancellation/reset paths | Old state/new capture | Reset recovers uncaptured contents |
| Block copy | PCMChunk copied across queues | Reusable input-buffer lifetime | Copy authenticates contents |
| Final | Pipeline failure/duration/empty checks remain | Final versus preview/buttons | finish always succeeds losslessly |
| Handoff | Original target/reservation remain | Text/receipts | Internal conversion grants sending/cloud transcoding |

</div>

## Synthetic stream sequence

After A, B is not yet available: noDataNow retains converter state. Actual ending enters finish. Each tap callback ending is not the whole stream, and tail output does not certify every original word.

Comments explain state retention to avoid reset-related boundary-history loss; this is not a device zero-loss result. Do not reset repeatedly, falsify end flags or expand loops to bypass failures. No new importer/transcoding service is supplied.

## FAQ

<h3 id="faq-1">Should every block end with endOfStream?</h3>

Not in this implementation. Ordinary gaps use noDataNow; finish ends the stream.

<h3 id="faq-2">Do 16 calls mean 16 seconds/frames?</h3>

No. Call count is not latency/audio length.

<h3 id="faq-3">Is a new converter per block equivalent?</h3>

Do not assume that. Stateful conversion retains history/priming.

<h3 id="faq-4">Does tail output prove no loss?</h3>

No. Actual audio, errors, text and completeness remain separate.

<h3 id="faq-5">Does block copying verify an archival original?</h3>

No. It handles lifetime, not signatures/content truth.

<h3 id="faq-6">Can this convert arbitrary files?</h3>

No general tool is added; fixed internal PCM review only.

## Reading and source

[Format admission](/en/guides/pcm-format-admission-review/) · [Queue/final](/en/guides/capture-buffer-pressure-checklist/) · [Recognition segments](/en/guides/note-segment-join-provenance/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Converter/convertOnce/finish](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift) · [Tap/stop entry](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)
