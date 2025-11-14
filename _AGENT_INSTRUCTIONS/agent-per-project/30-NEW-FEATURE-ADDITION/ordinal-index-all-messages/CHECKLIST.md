# Ordinal Index All Messages — Delivery Checklist

## Planning
- [ ] Proposal approved by product owner
- [ ] Schema review confirming `message_index` ordering and coverage
- [ ] Finalize design notes and secure architecture sign-off

## Implementation
- [ ] Add Drift query/DAO for global ordinal paging (keyset-based)
- [ ] Implement application-layer use case (`FetchGlobalMessageTimeline`)
- [ ] Generate Riverpod provider family for timeline pagination
- [x] Extend ViewSpec (`MessagesSpec.globalTimeline`) and coordinator wiring
- [ ] Build macOS timeline widget with virtualized list + jump controls
- [x] Provide navigation entry point (menu, command palette, or shortcut)

## Validation
- [ ] Unit tests for DAO ordering and pagination boundaries
- [ ] Provider tests covering cursor state and lazy hydration
- [ ] Widget/integration test ensuring navigation + rendering works
- [ ] Manual run against large fixture confirming smooth scrolling

## Release
- [ ] Update documentation in `40-FEATURES` once delivered
- [ ] Capture release notes and user guidance
- [ ] Create `STATUS.md` with final outcome and metrics
