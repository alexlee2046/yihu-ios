import Foundation
import Observation
import WatchConnectivity

@MainActor
@Observable
final class CollieWatchPhoneBridge: NSObject, WCSessionDelegate {
    static let shared = CollieWatchPhoneBridge()
    struct OpenRequest: Equatable { var workbench: String; var task: String; var nonce = UUID() }
    var openRequest: OpenRequest?
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
                rows.append(.init(workbench: workbench.id.uuidString, task: id,
                    title: String(task.title.prefix(160)), project: String(task.project.prefix(80)),
                    status: task.status ?? "", priority: task.priority ?? "", next: String(task.next.prefix(600)),
                    sourceDate: snapshot.generatedAt, readFailed: store.errors[workbench.id] != nil))
            }
        }
        var payload = YihuWatchSnapshot(items: Array(rows.prefix(200)), capturedAt: Date(),
                                        truncated: rows.count > 200, hasSource: !store.snapshots.isEmpty)
        while let data = try? JSONEncoder().encode(payload) {
            if data.count <= YihuWatchSnapshot.maximumBytes {
                try? WCSession.default.updateApplicationContext(["radar": data])
                return
            }
            guard !payload.items.isEmpty else { return }
            payload.items.removeLast(); payload.truncated = true
        }
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor [weak self] in self?.publish() }
    }
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        let kind = message["kind"] as? String
        let workbench = message["workbench"] as? String
        let task = message["task"] as? String
        guard kind == "sync" || (kind == "open" && workbench != nil && task != nil) else {
            replyHandler(["queued": false]); return
        }
        replyHandler(["queued": true]) // Queued, not a promise that phone UI has opened.
        Task { @MainActor [weak self] in
            guard let self else { return }
            if kind == "sync" { self.publish() }
            else if let workbench, let task { self.openRequest = .init(workbench: workbench, task: task) }
        }
    }
}
