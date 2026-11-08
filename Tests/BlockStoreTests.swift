import XCTest
@testable import CallBlockPro
final class BlockStoreTests: XCTestCase {
    func testInternationalFormats() {
        XCTAssertEqual(BlockStore.normalized("+44 (1234) 567-890"), 441234567890)
        XCTAssertEqual(BlockStore.normalized("00441234567890"), 441234567890)
        XCTAssertNil(BlockStore.normalized("+44*"))
        XCTAssertNil(BlockStore.normalized("+44abc1234567"))
        XCTAssertNil(BlockStore.normalized("0123456789"))
        XCTAssertNil(BlockStore.normalized("+1234567890123456"))
        XCTAssertNil(BlockStore.normalized("44+12345678"))
    }
    func testPersistenceDeduplicationAndRemoval() {
        let original = BlockStore.numbers()
        let sample: Int64 = 447700900123
        guard !original.contains(sample) else { return }
        defer { BlockStore.remove(sample) }
        XCTAssertTrue(BlockStore.add("+447700900123"))
        XCTAssertTrue(BlockStore.add("00447700900123"))
        XCTAssertEqual(BlockStore.numbers().filter { $0 == sample }.count, 1)
        BlockStore.remove(sample)
        XCTAssertFalse(BlockStore.numbers().contains(sample))
    }
}
