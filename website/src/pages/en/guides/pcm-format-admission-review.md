---
layout: ../../../layouts/Wave3Guide.astro
title: "PCM format admission: rates, channels and conversion are not device certification"
description: "Review finite rate range, 1–8 channels, non-interleaved Float32 and block consistency. Preconditions do not guarantee converter creation or success; no compatibility mode."
lang: en
---

<h2 id="first-answer">Within range is an admission prerequisite, not an all-accessory conversion guarantee</h2>

ColliePCMStreamConverter requires finite 8000–192000 Hz input, 1–8 channels and non-interleaved Float32 before attempting a 16 kHz mono output converter. Creation/conversion can still fail. This reviews exact admission, not a user rate control, hardware certification or universal audio importer.

## Different from permission and route recovery

Permission checks prerequisites; recovery checks route events. Here **why a native PCM format/block fails converter admission** matters. No capture or format-coverage benchmark ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Rate | Finite 8000…192000 Hz | Actual value/creation result | Every device in range tested |
| Channels | 1…8 | Actual channel descriptor | Speaker identification or track separation |
| Common format | pcmFormatFloat32 | Actual data, not suffix/label | Any integer PCM/compressed file directly accepted |
| Interleaving | Non-interleaved required | Actual buffer layout | Relabeling reinterprets bytes safely |
| Output | 16 kHz mono | Existing conversion succeeds | User 8 kHz bypass |
| Successive blocks | isStandard/rate/channels/format checks | Original sourceFormat match | Old converter always reusable |
| PCMChunk | Copies valid nonempty blocks across queues | Block/buffer lifetime | Privacy certification or recognition accuracy |
| Failure | unsupportedFormat/conversionFailed etc. | Format versus processing errors | Invented audio, cloud conversion or delivery |

</div>

## Synthetic format review

Input rate is in range but data is not non-interleaved Float32. Result: still fails this converter's prerequisites. A normal-looking rate is insufficient. Even passing all conditions needs successful creation/conversion.

Parameters are admission rules, not quality/accuracy promises. Do not falsify headers, force converters or skip destination/model guards. Error categories do not authenticate spoken content.

## FAQ

<h3 id="faq-1">Is 48000 Hz guaranteed usable?</h3>

No. Other conditions and actual creation/conversion must succeed.

<h3 id="faq-2">Does 1–8 channels mean speaker separation?</h3>

No. It is input admission; output is mono, not diarization.

<h3 id="faq-3">Can a Float32 label repair actual bytes?</h3>

No. Description/layout must match; labels cannot bypass checks.

<h3 id="faq-4">Do matching channels justify reusing a converter?</h3>

Not alone. Rate, standard-format and other conditions also matter.

<h3 id="faq-5">Is this hardware certification?</h3>

No device/noise/accuracy matrix was tested.

<h3 id="faq-6">Does failure trigger cloud conversion or generated fill?</h3>

No fallback/fill is added. Keep errors/gaps within the original authorized process.

## Reading and source

[Permission/sample contract](/en/guides/microphone-permission-sample-contract/) · [Route recovery](/en/guides/audio-route-recovery-matrix/) · [Interruption gaps](/en/guides/interruption-recapture-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Format/block/converter admission](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/ColliePCMStream.swift) · [Native capture entry](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)
