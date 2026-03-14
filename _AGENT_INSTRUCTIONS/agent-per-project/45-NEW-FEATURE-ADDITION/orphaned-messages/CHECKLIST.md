---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./RETROSPECTIVE.md
  - ./TESTS.md
tests: []
---

# Checklist — Orphaned Messages / Unlinked Source Content

## Proposal / Scope
- [x] Confirm user-facing label for v1. _(Chose `Recovered Unlinked Messages`.)_
- [x] Confirm whether v1 includes only likely-content-bearing rows or also sparse artifacts by default. _(Likely-content-bearing rows are primary; sparse artifacts stay preserved but lower-priority for now.)_
- [x] Confirm entry point in navigation chrome. _(Messages-state top menu, with sidebar cassettes for navigation beneath it.)_

## Data Model
- [x] Choose storage strategy. _(Dedicated orphan / unlinked tables; do not force these rows into the normal relationship model.)_
- [x] Confirm ledger schema for orphan rows, attachments, and any supporting metadata. _(`recovered_unlinked_messages` and `recovered_unlinked_message_attachments` landed in the ledger.)_
- [x] Confirm working-db projection model for orphan rows. _(`recovered_unlinked_messages` and `recovered_unlinked_attachments` landed in `working.db`.)_
- [ ] Confirm whether sparse artifact rows need a separate projection or only a filter field.

## Import Pipeline
- [x] Add source-orphan detection as an explicit import concern instead of a silent drop.
- [x] Preserve plain text, `attributedBody`, and attachment joins for orphan rows.
- [x] Ensure rich-text extraction can run for orphan rows.
- [x] Extend import audit logging to report preserved orphan counts and bucket breakdowns.

## Migration Pipeline
- [x] Project preserved orphan rows into working-db storage without fake chat linkage.
- [x] Preserve attachment relationships and handle linkage in the projection.
- [x] Extend migration audit logging to report projected orphan counts.

## Query / Provider Layer
- [x] Design browse provider(s) for unlinked records.
- [ ] Design search provider(s) for the dedicated surface.
- [x] Ensure existing chat/thread providers do not accidentally pull orphan rows into normal flows.

## Navigation / UI
- [x] Add ViewSpec route for the new quarantined feature surface.
- [x] Define coordinator / resolver / widget-builder ownership for the surface.
- [x] Design list rows for plain-text, rich-text, media-only, and sparse artifact cases.
- [x] Decide how to expose sparse artifacts in v1. _(Keep them behind a lower-priority advanced path for now.)_
- [x] Add contact-scoped recovered browsing and best-guess outgoing context reconstruction.

## Testing
- [ ] Import tests for orphan detection and preservation.
- [ ] Migration tests for orphan projection integrity.
- [ ] Provider tests for browse/search behavior.
- [ ] Widget smoke tests for the quarantined surface.

## Documentation
- [x] Source-db research documented under `15-MACOS-SOURCE-DATABASES/`.
- [x] Add implementation notes once schema direction is approved.
- [x] Update import/migration docs after code lands.
- [x] Add a human-readable retrospective explaining the Apple visibility hypothesis and the app restructure that now reveals recovered hidden information.

## Verification
- [ ] Manual: import a dataset known to contain source orphans and verify preserved counts.
- [ ] Manual: confirm orphan records remain separate from normal chats.
- [ ] Manual: confirm attachments and decoded text appear where available.
- [ ] Manual: confirm sparse artifacts are accessible but not noisy by default.