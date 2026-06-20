import Foundation

public let focusOutputPrefix = "New focus: "

/// Sanitizes an application name before it is written to stdout.
public func sanitizedAppName(_ name: String?, byteLimit: Int = 128) -> String {
    precondition(byteLimit >= 0, "byteLimit must be non-negative")

    let safeName = name ?? "<none>"
    var consumedBytes = 0
    var sanitizedScalars = String.UnicodeScalarView()

    for scalar in safeName.unicodeScalars {
        let scalarByteCount = String(scalar).utf8.count

        guard consumedBytes + scalarByteCount <= byteLimit else {
            break
        }

        consumedBytes += scalarByteCount

        if !CharacterSet.controlCharacters.contains(scalar) {
            sanitizedScalars.append(scalar)
        }
    }

    return String(sanitizedScalars)
}

public func focusChangeLine(for sanitizedName: String) -> String {
    "\(focusOutputPrefix)\(sanitizedName)"
}

public struct FocusChangeTracker {
    private var lastPrintedName: String

    public init(lastPrintedName: String = "") {
        self.lastPrintedName = lastPrintedName
    }

    public mutating func line(for rawName: String?) -> String? {
        let newName = sanitizedAppName(rawName)

        guard newName != lastPrintedName else {
            return nil
        }

        lastPrintedName = newName
        return focusChangeLine(for: newName)
    }
}
