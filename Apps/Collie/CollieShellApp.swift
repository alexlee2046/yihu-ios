import AVFoundation
import Foundation
import SwiftUI

private func shellText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

@main
struct CollieShellApp: App {
    @UIApplicationDelegateAdaptor(CollieNativePushAppDelegate.self) private var appDelegate
    @State private var notifications = CollieNativeNotificationsController()
    @State private var connectionSettings = CollieConnectionSettings()
    @State private var voice: CollieVoiceController
    @State private var voiceNotes: CollieVoiceNotesStore

    init() {
        let voice = CollieVoiceController()
        _voice = State(initialValue: voice)
        _voiceNotes = State(initialValue: CollieVoiceNotesStore(
            transcriber: voice.transcriber,
            // Notes yield to live dictation and only run in the foreground.
            canTranscribe: { [weak voice] in
                guard let voice else { return false }
                return !voice.canCancel && voice.phase != .delivering
                    && UIApplication.shared.applicationState == .active
            },
            terms: { [weak voice] in voice?.recognitionTerms ?? [] },
            canRecord: { [weak voice] in voice.map { !$0.canCancel && $0.phase != .delivering } ?? false }
        ))
    }

    var body: some Scene {
        WindowGroup {
            CollieRootView(settings: connectionSettings, voice: voice, notifications: notifications,
                           voiceNotes: voiceNotes)
                .task { appDelegate.bind(controller: notifications) }
                .onOpenURL { url in CollieShareTrayModel.shared.importOpened(url) }
        }
    }
}

@MainActor
@Observable
final class CollieConnectionRuntime {
    private(set) var webSession: CollieWebSession?
    @ObservationIgnored private(set) weak var transcriptTarget: CollieWebSession?

    static func voiceBlockReason(_ voice: CollieVoiceController) -> String? {
        if voice.canCancel { return shellText("录音或转写正在进行，请先完成或取消，不能在此时切换服务。") }
        if voice.phase == .delivering { return shellText("转写文字正在交付，请等待完成后再切换服务。") }
        if voice.canRetryDelivery { return shellText("存在尚未填入的转写文字，请先填入或明确放弃，避免丢失草稿。") }
        return nil
    }

    func switchBlockReason(to origin: URL, voice: CollieVoiceController,
                           notifications: CollieNativeNotificationsController) -> String? {
        if webSession?.baseURL == origin { return nil }
        if notifications.isBusy { return shellText("正在开启或停用通知，请等待完成后再切换工作台。") }
        return Self.voiceBlockReason(voice)
    }

    func installConnection(_ origin: URL, voice: CollieVoiceController,
                           notifications: CollieNativeNotificationsController,
                           voiceNotes: CollieVoiceNotesStore? = nil) {
        guard webSession?.baseURL != origin else { return }
        webSession?.invalidate()
        let newSession = CollieWebSession(baseURL: origin)
        webSession = newSession
        notifications.navigationBlockReason = { [weak voice, weak voiceNotes, weak notifications] in
            guard let voice else { return shellText("无法检查语音输入状态，请稍后重试。") }
            if voiceNotes?.recorder.isRecording == true {
                return shellText("请先结束语音笔记录音，再切换工作台。")
            }
            if notifications?.isBusy == true {
                return shellText("正在开启或停用通知，请等待完成后再切换工作台。")
            }
            return Self.voiceBlockReason(voice)
        }
        notifications.canNavigate = { [weak notifications] in
            guard let notifications else { return false }
            return notifications.navigationBlockReason() == nil
        }
        // activate can synchronously deliver a cold-start tap and reenter here.
        transcriptTarget = newSession
        voice.deliverTranscript = { [weak newSession, weak self] transcript in
            guard let newSession, self?.webSession === newSession else { return false }
            return await newSession.insertTranscript(transcript)
        }
        notifications.activate(session: newSession)
    }
}

@MainActor
@Observable
final class CollieShellPresentation {
    var settingsPresented = false
    var notesPresented = false
}

@MainActor
private struct CollieRootView: View {
    let settings: CollieConnectionSettings
    let voice: CollieVoiceController
    let notifications: CollieNativeNotificationsController
    let voiceNotes: CollieVoiceNotesStore
    @State private var connection = CollieConnectionRuntime()
    @State private var radar = CollieRadarStore()
    @State private var shortcuts = CollieWorkbenchShortcuts()
    @State private var shellPresentation = CollieShellPresentation()
    @State private var radarPresentation = CollieRadarPresentation()
    @AppStorage("collie.workbench.selection.v1") private var selection = "web"
    @State private var workbenchesPresented = false
    @State private var addingWeb = false
    @State private var pendingAddWeb = false
    @State private var selectionNotice: String?
    private var webSession: CollieWebSession? { connection.webSession }
    private var selectedRadar: UUID? {
        guard let id = UUID(uuidString: selection), radar.workbenches.contains(where: { $0.id == id }) else { return nil }
        return id
    }

    private var shortcutItems: [CollieWorkbenchShortcutItem] {
        // Keep the primary web entry and native radar together on first use.
        // An explicit user shortcut order always takes precedence in the model.
        let web = settings.recentOrigins.map {
            CollieWorkbenchShortcutItem(id: $0.absoluteString, name: settings.name(for: $0), icon: "globe")
        }
        let native = radar.workbenches.map {
            CollieWorkbenchShortcutItem(id: $0.id.uuidString, name: $0.name, icon: "scope")
        }
        return Array(web.prefix(1)) + native + Array(web.dropFirst())
    }

    private var shortcutBar: CollieWorkbenchShortcutBar {
        CollieWorkbenchShortcutBar(shortcuts: shortcuts, items: shortcutItems,
                                  selected: selectedRadar?.uuidString ?? settings.currentOrigin?.absoluteString,
                                  select: { id in
            if let radarID = UUID(uuidString: id) { _ = selectRadar(radarID) }
            else if let origin = settings.recentOrigins.first(where: { $0.absoluteString == id }) { _ = selectWeb(origin) }
        }, openAll: { workbenchesPresented = true })
    }

    private var workbenchHeader: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Text(selectedRadar.flatMap { id in radar.workbenches.first { $0.id == id }?.name } ?? radarText("一呼"))
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                Spacer(minLength: 8)
                if let id = selectedRadar, let item = radar.workbenches.first(where: { $0.id == id }) {
                    CollieRadarActions(store: radar, item: item, presentation: radarPresentation)
                } else if webSession != nil {
                    Button { shellPresentation.notesPresented = true } label: {
                        Image(systemName: "waveform").frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(radarText("语音记录"))
                    .accessibilityIdentifier("collie-voice-notes")
                    Button { shellPresentation.settingsPresented = true } label: {
                        Image(systemName: "gearshape").frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(radarText("一呼设置"))
                    .accessibilityIdentifier("collie-connection-settings")
                }
            }
            shortcutBar
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(BenchsideStyle.surface)
        .overlay(alignment: .bottom) { Divider().accessibilityHidden(true) }
        .tint(BenchsideStyle.accent)
    }

    var body: some View {
        VStack(spacing: 0) {
            workbenchHeader
            ZStack {
                if let webSession, settings.currentOrigin != nil {
                    CollieShellView(
                        webSession: webSession,
                        voice: voice,
                        voiceNotes: voiceNotes,
                        connectionSettings: settings,
                        notifications: notifications,
                        onWillSaveConnection: connectionChangeBlockReason,
                        onSavedConnection: installConnection,
                        onOpenWorkbenches: { workbenchesPresented = true },
                        showsHeader: false,
                        presentation: shellPresentation,
                        isWorkbenchActive: selectedRadar == nil
                    )
                    .id(webSession.baseURL.absoluteString)
                    .opacity(selectedRadar == nil ? 1 : 0)
                    .allowsHitTesting(selectedRadar == nil)
                    .accessibilityHidden(selectedRadar != nil)
                } else if selectedRadar == nil {
                    VStack(spacing: 0) {
                        CollieConnectionSettingsView(
                            settings: settings,
                            isInitialSetup: true,
                            onWillSave: connectionChangeBlockReason,
                            onSaved: installConnection
                        )
                    }
                    .opacity(selectedRadar == nil ? 1 : 0)
                    .allowsHitTesting(selectedRadar == nil)
                    .accessibilityHidden(selectedRadar != nil)
                }
                if let id = selectedRadar {
                    CollieRadarView(store: radar, id: id, presentation: radarPresentation)
                        .id(id)
                }
            }
        }
        .sheet(isPresented: $workbenchesPresented, onDismiss: {
            if pendingAddWeb { pendingAddWeb = false; addingWeb = true }
        }) {
            CollieWorkbenchPicker(settings: settings, radar: radar, selectedRadar: selectedRadar,
                                  selectWeb: selectWeb, selectRadar: selectRadar,
                                  addWeb: { pendingAddWeb = true }, notice: selectionNotice,
                                  shortcuts: shortcuts)
        }
        .sheet(isPresented: $addingWeb) {
            NavigationStack {
                CollieConnectionSettingsView(settings: settings, onWillSave: connectionChangeBlockReason,
                                             onSaved: { origin in addingWeb = false; installConnection(origin) })
                    .toolbar { ToolbarItem(placement: .cancellationAction) {
                        Button(radarText("取消")) { addingWeb = false }
                    } }
            }
        }
        .alert(radarText("暂时不能切换工作台"), isPresented: Binding(
            get: { selectionNotice != nil && !workbenchesPresented && !addingWeb },
            set: { if !$0 { selectionNotice = nil } }
        )) { Button(radarText("完成"), role: .cancel) { selectionNotice = nil } }
        message: { Text(selectionNotice ?? "") }
        .task {
            let settings = self.settings
            let notifications = self.notifications
            settings.isNotificationEnabled = { [weak notifications] origin in
                notifications?.isEnabled(for: origin) == true
            }
            notifications.knownOrigins = { [weak settings] in settings?.recentOrigins ?? [] }
            notifications.onOpenWorkbench = { if canSelect() { selection = "web" } }
            notifications.onSwitchOrigin = { origin in
                guard canSelect() else { return selectionNotice }
                selection = "web"
                return settings.quickSwitch(to: origin, from: webSession?.baseURL,
                                     blockedReason: connectionChangeBlockReason,
                                     onSaved: installConnection)
            }
            if webSession == nil, let origin = settings.currentOrigin {
                let previousSelection = selection
                connection.installConnection(origin, voice: voice, notifications: notifications, voiceNotes: voiceNotes)
                // A notification may have switched selection during activation.
                if selection == previousSelection, selectedRadar == nil { selection = "web" }
            }
            await voice.refreshModelState()
            if ProcessInfo.processInfo.environment["COLLIE_AUTO_DOWNLOAD_MODEL"] == "1",
               voice.phase == .needsModel {
                await voice.performPrimaryAction()
            }
            if ProcessInfo.processInfo.environment["COLLIE_VALIDATE_MODEL"] == "1" {
                let runID = ProcessInfo.processInfo.environment["COLLIE_VALIDATION_RUN_ID"] ?? "manual"
                let error = await voice.validateInstalledModel()
                writeValidationStatus("\(runID):" + (error.map { "failed: \($0)" } ?? "ready"))
            }
        }
    }

    private func writeValidationStatus(_ status: String) {
        guard let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return }
        try? FileManager.default.createDirectory(at: applicationSupport, withIntermediateDirectories: true)
        try? status.write(
            to: applicationSupport.appendingPathComponent("collie-model-validation.txt"),
            atomically: true,
            encoding: .utf8
        )
    }

    private func connectionChangeBlockReason(_ origin: URL) -> String? {
        guard canSelect() else { return selectionNotice }
        return connection.switchBlockReason(to: origin, voice: voice, notifications: notifications)
    }

    private func installConnection(_ origin: URL) {
        selection = "web"
        connection.installConnection(origin, voice: voice, notifications: notifications, voiceNotes: voiceNotes)
    }

    private func canSelect() -> Bool {
        if voiceNotes.recorder.isRecording {
            selectionNotice = radarText("请先结束语音笔记录音，再切换工作台。")
        } else if notifications.isBusy {
            selectionNotice = radarText("正在开启或停用通知，请等待完成后再切换工作台。")
        } else {
            selectionNotice = CollieConnectionRuntime.voiceBlockReason(voice)
        }
        return selectionNotice == nil
    }

    private func selectWeb(_ origin: URL) -> Bool {
        if selectedRadar == nil, origin == settings.currentOrigin { return true }
        guard canSelect() else { return false }
        if let reason = settings.quickSwitch(to: origin, from: webSession?.baseURL,
                                             blockedReason: connectionChangeBlockReason,
                                             onSaved: installConnection) {
            selectionNotice = reason
            return false
        }
        installConnection(origin)
        return true
    }

    private func selectRadar(_ id: UUID) -> Bool {
        if selectedRadar == id { return true }
        guard canSelect(), radar.workbenches.contains(where: { $0.id == id }) else { return false }
        webSession?.dismissKeyboard()
        selection = id.uuidString
        return true
    }
}

struct CollieShellView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let webSession: CollieWebSession
    let voice: CollieVoiceController
    private let voiceNotes: CollieVoiceNotesStore?
    private let connectionSettings: CollieConnectionSettings?
    private let notifications: CollieNativeNotificationsController?
    private let onWillSaveConnection: ((URL) -> String?)?
    private let onSavedConnection: ((URL) -> Void)?
    private let onOpenWorkbenches: (() -> Void)?
    private let showsHeader: Bool
    @Bindable private var presentation: CollieShellPresentation
    private let isWorkbenchActive: Bool
    @State private var pendingRecoveryMessage: String?
    @State private var switchNotice: String?
    @State private var renameOrigin: URL?
    @State private var renameDraft = ""
    @State private var showRename = false
    @State private var placement = CollieVoicePlacement()
    @State private var voiceDrag = CGSize.zero
    private let shortcuts = CollieVoiceShortcutCenter.shared
    private let shareTray = CollieShareTrayModel.shared
    private let hermesPush = CollieHermesPush.shared

    init(
        webSession: CollieWebSession,
        voice: CollieVoiceController,
        voiceNotes: CollieVoiceNotesStore? = nil,
        connectionSettings: CollieConnectionSettings? = nil,
        notifications: CollieNativeNotificationsController? = nil,
        onWillSaveConnection: ((URL) -> String?)? = nil,
        onSavedConnection: ((URL) -> Void)? = nil,
        onOpenWorkbenches: (() -> Void)? = nil,
        showsHeader: Bool = true,
        presentation: CollieShellPresentation = CollieShellPresentation(),
        isWorkbenchActive: Bool = true
    ) {
        self.webSession = webSession
        self.voice = voice
        self.voiceNotes = voiceNotes
        self.connectionSettings = connectionSettings
        self.notifications = notifications
        self.onWillSaveConnection = onWillSaveConnection
        self.onSavedConnection = onSavedConnection
        self.onOpenWorkbenches = onOpenWorkbenches
        self.showsHeader = showsHeader
        self.presentation = presentation
        self.isWorkbenchActive = isWorkbenchActive
    }

    private var shellContent: some View {
        VStack(spacing: 0) {
            // Keep the WKWebView mounted when Radar is active, but not its
            // native navigation controls (opacity alone leaves them in AX).
            if showsHeader, connectionSettings != nil, isWorkbenchActive {
                shellHeader
            }

            ZStack {
                CollieWebView(
                    session: webSession,
                    isVisible: isWorkbenchActive,
                    pageReady: { notifications?.applicationDidBecomeActive(session: webSession) },
                    openNotificationSettings: { presentation.settingsPresented = true }
                ) {
                    guard !voice.canCancel, voice.phase != .delivering else { return }
                    await webSession.setKeyboardEnabled(true)
                }

            if let errorMessage = webSession.errorMessage {
                CollieConnectionErrorView(
                    message: errorMessage,
                    reload: { webSession.reload() },
                    changeConnection: { presentation.settingsPresented = true }
                )
            } else if webSession.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(BenchsideStyle.accent)
                    Text(shellText("正在连接工作台…"))
                        .font(.headline)
                    Text(shellText("正在建立安全连接"))
                        .font(.footnote)
                        .foregroundStyle(BenchsideStyle.secondary)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .background(BenchsideStyle.surfaceRaised, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(BenchsideStyle.border, lineWidth: 1)
                }
                .allowsHitTesting(false)
            }
        }
        }
        .background(BenchsideStyle.canvas)
        .overlay(alignment: .top) {
            CollieShareTray(model: shareTray, session: webSession)
        }
        .overlay {
            GeometryReader { geometry in
                if voiceNotes?.recorder.isRecording != true,
                   !webSession.keyboardVisible || voice.phase != .ready || voice.canRetryDelivery {
                    CollieVoiceBar(
                        voice: voice,
                        beforeVoiceStart: { webSession.dismissKeyboard() },
                        pendingRecoveryTitle: webSession.isConnected ? (voice.voiceprintBlocked ? shellText("仍然填入") : shellText("再次填入")) : shellText("重新连接并填入"),
                        pendingRecoveryNotice: pendingRecoveryMessage ?? (voice.voiceprintBlocked ? voice.notice : nil),
                        recoverPendingTranscript: recoverPendingTranscript,
                        side: placement.side,
                        onReposition: { voiceDrag = placement.clampedDrag($0, in: geometry.size) },
                        onRepositionEnded: { translation in
                            updatePlacement(placement.moved(by: translation, in: geometry.size))
                        },
                        onFlipSide: { updatePlacement(placement.flipped()) }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, placement.bottom)
                    .offset(voiceDrag)
                    .frame(maxWidth: .infinity, maxHeight: .infinity,
                           alignment: placement.side == .leading ? .bottomLeading : .bottomTrailing)
                }
            }
        }
        .background {
            // Hardware keyboard: ⌘⇧D starts or finishes voice input.
            Button(shellText("语音输入")) { shortcuts.requestToggle() }
                .keyboardShortcut("d", modifiers: [.command, .shift])
                .disabled(!isWorkbenchActive)
                .opacity(0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .onAppear {
            placement = CollieVoicePlacement.load(for: webSession.baseURL)
            connectionSettings?.rememberPageTitle(webSession.pageTitle, for: webSession.baseURL)
            shareTray.refresh()
            runPendingShortcut()
        }
    }

    private var observedShell: some View {
        shellContent
        .onChange(of: shortcuts.pendingToggle) { _, _ in runPendingShortcut() }
        .onChange(of: isWorkbenchActive) { _, active in if active { runPendingShortcut() } }
        .onChange(of: hermesPush.pendingURL) { _, _ in openPendingHermesURL() }
        .onChange(of: webSession.isConnected) { _, _ in openPendingHermesURL() }
        .onChange(of: webSession.pageTitle) { _, title in
            connectionSettings?.rememberPageTitle(title, for: webSession.baseURL)
        }
        .onChange(of: voice.phase) { _, _ in
            clearSwitchNoticesIfAllowed()
            runPendingShortcut()
            openPendingHermesURL()
            // Live dictation owns the model: pause note transcription, resume when idle.
            if voice.canCancel { voiceNotes?.pauseTranscription() } else { voiceNotes?.resumeTranscription() }
        }
        .onChange(of: voice.canCancel || voice.phase == .delivering) { _, blocked in
            if blocked { webSession.dismissKeyboard() }
            else { clearSwitchNoticesIfAllowed() }
        }
        .onChange(of: voice.canRetryDelivery) { _, canRetry in
            if !canRetry { pendingRecoveryMessage = nil }
            clearSwitchNoticesIfAllowed()
        }
        .onChange(of: notifications?.isBusy) { _, _ in clearSwitchNoticesIfAllowed() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                voice.applicationDidBecomeActive()
                shareTray.refresh()
                voiceNotes?.resumeTranscription()
                hermesPush.retryIfNeeded()
                runPendingShortcut()
                if !webSession.isLoading { notifications?.applicationDidBecomeActive(session: webSession) }
            } else {
                voice.applicationDidResignActive(isBackground: phase == .background)
                voiceNotes?.pauseTranscription() // no model inference in the background
                webSession.dismissKeyboard()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            guard isWorkbenchActive else { return }
            webSession.setKeyboardVisible(true)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            guard isWorkbenchActive else { return }
            webSession.setKeyboardVisible(false)
        }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { notification in
            guard
                let rawValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                AVAudioSession.InterruptionType(rawValue: rawValue) == .began
            else { return }
            voice.cancelRecording(reason: shellText("录音被系统中断，请重试。"))
        }
    }

    var body: some View {
        observedShell
        .sheet(isPresented: $presentation.notesPresented) {
            if let voiceNotes {
                NavigationStack {
                    CollieVoiceNotesView(store: voiceNotes) { shareTray.refresh() }
                }
                .presentationDragIndicator(.visible)
                .presentationBackground(BenchsideStyle.canvas)
            }
        }
        .alert(shellText("重命名工作台"), isPresented: $showRename) {
            TextField(shellText("工作台名称"), text: $renameDraft)
            Button(shellText("取消"), role: .cancel) { renameOrigin = nil }
            Button(shellText("保存")) {
                if let renameOrigin { connectionSettings?.rename(renameOrigin, to: renameDraft) }
                renameOrigin = nil
            }
        } message: {
            Text(shellText("名称保存在本机的本地设置中；清空可恢复页面标题或地址。"))
        }
        .sheet(isPresented: $presentation.settingsPresented) {
            NavigationStack {
                if let connectionSettings, let notifications {
                    CollieLinkSettingsView(
                        session: webSession,
                        notifications: notifications,
                        voice: voice,
                        settings: connectionSettings,
                        onWillSave: onWillSaveConnection,
                        onSaved: { origin in
                            presentation.settingsPresented = false
                            onSavedConnection?(origin)
                        }
                    )
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
            .presentationBackground(BenchsideStyle.canvas)
        }
    }

    /// A Hermes reminder was tapped: open its session once voice is idle. It only
    /// switches to a workbench the user already added (never a new server).
    private func openPendingHermesURL() {
        guard let url = hermesPush.pendingURL,
              let origin = URL(string: "\(url.scheme ?? "https")://\(url.host ?? "")\(url.port.map { ":\($0)" } ?? "")"),
              let validOrigin = CollieConnectionOrigin.validate(origin.absoluteString) else { return }
        // Don't pull the page out from under dictation or an unfilled transcript.
        guard !voice.canCancel, voice.phase != .delivering, !voice.canRetryDelivery,
              onWillSaveConnection?(validOrigin) == nil else { return }
        if validOrigin == webSession.baseURL {
            if !isWorkbenchActive { onSavedConnection?(validOrigin) }
            guard webSession.isConnected, let target = hermesPush.consumePendingURL() else { return }
            webSession.openNativeNotification(target)
        } else if let connectionSettings, connectionSettings.recentOrigins.contains(validOrigin) {
            connectionSettings.save(validOrigin)
            onSavedConnection?(validOrigin) // the new shell opens the URL once connected
        } else {
            _ = hermesPush.consumePendingURL() // unknown workbench: drop rather than switch
        }
    }

    private func clearSwitchNoticesIfAllowed() {
        guard !voice.canCancel, voice.phase != .delivering,
              !voice.canRetryDelivery, notifications?.isBusy != true else { return }
        switchNotice = nil
        notifications?.clearNavigationNotice()
    }

    private func switchWorkbench(to origin: URL) {
        guard let connectionSettings else { return }
        switchNotice = connectionSettings.quickSwitch(
            to: origin, from: webSession.baseURL,
            blockedReason: { onWillSaveConnection?($0) },
            onSaved: { onSavedConnection?($0) }
        ) // Unlike Settings → Change Workbench, keep all push bindings.
    }

    private func beginRename(_ origin: URL) {
        renameOrigin = origin
        renameDraft = connectionSettings?.name(for: origin) ?? ""
        showRename = true
    }

    private func updatePlacement(_ next: CollieVoicePlacement) {
        placement = next
        voiceDrag = .zero
        next.save(for: webSession.baseURL)
    }

    /// Runs a shortcut request once the app is in front and voice can act on it:
    /// start when ready, finish when recording; otherwise keep it pending.
    private func runPendingShortcut() {
        guard isWorkbenchActive, shortcuts.pendingToggle, scenePhase == .active,
              voiceNotes?.recorder.isRecording != true else { return }
        if voice.isRecording {
            guard shortcuts.consumeToggle() else { return }
            Task { await voice.performPrimaryAction() }
        } else if voice.phase == .ready, !voice.canRetryDelivery {
            guard shortcuts.consumeToggle() else { return }
            Task { @MainActor in
                webSession.dismissKeyboard()
                await voice.performPrimaryAction()
            }
        }
    }

    private func recoverPendingTranscript() async {
        pendingRecoveryMessage = nil
        webSession.dismissKeyboard()
        if !webSession.isConnected {
            webSession.reload()
            for _ in 0..<120 where !Task.isCancelled {
                if webSession.isConnected { break }
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
        guard webSession.isConnected else {
            pendingRecoveryMessage = shellText("仍无法连接，文字已保存在本机。")
            return
        }
        await voice.retryDelivery()
    }

    private var shellHeader: some View {
        VStack(spacing: 8) {
            if dynamicTypeSize.isAccessibilitySize {
                HStack {
                    Text(shellText("一呼"))
                        .font(.headline.weight(.bold))
                    Spacer()
                    notesButton
                    settingsButton
                }
                if !webSession.isConnected {
                    connectionPill
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ZStack {
                    Text(shellText("一呼"))
                        .font(.headline.weight(.bold))
                    HStack {
                        if !webSession.isConnected { connectionPill }
                        Spacer()
                        notesButton
                        settingsButton
                    }
                }
            }
            if let onOpenWorkbenches {
                Button(action: onOpenWorkbenches) {
                    HStack {
                        Image(systemName: "square.grid.2x2")
                        Text(connectionSettings?.name(for: webSession.baseURL) ?? radarText("工作台"))
                            .lineLimit(1)
                        Image(systemName: "chevron.down").font(.caption)
                        Spacer()
                    }
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("collie-workbench-picker")
            } else if let connectionSettings { quickSwitchRow(connectionSettings) }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(BenchsideStyle.surface)
        .overlay(alignment: .bottom) { Divider().accessibilityHidden(true) }
        .tint(BenchsideStyle.accent)
    }

    private func quickSwitchRow(_ settings: CollieConnectionSettings) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(shellText("工作台"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(BenchsideStyle.secondary)
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(settings.recentOrigins, id: \.absoluteString) { origin in
                            workbenchChip(origin, settings: settings)
                                .id(origin.absoluteString)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .accessibilityIdentifier("collie-quick-switch")
                .onAppear { proxy.scrollTo(webSession.baseURL.absoluteString, anchor: .center) }
            }
            if let switchNotice = switchNotice ?? notifications?.navigationNotice {
                Text(switchNotice)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("collie-switch-notice")
            }
        }
    }

    private func workbenchChip(_ origin: URL, settings: CollieConnectionSettings) -> some View {
        let selected = origin == webSession.baseURL
        let name = settings.name(for: origin)
        return Button { switchWorkbench(to: origin) } label: {
            HStack(spacing: 5) {
                if selected { Image(systemName: "checkmark.circle.fill") }
                Text(name).lineLimit(1)
            }
            .font(.subheadline.weight(selected ? .semibold : .medium))
            .foregroundStyle(selected ? BenchsideStyle.accent : BenchsideStyle.ink)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(selected ? BenchsideStyle.accent.opacity(0.14) : BenchsideStyle.surfaceRaised,
                        in: Capsule())
            .overlay { Capsule().stroke(selected ? BenchsideStyle.accent : BenchsideStyle.border, lineWidth: 1) }
        }
        .buttonStyle(.plain)
        .contextMenu { Button(shellText("重命名工作台")) { beginRename(origin) } }
        .accessibilityLabel(String(format: shellText("%1$@，%2$@"), name, selected ? shellText("当前工作台") : shellText("切换工作台")))
        .accessibilityIdentifier("collie-workbench-\(origin.absoluteString)")
    }

    private var connectionPill: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(webSession.isConnected ? BenchsideStyle.accent :
                      (webSession.errorMessage == nil ? BenchsideStyle.secondary : Color.red))
                .frame(width: 8, height: 8)
            Text(webSession.connectionStatusLabel)
                .font(.caption.weight(.medium))
                .lineLimit(1)
        }
        .foregroundStyle(webSession.isConnected ? BenchsideStyle.accent : BenchsideStyle.secondary)
        .padding(.horizontal, 12)
        .frame(minHeight: 32)
        .background(BenchsideStyle.accent.opacity(webSession.isConnected ? 0.10 : 0.04), in: Capsule())
        .overlay { Capsule().stroke(BenchsideStyle.border, lineWidth: 1) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: shellText("工作台%@"), webSession.connectionStatusLabel))
    }

    @ViewBuilder
    private var notesButton: some View {
        if let voiceNotes {
            Button { presentation.notesPresented = true } label: {
                Group {
                    if voiceNotes.recorder.isRecording {
                        Image(systemName: "record.circle.fill").foregroundStyle(.red)
                            .symbolEffect(.pulse, isActive: true)
                    } else {
                        Image(systemName: "waveform.badge.mic")
                    }
                }
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(BenchsideStyle.surfaceRaised, in: Circle())
            }
            .buttonStyle(ColliePressButtonStyle())
            .accessibilityLabel(voiceNotes.recorder.isRecording ? shellText("正在语音记录") : shellText("语音记录"))
            .accessibilityIdentifier("collie-voice-notes")
        }
    }

    private var settingsButton: some View {
        Button { presentation.settingsPresented = true } label: {
            Label(shellText("一呼设置"), systemImage: "gearshape")
                .labelStyle(.iconOnly)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(BenchsideStyle.surfaceRaised, in: Circle())
        }
        .buttonStyle(ColliePressButtonStyle())
        .accessibilityIdentifier("collie-connection-settings")
    }
}

private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon.imageScale(.small)
        }
    }
}

struct ColliePressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .opacity(configuration.isPressed ? 0.76 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct CollieVoiceBar: View {
    let voice: CollieVoiceController
    var beforeVoiceStart: @MainActor () async -> Void = {}
    var pendingRecoveryTitle = shellText("再次填入")
    var pendingRecoveryNotice: String? = nil
    var recoverPendingTranscript: @MainActor () async -> Void = {}
    var side: CollieVoicePlacement.Side = .trailing
    /// Live drag offset while moving the idle microphone; `onRepositionEnded` commits it.
    var onReposition: (CGSize) -> Void = { _ in }
    var onRepositionEnded: (CGSize) -> Void = { _ in }
    var onFlipSide: () -> Void = {}

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isPressing = false
    @State private var cancelsOnRelease = false
    @State private var startedByHold = false
    @State private var holdTask: Task<Void, Never>?
    @State private var confirmingDiscard = false
    @State private var isRepositioning = false

    private var displayedTranscript: String { voice.pendingTranscript ?? voice.previewText }
    /// A press held past this becomes push-to-talk; shorter presses toggle. Normal
    /// taps often last 120–200 ms, so a lower threshold turned slow taps into empty holds.
    static let holdThreshold: Duration = .milliseconds(250)
    /// Moving this far before the hold threshold means "move the button", not "talk".
    static let repositionSlop: CGFloat = 10
    enum ReleaseAction: Equatable {
        case none
        case cancel
        case finishHold
        case toggleTap
    }

    static func releaseAction(
        startedByHold: Bool, isReady: Bool, isRecording: Bool, dragDistance: CGFloat
    ) -> ReleaseAction {
        if dragDistance > 72 { return startedByHold ? .cancel : .none }
        if startedByHold { return .finishHold }
        if isReady || isRecording { return .toggleTap }
        return .none
    }

    private var showsHoldControl: Bool {
        switch voice.phase {
        case .ready, .preparing, .recording, .transcribing, .delivering, .checkingModel:
            true
        case .needsModel, .downloading, .failed:
            false
        }
    }

    var body: some View {
        VStack(alignment: side == .leading ? .leading : .trailing, spacing: 10) {
            if voice.canRetryDelivery {
                pendingTranscriptPanel
            } else {
                if !displayedTranscript.isEmpty, voice.isRecording {
                    liveTranscript
                }
                if cancelsOnRelease, voice.canCancel {
                    Text(shellText("松开取消"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(BenchsideStyle.surfaceRaised, in: Capsule())
                } else if voice.phase == .ready, voice.notice != nil {
                    Label(voice.notice ?? "", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BenchsideStyle.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(BenchsideStyle.surfaceRaised, in: Capsule())
                }

                if voice.isRecording {
                    CollieMicrophoneModeControl(compact: true)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(BenchsideStyle.surfaceRaised, in: Capsule())
                        .accessibilityIdentifier("collie-recording-microphone-mode")
                }
                if showsHoldControl {
                    holdControl
                } else {
                    exceptionalState
                }
            }
        }
        .frame(maxWidth: 360, alignment: side == .leading ? .leading : .trailing)
        .foregroundStyle(BenchsideStyle.ink)
        .tint(BenchsideStyle.accent)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: voice.phase)
        .sensoryFeedback(.selection, trigger: voice.isRecording)
        .sensoryFeedback(.impact(weight: .light), trigger: isRepositioning) { _, moving in moving }
        .confirmationDialog(shellText("放弃这段文字？"), isPresented: $confirmingDiscard, titleVisibility: .visible) {
            Button(shellText("放弃文字"), role: .destructive) { voice.discardPendingTranscript() }
            Button(shellText("保留"), role: .cancel) {}
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                isPressing = false
                holdTask?.cancel()
                holdTask = nil
            } else if startedByHold, !isPressing, voice.isRecording {
                startedByHold = false
                Task { @MainActor in await finishRecordingAfterPreparation() }
            }
        }
        .onDisappear {
            holdTask?.cancel()
            holdTask = nil
            if startedByHold, voice.canCancel { voice.cancelRecording() }
        }
    }

    private var holdControl: some View {
        HStack(spacing: 12) {
            if voice.isRecording {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(String(format: shellText("%lld 秒"), Int64(voice.recordingSeconds(at: context.date))))
                        .font(.callout.weight(.semibold).monospacedDigit())
                        .foregroundStyle(BenchsideStyle.ink.opacity(0.85))
                        .accessibilityIdentifier("collie-recording-time")
                }
            } else if voice.phase == .downloading {
                Text("\(Int(voice.downloadProgress * 100))%")
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ZStack {
                if voice.isRecording {
                    Circle()
                        .fill(BenchsideStyle.accent.opacity(0.18))
                        .frame(width: 76, height: 76)
                        .scaleEffect(reduceMotion ? 1 : 1 + CGFloat(voice.level) * 0.12)
                    Circle()
                        .fill(BenchsideStyle.accent)
                        .frame(width: 58, height: 58)
                    Image(systemName: "waveform")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(BenchsideStyle.onAccent)
                } else if voice.showsProgressIndicator {
                    Circle()
                        .fill(BenchsideStyle.surfaceRaised)
                        .frame(width: 58, height: 58)
                        .overlay { Circle().stroke(BenchsideStyle.border, lineWidth: 1) }
                    ProgressView()
                        .tint(BenchsideStyle.accent)
                } else {
                    Circle()
                        .fill(BenchsideStyle.accent)
                        .frame(width: 58, height: 58)
                    Image(systemName: "mic.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(BenchsideStyle.onAccent)
                }
            }
            .frame(width: 76, height: 76)
            .shadow(color: .black.opacity(voice.phase == .ready ? 0.18 : 0), radius: 12, y: 5)
            .contentShape(Circle())
            .gesture(holdGesture)
            .allowsHitTesting(voice.phase == .ready || voice.phase == .preparing || voice.isRecording)
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(voice.isRecording ? shellText("正在录音") : shellText("语音输入"))
            .accessibilityHint(voice.isRecording ? shellText("松开或双击完成录音") : shellText("点按开始，或按住说话"))
            .accessibilityIdentifier("collie-voice-primary")
            .accessibilityAction {
                Task { @MainActor in
                    if voice.phase == .ready { await beforeVoiceStart() }
                    await voice.performPrimaryAction()
                }
            }
            .accessibilityAction(named: shellText("放弃录音")) {
                voice.cancelRecording()
            }
            .accessibilityAction(named: side == .leading ? shellText("移到右侧") : shellText("移到左侧")) {
                onFlipSide()
            }
        }
        .padding(6)
        .background {
            if voice.isRecording {
                Capsule()
                    .fill(reduceTransparency ? AnyShapeStyle(BenchsideStyle.surfaceRaised) : AnyShapeStyle(.ultraThinMaterial))
            }
        }
        .overlay {
            if voice.isRecording { Capsule().stroke(BenchsideStyle.border, lineWidth: 1) }
        }
        .shadow(color: .black.opacity(voice.isRecording ? 0.14 : 0), radius: 14, y: 6)
    }

    private var holdGesture: some Gesture {
        // Global space: the button moves with the drag, so local coordinates would feed back.
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                if !isPressing {
                    isPressing = true
                    cancelsOnRelease = false
                    startedByHold = false
                    holdTask?.cancel()
                    holdTask = Task { @MainActor in
                        try? await Task.sleep(for: Self.holdThreshold)
                        guard !Task.isCancelled, isPressing, !cancelsOnRelease, voice.phase == .ready else { return }
                        startedByHold = true
                        await beforeVoiceStart()
                        guard isPressing else {
                            startedByHold = false
                            return
                        }
                        await voice.performPrimaryAction()
                    }
                }
                let distance = hypot(value.translation.width, value.translation.height)
                if !isRepositioning, !startedByHold, voice.phase == .ready, !voice.canRetryDelivery,
                   distance > Self.repositionSlop {
                    isRepositioning = true
                    holdTask?.cancel()
                    holdTask = nil
                }
                if isRepositioning {
                    onReposition(value.translation)
                    return
                }
                cancelsOnRelease = distance > 72
            }
            .onEnded { value in
                if isRepositioning {
                    isRepositioning = false
                    isPressing = false
                    onRepositionEnded(value.translation)
                    return
                }
                holdTask?.cancel()
                holdTask = nil
                isPressing = false
                let action = Self.releaseAction(
                    startedByHold: startedByHold,
                    isReady: voice.phase == .ready,
                    isRecording: voice.isRecording,
                    dragDistance: hypot(value.translation.width, value.translation.height)
                )
                startedByHold = false
                cancelsOnRelease = false
                switch action {
                case .none:
                    break
                case .cancel:
                    voice.cancelRecording()
                case .finishHold:
                    Task { @MainActor in await finishRecordingAfterPreparation() }
                case .toggleTap:
                    Task { @MainActor in
                        if voice.phase == .ready { await beforeVoiceStart() }
                        await voice.performPrimaryAction()
                    }
                }
            }
    }

    @MainActor
    private func finishRecordingAfterPreparation() async {
        for _ in 0..<100 where !Task.isCancelled {
            if voice.isRecording {
                await voice.performPrimaryAction()
                return
            }
            if voice.phase != .preparing { return }
            try? await Task.sleep(for: .milliseconds(50))
        }
        if voice.canCancel { voice.cancelRecording(reason: shellText("录音没有开始，请重试。")) }
    }

    private var liveTranscript: some View {
        CollieTranscriptPreview(text: displayedTranscript, allowsIncrementalAnimation: !reduceMotion)
            .font(.callout)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: 320, alignment: .leading)
            .background(reduceTransparency ? AnyShapeStyle(BenchsideStyle.surfaceRaised) : AnyShapeStyle(.ultraThinMaterial), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(BenchsideStyle.border, lineWidth: 1) }
            .accessibilityIdentifier("collie-voice-preview")
    }

    private var exceptionalState: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch voice.phase {
            case .needsModel:
                Text(shellText("下载语音模型"))
                    .font(.callout.weight(.semibold))
                Text(shellText("约 950 MB，建议连接 Wi‑Fi。下载时请停留在一呼，完成后可离线使用。"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                actionRow {
                    Button(shellText("下载")) { Task { await voice.performPrimaryAction() } }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("collie-voice-primary")
                    Menu {
                        ForEach(Qwen3ModelDownloadSource.allCases) { source in
                            Button {
                                voice.setModelDownloadSource(source)
                            } label: {
                                if source == voice.modelDownloadSource {
                                    Label(String(format: shellText("%1$@（%2$@）"), source.shortLabel, source.detail), systemImage: "checkmark")
                                } else {
                                    Text(String(format: shellText("%1$@（%2$@）"), source.shortLabel, source.detail))
                                }
                            }
                        }
                    } label: {
                        Label(String(format: shellText("下载源：%@"), voice.modelDownloadSource.shortLabel), systemImage: "chevron.up.chevron.down")
                            .labelStyle(TrailingIconLabelStyle())
                            .font(.callout)
                            .frame(minHeight: 44)
                    }
                    .accessibilityLabel(String(format: shellText("下载源：%@"), voice.modelDownloadSource.shortLabel))
                }
            case .downloading:
                HStack(spacing: 10) {
                    ProgressView(value: voice.downloadProgress)
                    Text("\(Int(voice.downloadProgress * 100))%")
                        .font(.caption.monospacedDigit())
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(format: shellText("语音模型下载进度 %lld%%"), Int64(voice.downloadProgress * 100)))
                Text(shellText("请停留在一呼，下载完成后可离线使用。"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            case .failed(let message):
                Label(message, systemImage: "exclamationmark.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("collie-voice-failure")
                failureActions
            default:
                EmptyView()
            }
        }
        .padding(14)
        .frame(maxWidth: 320, alignment: .leading)
        .background(reduceTransparency ? AnyShapeStyle(BenchsideStyle.surfaceRaised) : AnyShapeStyle(.ultraThinMaterial), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(BenchsideStyle.border, lineWidth: 1) }
        .shadow(color: .black.opacity(0.12), radius: 14, y: 5)
    }

    /// Each failure offers the one action that can actually recover it, plus a way to dismiss.
    @ViewBuilder
    private var failureActions: some View {
        switch voice.failureKind {
        case .microphonePermission:
            actionRow {
                Button(shellText("去设置")) {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("collie-voice-open-settings")
                dismissFailureButton
            }
        case .modelDownload:
            actionRow {
                Button(shellText("重试")) {
                    Task { await voice.retryModelDownload(using: voice.modelDownloadSource) }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("collie-voice-primary")
                Menu(shellText("换下载源")) {
                    ForEach(Qwen3ModelDownloadSource.allCases) { source in
                        Button(String(format: shellText("%1$@（%2$@）"), source.shortLabel, source.detail)) {
                            Task { await voice.retryModelDownload(using: source) }
                        }
                    }
                }
                .frame(minHeight: 44)
            }
        case .model:
            actionRow {
                Button(shellText("重试")) { Task { await voice.performPrimaryAction() } }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("collie-voice-primary")
            }
        case .recording:
            actionRow {
                Button(shellText("再录一次")) {
                    Task { @MainActor in
                        await voice.performPrimaryAction() // Clears the failure.
                        guard voice.phase == .ready else { return }
                        await beforeVoiceStart()
                        await voice.performPrimaryAction()
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("collie-voice-primary")
                dismissFailureButton
            }
        }
    }

    private var dismissFailureButton: some View {
        Button(shellText("关闭")) { Task { await voice.performPrimaryAction() } }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("collie-voice-dismiss-failure")
    }

    @ViewBuilder
    private func actionRow<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) { content() }
                .controlSize(.large)
        } else {
            HStack(spacing: 10) { content() }
                .controlSize(.large)
        }
    }

    private var pendingTranscriptPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let pendingRecoveryNotice {
                Text(pendingRecoveryNotice)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            Text(displayedTranscript)
                .font(.callout)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("collie-voice-preview")
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 8) { retryButton; discardButton }
            } else {
                HStack(spacing: 10) { retryButton; discardButton }
            }
        }
        .padding(14)
        .frame(maxWidth: 340, alignment: .leading)
        .background(reduceTransparency ? AnyShapeStyle(BenchsideStyle.surfaceRaised) : AnyShapeStyle(.ultraThinMaterial), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(BenchsideStyle.border, lineWidth: 1) }
        .shadow(color: .black.opacity(0.12), radius: 14, y: 5)
    }

    private var retryButton: some View {
        Button {
            Task { await recoverPendingTranscript() }
        } label: {
            Text(pendingRecoveryTitle)
                .font(.callout.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("collie-retry-transcript")
    }

    private var discardButton: some View {
        Button(shellText("放弃")) { confirmingDiscard = true }
            .font(.callout.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 44)
            .buttonStyle(.bordered)
            .accessibilityIdentifier("collie-discard-transcript")
    }
}

struct CollieConnectionErrorView: View {
    let message: String
    var reload: () -> Void
    var changeConnection: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.10))
                        .frame(width: 76, height: 76)
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)
                }
                Text(shellText("无法连接工作台"))
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.body)
                    .foregroundStyle(BenchsideStyle.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: reload) {
                    Label(shellText("重新加载"), systemImage: "arrow.clockwise")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(ColliePressButtonStyle())
                .foregroundStyle(BenchsideStyle.onAccent)
                .background(BenchsideStyle.accent, in: Capsule())
                .accessibilityIdentifier("collie-web-reload")
                if let changeConnection {
                    Button(shellText("更换工作台"), action: changeConnection)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .accessibilityIdentifier("collie-web-change-workbench")
                }
            }
            .padding(28)
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity)
        }
        .contentMargins(.vertical, 56, for: .scrollContent)
        .background(BenchsideStyle.canvas)
        .tint(BenchsideStyle.accent)
    }
}
