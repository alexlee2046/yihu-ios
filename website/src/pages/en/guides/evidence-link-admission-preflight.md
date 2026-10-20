---
layout: ../../../layouts/Wave3Guide.astro
title: "Why evidence text has no clickable link: tokenization, HTTPS and URL admission"
description: "Review safeEvidenceURLs splitting, edge punctuation, HTTPS, credentials, ports and deduplication. Shape filtering is not security scanning, truth or full Markdown parsing."
lang: en
---

<h2 id="first-answer">Clickable means admitted shape, not trusted, redacted evidence</h2>

Radar retains evidence text and extracts clickable URLs. Parsing splits whitespace/newlines and listed delimiters, trims edge punctuation, requires HTTPS/nonempty host/no embedded user-password/valid port, then deduplicates by absoluteString. This is not full Markdown parsing, security scanning or business-evidence certification.

## Different from provenance and evidence truth checks

Provenance maps claims; second checks assess truth. Here **why text does not produce a link and which URL shapes are admitted** matters. Delimiters include Latin/Chinese comma/semicolon and vertical bar. No example URL is fetched or source rewritten.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Null/empty | Empty URL list | Original evidence versus placeholder | No business evidence exists |
| Tokenization | Whitespace/newlines/listed punctuation | Comma can split valid URL text | All reference syntax understood |
| Edge punctuation | Trims brackets/quotes etc. | Actual candidate | Full labeled Markdown parsing |
| Scheme/host | HTTPS, nonempty host | Protocol/destination | Safe-domain allowlist or authority |
| Embedded credentials | No user/password | Keep credentials out of URLs | Paths/queries automatically redacted |
| Port | Explicit 1…65535 | Shape versus access permission | Every endpoint tested |
| Deduplication | First absoluteString retained | Spellings/reference relationships | Universal semantic normalization |
| Result | Clickable candidates only | Body/evidence quality/destination | Harmless, true, read or handled |

</div>

## Synthetic URL review

Standalone https://example.com/review illustrates shape, not real project evidence. Labeled Markdown need not expand through a full grammar. Inspect original/tokenization rather than deleting evidence or inventing safety conclusions.

Paths, queries and fragments can disclose information despite no user/password. Existing access/destination permission applies; safe in a method name is neither a malware scan nor universal network safety.

## FAQ

<h3 id="faq-1">Does no link mean no evidence?</h3>

No. Text may not meet tokenization/URL rules. Inspect originals.

<h3 id="faq-2">Are labeled Markdown links always extracted?</h3>

No guarantee. This is not a full Markdown parser supporting all nesting.

<h3 id="faq-3">Does HTTPS prove trust and access permission?</h3>

No. Shape differs from origin, content, identity and authority.

<h3 id="faq-4">Is no embedded user/password equivalent to redaction?</h3>

No. Paths/query/fragments can remain sensitive.

<h3 id="faq-5">Are all equivalent URLs merged?</h3>

No semantic-normalization guarantee; deduplication uses absoluteString.

<h3 id="faq-6">Were example URLs opened?</h3>

No. No site-security or business-evidence acceptance was performed.

## Reading and source

[Evidence review](/en/guides/radar-evidence-second-check/) · [Claim provenance](/en/guides/radar-summary-claim-provenance/) · [Sensitive layers](/en/guides/carrier-redaction-archive-matrix/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[parseSafeEvidenceURLs](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [Link presentation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift)
