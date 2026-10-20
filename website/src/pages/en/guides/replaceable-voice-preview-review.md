---
layout: ../../../layouts/Wave3Guide.astro
title: "Why voice previews change: replaceable partials, final returns and evidence scope"
description: "Review complete replaceable partial strings, bufferingNewest and session/phase guards. Intermediate text is not cumulative verbatim speech or delivery proof."
lang: en
---

<h2 id="first-answer">A partial is replaceable display, not another transcript fragment to append</h2>

The recognition interface defines onPartialText as complete replaceable strings; only returned final text enters original deliverable boundaries. The controller uses bufferingNewest(1) with sessionID, phase and cancellation guards. Redecoding/final results can correct previews. Multiple displays cannot be joined into extra quotations, approvals or executed actions.

## Different from meters, segment joins and receipts

Meters show energy, long-note join handles recognition pieces, receipts concern handoff. Here **replacement semantics and evidence scope within one preview sequence** matter. No model or actual speech is processed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Interface | Complete replaceable onPartialText | Not an incremental-token append contract | Each update is a new sentence |
| Buffer | bufferingNewest(1) keeps latest | Not every intermediate update displayed | Full token timeline |
| Session/phase | sessionID/expectedPhase/cancellation | Actual recognition ownership | Old preview can join a new target |
| Length condition | Partial display uses prior-call length condition | Final return can correct | Text always grows without revision |
| Final pass | Full pass gets priority after stop | Actual return/error versus preview | Visible words guarantee final success |
| previewUnavailable | Preview-path failure can be separate | Actual final flow | Model corrupt/must delete |
| Later guards | Final still subject to voiceprint/target etc. | Text versus authority | Final is always delivered |
| Editorial retention | Final/processing/audio separately | Actual reviewed scope | Screenshot is verbatim certification |

</div>

## Synthetic preview sequence

Display sample, then sample needs review, then final sample deferred. These are not three quotations to concatenate into additional decisions. This illustrates replacement, not actual model output/accuracy.

Retain real errors/cancellation/differences instead of copying old previews around final/handoff guards. bufferingNewest is not permanent retention of every intermediate event.

## FAQ

<h3 id="faq-1">Should every partial append to an archive?</h3>

No. Complete replacement semantics make append create duplicates/conflicts.

<h3 id="faq-2">Does visible preview establish final success?</h3>

No. Recognition, filtering and delivery remain separate.

<h3 id="faq-3">Does preview always grow monotonically?</h3>

No guarantee. Redecoding/final corrections and display thresholds do not certify stable meaning.

<h3 id="faq-4">Does bufferingNewest retain every token?</h3>

No. It is neither a full event archive nor alignment.

<h3 id="faq-5">Should previewUnavailable trigger model deletion?</h3>

Do not infer corruption. Source retains final handling separately without deleting for preview failure.

<h3 id="faq-6">Is returned final necessarily inserted?</h3>

No. Voiceprint/target/permission/actual receipts still need review.

## Reading and source

[Meter distinction](/en/guides/audio-level-not-accuracy-review/) · [Long-note joins](/en/guides/note-segment-join-provenance/) · [Callback ownership](/en/guides/capture-completion-token-review/) · [Actual receipts](/en/guides/handoff-evidence-audit-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Partial contract](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceInterfaces.swift) · [Preview/final/delivery](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
