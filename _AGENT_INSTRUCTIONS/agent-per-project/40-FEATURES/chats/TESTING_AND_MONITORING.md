---
tier: feature
scope: testing-monitoring
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./STATE_AND_PROVIDER_INVENTORY.md
	- ./WORK_LOG.md
tests: []
feature: chats
doc_type: testing-monitoring
status: draft
last_updated: 2025-11-06
---

# Testing & Monitoring — Chats

## Automated Coverage Targets
- Unit: chat summary derivations (last message preview, unread counts).
- Integration: migration tests verifying participant roster consistency.
- Widget: chat list rendering under large datasets, pin/archive toggles.

## Test Data Requirements
- Import fixtures with mix of DM and group chats.
- Edge cases: empty chats, chats with deleted participants, high-volume threads.

## Monitoring & Telemetry
- Instrument chat list load time metrics.
- Track unread counter discrepancies between ledger and projection.
- Logging for pin/archive overlay writes.

## Manual Verification Checklist
- Chat list ordering matches last activity timestamps.
- Pin/archive toggles persist across app restarts.
- Participant roster updates correctly after handle overrides.

## TODO
- Define thresholds for slow chat list queries.
- Add scenario tests for re-import causing chat merges/splits.
