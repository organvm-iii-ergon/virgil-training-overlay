# UX & Accessibility Journal

## Learnings

### Output Format Stability
- **Date**: 2024-05-22
- **Context**: CLI output for downstream consumption.
- **Decision**: Strictly preserved the `New focus: <App Name>` format.
- **Reasoning**: Changing the output format (e.g., adding timestamps, changing prefixes) breaks existing scripts and tools that rely on this specific contract. Improvements must not alter the established interface.

## 2024-05-23 - Standard CLI Flags
**Learning:** Even minimal CLI tools must support standard flags (`-v`, `--version`) for discoverability.
**Action:** Always implement help and version flags before initial release to aid debugging and support.
