---
layout: ../../../layouts/Wave3Guide.astro
title: "Why recovery notifications are suppressed: a two-second window is not a recovery SLA"
description: "Review matching token, running engine and unchanged route/format. Real same-shape changes can be suppressed too; no forced recovery or zero-miss guarantee."
lang: en
indexable: false
---

<h2 id="first-answer">Two seconds is notification policy, not guaranteed recovery or a mandatory wait</h2>

CollieAudioRecoveryChangeDebouncer defaults to two seconds. Matching expectedToken, unexpired deadline, running engine and unchanged format/route permit suppression while retaining expectation for the window. Source also acknowledges genuine same-route/format changes can be ignored then. This tradeoff is not zero-miss, zero-latency or universal recovery evidence.

## Different from event recovery and completion tokens

Recovery matrices cover event types; completion tokens identify capture results. Here **why equivalent notices need not each surface and what suppression proves** matters. No events, timing configuration or audio settings are changed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Arm | Save token/deadline | Current expected window | Authority/recovery completed |
| Default two seconds | Configured gracePeriod | Scope, not response SLA | Guaranteed recovery/mandatory wait |
| Wrong token | Do not suppress | Capture association | Account authentication |
| Other mismatch | Expired/stopped/changed format or route resets without suppression | Actual inputs | Every anomaly always detected |
| All match | Suppress, keep expectation | Multiple notices in window | First notice only |
| Genuine same-shape change | Can still be ignored | Acknowledged boundary | Every genuine event surfaces |
| UI/content | Notice handling differs from speech | Audio/errors/final | No notice means perfect capture |
| Later action | Original recovery/target/handoff guards | Prior effects/unknowns | Automatic recapture/resend/forced rebind |

</div>

## Synthetic debounce review

Same token, inside the window, engine running, unchanged format/route: report matching suppression conditions, not that no event occurred or recovery performance passed. Changed conditions retain original handling; do not falsify flags to suppress notices.

Fixed-source logic is not call/Bluetooth/wind device acceptance. No universal event-truth detector or SLA follows from timing settings.

## FAQ

<h3 id="faq-1">Is two seconds a recovery promise?</h3>

No. Debouncing is not guaranteed recovery, latency or hardware evidence.

<h3 id="faq-2">Is only the first notice suppressed?</h3>

No. Matching expectations persist through the window for multiple notices.

<h3 id="faq-3">Must every real same-route/format change surface?</h3>

No. Source acknowledges suppression within this policy window.

<h3 id="faq-4">Does matching token prove user authority?</h3>

No. It associates recovery expectation only.

<h3 id="faq-5">Can no warning prove complete transcription?</h3>

No. Notices, audio, final text and handoff need separate evidence.

<h3 id="faq-6">Were system/accessory tests run?</h3>

No. Condition review only, without setting changes/event injection.

## Reading and source

[Recovery matrix](/en/guides/audio-route-recovery-matrix/) · [Capture tokens](/en/guides/capture-completion-token-review/) · [Display/evidence](/en/guides/audio-level-not-accuracy-review/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Recovery debouncer/call path](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)
