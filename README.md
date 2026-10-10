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

Native notifications require the web bridge `window.collieNativePush.request(operation, payload)` for `status`, `register` and `unregister`, matching native-push server endpoints, and an APNs provider configured for **your app's bundle ID and signing environment**. APNs private keys belong on your server, never in this app repository. A stock Collie release may not implement this extension. Web access and native notification support are different capabilities.

Voice insertion dispatches the `collie:native-transcript` web event. The workbench must implement the corresponding composer integration; do not assume every upstream version does. Transcription should be reviewed before sending. The separate Hermes Live Activity integration is optional and requires a compatible relay you control; its source endpoint is deliberately `https://relay.example.invalid`. Do not enable it without configuring your relay in `CollieHermesPush.swift`.

## Workbenches and PM Radar

Web workbenches and native PM Radar share one header and shortcut bar. Use the grid to manage workbenches and customize shortcut order/visibility. Radar supports overview, projects and actions, with per-workbench search, filters, display options and local snapshots.

Import a `pm-radar --json` export or configure an HTTPS JSON feed. Authenticated feeds currently require a file export: Radar does not reuse web cookies, store credentials or follow redirects. Snapshots are limited to 2 MiB; failed refreshes retain the last valid snapshot, and changing the feed clears its old cache. Data older than 24 hours is marked stale. Radar is read-only and does not update the source task tracker.

Run the standalone model/persistence checks from this directory:

```sh
swiftc -swift-version 6 Apps/Collie/CollieRadarModel.swift \
  Apps/Collie/CollieRadarStore.swift Tests/CollieRadar/ModelChecks.swift \
  -o /tmp/yihu-radar-checks
/tmp/yihu-radar-checks
```

The `CollieUITests` scheme test target includes a device navigation check. It requires saved web/Radar workbenches and visible shortcuts; it is not a first-run setup test. Screenshots can contain your workbench content: use synthetic data and do not commit test results. Device results from the original workspace do not establish validation of this independent checkout. Light appearance and accessibility text sizes still need acceptance.

## Models and limitations

Qwen3 ASR model files are **not** in the repository. Download them through the app's model screen (Hugging Face or ModelScope); the app verifies pinned SHA-256 hashes. Model downloads need storage, bandwidth and a capable device.

WeSpeaker and CAM++ speaker-verification artifacts are deliberately omitted. Code loads these resources dynamically and reports missing models rather than bundling private/generated artifacts. Speaker enrollment/verification and any voice-insertion path requiring a verified speaker will not be available without compatible models. Do not disable verification to work around missing assets. See `Apps/Collie/ThirdPartyNotices.txt` and `Vendor/CAMPlus` for provenance. Core ML conversions must match the pinned hashes in the source; upstream weights alone are not a drop-in replacement.

This extracted public candidate has only received static dependency/configuration and sanitization checks. No clean-room Xcode build, device push, voice insertion or full regression result is claimed. Some UI strings remain Chinese.

## License

Original Yihu code: [Apache License 2.0](LICENSE). Third-party code retains its own license and notices; see [NOTICE](NOTICE) and the bundled acknowledgements. Collie server code, other products, model binaries, user recordings and private repository history are not included.
