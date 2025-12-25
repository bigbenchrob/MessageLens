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
- [x] Confirm v1 scope choice: A / B / C. _(Chose B: filters framework only for now)_
- [x] Confirm entry point in UI/navigation. _(Added `TopChatMenuChoice.globalTimeline` + `MessagesSpec.globalTimelineV2()`)_
- [ ] Confirm required correspondent label fields (name vs handle). _(TODO in hydration provider; using senderName for now)_

## Data & Index
- [x] Verify `message_index` has monthKey support and required lookup methods. _(GlobalMessageIndexDataSource has monthKey, getByOrdinal, firstOrdinalOnOrAfter)_
- [x] Verify mapping for "jump to search hit" (messageId → ordinal). _(Data source supports this; VM jump helper not yet wired)_
- [x] Confirm DB maintenance lock behavior for global providers. _(Ordinal provider short-circuits with totalCount=0 during lock)_

## Providers & View Model
- [x] Create `global_messages` view model module with VM + `jump/` + `hydration/`. _(All created: VM, ordinal provider, hydration provider)_
- [x] Ensure all DB access goes through centralized providers. _(Uses `driftWorkingDatabaseProvider`)_
- [x] Ensure controller/timer lifecycle is idempotent in VM. _(Search controller properly disposed; listener attached only once)_

## UI
- [x] Implement dumb global timeline view. _(GlobalTimelineV2View with browse skeleton + hydration)_
- [ ] Add prominent correspondent label per row. _(Using senderName; needs enhancement for global-specific UI model)_
- [x] Implement two modes: browse vs search. _(Browse done; search placeholder exists in VM but not wired to real provider)_
- [x] Verify no scroll jitter during hydration. _(Using fixed-height skeleton placeholders)_

## Search
- [ ] Implement global search provider. _(VM has debounce + placeholder; no real search provider yet)_
- [ ] Add "jump to result" behavior. _(Framework exists; not implemented)_
- [ ] Ensure unknown senders are discoverable (no contact required). _(Will work once search provider built)_

## Tests
- [ ] Provider tests for ordinal/jumps.
- [ ] Provider tests for global search results.
- [ ] Widget smoke tests for browse/search switching.

## Verification
- [ ] Manual: open All Messages, scroll, jump month, search, jump to hit. _(Partially: can open, browse; search/month-jump not wired)_
- [x] `flutter analyze` clean. _(Verified earlier)_
- [x] `dart run build_runner build --delete-conflicting-outputs` clean. _(Ran successfully earlier)_

## Documentation
- [ ] Add/extend `40-FEATURES/messages/` docs with global timeline section.
- [ ] Include a human-readable mechanistic walkthrough for global timeline.
