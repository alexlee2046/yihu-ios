---
layout: ../../../layouts/Wave3Guide.astro
title: "Why fields differ across phone, Watch, web and attachments"
description: "Compare phone ledgers, Watch pending summaries, web drafts and text attachments with source-time, truncation and target checks. No full-field synchronization or identical-permission promise."
lang: en
---

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
