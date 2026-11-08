import Foundation
struct BlockStore {
    static let suite = "group.com.callblockpro.shared"
    static let key = "blockedNumbers"
    static func normalized(_ raw: String) -> Int64? {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = CharacterSet(charactersIn: "+0123456789 ()-.")
        guard text.unicodeScalars.allSatisfy({ allowed.contains($0) }),
              !text.dropFirst().contains("+") else { return nil }
        var digits = text.filter { $0 >= "0" && $0 <= "9" }
        if digits.hasPrefix("00") { digits.removeFirst(2) }
        guard (7...15).contains(digits.count), digits.first != "0" else { return nil }
        return Int64(digits)
    }
    static func numbers() -> [Int64] {
        let values = UserDefaults(suiteName: suite)?.array(forKey: key) as? [NSNumber] ?? []
        return Array(Set(values.map { $0.int64Value })).filter { $0 > 0 }.sorted()
    }
    static func add(_ raw: String) -> Bool {
        guard let number = normalized(raw) else { return false }
        let all = Array(Set(numbers() + [number])).sorted()
        UserDefaults(suiteName: suite)?.set(all.map { NSNumber(value: $0) }, forKey: key)
        return numbers().contains(number)
    }
    static func remove(_ number: Int64) {
        UserDefaults(suiteName: suite)?.set(numbers().filter { $0 != number }.map { NSNumber(value: $0) }, forKey: key)
    }
}
