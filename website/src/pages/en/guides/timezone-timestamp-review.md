---
layout: ../../../layouts/Wave3Guide.astro
title: "Review brief timestamps across timezones: source, task and carrier clocks"
description: "Separate fixed UTC+08 date_str, Unix task updates, phone requests and Watch packaging. Manual date-boundary checks, not a new timezone converter or refresh SLA."
lang: en
---

## SYN-TZR-52 time and request lifetime preflight

SYNTHETIC_EXAMPLE · pending · not_run. Dates, events, epochs and lifetimes differ.

[/samples/p31-timezone-timestamp-review/README.md](/samples/p31-timezone-timestamp-review/README.md) · [/samples/p31-timezone-timestamp-review/preflight.zh.json](/samples/p31-timezone-timestamp-review/preflight.zh.json) · [/samples/p31-timezone-timestamp-review/preflight.en.json](/samples/p31-timezone-timestamp-review/preflight.en.json)

<div role="region" aria-label="SYN-TZR-52" tabindex="0">

| ID | Check | Expectation/boundary |
| --- | --- | --- |
| D01 | Fixed UTC+08 | parse=true; 2026-10-18T01:00:00Z |
| D02 | Previous UTC date | parse=true; 2026-10-17T16:30:00Z |
| D03 | Valid leap day | parse=true; 2024-02-28T16:00:00Z |
| D04 | Invalid leap day | parse=false; reject, no repair |
| D05 | ISO is not source format | parse=false; reject, no repair |
| D06 | Offset suffix differs | parse=false; reject, no repair |
| D07 | Non-padded format | parse=false; reject, no repair |
| D08 | Extra seconds | parse=false; reject, no repair |
| D09 | Minute out of range | parse=false; reject, no repair |
| D10 | Hour24 roundtrip differs | parse=false; reject, no repair |
| D11 | No whitespace repair | parse=false; reject, no repair |
| D12 | Fixed offset not device DST | parse=true; 2026-03-07T18:30:00Z |
| W01 | Source versus packaging | Date JSON source=813978000; captured=813978060; reference2001 seconds |
| W02 | Date boundary same instant | Date JSON source=813947400; captured=813947520; reference2001 seconds |
| W03 | New package not new source | Date JSON source=813978000; captured=814064400; reference2001 seconds |
| W04 | Unix zero is not Date zero | Date JSON source=-978307200; captured=813978000; reference2001 seconds |
| W05 | Date zero is2001 | Date JSON source=0; captured=813978000; reference2001 seconds |
| W06 | Unknown source not package time | Date JSON source=unknown/omitted; captured=813978000; reference2001 seconds |
| S01 | No request | consume=[false]; pending=false |
| S02 | Immediate one-time consume | consume=[true, false]; pending=false |
| S03 | One ms before endpoint | consume=[true]; pending=false |
| S04 | Inclusive30s endpoint | consume=[true]; pending=false |
| S05 | After endpoint expires | consume=[false, false]; pending=false |
| S06 | Repeat refresh not N-queue | consume=[true, false]; pending=false |
| M01 | Identify the event first | Source read, task update, phone request, Watch packaging and file edit are distinct; never replace source time with now. |
| M02 | Explicit offset and format | Original date_str uses fixed Gregorian/POSIX UTC+08 with exact roundtrip, not phone zone/DST; UTC display does not authorize ISO source rewrites. |
| M03 | Seconds milliseconds and Date epoch | Task Unix seconds, default JSONEncoder Date reference2001 and ContinuousClock relative Duration differ; no digit-count /1000 repair or cross-domain subtraction. |
| M04 | Freshness thresholds are not SLA | 24h stale/>5m future are source-only here; isOutdated/isFutureDated/stale are not run, not refresh/response/business-deadline promises. |
| M05 | Consumption is not capture | Inclusive30s belongs to original request center; Intent return/Bool consume proves no foreground/system binding/permission/capture/insertion/send. |
| M06 | Preserve originals and stop | Synthetic only, no source fetch/current-time masking/rename-or-unit bypass. Preserve unknowns/reservations; destinations may sync, no blind retry. |

</div>



<h2 id="first-answer">Identify the event before comparing timezone, units and ordering</h2>

Current Radar parses `date_str` using fixed `yyyy-MM-dd HH:mm` in UTC+08:00. Last successful source read cannot be replaced with a phone request, cache hit or file modification. Optional task `timestamp` is a separate Unix-time field; Watch `sourceDate` and `capturedAt` also differ. Establish event/contract first instead of treating all times as equivalent numbers.

## Different from cache diagnosis and batch comparison

Cache review locates old data/read failures; batch review establishes comparable exports. Here **different time meanings can be compared incorrectly**. No automatic timezone converter, clock repair, scheduling or cross-zone sync is added, and no live source time is rewritten.

## Time meanings and units

<div role="region" aria-label="Timestamp/timezone/unit checks, scroll horizontally" tabindex="0">

| Time/location | Current meaning/contract | Check | Does not replace |
| --- | --- | --- | --- |
| date_str | Last successful source read, fixed UTC+08 format | Exact string, source and successful read state | Refresh tap or exported-file save time |
| Task timestamp | Optional Double, Unix task-update time | Producer units, absence/null and ordering scope | Whole-source read, approval or handling time |
| Phone request | Local event starting a read | New successful source response versus cache | Source update or task modification |
| Watch sourceDate | Source represented by the phone summary | Scope, failures and truncation | Watch packaging or independent refresh |
| Watch capturedAt | Summary packaging time | Inspect separately from sourceDate | New business state or successful source read |
| File/editorial time | Save/copy/edit event | Whether only a copy/document changed | Original business event or source identity |
| Unix seconds/milliseconds | Different units, not interchangeable | Producer/consumer contract | Automatic conversion based on digit count |
| Other-zone presentation | Another display of one instant | Explicit offset, date boundary and applicable rules | Writing local-zone text back as date_str |

</div>

Watch dates use that carrier's Date encoding contract. Do not subtract arbitrary serialized values directly from task Unix fields without verifying format/units. This page supplies no universal timestamp detector.

## Two fixed historical illustrations

```text
A: 2026-10-18 09:00 under date_str's UTC+08 contract
Same instant in UTC: 2026-10-18 01:00 UTC

B: 2026-10-18 00:30 at UTC+08
Same instant in UTC: 2026-10-17 16:30 UTC, on the preceding date
```

These are explicit-offset illustrations, not real/current source data. A UTC display does not authorize appending `Z`, offsets or ISO separators to `date_str`. Its strict round-trip format is not arbitrary ISO8601 acceptance.

## Review sequence

Label the event first: source read, task update, request, packaging or editing. Confirm identity/scope, then format, timezone/offset and unit. If ordering conflicts, inspect absent timestamps, priorities and source-order rules before assuming clock failure or changed task state.

Current source marks source age over 24 hours stale and flags time more than five minutes ahead. These are freshness signals, not response latency, refresh frequency, service SLA or a business deadline. Keep unknown/failed times rather than filling now to hide a warning. Corrections belong to the original maintenance process without bypassing parsing/write authority.

## FAQ

<h3 id="faq-phone-zone">Does another phone timezone change date_str parsing?</h3>

The current model fixes UTC+08 rather than inferring from device location. Keep displayed time and source meaning separate.

<h3 id="faq-iso">Is adding Z or +08:00 automatically more compatible?</h3>

No. The consumer has an exact format/round-trip check. A source-format change needs actual-version compatibility review.

<h3 id="faq-unit">Can a 13-digit value automatically be divided by 1000?</h3>

Do not repair by digit count. Confirm producer contract/field first. Wrong units can be invalid or mean another instant; no automatic coercion is offered.

<h3 id="faq-refresh">Why is source time old after refresh or packaging?</h3>

Request/packaging events differ from successful source reads. Cache can retain an old source time; do not substitute now.

<h3 id="faq-threshold">Are 24 hours and five minutes refresh SLAs?</h3>

No. They are current stale/future-source thresholds, not promised update schedules or task-handling deadlines.

<h3 id="faq-unknown">Can missing time be filled with now to help comparison?</h3>

That fabricates meaning. Keep the gap and confirm at the source instead of presenting old data/edited copies as new facts.

## Reading and source

[JSON types/nulls](/en/guides/radar-json-null-validation/) · [Batch comparison](/en/guides/radar-snapshot-batch-comparison/) · [Cross-device presentation](/en/guides/cross-device-field-presentation/) · [Format compatibility](/en/guides/brief-format-change-compatibility/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [source-date parsing/freshness/sorting](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [Watch date model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/YihuWatchSnapshot.swift).
