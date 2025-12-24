---
tier: project
scope: checklist
owner: agent-per-project
last_reviewed: 2025-12-24
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./PHASES.md
tests: []
---

# Checklist — Global Messages Timeline

## Proposal / Scope
- [ ] Confirm v1 scope choice: A / B / C.
- [ ] Confirm entry point in UI/navigation.
- [ ] Confirm required correspondent label fields (name vs handle).

## Data & Index
- [ ] Verify `message_index` has monthKey support and required lookup methods.
- [ ] Verify mapping for “jump to search hit” (messageId → ordinal).
- [ ] Confirm DB maintenance lock behavior for global providers.

## Providers & View Model
- [ ] Create `global_messages` view model module with VM + `jump/` + `hydration/`.
- [ ] Ensure all DB access goes through centralized providers.
- [ ] Ensure controller/timer lifecycle is idempotent in VM.

## UI
- [ ] Implement dumb global timeline view.
- [ ] Add prominent correspondent label per row.
- [ ] Implement two modes: browse vs search.
- [ ] Verify no scroll jitter during hydration.

## Search
- [ ] Implement global search provider.
- [ ] Add “jump to result” behavior.
- [ ] Ensure unknown senders are discoverable (no contact required).

## Tests
- [ ] Provider tests for ordinal/jumps.
- [ ] Provider tests for global search results.
- [ ] Widget smoke tests for browse/search switching.

## Verification
- [ ] Manual: open All Messages, scroll, jump month, search, jump to hit.
- [ ] `flutter analyze` clean.
- [ ] `dart run build_runner build --delete-conflicting-outputs` clean.

## Documentation
- [ ] Add/extend `40-FEATURES/messages/` docs with global timeline section.
- [ ] Include a human-readable mechanistic walkthrough for global timeline.
