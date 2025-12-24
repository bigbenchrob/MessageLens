---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ../../60-NAVIGATION/navigation-overview.md
tests: []
feature: messages
doc_type: interactions
status: draft
last_updated: 2025-12-23
---

# Interactions & Navigation — Messages

This document describes the current, canonical **contact messages** flow.
Chat-specific message screens are intentionally stubbed/absent.

## Primary Entry Points
- Contact messages in the **center panel**, driven by `ViewSpec.messages(MessagesSpec.forContact(...))`.
- The view is intentionally “dumb”: it renders state and delegates behaviors (search debounce, jump) to the view model.

## User Flows
1. **Select Contact** → center panel shows contact timeline.
	- “Skeleton”: ordinal provider loads `totalCount` and builds a fixed-height list.
	- “Hydration”: each row loads `messageByContactOrdinalProvider(contactId, ordinal)`.
2. **Initial positioning**
	- Default: jump to latest message.
	- If `scrollToDate` is provided, VM jumps to the month bucket for that date.
3. **Search messages with this contact**
	- Typing updates VM controller -> debounce -> `contactMessageSearchResultsProvider`.
	- UI switches from ordinal timeline to a search results list.
4. **Jump by month (heatmap)**
	- Heatmap chooses a month.
	- VM invokes `contactMessagesOrdinalProvider(...).notifier.jumpToMonth(monthKey)`.
5. **View rich content**
	- URL previews use `MessageLinkPreviewCard` when appropriate.
	- Image/video tiles render for first matching attachment.

## Cross-Feature Touchpoints
- Contacts feature selects a `contactId` and drives `MessagesSpec.forContact` navigation.
- Search feature provides the underlying `SearchService`, used for contact message search.
- DB maintenance/reset feature toggles `dbMaintenanceLockProvider`.

## Navigation Guardrails
- Always rely on ViewSpec variants for navigation; avoid manual route pushes.
- Prefer `MessagesSpec.forContact(contactId: ..., scrollToDate: ...)` for contact-scoped browsing.
- `MessagesSpec.forChat` and `MessagesSpec.forChatInDateRange` exist, but are currently stubbed in `MessagesCoordinator`.
- Ensure timeline gracefully handles missing message records (row hydration may return null).

## Outstanding Decisions
- Whether to add “jump to specific day” (today: month-level jump is supported).
- Attachment loading strategy in per-row hydration (currently minimal; attachments come from `ChatMessageListItem`).
