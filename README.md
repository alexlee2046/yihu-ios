# 一呼 · Yihu for iOS

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform: iOS 18+](https://img.shields.io/badge/iOS-18%2B-blue.svg)](project.yml)
[![Swift: 6](https://img.shields.io/badge/Swift-6-orange.svg)](project.yml)

Yihu is an independent native iOS browser shell optimized for Agent workbenches, including your own [Collie](https://github.com/AltanS/collie), OpenClaw or Hermes web UI. It adds on-device speech, voice notes and iOS sharing around WebKit; compatible integrations can enable native notifications and Live Activities. It is **not a general-purpose Agent platform**: it does not host Agents, supply a backend or make arbitrary workbenches natively compatible. Yihu is available on the [App Store (verified US listing)](https://apps.apple.com/us/app/yihu/id6819057500): public version **0.1.0**, released **2026-10-19**, requiring iOS/iPadOS **18.0+** (Apple public metadata checked 2026-10-24). Regional availability follows the store. This repository contains source development that may be ahead of that edition; a source merge does not establish a store update or binary feature parity. Yihu is not an official client of those workspace services.

一呼是**针对 Agent 场景优化的原生 iOS 浏览器壳**，用于访问自有 Collie、OpenClaw、Hermes 等网页工作台，并提供端侧语音、录音笔记与系统分享。基础 HTTPS 浏览不等于原生增强已适配；通知、实时活动等需兼容接口与服务。它不是通用 Agent 平台，不托管 Agent、不提供后端，也不承诺任意工作台原生兼容。已上架 [App Store（已核美区页面）](https://apps.apple.com/us/app/yihu/id6819057500)，当前公开版本 **0.1.0**，发布于 **2026-10-19**，需 iOS/iPadOS **18.0+**（2026-10-24 核对 Apple 公开数据，地区供应以商店为准）。商店安装无需 Mac 或自行签名；工作台由用户自备，语音模型按需另行下载，商店说明约 950 MB。仓库包含可能领先商店版的源码开发，合入不等于商店更新或全部功能已在该版发布。仓库不提供预配置服务器，也不是上述服务的官方客户端。

[Build / 构建](#build-locally) · [Connection / 连接](#connect-to-your-own-workbench) · [Limitations / 限制](#models-and-limitations) · [Contributing / 贡献](CONTRIBUTING.md) · [Security / 安全](SECURITY.md)

## Feature overview / 功能概览

### Available in `main` / 已合入主分支

Product source in `main` now includes [PR #3, c76dbd3](https://github.com/alexlee2046/yihu-ios/pull/3). “Available” means source is merged, not that every device/service combination has passed acceptance.
主分支已合入 PR #3；“已合入”不等于所有设备与服务组合都已验收。

| Capability / 功能 | Scope and requirements / 范围与要求 |
| --- | --- |
| Web workbenches / 网页工作台 | WebKit browsing of reachable, trusted HTTPS origins, with per-workbench shortcuts and in-memory navigation state. Login and page compatibility remain the server's responsibility. 支持自有 HTTPS 网页、快捷入口与工作台切换；登录与网页兼容仍取决于服务端，网页导航状态仅在内存保留。 |
| On-device speech / 端侧语音 | Qwen3 ASR with separately downloaded, hash-verified models. Guarded insertion respects explicit host refusal and compatible draft editors; it never presses Send. 模型需单独下载并校验；填入遵守宿主拒绝与草稿编辑器边界，发送前由用户检查，不自动发送。 |
| Voice notes / 录音笔记 | Record longer audio, transcribe in segments on the phone and retain local audio/transcripts. Requires microphone permission and compatible models. 支持长录音、手机分段转写及本地保存；需麦克风权限和兼容模型。 |
| PM Radar / 原生台账 | Per-workbench filters, management counts and bounded offline snapshots; source-read timestamps distinguish cache from fresh reads. 工作台独立筛选、管理计数与有界离线快照，读取时间区分旧缓存与最新来源；需自备 JSON 数据源。 |
| Confirmed replies / 确认后回复 | Eligible decision/acceptance items require separately authorized server writes, explicit confirmation and receipt readback. 决策与验收反馈需服务端独立授权、用户确认及回执核验；不自动改状态或执行任务。 |
| Apple Watch companion / 手表伴侣 | Paired-phone summaries, protected draft handoff and phone-assisted local speech recognition. 配对手机提供摘要、受保护草稿接续及手机端侧识别；手表直写未授权，真机余项仍待验证。 |
| Share inbox / 分享收件箱 | Import text, links and files through the iOS share extension; content is staged in the App Group, not automatically sent. 分享的文字、链接和文件仅暂存 App Group，不自动发送。 |
| Live Activities / 实时活动 | Widget extension and optional Hermes relay integration; requires a compatible relay you control. The placeholder endpoint is intentionally unusable. 需自有兼容中继；占位地址不可用，不代表通知链已开通。 |
| Speaker verification / 声纹验证 | Enrollment/settings code is included, but compatible WeSpeaker/CAM++ model artifacts are not; verification-dependent paths remain unavailable without them. 包含登记与设置代码，不含模型；缺模型时相关路径不可用。声纹仅是可能误判的便利过滤，不是身份认证。 |
| Localization / 本地化 | English and Simplified Chinese resources; some UI strings remain Chinese. 提供英文和简体中文资源，部分界面仍仅中文。 |

### Verification scope / 验证范围

The fixed PR #3 candidate passed [native/build and light/dark/maximum-text simulator CI](https://github.com/alexlee2046/yihu-ios/actions/runs/38183231918). Five physical-device checks passed on the installed c76 candidate: navigation, menu refresh, pull refresh, foreground recovery and reversible cross-workbench search isolation. Existing automatic transcript insertion was separately accepted.
PR #3 固定候选已有原生/构建及三种模拟器场景通过证据；已安装 c76 真机通过导航、菜单刷新、下拉刷新、前后台恢复、双工作台搜索隔离五项，配置回读确认已还原。自动填入沿用此前独立验收。

Maximum text size on a physical phone, full filtering/counts and two live sources, cold-start shortcuts, real replies, remaining Watch/recording and push delivery remain device/service acceptance items. Alex will test and provide feedback separately. Merging source does not certify these paths; no additional acceptance tooling is being added.
真机最大字号、完整筛选计数与双实时来源、冷启动快捷配置、真实回复、Watch/录音余项及推送交付由 Alex 后测反馈；代码合入不等于这些路径已通过，不继续扩展验收工具。

[PR #5](https://github.com/alexlee2046/yihu-ios/pull/5) supplies opt-in, non-destructive checks, not new product capabilities. [CI for its fixed 61e158c source](https://github.com/alexlee2046/yihu-ios/actions/runs/38244125098) is separate from the earlier 991292c run.
PR #5 提供显式授权的非破坏性检查，不是新增产品功能；测试结果绑定具体提交，旧 991292c CI 不替代 61e158c 的回证。

### Bounded client enhancements / 有界客户端增量

[PR #4](https://github.com/alexlee2046/yihu-ios/pull/4) is limited to the [PM-approved reduced scope](https://github.com/alexlee2046/yihu-ios/pull/4#issuecomment-6124724831). Its review/CI evidence is separate from the c76 device evidence above.

- **Voice notes:** explicit insertion uses the workbench/page captured when opening notes and the existing refusal/draft guards; it never sends. Each note reserves one handoff in its existing local metadata before insertion or share-tray staging. Uncertain/failed handoffs retain the original note and are not automatically retried or converted into another staged copy; check the destination and use Copy if needed. Direct insertion is limited to 3,000 transcript characters; longer notes use the existing attachment path.
- **Images:** explicit camera/photo selection only stages a JPEG in the existing inbox. Files are capped at 32 MiB and 32 million source pixels before decoding; camera-provided bitmaps are capped at 32 million pixels/128 MiB before further processing. Background downsampling/normalization produces at most 2,048 pixels per side with scale 1 and strips source metadata. Cancelled or failed processing preserves existing shares. Upload/attachment still requires the existing separate user action.
- **Live Activities:** optional `agentName` changes display text only; missing/blank names retain Hermes. It adds no notification permission, provider or delivery claim.

PR #4 按 PM 减法范围仅保留录音笔记显式填入、图片暂存及活动可选名称。笔记绑定打开记录时的工作台/页面，每条在原元数据中先保留一次交接标记；失败或结果不确定保留原文、不自动重试或转存，核对目标后可手动复制。3000字以上沿用附件暂存。图片文件先限32 MiB/3200万像素；系统相机已提供的位图先限3200万像素/128 MiB，再后台缩至单边最多2048、scale 1，规范方向并移除来源元数据。取消/失败保留原分享，不自动上传或发送。名称仅显示、缺省仍为Hermes；这些新增路径的真机余项由Alex后测，不能引用旧c76真机证据代替。

Relay server/containers/MCP, configurable or inferred relay registration, general Agent abstractions and standalone Watch approval are excluded. Existing main-line Watch draft → phone confirmation remains unchanged; production notifications and Watch direct-write authorization retain their separate gates.
本轮撤出中继服务/容器/MCP、可配置或推断式中继注册、通用Agent抽象、独立手表审批及对应实现声明；既有手表草稿→手机确认保持不变，通知生产接入与手表直写仍走原独立授权门。

## Build locally

This path is for source developers, separate from [App Store installation](https://apps.apple.com/us/app/yihu/id6819057500). Source signing and build prerequisites below are not requirements for installing the store edition.

Requires macOS, Xcode with the iOS 18 SDK or newer and Swift 6, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

1. In `project.yml`, replace `YIHU_BUNDLE_ID` and `YIHU_APP_GROUP` with unique identifiers registered to **your own** Apple developer team. Set `DEVELOPMENT_TEAM` to your own team ID. The main app and share extension must use the same App Group.
2. Run `xcodegen generate --spec project.yml` in this directory.
3. Open `Yihu.xcodeproj`, select the `CollieiOS` scheme and your device, and configure signing for the app, extensions and Watch companion with your own team. Enable App Groups and Push Notifications using your own provisioning. Push capability may require a paid Apple Developer membership.
4. Build and run in Xcode. No signing identities, profiles, APNs keys, server credentials or prebuilt app are included. Do not commit your signing configuration.

All Swift imports are Apple SDK modules. The required third-party Swift inference source is vendored with its license; there is no dependency on the original private workspace or a local Swift package.

## Connect to your own workbench

On first launch, enter your own HTTPS workbench origin, such as `https://collie.example.com`. No workbench is preconfigured. Collie, OpenClaw and Hermes are examples of web UIs, not a certified native-integration compatibility list. The validator accepts only an origin: no user/password, path, query or fragment. The iPhone must be able to reach your server and trust its TLS certificate. Authenticate/pair with your server as required; the app does not bypass server permissions.

首次连接只填自有 HTTPS 工作台源地址，不带账号密码、路径、参数或片段；手机需能访问服务并信任其 TLS 证书。上述产品仅是网页工作台示例，不是原生功能适配认证清单。

Native notifications require the web bridge `window.collieNativePush.request(operation, payload)` for `status`, `register` and `unregister`, matching native-push server endpoints, and an APNs provider configured for **your app's bundle ID and signing environment**. APNs private keys belong on your server, never in this app repository. Stock Collie v1.19.2 does not expose this APNs extension or a public native-notification delivery adapter. Settings checks the optional capability without asking for notification permission or registering a device; a missing bridge is shown as unavailable. Existing bindings are retained so they can be explicitly disabled or reused with a compatible origin. No relay, provider credentials or server patches are created automatically. Web access and native notification support are different capabilities.

Voice insertion does not require a Collie fork. The optional `collie:native-transcript` host event is tried first; an observed refusal never falls through. Without a handler, a native-injected adapter edits only the field the user last focused on the same page. The stock Collie v1.19.2 DOM adapter requires an editable composer and an unambiguous, unlocked draft-mode control; sending, direct terminal typing and unknown layouts are refused. An incompatible page retains the transcript in the native panel for explicit copy or retry. No insertion path presses Send; transcription should be reviewed before sending. The separate Hermes Live Activity integration is optional and requires a compatible relay you control; its source endpoint is deliberately `https://relay.example.invalid`. Do not enable it without configuring your relay in `CollieHermesPush.swift`.

语音填入不自动发送；宿主明确拒绝后不降级绕过，未知编辑器保留原生转写供用户处理。通知需网页桥、服务端接口及匹配签名环境的 APNs 配置；实时活动还需自有兼容中继，占位地址不可用。

## Workbenches and PM Radar

Web workbenches and native PM Radar share one header and shortcut bar. Use the grid to manage workbenches and customize shortcut order/visibility. Radar opens with management categories for decisions, acceptance, in-progress and to-do work. Completed/on-hold tasks are hidden by default and available through the history toggle; choosing a historical status enables history. Project, source-status, priority and search filters intersect and persist independently per workbench. Default task ordering is P0 → P1 → P2 → missing/other priorities, then latest source modification within each priority; a bucket with missing timestamps retains source order. Display settings can disable priority-first ordering. Clear filters restores the unfinished scope. Cards emphasize the title, project, status, priority and next step; owner session, window state, evidence and source modification time are expandable details. Missing fields are marked rather than inferred. Overview counts reflect the current filters and open the matching task list. Switching web origins captures native WebKit interaction state per trusted origin in memory, so returning restores the page/history/scroll instead of opening the root again; it does not copy browser state across origins or persist it to disk.

Import a `pm-radar --json` export or configure an HTTPS JSON feed. `tools/serve-radar.py --port PORT --tailnet-host HOST:HTTPS_PORT` is an optional loopback-only, read-only adapter behind your existing access-controlled HTTPS/Tailnet path. The adapter keeps one bounded in-memory snapshot: fresh for 30 seconds, and served for at most five minutes while a single background `req list --all --json` read runs. Reads are request-triggered; there are no server data files, polling or scheduler. Cold starts and expired snapshots wait for the source; unavailable reads without a usable snapshot return HTTP 503. It never prints task text or raw CLI errors. Host/Origin guards and denied write methods restrict the adapter; HTTPS and network access control belong to your proxy. Do not expose private ledger data publicly. The app retains only its existing local offline cache.

Responses supply optional `tasks` (all non-archived ledger items) alongside `decisions` (only waiting-for-decision/acceptance items). The All tasks and Projects views use `tasks`; Overview and My actions show `decisions`. Task records may include `id`, `priority`, `evidence`, `session` and `window_status` as separate source fields, and an optional Unix task-update `timestamp`. No Git activity is synthesized from task update times. Legacy exports lacking `tasks` remain readable with an incomplete-ledger notice. `date_str` records the last successful source read, never a failed phone fetch or cache hit. Optional `source_refreshing` / `source_refresh_failed` flags distinguish revalidation and failed reads from fresh source data. The phone paints the cached response first and makes one `Cache-Control: no-cache` follow-up to await that same source read; no polling loop is started. Host/proxy and per-request write authorization checks still run on cache hits. Reply preparation/readback bypass this cache; even uncertain submissions invalidate it.

**Reply history / 回复历史:** With the existing explicitly bound personal identity, “History and feedback” reads the original private item on demand, including completed items. Read permission is checked separately from eligibility to send. Five source records are fetched per page, with at most 100 displayed per opening; larger notes link to their full source. Verified phone replies show the exact text, provider timestamp and comment link. Draft notes have no independent provider comment timestamp/link and are labeled accordingly. Reopening reads history again; there is no additional local history database. Unsupported older adapters, offline/permission/read failures and genuinely empty history are distinct, and history reads never transmit an unsent draft. Changing source or closing the view invalidates late reads. New replies retain the original confirmation, target checks and durable request-ID uncertainty protections. History requires the matching adapter revision through the existing release gate. The same view shows source status, next step and owner session. Only later source notes explicitly citing `request_id: UUID` or that item's exact original comment URL are associated with a reply; an ordinary note or status change is only an item update. Association never means read, handled or executed. Draft notes can associate by request ID, not by their shared draft URL. The empty-feedback message applies only to the records read so far.

In Debug builds only, explicitly launching with `YIHU_RADAR_FEED` set to a valid HTTPS feed provisions/selects a matching Radar workbench and refreshes it without replacing unrelated workbenches. This delivery convenience is not enabled automatically and does not embed a feed address.

Authenticated feeds currently require a file export: Radar does not reuse web cookies, store credentials or follow redirects. Snapshots are limited to 2 MiB; failed refreshes retain the last valid snapshot, and changing the feed clears its old cache. Cache reads are bounded to 2 MiB and corrupt files are retained with a recovery message. Duplicate workspace IDs refuse configuration loading without overwriting its original data. Changing a feed is refused if its old cache cannot be cleared, preventing source mix-ups after relaunch. Snapshot dates and record identities/timestamp ranges are validated; future-dated snapshots show a clock warning, and data older than 24 hours is marked stale. Explicit task status values distinguish progressing, waiting, blocked, completed and paused work; project records may optionally supply a `status` string, while legacy feeds remain supported. Project cards show source task statuses, or “Task status not provided” when none exist. Action records may optionally provide a Unix `timestamp` for newest-first sorting; if any matching action lacks a timestamp, newest-first preserves the complete source order. Turning newest-first off sorts action titles alphabetically. Code activity and snapshot age never imply a task is blocked or finished. Radar reads the source task tracker without changing task status. Optional decision/acceptance replies require separately enabled write authorization, as described below.

### Content-bound authorization records (in development)

The private ledger remains the only request/receipt store. A request owner can include one fenced `yihu-authorization` JSON object in the original item description. Its exact operation, fingerprint, scope, expiry and budget are displayed in the existing reply view and repeated in the confirmation sheet. The separate authorization button requires a note; an ordinary reply, including “同意”, is **not** authorization. The existing `prepare/submit/check`, personal Tailscale identity check, source revalidation and durable request ID apply. After an ambiguous response, readback uses the originally confirmed declaration even if the current request changed or expired. No additional local receipt database is introduced.

```yihu-authorization
{"version":1,"operation":"colab.run","fingerprint":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","subject":"Synthetic public-image experiment","scope":"Only the reviewed batch; no private data or customer delivery","expires_at":1893456000,"budget":{"session_cu":5,"total_cu":100,"minutes":15}}
```

Replace the example fingerprint and expiry with the actual preflight digest and a short expiry. Supported operations are `colab.run`, `colab.resume`, `colab.recover`, `colab.calibrate`, and `release.promote`. Colab requests use a full 64-character experiment digest; release requests use a full 40-character commit SHA. Run/resume require the three explicit positive budget limits; other operations require `budget: null`. Duplicate declarations/JSON keys, unknown fields, invalid fingerprints and invalid budgets fail closed. Changing any declared field changes the request digest and target version; a new confirmation is required. No credentials belong in the declaration or note.

**The phone records a scoped human confirmation; it does not mint an execution token or launch anything.** The separate Colab executor must read the trusted original receipt and retain its own explicit approval, exact fingerprint, budget and idempotency checks. Production still requires `promote` and independently signed authorization. Upload, link creation and customer delivery are not added or implicitly authorized. Neither a ledger marker nor a generic comment is a credential or a bypass-proof gate. Cross-repository acceptance remains under [the original requirement](https://github.com/users/alexlee2046/projects/3?pane=issue&itemId=272152146), separate from deployment/device acceptance.

The optional read-only Colab projection reuses the same authenticated feed and request-triggered cache. Operators explicitly supply `--colab-workbench /existing/workbench.py --colab-output /existing/ledger-root --colab-cwd /existing/devops`; all paths must be absolute. It runs only `python3 workbench.py snapshot --output ROOT` from the existing devops directory. Supplying `--colab-wrap /existing/colab-wrap` also opts in to `--live-usage` read-only sampling; there is no automatic GPU run or new scheduling. The producer is limited to 40 seconds/2 MiB stdout; stderr is discarded. Snapshot and ledger reads run concurrently. A failed/invalid projection shows a separate unavailable notice without blocking the ledger or displaying an old balance as fresh.

Schema v1 is exposed as optional `colab`, with `colab_unavailable` on failure. The Overview shows CU sampling time, measured/unmeasured runs, query/batch progress, full experiment fingerprints, Baseline/Candidate metrics, release-confirmation warnings and original request-ID execution statuses. Unknown numbers and release state remain unknown, not zero/success. Telemetry older than five minutes is marked stale, and execution `uncertain` requires original-ID readback rather than rerun. Execution/evaluation completion is not product acceptance or release permission. No new receipt store, feed, credential or execution path is introduced. The four run/resume × integral/fractional authorization groups (plus equivalent integral floating-point cases) are pinned in the shared synthetic fixture and checked in the existing remote CI.

本增量复用原台账、手机二次确认与只读快照，展示预算/进度/评测/释放与执行待核状态，不产生执行令牌、不自动运行、不新增审批平台。执行消费归 Colab 原入口；原执行门、生产签名与外发边界不变，跨仓、真机和部署验收分开。

### Apple Watch companion (#31)

`YihuWatch` is a watchOS 11+ companion using the phone's existing WatchConnectivity pairing. It receives only pending decision/acceptance summaries, without feed URLs, credentials or reply drafts. Lists/details show source read times, stale/failed reads and phone reachability; oversized payloads are trimmed with an explicit more-on-phone notice. Sync requests transfer the phone's existing snapshot, not pretend to refresh the ledger. A selected item queues a phone handoff; the phone resolves the original workbench/task and respects its existing busy and reply-sheet guards. It opens read-only details, never sends replies or changes status from the watch.

Build the `YihuWatch` scheme with a generic watchOS Simulator destination and `CODE_SIGNING_ALLOWED=NO`. The existing `ios.yml` workflow has a `watch_only=true` dispatch for native checks, watch/phone builds and a synthetic watch screenshot; it skips the previously accepted legacy UI scenarios. `YIHU_WATCH_DEMO=1` is Debug-only synthetic UI evidence, not proof of pairing. No watch signing/profile changes or physical install are performed without separate approval.

Watch proposal input (#32) uses the system TextField keyboard/dictation UI and a protected local draft. Transfer shows the whole proposal and retains its UUID after uncertain transport; the phone checks source/task fingerprints and refuses busy UI or another existing draft. It acknowledges only a safely persisted phone proposal. The phone's existing reply form fetches fresh metadata and requires another explicit confirmation to write. Missing/older capabilities remain view-only. This is not direct watch reply authorization.

Direct watch replies (#33) require separate confirmation of the paired-device write authorization and must retain #30's target/readback/idempotency boundaries; this entry remains closed pending that decision. The watch notification page (#34) reports phone notification state and system mirroring prerequisites, without requesting permissions. A live-ledger GET feed is not a push event source: PM task reminders remain unavailable until an authorized upstream supports them. Existing workbench notification mirroring is conditional on phone/service/system support, not evidence of delivery. No independent watch APNs, new notification backend, polling relay or automatic execution is enabled.

### Optional decision and acceptance replies

The adapter remains read-only unless explicitly started with `--writer-user-id USER_ID`. Bind only an authorized personal Tailscale identity. The loopback listener trusts Serve's injected `Tailscale-User-Login` header; Serve strips spoofed values. Tagged or unrecognized identities cannot write. Funnel must remain disabled; the adapter checks the current private Serve configuration. POST requests with browser Origin/Fetch headers are refused even from the Collie origin, and require native JSON intent. No GitHub credential is copied to the phone.

For eligible decision/acceptance items, the phone reads fresh target metadata, shows the original title/link/status/next step and complete reply in a second confirmation form, then posts only on explicit Send. The server restricts targets to the configured private Project and writable private Issues or DraftIssues. It uses the existing `req note` CLI and its private-project/repository/sensitive-text guards; reply text is piped in, not put in process arguments or logs. It never changes status, creates a requirement, merges or deploys.

A reply UUID and body digest are recorded on the original comment/draft. Receipt lookup paginates all comments before deciding whether a reply exists. The phone preserves unsent drafts and persists pending requests before submission with file protection and backup exclusion. Uncertain results freeze input and require readback rather than blind retries. A bounded in-memory set remembers attempted UUIDs/digests (not ledger data or reply bodies); if an attempt is unresolved, a missing comment is not treated as proof of no write. After a server restart, unresolved requests remain unknown unless a durable receipt is found. Source/task changes require a new confirmation. Resolve local drafts/pending results before changing the source or deleting the workbench.

Run the standalone adapter and model/persistence checks from this directory:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 Tests/CollieRadar/AdapterChecks.py
swiftc -swift-version 6 Apps/Collie/CollieRadarModel.swift \
  Apps/Collie/CollieRadarStore.swift Tests/CollieRadar/ModelChecks.swift \
  -o /tmp/yihu-radar-checks
/tmp/yihu-radar-checks
```

The `CollieUITests` scheme test target exercises both web and Radar navigation using a synthetic `.invalid` origin and creates a Radar workbench if needed. Run it only on an isolated simulator installation, not against your saved device workbenches. The `Yihu iOS acceptance` workflow runs the model checks, builds the independent app/extensions/test target, and exercises light, dark and accessibility text sizes on a standard hosted macOS runner. Its artifacts contain synthetic-data screenshots and test results, not device or signing evidence. Physical-device acceptance is separate.

`CollieDeviceSmokeTests` is an opt-in, presentation-only check of an **already installed** app. Build a separate UI-test runner containing only that test file, using an existing device-authorized development profile. Its `xctestrun` must use `UseDestinationArtifacts`, the installed runner's `TestHostBundleIdentifier` and `TestBundleDestinationRelativePath`, and the existing app's `UITargetAppBundleIdentifier`; omit install paths and dependent products. Set runner environment variables `YIHU_DEVICE_SMOKE=1` and `YIHU_EXISTING_APP_BUNDLE_ID` explicitly. Keep `SystemAttachmentLifetime` and `UserAttachmentLifetime` at `keepNever`, disable parallel execution, and keep all physical-device diagnostics private/local. The owner must approve any XCTest automation/passcode prompt on the phone. Do not disable the device passcode or reset pairing to bypass it.

This check activates the existing app without demo arguments or a reinstall, refuses an active interaction, checks visible Web/Radar shortcuts and repeated taps, reads notification capability status, opens/dismisses the workbench list, and restores the original selection. It never creates workbenches, edits preferences, enters text, records audio or sends replies. A missing prerequisite is a skip, and runner initialization/authorization failure is **not** a successful app test. Model accuracy, real replies, Watch pairing, notifications, restart recovery and system appearance changes remain separate acceptance items.

`CollieDeviceAcceptanceTests` adds existing-source menu/pull refresh, foreground recovery, and reversible search isolation across two existing Radar workbenches. It requires separate `YIHU_DEVICE_ACCEPTANCE=1` opt-in and privately supplied existing workbench IDs/names. Refresh requires the displayed source-read time to advance and an external check of the device cache; minute-precision timestamps can require a later retry. Search checks require initially empty queries and remove only their own synthetic markers. These checks do not replace cold-restart, full filter/count, real-reply, microphone or Watch acceptance.

## Models and limitations

Qwen3 ASR model files are **not** in the repository. Download them through the app's model screen (Hugging Face or ModelScope); the app verifies pinned SHA-256 hashes. Model downloads need storage, bandwidth and a capable device.

WeSpeaker and CAM++ speaker-verification artifacts are deliberately omitted. Code loads these resources dynamically and reports missing models rather than bundling private/generated artifacts. Speaker enrollment/verification and any voice-insertion path requiring a verified speaker will not be available without compatible models. Do not disable verification to work around missing assets. See [ThirdPartyNotices.txt](Apps/Collie/ThirdPartyNotices.txt) and [CAMPlus provenance](Apps/Collie/Vendor/CAMPlus) for provenance. Core ML conversions must match the pinned hashes in the source; upstream weights alone are not a drop-in replacement.

Build, simulator and partial physical-device evidence is linked above. It is not certification of every device, notification path or end-to-end service integration. Some UI strings remain Chinese.

On-device transcription does not mean all data stays on the phone: web browsing, user sends/uploads and optional notification/relay integrations involve their respective services. Use synthetic data in public screenshots, logs and issues; redact service origins, account/device identifiers, local paths, task text and recordings. Never publish credentials, signing materials or model artifacts.

模型不随仓库提供，下载需要存储、带宽与适用设备；缺声纹模型时相关能力不可用，声纹不能替代身份认证或写入授权。端侧转写不代表所有数据留在本机：网页访问、用户发送/上传与可选通知/中继会涉及相应服务。公开截图、日志和 Issue 仅用合成数据，脱敏服务地址、账号/设备标识、本地路径、任务正文与录音，不上传凭据、签名材料或模型文件。已合入源码或局部证据均不作为完整真机验收结论。

## License

Original Yihu code: [Apache License 2.0](LICENSE). Third-party code retains its own license and notices; see [NOTICE](NOTICE) and the bundled acknowledgements. Collie server code, other products, model binaries, user recordings and private repository history are not included.
