---
layout: ../../../layouts/Wave3Guide.astro
title: "Meeting Notes Template: Decisions & Next Steps | Yihu"
description: "Organize decisions, actions, owners, dates and open questions against the original transcript. Try Yihu’s no-mic note preview, then review privacy and App Store setup."
lang: en
privacyPreview: true
---

<h2 id="first-answer">Check the original; separate decisions, actions and questions</h2>

Keep the transcript first and separate confirmed decisions, concrete actions and open questions. Record owners and dates only when agreed; ask about missing facts rather than guessing. After drafting in your chosen tool, check numbers, conditions and negation against the original.

<div role="region" aria-label="Meeting note template" tabindex="0">

| Part | What to write | Synthetic example |
|---|---|---|
| Decision | A confirmed point, with its source | Gather the missing specifications before quoting. |
| Action | One concrete next step | List the missing parameters. |
| Owner | Who agreed to do it | Unconfirmed. |
| Date | An agreed deadline, or unconfirmed | Unconfirmed. |
| Open question | Information needed before a commitment | Check delivery time before replying. |

</div>

## Choose a workflow

For a searchable transcript, a standalone transcription tool can be enough. For follow-up work, add a review step for actions, owners and dates. If you already use an Agent web workspace, Yihu helps bring phone recordings/text into that workflow.

[Compare transcription and action-item workflows](/en/guides/recording-notes-handoff/#compare)

This is an editorial template, not an app import format. For Radar JSON, use the supported brief format instead of turning these labels into invented API keys.

## A reviewed action card, using the same sample

Keep the original line “check delivery time before replying” next to the action. Write “confirm delivery time,” leave owner/date unconfirmed, and keep the proposed reply separate until reviewed. This is an editorial example, not a new native task-creation feature.

## FAQ

<h3 id="faq-summary">Does choosing a template create finished minutes?</h3>

It provides an organizing prompt. Inspect the output from your chosen tool and confirm it against the recording.

<h3 id="faq-missing">What if the owner or date is missing?</h3>

Mark it unconfirmed and ask, instead of guessing a person or deadline.

<h3 id="faq-proposal">How should I handle a proposal?</h3>

Keep it as a proposal or open question until confirmed, rather than upgrading it to a decision.

<h3 id="faq-review">What should I check before sharing?</h3>

Check the destination, necessary material and whether a draft already exists. Retain the original while reviewing uncertainty.

[Voice notes](/en/guides/recording-notes-handoff/) · [Daily brief](/en/guides/multi-project-radar-watch/) · [Setup](/en/start/) · [Privacy](/en/privacy/)

<details><summary>Implementation reference</summary>

[Voice notes](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift)

</details>
