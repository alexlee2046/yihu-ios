---
layout: ../../../layouts/Wave3Guide.astro
title: "Watch Voice queued or ready? Check the Next Step | Yihu"
description: "Check the phone’s original request, transcription result and draft separately. Preview Yihu with no mic or Watch pairing, then review privacy and App Store setup."
lang: en
privacyPreview: true
trialLabel: "Try the on-page draft"
indexable: false
---

<h2 id="first-answer">Check the phone’s request, then the result and draft</h2>

Check the paired phone’s original request, target and current state. queued can confirm acceptance, the same request or cache reuse; inspect the later result. A bounded ready result is not a phone reply draft or web insertion. Keep the original request when evidence is missing instead of inventing IDs or targets to resend. receiveVoice still checks target and foreground/busy conditions for new transcription.

## Different from presentation, PCM and draft restoration

Presentation checks fields, PCM checks shape, restoration checks pending phone records. Here **Watch voice request/result stages and admission** matter. No pairing/audio/transcription/sending ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Target | sourceToken/taskToken matches | Local field hashes not signatures | Account/approval authentication |
| queued | Acceptance/same request/cache confirmation | Actual request/later result | Completed ASR/durable background queue |
| Audio | 16 kHz mono, 0<frames≤176000, finite samples | Admission versus transcoding | Every original format supported |
| New execution | Foreground/busy/model guards | Cache resend versus execution | Always-on background relay |
| ready | Recheck target/codec/bounded cache | Result versus phone draft | Web filled/reply sent |
| Paired delivery | WCSession channels and queue guards | Result versus actual receipt | Cloud/polling/guaranteed delivery |
| Retry | Reuse consistent original request | No invented ID/token replay | New ID resumes original action |
| Final handoff | Draft save/submission separately | Target/state/confirmation | Transcription completes business |

</div>

## Synthetic stage note

Only queued without a result/draft record leaves later stages unknown. Even ready text does not establish a saved phone draft: this path intentionally avoids web-composer delivery callbacks.

A cache is not unlimited history or recovery guarantee, paired background delivery is not cloud service, and voiceprint filtering is not authority. No Watch/phone/network test ran or real audio was uploaded.

## FAQ

<h3 id="faq-1">Does queued prove ASR completion?</h3>

No. Acceptance/same request/cache reuse still require result evidence.

<h3 id="faq-2">Does ready mean a saved phone reply draft?</h3>

No. Bounded result explicitly differs from phone draft/web insertion.

<h3 id="faq-3">Do 176000 frames allow any file?</h3>

No. Sampling/channel/length/finite and other gates remain; capture capabilities differ.

<h3 id="faq-4">Does every request run fresh ASR?</h3>

No. Consistent requests can reuse cached results; execution/resend differ.

<h3 id="faq-5">Is this cloud relay or guaranteed messaging?</h3>

No. Paired channels/cache do not certify delivery/background availability.

<h3 id="faq-6">Was a Watch paired or reply sent?</h3>

No. Fixed paths only, without actual cross-device acceptance.

## Reading and source

[Cross-device fields](/en/guides/cross-device-field-presentation/) · [PCM guards](/en/guides/pcm-format-admission-review/) · [Phone drafts](/en/guides/reply-draft-restoration-scope/) · [Voiceprint scope](/en/guides/voiceprint-filter-not-authorization/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Voice/cache/result flow](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWatchPhoneBridge.swift) · [Foreground/delivery scope](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
