---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./DOMAIN_AND_DATA_MAP.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: messages
doc_type: charter
status: draft
last_updated: 2025-12-23
---

# Feature Charter — Messages

## Mission
- Provide a fast, stable, contact-scoped message timeline UI (“Messages for Contact”).
- Keep the presentation pipeline deterministic and resilient to database maintenance/reset.
- Enable search and timeline jumps without coupling UI widgets to data-fetching details.

## Primary Outcomes
- Contact-scoped timeline: ordered across all chats/handles for a given contact.
- Ordinal skeleton + per-row hydration: fast first paint, stable scroll, minimal churn.
- “Jump” behavior: jump to latest and jump to month (heatmap-driven) without requiring the view to know index math.
- Search: debounced, provider-driven search results list.

## Success Metrics
- Timeline opens quickly even with large histories (ordinal skeleton computation is bounded and cache-friendly).
- No UI lockups during destructive DB maintenance (providers short-circuit rather than hanging).
- No scroll jitter during hydration (placeholders are fixed-height).

## Non-Goals
- Chat-specific timeline UI (intentionally removed until needed).
- Global timeline UI (exists, but this doc set focuses on the contact-scoped pipeline).
- Direct widget-driven database access.

## Stakeholders & Dependencies
- Depends on `working.db` projection tables and the `contact_message_index` mapping.
- Depends on centralized DB providers (`driftWorkingDatabaseProvider`) and maintenance lock (`dbMaintenanceLockProvider`).
- Consumed by: contact messages center panel, search feature (for contact search).

## Open Questions
- Attachment hydration strategy for contact timeline (currently minimal in ordinal hydration path; attachments come from `ChatMessageListItem`).
- Whether month jump should be animated vs. instantaneous for large jumps.
