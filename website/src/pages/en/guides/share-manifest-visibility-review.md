---
layout: ../../../layouts/Wave3Guide.astro
title: "What a share manifest establishes: local visibility and incomplete directories"
description: "Review copy-before-manifest, pending decoding and incomplete-directory cleanup. Visible is not reviewed/delivered; 3600 seconds is not universal retention."
lang: en
---

<h2 id="first-answer">A manifest makes local batches visible; it is not a service receipt or immutable archive</h2>

Inbox save copies files/builds items before atomically writing manifest.json last. pending reads/decodes manifests to list batches, without verifying every attachment still exists or was reviewed. update can rewrite a manifest. It therefore certifies neither server submission, delivery, business approval nor immutable archiving.

## Different from mixed handoff, encoding and protection

Handoff checks page stages, encoding checks serialization, protection checks write options. Here **local construction visibility, missing entries and incomplete directories** matter. No inbox access, cleanup or deletion occurs.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Construction | Copy, not move; manifest last | Original versus staged copy | Source moved or business message sent |
| Visibility | Readable/decodable manifest listed | List versus actual attachments | Each file exists/reviewed/integrity-checked |
| pending failure | Directory/read/decode can omit entries | Actual errors/scope | Empty means no material |
| Update | Manifest can change after partial placement | Current stage | Permanent immutable original |
| No manifest | sweepIncomplete conditionally attempts cleanup | Absence/directory timestamp | Every batch has deletion TTL |
| Default 3600 seconds | Modification age; missing time can use distantPast | Age/call time | Hourly clearing/minimum one-hour retention |
| Removal | try? is not independent success proof | Actual directories/copies | Secure erasure/complete collection |
| Service/archive | Local metadata differs | Actual drafts/attachments/receipts | Server transaction or recipient confirmation |

</div>

## Synthetic local observation

A lacks a manifest and is absent from pending: that does not establish no file was copied or every copy was removed. B has a decodable manifest: inspect attachments/stage separately instead of claiming complete archiving.

Default cleanup age is 3600 seconds against modification time. Missing time can use distantPast, not a minimum hour after creation. Cleanup must be called; no timer service is added. Original/staged/remote copies retain actual permission boundaries.

## FAQ

<h3 id="faq-1">Does a manifest prove every attachment exists?</h3>

pending decodes the list, not every file's existence/content. Verify separately.

<h3 id="faq-2">Does an empty list prove no residual files?</h3>

No. Missing manifests and directory/read/decode failures differ.

<h3 id="faq-3">Is 3600 seconds every material's retention period?</h3>

No. It is incomplete-directory age, not universal TTL or scheduled-cleanup promise.

<h3 id="faq-4">Does missing modification time guarantee an hour?</h3>

No. This path can use distantPast; no creation-based minimum follows.

<h3 id="faq-5">Is the manifest immutable?</h3>

No. Existing update rewrites it; not a tamper-proof log.

<h3 id="faq-6">Was cleanup/upload run here?</h3>

No. Local structure review only, without access/deletion/upload or new archive service.

## Reading and source

[Mixed-batch stages](/en/guides/share-batch-item-preflight/) · [Encoding/internal manifest](/en/guides/export-encoding-delimiter-preflight/) · [File options](/en/guides/local-file-protection-scope/) · [Removal scope](/en/guides/note-removal-retention-boundaries/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Save/update/pending/sweep](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift) · [Cleanup invocation/placement](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShareTray.swift)
