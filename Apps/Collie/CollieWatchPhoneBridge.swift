import CryptoKit
import Foundation
import Observation
import WatchConnectivity

private struct CollieWatchReplyCallback: @unchecked Sendable {
    var send: ([String: Any]) -> Void
}

@MainActor
@Observable
final class CollieWatchPhoneBridge: NSObject, WCSessionDelegate {
    static let shared = CollieWatchPhoneBridge()
    struct OpenRequest: Equatable { var workbench: String; var task: String; var sourceToken: String; var nonce = UUID() }
    static func sourceToken(_ workbench: CollieRadarWorkbench) -> String {
        let identity = workbench.source + "\n" + (workbench.watchSourceIdentity?.uuidString ?? "")
        return SHA256.hash(data: Data(identity.utf8)).map { String(format: "%02x", $0) }.joined()
    }
    static func taskToken(_ task: CollieRadarSnapshot.Action) -> String {
        let fields = [task.id ?? "", task.title, task.status ?? "", task.next]
        let data = (try? JSONEncoder().encode(fields)) ?? Data()
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
    var openRequest: OpenRequest?
    @ObservationIgnored var canReceiveDraft: () -> Bool = { false }
    @ObservationIgnored var phoneNotificationState: () -> String = { "unknown" }
    func notificationStateChanged() { publish() }
    private weak var store: CollieRadarStore?

    func bind(_ store: CollieRadarStore) {
        self.store = store
        store.watchUpdate = { [weak self] in self?.publish() }
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func publish() {
        guard let store, WCSession.default.activationState == .activated,
              WCSession.default.isPaired, WCSession.default.isWatchAppInstalled else { return }
        var rows: [YihuWatchSnapshot.Item] = []
        for workbench in store.ordered {
            guard let snapshot = store.snapshots[workbench.id] else { continue }
            for task in snapshot.allTasks where ["等你决策", "等你验收"].contains(task.status ?? "") {
                guard let id = task.id, !id.isEmpty else { continue }
                rows.append(.init(workbench: workbench.id.uuidString, task: id, sourceToken: Self.sourceToken(workbench), taskToken: Self.taskToken(task),
                    canDraft: workbench.supportsWatchDrafts,
                    title: String(task.title.prefix(160)), project: String(task.project.prefix(80)),
                    status: task.status ?? "", priority: task.priority ?? "", next: String(task.next.prefix(600)),
                    sourceDate: snapshot.generatedAt, readFailed: store.errors[workbench.id] != nil))
            }
        }
        var payload = YihuWatchSnapshot(items: Array(rows.prefix(200)), capturedAt: Date(),
                                        truncated: rows.count > 200, hasSource: !store.snapshots.isEmpty,
            sourceDate: store.snapshots.values.compactMap(\.generatedAt).min(), readFailed: !store.errors.isEmpty, phoneNotificationState: phoneNotificationState())
        while let data = try? JSONEncoder().encode(payload) {
            if data.count <= YihuWatchSnapshot.maximumBytes {
                try? WCSession.default.updateApplicationContext(["radar": data])
                return
            }
            guard !payload.items.isEmpty else { return }
            payload.items.removeLast(); payload.truncated = true
        }
    }

    private func receiveDraft(_ data: Data) -> String {
        guard canReceiveDraft() else { return "busy" }
        guard let store, let draft = try? YihuWatchDraft.decode(data),
              let id = UUID(uuidString: draft.workbench),
              let bench = store.workbenches.first(where: { $0.id == id }),
              bench.supportsWatchDrafts,
              Self.sourceToken(bench) == draft.sourceToken,
              let task = store.snapshots[id]?.allTasks.first(where: { $0.id == draft.task }),
              ["等你决策", "等你验收"].contains(task.status ?? ""),
              Self.taskToken(task) == draft.taskToken else { return "changed" }
        let file = CollieRadarPendingReply.file(id)
        if FileManager.default.fileExists(atPath: file.path) {
            guard let handle = try? FileHandle(forReadingFrom: file) else { return "busy" }
            defer { try? handle.close() }
            guard let bytes = try? handle.read(upToCount: 40_001), bytes.count <= 40_000,
                  let saved = try? JSONDecoder().decode(CollieRadarPendingReply.self, from: bytes),
                  saved.requestID == draft.requestID, saved.source == bench.source,
                  saved.target.id == draft.task, saved.text == draft.text else { return "busy" }
            return "saved" // Lost acknowledgement retry; never overwrite an existing draft.
        }
        do {
            let folder = file.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            var excluded = folder; var values = URLResourceValues(); values.isExcludedFromBackup = true
            try excluded.setResourceValues(values)
            let target = CollieRadarReplyTarget(eligible: false, epoch: "", id: draft.task,
                title: task.title, url: task.url, status: task.status ?? "", next: task.next, version: "")
            let record = CollieRadarPendingReply(source: bench.source, target: target, text: draft.text,
                                                requestID: draft.requestID, submitted: false)
            try JSONEncoder().encode(record).write(to: file, options: [.atomic, .completeFileProtection])
            openRequest = .init(workbench: bench.id.uuidString, task: draft.task, sourceToken: draft.sourceToken)
            return "saved"
        } catch { return "unavailable" }
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor [weak self] in self?.publish() }
    }
    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor [weak self] in self?.publish() }
    }
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        let kind = message["kind"] as? String
        if kind == "draft" {
            guard let data = message["draft"] as? Data, data.count <= YihuWatchDraft.maximumBytes else {
                replyHandler(["state": "invalid"]); return
            }
            let callback = CollieWatchReplyCallback(send: replyHandler)
            Task { @MainActor [weak self] in callback.send(["state": self?.receiveDraft(data) ?? "unavailable"]) }
            return
        }
        let workbench = message["workbench"] as? String
        let task = message["task"] as? String
        let sourceToken = message["sourceToken"] as? String
        guard kind == "sync" || (kind == "open" && workbench != nil && task != nil && sourceToken != nil) else {
            replyHandler(["queued": false]); return
        }
        replyHandler(["queued": true]) // Queued, not a promise that phone UI has opened.
        Task { @MainActor [weak self] in
            guard let self else { return }
            if kind == "sync" { self.publish() }
            else if let workbench, let task, let sourceToken { self.openRequest = .init(workbench: workbench, task: task, sourceToken: sourceToken) }
        }
    }
}
