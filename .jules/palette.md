# UX & Accessibility Journal

## Learnings

### Output Format Stability
- **Date**: 2024-05-22
- **Context**: CLI output for downstream consumption.
- **Decision**: Strictly preserved the `New focus: <App Name>` format.
- **Reasoning**: Changing the output format (e.g., adding timestamps, changing prefixes) breaks existing scripts and tools that rely on this specific contract. Improvements must not alter the established interface.

### Version Flag Expectation
- **Date**: 2024-05-22
- **Context**: CLI tool UX.
- **Decision**: Added `-v` / `--version` support.
- **Reasoning**: Users expect standard CLI flags to be available. Lack of version info frustrates debugging and verification.

## Future Opportunities

### Verbose Mode
- Could add a `--verbose` flag to print startup/shutdown messages, but only when explicitly requested, to preserve default output format for pipes.
