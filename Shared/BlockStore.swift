import Foundation

struct BlockStore {
    static let suite = "group.com.callblockpro.shared"
    static let key = "blockedNumbers"
    static func numbers() -> [Int64] {
        let values = UserDefaults(suiteName: suite)?.array(forKey: key) as? [NSNumber] ?? []
        return Array(Set(values.map { $0.int64Value })).sorted()
    }
    static func add(_ raw: String) -> Bool {
        let digits = raw.filter(\.isNumber)
        guard (7...15).contains(digits.count), let number = Int64(digits), number > 0 else { return false }
        var all = numbers()
        all.append(number)
        UserDefaults(suiteName: suite)?.set(Array(Set(all)).sorted().map { NSNumber(value: $0) }, forKey: key)
        return true
    }
    static func remove(_ number: Int64) {
        UserDefaults(suiteName: suite)?.set(numbers().filter { $0 != number }.map { NSNumber(value: $0) }, forKey: key)
    }
}
