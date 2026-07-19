import XCTest
@testable import MacTooltipCore

final class CommandLineSupportTests: XCTestCase {
    func testHelpFlagDetectionRecognizesSupportedFlagsAnywhereInArguments() {
        XCTAssertFalse(isHelpRequested(in: ["mac-tooltip"]))
        XCTAssertTrue(isHelpRequested(in: ["mac-tooltip", "-h"]))
        XCTAssertTrue(isHelpRequested(in: ["mac-tooltip", "--help"]))
        XCTAssertTrue(isHelpRequested(in: ["--help", "mac-tooltip"]))
    }

    func testVersionFlagDetectionRecognizesSupportedFlagsAnywhereInArguments() {
        XCTAssertFalse(isVersionRequested(in: ["mac-tooltip"]))
        XCTAssertTrue(isVersionRequested(in: ["mac-tooltip", "-v"]))
        XCTAssertTrue(isVersionRequested(in: ["mac-tooltip", "--version"]))
        XCTAssertTrue(isVersionRequested(in: ["--version", "mac-tooltip"]))
    }

    func testVersionTextReportsSemanticVersion() {
        XCTAssertEqual(macTooltipVersionText, "mac-tooltip version \(macTooltipVersion)")
        XCTAssertFalse(macTooltipVersion.isEmpty)
    }

    func testFocusTimestampFormatsFixedInstantDeterministically() {
        // 2024-10-25T13:04:09Z -> "[13:04:09]" in UTC
        let instant = Date(timeIntervalSince1970: 1_729_861_449)
        XCTAssertEqual(focusTimestamp(for: instant, timeZone: TimeZone(identifier: "UTC")!), "[13:04:09]")
    }

    func testTimestampedFocusLinePrefixesWithoutMutatingLine() {
        let instant = Date(timeIntervalSince1970: 1_729_861_449)
        XCTAssertEqual(
            timestampedFocusLine("New focus: Safari", at: instant, timeZone: TimeZone(identifier: "UTC")!),
            "[13:04:09] New focus: Safari"
        )
    }

    func testHelpTextPreservesCliOutputContract() {
        XCTAssertEqual(
            macTooltipHelpText,
            """
            Usage: mac-tooltip
            Tracks the frontmost application and prints its name to stdout.

            Options:
              -h, --help      Show this help message
              -v, --version   Show version information
            """
        )
    }

    func testFocusChangeReporterWritesOnlyChangedFocusLines() {
        var emittedLines = [String]()
        var reporter = FocusChangeReporter { line in
            emittedLines.append(line)
        }

        reporter.handleFocusChange("Terminal")
        reporter.handleFocusChange("Terminal")
        reporter.handleFocusChange("Safari")

        XCTAssertEqual(
            emittedLines,
            [
                "New focus: Terminal",
                "New focus: Safari",
            ]
        )
    }

    func testFocusChangeReporterSanitizesBeforeWritingAndDeduplicating() {
        var emittedLines = [String]()
        var reporter = FocusChangeReporter { line in
            emittedLines.append(line)
        }

        reporter.handleFocusChange("Visual\nStudio Code")
        reporter.handleFocusChange("VisualStudio Code")
        reporter.handleFocusChange(nil)
        reporter.handleFocusChange(nil)

        XCTAssertEqual(
            emittedLines,
            [
                "New focus: VisualStudio Code",
                "New focus: <none>",
            ]
        )
    }

    func testFocusChangeReporterCanStartFromExistingTrackerState() {
        var emittedLines = [String]()
        var reporter = FocusChangeReporter(
            tracker: FocusChangeTracker(lastPrintedName: "Terminal")
        ) { line in
            emittedLines.append(line)
        }

        reporter.handleFocusChange("Terminal")
        reporter.handleFocusChange("Finder")

        XCTAssertEqual(emittedLines, ["New focus: Finder"])
    }
}
