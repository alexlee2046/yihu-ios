---
layout: ../../../layouts/Wave3Guide.astro
title: "Cross-department minutes: ownership acknowledgment and archive checks"
description: "After manual minutes, verify responsible-role acknowledgment, approved scope and existing retention rules. Not Yihu task assignment, e-signature, document storage or automatic archiving."
lang: en
---

## SYN-DMO-44 · Department minutes ownership and minimal archive checks

SYNTHETIC_EXAMPLE / SYN-DMO-44. Real claims/archives remain pending / not_run. Manual ledger, not App import, automatic assignment or speaker recognition.

- 中文 JSON: [preflight.zh.json](https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.zh.json) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.zh.json
- English JSON: [preflight.en.json](https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.en.json) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/preflight.en.json
- Public bilingual check card: [README.md](https://getyihu.com/samples/p23-department-minutes-ownership-archive/README.md) — https://getyihu.com/samples/p23-department-minutes-ownership-archive/README.md

### Split proposed responsibilities manually, never silently claim them

S1/S2 and R1/R2 are hand-authored fictional speaker/role labels, not native diarization or accounts. C2 keeps U1/U2 proposal references in separate T1/T2 draft actions. proposed_role is not confirmed_owner. Every real confirmed owner, deadline, claim evidence, execution approval, archive location and retention reference remains null. C3 does not resolve ambiguous pronouns; C5 read/CC is not consent; C6 wording review does not authorize purchasing, sending, changes or release; C7 preserves conflicting versions instead of choosing an owner. pending/not_run describe the real workflow; separately passed host checks do not hide behind those labels.

### Original source guards do not establish ownership or formal archives

Source filter examples check data scope/text only: project is not a department ACL, session/next role text or fixed Alex is not login/owner identity, an empty list is not no responsible person. safeEvidenceURLs rejects some malformed shapes and deduplicates, but keeps allowed HTTPS query/fragment content (E9). HTTPS is not publication permission, redaction, trust or access authorization.

Original VoiceNote.reserveHandOff runs only on synthetic owned temporary metadata. done/nonempty/not-attempted gates an atomic marker reservation, not delivery, acceptance or archive completion. Failed metadata write preserves the original; an archive copy cannot reset an attempted marker. Whitespace-only nonempty text can pass this guard, not evidence of useful minutes or automatic repair. Real phone notes, Store.handOff, AppGroup/clipboard/workspace and network are not called.

### Disclosure, access and retention use existing approved processes

All public content is entirely synthetic, not renamed private customer material. Keep authorized original references private; verify archive purpose, approved readers/location/version, necessary copies and actual retention rules. Unknown stops at an approved draft, not a new account/share link/upload. Local deletion is not recall of attachments, workspace, sync or backups. No universal retention period, guaranteed deletion, compliance certification or CRM archive. 40 rows =12external manual+10URL+8meta+6filter+4copy boundaries; only24/language are original-source host execution, never actual acknowledgment or an App ownership engine.

<div role="region" aria-label="SYN-DMO-44 manual claim, source guards and copy scope, horizontally scrollable" tabindex="0">

| ID | Separate scope | Synthetic input/manual split | Host expectation or manual boundary |
| --- | --- | --- | --- |
| C1 | External human claim/archive ledger | `{"mode":"proposal_not_claim","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Explicit acknowledgment missing; proposal is not assignment.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C2 | External human claim/archive ledger | `{"mode":"split_atomic_responsibilities","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":"R1","confirmed_owner":null,"deadline":null},{"draft_id":"T2","speech_refs":["U2"],"proposed_role":"R2","confirmed_owner":null,"deadline":null}]}` | `{"rule":"Keep separate draft actions/evidence references, no inferred joint owner.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C3 | External human claim/archive ledger | `{"mode":"ambiguous_pronoun","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Leave proposed/confirmed owner and deadline null; ask existing authorized process.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C4 | External human claim/archive ledger | `{"mode":"quoted_role_not_consent","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"A role quoted in speech is not the role accepting responsibility.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C5 | External human claim/archive ledger | `{"mode":"read_receipt_not_ack","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"A synthetic read receipt or CC never establishes claim/approval.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C6 | External human claim/archive ledger | `{"mode":"review_scope_not_execution","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Text-review-only scope does not authorize purchase, sending, changes or release.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C7 | External human claim/archive ledger | `{"mode":"conflicting_versions","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Preserve both synthetic references, do not pick a winner or overwrite source.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C8 | External human claim/archive ledger | `{"mode":"unconfirmed_owner_stays_empty","speakers":["S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"No auto owner/deadline inferred from session/title/next or placeholder.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C9 | External human claim/archive ledger | `{"mode":"archive_location_unknown","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"No new account, shared location or upload; existing access/retention must be verified.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C10 | External human claim/archive ledger | `{"mode":"copies_not_recalled","speakers":["S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Local note deletion is not deletion of clipboard, workspace, attachments, sync or backups.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C11 | External human claim/archive ledger | `{"mode":"public_synthetic_not_redaction","speakers":["S1"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Entire public example is synthetic; HTTPS parsing is not redaction/publication permission.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| C12 | External human claim/archive ledger | `{"mode":"uncertain_handoff_no_resend","speakers":["S1","S2"],"drafts":[{"draft_id":"T1","speech_refs":["U1"],"proposed_role":null,"confirmed_owner":null,"deadline":null}]}` | `{"rule":"Check approved destination through existing process; never reset once-attempted marker for an archive copy.","confirmed_owner":null,"deadline":null,"claim":"pending","live":"not_run"}` |
| E1 | Original evidence URL parser | `null` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E2 | Original evidence URL parser | `""` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E3 | Original evidence URL parser | `"https://example.invalid/evidence/sample"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E4 | Original evidence URL parser | `"(https://example.invalid/evidence/sample)"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E5 | Original evidence URL parser | `"https://example.invalid/evidence/sample;https://example.invalid/evidence/sample"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample"],"disclosure_permission":"pending","live":"not_run"}` |
| E6 | Original evidence URL parser | `"http://example.invalid/evidence/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E7 | Original evidence URL parser | `"https://role@example.invalid/evidence/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E8 | Original evidence URL parser | `"https://example.invalid:0/sample"` | `{"host_expected_URLs":[],"disclosure_permission":"pending","live":"not_run"}` |
| E9 | Original evidence URL parser | `"https://example.invalid/evidence/sample?ref=SYN-DMO-44#mock"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample?ref=SYN-DMO-44#mock"],"disclosure_permission":"pending","live":"not_run"}` |
| E10 | Original evidence URL parser | `"https://example.invalid/evidence/sample,https://example.invalid/evidence/other"` | `{"host_expected_URLs":["https://example.invalid/evidence/sample","https://example.invalid/evidence/other"],"disclosure_permission":"pending","live":"not_run"}` |
| H1 | Original owned-meta reservation guard | `"done_text"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H2 | Original owned-meta reservation guard | `"repeat_after_reserve"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H3 | Original owned-meta reservation guard | `"explicit_false"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H4 | Original owned-meta reservation guard | `"pending_status"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H5 | Original owned-meta reservation guard | `"empty_transcript"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H6 | Original owned-meta reservation guard | `"whitespace_transcript"` | `{"host_success":true,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| H7 | Original owned-meta reservation guard | `"failed_meta_write"` | `{"host_success":false,"host_attempted":null,"delivery_or_claim":"pending","live":"not_run"}` |
| H8 | Original owned-meta reservation guard | `"already_attempted"` | `{"host_success":false,"host_attempted":true,"delivery_or_claim":"pending","live":"not_run"}` |
| S1 | Original scope/text filter | `"project_scope"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S2 | Original scope/text filter | `"other_project"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| S3 | Original scope/text filter | `"role_text_search"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S4 | Original scope/text filter | `"role_not_identity"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| S5 | Original scope/text filter | `"fixed_code_word"` | `{"host_expected_ids":["a"],"owner_or_access":"pending","live":"not_run"}` |
| S6 | Original scope/text filter | `"explicit_empty_tasks"` | `{"host_expected_ids":[],"owner_or_access":"pending","live":"not_run"}` |
| R1 | Read-only copy boundary | `"private_original"` | `{"rule":"Authorized original references stay in their approved private scope, no raw customer text in public.","status":"pending","live":"not_run"}` |
| R2 | Read-only copy boundary | `"local_note"` | `{"rule":"Synthetic host reservation only; actual phone note/audio not accessed or deleted.","status":"pending","live":"not_run"}` |
| R3 | Read-only copy boundary | `"clipboard_workspace_attachment"` | `{"rule":"Destination may save/sync/process separately; no remote delivery or ownership receipt.","status":"pending","live":"not_run"}` |
| R4 | Read-only copy boundary | `"retention_access_backup"` | `{"rule":"Unknown rules remain unknown, no invented retention duration/anonymization/deletion guarantee.","status":"pending","live":"not_run"}` |

</div>

Pinned source boundaries: [RadarModel](https://github.com/alexlee2046/yihu-ios/blob/0ddfe9805389827229d74a7adbf0c83a168d94e3/Apps/Collie/CollieRadarModel.swift) · [VoiceNote](https://github.com/alexlee2046/yihu-ios/blob/0ddfe9805389827229d74a7adbf0c83a168d94e3/Apps/Collie/CollieVoiceNote.swift)


<h2 id="first-answer">Naming a role is not acknowledgment, and saving a document is not formal archiving</h2>

Yihu provides voice text, notes and workbench handoff; this article adds no cross-department assignment/archive system. After drafting minutes manually, distinguish a proposed responsible role, its explicit acknowledgment through an existing process, the approved scope and an authorized document location. Visible drafts, receipt, ownership acknowledgment, approval and completed work need separate evidence; saved does not cover them all.

## A different task from fields and to-do extraction

The minutes-fields guide separates facts/proposals/questions; multi-note review handles conflicts across records. Here no new tasks are extracted. Check **whether an already proposed handoff was acknowledged by the relevant role and whether archiving conditions are known**. Do not fill real names, infer owners or alter departmental permissions just to complete a table.

## Manual ownership and archive checklist

<div role="region" aria-label="Cross-department acknowledgment and archive checks, scroll horizontally" tabindex="0">

| Dimension | Existing evidence needed | Synthetic record | Missing-evidence action |
| --- | --- | --- | --- |
| Proposed role | Role proposed in original text or existing process | Role A suggested, not acknowledged | Keep it proposed; do not assign automatically |
| Acknowledgment | Explicit response through an authorized workflow | No acknowledgment evidence supplied | CC, read status or a named person is not ownership |
| Approved scope | Confirmed content, constraints and unapproved parts | Review sample only; do not execute | No inferred purchasing, email, change or release authority |
| Open questions | Existing process that must confirm next | Owner and deadline pending | No guessed person/date |
| Archive location | Existing authorized storage and access scope | Location unverified; no upload | A local/workbench draft is not automatically an official archive |
| Retention rule | Actual team policy/reference, not invented duration | Existing rule needs maintainer clarification | No permanent-retention, backup-free or deletion guarantee |
| Copies | Actual note, clipboard, document and workbench copies | Local sample checked; others unknown | One deletion does not recall all material |
| Handoff stage | Separate draft/staged/recorded/uncertain evidence | Draft for review; not sent | saved/queued are not ownership or completion |

</div>

## A synthetic acknowledgment card that assigns no real work

```text
Item: Three sample editorial fields (not a real task)
proposed_role: Role A suggested, not assigned
acknowledgment_evidence: Not provided; do not mark acknowledged
approved_scope: Review sample wording only; no execution authority
open_question: Which existing process confirms ownership?
archive_location: Unverified; do not upload to a new destination
retention_rule_reference: Pending existing team policy
handoff_state: Local draft, not sent
```

These are manual checklist labels, not app/Radar imports or a signing API. This page sends no invitation, changes no permission, creates no shared document and collects no names/contact information. Confirm through the team's existing authorized channel, not by copying the synthetic card to a live ledger as a test.

## Ordering before archiving

1. Check the original and edited version before asking another role to confirm recognition errors.
2. Separate proposed responsibility from actual acknowledgment evidence. Silence is not consent.
3. Verify confirmed content/permission scope. Agreeing to review wording does not authorize task execution.
4. Check existing archive location, access and retention rules. Without evidence, stop in an authorized local draft instead of provisioning accounts, share links or public attachments.
5. List necessary copies and uncertain handoffs. Previously attempted notes retain original one-handoff state; archiving is not a bypass for repeated delivery.

Radar replies, if needed, retain original eligibility, server authority, phone confirmation and receipt readback. A recorded reply is not completed ownership work, and reply history is not a general document archive.

## FAQ

<h3 id="faq-owner">Does writing role A in minutes establish ownership?</h3>

No. It is proposed text until the relevant role explicitly confirms through an existing authorized process. CC or silence cannot replace that evidence.

<h3 id="faq-feature">Does Yihu provide departmental assignment or e-signatures?</h3>

No such capability is asserted or added. This is manual review guidance; voice drafts and note handoff do not create an organizational approval system.

<h3 id="faq-archive">Is saving a workbench draft formal archiving?</h3>

Not necessarily. The existing team process defines location, version, access and retention. Saving a draft alone does not establish those requirements.

<h3 id="faq-consent">Does acknowledging a review action authorize all proposals?</h3>

No. Scope must be explicit. Review, approval and execution authority are distinct, and unapproved content stays open.

<h3 id="faq-retention">Can this guide prescribe one retention/deletion period?</h3>

No. Destinations, accounts, backups and team policies differ. Refer to actual rules without inventing periods or deletion guarantees.

<h3 id="faq-reply-history">Can Radar reply history be a complete department archive?</h3>

Not as an inference. It reads original-item replies/feedback within its permission/implementation limits, not arbitrary documents, versions, signatures or ownership records.

## Guides and evidence

[Manual minutes fields](/en/guides/meeting-notes-brief-fields/) · [Multiple-note/to-do review](/en/guides/multi-note-review-handoff/) · [Manual noisy-transcript correction](/en/guides/noisy-transcript-text-correction/) · [Phone decisions/receipts](/en/guides/mobile-agent-decisions/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Implementation boundaries: [README replies/history](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md), [note one-handoff model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNote.swift). Cards and archive checks are editorial suggestions, not source functionality or compliance certification.
