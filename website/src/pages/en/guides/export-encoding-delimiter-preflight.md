---
layout: ../../../layouts/Wave3Guide.astro
title: "Before exporting notes or Radar briefs: encoding, line breaks and delimiters"
description: "Separate UTF-8 Markdown, internal share manifests and source JSON. Check characters/bytes and string escaping without a CSV exporter, universal transcoder or file-repair feature."
lang: en
---

<h2 id="first-answer">Identify carrier and consumer first; commas are not universally field separators</h2>

The existing longer-note staging path writes UTF-8 Markdown. The share inbox also has an internal JSON manifest, while Radar consumes another snapshot model. Being text files does not make them interchangeable. Encoding, newlines, escaping, character counts and field contracts need separate review. No CSV exporter, transcoder or automatic repair of live files is added.

## Different from terms, types and format revisions

Vocabulary preflight concerns term splitting, JSON validation concerns field shapes, and revision review concerns contract changes. Here **text serialization/readback within a chosen carrier** is the task, not changing term meaning, model settings or source fields.

## Encoding and delimiter checks

<div role="region" aria-label="Export encoding and delimiter checks, scroll horizontally" tabindex="0">

| Object | Existing implementation/meaning | Check | Do not infer |
| --- | --- | --- | --- |
| Short note text | Transcript Swift Character count selects text/attachment path | 3000 is not bytes or audio duration | CJK/combined characters each use one byte |
| Longer note attachment | Existing path writes Markdown with utf8 encoding | Body, heading, newlines and actual consumer | Every file has identical encoding or CSV/transcoding support |
| Inbox manifest | JSONEncoder writes an internal shared batch | Not the Radar snapshot contract | Renaming .json makes it Radar-compatible |
| Radar source JSON | Actual JSONDecoder and model contract | Syntax, types, size, dates and identities separately | This guide restricts every decoder input to one encoding or repairs it |
| Comma/semicolon | Can be data inside JSON strings | Quoted/unquoted semantics, not vocabulary splitting | Every comma creates a task/field |
| Newline/quotes | JSON strings need valid escaping | \n, quotes and backslashes as actual content | Literal backslash-n and newline have identical bytes |
| Unicode | Characters, UTF-8 bytes and meaning differ | Actual encoding and retained original | Similar display proves identical bytes |
| Filename/copies | Suffix/save time differ from body contract | Destination and prior handoff state | Rename/extension changes bypass reservation/permission |

</div>

## A JSON string syntax fragment

This demonstrates strings only: **not a complete Radar snapshot**, missing other required model fields and not an example app-generated export.

```json
{
  "title": "Sample, A",
  "next": "Line1\nLine2"
}
```

After parsing, the comma remains title data and the escaped newline belongs to next. Preserving literal backslash/n needs a different serialization. Do not split JSON by commas. Vocabulary punctuation splitting does not define exported-body parsing.

The synthetic text 样例A has three simple characters and seven UTF-8 bytes. This illustrates different counts, not a universal counter; JavaScript string length must not substitute for Swift Character limits.

## Retain evidence before and after export

Use non-sensitive fixtures to identify how the destination reads the carrier, then compare original/readback without rewriting real source data to hide display errors. Do not remove bytes/quotes or fill now without knowing the encoding/consumer contract.

Correct display does not establish source identity, model validation or delivery. Writing a file is a local/staging step only. Original note reservations, destination permission and uncertain-stop states remain. Re-encoding/renaming does not authorize resending.

## FAQ

<h3 id="faq-markdown">Are long-note exports CSV?</h3>

No. The cited path writes UTF-8 Markdown through existing inbox staging. No CSV exporter or field converter is added.

<h3 id="faq-manifest">Can manifest.json be used as a Radar source?</h3>

No. The internal share-batch manifest and Radar snapshot have different models. A shared suffix is not a shared contract.

<h3 id="faq-comma">Can every JSON comma use vocabulary splitting rules?</h3>

No. Inside quotes it can be data. JSON has its own grammar; vocabulary splitting is not a general JSON/CSV parser.

<h3 id="faq-count">Is the 3000 threshold 3000 UTF-8 bytes?</h3>

No. It counts Swift Characters, not encoded bytes, Unicode scalars or recording duration.

<h3 id="faq-encoding">Can unreadable CJK simply be re-encoded and handed off again?</h3>

Do not repair blindly. Verify original encoding, destination contract and prior result. Re-encoding does not erase an attempt or duplicate risk.

<h3 id="faq-fixture">Does the fragment establish app import acceptance?</h3>

No. It demonstrates strings, not a complete model, actual-version decoding, permission or device acceptance.

## Reading and source

[Term splitting/limits](/en/guides/multilingual-terms-preflight/) · [JSON types/nulls](/en/guides/radar-json-null-validation/) · [Format revision](/en/guides/brief-format-change-compatibility/) · [One note handoff](/en/guides/recording-notes-handoff/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [Markdown writing/threshold](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift), [internal share manifest](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift), [Radar model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift).
