---
layout: ../../../layouts/Wave3Guide.astro
title: "iPhone read-aloud vs voice input: what differs? | Yihu"
description: "Playback is not recording or a sent draft. Check the boundaries, US App Store 0.1.0 listing and Apache-2.0 source—not a native TTS promise."
lang: en
---

<h2 id="first-answer">Web playback does not establish built-in Yihu TTS or a voice-call backend</h2>

Yihu wraps WebKit for your own Agent workbench and adds native transcription/draft delivery. When a site offers read-aloud, its text, voice, generation service and playback controls belong to that site's implementation. Source configuration permits inline media, not universal acceptance of TTS, continuous two-way voice or lock-screen playback. This guide addresses the transition from listening to a web page to dictating a phrase, not another pairing checklist or certification of arbitrary voice Agents.

## Separate output, capture and handoff

**Output**: whether the authorized site offers read-aloud, produces playable content and routes sound where expected are different questions. Yihu does not supply a general TTS service; silence/network failure is not automatically a headset problem.

**Capture**: system microphone authorization, page capture requests and native recording controls have separate rules. Permission to play is not permission to record, and opening a page is not native or server-write authority.

**Handoff**: native recognized text can attempt guarded insertion into a compatible draft, without sending. A site's own voice session follows its service rules. Neither path establishes receipts or compatibility for the other.

## Read-aloud to input checks

<div role="region" aria-label="Web output and microphone transition checks, scroll horizontally" tabindex="0">

| Check | Current basis | Observe | Do not infer |
| --- | --- | --- | --- |
| Web read-aloud | Provided by the particular site/service if present | Content origin, page controls and actual playback | Built-in universal Yihu TTS or a hosted voice Agent |
| Inline media | WebKit permits inline playback | The actual site/system combination | Universal media, background or lock-screen acceptance |
| Output route | System output and page volume/pause state | Phone speaker versus selected headset | Connected output proves the active microphone |
| Page capture | Separate page/system permission boundary | Which page requests the mic and whether the user permits it | Playback permission is capture/write permission |
| Native recording | Separate permission, models and capture entry point | System mic-use state and interruption messages | Stable concurrency with web capture or no conflicts |
| Transcript draft | Page/editor/host-permission guards | Existing unsent text or explicit refusal | Audible output proves insertion or a sent message |
| Stop/recovery | Site, system and native paths have their own controls | Whether your playback/recording stopped and target changed | Closing a panel recalls data already received remotely |

</div>

## A safe single-path transition

1. Use authorized synthetic material while safely stationary, not customer data, private tasks or real meeting audio.
2. Identify whether you are using the site's voice/playback controls. End this output through its existing stop/pause action and inspect state. Do not start simultaneous web/native capture to probe concurrency.
3. Check system microphone permission, actual route, model availability and the intended draft. Do not reset another person's session, permissions or settings. Stop the affected path on conflict rather than repeatedly pressing Record.
4. Use “Prepare a sample checklist; keep a draft without sending.” Short speech may automatically attempt guarded insertion, so select the target first and inspect whether text already appeared.
5. Retain the original and inspect destination content on uncertainty. Do not switch pages/editors or clear markers to bypass refusal. End playback/recording you started and retain the failing-layer description.

This is suggested check ordering, not a completed browser/device test. It adds no OS-level microphone occupancy probe, universal conflict panel or automatic resource arbitration.

## Read-aloud content and retained copies

Whether web TTS sends text to a service, stores audio or syncs history depends on that service. Local ASR does not answer those questions. Prepared-model native transcription is local processing, not a guarantee that later web drafts never leave the phone. Pause, recording stop and remote deletion are different operations; a Stop button does not establish recall.

## FAQ

<h3 id="faq-native-tts">Does Yihu add one read-aloud button to every Agent page?</h3>

No such feature is promised here. The scope is a browser shell with enhancements such as native drafts; read-aloud, when present, is site-provided. Inline media configuration is not universal TTS functionality.

<h3 id="faq-concurrent">Can the page and native microphone always run concurrently?</h3>

No concurrency matrix from this work supports that guarantee. Switch one path at a time and observe permission, routing and interruptions. Do not repeatedly start capture to bypass system messages.

<h3 id="faq-autoplay">Does inline playback guarantee autoplay and lock-screen use?</h3>

No. Page implementation, system policy, audio session and actual versions still matter. Configuration is not acceptance of every site or background scenario.

<h3 id="faq-permission">Does page read-aloud establish microphone permission?</h3>

No. Media output, microphone authorization, page capture and server identity/write authority are separate layers. Check actual prompts independently.

<h3 id="faq-loopback">How can I check read-aloud was not captured as my speech?</h3>

Stop this playback first, then inspect recognition of a single synthetic phrase. Loopback/echo needs actual device evidence; voiceChat settings do not guarantee zero echo or speaker-verification accuracy.

<h3 id="faq-stop">Does stopping web voice recall data already sent to a service?</h3>

Not as a general promise. Stop, recall, remote retention and history sync differ. Follow the actual service policy; this page supplies no universal remote-delete function.

## Guides and evidence

[Bluetooth input diagnosis](/en/guides/bluetooth-audio-input-troubleshooting/) · [Weak-network handoff](/en/guides/offline-workbench-handoff-troubleshooting/) · [Voice-draft comparison](/en/guides/iphone-agent-voice-drafts/) · [Multiple-note review](/en/guides/multi-note-review-handoff/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [WebKit configuration](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift), [native audio policy](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift), [README boundaries](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
