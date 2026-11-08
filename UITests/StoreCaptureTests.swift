import XCTest
import StoreKitTest

final class StoreCaptureTests: XCTestCase {
    private var session: SKTestSession!
    override func setUpWithError() throws {
        continueAfterFailure = false
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "CallBlockProducts", withExtension: "storekit"))
        session = try SKTestSession(contentsOf: url)
        session.disableDialogs = true
        session.timeRate = .realTime
        session.clearTransactions()
    }
    override func tearDownWithError() throws { session?.clearTransactions() }

    func testCaptureHelp() {
        let app = XCUIApplication()
        app.launch()
        app.swipeUp()
        XCTAssertTrue(app.buttons["Start 3-day free trial"].waitForExistence(timeout: 15))
        attach(app.screenshot(), name: "CallBlock-Subscription-Review")
        app.buttons["Country prefixes"].tap()
        XCTAssertTrue(app.navigationBars["Country prefixes"].waitForExistence(timeout: 5))
        app.swipeUp()
        attach(app.screenshot(), name: "CallBlock-Country-Prefix-Help")
        app.buttons["Done"].tap()
    }

    func testTrialPurchaseRestoreAndExpiry() throws {
        let app = XCUIApplication()
        app.launch()
        app.swipeUp()
        let trial = app.buttons["Start 3-day free trial"]
        XCTAssertTrue(trial.waitForExistence(timeout: 15))
        trial.tap()
        XCTAssertTrue(app.staticTexts["Subscription active"].waitForExistence(timeout: 15))
        app.buttons["Restore purchases"].tap()
        XCTAssertTrue(app.staticTexts["Subscription restored."].waitForExistence(timeout: 10))
        try session.expireSubscription(productIdentifier: "callblockpro.annual")
        app.terminate()
        app.launch()
        app.swipeUp()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Subscribe:")).firstMatch.waitForExistence(timeout: 15))
        XCTAssertFalse(app.staticTexts["Subscription active"].exists)
    }

    private func attach(_ screenshot: XCUIScreenshot, name: String) {
        let shot = XCTAttachment(screenshot: screenshot)
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
