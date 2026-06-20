# Security Journal

## Learnings

### Log Injection Prevention
- **Date**: 2024-05-22
- **Context**: Outputting application names to stdout.
- **Threat**: An application could have control characters in its name, potentially messing with the terminal or downstream log processors (Log Injection).
- **Mitigation**: Sanitized the `NSWorkspace` output by filtering out `CharacterSet.controlCharacters` from the application name before printing.

## 2024-05-23 - Denial of Service via Long Inputs
**Vulnerability:** Unbounded input strings from `NSWorkspace` could cause excessive memory usage or processing time (DoS) if malicious or malformed app names are encountered.
**Learning:** `String` initialization from `UTF8View` slices requires explicit decoding strategies (`String(decoding:as:)`) to strictly enforce UTF-8 validity and handle truncation safely without optionals.
**Prevention:** Use `String(decoding: name.utf8.prefix(128), as: UTF8.self)` to strictly limit input size to 128 bytes and ensure valid UTF-8 sequences.
