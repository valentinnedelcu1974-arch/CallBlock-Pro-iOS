import XCTest
import StoreKitTest

final class StoreCaptureTests: XCTestCase {
    private var session: SKTestSession!
    override func setUpWithError() throws {
        continueAfterFailure = false
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "CallBlockProducts", withExtension: "storekit"))
        session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.timeRate = .realTime
        session.clearTransactions()
    }
    override func tearDownWithError() throws { session?.clearTransactions() }

    func testCaptureHelp() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        revealSubscription(in: app)
        XCTAssertTrue(app.buttons["Start 3-day free trial"].waitForExistence(timeout: 20), app.debugDescription)
        attach(app.screenshot(), name: "XNoCall-Subscription-Review")
        for _ in 0..<4 { if app.buttons["Country prefixes"].isHittable { break }; app.swipeDown() }
        app.buttons["Country prefixes"].tap()
        XCTAssertTrue(app.navigationBars["Country prefixes"].waitForExistence(timeout: 5))
        attach(app.screenshot(), name: "XNoCall-Country-Prefix-Help")
        app.buttons["Done"].tap()
    }

    func testTrialPurchaseRestoreAndExpiry() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        revealSubscription(in: app)
        let trial = app.buttons["Start 3-day free trial"]
        XCTAssertTrue(trial.waitForExistence(timeout: 20), app.debugDescription)
        trial.tap()
        XCTAssertTrue(app.staticTexts["Subscription active"].waitForExistence(timeout: 20), app.debugDescription)
        app.buttons["Restore purchases"].tap()
        XCTAssertTrue(app.staticTexts["Subscription restored."].waitForExistence(timeout: 10))
        try session.expireSubscription(productIdentifier: "callblockpro.annual")
        app.terminate()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        revealSubscription(in: app)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Subscribe:")).firstMatch.waitForExistence(timeout: 20), app.debugDescription)
        XCTAssertFalse(app.staticTexts["Subscription active"].exists)
    }

    private func revealSubscription(in app: XCUIApplication) {
        for _ in 0..<7 {
            if app.buttons["Restore purchases"].exists && app.buttons["Restore purchases"].isHittable { return }
            app.swipeUp()
        }
    }

    private func attach(_ screenshot: XCUIScreenshot, name: String) {
        let shot = XCTAttachment(screenshot: screenshot)
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
