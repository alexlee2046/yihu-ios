import Foundation
import Observation
import SwiftUI

/// The only URL form accepted by the real Collie connection settings.
/// WebKit test fixtures may still use loopback HTTP through CollieWebSession's
/// explicit initializer; this validator intentionally never accepts it.
enum CollieConnectionOrigin {
    static let defaultsKey = "collie.connection.origin"
    static let recentKey = "collie.connection.recent"
    static let customNamesKey = "collie.connection.custom-names"
    static let pageNamesKey = "collie.connection.page-names"
    static let maxRecent = 6

    static func validate(_ rawValue: String) -> URL? {
        let input = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty, let components = URLComponents(string: input),
              components.scheme?.lowercased() == "https",
              let host = components.host, !host.isEmpty,
              components.user == nil, components.password == nil,
              components.query == nil, components.fragment == nil,
              components.percentEncodedPath.isEmpty || components.percentEncodedPath == "/",
              components.port.map({ (1...65535).contains($0) }) ?? true,
              let url = normalizedURL(host: host, port: components.port)
        else { return nil }
        return url
    }

    private static func normalizedURL(host: String, port: Int?) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host.lowercased()
        if let port, port != 443 { components.port = port }
        guard let url = components.url else { return nil }
        return url
    }
}

@MainActor
@Observable
final class CollieConnectionSettings {
    private let defaults: UserDefaults

    private(set) var currentOrigin: URL?
    /// Added workbenches; quick-switch keeps this order stable.
    private(set) var recentOrigins: [URL] = []
    @ObservationIgnored var isNotificationEnabled: @MainActor (URL) -> Bool = { _ in false }
    private(set) var customNames: [String: String] = [:]
    private(set) var pageNames: [String: String] = [:]
    var draft = ""
    private(set) var validationMessage: String?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let saved = defaults.string(forKey: CollieConnectionOrigin.defaultsKey),
           let origin = CollieConnectionOrigin.validate(saved) {
            currentOrigin = origin
            draft = origin.absoluteString
        } else {
            defaults.removeObject(forKey: CollieConnectionOrigin.defaultsKey)
        }
        recentOrigins = (defaults.stringArray(forKey: CollieConnectionOrigin.recentKey) ?? [])
            .compactMap(CollieConnectionOrigin.validate)
        if recentOrigins.isEmpty, let currentOrigin { recentOrigins = [currentOrigin] }
        customNames = defaults.dictionary(forKey: CollieConnectionOrigin.customNamesKey) as? [String: String] ?? [:]
        pageNames = defaults.dictionary(forKey: CollieConnectionOrigin.pageNamesKey) as? [String: String] ?? [:]
    }

    var hasSavedOrigin: Bool { currentOrigin != nil }

    func name(for origin: URL) -> String {
        let name = customNames[origin.absoluteString] ?? pageNames[origin.absoluteString]
            ?? CollieConnectionSettingsView.displayName(origin)
        let duplicate = recentOrigins.contains { other in
            other != origin && (customNames[other.absoluteString] ?? pageNames[other.absoluteString]
                ?? CollieConnectionSettingsView.displayName(other)) == name
        }
        return duplicate ? "\(name)（\(CollieConnectionSettingsView.displayName(origin))）" : name
    }

    /// Home and notification actions reuse saved workbenches without touching push bindings.
    @discardableResult
    func quickSwitch(to origin: URL, from current: URL?,
                     blockedReason: (URL) -> String?, onSaved: (URL) -> Void) -> String? {
        guard recentOrigins.contains(origin) else { return "该工作台不在最近用过的列表中。" }
        guard origin != current else { return nil }
        if let reason = blockedReason(origin) { return reason }
        save(origin, reorderRecent: false)
        onSaved(origin)
        return nil
    }

    func rename(_ origin: URL, to raw: String) {
        guard recentOrigins.contains(origin) else { return }
        let name = String(raw.trimmingCharacters(in: .whitespacesAndNewlines).prefix(32))
        if name.isEmpty { customNames.removeValue(forKey: origin.absoluteString) }
        else { customNames[origin.absoluteString] = name }
        defaults.set(customNames, forKey: CollieConnectionOrigin.customNamesKey)
    }

    func rememberPageTitle(_ raw: String?, for origin: URL) {
        guard recentOrigins.contains(origin), let raw else { return }
        // Most workbench titles put the product name before a page-specific suffix.
        let first = raw.components(separatedBy: " | ").first?
            .components(separatedBy: " — ").first?
            .components(separatedBy: " – ").first ?? raw
        let name = String(first.trimmingCharacters(in: .whitespacesAndNewlines).prefix(32))
        guard !name.isEmpty, !name.contains("://"),
              name != CollieConnectionSettingsView.displayName(origin),
              pageNames[origin.absoluteString] == nil else { return }
        pageNames[origin.absoluteString] = name
        defaults.set(pageNames, forKey: CollieConnectionOrigin.pageNamesKey)
    }

    func validateDraft() -> URL? {
        guard let origin = CollieConnectionOrigin.validate(draft) else {
            validationMessage = String(localized: "请输入以 https:// 开头的工作台地址，例如 https://collie.example.com；只填主机名或 IP 地址（可带端口），不要带账号密码、路径、参数或 # 片段。", table: "Yihu")
            return nil
        }
        validationMessage = nil
        return origin
    }

    func save(_ origin: URL) { save(origin, reorderRecent: true) }

    private func save(_ origin: URL, reorderRecent: Bool) {
        guard let normalized = CollieConnectionOrigin.validate(origin.absoluteString) else { return }
        defaults.set(normalized.absoluteString, forKey: CollieConnectionOrigin.defaultsKey)
        var ordered = recentOrigins.filter { $0 != normalized }
        if reorderRecent || !recentOrigins.contains(normalized) { ordered.insert(normalized, at: 0) }
        else if let index = recentOrigins.firstIndex(of: normalized) { ordered.insert(normalized, at: index) }
        // Six is a soft cap: never discard an origin with an enabled push binding.
        for candidate in ordered.reversed() where ordered.count > CollieConnectionOrigin.maxRecent {
            if candidate != normalized && !isNotificationEnabled(candidate) {
                ordered.removeAll { $0 == candidate }
                customNames.removeValue(forKey: candidate.absoluteString)
                pageNames.removeValue(forKey: candidate.absoluteString)
            }
        }
        recentOrigins = ordered
        defaults.set(ordered.map(\.absoluteString), forKey: CollieConnectionOrigin.recentKey)
        defaults.set(customNames, forKey: CollieConnectionOrigin.customNamesKey)
        defaults.set(pageNames, forKey: CollieConnectionOrigin.pageNamesKey)
        currentOrigin = normalized
        draft = normalized.absoluteString
        validationMessage = nil
    }

    func setValidationMessage(_ message: String?) {
        validationMessage = message
    }

    func resetDraft() {
        draft = currentOrigin?.absoluteString ?? ""
        validationMessage = nil
    }
}

struct CollieConnectionSettingsView: View {
    @Bindable private var settings: CollieConnectionSettings
    let isInitialSetup: Bool
    var notifications: CollieNativeNotificationsController?
    var webSession: CollieWebSession?
    var onWillSave: ((URL) -> String?)?
    var onSaved: ((URL) -> Void)?
    @State private var confirmingUnboundChange = false
    @State private var pendingOrigin: URL?
    @State private var operationMessage: String?
    @State private var isSaving = false

    init(
        settings: CollieConnectionSettings,
        isInitialSetup: Bool = false,
        notifications: CollieNativeNotificationsController? = nil,
        webSession: CollieWebSession? = nil,
        onWillSave: ((URL) -> String?)? = nil,
        onSaved: ((URL) -> Void)? = nil
    ) {
        self.settings = settings
        self.isInitialSetup = isInitialSetup
        self.notifications = notifications
        self.webSession = webSession
        self.onWillSave = onWillSave
        self.onSaved = onSaved
    }

    @ViewBuilder
    var body: some View {
        if isInitialSetup {
            NavigationStack { content }
        } else {
            content
        }
    }

    private var content: some View {
        Form {
                if isInitialSetup {
                    Section {
                        Text("连接后即可查看工作台并使用本机语音输入。", tableName: "Yihu")
                            .foregroundStyle(.secondary)
                    }
                }
                Section {
                    TextField("https://collie.example.com", text: $settings.draft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .frame(minHeight: 44)
                        .accessibilityLabel(Text("Collie 工作台地址", tableName: "Yihu"))
                        .accessibilityIdentifier("collie-connection-origin")
                    if let validationMessage = settings.validationMessage {
                        Text(validationMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("collie-connection-error")
                    }
                } header: {
                    Text("工作台地址", tableName: "Yihu")
                } footer: {
                    Text("可以是 Collie、OpenClaw 控制台、Hermes 管理台或其他网页工作台。地址保存在这台 iPhone 的本地设置中。", tableName: "Yihu")
                }

                let others = settings.recentOrigins.filter { $0 != settings.currentOrigin }
                if !isInitialSetup, !others.isEmpty {
                    Section {
                        ForEach(others, id: \.self) { origin in
                            Button {
                                settings.draft = origin.absoluteString
                                Task { await save() }
                            } label: {
                                Label(Self.displayName(origin), systemImage: "clock.arrow.circlepath")
                                    .frame(minHeight: 44)
                            }
                            .disabled(isSaving)
                        }
                    } header: {
                        Text("最近用过", tableName: "Yihu")
                    }
                }

                if let operationMessage {
                    Section {
                        Label(operationMessage, systemImage: "exclamationmark.circle")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }

                Section {
                    Button { Task { await save() } } label: {
                        Label(isSaving ? String(localized: "正在切换…", table: "Yihu") : (isInitialSetup ? String(localized: "连接", table: "Yihu") : String(localized: "切换工作台", table: "Yihu")),
                              systemImage: isInitialSetup ? "arrow.right" : "arrow.triangle.2.circlepath")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(BenchsideStyle.onAccent)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(BenchsideStyle.accent, in: Capsule())
                    }
                    .buttonStyle(ColliePressButtonStyle())
                    .disabled(settings.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                    .opacity(settings.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                    .accessibilityIdentifier("collie-connection-save")
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(BenchsideStyle.canvas)
            .tint(BenchsideStyle.accent)
            .navigationTitle(Text(isInitialSetup ? LocalizedStringKey("连接 Collie 工作台") : LocalizedStringKey("更换工作台"), tableName: "Yihu"))
            .navigationBarTitleDisplayMode(isInitialSetup ? .inline : .large)
            .onAppear {
                if !isInitialSetup {
                    settings.resetDraft()
                    operationMessage = nil
                }
            }
            .alert(Text("上一次停用未完成", tableName: "Yihu"), isPresented: $confirmingUnboundChange) {
                Button(String(localized: "取消", table: "Yihu"), role: .cancel) { pendingOrigin = nil }
                Button(String(localized: "仍然切换", table: "Yihu"), role: .destructive) {
                    guard let origin = pendingOrigin else { return }
                    pendingOrigin = nil
                    commit(origin)
                }
            } message: {
                Text("原工作台可能最多继续收到 7 天通用提醒，通知不会转移到新的工作台。可切回原地址重试停用。仍要更换工作台吗？", tableName: "Yihu")
            }
    }

    @MainActor
    private func save() async {
        guard let origin = settings.validateDraft() else { return }
        operationMessage = nil
        let changesWorkbench = settings.currentOrigin != origin

        if let reason = onWillSave?(origin) {
            operationMessage = reason
            return
        }
        if changesWorkbench, notifications?.isBusy == true {
            operationMessage = String(localized: "请等待通知操作完成后再切换工作台。", table: "Yihu")
            return
        }
        if changesWorkbench, notifications?.isEnabled == true {
            isSaving = true
            await notifications?.disable(session: webSession)
            isSaving = false
        }

        if let reason = onWillSave?(origin) {
            operationMessage = reason
            return
        }
        if changesWorkbench, notifications?.hasPendingUnregister == true {
            pendingOrigin = origin
            confirmingUnboundChange = true
            return
        }
        commit(origin)
    }

    static func displayName(_ origin: URL) -> String {
        guard let host = origin.host else { return origin.absoluteString }
        return origin.port.map { "\(host):\($0)" } ?? host
    }

    private func commit(_ origin: URL) {
        if let reason = onWillSave?(origin) {
            operationMessage = reason
            return
        }
        settings.save(origin)
        onSaved?(origin)
    }
}
