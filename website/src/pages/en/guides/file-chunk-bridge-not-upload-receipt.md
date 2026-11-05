---
layout: ../../../layouts/Wave3Guide.astro
title: "What file chunks establish: a 768 KiB bridge is not resumable upload or a receipt"
description: "Review native base64 reads, JS parts and page inputs. Chunking is not server streaming, constant whole-process memory or delivery; no transfer service added."
lang: en
---

<h2 id="syn-chk-40">SYN-CHK-40: chunks, page admission and inbox parsing</h2>

SYNTHETIC_EXAMPLE: owned temp files/fake WK/VM only, not real AppGroup or server upload.

[ZH: /samples/p19-file-chunk-bridge/preflight.zh.json](/samples/p19-file-chunk-bridge/preflight.zh.json) · [EN: /samples/p19-file-chunk-bridge/preflight.en.json](/samples/p19-file-chunk-bridge/preflight.en.json) · [Card: /samples/p19-file-chunk-bridge/preflight-card.md](/samples/p19-file-chunk-bridge/preflight-card.md)

<div role="region" aria-label="Synthetic file chunk, page receipt and inbox checks; horizontally scrollable" tabindex="0">

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| N1 | no_web | {'result': 'failed', 'roles': []} | Original Swift + fake WK replies; not server upload |
| N2 | untrusted | {'result': 'failed', 'roles': []} | Original Swift + fake WK replies; not server upload |
| N3 | normal | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N4 | no_input | {'result': 'noUploadControl', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N5 | single_only | {'result': 'oneAtATime', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N6 | unknown | {'result': 'failed', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N7 | chunk_false | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N8 | chunk_throw | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N9 | begin_throw | {'result': 'failed', 'roles': ['begin', 'discard']} | Original Swift + fake WK replies; not server upload |
| N10 | begin_false | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N11 | attach_throw | {'result': 'failed', 'roles': ['begin', 'chunk', 'attach', 'discard']} | Original Swift + fake WK replies; not server upload |
| N12 | origin_drift | {'result': 'failed', 'roles': ['begin', 'chunk', 'discard']} | Original Swift + fake WK replies; not server upload |
| N13 | same_origin_path_drift | {'result': 'attached', 'roles': ['begin', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| N14 | empty_file | {'result': 'attached', 'roles': ['begin', 'attach']} | Original Swift + fake WK replies; not server upload |
| N15 | empty_files | {'result': 'failed', 'roles': ['attach']} | Original Swift + fake WK replies; not server upload |
| N16 | two_chunks | {'result': 'attached', 'roles': ['begin', 'chunk', 'chunk', 'attach']} | Original Swift + fake WK replies; not server upload |
| F1 | synthetic file bytes=0 | actual source raw chunks=[]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F2 | synthetic file bytes=1 | actual source raw chunks=[1]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F3 | synthetic file bytes=786432 | actual source raw chunks=[786432]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F4 | synthetic file bytes=786433 | actual source raw chunks=[786432, 1]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| F5 | synthetic file bytes=1572881 | actual source raw chunks=[786432, 786432, 17]; reassembled bytes equal | Owned temp files, not network resume or total memory limit |
| C1 | normal | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C2 | binary_split | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C3 | unknown_chunk | false | Original emitted JS with synthetic File/DataTransfer/input |
| C4 | duplicate | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C5 | reordered | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C6 | missing_chunk | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C7 | invalid_base64 | throws | Original emitted JS with synthetic File/DataTransfer/input |
| C8 | discard | false | Original emitted JS with synthetic File/DataTransfer/input |
| C9 | rebegin | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C10 | no_input | no-input | Original emitted JS with synthetic File/DataTransfer/input |
| C11 | single_only | single-only | Original emitted JS with synthetic File/DataTransfer/input |
| C12 | type_mismatch | no-input | Original emitted JS with synthetic File/DataTransfer/input |
| C13 | multiple | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C14 | partial_ids | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C15 | empty_file | attached | Original emitted JS with synthetic File/DataTransfer/input |
| C16 | repeat_attach | failed | Original emitted JS with synthetic File/DataTransfer/input |
| C17 | empty_mime | attached | Original emitted JS with synthetic File/DataTransfer/input |
| I1 | orphan_file | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I2 | corrupt_json | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I3 | invalid_schema | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I4 | missing_payload | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I5 | save_copy | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I6 | empty_save_rollback | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I7 | inline_text | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I8 | duplicate_names | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I9 | oldest_first | pending decoded batches=2 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I10 | update_empty_items | pending decoded batches=1 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| I11 | missing_root | pending decoded batches=0 | init(root:) owned temp FS only, no shared()/AppGroup/real import |
| R1 | AppGroup access/declarations/signature/parse need separate evidence | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R2 | attached is not remote upload or business send | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R3 | Chunks have no sequence/checksum/resume guarantee | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |
| R4 | Discard/staging removal is not remote revocation | source/manual boundary; runtime not_run | No entitlement, signed-binary, AppStore or remote completion certification |

</div>

768KiB is the raw read block, not total memory or a resumable upload protocol; base64/JS parts/File add allocations. Chunk true/attached are bridge/page-stage results, not sequence/checksum/idempotent retry or remote completion proof. Duplicate/missing/reordered parts can still form a File and missing IDs can leave an attached subset. AppGroup declaration, runtime access, manifest visibility, pending decode, actual import and server receipt require separate evidence. Corrupt manifests are skipped; decoded batches may reference missing files. Real WK/container rights/remote API/AppStore review/business send are not_run. Preserve uncertain effects, do not blindly resend; destination may save/sync/auto-process.

<h2 id="first-answer">Chunks crossing a WebKit bridge do not prove the destination saved a complete file</h2>

attachFiles reads up to 768 KiB raw data per chunk, base64-encodes bridge arguments, then asks the page's own file control to accept them. JS accumulates parts and constructs File objects. Chunking proves neither constant memory everywhere nor server streaming/resume. attached is a page-stage result, not remote completion or sending.

## Different from mixed batches, manifests and protection

Batches concern placement order, manifests concern local visibility, protection concerns writes. Here **native-to-JS-to-input stages** matter. No real attachment is read/uploaded and no transfer service is added.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Native reads | Up to 768 KiB with offset | Local read/errors | Server resume offset |
| Base64 | Bridge string encoding | Overhead versus transfer stage | Raw bytes equal all RAM |
| JS staging | incoming/parts accumulate into File | Page memory versus local file | Constant memory across all sides |
| Chunk response | Per-chunk Bool can fail | Local acceptance versus service | Backend saved every chunk |
| Final control | Page input/accept conditions | Actual control/service limits | Every site/type/size supported |
| Page boundary | isTrusted etc. on this path | Not all text-path conditions transfer | All channels have identical guards |
| Discard | Clear helper IDs | Local staging versus remote copies | Recall a prior service upload |
| Budget/result | Local staging/attached separately | Actual stage/remaining items | 200 MiB staging guarantees site acceptance |

</div>

## Synthetic chunk note

Known: helper accepted several sample chunks. Unknown: final input/service status. Do not report upload complete or infer nothing happened from later failure. Keep the intended page stable and inspect actual results rather than renaming types/replaying batches.

Avoiding one giant JS string is implementation intent, not total-memory/speed/background-resume SLA. No general server upload/recovery protocol or device/network benchmark is supplied here.

## FAQ

<h3 id="faq-1">Are chunks server streaming?</h3>

No. Native-to-JS and site-to-service are different stages.

<h3 id="faq-2">Is 768 KiB a whole-memory limit?</h3>

No. Base64/parts/File and other allocations remain.

<h3 id="faq-3">Does attached prove server storage?</h3>

No. Page acceptance differs from remote evidence.

<h3 id="faq-4">Does discard recall a remote attachment?</h3>

No. Clearing helper state does not establish recall.

<h3 id="faq-5">Does 200 MiB staging certify every site?</h3>

No. Inputs/services retain limits and permissions.

<h3 id="faq-6">Was upload/resume tested?</h3>

No. Fixed source only, without a transfer/transcoding/resume feature.

## Reading and source

[Batch stages](/en/guides/share-batch-item-preflight/) · [Local visibility](/en/guides/share-manifest-visibility-review/) · [File protection](/en/guides/local-file-protection-scope/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Attachment/chunk flow](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWebView.swift) · [Parts/input adaptation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieTextInsertion.swift) · [Staging budget](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift)
