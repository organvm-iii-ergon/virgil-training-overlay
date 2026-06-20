# Performance Journal

## Learnings

### Event-Driven vs Polling
- **Date**: 2024-05-22
- **Context**: Monitoring frontmost application changes.
- **Change**: Switched from `Timer`-based polling (1s interval) to `NSWorkspace.didActivateApplicationNotification`.
- **Impact**: Reduced CPU usage and battery drain by only waking up when the OS notifies of a change, rather than waking up every second regardless of activity. This aligns with the "event-driven over polling" directive.

## 2024-10-24 - Efficient String Sanitization
**Learning:** Using `components(separatedBy:).joined()` for character filtering creates excessive temporary allocations.
**Action:** Use `unicodeScalars` iteration with `reserveCapacity` for O(n) filtering with minimal allocation.
