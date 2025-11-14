# Test Plan — Ordinal Index All Messages

## Automated Coverage
- [ ] **DAO tests**: verify keyset pagination returns deterministic order and respects inclusive/exclusive bounds.
- [ ] **Use case tests**: ensure cursors translate to DAO calls and emit expected DTOs, including empty/end-of-data handling.
- [ ] **Provider tests**: confirm Riverpod pagination state machines request additional pages lazily and recover from transient failures.
- [ ] **Widget tests**: simulate scrolling in the timeline view to assert hydration triggers and jump controls update state.

## Manual Validation
- [ ] Launch macOS build with production-scale fixture and scroll through tens of thousands of messages without stutter.
- [ ] Use jump controls to navigate to oldest/newest message and confirm proper anchoring.
- [ ] Open a message from the timeline to its chat and ensure navigation context persists.
