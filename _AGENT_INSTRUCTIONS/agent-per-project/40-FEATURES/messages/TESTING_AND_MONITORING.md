---
feature: messages
doc_type: testing-monitoring
owner: @rob
status: draft
last_updated: 2025-11-06
---

# Testing & Monitoring — Messages

## Automated Coverage Targets
- Unit: message normalization, reaction aggregation, attachment metadata parsing.
- Integration: migration replay to ensure idempotent message projection.
- Widget: timeline rendering with mixed content types (text, attachments, system messages).

## Test Data Requirements
- Fixture chat with long history (±10k messages) for paging benchmarks.
- Mixed attachments (images, videos, files) and reactions.
- Edge cases: edited messages, deleted messages, ephemeral/downgraded attachments.

## Monitoring & Telemetry
- Import throughput and failure metrics for message batches.
- Timeline render performance instrumentation.
- Attachment download success/error counts.

## Manual Verification Checklist
- Jump-to-message navigation positions selection correctly.
- Reactions update in real time across panels.
- Attachment previews open without blocking UI thread.

## TODO
- Add regression harness for attributed body parsing (Rust FFI integration).
- Define alerting thresholds for message import lag vs. expected schedule.
