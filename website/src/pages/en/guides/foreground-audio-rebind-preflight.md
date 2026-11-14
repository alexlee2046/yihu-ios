---
layout: ../../../layouts/Wave3Guide.astro
title: "Returning to foreground: request invalidation, transcription resume and target review"
description: "Separate permission-dialog inactive, true background, short-speech cancellation and note transcription. Recheck state/route/target without seamless audio rebinding or lock-screen recording promises."
lang: en
---

<h2 id="first-answer">Foreground is a state event, not capture, audio-rebind or delivery confirmation</h2>

The current foreground callback enters short-speech readiness checks and resumes existing note transcription. Leaving the active state follows cancellation/pause logic. A permission dialog's `inactive` differs from true `background`. Rebind preflight here means manual state/route/target review, not a promise that every audio session seamlessly resumes.

## Different from audio recovery and format preflight

Recovery concerns route/engine notifications; permission/sample review concerns authorization and format. Here **after lifecycle changes, which request remains valid and which work can continue** is the task. No setting change, recording, background inference daemon or forced-rebind switch is supplied.

## Foreground-return checks

<div role="region" aria-label="Lifecycle request/audio-state checks, scroll horizontally" tabindex="0">

| Event/state | Current implementation boundary | Review on return | Does not establish |
| --- | --- | --- | --- |
| Preparing permission dialog | Exception when not background, preparing and requesting permission | Valid request, actual consent and phase | Every inactive cancels, or every return is a new recording |
| True background | Invalidates cancellable short-speech requests, including late permission responses | Old request is not a newly authorized session | Late granted revives the canceled capture |
| Other inactive transition | Original short-speech cancellation, subject to cancellable state | Canceled, complete and unresolved content separately | Cancellation recalls prior insertion/server effects |
| applicationDidBecomeActive | Readiness check and possible idle model warm-up | Actual UI phase and valid pending preparation | Callback establishes capture/recognition success |
| Note transcription pause/resume | Shell pauses outside active, resumes when active | Pending text, errors and actual note state | Background model inference or uninterrupted audio everywhere |
| Audio input/pipeline | System route may have changed | Current permission/format/recovery conditions | Every accessory session seamlessly rebound |
| Page/draft target | Existing insertion/target guards remain | Workbench, page, draft and authority | Same-looking view restores Agent memory or resend eligibility |
| Existing handoff | One-handoff and uncertain-stop boundaries remain | Target content, attempted state and receipts | Foreground clears prior effects or permits blind retry |

</div>

Cancellation invalidates short-speech work through session identity/task cleanup; it does not erase effects already committed. Note transcription and live capture are different state machines. One callback cannot establish lock-screen continuity for all paths.

## Synthetic return review

```text
Before: Short speech awaiting permission, no final result.
Transition: True background invalidates the old request.
Return: Even with system granted, inspect current state; do not attach late consent to old work.
Next: Explicit choice through the existing entry point; check target/prior content, no automatic rerecord/resend.
```

This is not a real permission dialog or device regression result. A dialog causing inactive only can preserve pending preparation. Identify the event rather than assuming a returned screen reveals the path.

## Rebinding cannot bypass conditions

Current route, format, model and destination retain existing checks. Do not force old converters, ignore failures or adopt a cloud service to make old recording appear continuous. Renaming/replacing drafts does not erase reservations.

When state/content is uncertain, stop within original scope and inspect evidence. No lock-screen/call/accessory/OS matrix was tested, and no zero-loss, latency or background-continuity guarantee is supplied.

## FAQ

<h3 id="faq-inactive">Does inactive always mean true background?</h3>

No. Permission dialogs can cause inactive; preparing permission requests have an exception. Identify actual event and phase.

<h3 id="faq-late">Can late granted after background revive an old request?</h3>

Current short-speech logic invalidates cancellable work on true background. Late permission is not evidence the canceled capture resumes.

<h3 id="faq-resume">Does resumeTranscription mean microphone capture continues?</h3>

No. Transcription, audio capture and handoff differ. A method name does not guarantee continuous recording across every path.

<h3 id="faq-active">Does active prove model recognition completed?</h3>

No. Readiness/warm-up is not returned final text. Inspect actual state and errors rather than inferring results from callbacks.

<h3 id="faq-rebind">Is there a forced seamless-rebind or lock-screen recording switch?</h3>

None is added. This is state/binding preflight, not universal device/OS recovery evidence.

<h3 id="faq-retry">Does foreground clear handoff history so retry is safe?</h3>

No. Prior attempts/effects still need review. Lifecycle transitions do not cancel one-handoff/uncertainty rules.

## Reading and source

[Audio recovery](/en/guides/audio-route-recovery-matrix/) · [Permission/sample contract](/en/guides/microphone-permission-sample-contract/) · [Target/context review](/en/guides/follow-up-context-preflight/) · [Handoff claim review](/en/guides/handoff-evidence-audit-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [short-speech lifecycle/cancellation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceController.swift), [shell transcription lifecycle](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift), [original target guards](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift).
