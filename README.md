# Yihu for iOS

An independent native iOS companion for your own [Collie](https://github.com/AltanS/collie) workbench. Includes a WebKit shell, native voice transcription, a share extension and Live Activity UI. This is a source release, not an App Store binary or an official Collie client.

## Build locally

Requires macOS, Xcode with the iOS 18 SDK or newer and Swift 6, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

1. In `project.yml`, replace `YIHU_BUNDLE_ID` and `YIHU_APP_GROUP` with unique identifiers registered to **your own** Apple developer team. Set `DEVELOPMENT_TEAM` to your own team ID. The main app and share extension must use the same App Group.
2. Run `xcodegen generate --spec project.yml` in this directory.
3. Open `Yihu.xcodeproj`, select the `CollieiOS` scheme and your device, and configure signing for all three targets with your own team. Enable App Groups and Push Notifications using your own provisioning. Push capability may require a paid Apple Developer membership.
4. Build and run in Xcode. No signing identities, profiles, APNs keys, server credentials or prebuilt app are included. Do not commit your signing configuration.

All Swift imports are Apple SDK modules. The required third-party Swift inference source is vendored with its license; there is no dependency on the original private workspace or a local Swift package.

## Connect to your own workbench

On first launch, enter your own HTTPS Collie origin, such as `https://collie.example.com`. No workbench is preconfigured. The validator accepts only an origin: no user/password, path, query or fragment. The iPhone must be able to reach your server and trust its TLS certificate. Authenticate/pair with your server as required; the app does not bypass Collie's permissions.

Native notifications require the web bridge `window.collieNativePush.request(operation, payload)` for `status`, `register` and `unregister`, matching native-push server endpoints, and an APNs provider configured for **your app's bundle ID and signing environment**. APNs private keys belong on your server, never in this app repository. Stock Collie v1.19.2 does not expose this APNs extension or a public native-notification delivery adapter. Settings checks the optional capability without asking for notification permission or registering a device; a missing bridge is shown as unavailable. Existing bindings are retained so they can be explicitly disabled or reused with a compatible origin. No relay, provider credentials or server patches are created automatically. Web access and native notification support are different capabilities.

Voice insertion does not require a Collie fork. The optional `collie:native-transcript` host event is tried first; an observed refusal never falls through. Without a handler, a native-injected adapter edits only the field the user last focused on the same page. The stock Collie v1.19.2 DOM adapter requires an editable composer and an unambiguous, unlocked draft-mode control; sending, direct terminal typing and unknown layouts are refused. An incompatible page retains the transcript in the native panel for explicit copy or retry. No insertion path presses Send; transcription should be reviewed before sending. The separate Hermes Live Activity integration is optional and requires a compatible relay you control; its source endpoint is deliberately `https://relay.example.invalid`. Do not enable it without configuring your relay in `CollieHermesPush.swift`.

## Workbenches and PM Radar

Web workbenches and native PM Radar share one header and shortcut bar. Use the grid to manage workbenches and customize shortcut order/visibility. Radar opens with management categories for decisions, acceptance, in-progress and to-do work. Completed/on-hold tasks are hidden by default and available through the history toggle; choosing a historical status enables history. Project, source-status, priority and search filters intersect and persist independently per workbench. Default task ordering is P0 → P1 → P2 → missing/other priorities, then latest source modification within each priority; a bucket with missing timestamps retains source order. Display settings can disable priority-first ordering. Clear filters restores the unfinished scope. Cards emphasize the title, project, status, priority and next step; owner session, window state, evidence and source modification time are expandable details. Missing fields are marked rather than inferred. Overview counts reflect the current filters and open the matching task list. Switching web origins captures native WebKit interaction state per trusted origin in memory, so returning restores the page/history/scroll instead of opening the root again; it does not copy browser state across origins or persist it to disk.

Import a `pm-radar --json` export or configure an HTTPS JSON feed. `tools/serve-radar.py --port PORT --tailnet-host HOST:HTTPS_PORT` is an optional loopback-only, read-only adapter behind your existing access-controlled HTTPS/Tailnet path. Each GET directly runs the existing `req list --all --json` CLI: no server data files, cache, polling or scheduler. It returns HTTP 503 if the ledger is unavailable and never prints task text or raw CLI errors. Host/Origin guards and denied write methods restrict the adapter; HTTPS and network access control belong to your proxy. Do not expose private ledger data publicly. The app retains only its existing local offline cache.

Responses supply optional `tasks` (all non-archived ledger items) alongside `decisions` (only waiting-for-decision/acceptance items). The All tasks and Projects views use `tasks`; Overview and My actions show `decisions`. Task records may include `id`, `priority`, `evidence`, `session` and `window_status` as separate source fields, and an optional Unix task-update `timestamp`. No Git activity is synthesized from task update times. Legacy exports lacking `tasks` remain readable with an incomplete-ledger notice. `date_str` records the last successful source read, never a failed phone fetch.

In Debug builds only, explicitly launching with `YIHU_RADAR_FEED` set to a valid HTTPS feed provisions/selects a matching Radar workbench and refreshes it without replacing unrelated workbenches. This delivery convenience is not enabled automatically and does not embed a feed address.

Authenticated feeds currently require a file export: Radar does not reuse web cookies, store credentials or follow redirects. Snapshots are limited to 2 MiB; failed refreshes retain the last valid snapshot, and changing the feed clears its old cache. Cache reads are bounded to 2 MiB and corrupt files are retained with a recovery message. Duplicate workspace IDs refuse configuration loading without overwriting its original data. Changing a feed is refused if its old cache cannot be cleared, preventing source mix-ups after relaunch. Snapshot dates and record identities/timestamp ranges are validated; future-dated snapshots show a clock warning, and data older than 24 hours is marked stale. Explicit task status values distinguish progressing, waiting, blocked, completed and paused work; project records may optionally supply a `status` string, while legacy feeds remain supported. Project cards show source task statuses, or “Task status not provided” when none exist. Action records may optionally provide a Unix `timestamp` for newest-first sorting; if any matching action lacks a timestamp, newest-first preserves the complete source order. Turning newest-first off sorts action titles alphabetically. Code activity and snapshot age never imply a task is blocked or finished. Radar reads the source task tracker without changing task status. Optional decision/acceptance replies require separately enabled write authorization, as described below.

### Apple Watch companion (#31)

`YihuWatch` is a watchOS 11+ companion using the phone's existing WatchConnectivity pairing. It receives only pending decision/acceptance summaries, without feed URLs, credentials or reply drafts. Lists/details show source read times, stale/failed reads and phone reachability; oversized payloads are trimmed with an explicit more-on-phone notice. Sync requests transfer the phone's existing snapshot, not pretend to refresh the ledger. A selected item queues a phone handoff; the phone resolves the original workbench/task and respects its existing busy and reply-sheet guards. It opens read-only details, never sends replies or changes status from the watch.

Build the `YihuWatch` scheme with a generic watchOS Simulator destination and `CODE_SIGNING_ALLOWED=NO`. The existing `ios.yml` workflow has a `watch_only=true` dispatch for native checks, watch/phone builds and a synthetic watch screenshot; it skips the previously accepted legacy UI scenarios. `YIHU_WATCH_DEMO=1` is Debug-only synthetic UI evidence, not proof of pairing. No watch signing/profile changes or physical install are performed without separate approval.

Watch proposal input (#32) uses the system TextField keyboard/dictation UI and a protected local draft. Transfer shows the whole proposal and retains its UUID after uncertain transport; the phone checks source/task fingerprints and refuses busy UI or another existing draft. It acknowledges only a safely persisted phone proposal. The phone's existing reply form fetches fresh metadata and requires another explicit confirmation to write. Missing/older capabilities remain view-only. This is not direct watch reply authorization.

Direct watch replies (#33) require separate confirmation of the paired-device write authorization and must retain #30's target/readback/idempotency boundaries; this entry remains closed pending that decision. The watch notification page (#34) reports phone notification state and system mirroring prerequisites, without requesting permissions. A live-ledger GET feed is not a push event source: PM task reminders remain unavailable until an authorized upstream supports them. Existing workbench notification mirroring is conditional on phone/service/system support, not evidence of delivery. No independent watch APNs, new notification backend, polling relay or automatic execution is enabled.

### Optional decision and acceptance replies

The adapter remains read-only unless explicitly started with `--writer-user-id USER_ID`. Bind only an authorized personal Tailscale identity. The loopback listener trusts Serve's injected `Tailscale-User-Login` header; Serve strips spoofed values. Tagged or unrecognized identities cannot write. Funnel must remain disabled; the adapter checks the current private Serve configuration. POST requests with browser Origin/Fetch headers are refused even from the Collie origin, and require native JSON intent. No GitHub credential is copied to the phone.

For eligible decision/acceptance items, the phone reads fresh target metadata, shows the original title/link/status/next step and complete reply in a second confirmation form, then posts only on explicit Send. The server restricts targets to the configured private Project and writable private Issues or DraftIssues. It uses the existing `req note` CLI and its private-project/repository/sensitive-text guards; reply text is piped in, not put in process arguments or logs. It never changes status, creates a requirement, merges or deploys.

A reply UUID and body digest are recorded on the original comment/draft. Receipt lookup paginates all comments before deciding whether a reply exists. The phone preserves unsent drafts and persists pending requests before submission with file protection and backup exclusion. Uncertain results freeze input and require readback rather than blind retries. A bounded in-memory set remembers attempted UUIDs/digests (not ledger data or reply bodies); if an attempt is unresolved, a missing comment is not treated as proof of no write. After a server restart, unresolved requests remain unknown unless a durable receipt is found. Source/task changes require a new confirmation. Resolve local drafts/pending results before changing the source or deleting the workbench.

Run the standalone model/persistence checks from this directory:

```sh
swiftc -swift-version 6 Apps/Collie/CollieRadarModel.swift \
  Apps/Collie/CollieRadarStore.swift Tests/CollieRadar/ModelChecks.swift \
  -o /tmp/yihu-radar-checks
/tmp/yihu-radar-checks
```

The `CollieUITests` scheme test target exercises both web and Radar navigation using a synthetic `.invalid` origin and creates a Radar workbench if needed. Run it only on an isolated simulator installation, not against your saved device workbenches. The `Yihu iOS acceptance` workflow runs the model checks, builds the independent app/extensions/test target, and exercises light, dark and accessibility text sizes on a standard hosted macOS runner. Its artifacts contain synthetic-data screenshots and test results, not device or signing evidence. Physical-device acceptance is separate.

## Models and limitations

Qwen3 ASR model files are **not** in the repository. Download them through the app's model screen (Hugging Face or ModelScope); the app verifies pinned SHA-256 hashes. Model downloads need storage, bandwidth and a capable device.

WeSpeaker and CAM++ speaker-verification artifacts are deliberately omitted. Code loads these resources dynamically and reports missing models rather than bundling private/generated artifacts. Speaker enrollment/verification and any voice-insertion path requiring a verified speaker will not be available without compatible models. Do not disable verification to work around missing assets. See `Apps/Collie/ThirdPartyNotices.txt` and `Vendor/CAMPlus` for provenance. Core ML conversions must match the pinned hashes in the source; upstream weights alone are not a drop-in replacement.

The independent checkout has passed a Debug iOS Simulator app/extension build and standalone Radar model/persistence checks. Remote UI acceptance is recorded on the pull request; a workflow definition alone is not a passing result. No physical-device push, voice insertion or full regression result is claimed. Some UI strings remain Chinese.

## License

Original Yihu code: [Apache License 2.0](LICENSE). Third-party code retains its own license and notices; see [NOTICE](NOTICE) and the bundled acknowledgements. Collie server code, other products, model binaries, user recordings and private repository history are not included.
