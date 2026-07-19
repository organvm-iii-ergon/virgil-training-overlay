#!/usr/bin/swift
import Foundation
import AppKit
import MacTooltipCore

// MARK: - CLI Argument Handling

// Early check for help flags to avoid unnecessary initialization.
if isHelpRequested(in: CommandLine.arguments) {
    print(macTooltipHelpText)
    exit(0)
}

if isVersionRequested(in: CommandLine.arguments) {
    print(macTooltipVersionText)
    exit(0)
}

// MARK: - State

var focusReporter = FocusChangeReporter { line in
    Swift.print(timestampedFocusLine(line, at: Date()))
}

/// Prints the new focus application name if it has changed.
/// - Parameter rawName: The raw name of the application.
func handleFocusChange(_ rawName: String?) {
    focusReporter.handleFocusChange(rawName)
}

// MARK: - Main Logic

// Performance: Use NSWorkspace notifications so the process wakes only when
// the active application changes.
let workspace = NSWorkspace.shared
let notificationCenter = workspace.notificationCenter

// Initial check to set the state and print current focus.
handleFocusChange(workspace.frontmostApplication?.localizedName)

// Observe application activation events.
notificationCenter.addObserver(
    forName: NSWorkspace.didActivateApplicationNotification,
    object: nil,
    queue: .main
) { notification in
    let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    handleFocusChange(app?.localizedName)
}

// MARK: - Signal Handling

// Detect Ctrl-C to stop observing and exit gracefully.
signal(SIGINT, SIG_IGN)
let sigintSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
sigintSrc.setEventHandler {
    Swift.print("")
    exit(0)
}
sigintSrc.resume()

// Start the run loop to process notifications.
RunLoop.current.run()
