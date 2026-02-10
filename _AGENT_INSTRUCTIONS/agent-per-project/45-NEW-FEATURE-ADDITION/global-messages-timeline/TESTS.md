---
tier: project
scope: tests
owner: agent-per-project
last_reviewed: 2025-12-24
source_of_truth: doc
links:
  - ./PROPOSAL.md
tests: []
---

# Tests — Global Messages Timeline

This file will be filled in as we implement.

## Provider / Unit Tests (planned)
- Global ordinal provider:
  - empty DB → totalCount 0
  - jumpToLatest on empty → no crash
  - jumpToMonth on month with no messages → no crash / no movement
  - maintenance lock short-circuits to empty state

- Global hydration provider:
  - ordinal out of range → null
  - message row mapping returns correspondent label

- Global search provider:
  - query returns results with messageId + timestamp
  - “jump to result” can resolve to an ordinal

## Widget Tests (planned)
- Renders empty state.
- Renders timeline list with skeleton + hydration placeholders.
- Switching to search mode swaps list.

## Manual Verification (planned)
- Search for a phrase that matches unknown sender.
- Jump to a historical month and browse around.
- Confirm scroll does not jitter when rich previews load.
