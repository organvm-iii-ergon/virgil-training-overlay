# Performance Journal

## Learnings

### Event-Driven vs Polling
- **Date**: 2024-05-22
- **Context**: Monitoring frontmost application changes.
- **Change**: Switched from `Timer`-based polling (1s interval) to `NSWorkspace.didActivateApplicationNotification`.
- **Impact**: Reduced CPU usage and battery drain by only waking up when the OS notifies of a change, rather than waking up every second regardless of activity. This aligns with the "event-driven over polling" directive.

## 2026-01-21 - Efficient String Sanitization
**Learning:** `components(separatedBy:).joined()` creates excessive intermediate allocations (O(n) allocations) which is costly in hot paths.
**Action:** Use `reserveCapacity` with `.utf8.count` (O(1) allocation) and iterate `unicodeScalars` manually to build sanitized strings.
