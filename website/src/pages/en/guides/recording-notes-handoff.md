---
layout: ../../../layouts/Wave3Guide.astro
title: "Turn voice notes into action items: keep the original and the next step"
description: "SYN-REC-41 synthetic / non-clinical preflight: /samples/p20-recording-notes-handoff/preflight.zh.json · /samples/p20-recording-notes-handoff/preflight.en.json. An iPhone voice-note workflow from recording to reviewable next steps, with a synthetic meeting example and a transcription-versus-action comparison."
lang: en
preview: voice
voiceSample: meeting
---

<h2 id="syn-rec-41">SYN-REC-41: recording-note handoff and time review</h2>

SYNTHETIC_EXAMPLE: time ledger is external/manual, not native word alignment; medical decisions excluded, no automatic clinical filter claimed.

[ZH: /samples/p20-recording-notes-handoff/preflight.zh.json](/samples/p20-recording-notes-handoff/preflight.zh.json) · [EN: /samples/p20-recording-notes-handoff/preflight.en.json](/samples/p20-recording-notes-handoff/preflight.en.json) · [Card: /samples/p20-recording-notes-handoff/preflight-card.md](/samples/p20-recording-notes-handoff/preflight-card.md)

<div role="region" aria-label="Synthetic recording-note, segmentation, handoff and medical-exclusion checks; horizontally scrollable" tabindex="0">

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| S1 | short;frames=16000;final=False | keep=16000 frames, synthetic seconds=1.0 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S2 | final_full;frames=448000;final=True | keep=448000 frames, synthetic seconds=28.0 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S3 | zeros;frames=448000;final=False | keep=320800 frames, synthetic seconds=20.05 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S4 | quiet25;frames=448000;final=False | keep=400800 frames, synthetic seconds=25.05 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S5 | quiet_last;frames=448000;final=False | keep=447200 frames, synthetic seconds=27.95 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S6 | equal_energy;frames=448000;final=False | keep=320800 frames, synthetic seconds=20.05 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S7 | quiet_before_search;frames=448000;final=False | keep=320800 frames, synthetic seconds=20.05 | Synthetic array energy only, not word timestamps/ASR accuracy |
| S8 | empty;frames=0;final=False | keep=0 frames, synthetic seconds=0.0 | Synthetic array energy only, not word timestamps/ASR accuracy |
| J1 | ''+'Hello' | 'Hello' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J2 | 'Plan'+'B' | 'Plan B' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J3 | 'Owner'+'已确认' | 'Owner已确认' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J4 | '待定'+'Next' | '待定Next' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J5 | 'Note.'+'Next' | 'Note.Next' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J6 | 'alpha '+'beta' | 'alpha beta' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J7 | 'é'+'x' | 'éx' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| J8 | 'hi'+'' | 'hi' | Original string join, no new punctuation/timestamps/speaker/medical meaning |
| H1 | short | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'text'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H2 | exact3000 | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'text'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H3 | over3000 | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'markdown'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H4 | attempted | {'success': False, 'reserved': True, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H5 | inbox_fail | {'success': False, 'reserved': True, 'save_calls': 1, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H6 | no_inbox | {'success': False, 'reserved': False, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H7 | pending | {'success': False, 'reserved': False, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H8 | empty | {'success': False, 'reserved': False, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H9 | reserve_write_fail | {'success': False, 'reserved': False, 'save_calls': 0, 'material': 'none'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H10 | whitespace | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'text'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| H11 | unicode3000 | {'success': True, 'reserved': True, 'save_calls': 1, 'material': 'text'} | Owned metadata/Markdown writes + fake inbox; no real destination receipt |
| L1 | [{'start_frame': 0, 'end_frame': 336800, 'review_text': 'SYNTHETIC_EXAMPLE: 场地验收仍待复核。', 'speaker': 'unknown'}, {'start_frame': 336800, 'end_frame': 768000, 'review_text': '负责人和截止日期未确认，不得对外写成承诺。', 'speaker': 'unknown'}] | structurally_contiguous_not_verified_alignment | Independent manual review ledger, not native exported/aligned timestamps |
| L2 | [{'start_frame': 0, 'end_frame': 16000}, {'start_frame': 18000, 'end_frame': 32000}] | review_gap | Independent manual review ledger, not native exported/aligned timestamps |
| L3 | [{'start_frame': 0, 'end_frame': 16000}, {'start_frame': 15000, 'end_frame': 32000}] | review_overlap | Independent manual review ledger, not native exported/aligned timestamps |
| L4 | [{'start_frame': 16000, 'end_frame': 0}] | reject_interval | Independent manual review ledger, not native exported/aligned timestamps |
| L5 | [{'start_frame': -1, 'end_frame': 16000}] | reject_interval | Independent manual review ledger, not native exported/aligned timestamps |
| E1 | ordinary_meeting_minutes | human_fact_review_only | Explicit sample category only; no App clinical filter or medical inference |
| E2 | diagnosis_request | excluded_medical_decision | Explicit sample category only; no App clinical filter or medical inference |
| E3 | prescription_or_treatment_order | excluded_medical_decision | Explicit sample category only; no App clinical filter or medical inference |
| E4 | uncertain_clinical_inference_from_transcript | excluded_medical_decision | Explicit sample category only; no App clinical filter or medical inference |

</div>

Source persists flat transcript plus16k-frame checkpoint, not this per-segment timestamp/speaker ledger. Minimum-energy cuts do not certify word boundaries/accuracy. Meeting-minutes is a prompt, not already generated minutes; verify proposals/negations/owners/dates against source, leave missing facts pending. Diagnosis, prescriptions/treatment orders or clinical inference are outside this sample: use appropriately qualified professional workflows, not generated/executed medical decisions. No new automatic App medical filter is implemented. Source reserves before handoff, text at<=3000 Characters and Markdown above; transcript only, no original audio attached. Downstream failure may retain attempted reservation; no automatic resend/staging fallback. Store needs no Mac/self-signing. Actual recording/ASR alignment/clinical use/destination insertion/send are not_run; destination may save/sync/auto-process.

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

<h2 id="same-task">Compare one recording through to a usable follow-up</h2>

Use the synthetic transcript above for each approach. The test is whether you can find the next action and its source, not whether a generated paragraph sounds polished.

<div role="region" aria-label="Transcription versus action workflow" tabindex="0">

| Check | Transcript-only task | Voice-to-action workflow |
|---|---|---|
| Expected result | Searchable text alongside its recording. | A reviewed decision, action and open-question list alongside the original. |
| Additional work | Correct words needed for later use. | Separate proposals from decisions; verify names, numbers, owners and dates. |
| Missing information | Leave unclear wording marked. | Keep owner/deadline unconfirmed instead of assigning them by guess. |
| Data handling | Inspect the selected tool's storage/export settings. | Inspect both the recorder and the organizing destination; hand over only needed material. |
| Where Yihu fits | A lighter transcription tool may meet this task. | Local notes plus your existing Agent web workspace, with model/signing setup. |

</div>

A useful reviewed outcome from the sample is “list the missing specifications; owner and deadline to confirm.” Keep the source and check the destination draft before another handoff. [Use the meeting-note template](/en/guides/meeting-notes-brief-fields/).

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
