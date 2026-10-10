import Foundation

@main
struct CollieRadarModelChecks {
    @MainActor
    static func main() throws {
        let fixture = """
        {"date_str":"2026-10-08 08:00","decisions":[{"project":"demo","status":"等你验收","title":"Original title","next":"Original next","url":"https://example.org/issues/1"}],"active":[{"name":"Demo project","path":"demo","timestamp":1780000000,"message":"A commit","age_hours":1}],"stale":[],"cold":[]}
        """
        let snapshot = try CollieRadarSnapshot.decode(Data(fixture.utf8))
        precondition(snapshot.decisions.first?.title == "Original title")
        precondition(snapshot.projectNames == ["demo"])
        precondition(snapshot.projectName("demo") == "Demo project")
        precondition(snapshot.generatedAt != nil)
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
