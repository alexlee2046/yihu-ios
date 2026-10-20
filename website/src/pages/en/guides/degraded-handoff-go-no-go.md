---
layout: ../../../layouts/Wave3Guide.astro
title: "Before copying or staging under weak coverage: degraded-handoff permission checks"
description: "After locating a network problem, decide whether to retain locally, whether a different target is authorized and whether prior delivery is uncertain. No automatic fallback, bypass or blind retry."
lang: en
---

<h2 id="first-answer">Weak coverage is not permission to change paths; inspect the original result and authority</h2>

With local text retained and a page/service unreachable, stopping locally is an option. Do not automatically move the same content to clipboard, attachments or another source. After diagnosis, this checklist evaluates permission to change the handoff and whether a prior attempt already created a copy. It adds no automatic fallback, retry or reliable-delivery queue, and manual actions do not bypass host refusal or one-handoff guards.

## A decision after, not another weak-network diagnosis

The troubleshooting guide locates model, web, cache and real-reply failures. Here the affected layer is known; decide **whether to keep waiting or perform a separately authorized manual action**. A valid outcome may be retain pending review, not a requirement to find any path that sends.

## Go/no-go before changing handoff

<div role="region" aria-label="Degraded-handoff go/no-go table, scroll horizontally" tabindex="0">

| Situation | Evidence first | Safe retained state | Not authorized by it |
| --- | --- | --- | --- |
| Text local, no handoff yet | Original, intended target and actual absence of an attempt | Retain pending user choice | Automatic upload or a newly selected source |
| Explicit host refusal | Refusal/unknown response | Retain text and stop the path | Force another editor or bypass through attachments |
| Note already attempted | One-handoff marker and destination content | Uncertain-stop with originals | Clear markers, rename or copy then redeliver automatically |
| Attachment staged | Actual version and any later upload | Inspect tray and destination stage | Unsent interpreted as not uploaded |
| Manual copying proposed | Authorized destination, existing text and handling rules | Explicit user choice within reviewed scope | Duplicate-free copying or local-only retention claims |
| Source change proposed | Identity, cache-clear conditions and unresolved replies | Follow existing conditions; stop on failure | Bypass a frozen/unauthorized result by changing sources |
| Real reply timeout | Original request_id, pending state and readback | Inspect through original identity | New-ID resend or timeout treated as no write |
| Urgent contact needed | Existing validated communication/safety process | Leave this trial for that process | Treat draft, staging or queued as urgent delivery |

</div>

## A synthetic retain-without-forwarding decision

```text
Known: Sample text is local; web handoff result is uncertain.
Unknown: Whether the destination already contains it.
Proposed alternative: Copy to a different draft.
Decision: Do not copy/forward yet; retain originals and inspect destination content.
Reason: A new copy cannot prove the earlier attempt did not happen or prevent duplicates.
```

This does not ban all manual copying. It requires permission, destination-content and uncertainty checks first. No cross-target deduplication/recall is supplied, and no network disconnection, cache deletion or task reset is required for a test.

## Four questions before fallback

1. **What changes?** Local retention, copying, staging, attachment upload and sending are different actions, not one fallback-send operation.
2. **Is the old result known?** Inspect original note/request state and destination content. An absent receipt is not proof of no write.
3. **Is the new destination independently authorized?** Web read access, model download and Bluetooth pairing do not authorize sharing data to any service.
4. **Which copies remain?** Clipboard, document sync and workbench attachments can expand processing. Retain without handoff if the scope is unclear.

Connectivity returning does not authorize automatically resending everything pending. Target, source identity, permission and content may have changed. Keep existing guards/confirmation; no offline outbox, background compensation or cross-source migration is added.

## FAQ

<h3 id="faq-fallback">Does Yihu automatically turn notes into attachments on weak coverage?</h3>

No such capability is asserted here. Explicit handoff and reservation remain; weak coverage grants no path-switch, retry or upload authority.

<h3 id="faq-refusal">Can a file upload bypass a refused text target?</h3>

Do not use attachments to bypass refusal. Retain originals and stop the affected path, following actual host permission rather than searching for a permissive editor.

<h3 id="faq-copy">Is manual copying always safe and duplicate-free?</h3>

No. It creates a copy and the destination can sync, save or already contain the same text. Explicit user choice and scope checks are needed, without a duplicate-free guarantee.

<h3 id="faq-pending">Can I switch workbenches and resend an uncertain request?</h3>

Do not change sources to bypass uncertainty. Preserve the original identity/pending state and existing readback/confirmation boundary.

<h3 id="faq-online">Should all local notes send automatically when connectivity returns?</h3>

No. Connectivity does not establish unchanged permission, destination or relevance. Recheck state; this page implements no automatic outbox.

<h3 id="faq-stop">Is retaining locally simply a failed workflow?</h3>

Not as a blanket label. It can be an explicit safe-stop result. It is not remote delivery and does not negate completed local processing.

## Reading and evidence

[Layered weak-network diagnosis](/en/guides/offline-workbench-handoff-troubleshooting/) · [One-handoff/attachment boundaries](/en/guides/recording-notes-handoff/) · [Correction and copies](/en/guides/noisy-transcript-text-correction/) · [Handoff evidence review](/en/guides/handoff-evidence-audit-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [one-handoff model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift), [source-read/change conditions](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift), [README uncertain replies](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
