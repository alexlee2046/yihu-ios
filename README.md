# 一呼 · Yihu for iOS

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform: iOS 18+](https://img.shields.io/badge/iOS-18%2B-blue.svg)](project.yml)
[![Swift: 6](https://img.shields.io/badge/Swift-6-orange.svg)](project.yml)

Yihu is an independent native iOS browser shell optimized for Agent workbenches, including your own [Collie](https://github.com/AltanS/collie), OpenClaw or Hermes web UI. It adds on-device speech, voice notes and iOS sharing around WebKit; compatible integrations can enable native notifications and Live Activities. It is **not a general-purpose Agent platform**: it does not host Agents, supply a backend or make arbitrary workbenches natively compatible. This is a source release, not an App Store binary or an official client of those services.

一呼是**针对 Agent 场景优化的原生 iOS 浏览器壳**，用于访问自有 Collie、OpenClaw、Hermes 等网页工作台，并提供端侧语音、录音笔记与系统分享。基础 HTTPS 浏览不等于原生增强已适配；通知、实时活动等需兼容接口与服务。它不是通用 Agent 平台，不托管 Agent、不提供后端，也不承诺任意工作台原生兼容。需要自备服务、模型和签名配置；仓库不提供预配置服务器或可安装的 App Store 成品，也不是上述服务的官方客户端。

[Build / 构建](#build-locally) · [Connection / 连接](#connect-to-your-own-workbench) · [Limitations / 限制](#models-and-limitations) · [Contributing / 贡献](CONTRIBUTING.md) · [Security / 安全](SECURITY.md)

## Feature overview / 功能概览

### Available in `main` / 已合入主分支

Source checked against [`main` at 27ed419](https://github.com/alexlee2046/yihu-ios/tree/27ed41923664704eef26be0df887358cf133a151). “Available” means source is merged, not that every device/service combination has passed acceptance.
以下按主分支源码核实；“已合入”不等于所有设备与服务组合都已验收。

| Capability / 功能 | Scope and requirements / 范围与要求 |
| --- | --- |
| Web workbench / 网页工作台 | WebKit browsing of a reachable, trusted HTTPS workbench origin, not limited to Collie; login and page compatibility remain the server's responsibility. 可连接可达且证书受信的 HTTPS 网页工作台，不限 Collie；登录与页面兼容仍取决于服务端。 |
| On-device speech / 端侧语音 | Qwen3 ASR with separately downloaded, hash-verified models; review transcripts before sending. Insertion tries the Collie event bridge, then the last-focused editable field on the trusted page; custom editors may not work. 模型需单独下载并校验哈希；发送前检查转写；填入先尝试 Collie 事件桥，再尝试同源页面最近聚焦的可编辑输入框，自定义编辑器不保证兼容。 |
| Voice notes / 录音笔记 | Record longer audio, transcribe in segments on the phone and retain local audio/transcripts. Requires microphone permission and compatible models. 支持长录音、手机分段转写及本地保存；需麦克风权限和兼容模型。 |
| Share inbox / 分享收件箱 | Import text, links and files through the iOS share extension; content is staged in the App Group, not automatically sent. 分享的文字、链接和文件仅暂存 App Group，不自动发送。 |
| Live Activities / 实时活动 | Widget extension and optional Hermes relay integration; requires a compatible relay you control. The placeholder endpoint is intentionally unusable. 需自有兼容中继；占位地址不可用，不代表通知链已开通。 |
| Speaker verification / 声纹验证 | Enrollment/settings code is included, but compatible WeSpeaker/CAM++ model artifacts are not; verification-dependent paths remain unavailable without them. 包含登记与设置代码，不含模型；缺模型时相关路径不可用。声纹仅是可能误判的便利过滤，不是身份认证。 |
| Localization / 本地化 | English and Simplified Chinese resources; some UI strings remain Chinese. 提供英文和简体中文资源，部分界面仍仅中文。 |

### On GitHub, pending acceptance / 已推送、待验收

These draft PRs are **not part of `main`** and do not redefine the released product as a universal Agent platform. Follow the PRs for source, test evidence and the current review state; a PR description is not proof of device acceptance.
以下 PR 均为草稿、尚未合入；代理抽象或 MCP 工具的候选代码不改变产品定位。源码、测试和审查状态以对应 PR 为准，PR 描述不等于真机验收通过。

| Change / 改动 | Review entry / 审查入口 |
| --- | --- |
| Multiple workbenches, native PM Radar, filtering/offline snapshots, optional confirmed replies, Apple Watch summaries/proposal handoff and guarded composer insertion / 多工作台、原生台账、筛选与离线快照、受限确认回复、Watch 摘要与草稿接续、受保护填入 | [PR #3](https://github.com/alexlee2046/yihu-ios/pull/3) · [Detailed branch documentation / 分支详情](https://github.com/alexlee2046/yihu-ios/blob/c76dbd3bfbf04a7f5f4fc247757e105708551597/README.md) · `c76dbd3` · Partial device acceptance; maximum text size, full filtering/counts, cold-start shortcuts, real replies, Watch, recording and push remain pending / 部分真机通过；最大字号、完整筛选计数、冷启动快捷配置、真实回复、Watch、录音及推送仍待验收 |
| Configurable relay, voice-note insertion, agent abstractions, watch approval UI, relay/MCP tooling and photo diagnostics / 可配置中继、录音笔记填入、代理抽象、手表审批界面、中继/MCP 工具及图片诊断 | [PR #4](https://github.com/alexlee2046/yihu-ios/pull/4) · `c94bd68` · Blocked by six [security/functional findings / 安全与功能阻断](https://github.com/alexlee2046/yihu-ios/pull/4#pullrequestreview-5484553270) |
| Opt-in, non-destructive physical-device checks / 显式授权的非破坏性真机检查 | [PR #5](https://github.com/alexlee2046/yihu-ios/pull/5) · `61e158c` · Five checks passed on the installed PR #3 candidate; this branch adds tests, not product capabilities. Earlier CI at `991292c` is not full CI evidence for this head / 五项检查基于已安装的 PR #3 候选；本分支是测试，不是新增功能，旧 CI 不代表当前提交完整通过 |

Watch direct replies, relay deployment and physical-device delivery are not implied by this list. Review and authorization boundaries remain separate from repository publication.
本表不代表手表直写已授权、中继已部署或真机功能全部交付；源码发布与审查、授权、验收分别处理。

## Build locally

Requires macOS, Xcode with the iOS 18 SDK or newer and Swift 6, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

1. In `project.yml`, replace `YIHU_BUNDLE_ID` and `YIHU_APP_GROUP` with unique identifiers registered to **your own** Apple developer team. Set `DEVELOPMENT_TEAM` to your own team ID. The main app and share extension must use the same App Group.
2. Run `xcodegen generate --spec project.yml` in this directory.
3. Open `Yihu.xcodeproj`, select the `CollieiOS` scheme and your device, and configure signing for all three targets with your own team. Enable App Groups and Push Notifications using your own provisioning. Push capability may require a paid Apple Developer membership.
4. Build and run in Xcode. No signing identities, profiles, APNs keys, server credentials or prebuilt app are included. Do not commit your signing configuration.

All Swift imports are Apple SDK modules. The required third-party Swift inference source is vendored with its license; there is no dependency on the original private workspace or a local Swift package.

## Connect to your own workbench

On first launch, enter your own HTTPS workbench origin, such as `https://collie.example.com`. No workbench is preconfigured. Collie, OpenClaw and Hermes are examples of web UIs, not a certified native-integration compatibility list. The validator accepts only an origin: no user/password, path, query or fragment. The iPhone must be able to reach your server and trust its TLS certificate. Authenticate/pair with your server as required; the app does not bypass server permissions.

首次连接只填自有 HTTPS 工作台源地址，不带账号密码、路径、参数或片段；手机需能访问服务并信任其 TLS 证书。上述产品仅是网页工作台示例，不是原生功能适配认证清单。

Native notifications require the web bridge `window.collieNativePush.request(operation, payload)` for `status`, `register` and `unregister`, matching native-push server endpoints, and an APNs provider configured for **your app's bundle ID and signing environment**. APNs private keys belong on your server, never in this app repository. A stock Collie release may not implement this extension. Web access and native notification support are different capabilities.

Voice insertion first dispatches the optional `collie:native-transcript` web event; if it does not accept the text, `main` tries the last-focused editable field on the same trusted origin. This fallback does not require a server fork, but cannot guarantee compatibility with every page/editor. No insertion path presses Send; review transcripts before sending. PR #3's stronger draft-mode/refusal guards are pending, not a guarantee of `main`. The separate Hermes Live Activity integration is optional and requires a compatible relay you control; its source endpoint is deliberately `https://relay.example.invalid`. Do not enable it without configuring your relay in `CollieHermesPush.swift`.

语音填入可尝试同源页面的最近输入框，不意味着任意网页都兼容，也不自动点击发送。原生通知需网页桥、服务端接口及匹配签名环境的 APNs 配置；Hermes 实时活动还需自有兼容中继，占位地址不可用。PR #3 的更严格草稿模式/拒绝保护仍待验收。

## Models and limitations

Qwen3 ASR model files are **not** in the repository. Download them through the app's model screen (Hugging Face or ModelScope); the app verifies pinned SHA-256 hashes. Model downloads need storage, bandwidth and a capable device.

WeSpeaker and CAM++ speaker-verification artifacts are deliberately omitted. Code loads these resources dynamically and reports missing models rather than bundling private/generated artifacts. Speaker enrollment/verification and any voice-insertion path requiring a verified speaker will not be available without compatible models. Do not disable verification to work around missing assets. See [ThirdPartyNotices.txt](Apps/Collie/ThirdPartyNotices.txt) and [CAMPlus provenance](Apps/Collie/Vendor/CAMPlus) for provenance. Core ML conversions must match the pinned hashes in the source; upstream weights alone are not a drop-in replacement.

The extracted `main` source has only received static dependency/configuration and sanitization checks; the pending PRs' partial build/device evidence must not be treated as a clean-room build or full regression result for `main`. Device push and end-to-end service compatibility are not certified. Some UI strings remain Chinese.

On-device transcription does not mean all data stays on the phone: web browsing, user sends/uploads and optional notification/relay integrations involve their respective services. Use synthetic data in public screenshots, logs and issues; redact service origins, account/device identifiers, local paths, task text and recordings. Never publish credentials, signing materials or model artifacts.

模型不随仓库提供，下载需要存储、带宽与适用设备；缺声纹模型时相关能力不可用，声纹不能替代身份认证或写入授权。端侧转写不代表所有数据留在本机：网页访问、用户发送/上传与可选通知/中继会涉及相应服务。公开截图、日志和 Issue 仅用合成数据，脱敏服务地址、账号/设备标识、本地路径、任务正文与录音，不上传凭据、签名材料或模型文件。待验收 PR 的局部证据不作为主分支完整验收结论。

## License

Original Yihu code: [Apache License 2.0](LICENSE). Third-party code retains its own license and notices; see [NOTICE](NOTICE) and the bundled acknowledgements. Collie server code, other products, model binaries, user recordings and private repository history are not included.
