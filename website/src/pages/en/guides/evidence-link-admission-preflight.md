---
layout: ../../../layouts/Wave3Guide.astro
title: "Why evidence text has no clickable link: tokenization, HTTPS and URL admission"
description: "Review safeEvidenceURLs splitting, edge punctuation, HTTPS, credentials, ports and deduplication. Shape filtering is not security scanning, truth or full Markdown parsing."
lang: en
---

## SYN-ELA-46 evidence link admission preflight

SYNTHETIC_EXAMPLE · pending · not_run. Shape is not safety, truth, redaction or authority.

[/samples/p25-evidence-link-admission-preflight/README.md](/samples/p25-evidence-link-admission-preflight/README.md) · [/samples/p25-evidence-link-admission-preflight/preflight.zh.json](/samples/p25-evidence-link-admission-preflight/preflight.zh.json) · [/samples/p25-evidence-link-admission-preflight/preflight.en.json](/samples/p25-evidence-link-admission-preflight/preflight.en.json)

<div role="region" aria-label="SYN-ELA-46" tabindex="0">

| ID | Check | Boundary |
| --- | --- | --- |
| E01 | Null | Null input does not prove absent business evidence. |
| E02 | Empty string | Do not fabricate evidence or URLs. |
| E03 | Whitespace | An empty list is not an instruction to delete source records. |
| E04 | Standalone HTTPS | Shape admission only, not trust or access authority. |
| E05 | Edge punctuation | Only trims listed edge characters, not full grammar parsing. |
| E06 | Newline tokens | First-seen ordering is not a provenance relationship. |
| E07 | Listed separators | Listed punctuation splits tokens; not all reference syntax. |
| E08 | Exact duplicate | absoluteString deduplication is not content deduplication. |
| E09 | Reject HTTP | Rejection proves neither a missing nor malicious destination. |
| E10 | Other scheme | Do not rewrite a scheme to fabricate admission. |
| E11 | Missing host | Do not invent a host. |
| E12 | Embedded user | SYN-user is synthetic; absent user info does not redact paths or queries. |
| E13 | Port zero | The port gate is not endpoint availability testing. |
| E14 | Out-of-range port | Do not rewrite the port and conceal the original. |
| E15 | Port upper bound | Admission is not port security certification or a network test. |
| E16 | Explicit 443 | Do not claim semantic normalization with omitted ports. |
| E17 | Labeled Markdown | This case is not extracted; not a full Markdown parser. |
| E18 | Comma inside URL | Comma splits off a prefix that may differ from intent; retain the original for review. |
| E19 | Query and fragment retained | All markers are synthetic; filtering neither redacts nor authorizes disclosure of paths, queries or fragments. |
| E20 | Period is not trimmed | A final period remains; do not assume prose is automatically corrected. |
| E21 | No domain allowlist | localhost may pass shape checks; no fetching or bypassing local-network authority. |
| E22 | Encoded comma | No universal normalization of decoded semantics. |
| E23 | Different fragments | Different absoluteStrings may coexist; not proof of distinct contents or reading. |
| E24 | Trailing slash spelling | Distinct strings are not automatically merged semantically; no redirects are resolved. |
| R01 | Evidence and reminder parsers do not grant each other admission | Evidence uses shape filtering; reminders separately check relay HTTPS/host, not the same allowlist. |
| R02 | Pending slot is not an open receipt | handleTap sets pendingURL; consumption clears it, not a complete audit queue. |
| R03 | Preserve speech and notes | Do not bypass notesPresented, canCancel, delivering, canRetryDelivery or onWillSaveConnection for navigation. |
| R04 | Current-origin connection | Consume only once connected; not proof of login, session, trusted content or business success. |
| R05 | Saved versus unknown origin | Other origins must be saved; consume/drop unknown origins without adding a server or widening authority. |
| R06 | Destination and originals | No fetching examples or erasing originals/effects; destinations may save/sync/process, no blind retry when unknown. |

</div>



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
