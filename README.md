[![ORGAN-III: Ergon](https://img.shields.io/badge/ORGAN--III-Ergon-1b5e20?style=flat-square)](https://github.com/organvm-iii-ergon)
[![Swift](https://img.shields.io/badge/Swift-5.5+-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-000000?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

# Virgil Training Overlay

> *Like Clippy, but it's midway through a life and it's Virgil leading me through a Divine Comedy.*

A lightweight, event-driven macOS utility that monitors which application currently holds focus and reports transitions to stdout. Named for Dante's guide through the Inferno, Virgil Training Overlay watches how you move through your computing environment — tracking the application-to-application journey the way a training companion observes a learner navigating unfamiliar terrain. The long-term vision is a contextual overlay system that provides guidance, coaching, and productivity insights based on real-time application focus patterns.

---

## Table of Contents

- [Product Overview](#product-overview)
- [Why This Exists](#why-this-exists)
- [Technical Architecture](#technical-architecture)
- [Installation and Quick Start](#installation-and-quick-start)
- [Usage](#usage)
- [Features](#features)
- [Roadmap](#roadmap)
- [Cross-Organ References](#cross-organ-references)
- [Related Work](#related-work)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

---

## Product Overview

Virgil Training Overlay (package name: `mac-tooltip`) is a macOS command-line utility written in Swift that detects and reports changes in the frontmost application. It operates as a persistent background process, listening for `NSWorkspace.didActivateApplicationNotification` events and printing a single line to stdout each time the user switches to a different application.

The output contract is stable and intentionally minimal:

```
New focus: Terminal
New focus: Safari
New focus: Visual Studio Code
```

This deceptively simple interface is the foundation for a much larger ambition. By capturing the raw signal of *where attention moves*, Virgil becomes the sensory layer for training overlays, productivity analytics, automation triggers, and contextual coaching systems. The name draws from Dante's *Divine Comedy*: just as Virgil guided Dante through unfamiliar and sometimes hostile territory, this tool watches how you navigate the landscape of your applications — not to judge, but to accompany.

The package name `mac-tooltip` reflects the tool's original conception as a persistent tooltip-style indicator. The repository name `virgil-training-overlay` captures the evolved vision: a companion that not only observes but eventually guides. Both names are in active use — the package name in `Package.swift` and the repository name in the GitHub organization.

### Who Is This For?

- **Developers** building automation workflows that respond to application context changes
- **Productivity researchers** studying application-switching patterns and attention fragmentation across computing sessions
- **Power users** who want to pipe focus-change events into scripts, loggers, notification daemons, or custom analytics pipelines
- **The project owner** — this is a personal tool built to scratch a personal itch, with the craftsmanship expected of a portfolio-grade product

### Design Philosophy

Virgil follows three principles that govern all ORGAN-III products:

1. **Minimal footprint, maximum signal.** The entire application is a single Swift file with zero external dependencies. It does one thing and does it well. There is no configuration to manage, no database to maintain, no account to create. You run it, it watches, it reports.
2. **Event-driven, not polling.** An earlier version polled `NSWorkspace.shared.frontmostApplication` every second via a `Timer`. The current implementation uses macOS notification center events, waking up only when the OS reports an actual application switch. This reduces CPU usage and battery drain to near zero during idle periods — a design choice documented in the project's performance journal (`.jules/bolt.md`).
3. **Stable output contract.** The `New focus: <App Name>` format is a public interface. Downstream scripts and tools depend on it. Changes to this format constitute a breaking change and follow semantic versioning discipline. This constraint is explicitly tracked in the UX journal (`.jules/palette.md`).

---

## Why This Exists

Most application-usage monitors are heavy desktop apps with dashboards, accounts, and telemetry. They solve the *reporting* problem but create new problems: privacy concerns, resource overhead, vendor lock-in, and dependence on proprietary data formats that may disappear when the company pivots or shuts down.

Virgil takes the opposite approach. It is a Unix-philosophy tool: a small, composable program that outputs structured text to stdout. You can pipe it into `tee` for logging, `grep` for filtering, `awk` for transformation, or a custom script for anything else. It produces raw material; you decide what to build with it. The data never leaves your machine unless you explicitly send it somewhere.

The deeper motivation is Dantean. The *Divine Comedy* is a narrative about guided passage through unfamiliar territory — a training overlay for the afterlife, if you will. The modern equivalent is navigating the dozens of applications that constitute a knowledge worker's daily environment. We switch between code editors, browsers, terminals, communication tools, and creative applications dozens or hundreds of times per day, often without conscious awareness of the pattern. Virgil watches the journey, and the long-term vision is for it to eventually *speak*: offering contextual guidance, surfacing relevant resources, and gently redirecting attention when patterns suggest drift.

That vision lives in the [Lifecycle Roadmap](LIFECYCLE_ROADMAP.md). The current release is the sensory foundation — the eyes before the voice.

---

## Technical Architecture

### System Design

Virgil is a single-file Swift executable that relies exclusively on Apple's system frameworks. There are no external dependencies, no package manager fetches, and no build plugins. The entire project compiles in under two seconds on modern hardware.

```
virgil-training-overlay/
├── Package.swift           # Swift Package Manager manifest
├── main.swift              # Complete application (single file)
├── CLAUDE.md               # AI assistant development guide
├── LIFECYCLE_ROADMAP.md    # Exhaustive feature and release roadmap
└── .jules/                 # Development journal entries
    ├── bolt.md             # Performance learnings
    ├── palette.md          # UX and accessibility decisions
    └── sentinel.md         # Security considerations
```

The `.jules/` directory contains structured development journals that document architectural decisions, security mitigations, and performance tradeoffs. These journals serve as a persistent knowledge base for any developer (human or AI) working on the project, capturing the *why* behind each decision so that future contributors do not inadvertently undo deliberate choices.

### Core Loop

The application lifecycle follows a straightforward state machine:

```
STARTUP → MONITORING → SHUTDOWN
```

**Startup** initializes the workspace observer, registers the signal handler, and performs an immediate check of the current frontmost application to establish baseline state. **Monitoring** is an indefinite event-driven loop: the macOS notification center delivers `didActivateApplicationNotification` events, each containing the newly focused `NSRunningApplication`. The handler compares the new application name against the previously reported name and only emits output when a genuine change has occurred. **Shutdown** is triggered by `SIGINT` (Ctrl-C) and exits cleanly with code 0.

### Event-Driven Architecture

The critical architectural decision — and the one most worth understanding — is the switch from polling to event-driven monitoring. The original implementation used `Timer.scheduledTimer` with a 1-second interval:

```swift
// OLD: Polling approach (replaced)
let updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    let newName = NSWorkspace.shared.frontmostApplication?.localizedName ?? "<none>"
    if newName != prevName { /* ... */ }
}
```

The current implementation uses `NSWorkspace.didActivateApplicationNotification`:

```swift
// CURRENT: Event-driven approach
notificationCenter.addObserver(
    forName: NSWorkspace.didActivateApplicationNotification,
    object: nil,
    queue: .main
) { notification in
    let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
        as? NSRunningApplication
    handleFocusChange(app?.localizedName)
}
```

This change eliminates the cost of waking the process every second. On a modern MacBook, the difference between "polling 86,400 times per day" and "waking only on actual application switches" is meaningful for battery life and thermal performance. The polling approach consumed measurable CPU cycles even when the user was idle for hours; the event-driven approach consumes effectively nothing until the OS delivers a notification.

### Security: Input Sanitization

Application names are untrusted input. A malicious or malformed application name could contain control characters (carriage returns, ANSI escape sequences, null bytes) that would corrupt terminal output or exploit downstream log processors. This class of vulnerability is known as log injection, and Virgil addresses it proactively. The sanitization pipeline:

1. **Null coalescing** — absent application names default to `<none>` rather than producing empty output
2. **Byte-length truncation** — names are capped at 128 bytes to prevent DoS via excessively long strings
3. **Control character stripping** — all characters in `CharacterSet.controlCharacters` are removed using Foundation's optimized string processing routines

This is documented in `.jules/sentinel.md` as a deliberate security decision, not an incidental implementation detail. The security journal approach ensures that future contributors understand the threat model and do not inadvertently weaken the sanitization.

### Framework Dependencies

| Framework | Purpose | Required |
|-----------|---------|----------|
| `Foundation` | Core Swift types, string processing, dispatch sources, signal handling | Yes |
| `AppKit` | `NSWorkspace`, `NSRunningApplication`, notification center, `RunLoop` | Yes |

Both frameworks ship with macOS. No additional installation or entitlements are required for the current feature set. The `NSWorkspace.shared.frontmostApplication` API does not require Accessibility permissions — it queries publicly available process metadata. Future features (screen overlay, automation scripting) may require additional entitlements, which will be requested incrementally following the principle of least privilege.

### Signal Handling

Virgil registers a `DispatchSource` for `SIGINT` to ensure clean shutdown:

```swift
let sigintSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
sigintSrc.setEventHandler {
    Swift.print("")
    exit(0)
}
sigintSrc.resume()
```

This ensures that piped output is flushed, the terminal gets a clean newline after the `^C` indicator, and the process exits with code 0, signaling success to any parent process or shell script. This is particularly important when Virgil is used as a component in a pipeline — downstream consumers need a reliable termination signal.

---

## Installation and Quick Start

### Prerequisites

- **macOS** (any version supporting Swift 5.5+; tested on macOS 13 Ventura through macOS 26 Tahoe)
- **Swift toolchain** (ships with Xcode or can be installed standalone via [swift.org](https://swift.org/download/))

No Homebrew packages, no CocoaPods, no Carthage. The project builds with only the tools Apple ships.

### Build from Source

```bash
# Clone the repository
git clone https://github.com/organvm-iii-ergon/virgil-training-overlay.git
cd virgil-training-overlay

# Build (debug)
swift build

# Build (release, optimized)
swift build -c release
```

### Run

```bash
# Via Swift Package Manager
swift run

# Via compiled binary (after building)
.build/debug/mac-tooltip

# Or for release builds
.build/release/mac-tooltip
```

### Run as a Script

The `main.swift` file includes a shebang line (`#!/usr/bin/swift`) and can be executed directly without compilation:

```bash
chmod +x main.swift
./main.swift
```

This is useful for quick experimentation but bypasses compiler optimizations. For sustained use, build a release binary.

### Quick Verification

```bash
# Run Virgil, switch between a few apps, then Ctrl-C
swift run
# Expected output:
# New focus: Terminal
# New focus: Finder
# New focus: Safari
# ^C
```

If you see application names appearing as you switch windows, Virgil is working correctly.

---

## Usage

### Basic Monitoring

```bash
# Monitor and display focus changes in real time
swift run
```

### Logging to a File

```bash
# Pipe output to a timestamped log
swift run 2>/dev/null | while IFS= read -r line; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') $line"
done | tee -a ~/focus-log.txt
```

### Filtering Specific Applications

```bash
# Only log when switching to/from a specific app
swift run | grep -E "Safari|Chrome|Firefox"
```

### Integration with Other Tools

```bash
# Count focus changes per app over a session
swift run | awk -F': ' '{count[$2]++} END {for (app in count) print count[app], app}' | sort -rn
```

### Background Monitoring

```bash
# Run in background, log to file, stop later with kill
swift run > ~/focus-log.txt 2>&1 &
VIRGIL_PID=$!
# ... do your work ...
kill $VIRGIL_PID
```

### Command-Line Help

```bash
swift run -- --help
# Usage: mac-tooltip
# Tracks the frontmost application and prints its name to stdout.
#
# Options:
#   -h, --help   Show this help message
```

---

## Features

### Current (v0.1)

| Feature | Description |
|---------|-------------|
| **Real-time focus detection** | Reports application switches as they happen via macOS notification center |
| **Event-driven architecture** | Zero CPU cost during idle periods; wakes only on actual application transitions |
| **Stable output format** | `New focus: <App Name>` contract suitable for piping and parsing |
| **Input sanitization** | Strips control characters and truncates long names to prevent log injection |
| **Graceful shutdown** | Clean `SIGINT` handling with proper exit code |
| **Zero dependencies** | No external packages; builds with only Apple system frameworks |
| **Script-compatible** | Shebang line allows direct execution without compilation |
| **Change deduplication** | Only reports when the focused application actually changes, suppressing redundant events |

### Planned

The full feature evolution is documented in [LIFECYCLE_ROADMAP.md](LIFECYCLE_ROADMAP.md). Key milestones include:

- **v0.2:** Configuration file support, structured logging framework, comprehensive error handling
- **v0.3:** Command-line argument parsing (configurable output format, verbosity), menu bar app wrapper
- **v0.4:** Focus history persistence (SQLite/CoreData), notification support
- **v0.5:** Data export (CSV, JSON), encryption at rest, privacy controls
- **v0.6+:** Preferences UI, AppleScript integration, usage analytics, custom triggers
- **v1.0:** Contextual training overlay — the "Virgil speaks" milestone, where the tool transitions from passive observation to active guidance based on learned attention patterns

---

## Roadmap

Virgil's development follows a four-phase lifecycle, designed to build capabilities incrementally while keeping each release shippable and useful on its own:

| Phase | Timeline | Focus | Key Deliverables |
|-------|----------|-------|------------------|
| **Foundation** | Weeks 1-4 | Core monitoring, error handling, configuration, tests | Stable CLI, XCTest suite, config file |
| **Enhancement** | Weeks 5-12 | Menu bar UI, data persistence, export, integrations | Menu bar app, SQLite storage, CSV/JSON export |
| **Maturity** | Months 4-6 | ML pattern recognition, automation workflows, enterprise features | Usage analytics, custom triggers, plugin system |
| **Scale** | Month 7+ | Cross-platform exploration, cloud sync, AI coaching | The "Virgil speaks" contextual overlay |

The current release sits at the end of Phase 1, Week 2. The event-driven architecture migration (originally planned for Phase 2) was pulled forward as a foundation-hardening improvement, reflecting the project's commitment to getting the fundamentals right before adding features.

See [LIFECYCLE_ROADMAP.md](LIFECYCLE_ROADMAP.md) for the exhaustive breakdown including release cadence, quality gates, security lifecycle, maintenance windows, and end-of-life planning.

---

## Cross-Organ References

Virgil Training Overlay sits within **ORGAN-III (Ergon)**, the commerce and product organ of the eight-organ creative-institutional system. It connects to the broader architecture in several ways:

| Organ | Connection |
|-------|------------|
| **I — Theoria** | The recursive-engine and epistemological frameworks in ORGAN-I inform how Virgil might eventually *model* attention patterns — not just record them. The transition from raw observation to structured understanding is fundamentally a theory problem, and the recursive self-observation pattern (a system watching its own user watching applications) is precisely the kind of structure ORGAN-I explores. |
| **II — Poiesis** | The generative and experiential work in ORGAN-II (particularly metasystem-master) explores how creative systems observe and respond to their own state. Virgil is a micro-instance of this pattern: a system that watches its user in real time, with the long-term goal of responding creatively to what it observes. |
| **III — Ergon** | Virgil is one of several ORGAN-III products. It shares the organ's emphasis on shipping working software with clean interfaces and portfolio-grade documentation. Sibling repos include [tab-bookmark-manager](https://github.com/organvm-iii-ergon/tab-bookmark-manager) and [a-i-chat--exporter](https://github.com/organvm-iii-ergon/a-i-chat--exporter). |
| **IV — Taxis** | The orchestration and governance patterns in ORGAN-IV (particularly [agentic-titan](https://github.com/organvm-iv-taxis/agentic-titan)) define how tools like Virgil might be composed into larger agent workflows. An overlay that coaches based on focus patterns is, architecturally, an agent — one that perceives, reasons about, and acts upon its environment. |
| **V — Logos** | The public-process essays in ORGAN-V may eventually document the design decisions behind Virgil's evolution from a tooltip to a training companion. The Dantean metaphor is rich territory for building-in-public narrative, and the journey from polling to event-driven architecture is itself a story worth telling. |

---

## Related Work

Virgil occupies a specific niche: minimal, local, composable, and metaphor-driven. For context, here is how it relates to adjacent tools in the application-monitoring space:

- **[RescueTime](https://www.rescuetime.com/)** — Full-featured productivity tracker with cloud dashboards, team analytics, and goal-setting. Virgil is the opposite: local-only, no account required, stdout-based, zero telemetry.
- **[ActivityWatch](https://activitywatch.net/)** — Open-source, privacy-focused activity watcher with a local web UI. Closer to Virgil in spirit but significantly heavier in footprint; Virgil is a single-file alternative for users who want raw events rather than a dashboard.
- **[Hammerspoon](https://www.hammerspoon.org/)** — Lua-based macOS automation framework. Virgil's focus-monitoring could be replicated with a Hammerspoon script, but Virgil exists as a standalone tool with its own development trajectory toward contextual coaching — a different ambition than general-purpose automation.
- **macOS Screen Time** — Apple's built-in usage tracking. Aggregated, retroactive, and category-based; Virgil provides real-time, per-switch granularity with exact application names suitable for programmatic consumption.
- **`lsappinfo`** — Apple's undocumented command-line tool for querying application state. Provides a snapshot rather than a stream; Virgil provides continuous monitoring with change detection.

---

## Contributing

Contributions are welcome. This is an early-stage personal project with a clear vision, so please read before submitting:

1. **Open an issue first** for any non-trivial change. Describe what you want to do and why.
2. **Respect the minimalism.** Virgil is intentionally a single-file utility. PRs that introduce unnecessary complexity or external dependencies will be declined.
3. **Preserve the output contract.** The `New focus: <App Name>` format is a stable interface. Changes to this format require a major version bump and migration path.
4. **Match existing code style.** The codebase uses `camelCase` for functions and (non-standardly) `snake_case` for some variables. Match what is there or propose a full-codebase refactor — do not mix styles within a single PR.
5. **Test manually.** There is no automated test suite yet (it is on the roadmap). Document your testing steps in the PR description.

### Development Setup

```bash
git clone https://github.com/organvm-iii-ergon/virgil-training-overlay.git
cd virgil-training-overlay
swift build
swift run
# Switch between apps to verify output
```

### Branch Naming

```
feature/<description>
fix/<description>
docs/<description>
```

---

## License

This project is licensed under the [MIT License](LICENSE).

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.

---

## Author

**[@4444j99](https://github.com/4444j99)**

Virgil Training Overlay is part of **ORGAN-III (Ergon)** — the commerce and product organ of an eight-organ creative-institutional system spanning theory, art, commerce, orchestration, public process, community, and marketing.

For the full system map, see [meta-organvm](https://github.com/meta-organvm).
