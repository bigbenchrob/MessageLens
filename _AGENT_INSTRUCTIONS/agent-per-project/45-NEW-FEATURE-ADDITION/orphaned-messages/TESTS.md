---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./RETROSPECTIVE.md
tests: []
---

# Tests — Orphaned Messages / Unlinked Source Content

This file describes the verification strategy for the implemented v1 recovery path and the next testing gaps that still need to be closed.

## Import / Unit Tests (planned)

- source dataset with orphan rows preserves them instead of dropping them
- source dataset with thread-linked rows still imports unchanged
- orphan row with plain text retains text
- orphan row with only `attributedBody` is preserved for later extraction
- orphan row with attachment joins preserves attachment relationships

## Migration / Unit Tests (planned)

- preserved ledger orphan rows project into working-db orphan storage
- no projected orphan row is assigned a fabricated normal chat relationship
- sparse artifact rows remain preserved and flagged appropriately

## Provider / Query Tests (planned)

- browse provider returns unlinked rows in stable date order
- contact-scoped recovered browsing matches directly attributable rows by surviving sender identity
- contact-scoped recovered browsing can add labeled best-guess nearby outgoing context without reclassifying those rows as normal chat messages
- search provider finds plain-text unlinked rows
- media-only unlinked rows hydrate correctly
- sparse artifact filter/toggle behaves as intended
- existing normal chat/message providers do not include unlinked rows accidentally

## Widget Tests (planned)

- quarantined surface renders empty state correctly
- quarantined surface renders mixed text/media rows
- contact-scoped recovered browsing visibly distinguishes directly matched rows from best-guess inferred rows
- sparse artifact section/toggle is hidden by default if that is the approved UX
- unlinked status labeling is visible and unambiguous

## Manual Verification (planned)

- run import against a dataset known to contain orphan rows and confirm counts match audit logs
- open the unlinked-content surface and verify text-bearing rows appear
- verify media-bearing orphan rows render with working attachments
- open a contact-scoped recovered view and verify nearby outgoing replies can restore conversation meaning where direct inbound rows are otherwise confusing in isolation
- confirm standard chat views remain unchanged
- confirm audit logs report preserved orphan counts and sparse artifact counts

## Regression Concerns

- import performance regression from orphan-preservation logic
- migration-schema drift caused by new orphan tables
- accidental cross-contamination into existing message/chat providers
- confusing UX if unlinked rows appear indistinguishable from normal messages