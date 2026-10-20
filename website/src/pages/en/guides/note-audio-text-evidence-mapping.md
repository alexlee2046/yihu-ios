---
layout: ../../../layouts/Wave3Guide.astro
title: "Map audio, note metadata and transcript evidence: progress is not verbatim truth"
description: "Separate audio.caf, note.json, transcript, transcribedFrames and text-only handoff. Completion does not certify every word; no forced alignment or original-file backup."
lang: en
---

<h2 id="first-answer">Audio, text and metadata differ; handing off text does not share the audio</h2>

Notes relate audio.caf and note.json by one id. Transcription resumes at transcribedFrames and accumulates transcript. Done does not establish every word was reviewed; the emptyTranscript branch can advance frames without adding text. Workbench handoff shares transcription, not recording files. This is an editorial mapping checklist, not forced alignment or original-file archiving.

## Different from passage review and revision retention

Passage review checks speech; revision retention maps reviewed versions. Here **local audio, metadata, progress and handed-off text must not be mistaken for identical evidence**. No sandbox access, file export, index or backup is performed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Note id | Relates one note's materials | Actual originals/version | Same filename means same record |
| audio.caf | Local captured file | Readable scope/state | Text display proves complete audio |
| note.json | Metadata/state/transcript etc. | Original state versus editorial copy | Tamper-proof audit certificate |
| transcribedFrames | 16 kHz frame processing position | Processing scope versus contents | Word alignment or accuracy |
| emptyTranscript | May advance position without text | Whether actual content needs review | Original contained no business speech |
| done | Transcription process finished | Originals/unknowns/error scope | Automatic truth/semantic completeness acceptance |
| Text handoff | Short text or long Markdown | Actual delivered text/attachment | audio.caf/all originals shared by default |
| Local retention | Source attempts backup exclusion | Permissions/policy/other copies | Permanent backup, disaster recovery or original archive button |

</div>

## Synthetic mapping review

Sample note is done with one text paragraph. That does not prove every audio word was reviewed; a staged Markdown file does not establish audio transfer. Inspect actual materials/scope.

Keep authorized references/text versions/reviewed scope/gaps manually, without treating internal fields as editable import/restore APIs. Copies do not change originals, progress does not authenticate contents, and an archive does not erase handoff reservations.

## FAQ

<h3 id="faq-1">Does 100% or done certify every word?</h3>

No. Processing state does not replace listening, meaning or original-content review.

<h3 id="faq-2">Does emptyTranscript prove only silence existed?</h3>

Not independently. Processing can skip text and advance; actual content needs separate review.

<h3 id="faq-3">Is transcribedFrames a timestamp for each word?</h3>

No. It is a 16 kHz frame position, not forced word alignment.

<h3 id="faq-4">Does long Markdown also upload the audio?</h3>

The cited path hands off text, not recording files. Text attachments do not prove original transfer.

<h3 id="faq-5">Is note.json tamper-proof evidence?</h3>

No signing/immutability mechanism is asserted. Metadata differs from trust/truth.

<h3 id="faq-6">Does local audio mean permanent backup?</h3>

No. Source attempts backup exclusion; actual retention applies without a new restore guarantee.

## Reading and source

[Passage review](/en/guides/recording-segment-review-labels/) · [Text attachment format](/en/guides/export-encoding-delimiter-preflight/) · [Material relationships](/en/guides/batch-change-record-retention/) · [Per-item sharing scope](/en/guides/share-batch-item-preflight/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Metadata/reservation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift) · [Audio/frame/text handling](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [Text-only handoff explanation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotesView.swift)
