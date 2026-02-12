# Rationalize Message Views — Design Notes

## Architecture Decision: Strategy Pattern

The consolidation uses the **Strategy Pattern** to handle scope-specific differences without polluting core logic with conditionals.

### Why Strategy Pattern?

**Alternatives considered:**

1. **Giant switch statements** — Simple but becomes unmaintainable as scopes diverge
2. **Inheritance** — Creates tight coupling, hard to compose
3. **Composition with callbacks** — Works but loses type safety
4. **Strategy Pattern** — ✅ Clean separation, easily extensible, type-safe

### Strategy Interfaces

```dart
/// Strategy for obtaining ordinal-based message counts and positions.
abstract class OrdinalStrategy {
  /// Total message count in this scope.
  Future<int> getTotalCount();
  
  /// Find first ordinal on or after the given date. Returns null if none.
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date);
  
  /// Find first ordinal for a given month (format: 'YYYY-MM').
  Future<int?> getFirstOrdinalForMonth(String monthKey);
}

/// Strategy for hydrating a message at a given ordinal.
abstract class HydrationStrategy {
  /// Load the message at the given ordinal position.
  /// Returns null if ordinal is out of range.
  Future<MessageListItem?> loadMessageAtOrdinal(int ordinal);
}

/// Strategy for searching messages within a scope.
abstract class SearchStrategy {
  /// Search for messages matching the query.
  Future<List<MessageListItem>> search({
    required String query,
    SearchMode mode = SearchMode.allTerms,
  });
}
```

### Strategy Factory

The scope sealed class includes factory methods:

```dart
extension MessageTimelineScopeStrategies on MessageTimelineScope {
  OrdinalStrategy toOrdinalStrategy(WorkingDatabase db) {
    return switch (this) {
      GlobalScope() => GlobalOrdinalStrategy(db),
      ContactScope(:final contactId) => ContactOrdinalStrategy(db, contactId),
      HandleScope(:final handleId) => HandleOrdinalStrategy(db, handleId),
    };
  }
  
  HydrationStrategy toHydrationStrategy(WorkingDatabase db) {
    return switch (this) {
      GlobalScope() => GlobalHydrationStrategy(db),
      ContactScope(:final contactId) => ContactHydrationStrategy(db, contactId),
      HandleScope(:final handleId) => HandleHydrationStrategy(db, handleId),
    };
  }
}
```

---

## File Organization

### Before (duplicated)
```
view_model/
├── contact_messages/
│   ├── contact_messages_view_model_provider.dart
│   ├── hydration/
│   │   └── message_by_contact_ordinal_provider.dart
│   ├── jump/
│   │   └── contact_messages_ordinal_provider.dart
│   └── search/
│       └── contact_message_search_provider.dart
├── global_messages/
│   ├── global_messages_view_model_provider.dart
│   ├── hydration/
│   │   └── message_by_global_ordinal_provider.dart
│   ├── jump/
│   │   └── global_messages_ordinal_provider.dart
│   └── search/
│       └── global_message_search_provider.dart
└── shared/
    └── (common utilities)
```

### After (unified) — FINAL IMPLEMENTATION
```
domain/value_objects/
├── message_timeline_scope.dart         # Sealed class: global(), contact(), chat()
└── message_timeline_scope.freezed.dart

domain/
└── message_timeline_scope_extensions.dart  # toOrdinalStrategy() extension

application/strategies/
├── ordinal_strategy.dart                # Interface
├── global_ordinal_strategy.dart         # Delegates to GlobalMessageIndexDataSource
├── contact_ordinal_strategy.dart        # Delegates to ContactMessageIndexDataSource
├── chat_ordinal_strategy.dart           # Delegates to MessageIndexDataSource
└── strategies.dart                      # Barrel export

presentation/view_model/timeline/
├── message_timeline_view_model_provider.dart  # Unified view model with search
├── ordinal/
│   ├── message_timeline_ordinal_provider.dart  # Unified ordinal state + scroll
│   └── current_visible_month_provider.dart     # Heatmap month tracking
└── hydration/
    └── message_by_ordinal_provider.dart   # Hydrates via strategy

presentation/view/
├── messages_timeline_view.dart           # Unified view widget
└── (old views deleted)

shared/                                    # Unchanged
├── message_row_mapper.dart
└── hydration/
    └── messages_for_handle_provider.dart
```

---

## Scope Differences Matrix

| Aspect | Global | Contact | Handle |
|--------|--------|---------|--------|
| **Index table** | global_message_index | contact_message_index | chat ordinal (inline) |
| **Ordinal column** | ordinal | ordinal | rowid or inline |
| **Filter** | None (all messages) | contact_id | chat_id |
| **Search mode toggle** | Yes | No (future?) | No |
| **Header widget** | Toolbar | Contact info + stats | Handle info |
| **Jump to month** | Via index lookup | Via index lookup | Via date query |

---

## Provider Family Parameters

The unified providers use `MessageTimelineScope` as the family key:

```dart
// Usage:
ref.watch(messageTimelineOrdinalProvider(scope: const MessageTimelineScope.global()));
ref.watch(messageTimelineOrdinalProvider(scope: MessageTimelineScope.contact(contactId: 42)));
ref.watch(messageByOrdinalProvider(scope: scope, ordinal: 100));
```

**Riverpod equality**: Freezed classes with `@freezed` generate proper `==` and `hashCode`, so provider caching works correctly.

---

## View Composition

The unified view follows a composition pattern rather than inheritance:

```dart
class MessagesTimelineView extends HookConsumerWidget {
  const MessagesTimelineView({
    required this.scope,
    this.scrollToDate,
    super.key,
  });

  final MessageTimelineScope scope;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: Column(
        children: [
          // Scope-specific header
          _buildHeader(context, ref, scope),
          const Divider(height: 1),
          // Scope-specific search bar (optional)
          if (_hasSearchBar(scope)) _buildSearchBar(context, ref, scope),
          // Unified scroll list
          Expanded(
            child: _MessageScrollList(
              scope: scope,
              scrollToDate: scrollToDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, MessageTimelineScope scope) {
    return scope.when(
      global: () => _GlobalToolbar(),
      contact: (contactId) => _ContactHeader(contactId: contactId),
      handle: (handleId) => _HandleHeader(handleId: handleId),
    );
  }
}
```

---

## Migration Strategy

### Option A: Big Bang (not recommended)
Replace all views at once. High risk, hard to debug failures.

### Option B: Incremental (recommended)
1. Build unified infrastructure alongside existing code
2. Create thin wrapper views that delegate to unified
3. Migrate one scope at a time (Global → Contact → Handle)
4. Delete old code after each migration is verified
5. Optionally collapse wrappers into single view

### Option C: Parallel Run
Keep both implementations, add feature flag. Excessive overhead for internal refactoring.

**Selected: Option B — Incremental migration**

---

## Design Questions — Final Answers

### Q1: Where does MessageTimelineScope live?

**Final answer:** `messages/domain/value_objects/` — It describes a domain concept (the scope of a message query). The extension method `toOrdinalStrategy()` lives in `message_timeline_scope_extensions.dart`.

### Q2: Should the unified view replace the old views entirely?

**Final answer:** Yes. The unified `MessagesTimelineView` directly replaces the old views. Widget builders instantiate it with the appropriate scope. No thin wrappers needed.

### Q3: How to handle scope-specific state (e.g., global filters)?

**Final answer:** The unified view model includes `searchMode` which is only used by global scope. Scope-specific UI (headers, search bar variants) is handled via `switch` on the scope within the view widget.
