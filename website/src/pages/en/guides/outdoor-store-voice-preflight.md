---
layout: ../../../layouts/Wave3Guide.astro
title: "Outdoor riding and stores: Bluetooth checks and workbench text handoff"
description: "Check Bluetooth routes, models, weak connectivity, notes and destination drafts while safely stationary. A synthetic workflow, not a live group intercom, wind-noise or dispatch-delivery promise."
lang: en
---

<h2 id="first-answer">A stationary text workflow, not an intercom deployment guide</h2>

Yihu can combine phone transcription, recording notes and existing JSON-ledger reads around your own Agent web workbench. Stop riding and reach a safe place before operating it; in stores, move away from heat, vehicles and active service areas. Bluetooth pairing proves neither the active recording input nor multi-person hands-free intercom capability. Use a separately validated contact method for live communications, emergencies and safety dispatch, not this guide.

## Prepare a sample that cannot execute real work

Build and sign the app yourself, prepare compatible models and microphone permission, and use a trusted HTTPS workbench you are authorized to access. Choose an empty draft editor that does not submit input automatically. Do not test against existing orders, customer conversations, payments or production instructions. This page and the website demo do not access your microphone, real workbench or customer data.

**Synthetic phrase**: “Prepare a sample equipment checklist; keep only a draft, without sending, ordering or executing.” This is a process illustration, not a passed device test. Confirm the destination, then choose short dictation or recording notes, rather than handing the same content over twice.

## Route, model and handoff parameter checklist

<div role="region" aria-label="Stationary preflight parameters and stop conditions, scroll horizontally" tabindex="0">

| Item | Current source/workflow basis | Check | Stop boundary |
| --- | --- | --- | --- |
| Runtime | iOS 18+, own signing; speech requires downloaded compatible models | Check model availability, permission and free space before choosing the target | Stay in setup; never bypass verification or permission |
| Bluetooth input | Near-field policy requests voiceChat and allowBluetoothHFP | Check actual input/output while stationary and review a synthetic phrase | Recheck after a route change; paired does not prove the input |
| Short speech | Guarded draft handoff, without pressing Send | Focus the intended composer first; inspect whether text was already inserted | Do not blindly insert again; retain text on refusal or uncertainty |
| Recording notes | Local audio.caf/note.json; segmented transcription when foreground processing is available | Review names, numbers, negations and segment joins | Distinguish interruption/failure from completion; no arbitrary-duration guarantee |
| Direct note insertion | Current UI threshold is 3,000 Swift Characters, plus completion and target checks | ASCII lengths 3000/3001 only illustrate the boundary | Longer text uses existing Markdown staging; not a recording-duration limit |
| Attachment handoff | Stage in the share tray first; raw audio is not attached | Inspect text and destination before a separate next action | Staging is not uploading; unsent does not establish not uploaded |
| Radar freshness | Existing cache, source date_str and failed reads are distinct signals | Inspect source time/errors and distinguish tasks from decisions | Do not label data latest without a successful source read or treat zero matches as an empty ledger |
| Watch/receipts | Watch hands off existing phone summaries; replies need separate phone confirmation/authority | Check phone reachability, target, confirmation and service readback | queued/saved are not proof of sending, approval or execution |

</div>

## Outdoor riding: a record after stopping

1. **Stop and find a safe location first**. Do not operate a phone while riding, crossing, descending or needing environmental awareness. Do not block necessary ambient sound. This work does not certify helmet headsets or AirPods for Yihu.
2. **Check audio and models**. Wind, a helmet and input changes can affect actual recording. Requesting system audio processing is not a measured wind-noise result. Delay recording or choose an appropriate manual method when conditions are unsuitable.
3. **Separate local and remote steps**. Prepared-model phone processing, audio retention and web reachability are distinct. Without a network, do not promise uploads, replies or web-draft sync; cached cards are not a successful new refresh.
4. **Use only the synthetic draft**. Review text and destination. If already inserted, inspect instead of inserting again. Unknown editors and host refusals are not bypassed. Retain originals on uncertainty and use established channels for urgent matters.

## Restaurant, hotel and retail stores: non-urgent text handoff

Keep a trial free of orders and personal information: for example, three equipment questions for a future internal meeting. Before recording, check participant awareness, permissions and service rules. Customer conversations, table details and private employee information are not demo material.

In a safe stationary location, open the correct workbench and choose a short-speech draft or a recording note. Short speech may automatically attempt guarded insertion, so choose the destination first. Stopping a note recording is not handing it to an Agent. Explicit insertion or staging reserves one note-handoff marker; uncertain results do not automatically retry or switch to another route. Inspect existing destination content before deciding whether manual copying is appropriate.

If your team exports equipment checks or inquiry follow-ups as its own Radar JSON, read-only filtering does not change ledger status. “Foreign-trade Radar” here only describes authorized task-data interpretation and reading, not lead scraping, automatic purchasing, automatic email or real-time store dispatch. Real replies retain separate write permission, phone confirmation and readback; this walkthrough is not service acceptance.

## FAQ

<h3 id="faq-hands-free">Can headset buttons or speech provide continuous button-free dispatch?</h3>

This guide makes no such promise. Bluetooth session configuration is not evidence of headset-button triggers, lock-screen wake or continuous group intercom. The candidate covers safely stationary audio checks and text handoff only.

<h3 id="faq-wind">Does voiceChat guarantee riding wind noise is removed?</h3>

No. It requests a system audio mode; it is not a test result for a headset, wind speed, helmet or riding condition. Stop and use an appropriate alternative if the environment prevents reliable recognition.

<h3 id="faq-offline">Can the whole workflow run offline in weak coverage?</h3>

No blanket claim is appropriate. Prepared models, local notes and existing snapshots have local paths. Model downloads, web access, attachment handoff and service replies have separate network/permission prerequisites. Identify the actual stopped step instead of calling everything offline.

<h3 id="faq-minutes">Does stopping recording produce trustworthy AI meeting minutes?</h3>

No. The source provides segmented transcription and retained originals. Review, summarization and action extraction need a separate authorized workflow. Recognition can be wrong; local retention does not rule out backup or later handoff copies.

<h3 id="faq-interruption">Can recording always continue losslessly after a call or headset change?</h3>

No. Input-change handling and interruption/failure messages exist in source, but are not acceptance of every device/interrupt combination. Check saved status, audio and transcript joins. A recovery path is not a guarantee against lost words.

<h3 id="faq-urgent">Can a store treat inserted draft text as delivery for an urgent instruction?</h3>

No. Drafts, uploads, sends, receipts and handling are separate states. This guide promises no latency, range or production delivery. Use established validated communications and safety procedures for urgent work.

## Reading and source evidence

[Choose between Yihu, radio and voice chat](/en/guides/voice-workbench-vs-radio-chat/) · [Setup checks](/en/start/) · [Privacy](/en/privacy/) · [Recording notes and one handoff](/en/guides/recording-notes-handoff/) · [Multi-project Radar and Watch](/en/guides/multi-project-radar-watch/)

Evidence: [README capabilities/limits](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md), [audio-capture policy](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift), [note input-change handling](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift). This is a source/static-content explanation, not device, workbench-write, meeting-accuracy or production-dispatch acceptance.
