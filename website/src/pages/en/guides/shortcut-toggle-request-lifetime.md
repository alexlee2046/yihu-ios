---
layout: ../../../layouts/Wave3Guide.astro
title: "Did a shortcut return start recording? A 30-second toggle request consumed once"
description: "AppIntent sets pendingToggle; foreground ready starts, recording finishes. A 30-second lifetime is not SLA/background authority, repeated Bool requests are not an N-item queue."
lang: en
---

<h2 id="first-answer">An Intent result is not completed recording, insertion or sending</h2>

ToggleVoiceInputIntent sets pendingToggle and requests opening the App. The foreground workbench actually consumes start/stop requests. A live request lasts 30 seconds and is consumed once; repeated requests refresh a Bool/timestamp rather than enqueue N actions. Ready can start, recording can finish, other conditions wait or expire. Neither timely response nor bypass of microphone/target guards follows.

## Different from permission, busy states and audio rebind

Permission checks consent, busy checks admission, rebind checks routes. Here **system Intent-to-local-toggle lifecycle** matters. No Siri/Action Button/shortcut setup or microphone operation ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Intent | perform requests toggle/returns result | Request versus capture | Return proves recording |
| Entry | openAppWhenRun declaration | Actual system binding/availability | All devices/phrases configured |
| Pending | Bool/requestedAt | Repeats refresh time | N requests execute N recordings |
| consumeToggle | Live request once/clear pending | Thirty-second lifetime versus speed | Guaranteed start within thirty seconds |
| Foreground | Active workbench/note/capture guards | Actual UI state | Old background request silently records |
| Toggle | Ready starts/recording finishes | Not always start | Every repeat creates a recording |
| Authority/target | Original capture/handoff conditions | Permission/target/receipt | Intent already sent Agent command |
| Expired | No very-late consumption | Fresh user action | Unlimited queue/recovery |

</div>

## Synthetic Intent note

An Intent result alone establishes a request, not captured audio or inserted text. Running the entry while recording can finish it rather than create another note. Check actual state, not button counts, for material quantity.

Declared system entries do not prove every Siri phrase/hardware binding/device available. No entry was configured, background recording authorized or Agent task executed.

## FAQ

<h3 id="faq-1">Does Intent return prove recording?</h3>

No. Request, consumer and capture stages differ.

<h3 id="faq-2">Is thirty seconds a response SLA?</h3>

No. It is request lifetime, not latency acceptance.

<h3 id="faq-3">Do repeats queue equally many recordings?</h3>

No. Pending is Bool, not a count; toggles can finish an existing recording.

<h3 id="faq-4">What does another invocation during capture do?</h3>

It can finish capture, subject to actual foreground/state conditions.

<h3 id="faq-5">Does it force recording in background/without consent?</h3>

No bypass or background-relay guarantee follows.

<h3 id="faq-6">Were Siri/hardware bindings tested?</h3>

No. Source entries only, without specific-device setup/tests.

## Reading and source

[Permission](/en/guides/microphone-permission-sample-contract/) · [Busy guards](/en/guides/audio-busy-state-admission/) · [Foreground rebind](/en/guides/foreground-audio-rebind-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Intent/lifetime/consume](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceShortcuts.swift) · [Foreground consumer](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift) · [Capture/handoff](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift)
