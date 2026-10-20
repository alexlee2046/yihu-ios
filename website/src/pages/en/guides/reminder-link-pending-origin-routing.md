---
layout: ../../../layouts/Wave3Guide.astro
title: "Why a reminder tap stays pending: voice guards, pendingURL and saved origins"
description: "Review Hermes HTTPS/host admission, retained speech/notes, known origins and connected consumption. No new server is added; login/session/service success is not established."
lang: en
---

<h2 id="first-answer">A reminder tap creates a pending link, not proof the destination session is usable</h2>

Hermes reminders pass the existing HTTPS/host parser and set pendingURL. Routing still checks notes and voice cancel/delivery/retained-text conditions. Current origin must be connected before consumption; other origins must already be saved, and unknown ones are dropped rather than added as servers. A tap proves neither login/session existence nor business success or a bundled universal push service.

## Different from payloads, Watch opening and origin admission

Payloads concern fields, Watch uses a different message/local-task route, origins concern scope. Here **reminder tap-to-existing-web-workbench pending navigation** matters. No real notification, service registration or origin change ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Entry | isHermesSessionURL HTTPS/host gate | Parser versus all-Agent compatibility | Any notification URL accepted |
| pendingURL | One pending link, cleared on consume | Slot versus click history | Reliable complete audit queue |
| Speech | canCancel/delivering/canRetryDelivery guards | Retained text versus navigation | Reminder discards unfilled text |
| Notes/switch | notesPresented/onWillSaveConnection | Existing protection | Tap overwrites material |
| Current origin | isConnected before consumePendingURL | Local loading versus service | Login/session verified |
| Other origin | Only recentOrigins can switch | User-saved source | Notification adds a server |
| Unknown | Consume/drop instead of create | Actual target review | Loosen trust to fix everything |
| Outcome | Navigation/login/session/write separately | Do not copy guards across entries | Tap submits/approves |

</div>

## Synthetic reminder note

pendingURL alone establishes pending navigation, not an opened session. Retained speech can block switching; do not discard it for a link. Unknown origins do not become available services merely by appearing in reminders.

Source/connected checks do not certify accounts or business results. No push-service/delivery/device/visual test ran and no hosted Agent/push platform is supplied.

## FAQ

<h3 id="faq-1">Does tapping prove the session opened?</h3>

No. Pending link, guards and actual navigation differ.

<h3 id="faq-2">Are all notification URLs accepted?</h3>

No. Parser, saved/current origins and path-specific conditions remain.

<h3 id="faq-3">Will an unsaved server be added?</h3>

Not by this route; unknown origins are dropped.

<h3 id="faq-4">Does connected prove login/session existence?</h3>

Not independently; inspect the destination separately.

<h3 id="faq-5">Can a reminder override retained transcription?</h3>

Do not bypass speech/note/switch guards; preserve pending material.

<h3 id="faq-6">Was push enabled or a real link opened?</h3>

No. Existing source route only, without third-party registration/authority.

## Reading and source

[Payload model](/en/guides/notification-payload-model-preflight/) · [Watch route](/en/guides/watch-open-request-ui-boundaries/) · [Origin scope](/en/guides/workbench-origin-page-boundaries/) · [Pending material](/en/guides/degraded-handoff-go-no-go/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Parsing/pending link](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieHermesPush.swift) · [Reminder routing](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift) · [Connection/navigation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift)
