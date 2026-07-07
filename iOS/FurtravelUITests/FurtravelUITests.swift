import XCTest

final class FurtravelUITests: XCTestCase {
    func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestReset"]
        app.launch()
        return app
    }

    func testAddEntryFlow() {
        let app = launchApp()
        app.buttons["addEntryButton"].tap()
        let saveButton = app.buttons["saveEntryButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        saveButton.tap()
    }

    func testFreeLimitTriggersPaywall() {
        let app = launchApp()
        for _ in 0..<40 {
            let addButton = app.buttons["addEntryButton"]
            guard addButton.exists else { break }
            addButton.tap()
            let saveButton = app.buttons["saveEntryButton"]
            if saveButton.waitForExistence(timeout: 2) {
                saveButton.tap()
            }
            if app.buttons["unlockProButton"].waitForExistence(timeout: 1) {
                break
            }
        }
        XCTAssertTrue(app.buttons["unlockProButton"].waitForExistence(timeout: 3) || app.buttons["dismissPaywallButton"].waitForExistence(timeout: 1))
    }

    func testKeyboardDismissesOnTapOutside() {
        let app = launchApp()
        app.buttons["addEntryButton"].tap()
        let textFields = app.textFields
        if textFields.count > 0 {
            textFields.firstMatch.tap()
            XCTAssertTrue(app.keyboards.element.exists)
            app.navigationBars.firstMatch.tap()
            XCTAssertFalse(app.keyboards.element.waitForExistence(timeout: 2))
        }
    }

    func testSettingsSheetOpens() {
        let app = launchApp()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["doneSettingsButton"].waitForExistence(timeout: 3))
        app.buttons["doneSettingsButton"].tap()
    }
}
