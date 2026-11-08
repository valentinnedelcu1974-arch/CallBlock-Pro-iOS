import XCTest
final class StoreCaptureTests: XCTestCase {
    func testCaptureHelp() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Country prefixes"].waitForExistence(timeout: 15))
        app.buttons["Country prefixes"].tap()
        XCTAssertTrue(app.navigationBars["Country prefixes"].waitForExistence(timeout: 5))
        app.swipeUp()
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "CallBlock-Country-Prefix-Help"
        shot.lifetime = .keepAlways
        add(shot)
        app.buttons["Done"].tap()
    }
}
