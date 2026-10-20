---
layout: ../../../layouts/Wave3Guide.astro
title: "Before mixed-language dictation: language hints, term order and original wording"
description: "Review existing language/term parsing, 80-item and 40-character limits and context budgets. No guarantee every term survives, translation, proper-name accuracy or a new vocabulary service."
lang: en
---

<h2 id="first-answer">A term list is recognition context, not a guaranteed preserve-or-translate dictionary</h2>

Existing language choices are automatic, Chinese and English; the automatic label mentions mixed Chinese/English. Terms provide recognition background. A language hint, parsed list and final text are different layers. Entering a term does not prove every item reached the model or was preserved correctly. No translation service, universal multilingual accuracy or proper-name guarantee is supplied.

## Different from correction and minutes review

Correction deals with already recognized text. Here **before capture, inspect the actual hint, list parsing and original terms requiring later review**. This is not another audio diagnosis. Vocabulary is neither an Agent instruction channel, identity nor approval.

## Language and vocabulary preflight

<div role="region" aria-label="Language hints and term parsing, scroll horizontally" tabindex="0">

| Check | Existing boundary | Synthetic inspection | Not established |
| --- | --- | --- | --- |
| Language choice | automatic/chinese/english; automatic supplies no fixed language hint | Actual version/selection | Every language supported or automatic translation |
| Term toggle | Referencing terms and retaining them are separate | Disabling use does not delete stored terms | Stored implies used in this recognition |
| Separators | Newlines and listed Latin/Chinese commas, enumeration marks/semicolons split terms | Sample-A and Sample-B as separate items | A comma inside a name remains unsplit |
| Whitespace/duplicates | Trim ends, drop blanks, case-insensitive deduplication, first-item order | Sample/sample keeps the first | Universal Unicode normalization or entity merging |
| Count | Up to 80 accepted terms | Overflow is not counted as adopted | All 80 always reach recognition context |
| Length | Up to 40 Swift Characters per item; overlong items are dropped, not truncated | Inspect actual character count | 40 characters means 40 UTF-8 bytes |
| Order | Earlier valid terms have priority, within context budget | Put necessary synthetic terms first | Longer audio preserves every term |
| Output | Check spelling, abbreviations, quantities and negations | Retain original references | Vocabulary replaces source/device accuracy checks |

</div>

Ordinary spaces do not split terms in this parser, but that does not make an entire phrase immutable to the recognizer. Do not put long operational prompts into the vocabulary to request execution; it is recognition context, not business authority.

## One synthetic list

```text
Input illustration:
Sample-A
sample-a
样例代号B，API

Editorial expectation: First Sample-A retained; its case duplicate is not another term. The Chinese sample label and API are separate items.
Still unknown: How much context reaches recognition and whether spelling survives in output.
```

This neither changes app settings nor runs recognition. Use no customer names, private product codes, service tokens or real tasks publicly. Team vocabulary belongs in existing authorized processes, without provisioning a shared service or third-party authorization here.

## Original words versus later briefs

Recognition, editorial translation and summarization are different processing steps. Expanding an acronym, translating a phrase or merging aliases needs a reason and retained unknowns, not a claim the model produced that wording. Shared labels do not prove cross-device vocabulary synchronization.

Actual version, compatible models, permission and a safe environment remain prerequisites. No automatic terminology alignment, cross-language entity resolution or every-name-correct feature is provided, and no parameter bypasses model/target guards.

## FAQ

<h3 id="faq-language">Does automatic guarantee every language and accent?</h3>

No. Choices/labels are not arbitrary-language accuracy evidence. Check actual models/devices; this page runs no recognition benchmark.

<h3 id="faq-long">Are over-40-character terms truncated to 40?</h3>

No. Current parsing drops items failing the length condition. Do not present a shortened string as an automatically adopted result.

<h3 id="faq-budget">Does parsing 80 entries mean recognition uses them all?</h3>

No. Order and context budgets affect the adopted scope. An upper bound is not an all-items guarantee.

<h3 id="faq-switch">Does disabling term use delete the list?</h3>

Existing UI distinguishes the two and retains terms. Check actual setting/version rather than inferring enablement from storage.

<h3 id="faq-translate">Does vocabulary automatically translate into another language?</h3>

No translation guarantee follows. Terms are background; output, editing and translation need separate source review.

<h3 id="faq-permission">Does send/execute in vocabulary authorize an Agent?</h3>

No. Term text is not server permission, user confirmation or operation authority. Handoff/receipt guards remain.

## Reading and source

[Manual correction](/en/guides/noisy-transcript-text-correction/) · [Original-word passage review](/en/guides/recording-segment-review-labels/) · [Summary provenance](/en/guides/radar-summary-claim-provenance/) · [Timezone/time checks](/en/guides/timezone-timestamp-review/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [language choices/term parser](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceInterfaces.swift), [settings explanation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieLinkSettingsView.swift), [recognition context prefixes](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Vendor/SpeechSwiftCoreML/CoreMLASRModel.swift).
