---
layout: ../../../layouts/Wave3Guide.astro
title: "Empty fields and display defaults: placeholders must not become source values"
description: "Separate missing values, UI placeholders, sorting fallbacks and capability checks. No fabricated titles, business defaults or automatic source-repair feature."
lang: en
---

## SYN-EFD-43 · Empty fields, placeholders and derived-filter checks

SYNTHETIC_EXAMPLE / SYN-EFD-43: read-only checks, not an App import schema or real customer records. 44 host cases per language test original model/display expressions, not UI pixels, backfill or replies.

- 中文 JSON: [preflight.zh.json](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.zh.json) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.zh.json
- English JSON: [preflight.en.json](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.en.json) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight.en.json
- Bilingual card: [preflight-card.md](https://getyihu.com/samples/p22-empty-field-display-defaults/preflight-card.md) — https://getyihu.com/samples/p22-empty-field-display-defaults/preflight-card.md

### Source values, display, ordering and permission are different

Status and action-card next test trimmed emptiness but preserve nonempty original text. Priority/session/window_status/evidence only test isEmpty: whitespace can remain visible. The continuation detail next uses isEmpty instead of the card's trim predicate. Null evidence and literal 待补 can share a label but are different source values. Chinese source label keys are checked, not English localization or SwiftUI pixels.

P0/P1/P2 rank 0/1/2; all other priorities rank 3, never a source assignment to P2. With newest-first, a missing timestamp preserves original order across its rank group, not a fabricated zero/current time. Explicit tasks: [] remains empty; missing/null tasks can fall back to decisions. Project/status/search/history filters can hide attention hits without proving there are no tasks.

reply_supported == true satisfies only that UI capability condition. The card checks two exact untrimmed statuses and a non-nil id. Even an empty id or nonempty invalid-URL source can satisfy the tested UI predicates: this is not a valid target, source, prepare or server-write authorization, and no bypass is added. Current source, target version/eligible, text and service authorization/send remain separate and not_run. requiresMyAttention trims status or uses localizedStandardContains on next for fixed Alex, not current-login identity or title scanning. A2 can hit attention but fail raw-status button visibility; A7 can hit the getter while default history filtering excludes it.

44 host cases =4 display+8 attention+9 reply gate+9 ordering/filter+14 decode, plus4 read-only boundaries. Missing required title/next are not repaired by labels. JSON Bool decoding is not last wave's APNs NSNumber bridge. No source backfill, identity service or native reason API is added.

<div role="region" aria-label="SYN-EFD-43 field, capability and derived-filter checks, horizontally scrollable" tabindex="0">

| ID | Scope | Synthetic input/mode | Host expectation/read-only boundary |
| --- | --- | --- | --- |
| F1 | Field display expressions | `{"status":null,"priority":null,"next":"","session":null,"window_status":null,"evidence":null}` | `{"status":"任务状态未提供","priority":"优先级待补","card_next":"下一步待补","detail_next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` |
| F2 | Field display expressions | `{"status":" \n","priority":" ","next":" ","session":" ","window_status":" ","evidence":" "}` | `{"status":"任务状态未提供","priority":" ","card_next":"下一步待补","detail_next":" ","session":" ","window_status":" ","evidence":" "}` |
| F3 | Field display expressions | `{"status":"待补","priority":"优先级待补","next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` | `{"status":"待补","priority":"优先级待补","card_next":"下一步待补","detail_next":"下一步待补","session":"待补","window_status":"未提供","evidence":"待补"}` |
| F4 | Field display expressions | `{"status":"进行中","priority":"","next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","session":"","window_status":"","evidence":""}` | `{"status":"进行中","priority":"优先级待补","card_next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","detail_next":"SYNTHETIC_EXAMPLE: unknown owner/deadline","session":"待补","window_status":"未提供","evidence":"待补"}` |
| A1 | Derived attention | `{"status":"等你决策","next":"","title":"synthetic"}` | `true` |
| A2 | Derived attention | `{"status":" 等你验收 \n","next":"","title":"synthetic"}` | `true` |
| A3 | Derived attention | `{"status":"进行中","next":"Alex please review","title":"synthetic"}` | `true` |
| A4 | Derived attention | `{"status":"进行中","next":"alex review","title":"synthetic"}` | `true` |
| A5 | Derived attention | `{"status":"进行中","next":"","title":"Alex in title only"}` | `false` |
| A6 | Derived attention | `{"status":null,"next":"","title":"synthetic"}` | `false` |
| A7 | Derived attention | `{"status":"已完成","next":"Alex","title":"synthetic"}` | `true` |
| A8 | Derived attention | `{"status":"进行中","next":"someone else","title":"synthetic"}` | `false` |
| G1 | UI reply gate expressions | `{"reply_supported":null,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":false}` |
| G2 | UI reply gate expressions | `{"reply_supported":false,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":false}` |
| G3 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":true}` |
| G4 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":""}` | `{"visible":true,"ui_enabled":false}` |
| G5 | UI reply gate expressions | `{"reply_supported":true,"status":" 等你决策 ","item_id":"syn-id","source":"https://synthetic.invalid/radar.json"}` | `{"visible":false,"ui_enabled":false}` |
| G6 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":null,"source":"https://synthetic.invalid/radar.json"}` | `{"visible":false,"ui_enabled":false}` |
| G7 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"","source":"https://synthetic.invalid/radar.json"}` | `{"visible":true,"ui_enabled":true}` |
| G8 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":"not a URL"}` | `{"visible":true,"ui_enabled":true}` |
| G9 | UI reply gate expressions | `{"reply_supported":true,"status":"等你决策","item_id":"syn-id","source":null}` | `{"visible":true,"ui_enabled":false}` |
| S1 | Ordering/filtering | `{"mode":"priority_rank"}` | `["zero","one","two","missing","unknown"]` |
| S2 | Ordering/filtering | `{"mode":"missing_time_stable"}` | `["older","missing","newer"]` |
| S3 | Ordering/filtering | `{"mode":"complete_time"}` | `["newer","older"]` |
| S4 | Ordering/filtering | `{"mode":"priority_off_missing_time"}` | `["older","missing","newer"]` |
| S5 | Ordering/filtering | `{"mode":"priority_exact"}` | `["exact"]` |
| S6 | Ordering/filtering | `{"mode":"attention_project_excludes"}` | `[]` |
| S7 | Ordering/filtering | `{"mode":"attention_alltasks"}` | `["waiting"]` |
| S8 | Ordering/filtering | `{"mode":"explicit_empty_tasks"}` | `[]` |
| S9 | Ordering/filtering | `{"mode":"legacy_fallback"}` | `["waiting"]` |
| D1 | Original decode | `{"mode":"normal"}` | `true` |
| D2 | Original decode | `{"mode":"missing_title"}` | `false` |
| D3 | Original decode | `{"mode":"null_title"}` | `false` |
| D4 | Original decode | `{"mode":"blank_title"}` | `false` |
| D5 | Original decode | `{"mode":"missing_next"}` | `false` |
| D6 | Original decode | `{"mode":"null_next"}` | `false` |
| D7 | Original decode | `{"mode":"empty_next"}` | `true` |
| D8 | Original decode | `{"mode":"missing_priority"}` | `true` |
| D9 | Original decode | `{"mode":"null_priority"}` | `true` |
| D10 | Original decode | `{"mode":"empty_priority"}` | `true` |
| D11 | Original decode | `{"mode":"reply_number"}` | `false` |
| D12 | Original decode | `{"mode":"reply_string"}` | `false` |
| D13 | Original decode | `{"mode":"reply_null"}` | `true` |
| D14 | Original decode | `{"mode":"duplicate_ids"}` | `false` |
| R1 | Read-only manual boundary | `{"review":"Placeholders never backfill source or define business state"}` | `"not_run"` |
| R2 | Read-only manual boundary | `{"review":"Rank fallback/stable missing time is not assigning P2/current time"}` | `"not_run"` |
| R3 | Read-only manual boundary | `{"review":"UI capability/visibility is not prepare or server authorization"}` | `"not_run"` |
| R4 | Read-only manual boundary | `{"review":"Derived attention is not current account/owner recognition"}` | `"not_run"` |

</div>

Pinned source: [Radar model](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarModel.swift) · [UI expressions](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarView.swift) · [reply follow-on boundaries](https://github.com/alexlee2046/yihu-ios/blob/521ca77e1cf5d827617ae8963c2fc4f6cc232b3f/Apps/Collie/CollieRadarReply.swift)


<h2 id="first-answer">A missing-value label may be UI explanation, not supplied business data</h2>

Some task-card branches display status not provided, priority pending or next step pending when fields are empty. These branches do not mean source fields were assigned a default business state, priority or action. Separate raw values from rendering. Do not fill unknowns with confirmed facts to complete a screen. No default-value fixer or source autocompletion is added.

## Different from JSON type validation

JSON guidance checks missing/null/types. Here **rendering, fallback ordering and capability conditions can be mistaken for source contents**. This is not another full schema guide, field editor or blanket equivalence between empty strings and all whitespace.

## Empty values, placeholders and fallbacks

<div role="region" aria-label="Empty-field/display-default checks, scroll horizontally" tabindex="0">

| Location | Existing consumer behavior/boundary | Review | Do not fill/infer |
| --- | --- | --- | --- |
| Required identity/title | Decode checks nonempty project/title and other conditions | Presence, type and nonempty rules | Untitled automatically replaces valid source data |
| status rendering | Blank task-card state can display not provided | Label versus raw status | Missing means planned, done or approved |
| priority rendering | nil/empty can display pending priority | Actual value versus label | Replace with P2/default business priority |
| next rendering | Task card can show pending after trimming empty text | Original, specific control and known gap | Invent action or owner |
| session/evidence | Some missing values display pending/not provided | Whether the source supplied those words literally | Label establishes an owner session or evidence |
| Sort fallback | Unknown priorities have ordering rules | Order is not a field assignment | Low position means source assigned low urgency |
| reply_supported | Explicit true required for this capability condition | Unknown differs from explicit false | Disabled UI means rewrite all missing values as false |
| Empty note transcript | handOff rejects an empty transcript | Original versus UI message | Pass a placeholder as transcription or silently remove gaps |

</div>

Trimming depends on each implementation/control; it is not uniform. Do not generalize one card's condition into universal cleansing. Similar displays do not establish identical raw values.

## Synthetic placeholder versus literal text

```text
A: evidence is null; the card displays a pending label.
B: evidence is literally the pending-label string supplied by the source.
Review: Neither establishes actual business evidence, but source values differ.
Decision: Preserve the distinction; a placeholder screenshot is not the original field. Rewrite no live data.
```

This is not a complete snapshot or actual decoder run. Inspect originals only with existing authorization; no raw-data viewer or public private-source access is added.

## Defaults must not expand conclusions

An editor can label unknowns but must not claim source updates. Identity/required-field/capability failures cannot be bypassed by filling now, empty arrays or familiar priorities.

No text does not prove no meeting occurred. No matching tasks does not prove all tasks completed. A pending label does not promise automatic completion. Retain actual facts/unknowns without deriving business status, authority or resend eligibility from placeholders/order.

## FAQ

<h3 id="faq-source">Does priority pending mean the source saved that string?</h3>

Not necessarily. Inspect the original field rather than treating screenshot labels as raw values.

<h3 id="faq-required">Can an untitled default make a missing title valid?</h3>

Do not fabricate values. The consumer has nonempty identity/title conditions; use the real source-maintenance process.

<h3 id="faq-spaces">Are empty, whitespace and missing identical everywhere?</h3>

No. Parser/control conditions differ. No universal normalization or cleansing guarantee is supplied.

<h3 id="faq-false">Does disabled UI prove reply_supported is explicitly false?</h3>

No. Unknown capability and other permission/source conditions affect availability. Preserve raw value versus UI outcome without writing false.

<h3 id="faq-priority">Can fallback ordering justify filling low priority?</h3>

No. Ordering does not modify source priority or establish business urgency.

<h3 id="faq-notes">Can no-text placeholder text be handed off as transcription?</h3>

Do not do so. Messages are not originals; entry/one-handoff guards remain. Preserve the actual content gap.

## Reading and source

[JSON types/nulls](/en/guides/radar-json-null-validation/) · [Summary provenance](/en/guides/radar-summary-claim-provenance/) · [Cross-device display](/en/guides/cross-device-field-presentation/) · [One note handoff](/en/guides/recording-notes-handoff/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [task-card placeholders](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarView.swift), [decode/sorting](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [empty-transcript guard](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieVoiceNotes.swift).
