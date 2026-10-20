---
layout: ../../../layouts/Wave3Guide.astro
title: "What an audio meter proves: RMS is not accuracy, wind score or delivery"
description: "Review different short-speech/long-note RMS scaling and clipping. Levels are not calibrated decibels, identity or content truth; no actual acoustic benchmark."
lang: en
---

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
