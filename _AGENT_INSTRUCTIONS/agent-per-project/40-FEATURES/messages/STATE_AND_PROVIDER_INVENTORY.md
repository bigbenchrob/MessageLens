---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ./DOMAIN_AND_DATA_MAP.md
tests: []
feature: messages
doc_type: state-provider-inventory
status: draft
last_updated: 2025-11-06
---

# State & Provider Inventory — Messages

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| `messageTimelineProvider` | @riverpod stream | `chatId`, paging cursor | Streams paginated message timeline entries. | Message detail UI, analytics exports. |
| `messageDetailProvider` | @riverpod future | `messageGuid` | Loads full message payload incl. attachments. | Detail flyouts, debugging tools. |
| `messageReactionsProvider` | @riverpod family | `messageGuid` | Exposes aggregated reactions for a message. | UI reaction chips, notifications. |
| `messageComposerStateProvider` | @riverpod notifier | `chatId` | Tracks draft state, ephemeral attachments. | Compose UI.

## State Objects & Caches
- Drift DAOs: `MessagesDao`, `MessageAttachmentsDao`, `MessageReactionsDao`.
- In-memory caches for timeline pagination cursors and optimistic updates.

## Invalidations & Triggers
- New message append invalidates timeline providers and chat summary providers.
- Reaction updates should broadcast to both timeline and detail providers.
- Attachment downloads notify once metadata upgrades (e.g., thumbnail path available).

## TODO
- Consolidate duplicate timeline logic used in test harnesses.
- Decide whether to expose derived timeline entry type via freezed union.
