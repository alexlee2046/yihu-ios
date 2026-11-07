---
layout: ../../../layouts/Wave3Guide.astro
title: "Does attachment 2 mean version two? Batch names, MIME and byte-count evidence"
description: "Review case-insensitive batch-local naming, extension-derived MIME and byteCount. Suffixes are not revisions/deduplication; metadata is not hash or truth."
lang: en
---

## SYN-ANM-45 attachment name and metadata preflight

SYNTHETIC_EXAMPLE · pending · not_run. Synthetic correspondence review, not revision approval, deduplication, redaction or authority.

[/samples/p24-attachment-name-metadata-provenance/README.md](/samples/p24-attachment-name-metadata-provenance/README.md) · [/samples/p24-attachment-name-metadata-provenance/preflight.zh.json](/samples/p24-attachment-name-metadata-provenance/preflight.zh.json) · [/samples/p24-attachment-name-metadata-provenance/preflight.en.json](/samples/p24-attachment-name-metadata-provenance/preflight.en.json)

Suffix is not revision, size is not hash, MIME is not real format. Stop when original reference, actual version or receipt is unknown. Test roots do not prove system App Group access; real attachments, cross-process operations and remote receipt remain not_run.

<div role="region" aria-label="SYN-ANM-45" tabindex="0">

| ID | Check | Synthetic observation | Boundary |
| --- | --- | --- | --- |
| C01 | Batch-local naming | sample.txt stays sample.txt; a fresh batch may reuse it. | Not account-wide deduplication. |
| C02 | Case collision | After sample.txt, SAMPLE.TXT becomes SAMPLE 2.TXT. | No content merge; 2 is not a business revision. |
| C03 | Occupied suffix | Occupied report.txt/report 2.txt yields report 3.txt. | Not approval order. |
| C04 | Empty-name fallback | Empty name becomes file, then file 2. | Not recovery of original identity. |
| C05 | Slash replacement | a/b.txt becomes a_b.txt. | Not arbitrary-path security certification or malware scanning. |
| C06 | Multiple suffixes | Conflicting a.tar.gz becomes a.tar 2.gz. | No unpacking or format verification. |
| C07 | Extension-derived type | Synthetic sample.txt infers text/plain. | MIME is not content sniffing, trust or redaction. |
| C08 | Equal size, different contents | alpha and bravo are each 5 bytes. | Equal size is not equal SHA or authenticity. |
| C09 | Missing-source size | byteCount may return 0 when size cannot be read. | 0 does not prove an empty file or successful copy. |
| C10 | Directory estimate | Two controlled 5-byte files total 10 in a directory. | Not total memory, a frozen snapshot or integrity guarantee. |
| C11 | Staging budget | Measured file accumulation gate is 200 MiB = 209715200 bytes. | Not a combined text/URL bound or website upload allowance. |
| C12 | Copy and original reference | save copies rather than moves; synthetic original remains. | No automatic original-path/content-hash/approved-version ledger; review the external mapping separately. |
| C13 | Manifest written last | Copy files first; atomically write manifest last. | Not a cross-process lock, whole-file transaction or real Extension evidence. |
| C14 | pending decode boundary | Bad JSON is skipped; a valid manifest may return even with a missing copy. | Visibility does not prove files complete, import or delivery. |
| C15 | Three App Group evidence layers | Record source declaration, final signature and system containerURL separately. | Writable test root is not system authority; nil is not a unique network diagnosis. |
| C16 | Destination and copies | Review revisions and necessary copies against authorized originals; stop when unknown. | Insertion/attached is not remote completion; destination may save/sync/process; discard is not server revocation. |

</div>



<h2 id="first-answer">A staged rename distinguishes files; it does not certify versions, deduplication or contents</h2>

Each save creates batch-local usedNames. uniqueName detects conflicts case-insensitively and preserves files under numbered names instead of merging/dropping contents. contentType comes from the extension; byteCount estimates source size. None establishes business version, actual format, byte identity or redaction. No archive deduplication/inspection service is added.

## Different from item review, encoding and revision retention

Items concern content/stages, encoding concerns serialization, retention relates revisions. Here **original-to-staged names and metadata evidence** matter. No real file is copied, renamed or disclosed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Local names | usedNames for one batch | Batch/item IDs/original reference | Whole-inbox/account deduplication |
| Case | lowercased collision checks | Original/staged mapping | Case variants prove identical content |
| Suffix | Preserve/number conflicting files | Name occupancy | Version 2/latest approval |
| Name cleanup | Name-character processing | Label versus actual material | Security scan/content identification |
| Type hint | Extension-derived UTType/MIME | Actual format/destination | Suffix proves trusted contents |
| byteCount | File/package size estimate; read failures separately | Measured size/actual copy | Same size means same SHA |
| Staging budget | 200 MiB measured-file accumulation | Not every text/page limit | Every site accepts 200 MiB |
| Retention identity | Batch/item/id/reference separately | Real version/content evidence | Name/number/MIME are business identity |

</div>

## Synthetic naming illustration

One batch contains sample.txt followed by SAMPLE.TXT; the latter can become SAMPLE 2.TXT. This is a collision suffix, not business v2, equal contents or automatic merging.

Other batches can reuse names. Type/size are not cryptographic digests. Use authorized originals/actual bytes/content for revision review instead of disguising formats or bypassing handoff/access through renaming.

## FAQ

<h3 id="faq-1">Does suffix 2 mean business v2?</h3>

No. Local naming occupancy is not approval/version order.

<h3 id="faq-2">Are case variants retained without renaming?</h3>

Current checks lowercase conflicts and number candidates, without merging contents.

<h3 id="faq-3">Does this globally remove duplicate contents?</h3>

No. Batch-local name uniqueness is not content deduplication.

<h3 id="faq-4">Does MIME prove real format?</h3>

No. Extension inference differs from content/destination evidence.

<h3 id="faq-5">Does equal byteCount prove equal bytes?</h3>

No. Size is neither SHA nor authenticity.

<h3 id="faq-6">Were files copied/renamed/inspected?</h3>

No. Synthetic/source review only, without attachment operations/services.

## Reading and source

[Per-item checks](/en/guides/share-batch-item-preflight/) · [Encoding/names](/en/guides/export-encoding-delimiter-preflight/) · [Version material](/en/guides/batch-change-record-retention/) · [File bridge stages](/en/guides/file-chunk-bridge-not-upload-receipt/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Naming/sizes/save](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift) · [Files/later placement](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShareTray.swift)
