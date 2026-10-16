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
        let status = path == "/unavailable" ? 503
            : path == "/join" && request.value(forHTTPHeaderField: "Cache-Control") != "no-cache" ? 400 : 200
        let response = HTTPURLResponse(url: request.url!, statusCode: status,
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
        _ = try await CollieRadarStore.download(URL(string: "https://fixture.invalid/join")!, session: session, waitForRefresh: true)
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
        precondition(snapshot.source_refreshing == nil && snapshot.source_refresh_failed == nil)
        let sourceFailure = fixture.replacingOccurrences(of: "{\"date_str\"", with: "{\"source_refresh_failed\":true,\"date_str\"")
        let failedSourceSnapshot = try CollieRadarSnapshot.decode(Data(sourceFailure.utf8))
        precondition(failedSourceSnapshot.source_refresh_failed == true)
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
        precondition(legacyDisplay.searchText == nil && legacyDisplay.onlyMentioningMe == nil)
        let parsedEvidence = CollieRadarSnapshot.Action.parseSafeEvidenceURLs(
            "https://github.com/example/repo/issues/40#issuecomment-1 ; https://github.com/example/repo/pull/47 , https://github.com/example/repo/pull/47 http://insecure.example.org/1 https://user:secret@example.org/2 https://example.org:0/3"
        )
        precondition(parsedEvidence.map(\.absoluteString) == [
            "https://github.com/example/repo/issues/40#issuecomment-1",
            "https://github.com/example/repo/pull/47"
        ])
        var attentionSnapshot = snapshot
        attentionSnapshot.tasks = [
            CollieRadarSnapshot.Action(project: "demo", status: "等你决策", title: "Decision item", next: "Confirm plan", url: "https://example.org/1", id: "t1"),
            CollieRadarSnapshot.Action(project: "demo", status: "进行中", title: "Hidden blocker", next: "等alex接数据线解锁手机", url: "https://example.org/2", id: "t2"),
            CollieRadarSnapshot.Action(project: "other", status: "进行中", title: "Routine work", next: "Lead running CI", url: "https://example.org/3", id: "t3")
        ]
        var mentionFilter = CollieRadarDisplay()
        mentionFilter.onlyMentioningMe = true
        precondition(attentionSnapshot.matchingActions(display: mentionFilter).map(\.title) == ["Decision item", "Hidden blocker"])
        precondition(attentionSnapshot.matchingProjectNames(display: mentionFilter) == ["demo"])
        precondition(CollieRadarFeed.validate("https://example.org/pm/radar.json") != nil)
        var draftWorkbench = CollieRadarWorkbench()
        precondition(!draftWorkbench.supportsWatchDrafts)
        draftWorkbench.source = "https://example.org/pm/radar.json"
        precondition(draftWorkbench.supportsWatchDrafts, "Local drafts must not depend on ledger-write permission")
        draftWorkbench.source = "http://example.org/pm/radar.json"
        precondition(!draftWorkbench.supportsWatchDrafts)
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
        store.importSnapshot(Data(sourceFailure.utf8), for: id)
        precondition(store.errors[id] != nil)
        precondition(CollieRadarStore(defaults: defaults, directory: directory).errors[id] != nil)
        precondition(store.snapshots[id]?.date_str == snapshot.date_str)
        store.importSnapshot(Data(fixture.utf8), for: id)
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
        changed.source = "https://example.org/feed.json"
        loaded.update(changed)
        loaded.importSnapshot(try JSONEncoder().encode(attentionSnapshot), for: id)
        let candidates = loaded.writableDraftCandidates
        precondition(candidates.count == 1 && candidates.first?.action.id == "t1")
        let draftFile = CollieRadarPendingReply.file(id)
        defer { try? FileManager.default.removeItem(at: draftFile) }
        var wrongURL = candidates[0]
        wrongURL.action.url = "https://example.org/other-item"
        precondition(!loaded.saveUnsubmittedDraft(text: "Wrong target", for: wrongURL))
        precondition(!loaded.saveUnsubmittedDraft(text: "   ", for: candidates[0]))
        precondition(!loaded.saveUnsubmittedDraft(text: String(repeating: "x", count: 4001), for: candidates[0]))
        precondition(loaded.saveUnsubmittedDraft(text: "Voice note draft", for: candidates[0]))
        precondition(loaded.writableDraftCandidates.isEmpty, "Workbench with existing draft must not accept another overwrite")
        precondition(!loaded.saveUnsubmittedDraft(text: "Second overwrite", for: candidates[0]))
        precondition(loaded.pendingReply(id)?.id == "t1")
        try? FileManager.default.removeItem(at: draftFile)
        changed.source = "https://example.org/new-source.json"
        loaded.update(changed)
        precondition(loaded.snapshots[id] == nil)
        loaded.importSnapshot(try JSONEncoder().encode(attentionSnapshot), for: id)
        precondition(!loaded.saveUnsubmittedDraft(text: "Old source", for: candidates[0]))
        precondition(!FileManager.default.fileExists(atPath: draftFile.path))
        loaded.remove(secondID)
        precondition(!loaded.workbenches.contains { $0.id == secondID })
        let original = Data("unreadable original preferences".utf8)
        defaults.set(original, forKey: "collie.radar.workbenches.v1")
        let corrupt = CollieRadarStore(defaults: defaults, directory: directory)
        precondition(corrupt.configurationError != nil)
        precondition(corrupt.add() == nil)
        precondition(defaults.data(forKey: "collie.radar.workbenches.v1") == original)

        let authorization = CollieRadarAuthorization(version: 1, operation: "colab.run",
            fingerprint: String(repeating: "a", count: 64), subject: "Synthetic batch", scope: "Public images only",
            expires_at: 2000, budget: .init(session_cu: 5, total_cu: 100, minutes: 15),
            digest: String(repeating: "b", count: 64))
        precondition(authorization.valid)
        precondition(authorization.current(at: Date(timeIntervalSince1970: 1999)))
        precondition(!authorization.current(at: Date(timeIntervalSince1970: 2000)))
        var invalidAuthorization = authorization
        invalidAuthorization.operation = "shell"
        precondition(!invalidAuthorization.valid)
        invalidAuthorization = authorization
        invalidAuthorization.budget!.session_cu = 101
        precondition(!invalidAuthorization.valid)
        invalidAuthorization = authorization
        invalidAuthorization.fingerprint = String(repeating: "a", count: 40)
        precondition(!invalidAuthorization.valid)
        invalidAuthorization.operation = "release.promote"
        invalidAuthorization.budget = nil
        precondition(invalidAuthorization.valid)
        let authorizationData = try JSONEncoder().encode(authorization)
        precondition(!String(data: authorizationData, encoding: .utf8)!.contains("token"))

        // Source-scoped history, including read-only completed items.
        let target: [String: Any] = ["eligible": false, "epoch": "fixture", "id": "PVTI_fixture",
                                    "title": "Synthetic", "url": "https://fixture.invalid/issues/1",
                                    "status": "已完成", "next": "", "version": "fixture"]
        let entry: [String: Any] = ["id": "IC_fixture", "position": 1, "kind": "reply", "text": "Original",
                                   "request_id": "11111111-2222-4333-8444-555555555555",
                                   "url": "https://fixture.invalid/issues/1#issuecomment-1",
                                   "created_at": 100.0, "updated_at": 100.0, "text_omitted": false, "references": []]
        let historyFixture: [String: Any] = ["history_version": 1, "target": target, "entries": [entry],
                                            "total": 1, "start": 1, "end": 1, "read_at": 200.0, "draft": false]
        func decodeHistory(_ value: [String: Any]) throws -> CollieRadarReplyHistory {
            try JSONDecoder().decode(CollieRadarReplyHistory.self, from: JSONSerialization.data(withJSONObject: value))
        }
        let replyHistory = try decodeHistory(historyFixture)
        try replyHistory.validate(id: "PVTI_fixture", after: 0)
        precondition(!replyHistory.target.eligible && replyHistory.entries[0].text == "Original")
        for foreignID in ["PVTI_other", ""] {
            do {
                try replyHistory.validate(id: foreignID, after: 0)
                preconditionFailure("Cross-target history accepted")
            } catch CollieRadarError.invalidSnapshot { }
        }
        for (key, value): (String, Any) in [("total", 2), ("before", "loop"), ("start", 0), ("history_version", 99)] {
            var invalid = historyFixture
            invalid[key] = value
            do {
                try decodeHistory(invalid).validate(id: "PVTI_fixture", after: 0)
                preconditionFailure("Incomplete or unsupported history accepted")
            } catch CollieRadarError.invalidSnapshot { }
        }
        for badURL in ["https://foreign.invalid/issues/1#issuecomment-1",
                       "https://fixture.invalid:444/issues/1#issuecomment-1",
                       "https://fixture.invalid/issues/2#issuecomment-1"] {
            var invalid = historyFixture
            var badEntry = entry
            badEntry["url"] = badURL
            invalid["entries"] = [badEntry]
            do {
                try decodeHistory(invalid).validate(id: "PVTI_fixture", after: 0)
                preconditionFailure("Foreign history link accepted")
            } catch CollieRadarError.invalidSnapshot { }
        }
        do {
            try replyHistory.validate(id: "PVTI_fixture", after: 0, existingIDs: ["IC_fixture"])
            preconditionFailure("Duplicate history page accepted")
        } catch CollieRadarError.invalidSnapshot { }
        var ordinary = entry
        ordinary["id"] = "IC_ordinary"; ordinary["position"] = 2; ordinary["kind"] = "update"
        ordinary.removeValue(forKey: "request_id")
        ordinary["url"] = "https://fixture.invalid/issues/1#issuecomment-2"
        var linked = ordinary
        linked["id"] = "IC_linked"; linked["position"] = 3
        linked["url"] = "https://fixture.invalid/issues/1#issuecomment-3"
        var feedbackFixture = historyFixture
        feedbackFixture["total"] = 3; feedbackFixture["end"] = 3
        for reference in ["11111111-2222-4333-8444-555555555555", "https://fixture.invalid/issues/1#issuecomment-1"] {
            linked["references"] = [reference]
            feedbackFixture["entries"] = [linked, ordinary, entry]
            let feedbackHistory = try decodeHistory(feedbackFixture)
            try feedbackHistory.validate(id: "PVTI_fixture", after: 0)
            precondition(feedbackHistory.feedback(for: feedbackHistory.entries.last!).map(\.id) == ["IC_linked"])
            var completed = feedbackHistory
            completed.target.status = "已完成"
            completed.entries[0].references = []
            precondition(completed.feedback(for: completed.entries.last!).isEmpty, "Status changes must not synthesize feedback")
            completed.entries[0].references = [reference]
            completed.entries[0].position = 0
            precondition(completed.feedback(for: completed.entries.last!).isEmpty, "Earlier notes cannot be subsequent feedback")
            completed.entries[0].position = 3
            completed.entries[0].kind = "reply"
            precondition(completed.feedback(for: completed.entries.last!).isEmpty, "Another phone reply is not an owner response")
        }
        linked["references"] = ["https://foreign.invalid/issues/1#issuecomment-1"]
        feedbackFixture["entries"] = [linked, ordinary, entry]
        do {
            try decodeHistory(feedbackFixture).validate(id: "PVTI_fixture", after: 0)
            preconditionFailure("Foreign feedback reference accepted")
        } catch CollieRadarError.invalidSnapshot { }
        print("Feedback checks passed: exact request/comment references, ordinary notes and status changes never imply handled")
        print("History model checks passed: identity, completed read-only item, pagination range, version, URLs and duplicate pages")
        print("Radar checks passed: shortcut defaults, mixed ordering, hiding, persistence, deleted/duplicate identities, search/filter intersections, action-only projects, legacy decoding, per-workspace search persistence, schema, project identity, URL boundaries, size/date validation, display/cache persistence, ordering, failed-import retention, source isolation, deletion and corrupt-config preservation")
    }
}
