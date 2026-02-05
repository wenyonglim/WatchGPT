import XCTest

final class HistoryTrimmingTests: XCTestCase {
    func testTrimmedHistoryCapsToMax() {
        let messages = (0..<30).map { index in
            "msg-\(index)"
        }

        let trimmed = HistoryTrimmer.trim(messages, maxItems: 16)
        XCTAssertEqual(trimmed.count, 16)
        XCTAssertEqual(trimmed.first, "msg-14")
        XCTAssertEqual(trimmed.last, "msg-29")
    }

    func testTrimmedHistoryWithSmallMaxReturnsSuffix() {
        let messages = (0..<5).map { index in
            "item-\(index)"
        }

        let trimmed = HistoryTrimmer.trim(messages, maxItems: 2)
        XCTAssertEqual(trimmed.count, 2)
        XCTAssertEqual(trimmed, ["item-3", "item-4"])
    }
}
