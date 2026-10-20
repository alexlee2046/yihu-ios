---
layout: ../../../layouts/Wave3Guide.astro
title: "Multi-project PM Radar: JSON, cache age and Watch-to-iPhone handoff"
description: "Understand tasks versus decisions, multi-project sources and stale caches. Separate watch summaries, phone confirmation, write authorization and notification event sources."
lang: en
---

<h2 id="first-answer">First answer</h2>

Yihu PM Radar consumes your multi-project JSON snapshots: distinguish the ledger, pending subset and source time before filtering. A paired Watch offers existing summaries and a phone handoff, not independent ledger refresh, approval, push delivery or execution guarantees. Read access is not write permission; missing fields, stale caches and failed reads must remain visible.

## From source contract to a wrist summary
1. **Choose a source**: import an authorized JSON export or configure an existing access-controlled HTTPS feed. Do not publish private ledgers or put credentials, tokens or query parameters in the URL. A native feed read does not share the web login session.
2. **Check structure**: inspect date_str, decisions, active/stale/cold and optional tasks. A task's project matches a project record's path. An array named projects does not replace the three arrays required by the current model.
3. **Inspect source time and failure flags**: displaying an old snapshot is not a successful refresh. Distinguish source_refreshing from source_refresh_failed. Request initiation, cache hits and successful source reads must not share a misleading “latest” label.
4. **Then filter**: check project/status/priority/search and history. Current View management groups/counts use the filtered full-task set. The README overview does not override View behavior; decisions is not the complete ledger.
5. **Use the wrist for preview/handoff**: check source age and phone reachability. Sync republishes an existing snapshot. Opening an item or proposing text still requires phone source/task checks, busy-state guards, explicit confirmation and separate server authority—not independent approval.

<div role="region" aria-label="Implementation boundaries (scroll horizontally)" tabindex="0">

| Data/layer | Meaning | Misinterpretation to avoid |
| --- | --- | --- |
| tasks / decisions | Ledger / pending subset; missing tasks means incomplete legacy scope | A small subset means no project tasks |
| active / stale / cold | Source project-activity records; path joins task project | The stale bucket is snapshot expiry, or inactivity proves blockage |
| Source date_str | Last successful read in UTC+08:00 | Pressing refresh makes it current |
| Phone cache | Last valid snapshot, retained with a failure indication | Visible cards prove a successful new read |
| Optional adapter cache | Request-triggered; fresh 30s, old up to 5m while revalidating; failed reads without usable data can return 503 | Every source refreshes on a 30s schedule or provides a phone SLA |
| Watch sync | Existing pending summaries; truncation points back to the phone | A fresh ledger read or queued means the UI opened |
| Writes / notifications | Separate authorization, subscription/service and device prerequisites | GET implies write/push permission or a standalone Watch approver |

</div>

**Synthetic walkthrough**: demo-alpha has two tasks and demo-beta one: tasks=3, decisions=1. Intersecting demo-beta with the waiting-for-decision status gives zero; selecting its actual to-do status gives one. The project did not disappear. Watch selects decision/acceptance items only, so no beta summary is not proof that beta is absent. The fixed date 2026-10-18 09:00 is historical demo data, not fresh because this page was published now. reply_supported=false and example.invalid links prevent this illustration from claiming a real source or write.

**Keep cache layers separate**: client warnings use 24 hours and five minutes into the future; the optional adapter's 30s/5m bounds describe read caching, not task-update frequency. A refreshing source can paint cached data and receive one no-cache follow-up. This introduces no scheduler, timer or polling.

## Detailed questions and answers

<a id="faq-radar-feed-schema"></a>
## How should a multi-project snapshot distinguish the full task ledger, pending items and project activity?

The JSON uses tasks for the full ledger, decisions for the decision/acceptance subset, and active/stale/cold for project records. projects is a computed model property combining those three arrays, not a replacement import key. A task's project matches a project's path. Legacy exports without tasks fall back to decisions with an incomplete-ledger notice. Do not treat subset counts as ledger totals; current management counts follow the View's filtered full-task set.


<a id="faq-radar-source-identity"></a>
## How can I prevent an old cached snapshot from masquerading as a new workbench source?

Native JSON reads do not reuse web cookies, store credentials or follow redirects. Use the documented file-export path for authenticated feeds rather than embedding a secret in a URL. Changing a source requires clearing its old cache; failure or an unresolved reply can block the change. Source-revision checks discard results from superseded requests. These safeguards do not replace server access control or equate the permissions of different sources.


<a id="faq-radar-filter-intersection"></a>
## If project, status and search filters return nothing, how can I distinguish an empty ledger from filtered-out tasks?

Project, source-status, priority and search filters intersect. Completed and on-hold items are hidden by default; inspect history and filters where needed. Check whether tasks is present, clear unrelated conditions, select the intended project and restore filters one at a time. Zero matches do not establish completion, blockage or an empty source. Missing task status is not inferred from code activity.


<a id="faq-radar-freshness-clock"></a>
## How do I distinguish source read time, a cache hit and a refresh just requested on my phone?

date_str records the last successful source read in UTC+08:00, not a phone request time or a cache hit. source_refreshing/source_refresh_failed signal an in-flight or failed source read. The phone retains its previous snapshot and can make one no-cache follow-up, not a polling loop. Data older than 24 hours is stale; a source clock over five minutes ahead triggers a warning. The optional adapter's 30-second/five-minute cache is a separate layer, not a phone refresh SLA.


<a id="faq-watch-snapshot-handoff"></a>
## Does a watch project summary or sync acknowledgment prove that the ledger refreshed or the phone handled an item?

A paired Watch receives pending decision/acceptance summaries from the phone's existing snapshot, with source age, read failures and reachability. A sync request republishes that snapshot rather than refreshing the source ledger. queued means queued; saved means a proposal was safely persisted on the phone. Neither proves an opened page, a submitted reply or a handled task. Final confirmation and readback still belong to the iPhone and authorized service path.


<a id="faq-radar-capability-planes"></a>
## Why does reading task JSON or a watch summary not imply permission to reply or receive task pushes?

JSON GET, reply-write authorization and notification event sources are separate capability planes. A readable snapshot or reply_supported flag does not replace server identity, target permissions, explicit phone confirmation and readback. A GET feed is not a push event stream. Notifications need an authorized upstream, device subscription and matching signing/system conditions; direct Watch writes retain a separate authorization gate. This candidate claims neither production delivery nor automatic status changes.


Related reading: [Get started](https://getyihu.com/en/start/) · [Privacy](https://getyihu.com/en/privacy/) · [Mobile decisions](https://getyihu.com/en/guides/mobile-agent-decisions/)
