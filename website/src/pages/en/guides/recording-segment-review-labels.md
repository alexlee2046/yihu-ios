---
layout: ../../../layouts/Wave3Guide.astro
title: "Review one meeting recording: manual labels, numbers and negations"
description: "Use editorial passage labels to check joins, quantities, units, negations and conditions within one transcript. Labels are not app timestamps, speaker detection or automatic minutes."
lang: en
---

<h2 id="first-answer">Recognition windows are not chapters, and editorial labels are not app annotations</h2>

Yihu notes process 16 kHz audio frames in current windows of up to 28 seconds, searching the last eight seconds for a low-energy cut. This is not topic detection, diarization, word timestamps or accuracy evidence. For one recording, use manual labels such as sample passage A/B to locate review work. This does not modify audio, add native annotations or replace checking the original transcript and recording.

## A different task from combining independent notes

The multi-note guide compares separate records, times, conflicts and handoff states. Here the first task is identifying unchecked wording within one recording. Editorial text chunks need not match recognizer windows. Do not infer seconds from paragraph length or present a manual label as an app-generated chapter ID.

## Within-record semantic review table

<div role="region" aria-label="Manual passage and semantic review table, scroll horizontally" tabindex="0">

| Check | Editorial record | Synthetic risk | Boundary |
| --- | --- | --- | --- |
| Source location | Sample label and retained original wording | Confusing passage A with B | Labels locate text; retain originals without invented seconds |
| Numbers/units | Quantity, currency or time unit in the original | Three versus two; days versus weeks | No inferred value or assumed currency for a unitless number |
| Negations | Not, never, not yet and actual reviewed scope | Do not send becomes send | Keep unreviewed statements pending, not executable |
| Conditions | If, suggested, awaiting approval | Could consider becomes approved | Keep conditions/proposals separate from decisions |
| Segment joins | Original text on both sides and available evidence | One sentence can span windows | Fluent joining does not prove no gaps/duplication |
| Speaker | Verified origin or unknown | Inferring a role from tone | No automatic diarization or identity claim |
| Review scope | Passages/fields checked versus pending | One reviewed passage treated as complete acceptance | Report actual scope, not unchecked sections |
| Handoff | Edited destination and original note state | Re-inserting after editing | One-handoff and uncertain-stop rules remain |

</div>

## Two synthetic passages from one record

```text
Manual label: Sample passage A (not an app timestamp)
Original: Suggest keeping three sample items; do not send.
Review: The number three and the negation do not send.

Manual label: Sample passage B (not a speaker label)
Original: If confirmed next time, change the sample to two items; not approved now.
Review: The condition if, two versus three, and approval state.

Editorial conclusion: A conditional count change, without execution approval; retain pending review.
```

Do not compress these into “two items confirmed; send.” The phrases illustrate review, not a real meeting or a completed capture/recognition test. Check actual audio/text in a safe authorized environment. Preserve unknowns rather than requesting real recordings be sent to this site.

## From passage review to draft minutes

Retain original wording and labels, then separate supported facts, unconfirmed proposals and questions. Do not fill a number or negation just to complete a table. Labels can live in an existing controlled document; that tool controls storage, sync, backup and access. They do not automatically become Yihu fields or Radar tasks.

The manual minutes guide can organize a `review_state` limited to the genuinely reviewed scope. Even when another authorized model assists, compare against the source. Model prose is neither original audio, independent approval nor execution receipt.

## FAQ

<h3 id="faq-label-feature">Does Yihu automatically attach chapter labels to audio?</h3>

No feature of that kind is asserted. Sample labels are editorial references, not native timestamps, export fields or a persisted chapter model.

<h3 id="faq-window">Does each text paragraph represent exactly 28 seconds?</h3>

No. Twenty-eight seconds is the current maximum processing window; cuts/final windows vary, and paragraphs are not a timeline. It proves neither arbitrary recording duration nor exact alignment.

<h3 id="faq-speaker">Does labeling a passage role A establish speaker recognition?</h3>

No. Unverified roles stay unknown. Editorial labels, convenience speaker filtering and identity authentication are separate and cannot substitute for one another.

<h3 id="faq-punctuation">Does fluent joined text prove correct recognition?</h3>

No. Quantities, negations, units and conditions can still be wrong. Joining rules do not guarantee semantic correctness or lossless boundaries.

<h3 id="faq-approval">Can one reviewed passage make the whole minutes approved?</h3>

No. Passage review, full review and approval each require evidence. Do not extend the reviewed scope or turn a proposal into execution permission.

<h3 id="faq-handoff">Can edited passages/labels automatically trigger another handoff?</h3>

No. Prior note attempts still need inspection. Check destination content on uncertainty rather than evading one-handoff markers through editing or blind retries.

## Reading and source

[Recording implementation boundaries](/en/guides/recording-notes-handoff/) · [Manual minutes fields](/en/guides/meeting-notes-brief-fields/) · [Multiple-note review](/en/guides/multi-note-review-handoff/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [segmentation and text joining](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift), [note model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift). No device accuracy, automatic minutes or new annotation functionality is supplied here.
