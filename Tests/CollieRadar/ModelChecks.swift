import Foundation

private final class RadarFixtureProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let path = request.url!.path
        let body = path == "/oversized" || path == "/streamed-oversized"
            ? Data(count: CollieRadarSnapshot.maximumBytes + 1)
            : Data(#"{"date_str":"2026-10-08 08:00","decisions":[],"active":[],"stale":[],"cold":[]}"#.utf8)
        let headers = path == "/streamed-oversized" ? [:] : ["Content-Length": String(body.count)]
        let response = HTTPURLResponse(url: request.url!, statusCode: path == "/unavailable" ? 503 : 200,
                                       httpVersion: "HTTP/1.1", headerFields: headers)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@main
struct CollieRadarModelChecks {
    @MainActor
    static func main() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [RadarFixtureProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        let (_, downloaded) = try await CollieRadarStore.download(URL(string: "https://fixture.invalid/valid")!, session: session)
        precondition(downloaded.decisions.isEmpty)
        for path in ["oversized", "streamed-oversized"] {
            do {
                _ = try await CollieRadarStore.download(URL(string: "https://fixture.invalid/\(path)")!, session: session)
                preconditionFailure("Accepted oversized download")
            } catch CollieRadarError.tooLarge { }
        }
        do {
            _ = try await CollieRadarStore.download(URL(string: "https://fixture.invalid/unavailable")!, session: session)
            preconditionFailure("Accepted failed feed")
        } catch CollieRadarError.http(503) { }

        let fixture = """
        {"date_str":"2026-10-08 08:00","decisions":[{"project":"demo","status":"等你验收","title":"Original title","next":"Original next","url":"https://example.org/issues/1"}],"active":[{"name":"Demo project","path":"demo","timestamp":1780000000,"message":"A commit","age_hours":1}],"stale":[],"cold":[]}
        """
        let snapshot = try CollieRadarSnapshot.decode(Data(fixture.utf8))
        precondition(snapshot.decisions.first?.title == "Original title")
        precondition(snapshot.projectNames == ["demo"])
        precondition(snapshot.projectName("demo") == "Demo project")
        precondition(snapshot.generatedAt != nil)
        let withoutStatus = fixture.replacingOccurrences(of: "\"status\":\"等你验收\",", with: "")
        let missingStatus = try CollieRadarSnapshot.decode(Data(withoutStatus.utf8))
        precondition(missingStatus.decisions[0].status == nil)
        precondition(missingStatus.taskStatuses(for: "demo").isEmpty)
        precondition(snapshot.taskStatuses(for: "demo") == ["等你验收"])
        precondition(CollieRadarTaskState.classify("进行中") == .progressing)
        precondition(CollieRadarTaskState.classify("等你决策") == .waiting)
        precondition(CollieRadarTaskState.classify("blocked") == .blocked)
        for value in ["stale", "cold", "unknown", "no recent commits"] {
            precondition(CollieRadarTaskState.classify(value) == .unknown)
        }
        var explicitStatus = snapshot
        explicitStatus.active[0].status = "blocked"
        precondition(explicitStatus.taskStatuses(for: "demo") == ["blocked", "等你验收"])
        var statusSearch = CollieRadarDisplay()
        statusSearch.searchText = "blocked"
        precondition(explicitStatus.matchingProjects(display: statusSearch).count == 1)
        precondition(explicitStatus.matchingProjectNames(display: statusSearch) == ["demo"])
        var sortedActions = snapshot
        var first = snapshot.decisions[0]
        first.title = "Zulu"
        first.timestamp = 10
        var second = first
        second.title = "Alpha"
        second.timestamp = 20
        sortedActions.decisions = [first, second]
        var ordering = CollieRadarDisplay()
        precondition(sortedActions.matchingActions(display: ordering).map(\.title) == ["Alpha", "Zulu"])
        ordering.newestFirst = false
        precondition(sortedActions.matchingActions(display: ordering).map(\.title) == ["Alpha", "Zulu"])
        sortedActions.decisions[0].timestamp = nil
        ordering.newestFirst = true
        precondition(sortedActions.matchingActions(display: ordering).map(\.title) == ["Zulu", "Alpha"])
        sortedActions.decisions[1].timestamp = nil
        ordering.newestFirst = true
        precondition(sortedActions.matchingActions(display: ordering).map(\.title) == ["Zulu", "Alpha"])
        explicitStatus.decisions = []
        explicitStatus.active[0].status = nil
        precondition(explicitStatus.taskStatuses(for: "demo").isEmpty)
        var display = CollieRadarDisplay()
        for query in [" ORIGINAL TITLE ", "original next", "等你验收", "demo project", "demo"] {
            display.searchText = query
            precondition(snapshot.matchingActions(display: display).count == 1)
            precondition(snapshot.matchingProjectNames(display: display) == ["demo"])
        }
        display.searchText = "A commit"
        precondition(snapshot.matchingActions(display: display).isEmpty)
        precondition(snapshot.matchingProjects(display: display).count == 1)
        precondition(snapshot.matchingProjectNames(display: display) == ["demo"])
        display.project = "other"
        precondition(snapshot.matchingProjects(display: display).isEmpty)
        precondition(snapshot.matchingProjectNames(display: display).isEmpty)
        display.project = ""
        display.searchText = "no match"
        precondition(snapshot.matchingActions(display: display).isEmpty)
        precondition(snapshot.matchingProjectNames(display: display).isEmpty)
        display.searchText = " \n "
        precondition(snapshot.matchingActions(display: display).count == 1)
        var actionOnly = snapshot
        actionOnly.active = []
        precondition(actionOnly.matchingProjectNames(display: display) == ["demo"])
        // Shared presentation results must preserve the legacy per-card semantics.
        var ledger = snapshot
        ledger.tasks = (0..<2_000).map { index in
            CollieRadarSnapshot.Action(project: "project-\(index % 40)",
                status: ["等你验收", "进行中", "已完成", "搁置", "", " blocked "][index % 6],
                title: "Task \(index)", next: "Next step", url: "", timestamp: Double(index),
                id: "task-\(index)", priority: ["P0", "P1", "P2"][index % 3])
        }
        ledger.active = (0..<40).map { index in
            CollieRadarSnapshot.Project(name: "Project \(index)", path: "project-\(index)",
                timestamp: Double(index), message: "Activity", status: index.isMultiple(of: 2) ? "blocked" : nil)
        }
        var variations = [CollieRadarDisplay()]
        for query in ["Task 1", "Activity", "no match"] {
            var filter = CollieRadarDisplay(); filter.searchText = query; variations.append(filter)
        }
        var history = CollieRadarDisplay(); history.showHistory = true; variations.append(history)
        var priority = CollieRadarDisplay(); priority.priority = "P0"; variations.append(priority)
        var status = CollieRadarDisplay(); status.status = "进行中"; variations.append(status)
        var project = CollieRadarDisplay(); project.project = "project-1"; variations.append(project)
        for filter in variations {
            let tasks = ledger.matchingActions(display: filter, includeAllTasks: true)
            let activity = ledger.matchingProjects(display: filter, matchingTasks: tasks)
            precondition(activity.map(\.path) == ledger.matchingProjects(display: filter).map(\.path))
            let keys = ledger.matchingProjectNames(display: filter, matchingTasks: tasks, matchingActivity: activity)
            precondition(keys == ledger.matchingProjectNames(display: filter))
            let statuses = ledger.taskStatusesByProject(actions: tasks, activity: activity)
            for key in keys {
                precondition((statuses[key] ?? []) == ledger.taskStatuses(for: key, display: filter))
            }
        }
        let start = Date()
        let perCard = ledger.projectNames.map { ledger.taskStatuses(for: $0, display: CollieRadarDisplay()) }
        let perCardTime = Date().timeIntervalSince(start)
        let sharedStart = Date()
        let sharedTasks = ledger.matchingActions(display: CollieRadarDisplay(), includeAllTasks: true)
        let sharedActivity = ledger.matchingProjects(display: CollieRadarDisplay(), matchingTasks: sharedTasks)
        let shared = ledger.taskStatusesByProject(actions: sharedTasks, activity: sharedActivity)
        precondition(perCard == ledger.projectNames.map { shared[$0] ?? [] })
        print(String(format: "Synthetic 2000-task/40-project status presentation: per-card %.1f ms, shared %.1f ms",
                     perCardTime * 1000, Date().timeIntervalSince(sharedStart) * 1000))
        let legacyDisplay = try JSONDecoder().decode(CollieRadarDisplay.self, from: Data(#"{"page":"overview","project":"","compact":false,"showNext":true,"showStatus":true,"showActivity":true,"newestFirst":true}"#.utf8))
        precondition(legacyDisplay.searchText == nil)
        precondition(CollieRadarFeed.validate("https://example.org/pm/radar.json") != nil)
        for invalid in ["http://example.org/radar.json", "https://user:secret@example.org/",
                        "https://example.org/?token=secret", "https://example.org/#secret",
                        "https://example.org:0/radar.json", "https:///radar.json"] {
            precondition(CollieRadarFeed.validate(invalid) == nil, "Accepted an unsafe feed URL")
        }
        do {
            _ = try CollieRadarSnapshot.decode(Data(count: CollieRadarSnapshot.maximumBytes + 1))
            preconditionFailure("Accepted oversized data")
        } catch CollieRadarError.tooLarge { }
        do {
            _ = try CollieRadarSnapshot.decode(Data(fixture.replacingOccurrences(of: "2026-10-08 08:00", with: "unknown").utf8))
            preconditionFailure("Accepted an invalid snapshot date")
        } catch CollieRadarError.invalidSnapshot { }
        let item = CollieRadarWorkbench(name: "My radar", source: "https://example.org/feed.json", favorite: true,
                                       display: CollieRadarDisplay(page: .actions, project: "demo", compact: true,
                                                                  showNext: false, showStatus: false,
                                                                  showActivity: false, newestFirst: false))
        let restored = try JSONDecoder().decode(CollieRadarWorkbench.self, from: JSONEncoder().encode(item))
        precondition(restored == item)
        let suite = "collie.radar.checks." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(suite, isDirectory: true)
        defer {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: directory)
        }
        let shortcuts = CollieWorkbenchShortcuts(defaults: defaults)
        let available = ["https://example.org", "radar-one", "radar-two"]
        precondition(shortcuts.visible(available: available) == available)
        shortcuts.move(from: IndexSet(integer: 2), to: 0, available: available)
        precondition(shortcuts.visible(available: available) == ["radar-two", "https://example.org", "radar-one"])
        shortcuts.set(["radar-one", "radar-one", "deleted", "https://example.org"])
        precondition(shortcuts.visible(available: available) == ["radar-one", "https://example.org"])
        let restoredShortcuts = CollieWorkbenchShortcuts(defaults: defaults)
        precondition(restoredShortcuts.visible(available: available) == ["radar-one", "https://example.org"])
        shortcuts.set([])
        precondition(CollieWorkbenchShortcuts(defaults: defaults).visible(available: available).isEmpty)
        shortcuts.set(["radar-two"])
        precondition(shortcuts.visible(available: available + ["new-workbench"]) == ["radar-two"])
        let store = CollieRadarStore(defaults: defaults, directory: directory)
        let id = store.add()!
        store.importSnapshot(Data(fixture.utf8), for: id)
        precondition(store.snapshots[id]?.decisions.first?.title == "Original title")
        precondition(store.errors[id] == nil)
        store.importSnapshot(Data("invalid".utf8), for: id)
        precondition(store.snapshots[id]?.decisions.first?.title == "Original title")
        precondition(store.errors[id] != nil)
        var searched = store.workbenches.first { $0.id == id }!
        searched.display.searchText = "Original title"
        store.update(searched)
        let secondID = store.add()!
        precondition(store.workbenches.first { $0.id == secondID }?.display.searchText == nil)
        store.move(from: IndexSet(integer: 1), to: 0)
        precondition(store.workbenches.first?.id == secondID)
        let loaded = CollieRadarStore(defaults: defaults, directory: directory)
        precondition(loaded.workbenches.first?.id == secondID)
        precondition(loaded.workbenches.first { $0.id == id }?.display.searchText == "Original title")
        precondition(loaded.workbenches.first { $0.id == secondID }?.display.searchText == nil)
        precondition(loaded.snapshots[id]?.decisions.first?.title == "Original title")
        var changed = loaded.workbenches.first { $0.id == id }!
        changed.source = "https://example.org/new-source.json"
        loaded.update(changed)
        precondition(loaded.snapshots[id] == nil)
        loaded.remove(secondID)
        precondition(!loaded.workbenches.contains { $0.id == secondID })
        let original = Data("unreadable original preferences".utf8)
        defaults.set(original, forKey: "collie.radar.workbenches.v1")
        let corrupt = CollieRadarStore(defaults: defaults, directory: directory)
        precondition(corrupt.configurationError != nil)
        precondition(corrupt.add() == nil)
        precondition(defaults.data(forKey: "collie.radar.workbenches.v1") == original)
        print("Radar checks passed: shortcut defaults, mixed ordering, hiding, persistence, deleted/duplicate identities, search/filter intersections, action-only projects, legacy decoding, per-workspace search persistence, schema, project identity, URL boundaries, size/date validation, display/cache persistence, ordering, failed-import retention, source isolation, deletion and corrupt-config preservation")
    }
}
