import XCTest

/// Opt-in, presentation-only checks of an already installed app.
/// Run with a separate signed runner and UseDestinationArtifacts. Never use the
/// simulator fixture, install a target app, change preferences, type, or send.
/// Keep physical-device xcresults local with system/user attachments keepNever:
/// XCTest diagnostics can contain private accessibility content even without
/// explicit screenshots or debugDescription calls in this test.
@MainActor
final class CollieDeviceSmokeTests: XCTestCase {
    private struct CheckFailed: Error, CustomStringConvertible {
        let description: String
    }

    private func require(_ value: Bool, _ message: String) throws {
        if !value { throw CheckFailed(description: message) }
    }

    private func wait(_ condition: @escaping () -> Bool, timeout: TimeInterval = 10) -> Bool {
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        return XCTWaiter.wait(for: [ready], timeout: timeout) == .completed
    }

    private func doneButton(_ app: XCUIApplication) -> XCUIElement {
        app.navigationBars.buttons.matching(NSPredicate(format: "label IN %@", ["完成", "Done"])).firstMatch
    }

    private func idle(_ app: XCUIApplication) -> Bool {
        app.alerts.count == 0 && app.sheets.count == 0 && app.keyboards.count == 0 &&
        !app.descendants(matching: .any)["collie-voice-preview"].exists &&
        !app.descendants(matching: .any)["collie-recording-time"].exists &&
        app.buttons["collie-shortcuts-all"].isHittable
    }

    func testExistingWorkbenchNavigationAndReadOnlySettings() throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("Physical-device checks are separate from synthetic simulator acceptance")
        #else
        let environment = ProcessInfo.processInfo.environment
        try XCTSkipUnless(environment["YIHU_DEVICE_SMOKE"] == "1", "Requires explicit physical-device opt-in")
        guard let bundle = environment["YIHU_EXISTING_APP_BUNDLE_ID"],
              bundle.range(of: #"^[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$"#, options: .regularExpression) != nil else {
            throw CheckFailed(description: "An explicit installed target bundle is required")
        }
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: bundle)
        // Activate preserves the running app: no launch arguments, demo origin,
        // terminate/relaunch, reset, permissions prompt or transcript insertion.
        app.activate()
        try require(app.buttons["collie-shortcuts-all"].waitForExistence(timeout: 15), "Main header unavailable")
        try require(idle(app), "Existing user interaction is active; no navigation attempted")
        let shortcuts = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "collie-shortcut-"))
        let initial = shortcuts.allElementsBoundByIndex
        let inventory = initial.map(\.identifier)
        guard let original = initial.first(where: \.isSelected)?.identifier else {
            throw CheckFailed(description: "Original selection unavailable")
        }
        guard let web = initial.first(where: { $0.identifier.contains("://") && $0.isHittable })?.identifier,
              let radar = initial.first(where: { !$0.identifier.contains("://") && $0.isHittable })?.identifier else {
            throw XCTSkip("Both existing Web and Radar shortcuts must be visible; no workbench is added")
        }
        var ownsSheet = false
        defer {
            if ownsSheet, app.alerts.count == 0, doneButton(app).isHittable {
                doneButton(app).tap()
            }
            if idle(app), app.buttons[original].isHittable, !app.buttons[original].isSelected {
                app.buttons[original].tap()
            }
        }

        for identifier in [radar, web] {
            try require(idle(app), "User interaction appeared; navigation stopped")
            let button = app.buttons[identifier]
            try require(button.isHittable && button.frame.height >= 44, "Shortcut target unavailable or too small")
            button.tap()
            try require(wait { button.isSelected && button.isHittable }, "Selected shortcut failed the 10-second hittability check")
            try require(idle(app), "Navigation opened an unexpected interaction")
            button.tap()
            try require(wait { button.isSelected && button.isHittable }, "Repeat tap did not preserve selected shortcut")
            try require(idle(app), "Repeat tap opened an unexpected interaction")
            if identifier == radar {
                try require(app.descendants(matching: .any)["collie-radar-page"].exists, "Radar page unavailable")
                try require(app.textFields["collie-radar-search"].isHittable, "Radar search unavailable")
                try require(app.buttons["collie-radar-actions"].isHittable, "Radar display menu unavailable")
            } else {
                try require(app.buttons["collie-connection-settings"].isHittable, "Web settings unavailable")
                if app.buttons["collie-web-reload"].exists {
                    try require(app.webViews.count == 0, "Native error page retained a WebKit accessibility tree")
                }
            }
        }

        app.buttons["collie-connection-settings"].tap()
        ownsSheet = true
        let notification = app.descendants(matching: .any)["collie-native-notifications-status"]
        let list = app.collectionViews.firstMatch
        try require(list.waitForExistence(timeout: 5), "Settings list unavailable")
        for _ in 0..<3 where !notification.exists { list.swipeUp() }
        try require(notification.waitForExistence(timeout: 5), "Notification capability status unavailable")
        try require(doneButton(app).isHittable, "Settings dismissal unavailable")
        doneButton(app).tap()
        ownsSheet = false
        try require(wait { self.idle(app) }, "Settings did not return to the workbench")

        app.buttons["collie-shortcuts-all"].tap()
        ownsSheet = true
        let customize = app.buttons["collie-shortcuts-customize"]
        try require(customize.waitForExistence(timeout: 5) && customize.isHittable, "Shortcut management entry unavailable")
        // Do not enter the editable list, swipe rows, reorder or toggle anything.
        try require(doneButton(app).isHittable, "Workbench list dismissal unavailable")
        doneButton(app).tap()
        ownsSheet = false
        try require(wait { self.idle(app) }, "Workbench list did not dismiss")
        try require(shortcuts.allElementsBoundByIndex.map(\.identifier) == inventory, "Shortcut inventory changed")
        try require(app.buttons[original].isHittable, "Original workbench cannot be restored")
        app.buttons[original].tap()
        try require(wait { app.buttons[original].isSelected && self.idle(app) }, "Original selection was not restored")
        #endif
    }
}
