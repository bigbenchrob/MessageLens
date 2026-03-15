---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-03-14
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./RETROSPECTIVE.md
  - ./TESTS.md
tests: []
---

# Checklist — Message Variant Preservation

## Proposal / Scope
- [ ] Confirm feature name and branch name.
- [ ] Confirm whether phase 1 begins with recovered/unlinked rows only or includes linked messages immediately.
- [ ] Confirm which raw Apple fields are approved for ledger preservation.

## Data Model
- [ ] Define minimum useful raw discriminator set.
- [ ] Define normalized semantic fields for working-db.
- [ ] Decide which raw fields remain ledger-only and which get projected forward.
- [ ] Define a conservative `sparse artifact` rule.

## Import Pipeline
- [ ] Preserve raw Apple `item_type`.
- [ ] Preserve raw `associated_message_type`.
- [ ] Preserve `message_summary_info` presence or content as approved.
- [ ] Preserve `payload_data` presence or content as approved.
- [ ] Preserve additional source flags needed for classification.
- [ ] Extend import audit logging with counts by raw variant evidence.

## Migration Pipeline
- [ ] Add working-db fields for normalized semantics.
- [ ] Project raw diagnostic fields needed by provider and UI layers.
- [ ] Add migration audit counts for semantic buckets.

## Classification Layer
- [ ] Replace current catch-all `'text'` fallback with a conservative multi-signal classifier.
- [ ] Distinguish plain text from typedstream-backed text.
- [ ] Distinguish edited / unsent, associated / reaction, balloon / app, and sparse artifact rows where possible.
- [ ] Preserve `unknown` when evidence is insufficient.

## Query / Provider Layer
- [ ] Expose developer-readable semantic metadata for recovered rows.
- [ ] Decide whether normal message providers also surface semantic metadata in phase 1.
- [ ] Ensure legacy consumers do not break if new fields are absent in older data states.

## UI / Diagnostics
- [ ] Add developer-facing display for raw item type and semantic classification in recovered views.
- [ ] Replace misleading blank-text labels for sparse artifacts with clearer wording.
- [ ] Decide whether linked-message surfaces need any phase 1 developer-only annotations.

## Testing
- [ ] Import tests for raw-field preservation.
- [ ] Migration tests for semantic projection.
- [ ] Classifier tests with representative Apple row shapes.
- [ ] Provider tests for recovered-row metadata exposure.

## Documentation
- [x] Create feature proposal package.
- [ ] Update source-db and import docs after schema direction is approved.
- [ ] Document final classification matrix once implemented.

## Verification
- [ ] Manual: inspect a known sparse recovered artifact and verify it is not labeled as ordinary text.
- [ ] Manual: inspect a typedstream-backed row and verify classification reflects rich-text source.
- [ ] Manual: inspect an edited / unsent row if present in dataset.
- [ ] Manual: verify no anomalous rows are dropped during import or migration.