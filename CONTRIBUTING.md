# Contributing / 贡献指南

## Before changing code

- Search existing [issues](https://github.com/alexlee2046/yihu-ios/issues) and [pull requests](https://github.com/alexlee2046/yihu-ios/pulls). Larger changes should first explain the problem and acceptance criteria in an issue.
- Keep PRs focused. State the base branch and dependencies; features in open PRs are not automatically available in `main`.
- Follow the [README](README.md#build-locally) to generate the Xcode project. Keep personal signing changes local; never commit credentials, provisioning profiles, model binaries, recordings or private workbench data.
- Preserve explicit confirmation and server authorization for writes. The voiceprint check is a convenience filter that can produce false positives, not authentication; do not bypass it or treat it as write authorization. Optional notification/relay support must not become automatic execution.

## Validation and review

Build the `CollieiOS` scheme on an isolated iOS Simulator with your generated project. For example:

```sh
xcodegen generate --spec project.yml
xcodebuild -project Yihu.xcodeproj -scheme CollieiOS \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Run the checks available on the PR's branch and link the exact CI run/results. Describe what was actually verified: simulator builds, synthetic UI evidence and physical-device checks are different. If a check cannot run, say so. Do not claim a workflow file alone proves acceptance.

Use synthetic data in screenshots and logs. Redact server origins, task text, account identifiers and local paths before attaching evidence. Security-sensitive reports follow [SECURITY.md](SECURITY.md).

提交前说明改动目的、验证结果和功能限制；设备验证需单独提供证据，签名与个人数据不进入仓库。
