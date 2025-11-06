---
feature: chat-handles
doc_type: testing-monitoring
owner: @rob
status: draft
last_updated: 2025-11-06
---

# Testing & Monitoring — Chat Handles

## Automated Coverage Targets
- Unit: handle normalization, collision resolution, override precedence.
- Integration: import pipeline ensuring handle IDs stay stable across batches.
- Widget/State: manual link UI workflow once implemented.

## Test Data Requirements
- Fixtures with mixed iMessage/SMS handles.
- Edge cases: international numbers, email handles, deleted contacts.

## Monitoring & Telemetry
- Import logs for normalization failures.
- Drift projections diffing to detect unexpected handle churn.
- Overlay audit trail for manual overrides.

## Manual Verification Checklist
- Manual link round-trip (create, update, remove) reflects in UI.
- Search by handle identifier returns expected chat/message rows.

## TODO
- Decide on alerting thresholds for normalization failures.
- Add coverage for handle merge scenarios when contacts consolidate.
