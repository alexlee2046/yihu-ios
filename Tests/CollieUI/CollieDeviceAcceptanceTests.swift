import XCTest

/// Additional opt-in checks. Temporary display edits must be undone through the
/// UI, never by replacing app files. Keep raw results local and attachments off.
@MainActor
final class CollieDeviceAcceptanceTests: XCTestCase {
    private struct Failure: Error, CustomStringConvertible { let description: String }
    private var env: [String: String] { ProcessInfo.processInfo.environment }
    private func check(_ condition: Bool, _ message: String) throws {
        if !condition { throw Failure(description: message) }
    }
    private func wait(_ seconds: TimeInterval = 10, _ condition: @escaping () -> Bool) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        return XCTWaiter.wait(for: [expectation], timeout: seconds) == .completed
    }
    private func begin() throws -> XCUIApplication {
        #if targetEnvironment(simulator)
        throw XCTSkip("Requires the separately authorized existing physical-device app")
        #else
        try XCTSkipUnless(env["YIHU_DEVICE_ACCEPTANCE"] == "1", "Explicit device acceptance opt-in required")
        guard let bundle = env["YIHU_EXISTING_APP_BUNDLE_ID"],
              bundle.range(of: #"^[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$"#, options: .regularExpression) != nil else {
            throw Failure(description: "Missing installed app identity")
        }
        let app = XCUIApplication(bundleIdentifier: bundle)
        app.activate()
        try check(app.buttons["collie-shortcuts-all"].waitForExistence(timeout: 15), "Main screen unavailable")
        try check(idle(app), "Active interaction: acceptance stopped")
        return app
        #endif
    }
    private func idle(_ app: XCUIApplication) -> Bool {
        app.buttons["collie-shortcuts-all"].isHittable && app.alerts.count == 0 &&
        app.sheets.count == 0 && app.keyboards.count == 0 &&
        !app.descendants(matching: .any)["collie-voice-preview"].exists &&
        !app.descendants(matching: .any)["collie-recording-time"].exists
    }
    private func shortcuts(_ app: XCUIApplication) -> [XCUIElement] {
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "collie-shortcut-")).allElementsBoundByIndex
    }
    private func selected(_ app: XCUIApplication) throws -> String {
        guard let id = shortcuts(app).first(where: \.isSelected)?.identifier else {
            throw Failure(description: "Original selection unavailable")
        }
        return id
    }
    private func reveal(_ id: String, _ app: XCUIApplication) -> Bool {
        if app.buttons[id].exists && app.buttons[id].isHittable { return true }
        guard let current = shortcuts(app).first(where: \.isSelected)?.identifier else { return false }
        let header = app.scrollViews.containing(.button, identifier: current).firstMatch
        guard header.exists, header.frame.height < 200 else { return false }
        for left in [true, true, false, false, false, false] {
            if left { header.swipeLeft() } else { header.swipeRight() }
            if app.buttons[id].exists && app.buttons[id].isHittable { return true }
        }
        return false
    }
    private func select(_ id: String, _ app: XCUIApplication) throws {
        try check(idle(app), "Active interaction before workbench switch")
        try openExisting(id, app)
        try check(wait { self.idle(app) }, "Workbench switch failed")
    }
    private func openExisting(_ id: String, _ app: XCUIApplication) throws {
        if reveal(id, app) {
            app.buttons[id].tap()
            try check(wait { app.buttons[id].isSelected && app.buttons[id].isHittable }, "Shortcut selection failed")
            return
        }
        // A saved workbench may intentionally be absent from the shortcut bar.
        // Navigate the existing picker instead of altering shortcut preferences.
        guard let data = env["YIHU_EXISTING_RADAR_NAMES"]?.data(using: .utf8),
              let names = try? JSONDecoder().decode([String: String].self, from: data),
              let name = names[id], names.values.filter({ $0 == name }).count == 1 else {
            throw Failure(description: "Existing workbench name is unavailable or ambiguous")
        }
        app.buttons["collie-shortcuts-all"].tap()
        var ownsPicker = true
        defer {
            if ownsPicker && app.alerts.count == 0 {
                let done = app.navigationBars.buttons.matching(NSPredicate(format: "label IN %@", ["完成", "Done"])).firstMatch
                if done.isHittable { done.tap() }
            }
        }
        let list = app.descendants(matching: .any)["collie-workbench-list"].firstMatch
        try check(list.waitForExistence(timeout: 5), "Existing workbench picker unavailable")
        let rows = list.buttons.matching(NSPredicate(format: "label == %@", name))
        for _ in 0..<3 where !rows.allElementsBoundByIndex.contains(where: \.isHittable) { list.swipeUp() }
        guard let row = rows.allElementsBoundByIndex.first(where: \.isHittable) else {
            throw Failure(description: "Existing named workbench is not reachable")
        }
        row.tap()
        ownsPicker = false
        try check(wait { app.buttons["collie-shortcuts-all"].isHittable && app.textFields["collie-radar-search"].exists }, "Existing Radar picker selection failed")
    }
    private func restoreSelection(_ id: String, _ app: XCUIApplication) {
        if idle(app), reveal(id, app), !app.buttons[id].isSelected { app.buttons[id].tap() }
    }
    private func radarID(_ key: String) throws -> String {
        guard let id = env[key], UUID(uuidString: id) != nil else {
            throw Failure(description: "An existing Radar identity is required")
        }
        return "collie-shortcut-" + id
    }

    func testPullToRefreshOnExistingLedger() throws { try refresh(pull: true) }
    func testMenuRefreshOnExistingLedger() throws { try refresh(pull: false) }

    private func refresh(pull: Bool) throws {
        let app = try begin(), original = try selected(app)
        defer { restoreSelection(original, app) }
        try select(radarID("YIHU_RADAR_PRIMARY_ID"), app)
        let page = app.descendants(matching: .any)["collie-radar-page"]
        let scroll = app.scrollViews.containing(.any, identifier: "collie-radar-page").firstMatch
        try check(page.isHittable && scroll.exists, "Radar must start near the top for a real pull gesture")
        // SwiftUI's Menu label does not expose its ProgressView as a UIKit
        // activity indicator on every OS. Require changed SOURCE read time,
        // not an assumed spinner accessibility role or a stopped animation.
        let dates = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", #"\d{4}-\d{2}-\d{2} \d{2}:\d{2}"#))
        try check(dates.count == 1, "An unambiguous source read time is required")
        let previous = dates.firstMatch.label
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 8 * 3600)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        try XCTSkipUnless(previous != formatter.string(from: Date()), "Source time has minute precision; retry after its minute boundary")
        let started = Date()
        if pull {
            // Pull through most of the verified native scroll viewport. A
            // generic mid-content swipe can merely reposition the scroll view.
            let start = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15))
            let end = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
            start.press(forDuration: 0.1, thenDragTo: end)
        } else {
            app.buttons["collie-radar-actions"].tap()
            let refresh = app.buttons.matching(NSPredicate(format: "label IN %@", ["刷新", "Refresh"])).firstMatch
            try check(refresh.waitForExistence(timeout: 5) && refresh.isEnabled, "Configured source refresh is unavailable")
            refresh.tap()
        }
        let advanced = wait(50) { dates.count == 1 && dates.firstMatch.label != previous }
        let failure = app.staticTexts.matching(NSPredicate(format: "label IN %@", ["更新失败，原有快照已保留。", "Update failed. Your previous snapshot has been kept."])).count > 0
        print("YIHU_DEVICE_REFRESH_ERROR_VISIBLE=\(failure ? 1 : 0)")
        try check(advanced, "Source read time did not advance after the refresh action")
        try check(idle(app) && page.exists, "Refresh lost the workbench")
        // Also compare the actual device cache with the source response before
        // calling this a successful live-ledger refresh.
        print("YIHU_DEVICE_REFRESH_MILLISECONDS=\(Int(Date().timeIntervalSince(started) * 1000))")
    }

    private func searchValue(_ app: XCUIApplication) -> String {
        let field = app.textFields["collie-radar-search"]
        let value = field.value as? String ?? ""
        return value == field.placeholderValue ? "" : value
    }
    private func selectWhileOwningSearch(_ id: String, _ app: XCUIApplication) throws {
        try check(app.alerts.count == 0 && app.sheets.count == 0, "Unexpected interaction during filter test")
        try openExisting(id, app)
    }
    private func clearOwnedSearch(_ app: XCUIApplication, probes: Set<String>) {
        guard probes.contains(searchValue(app)), app.alerts.count == 0, app.sheets.count == 0 else { return }
        let clear = app.buttons.matching(NSPredicate(format: "label IN %@", ["清空搜索", "Clear search"])).firstMatch
        if clear.isHittable { clear.tap() }
    }

    func testReversibleSearchIsolationBetweenExistingWorkbenches() throws {
        let app = try begin(), original = try selected(app)
        defer { restoreSelection(original, app) }
        let primary = try radarID("YIHU_RADAR_PRIMARY_ID"), secondary = try radarID("YIHU_RADAR_SECONDARY_ID")
        try check(primary != secondary, "Two distinct existing workbenches are required")
        let firstProbe = "YIHU-DEVICE-ISOLATION-A-991292C"
        let secondProbe = "YIHU-DEVICE-ISOLATION-B-991292C"
        let probes: Set<String> = [firstProbe, secondProbe]
        try select(primary, app)
        try XCTSkipUnless(searchValue(app).isEmpty, "Existing user search must be preserved")
        try select(secondary, app)
        try XCTSkipUnless(searchValue(app).isEmpty, "Other workbench has an existing user search")
        defer {
            // Only remove our exact synthetic markers, never an unrelated query.
            for id in [primary, secondary] where app.alerts.count == 0 && app.sheets.count == 0 {
                if (try? openExisting(id, app)) != nil { clearOwnedSearch(app, probes: probes) }
            }
            if app.alerts.count == 0 && app.sheets.count == 0 && app.buttons[original].isHittable {
                app.buttons[original].tap()
            }
        }
        try select(primary, app)
        app.textFields["collie-radar-search"].tap()
        app.textFields["collie-radar-search"].typeText(firstProbe + "\n")
        try check(searchValue(app) == firstProbe, "First synthetic filter was not entered")
        let empty = app.staticTexts.matching(NSPredicate(format: "label IN %@", ["这份快照中没有匹配的任务。", "No matching tasks in this snapshot."])).firstMatch
        if !empty.exists { app.scrollViews.containing(.any, identifier: "collie-radar-page").firstMatch.swipeUp() }
        try check(empty.waitForExistence(timeout: 5), "Synthetic unmatched filter did not produce an empty result")
        try selectWhileOwningSearch(secondary, app)
        try check(searchValue(app).isEmpty, "First workbench search leaked into the second")
        app.textFields["collie-radar-search"].tap()
        app.textFields["collie-radar-search"].typeText(secondProbe + "\n")
        try selectWhileOwningSearch(primary, app)
        try check(searchValue(app) == firstProbe, "First workbench did not retain its own filter")
        clearOwnedSearch(app, probes: probes)
        try check(searchValue(app).isEmpty, "First synthetic query was not cleared")
        try selectWhileOwningSearch(secondary, app)
        try check(searchValue(app) == secondProbe, "Second workbench did not retain its own filter")
        clearOwnedSearch(app, probes: probes)
        try check(searchValue(app).isEmpty, "Second synthetic query was not cleared")
        try selectWhileOwningSearch(original, app)
        try check(try selected(app) == original, "Original selection was not restored after isolation test")
    }

    func testForegroundResumePreservesWorkbenches() throws {
        let app = try begin(), original = try selected(app)
        let inventory = shortcuts(app).map(\.identifier)
        XCUIDevice.shared.press(.home)
        app.activate()
        try check(wait(15) { self.idle(app) }, "Foreground resume did not recover the main screen")
        try check(shortcuts(app).map(\.identifier) == inventory, "Workbench inventory changed across foreground resume")
        try check(try selected(app) == original, "Selected workbench changed across foreground resume")
        // This is foreground recovery, deliberately not a destructive cold
        // restart of a WebKit process that might hold an unsent user draft.
    }
}
