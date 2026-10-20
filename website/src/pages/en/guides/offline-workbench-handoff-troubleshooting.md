---
layout: ../../../layouts/Wave3Guide.astro
title: "Transcribed offline but not delivered? Diagnose weak-network handoff and Radar cache"
description: "Separate prepared models, web access, attachment staging, task JSON cache and real replies. Use source times and uncertain-stop rules rather than treating visible cards as refresh or delivery receipts."
lang: en
---

<h2 id="first-answer">Offline is not a global switch: identify the step with evidence</h2>

Prepared local models, recording notes and existing Radar snapshots have local paths, while model downloads, HTTPS pages, attachment handoff and service replies have separate network/permission requirements. Completed transcription only establishes text for that processing step; visible cards only establish a displayable snapshot. Record layered states such as “local complete, remote unknown” rather than calling the entire workflow offline-successful or failed.

## A minimal non-destructive diagnostic sequence

Identify the current workbench, page and data source first; retain originals and existing state. Use only synthetic content without business meaning. Do not disconnect another person's network, delete cache, reset accounts or send test replies to real tasks. After an uncertain write, use the original request identity for readback rather than creating another request to test sending.

## Network and state layers

<div role="region" aria-label="Offline and weak-network state layers, scroll horizontally" tabindex="0">

| Step | Existing evidence or field | Still check | Stop/retention boundary |
| --- | --- | --- | --- |
| Model preparation | Downloaded, verified compatible model | Actual availability, permission/resources; downloaded once is insufficient | Stop if missing; no verification bypass or offline-recognition promise |
| Local notes | Phone audio/text with pending/failed/completed state | Calls, storage, input changes and eligible foreground processing | Retain originals and inspect joins; no lossless guarantee |
| HTTPS page | Actual phone access result | Phone reachability, trusted TLS, login and editor compatibility | Do not disable TLS checks, expose private sources or weaken permissions |
| Draft insertion | Unsent text at the intended destination | Captured/current page, host refusal and busy state | Inspect existing insertion; no blind retry on uncertainty |
| Attachment staging | Text/Markdown in the share tray | Whether a later user handoff happened and the host uploads first | Staged is not uploaded; unsent is not proof of no upload |
| Radar source | date_str, source_refreshing, source_refresh_failed | Source identity and last successful read time | Retain old data with failure/age indication; do not replace time with now |
| Radar collection | tasks ledger versus decisions pending subset | Project/status/search/history intersection | Zero matches do not prove no tasks; inspect filters, do not edit the ledger |
| Real reply | Saved request_id, server receipt or uncertainty | Separate write permission, phone confirmation, original target/readback | Do not resend with a new ID; receipt is not handling/execution |

</div>

## Visible cards after a failed refresh

`date_str` records the last successful source read and is parsed as UTC+08:00 by the current model. A phone request or cache hit cannot replace it with now. `source_refreshing` and `source_refresh_failed` distinguish in-flight reading from failure. The client marks sources older than 24 hours stale and warns when the source clock is over five minutes ahead. These freshness signals do not infer that tasks are paused, blocked or complete.

The optional read-only adapter's 30-second fresh/five-minute old cache is a separate request-triggered server policy, not every source's polling interval or a phone-refresh SLA. The client's existing single `no-cache` follow-up is not perpetual polling. This guide adds no scheduler, cache database or private-ledger service.

## Three practical branches

**Text exists but the web page does not open.** Record recognized text and web connectivity separately. Retain the local original; inspect the phone's existing authorized network, TLS and service without relaxing security. Once access returns, inspect destination content first rather than assuming the earlier write did not happen.

**Radar shows an old date and filters return zero.** Check whether `tasks` exists. Legacy sources without it fall back to a pending subset with an incomplete-scope notice. Then check project, status, priority, search and history. An old source and an empty filtered collection are different problems, not explanations for each other.

**Timeout after confirmation.** A timeout is not proof of no write. Preserve pending information and follow the existing request identity/uncertain-result path. Do not change sources, clear markers or create a request to bypass a frozen state. Even a recorded reply is not proof of a changed task status or completed handling.

## FAQ

<h3 id="faq-offline-model">Does a previously downloaded model guarantee offline transcription?</h3>

No. Verify the actual version's compatible model is available and checked, with permission/resources ready. Model preparation, audio capture and recognition remain distinct; there is no arbitrary device/language/performance guarantee.

<h3 id="faq-timestamp">Why is date_str old after I just refreshed?</h3>

A phone request is not a successful source read. The contract preserves source time; cache hits and failures do not make it current. Inspect refreshing/failure indicators alongside old cards.

<h3 id="faq-source-login">Why can native Radar fail while the web page is logged in?</h3>

They are separate sessions. Native JSON does not reuse web cookies, store source credentials or follow redirects. Use the documented authorized file-export path for authenticated feeds; do not put credentials or tokens in URLs.

<h3 id="faq-upload">Does staged Markdown prove the server received it?</h3>

No. Staging, later user handoff, attachment upload and message submission are separate. The text attachment excludes original audio, and a host may upload before sending a message.

<h3 id="faq-uncertain">Can I retry a timed-out receipt with a new request_id?</h3>

Do not retry blindly that way. Preserve the original identity and frozen/readback boundary. New IDs can create duplicate writes; this guide offers no end-to-end exactly-once guarantee.

<h3 id="faq-watch-refresh">Does successful Watch sync prove a refreshed ledger?</h3>

No. Sync republishes the phone's existing snapshot. queued and saved establish only their transport/persistence stages. Source refresh, phone confirmation and service readback need their own evidence.

## Reading and evidence

[Bluetooth input troubleshooting](/en/guides/bluetooth-audio-input-troubleshooting/) · [One recording-note handoff](/en/guides/recording-notes-handoff/) · [Radar and Watch](/en/guides/multi-project-radar-watch/) · [Mobile decisions and age](/en/guides/mobile-agent-decisions/) · [Meeting/brief fields](/en/guides/meeting-notes-brief-fields/) · [Privacy](/en/privacy/) · [Start](/en/start/)

Source: [README](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/README.md), [Radar model](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarModel.swift), [source reads/cache](https://github.com/alexlee2046/yihu-ios/blob/a59676a72c1931bb36dc29ef0810b5e6dc9339ea/Apps/Collie/CollieRadarStore.swift). These are synthetic diagnostic illustrations, not real source connections or writes.
