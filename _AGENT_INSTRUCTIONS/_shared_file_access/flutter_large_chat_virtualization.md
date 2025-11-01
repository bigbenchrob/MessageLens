# Efficient Handling of Large Message Lists in Flutter (iMessage Data App)

## Problem Context

In large iMessage chats (e.g. 60,000+ messages), the previous paging strategy (loading recent messages first and adding older ones as the user scrolls) worked fine. However, introducing a **timeline feature** allowing users to jump to arbitrary months broke this logic: messages loaded out of order, leading to confusing results.

The core issue: **no stable index** across dynamically loaded pages.

---

## Core Solution: Stable Ordinal Index + Virtualized List

The key is to **lock order in the database**, not the UI.

### 1. Message Index Table

Create a persistent table that maps each message to an **ordinal position** within its chat.

```sql
CREATE TABLE message_index(
  chat_id        INTEGER,
  ordinal        INTEGER,  -- 0..N-1 for that chat
  message_id     INTEGER PRIMARY KEY,
  sent_at        INTEGER,
  month_key      TEXT
);

CREATE UNIQUE INDEX ux_message_index_chat_ordinal ON message_index(chat_id, ordinal);
CREATE INDEX ix_message_index_chat_month ON message_index(chat_id, month_key, ordinal);
CREATE INDEX ix_message_index_chat_sent ON message_index(chat_id, sent_at, ordinal);
```

Populate this once:

```sql
INSERT INTO message_index(chat_id, message_id, ordinal, sent_at, month_key)
SELECT chat_id,
       id,
       ROW_NUMBER() OVER (PARTITION BY chat_id ORDER BY sent_at, id) - 1 AS ordinal,
       sent_at,
       STRFTIME('%Y-%m', sent_at / 1000, 'unixepoch')
FROM messages;
```

### Benefits

- Ordinals never change, ensuring **stable scroll anchors**.
- Jumping to a month is instant: 
  ```sql
  SELECT MIN(ordinal), MAX(ordinal)
  FROM message_index
  WHERE chat_id=? AND month_key='2023-06';
  ```

---

## 2. Flutter: Virtualized List by Ordinal

Instead of loading full messages, load by ordinal index.

Use `ScrollablePositionedList` or `flutter_list_view`.

```dart
final itemScrollController = ItemScrollController();
final itemPositionsListener = ItemPositionsListener.create();

Widget build(BuildContext context) {
  return ScrollablePositionedList.builder(
    itemScrollController: itemScrollController,
    itemPositionsListener: itemPositionsListener,
    itemCount: ref.watch(messageCountProvider(chatId)),
    itemBuilder: (ctx, ordinal) => MessageRow(ordinal: ordinal, chatId: chatId),
    minCacheExtent: 800,
  );
}
```

Jumping to a month:

```dart
Future<void> jumpToMonth(String yyyymm) async {
  final start = await repo.firstOrdinalForMonth(chatId, yyyymm);
  itemScrollController.jumpTo(index: start);
}
```

---

## 3. Skeleton-Then-Hydrate Pattern

Do **not** build 50,000 placeholders. Build only visible ones.

```dart
@riverpod
Future<LightMessage> lightByOrdinal(LightByOrdinalRef ref, ChatId chatId, int ordinal) =>
    repo.getLightByOrdinal(chatId, ordinal);

@riverpod
Future<RichMessage> richById(RichByIdRef ref, MessageId id) =>
    repo.getRichById(id);
```

```dart
class MessageRow extends ConsumerWidget {
  final int ordinal;
  final ChatId chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = ref.watch(lightByOrdinalProvider(chatId, ordinal));
    return light.when(
      data: (m) {
        final rich = ref.watch(richByIdProvider(m.id));
        return rich.when(
          data: (rm) => RichMessageTile(rm),
          loading: () => LightSkeletonTile(m),
          error: (_) => ErrorTile(m),
        );
      },
      loading: () => const VeryCheapLineSkeleton(),
      error: (_) => const ErrorLine(),
    );
  }
}
```

- Only on-screen ordinals are built.
- Hydration (rich message loading) happens lazily.
- Riverpod memoization keeps it smooth.

---

## 4. Index-Based Stability

Why the previous system broke: loading by date ranges meant **shifting boundaries**. Ordinals give you unchanging anchors.

```text
ordinal 0      → oldest message
ordinal 59999  → newest message
```
When the user jumps to June 2023 → `jumpTo(index: startOrdinal)`.

---

## 5. SQLite Performance Notes

Avoid `OFFSET` in large tables — it’s O(n). Instead, use indexed lookups:

```sql
SELECT * FROM message_index WHERE chat_id=? AND ordinal=?;
```

Add **covering indexes** for light queries (SQLite ≥ 3.38):

```sql
CREATE INDEX idx_message_index_light ON message_index(chat_id, ordinal) 
  INCLUDE(message_id, sent_at);
```

---

## 6. Variable Height Lists

Use these virtualized widgets:
- `ScrollablePositionedList` (simple, jump-to-index)
- `flutter_list_view` (more performant, caches row heights)

They handle dynamic message heights automatically.

---

## 7. Optimization Checklist

✅ Add `message_index` with ordinals.  
✅ Replace page-based queries with `ordinal` access.  
✅ Switch to index-aware list (`ScrollablePositionedList`).  
✅ Split data layer into “light” and “rich” queries.  
✅ Remove 50k widget build loops.  
✅ Use ordinal jumps for timeline navigation.

---

## 8. Optional Prefetching

- Hydrate ±10 ordinals around the viewport.  
- When jumping to month, prefetch a small neighborhood first.  
- Use Drift or Sqflite caching.

---

## Summary

| Layer | Responsibility | Notes |
|-------|----------------|-------|
| SQLite | Lock message order with ordinals | Use message_index table |
| Repository | Query by ordinal or month | No OFFSETs |
| Riverpod | Provide light/rich messages | Windowed hydration |
| UI | Virtualized list + skeleton tiles | No 50k widget trees |

---

## Next Steps

If desired, I can generate a ready-to-paste `Drift` schema migration and Riverpod providers implementing this architecture.
