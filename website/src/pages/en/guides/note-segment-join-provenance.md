---
layout: ../../../layouts/Wave3Guide.astro
title: "Segment joining: low-energy cuts, ASCII spaces and original-word evidence"
description: "Review 28-second windows, last-eight-second search and ASCII boundary joining. Not semantic segmentation, punctuation repair, alignment or a minutes engine."
lang: en
---

<h2 id="first-answer">Joining may add a boundary space; it does not certify grammar, punctuation or meaning</h2>

CollieNoteSegmenter uses 16 kHz, 28-second windows and a low-energy search over the last eight seconds in 1600-frame steps, with final/short-window handling. join inserts one space only when both adjacent characters are ASCII letters/digits; other boundaries concatenate. It is not semantic splitting, punctuation repair, diarization or word alignment. No structured-minutes engine is added.

## Different from original-word and encoding review

Listening reviews content; export review checks serialization. Here **what segmentation/joining itself adds or preserves at boundaries** matters, so processed text is not mistaken for an untouched verbatim original. No model/audio benchmark ran.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Window | 16 kHz/up to 28 seconds | Final window/actual length | Each window is a whole sentence |
| Search | Last eight seconds, low energy | Acoustic versus semantic cut | Words never cut |
| Step | 1600 frames, about 100 ms | Granularity versus content | 100-ms word alignment |
| ASCII boundary | Letters/digits both sides add space | API + V2 → API V2 | Space necessarily came from speech |
| Other boundaries | Direct join, no rhetoric repair | CJK/punctuation/existing spaces | Grammar correction/paragraph hierarchy |
| Empty/first piece | Existing/next per implementation | Original words/output | Missing sentences generated |
| Progress | Frame position differs from text | transcribedFrames/audio | Every piece manually reviewed |
| Retention | Original/processed/edited text separated | Added spaces/editorial reasons | Automatic verbatim authenticity certificate |

</div>

## Synthetic joining illustration

API + V2 becomes API V2; 样例 + 说明 becomes 样例说明. These illustrate boundary rules, not recognition accuracy. Manual punctuation, splitting or alias edits must retain editorial status/evidence rather than claim the model/original explicitly supplied them.

Low energy is not guaranteed word absence. Review actual audio/text. Later briefs still preserve conditions, negation and unknowns; joining does not establish business approval or execution.

## FAQ

<h3 id="faq-1">Are 28-second windows semantic segmentation?</h3>

No. Acoustic windows/cuts differ from sentence boundaries or speaker separation.

<h3 id="faq-2">Do low-energy cuts guarantee no split words?</h3>

No. Strategy does not replace actual audio/result review.

<h3 id="faq-3">Must the API V2 space come from speech?</h3>

No. join can insert it at ASCII letter/digit boundaries. Distinguish processing from originals.

<h3 id="faq-4">Does CJK joining add spaces/punctuation?</h3>

Not through this join. Other boundaries concatenate; it is not general typography/correction.

<h3 id="faq-5">Does frame progress establish all words heard/reviewed?</h3>

No. Position, final text and manual acceptance differ.

<h3 id="faq-6">Is new segment editing or automatic minutes added?</h3>

No. This reviews fixed implementation, not new UI/API/model capability.

## Reading and source

[Original-word review](/en/guides/recording-segment-review-labels/) · [Export format](/en/guides/export-encoding-delimiter-preflight/) · [Audio/text mapping](/en/guides/note-audio-text-evidence-mapping/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Segmenter/join](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [Frame progress metadata](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift)
