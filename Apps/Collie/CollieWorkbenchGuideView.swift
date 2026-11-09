import SwiftUI
import UIKit

private func guideText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

struct CollieWorkbenchPlatformSpec: Identifiable {
    let id: String
    let title: String
    let badge: String
    let icon: String
    let templateOrigin: String
    let setupCommand: String
    let summary: String
    let steps: [String]
}

enum CollieWorkbenchCatalog {
    static var platforms: [CollieWorkbenchPlatformSpec] {
        [
            CollieWorkbenchPlatformSpec(
                id: "openclaw",
                title: "OpenClaw",
                badge: guideText("语音草稿 · 附件暂存"),
                icon: "terminal.fill",
                templateOrigin: "https://openclaw.example.com",
                setupCommand: "tailscale serve --bg 18789",
                summary: guideText("原生连接 OpenClaw 网页控制台，用端侧离线语音代替手机小屏敲字，支持锁屏长录音转写与系统分享截图上传。"),
                steps: [
                    guideText("在运行 OpenClaw 的主机开启 HTTPS 访问（例如运行 tailscale serve --bg 18789，或使用 Caddy / Cloudflare Tunnel 映射 HTTPS 域名）。"),
                    guideText("在一呼填入 https:// 主机地址并连接，登录后聚焦聊天输入框即可点按底部麦克风口述草稿。"),
                    guideText("在任意 App 通过系统分享面板选择「一呼」，可将截图、日志与代码片段暂存并一键挂入页面上传框。")
                ]
            ),
            CollieWorkbenchPlatformSpec(
                id: "hermes",
                title: "Hermes",
                badge: guideText(":9444 · 灵动岛实时活动"),
                icon: "bolt.horizontal.circle.fill",
                templateOrigin: "https://hermes.example.com:9444",
                setupCommand: "tailscale serve --bg --https=9444 9444",
                summary: guideText("原生接入 Hermes :9444 管理台，在 iPhone 锁屏与灵动岛实时显示长耗时任务进度，任务完成即刻推送提醒。"),
                steps: [
                    guideText("在 Hermes 所在主机映射 :9444 HTTPS 端口（例如运行 tailscale serve --bg --https=9444 9444）。"),
                    guideText("在一呼填入 https://<你的主机>:9444 连接 Hermes WebUI。"),
                    guideText("进入「一呼设置 → 任务提醒」开启「Hermes 任务提醒」，即可在锁屏与灵动岛查看任务步骤进度，点击通知直达对应会话。")
                ]
            ),
            CollieWorkbenchPlatformSpec(
                id: "dot-live",
                title: "Dot & Dot Live",
                badge: guideText(":10000 · WebRTC 实时通话"),
                icon: "waveform.circle.fill",
                templateOrigin: "https://dot.example.com:10000",
                setupCommand: "tailscale serve --bg --https=10000 10000",
                summary: guideText("连接 :10000 HTTPS Dot 工作台后自动挂载「Live 通话」悬浮条，通过 WebRTC 与 Agent 全双工实时语音对讲。"),
                steps: [
                    guideText("在一呼填入 https://<你的主机>:10000 连接 Dot 工作台，右下角会自动出现「Live 通话」控制条。"),
                    guideText("点击「Live 通话」开启 WebRTC 双向实时语音（/dot-voice/call · /attach · /stop），自动启用 iOS 硬件回声消除与蓝牙耳机路由，支持随时静音或挂断。"),
                    guideText("如需为你的团队工作台接入 Dot Live 实时语音网关，可通过下方「打开在线接入文档」联系我们对接。")
                ]
            ),
            CollieWorkbenchPlatformSpec(
                id: "collie",
                title: "Collie & PM Radar",
                badge: guideText("原生草稿桥 · 多项目简报"),
                icon: "rectangle.3.group.bubble.fill",
                templateOrigin: "https://collie.example.com",
                setupCommand: "python3 tools/serve-radar.py --port 8787 --tailnet-host workbench.example.com:8443",
                summary: guideText("深度适配 Collie 网页工作台与 PM Radar 多项目简报，支持免弹键盘语音直填草稿、APNs 推送、Apple Watch 速览与靠近唤醒断网 Mac 热点。"),
                steps: [
                    guideText("在一呼填入 https://<你的主机> 连接 Collie 工作台，自动启用 collie:native-transcript 草稿桥与原生通知。"),
                    guideText("点击顶部网格按钮「全部工作台 → 添加 PM Radar」，填入简报源即可在一屏汇总多个项目的「等你决策 / 等你验收」事项。"),
                    guideText("在「一呼设置 → Mac 热点唤醒」开启蓝牙唤醒，外出时附近断网的 MacBook 会自动连回这台 iPhone 的个人热点。")
                ]
            )
        ]
    }

    static var manualHighlights: [(icon: String, title: String, detail: String)] {
        [
            (
                "mic.fill",
                guideText("1. 端侧离线语音草稿"),
                guideText("首次点击底部麦克风按需下载约 950 MB 本地语音模型。口述内容在本机离线转写并填入当前输入框，由你核对确认后再点发送。")
            ),
            (
                "waveform",
                guideText("2. 锁屏长录音与分段交接"),
                guideText("点击顶部波形按钮打开「语音记录」，手机锁屏后仍可持续后台录音，支持多段追加录音、分段转写与一键交接至工作台。")
            ),
            (
                "person.wave.2.fill",
                guideText("3. 声纹过滤与近场收音"),
                guideText("在「一呼设置 → 只认我的声音」录入个人声纹，配合近场收音减弱环境杂音，在嘈杂场所优先识别你本人的声音。")
            ),
            (
                "applewatch",
                guideText("4. Apple Watch 腕上协同"),
                guideText("在 Apple Watch 上抬腕查看待决策事项摘要、使用快捷回复模板或恢复未发语音草稿，回到手机即可核对确认。")
            )
        ]
    }
}

struct CollieWorkbenchGuideView: View {
    var onSelectTemplate: ((String) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var copiedCommandID: String?

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(guideText("一呼（Yihu）专为 OpenClaw、Hermes、Dot / Dot Live 与 Collie 等 Agent 工作台打造 iPhone 原生体验。"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(BenchsideStyle.ink)
                    Text(guideText("选择下方工作台可一键填入地址模板或复制服务端 HTTPS 映射命令。"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            ForEach(CollieWorkbenchCatalog.platforms) { item in
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            BenchsideStyle.rowBadge(item.icon)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundStyle(BenchsideStyle.ink)
                                Text(item.badge)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(BenchsideStyle.accent)
                            }
                            Spacer()
                        }

                        Text(item.summary)
                            .font(.subheadline)
                            .foregroundStyle(BenchsideStyle.ink)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(item.steps.enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("\(idx + 1).")
                                        .font(.footnote.monospacedDigit().weight(.semibold))
                                        .foregroundStyle(BenchsideStyle.accent)
                                    Text(step)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            Text(item.setupCommand)
                                .font(.caption.monospaced())
                                .foregroundStyle(BenchsideStyle.ink)
                                .lineLimit(2)
                                .textSelection(.enabled)
                            Spacer(minLength: 4)
                            Button {
                                UIPasteboard.general.string = item.setupCommand
                                copiedCommandID = item.id
                            } label: {
                                Label(
                                    copiedCommandID == item.id ? guideText("已复制") : guideText("复制命令"),
                                    systemImage: copiedCommandID == item.id ? "checkmark.circle.fill" : "doc.on.doc"
                                )
                                .font(.caption.weight(.semibold))
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .accessibilityIdentifier("collie-guide-copy-\(item.id)")
                        }
                        .padding(10)
                        .background(BenchsideStyle.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                        if let onSelectTemplate {
                            Button {
                                onSelectTemplate(item.templateOrigin)
                                dismiss()
                            } label: {
                                Label(
                                    String(format: guideText("填入 %@ 地址模板"), item.title),
                                    systemImage: "arrow.up.left.circle.fill"
                                )
                                .font(.footnote.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 38)
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("collie-guide-use-\(item.id)")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                ForEach(Array(CollieWorkbenchCatalog.manualHighlights.enumerated()), id: \.offset) { _, row in
                    HStack(alignment: .top, spacing: 12) {
                        BenchsideStyle.rowBadge(row.icon)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(row.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BenchsideStyle.ink)
                            Text(row.detail)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text(guideText("日常高频功能速查"))
            }

            Section {
                if let startURL = URL(string: "https://getyihu.com/start/#workbench-integrations") {
                    Link(destination: startURL) {
                        Label(guideText("打开在线接入文档与 Dot Live 对接说明"), systemImage: "safari")
                            .frame(minHeight: 44)
                    }
                    .accessibilityIdentifier("collie-guide-online-docs")
                }
                if let repoURL = URL(string: "https://github.com/alexlee2046/yihu-ios#readme") {
                    Link(destination: repoURL) {
                        Label(guideText("查看 GitHub 开源仓库与完整 README"), systemImage: "chevron.left.forwardslash.chevron.right")
                            .frame(minHeight: 44)
                    }
                    .accessibilityIdentifier("collie-guide-github-readme")
                }
            } header: {
                Text(guideText("在线文档与合作接入"))
            } footer: {
                Text(guideText("如需为团队工作台定制或接入 Dot Live 实时语音服务，可通过在线接入文档中的联系入口与我们对接。"))
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(BenchsideStyle.canvas)
        .tint(BenchsideStyle.accent)
        .navigationTitle(guideText("使用说明与工作台接入"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
