---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chat-handles
doc_type: interactions
status: draft
last_updated: 2025-11-06
---

# Interactions & Navigation — Chat Handles

## Primary Entry Points
- Manual handle linking panel (center panel ViewSpec TBD).
- Import diagnostics tooling when handle normalization fails.

## User Flows
1. **View unmatched handles** → surfaces orphaned handles requiring contact association.
2. **Link handle to participant** → writes overlay override, triggers index rebuild.
3. **Unlink handle** → removes override, re-projects participant roster.

## Cross-Feature Touchpoints
- Chats feature subscribes to roster updates after manual link.
- Messages feature resolves display name after overrides.
- Search feature must refresh handle indexes after changes.

## Navigation Guardrails
- All entry points should be described via dedicated ViewSpecs once the UI is formalized.
- Avoid hard-coded navigation; use `panelsViewStateProvider` + feature coordinators.

## Outstanding Decisions
- Finalize ViewSpec naming (e.g., `ViewSpec.manualHandleLinking`).
- Determine how to surface handle diagnostics in search/global datasets.
