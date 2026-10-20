---
layout: ../../../layouts/Wave3Guide.astro
title: "What privacy manifests and permission copy prove: declarations versus runtime and sites"
description: "Review current API-use categories and Info.plist copy, not runtime network auditing, third-party zero collection or App Store approval. No compliance certification."
lang: en
---

<h2 id="first-answer">A declaration is not whole-path acceptance or proof that data never leaves</h2>

Current PrivacyInfo.xcprivacy lists UserDefaults/FileTimestamp accessed-API categories and reason codes. Info.plist separately contains microphone/camera purpose text and other configuration. These are source declarations/copy, not audits of every runtime entry, third-party page or later handoff. They establish neither zero collection, App Store review nor legal/privacy certification.

## Different from redaction, file options and service privacy

Redaction concerns content, protection concerns actual writes, sites/services have separate scopes. Here **static declarations within an evidence chain** matter. No legal conclusion, private-data access, request or permission change occurs.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| PrivacyInfo | Lists NSPrivacyAccessedAPITypes | Actual file/version | All runtime data flows audited |
| Categories/reasons | UserDefaults/FileTimestamp and CA92.1/C617.1 | Only listed source scope | Invent missing Tracking/CollectedData fields |
| Info.plist copy | Mic/camera purpose text | Copy versus entry implementation | One sentence proves every path |
| Background configuration | audio etc. declared | Actual runtime/system evidence | All locked/low-power scenarios guaranteed |
| Native/pages | Different code/service scopes | Scripts/Cookies/accounts/later actions | Native declarations cover every site |
| Local ASR/handoff | Separate stages | Actual destination/upload/send | Local recognition means data never leaves |
| Distribution/review | Files are not external acceptance | Real release evidence | Unverified App Store/sameAs |
| Retention evidence | Version/declarations/tests separated | Actually reviewed scope | Security/privacy/legal certification |

</div>

## Synthetic declaration note

Known: two API categories are declared in fixed source. Unknown: every device path, third-party page and destination's processing. Report reviewed declarations, not whole-chain zero collection/compliance.

Absent fields do not automatically create runtime guarantees. Preserve copy, choice, implementation and actual network/destination evidence separately. No store identity, certification or privacy test is supplied.

## FAQ

<h3 id="faq-1">Is PrivacyInfo a complete runtime audit?</h3>

No. Source declarations differ from actual flows/third-party evidence.

<h3 id="faq-2">Does an absent collection field prove whole-chain zero collection?</h3>

No. Invent neither meanings nor coverage.

<h3 id="faq-3">Does purpose copy replace testing every entry?</h3>

No. Native/shortcut/page/later actions need implementation-specific evidence.

<h3 id="faq-4">Does local ASR mean later text is never uploaded?</h3>

No. Recognition and authorized handoff/services differ.

<h3 id="faq-5">Does a manifest prove App Store release/review?</h3>

No. Do not generate unverified store links/sameAs.

<h3 id="faq-6">Is legal/privacy certification provided?</h3>

No. Static evidence scope only, without testing or compliance conclusions.

## Reading and source

[File options](/en/guides/local-file-protection-scope/) · [Sensitive content layers](/en/guides/carrier-redaction-archive-matrix/) · [Shell/services](/en/guides/voice-workbench-vs-radio-chat/) · [Actual handoff](/en/guides/handoff-evidence-audit-checklist/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Actual API declarations](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/PrivacyInfo.xcprivacy) · [Purpose/background settings](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/Info.plist) · [Native/workbench boundaries](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md)
