---
layout: ../../../layouts/Wave3Guide.astro
title: "Why fields differ across phone, Watch, web and attachments"
description: "Compare phone ledgers, Watch pending summaries, web drafts and text attachments with source-time, truncation and target checks. No full-field synchronization or identical-permission promise."
lang: en
---

<h2 id="syn-xdev-38">SYN-XDEV-38: field subsets, defaults and clipping</h2>

SYNTHETIC_EXAMPLE: memory bridge/codec and source expressions, not real pairing, sync or delivery.

[ZH: /samples/p17-cross-device-fields/cross-device-fields-preflight.zh.json](/samples/p17-cross-device-fields/cross-device-fields-preflight.zh.json) · [EN: /samples/p17-cross-device-fields/cross-device-fields-preflight.en.json](/samples/p17-cross-device-fields/cross-device-fields-preflight.en.json) · [Card: /samples/p17-cross-device-fields/preflight-card.md](/samples/p17-cross-device-fields/preflight-card.md)

<div role="region" aria-label="Synthetic cross-device fields, defaults and clipping table; horizontally scrollable" tabindex="0">

| Case | Synthetic condition / 合成条件 | Scoped expectation / 范围内结果 | Not certified / 未证 |
| --- | --- | --- | --- |
| P1 | Full phone tasks differ from Watch pending subset | {'item_count': 1, 'truncated': False, 'phone_all_count': 3} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P2 | Field prefixes clipped while truncated flag remains false | {'item_count': 1, 'title_characters': 160, 'project_characters': 80, 'next_characters': 600, 'truncated': False} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P3 | Extended-grapheme prefix is not UTF8 bytes | {'item_count': 1, 'title_characters': 160, 'project_characters': 80, 'next_characters': 600, 'title_utf8_greater_than_characters': True, 'truncated': False} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P4 | Explicit empty tasks does not fall back to decisions | {'item_count': 0, 'phone_all_count': 0} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P5 | Missing legacy tasks falls back to decisions | {'item_count': 1, 'phone_all_count': 1} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P6 | Trim/mention attention differs from exact Watch status | {'item_count': 0, 'phone_attention_count': 2} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P7 | Nil/empty IDs skipped; whitespace ID is not empty | {'item_count': 1, 'first_task': ' '} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P8 | 201 source rows do not guarantee200 transmitted | {'within_200_items': True, 'truncated': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P9 | Byte budget trims before200 and preserves prefix order | {'item_count_less_than_input': True, 'truncated': True, 'first_task': 'syn-0'} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P10 | New capturedAt cannot fill missing sourceDate | {'item_count': 1, 'source_date_missing': True, 'stale': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| P11 | Cached display with read failure is stale | {'item_count': 1, 'read_failed': True, 'stale': True} | Fake store/workbench/WCSession sink; no paired-device transfer |
| D1 | normal | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D2 | bytes_exact | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D3 | bytes_over | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D4 | rows200 | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D5 | rows201 | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D6 | duplicate | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D7 | invalid_uuid | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D8 | uppercase_token | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D9 | missing_next | shared codec accepted=False | Host JSON codec only; not a received device packet |
| D10 | long_title | shared codec accepted=True | Host JSON codec only; not a received device packet |
| D11 | invalid_status | shared codec accepted=False | Host JSON codec only; not a received device packet |
| F1 | next=''; priority=None | label='下一步待补'; priority predicate=False | Extracted expressions, not pixels/localization/full SwiftUI |
| F2 | next=' '; priority=' ' | label=' '; priority predicate=True | Extracted expressions, not pixels/localization/full SwiftUI |
| F3 | next='SYNTHETIC_EXAMPLE: pending verification'; priority='P1' | label='SYNTHETIC_EXAMPLE: pending verification'; priority predicate=True | Extracted expressions, not pixels/localization/full SwiftUI |
| F4 | next=''; priority='' | label='下一步待补'; priority predicate=False | Extracted expressions, not pixels/localization/full SwiftUI |
| B1 | Web draft/text attachment is not ledger mirror or original audio | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B2 | queued/ready is not phone draft/web insertion/send receipt | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B3 | Local fingerprints/canDraft do not replace authentication/authorization | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |
| B4 | Screen line wrapping/layout and real pairing not executed | source/manual review; runtime not_run | No carrier sync, auth or business delivery receipt |

</div>

Watch title/project/next use160/80/600 Swift characters, not UTF8 bytes. Field clipping may coexist with truncated=false; that flag covers row/byte pruning, not every prefix.50000 bytes/200 items are upper bounds, not200 guaranteed transmitted. Missing required next rejects decode; empty string uses the placeholder, whitespace is not auto-filled and no source is rewritten. capturedAt is not sourceDate; queued/ready is not draft persistence/web insertion/server send. Web drafts/attachments are not full-ledger mirrors. Verify destination storage/sync and authorization separately; do not invent absent fields or blindly resend. Real pairing/layout/ASR/handoff are all not_run.

<h2 id="first-answer">Different carriers are not full replicas; fewer fields do not prove loss or completion</h2>

Phone Radar, paired Watch summaries, web drafts and share attachments have different data/permission boundaries. Watch receives the phone's existing pending decision/acceptance summaries and may truncate them. Web drafts/attachments contain selected text, not a phone-ledger mirror. Start with carrier, source identity and collection, then compare time/fields. Similar appearance is not full synchronization or independent refresh.

## Separate from batches and format revisions

Batch comparison inspects two exports from a source; compatibility review inspects producer changes. Here **different carriers in one workflow intentionally present different scopes**. Missing fields may reflect selection, truncation, absent data or no handoff, rather than sync failure. Do not fabricate values to make screens agree.

## Cross-device field and scope matrix

<div role="region" aria-label="Cross-device fields and truncation, scroll horizontally" tabindex="0">

| Carrier/field | Current scope | Check | Do not infer |
| --- | --- | --- | --- |
| Phone tasks/decisions | Ledger versus pending subset; legacy fallback | Whether tasks exists and current view/filter scope | Few pending items means few ledger tasks |
| Watch items | Paired-phone pending summaries | Source time, read failures, reachability and truncation | Full ledger or independent source refresh |
| Watch title/project/next | Bridge prefixes up to 160/80/600 characters | Return to phone for full text before deciding | Every field complete or characters equal bytes |
| Watch payload | Decode limit 50000 bytes and 200 items; bridge can trim further | Inspect truncated/more-on-phone signals | Guaranteed delivery of 200 items or deletion implied by trimming |
| Source/capture time | sourceDate differs from capturedAt | Judge freshness using source time | Fresh packaging proves a new successful source read |
| Target identity | workbench/task and protected source/item markers | Existing phone checks resolve originals | Markers are account authentication or direct Watch-write authority |
| Web draft | Selected text in an unsent destination | Actual workbench/page/draft contents | Automatic Radar field update or a sent reply |
| Text attachment | Tray text/Markdown, without original audio | Actual version and later handoff/upload stage | Full ledger/audio replica or automatic cross-device updating |

</div>

These are source-level payload/prefix limits, not bandwidth, latency or universal pairing-success results. Swift string prefixes are not UTF-8 byte counts. Total payload size can require trimming before 200 items.

## A synthetic missing-field comparison

```text
Phone: Three sample tasks; one awaits a decision.
Watch: Only that pending summary appears, with shortened next text.
Web: No handoff selected, so no matching draft exists.
Interpretation: Carrier scopes differ; check complete source on the phone.
Not established: Other tasks completed, Watch lost data or web synchronization failed.
```

This is not an actual paired-device trace. It calls no Watch, workbench or server. Preserve unknowns/provenance and minimize private material; do not publish task text, feed addresses or protected identity markers.

## Review order

Establish the same source/item first, then each carrier's collection and permission scope. Inspect `sourceDate`, failure and truncation rather than counting display rows. Continuing on the phone or replying still requires target/busy checks, phone confirmation and server authority; Watch visibility cannot bypass them.

Editing a web/local draft does not automatically update source JSON or staged attachments. This comparison adds no sync repair, field converter or cross-device write tool.

## FAQ

<h3 id="faq-complete">Should Watch display every phone tasks field?</h3>

No. It carries pending summaries rather than the full source ledger, with possible field/count truncation. Return to the phone for full context.

<h3 id="faq-truncate">Does shortened next prove deleted source text?</h3>

No. Prefix and total-size limits can shorten presentation without deleting or changing the original.

<h3 id="faq-captured">Does a recent capturedAt establish a refreshed ledger?</h3>

No. Packaging and source time differ. Sync can republish an existing phone snapshot without an independent source read.

<h3 id="faq-token">Do source/item markers permit standalone Watch approval?</h3>

No. They protect target checks, not account/server write authority or phone confirmation. This page offers no marker construction/bypass method.

<h3 id="faq-attachment">Does Markdown contain original audio and all tasks?</h3>

Not as a general statement. Current note sharing is text/Markdown without original audio, not automatically a ledger snapshot.

<h3 id="faq-sync">Does editing a web draft write back to Radar?</h3>

No such sync is asserted. Check web text, phone source JSON and attachments separately. No bidirectional field sync/writeback is added.

## Guides and source

[Radar/Watch](/en/guides/multi-project-radar-watch/) · [Format compatibility](/en/guides/brief-format-change-compatibility/) · [Originals and handoff](/en/guides/recording-notes-handoff/) · [Follow-up evidence minimization](/en/guides/followup-evidence-minimization/) · [Start](/en/start/) · [Privacy](/en/privacy/)

Evidence: [Watch payload model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Shared/YihuWatchSnapshot.swift), [phone bridge/trimming](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieWatchPhoneBridge.swift), [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md).
