---
tier: project
scope: feature-checklist
owner: agent-per-project
last_reviewed: 2025-11-08
source_of_truth: doc
status: in_progress
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
---

# Development Checklist: Contact Menu Enhancements

**Status**: 🟡 In Progress  
**Started**: 2025-11-08  
**Target Completion**: 2025-11-22 (2.5 weeks)

## Phase 1: Foundation - Database & Domain Layer (Days 1-2)

### 1.1 Overlay Database Schema ⬜

- [ ] **Task**: Create migration for `favorite_contacts` table

  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**:
    ```dart
    @DataClassName('FavoriteContactRow')
    class FavoriteContacts extends Table {
      IntColumn get participantId => integer().customConstraint('PRIMARY KEY')();
      IntColumn get sortOrder => integer().withDefault(const Constant(0))();
      TextColumn get pinnedAtUtc => text()();
      DateTimeColumn get lastInteractionUtc => dateTime().nullable()();
    }
    ```
  - **Migration**: Add to next migration number
  - **Verification**: Run `dart run build_runner build` successfully

- [ ] **Task**: Create database index for sort_order

  - **File**: Same as above
  - **Details**: `CREATE INDEX idx_favorite_contacts_sort_order ON favorite_contacts(sort_order);`
  - **Rationale**: Fast retrieval of ordered favorites

- [ ] **Task**: Add helper queries to OverlayDatabase
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Methods**:
    - `getAllFavorites()` - Returns all favorites ordered by sort_order
    - `addFavorite(participantId, lastInteractionUtc)` - Inserts with auto sort_order
    - `removeFavorite(participantId)` - Deletes favorite
    - `updateLastInteraction(participantId, dateTime)` - Updates interaction timestamp
    - `reorderFavorites(List<participantId>)` - Bulk update sort_order
  - **Status**: ⬜ Not started

### 1.2 Domain Entities ⬜

- [ ] **Task**: Create `FavoriteContact` entity

  - **File**: `lib/features/contacts/domain/entities/favorite_contact.dart`
  - **Details**:
    ```dart
    @freezed
    abstract class FavoriteContact with _$FavoriteContact {
      const factory FavoriteContact({
        required int participantId,
        required String displayName,
        required String shortName,
        required int sortOrder,
        required DateTime pinnedAtUtc,
        DateTime? lastInteractionUtc,
        required int messageCount,
        required int chatCount,
      }) = _FavoriteContact;
    }
    ```
  - **Freezed**: Run code generation after creating
  - **Status**: ⬜ Not started

- [ ] **Task**: Create `GroupedContacts` value object
  - **File**: `lib/features/contacts/domain/entities/grouped_contacts.dart`
  - **Details**:
    ```dart
    @freezed
    abstract class GroupedContacts with _$GroupedContacts {
      const factory GroupedContacts({
        required Map<String, List<ContactSummary>> groups,
        required Map<String, int> letterCounts,
        required List<String> availableLetters,
      }) = _GroupedContacts;
    }
    ```
  - **Status**: ⬜ Not started

### 1.3 Unit Tests - Domain ⬜

- [ ] **Task**: Test `FavoriteContact` entity

  - **File**: `test/features/contacts/domain/entities/favorite_contact_test.dart`
  - **Cases**: Freezed equality, copyWith, serialization
  - **Status**: ⬜ Not started

- [ ] **Task**: Test database queries
  - **File**: `test/essentials/db/infrastructure/overlay/favorite_contacts_queries_test.dart`
  - **Cases**: Add, remove, reorder, query all favorites
  - **Status**: ⬜ Not started

---

## Phase 2: Application Layer - Providers (Days 3-4)

### 2.1 Favorite Contacts Provider ⬜

- [ ] **Task**: Create `favoriteContactsProvider`

  - **File**: `lib/features/contacts/application/favorite_contacts_provider.dart`
  - **Details**:
    ```dart
    @riverpod
    Future<List<FavoriteContact>> favoriteContacts(Ref ref) async {
      final overlayDb = await ref.watch(overlayDatabaseProvider.future);
      final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

      // 1. Query favorite_contacts table (ordered by lastInteractionUtc DESC)
      // 2. Join with working_participants for display names
      // 3. Calculate message/chat counts per participant
      // 4. Return max 10 favorites
    }
    ```
  - **Status**: ⬜ Not started

- [ ] **Task**: Create `FavoriteContactsController`
  - **File**: Same as above
  - **Details**:
    ```dart
    @riverpod
    class FavoriteContactsController extends _$FavoriteContactsController {
      @override
      void build() {}

      Future<void> pinContact(int participantId) async {
        // Check count < 10, throw if at limit
        // Insert with current timestamp as lastInteractionUtc
        // Invalidate favoriteContactsProvider
      }

      Future<void> unpinContact(int participantId) async {
        // Remove from favorite_contacts
        // Invalidate favoriteContactsProvider
      }

      Future<void> updateLastInteraction(int participantId) async {
        // Update lastInteractionUtc to DateTime.now()
        // Invalidate favoriteContactsProvider (triggers re-sort)
      }
    }
    ```
  - **Status**: ⬜ Not started

### 2.2 Grouped Contacts Provider ⬜

- [ ] **Task**: Create `groupedContactsProvider`
  - **File**: `lib/features/contacts/application/grouped_contacts_provider.dart`
  - **Details**:
    ```dart
    @riverpod
    Future<GroupedContacts> groupedContacts(Ref ref) async {
      final allContacts = await ref.watch(
        contactsListProvider(spec: const ContactsListSpec.alphabetical()).future,
      );

      // 1. Group by first letter (uppercase)
      // 2. Calculate counts per letter
      // 3. Extract available letters (A-Z, #)
      // 4. Return GroupedContacts value object
    }
    ```
  - **Grouping Logic**:
    - A-Z for letters
    - "#" for numbers/special characters
    - "★" reserved for favorites (not in grouped list)
  - **Status**: ⬜ Not started

### 2.3 Contact Search Provider ⬜

- [ ] **Task**: Create `contactSearchProvider`

  - **File**: `lib/features/contacts/application/contact_search_provider.dart`
  - **Details**:
    ```dart
    @riverpod
    class ContactSearch extends _$ContactSearch {
      @override
      String build() => ''; // Current search query

      void updateQuery(String query) {
        state = query.trim();
      }

      void clearQuery() {
        state = '';
      }
    }
    ```
  - **Status**: ⬜ Not started

- [ ] **Task**: Create `filteredContactsProvider`
  - **File**: Same as above
  - **Details**:
    ```dart
    @riverpod
    Future<List<ContactSummary>> filteredContacts(Ref ref) async {
      final query = ref.watch(contactSearchProvider).toLowerCase();

      if (query.isEmpty) {
        return ref.watch(
          contactsListProvider(spec: const ContactsListSpec.all()).future,
        );
      }

      final allContacts = await ref.watch(
        contactsListProvider(spec: const ContactsListSpec.all()).future,
      );

      return allContacts
          .where((c) =>
            c.displayName.toLowerCase().contains(query) ||
            c.shortName.toLowerCase().contains(query)
          )
          .toList();
    }
    ```
  - **Status**: ⬜ Not started

### 2.4 Unit Tests - Providers ⬜

- [ ] **Task**: Test `favoriteContactsProvider`

  - **File**: `test/features/contacts/application/favorite_contacts_provider_test.dart`
  - **Cases**:
    - Returns favorites ordered by lastInteractionUtc
    - Limits to 10 items
    - Handles empty state
    - Invalidates on controller actions
  - **Status**: ⬜ Not started

- [ ] **Task**: Test `FavoriteContactsController`

  - **File**: Same as above
  - **Cases**:
    - Pin contact (happy path)
    - Pin contact (at limit, throws error)
    - Unpin contact
    - Update last interaction (re-sorts)
  - **Status**: ⬜ Not started

- [ ] **Task**: Test `groupedContactsProvider`

  - **File**: `test/features/contacts/application/grouped_contacts_provider_test.dart`
  - **Cases**:
    - Groups A-Z correctly
    - Handles special characters → "#"
    - Empty groups not included
    - Letter counts accurate
  - **Status**: ⬜ Not started

- [ ] **Task**: Test `filteredContactsProvider`
  - **File**: `test/features/contacts/application/contact_search_provider_test.dart`
  - **Cases**:
    - Empty query → all contacts
    - Case-insensitive matching
    - Matches display name
    - Matches short name
    - No matches → empty list
  - **Status**: ⬜ Not started

---

## Phase 3: Presentation - New Widgets (Days 5-7)

### 3.1 Favorites Section Widget ⬜

- [ ] **Task**: Create `FavoritesSection` widget

  - **File**: `lib/features/contacts/presentation/widgets/favorites_section.dart`
  - **Details**:
    - Horizontal scrollable row of pinned contacts
    - Each favorite: rounded card with avatar + name
    - Click → select that contact (same as dropdown selection)
    - Context menu on right-click: "Unpin from Favorites"
    - Empty state: Helper text "No pinned contacts..."
  - **Styling**:
    - Card height: 60px
    - Card width: 80px
    - Gap between cards: 8px
    - Use MacosColors for consistency
  - **Status**: ⬜ Not started

- [ ] **Task**: Add context menu to favorite cards
  - **Details**:
    ```dart
    GestureDetector(
      onSecondaryTapDown: (details) async {
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(...),
          items: [
            PopupMenuItem(
              value: 'unpin',
              child: Row(
                children: [
                  Icon(CupertinoIcons.star_slash),
                  SizedBox(width: 8),
                  Text('Unpin from Favorites'),
                ],
              ),
            ),
          ],
        );

        if (selected == 'unpin') {
          await ref.read(favoriteContactsControllerProvider.notifier)
              .unpinContact(participantId);
        }
      },
      child: FavoriteContactCard(...),
    )
    ```
  - **Status**: ⬜ Not started

### 3.2 Grouped Contact Selector Widget ⬜

- [ ] **Task**: Create `GroupedContactSelector` widget

  - **File**: `lib/features/contacts/presentation/widgets/grouped_contact_selector.dart`
  - **Details**:
    - Replaces flat `MacosPopupButton`
    - Shows collapsible sections by letter
    - Section header: Letter + count badge (e.g., "B (23)")
    - Click header → expand/collapse section
    - Click contact → select that contact
    - Currently selected contact highlighted
  - **State Management**:
    - Track expanded/collapsed per section (local state)
    - Remember last expanded section (sticky)
  - **Status**: ⬜ Not started

- [ ] **Task**: Implement sticky header behavior

  - **Details**:
    - Use `CustomScrollView` with `SliverPersistentHeader`
    - Currently expanded section header stays visible during scroll
    - OR: Simpler approach with elevated header style for active section
  - **Status**: ⬜ Not started

- [ ] **Task**: Add expand/collapse animations
  - **Details**:
    - Smooth height animation (200ms)
    - Rotate caret icon (0° → 90°)
    - Use `AnimatedContainer` or `AnimatedSize`
  - **Status**: ⬜ Not started

### 3.3 Alphabet Jump Bar Widget ⬜

- [ ] **Task**: Create `AlphabetJumpBar` widget

  - **File**: `lib/features/contacts/presentation/widgets/alphabet_jump_bar.dart`
  - **Details**:
    - Fixed position on right edge of sidebar
    - Flush with top of sidebar
    - Vertical column of letter buttons: A-Z, ★, #
    - Each letter: 20x20 touch target
    - Click letter → scroll grouped selector to that section
    - Hover → show tooltip with letter + count
  - **Styling**:
    - Width: 24px
    - Letter size: 10px
    - Active letter: highlighted (blue tint)
    - Inactive but available: gray
    - Unavailable (no contacts): very light gray, non-clickable
  - **Status**: ⬜ Not started

- [ ] **Task**: Implement scroll-to-section behavior

  - **Details**:
    - Maintain `ScrollController` in parent widget
    - Jump bar receives controller via constructor
    - Calculate target offset for each letter's section
    - Animate scroll with `animateTo(duration: 300ms, curve: easeOut)`
  - **Status**: ⬜ Not started

- [ ] **Task**: Add hover effects and feedback
  - **Details**:
    - MouseRegion for hover detection
    - Scale letter slightly on hover (1.2x)
    - Show tooltip: "M (15 contacts)"
    - Cursor: pointer on available letters
  - **Status**: ⬜ Not started

### 3.4 Contact Search Field Widget ⬜

- [ ] **Task**: Create `ContactSearchField` widget

  - **File**: `lib/features/contacts/presentation/widgets/contact_search_field.dart`
  - **Details**:
    - macOS-styled search field (MacosSearchField or custom)
    - Leading icon: magnifying glass
    - Trailing icon: clear button (X) when text present
    - Placeholder: "Search contacts..."
    - Debounce input: 300ms
  - **Integration**:
    - Watch `contactSearchProvider`
    - Call `updateQuery()` on text change
    - Call `clearQuery()` on clear button
  - **Status**: ⬜ Not started

- [ ] **Task**: Add result count badge
  - **Details**:
    - Below search field: "X contacts found"
    - Only show when query is not empty
    - Subtle styling (small gray text)
  - **Status**: ⬜ Not started

### 3.5 Widget Tests ⬜

- [ ] **Task**: Test `FavoritesSection`

  - **File**: `test/features/contacts/presentation/widgets/favorites_section_test.dart`
  - **Cases**:
    - Renders favorite cards correctly
    - Empty state shows helper text
    - Click card → callback invoked with participantId
    - Context menu shows on right-click
    - Unpin action calls controller
  - **Status**: ⬜ Not started

- [ ] **Task**: Test `GroupedContactSelector`

  - **File**: `test/features/contacts/presentation/widgets/grouped_contact_selector_test.dart`
  - **Cases**:
    - Renders sections with correct counts
    - Expand/collapse works
    - Click contact → callback invoked
    - Selected contact highlighted
  - **Status**: ⬜ Not started

- [ ] **Task**: Test `AlphabetJumpBar`

  - **File**: `test/features/contacts/presentation/widgets/alphabet_jump_bar_test.dart`
  - **Cases**:
    - Renders all letters
    - Available vs unavailable styling
    - Click letter → scroll callback invoked
    - Hover shows tooltip
  - **Status**: ⬜ Not started

- [ ] **Task**: Test `ContactSearchField`
  - **File**: `test/features/contacts/presentation/widgets/contact_search_field_test.dart`
  - **Cases**:
    - Text input updates provider
    - Clear button clears text and provider
    - Debounce works (300ms delay)
    - Result count displays correctly
  - **Status**: ⬜ Not started

---

## Phase 4: Integration - Refactor ContactsSidebarView (Days 8-9)

### 4.1 Sidebar Layout Restructure ⬜

- [ ] **Task**: Refactor `ContactsSidebarView` layout

  - **File**: `lib/features/contacts/presentation/view/contacts_sidebar_view.dart`
  - **Old Structure**:
    ```
    - MENU A selector (Contacts vs Unmatched)
    - Contact dropdown (MacosPopupButton)
    - Filter radio buttons (All/A-Z/Favorites)
    - Empty state / Chats list
    ```
  - **New Structure**:
    ```
    - MENU A selector (Contacts vs Unmatched)
    - Row(
        - Column(
            - FavoritesSection
            - ContactSearchField
            - GroupedContactSelector
            - Filter radio buttons (All/A-Z/Favorites)
          )
        - AlphabetJumpBar (fixed on right edge)
      )
    - Empty state / Chats list
    ```
  - **Status**: ⬜ Not started

- [ ] **Task**: Wire up favorites section

  - **Details**:
    - Watch `favoriteContactsProvider`
    - Pass click callback to FavoritesSection
    - On click → update `selectedParticipantId` in SidebarSpec
    - Clear center panel (existing pattern)
  - **Status**: ⬜ Not started

- [ ] **Task**: Wire up search field

  - **Details**:
    - Add ContactSearchField above contact selector
    - When search query active:
      - Hide grouped selector, show flat filtered list
      - Hide jump bar (not relevant during search)
    - When search cleared:
      - Restore grouped selector and jump bar
  - **Status**: ⬜ Not started

- [ ] **Task**: Wire up grouped selector

  - **Details**:
    - Replace `MacosPopupButton` with `GroupedContactSelector`
    - Watch `groupedContactsProvider`
    - Pass `selectedParticipantId` for highlighting
    - On contact click → same logic as old dropdown
  - **Status**: ⬜ Not started

- [ ] **Task**: Wire up alphabet jump bar
  - **Details**:
    - Position on right edge of contact selector area
    - Pass `ScrollController` from grouped selector
    - Pass available letters from `groupedContactsProvider`
    - On letter click → scroll to that section
  - **Status**: ⬜ Not started

### 4.2 Context Menu for Contact Pinning ⬜

- [ ] **Task**: Add context menu to contact items

  - **Location**: Within `GroupedContactSelector` contact rows
  - **Details**:
    ```dart
    GestureDetector(
      onSecondaryTapDown: (details) async {
        final isFavorite = await _checkIfFavorite(participantId);

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(...),
          items: [
            if (!isFavorite)
              PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.star),
                    SizedBox(width: 8),
                    Text('Pin to Favorites'),
                  ],
                ),
              )
            else
              PopupMenuItem(
                value: 'unpin',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.star_slash),
                    SizedBox(width: 8),
                    Text('Unpin from Favorites'),
                  ],
                ),
              ),
          ],
        );

        if (selected == 'pin') {
          try {
            await ref.read(favoriteContactsControllerProvider.notifier)
                .pinContact(participantId);
          } catch (e) {
            // Show error dialog: "Maximum 10 favorites reached"
          }
        } else if (selected == 'unpin') {
          await ref.read(favoriteContactsControllerProvider.notifier)
              .unpinContact(participantId);
        }
      },
      child: ContactRow(...),
    )
    ```
  - **Status**: ⬜ Not started

- [ ] **Task**: Add error dialog for favorites limit
  - **Details**:
    - Show MacosAlertDialog when trying to pin 11th contact
    - Message: "You can pin up to 10 favorite contacts. Unpin a contact to add this one."
    - Button: "OK"
  - **Status**: ⬜ Not started

### 4.3 Update Last Interaction on Contact Selection ⬜

- [ ] **Task**: Track contact interactions
  - **Location**: `ContactsSidebarView` contact selection callback
  - **Details**:
    ```dart
    onContactSelected: (participantId) async {
      // Existing navigation logic...

      // Update last interaction for favorites re-sorting
      final isFavorite = await _checkIfFavorite(participantId);
      if (isFavorite) {
        await ref.read(favoriteContactsControllerProvider.notifier)
            .updateLastInteraction(participantId);
      }
    }
    ```
  - **Rationale**: Auto-sorts favorites by recent usage
  - **Status**: ⬜ Not started

### 4.4 Preserve Existing Functionality ⬜

- [ ] **Task**: Verify filter radio buttons still work

  - **Location**: All/A-Z/Favorites radio buttons
  - **Test**: Each mode updates `ContactsListSpec` correctly
  - **Status**: ⬜ Not started

- [ ] **Task**: Verify chat view mode selector still works

  - **Location**: Recent Activity / Newest / Oldest dropdown
  - **Test**: Changes propagate to chat list sorting
  - **Status**: ⬜ Not started

- [ ] **Task**: Verify empty state still shows
  - **Location**: "Select a contact to view their chats"
  - **Test**: Shows when no contact selected
  - **Status**: ⬜ Not started

---

## Phase 5: Polish & Edge Cases (Day 10)

### 5.1 Empty States ⬜

- [ ] **Task**: Favorites empty state

  - **Component**: `FavoritesSection`
  - **Design**: Subtle dashed border box with text
  - **Message**: "No pinned contacts. Right-click any contact to pin."
  - **Height**: Same as favorites section (60px)
  - **Status**: ⬜ Not started

- [ ] **Task**: Search no results state

  - **Component**: Below `ContactSearchField`
  - **Design**: Center-aligned text with icon
  - **Message**: "No contacts found for '[query]'"
  - **Icon**: Magnifying glass with slash
  - **Status**: ⬜ Not started

- [ ] **Task**: Grouped selector empty section
  - **Behavior**: Don't show section header if no contacts
  - **Jump bar**: Don't show letter if section empty
  - **Status**: ⬜ Not started

### 5.2 Performance Optimizations ⬜

- [ ] **Task**: Lazy load grouped sections

  - **Details**: Only render visible contact rows
  - **Use**: ListView.builder inside each section
  - **Status**: ⬜ Not started

- [ ] **Task**: Debounce search input

  - **Details**: 300ms delay before updating provider
  - **Use**: `Debouncer` utility or Timer
  - **Status**: ⬜ Not started

- [ ] **Task**: Cache grouped contacts

  - **Details**: Provider caching (Riverpod already handles this)
  - **Verify**: No unnecessary re-grouping on each render
  - **Status**: ⬜ Not started

- [ ] **Task**: Profile with 500+ contacts
  - **Test**: Scroll performance, search speed, favorites load time
  - **Tool**: Flutter DevTools performance tab
  - **Target**: <16ms frame time, <300ms search results
  - **Status**: ⬜ Not started

### 5.3 Animations & Transitions ⬜

- [ ] **Task**: Smooth scroll animations

  - **Details**: Jump bar → grouped selector scroll (300ms easeOut)
  - **Status**: ⬜ Not started

- [ ] **Task**: Expand/collapse animations

  - **Details**: Section height animation (200ms easeInOut)
  - **Caret rotation**: 0° → 90° (150ms)
  - **Status**: ⬜ Not started

- [ ] **Task**: Favorite pin/unpin feedback

  - **Details**: Brief scale animation when adding/removing favorite
  - **Duration**: 200ms
  - **Status**: ⬜ Not started

- [ ] **Task**: Hover effects
  - **Jump bar letters**: Scale 1.0 → 1.2 on hover
  - **Contact rows**: Background color change
  - **Favorite cards**: Subtle elevation change
  - **Status**: ⬜ Not started

### 5.4 Accessibility ⬜

- [ ] **Task**: Keyboard navigation

  - **Details**:
    - Tab through favorites, search field, grouped selector, jump bar
    - Arrow keys navigate within grouped selector
    - Enter/Space select contact
    - Escape close expanded section
  - **Status**: ⬜ Not started

- [ ] **Task**: VoiceOver support

  - **Details**:
    - Semantic labels for all interactive elements
    - Announce section changes when scrolling
    - Announce search result counts
  - **Status**: ⬜ Not started

- [ ] **Task**: Focus indicators

  - **Details**: Clear visual outline on all focusable elements
  - **Color**: macOS system blue (0xFF007AFF)
  - **Width**: 2px
  - **Status**: ⬜ Not started

- [ ] **Task**: Color contrast
  - **Test**: All text meets WCAG AA (4.5:1 for normal text)
  - **Tool**: Color contrast checker
  - **Status**: ⬜ Not started

---

## Phase 6: Testing & Documentation (Days 11-12)

### 6.1 Integration Tests ⬜

- [ ] **Task**: End-to-end favorites flow

  - **File**: `integration_test/favorites_flow_test.dart`
  - **Steps**:
    1. Launch app
    2. Navigate to contacts sidebar
    3. Right-click contact → Pin to Favorites
    4. Verify appears in favorites section
    5. Click favorite → verify chats load
    6. Right-click favorite → Unpin
    7. Verify removed from favorites section
  - **Status**: ⬜ Not started

- [ ] **Task**: End-to-end search flow

  - **File**: `integration_test/contact_search_flow_test.dart`
  - **Steps**:
    1. Launch app
    2. Navigate to contacts sidebar
    3. Click search field
    4. Type "Rob"
    5. Verify filtered results show
    6. Click clear button
    7. Verify all contacts restored
  - **Status**: ⬜ Not started

- [ ] **Task**: End-to-end jump bar flow
  - **File**: `integration_test/jump_bar_flow_test.dart`
  - **Steps**:
    1. Launch app with 100+ contacts
    2. Navigate to contacts sidebar
    3. Click letter "M" in jump bar
    4. Verify scrolls to M section
    5. Click contact in M section
    6. Verify chats load for that contact
  - **Status**: ⬜ Not started

### 6.2 Manual Testing Scenarios ⬜

- [ ] **Scenario**: Small contact list (10 contacts)

  - **Verify**: UI doesn't look broken, grouping still works
  - **Status**: ⬜ Not started

- [ ] **Scenario**: Medium contact list (50 contacts)

  - **Verify**: Grouping provides clear benefit, jump bar useful
  - **Status**: ⬜ Not started

- [ ] **Scenario**: Large contact list (500+ contacts)

  - **Verify**: No performance issues, smooth scrolling, fast search
  - **Status**: ⬜ Not started

- [ ] **Scenario**: Pin/unpin various contacts

  - **Verify**: Auto-sorts by last interaction, limit enforced at 10
  - **Status**: ⬜ Not started

- [ ] **Scenario**: Search with no results

  - **Verify**: Empty state shows, clear button works
  - **Status**: ⬜ Not started

- [ ] **Scenario**: All contacts start with same letter

  - **Verify**: Jump bar shows only that letter, UI doesn't break
  - **Status**: ⬜ Not started

- [ ] **Scenario**: Keyboard-only navigation
  - **Verify**: Can access all features via keyboard
  - **Status**: ⬜ Not started

### 6.3 Documentation Updates ⬜

- [ ] **Task**: Update `DESIGN_NOTES.md`

  - **Content**:
    - Implementation decisions made during development
    - Performance characteristics
    - Known limitations
  - **Status**: ⬜ Not started

- [ ] **Task**: Update `TESTS.md`

  - **Content**:
    - Test coverage summary
    - Manual test results
    - Performance benchmarks
  - **Status**: ⬜ Not started

- [ ] **Task**: Create `STATUS.md`

  - **Content**:
    - Feature completion status
    - Known bugs / edge cases
    - Future enhancements
  - **Status**: ⬜ Not started

- [ ] **Task**: Update user-facing documentation
  - **File**: `README.md` or user guide
  - **Content**:
    - How to pin/unpin favorites
    - Using the jump bar
    - Search tips
  - **Status**: ⬜ Not started

### 6.4 Code Review Preparation ⬜

- [ ] **Task**: Self-review all changes

  - **Checklist**:
    - [ ] All files follow Dart linting rules
    - [ ] No hardcoded values (use constants)
    - [ ] All providers use code generation
    - [ ] Freezed classes are `abstract`
    - [ ] Use `withValues(alpha:)` not `withOpacity()`
    - [ ] All control flow has braces
    - [ ] Imports use `hooks_riverpod`
  - **Status**: ⬜ Not started

- [ ] **Task**: Run full test suite

  - **Command**: `flutter test`
  - **Expected**: All tests pass
  - **Status**: ⬜ Not started

- [ ] **Task**: Run code generation

  - **Command**: `dart run build_runner build --delete-conflicting-outputs`
  - **Expected**: No errors, all .g.dart files updated
  - **Status**: ⬜ Not started

- [ ] **Task**: Run analyzer

  - **Command**: `flutter analyze`
  - **Expected**: Zero issues
  - **Status**: ⬜ Not started

- [ ] **Task**: Format code
  - **Command**: `dart format .`
  - **Expected**: All files formatted
  - **Status**: ⬜ Not started

---

## Completion Criteria

### Must Have (Blocking)

- [x] Proposal approved
- [ ] All Phase 1-6 tasks completed
- [ ] All unit tests passing
- [ ] All widget tests passing
- [ ] At least 2 integration tests passing
- [ ] Manual testing completed for all scenarios
- [ ] Zero analyzer errors
- [ ] Documentation updated

### Should Have (Non-Blocking)

- [ ] All accessibility features implemented
- [ ] Performance profiling completed
- [ ] All animations polished
- [ ] User documentation created

### Nice to Have (Future Enhancement)

- [ ] Drag-to-reorder favorites
- [ ] Contact categories/tags
- [ ] Smart groups (Recents, Top Chats)
- [ ] Advanced search (phone/email)

---

## Progress Tracking

**Phase 1**: ⬜ Not Started (0/3 sections complete)  
**Phase 2**: ⬜ Not Started (0/4 sections complete)  
**Phase 3**: ⬜ Not Started (0/5 sections complete)  
**Phase 4**: ⬜ Not Started (0/4 sections complete)  
**Phase 5**: ⬜ Not Started (0/4 sections complete)  
**Phase 6**: ⬜ Not Started (0/4 sections complete)

**Overall Progress**: 0% (0/24 sections complete)

---

## Notes & Decisions

### 2025-11-08: Initial Checklist Created

- Favorites limited to 10, auto-sorted by last interaction
- Search only matches display names (not phone/email)
- Jump bar fixed on right edge, permanently visible
- All decisions approved in PROPOSAL.md

---

**Next Action**: Begin Phase 1.1 - Create overlay database migration for `favorite_contacts` table.
