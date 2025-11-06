---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ../chat-handles/DOMAIN_AND_DATA_MAP.md
	- ../../50-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md
tests: []
feature: chat-handles
doc_type: charter
status: draft
last_updated: 2025-11-06
---

# Feature Charter — Chat Handles

## Mission
- Capture how canonical handle identities are created, normalized, and associated with participants.
- Document inbound data sources (macOS Messages handles, manual overrides) and the invariants we must preserve.

## Primary Outcomes
- Deterministic mapping from Apple handle rows to application `HandleId`s.
- Clear override story for user-driven corrections (see manual-handle-to-contact-linking).
- Cohesive auditing so migrations and UI features share the same handle vocabulary.

## Success Metrics
- Handle normalization errors detected in import logs.
- Manual override latency between overlay write and projection update.
- Regression tests covering canonicalization edge cases.

## Non-Goals
- Contact display formatting (owned by contacts feature).
- Navigation or UI presentation of handles (covered elsewhere).

## Stakeholders & Dependencies
- Depends on import/migration pipelines for source data fidelity.
- Provides identifiers consumed by chats, messages, and search features.

## Open Questions
- How do we stage alternative normalization strategies (e.g., phone formatting) without breaking projections?
- What telemetry do we need to catch drift between import ledger and working projection?
