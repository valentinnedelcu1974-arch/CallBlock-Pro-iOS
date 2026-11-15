import XCTest
@testable import CallBlockPro
final class RuleNotesTests: XCTestCase {
    func testPrivateDecisionRoundTripAndRemoval() {
        let number: Int64 = 447700900191
        defer { RuleNotes.remove(number) }
        RuleNotes.save(number, label: "Repeated sales", reason: "Repeated sales", note: "My own decision")
        XCTAssertEqual(RuleNotes.read(number).label, "Repeated sales")
        XCTAssertEqual(RuleNotes.read(number).note, "My own decision")
        RuleNotes.remove(number)
        XCTAssertEqual(RuleNotes.read(number).label, "")
        XCTAssertEqual(RuleNotes.read(number).note, "")
    }
}
