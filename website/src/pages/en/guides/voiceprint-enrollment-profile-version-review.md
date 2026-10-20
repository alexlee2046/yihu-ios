---
layout: ../../../layouts/Wave3Guide.astro
title: "Why six enrollment phrases? Voiced frames, legacy profile versions and capture mode"
description: "Separate six-phrase enrollment, v1 three/v2 six groups and 32000 voiced frames. Partial consistency is not completion, arbitrary import or identity; no biometrics are read."
lang: en
---

<h2 id="first-answer">Phrase count, voiced estimates and legacy compatibility are separate enrollment conditions</h2>

Current enrollment requires 6 phrases and 32000 voiced frames per phrase, unlike the 16000-frame matching floor. voicedRange estimates counts, not total recording seconds or semantic truth. Current v2 profiles require six groups; legacy v1 allows three only with dimension/finite/consistency conditions. This is not arbitrary three-phrase import, mode bypass or identity authentication.

## Different from matching, near-field policy and model assets

Matching checks convenient filtering, near-field checks capture policy, assets check fixed files. Here **enrollment completeness, profile versions and mode prerequisites** matter. No recording or real profile read/replacement ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Current enrollment | enrollmentPhraseCount=6 | Quiet/everyday prompts versus material | Six seconds completes enrollment |
| Per phrase | enrollmentMinimumVoicedSamples=32000 | At 16k about two voiced-estimate seconds, not wall time | Two seconds recorded always enough |
| Matching | minimumVoicedSamples=16000 | Separate stage | Floors interchangeable |
| Incremental consistency | enrollmentIsConsistent can inspect subsets | Partial pass versus completeness | One/two phrases finishes |
| Version | Current v2 six/legacy v1 three | Format/dimensions/finite/consistency | Every old profile compatible |
| File selection | Existing current chosen first | Actual loading outcome | Broken v2 automatically restores v1 |
| Mode | profileCaptureModeMatches prerequisite | Capture toggle versus other routes | Changing mode always retains compatibility |
| Authority | Local enrollment/similarity policy | Actual authority separately | Biometric/spoof/accuracy certification |

</div>

## Synthetic enrollment note

Three vectors passing a helper do not complete current six-phrase enrollment. Legacy paths still require version/dimension/consistency. Capture-mode changes require original-setting review, not automatic profile replacement or importing another person's data.

Voiced counts/similarity are algorithmic conditions, not content/identity or real-scene scores. No biometrics/person/device test ran; cross-environment/distance/noise performance is not promised.

## FAQ

<h3 id="faq-1">Are six phrases six total seconds?</h3>

No. Phrase count and per-phrase voiced conditions differ.

<h3 id="faq-2">Do two recorded seconds meet 32000 voiced frames?</h3>

Not necessarily; wall duration and voicedRange estimate differ.

<h3 id="faq-3">Are all old three-phrase profiles accepted?</h3>

No. The v1 branch retains other checks, while current v2 needs six groups.

<h3 id="faq-4">Does partial consistency complete enrollment?</h3>

No. Helpers and final completeness differ.

<h3 id="faq-5">Will broken current profiles automatically restore legacy?</h3>

Not guaranteed; file existence selects the path rather than bypassing failed current validation.

<h3 id="faq-6">Were real profiles read/re-enrolled?</h3>

No. Source conditions only, without biometrics or identity claims.

## Reading and source

[Matching versus authority](/en/guides/voiceprint-filter-not-authorization/) · [Capture policy](/en/guides/near-field-policy-route-review/) · [Model evidence](/en/guides/model-artifact-validation-evidence/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Constants/version/consistency](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceprint.swift) · [Enrollment flow](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceprintSettingsView.swift)
