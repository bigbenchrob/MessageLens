---
feature: messages
doc_type: interactions
owner: @rob
status: draft
last_updated: 2025-11-06
---

# Interactions & Navigation — Messages

## Primary Entry Points
- Message timeline in center/right panels triggered by `ViewSpec.messages`.
- Deep linking from search results or notifications to specific message anchors.

## User Flows
1. **Select Chat** → timeline loads with most recent messages, lazy paging backwards.
2. **Jump to Message** → highlight target message and optionally load surrounding context.
3. **React / Unreact** → apply reaction update, propagate to chat summary.
4. **View Attachment** → open inline preview or external viewer.

## Cross-Feature Touchpoints
- Chat feature signals active chat selection.
- Search feature provides direct message GUID navigation.
- Chat handles feature ensures sender names resolve correctly.

## Navigation Guardrails
- Always rely on ViewSpec variants for navigation; avoid manual route pushes.
- Maintain scroll position state in provider-backed caches for multi-panel layouts.
- Ensure timeline gracefully handles missing message records (e.g., redacted attachments).

## Outstanding Decisions
- How to present multi-window message views on macOS (reuse same providers?).
- UX for very large attachments (streaming vs. download step).
