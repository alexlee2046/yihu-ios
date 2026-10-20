---
layout: ../../../layouts/Wave3Guide.astro
title: "What local file options prove: atomic writes, backup exclusion and carrier scope"
description: "Review per-path options. atomic is not end-to-end encryption; backup exclusion is not no copies; absent explicit options do not prove plaintext or certification."
lang: en
---

<h2 id="first-answer">Local write options do not replace network, remote, backup and retention review</h2>

Source paths use different options: some iOS cache/pending/temporary-image writes specify completeFileProtection; inbox manifests and note metadata use atomic writes, with backup exclusion on selected directories. Review actual paths instead of claiming end-to-end encryption, uniform protection or disappearance of every copy.

## Different from redaction, removal and retention mapping

Redaction checks content, removal checks deletion scope, retention maps evidence. Here **which carriers options cover and what needs actual attributes/system checks** matters. No private files/properties, backups or restores are operated.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| atomic | Write-replacement consistency option | Actual file/failure | Encryption/signature/directory transaction |
| iOS cache/pending | Cited paths specify completeFileProtection | Actual file/system conditions | Every platform/file identical |
| Temporary image | Explicit staged JPEG protection write | Staged file versus later copies | All shared files get identical options |
| Manifest/note metadata | Some writes specify only atomic | Defaults/inheritance separately | Missing explicit option proves plaintext |
| Backup exclusion | Per-directory, differing error handling | Success/other copies | No backups or permanent non-retention |
| Network/remote | Local options do not cover service | Actual target/network/authority | End-to-end encryption or remote wipe |
| Platform branches | iOS/test-platform options differ | Conditional code/runtime | macOS branch proves a shipped Mac app |
| Security/retention | Actual scope/policy required | Content/copies/access separately | Certification/permanent backup/restore SLA |

</div>

## Synthetic protection review

Known: one sample write explicitly specifies completeFileProtection. Unknown: other-copy attributes/destination retention. Report that call only, not whole-package end-to-end encryption or irreversible deletion.

Absent explicit options do not prove plaintext; defaults/inheritance need authorized inspection. No security audit/device unlock ran, and atomic/exclusion does not establish evidence truth or compliance.

## FAQ

<h3 id="faq-1">Is atomic encryption?</h3>

No encryption/signing follows from that option alone.

<h3 id="faq-2">Does one protected path cover every attachment?</h3>

No. Writes/later copies need separate review.

<h3 id="faq-3">Does atomic alone guarantee plaintext?</h3>

No. Defaults/inheritance/actual system conditions matter.

<h3 id="faq-4">Does backup exclusion prove no copies exist?</h3>

No. Setting success, other backups/remotes/manual copies differ.

<h3 id="faq-5">Does macOS conditional code prove a live Mac app?</h3>

No. Test/conditional paths establish neither distribution nor store/production support.

<h3 id="faq-6">Is this privacy or recovery certification?</h3>

No certification/backup/restore service is added; actual permissions/policies remain.

## Reading and source

[Content redaction](/en/guides/carrier-redaction-archive-matrix/) · [Removal scope](/en/guides/note-removal-retention-boundaries/) · [Material retention](/en/guides/batch-change-record-retention/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Pending writes/attributes](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarReply.swift) · [Cache/draft platform options](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift) · [Note writes/exclusion](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift) · [Temporary image](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieDiagnosticImage.swift) · [Manifest writes](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/CollieShareInbox.swift)
