---
layout: ../../../layouts/Wave3Guide.astro
title: "What a notification payload model proves: shape is not deployed push"
description: "Review exact keys, version, UUID and eventKey constraints without inferring subscriptions, delivery, navigation, write authority or new push infrastructure."
lang: en
---

<h2 id="syn-ntf-42">SYN-NTF-42: payloads, guarded routes and delivery boundaries</h2>

SYNTHETIC_EXAMPLE: original parsers/routes with memory doubles, not APNs/Keychain/device delivery.

[ZH: /samples/p21-notification-payload-model/preflight.zh.json](/samples/p21-notification-payload-model/preflight.zh.json) · [EN: /samples/p21-notification-payload-model/preflight.en.json](/samples/p21-notification-payload-model/preflight.en.json) · [Card: /samples/p21-notification-payload-model/preflight-card.md](/samples/p21-notification-payload-model/preflight-card.md)

<div role="region" aria-label="Synthetic notification payload, route and delivery boundary table; horizontally scrollable" tabindex="0">

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| A1 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=True | Host model only, not active subscription/APNs/auth |
| A2 | {'version': True, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A3 | {'version': '1', 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A4 | {'version': 2, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A5 | {'version': 1.0, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=True | Host model only, not active subscription/APNs/auth |
| A6 | {'version': 1, 'subscriptionId': 'invalid', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A7 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A8 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A9 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A10 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'url': 'https://synthetic.invalid'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A11 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111'} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| A12 | {'version': 1, 'subscriptionId': '11111111-1111-1111-1111-111111111111', 'eventKey': ''} | yihuRadar model accepted=False | Host model only, not active subscription/APNs/auth |
| P1 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/tasks/42'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P2 | {'version': True, 'registrationId': 'synthetic-registration', 'path': '/tasks/42'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P3 | {'version': '1', 'registrationId': 'synthetic-registration', 'path': '/tasks/42'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| P4 | {'version': 1, 'registrationId': '', 'path': '/tasks/42'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| P5 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': ''} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P6 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': 'https://other.invalid/x'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P7 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P8 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| P9 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P10 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界界'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| P11 | {'version': 1, 'registrationId': 'synthetic-registration', 'path': '/tasks/42', 'extra': 'synthetic'} | collie payload accepted=True | Separate schema; parse is not trusted route or delivery |
| P12 | {'version': 2, 'registrationId': 'synthetic-registration', 'path': '/tasks/42'} | collie payload accepted=False | Separate schema; parse is not trusted route or delivery |
| R1 | origin=https://alpha.invalid; path='/' | original route resolve=True | Foundation URL only, no server decode/browser security certification |
| R2 | origin=https://alpha.invalid; path='/tasks/42?from=push#check' | original route resolve=True | Foundation URL only, no server decode/browser security certification |
| R3 | origin=https://alpha.invalid; path='relative' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R4 | origin=https://alpha.invalid; path='https://other.invalid/x' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R5 | origin=https://alpha.invalid; path='//other.invalid/x' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R6 | origin=https://alpha.invalid; path='/../x' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R7 | origin=https://alpha.invalid; path='/%2e%2e/x' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R8 | origin=https://alpha.invalid; path='/%2f%2fevil.invalid' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R9 | origin=https://alpha.invalid; path='/a\\b' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R10 | origin=https://alpha.invalid; path='/a%5cb' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R11 | origin=https://alpha.invalid; path='/bad%ZZ' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R12 | origin=https://alpha.invalid; path='/a\nb' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R13 | origin=https://alpha.invalid; path='' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| R14 | origin=https://alpha.invalid; path='/%252e%252e/x' | original route resolve=True | Foundation URL only, no server decode/browser security certification |
| R15 | origin=http://alpha.invalid; path='/tasks/42' | original route resolve=False | Foundation URL only, no server decode/browser security certification |
| Q1 | normal | {'open_calls': 1, 'pending': False, 'callbacks': 1, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q2 | loading | {'open_calls': 0, 'pending': True, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q3 | age299999 | {'open_calls': 1, 'pending': False, 'callbacks': 1, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q4 | age300000 | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q5 | no_active | {'open_calls': 0, 'pending': True, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q6 | unregistered | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q7 | blocked | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 1, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q8 | open_false | {'open_calls': 1, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q9 | other_no_switch | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 1, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q10 | switch_loading | {'open_calls': 0, 'pending': True, 'callbacks': 0, 'blocks': 0, 'switches': 1} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q11 | switch_ready | {'open_calls': 1, 'pending': False, 'callbacks': 1, 'blocks': 0, 'switches': 1} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q12 | ambiguous | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q13 | active_wins | {'open_calls': 1, 'pending': False, 'callbacks': 1, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q14 | disabled | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q15 | invalid_route | {'open_calls': 0, 'pending': False, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| Q16 | no_web | {'open_calls': 0, 'pending': True, 'callbacks': 0, 'blocks': 0, 'switches': 0} | In-memory binding/default/session/clock, no real UI or Keychain |
| E1 | Parse/local navigation attempt is not APNs delivery/user view | source/manual boundary; runtime not_run | No remote unregister/delivery, credentials or business authorization |
| E2 | yihuRadar and collie schemas have different key/type gates | source/manual boundary; runtime not_run | No remote unregister/delivery, credentials or business authorization |
| E3 | Local disable/pending unregister is not remote unbind or system revocation | source/manual boundary; runtime not_run | No remote unregister/delivery, credentials or business authorization |
| E4 | Synthetic registration shape is not credentials or service write authorization | source/manual boundary; runtime not_run | No remote unregister/delivery, credentials or business authorization |

</div>

The original yihuRadar event and native collie payload are distinct schemas: exact inner keys/UUID/64 lowercase hex with Boolean exclusion versus registrationId/path and2048 UTF8 bytes. Do not transfer one schema gate to the other. Host Foundation number bridging is not lexical JSON or all APNs marshalling conformance. Parsed input still needs enabled local binding, origin/route and navigation/loading/exclusive300s pending gates; onOpen is not user-visible/server success. Disabled/pending unregister/timeout is not remote stop or system permission revocation. Actual permission/Keychain/APNs/UI/remote receipts are not_run. No real device tokens/private sources read; no blind replay, destination may save/sync/auto-process.

<h2 id="first-answer">Parsing an event shape is not end-to-end notification acceptance or authority</h2>

CollieRadarNotificationEvent parses a yihuRadar payload with version, subscriptionId and eventKey constraints. It represents an opaque intent, not an arbitrary URL/write command. A model alone does not establish subscription wiring, push delivery or click navigation. No push service is provisioned here.

## Different from source compatibility and phone confirmation

Review **how far evidence from one input model can support a claim**, not system permission, APNs testing or business approval. Comments require local registration and a fresh private-source read before navigation. Those requirements need independent call-chain evidence; a struct does not implement/prove them by itself.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Envelope | Reads yihuRadar dictionary | Actual caller/entry wiring | Every notification uses this model |
| Exact keys | version/subscriptionId/eventKey only | Extra keys are not automatically compatible | Arbitrary extensions accepted |
| version | Integer 1, explicitly excludes boolean | Type/version separately | true replaces 1 |
| subscriptionId | Parseable UUID | Actual local registration separately | UUID shape proves subscription |
| eventKey | 64 lowercase hexadecimal characters | Source/event association | Cryptographic signature or authentic event |
| Navigation | Comments require registration/fresh read | Actual implementation/tests/access | Parsing means task opened |
| Writes/execution | Not a write command | Original confirmation/write access/receipt | Click equals consent or execution |
| Production | Fixed-source review only | Deployment/device/delivery separately | Push live or latency guaranteed |

</div>

## Synthetic review result

Known: the fixed source checks event shape. Unproved: registration, delivery, click parser invocation and navigation. Report model review only, not a completed integration.

Do not register services, enter device tokens or expose private sources to inspect a model. Even future delivery acceptance would not turn an event intent into write authority or business completion.

## FAQ

<h3 id="faq-1">Does a struct prove deployed push?</h3>

No. Model, wiring, deployment and device delivery are separate evidence layers.

<h3 id="faq-2">Can true replace version 1?</h3>

The model explicitly excludes booleans; numeric appearance is insufficient.

<h3 id="faq-3">Is a hash-looking eventKey a signature?</h3>

No. A 64-lowercase-hex shape independently proves neither signature, authenticity nor authority.

<h3 id="faq-4">Does valid UUID prove registration?</h3>

No. Registration/identity need actual call-chain review.

<h3 id="faq-5">Does notification tapping approve execution?</h3>

No. An opaque event is not a write command. Original permission/confirmation remain.

<h3 id="faq-6">Were APNs/devices tested here?</h3>

No. Fixed source only, without delivery/navigation/latency acceptance.

## Reading and source

[Contract compatibility](/en/guides/brief-format-change-compatibility/) · [Confirmation scope](/en/guides/multi-role-approval-receipt-checklist/) · [Target/context](/en/guides/follow-up-context-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Event model/comments](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [Source/product scope](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)
