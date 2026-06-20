# Security Journal

## Learnings

### Log Injection Prevention
- **Date**: 2024-05-22
- **Context**: Outputting application names to stdout.
- **Threat**: An application could have control characters in its name, potentially messing with the terminal or downstream log processors (Log Injection).
- **Mitigation**: Sanitized the `NSWorkspace` output by filtering out `CharacterSet.controlCharacters` from the application name before printing.

## 2024-05-23 - [Optimized Sanitization]
**Vulnerability:** DoS risk via memory exhaustion when sanitizing long strings using `components(separatedBy:)`.
**Learning:** `components(separatedBy:)` creates an array of substrings, which is memory intensive.
**Prevention:** Iterate `unicodeScalars` and build the result string using `reserveCapacity` to minimize allocations.
