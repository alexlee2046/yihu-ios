import Foundation
import SwiftUI

// Resolve plain runtime strings through the same table as the shell's SwiftUI labels.
private func settingsText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

/// The single, stable settings entry point for the native shell.
struct CollieLinkSettingsView: View {
    @AppStorage(CollieAudioCapturePreferences.nearFieldCaptureKey) private var nearFieldCaptureEnabled = true
    let session: CollieWebSession
    let notifications: CollieNativeNotificationsController
    let voice: CollieVoiceController
    let settings: CollieConnectionSettings
    var onWillSave: ((URL) -> String?)?
    var onSaved: ((URL) -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    BenchsideStyle.rowBadge("globe", tint: session.errorMessage == nil ? BenchsideStyle.accent : .orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(settings.name(for: session.baseURL))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(BenchsideStyle.ink)
                        Text(session.baseURL.absoluteString)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("collie-current-workbench")
                    }
                    Spacer()
                }
                .padding(.vertical, 2)
                if session.isLoading {
                    Label(settingsText("正在连接…"), systemImage: "arrow.clockwise")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if let errorMessage = session.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .font(.footnote)
                        .foregroundStyle(.red)
                    Button {
                        session.reload()
                    } label: {
                        Label(settingsText("重新加载"), systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    }
                    .accessibilityIdentifier("collie-reconnect")
                }
            } header: {
                Text(settingsText("当前工作台"))
            }

            CollieNativeNotificationsSection(controller: notifications, session: session)

            CollieVoiceModelSection(voice: voice)

            CollieRecognitionParametersSection(
                isBusy: voice.isRecording || voice.canCancel || voice.phase == .delivering
            )

            CollieNearFieldCaptureSection(
                isEnabled: $nearFieldCaptureEnabled,
                isRecording: voice.isRecording,
                isBusy: voice.canCancel || voice.phase == .delivering
            )

            if CollieHermesPush.shared.shouldShowSettings(for: settings.recentOrigins) {
                CollieHermesPushSection(push: .shared)
            }

            CollieHotspotBridgeSection(bridge: .shared)

            Section {
                NavigationLink {
                    CollieConnectionSettingsView(
                        settings: settings,
                        notifications: notifications,
                        webSession: session,
                        onWillSave: onWillSave,
                        onSaved: onSaved
                    )
                } label: {
                    Label(settingsText("更换工作台"), systemImage: "arrow.triangle.2.circlepath")
                        .frame(minHeight: 44)
                }
                .accessibilityIdentifier("collie-change-workbench")
            }

            Section {
                NavigationLink { CollieCreditsView() } label: {
                    Label(settingsText("关于与开源许可"), systemImage: "info.circle")
                        .frame(minHeight: 44)
                }
                .accessibilityIdentifier("collie-credits")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(settingsText("一呼设置"))
        .navigationBarTitleDisplayMode(.large)
        .tint(BenchsideStyle.accent)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button(settingsText("完成")) { dismiss() } }
        }
    }
}

struct CollieNearFieldCaptureSection: View {
    @Binding var isEnabled: Bool
    let isRecording: Bool
    let isBusy: Bool

    var body: some View {
        Section {
            Toggle(isOn: $isEnabled) {
                Label(settingsText("近场收音"), systemImage: "mic.badge.plus")
            }
            .accessibilityIdentifier("collie-near-field-capture-toggle")
            .disabled(isBusy)
            CollieMicrophoneModeControl()
                .accessibilityIdentifier("collie-microphone-mode-control")
            if isRecording {
                Label(settingsText("录音中也可在底部栏切换麦克风模式。"), systemImage: "mic.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(settingsText("近场收音"))
        } footer: {
            Text(settingsText("开启后可减弱环境杂音，突出近处说话声。"))
        }
    }
}

/// Keep supported ASR controls beside the existing vocabulary and capture settings.
struct CollieRecognitionParametersSection: View {
    @AppStorage(CollieRecognitionPreferences.languageKey) private var language = "automatic"
    @AppStorage(CollieRecognitionPreferences.maxTokensKey) private var maxTokens = CollieRecognitionPreferences.defaultMaxTokens
    @AppStorage(CollieRecognitionPreferences.usesTermsKey) private var usesTerms = true
    let isBusy: Bool

    private var selectedLanguage: Binding<CollieRecognitionPreferences.Language> {
        Binding(
            get: { CollieRecognitionPreferences.Language(rawValue: language) ?? .automatic },
            set: { language = $0.rawValue }
        )
    }

    private var boundedTokens: Binding<Int> {
        Binding(
            get: { CollieRecognitionPreferences.clampTokens(maxTokens) },
            set: { maxTokens = CollieRecognitionPreferences.clampTokens($0) }
        )
    }

    var body: some View {
        Section {
            Picker(selection: selectedLanguage) {
                ForEach(CollieRecognitionPreferences.Language.allCases) { option in
                    Text(option.label).tag(option)
                }
            } label: {
                Label(settingsText("识别语言"), systemImage: "globe.asia.australia")
            }
            .accessibilityIdentifier("collie-recognition-language")
            Toggle(isOn: $usesTerms) {
                Label(settingsText("使用常用词提示"), systemImage: "text.badge.checkmark")
            }
            .accessibilityIdentifier("collie-recognition-use-terms")
            Stepper(value: boundedTokens, in: CollieRecognitionPreferences.tokenRange, step: 64) {
                LabeledContent {
                    Text(boundedTokens.wrappedValue.formatted())
                        .monospacedDigit()
                } label: {
                    Label(settingsText("单次输出上限"), systemImage: "number")
                }
            }
            .accessibilityIdentifier("collie-recognition-max-tokens")
            Button {
                language = CollieRecognitionPreferences.Language.automatic.rawValue
                maxTokens = CollieRecognitionPreferences.defaultMaxTokens
                usesTerms = true
            } label: {
                Label(settingsText("恢复默认参数"), systemImage: "arrow.counterclockwise")
                    .frame(minHeight: 44)
            }
            .accessibilityIdentifier("collie-recognition-reset")
        } header: {
            Text(settingsText("识别参数"))
        } footer: {
            Text(settingsText("默认自动识别中英文。常说的专有名词可添加到上方「常用词」。"))
        }
        .disabled(isBusy)
    }
}

/// Makes the ~950 MB on-device model visible and removable; downloading stays on the voice card.
struct CollieVoiceModelSection: View {
    let voice: CollieVoiceController
    @State private var confirmingRemoval = false

    var body: some View {
        Section {
            NavigationLink {
                CollieVoiceprintSettingsView(voice: voice)
            } label: {
                Label(settingsText("只认我的声音"), systemImage: "waveform.badge.person.crop")
                    .frame(minHeight: 44)
            }
            .accessibilityIdentifier("collie-voiceprint-settings")
            LabeledContent {
                Text(status)
            } label: {
                Label(settingsText("离线模型"), systemImage: "cpu")
            }
            .accessibilityIdentifier("collie-voice-model-status")
            NavigationLink {
                CollieRecognitionTermsView(voice: voice)
            } label: {
                LabeledContent {
                    Text(voice.recognitionTerms.isEmpty ? settingsText("未设置") : voice.recognitionTerms.count.formatted())
                } label: {
                    Label(settingsText("常用词"), systemImage: "character.book.closed")
                }
                .frame(minHeight: 44)
            }
            .accessibilityIdentifier("collie-recognition-terms")
            if voice.phase == .ready, !voice.canRetryDelivery {
                Button(role: .destructive) { confirmingRemoval = true } label: {
                    Label(settingsText("删除语音模型"), systemImage: "trash")
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .accessibilityIdentifier("collie-voice-model-remove")
            }
        } header: {
            Text(settingsText("语音输入"))
        } footer: {
            Text(settingsText("语音在本机离线识别，不会上传。"))
        }
        .confirmationDialog(settingsText("删除语音模型？"), isPresented: $confirmingRemoval, titleVisibility: .visible) {
            Button(settingsText("删除"), role: .destructive) { Task { await voice.removeModel() } }
            Button(settingsText("取消"), role: .cancel) {}
        } message: {
            Text(settingsText("可释放约 950 MB 空间。之后使用语音输入需要重新下载。"))
        }
    }

    private var status: String {
        switch voice.phase {
        case .checkingModel: settingsText("正在检查…")
        case .needsModel: settingsText("未下载（约 950 MB）")
        case .downloading: String(format: settingsText("正在下载 %lld%%"), Int64(voice.downloadProgress * 100))
        case .failed where voice.failureKind == .modelDownload: settingsText("下载未完成")
        case .failed where voice.failureKind == .model: settingsText("无法加载")
        default: settingsText("已就绪（约 950 MB）")
        }
    }
}

/// Edits the expected-vocabulary list; one term per line, earlier lines take priority.
struct CollieRecognitionTermsView: View {
    let voice: CollieVoiceController
    @Environment(\.scenePhase) private var scenePhase
    @State private var text = ""
    @State private var loaded = false

    var body: some View {
        Form {
            Section {
                TextEditor(text: $text)
                    .font(.body.monospaced())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .frame(minHeight: 260)
                    .accessibilityLabel(settingsText("常用词，每行一个"))
                    .accessibilityIdentifier("collie-recognition-terms-editor")
            } header: {
                Text(settingsText("每行一个"))
            } footer: {
                Text(settingsText("适合常说的英文缩写、产品名和人名，越靠前越优先。"))
            }
            Section {
                Button(settingsText("恢复默认词表")) {
                    voice.setRecognitionTerms(nil)
                    text = voice.recognitionTerms.joined(separator: "\n")
                }
                .frame(minHeight: 44)
            }
        }
        .navigationTitle(settingsText("常用词"))
        .navigationBarTitleDisplayMode(.inline)
        .tint(BenchsideStyle.accent)
        .onAppear {
            guard !loaded else { return }
            loaded = true
            text = voice.recognitionTerms.joined(separator: "\n")
        }
        .onDisappear(perform: save)
        // The app may be killed in the background without the page ever disappearing.
        .onChange(of: scenePhase) { _, phase in if phase != .active { save() } }
    }

    private func save() {
        let edited = CollieRecognitionTerms.parse(text)
        if edited != voice.recognitionTerms { voice.setRecognitionTerms(edited) }
    }
}

/// Hermes task reminders: lock-screen progress and completion pushes for tasks
/// started in the Hermes WebUI, delivered by the tailnet-only relay on your separately configured server.
struct CollieHermesPushSection: View {
    let push: CollieHermesPush

    var body: some View {
        Section {
            Toggle(isOn: Binding(
                get: { push.isRequested },
                set: { on in if on { Task { await push.enable() } } else { push.disable() } }
            )) {
                Text(settingsText("Hermes 任务提醒")).frame(minHeight: 44, alignment: .leading)
            }
            .accessibilityIdentifier("collie-hermes-push")
            switch push.status {
            case .registering: Label(settingsText("正在登记…"), systemImage: "arrow.triangle.2.circlepath").font(.footnote)
            case .failed(let message): Text(message).font(.footnote).foregroundStyle(.orange)
            case .on, .off: EmptyView()
            }
        } header: {
            Text(settingsText("任务提醒"))
        } footer: {
            Text(settingsText("在锁屏和灵动岛显示任务进度，完成后推送通知（需开启 Tailscale）。"))
        }
    }
}

/// BLE proximity hotspot wake: detects when the paired MacBook is nearby and offline,
/// then wakes its Bluetooth/Wi-Fi hotspot connection and optionally triggers the iOS Hotspot Shortcut.
struct CollieHotspotBridgeSection: View {
    @Bindable var bridge: CollieHotspotBridge

    var body: some View {
        Section {
            Toggle(isOn: $bridge.isEnabled) {
                Label(settingsText("靠近断网 Mac 时自动唤醒"), systemImage: "laptopcomputer.and.iphone")
            }
            .accessibilityIdentifier("collie-hotspot-ble-toggle")
            if bridge.isEnabled {
                Text(bridge.statusSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("collie-hotspot-ble-status")
            }
            Toggle(isOn: $bridge.autoRunShortcutInForeground) {
                Label(settingsText("同时运行快捷指令开启热点"), systemImage: "bolt.horizontal.circle")
            }
            .accessibilityIdentifier("collie-hotspot-shortcut-toggle")
            LabeledContent {
                TextField(CollieHotspotBLEProtocol.defaultHotspotSSID, text: $bridge.hotspotSSID)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("collie-hotspot-ssid")
            } label: {
                Label(settingsText("热点名称"), systemImage: "wifi")
            }
            if bridge.autoRunShortcutInForeground {
                LabeledContent {
                    TextField(CollieHotspotBLEProtocol.defaultShortcutName, text: $bridge.shortcutName)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("collie-hotspot-shortcut-name")
                } label: {
                    Label(settingsText("快捷指令"), systemImage: "square.stack.3d.up")
                }
            }
            Button {
                bridge.triggerManualWake(runShortcut: bridge.autoRunShortcutInForeground)
            } label: {
                Label(settingsText("立即唤醒附近 Mac"), systemImage: "personalhotspot")
                    .frame(minHeight: 44)
            }
            .accessibilityIdentifier("collie-hotspot-wake-now")
        } header: {
            Text(settingsText("Mac 热点唤醒"))
        } footer: {
            Text(settingsText("当断网的 MacBook 在附近时，通过蓝牙自动连回这台 iPhone 的个人热点。"))
        }
    }
}
