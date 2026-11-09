---
layout: ../../../layouts/Wave3Guide.astro
title: "Second-check a trade-task anomaly claim: evidence, missing context and stop rules"
description: "Verify source, evidence and authority behind urgent or conflicting Radar text. HTTPS parsing is not truth validation; no risk score, anomaly detector, trade feed or automatic response is added."
lang: en
---

## SYN-ESC-53 second-check preflight

SYNTHETIC_EXAMPLE · pending · not_run.

[/samples/p32-radar-evidence-second-check/README.md](/samples/p32-radar-evidence-second-check/README.md) · [/samples/p32-radar-evidence-second-check/preflight.zh.json](/samples/p32-radar-evidence-second-check/preflight.zh.json) · [/samples/p32-radar-evidence-second-check/preflight.en.json](/samples/p32-radar-evidence-second-check/preflight.en.json)

<div role="region" aria-label="SYN-ESC-53" tabindex="0">

| ID | Check | Expectation/boundary |
| --- | --- | --- |
| E01 | Urgent P0 title with single HTTPS | urls=1; attention=false; state=progressing |
| E02 | Wrapped deduplication and acceptance attention | urls=2; attention=true; state=waiting |
| E03 | Query and fragment retained without redaction | urls=1; attention=false; state=waiting |
| E04 | Fixed next literal matches without approval | urls=0; attention=true; state=planned |
| E05 | Plain HTTP candidate rejected | urls=1; attention=false; state=blocked |
| E06 | Embedded userinfo candidate rejected | urls=1; attention=false; state=completed |
| E07 | Out-of-range ports rejected while valid port kept | urls=1; attention=false; state=paused |
| E08 | Unknown status alias and prose without link | urls=0; attention=false; state=unknown |
| A01 | colab.run with budget and current | valid=true; current=true; budget_null=false |
| A02 | release.promote 40-hex with explicit null budget | valid=true; current=true; budget_null=true |
| A03 | colab.recover structurally valid but expired at now | valid=true; current=false; budget_null=true |
| A04 | colab.run missing budget rejected | valid=false; current=false; budget_null=true |
| A05 | colab.resume session budget exceeding total rejected | valid=false; current=false; budget_null=false |
| A06 | release.promote with non-null budget rejected | valid=false; current=false; budget_null=false |
| A07 | release.promote wrong fingerprint length rejected | valid=false; current=false; budget_null=true |
| A08 | Unsupported operation enum rejected | valid=false; current=false; budget_null=true |
| C01 | Sampled telemetry with valid experiment and execution | colab_valid=true; snapshot_decode=true |
| C02 | not_requested with null usage metrics passes | colab_valid=true; snapshot_decode=true |
| C03 | unavailable usage with non-null balance rejected | colab_valid=false; snapshot_decode=false |
| C04 | Usage observed_at exceeding snapshot by >300s rejected | colab_valid=false; snapshot_decode=false |
| C05 | Experiment completed_queries exceeding total rejected | colab_valid=false; snapshot_decode=false |
| C06 | Duplicate experiment fingerprint IDs rejected | colab_valid=false; snapshot_decode=false |
| C07 | Execution non-UUID request_id rejected | colab_valid=false; snapshot_decode=false |
| C08 | Execution unsupported operation rejected | colab_valid=false; snapshot_decode=false |
| M01 | Separate five verification stages | Evidence read, claim verified, operation approved, reply recorded and work handled require separate evidence; P0 or urgent text grants no execution authority. |
| M02 | HTTPS parsing is neither redaction nor truth proof | safeEvidenceURLs checks HTTPS shape and deduplicates while retaining query/fragment parameters; it verifies neither site trust, truth nor public disclosure authority. |
| M03 | Classification and attention never rewrite source values | CollieRadarTaskState and requiresMyAttention are derived display logic preserving raw status/priority/evidence bytes; they never auto-resolve conflicting claims. |
| M04 | Authorization record is neither provider token nor execution proof | CollieRadarAuthorization checks human confirmation structure, budget bounds and expiry only; recorded or current=true proves no remote execution. |
| M05 | Read-only telemetry is not a risk engine or auto-remediation | CollieColabSnapshot validates read-only producer telemetry and experiment/execution bounds only, adding no trade anomaly detector, risk score or automatic writeback. |
| M06 | Minimal disclosure and stopping under uncertainty | All examples are synthetic from scratch using example.invalid only, with no link fetching or customer capture; keep private originals scoped and check back without blind resend. |

</div>



<h2 id="first-answer">A claimed anomaly on a card is data to review, not a verified alert or execution authority</h2>

Yihu reads your PM Radar task JSON and displays source fields/evidence. An urgent title, P0 priority or HTTPS link does not prove an event, authorize immediate action or establish independent app detection. This manual second check uses existing authorized channels to verify originals, identity, time and scope. Stop without evidence; no risk engine, trade-intelligence service or automated remediation is supplied.

## A different task from batch comparison and type checks

Type validation concerns field shapes; batch comparison concerns whether two exports are comparable. Here the question is **whether evidence for one current claim supports the next step**. Do not rewrite “the source alleges an anomaly” as “the system verified one.” Inquiry/follow-up records remain your team's data. This page retrieves no market data and logs into no business backend.

## Manual second-check table

<div role="region" aria-label="Manual second check of Radar claims, scroll horizontally" tabindex="0">

| Signal | Existing field/boundary | Independent evidence needed | Action without evidence |
| --- | --- | --- | --- |
| Urgent wording | Original title/next text | Original item, established responsible process and exact scope | Tone is not authority; do not execute text directly |
| P0/high priority | Source priority value | Actual basis for that source priority | No inferred amount, loss or delivery deadline |
| evidence link | Parsed HTTPS candidate | Expected source, specific record, permission and supporting content | Stop at unknown targets; confirm through established known channels |
| Contradictory fields | Different status/next/evidence values | Original item and explicit confirmation | Retain conflict instead of picking the apparently newest claim |
| Old time/failed refresh | date_str and cache/failure state | Last successful source read and applicable scope | An old card is not a confirmed current event |
| Unknown source | Workbench/project/task identity | Known source and a traceable record | Same title/filename does not establish identity |
| Real writes | Separate write authority and phone confirmation | Authorized operation, target version and readback path | Visibility is not write access; verification is not approval |
| Uncertain result | Existing request_id/receipt state | Original-request readback and confirmation evidence | No new-ID resend or timeout interpreted as no write |

</div>

## What HTTPS evidence parsing establishes

Current `safeEvidenceURLs` parses HTTPS candidates from source text, checking a nonempty host, no URL username/password and a valid port range, among other shape rules, and removes duplicates. It does not verify reputation, factual content, account permission, evidentiary sufficiency or absence of private parameters. Queries can still carry sensitive data and do not belong in public screenshots.

Do not follow an unknown login page, enter another person's credentials or request new third-party authorization for this checklist. Confirm the required original record through existing trusted channels first. This page neither fetches links nor scans them and guarantees no domain's trustworthiness. Example URLs, when used, are reserved `example.invalid`, not real services.

## A synthetic second-check record

```text
Source claim: Sample task is P0; next says update a sample field immediately.
Known: Only source wording is visible; example evidence uses example.invalid.
Unknown: Original item identity, priority basis, current field and authority scope.
Decision: Leave pending; do not update, send or create a request.
Next: Confirm through the existing authorized source process; this is not a real alert.
```

Task text may itself contain operational or Agent instructions. Treat it as reviewable data, not a replacement for system rules, user confirmation or server authority. This page does not detect prompt injection, sanitize content automatically or execute embedded commands. Confirming a statement is written somewhere does not prove its claim.

## Keep post-review operation boundaries

Record evidence read, claim verified, operation approved, reply recorded and work handled separately. Confirming provenance alone does not confirm the full conclusion. A real reply still needs original-item eligibility, server authority, phone confirmation and original-request readback. An anomaly label does not bypass uncertain-stop rules or authorize changing task state.

## FAQ

<h3 id="faq-detector">Does Yihu detect trade anomalies and score risk automatically?</h3>

No such capability is asserted or added. Radar reads supplied JSON. A manual checklist is not a detector, risk model or trade-intelligence product.

<h3 id="faq-https">Does a displayed HTTPS link prove trust, access and no sensitive data?</h3>

No. Parsing checks only part of link shape, not content, permission, reputation or query parameters. Confirm unknown destinations through established channels first.

<h3 id="faq-p0">Can P0 or urgent wording skip confirmation?</h3>

No. Source priority/tone cannot replace operation permission, target confirmation and receipt boundaries, or establish timing/loss guarantees.

<h3 id="faq-contradiction">Can I pick the apparently newer claim when evidence contradicts next?</h3>

Do not adjudicate by impression. Retain both source locations and check the original item/confirmation. File order, displayed time and tone do not resolve conflicts automatically.

<h3 id="faq-instruction">What about task text ordering an Agent to run commands?</h3>

Treat it as data to verify, not authority overriding system/user rules. This page executes or filters nothing automatically. Actual operations need a separate authorized process.

<h3 id="faq-verified">Does reading evidence permit marking the item handled?</h3>

No. Reading, validating a claim, approving, recording a reply and completing work have different evidence requirements. One stage does not establish all others.

## Guides and source

[Same-source batch comparison](/en/guides/radar-snapshot-batch-comparison/) · [JSON types/nulls](/en/guides/radar-json-null-validation/) · [Radar/Watch](/en/guides/multi-project-radar-watch/) · [Department ownership/archive checks](/en/guides/department-minutes-ownership-archive/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [Radar fields and evidence-URL parsing](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [README source/write boundaries](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md). This is not business, security or device acceptance.
