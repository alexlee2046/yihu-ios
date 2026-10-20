---
layout: ../../../layouts/Wave3Guide.astro
title: "Text, screenshots and attachments: carrier-specific redaction/archive checks"
description: "Separate text, visible pixels, metadata in the explicit camera/photo staging path and other files. Resizing or not copying source metadata is not automatic masking or universal attachment cleaning."
lang: en
---

<h2 id="first-answer">Identify carrier and processing path: metadata removal is not pixel-text redaction</h2>

Review text, screenshots, photos and other files separately before retention/sharing. Yihu's explicit camera/photo staging path performs bounded JPEG processing without copying source metadata. This is not automatic pixel masking, OCR redaction, universal attachment cleaning or an archive service. Minimization decides what to retain; here **which layer in a selected carrier may still disclose information** needs review.

## Carrier-specific scope matrix

<div role="region" aria-label="Text/image/attachment redaction scope, scroll horizontally" tabindex="0">

| Carrier/layer | Existing implementation/manual boundary | Still inspect | Do not claim |
| --- | --- | --- | --- |
| Text/transcript | Originals and manual corrections differ | Names, accounts, references, body and combinations | Automatic sensitive-word detection/masking |
| JSON/link text | Source fields retained; link filtering checks shape only | Paths, query, fragments and source/item identities | Valid JSON/HTTPS establishes redaction |
| Screenshot pixels | Visible text/avatars/QR codes remain image content | Customer material, accounts, tokens or identifying details | Metadata removal deletes visible text |
| Explicit image staging | JPEG processing of selected camera/photo input without source GPS/metadata copying | Final pixels, orientation, actual content and destination | Every shared file uses this path or output is anonymous |
| Encoded-image admission | Up to 32 MiB and 32 million pixels | Actual input type and refusal state | Size limits certify privacy/security |
| Camera bitmap/output | Separate 128 MiB bitmap bound; output side up to 2048 | Successful processing and final visible content | Resizing is reliable masking or confidentiality/performance evidence |
| Other attachments | Actual type/tool policy applies | Body, comments, revisions, hidden content and metadata | The image helper cleans arbitrary PDFs/documents/audio |
| Copies/archive | Original, edited file, tray, workbench and sync may differ | Existing permission, necessary copies and retention policy | Local deletion recalls remote/backed-up copies |

</div>

These are source admission/processing limits, not device-certified privacy outcomes. `CollieDiagnosticImage` describes its explicit input/output path, not every file in the system share inbox.

## Three layers in a synthetic review

```text
Carrier: A synthetic screenshot displaying sample account A.
Layer 1: Is the file in the reviewed image-processing path?
Layer 2: Is sample account A still readable in output pixels? Resizing does not prove removal.
Layer 3: Are old versions already in attachments/destinations, and is retention authorized?
Conclusion: Do not claim anonymity or recall of every copy without evidence.
```

No image, real account, camera, OCR or redaction operation is supplied. If masking is necessary, use an existing authorized tool and inspect the saved result. An editing step is not proof of successful masking, and older copies remain in scope.

## Path before content, then retention

Identify explicit photo/camera staging versus other system-shared files or text attachments. Check success and actual saved content. Only output from the relevant path supports that path's source properties; an identical filename suffix is insufficient.

Then inspect permissions/destination/necessary copies of originals and edits. Staging does not upload/send automatically. Later workbench handoff can upload before sending, so unsent messages do not establish no remote copy. Prior attempts retain guards; a renamed redacted draft cannot bypass one-handoff/uncertainty.

No universal retention period, legal certification, irreversible deletion or anonymity guarantee is provided. Keep unknown/unsuitable material within original permissions for the existing information-handling process, not public demos.

## FAQ

<h3 id="faq-pixels">Does removing GPS/source metadata remove screenshot text?</h3>

No. Text, avatars, QR codes and tables can remain readable in pixels. Review the final image separately.

<h3 id="faq-all-files">Is every file shared to Yihu automatically stripped?</h3>

No blanket claim follows. The cited path is explicit image staging, not arbitrary document/PDF/audio or other file input.

<h3 id="faq-resize">Does a 2048-side output guarantee unidentifiable details?</h3>

No. It is bounded processing, not a masking/anonymization algorithm. Text and other identifying detail can remain.

<h3 id="faq-limit">Does under 32 MiB mean safely redacted?</h3>

No. Admission size/pixels differ from content, permission and privacy. Check input type and actual result.

<h3 id="faq-replacement">Does a replacement attachment delete the older remote one?</h3>

No such feature is supplied. Inspect tray/uploads/drafts/sync separately under actual service rules, without a recall guarantee.

<h3 id="faq-archive">Does checking every box certify lawful anonymity or complete archiving?</h3>

No. This is neither legal nor anonymization certification. Actual permissions, content and retention evidence remain necessary, limited to reviewed scope.

## Reading and source

[Evidence minimization](/en/guides/followup-evidence-minimization/) · [Ownership/archive rules](/en/guides/department-minutes-ownership-archive/) · [Corrections/copies](/en/guides/noisy-transcript-text-correction/) · [Handoff evidence review](/en/guides/handoff-evidence-audit-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [explicit image inputs/limits/encoding/staging](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieDiagnosticImage.swift), [README image/sharing limits](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
