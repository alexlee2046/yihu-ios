# 一呼 · Yihu for iOS

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform: iOS 18+](https://img.shields.io/badge/iOS-18%2B-blue.svg)](project.yml)
[![Swift: 6](https://img.shields.io/badge/Swift-6-orange.svg)](project.yml)

An independent native iOS companion for your own [Collie](https://github.com/AltanS/collie) workbench. Includes a WebKit shell, on-device voice transcription, voice notes, a share extension and optional Live Activity UI. This is a source release, not an App Store binary or an official Collie client.

一呼是连接自有 Collie 工作台的原生 iOS 客户端：网页工作台、端侧语音输入、长录音笔记、系统分享收件箱和可选 Live Activity。需要自备服务、模型和签名配置；仓库不提供预配置服务器或可安装的 App Store 成品。

[Build / 构建](#build-locally) · [Connection / 连接](#connect-to-your-own-workbench) · [Limitations / 限制](#models-and-limitations) · [Contributing / 贡献](CONTRIBUTING.md) · [Security / 安全](SECURITY.md)

## Feature overview / 功能概览

### Available in `main` / 已合入主分支

| Capability / 功能 | Scope and requirements / 范围与要求 |
| --- | --- |
| Web workbench / 网页工作台 | WebKit shell connected to your own HTTPS Collie origin; server authentication still applies. 连接自有 HTTPS Collie 服务，仍需服务端认证。 |
| On-device speech / 端侧语音 | Qwen3 ASR with separately downloaded, hash-verified models; review transcripts before sending. Composer insertion needs a compatible host integration. 模型需单独下载并校验哈希；发送前检查转写，自动填入需要兼容的宿主接口。 |
| Voice notes / 录音笔记 | Record longer audio, transcribe in segments on the phone and retain local audio/transcripts. Requires microphone permission and compatible models. 支持长录音、手机分段转写及本地保存；需麦克风权限和兼容模型。 |
| Share inbox / 分享收件箱 | Import text, links and files through the iOS share extension; content is staged in the App Group, not automatically sent. 分享的文字、链接和文件仅暂存 App Group，不自动发送。 |
| Live Activities / 实时活动 | Widget extension and optional Hermes relay integration; requires a compatible relay you control. The placeholder endpoint is intentionally unusable. 需自有兼容中继；占位地址不可用，不代表通知链已开通。 |
| Speaker verification / 声纹验证 | Enrollment/settings code is included, but compatible WeSpeaker/CAM++ model artifacts are not; verification-dependent paths remain unavailable without them. 包含登记与设置代码，不含模型；缺模型时相关路径不可用。声纹仅是可能误判的便利过滤，不是身份认证。 |
| Localization / 本地化 | English and Simplified Chinese resources; some UI strings remain Chinese. 提供英文和简体中文资源，部分界面仍仅中文。 |

### On GitHub, pending acceptance / 已推送、待验收

These changes are **not part of `main`**. Follow the PRs for source, test evidence and the current review state; a PR description is not proof of device acceptance.
以下改动尚未合入主分支；源码、测试和审查状态以对应 PR 为准，PR 描述不等于真机验收通过。

| Change / 改动 | Review entry / 审查入口 |
| --- | --- |
| Multiple workbenches, native PM Radar, filtering/offline snapshots, optional confirmed replies, Apple Watch summaries/proposal handoff and guarded composer insertion / 多工作台、原生台账、筛选与离线快照、受限确认回复、Watch 摘要与草稿接续、受保护填入 | [PR #3](https://github.com/alexlee2046/yihu-ios/pull/3) · [Detailed branch documentation / 分支详情](https://github.com/alexlee2046/yihu-ios/blob/feat/workbench-radar/README.md) · Partial device acceptance; remaining items tracked separately / 部分真机通过，其余缺口独立保留 |
| Configurable relay, voice-note insertion, agent abstractions, watch approval UI, relay/MCP tooling and photo diagnostics / 可配置中继、录音笔记填入、代理抽象、手表审批界面、中继/MCP 工具及图片诊断 | [PR #4](https://github.com/alexlee2046/yihu-ios/pull/4) · Blocked by [security/functional findings / 安全与功能阻断](https://github.com/alexlee2046/yihu-ios/pull/4#pullrequestreview-5484553270) |
| Opt-in, non-destructive physical-device checks / 显式授权的非破坏性真机检查 | [PR #5](https://github.com/alexlee2046/yihu-ios/pull/5) · Five checks passed; not full acceptance / 五项通过，不代表全部验收完成 |

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

On first launch, enter your own HTTPS Collie origin, such as `https://collie.example.com`. No workbench is preconfigured. The validator accepts only an origin: no user/password, path, query or fragment. The iPhone must be able to reach your server and trust its TLS certificate. Authenticate/pair with your server as required; the app does not bypass Collie's permissions.

Native notifications require the web bridge `window.collieNativePush.request(operation, payload)` for `status`, `register` and `unregister`, matching native-push server endpoints, and an APNs provider configured for **your app's bundle ID and signing environment**. APNs private keys belong on your server, never in this app repository. A stock Collie release may not implement this extension. Web access and native notification support are different capabilities.

Voice insertion dispatches the `collie:native-transcript` web event. The workbench must implement the corresponding composer integration; do not assume every upstream version does. Transcription should be reviewed before sending. The separate Hermes Live Activity integration is optional and requires a compatible relay you control; its source endpoint is deliberately `https://relay.example.invalid`. Do not enable it without configuring your relay in `CollieHermesPush.swift`.

## Models and limitations

Qwen3 ASR model files are **not** in the repository. Download them through the app's model screen (Hugging Face or ModelScope); the app verifies pinned SHA-256 hashes. Model downloads need storage, bandwidth and a capable device.

WeSpeaker and CAM++ speaker-verification artifacts are deliberately omitted. Code loads these resources dynamically and reports missing models rather than bundling private/generated artifacts. Speaker enrollment/verification and any voice-insertion path requiring a verified speaker will not be available without compatible models. Do not disable verification to work around missing assets. See [ThirdPartyNotices.txt](Apps/Collie/ThirdPartyNotices.txt) and [CAMPlus provenance](Apps/Collie/Vendor/CAMPlus) for provenance. Core ML conversions must match the pinned hashes in the source; upstream weights alone are not a drop-in replacement.

This extracted public candidate has only received static dependency/configuration and sanitization checks. No clean-room Xcode build, device push, voice insertion or full regression result is claimed. Some UI strings remain Chinese.

## License

Original Yihu code: [Apache License 2.0](LICENSE). Third-party code retains its own license and notices; see [NOTICE](NOTICE) and the bundled acknowledgements. Collie server code, other products, model binaries, user recordings and private repository history are not included.
