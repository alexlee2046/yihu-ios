---
layout: ../../../layouts/Wave3Guide.astro
title: "Turn voice notes into action items: keep the original and the next step"
description: "An iPhone voice-note workflow from recording to reviewable next steps, with a synthetic meeting example and a transcription-versus-action comparison."
lang: en
---

<h2 id="first-answer">Start with a useful next step</h2>

Keep the recording and transcript first, then use your chosen workspace or tool to organize them. Separate confirmed points, follow-ups and unanswered questions so the next phone visit starts with a clear action.

## A note you can pick up after the meeting

Synthetic example, not a real meeting or customer record:

<div role="region" aria-label="From transcript to next steps" tabindex="0">

| Material | Sample | How to use it |
|---|---|---|
| Transcript | “We still need the specifications. Confirm quote inputs first; check delivery time before replying.” | Keep the words to check numbers and conditions. |
| Conclusion | Gather specifications before quoting. | Review against the original. |
| Action | List missing parameters for the responsible colleague. | Mark owner and deadline as unconfirmed if absent. |
| Open question | Delivery time and final quote scope. | Obtain evidence before making a commitment. |

</div>

<h2 id="compare">Transcription app or voice-to-action workflow?</h2>

<div role="region" aria-label="Voice-note workflow comparison" tabindex="0">

| Your task | A useful starting point | Your next step |
|---|---|---|
| Save audio and get text | A standalone recording/transcription tool | Review text, storage and sharing settings. |
| Organize decisions and actions | Original text plus an organizing tool | Confirm owners, dates, proposals and decisions. |
| Continue in an existing Agent web workspace on iPhone | Yihu voice notes plus your workspace | Prepare models/setup, choose a handoff and inspect the result. |

</div>

## Continue with Yihu

1. Record on iPhone and retain local audio and segmented text.
2. Review names, numbers and context.
3. Choose an organizing prompt and destination; longer text can use the existing Markdown-material path.
4. Inspect the result in your chosen tool before acting.

“Meeting minutes” selects an organizing prompt rather than producing finished native minutes. Obtain any required participant consent and prepare your models/workspace first.

## FAQ

<h3 id="faq-tool">Do I need a workspace just for transcription?</h3>

A standalone recorder/transcription tool may take fewer setup steps. Yihu fits people already using an Agent web workspace who want to continue there.

<h3 id="faq-action">Can it fill missing owners and deadlines?</h3>

Keep missing facts unconfirmed. Check generated results against the original, especially quotes, delivery dates and external commitments.

<h3 id="faq-material">Do I hand off audio or text?</h3>

The note handoff uses text or Markdown text material. Local audio and transcripts remain available; inspect the selected outlet's actual contents.

<h3 id="faq-original">Why retain the original?</h3>

It helps check recognition differences, context and whether a statement was a proposal or a decision.

## Continue

[Voice drafts](/en/guides/iphone-agent-voice-drafts/) · [Audio checks](/en/guides/bluetooth-audio-input-troubleshooting/) · [Voice notes](/en/guides/recording-notes-handoff/) · [Daily brief](/en/guides/multi-project-radar-watch/) · [Setup](/en/start/) · [Privacy](/en/privacy/)

<details><summary>Implementation references</summary>

[Frozen implementation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)

</details>
