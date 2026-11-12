import XCTest
final class MercuryStoreScreenshots: XCTestCase {
    func testCaptureWorkspace() {
        let app = XCUIApplication()
        app.launch()
        let workspace = app.buttons["Mercury Workspace · Inspect, import, export"]
        XCTAssertTrue(workspace.waitForExistence(timeout: 15))
        workspace.tap()
        XCTAssertTrue(app.navigationBars["Mercury Workspace"].waitForExistence(timeout: 10))
        attach(app.screenshot(), name: "Mercury-Workspace")
        app.swipeUp()
        attach(app.screenshot(), name: "Mercury-Inspector-Export")
    }
    private func attach(_ screenshot: XCUIScreenshot, name: String) {
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
