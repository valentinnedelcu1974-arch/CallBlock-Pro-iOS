import XCTest
final class NotebookTests: XCTestCase {
    func testSaveSearchAndPrivateDecision() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        let input = app.textFields["numberInput"]
        for _ in 0..<6 { if input.exists && input.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(input.exists)
        input.tap(); input.typeText("+447700900789")
        app.buttons["addNumber"].tap()
        let notebook = app.buttons["Rule notebook · Labels and decisions"]
        for _ in 0..<6 { if notebook.exists && notebook.isHittable { break }; app.swipeDown() }
        notebook.tap()
        let row = app.buttons["ruleRow-447700900789"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), app.debugDescription)
        row.tap()
        let label = app.textFields["ruleLabel"]
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        label.tap(); label.typeText("Repeated sales")
        app.buttons["Save decision"].tap()
        XCTAssertTrue(app.staticTexts["Saved on this device"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        let search = app.searchFields.firstMatch
        search.tap(); search.typeText("Repeated sales")
        XCTAssertTrue(app.staticTexts["Repeated sales"].waitForExistence(timeout: 5))
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "XNoCall-Private-Notebook"; shot.lifetime = .keepAlways; add(shot)
    }
}
