---
feature: chats
doc_type: state-provider-inventory
owner: @rob
status: draft
last_updated: 2025-11-06
---

# State & Provider Inventory — Chats

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| `chatListProvider` | @riverpod stream | filters, paging | Streams paginated chat summaries ordered by recency. | Chat sidebar UI, search suggestions. |
| `chatDetailProvider` | @riverpod future | `chatId` | Loads chat metadata + participant roster. | Chat detail panel, message header. |
| `chatPreferencesProvider` | @riverpod notifier | `chatId` | Persists pin/archive/mute overlay state. | UI toggles, background sync. |
| `chatUnreadCounterProvider` | @riverpod family | `chatId` | Supplies unread count with automatic invalidation. | Badge rendering across app shell. |

## State Objects & Caches
- Drift DAOs: `ChatsDao`, `ChatParticipantsDao`.
- Derived caches for unread counts and last message previews.

## Invalidations & Triggers
- Import/migration completion should trigger full chat list refresh.
- Message append events must invalidate unread counters and last message preview provider.
- Overlay preference changes should invalidate both list and detail providers.

## TODO
- Confirm we have consistent provider naming in code (`messages` feature currently duplicates some logic).
- Evaluate need for background caching when chat list is large.
