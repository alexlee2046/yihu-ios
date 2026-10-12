import Foundation
import Observation
import SwiftUI

private struct CollieRadarReplyResponse: Decodable {
    var outcome: String?
    var error: String?
    var target: CollieRadarReplyTarget?
}

private struct CollieRadarReplyRequest: Encodable {
    var operation: String
    var id: String
    var text: String
    var request_id: String
    var version: String?
    var confirmed: Bool
    var epoch: String?
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
    private let workbenchID: UUID
    private let source: String
    private let selected: CollieRadarSnapshot.Action
    private var targetID: String

    init(workbenchID: UUID, source: String, selected: CollieRadarSnapshot.Action) {
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
                if pending { notice = radarText("有待核实的回复，先查回结果再重试。") }
            } catch {
                blocked = true
                notice = radarText("待核回复记录无法读取，原始记录已保留；暂不能发送新的回复。")
            }
        }
    }

    var canSend: Bool {
        target?.eligible == true && ["等你决策", "等你验收"].contains(target?.status ?? "") &&
        !busy && !blocked && !pending && !recorded &&
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text.unicodeScalars.count <= 4000
    }

    func prepare() async {
        guard !busy, !blocked, !pending, !recorded else { return }
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
                                            requestID: requestID, submitted: submitted)
        let data = try JSONEncoder().encode(record)
        #if os(iOS)
        try data.write(to: file, options: [.atomic, .completeFileProtection])
        #else
        try data.write(to: file, options: [.atomic])
        #endif
    }

    func submit() async {
        guard canSend, let target else { return }
        busy = true
        defer { busy = false }
        do {
            // Persist before any submit. A killed app must resume the same request ID,
            // not turn an uncertain write into a new comment.
            try persist(target, submitted: true)
        } catch {
            notice = radarText("无法安全保存待核回复，尚未发送。")
            return
        }
        pending = true
        do {
            let result = try await request("submit", id: target.id, version: target.version)
            guard result.outcome == "recorded" else { throw CollieRadarError.invalidSnapshot }
            complete()
        } catch let error as CollieRadarReplyFailure {
            if ["forbidden", "invalid_request", "target_changed", "target_unavailable", "write_rejected"].contains(error.code) {
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
        recorded = true
        if clearPending() { notice = radarText("已记录，待 PM／负责人处理。") }
    }

    private func request(_ operation: String, id: String, version: String? = nil) async throws -> CollieRadarReplyResponse {
        guard let url = CollieRadarFeed.validate(source) else { throw CollieRadarError.invalidURL }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.urlCredentialStorage = nil
        configuration.timeoutIntervalForRequest = 25
        configuration.timeoutIntervalForResource = 45
        let session = URLSession(configuration: configuration, delegate: CollieRadarReplyNoRedirect(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("1", forHTTPHeaderField: "X-Yihu-Reply")
        request.httpBody = try JSONEncoder().encode(CollieRadarReplyRequest(
            operation: operation, id: id, text: operation == "prepare" ? "" : text, request_id: requestID.uuidString,
            version: version, confirmed: operation == "submit", epoch: target?.epoch))
        guard let body = request.httpBody, body.count <= 20_000 else {
            throw CollieRadarReplyFailure(code: "invalid_request")
        }
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse else { throw CollieRadarError.invalidSnapshot }
        guard http.expectedContentLength <= 40_000 else { throw CollieRadarError.tooLarge }
        var data = Data()
        for try await byte in bytes {
            guard data.count < 40_000 else { throw CollieRadarError.tooLarge }
            data.append(byte)
        }
        let result = try JSONDecoder().decode(CollieRadarReplyResponse.self, from: data)
        if !(200...299).contains(http.statusCode) || result.error != nil {
            throw CollieRadarReplyFailure(code: result.error ?? "unavailable", target: result.target)
        }
        return result
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
        case "write_rejected": return radarText("回复被安全规则拒绝，或写入口暂不可用；请修改或稍后重试。")
        default: return radarText("无法核实条目或回复结果，请稍后重试。")
        }
    }
}

struct CollieRadarReplyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var session: CollieRadarReplySession
    @State private var confirming = false
    @State private var discarding = false
    let store: CollieRadarStore
    let workbenchID: UUID

    init(store: CollieRadarStore, workbenchID: UUID, source: String, action: CollieRadarSnapshot.Action) {
        self.store = store
        self.workbenchID = workbenchID
        _session = State(initialValue: CollieRadarReplySession(workbenchID: workbenchID, source: source, selected: action))
    }

    var body: some View {
        NavigationStack {
            Form {
                if let target = session.target {
                    Section(radarText("确认回复目标")) {
                        Text(target.title).font(.headline)
                        Text(target.url).font(.caption).textSelection(.enabled)
                        Text(target.status)
                        Text(target.next.isEmpty ? radarText("下一步待补") : target.next)
                    }
                }
                Section(radarText("回复原文")) {
                    TextEditor(text: $session.text).frame(minHeight: 160)
                        .disabled(session.busy || session.pending || session.recorded || session.blocked)
                    Text(radarText("最多 4000 字符；仅记录回复，不自动改状态或执行操作。"))
                        .font(.footnote).foregroundStyle(.secondary)
                }
                if let notice = session.notice {
                    Section { Text(notice).foregroundStyle(session.recorded ? Color.secondary : Color.orange) }
                }
                Section {
                    if session.busy { ProgressView() }
                    if session.pending {
                        Button(radarText("查回回复结果")) { Task { await session.check() } }.disabled(session.busy)
                    } else if !session.recorded && !session.blocked {
                        Button(radarText("重新读取条目")) { Task { await session.prepare() } }.disabled(session.busy)
                        Button(radarText("确认并发送回复")) { confirming = true }.disabled(!session.canSend)
                        Button(radarText("丢弃未发送草稿"), role: .destructive) { discarding = true }.disabled(session.busy)
                    }
                }
            }
            .navigationTitle(radarText("回复决策／验收反馈"))
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button(radarText(session.recorded ? "完成" : "关闭")) {
                    if session.preserveDraft() { dismiss() }
                }.disabled(session.busy)
            } }
            .interactiveDismissDisabled(session.busy || (!session.recorded && !session.pending && !session.text.isEmpty))
            .alert(radarText("丢弃未发送草稿？"), isPresented: $discarding) {
                Button(radarText("取消"), role: .cancel) {}
                Button(radarText("丢弃未发送草稿"), role: .destructive) {
                    if session.discardDraft() { dismiss() }
                }
            }
            .task { await session.prepare() }
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
                        Section(radarText("回复原文")) { Text(session.text).textSelection(.enabled) }
                        Button(radarText("发送回复")) {
                            confirming = false
                            Task {
                                await session.submit()
                                if session.recorded { await store.refresh(workbenchID) }
                            }
                        }.disabled(!session.canSend)
                    }
                    .navigationTitle(radarText("确认发送到原条目？"))
                    .toolbar { ToolbarItem(placement: .cancellationAction) {
                        Button(radarText("取消")) { confirming = false }
                    } }
                }
            }
        }
    }
}
