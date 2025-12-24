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
last_updated: 2025-12-23
---

# State & Provider Inventory — Messages

This inventory is authoritative for the **contact messages** path.
Chat-specific message UI/providers were intentionally hard-deleted.

If you want the “how it works” narrative first, start here:
- `./message-display-flow-walkthrough.md`

| Provider / State | Kind | Location | Parameters | Responsibility |
| --- | --- | --- | --- | --- |
| `contactMessagesViewModelProvider` | `@riverpod` notifier | `lib/features/messages/presentation/view_model/contact_messages/contact_messages_view_model.dart` | `contactId` | Orchestrates the contact-messages UI state: search controller, debounce, search results, and exposes ordinal state.
| `contactMessagesOrdinalProvider` | `@riverpod` async notifier | `lib/features/messages/presentation/view_model/contact_messages/jump/contact_messages_ordinal_provider.dart` | `contactId` | Computes `totalCount` and owns scroll controllers; provides jump helpers (`jumpToLatest`, `jumpToMonth`). Short-circuits when `dbMaintenanceLockProvider` is true.
| `messageByContactOrdinalProvider` | `@riverpod` future family | `lib/features/messages/presentation/view_model/contact_messages/hydration/message_by_contact_ordinal_provider.dart` | `contactId`, `ordinal` | Hydrates a single message row by mapping `ordinal -> messageId -> message joins -> ChatMessageListItem`.
| `contactMessageSearchResultsProvider` | `@riverpod` future family | `lib/features/messages/presentation/view_model/contact_message_search_provider.dart` | `contactId`, `query` | Delegates contact search to `SearchService` (FTS first, then legacy join).
| `searchServiceProvider` | provider | `lib/features/search/search_feature_providers.dart` | — | Exposes `SearchService` to message/search providers.
| `dbMaintenanceLockProvider` | provider | `lib/essentials/db/feature_level_providers.dart` | — | Guards destructive DB maintenance; prevents providers from opening DB during reset.
| `driftWorkingDatabaseProvider` | provider | `lib/essentials/db/feature_level_providers.dart` | — | Single source of truth for opening `working.db` (avoids multiple connections/locking).

## State Objects & Caches
- `ContactMessagesViewModelState` (immutable): search text + debounced query + results + ordinal state.
- `ContactMessagesOrdinalState`: `totalCount` + `ItemScrollController` + `ItemPositionsListener`.

Notes on lifecycle:
- Riverpod Notifier `build()` may run multiple times; stateful objects must be initialized idempotently.
- `ContactMessagesViewModel` owns a single `TextEditingController` and `Timer` debounce and disposes them via `ref.onDispose`.

## Invalidations & Triggers
- Contact selection drives which `contactId` is passed to the providers; changing `contactId` creates a new provider instance.
- Search updates originate from the VM-owned `TextEditingController` listener.
- DB maintenance lock causes ordinal provider to immediately return empty state (prevents “infinite loading”).

## TODO
- If/when chat-specific UI returns, it should follow the same “ordinal + hydration + view model” pattern.
