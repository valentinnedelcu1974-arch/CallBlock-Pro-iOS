import XCTest
final class ControlsTests: XCTestCase {
    func testAddDuplicateDeleteAndHelp() {
        let app = XCUIApplication()
        app.launch()
        let input = app.textFields["numberInput"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap(); input.typeText("+447700900456")
        app.buttons["addNumber"].tap()
        let remove = app.buttons["Remove +447700900456"]
        XCTAssertTrue(remove.waitForExistence(timeout: 5))
        input.tap(); input.typeText("+447700900456")
        app.buttons["addNumber"].tap()
        XCTAssertTrue(app.staticTexts["This number is already in your list."].exists)
        remove.tap()
        XCTAssertFalse(remove.exists)
        app.swipeUp()
        app.buttons["Country prefixes"].tap()
        XCTAssertTrue(app.navigationBars["Country prefixes"].waitForExistence(timeout: 3))
        app.buttons["Done"].tap()
        app.buttons["WhatsApp calls"].tap()
        XCTAssertTrue(app.navigationBars["WhatsApp calls"].waitForExistence(timeout: 3))
        app.buttons["Done"].tap()
        let check = app.buttons["Check subscription availability"]
        if check.waitForExistence(timeout: 10) { check.tap() }
    }
}
