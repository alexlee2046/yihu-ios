---
layout: ../../../layouts/Wave3Guide.astro
title: "After a note leaves the list: async saves, disk removal and remote copies differ"
description: "Review recordingID, in-memory deleted guards and attempted directory removal. List changes are not secure erasure, permanent tombstones or remote recall; no data is deleted."
lang: en
---

<h2 id="first-answer">List removal proves neither deletion of every copy nor recoverability</h2>

Note deletion refuses the current recordingID. For other notes it records an in-memory deleted id, pauses transcription if needed, attempts directory removal, updates the list and clears progress. save checks deleted against async rewrites. Removal uses try?, so list changes do not independently verify disk deletion, permanent tombstones, secure erasure or remote recall.

## Different from minimization and audio/text mapping

Minimization decides what to retain; mapping identifies material. Here **local removal state, async-save guards and retention evidence** matter. No actual file deletion, restore or internal-state bypass is performed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Active recording | Matching recordingID returns | Actual recording state | Lossless deletion at any moment |
| deleted set | In-memory removed IDs | This instance's save scope | Permanent cross-restart tombstone |
| Async save | Skip deleted IDs | Old work versus originals | All disk/sync copies erased |
| Transcribing note | Pause then resume other pending work | Actual task/content state | Every recording/transcription permanently stops |
| Directory | try? removal attempt | List alone is not disk verification | Secure/irrecoverable erasure |
| List/progress | Remove notes/clear progress | Presentation versus physical result | Never reappears under any condition |
| Prior handoff | Uploads/drafts/service separately | Destination/receipts | Local deletion recalls remote files |
| Retention decision | Existing purpose/authority/policy | Necessary originals/approval scope | Checklist authorizes all evidence destruction |

</div>

## Synthetic removal note

Observed: sample note absent from current list. Unknown: directory-removal success and other destinations. Report list state only, not complete erasure or available backup recovery.

Real deletion still needs actual authorization; do not destroy material for demonstrations. This read-only guide offers no permanent erasure, disaster recovery, compliance certification or handoff recall service.

## FAQ

<h3 id="faq-1">Does absent-from-list prove successful file deletion?</h3>

Not independently. Attempted removal/list updates do not verify disk state.

<h3 id="faq-2">Is deleted a permanent deletion certificate?</h3>

No. It is an in-memory save guard, not a permanent tombstone/erasure certificate.

<h3 id="faq-3">Does deleting recall a previously shared attachment?</h3>

No inference follows. Destination copies/service policy need review.

<h3 id="faq-4">Can this entry delete the active recording?</h3>

The source has a recordingID guard; not every state is deletable.

<h3 id="faq-5">Does removal failure guarantee recovery?</h3>

No. Actual files/copies/permissions need evidence; do not assume a backup.

<h3 id="faq-6">Was any data deleted/restored here?</h3>

No. Actual deletion/restore needs authorization; source scope only.

## Reading and source

[Minimization](/en/guides/followup-evidence-minimization/) · [Audio/text mapping](/en/guides/note-audio-text-evidence-mapping/) · [Prior effects/receipts](/en/guides/reply-request-receipt-mapping/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Delete/save/recordingID](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [Metadata/handoff marker](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift)
