# Rationalize Message Views — Test Plan

## Unit Tests

### MessageTimelineScope
- [ ] `MessageTimelineScope.global()` creates correct variant
- [ ] `MessageTimelineScope.contact(contactId: 42)` creates correct variant
- [ ] `MessageTimelineScope.handle(handleId: 99)` creates correct variant
- [ ] Equality: same variants with same parameters are equal
- [ ] Inequality: different variants are not equal
- [ ] Inequality: same variant with different parameters are not equal

### Ordinal Strategies
- [ ] `GlobalOrdinalStrategy.getTotalCount()` returns correct count from global_message_index
- [ ] `GlobalOrdinalStrategy.getFirstOrdinalOnOrAfter()` finds correct ordinal
- [ ] `GlobalOrdinalStrategy.getFirstOrdinalForMonth()` finds correct ordinal
- [ ] `ContactOrdinalStrategy.getTotalCount()` returns correct count for contact
- [ ] `ContactOrdinalStrategy.getFirstOrdinalOnOrAfter()` finds correct ordinal
- [ ] `ContactOrdinalStrategy.getFirstOrdinalForMonth()` finds correct ordinal
- [ ] `HandleOrdinalStrategy.getTotalCount()` returns correct count for handle
- [ ] All strategies return 0/null for empty datasets

### Hydration Strategies
- [ ] `GlobalHydrationStrategy.loadMessageAtOrdinal()` returns correct message
- [ ] `GlobalHydrationStrategy.loadMessageAtOrdinal()` returns null for out-of-range
- [ ] `ContactHydrationStrategy.loadMessageAtOrdinal()` returns correct message
- [ ] `HandleHydrationStrategy.loadMessageAtOrdinal()` returns correct message
- [ ] All strategies correctly populate `MessageListItem` fields

### MessageTimelineOrdinalProvider
- [ ] Returns correct state for global scope
- [ ] Returns correct state for contact scope
- [ ] Returns correct state for handle scope
- [ ] `jumpToLatest()` calls scroll controller correctly
- [ ] `jumpToMonth()` calls scroll controller correctly
- [ ] Returns empty state during maintenance lock

### messageByOrdinalProvider
- [ ] Returns message for valid ordinal (global)
- [ ] Returns message for valid ordinal (contact)
- [ ] Returns message for valid ordinal (handle)
- [ ] Returns null for invalid ordinal
- [ ] Correctly maps participant data

### MessageTimelineViewModelProvider
- [ ] Initializes with correct default state
- [ ] Search controller text updates searchQuery
- [ ] Debounce delays debouncedQuery update
- [ ] Empty query clears search results
- [ ] Non-empty query triggers search
- [ ] `jumpToLatest()` delegates to ordinal provider
- [ ] `jumpToMonth()` delegates to ordinal provider
- [ ] Disposes resources correctly

## Widget Tests

### MessagesTimelineView
- [ ] Global scope shows toolbar with "Jump to latest"
- [ ] Contact scope shows contact header
- [ ] Handle scope shows handle header
- [ ] Search field updates view model
- [ ] Scroll list uses `ScrollablePositionedList`
- [ ] Empty state shows appropriate message
- [ ] Loading state shows progress indicator
- [ ] Error state shows error message

### _MessageScrollList
- [ ] Renders skeleton for loading rows
- [ ] Renders `MessageCard` for hydrated rows
- [ ] Handles scroll position correctly
- [ ] Respects `itemPositionsListener` for visibility tracking

## Integration Tests

### Global Timeline Flow
- [ ] Navigate to global timeline from sidebar
- [ ] Messages load and scroll correctly
- [ ] Search filters messages
- [ ] Jump to date from heatmap works
- [ ] Jump to latest works

### Contact Messages Flow
- [ ] Navigate to contact from picker
- [ ] Messages load for correct contact
- [ ] Search filters within contact
- [ ] Jump to date works
- [ ] Message count is accurate

### Handle Lens Flow
- [ ] Navigate to handle from contact detail
- [ ] Messages load for correct handle
- [ ] Scroll behavior works

## Manual QA Checklist

### Global Timeline
- [ ] Opens without error
- [ ] Shows all messages chronologically
- [ ] Skeleton rows hydrate on scroll
- [ ] Search: "All terms" mode works
- [ ] Search: "Any term" mode works
- [ ] Search: Clear button resets
- [ ] Toolbar: Jump to latest scrolls to end
- [ ] Heatmap: Click month jumps correctly

### Contact Messages
- [ ] Opens without error for known contact
- [ ] Shows correct message count in header
- [ ] Messages appear across all chats with contact
- [ ] Search within contact works
- [ ] Scroll behavior is smooth

### Handle Lens
- [ ] Opens without error
- [ ] Shows messages for single handle only
- [ ] Distinguished from contact view

### Edge Cases
- [ ] Contact with 0 messages shows empty state
- [ ] Very large contact (10k+ messages) scrolls smoothly
- [ ] Rapid scope switching doesn't cause race conditions
- [ ] Search during scroll doesn't cause flicker

## Test Migration Notes

### Existing Tests to Update
- `/test/features/messages/presentation/view_model/global_messages/` → migrate or delete
- `/test/features/messages/presentation/view_model/contact_messages/` → migrate or delete

### New Test Files to Create
- `/test/features/messages/domain/value_objects/message_timeline_scope_test.dart`
- `/test/features/messages/application/strategies/ordinal_strategy_test.dart`
- `/test/features/messages/application/strategies/hydration_strategy_test.dart`
- `/test/features/messages/presentation/view_model/timeline/message_timeline_ordinal_provider_test.dart`
- `/test/features/messages/presentation/view_model/timeline/message_by_ordinal_provider_test.dart`
- `/test/features/messages/presentation/view_model/timeline/message_timeline_view_model_provider_test.dart`
- `/test/features/messages/presentation/view/messages_timeline_view_test.dart`
