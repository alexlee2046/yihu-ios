---
layout: ../../../layouts/Wave3Guide.astro
title: "Before exporting notes or Radar briefs: encoding, line breaks and delimiters"
description: "Separate UTF-8 Markdown, internal share manifests and source JSON. Check characters/bytes and string escaping without a CSV exporter, universal transcoder or file-repair feature."
lang: en
---

## SYN-ECD-47 encoding and delimiter preflight

SYNTHETIC_EXAMPLE · pending · not_run. Characters/bytes, carriers/consumers and receipts are separate.

[/samples/p26-export-encoding-delimiter-preflight/README.md](/samples/p26-export-encoding-delimiter-preflight/README.md) · [/samples/p26-export-encoding-delimiter-preflight/preflight.zh.json](/samples/p26-export-encoding-delimiter-preflight/preflight.zh.json) · [/samples/p26-export-encoding-delimiter-preflight/preflight.en.json](/samples/p26-export-encoding-delimiter-preflight/preflight.en.json)

<div role="region" aria-label="SYN-ECD-47" tabindex="0">

| ID | Check | Expectation/boundary |
| --- | --- | --- |
| T01 | CJK mixed | Swift Character 3; UTF-8 bytes 7. |
| T02 | Combining character | Swift Character 1; UTF-8 bytes 3. |
| T03 | Precomposed character | Swift Character 1; UTF-8 bytes 2. |
| T04 | Joined emoji | Swift Character 1; UTF-8 bytes 25. |
| T05 | Actual newline | Swift Character 11; UTF-8 bytes 11. |
| T06 | Literal backslash-n | Swift Character 12; UTF-8 bytes 12. |
| T07 | Quotes comma backslash | Swift Character 9; UTF-8 bytes 9. |
| T08 | CRLF | Swift Character 3; UTF-8 bytes 4. |
| T09 | 3000 characters | Swift Character 3000; UTF-8 bytes 9000. |
| T10 | 3001 characters | Swift Character 3001; UTF-8 bytes 9003. |
| D01 | Complete minimal model | Radar decode true; utf8; not real import/authority. |
| D02 | String delimiters and escaping | Radar decode true; utf8; not real import/authority. |
| D03 | Fragment is not snapshot | Radar decode false; utf8; not real import/authority. |
| D04 | Wrong date type | Radar decode false; utf8; not real import/authority. |
| D05 | Invalid calendar date | Radar decode false; utf8; not real import/authority. |
| D06 | Unescaped JSON newline | Radar decode false; raw_unescaped_newline; not real import/authority. |
| D07 | Consumer-specific encoding observation | Radar decode true; utf16le_bom; not real import/authority. |
| D08 | Model byte bound | Radar decode false; oversize; not real import/authority. |
| C01 | Internal manifest roundtrip | batch_roundtrip: true; synthetic temporary data only. |
| C02 | Manifest is not Radar | batch_as_radar: false; synthetic temporary data only. |
| C03 | Radar is not manifest | radar_as_batch: false; synthetic temporary data only. |
| C04 | Wrong items type | wrong_items_type: false; synthetic temporary data only. |
| H01 | Durable reservation | normal: true; synthetic temporary data only. |
| H02 | Do not reset attempted | already_attempted: false; synthetic temporary data only. |
| H03 | No empty-text reservation | empty: false; synthetic temporary data only. |
| H04 | Write failure is not success | write_failure: false; synthetic temporary data only. |
| M01 | Long-note branch is source-reviewed | handOff uses body.count<=3000 for text, otherwise UTF-8 Markdown with heading/newlines. Host does not run Store.handOff; no CSV or universal transcoder. |
| M02 | Separate delimiter contracts | Vocabulary splitting is not JSON/CSV grammar; commas may be string data. Do not split real bodies, rewrite fields/dates or repair originals. |
| M03 | PCM end is not text encoding | noDataNow preserves block state; finish uses endOfStream, up to 16 calls with early exits. Not characters/bytes/duration/semantic segmentation; no audio conversion run. |
| M04 | Preserve originals and handoff state | Readable display/file write/tail output does not prove completeness, import or remote completion. Re-encoding/renaming never resets reservations or grants resend authority; stop when unknown. |

</div>



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
