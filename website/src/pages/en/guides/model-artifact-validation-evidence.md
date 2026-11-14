---
layout: ../../../layouts/Wave3Guide.astro
title: "What model validation proves: revision, asset SHA, loading and warm-up differ"
description: "isInstalled checks revision, asset sizes and hashes. Integrity is not CoreML readiness or accuracy; loaded/warmed instances can be reused. No downloads/inference ran."
lang: en
indexable: false
---

<h2 id="first-answer">Pinned asset identity is not accuracy; installation, loading and warming are separate gates</h2>

Qwen3ModelStore.isInstalled checks a fixed revision marker and listed asset sizes/SHA-256, not directory existence alone. New loading still has an integrity gate, while CoreML load/warm-up can fail separately. validateInstalledModel can reuse a loaded/warmed instance rather than reread every file each call. File evidence does not establish every word's accuracy or scenario readiness.

## Different from trial, voiceprint and material digests

Trial checks the whole chain; voiceprint is another convenience filter; digests identify bytes. Here **pinned ASR assets, installation, memory loading and warming** have separate evidence scopes. No download, private voice access, removal or inference ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Pinned manifest | Repository revisions/per-asset bytes/SHA | Actual fixed-source manifest | Any same-name weights compatible |
| isInstalled | Marker and listed sizes/digests | Cancellation/missing/mismatch causes | Directory presence suffices |
| Manifest scope | Listed assets checked | Reviewed files versus other material | Every directory file authenticated |
| Publish tree | Verified staging then replace/move | Actual install/error | Progress means loaded |
| Load | loadIfNeeded checks memory first | New load integrity/generation | Every call rescans all files |
| Generation | installGeneration guards suspended old load | Old preparation/current model | Identity signature |
| Warm-up | validate can reuse warmed instance | Actual results/errors | Real speech accuracy accepted |
| Retention evidence | Version/manifest/actual checks | Device/permissions/audio/content separately | Security certification/semantic truth/restore SLA |

</div>

## Synthetic validation note

Known: assets match one pinned manifest. Unknown: this device's CoreML load, warming and speech quality. Report file integrity only, not recognition performance. Reusing a loaded instance cannot be described as a just-completed full disk recheck.

Do not falsify revision markers/manifests or download/remove real models for demonstration. Digests match expected bytes, not release trust, usage permission, runtime compatibility or speech accuracy. None was benchmarked here.

## FAQ

<h3 id="faq-1">Does isInstalled check only folder existence?</h3>

No. Fixed revision, listed sizes and SHA are checked.

<h3 id="faq-2">Do matching hashes guarantee every sentence?</h3>

No. Integrity differs from runtime, device/audio and meaning.

<h3 id="faq-3">Does validate reread all files every time?</h3>

Not necessarily. Loaded/warmed instances can be reused; new loading still needs integrity.

<h3 id="faq-4">Can loading fail after installation?</h3>

Yes. CoreML load/warm-up differ from download status.

<h3 id="faq-5">Does false prove malicious modification?</h3>

No. Cancellation, missing/read/size/hash/version conditions need separate review.

<h3 id="faq-6">Was a model run/downloaded?</h3>

No. Source/evidence review only, without performance/device acceptance.

## Reading and source

[Whole-chain trial](/en/guides/first-trial-go-no-go-checklist/) · [Voiceprint distinction](/en/guides/voiceprint-filter-not-authorization/) · [Material/version mapping](/en/guides/batch-change-record-retention/) · [Preview/final](/en/guides/replaceable-voice-preview-review/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Manifest/install/verification](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Qwen3ModelStore.swift) · [Load/validation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Qwen3OnDeviceTranscriber.swift) · [Existing preparation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
