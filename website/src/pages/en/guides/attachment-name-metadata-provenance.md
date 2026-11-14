---
layout: ../../../layouts/Wave3Guide.astro
title: "Does attachment 2 mean version two? Batch names, MIME and byte-count evidence"
description: "Review case-insensitive batch-local naming, extension-derived MIME and byteCount. Suffixes are not revisions/deduplication; metadata is not hash or truth."
lang: en
---

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
