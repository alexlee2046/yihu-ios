---
layout: ../../../layouts/Wave3Guide.astro
title: "Recording stopped after switching headsets? Check what was saved"
description: "Choose a next step for silent playback, missing input or interrupted recording: compare the phone microphone, inspect saved passages, then review text and drafts."
lang: en
quickCheck: audio
---

<h2 id="first-answer">Listen to the saved passage, then compare the phone microphone</h2>

In a safe stationary setting, check whether recording is still active and whether the app reports a saved result or error. Play back the saved passage and inspect numbers and negation around the interruption. Make a separate short phone-mic sample to compare with headset input. Do not operate while driving.

## Try this order

1. **Separate playback from input.** Play existing audio to check output; hearing it does not establish that the headset microphone is selected.
2. **Keep what was saved.** After a call or switch, inspect saved audio, transcription and error state, and mark incomplete wording.
3. **Make a short comparison.** Use the phone microphone with a synthetic phrase such as “Check three items tomorrow; do not send.” Then inspect headset input and the app’s microphone permission.
4. **Inspect the existing draft.** If earlier text already reached the workbench, review that draft. Pause when the result is unclear rather than handing it off again.

## Choose your next check

<div role="region" aria-label="Checks after switching audio devices, scroll horizontally" tabindex="0">

| What you see | First action | Before continuing |
| --- | --- | --- |
| Playback is silent too | Check volume and output, then play an existing sample | Restore playback before testing input separately |
| Playback works but the headset records nothing | Compare a phone-mic sample; inspect input and permission | Use the actual new sample, not just the connection icon |
| A call or device switch stopped recording | Keep saved passages and inspect interruption messages | Check the last sentence, numbers, negation and gaps |
| A note was saved only up to a point | Play back the retained portion and mark the join | Keep the original; make a separate supplement if needed |
| Audio exists but the workbench has no text | Next inspect speech models and the intended editor | Locate the text before recording or handing off again |

</div>

## Why inspect short speech and recording notes separately?

Short speech and notes use different capture and saving paths. After an input change, the source attempts recovery when its conditions allow, but can also stop and report an interruption. Identify which entry point you used, then inspect actual audio, text and saved results. A reconnected headset cannot replace that check.

## FAQ

<h3 id="faq-output">Why can I hear the headset but not record through it?</h3>

Playback and recording input need separate checks. Compare the phone microphone first, then inspect available input choices and microphone permission in the actual app.

<h3 id="faq-switch">Should I immediately record everything again?</h3>

Keep and play back saved passages first. Mark gaps and make a separate short supplement if needed, without overwriting the original or duplicating a draft.

<h3 id="faq-call">Will recording automatically resume after a call?</h3>

Inspect the actual recording entry point and state. A call can interrupt capture; ending it does not establish recovery or completeness.

<h3 id="faq-notes">What if a note says it was saved only up to that point?</h3>

Play back the saved part, identify its last sentence and gaps, then decide whether to record a separate supplement. Review joins before organizing action items.

<h3 id="faq-draft">Can recovered audio hand off the earlier draft again?</h3>

Inspect the destination draft first. Audio recovery does not establish that the earlier handoff failed; review existing text instead of inserting it automatically again.

<h3 id="faq-report">What should I include in a report?</h3>

Start with version, device model, event category and synthetic-sample results. Keep unique device identifiers, real recordings and customer text out of public feedback.

## Continue with your task

[Audio input questions and preview](/en/guides/bluetooth-audio-input-troubleshooting/#interactive-preview) · [Notes to action items](/en/guides/recording-notes-handoff/#interactive-preview) · [Voice drafts](/en/guides/iphone-agent-voice-drafts/#interactive-preview) · [Daily sales brief](/en/guides/multi-project-radar-watch/#interactive-preview) · [Setup](/en/start/) · [Privacy](/en/privacy/)

<details><summary>Implementation reference: recovery conditions and stop messages</summary>

Short speech attempts recovery under conditions including unchanged input format; oldDeviceUnavailable/noSuitableRouteForCategory notifications can stop capture. The internal debounce grace is two seconds, not reconnection latency or a recovery guarantee. Notes attempt writer retargeting; failures still require inspection of what was saved. This page supplies no headset, call-interruption or physical-device acceptance results.

Evidence: [short-speech events and format checks](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift), [notes and interruptions](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift).

</details>
