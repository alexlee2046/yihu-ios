---
layout: ../../../layouts/Wave3Guide.astro
title: "Near-field preference versus actual route: HFP allowance and capture policy"
description: "Review existing short-speech playAndRecord/voiceChat, HFP allowance and graph policy. No forced microphone, noisy-environment performance or universal-path guarantee."
lang: en
---

<h2 id="first-answer">allowBluetoothHFP is permission to use a route, not proof it was selected or more accurate</h2>

Short-speech start reads the near-field preference. Enabled policy uses playAndRecord/voiceChat with mixWithOthers/allowBluetoothHFP; disabled policy uses record/default. Input graph policy branches too. These are implementation choices, not successful hardware activation, forced mic selection or measured accuracy. No noise-removal/mic-selection service is added.

## Different from accessory suitability and recovery

Suitability checks environment; recovery checks capture events. Here **stored preference, startup configuration, graph and actual route have separate evidence scopes**. No setting or recording changes occur; long notes use another capture path.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Preference | Default true when absent | Actual version/entry | Default means system authorization |
| Enabled session | playAndRecord/voiceChat | Category/activation results | Universal success or no echo |
| HFP | allowBluetoothHFP permits | Actual input route | Paired headset mic forced |
| Mixing | mixWithOthers policy | Actual playback/output | Unlimited web TTS/capture coexistence |
| Input graph | Voice-processing policy etc. | Actual configuration success | Noise benchmark or speaker identification |
| Disabled | record/default path | Actual entry/state | All accessories compatible |
| Startup snapshot | Preference read at start | This capture versus later settings | Saved changes prove old capture rebound |
| Other capture | Long notes separately implemented | Actual entry/permission/format | Every recording/page uses one policy |

</div>

## Synthetic policy review

Known: preference enabled. Unknown: selected HFP input and graph result. Report allowance only, not route selection or noise performance. Startup failures retain original handling rather than forcing mismatched pipelines.

voiceChat/voice processing names are not wind, distance, latency or accuracy SLAs. Actual route/safe environment need review without replacing device/OS acceptance or expanding service/target authority.

## FAQ

<h3 id="faq-1">Does true mean microphone permission granted?</h3>

No. Preference, system authorization and successful start differ.

<h3 id="faq-2">Does HFP allowance force headset input?</h3>

No. Inspect the actual route, not pairing or options alone.

<h3 id="faq-3">Does voiceChat guarantee cycling wind performance?</h3>

No benchmark/SLA is supplied; do not operate while driving/cycling.

<h3 id="faq-4">Does mixWithOthers guarantee all page playback/capture coexistence?</h3>

No. Actual page/system/input/output boundaries still matter.

<h3 id="faq-5">Do long notes use this exact policy?</h3>

Do not generalize short-speech configuration to the separate long-note path.

<h3 id="faq-6">Does editing preferences prove old capture rebound?</h3>

No. Inspect startup, phase/route and original guards.

## Reading and source

[Accessory preflight](/en/guides/vehicle-exhibition-microphone-preflight/) · [Route recovery](/en/guides/audio-route-recovery-matrix/) · [Permission/format](/en/guides/microphone-permission-sample-contract/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Policy/graph/start](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift) · [Existing settings](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieLinkSettingsView.swift) · [Separate long-note path](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift)
