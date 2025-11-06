---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ./DOMAIN_AND_DATA_MAP.md
tests: []
feature: chat-handles
doc_type: state-provider-inventory
status: draft
last_updated: 2025-11-06
---

# State & Provider Inventory — Chat Handles

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| `handleCanonicalizerProvider` | @riverpod class | N/A | Normalizes raw handle data into canonical identifiers. | Import + migration orchestration. |
| `handlesByChatProvider` | @riverpod family | `chatId` | Exposes handle roster for a chat. | Chats feature UI, search indexing. |
| `manualHandleOverridesProvider` | @riverpod future | N/A | Loads manual overrides from overlay DB. | Manual link UI, participant resolution. |

## State Objects & Caches
- Drift DAOs: `HandlesDao`, projection caches.
- Derived caches for normalized phone/email formats.

## Invalidations & Triggers
- Overlay writes should invalidate `manualHandleOverridesProvider` and any derived caches.
- Import refresh triggers full rebuild, ensure providers bubble change events.

## TODO
- Audit existing providers in `lib/features/contacts` and consolidate here.
- Decide whether search feature should subscribe directly or via facade provider.
