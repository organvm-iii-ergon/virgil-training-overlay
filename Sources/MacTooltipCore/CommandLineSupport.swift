import Foundation

public let macTooltipVersion = "1.0.0"

public let macTooltipVersionText = "mac-tooltip version \(macTooltipVersion)"

public let macTooltipHelpText = """
Usage: mac-tooltip
Tracks the frontmost application and prints its name to stdout.

Options:
  -h, --help      Show this help message
  -v, --version   Show version information
"""

public func isHelpRequested(in arguments: [String]) -> Bool {
    arguments.contains("-h") || arguments.contains("--help")
}

public func isVersionRequested(in arguments: [String]) -> Bool {
    arguments.contains("-v") || arguments.contains("--version")
}

public struct FocusChangeReporter {
    private var tracker: FocusChangeTracker
    private let writeLine: (String) -> Void

    public init(
        tracker: FocusChangeTracker = FocusChangeTracker(),
        writeLine: @escaping (String) -> Void
    ) {
        self.tracker = tracker
        self.writeLine = writeLine
    }

    /// Emits a focus-change line when the application name changed.
    public mutating func handleFocusChange(_ rawName: String?) {
        if let line = tracker.line(for: rawName) {
            writeLine(line)
        }
    }
}
