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

/// Formats a `[HH:mm:ss]` timestamp prefix for a real-time focus log line.
///
/// The timestamp is a presentation concern layered on top of the deduplicated
/// focus line, so it never participates in change detection. `timeZone` is
/// injectable purely to keep the formatting deterministic under test; the CLI
/// uses the current time zone.
public func focusTimestamp(for date: Date, timeZone: TimeZone = .current) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = timeZone
    formatter.dateFormat = "HH:mm:ss"
    return "[\(formatter.string(from: date))]"
}

/// Prefixes a focus line with a `[HH:mm:ss]` timestamp for log context.
public func timestampedFocusLine(_ line: String, at date: Date, timeZone: TimeZone = .current) -> String {
    "\(focusTimestamp(for: date, timeZone: timeZone)) \(line)"
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
