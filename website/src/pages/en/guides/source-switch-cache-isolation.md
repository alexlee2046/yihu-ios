---
layout: ../../../layouts/Wave3Guide.astro
title: "Before changing a Radar source: old cache, pending records and late reads"
description: "Review cache cleanup, sourceRevisions and filter resets. Local isolation is not server identity, full migration or cross-device cleanup; no source is changed."
lang: en
---

<h2 id="first-answer">A new configured source cannot make old cache or late reads new-source evidence</h2>

On an actual source-field change, CollieRadarStore checks local reply records and refuses switching while unresolved. Failed old-cache cleanup also prevents the change. The success path increments local sourceRevisions, clears the snapshot, updates Watch source identity and resets selected filters. Reads check revision before storage instead of treating an old response as new-source success.

## Different from URL, offline and draft review

URL checks shape, offline checks read failure, drafts check original targets. Here **configuration-change isolation between old data and new source** matters. No live source/cache/record/credential is changed.

<div role="region" aria-label="Source-boundary review, scroll horizontally" tabindex="0">

| Check | Verified scope | Manual review | Not established |
| --- | --- | --- | --- |
| Change test | Trimmed source comparison | Actual source change versus rename | Every settings edit is a source switch |
| Reply records | Resolve draft/pending first | Original request/target | Switching erases uncertainty |
| Old cache | Failure refuses switch | Actual error/original configuration | Ignored failure is safe success |
| Snapshot | Cleared on success path | Local display versus server data | Server history/tasks deleted |
| sourceRevisions | Client-local isolation counter | Captured versus current revision | Server version/authentication |
| Watch identity | watchSourceIdentity updated | Local presentation identity | All Watch copies erased |
| Filters | project/status/priority reset | These versus all preferences | Tasks absent/completed |
| Async results | Revision checked before stores/follow-up | Late data is not a new read | Old network request never sent/recalled |

</div>

## Synthetic switch review

Old read A captured revision A; after a successful configuration change current revision is B. A's response is not B's latest read. If cleanup failed, report no switch rather than turning preparation into successful persistence.

Local IDs are not backend credentials, and display resets are not business migration. No atomic cross-device sync, restore or total-cleanup guarantee is supplied. Original permissions, unresolved replies and retention policies remain.

## FAQ

<h3 id="faq-1">Can source switching bypass a pending reply?</h3>

No. This change path requires resolving existing reply records instead of resetting uncertainty through URLs.

<h3 id="faq-2">Does failed cache cleanup still commit the source?</h3>

The cited path refuses the change; do not report a successful switch.

<h3 id="faq-3">Is revision a server task version?</h3>

No. sourceRevisions is local isolation, separate from business version/identity.

<h3 id="faq-4">Does a filter reset mean all tasks vanished?</h3>

No. Selected display conditions reset without modifying server material.

<h3 id="faq-5">Does an ignored response mean no network request happened?</h3>

No. Discarding results is not recalling an issued request.

<h3 id="faq-6">Was a source/cache changed here?</h3>

No. Fixed-source inspection only, without live configuration/data modification.

## Reading and source

[Feed URL](/en/guides/radar-feed-url-boundary-preflight/) · [Offline/old data](/en/guides/offline-workbench-handoff-troubleshooting/) · [Draft ownership](/en/guides/reply-draft-restoration-scope/) · [Start](/en/start/) · [Privacy](/en/privacy/)

[Update/read isolation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift) · [Source/display models](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift)
