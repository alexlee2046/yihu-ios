import Foundation

@main
struct WatchExperienceChecks {
    static func main() throws {
        let now = Date()
        let item = YihuWatchSnapshot.Item(workbench: UUID().uuidString, task: "synthetic-task",
            sourceToken: String(repeating: "a", count: 64), taskToken: String(repeating: "b", count: 64),
            canDraft: true, title: "示例事项", project: "示例项目", status: "等你决策", priority: "P1",
            next: "补证据", sourceDate: now, readFailed: false)
        var snapshot = YihuWatchSnapshot(items: [item], capturedAt: now, truncated: false,
                                        hasSource: true, sourceDate: now)
        func roundTrip(_ snapshot: YihuWatchSnapshot) throws -> YihuWatchSnapshot {
            try YihuWatchSnapshot.decode(JSONEncoder().encode(snapshot))
        }
        func rejects(_ operation: () throws -> Void) {
            do { try operation(); preconditionFailure("Expected rejection") } catch {}
        }
        precondition(tryValue { try roundTrip(snapshot).count(for: "等你决策") } == 1)
        snapshot.truncated = true
        precondition(snapshot.count(for: "等你决策") == nil, "Legacy trimmed counts are not totals")
        snapshot.decisionCount = 250; snapshot.acceptanceCount = 12
        let trimmed = try roundTrip(snapshot)
        precondition(trimmed.count(for: "等你决策") == 250)
        var invalid = snapshot; invalid.decisionCount = -1
        rejects { _ = try roundTrip(invalid) }
        invalid = snapshot; invalid.acceptanceCount = nil
        rejects { _ = try roundTrip(invalid) }
        invalid = snapshot; invalid.decisionCount = 0
        rejects { _ = try roundTrip(invalid) }
        invalid = snapshot; invalid.decisionCount = Int.max
        rejects { _ = try roundTrip(invalid) }

        let widget = YihuWatchWidgetSnapshot(snapshot)
        precondition(widget.total == 262)
        precondition(!widget.needsRefresh(at: now))
        precondition(widget.needsRefresh(at: now.addingTimeInterval(86400)))
        precondition(widget.needsRefresh(at: now.addingTimeInterval(-301)))
        snapshot.incompleteSources = true
        precondition(YihuWatchWidgetSnapshot(snapshot).needsRefresh(at: now))
        snapshot.incompleteSources = false; snapshot.readFailed = true
        precondition(YihuWatchWidgetSnapshot(snapshot).needsRefresh(at: now))
        snapshot.hasSource = false
        precondition(YihuWatchWidgetSnapshot(snapshot).status(at: now) == "请在手机同步")
        let bytes = try JSONEncoder().encode(widget)
        let keys = Set((try JSONSerialization.jsonObject(with: bytes) as! [String: Any]).keys)
        precondition(keys == Set(["decisionCount", "acceptanceCount", "sourceDate", "hasSource", "readFailed", "incompleteSources"]))
        precondition(!String(decoding: bytes, as: UTF8.self).contains(item.title))
        rejects { _ = try YihuWatchWidgetSnapshot.decode(Data(repeating: 0, count: 2049)) }
        for route in YihuWatchRoute.allCases { precondition(YihuWatchRoute(url: route.url) == route) }
        for url in ["https://actions/all", "yihu-watch://other/all", "yihu-watch://actions/delete",
                    "yihu-watch://actions/all?send=true", "yihu-watch://actions/all#execute"] {
            precondition(YihuWatchRoute(url: URL(string: url)!) == nil)
        }

        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = YihuWatchDraftStore(file: root.appendingPathComponent("draft/proposal.json"))
        precondition(tryValue { try store.load() } == nil)
        var draft = YihuWatchDraft(requestID: UUID(), workbench: item.workbench, task: item.task,
            sourceToken: item.sourceToken!, taskToken: item.taskToken!, text: "测试草稿", transferAttempted: false)
        try store.save(draft)
        precondition(tryValue { try store.load()?.text } == draft.text)
        precondition(draft.matches(item))
        var changedItem = item; changedItem.taskToken = String(repeating: "c", count: 64)
        precondition(!draft.matches(changedItem))
        // Recovery can read the original text without any current snapshot/item.
        snapshot.items = []
        precondition(tryValue { try store.load()?.text } == "测试草稿")
        var other = draft; other.requestID = UUID()
        rejects { try store.save(other) }
        other = draft; other.task = "other-task"
        rejects { try store.save(other) }
        draft.text = "编辑后的草稿"; try store.save(draft)
        draft.transferAttempted = true; try store.save(draft)
        other = draft; other.text = "不允许换内容"
        rejects { try store.save(other) }
        other = draft; other.transferAttempted = false
        rejects { try store.save(other) }
        draft.phoneSaved = true; try store.save(draft)
        precondition(tryValue { try store.load()?.phoneSaved } == true)
        other = draft; other.phoneSaved = false
        rejects { try store.save(other) }
        try store.save(draft) // Original-ID duplicate is safe.
        try store.clear()
        precondition(tryValue { try store.load() } == nil)
        try Data("corrupt".utf8).write(to: store.file)
        rejects { _ = try store.load() }
        rejects { try store.save(draft) }
        precondition(tryValue { try Data(contentsOf: store.file) } == Data("corrupt".utf8))
        try store.clear()
        try Data(repeating: 0, count: YihuWatchDraft.maximumBytes + 1).write(to: store.file)
        rejects { _ = try store.load() }
        try store.clear()
        let obstruction = root.appendingPathComponent("not-a-directory")
        try Data().write(to: obstruction)
        rejects { try YihuWatchDraftStore(file: obstruction.appendingPathComponent("draft.json")).save(draft) }

        let widgetFile = root.appendingPathComponent("widget/counts.json")
        try YihuWatchWidgetStore.save(widget, to: widgetFile)
        precondition(YihuWatchWidgetStore.load(from: widgetFile)?.total == 262)
        try Data("corrupt".utf8).write(to: widgetFile)
        precondition(YihuWatchWidgetStore.load(from: widgetFile) == nil)
        rejects { try YihuWatchWidgetStore.save(widget, to: nil) }
        precondition(YihuWatchQuickDraft.canApply(text: "", locked: false))
        precondition(!YihuWatchQuickDraft.canApply(text: "existing", locked: false))
        precondition(!YihuWatchQuickDraft.canApply(text: "", locked: true))
        print("Synthetic Watch experience checks passed: totals, freshness, privacy projection, routes, protected recovery, receipts, write failures and template guards")
    }
    static func tryValue<T>(_ operation: () throws -> T) -> T {
        do { return try operation() } catch { preconditionFailure("Unexpected failure") }
    }
}
