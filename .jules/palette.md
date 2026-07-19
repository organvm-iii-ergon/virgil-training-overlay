# UX & Accessibility Journal

## Learnings

### Output Format Stability
- **Date**: 2024-05-22
- **Context**: CLI output for downstream consumption.
- **Decision**: Strictly preserved the `New focus: <App Name>` format.
- **Reasoning**: Changing the output format (e.g., adding timestamps, changing prefixes) breaks existing scripts and tools that rely on this specific contract. Improvements must not alter the established interface.

### Standard CLI Help Patterns
- **Date**: 2024-05-22
- **Context**: User on-boarding and tool discoverability.
- **Learning**: Even simple tools need documentation.
- **Action**: Added `-h` and `--help` flags to provide immediate, context-aware usage instructions without requiring the user to read the source code.
- **Outcome**: Improved discoverability and standard compliance for CLI tools.
