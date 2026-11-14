---
layout: ../../../layouts/Wave3Guide.astro
title: "What file chunks establish: a 768 KiB bridge is not resumable upload or a receipt"
description: "Review native base64 reads, JS parts and page inputs. Chunking is not server streaming, constant whole-process memory or delivery; no transfer service added."
lang: en
---

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
