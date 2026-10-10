import XCTest

final class CollieWorkbenchUITests: XCTestCase {
    /// Uses only synthetic workbenches in an isolated simulator installation.
    /// Does not access a real server, microphone or user draft.
    @MainActor
    func testIntegratedWorkbenchShortcutNavigation() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-collie.connection.origin", "https://workbench.example.invalid"]
        app.launch()
        defer { app.terminate() }
        let all = app.buttons["collie-shortcuts-all"]
        XCTAssertTrue(all.waitForExistence(timeout: 15))
        XCTAssertEqual(app.buttons.matching(identifier: "collie-shortcuts-all").count, 1)
        XCTAssertFalse(app.buttons["collie-shortcuts-customize"].exists)
        XCTAssertFalse(app.buttons["collie-workbench-picker"].exists)
        let tabs = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "collie-shortcut-"))
        if !tabs.allElementsBoundByIndex.contains(where: { !$0.identifier.contains("://") }) {
            all.tap()
            let addRadar = app.buttons.matching(NSPredicate(
                format: "label == %@ OR label == %@", "添加 PM Radar", "Add PM Radar"
            )).firstMatch
            XCTAssertTrue(addRadar.waitForExistence(timeout: 5))
            if !addRadar.isHittable { app.swipeUp() }
            addRadar.tap()
            XCTAssertTrue(app.textFields["collie-radar-search"].waitForExistence(timeout: 5))
        }
        attachWorkbenchScreen(name: "integrated-workbench-initial")

        let identifiers = tabs.allElementsBoundByIndex.map(\.identifier)
        let web = try XCTUnwrap(identifiers.first(where: { $0.contains("://") }), "Must cover a web workbench")
        let radar = try XCTUnwrap(identifiers.first(where: { !$0.contains("://") }), "Must cover a Radar workbench")
        // Always finish on the web before checking its settings; never let a
        // first-four prefix silently omit Radar.
        for id in [radar, web] {
            let button = app.buttons[id]
            if !button.isHittable {
                // Returning preserves the selected web tab and its viewport;
                // an offscreen target can be on either side, not only the right.
                let scroll = app.scrollViews.firstMatch
                if button.frame.midX < scroll.frame.midX { scroll.swipeRight() }
                else { scroll.swipeLeft() }
            }
            XCTAssertTrue(button.isHittable)
            XCTAssertGreaterThanOrEqual(button.frame.height, 44)
            button.tap()
            attachWorkbenchScreen(name: id.contains("://") ? "web-after-switch" : "radar-after-switch")
            XCTAssertTrue(button.isSelected)
            let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: button)
            XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 10), .completed)
            button.tap()
            XCTAssertFalse(app.alerts.firstMatch.exists)
            XCTAssertEqual(app.buttons.matching(identifier: "collie-shortcuts-all").count, 1)
            XCTAssertFalse(app.buttons["collie-radar-back"].exists)
            XCTAssertFalse(app.buttons["collie-workbench-picker"].exists)
            if !id.contains("://") {
                XCTAssertTrue(app.descendants(matching: .any)["collie-radar-page"].waitForExistence(timeout: 5))
                XCTAssertTrue(app.textFields["collie-radar-search"].isHittable)
                XCTAssertTrue(app.buttons["collie-radar-actions"].isHittable)
                XCTAssertFalse(app.buttons["collie-connection-settings"].exists)
                attachWorkbenchScreen(name: "unified-radar-workbench")
                app.buttons["collie-radar-actions"].tap()
                let configure = app.buttons.matching(NSPredicate(
                    format: "label == %@ OR label == %@", "显示与数据源", "Display and data source"
                )).firstMatch
                XCTAssertTrue(configure.waitForExistence(timeout: 5))
                configure.tap()
                let cancel = app.buttons.matching(NSPredicate(
                    format: "label == %@ OR label == %@", "取消", "Cancel"
                )).firstMatch
                XCTAssertTrue(cancel.waitForExistence(timeout: 5))
                cancel.tap()
                XCTAssertTrue(all.waitForExistence(timeout: 5))
            } else {
                XCTAssertTrue(app.buttons["collie-connection-settings"].isHittable)
                XCTAssertFalse(app.buttons["collie-radar-actions"].exists)
                attachWorkbenchScreen(name: "unified-web-workbench")
            }
        }
        let settings = app.buttons["collie-connection-settings"]
        XCTAssertTrue(settings.isHittable)
        settings.tap()
        XCTAssertTrue(app.descendants(matching: .any)["collie-native-notifications-status"].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        XCTAssertTrue(all.waitForExistence(timeout: 15))
        all.tap()
        let customize = app.buttons["collie-shortcuts-customize"]
        XCTAssertTrue(customize.waitForExistence(timeout: 5))
        customize.tap()
        let management = app.navigationBars.matching(NSPredicate(
            format: "identifier == %@ OR identifier == %@", "自定义快捷入口", "Customize shortcuts"
        )).firstMatch
        XCTAssertTrue(management.waitForExistence(timeout: 5))
        attachWorkbenchScreen(name: "shortcut-management-in-workbench-list")
        // Relaunch closes the management sheet without modifying any setting.
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons[web].waitForExistence(timeout: 5))
        if !app.buttons[web].isHittable { app.scrollViews.firstMatch.swipeRight() }
        XCTAssertTrue(app.buttons[web].isHittable)
        app.buttons[web].tap()
    }

    @MainActor
    private func attachWorkbenchScreen(name: String) {
        // App-layer snapshots can omit composited WebKit/NavigationStack layers.
        // Capture the actual device screen for visual acceptance instead.
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

}
