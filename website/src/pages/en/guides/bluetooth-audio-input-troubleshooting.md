---
layout: ../../../layouts/Wave3Guide.astro
title: "iPhone Bluetooth mic not recording? Check the input in four steps"
description: "A practical check for Bluetooth headsets, parked-car audio and the iPhone microphone: separate playback from recording, then choose a next step."
lang: en
---

<h2 id="first-answer">Start with a useful next step</h2>

Park or move somewhere safe, pause calls and other playback, then record a short sample. Compare the device, audible output, recording playback and a second sample after switching.

## Four checks, in order

<div role="region" aria-label="Four audio input checks" tabindex="0">

| Step | What to check | Next action |
|---|---|---|
| 1. Device | Phone, headset or parked-car audio? | Decide which microphone you intend to use; a paired name alone does not select it. |
| 2. Playback | Can you hear a prompt or recording after pausing other playback? | Check output and volume first if not, then check recording. |
| 3. Sample | Record a phrase in an app with permission and play it back. | For quiet/silent input, check that app's mic permission and compare the phone mic. |
| 4. Switch | Disconnect the accessory, record on the phone, then reconnect and compare. | If only the accessory fails, inspect available input choices, device settings and app compatibility. |

</div>

## Turn the result into one next step

- **Playback works, recording does not:** inspect the recording app's microphone permission and any available system input selector, then test a phrase.
- **Phone records, accessory does not:** keep this comparison and check the accessory connection/settings. Output alone does not establish input readiness.
- **Trouble after a call or returning to the app:** stop the current capture, reopen recording in the foreground and inspect retained text before starting another clip.
- **Recording works, but the page has no text:** check speech models and the intended workspace/editor. Keep the transcript while reviewing the destination.

## Where Yihu fits

Yihu uses iPhone audio input, transcribes with prepared local models and hands text to a compatible web draft. This checklist suggests a next action; it does not inspect or switch a website visitor's Bluetooth hardware. Available inputs vary by system/device/app. Operate car controls only while parked.

## FAQ

<h3 id="faq-output">Why does recording use my phone when the headset plays music?</h3>

Playback and capture are separate choices. Compare short phone/accessory recordings and inspect the input options your system provides.

<h3 id="faq-permission">Where do I check mic permission?</h3>

Open Settings → Privacy & Security → Microphone for the recording app. A web workspace and native capture can have different permission requirements.

<h3 id="faq-car">Should I do this while driving?</h3>

Park first. This is a troubleshooting checklist, not driving guidance or a dedicated CarPlay interface.

<h3 id="faq-quality">Is a particular headset guaranteed to work well?</h3>

Try it on your own device and in your environment. No headset, wind-noise, distance or accuracy promise is made without device evidence.

## Continue

[Voice drafts](/en/guides/iphone-agent-voice-drafts/) · [Audio checks](/en/guides/bluetooth-audio-input-troubleshooting/) · [Voice notes](/en/guides/recording-notes-handoff/) · [Daily brief](/en/guides/multi-project-radar-watch/) · [Setup](/en/start/) · [Privacy](/en/privacy/)

<details><summary>Implementation references</summary>

[Frozen implementation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift) · [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md) · [Apple microphone help](https://support.apple.com/en-ie/101600)

</details>
