---
layout: ../../../layouts/Wave3Guide.astro
title: "Before saving a note as a Radar draft: candidates do not grant reply access"
description: "Review local enumeration, source/state/id checks, reservation and eligible=false. Candidates are not live capabilities, bulk dispatch or a new opportunity backend."
lang: en
---

<h2 id="first-answer">A visible candidate passed local filters; draft saving is not reply submission</h2>

writableDraftCandidates enumerates local workbenches/snapshots with valid feed shape, no local reply record, specified decision/acceptance states and nonempty id. Enumeration does not additionally establish reply_supported or freshness. Saved targets use eligible=false, empty epoch/version and submitted=false; original prepare/confirmation remains. No automatic sender or opportunity-collection backend is added.

## Different from restoration, aliases and multi-note review

Restoration checks old ownership, aliases check display, multi-note review checks originals/order. Here **local Radar draft candidate scope and save results** matter. No real note, target or service is operated.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Enumeration | Local ordered workbenches/snapshot.allTasks | Actual source/original item | Organization-wide discovery/sync |
| Filters | Feed shape/no local record/status/nonempty id | Gaps/existing records | Service write access established |
| Not established | No extra reply_supported/freshness check | Later actual target/capability | Candidate is fresh/submittable |
| Save recheck | Workbench/source/id/url/state etc. | Candidate changed since enumeration | List snapshot permanently valid |
| Text | Trimmed, at most 4000 Unicode scalars | Original/actual saved scope | Bytes/characters interchangeable |
| Draft | eligible=false, empty epoch/version, submitted=false | Local record/later prepare | Submitted/authorized/executed |
| Reservation | Shell calls reserveHandOff before save | Failure may follow reservation | Blind replay safe after save failure |
| Later action | Original source/target/canSend/confirmation | Real receipts/prior effects | Automatic bulk dispatch/CRM writes |

</div>

## Synthetic candidate review

Sample candidate A exists; capability/freshness unreviewed. A candidate does not prove submission readiness. A successful local save is not sent. On failure inspect note reservation/local state before another attempt.

No target-discovery/reply-adapter service is created. writable in a name does not establish every write prerequisite; report the stage actually performed.

## FAQ

<h3 id="faq-1">Does appearing prove reply_supported=true?</h3>

No. Enumeration does not additionally check that field; later capability/target review remains.

<h3 id="faq-2">Does no candidate mean no tasks exist?</h3>

No. Snapshot/status/id/local-record filters can exclude entries.

<h3 id="faq-3">Does saving a draft submit to a backend?</h3>

The cited path writes a local unsent record, not server receipt/approval.

<h3 id="faq-4">Why eligible=false?</h3>

A local draft grants no writes; actual target preparation/confirmation remains.

<h3 id="faq-5">Can failed save be retried with another target immediately?</h3>

Not blindly. The shell may already have reserved the note handoff; inspect state/results.

<h3 id="faq-6">Is automatic opportunity archiving/bulk writing added?</h3>

No. Existing local draft flow only, without hosted backend or dispatch.

## Reading and source

[Draft ownership](/en/guides/reply-draft-restoration-scope/) · [Status/eligibility](/en/guides/status-alias-approval-boundaries/) · [One handoff](/en/guides/recording-notes-handoff/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Candidates/local draft](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift) · [Reservation/save order](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieShellApp.swift) · [Existing candidate UI](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotesView.swift)
