---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-03-14
source_of_truth: doc
links:
  - ../orphaned-messages/PROPOSAL.md
  - ../orphaned-messages/RETROSPECTIVE.md
  - ../../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md
  - ../../15-MACOS-SOURCE-DATABASES/apple-typedstream-format-reference.md
  - ../../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../../10-DATABASES/04-db-chat.md
  - ../../10-DATABASES/INVIOLATE_RULES.md
  - ./RETROSPECTIVE.md
tests: []
feature: message-variant-preservation
status: proposed
created: 2026-03-14
---

# Feature Proposal — Message Variant Preservation

**Proposed Branch**: `Ftr.message-variant-preservation`
**Status**: Proposed
**Created**: 2026-03-14

---

## Overview

Add a richer message-semantics preservation layer to the import and projection pipeline so MessageLens retains and classifies more of the useful Apple `message`-table signal that currently gets flattened away.

This feature is not about mirroring `chat.db` wholesale.

It is about preserving the specific source fields and payload channels that help classify message rows which do **not** fit cleanly into the current contact → handle → chat → message model, including:

- recovered orphan/unlinked rows
- rows with `NULL` plain text but meaningful typedstream or summary payloads
- reactions and associated-message carriers
- app / balloon / plugin messages
- edited / unsent message records
- sparse artifact rows that should be preserved but clearly labeled as uncertain

## User Value

### Problem

The current importer preserves raw rows well enough for standard text-heavy messages, but the semantic model is still shallow.

In particular:

- unfamiliar Apple `item_type` values often collapse to `'text'`
- `NULL text` is currently too easy to misread as missing extraction rather than a distinct Apple message state
- useful variant-defining fields are not consistently preserved into ledger and working projections
- recovered orphan rows can contain structurally important clues even when they do not contain body text

As a result, MessageLens currently preserves many anomalous records but cannot always explain what they are.

### Proposed User-Facing Outcome

This feature should make the app more honest and more useful by:

- preserving enough source signal to classify message variants conservatively
- distinguishing normal text from typedstream text, edited / unsent rows, reactions, balloons, and sparse artifacts
- improving developer-visible diagnostics first
- enabling later UX work without another schema rethink

### Benefits

- fewer misleading `'text'` labels on rows that are not ordinary text messages
- better debugging and developer analysis of anomalous source records
- stronger future foundation for user-facing recovered-content improvements
- more durable source preservation without scraping every column in `chat.db`

---

## Existing Architecture Summary

- `chat.db` is read by importers coordinated through the import orchestration layer and copied into `macos_import.db` ledger tables.
- message rows currently preserve plain text, some payload fields, and `attributedBody` blobs, but semantic classification remains limited.
- `working.db` is rebuilt from the ledger by migrators; recovered/unlinked rows already have dedicated tables due to the orphaned-messages feature.
- the recovered deleted-messages investigation revealed that some anomalous rows are preserved correctly but semantically mislabeled.
- the current UI primarily consumes simplified message categories, which means a weak classifier upstream becomes a misleading presentation downstream.

## Assumptions

1. We want to preserve **useful discriminators**, not the full `message` schema.
2. The first implementation priority is preservation and classification, not broad UX redesign.
3. Recovered/unlinked rows are the strongest proving ground for this work, but linked messages should benefit too when the same source semantics apply.
4. It is acceptable to add ledger and working-db fields if they materially improve semantic preservation.

## Hard Invariants

1. Do not suppress, skip, or hide anomalous source records.
2. Do not fabricate thread membership or stronger meaning than the source proves.
3. Do not bypass centralized DB providers.
4. Do not dual-write user intent into working DB tables.
5. Do not widen scope into a general-purpose `chat.db` mirror project.

---

## Scope

### Phase 1 — Preserve Message Variant Signal

1. **Preserve raw discriminators in the ledger**
   Capture the Apple fields most useful for semantic classification.

2. **Project normalized semantic fields into working-db**
   Store conservative classifications and raw source hints side-by-side.

3. **Improve recovered/unlinked interpretation first**
   Use recovered rows as the first consumer of the richer classification model.

4. **Expose developer diagnostics**
   Make it easy to see why a row was classified the way it was.

### Candidate Fields To Preserve

Ledger candidates:

- raw Apple `item_type` integer
- raw `associated_message_type`
- `message_summary_info` blob
- `payload_data` blob presence and optionally raw bytes where feasible
- `is_empty`
- `group_action_type`
- `message_action_type`
- `expressive_send_style_id`
- `reply_to_guid`
- presence flags for `text`, `attributedBody`, attachment joins, and chat joins

Working projection candidates:

- `raw_item_type`
- `raw_associated_message_type`
- `semantic_kind`
- `content_presence_kind`
- `is_sparse_artifact`
- `has_attributed_body_source`
- `has_message_summary_info`
- `has_payload_data`

### Out Of Scope

- copying all columns from Apple `message`
- broad end-user UI redesign for every message type
- turning every preserved variant into a polished first-class UX immediately
- proving Apple's internal semantics beyond what the data supports

---

## Proposed Direction

### Core Strategy

Preserve raw Apple discriminators first, classify second.

That means:

- keep the source evidence needed for later interpretation
- classify conservatively using multiple signals, not just `text` and a few integer constants
- preserve uncertainty explicitly when a row cannot be interpreted confidently

### Why This Direction

The `imessage-database` Rust crate demonstrates that Apple messages exist in many more variants than our current importer model recognizes, including edited, unsent, tapback, balloon, app, and other special payload forms.

Its value for MessageLens is not “import this crate directly.”

Its value is that it confirms a better design principle:

- do not collapse unknown variants into ordinary text
- inspect multiple payload channels before assigning meaning
- treat unknown variants as unknown, not malformed text

### Initial Classification Targets

The normalized semantic layer should be able to distinguish at least:

- normal plain text
- typedstream-backed text
- edited / unsent
- reaction-carrier / associated
- app / balloon payload
- attachment-only
- system / announcement
- unknown raw variant
- sparse artifact

---

## Architecture Impact

### Areas Likely To Change In Implementation

| Area | Planned Change |
| --- | --- |
| Import pipeline | preserve additional source discriminators and payload markers |
| Ledger schema | add targeted message-variant fields |
| Migration pipeline | project richer semantic metadata into working-db |
| Working schema | add normalized semantic and raw diagnostic fields |
| Provider layer | surface developer-readable classifications |
| UI | initially limited to developer-facing recovered diagnostics |
| Audit logs | report counts by raw and normalized message variant |

### Why This Is A Separate Feature

The orphaned-messages feature proved the value of preserving anomalous records.

This feature generalizes that lesson into a broader message-classification capability. It deserves separate planning because it introduces new schema, migration, and semantics decisions that extend beyond recovered rows alone.

---

## Risks

1. **Schema sprawl**
   Too many new fields could recreate the “mirror `chat.db`” mistake in a narrower form.

2. **False confidence in classification**
   Over-classifying weak evidence would be worse than preserving uncertainty.

3. **Migration complexity**
   Adding fields in both ledger and working projections increases maintenance burden.

4. **Premature UX coupling**
   If UI needs drive schema too early, the semantic model may be distorted around current screens instead of future reuse.

---

## Approval Questions

1. Is `message-variant-preservation` the right feature name, or do you want a different label?
2. Should phase 1 cover both linked and recovered/unlinked messages, or should we explicitly scope initial implementation to recovered rows first?
3. Do you want raw payload blobs preserved only in the ledger, or also surfaced in working-db via presence flags and normalized metadata?

---

## Success Criteria

This feature is successful when:

- anomalous rows like recovered `item_type = 1` artifacts are no longer mislabeled as ordinary text
- the ledger contains enough source signal to revisit message interpretation without re-import redesign
- working-db exposes a conservative semantic layer suitable for future developer and user-facing enhancements
- the recovered deleted-messages feature can explain more rows without fabricating meaning