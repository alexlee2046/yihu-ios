---
layout: ../../../layouts/Wave3Guide.astro
title: "When recognition settings apply: per-pass snapshots and output-token budgets"
description: "Review language/usesTerms/maxTokens snapshots, default 448 and 64–1024 bounds. Tokens are not characters/audio seconds or accuracy, and no live/cloud tuning is added."
lang: en
indexable: false
---

<h2 id="first-answer">Per-pass settings are not a permanently fixed session or real-time tuning feature</h2>

Each Qwen3OnDeviceTranscriber.transcribe reads language, usesTerms and maxTokens preferences for that pass. Maximum output defaults to 448 tokens with a clamped 64–1024 range. Tokens are neither character count nor audio duration. Raising the ceiling does not directly improve accuracy and remains model-cache bounded. Busy UI disables the section; no live capture-time tuning is added.

## Different from terms, PCM and previews

Terms concern list parsing, PCM concerns sampling, previews concern replacement. Here **parameter timing and output-budget units per recognition call** matter. No settings/model/cloud temperature or budget is changed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Snapshot | language/usesTerms/maxTokens per pass | This versus later calls | Every pass in a capture always identical |
| Language | One modelHint or automatic | Actual choice | Translation/accuracy guarantee |
| Output budget | Default 448, range 64–1024 | Tokens versus Characters/bytes | 448 seconds or complete 448 characters |
| Clamp | Limit preference to allowed range | Actual consumer/value | Any number executes |
| Terms | Toggle snapshot/content argument separately | Actual decoding inputs | Output-token count equals term count |
| Low budget | Output can truncate, cache limited | Actual output/audio | More always better/complete |
| Audio conditions | Original 16 kHz mono/length guards | Audio versus output limits | maxTokens bypasses 30-second boundaries |
| Comparison | Actual parameters/reviewed scope | Preview/final/retry passes differ | Labels certify accuracy/delivery |

</div>

## Synthetic parameter note

Two calls have different output ceilings. Text length alone does not establish accuracy or retention of all conditions. Do not bypass busy UI to test; snapshot semantics are not a live-control promise.

contextTerms is obtained when constructing decoder arguments; avoid claiming every setting was atomically fixed forever across the whole session. Briefs still need original/negation/unknown review. No benchmark/optimization result is supplied.

## FAQ

<h3 id="faq-1">Are 448 tokens 448 characters?</h3>

No. Tokens, Characters, scalars and bytes differ, and none is audio duration.

<h3 id="faq-2">Does 1024 guarantee better accuracy?</h3>

No. It raises output budget within model/cache/input constraints.

<h3 id="faq-3">Does maxTokens extend audio admission?</h3>

No bypass of original sampling/length guards follows.

<h3 id="faq-4">Must previews/final share one configuration?</h3>

Per-pass snapshots do not prove a permanently identical session; inspect actual calls.

<h3 id="faq-5">Is this cloud Agent temperature/beam tuning?</h3>

No. Existing ASR settings do not provide arbitrary temperature/top-p/beam or a universal Agent backend.

<h3 id="faq-6">Were settings/model optimizations run?</h3>

No. Source units/timing only, without performance/accuracy acceptance.

## Reading and source

[Vocabulary](/en/guides/multilingual-terms-preflight/) · [PCM admission](/en/guides/pcm-format-admission-review/) · [Preview meaning](/en/guides/replaceable-voice-preview-review/) · [Retry scope](/en/guides/note-transcription-retry-checkpoint/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Pass snapshot/arguments](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Qwen3OnDeviceTranscriber.swift) · [Defaults/range/clamp](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceInterfaces.swift) · [Settings/busy scope](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieLinkSettingsView.swift)
