---
layout: ../../../layouts/Wave3Guide.astro
title: "What an audio meter proves: RMS is not accuracy, wind score or delivery"
description: "Review different short-speech/long-note RMS scaling and clipping. Levels are not calibrated decibels, identity or content truth; no actual acoustic benchmark."
lang: en
---

## SYN-ALR-48 audio level versus accuracy preflight

SYNTHETIC_EXAMPLE · pending · not_run. Levels, real content, capture tokens and receipts differ.

[/samples/p27-audio-level-not-accuracy-review/README.md](/samples/p27-audio-level-not-accuracy-review/README.md) · [/samples/p27-audio-level-not-accuracy-review/preflight.zh.json](/samples/p27-audio-level-not-accuracy-review/preflight.zh.json) · [/samples/p27-audio-level-not-accuracy-review/preflight.en.json](/samples/p27-audio-level-not-accuracy-review/preflight.en.json)

<div role="region" aria-label="SYN-ALR-48" tabindex="0">

| ID | Check | Expectation/boundary |
| --- | --- | --- |
| L01 | Empty vector | short≈0.000000; note≈0.000000; synthetic only |
| L02 | Zeros | short≈0.000000; note≈0.000000; synthetic only |
| L03 | Positive DC | short≈0.020000; note≈0.120000; synthetic only |
| L04 | Negative DC | short≈0.020000; note≈0.120000; synthetic only |
| L05 | Alternating signs | short≈0.020000; note≈0.120000; synthetic only |
| L06 | Two unsaturated gains | short≈0.100000; note≈0.600000; synthetic only |
| L07 | Long meter saturated | short≈0.200000; note≈1.000000; synthetic only |
| L08 | Half short, full long | short≈0.500000; note≈1.000000; synthetic only |
| L09 | Both full | short≈1.000000; note≈1.000000; synthetic only |
| L10 | Full-scale samples | short≈1.000000; note≈1.000000; synthetic only |
| L11 | Finite out-of-range values | short≈1.000000; note≈1.000000; synthetic only |
| L12 | Sparse high value | short≈1.000000; note≈1.000000; synthetic only |
| L13 | Sparse low value | short≈0.141421; note≈0.848528; synthetic only |
| L14 | Unequal amplitudes | short≈0.632456; note≈1.000000; synthetic only |
| L15 | Equal-energy DC | short≈0.200000; note≈1.000000; synthetic only |
| L16 | Equal-energy negative DC | short≈0.200000; note≈1.000000; synthetic only |
| L17 | Four-point sparse vector | short≈0.200000; note≈1.000000; synthetic only |
| L18 | Low mixed amplitude | short≈0.070711; note≈0.424264; synthetic only |
| L19 | Saturated DC | short≈1.000000; note≈1.000000; synthetic only |
| L20 | Small finite values | short≈0.010000; note≈0.060000; synthetic only |
| S01 | Empty input retains meter | empty_retains: note≈0.600000; frames=2 |
| S02 | Zero samples update | zero_updates: note≈0.000000; frames=4 |
| S03 | Closed file retains prior meter | closed_after_seed: note≈0.600000; frames=2 |
| S04 | No file means no update | closed_initial: note≈0.000000; frames=0 |
| M01 | Meter is not ASR or identity | DC, alternating and sparse vectors can share RMS/meters without the same words or speaker; no ASR/voiceprint run. |
| M02 | Gain is not calibration | Gains 2/12 are not dB SPL, wind ratings or probabilities; clipping loses display distinction, not a hardware-gain recommendation. |
| M03 | Display versus writing | Long append updates after successful writes; empty input/no file can retain level. Closed-file guard is not injected storage failure; timer reads do not promise zero UI latency. |
| M04 | Token before completion | captureCompleted compares activeToken before export/cleanup; token is capture association, not identity, write authority or universal exactly-once. |
| M05 | Separate stop and cancel | Stop may await this drain; cancel clears activeToken. Old full meters or late callbacks prove neither a new final nor delivery. |
| M06 | Review real content and authority separately | No customer audio, upload or recapture. Check authority, originals, gaps, saved/remote receipts separately; no blind retry when unknown. |

</div>



<h2 id="first-answer">A moving meter is not correct speech, and full scale is not 100% recognition</h2>

Short-speech PCM scales sample RMS into a 0–1 range; long-note writes use another multiplier. These are level displays, not recognition confidence, voiceprint identity, wind rating or delivery receipts. Matching bar lengths across paths do not directly compare sound quality. No acoustic scoring/calibration tool is added.

## Different from silence, voiceprint and original-word review

Diagnosis checks missing audio, voiceprint review checks filtering scope, listening checks content. Here **what meter formulas/displays establish** matters. No real capture or system-volume change occurs.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Short speech | RMS multiplied by 2, bounded | Display scale/raw samples | 0.5 means 50% recognition confidence |
| Long note | RMS multiplied by 12, capped at 1 | Different path scaling | Same length means same pressure/quality |
| Clipping | Many large values look full | Signal versus display saturation | Full means every word correct |
| Near zero | Can be quiet/no new samples etc. | Actual state/input/errors | Permission absent or nothing captured |
| Timer display | Reads current pipeline level | Display time versus final | Zero latency/all audio saved |
| RMS | Sample-energy statistic | No device/environment calibration | Standard dB SPL/noise certification |
| Text/identity | Separate ASR/voiceprint paths | Actual results/originals | Energy proves recognition/speaker match |
| Handoff | Target/receipt separately checked | Saved versus delivered | Screenshot proves business completion |

</div>

## Synthetic arithmetic

Two synthetic samples 0.1 and -0.1 have RMS 0.1. The short-speech illustration is about 0.2; long-note scaling gives 1.2 capped to 1. This is math, not microphone measurement, physical pressure or comparative performance.

Inspect real content/errors even with a full meter. Display does not establish permission, model readiness or selected target. Public checks need no customer recordings; no device/wind/accuracy test ran.

## FAQ

<h3 id="faq-1">Does full scale mean 100% recognition?</h3>

No. Display clipping is not ASR confidence.

<h3 id="faq-2">Can equal bars compare path quality?</h3>

Not directly; scaling differs and no acoustic calibration is supplied.

<h3 id="faq-3">Does zero prove no permission?</h3>

Not independently. Review permission, route, capture and errors.

<h3 id="faq-4">Is RMS a standard decibel reading?</h3>

No calibrated dB SPL measurement/certification is provided here.

<h3 id="faq-5">Does a normal meter prove identity or complete content?</h3>

No. Filtering, original words, saving and transcription differ.

<h3 id="faq-6">Were noise/microphone tests run?</h3>

No. Synthetic arithmetic is not actual device/scenario evidence.

## Reading and source

[Input diagnosis](/en/guides/bluetooth-audio-input-troubleshooting/) · [Voiceprint scope](/en/guides/voiceprint-filter-not-authorization/) · [Audio/text evidence](/en/guides/note-audio-text-evidence-mapping/) · [Preview/final](/en/guides/capture-buffer-pressure-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Short-speech RMS](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift) · [Long-note levels](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift) · [Meter reads](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)

## SYN-LEVEL-35 two-pipeline example

Fourteen synthetic inputs separate scaling/display saturation from recognized content: DC and alternating vectors can share RMS, while different RMS can share a bar under different gains. Original note append updates only after a successful write; empty/failed input can retain a previous level. An empty short-function result is not a live UI refresh guarantee. Buffer/file/lock spies are not device, storage or acoustic calibration tests.

[Continue to the filled example on the same-language outdoor/store guide](/en/guides/outdoor-store-voice-preflight/#syn-level-35). No pressure/noise rating, identity, accuracy or delivery is inferred; no new scoring/diagnostic backend is supplied.
