---
layout: ../../../layouts/Wave3Guide.astro
title: "What voiceprint decisions prove: convenience filtering is not identity or authority"
description: "Source explicitly calls local voiceprint filtering non-authentication. match/bypass/unavailable and threshold 0.70 are not identity probability, signing or operation permission."
lang: en
---

<h2 id="first-answer">Voiceprint match is not authentication; bypass is not a successful comparison</h2>

CollieVoiceprint explicitly describes a local convenience filter, not authentication, with false positives possible. Decision includes bypass, match, mismatch and unavailable. Disabled comparison can bypass without matching. Threshold 0.70 is not a 70% identity probability. No decision replaces account/target authority, phone confirmation or execution receipts.

## Different from sampling, routes and approval roles

Sampling checks input, route review checks system state, role review checks authority. Here **local sound-filter conclusions must not be elevated into identity/approval**. No real voiceprint is recorded, enrolled or read, and no setting/model is changed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Disabled | decide returns bypass | No comparison versus match | Speaker identity verified |
| match/mismatch | Score/threshold classification | Actual branch/limited context | Identity authentication or unforgeable signature |
| 0.70 threshold | Implementation comparison threshold | Not calibrated identity probability | 70% confidence or population accuracy |
| unavailable | Mode/sample/vector prerequisites missing | Unready versus mismatch | Not the speaker, or permission to bypass |
| Minimum voiced samples | 16000, about one second at 16 kHz | Voiced count versus total duration | One-second recording always sufficient |
| Capture mode | Stored/current modes separately checked | Existing settings guidance/process | Old profile applies after every change |
| Original delivery | Foreground/session/target guards remain | Actual entry/state | Local filtering grants server writes |
| Retention evidence | Actual filtering scope only | Identity, truth and approval separately | Automatic signing/approval/execution |

</div>

## Synthetic decision note

Result: bypass because comparison was disabled. Record not compared, not speaker verified. Unavailable likewise retains its limited cause rather than inventing match/authority.

Voices/profiles are sensitive; public review needs no recordings/vectors. No population/device, anti-spoofing or noise benchmark ran. This does not recommend disabling safeguards or turn a convenience feature into biometric authentication.

## FAQ

<h3 id="faq-1">Can match establish the speaker authorized an operation?</h3>

No. Source explicitly says non-authentication; account/scope/confirmation remain separate.

<h3 id="faq-2">Are bypass and match equivalent?</h3>

No. Bypass can occur without comparison when disabled.

<h3 id="faq-3">Is 0.70 a 70% identity confidence?</h3>

No. It is a score threshold, not calibrated probability/population accuracy.

<h3 id="faq-4">Does unavailable prove another speaker?</h3>

No. Mode/sample/profile readiness differs from mismatch.

<h3 id="faq-5">Is one second always enough voiced audio?</h3>

No. Total duration and voiced sample count differ.

<h3 id="faq-6">Is authentication/enrollment/signing added here?</h3>

No. Fixed-source review collects no biometrics and establishes no new identity/authorization process.

## Reading and source

[Sampling permission](/en/guides/microphone-permission-sample-contract/) · [Capture mode](/en/guides/near-field-policy-route-review/) · [Confirmation/authority](/en/guides/multi-role-approval-receipt-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Non-authentication/Decision](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceprint.swift) · [Entry/delivery guards](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
