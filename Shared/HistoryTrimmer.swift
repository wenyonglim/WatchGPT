import Foundation

enum HistoryTrimmer {
    static func trim<T>(_ items: [T], maxItems: Int) -> [T] {
        guard maxItems > 0, items.count > maxItems else { return items }
        return Array(items.suffix(maxItems))
    }
}
