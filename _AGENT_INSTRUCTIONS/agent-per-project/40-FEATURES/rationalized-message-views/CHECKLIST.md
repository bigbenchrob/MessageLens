# Rationalize Message Views — Implementation Checklist

**Status**: ✅ COMPLETE — Merged to main

## Phase 1: Foundation — Sealed Class & Strategies ✅

- [x] **1.1** Create `MessageTimelineScope` sealed class
  - Location: `lib/features/messages/domain/value_objects/message_timeline_scope.dart`
  - Variants: `global()`, `contact({required int contactId})`, `chat({required int chatId})`
  - Run `dart run build_runner build --delete-conflicting-outputs`

- [x] **1.2** Create ordinal strategy interface
  - Location: `lib/features/messages/application/strategies/ordinal_strategy.dart`
  - Methods: `getTotalCount()`, `getFirstOrdinalForMonth(String monthKey)`, `getFirstOrdinalOnOrAfter(DateTime date)`, `getMessageIdByOrdinal(int ordinal)`

- [x] **1.3** Implement `GlobalOrdinalStrategy`
  - Location: `lib/features/messages/application/strategies/global_ordinal_strategy.dart`
  - Delegates to `GlobalMessageIndexDataSource`

- [x] **1.4** Implement `ContactOrdinalStrategy`
  - Location: `lib/features/messages/application/strategies/contact_ordinal_strategy.dart`
  - Delegates to `ContactMessageIndexDataSource`

- [x] **1.5** Implement `ChatOrdinalStrategy`
  - Location: `lib/features/messages/application/strategies/chat_ordinal_strategy.dart`
  - Delegates to `MessageIndexDataSource` (existing per-chat index)

- [x] **1.6** Create extension for scope → strategy conversion
  - Location: `lib/features/messages/domain/message_timeline_scope_extensions.dart`
  - Method: `toOrdinalStrategy(WorkingDatabase db)`

## Phase 2: Unified Ordinal Provider ✅

- [x] **2.1** Create unified `MessageTimelineOrdinalState`
  - Location: `lib/features/messages/presentation/view_model/timeline/ordinal/`
  - Contains: `scope`, `totalCount`, `itemScrollController`, `itemPositionsListener`, `strategy`

- [x] **2.2** Create unified `MessageTimelineOrdinalProvider`
  - Location: `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart`
  - Accepts `MessageTimelineScope` as family parameter
  - Uses strategy pattern to delegate to correct data source
  - Implements `jumpToLatest()`, `jumpToMonth()`, `jumpToDate()`, `scrollTo()`

## Phase 3: Unified Hydration Provider ✅

- [x] **3.1** Create unified `messageByTimelineOrdinalProvider`
  - Location: `lib/features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart`
  - Accepts `scope` and `ordinal` as parameters
  - Uses `OrdinalStrategy.getMessageIdByOrdinal()` (no separate hydration strategy needed)
  - Shares query logic via `MessageRowMapper`

## Phase 4: Unified View Model ✅

- [x] **4.1** Create unified `MessageTimelineViewModelState`
  - Location: `lib/features/messages/presentation/view_model/timeline/message_timeline_view_model_provider.dart`
  - Fields: `scope`, `searchController`, `searchQuery`, `debouncedQuery`, `searchMode`, `searchResults`, `ordinal`

- [x] **4.2** Create unified `MessageTimelineViewModelProvider`
  - Accepts `MessageTimelineScope` as family parameter
  - Manages TextEditingController lifecycle
  - Handles debounced search with scope-aware search execution
  - Delegates jump methods to ordinal provider

## Phase 5: Unified View Widget ✅

- [x] **5.1** Create unified `MessagesTimelineView`
  - Location: `lib/features/messages/presentation/view/messages_timeline_view.dart`
  - Accepts `MessageTimelineScope` and optional `scrollToDate`
  - Uses `switch` on scope for scaffold style
  - Reuses `MessageCard` widget for rows

- [x] **5.2** Create scope-specific components
  - `_GlobalSearchBar` — search field with mode toggle
  - `_SimpleSearchBar` — search field without mode toggle (contact/chat)
  - `_SearchModeToggle` — All terms / Any term buttons
  - `_ContactHeader` — contact name, message count
  - `_ChatHeader` — chat info, message count

- [x] **5.3** Create shared components
  - `_MessageRow` — hydrates via `messageByTimelineOrdinalProvider`
  - `_SkeletonRow` — loading placeholder
  - `_SearchResultsList` — displays search results

## Phase 6: Migration & Cleanup

- [x] **6.1** Update GlobalMessagesView builder
  - Modified `global_timeline_builder.dart` to use `MessagesTimelineView` with `GlobalTimelineScope`

- [x] **6.2** Update MessagesForContactView builder
  - Modified `messages_for_contact_builder.dart` to use `MessagesTimelineView` with `ContactTimelineScope`

- [x] **6.3** Manual testing
  - [x] Global timeline loads and scrolls
  - [x] Global search works (all terms / any term)
  - [x] Jump to date from heatmap works
  - [x] Contact messages load and scroll
  - [x] Contact search works

- [x] **6.4** Delete orphaned old code (after testing)
  - Deleted `global_messages_view.dart`
  - Deleted `messages_for_contact_view.dart`
  - Deleted `global_messages/` folder
  - Deleted `contact_messages/` folder
  - Created `current_visible_month_provider.dart` to replace old heatmap providers
  - Updated `messages_heatmap_widget.dart` to use unified provider

## Phase 7: Documentation & Verification

- [x] **7.1** Update DESIGN_NOTES.md with final architecture
- [x] **7.2** Update TESTS.md with test coverage summary
- [x] **7.3** Run `flutter analyze` — ensure no issues
- [x] **7.4** Manual QA checklist:
  - [x] Global timeline loads and scrolls
  - [x] Global search works (all terms / any term)
  - [x] Jump to date from heatmap works
  - [x] Contact messages load and scroll
  - [x] Contact search works
  - [x] Handle lens loads and scrolls
- [x] **7.5** Create STATUS.md marking feature complete
- [x] **7.6** Move documentation to `40-FEATURES/rationalized-message-views/`

---

## Progress Summary

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Foundation | ✅ Complete | Sealed class + 3 strategies |
| 2. Ordinal Provider | ✅ Complete | Unified state + provider |
| 3. Hydration Provider | ✅ Complete | Uses ordinal strategy directly |
| 4. View Model | ✅ Complete | Unified with scope-aware search |
| 5. View Widget | ✅ Complete | MessagesTimelineView created |
| 6. Migration | ✅ Complete | Old code deleted, heatmap updated |
| 7. Documentation | ✅ Complete | Merged to main |
