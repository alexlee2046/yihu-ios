---
layout: ../../../layouts/Wave3Guide.astro
title: "Empty fields and display defaults: placeholders must not become source values"
description: "Separate missing values, UI placeholders, sorting fallbacks and capability checks. No fabricated titles, business defaults or automatic source-repair feature."
lang: en
---

<h2 id="first-answer">A missing-value label may be UI explanation, not supplied business data</h2>

Some task-card branches display status not provided, priority pending or next step pending when fields are empty. These branches do not mean source fields were assigned a default business state, priority or action. Separate raw values from rendering. Do not fill unknowns with confirmed facts to complete a screen. No default-value fixer or source autocompletion is added.

## Different from JSON type validation

JSON guidance checks missing/null/types. Here **rendering, fallback ordering and capability conditions can be mistaken for source contents**. This is not another full schema guide, field editor or blanket equivalence between empty strings and all whitespace.

## Empty values, placeholders and fallbacks

<div role="region" aria-label="Empty-field/display-default checks, scroll horizontally" tabindex="0">

| Location | Existing consumer behavior/boundary | Review | Do not fill/infer |
| --- | --- | --- | --- |
| Required identity/title | Decode checks nonempty project/title and other conditions | Presence, type and nonempty rules | Untitled automatically replaces valid source data |
| status rendering | Blank task-card state can display not provided | Label versus raw status | Missing means planned, done or approved |
| priority rendering | nil/empty can display pending priority | Actual value versus label | Replace with P2/default business priority |
| next rendering | Task card can show pending after trimming empty text | Original, specific control and known gap | Invent action or owner |
| session/evidence | Some missing values display pending/not provided | Whether the source supplied those words literally | Label establishes an owner session or evidence |
| Sort fallback | Unknown priorities have ordering rules | Order is not a field assignment | Low position means source assigned low urgency |
| reply_supported | Explicit true required for this capability condition | Unknown differs from explicit false | Disabled UI means rewrite all missing values as false |
| Empty note transcript | handOff rejects an empty transcript | Original versus UI message | Pass a placeholder as transcription or silently remove gaps |

</div>

Trimming depends on each implementation/control; it is not uniform. Do not generalize one card's condition into universal cleansing. Similar displays do not establish identical raw values.

## Synthetic placeholder versus literal text

```text
A: evidence is null; the card displays a pending label.
B: evidence is literally the pending-label string supplied by the source.
Review: Neither establishes actual business evidence, but source values differ.
Decision: Preserve the distinction; a placeholder screenshot is not the original field. Rewrite no live data.
```

This is not a complete snapshot or actual decoder run. Inspect originals only with existing authorization; no raw-data viewer or public private-source access is added.

## Defaults must not expand conclusions

An editor can label unknowns but must not claim source updates. Identity/required-field/capability failures cannot be bypassed by filling now, empty arrays or familiar priorities.

No text does not prove no meeting occurred. No matching tasks does not prove all tasks completed. A pending label does not promise automatic completion. Retain actual facts/unknowns without deriving business status, authority or resend eligibility from placeholders/order.

## FAQ

<h3 id="faq-source">Does priority pending mean the source saved that string?</h3>

Not necessarily. Inspect the original field rather than treating screenshot labels as raw values.

<h3 id="faq-required">Can an untitled default make a missing title valid?</h3>

Do not fabricate values. The consumer has nonempty identity/title conditions; use the real source-maintenance process.

<h3 id="faq-spaces">Are empty, whitespace and missing identical everywhere?</h3>

No. Parser/control conditions differ. No universal normalization or cleansing guarantee is supplied.

<h3 id="faq-false">Does disabled UI prove reply_supported is explicitly false?</h3>

No. Unknown capability and other permission/source conditions affect availability. Preserve raw value versus UI outcome without writing false.

<h3 id="faq-priority">Can fallback ordering justify filling low priority?</h3>

No. Ordering does not modify source priority or establish business urgency.

<h3 id="faq-notes">Can no-text placeholder text be handed off as transcription?</h3>

Do not do so. Messages are not originals; entry/one-handoff guards remain. Preserve the actual content gap.

## Reading and source

[JSON types/nulls](/en/guides/radar-json-null-validation/) · [Summary provenance](/en/guides/radar-summary-claim-provenance/) · [Cross-device display](/en/guides/cross-device-field-presentation/) · [One note handoff](/en/guides/recording-notes-handoff/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [task-card placeholders](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift), [decode/sorting](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [empty-transcript guard](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift).
