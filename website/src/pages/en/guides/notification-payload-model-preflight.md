---
layout: ../../../layouts/Wave3Guide.astro
title: "What a notification payload model proves: shape is not deployed push"
description: "Review exact keys, version, UUID and eventKey constraints without inferring subscriptions, delivery, navigation, write authority or new push infrastructure."
lang: en
---

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
