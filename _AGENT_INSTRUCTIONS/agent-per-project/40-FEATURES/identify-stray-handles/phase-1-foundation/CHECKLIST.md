# Phase 1 — Checklist

## Schema
- [ ] Bump overlay DB schema version
- [ ] Add `virtual_participants` table definition (Drift)
- [ ] Add `handle_to_participant_overrides` table definition (Drift)
- [ ] Write Drift migration for version bump
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verify schema with `flutter analyze`

## Repositories
- [ ] Create `VirtualParticipantRepository` (overlay DB)
- [ ] Create `HandleOverrideRepository` (overlay DB)
- [ ] Unit tests for both repositories

## Providers
- [ ] Create `allParticipantsProvider` (merge working + overlay)
- [ ] Create `strayHandlesProvider` (unlinked handles)
- [ ] Migrate contact picker to use `allParticipantsProvider`
- [ ] Migrate hero card to use `allParticipantsProvider`
- [ ] Migrate heatmap view to use `allParticipantsProvider`
- [ ] Migrate message views to use `allParticipantsProvider`
- [ ] Unit tests for merged provider
- [ ] Unit tests for stray handles provider

## Prerequisite Cleanup
- [ ] Audit `ManualHandleLinkService` dual-write
- [ ] Refactor `ManualHandleLinkService` to overlay-only
- [ ] Migrate existing manual links from working DB to overlay overrides
- [ ] Audit `is_blacklisted` writes — ensure none target working DB
- [ ] Verify no other dual-write patterns exist

## Integration
- [ ] Virtual participant appears in contact picker
- [ ] Selecting virtual participant shows linked messages in heatmap
- [ ] Existing contact flows unaffected
- [ ] All existing tests pass
- [ ] `flutter analyze` clean
