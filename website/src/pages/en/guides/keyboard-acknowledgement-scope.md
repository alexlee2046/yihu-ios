---
layout: ../../../layouts/Wave3Guide.astro
title: "Does an enabled keyboard mean ready? Local state, asynchronous ack and page focus"
description: "Review optimistic state, keyboardRequest ordering and Bool acknowledgement. Display/focus is not universal input support, draft storage or sending."
lang: en
---

<h2 id="first-answer">Local enabled/visible is not page acknowledgement or inserted text</h2>

setKeyboardEnabled updates keyboardEnabled/keyboardVisible before awaiting enqueueKeyboard's Bool result, then rejects stale results through keyboardRequest. Failure can revert state/show an entry notice. dismissKeyboard requests UIKit end-editing and queues page disable. Local hiding proves neither immediate page acknowledgement nor saved/sent drafts.

## Different from origin, insertion bridges and audio busy states

Origin checks boundaries, bridges check text adaptation, busy states check resources. Here **keyboard intent versus page confirmation versus actual input session** matters. No keyboard, typing or page change ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Optimistic state | Enabled/visible set first | Call phase versus final result | true means physically shown |
| Script ack | Bool true counts as accepted | Actual page conditions/errors | Every input supported |
| keyboardRequest | New request invalidates old UI result | Local order/ownership | Account/server request_id |
| Serial tasks | Await prior task, recheck current request | Dispatched versus waiting | Older operation never ran |
| Native focus | Attempt becomeFirstResponder | Native/DOM/device visibility | DOM focus guarantees software keyboard |
| Hide | Local state/endEditing/queued disable | Intent versus page ack | Every page change instantly complete |
| Guards | Current webView/isTrusted required | Actual page/composer | Same name permits input |
| Handoff | Text/draft/receipt separately | Actual contents/authority | Keyboard state proves sending |

</div>

## Synthetic keyboard timing

Local fields become true on enable request while script acknowledgement is pending. Report intent, not readiness. A later disable means the old enable response cannot update the newer UI conclusion.

Actual device/input evidence remains necessary. Avoiding busy-page delay is a design intent, not zero-latency/universal-page acceptance. Do not change local booleans to bypass conditions.

## FAQ

<h3 id="faq-1">Does true prove a visible keyboard?</h3>

No. Optimistic state precedes ack; physical input conditions differ.

<h3 id="faq-2">Does Bool ack prove inserted transcription?</h3>

No. It acknowledges keyboard configuration, not insertion/sending.

<h3 id="faq-3">Is keyboardRequest a server request ID?</h3>

No. Local ordering grants no identity/write authority.

<h3 id="faq-4">Does hiding instantly confirm page disable?</h3>

No inference follows; queued page operations differ from local display.

<h3 id="faq-5">Does DOM focus guarantee a device soft keyboard?</h3>

No. Native input-session/device conditions need validation.

<h3 id="faq-6">Was real typing/device testing performed?</h3>

No. Fixed-source scope only, without browser/device acceptance.

## Reading and source

[Page/origin](/en/guides/workbench-origin-page-boundaries/) · [Text bridge](/en/guides/host-bridge-outcome-boundaries/) · [Busy states](/en/guides/audio-busy-state-admission/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Keyboard request flow](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift) · [Page keyboard policy](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieKeyboardPolicy.swift)
