# Performance Journal

## Learnings

### Event-Driven vs Polling
- **Date**: 2024-05-22
- **Context**: Monitoring frontmost application changes.
- **Change**: Switched from `Timer`-based polling (1s interval) to `NSWorkspace.didActivateApplicationNotification`.
- **Impact**: Reduced CPU usage and battery drain by only waking up when the OS notifies of a change, rather than waking up every second regardless of activity. This aligns with the "event-driven over polling" directive.

## 2026-01-18 - Swift String Truncation and Capacity
**Learning:** `String(decoding: prefix, as: UTF8.self)` is safer than `String(substring)` for UTF-8 truncation as it handles multi-byte splits gracefully. Also, `utf8.count` is O(1) while `unicodeScalars.count` is O(n), making `utf8.count` preferred for `reserveCapacity`.
**Action:** Prefer `String(decoding:as:)` for truncating byte buffers and use `utf8.count` for capacity hints.
