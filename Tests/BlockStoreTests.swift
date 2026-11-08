import XCTest
@testable import CallBlockPro
final class BlockStoreTests: XCTestCase {
    func testSubscriptionExpiryControlsExtensionList() {
        let defaults = UserDefaults(suiteName: BlockStore.suite)
        let old = defaults?.object(forKey: BlockStore.subscriptionExpiryKey)
        let sample: Int64 = 447700900789
        let existed = BlockStore.numbers().contains(sample)
        defer {
            if !existed { BlockStore.remove(sample) }
            if let old { defaults?.set(old, forKey: BlockStore.subscriptionExpiryKey) }
            else { defaults?.removeObject(forKey: BlockStore.subscriptionExpiryKey) }
        }
        XCTAssertTrue(BlockStore.add("+447700900789"))
        let now = Date()
        BlockStore.setSubscriptionExpiry(nil)
        XCTAssertTrue(BlockStore.blockingNumbers(now: now).isEmpty)
        BlockStore.setSubscriptionExpiry(now.addingTimeInterval(-1))
        XCTAssertTrue(BlockStore.blockingNumbers(now: now).isEmpty)
        BlockStore.setSubscriptionExpiry(now.addingTimeInterval(3600))
        XCTAssertTrue(BlockStore.blockingNumbers(now: now).contains(sample))
    }
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
