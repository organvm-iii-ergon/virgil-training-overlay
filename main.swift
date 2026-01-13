#!/usr/bin/swift
import Foundation
import AppKit

// MARK: - CLI Argument Handling

// Early check for help flags to avoid unnecessary initialization
if CommandLine.arguments.contains("-h") || CommandLine.arguments.contains("--help") {
    print("Usage: mac-tooltip")
    print("Tracks the frontmost application and prints its name to stdout.")
    print("")
    print("Options:")
    print("  -h, --help   Show this help message")
    exit(0)
}

// MARK: - Helper Functions

/// Sanitizes the application name to prevent log injection by removing control characters.
/// - Parameter name: The raw application name.
/// - Returns: The sanitized application name.
func getSanitizedAppName(_ name: String?) -> String {
    let safeName = name ?? "<none>"

    // Security: Truncate to prevent DoS via excessively long strings (byte-based limit)
    // using String(decoding:as:) ensures valid UTF-8 sequences.
    let truncated = String(decoding: safeName.utf8.prefix(128), as: UTF8.self)

    // Security: Remove control characters using Unicode Scalar iteration for performance
    var result = ""
    result.reserveCapacity(truncated.unicodeScalars.count)

    for scalar in truncated.unicodeScalars {
        if !CharacterSet.controlCharacters.contains(scalar) {
            result.unicodeScalars.append(scalar)
        }
    }

    return result
}

// MARK: - State

var lastPrintedName = ""

/// Prints the new focus application name if it has changed.
/// - Parameter rawName: The raw name of the application.
func handleFocusChange(_ rawName: String?) {
    let newName = getSanitizedAppName(rawName)

    // Optimization: Only print if the name actually changed.
    if newName != lastPrintedName {
        // Output format adherence: Strictly preserve "New focus: <App Name>"
        Swift.print("New focus: \(newName)")
        lastPrintedName = newName
    }
}

// MARK: - Main Logic

// Performance: We switched from a polling Timer to NSWorkspace notifications.
// This event-driven approach significantly reduces CPU usage and battery drain
// by only waking up the process when the active application actually changes.

let workspace = NSWorkspace.shared
let notificationCenter = workspace.notificationCenter

// Initial check to set the state and print current focus
handleFocusChange(workspace.frontmostApplication?.localizedName)

// Observe application activation events
notificationCenter.addObserver(
    forName: NSWorkspace.didActivateApplicationNotification,
    object: nil,
    queue: .main
) { notification in
    // Retrieve the application from the notification's user info
    let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    handleFocusChange(app?.localizedName)
}

// MARK: - Signal Handling

// Detect Ctrl-C to stop observing and exit gracefully
let sigintSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
sigintSrc.setEventHandler {
    Swift.print("")
    exit(0)
}
sigintSrc.resume()

// Start the run loop to process notifications
RunLoop.current.run()
