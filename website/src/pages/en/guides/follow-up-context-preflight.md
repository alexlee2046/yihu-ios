---
layout: ../../../layouts/Wave3Guide.astro
title: "Before a voice follow-up: references, workbench page and Agent context"
description: "Check what previous/continue/it refers to, the actual service conversation and draft target. Native transcription/page binding is not Agent memory or proof history reached a backend."
lang: en
---

<h2 id="first-answer">The page staying open does not prove Agent memory; resolve references before following up</h2>

Yihu transcribes native speech and attempts guarded delivery to compatible drafts. It supplies no universal Agent backend or cross-workbench conversation memory. Actual context belongs to the site/service. Previous, it and continue can become ambiguous after page/workbench changes or unverified history. Identify the referenced material, current conversation and composer first, not an app-inferred intent.

## Different from setup, correction and repeat delivery

Readiness checks prerequisites; correction checks text copies. Here **the next utterance needs an explicit antecedent and authorized target**. Do not automatically resend the previous passage to restore context, or treat visible page text as proof the service read/executed it.

## Follow-up context preflight

<div role="region" aria-label="Follow-up references and target checks, scroll horizontally" tabindex="0">

| Check | Material to establish | Synthetic example | Do not infer |
| --- | --- | --- | --- |
| Referent | Which previous phrase/item is meant | Synthetic phrase A, not a real order | It points to the correct business object automatically |
| Workbench | Current authorized HTTPS source | Existing own workbench only | Reachability is server identity/write permission |
| Page/conversation | Current page and actual service session | Is this the reviewed sample-draft session? | Navigation restoration is model memory restoration |
| Composer | Editable unsent field on the original page | Focus the compatible draft first | Arbitrary editor/terminal insertion is permitted |
| History scope | Service actually provides the required context | Visible history still needs scope/content review | Visible history necessarily reached the Agent context |
| Intended operation | Organization, proposal and execution differ | Edit sample wording only; do not send | Follow-up tone grants execution authority |
| Prior handoff | Inserted/staged/uncertain state | Inspect an existing draft | Missing receipt permits another delivery of prior text |
| Changed destination | Captured and current page/state | Recheck guards after navigation | A source switch automatically retargets an opened note |

</div>

## A less ambiguous synthetic draft

```text
Ambiguous: Continue; change it to two items.
More explicit: Review only the wording of local synthetic phrase A. Item count is unconfirmed; do not send or execute.
Still check: The current workbench/conversation is the authorized sample destination.
```

This is wording guidance, not guaranteed model interpretation or an Agent/service call. Do not copy a private conversation/customer data into a public example to add context.

## Destination binding is not backend context

Native draft delivery has source/page/request/host-refusal guards. Explicit note insertion uses the workbench/page captured when notes opened. These constrain where text may go; they do not determine which history a model receives, how pronouns are interpreted or whether a service persists conversations. A passed target guard does not establish correct understanding.

Implemented WebKit interaction restoration concerns navigation scope, not cross-origin identity copying or a unified conversation database. With unknown source, prior result or conversation, retain text and stop. Do not guess context by changing pages, repeating old rounds or clearing markers.

## FAQ

<h3 id="faq-memory">Does Yihu remember all prior speech across workbenches?</h3>

No such cross-workbench memory is asserted. It is a browser shell with voice drafts; the actual Agent conversation belongs to each service.

<h3 id="faq-restoration">Does restored page history establish restored model context?</h3>

No. Navigation/scroll state and the history supplied to a backend model are different facts requiring actual service evidence.

<h3 id="faq-pronoun">Can continue or previous omit the referenced object?</h3>

Avoid that when the object is unclear. Check material/conversation and state a synthetic reference within authorized scope rather than asking a reader to infer a real target.

<h3 id="faq-send">Can a follow-up automatically resend the prior round to restore context?</h3>

No blind resend follows. It may already be delivered or uncertain; inspect destination content and retain original request/one-handoff boundaries.

<h3 id="faq-switch">Does explicit note insertion follow page changes after opening notes?</h3>

Do not assume so. The note target is captured on opening and checked before insertion. Follow existing guards without retargeting by bypass.

<h3 id="faq-approval">Does apparent understanding authorize every requested operation?</h3>

No. Interpretation, explicit user intent and server authority differ. Original confirmation, write permission and receipts remain necessary.

## Reading and source

[Voice-draft choices](/en/guides/iphone-agent-voice-drafts/) · [Web output/capture transition](/en/guides/web-read-aloud-microphone-boundaries/) · [Originals and note targets](/en/guides/recording-notes-handoff/) · [Manual summary provenance](/en/guides/radar-summary-claim-provenance/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [draft-target guards](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift), [note target capture/checks](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift), [README service limits](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
