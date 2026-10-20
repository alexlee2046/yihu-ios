---
layout: ../../../layouts/Wave3Guide.astro
title: "Yihu, two-way radios or voice group chat: choose by destination"
description: "Compare Agent workbench drafts with radio calls and ordinary voice group chat: destination, connectivity, Bluetooth audio checks and confirmation, without invented range or latency results."
lang: en
---

<h2 id="first-answer">An Agent draft is not a person-to-person radio call</h2>

Yihu is an iOS browser shell for your own HTTPS Agent workbench, with phone transcription, recording notes and PM Radar JSON reads. Two-way radios serve compatible radio systems under the applicable local rules; ordinary voice group chat serves contacts or groups in a particular service. If you need continuous person-to-person field dispatch, do not treat Yihu as a tested replacement for either. This is a boundary comparison, not a benchmark ranking.

## Three different destinations

- **Speak to people**: identify listeners, compatible equipment or service, permissions and a fallback contact method. Radio models and chat applications are not interchangeable.
- **Hand a thought to an Agent**: choose the workbench and draft editor before transcribing with a configured local model. Draft insertion is neither message submission nor execution.
- **Keep a record first**: recording notes retain local audio and text for review before explicit handoff. Meeting recordings are not automatically verified minutes or assigned team actions.

## Parameters and selection boundaries

<div role="region" aria-label="Tool comparison table, scroll horizontally" tabindex="0">

| Check | Current Yihu scope | Two-way radio | Ordinary voice group chat |
| --- | --- | --- | --- |
| Destination | Your workbench draft or local note, not a group voice channel | Listeners in a compatible device/system; check the actual equipment | Contacts/groups in the particular service; check the actual product |
| Connectivity | Reachable, trusted HTTPS for web work; separately downloaded compatible models for transcription | Verify frequency, system, coverage and local operating rules | Verify account, permissions, network and service availability |
| Bluetooth/headset | Near-field source requests voiceChat and allowBluetoothHFP; not arbitrary-headset certification | Accessory connector, protocol and microphone behavior depend on the model | Routing and call behavior depend on app, system and headset combination |
| Offline/weak network | Prepared local models, notes and existing Radar cache have separate limits; no offline web-handoff promise | Do not infer independence from repeaters or networks from the category | Do not assume offline sending/receiving from the category |
| Send and receipt | Never presses Send; Radar replies need separate server authority, phone confirmation and readback | Follow device controls and your field readback procedure; not certified here | Follow actual send/receive indicators, which do not prove handling |
| Range and latency | No radio-range, end-to-end latency or continuous-call benchmark from this work | No universal number detached from equipment, environment and system | No universal number detached from network and service |
| Lock screen/button-free use | No promise of lock-screen wake, continuous button-free intercom or headset-button triggering | Check the specific manual and validation | Check the app version, system policy and validation |
| Reviewable text | Review transcript, destination and explicit handoff; recognition can be wrong | Recording/text features depend on the actual model | Text, transcription and recording retention depend on the actual product |

</div>

## Bluetooth audio checks are not hands-free call certification

The near-field configuration in `CollieAudioCapturePreferences` requests `playAndRecord`, `voiceChat` and `allowBluetoothHFP`; disabling near-field processing uses a different configuration. These are source-level audio-session choices. They do not certify any AirPods model, helmet headset or Bluetooth adapter, nor wind-noise reduction, echo control or battery endurance.

In a safe stationary setting, check the actual input, output and microphone permission. Use one synthetic phrase with no real task, then inspect transcription and the destination draft. Recheck after changing headsets, interruptions or an audio-service reset. The recording-note source has input-retargeting and failure paths; these are not proof of lossless interruption recovery. Do not operate the phone while moving or bypass a host refusal for a test.

## Route offline, meeting and trade needs separately

**Offline or weak connectivity**: an available downloaded model and local audio do not make the web reachable. A visible Radar card may be an old snapshot; stale sources and failures must remain distinguishable. Refresh taps, Bluetooth pairing and finished local recognition are not receipts from a remote destination.

**AI meeting minutes**: Yihu provides recording, segmented transcription and retained originals. Minutes still require review and a separately authorized destination workflow. This page promises neither speaker diarization, automatic action extraction nor accuracy. Confirm participant awareness and applicable recording rules before recording.

**Foreign-trade Radar**: a team can read its own authorized inquiry/follow-up tasks if it exports JSON matching the existing PM Radar contract. This is not a built-in customs database, market-intelligence subscription, customer-list scraper or automated email service. Keep `tasks`, `decisions`, source dates, cache status and write authority separate.

## FAQ

<h3 id="faq-radio-replacement">Can Yihu directly replace a store or riding-team radio?</h3>

Not on the evidence here. Its destination is your workbench draft, not an accepted multi-person voice channel. Choose and validate suitable equipment/services for live field contact; Yihu can help organize text while safely stationary.

<h3 id="faq-airpods">Does a paired Bluetooth headset prove Yihu uses its microphone?</h3>

No. Pairing, the actual input route and the active audio session are different facts. Check input/output and a synthetic recording on the actual device; source options do not certify a headset model.

<h3 id="faq-watch">Can Apple Watch be a standalone intercom or approval terminal?</h3>

The companion receives existing paired-phone summaries and hands work back to the phone, subject to pairing and system prerequisites. This page promises no independent intercom, ledger refresh or approval. Phone confirmation and server authority remain separate.

<h3 id="faq-weak-network">Is completed offline transcription proof of handoff?</h3>

No. It only establishes a result for that processing step. Web access, attachment upload or a real reply still needs the destination service and permissions. Retain the original and inspect uncertainty before trying again.

<h3 id="faq-trade-radar">Can a foreign-trade team import inquiry tasks?</h3>

Only through its own authorized JSON export matching the model contract. Make source identity, fields, dates and cache status explicit. This page adds no trade-data feed, customer list, notification backend or automatic follow-up.

<h3 id="faq-install">Where is the App Store download?</h3>

This is currently a source release, without a published binary link. Use your own signing, models and workbench as described in the build guide. A made-up store link or merged source cannot replace installation and device acceptance.

## Evidence and next steps

- [README: capabilities, prerequisites and limits](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)
- [Audio-session policy source](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieAudioRecorder.swift)
- [Recording input-change handling](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieNoteRecorder.swift)
- [Outdoor/store stationary checks and text handoff](/en/guides/outdoor-store-voice-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/) · [Recording notes](/en/guides/recording-notes-handoff/) · [Multi-project Radar and Watch](/en/guides/multi-project-radar-watch/)
