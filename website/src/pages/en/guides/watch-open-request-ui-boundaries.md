---
layout: ../../../layouts/Wave3Guide.astro
title: "Did Open on iPhone actually open? Watch queued messages, foreground routing and local tasks"
description: "Review basic open acknowledgement versus phone UI checks. sourceToken is not login authority; do not import voice/draft taskToken guards or treat queued as UI/business success."
lang: en
---

<h2 id="first-answer">Accepting an open request does not prove the correct task appeared on iPhone</h2>

Open-message queued acknowledges basic field shape before openRequest is set. Foreground phone routing then checks UUID, task in the current local snapshot, eligible status and sourceToken, plus switching/handoff guards. queued is not opened UI. The voice/draft taskToken checks cannot be copied onto this open path; opening is not submission or approval.

## Different from fields, Watch voice and draft restoration

Fields concern display, voice concerns transcription stages, restoration concerns phone drafts. Here **paired open messages through phone UI routing** matter. No Watch/phone/navigation operation ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Shape | kind/open and string workbench/task/sourceToken | Deeper routing checks later | queued validates all meaning |
| Pending | openRequest has nonce | Local trigger value | Task revision/approval receipt |
| Foreground | scenePhase.active for routing | Request may remain pending | Guaranteed wake/unlock |
| Task | ID/status in current local snapshot | Local knowledge versus live source | Click always refreshes server |
| Source | sourceToken checks configured identity | Hash versus account grant | Login/signature complete |
| Channel | Open differs from voice/draft | No imported taskToken guard | Every message checks identically |
| Blocked/invalid | Blocked can retain; invalid clears/notices | Actual pending/source state | Blind background business replay |
| Presentation | Tasks/filters/title search updated | UI versus source mutation | Approval/service receipt |

</div>

## Synthetic open note

queued while the phone is not foreground leaves routing pending, not task presentation established. Changed/invisible notices require authorized phone/source review instead of a final decision from an old Watch card.

Nonce/filter updates establish no service effects, truth or approval. No pairing/wake/visual test ran; live refresh/background relay is not promised.

## FAQ

<h3 id="faq-1">Does queued prove opened phone UI?</h3>

No. Acceptance and later validation/presentation differ.

<h3 id="faq-2">Does open also check taskToken?</h3>

Do not import voice/draft guards; this route uses sourceToken/local task checks.

<h3 id="faq-3">Does background phone automatically unlock?</h3>

No guarantee. Foreground routing is not unlock authority.

<h3 id="faq-4">Is a locally found task server-latest?</h3>

Not independently; this path reads a local snapshot.

<h3 id="faq-5">Does filter change update task status?</h3>

No. Display settings differ from source business state.

<h3 id="faq-6">Was an actual open/approval sent?</h3>

No. Static message/UI routing only, without navigation or business action.

## Reading and source

[Cross-device fields](/en/guides/cross-device-field-presentation/) · [Voice stages](/en/guides/watch-voice-queued-ready-boundaries/) · [Draft restoration](/en/guides/reply-draft-restoration-scope/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Open acceptance](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWatchPhoneBridge.swift) · [Open routing](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift)
