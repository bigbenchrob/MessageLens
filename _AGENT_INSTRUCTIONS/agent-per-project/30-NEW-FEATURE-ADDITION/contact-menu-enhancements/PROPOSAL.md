---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2025-11-08
source_of_truth: doc
status: awaiting_approval
links:
  - ../README.md
  - ../../40-FEATURES/README.md
  - ../../60-NAVIGATION/navigation-overview.md
  - ../../../agent-instructions-shared/00-global/riverpod-rules.md
tests: []
---

# Feature Proposal: Contact Menu Enhancements

## Executive Summary

The Contacts sidebar currently uses a single flat dropdown menu (`MacosPopupButton`) containing all contacts. As the contact list grows into hundreds of entries, this becomes unwieldy and difficult to navigate. This proposal introduces scalable enhancements to make the contact selection experience manageable and efficient for users with large contact lists, while maintaining macOS design conventions and requiring zero keyboard interaction.

## Problem Statement

### Current State

- **Location**: Left sidebar → "Contact:" dropdown (`MacosPopupButton`)
- **Behavior**: Single flat list of all contacts
- **Flow**: User selects contact → sidebar shows chats for that contact → user clicks chat → center panel shows messages
- **Issue**: With 100+ contacts, finding a specific contact in a single dropdown becomes tedious

### User Pain Points

1. **Scrolling fatigue**: Users must scroll through potentially hundreds of entries
2. **No visual grouping**: No organization to help users orient themselves
3. **No quick access**: Frequently contacted people are buried in the full list
4. **Mouse-only inefficiency**: Current design requires excessive scrolling even for mouse users

## Proposed Solution

Implement a **progressive disclosure** system with four complementary enhancements that work together:

### 1. **Favorites Section** (Highest Impact)

- Add a "Favorites / Pinned" section at the **top of the sidebar** (above the contact selector)
- Display 5-10 most frequently contacted people as clickable cards/buttons
- Allow users to pin/unpin contacts via context menu or star icon
- **Benefit**: 80% of interactions handled with a single click on familiar contacts

### 2. **Alphabetical Grouping with Collapsible Sections**

- Replace flat dropdown with grouped structure: A, B, C... sections
- Each section header shows count badge: "B (23)"
- Sections collapsible/expandable for progressive disclosure
- Currently open section remains sticky during scroll
- **Benefit**: Reduces cognitive load, provides clear landmarks for navigation

### 3. **Vertical A-Z Jump Bar** (iOS Contacts Style)

- Add slim vertical strip on right edge of contact selector area
- Shows: A, B, C... Z, plus "★" for favorites and "#" for non-alpha
- Click letter → scroll/jump to that section
- Optional: Support click-and-drag down the bar
- **Benefit**: Two-click access to any contact (jump + select)

### 4. **Optional Search Field** (Power Feature)

- Search box above contact list (existing TODO in code)
- As-you-type filtering with result count badge
- Treat as **optional enhancement**, not required workflow
- **Benefit**: Keyboard users get fast access, but not mandatory

### 5. **Smart Groups** (Future Enhancement - Not in Initial Scope)

- "Recent" contacts based on app usage
- "Top Chats" by message volume or recent activity
- System groups ("Family", "Work") if meaningful
- **Deferred**: Mentioned for completeness, not included in initial implementation

## Architecture Impact

### Navigation System

**No changes required** - Current `ViewSpec.sidebar(SidebarSpec.contacts(...))` pattern remains intact:

```dart
ViewSpec.sidebar(
  SidebarSpec.contacts(
    listMode: ContactsListSpec.alphabetical(), // Existing spec works
    selectedParticipantId: participantId,
    chatViewMode: chatViewMode,
  ),
)
```

### Data Layer

#### New Domain Entities

**File**: `lib/features/contacts/domain/entities/favorite_contact.dart`

```dart
@freezed
abstract class FavoriteContact with _$FavoriteContact {
  const factory FavoriteContact({
    required int participantId,
    required String displayName,
    required int sortOrder, // User-defined ordering
    DateTime? lastInteractionDate,
  }) = _FavoriteContact;
}
```

#### Database Changes (Overlay DB)

**File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`

**New Table**: `favorite_contacts`

```sql
CREATE TABLE favorite_contacts (
  participant_id INTEGER PRIMARY KEY,
  sort_order INTEGER NOT NULL DEFAULT 0,
  pinned_at_utc TEXT NOT NULL,
  FOREIGN KEY (participant_id) REFERENCES working_participants(id)
);
```

**Rationale**: Favorites are user preferences, belong in `db-overlay` per architectural rules

#### Enhanced Providers

**File**: `lib/features/contacts/application/contacts_list_provider.dart`

**New Functions**:

- `favoriteContactsProvider` - Returns pinned contacts in sort order
- `groupedContactsProvider` - Returns `Map<String, List<ContactSummary>>` grouped by first letter
- `contactsByLetterCountProvider` - Returns letter → count for jump bar badges

**Existing `ContactsListSpec`** already supports filtering modes, no changes needed:

```dart
ContactsListSpec.all()          // Currently shows all
ContactsListSpec.alphabetical() // Currently shows alphabetical
ContactsListSpec.favorites()    // Currently stubbed (TODO in code)
```

### Presentation Layer

#### Modified Views

**File**: `lib/features/contacts/presentation/view/contacts_sidebar_view.dart`

**Changes**:

1. Add favorites section above contact selector (lines 90-120, approximate)
2. Replace flat `MacosPopupButton` with grouped/collapsible structure
3. Add A-Z jump bar component to right side
4. Integrate search field (already has TODO comment at line 104)

**UI Structure** (revised):

```dart
Column(
  children: [
    FavoritesSection(),              // NEW: Pinned contacts
    ContactSelectorHeader(),         // Existing "Contact:" label
    GroupedContactSelector(),        // ENHANCED: Replaces MacosPopupButton
    AlphabeticalJumpBar(),           // NEW: A-Z quick navigation
    SearchField(),                   // NEW: Optional search
    ContactModeRadioButtons(),       // Existing: All/A-Z/Favorites
    Expanded(child: ChatsList()),    // Existing: Chats for selected contact
  ],
)
```

#### New Widgets

**File**: `lib/features/contacts/presentation/widgets/favorites_section.dart`

- Horizontal scrollable row of pinned contact cards
- Context menu: "Unpin contact"
- Click behavior: Same as selecting from dropdown

**File**: `lib/features/contacts/presentation/widgets/grouped_contact_selector.dart`

- Collapsible sections by letter
- Section headers with counts
- Sticky header behavior during scroll

**File**: `lib/features/contacts/presentation/widgets/alphabet_jump_bar.dart`

- Vertical strip showing A-Z + special characters
- Hover/click interactions
- Visual feedback for current section

**File**: `lib/features/contacts/presentation/widgets/contact_search_field.dart`

- macOS-styled search field
- As-you-type filtering
- Clear button

### State Management

#### New Providers

**File**: `lib/features/contacts/application/favorite_contacts_provider.dart`

```dart
@riverpod
Future<List<FavoriteContact>> favoriteContacts(Ref ref) async {
  // Query overlay DB for favorite_contacts table
  // Join with working_participants for display names
  // Order by sort_order
}

@riverpod
class FavoriteContactsController extends _$FavoriteContactsController {
  @override
  void build() {}

  Future<void> pinContact(int participantId) async { /* ... */ }
  Future<void> unpinContact(int participantId) async { /* ... */ }
  Future<void> reorderFavorites(List<int> participantIds) async { /* ... */ }
}
```

**File**: `lib/features/contacts/application/grouped_contacts_provider.dart`

```dart
@riverpod
Future<Map<String, List<ContactSummary>>> groupedContacts(Ref ref) async {
  final allContacts = await ref.watch(
    contactsListProvider(spec: const ContactsListSpec.alphabetical()),
  );

  // Group by first letter of displayName
  // Return Map<"A", List<ContactSummary>>
}

@riverpod
Future<Map<String, int>> contactLetterCounts(Ref ref) async {
  final grouped = await ref.watch(groupedContactsProvider.future);
  return grouped.map((letter, contacts) => MapEntry(letter, contacts.length));
}
```

**File**: `lib/features/contacts/application/contact_search_provider.dart`

```dart
@riverpod
class ContactSearch extends _$ContactSearch {
  @override
  String build() => ''; // Current search query

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
Future<List<ContactSummary>> filteredContacts(Ref ref) async {
  final query = ref.watch(contactSearchProvider).toLowerCase();
  if (query.isEmpty) {
    return ref.watch(
      contactsListProvider(spec: const ContactsListSpec.all()),
    );
  }

  final allContacts = await ref.watch(
    contactsListProvider(spec: const ContactsListSpec.all()).future,
  );

  return allContacts
      .where((c) => c.displayName.toLowerCase().contains(query))
      .toList();
}
```

## User Interaction Flows

### Flow 1: Access Favorite Contact (Most Common)

1. User opens Contacts sidebar
2. User sees favorites section at top
3. User clicks favorite contact card
4. Sidebar shows chats for that contact
5. User clicks chat → messages appear in center panel

**Mouse clicks**: 2 (favorite card + chat)

### Flow 2: Access Non-Favorite via Jump Bar

1. User opens Contacts sidebar
2. User clicks letter "S" in jump bar
3. Contact selector scrolls/jumps to S-section
4. User clicks contact name
5. Sidebar shows chats for that contact
6. User clicks chat → messages appear in center panel

**Mouse clicks**: 3 (jump + contact + chat)

### Flow 3: Access via Search (Power Users)

1. User opens Contacts sidebar
2. User clicks search field
3. User types "Rob" (keyboard)
4. Results filter to matching contacts
5. User clicks contact
6. Sidebar shows chats for that contact
7. User clicks chat → messages appear in center panel

**Mouse clicks**: 2-3 (search field + contact + chat)  
**Keyboard**: Optional, not required

### Flow 4: Pin/Unpin Favorite

1. User finds contact via any method
2. User right-clicks contact (or clicks star icon)
3. Context menu shows "Pin to Favorites" / "Unpin from Favorites"
4. User clicks menu item
5. Favorites section updates immediately

**Mouse clicks**: 2 (right-click + menu item)

## UI/UX Considerations

### Visual Design

- **macOS Native**: Use `macos_ui` components exclusively
- **Consistency**: Match existing sidebar styling (dividers, colors, spacing)
- **Hierarchy**: Favorites visually distinct but not overwhelming
- **Feedback**: Hover states, selection highlighting, smooth animations

### Accessibility

- **Keyboard Navigation**: All features accessible via Tab/Arrow keys
- **VoiceOver**: Proper labels for all interactive elements
- **Color Contrast**: Meets WCAG AA standards
- **Focus Indicators**: Clear visual feedback

### Performance

- **Large Lists**: Grouped sections only render visible items
- **Search**: Debounce search input (300ms)
- **Favorites**: Cache in provider, invalidate on changes only
- **Jump Bar**: O(1) lookup to target sections

## Migration Strategy

### Phase 1: Foundation (Days 1-2)

- ✅ Create overlay database migration for `favorite_contacts` table
- ✅ Implement `FavoriteContact` domain entity
- ✅ Create `favoriteContactsProvider` and controller
- ✅ Write unit tests for favorite contact logic

### Phase 2: Grouped Display (Days 3-4)

- ✅ Create `groupedContactsProvider`
- ✅ Build `GroupedContactSelector` widget
- ✅ Implement collapsible sections with sticky headers
- ✅ Test with 100+ contacts for performance

### Phase 3: Jump Bar (Day 5)

- ✅ Create `AlphabetJumpBar` widget
- ✅ Wire up scroll/jump behavior
- ✅ Add visual feedback (hover, active section highlighting)

### Phase 4: Favorites UI (Days 6-7)

- ✅ Build `FavoritesSection` widget
- ✅ Implement pin/unpin context menu
- ✅ Add drag-to-reorder (optional, time permitting)
- ✅ Integrate with `ContactsSidebarView`

### Phase 5: Search (Day 8)

- ✅ Create `ContactSearchField` widget
- ✅ Implement `contactSearchProvider`
- ✅ Wire up filtering behavior
- ✅ Add clear button and result counts

### Phase 6: Integration & Polish (Days 9-10)

- ✅ Refactor `ContactsSidebarView` to use all new components
- ✅ End-to-end testing with real data
- ✅ Animation polish and performance tuning
- ✅ Documentation updates

## Testing Strategy

### Unit Tests

- `favorite_contacts_provider_test.dart` - Pin/unpin/reorder logic
- `grouped_contacts_provider_test.dart` - Grouping algorithm, edge cases
- `contact_search_provider_test.dart` - Search filtering, empty states

### Widget Tests

- `favorites_section_test.dart` - Rendering, click behavior
- `grouped_contact_selector_test.dart` - Expand/collapse, selection
- `alphabet_jump_bar_test.dart` - Jump behavior, visual states
- `contact_search_field_test.dart` - Input handling, clear button

### Integration Tests

- End-to-end flow: Pin favorite → select via favorites → view chats
- Search → select contact → view messages
- Jump bar → select contact → verify correct section

### Manual Verification

- Test with 10, 50, 100, 500+ contacts
- Verify performance (smooth scrolling, no jank)
- Test on different screen sizes
- Verify keyboard navigation throughout

## Decisions (Approved 2025-11-08)

1. **Favorites Limit**: ✅ **Yes, enforce 10 maximum.** Display warning when limit reached.

2. **Favorites Ordering**: ✅ **Auto by frequency** (most recently interacted first). Drag-to-reorder deferred.

3. **Search Scope**: ✅ **Display names only**. Phone/email search deferred to future enhancement.

4. **Favorites Sync**: ✅ **Defer until multi-device support is on roadmap.** Local-only for now.

5. **Jump Bar Position**: ✅ **Fixed position flush with top of sidebar**, runs down right edge. Permanently visible in Contacts mode (hidden in Unmatched Handles mode deferred).

6. **Empty States**: ✅ **Approved**:

   - No favorites: "No pinned contacts. Right-click any contact to pin."
   - No search results: "No contacts found for '[query]'"
   - Empty section: Auto-collapse, don't show in jump bar

7. **Favorites Persistence**: ✅ **Yes, store in `db-overlay`** (persistent user preferences).

## Success Metrics

### Quantitative

- Users with 100+ contacts can find any contact in ≤3 clicks
- Search returns results in <300ms for 500+ contacts
- Favorites section reduces clicks for frequent contacts by 50%
- Zero performance degradation with 1000+ contacts

### Qualitative

- Users report "much easier to find contacts" in feedback
- No user confusion about new UI elements
- Positive sentiment on progressive disclosure approach

## Non-Goals (Out of Scope)

- ❌ **Smart Groups** (Recents, Top Chats) - Future enhancement
- ❌ **Contact Editing** - Separate feature, beyond scope
- ❌ **Multi-select Contacts** - Not needed for current workflows
- ❌ **Contact Categories/Tags** - Adds complexity, defer
- ❌ **Keyboard Shortcuts** - Optional, not required for success
- ❌ **Animated Transitions** - Nice-to-have, not critical

## Dependencies

### External

- None - All components use existing `macos_ui` package

### Internal

- ✅ `overlay_database.dart` - Schema migration for favorites table
- ✅ `contacts_list_provider.dart` - Data source for all contacts
- ✅ ViewSpec navigation system - Already in place, no changes

### Blocked By

- None - Feature is self-contained

## Risks & Mitigations

### Risk 1: Performance with Large Lists

**Impact**: High  
**Probability**: Medium  
**Mitigation**:

- Use lazy loading for grouped sections
- Only render visible items
- Cache grouped data in provider
- Profile with 1000+ contacts before release

### Risk 2: UI Complexity

**Impact**: Medium  
**Probability**: Low  
**Mitigation**:

- Progressive disclosure - show complexity only when needed
- Follow macOS design patterns
- User testing with 3-5 users before final release

### Risk 3: Favorites Not Adopted

**Impact**: Medium  
**Probability**: Low  
**Mitigation**:

- Auto-suggest pinning frequently used contacts (tooltip)
- Show benefits in first-run experience
- Make pin/unpin discoverable (context menu + star icon)

### Risk 4: Database Migration Issues

**Impact**: High  
**Probability**: Low  
**Mitigation**:

- Follow established overlay DB migration patterns
- Test migration with existing user data
- Add rollback capability if needed

## Alternatives Considered

### Alternative 1: Single Enhanced Dropdown

**Description**: Keep single dropdown, add search within it  
**Pros**: Minimal code changes  
**Cons**: Doesn't solve scrolling fatigue, no visual hierarchy  
**Decision**: ❌ Rejected - Doesn't address core problem

### Alternative 2: Tabs (Favorites / A-Z / Search)

**Description**: Separate tabs for different access methods  
**Pros**: Clear separation of concerns  
**Cons**: Extra clicks to switch tabs, hides functionality  
**Decision**: ❌ Rejected - Progressive disclosure is better

### Alternative 3: Two-Column Layout

**Description**: Favorites on left, alphabetical on right  
**Pros**: Both visible simultaneously  
**Cons**: Takes up precious sidebar space  
**Decision**: ❌ Rejected - Sidebar already cramped

### Alternative 4: Popover Picker (iOS Style)

**Description**: Full-screen overlay picker with search  
**Pros**: Lots of space for features  
**Cons**: Not macOS convention, disrupts workflow  
**Decision**: ❌ Rejected - Wrong platform paradigm

## Timeline Estimate

**Total**: 10 working days (2 weeks)

- **Phase 1** (Foundation): 2 days
- **Phase 2** (Grouped Display): 2 days
- **Phase 3** (Jump Bar): 1 day
- **Phase 4** (Favorites UI): 2 days
- **Phase 5** (Search): 1 day
- **Phase 6** (Integration & Polish): 2 days

**Buffer**: Add 20% (2 days) for unexpected issues  
**Final Estimate**: 12 working days (~2.5 weeks)

## Approval Checklist

- [x] User confirms problem statement resonates
- [x] Proposed solution aligns with user workflow
- [x] Timeline is acceptable
- [x] Open questions resolved
- [x] Risk mitigations are satisfactory
- [x] Ready to proceed to CHECKLIST.md

**Status**: ✅ **APPROVED** (2025-11-08)

---

**Next Steps**: Create `CHECKLIST.md` with detailed task breakdown and begin Phase 1 implementation.
