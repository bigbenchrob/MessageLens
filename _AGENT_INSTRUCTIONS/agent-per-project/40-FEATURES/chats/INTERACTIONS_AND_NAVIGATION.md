---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ../messages/INTERACTIONS_AND_NAVIGATION.md
tests: []
feature: chats
doc_type: interactions
status: draft
last_updated: 2025-11-06
---

# Interactions & Navigation — Chats

## Primary Entry Points
- Center panel chat list (`ViewSpec.chats` TBD).
- Deep links from search and notifications to specific chat detail.

## User Flows
1. **Launch → Chat List** — loads pinned chats then recent chats ordered by last activity.
2. **Select Chat** — updates panels to show chat detail and message timeline.
3. **Pin/Archive Chat** — toggles overlay state, updates projections.
4. **Mark All Read** — clears unread counters and propagates to message view.

## Cross-Feature Touchpoints
- Messages feature listens for active `chatId` selection to fetch timeline.
- Search feature links back into chats list by `chatId`.
- Chat handles feature ensures participant roster is resolved before detail view renders.

## Navigation Guardrails
- Use ViewSpec-driven navigation; ensure panel coordinators react to chat selection.
- Maintain derived state (selected chat, filters) in providers, not ad-hoc widget state.
- Provide consistent fallback panel when no chat is selected.

## Outstanding Decisions
- Finalize chat list filtering (archived vs. active in separate panels?).
- Determine policy for multi-window or split view scenarios on macOS.
