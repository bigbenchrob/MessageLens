---
feature: message-list-stable-ordering
status: proposed
created: 2025-10-31
owner: agent
---

# Feature Proposal: Message List Stable Ordering with Placeholder Architecture

## Overview

Implement a stable, placeholder-based message list architecture that prevents out-of-order message display and provides predictable scrolling behavior when navigating to specific time periods via timeline clicks.

## Problem Statement

### Current Behavior (Broken)
When clicking a month on the chat card timeline:
- Message list executes erratic jumps before landing on incorrect date
- Messages display out of order (e.g., 2018 messages before 2025 messages)
- Scroll position calculations fail because they're based on partially-loaded subsets
- Each timeline click produces a recognizable but incorrect sequence of jumps

### Root Causes
1. **No stable ordering structure** - Messages loaded page-by-page without fixed position guarantees
2. **Load-time ordering** - Sort happens during page loading, not upfront
3. **Scroll calculations from partial data** - Position calculated from currently loaded messages only
4. **Race conditions** - Multiple scroll/load operations interfere with each other
5. **State mutation during navigation** - Order can change as more messages load

## User Value

- **Reliable navigation**: Clicking timeline months consistently shows correct messages
- **No visual glitches**: Smooth scrolling without jumps or ordering errors
- **Predictable behavior**: Same action always produces same result
- **Better performance**: Scroll calculations work correctly even with large message histories
- **Foundation for future features**: Enables virtual scrolling, search result highlighting, etc.

## Scope

### In Scope

#### Phase 1: Placeholder Infrastructure
- Create `MessagePlaceholder` lightweight domain object containing:
  - Message ID (required)
  - Sent date (required for temporal navigation)
  - Is from me (for display positioning)
  - Message type hint (text, image, video, link preview)
- Modify `ChatMessagesPagerProvider` to load ALL placeholders on chat selection
- Store complete ordered placeholder list in provider state
- Implement hydration mechanism to load full message data on demand

#### Phase 2: Hydration Strategy
- **Viewport-based hydration**: Load full data for messages near current scroll position
- **Temporal subset hydration**: When navigating to specific month, hydrate that temporal range
- **Progressive expansion**: Hydrate adjacent messages as user scrolls
- **Memory management**: Dehydrate messages far from viewport (keep placeholders)

#### Phase 3: Scroll Position Logic
- Calculate scroll positions from placeholder indices (not loaded message indices)
- Jump to temporal position by finding placeholder with matching sent date
- Ensure scroll position remains stable during hydration
- Handle edge cases (no messages in target month, etc.)

#### Phase 4: UI Integration
- Render placeholders as loading skeletons until hydrated
- Smooth transitions when hydration completes
- Show appropriate loading indicators
- Handle placeholder-only state gracefully

### Out of Scope (Future Enhancements)
- Virtual scrolling (render only visible items) - foundational work enables this later
- Search result highlighting within message list
- Message prefetching based on scroll velocity
- Intelligent cache eviction strategies
- Cross-chat message context (requires different architecture)

## Dependencies

### Technical Dependencies
- **Existing**: `ChatMessagesPagerProvider` (major refactor required)
- **Existing**: `ChatMessageListItem` domain object
- **New**: `MessagePlaceholder` lightweight domain object
- **Existing**: `WorkingDatabase` for both placeholder and full message queries
- **Existing**: `MessagesForChatView` widget (moderate changes required)

### Domain Dependencies
- Message aggregate (no changes needed)
- Chat aggregate (no changes needed)
- Database schema (no changes needed - only query patterns change)

## Success Criteria

- [x] **Functional**: Clicking timeline month shows messages from that month consistently
- [x] **Functional**: Message order never becomes jumbled regardless of scroll/load operations
- [x] **Functional**: Scroll position calculations work correctly for all chat sizes (10 to 100,000+ messages)
- [x] **Performance**: Initial placeholder load completes in < 100ms for 100,000 messages
- [x] **Performance**: Hydration of 50 messages (viewport) completes in < 200ms
- [x] **Performance**: Smooth scrolling with no frame drops during hydration
- [x] **Quality**: No visual glitches or jumps when navigating between time periods
- [x] **Quality**: Memory usage remains reasonable (dehydration works correctly)
- [x] **Quality**: Test coverage > 85% for new placeholder/hydration logic

## Complexity Estimate

**Rating**: High

**Justification**:
- Requires significant refactor of existing message loading system
- Complex hydration/dehydration state management
- Scroll position calculations must work during transitions
- Memory management critical for large message histories
- Multiple edge cases to handle (no messages in month, scrolling during hydration, etc.)
- Must maintain backwards compatibility with existing message display components

**Estimated Effort**: 3-5 days

## Risks & Mitigation

### Risk 1: Performance regression for large chats
**Likelihood**: Medium  
**Impact**: High  
**Mitigation Strategy**:
- Profile placeholder loading with 100K+ message chats
- Use indexed queries (`SELECT id, sent_at, is_from_me, type WHERE chat_id = ? ORDER BY id`)
- Implement pagination for placeholder loading if needed (e.g., load 50K at a time)
- Add performance monitoring to detect regressions early

### Risk 2: Memory pressure from maintaining all placeholders
**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation Strategy**:
- Keep placeholders extremely lightweight (< 100 bytes each)
- Calculate memory usage: 100K messages × 100 bytes = 10MB (acceptable)
- Implement dehydration for messages outside viewport buffer
- Monitor memory usage in development builds

### Risk 3: Scroll position miscalculation during hydration
**Likelihood**: High  
**Impact**: High  
**Mitigation Strategy**:
- Lock scroll position during hydration using Flutter's `keepScrollOffset: true`
- Calculate positions from placeholder indices before hydration starts
- Use `LayoutBuilder` and `CustomScrollView` for precise control
- Extensive testing of edge cases (scrolling during hydration, rapid timeline clicks, etc.)

### Risk 4: Breaking existing message display functionality
**Likelihood**: Medium  
**Impact**: High  
**Mitigation Strategy**:
- Maintain `ChatMessageListItem` as-is for display logic
- Create `HydratedMessage` wrapper that holds either placeholder or full data
- Gradual migration: implement placeholder loading first, test, then add hydration
- Comprehensive widget tests for all message types (text, image, video, link preview)

### Risk 5: Complexity in handling rapid navigation
**Likelihood**: High  
**Impact**: Medium  
**Mitigation Strategy**:
- Debounce timeline clicks (250ms delay)
- Cancel in-flight hydration requests when new navigation occurs
- Use cancellation tokens or `ref.onDispose` cleanup
- Clear visual feedback when hydration is in progress

## Architecture Impact

### Affected Components
- `ChatMessagesPagerProvider` - Complete refactor to placeholder-based loading
- `MessagesForChatView` - Moderate changes to handle placeholders/hydration
- `MessagesPagerState` - Add placeholder list and hydration status
- Message list item builders - Minor changes to render loading states

### New Components Required
1. **`MessagePlaceholder`** domain object
   ```dart
   class MessagePlaceholder {
     final int id;
     final DateTime sentAt;
     final bool isFromMe;
     final MessageType type;
   }
   ```

2. **`MessageHydrationService`** application service
   - Hydrate placeholders to full messages
   - Manage hydration queue
   - Handle dehydration for memory management

3. **`HydratedMessage`** wrapper
   ```dart
   sealed class HydratedMessage {
     const HydratedMessage.placeholder(MessagePlaceholder);
     const HydratedMessage.loaded(ChatMessageListItem);
   }
   ```

4. **`PlaceholderListItem`** widget
   - Renders loading skeleton for unhydrated messages
   - Matches message type (text bubble, image card, etc.)

### Database Changes
**None required** - Only query patterns change:
- **Placeholder query**: `SELECT id, sent_at_utc, is_from_me, type FROM messages WHERE chat_id = ? ORDER BY id`
- **Hydration query**: `SELECT * FROM messages WHERE id IN (?, ?, ...) ORDER BY id`

### Database Query Patterns

#### Current Pattern (Problematic)
```sql
-- Load latest page
SELECT * FROM messages 
WHERE chat_id = ? 
ORDER BY id DESC 
LIMIT 300;

-- Load older page
SELECT * FROM messages 
WHERE chat_id = ? AND id < ?
ORDER BY id DESC 
LIMIT 300;
```
**Problems**: 
- No guarantee of consistent ordering across pages
- Scroll position based on partial data
- Can load overlapping or out-of-order ranges

#### New Pattern (Stable)
```sql
-- On chat selection: Load ALL placeholders
SELECT id, sent_at_utc, is_from_me, type, has_attachments
FROM messages 
WHERE chat_id = ? 
ORDER BY id ASC;

-- Hydrate viewport range (by index)
SELECT * FROM messages
WHERE chat_id = ? 
  AND id >= ? 
  AND id <= ?
ORDER BY id ASC;

-- Hydrate temporal range (for timeline navigation)
SELECT * FROM messages
WHERE chat_id = ?
  AND strftime('%Y-%m', sent_at_utc) = '2023-05'
ORDER BY id ASC;
```
**Benefits**:
- Single authoritative ordering (by message ID)
- Scroll position calculated from fixed placeholder indices
- Hydration loads exact ranges without ordering concerns

## UI/UX Considerations

### Loading States
- **Initial load**: Show header with "Loading messages..." and spinner
- **Timeline navigation**: Show skeleton placeholders for target month range
- **Scrolling**: Progressive skeleton replacement as messages hydrate
- **Rapid clicks**: Debounce and show "Navigating to [Month Year]..." banner

### Accessibility
- Screen readers announce "Loading message X of Y" for placeholders
- Skip navigation works correctly with placeholder list
- Keyboard navigation remains functional during hydration

### Platform Considerations (macOS)
- Use native macOS scrolling physics
- Maintain smooth scrollbar behavior during hydration
- Handle trackpad inertia correctly with placeholder-based scrolling

## Testing Strategy

### Unit Tests
- Placeholder loading from database (various chat sizes)
- Hydration service logic (queue management, cancellation)
- Scroll position calculations from placeholder indices
- Dehydration logic (memory management)
- Edge cases (empty chats, single message, no messages in target month)

### Integration Tests
- Full placeholder → hydration → display flow
- Timeline navigation to various months
- Scrolling during hydration
- Rapid timeline clicks (cancellation and debouncing)
- Memory usage with large chats (100K+ messages)

### Widget Tests
- Placeholder rendering (all message types)
- Smooth transitions when hydration completes
- Loading indicators appear/disappear correctly
- Scroll position remains stable during hydration

### Performance Tests
- Placeholder loading time for 100K messages
- Hydration time for 50-message viewport
- Memory usage over time with scrolling
- Frame rate during rapid scrolling

### Manual Testing Scenarios
1. **Basic timeline navigation**: Click various months, verify correct messages appear
2. **Order stability**: Scroll through entire chat, verify chronological order never breaks
3. **Rapid navigation**: Click timeline months quickly, verify no crashes or glitches
4. **Edge cases**: Test empty months, chat boundaries, very old/new messages
5. **Performance**: Test with largest available chat, verify smooth scrolling

## Implementation Plan

### Phase 1: Placeholder Infrastructure (Day 1)
1. Create `MessagePlaceholder` domain object
2. Add placeholder loading query to database layer
3. Modify `MessagesPagerState` to include placeholder list
4. Update `ChatMessagesPagerProvider.build()` to load placeholders
5. Test placeholder loading with various chat sizes

### Phase 2: Hydration Service (Day 2)
1. Create `MessageHydrationService` application service
2. Implement hydration queue and cancellation logic
3. Add hydration queries to database layer
4. Wire service into provider
5. Test hydration in isolation

### Phase 3: Provider Integration (Day 2-3)
1. Create `HydratedMessage` sealed class
2. Update provider state to track hydrated vs placeholder messages
3. Implement viewport-based hydration trigger
4. Implement temporal-range hydration for timeline navigation
5. Add dehydration logic for memory management
6. Test full provider behavior

### Phase 4: UI Updates (Day 3-4)
1. Create `PlaceholderListItem` widget for each message type
2. Update `MessagesForChatView` to render `HydratedMessage` variants
3. Implement loading state transitions
4. Update scroll position calculations to use placeholder indices
5. Test UI with various hydration states

### Phase 5: Timeline Integration (Day 4)
1. Update timeline month click handler to trigger temporal hydration
2. Implement scroll-to-month logic using placeholder indices
3. Add debouncing for rapid timeline clicks
4. Test timeline navigation thoroughly
5. Fix any ordering or positioning issues

### Phase 6: Polish & Testing (Day 5)
1. Add comprehensive unit tests
2. Add integration tests
3. Add widget tests
4. Performance profiling and optimization
5. Edge case testing and fixes
6. Documentation updates

## Documentation Requirements

### User-Facing Documentation
- None required (internal architectural improvement)

### API Documentation
- Document `MessagePlaceholder` domain object
- Document `MessageHydrationService` public API
- Document `HydratedMessage` sealed class usage

### Architecture Documentation
- Update `05-databases/README.md` with new query patterns
- Create `10-features/messages/message-list-architecture.md` explaining placeholder system
- Document hydration/dehydration strategy and memory management
- Add diagrams showing placeholder → hydration flow

### Migration Guide
- Document changes to `ChatMessagesPagerProvider` API
- Note any breaking changes to message list consumers
- Provide migration examples for any affected code

## Future Enhancements

Ideas for future iterations (out of scope for v1):

### Virtual Scrolling
- Render only visible messages (+ buffer)
- Reuse widgets for offscreen items
- Requires placeholder foundation (this proposal)

### Intelligent Prefetching
- Predict scroll direction
- Prefetch adjacent message ranges
- Adaptive buffer size based on scroll velocity

### Search Result Context
- Highlight search term in message list
- Show surrounding messages for context
- Jump to search results with stable scrolling

### Cross-Chat Context
- Show messages from same participant across chats
- Temporal correlation (all messages on specific date)
- Requires different architectural approach

### Advanced Memory Management
- LRU cache for hydrated messages
- Compress dehydrated message data
- Disk-based cache for very large chats

## Approval

- [ ] User/stakeholder approved
- [ ] Technical review complete
- [ ] Performance impact assessed
- [ ] Memory usage validated
- [ ] Ready to proceed to planning

---

## Notes

**Key Insight**: This is fundamentally an **index stability problem**. Current system has no stable indices because message order emerges from load operations. Solution: establish stable indices upfront (placeholder list), then hydrate on demand.

**Design Philosophy**: Separate **ordering concerns** (stable, upfront) from **data concerns** (lazy, on-demand). This is the same pattern used by virtual scrolling libraries and large data grid implementations.

**Alternative Considered**: Keep current paging system but add order validation. **Rejected** because it treats symptoms, not root cause. Placeholder approach is cleaner, more maintainable, and enables future features.
