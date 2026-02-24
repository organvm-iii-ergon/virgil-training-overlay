# CLAUDE.md - AI Assistant Guide

## Project Overview

**Project Name:** mac-tooltip
**Type:** macOS Command-Line Utility
**Language:** Swift
**Platform:** macOS only (requires AppKit)

This is a minimal macOS system monitoring utility that continuously tracks which application currently has focus (is frontmost). The program polls every second and reports changes to stdout with the format: `New focus: <app-name>`.

**Use Cases:**
- Application usage monitoring
- Automation workflows requiring active app detection
- Productivity/time tracking
- Development/debugging scenarios

## Repository Structure

```
virgil-training-overlay/
├── .git/            # Git repository metadata
├── Package.swift    # Swift Package Manager manifest (13 lines)
├── main.swift       # Main executable source code (31 lines)
└── CLAUDE.md        # This file - AI assistant documentation
```

**Key Characteristics:**
- Extremely minimal structure (2 source files)
- No subdirectories, modules, or packages
- No automated tests or additional configuration files; minimal documentation (this CLAUDE.md file only)
- Single-purpose, flat architecture
- Total code: ~42 lines

## Technologies & Dependencies

### Core Technologies
- **Swift Version:** 5.5+ (as specified in Package.swift)
- **Build System:** Swift Package Manager (SPM)
- **Platform:** macOS exclusive

### Frameworks
- **Foundation:** Core Swift framework for basic types
- **AppKit:** macOS framework for user interface and workspace management
  - `NSWorkspace.shared.frontmostApplication` - Detects active application

### Runtime APIs
- **Timer API:** `Timer.scheduledTimer` for 1-second polling intervals
- **DispatchSource:** Signal handling for graceful Ctrl-C shutdown
- **RunLoop:** Keeps application running continuously

### External Dependencies
**None** - The project is completely self-contained with zero external packages.

## File-by-File Breakdown

### Package.swift (Configuration)
**Purpose:** Swift Package Manager manifest
**Lines:** 13
**Key Details:**
- Package name: "mac-tooltip"
- Swift tools version: 5.5
- Target type: Executable (not a library)
- No dependencies

**Structure:**
```swift
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "mac-tooltip",
    dependencies: [],
    targets: [
        .executableTarget(
            name: "mac-tooltip",
            dependencies: []),
    ]
)
```

### main.swift (Implementation)
**Purpose:** Complete application logic
**Lines:** 31
**Shebang:** `#!/usr/bin/swift` (can run as script)

**Code Structure:**
1. **Lines 2-3:** Imports (Foundation, AppKit.NSWorkspace)
2. **Lines 6-8:** Helper function `currentFocusApp()` - retrieves frontmost app name
3. **Lines 10-11:** Initial state setup and first output
4. **Lines 14-20:** Timer-based polling loop (1-second interval)
5. **Lines 23-28:** SIGINT handler for graceful Ctrl-C shutdown
6. **Line 30:** RunLoop to keep application alive

**Key Functions:**
- `currentFocusApp() -> String` - Returns frontmost app name or "<none>"

**Key Variables:**
- `prev_name` - Stores previous app name for change detection
- `updateTimer` - Scheduled timer for polling
- `sigintSrc` - Signal handler for SIGINT

## Development Workflow

### Building the Project
```bash
# Standard build
swift build

# Release build (optimized)
swift build -c release

# Clean build artifacts
swift package clean
```

### Running the Application
```bash
# Run via Swift Package Manager
swift run

# Run directly as script (requires executable permissions)
chmod +x main.swift
./main.swift

# Run compiled binary (after building)
.build/debug/mac-tooltip
```

### Expected Output
```
New focus: Terminal
New focus: Safari
New focus: Visual Studio Code
^C
```

### Testing
**No automated tests exist.** Testing is manual:
1. Run the application
2. Switch between different macOS applications
3. Verify output shows correct application names
4. Test Ctrl-C graceful shutdown

## Code Conventions & Patterns

### Naming Conventions
**⚠️ Mixed Style (Non-standard for Swift):**
- Variables: `snake_case` (`prev_name`, `new_name`) - **Unusual for Swift**
- Functions: `camelCase` (`currentFocusApp()`) - **Standard Swift**
- **Note:** Swift convention typically uses camelCase throughout

### Architectural Patterns
- **Procedural/Imperative:** No classes, structs, protocols, or extensions
- **Polling-Based:** Timer polling (1 second) vs. event-driven architecture
- **Stateful:** Module-level mutable state (`prev_name`)
- **Single Responsibility:** One function, one purpose

### Code Style
- Minimal comments (function-level only)
- No error handling
- No configuration options
- Hardcoded values (1-second interval)
- Null coalescing with `??` operator
- Explicit module qualification: `Swift.print()` instead of `print()`

## Common Development Tasks

### Adding Command-Line Arguments
If you need to add CLI arguments:
```swift
import Foundation
let args = CommandLine.arguments
// args[0] is the program name
// args[1...] are user arguments
```

### Changing Poll Interval
Currently hardcoded to 1.0 second at line 14:
```swift
let updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
```
Modify the `1.0` value to change frequency.

### Adding Logging/Debugging
The project uses `Swift.print()` for output. To add debug logging:
```swift
#if DEBUG
Swift.print("Debug: \(message)")
#endif
```

### Handling Errors
Currently no error handling exists. To add:
```swift
func currentFocusApp() -> String {
    guard let app = NSWorkspace.shared.frontmostApplication else {
        return "<none>"
    }
    return app.localizedName ?? "<unknown>"
}
```

## Important Considerations

### Platform Limitations
- ✅ **macOS Only:** Requires AppKit framework
- ❌ **Not Cross-Platform:** Cannot run on Linux, Windows, iOS, etc.
- ❌ **No Linux/Windows Alternative:** Would require complete rewrite

### Permissions
- The current implementation using `NSWorkspace.shared.frontmostApplication` does not require special permissions (like Accessibility) to function.

### Performance
- **Polling Overhead:** Checks every second regardless of changes
- **More Efficient Alternative:** Could use NSWorkspace notifications:
  ```swift
  NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: nil,
      queue: .main
  ) { notification in
      // Handle app switch
  }
  ```

### Current Limitations
- No configuration file
- No command-line arguments
- Fixed 1-second polling interval
- No logging to file (stdout only)
- No error handling or recovery
- No tests or CI/CD

## Git Workflow

### Branch Naming Convention
All development branches should follow this pattern:
```
claude/<description>-<session-id>
```

Example: `claude/add-feature-01PvBzwapZ9juadJ4QwPW9ep`

### Git Commands
```bash
# Create and switch to new branch
git checkout -b claude/your-feature-name-<session-id>

# Stage changes
git add .

# Commit with descriptive message
git commit -m "Add feature: description"

# Push to remote with tracking
git push -u origin claude/your-feature-name-<session-id>
```

### Network Resilience
If git operations fail due to network errors:
- Retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s)
- Use specific branch fetching: `git fetch origin <branch-name>`

## AI Assistant Guidelines

### When Working on This Codebase

1. **Respect Minimalism:** This is intentionally minimal. Don't over-engineer.

2. **Platform Awareness:** Any changes MUST be macOS-compatible. Test AppKit availability.

3. **No External Dependencies:** Keep the project dependency-free unless explicitly required.

4. **Maintain Simplicity:** This is a utility, not a framework. Keep it simple.

5. **Preserve Executability:** Maintain shebang line if modifying main.swift.

6. **Consider Conventions:**
   - Current code uses `snake_case` for variables (non-standard)
   - When adding new code, match existing style OR refactor to full camelCase

7. **No Tests = Manual Testing:** Document testing steps for any changes.

8. **Documentation:** Since there's no README, CLAUDE.md serves as primary documentation.

### Typical Modification Scenarios

**Adding a Feature:**
1. Read main.swift to understand current implementation
2. Modify main.swift with new functionality
3. Test manually on macOS
4. Update CLAUDE.md if architecture changes
5. Commit with clear message

**Refactoring:**
1. Consider whether complexity is warranted for a 30-line utility
2. If yes, possibly introduce structs/classes
3. Update Package.swift if adding new targets
4. Document architectural changes in CLAUDE.md

**Bug Fixes:**
1. Reproduce the issue manually
2. Fix in main.swift
3. Test thoroughly
4. Commit with "Fix: <description>"

## Quick Reference

| Task | Command |
|------|---------|
| Build | `swift build` |
| Run | `swift run` |
| Clean | `swift package clean` |
| Release Build | `swift build -c release` |
| Run as Script | `./main.swift` (needs chmod +x) |
| Show Package Info | `swift package describe` |

## Version History

- **Initial Commit (07c3c85):** Add files via upload
  - Basic application focus monitoring
  - 1-second polling interval
  - Ctrl-C signal handling

## Future Considerations

Potential improvements (not currently implemented):

- [ ] Add command-line argument parsing
- [ ] Support configurable poll interval
- [ ] Switch from polling to event-driven notifications
- [ ] Add structured logging (not just print)
- [ ] Write unit tests
- [ ] Add README.md for general users
- [ ] Cross-platform support (if feasible without AppKit)
- [ ] Add CI/CD pipeline
- [ ] Package as standalone macOS app bundle
- [ ] Add accessibility permission check/prompt

---

**Last Updated:** 2025-11-18
**For:** AI Assistants (Claude, etc.)
**Maintainer:** Auto-generated from repository analysis

<!-- ORGANVM:AUTO:START -->
## System Context (auto-generated — do not edit)

**Organ:** ORGAN-III (Commerce) | **Tier:** archive | **Status:** ARCHIVED
**Org:** `unknown` | **Repo:** `virgil-training-overlay`

### Edges
- *No inter-repo edges declared in seed.yaml*

### Siblings in Commerce
`classroom-rpg-aetheria`, `gamified-coach-interface`, `trade-perpetual-future`, `fetch-familiar-friends`, `sovereign-ecosystem--real-estate-luxury`, `public-record-data-scrapper`, `search-local--happy-hour`, `multi-camera--livestream--framework`, `universal-mail--automation`, `mirror-mirror`, `the-invisible-ledger`, `enterprise-plugin`, `tab-bookmark-manager`, `a-i-chat--exporter`, `.github` ... and 11 more

### Governance
- Strictly unidirectional flow: I→II→III. No dependencies on Theory (I).

*Last synced: 2026-02-24T12:41:28Z*
<!-- ORGANVM:AUTO:END -->
