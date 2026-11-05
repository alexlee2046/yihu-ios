---
layout: ../../../layouts/Wave3Guide.astro
title: "PCM format admission: rates, channels and conversion are not device certification"
description: "Review finite rate range, 1–8 channels, non-interleaved Float32 and block consistency. Preconditions do not guarantee converter creation or success; no compatibility mode."
lang: en
---

<h2 id="syn-pcm-36">SYNTHETIC_EXAMPLE · SYN-PCM-36 PCM/EOF preflight</h2>

<a href="/samples/p14-pcm-admission/pcm-admission-preflight.en.json" download>/samples/p14-pcm-admission/pcm-admission-preflight.en.json</a> · <a href="/samples/p14-pcm-admission/preflight-card.md" download>/samples/p14-pcm-admission/preflight-card.md</a>

Fourteen byte-declaration cases, seven source guard cases and stream-end references are SYNTHETIC_EXAMPLE, not an app raw PCM importer. Valid s16le/f32le structure does not grant native Float32 non-interleaved admission. Source finish drains delayed samples; it does not repair cut frames by zero padding. Device/conversion/ASR/SLA results are not_run.

<div role="region" aria-label="Synthetic PCM structure preflight table" tabindex="0">
<table>
<thead><tr><th>Layer</th><th>Worked check</th><th>Not established</th></tr></thead>
<tbody>
<tr><td>16/24/48k declaration</td><td>Compare independent producer metadata; byte length is not a rate detector</td><td>Relabeling resamples audio</td></tr>
<tr><td>s16le/f32le</td><td>16/32bit, little endian and actual layout checked separately</td><td>Integer/interleaved raw is native converter input</td></tr>
<tr><td>Mono/stereo frames</td><td>Interleaved frame=channels×sample bytes;6B stereo s16le is incomplete</td><td>Zero fill recovers missing original content</td></tr>
<tr><td>Stream end</td><td>noDataNow between blocks; endOfStream at finish, at most16 flush calls</td><td>16 seconds/frames or automatic-padding SLA</td></tr>
</tbody></table>
</div>

Store0.1.0/id6819057500 installation needs no Mac/Xcode/self-signing; your account/models/permission/safe destination remain separate, without source/binary parity certification.

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
