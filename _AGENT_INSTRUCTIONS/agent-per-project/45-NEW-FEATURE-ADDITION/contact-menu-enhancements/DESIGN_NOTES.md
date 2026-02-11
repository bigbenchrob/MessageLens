---
tier: project
scope: feature-design
owner: agent-per-project
last_reviewed: 2025-11-08
source_of_truth: doc
status: in_progress
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
tests: []
---

# Design Notes: Contact Menu Enhancements

**Status**: 🟡 In Progress  
**Last Updated**: 2025-11-08

## Architecture Decisions

### Database Design

#### Favorites Storage Strategy

**Decision**: Store favorites in `db-overlay` (not `db-working`)  
**Rationale**:

- Favorites are user preferences, not imported data
- Must survive database rebuilds/migrations
- Follows project pattern: overlay DB for persistent user customizations
- Aligns with existing contact short names pattern

**Schema**:

```sql
CREATE TABLE favorite_contacts (
  participant_id INTEGER PRIMARY KEY,
  sort_order INTEGER NOT NULL DEFAULT 0,
  pinned_at_utc TEXT NOT NULL,
  last_interaction_utc TEXT,
  FOREIGN KEY (participant_id) REFERENCES working_participants(id)
);

CREATE INDEX idx_favorite_contacts_sort_order
  ON favorite_contacts(sort_order);
```

**Alternative Considered**: Store in `db-working` with migration support  
**Rejected**: Would be wiped on every migration, user frustration

---

### Favorites Ordering

#### Auto-Sort by Last Interaction

**Decision**: Sort by `last_interaction_utc DESC` (most recent first)  
**Rationale**:

- Aligns with natural usage patterns (recent = relevant)
- No manual ordering UI needed for v1
- Simple to implement and understand

**Tracking Strategy**:

- Update `last_interaction_utc` when user selects a favorite contact
- Provider invalidation triggers automatic re-sort
- Only update if contact is already favorited (optimization)

**Alternative Considered**: User drag-to-reorder with explicit sort_order  
**Deferred**: More complex UI, defer to future enhancement if requested

---

### Grouping Strategy

#### Alphabetical Sections

**Decision**: Group by first letter (uppercase), plus "#" for non-alpha  
**Implementation**:

```dart
String getGroupKey(String displayName) {
  final firstChar = displayName.trim().toUpperCase()[0];
  if (RegExp(r'[A-Z]').hasMatch(firstChar)) {
    return firstChar;
  }
  return '#'; // Numbers and special characters
}
```

**Edge Cases**:

- Empty display name → skip entirely (already filtered in provider)
- Leading spaces → trim before grouping
- Emoji/special characters → "#" group
- Single letter names → valid, no special handling

**Alternative Considered**: Smart grouping (common first names, nicknames)  
**Rejected**: Over-engineered, alphabetical is universal

---

### Search Scope

#### Display Name Only

**Decision**: Search only matches `displayName` and `shortName` fields  
**Rationale**:

- Simple implementation
- Covers 90% of user search needs
- Phone/email search deferred to avoid complexity

**Case Insensitive**:

```dart
final query = searchQuery.toLowerCase();
contacts.where((c) =>
  c.displayName.toLowerCase().contains(query) ||
  c.shortName.toLowerCase().contains(query)
)
```

**Debounce**: 300ms delay to avoid excessive provider invalidations

**Alternative Considered**: Full-text search across handles, notes, etc.  
**Deferred**: Future enhancement if users request it

---

### Jump Bar Design

#### Fixed Position

**Decision**: Jump bar fixed on right edge of sidebar, flush with top  
**Layout**:

```
┌─────────────────────┬─┐
│ Favorites Section   │A│
├─────────────────────┤B│
│ Search Field        │C│
├─────────────────────┤D│
│ Contact Selector    │E│
│   > Section A       │.│
│     - Alice         │.│
│     - Adam          │.│
│   > Section B       │Z│
│     - Bob           │#│
└─────────────────────┴─┘
```

**Styling**:

- Width: 24px
- Letter height: 16px (smaller touch targets, macOS convention)
- Available letters: normal gray
- Unavailable letters: light gray, non-interactive
- Active section: blue highlight

**Visibility**: Permanently visible in Contacts mode (hidden in Unmatched Handles mode - future)

**Alternative Considered**: Scrolls with content (not fixed)  
**Rejected**: Fixed position provides constant access, more useful

---

## UI/UX Decisions

### Favorites Section

#### Visual Design

**Card Style**:

- Width: 80px
- Height: 60px
- Border radius: 8px
- Background: subtle gray (light mode) / darker gray (dark mode)
- Hover: slight elevation + background color change
- Selected: blue border (2px)

**Content**:

- Avatar circle (32x32) centered at top
- Name label below (10px font, truncated if too long)
- No message count or other stats (keeps it clean)

**Empty State**:

- Dashed border box (same dimensions)
- Center-aligned text: "No pinned contacts"
- Subtext: "Right-click any contact to pin"
- Icon: Star outline

---

### Grouped Contact Selector

#### Section Headers

**Design**:

- Letter + count badge: "B (23)"
- Caret icon: ▸ (collapsed) / ▾ (expanded)
- Background: subtle tint to differentiate from items
- Sticky behavior: Current section header stays visible during scroll

**Collapse Behavior**:

- Click header → toggle expand/collapse
- Animation: 200ms height animation
- Remember state per section (local state, not persisted)
- Default: All sections collapsed except first with contacts

**Contact Items**:

- Same styling as current dropdown items
- Height: 32px
- Left padding: 16px (indented under header)
- Hover: background highlight
- Selected: blue background + checkmark icon

---

### Context Menu Design

#### Pin/Unpin Actions

**Appearance**:

- Right-click contact anywhere (favorites section or grouped selector)
- Menu shows:
  - If not favorited: "Pin to Favorites" (star icon)
  - If favorited: "Unpin from Favorites" (star-slash icon)
- macOS native menu styling (via Material `showMenu` with custom styling)

**Limit Enforcement**:

- When trying to pin 11th contact → show alert dialog
- Alert title: "Maximum Favorites Reached"
- Alert message: "You can pin up to 10 favorite contacts. Unpin a contact to add this one."
- Button: "OK"

---

### Search Field Design

#### Visual Style

**Component**: Custom styled `MacosTextField` or `CupertinoSearchTextField`  
**Layout**:

- Leading icon: Magnifying glass (12x12)
- Placeholder: "Search contacts..."
- Trailing icon: Clear button (X) when text present
- Height: 32px
- Border radius: 6px
- Subtle gray background

**Result Feedback**:

- Below search field: "X contacts found" (only when query active)
- Font size: 11px, gray color
- Updates live as user types (debounced 300ms)

---

## Performance Considerations

### Large Contact Lists

#### Lazy Loading Strategy

**Grouped Sections**: Use `ListView.builder` for each section's contacts  
**Rationale**: Only render visible items, crucial for 500+ contacts

**Benchmarking Targets**:

- 100 contacts: <50ms initial render
- 500 contacts: <100ms initial render
- 1000 contacts: <200ms initial render
- Scrolling: Maintain 60fps (16ms frame budget)

#### Provider Caching

**Grouped Contacts**: Riverpod's built-in caching should suffice  
**Verify**: No re-grouping on every render (profile in DevTools)

**Search Results**: Filtered list cached until query changes

---

### Animation Performance

**Targets**:

- Section expand/collapse: <200ms total
- Jump bar scroll: <300ms smooth animation
- Hover effects: <100ms instant feedback

**Tools**:

- Flutter DevTools Performance tab
- Profile on older hardware (if available)
- Test with 1000+ contacts for worst-case

---

## Accessibility Considerations

### Keyboard Navigation

**Tab Order**:

1. Favorites section cards (left to right)
2. Search field
3. Grouped contact selector sections/items
4. Jump bar letters (optional, Tab should skip)

**Arrow Keys**:

- Up/Down: Navigate within grouped selector
- Left/Right: Navigate within favorites section
- Enter/Space: Select focused item

**Escape Key**: Close expanded section (if in grouped selector)

### Screen Reader Support

**Semantic Labels**:

- Favorites cards: "[Name], favorite contact [X of Y]"
- Section headers: "[Letter], [count] contacts, [expanded/collapsed]"
- Jump bar letters: "Jump to [Letter], [count] contacts"
- Search field: "Search contacts by name"

**Announcements**:

- When section expands/collapses: Announce state change
- When search results update: Announce result count
- When favorite pinned/unpinned: Confirm action

### Visual Indicators

**Focus Outlines**:

- Color: System blue (0xFF007AFF)
- Width: 2px
- Offset: 2px from element edge
- Visible on all focusable elements

**Color Contrast**:

- All text: ≥4.5:1 against background (WCAG AA)
- Icons: ≥3:1 against background
- Interactive elements: ≥3:1 in all states

---

## Known Limitations

### Current Version (v1)

1. **No drag-to-reorder favorites**: Auto-sorts by last interaction only
2. **Search limited to names**: Phone/email search not supported
3. **No smart groups**: No "Recents" or "Top Chats" sections
4. **Jump bar always visible**: No auto-hide in Unmatched Handles mode yet
5. **Single sidebar only**: No support for right sidebar (endSidebar)

### Future Enhancements (Deferred)

1. **Contact categories/tags**: User-defined groupings beyond alphabetical
2. **Advanced search**: Search by phone, email, or custom fields
3. **Favorites sync**: Multi-device favorites synchronization
4. **Smart groups**: "Recently contacted", "Most messages", "Unread", etc.
5. **Jump bar gestures**: Click-and-drag scrolling (iOS style)

---

## Testing Strategy

### Unit Testing Priorities

**Critical** (must test):

- Favorites provider: Pin/unpin/reorder logic
- Grouped contacts provider: Grouping algorithm, edge cases
- Search provider: Filtering, empty states, debouncing
- Database queries: CRUD operations on favorite_contacts table

**Important** (should test):

- Widget rendering: Favorites section, grouped selector, jump bar
- Context menu: Pin/unpin actions, limit enforcement
- Empty states: All variations

**Nice to have** (optional):

- Animation timing
- Hover states
- Accessibility features

### Integration Testing Priorities

**Must Have**:

1. Pin favorite → appears in section → click → chats load
2. Search contact → select → chats load
3. Jump bar letter → scrolls → select contact → chats load

**Should Have**:

- Favorites limit enforcement (try to pin 11th)
- Search no results → clear → all contacts restored

### Manual Testing Checklist

**Small Dataset** (10 contacts):

- [ ] UI doesn't look broken
- [ ] Empty sections don't show
- [ ] Jump bar shows only available letters

**Medium Dataset** (50 contacts):

- [ ] Grouping provides value
- [ ] Jump bar useful
- [ ] Search responsive

**Large Dataset** (500+ contacts):

- [ ] No jank during scroll
- [ ] Search results <300ms
- [ ] Section expand/collapse smooth

**Edge Cases**:

- [ ] All contacts same letter → UI handles gracefully
- [ ] Contact names with emoji → groups correctly
- [ ] Empty display names → skipped (shouldn't happen)

---

## Implementation Notes

### Phase Ordering Rationale

**Phase 1 (Database)**: Foundation for all other work  
**Phase 2 (Providers)**: Business logic before UI  
**Phase 3 (Widgets)**: Isolated components, parallel work possible  
**Phase 4 (Integration)**: Wire everything together  
**Phase 5 (Polish)**: User-facing refinements  
**Phase 6 (Testing)**: Verification before ship

### Code Organization

**New Files Created**:

```
lib/features/contacts/
  domain/entities/
    favorite_contact.dart
    grouped_contacts.dart
  application/
    favorite_contacts_provider.dart
    grouped_contacts_provider.dart
    contact_search_provider.dart
  presentation/widgets/
    favorites_section.dart
    grouped_contact_selector.dart
    alphabet_jump_bar.dart
    contact_search_field.dart
```

**Modified Files**:

```
lib/features/contacts/
  presentation/view/
    contacts_sidebar_view.dart (major refactor)
lib/essentials/db/
  infrastructure/data_sources/local/overlay/
    overlay_database.dart (schema migration)
```

---

## Open Technical Questions

### Question 1: Sticky Headers Implementation

**Options**:

1. `SliverPersistentHeader` (complex but proper)
2. Custom elevated styling for active section (simpler)

**Decision**: Start with option 2, upgrade to option 1 if needed  
**Rationale**: Simpler implementation, good enough UX for v1

### Question 2: Jump Bar Scroll Animation

**Options**:

1. `animateTo()` with calculated offsets (precise)
2. `ScrollController.position.ensureVisible()` (automatic)

**Decision**: Option 1 for better control  
**Rationale**: Need to account for collapsed sections, variable heights

### Question 3: Favorites Interaction Tracking

**Options**:

1. Track on every contact selection (high frequency)
2. Track only on chat click (less frequent)

**Decision**: Option 1 (track on contact selection)  
**Rationale**: More accurate reflection of user interest, minimal overhead

---

## Migration Notes

### Database Migration

**Migration Number**: [To be determined based on current migration count]

**Up Migration**:

```sql
CREATE TABLE favorite_contacts (
  participant_id INTEGER PRIMARY KEY,
  sort_order INTEGER NOT NULL DEFAULT 0,
  pinned_at_utc TEXT NOT NULL,
  last_interaction_utc TEXT,
  FOREIGN KEY (participant_id) REFERENCES working_participants(id)
);

CREATE INDEX idx_favorite_contacts_sort_order
  ON favorite_contacts(sort_order);
```

**Down Migration**: (Not typically needed for overlay DB, but for completeness)

```sql
DROP INDEX IF EXISTS idx_favorite_contacts_sort_order;
DROP TABLE IF EXISTS favorite_contacts;
```

**Testing Migration**:

1. Create overlay DB backup before migration
2. Run migration
3. Verify table created with correct schema
4. Test insert/query operations
5. Verify index improves query performance

---

**Next Update**: After Phase 1 completion, document any implementation deviations or discoveries.
