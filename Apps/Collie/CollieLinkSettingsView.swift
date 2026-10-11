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
                Text(session.baseURL.absoluteString)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("collie-current-workbench")
                if session.isLoading {
                    Label(settingsText("正在连接…"), systemImage: "arrow.clockwise")
                        .foregroundStyle(.secondary)
                } else if let errorMessage = session.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .font(.footnote)
                        .foregroundStyle(.red)
                    Button {
                        session.reload()
                    } label: {
                        Label(settingsText("重新加载"), systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
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
                CollieHermesPushSection(push: .shared, settings: settings)
            }

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
            Toggle(settingsText("近场收音"), isOn: $isEnabled)
                .accessibilityIdentifier("collie-near-field-capture-toggle")
                .disabled(isBusy)
            CollieMicrophoneModeControl()
                .accessibilityIdentifier("collie-microphone-mode-control")
            Text(settingsText("使用 iOS 系统语音处理；开关变更从下一次录音生效。"))
                .font(.footnote)
                .foregroundStyle(.secondary)
            if isRecording {
                Label(settingsText("录音中也可从语音输入栏打开系统麦克风模式选择。"), systemImage: "mic.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(settingsText("近场收音"))
        } footer: {
            Text(settingsText("人声突显可减少背景声音，帮助突出附近的人声。系统麦克风模式由 iOS 控制。"))
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
            Picker(settingsText("识别语言"), selection: selectedLanguage) {
                ForEach(CollieRecognitionPreferences.Language.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .accessibilityIdentifier("collie-recognition-language")
            Text(settingsText("中英混说请选择自动识别。指定中文或英文只提供单一语言提示，不保证准确率提高。"))
                .font(.footnote)
                .foregroundStyle(.secondary)
            Toggle(settingsText("使用常用词提示"), isOn: $usesTerms)
                .accessibilityIdentifier("collie-recognition-use-terms")
            Text(settingsText("关闭后保留词表，但识别时不参考。可在上方“常用词”编辑提示词及优先顺序。"))
                .font(.footnote)
                .foregroundStyle(.secondary)
            Stepper(value: boundedTokens, in: CollieRecognitionPreferences.tokenRange, step: 64) {
                LabeledContent(settingsText("最大输出 token 数"), value: boundedTokens.wrappedValue.formatted())
            }
            .accessibilityIdentifier("collie-recognition-max-tokens")
            Text(settingsText("默认 448，可调 64–1024。不是字数；设得太低可能截断转写，调高只增加输出上限，仍受模型缓存限制，不会直接提高准确率。"))
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button(settingsText("恢复默认识别参数")) {
                language = CollieRecognitionPreferences.Language.automatic.rawValue
                maxTokens = CollieRecognitionPreferences.defaultMaxTokens
                usesTerms = true
            }
            .frame(minHeight: 44)
            .accessibilityIdentifier("collie-recognition-reset")
        } header: {
            Text(settingsText("识别参数"))
        } footer: {
            Text(settingsText("自动保存在本机，从下一次识别生效，语音输入和语音笔记共用。恢复默认不改变常用词表或收音设置。当前模型固定使用 16 kHz 单声道及贪心解码，不支持温度、top-p、beam size 调节。"))
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
            NavigationLink(settingsText("只认我的声音")) { CollieVoiceprintSettingsView(voice: voice) }
                .accessibilityIdentifier("collie-voiceprint-settings")
            LabeledContent(settingsText("状态"), value: status)
                .accessibilityIdentifier("collie-voice-model-status")
            NavigationLink {
                CollieRecognitionTermsView(voice: voice)
            } label: {
                LabeledContent(settingsText("常用词"), value: voice.recognitionTerms.isEmpty ? settingsText("未使用") : voice.recognitionTerms.count.formatted())
                    .frame(minHeight: 44)
            }
            .accessibilityIdentifier("collie-recognition-terms")
            if voice.phase == .ready, !voice.canRetryDelivery {
                Button(settingsText("删除语音模型"), role: .destructive) { confirmingRemoval = true }
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("collie-voice-model-remove")
            }
        } header: {
            Text(settingsText("语音输入"))
        } footer: {
            Text(settingsText("语音只在这台 iPhone 上识别，不会上传。"))
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
        default: settingsText("已下载（约 950 MB）")
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
                Text(settingsText("识别时会参考这些词，适合常说的英文术语、产品名和人名。越靠前越优先；录音越长，能带上的词越少。清空即不使用。"))
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
    var settings: CollieConnectionSettings? = nil

    @State private var relayDraft = ""
    @State private var relayNotice: String?

    private var suggestedURL: URL? {
        CollieHermesPush.suggestedRelayURL(for: settings?.recentOrigins ?? [])
    }

    var body: some View {
        Section {
            Toggle(isOn: Binding(
                get: { push.isRequested },
                set: { on in
                    if on {
                        if push.relayURL?.host == "relay.example.invalid" && relayDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            relayNotice = settingsText("请先填写有效的 Hermes Relay 服务地址（必须以 https:// 开头）。")
                            return
                        }
                        applyRelayDraft()
                        Task { await push.enable() }
                    } else {
                        push.disable()
                    }
                }
            )) {
                Text(settingsText("Hermes 任务提醒")).frame(minHeight: 44, alignment: .leading)
            }
            .accessibilityIdentifier("collie-hermes-push")

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(settingsText("Relay 服务地址")).font(.subheadline)
                    Spacer()
                    if let suggested = suggestedURL, relayDraft != suggested.absoluteString {
                        Button(settingsText("填入工作台地址")) {
                            relayDraft = suggested.absoluteString
                            applyRelayDraft()
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                    }
                }
                HStack {
                    TextField("https://relay.example.com:9444", text: $relayDraft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .font(.callout.monospaced())
                        .frame(minHeight: 36)
                        .onChange(of: relayDraft) { _, _ in
                            relayNotice = nil
                        }
                        .onSubmit {
                            applyRelayDraft()
                        }
                    if relayDraft != push.configuredRelayString {
                        Button(settingsText("保存")) {
                            applyRelayDraft()
                        }
                        .font(.caption.bold())
                        .buttonStyle(.borderedProminent)
                    }
                }
                if let notice = relayNotice {
                    Text(notice).font(.footnote).foregroundStyle(.orange)
                }
            }
            .padding(.vertical, 4)

            switch push.status {
            case .registering:
                Label(settingsText("正在登记…"), systemImage: "arrow.triangle.2.circlepath").font(.footnote)
            case .failed(let message):
                VStack(alignment: .leading, spacing: 4) {
                    Text(message).font(.footnote).foregroundStyle(.orange)
                    Button(settingsText("重试连接")) {
                        push.retryIfNeeded()
                    }
                    .font(.caption)
                    .buttonStyle(.borderless)
                }
            case .on:
                Label(settingsText("实时活动与提醒已就绪"), systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
            case .off:
                EmptyView()
            }
        } header: {
            Text(settingsText("任务提醒"))
        } footer: {
            Text(settingsText("在 Hermes WebUI 里交代的任务，会在锁屏和灵动岛显示进度，完成后提醒你。只包含工具名和状态，不含对话内容。必须使用 HTTPS 且需要开启 Tailscale。"))
        }
        .onAppear {
            relayDraft = push.configuredRelayString.isEmpty
                ? (suggestedURL?.absoluteString ?? "")
                : push.configuredRelayString
        }
    }

    private func applyRelayDraft() {
        let trimmed = relayDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            push.updateRelayURL("")
            relayNotice = nil
            return
        }
        guard let url = CollieHermesPush.validateRelayURL(trimmed) else {
            relayNotice = settingsText("地址必须是以 https:// 开头的合法 URL，不能带查询参数。")
            return
        }
        relayDraft = url.absoluteString
        push.updateRelayURL(url.absoluteString)
        relayNotice = nil
    }
}
