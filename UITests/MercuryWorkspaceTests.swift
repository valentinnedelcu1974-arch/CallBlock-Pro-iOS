import XCTest
final class MercuryWorkspaceTests: XCTestCase {
    func testInvalidImportMustBeCorrectedBeforeApply() {
        let app = XCUIApplication()
        app.launch()
        let launch = XCTAttachment(screenshot: app.screenshot())
        launch.name = "Mercury-Protection"
        launch.lifetime = .keepAlways
        add(launch)
        app.buttons["Mercury Workspace · Inspect, import, export"].tap()
        let editor = app.textViews["Numbers to inspect"]
        XCTAssertTrue(editor.waitForExistence(timeout: 10))
        editor.tap()
        editor.typeText("+447700900123\n+447700900123\ninvalid")
        let summary = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "1 unique valid · 1 invalid")).firstMatch
        XCTAssertTrue(summary.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Apply ")).firstMatch.isEnabled)
        let validation = XCTAttachment(screenshot: app.screenshot())
        validation.name = "Mercury-Import-Validation"
        validation.lifetime = .keepAlways
        add(validation)
    }
}
