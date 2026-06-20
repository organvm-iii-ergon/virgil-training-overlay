import XCTest
@testable import MacTooltipCore

final class FocusChangeTrackerTests: XCTestCase {
    func testSanitizedAppNameUsesFallbackForMissingName() {
        XCTAssertEqual(sanitizedAppName(nil), "<none>")
    }

    func testSanitizedAppNameRemovesControlCharacters() {
        let rawName = "Ter\nmi\tnal\u{001B}[31m"

        XCTAssertEqual(sanitizedAppName(rawName), "Terminal[31m")
    }

    func testSanitizedAppNameCapsAsciiNamesAtByteLimit() {
        let rawName = String(repeating: "A", count: 140)

        XCTAssertEqual(sanitizedAppName(rawName), String(repeating: "A", count: 128))
    }

    func testSanitizedAppNameDoesNotSplitMultibyteScalarsAtByteLimit() {
        let rawName = String(repeating: "A", count: 127) + "\u{00E9}"

        XCTAssertEqual(sanitizedAppName(rawName), String(repeating: "A", count: 127))
    }

    func testSanitizedAppNameAllowsMultibyteScalarsWithinByteLimit() {
        let rawName = String(repeating: "A", count: 126) + "\u{00E9}"
        let sanitizedName = sanitizedAppName(rawName)

        XCTAssertEqual(sanitizedName, rawName)
        XCTAssertEqual(sanitizedName.utf8.count, 128)
    }

    func testFocusChangeLinePreservesOutputContract() {
        XCTAssertEqual(focusChangeLine(for: "Safari"), "New focus: Safari")
    }

    func testTrackerEmitsOnlyChangedFocusNames() {
        var tracker = FocusChangeTracker()

        XCTAssertEqual(tracker.line(for: "Terminal"), "New focus: Terminal")
        XCTAssertNil(tracker.line(for: "Terminal"))
        XCTAssertEqual(tracker.line(for: "Safari"), "New focus: Safari")
    }

    func testTrackerDeduplicatesAfterSanitizingName() {
        var tracker = FocusChangeTracker()

        XCTAssertEqual(tracker.line(for: "Visual\nStudio Code"), "New focus: VisualStudio Code")
        XCTAssertNil(tracker.line(for: "VisualStudio Code"))
    }

    func testTrackerHandlesMissingNameAsAStableFocusValue() {
        var tracker = FocusChangeTracker()

        XCTAssertEqual(tracker.line(for: nil), "New focus: <none>")
        XCTAssertNil(tracker.line(for: nil))
        XCTAssertEqual(tracker.line(for: "Finder"), "New focus: Finder")
    }
}
