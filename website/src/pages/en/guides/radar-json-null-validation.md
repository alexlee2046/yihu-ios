---
layout: ../../../layouts/Wave3Guide.astro
title: "Before a trade brief reaches PM Radar: JSON types, nulls and missing fields"
description: "Check required strings/arrays, optional nulls, tasks fallback and source times against the general PM Radar contract. Authorized task-data interpretation, not a trade feed or import converter."
lang: en
---

<h2 id="first-answer">Valid JSON syntax does not establish model decoding or complete business data</h2>

First verify that a file is an authorized export from your own ledger, then check syntax, model types, post-decode validation and business meaning. Yihu reads the existing PM Radar snapshot contract, not arbitrary trade briefs. Missing fields, explicit `null`, empty strings and empty arrays are not interchangeable. This synthetic example explains the contract without connecting to a real source, converting minutes or enabling replies.

## Four checks, not one valid-JSON label

1. **Syntax**: parsable brackets, quotes and literals are only the first layer.
2. **Model types**: required strings/arrays and optional fields must match Swift Codable declarations. Stringified numbers and empty objects cannot substitute freely.
3. **Post-decode validation**: source date must parse and input is bounded to 2 MiB. Nonempty project/title values, project records, identities and timestamps have additional source checks.
4. **Business scope**: completeness, old cache, filtering, permission and evidence still need review. Parsing does not prove truth, freshness or write authority.

## Fields, nulls and empty collections

<div role="region" aria-label="Radar JSON fields and null checks, scroll horizontally" tabindex="0">

| Location | Model shape | Missing/null/empty distinction | Review rule |
| --- | --- | --- | --- |
| date_str | Required String, then a parsable source time | Missing/null fail required type; empty/invalid date fails later validation | Use the last successful source read, not a refresh-tap time |
| decisions | Required Action array | [] is a supplied empty subset; missing/null are not empty arrays | Empty pending scope is not proof of no ledger tasks |
| active/stale/cold | Three required Project arrays | [] means that collection is empty; projects cannot replace the three keys | Combined projects is a computed property, not an alternate import key |
| tasks | Optional Action array | Missing/null fall back to decisions; [] is an explicitly empty ledger and does not fall back | Distinguish incomplete legacy scope from supplied empty full scope |
| Action.project/title | Required String, validated as nonblank | Missing/null/numbers fail type; whitespace fails validation | project belongs to source identity, not guessed display names |
| Action.next/url | Required String | Missing/null fail type; a string does not establish authority or safe navigation | Decodable text is not an executable command or URL certification |
| Action.status/id/priority/timestamp and others | Optional String or Double, per field | Optional fields can be absent/null; wrong types are not unknown values | Keep absent status unknown; task timestamp is not source date_str |
| Project.name/path/timestamp/message | Required String/String/Double/String | Name/path must be nonblank; timestamp must fit source numeric bounds | Do not replace null time with now; message does not grant writes |
| reply_supported/source_refreshing/source_refresh_failed | Optional Bool | Missing/null do not establish true; string true is not Bool | Readability, refreshing and write authority remain distinct |

</div>

## Minimal synthetic example: optional nulls and required arrays

```json
{
  "date_str": "2026-10-18 09:00",
  "decisions": [],
  "active": [],
  "stale": [],
  "cold": [],
  "tasks": [
    {
      "id": "sample-check-1",
      "project": "sample",
      "status": null,
      "priority": null,
      "timestamp": null,
      "title": "Check synthetic brief fields; take no action",
      "next": "Inspect source and types only; send no reply",
      "url": "https://example.invalid/tasks/sample-check-1"
    }
  ],
  "reply_supported": false,
  "source_refreshing": false,
  "source_refresh_failed": false
}
```

The fixed date is historical demo data, not fresh because this page was published. Links use reserved `example.invalid`, with no reachable service. A record in `tasks` does not force this example to include project-activity records; those arrays express different information. `status: null` means no status supplied, not completed or blocked. `reply_supported: false` claims no write support; even true would not grant server permission.

Compare three variations: `"tasks": null` falls back to the pending subset; `"tasks": []` does not; a null/numeric `title` is not a valid unknown title. This page supplies no command to modify a real ledger and does not call example checks a completed Swift/device import.

## Repair at the source, not by hiding a failure

Do not turn an empty failed response into “all complete,” or relabel copied old data with a fresh date to produce cards. Missing `tasks` requires an incomplete-scope interpretation; supplied `tasks: []` still needs export-scope, permission and business checks. Extra unknown keys do not replace required keys, and JSON syntax tools do not verify read/write permission.

For inquiry/follow-up data, use the team's existing authorized export workflow. This page adds no customs/market API, lead scraper, automatic email, minutes-to-task conversion or universal JSON service. Text fields are not instructions authorizing an Agent to execute.

## FAQ

<h3 id="faq-null-vs-empty">Why do missing tasks, null and [] differ?</h3>

Absent/null optional arrays mean not supplied, so the current model falls back to `decisions`. An empty array explicitly supplies empty full scope. Legacy readability does not prove completeness.

<h3 id="faq-optional">Can optional fields use any type?</h3>

No. Optional permits absence/null, not replacement of String, Double or Bool constraints. A number encoded as text is not automatically a valid unknown value.

<h3 id="faq-time">Can unknown time be replaced with now or zero?</h3>

Do not fabricate source time. Optional task timestamps differ from required source `date_str`; required project times/dates belong to the source. A parsable value alone does not establish freshness.

<h3 id="faq-projects">Can a projects array replace active/stale/cold?</h3>

No. `projects` combines those three arrays as a computed model property. It cannot supply missing required import arrays; task-project/project-path meaning still needs review.

<h3 id="faq-validator">Do passing page example checks establish app import acceptance?</h3>

No. Frontend/example checks do not replace actual-version Swift decoding, file limits, device acceptance or source permission verification.

<h3 id="faq-brief">Can the editorial minutes template be imported as a trade Radar brief?</h3>

No. Editorial labels and the Radar model are different contracts. Use an existing authorized export workflow; no converter, data feed or write authority is added here.

## Guides and implementation

[Radar and Watch](/en/guides/multi-project-radar-watch/) · [Weak-network/cache diagnosis](/en/guides/offline-workbench-handoff-troubleshooting/) · [Editorial minutes/brief fields](/en/guides/meeting-notes-brief-fields/) · [Multiple-note/to-do review](/en/guides/multi-note-review-handoff/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [Radar model/decode validation](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [source reads/cache](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift), [README source/reply boundaries](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
