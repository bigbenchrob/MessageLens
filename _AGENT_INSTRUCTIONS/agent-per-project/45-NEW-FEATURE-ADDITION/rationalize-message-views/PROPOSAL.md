# Feature Proposal: Rationalize Message Views

**Status**: APPROVED — Implementation in progress on branch `Ftr.msgview`

## Summary

Consolidate the duplicated code between `GlobalMessagesView` and `MessagesForContactView` (and their supporting view model infrastructure) into a unified, parameterized architecture that supports both global and contact-scoped message timelines.

## Problem Statement

The messages feature currently has two parallel implementations:

```
view_model/
├── contact_messages/       # ~300 lines
│   ├── contact_messages_view_model_provider.dart
│   ├── hydration/message_by_contact_ordinal_provider.dart
│   ├── jump/contact_messages_ordinal_provider.dart
│   └── search/contact_message_search_provider.dart
├── global_messages/        # ~300 lines
│   ├── global_messages_view_model_provider.dart
│   ├── hydration/message_by_global_ordinal_provider.dart
│   ├── jump/global_messages_ordinal_provider.dart
│   └── search/global_message_search_provider.dart
└── shared/                 # Already factored out
```

Both implementations:
- Use `ScrollablePositionedList.builder` with ordinal-based virtual scrolling
- Hydrate skeleton rows on-demand via `AsyncValue.when()`
- Manage search with `TextEditingController` + debounce
- Support jump-to-date and jump-to-latest navigation
- Use identical join queries to fetch message + participant data

**Estimated duplication**: 40-50% of the code is structurally identical.

## Goals

1. **Reduce duplication** — Single set of core functions for ordinal state, hydration, and search
2. **Maintain type safety** — Use sealed classes for scope (Global/Contact/Handle) rather than stringly-typed parameters
3. **Preserve flexibility** — Keep extension points for scope-specific features (e.g., global filters, contact header)
4. **Enable Handle Lens** — The existing `messages_for_handle_view.dart` should use the same infrastructure

## Proposed Architecture

### 1. Unified Message Scope (Domain)

```dart
/// Defines the scope for message timeline queries.
@freezed
sealed class MessageTimelineScope with _$MessageTimelineScope {
  /// All messages across all contacts/chats
  const factory MessageTimelineScope.global() = GlobalScope;
  
  /// Messages with a specific contact (across all their handles)
  const factory MessageTimelineScope.contact({required int contactId}) = ContactScope;
  
  /// Messages from a specific handle (single conversation)
  const factory MessageTimelineScope.handle({required int handleId}) = HandleScope;
}
```

### 2. Unified Ordinal Provider (Application)

```dart
@riverpod
class MessageTimelineOrdinal extends _$MessageTimelineOrdinal {
  @override
  Future<MessageTimelineOrdinalState> build({required MessageTimelineScope scope}) async {
    // Delegate to appropriate data source based on scope
    final strategy = switch (scope) {
      GlobalScope() => GlobalOrdinalStrategy(db),
      ContactScope(:final contactId) => ContactOrdinalStrategy(db, contactId),
      HandleScope(:final handleId) => HandleOrdinalStrategy(db, handleId),
    };
    
    return MessageTimelineOrdinalState(
      totalCount: await strategy.getTotalCount(),
      itemScrollController: ItemScrollController(),
      itemPositionsListener: ItemPositionsListener.create(),
      strategy: strategy,
    );
  }
}
```

### 3. Unified Hydration Provider (Application)

```dart
@riverpod
Future<MessageListItem?> messageByOrdinal(
  Ref ref, {
  required MessageTimelineScope scope,
  required int ordinal,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final strategy = scope.toHydrationStrategy(db);
  return strategy.loadMessageAtOrdinal(ordinal);
}
```

### 4. Unified View (Presentation)

```dart
class UnifiedMessagesTimelineView extends HookConsumerWidget {
  const UnifiedMessagesTimelineView({
    required this.scope,
    this.scrollToDate,
    super.key,
  });

  final MessageTimelineScope scope;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Core scroll list logic is identical
    // Delegate header/toolbar differences to scope-specific widgets
    return Column(
      children: [
        scope.when(
          global: () => _GlobalToolbar(...),
          contact: (id) => _ContactHeader(contactId: id, ...),
          handle: (id) => _HandleHeader(handleId: id, ...),
        ),
        Expanded(child: _MessageScrollList(scope: scope, ...)),
      ],
    );
  }
}
```

## Scope

### In Scope
- Consolidate view model providers (ordinal, hydration, search)
- Create `MessageTimelineScope` sealed class
- Create unified `UnifiedMessagesTimelineView` (or similar)
- Migrate `GlobalMessagesView` to use unified infrastructure
- Migrate `MessagesForContactView` to use unified infrastructure
- Update `MessagesForHandleView` to use unified infrastructure
- Update tests to use parameterized approach

### Out of Scope (for now)
- Adding new features (stat cards, filters, etc.) — separate work
- Changing the navigation spec system
- Modifying `MessageCard` or other display widgets

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Over-abstraction makes code harder to follow | Medium | Medium | Use strategy pattern, not nested conditionals |
| Global and Contact diverge over time | Low | Medium | Keep extension points in view layer only |
| Regression in scroll behavior | Medium | High | Comprehensive tests + manual QA |
| Performance degradation from extra abstraction | Low | Low | Strategies are simple wrappers |

## Success Criteria

1. ✅ Single `MessageTimelineScope` sealed class used across all timeline views
2. ✅ Single ordinal provider parameterized by scope
3. ✅ Single hydration provider parameterized by scope
4. ✅ View model code reduced by ~40%
5. ✅ All existing tests pass
6. ✅ Manual verification: Global timeline, Contact messages, Handle lens all work

## Open Questions

1. **Naming**: Should the unified view be `UnifiedMessagesTimelineView` or just `MessagesTimelineView`?
2. **Location**: Should `MessageTimelineScope` live in `messages/domain/value_objects/` or a new location?
3. **Search mode toggle**: Should Contact gain the "All terms / Any term" toggle, or should it remain Global-only?

## Next Steps (pending approval)

1. Create detailed CHECKLIST.md with incremental steps
2. Create DESIGN_NOTES.md with strategy pattern details
3. Begin implementation with the sealed class and ordinal provider
