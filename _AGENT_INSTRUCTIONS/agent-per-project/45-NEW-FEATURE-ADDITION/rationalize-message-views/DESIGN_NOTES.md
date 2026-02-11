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

### After (unified)
```
view_model/
├── timeline/                          # Unified infrastructure
│   ├── message_timeline_view_model_provider.dart
│   ├── ordinal/
│   │   ├── message_timeline_ordinal_provider.dart
│   │   └── strategies/
│   │       ├── ordinal_strategy.dart  # Interface
│   │       ├── global_ordinal_strategy.dart
│   │       ├── contact_ordinal_strategy.dart
│   │       └── handle_ordinal_strategy.dart
│   ├── hydration/
│   │   ├── message_by_ordinal_provider.dart
│   │   └── strategies/
│   │       ├── hydration_strategy.dart  # Interface
│   │       ├── global_hydration_strategy.dart
│   │       ├── contact_hydration_strategy.dart
│   │       └── handle_hydration_strategy.dart
│   └── search/
│       └── timeline_search_provider.dart
└── shared/                            # Unchanged
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

## Open Design Questions

### Q1: Where does MessageTimelineScope live?

**Options:**
- `messages/domain/value_objects/` — Aligns with DDD, but scope is more of an application concern
- `messages/application/models/` — Application layer seems right since it coordinates providers
- `essentials/navigation/` — If it becomes navigation-related

**Tentative answer:** `messages/domain/value_objects/` — It describes a domain concept (the scope of a message query).

### Q2: Should the unified view replace the old views entirely?

**Options:**
- Yes, single `MessagesTimelineView` everywhere
- No, keep `GlobalMessagesView` / `MessagesForContactView` as thin wrappers

**Tentative answer:** Keep thin wrappers initially for easier migration. Collapse later if wrappers become trivial.

### Q3: How to handle scope-specific state (e.g., global filters)?

**Options:**
- Include in unified state with optional fields
- Create scope-specific state extensions
- Keep as separate providers

**Tentative answer:** Separate providers for scope-specific features. Unified state contains only common fields.
