import Foundation
import Observation
import SwiftUI

private struct CollieRadarReplyResponse: Decodable {
    var outcome: String?
    var error: String?
    var target: CollieRadarReplyTarget?
    var history: CollieRadarReplyHistory? = nil
}

private struct CollieRadarReplyRequest: Encodable {
    var operation: String
    var id: String
    var text: String
    var request_id: String
    var version: String?
    var confirmed: Bool
    var epoch: String?
    var before: String? = nil
    var authorization_confirmed: Bool? = nil
    var authorization_digest: String? = nil
    var authorization: CollieRadarAuthorization? = nil
}

private struct CollieRadarReplyFailure: Error {
    var code: String
    var target: CollieRadarReplyTarget?
}

private final class CollieRadarReplyNoRedirect: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest,
                    completionHandler: @escaping @Sendable (URLRequest?) -> Void) { completionHandler(nil) }
}

@MainActor
@Observable
final class CollieRadarReplySession {
    var text = ""
    private(set) var target: CollieRadarReplyTarget?
    private(set) var busy = false
    private(set) var pending = false
    private(set) var recorded = false
    private(set) var notice: String?
    private(set) var blocked = false
    private var requestID = UUID()
    private(set) var authorizationConfirmed = false
    private let workbenchID: UUID
    private let source: String
    private let selected: CollieRadarSnapshot.Action
    private var targetID: String
    private let currentSource: @MainActor () -> Bool
    private let configuration: URLSessionConfiguration
    private(set) var history: CollieRadarReplyHistory?
    private(set) var historyBusy = false
    private(set) var historyNotice: String?
    private var historyGeneration = 0
    private var historyActive = true
    private var historyCursors: Set<String> = []

    init(workbenchID: UUID, source: String, selected: CollieRadarSnapshot.Action,
         configuration: URLSessionConfiguration = .ephemeral,
         currentSource: @escaping @MainActor () -> Bool = { true }) {
        self.configuration = configuration
        self.currentSource = currentSource
        self.workbenchID = workbenchID
        self.source = source
        self.selected = selected
        self.targetID = selected.id ?? ""
        let file = CollieRadarPendingReply.file(workbenchID)
        if FileManager.default.fileExists(atPath: file.path) {
            do {
                let handle = try FileHandle(forReadingFrom: file)
                defer { try? handle.close() }
                let data = try handle.read(upToCount: 40_001) ?? Data()
                guard data.count <= 40_000 else { throw CollieRadarError.tooLarge }
                let saved = try JSONDecoder().decode(CollieRadarPendingReply.self, from: data)
                guard saved.source == source, CollieRadarFeed.validate(saved.source) != nil else {
                    throw CollieRadarError.invalidURL
                }
                target = saved.target
                targetID = saved.target.id
                text = saved.text
                requestID = saved.requestID
                pending = saved.submitted != false
                authorizationConfirmed = saved.authorizationConfirmed == true
                if pending { notice = radarText("有待核实的回复，先查回结果再重试。") }
            } catch {
                blocked = true
                notice = radarText("待核回复记录无法读取，原始记录已保留；暂不能发送新的回复。")
            }
        }
    }

    var canSend: Bool {
        currentSource() && target?.eligible == true && ["等你决策", "等你验收"].contains(target?.status ?? "") &&
        (history.map { $0.target.version == target?.version } ?? true) &&
        !busy && !blocked && !pending && !recorded &&
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text.unicodeScalars.count <= 4000
    }

    var canAuthorize: Bool {
        canSend && selectedMatchesTarget && target?.authorization?.current() == true
    }

    func prepare() async {
        guard currentSource(), !busy, !blocked, !pending, !recorded else { return }
        busy = true
        defer { busy = false }
        do {
            let result = try await request("prepare", id: targetID)
            guard let latest = result.target, latest.id == targetID, result.outcome == "prepared" else { throw CollieRadarError.invalidSnapshot }
            target = latest
            if targetID != (selected.id ?? "") {
                notice = radarText("已恢复先前条目的回复草稿，请先处理这份草稿。")
            } else if latest.status != selected.status || latest.next != selected.next {
                notice = radarText("条目已更新，请核对最新状态和下一步后重新确认。")
            }
        } catch let error as CollieRadarReplyFailure {
            target = error.target?.id == targetID ? error.target : nil
            notice = message(error)
        } catch { target = nil; notice = message(error) }
    }

    func preserveDraft() -> Bool {
        guard !busy else { return false }
        guard !pending, !recorded, !blocked else { return true }
        do {
            let file = CollieRadarPendingReply.file(workbenchID)
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if FileManager.default.fileExists(atPath: file.path) { try FileManager.default.removeItem(at: file) }
            } else {
                let draftTarget = target ?? CollieRadarReplyTarget(eligible: false, epoch: "", id: targetID,
                    title: selected.title, url: selected.url, status: selected.status ?? "", next: selected.next, version: "")
                try persist(draftTarget, submitted: false)
            }
            return true
        } catch {
            notice = radarText("无法保存回复草稿，输入仍在当前页面。")
            return false
        }
    }

    func discardDraft() -> Bool {
        guard !busy, !pending, !blocked else { return false }
        do {
            let file = CollieRadarPendingReply.file(workbenchID)
            if FileManager.default.fileExists(atPath: file.path) { try FileManager.default.removeItem(at: file) }
            text = ""
            return true
        } catch { notice = radarText("无法清理回复草稿，请稍后重试。"); return false }
    }

    private func persist(_ target: CollieRadarReplyTarget, submitted: Bool) throws {
        let file = CollieRadarPendingReply.file(workbenchID)
        let directory = file.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var excluded = directory
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try excluded.setResourceValues(values)
        let record = CollieRadarPendingReply(source: source, target: target, text: text,
                                            requestID: requestID, submitted: submitted,
                                            authorizationConfirmed: authorizationConfirmed)
        let data = try JSONEncoder().encode(record)
        #if os(iOS)
        try data.write(to: file, options: [.atomic, .completeFileProtection])
        #else
        try data.write(to: file, options: [.atomic])
        #endif
    }

    func submit(authorizing: Bool = false) async {
        guard canSend, !authorizing || canAuthorize, let target else { return }
        authorizationConfirmed = authorizing
        busy = true
        defer { busy = false }
        do {
            // Persist before any submit. A killed app must resume the same request ID,
            // not turn an uncertain write into a new comment.
            try persist(target, submitted: true)
        } catch {
            authorizationConfirmed = false
            notice = radarText("无法安全保存待核回复，尚未发送。")
            return
        }
        pending = true
        do {
            let result = try await request("submit", id: target.id, version: target.version)
            guard result.outcome == "recorded" else { throw CollieRadarError.invalidSnapshot }
            complete()
        } catch let error as CollieRadarReplyFailure {
            if ["forbidden", "invalid_request", "target_changed", "target_unavailable", "write_rejected", "invalid_authorization", "authorization_expired"].contains(error.code) {
                if let latest = error.target { self.target = latest }
                else if ["forbidden", "target_unavailable"].contains(error.code) { self.target = nil }
                if clearPending() { requestID = UUID() }
                notice = message(error)
            } else {
                notice = radarText("结果待核，先查回原条目再重试；不要重复发送。")
            }
        } catch { notice = radarText("结果待核，先查回原条目再重试；不要重复发送。") }
    }

    func check() async {
        guard pending, !busy, !blocked, let target else { return }
        busy = true
        defer { busy = false }
        do {
            let result = try await request("check", id: target.id)
            if result.outcome == "recorded" { complete() }
            else if result.outcome == "absent", let latest = result.target {
                if clearPending() {
                    self.target = nil
                    notice = radarText("已查回：未找到这次回复。输入已保留，请重新读取条目并确认。")
                    // Keep the same request ID for a retry. If provider visibility was
                    // delayed, its durable marker still prevents a second write.
                    let prepared = try await request("prepare", id: latest.id)
                    guard prepared.outcome == "prepared", let newTarget = prepared.target, newTarget.id == targetID else {
                        throw CollieRadarError.invalidSnapshot
                    }
                    self.target = newTarget
                }
            } else { throw CollieRadarError.invalidSnapshot }
        } catch { notice = message(error) }
    }

    private func clearPending() -> Bool {
        do {
            try FileManager.default.removeItem(at: CollieRadarPendingReply.file(workbenchID))
            pending = false
            return true
        } catch {
            notice = radarText("结果已查回，但本机待核记录未能清理；请稍后再核实。")
            return false
        }
    }

    private func complete() {
        // A pre-submit history read must not win over the confirmed receipt.
        historyGeneration += 1
        historyBusy = false
        recorded = true
        if clearPending() {
            notice = radarText(authorizationConfirmed ? "授权确认已记录；尚未执行，仍须原执行入口核验。" : "已记录，待 PM／负责人处理。")
        }
    }

    private func request(_ operation: String, id: String, version: String? = nil, before: String? = nil) async throws -> CollieRadarReplyResponse {
        guard currentSource(), let url = CollieRadarFeed.validate(source) else { throw CollieRadarError.invalidURL }
        configuration.httpCookieStorage = nil
        configuration.urlCredentialStorage = nil
        configuration.timeoutIntervalForRequest = operation == "history" ? 45 : 25
        configuration.timeoutIntervalForResource = operation == "history" ? 60 : 45
        let session = URLSession(configuration: configuration, delegate: CollieRadarReplyNoRedirect(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("1", forHTTPHeaderField: "X-Yihu-Reply")
        request.httpBody = try JSONEncoder().encode(CollieRadarReplyRequest(
            operation: operation, id: id, text: ["prepare", "history"].contains(operation) ? "" : text, request_id: requestID.uuidString,
            version: version, confirmed: operation == "submit", epoch: target?.epoch, before: before,
            authorization_confirmed: authorizationConfirmed ? true : nil,
            authorization_digest: authorizationConfirmed ? target?.authorization?.digest : nil,
            authorization: authorizationConfirmed ? target?.authorization : nil))
        guard let body = request.httpBody, body.count <= 20_000 else {
            throw CollieRadarReplyFailure(code: "invalid_request")
        }
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse else { throw CollieRadarError.invalidSnapshot }
        let maximum = operation == "history" ? 128 * 1024 : 40_000
        guard http.expectedContentLength <= maximum else { throw CollieRadarError.tooLarge }
        if operation == "history" {
            if [401, 403].contains(http.statusCode) { throw CollieRadarReplyFailure(code: "forbidden") }
            if [405, 501].contains(http.statusCode) { throw CollieRadarReplyFailure(code: "history_unsupported") }
        }
        var data = Data()
        for try await byte in bytes {
            guard data.count < maximum else { throw CollieRadarError.tooLarge }
            data.append(byte)
        }
        guard currentSource() else { throw CollieRadarError.invalidURL }
        var result: CollieRadarReplyResponse
        do { result = try JSONDecoder().decode(CollieRadarReplyResponse.self, from: data) }
        catch {
            if operation == "history", http.statusCode == 404 { throw CollieRadarReplyFailure(code: "history_unsupported") }
            throw error
        }
        if operation == "history", http.statusCode == 404, result.error != "target_unavailable" {
            throw CollieRadarReplyFailure(code: "history_unsupported")
        }
        if operation == "history", result.error == "invalid_request", before == nil {
            throw CollieRadarReplyFailure(code: "history_unsupported")
        }
        if !(200...299).contains(http.statusCode) || result.error != nil {
            throw CollieRadarReplyFailure(code: result.error ?? "unavailable", target: result.target)
        }
        if operation == "history" {
            guard result.outcome == "history" else { throw CollieRadarReplyFailure(code: "history_unsupported") }
            result.history = try JSONDecoder().decode(CollieRadarReplyHistory.self, from: data)
        }
        return result
    }

    var originalURL: URL? {
        guard let parts = URLComponents(string: history?.target.url ?? target?.url ?? selected.url),
              parts.scheme == "https", parts.host != nil, parts.user == nil, parts.password == nil else { return nil }
        return parts.url
    }
    private var selectedMatchesTarget: Bool {
        selected.id == targetID && selected.url == (history?.target.url ?? target?.url ?? selected.url)
    }
    var evidenceURLs: [URL] {
        guard selectedMatchesTarget else { return [] }
        return selected.safeEvidenceURLs
    }
    var canSelectNext: Bool {
        selectedMatchesTarget && recorded && !pending && !blocked && !busy && isCurrent
    }
    var isCurrent: Bool { currentSource() }
    var initiallyWritable: Bool { target?.eligible == true || ["等你决策", "等你验收"].contains(selected.status ?? "") }
    var showsComposer: Bool { initiallyWritable || history?.target.eligible == true || !text.isEmpty || pending || recorded || blocked }

    var quickReplies: [String] {
        Self.quickReplies(for: target?.status ?? selected.status)
    }

    static func quickReplies(for status: String?) -> [String] {
        switch status?.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "等你决策":
            return [
                radarText("同意按当前方案推进。"),
                radarText("暂缓此子项，先推进其余已确认部分。"),
                radarText("请补充备选方案对比后再决策。")
            ]
        case "等你验收":
            return [
                radarText("验收通过，可按现有门禁合入。"),
                radarText("工程阶段通过，生产发布暂缓。"),
                radarText("请补充实机或预览证据后再验。")
            ]
        default:
            return []
        }
    }

    func appendQuickReply(_ phrase: String) {
        guard !busy, !pending, !recorded, !blocked else { return }
        let cleaned = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        guard !text.contains(cleaned) else { return }
        let candidate = text + (text.isEmpty ? "" : "\n") + cleaned
        if candidate.unicodeScalars.count <= 4000 { text = candidate }
    }

    @discardableResult
    func appendVoiceTranscript(_ transcript: String) -> Bool {
        guard historyActive, currentSource(), !busy, !pending, !recorded, !blocked else { return false }
        let cleaned = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return false }
        let candidate = text + (text.isEmpty ? "" : "\n") + cleaned
        guard candidate.unicodeScalars.count <= 4000 else { return false }
        let previousText = text
        text = candidate
        guard preserveDraft() else {
            text = previousText
            return false
        }
        return true
    }

    func activateHistory() { historyActive = true }
    func cancelHistory() {
        historyActive = false
        historyGeneration += 1
        historyBusy = false
    }

    func loadHistory(more: Bool = false) async {
        guard historyActive, currentSource(), !historyBusy else { return }
        let loaded = more ? history?.entries.count ?? 0 : 0
        let cursor = more ? history?.before : nil
        guard !more || (cursor != nil && loaded < 100) else { return }
        historyGeneration += 1
        let generation = historyGeneration
        historyBusy = true
        historyNotice = nil
        defer { if generation == historyGeneration { historyBusy = false } }
        do {
            let response = try await request("history", id: targetID, before: cursor)
            guard historyActive, currentSource(), generation == historyGeneration, !Task.isCancelled else { return }
            guard var page = response.history else { throw CollieRadarError.invalidSnapshot }
            try page.validate(id: targetID, after: loaded,
                              existingIDs: more ? Set(history?.entries.map(\.id) ?? []) : [])
            if let next = page.before, (more && historyCursors.contains(next)) || next == cursor {
                throw CollieRadarError.invalidSnapshot
            }
            if more, let previous = history {
                guard previous.total == page.total, previous.target.version == page.target.version,
                      previous.draft == page.draft else { throw CollieRadarError.invalidSnapshot }
                page.entries = previous.entries + page.entries
                page.start = previous.start
                page.read_at = min(previous.read_at, page.read_at)
            } else { historyCursors = [] }
            if let next = page.before { historyCursors.insert(next) }
            history = page
        } catch {
            guard historyActive, currentSource(), generation == historyGeneration, !Task.isCancelled else { return }
            switch (error as? CollieRadarReplyFailure)?.code {
            case "history_unsupported": historyNotice = radarText("当前服务不支持历史回显，请查看原条目。")
            case "forbidden":
                if !pending { target = nil }
                history = nil
                historyCursors = []
                historyNotice = radarText("当前身份无权读取此历史，请核对原数据源权限。")
            case "target_unavailable":
                if !pending { target = nil }
                history = nil
                historyCursors = []
                historyNotice = radarText("条目已不在当前台账或不可见，历史暂不可用。")
            case "history_changed", "invalid_request":
                if !pending { target = nil }
                historyNotice = radarText("来源或分页范围已变化，请重新读取历史。")
            default:
                if let network = error as? URLError, [.notConnectedToInternet, .networkConnectionLost].contains(network.code) {
                    historyNotice = radarText("当前离线，历史暂不可用；这不表示回复没有发送。")
                } else { historyNotice = radarText("历史读取失败，已显示的记录和输入保留；请重试或查看原条目。") }
            }
        }
    }

    private func message(_ error: Error) -> String {
        guard let failure = error as? CollieRadarReplyFailure else {
            return radarText("无法核实条目或回复结果，请稍后重试。")
        }
        switch failure.code {
        case "forbidden": return radarText("当前身份没有回复权限。")
        case "target_unavailable": return radarText("目标已不在当前台账或不可见，输入已保留。")
        case "target_changed": return radarText("条目状态或下一步已变化，请重新核对；当前不一定仍可回复。")
        case "request_reused": return radarText("这次请求已用于另一份回复，请核实原条目。")
        case "invalid_request": return radarText("回复无效或过长，请修改后重新确认。")
        case "invalid_authorization": return radarText("授权申请格式无效，请负责人修正原条目；未授权、未执行。")
        case "authorization_expired": return radarText("授权申请已过期或范围已变化，请重新读取并核对；未授权、未执行。")
        case "write_rejected": return radarText("回复被安全规则拒绝，或写入口暂不可用；请修改或稍后重试。")
        default: return radarText("无法核实条目或回复结果，请稍后重试。")
        }
    }
}

@MainActor
struct CollieRadarReplyVoiceAdapter {
    var isRecording: () -> Bool
    var canCancel: () -> Bool
    var isDelivering: () -> Bool
    var canRetryDelivery: () -> Bool
    var primaryActionEnabled: () -> Bool
    var previewText: () -> String
    var performAction: () async -> Void
    var cancelRecording: () -> Void
    var discardPendingTranscript: () -> Void
    var bindHandler: (UUID, @escaping (String) -> Bool) -> Void
    var unbindHandler: (UUID) -> Void
    var blocksDraftActions: Bool { canCancel() || isDelivering() || canRetryDelivery() }
}

struct CollieRadarReplyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var session: CollieRadarReplySession
    @State private var confirming = false
    @State private var authorizing = false
    @State private var discarding = false
    @State private var discardingVoice = false
    @State private var voiceBinding = UUID()
    let store: CollieRadarStore
    let workbenchID: UUID
    var voice: CollieRadarReplyVoiceAdapter? = nil
    var nextAction: CollieRadarSnapshot.Action? = nil
    var onSelectNext: ((CollieRadarSnapshot.Action) -> Void)? = nil
    private var voiceBusy: Bool {
        voice?.blocksDraftActions == true
    }

    init(store: CollieRadarStore, workbenchID: UUID, source: String, action: CollieRadarSnapshot.Action,
         voice: CollieRadarReplyVoiceAdapter? = nil,
         nextAction: CollieRadarSnapshot.Action? = nil,
         onSelectNext: ((CollieRadarSnapshot.Action) -> Void)? = nil) {
        self.store = store
        self.workbenchID = workbenchID
        self.voice = voice
        self.nextAction = nextAction
        self.onSelectNext = onSelectNext
        _session = State(initialValue: CollieRadarReplySession(workbenchID: workbenchID, source: source, selected: action,
            currentSource: { store.workbenches.first(where: { $0.id == workbenchID })?.source == source }))
    }

    private var historySection: some View {
        Section(radarText("已发送记录与条目备注")) {
            Text(radarText("仅按明确引用关联后续备注，不表示已读、已处理或已执行。"))
                .font(.caption).foregroundStyle(.secondary)
            if let history = session.history {
                Text(radarText("已读取记录数") + "：\(history.entries.count) / \(history.total)")
                    .font(.caption).foregroundStyle(.secondary)
                Text(radarText("本轮读取始于") + "：" + Date(timeIntervalSince1970: history.read_at).formatted())
                    .font(.caption).foregroundStyle(.secondary)
                if history.draft { Text(radarText("草稿备注没有独立评论时间或评论链接，入口指向原草稿。")) }
                if history.entries.isEmpty { Text(radarText("来源当前没有可显示的记录。")) }
                ForEach(history.entries) { entry in
                    DisclosureGroup {
                        Text(entry.text_omitted ? radarText("原文较长，请在原条目查看完整内容。") : entry.text)
                            .textSelection(.enabled)
                        if let request = entry.request_id {
                            Text("request_id: " + request).font(.caption2).textSelection(.enabled)
                        }
                        if let url = URL(string: entry.url) { Link(radarText("查看来源原文"), destination: url) }
                        if entry.kind == "reply" {
                            let feedback = history.feedback(for: entry)
                            if feedback.isEmpty {
                                Text(radarText("已读取范围内暂无对应处理反馈。"))
                                    .font(.caption).foregroundStyle(.secondary)
                            } else {
                                DisclosureGroup(radarText("明确引用此回复的后续备注")) {
                                    ForEach(feedback) { note in
                                        Text(note.text_omitted ? radarText("原文较长，请在原条目查看完整内容。") : note.text)
                                            .textSelection(.enabled)
                                        if let stamp = note.created_at {
                                            Text(Date(timeIntervalSince1970: stamp), format: .dateTime).font(.caption)
                                        }
                                        if let url = URL(string: note.url) { Link(radarText("查看来源原文"), destination: url) }
                                    }
                                }
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(radarText(entry.kind == "reply" ? "手机已发送（回执已核实）" : "条目备注"))
                                .font(.subheadline.bold())
                            if let stamp = entry.created_at {
                                Text(Date(timeIntervalSince1970: stamp), format: .dateTime).font(.caption)
                            }
                        }
                    }
                }
                if history.before != nil {
                    if history.entries.count < 100 {
                        Button(radarText("加载更早记录")) { Task { await session.loadHistory(more: true) } }
                            .disabled(session.historyBusy)
                    } else { Text(radarText("已达本次显示上限，请在原条目查看更早记录。")) }
                }
            }
            if let notice = session.historyNotice {
                Text(notice).foregroundStyle(.orange)
                if session.history != nil { Text(radarText("以上为此前读取的记录，不代表当前最新结果。")) }
            }
            if session.historyBusy { ProgressView(radarText("正在读取历史")) }
            Button(radarText("重新读取历史")) { Task { await session.loadHistory() } }.disabled(session.historyBusy)
            if let url = session.originalURL { Link(radarText("查看原条目"), destination: url) }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if !session.isCurrent {
                    Section { Text(radarText("来源已变化，请关闭后重新打开；原输入仍保留。")) }
                } else {
                    if let target = session.history?.target ?? session.target {
                        Section(radarText("原条目")) {
                            Text(target.title).font(.headline)
                            Text(target.url).font(.caption).textSelection(.enabled)
                            Text(target.status)
                            Text(target.next.isEmpty ? radarText("下一步待补") : target.next)
                            Text(radarText("负责会话") + "：" + (target.owner_session.flatMap { $0.isEmpty ? nil : $0 } ?? radarText("待补")))
                                .font(.caption)
                            ForEach(Array(session.evidenceURLs.enumerated()), id: \.offset) { index, url in
                                Link(radarText("查看证据") + (session.evidenceURLs.count > 1 ? " #\(index + 1)" : ""), destination: url)
                                    .font(.caption)
                            }
                            Text(radarText("条目当前状态不代表某次回复已读或已处理。"))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    historySection
                    if session.showsComposer {
                        Section(radarText(session.recorded ? "本次已记录原文" : "写新回复")) {
                            if !session.recorded, !session.pending, !session.blocked, !session.quickReplies.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(session.quickReplies, id: \.self) { phrase in
                                            Button(phrase) { session.appendQuickReply(phrase) }
                                                .buttonStyle(.bordered)
                                                .controlSize(.small)
                                                .disabled(session.busy)
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            if let voice, !session.recorded, !session.pending, !session.blocked {
                                HStack(spacing: 8) {
                                    Button {
                                        Task { await voice.performAction() }
                                    } label: {
                                        Label(
                                            voice.isRecording() ? radarText("结束语音输入") :
                                            (voice.canRetryDelivery() ? radarText("填入保留的语音转写") : radarText("语音输入回复")),
                                            systemImage: voice.isRecording() ? "stop.fill" :
                                            (voice.canRetryDelivery() ? "arrow.down.doc" : "mic.fill")
                                        )
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .tint(voice.isRecording() ? .red : .accentColor)
                                    .disabled(session.busy || (!voice.primaryActionEnabled() && !voice.canRetryDelivery()))
                                    .accessibilityIdentifier("collie-radar-reply-voice")
                                    if voice.canCancel() && !voice.isRecording() {
                                        ProgressView().controlSize(.small)
                                    }
                                    if voice.canRetryDelivery() {
                                        Button(radarText("放弃保留的转写"), role: .destructive) {
                                            discardingVoice = true
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                    if voice.isRecording() {
                                        Button(radarText("取消录音"), role: .cancel) {
                                            voice.cancelRecording()
                                        }
                                        .buttonStyle(.borderless)
                                        .controlSize(.small)
                                    }
                                }
                                let preview = voice.previewText()
                                if !preview.isEmpty {
                                    Text(preview)
                                        .textSelection(.enabled)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            TextEditor(text: $session.text).frame(minHeight: 160)
                                .disabled(session.busy || session.pending || session.recorded || session.blocked)
                            Text(radarText("最多 4000 字符；仅记录回复，不自动改状态或执行操作。"))
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                        if let notice = session.notice {
                            Section { Text(notice).foregroundStyle(session.recorded ? Color.secondary : Color.orange) }
                        }
                        if let authorization = session.target?.authorization {
                            authorizationSection(authorization)
                        }
                        Section {
                            if session.busy { ProgressView() }
                            if session.canSelectNext, let nextAction, let onSelectNext {
                                Button(radarText("处理下一条待办") + "：" + nextAction.title) {
                                    onSelectNext(nextAction)
                                }
                                .disabled(session.busy)
                                .accessibilityIdentifier("collie-radar-reply-next")
                            }
                            if session.pending {
                                Button(radarText("查回回复结果")) { Task {
                                    await session.check()
                                    if session.recorded { await session.loadHistory() }
                                } }.disabled(session.busy)
                            } else if !session.recorded && !session.blocked {
                                Button(radarText("重新读取条目")) { Task { await session.prepare() } }.disabled(session.busy)
                                Button(radarText("确认并发送回复")) {
                                    authorizing = false
                                    confirming = true
                                }.disabled(!session.canSend || voiceBusy)
                                if session.target?.authorization != nil {
                                    Button(radarText("核对并记录本次授权")) {
                                        authorizing = true
                                        confirming = true
                                    }
                                    .disabled(!session.canAuthorize || voiceBusy)
                                    .accessibilityIdentifier("collie-radar-authorize")
                                    Text(radarText("授权须填写备注并再次确认；普通回复不构成操作授权。"))
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Button(radarText("丢弃未发送草稿"), role: .destructive) { discarding = true }.disabled(session.busy || voiceBusy)
                            }
                        }
                    }
                }
            }
            .navigationTitle(radarText("回复记录与反馈"))
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button(radarText(session.recorded ? "完成" : "关闭")) {
                    if session.preserveDraft() { dismiss() }
                }.disabled(session.busy || voiceBusy)
            } }
            .interactiveDismissDisabled(session.busy || voiceBusy || (!session.recorded && !session.pending && !session.text.isEmpty))
            .confirmationDialog(radarText("放弃这段文字？"), isPresented: $discardingVoice, titleVisibility: .visible) {
                Button(radarText("放弃文字"), role: .destructive) { voice?.discardPendingTranscript() }
                Button(radarText("保留"), role: .cancel) {}
            }
            .alert(radarText("丢弃未发送草稿？"), isPresented: $discarding) {
                Button(radarText("取消"), role: .cancel) {}
                Button(radarText("丢弃未发送草稿"), role: .destructive) {
                    if session.discardDraft() { dismiss() }
                }
            }
            .task {
                voice?.bindHandler(voiceBinding) { [session] transcript in
                    session.appendVoiceTranscript(transcript)
                }
                session.activateHistory()
                if session.initiallyWritable { await session.prepare() }
                if !Task.isCancelled { await session.loadHistory() }
            }
            .onDisappear {
                if voice?.canCancel() == true { voice?.cancelRecording() }
                voice?.unbindHandler(voiceBinding)
                session.cancelHistory()
            }
            .sheet(isPresented: $confirming) {
                NavigationStack {
                    Form {
                        if let target = session.target {
                            Section(radarText("确认回复目标")) {
                                Text(target.title)
                                Text(target.url).font(.caption)
                                Text(target.status)
                                Text(target.next.isEmpty ? radarText("下一步待补") : target.next)
                            }
                        }
                        if authorizing, let authorization = session.target?.authorization {
                            authorizationSection(authorization)
                        }
                        Section(radarText("回复原文")) { Text(session.text).textSelection(.enabled) }
                        Button(radarText(authorizing ? "仅确认上述范围并记录授权" : "发送回复")) {
                            confirming = false
                            Task {
                                await session.submit(authorizing: authorizing)
                                if session.recorded {
                                    await session.loadHistory()
                                    await store.refresh(workbenchID)
                                }
                            }
                        }.disabled((authorizing ? !session.canAuthorize : !session.canSend) || voiceBusy)
                    }
                    .navigationTitle(radarText(authorizing ? "确认本次操作授权？" : "确认发送到原条目？"))
                    .toolbar { ToolbarItem(placement: .cancellationAction) {
                        Button(radarText("取消")) { confirming = false }
                    } }
                }
            }
        }
    }

    private func authorizationSection(_ request: CollieRadarAuthorization) -> some View {
        Section(radarText("本次授权范围")) {
            Text(radarText(request.operationLabel)).font(.headline)
            Text(request.subject)
            Text(request.scope).textSelection(.enabled)
            LabeledContent(radarText("固定指纹")) {
                Text(request.fingerprint).font(.caption.monospaced()).textSelection(.enabled)
            }
            if let budget = request.budget {
                Text("\(radarText("单次 CU 上限"))：\(budget.session_cu.formatted())")
                Text("\(radarText("累计 CU 上限"))：\(budget.total_cu.formatted())")
                Text("\(radarText("分钟上限"))：\(budget.minutes.formatted())")
                Text(radarText("预算是停止目标，不是云平台硬限额；不允许自动扩额或购买。"))
                    .font(.caption).foregroundStyle(.secondary)
            }
            LabeledContent(radarText("授权申请到期")) {
                Text(Date(timeIntervalSince1970: request.expires_at), format: .dateTime)
            }
            Text(radarText("只记录这一次、上述范围的确认；不会自动执行。原工具须核验精确指纹和预算，生产发布仍需独立签名授权。"))
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}
