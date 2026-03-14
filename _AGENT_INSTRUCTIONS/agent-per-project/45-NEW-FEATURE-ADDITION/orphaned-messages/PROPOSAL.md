---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: doc
links:
  - ../../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md
  - ../../10-DATABASES/04-db-chat.md
  - ../../10-DATABASES/INVIOLATE_RULES.md
  - ../../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
   - ./RETROSPECTIVE.md
tests: []
feature: orphaned-messages
status: implemented-v1
created: 2026-03-13
---

# Feature Proposal — Recovered Unlinked Messages

**Branch**: `Ftr.orphaned`
**Status**: Implemented in v1, with additional refinement still possible
**Created**: 2026-03-13

---

## Overview

Add a new quarantined but user-accessible feature surface for `chat.db` message rows that exist in the source `message` table but do not have a `chat_message_join` row.

The feature should preserve and surface these records without falsely assigning them to a normal chat thread.

Approved v1 user-facing label:

- `Recovered Unlinked Messages`

Internal terminology may still use `orphan messages` or `unlinked messages` when discussing source-db shape.

## User Value

### Problem

The current import pipeline drops `9618` source `chat.db` message rows solely because they are not linked through `chat_message_join`.

Direct source analysis showed:

- `9184` of those rows appear to carry likely meaningful content by a conservative rule
- many are tied to real handles
- many contain plain text, rich text blobs, or attachment joins

As a result, MessageLens currently discards potentially valuable user data that exists in Apple’s source database.

### Implemented User-Facing Solution

The app now exposes these records through a dedicated quarantined feature surface that:

- clearly distinguishes them from normal chat-thread content
- allows browsing/searching recovered unlinked rows
- preserves attachments and decoded text where available
- avoids asserting chat membership the source data does not prove
- can restore partial conversation meaning by adding conservatively inferred nearby outgoing replies when sender linkage has been lost

### Benefits

- MessageLens can reveal useful source records that standard thread-linked views omit
- users gain access to potentially meaningful historical content without data loss
- the app remains honest about uncertainty by labeling these records as unlinked
- the import pipeline better aligns with the project’s data-fidelity rule

---

## Existing Architecture Summary

- `chat.db` is ingested into `macos_import.db` by table-specific importers coordinated by `ImportOrchestrator`.
- `working.db` is rebuilt from the ledger by table-specific migrators coordinated by `MigrationOrchestrator`.
- recovered orphan rows now flow through dedicated ledger and working-db tables separate from normal thread-linked messages.
- current normal message projection and UI message flows remain thread-oriented; recovered content is intentionally quarantined behind a separate route.
- navigation and UI dispatch are ViewSpec-based, so any new user-facing surface should enter through that system rather than ad hoc widget wiring.

## Assumptions

1. Source `chat.db` orphan rows are a persistent Apple data-shape reality, not a one-off corruption event.
2. The app should preserve access to these rows without claiming they belong to a known chat.
3. A separate data path is safer than inventing synthetic chat membership.
4. Phase 1 should favor correctness and explicitness over deep UI polish.

## Hard Invariants

1. Do not suppress, skip, or hide source records merely because they are anomalous.
2. Do not fabricate a normal `chat_id` relationship for orphan rows.
3. Do not violate overlay / working DB separation.
4. Do not bypass centralized DB providers.
5. Do not introduce navigation outside the ViewSpec / cross-surface architecture.

---

## Scope

### Phase 1 — Preserve And Surface Unlinked Source Messages

1. **Import preservation**
   Capture source orphan rows into dedicated ledger storage instead of dropping them.

2. **Projection**
   Migrate preserved orphan rows into dedicated working-db tables or a clearly partitioned projection model that does not require fake chat linkage.

3. **Attachments and text recovery**
   Preserve attachment joins and rich-text recovery behavior for orphan rows where available.

4. **Accessible quarantine UI**
   Add a user-accessible but clearly separated app surface for browsing these records.

5. **Searchability**
   Make the quarantined records discoverable through a dedicated surface search path, even if they are not merged into global message search in v1.

6. **Diagnostics**
   Extend audit logs so the import/migration reports clearly distinguish:
   - dropped-orphan behavior before the change
   - preserved orphan counts after the change
   - sparse artifact counts versus likely-content-bearing counts

### Out Of Scope (For This Proposal)

- Auto-merging orphan rows into existing chats
- Inferring chat membership heuristically from handle/date proximity
- Mixing unlinked records into the main chat timeline by default
- Solving every sparse artifact rendering edge case in v1
- Reworking the broader message feature architecture beyond what this feature requires

---

## Proposed Direction

### Implemented Data Strategy

The app now uses **dedicated recovered/unlinked tables** in both ledger and working projections rather than forcing these rows into existing `messages` tables with synthetic chat links.

Why:

- preserves the true source shape
- avoids fake chat relationships
- makes feature scope explicit
- limits risk of contaminating existing message/thread assumptions

### Implemented UX Strategy

Expose these records as a separate feature entry labeled `Recovered Unlinked Messages`, with contact-scoped entry points surfaced as `Recovered Deleted Messages` where appropriate.

Implemented / current v1 sub-buckets:

- **Recovered Unlinked Messages** — rows with text, `attributedBody`, or attachment joins
- **Recovered No-Handle Messages** — a separate experimental slice for outgoing orphan rows that no longer retain handle linkage
- sparse artifacts remain preserved but lower-priority in the current UI

### Implemented Navigation Strategy

The feature now enters through dedicated `MessagesSpec` variants and the normal ViewSpec routing/coordinator system.

---

## Architecture Impact

### Modified Areas

| Area | Change |
| --- | --- |
| Import pipeline | Preserve orphan source rows instead of dropping them |
| Migration pipeline | Project preserved orphan rows into working-db storage |
| Message text recovery | Ensure orphan rows participate in rich-text and attachment preservation paths |
| Navigation | Add a ViewSpec route and entry point for the unlinked-content surface |
| Presentation | Add a dedicated browsing/search surface for quarantined records |
| Audit logs | Report preserved orphan counts and bucket composition |

### Implemented Components

| Component | Purpose |
| --- | --- |
| `recovered_unlinked_messages` + related ledger tables | preserve source rows without `chat_id` fabrication |
| dedicated recovered working-db tables | user-facing access path for unlinked records |
| recovered ViewSpec / resolver / widget builder path | cross-surface compliant navigation |
| recovered query provider | browse + hydrate recovered rows, including contact-scoped matching |
| audit diagnostics extensions | explicit visibility into preserved orphan counts |

## What The Restructure Revealed

This restructuring changed the app from a thread-only reader into a source-aware recovery tool for this class of hidden records.

Two practical discoveries followed from that change:

1. rows that looked meaningless in isolation often became understandable once nearby recovered outgoing replies were visible
2. Apple's visible thread graph appears to hide more information than the raw `message` table actually loses

In other words, the app did not merely add a new bucket. It exposed a previously invisible layer of user history that had been present in `chat.db` but unreachable through the old import assumptions.

---

## Approved / Implemented Decisions

1. **Storage model**
   Use dedicated orphan/unlinked tables. Do not extend existing message tables with fabricated or nullable chat linkage.

2. **User-facing naming**
   Use `Recovered Unlinked Messages` as the v1 feature label.

3. **Feature boundary**
   Treat these records as a special category outside the normal contact → handle → chat → message flow.

4. **Sparse artifact visibility**
   Preserve sparse artifacts in storage, but keep them behind a lower-priority advanced path for now.

## Remaining Follow-Up Work

1. further tune how inferred nearby outgoing replies are presented and explained
2. decide whether sparse artifacts need their own explicit UI path in v1.1
3. decide whether recovered search should expand beyond the dedicated recovered surfaces

---

## Risks

1. **Schema complexity**
   Adding dedicated orphan tables increases import and migration surface area.

2. **UI confusion**
   Users may misinterpret recovered unlinked records as normal chats unless the feature is clearly labeled and visually separated.

3. **Cross-feature leakage**
   Existing message/thread assumptions may accidentally pull orphan rows into normal providers if boundaries are not explicit.

4. **Attachment edge cases**
   Some orphan rows are sparse or media-only and may require special fallback rendering.

5. **Search ambiguity**
   If these rows later enter broader global search, users may need explicit indicators that results are unlinked source content.

---

## Acceptance Criteria

- Orphan source rows are preserved rather than dropped during import.
- No orphan row is assigned a fabricated normal chat relationship.
- Users can reach a dedicated `Recovered Unlinked Messages` surface that exposes likely-content-bearing unlinked records.
- Attachments and recovered text are preserved where available.
- Sparse artifacts are not silently lost, but can be kept behind a lower-priority UI path.
- Audit logs explicitly report preserved orphan counts and bucket composition.
- All changes respect ViewSpec routing, provider patterns, and database access rules.