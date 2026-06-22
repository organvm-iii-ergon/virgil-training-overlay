import XCTest
@testable import MacTooltipCore

final class CommandLineSupportTests: XCTestCase {
    func testHelpFlagDetectionRecognizesSupportedFlagsAnywhereInArguments() {
        XCTAssertFalse(isHelpRequested(in: ["mac-tooltip"]))
        XCTAssertTrue(isHelpRequested(in: ["mac-tooltip", "-h"]))
        XCTAssertTrue(isHelpRequested(in: ["mac-tooltip", "--help"]))
        XCTAssertTrue(isHelpRequested(in: ["--help", "mac-tooltip"]))
    }

    func testHelpTextPreservesCliOutputContract() {
        XCTAssertEqual(
            macTooltipHelpText,
            """
            Usage: mac-tooltip
            Tracks the frontmost application and prints its name to stdout.

            Options:
              -h, --help   Show this help message
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
