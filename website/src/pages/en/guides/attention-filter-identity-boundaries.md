---
layout: ../../../layouts/Wave3Guide.astro
title: "Why attention filtering matches or misses: fixed display rules are not account identity"
description: "Review requiresMyAttention states and a fixed next-text match alongside other filters. No account resolution, ownership, approval or write authority follows."
lang: en
---

<h2 id="first-answer">Attention filtering is derived display, not server ownership, identity or authority</h2>

Current requiresMyAttention trims status and checks the two decision/acceptance states, or tests next for the fixed source string Alex. This getter does not read the signed-in account. A match does not establish actual ownership or reply access; a miss does not prove nothing needs handling.

## Different from aliases, ownership and placeholders

Aliases concern categories, ownership concerns responsibility, placeholders concern missing data. Here **attention-match reasons and display coverage** matter. The literal is a public code condition, not customer content or a new account-identification service.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| State branch | Two explicit trimmed states can match | Raw status/condition | Name must occur in prose |
| Next branch | localizedStandardContains for fixed Alex | next, not all contents | Current account/contact inferred |
| Filter enabled | matchingActions can use allTasks | Actual ledger/source coverage | Every pending task discovered |
| Other conditions | Project/status/priority/search/history still filter | Current display configuration | Matches always visible |
| No match/list empty | Source/multiple conditions matter | Originals/scope/unknowns | Nobody awaits action/all done |
| Derived Bool | No source-status rewrite | Raw versus display | Automatic claiming/approval |
| Reply eligibility | Actual target/capability/authority separately | Original prepare/confirmation | Match grants submit |
| Editorial retention | Original values/reviewed scope | Not a native reason API | Automatic owner evidence |

</div>

## Synthetic filter note

A can match an acceptance state without the literal in next. B containing the literal does not prove the signed-in user owns it. A project-filtered empty list does not establish no pending source items.

Briefs should state source/scope instead of treating filter screenshots as account, approval or receipt evidence. Do not edit names/states to bypass write guards.

## FAQ

<h3 id="faq-1">Does attention read the logged-in account?</h3>

This getter uses fixed states/text, without dynamic account-identity guarantees.

<h3 id="faq-2">Why match without a name?</h3>

The explicit decision/acceptance states can match independently.

<h3 id="faq-3">Does a name in title guarantee matching?</h3>

The name branch checks next, not every field; other filters also apply.

<h3 id="faq-4">Does empty mean no tasks?</h3>

No. Source coverage, filters and gaps need review.

<h3 id="faq-5">Does matching assign ownership or replies?</h3>

No. Responsibility/target/authority remain separate.

<h3 id="faq-6">Is multi-user identification or claiming added?</h3>

No. Derived display only, without provisioning accounts/authority/dispatch.

## Reading and source

[Status aliases](/en/guides/status-alias-approval-boundaries/) · [Ownership](/en/guides/department-minutes-ownership-archive/) · [Placeholders](/en/guides/empty-field-display-defaults/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Attention/matchingActions](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift) · [Display controls](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift)
