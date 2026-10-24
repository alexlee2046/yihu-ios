import XCTest

final class CollieWorkbenchUITests: XCTestCase {
    /// Next-version candidate UI only. The existing CI installs into an isolated
    /// simulator; launch-domain overrides never run against a daily-use device.
    @MainActor
    func testInitialYihuBranding() throws {
        continueAfterFailure = false
        for (language, locale, title, label) in [
            ("en", "en_US", "Start with Yihu", "HTTPS workspace address"),
            ("zh-Hans", "zh_CN", "开始使用一呼", "工作台 HTTPS 地址"),
        ] {
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale,
                                   "-collie.connection.origin", "", "-collie.workbench.selection.v1", "web"]
            app.launch()
            defer { app.terminate() }
            XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 15))
            let address = app.textFields["collie-connection-origin"]
            XCTAssertTrue(address.waitForExistence(timeout: 5))
            XCTAssertEqual(address.label, label)
            XCTAssertEqual(address.placeholderValue, "https://workbench.example.com")
            XCTAssertFalse(app.staticTexts["Connect to a Collie workbench"].exists)
            XCTAssertFalse(app.staticTexts["连接 Collie 工作台"].exists)
            XCTAssertFalse(app.buttons["collie-connection-save"].isEnabled)
            attachWorkbenchScreen(name: "candidate-yihu-onboarding-\(language)")
            // Do not enter an origin, connect, record, download a model or send.
        }
    }

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
        logShortcutHitTargets(app)

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
            XCTAssertFalse(button.label.isEmpty, "A shortcut must retain its accessible name")
            logShortcutHitTargets(app)
            if id.contains("://") && app.buttons["collie-web-reload"].exists {
                XCTAssertEqual(app.webViews.count, 0, "The native error page must replace WebKit's accessibility tree")
            }
            // Evaluate the actual XCUIElement getter rather than the KVC
            // attribute dictionary; keep the same hittability requirement.
            let ready = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in button.isHittable }, object: button)
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
        attachWorkbenchScreen(name: "settings-after-open")
        let notificationStatus = app.descendants(matching: .any)["collie-native-notifications-status"]
        // List cells outside the viewport are lazy at accessibility sizes.
        // Scroll the settings list, without relaxing the status assertion.
        let settingsList = app.collectionViews.firstMatch
        XCTAssertTrue(settingsList.waitForExistence(timeout: 5))
        for _ in 0..<3 where !notificationStatus.exists {
            settingsList.swipeUp()
        }
        attachWorkbenchScreen(name: "settings-notification-status")
        if !notificationStatus.exists { print("Synthetic settings hierarchy: \(app.debugDescription)") }
        XCTAssertTrue(notificationStatus.waitForExistence(timeout: 5))
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
    private func logShortcutHitTargets(_ app: XCUIApplication) {
        // Only this isolated synthetic installation: retain AX geometry and
        // hit-testing evidence without replacing any functional assertion.
        for button in app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "collie-shortcut-")).allElementsBoundByIndex {
            print("Synthetic shortcut: \(button.identifier) selected=\(button.isSelected) enabled=\(button.isEnabled) hittable=\(button.isHittable) frame=\(button.frame)")
            if button.isSelected && !button.isHittable {
                print("Synthetic hierarchy at blocked shortcut:\n\(app.debugDescription)")
            }
        }
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
