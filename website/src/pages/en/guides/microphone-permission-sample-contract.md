---
layout: ../../../layouts/Wave3Guide.astro
title: "Before using an external mic: permission, 16 kHz mono contract and stop rules"
description: "Separate system authorization, actual input format, pipeline conversion and model readiness. No user downsampling bypass, arbitrary-format compatibility or automatic cloud fallback."
lang: en
---

<h2 id="first-answer">Permission is not format readiness, and internal 16 kHz is not hardware certification</h2>

Native capture has its own microphone request and authorization check at start. The recognition interface uses bounded 16 kHz mono PCM. Actual system input and the internal contract remain distinct; conversion/start can fail. No user downgrade-sampling switch is provided here, and permission, pairing or downloaded models do not establish complete capture success.

## Different from input diagnosis and in-progress recovery

Diagnosis locates a failure; recovery describes events during recording. Here **before adopting an accessory, identify prerequisites and reject unsafe compatibility shortcuts**. This page requests no permission, changes no audio configuration and records nothing.

## Permission and sample-contract checks

<div role="region" aria-label="External microphone permission/sample contract, scroll horizontally" tabindex="0">

| Layer | Existing contract | Check | Do not bypass failure by |
| --- | --- | --- | --- |
| Native permission | Separate request and start-time authorization check | Actual system state/app messages | Ignoring refusal or treating prior consent as permanent |
| Page capture | Separate site/system conditions | Distinguish web capture from native entry point | Treating playback/login as native authorization |
| Accessory input | Actual route/input format | Inspect input, not just paired name | Assuming every headset/adapter works |
| Internal audio | Bounded 16 kHz mono PCM recognition input | Existing pipeline successfully prepared/converted | Treating arbitrary raw bytes as valid PCM |
| Changed format | Short speech compares rate, channels, commonFormat and interleaving | Follow actual-path mismatch handling | Forcing an unsafe converter to remain in use |
| Recognition settings | Actual model sampling/decoder option scope | Real version's available settings | Invented 8 kHz fallback or arbitrary temperature/beam control |
| Model/resources | Verified compatible model, storage and permission differ | Preserve the missing prerequisite | Audio exists, therefore model verification can be skipped |
| Final text/handoff | Partial/final results and destination guards differ | Existing final-result/eligibility boundaries | Delivering unfinished partials or format failures |

</div>

16 kHz is an internal contract, not device certification, sound-quality ranking, accuracy or bandwidth SLA. The system can supply a different input format which the implementation must successfully handle. No universal converter/all-input guarantee is offered.

## A synthetic readiness record

```text
Known: Actual system microphone permission checked.
Unknown: Can this accessory format enter the existing capture pipeline?
Model: Confirm separately for the actual app version.
Decision: No business recording until format readiness is known; no sample-rate/guard bypass.
```

On permission/format/start errors, keep a minimal non-sensitive category and version, then stop the affected step. Do not publicly reproduce with customer conversations, unique device IDs or repeated system-setting changes.

## Compatibility is not implicit authority expansion

Missing accessory readiness does not authorize starting capture on another input. Missing local models does not authorize an unapproved cloud recognizer. Web failure does not authorize sharing text with a new service. Alternative input/service/destination choices require the existing user-choice/authorization process, not an inferred compatibility exception.

Prior capture/handoff attempts keep their state and one-handoff markers. Restored permission or another device does not prove the earlier action did not occur. Preserve in-progress recovery/uncertain-stop boundaries without automatic rerecording/resending.

## FAQ

<h3 id="faq-granted">Is system permission enough for any accessory recording?</h3>

No. Route, format, pipeline, model and safe environment remain separate. Authorization does not establish audio or recognized text.

<h3 id="faq-web">Does a page's microphone access transfer to native capture?</h3>

Do not infer that. Page/system/native entry points have checks; playback/login/page permission does not replace native authorization or target guards.

<h3 id="faq-8k">Can I choose 8 kHz to bypass a 16 kHz pipeline failure?</h3>

No such user switch is asserted. Follow actual fixed sampling/conversion contracts instead of bypassing mismatches as a downgrade.

<h3 id="faq-convert">Does non-16-kHz hardware always fail or always convert?</h3>

Neither absolute statement follows. Actual-version pipeline handling must succeed. One number is not a full format matrix.

<h3 id="faq-partial">Can visible partial text be delivered as final?</h3>

No. Interface partials are replaceable intermediate strings. Only the returned final enters original delivery boundaries, still subject to target/permission checks.

<h3 id="faq-fallback">Does local failure authorize cloud ASR or another microphone?</h3>

Not by default. Alternatives can change data/permission scope and need separate authorization. This page adds no automatic fallback.

## Reading and source

[Input diagnosis](/en/guides/bluetooth-audio-input-troubleshooting/) · [Recovery matrix](/en/guides/audio-route-recovery-matrix/) · [Fallback permission](/en/guides/degraded-handoff-go-no-go/) · [Accessory preflight](/en/guides/vehicle-exhibition-microphone-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [permission/format checks](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift), [capture/recognition/partial interface](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceInterfaces.swift), [current settings explanation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieLinkSettingsView.swift).
