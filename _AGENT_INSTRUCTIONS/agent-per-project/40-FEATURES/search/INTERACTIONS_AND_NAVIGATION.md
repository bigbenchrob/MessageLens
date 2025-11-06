---
feature: search
doc_type: interactions
owner: @rob
status: draft
last_updated: 2025-11-06
---

# Interactions & Navigation — Search

## Primary Entry Points
- Search panel/ViewSpec (global command palette or dedicated panel).
- Shortcut triggers (keyboard, menu) launching search overlay.

## User Flows
1. **Launch Search** → load recent queries, focus input.
2. **Execute Query** → stream results grouped by entity type (chat/message/contact).
3. **Navigate to Result** → convert result to appropriate ViewSpec (chat or message) and update panels.
4. **Refine Filters** → adjust date range, participants, or content types.

## Cross-Feature Touchpoints
- Chats: deep links to chat list selection.
- Messages: jump to message timeline anchor.
- Chat handles: ensure participant naming consistent in results.

## Navigation Guardrails
- Maintain pure ViewSpec conversion layer for results to avoid hard-coded navigation.
- Support context-aware navigation (e.g., open chat in existing panel without resetting filters unnecessarily).
- Ensure search UI gracefully handles empty or long-running queries.

## Outstanding Decisions
- Where the search UI panel should live within multi-panel layout.
- Strategy for background indexing vs. user-initiated rebuilds.
