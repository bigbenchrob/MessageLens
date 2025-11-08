---
tier: project
scope: feature-testing
owner: agent-per-project
last_reviewed: 2025-11-08
source_of_truth: doc
status: in_progress
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./DESIGN_NOTES.md
tests: []
---

# Test Specification: Contact Menu Enhancements

**Status**: 🟡 In Progress  
**Last Updated**: 2025-11-08

## Test Coverage Goals

### Unit Tests

**Target**: ≥80% code coverage for business logic  
**Focus**: Providers, domain entities, database queries

### Widget Tests

**Target**: ≥70% coverage for UI components  
**Focus**: Rendering, user interactions, state changes

### Integration Tests

**Target**: ≥3 critical user flows  
**Focus**: End-to-end scenarios with real navigation

---

## Unit Test Specifications

### 1. FavoriteContact Entity Tests

**File**: `test/features/contacts/domain/entities/favorite_contact_test.dart`

```dart
group('FavoriteContact', () {
  test('creates instance with all required fields', () {
    final contact = FavoriteContact(
      participantId: 1,
      displayName: 'Alice',
      shortName: 'Ali',
      sortOrder: 0,
      pinnedAtUtc: DateTime(2025, 1, 1),
      lastInteractionUtc: DateTime(2025, 1, 15),
      messageCount: 50,
      chatCount: 3,
    );

    expect(contact.participantId, 1);
    expect(contact.displayName, 'Alice');
    expect(contact.sortOrder, 0);
  });

  test('supports equality comparison', () {
    final contact1 = FavoriteContact(...);
    final contact2 = FavoriteContact(...);

    expect(contact1, equals(contact2));
  });

  test('supports copyWith', () {
    final original = FavoriteContact(...);
    final updated = original.copyWith(sortOrder: 5);

    expect(updated.sortOrder, 5);
    expect(updated.participantId, original.participantId);
  });

  test('handles nullable lastInteractionUtc', () {
    final contact = FavoriteContact(
      ...,
      lastInteractionUtc: null,
    );

    expect(contact.lastInteractionUtc, isNull);
  });
});
```

---

### 2. Favorite Contacts Provider Tests

**File**: `test/features/contacts/application/favorite_contacts_provider_test.dart`

```dart
group('favoriteContactsProvider', () {
  late ProviderContainer container;
  late MockOverlayDatabase mockOverlayDb;
  late MockWorkingDatabase mockWorkingDb;

  setUp(() {
    mockOverlayDb = MockOverlayDatabase();
    mockWorkingDb = MockWorkingDatabase();

    container = ProviderContainer(
      overrides: [
        overlayDatabaseProvider.overrideWithValue(AsyncValue.data(mockOverlayDb)),
        driftWorkingDatabaseProvider.overrideWithValue(AsyncValue.data(mockWorkingDb)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('returns empty list when no favorites', () async {
    when(() => mockOverlayDb.getAllFavorites()).thenAnswer((_) async => []);

    final favorites = await container.read(favoriteContactsProvider.future);

    expect(favorites, isEmpty);
  });

  test('returns favorites ordered by lastInteractionUtc DESC', () async {
    when(() => mockOverlayDb.getAllFavorites()).thenAnswer((_) async => [
      FavoriteContactRow(
        participantId: 1,
        lastInteractionUtc: DateTime(2025, 1, 10),
      ),
      FavoriteContactRow(
        participantId: 2,
        lastInteractionUtc: DateTime(2025, 1, 15), // More recent
      ),
    ]);

    // Mock participant lookups
    when(() => mockWorkingDb.getParticipant(1)).thenAnswer(
      (_) async => Participant(id: 1, displayName: 'Alice'),
    );
    when(() => mockWorkingDb.getParticipant(2)).thenAnswer(
      (_) async => Participant(id: 2, displayName: 'Bob'),
    );

    final favorites = await container.read(favoriteContactsProvider.future);

    expect(favorites.length, 2);
    expect(favorites[0].participantId, 2); // Bob first (more recent)
    expect(favorites[1].participantId, 1); // Alice second
  });

  test('limits results to 10 favorites', () async {
    final mockFavorites = List.generate(
      15,
      (i) => FavoriteContactRow(
        participantId: i,
        lastInteractionUtc: DateTime(2025, 1, i + 1),
      ),
    );

    when(() => mockOverlayDb.getAllFavorites()).thenAnswer(
      (_) async => mockFavorites,
    );

    final favorites = await container.read(favoriteContactsProvider.future);

    expect(favorites.length, 10);
  });

  test('includes message and chat counts', () async {
    when(() => mockOverlayDb.getAllFavorites()).thenAnswer((_) async => [
      FavoriteContactRow(participantId: 1, ...),
    ]);

    when(() => mockWorkingDb.getMessageCountForParticipant(1))
        .thenAnswer((_) async => 42);
    when(() => mockWorkingDb.getChatCountForParticipant(1))
        .thenAnswer((_) async => 5);

    final favorites = await container.read(favoriteContactsProvider.future);

    expect(favorites[0].messageCount, 42);
    expect(favorites[0].chatCount, 5);
  });
});

group('FavoriteContactsController', () {
  late ProviderContainer container;
  late MockOverlayDatabase mockOverlayDb;

  setUp(() {
    mockOverlayDb = MockOverlayDatabase();
    container = ProviderContainer(
      overrides: [
        overlayDatabaseProvider.overrideWithValue(AsyncValue.data(mockOverlayDb)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('pinContact adds favorite successfully', () async {
    when(() => mockOverlayDb.getFavoriteCount()).thenAnswer((_) async => 5);
    when(() => mockOverlayDb.addFavorite(any(), any())).thenAnswer((_) async => {});

    final controller = container.read(favoriteContactsControllerProvider.notifier);

    await expectLater(
      controller.pinContact(1),
      completes,
    );

    verify(() => mockOverlayDb.addFavorite(1, any())).called(1);
  });

  test('pinContact throws when at limit (10)', () async {
    when(() => mockOverlayDb.getFavoriteCount()).thenAnswer((_) async => 10);

    final controller = container.read(favoriteContactsControllerProvider.notifier);

    await expectLater(
      controller.pinContact(1),
      throwsA(isA<FavoritesLimitException>()),
    );

    verifyNever(() => mockOverlayDb.addFavorite(any(), any()));
  });

  test('unpinContact removes favorite successfully', () async {
    when(() => mockOverlayDb.removeFavorite(any())).thenAnswer((_) async => {});

    final controller = container.read(favoriteContactsControllerProvider.notifier);

    await expectLater(
      controller.unpinContact(1),
      completes,
    );

    verify(() => mockOverlayDb.removeFavorite(1)).called(1);
  });

  test('updateLastInteraction updates timestamp', () async {
    when(() => mockOverlayDb.updateLastInteraction(any(), any()))
        .thenAnswer((_) async => {});

    final controller = container.read(favoriteContactsControllerProvider.notifier);

    await expectLater(
      controller.updateLastInteraction(1),
      completes,
    );

    verify(() => mockOverlayDb.updateLastInteraction(1, any())).called(1);
  });

  test('invalidates favoriteContactsProvider after pin', () async {
    when(() => mockOverlayDb.getFavoriteCount()).thenAnswer((_) async => 5);
    when(() => mockOverlayDb.addFavorite(any(), any())).thenAnswer((_) async => {});

    final controller = container.read(favoriteContactsControllerProvider.notifier);

    // Watch provider to detect invalidation
    var invalidateCount = 0;
    container.listen(
      favoriteContactsProvider,
      (_, __) => invalidateCount++,
    );

    await controller.pinContact(1);

    expect(invalidateCount, greaterThan(0));
  });
});
```

---

### 3. Grouped Contacts Provider Tests

**File**: `test/features/contacts/application/grouped_contacts_provider_test.dart`

```dart
group('groupedContactsProvider', () {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        contactsListProvider(spec: const ContactsListSpec.alphabetical())
            .overrideWithValue(
          AsyncValue.data([
            ContactSummary(displayName: 'Alice', ...),
            ContactSummary(displayName: 'Adam', ...),
            ContactSummary(displayName: 'Bob', ...),
            ContactSummary(displayName: '123 Pizza', ...),
          ]),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('groups contacts by first letter', () async {
    final grouped = await container.read(groupedContactsProvider.future);

    expect(grouped.groups.keys, containsAll(['A', 'B', '#']));
    expect(grouped.groups['A']?.length, 2); // Alice, Adam
    expect(grouped.groups['B']?.length, 1); // Bob
    expect(grouped.groups['#']?.length, 1); // 123 Pizza
  });

  test('provides correct letter counts', () async {
    final grouped = await container.read(groupedContactsProvider.future);

    expect(grouped.letterCounts['A'], 2);
    expect(grouped.letterCounts['B'], 1);
    expect(grouped.letterCounts['#'], 1);
  });

  test('lists available letters in order', () async {
    final grouped = await container.read(groupedContactsProvider.future);

    expect(grouped.availableLetters, ['A', 'B', '#']);
  });

  test('handles empty contact list', () async {
    final emptyContainer = ProviderContainer(
      overrides: [
        contactsListProvider(spec: const ContactsListSpec.alphabetical())
            .overrideWithValue(AsyncValue.data([])),
      ],
    );

    final grouped = await emptyContainer.read(groupedContactsProvider.future);

    expect(grouped.groups, isEmpty);
    expect(grouped.letterCounts, isEmpty);
    expect(grouped.availableLetters, isEmpty);
  });

  test('trims whitespace before grouping', () async {
    final container = ProviderContainer(
      overrides: [
        contactsListProvider(spec: const ContactsListSpec.alphabetical())
            .overrideWithValue(
          AsyncValue.data([
            ContactSummary(displayName: '  Alice', ...),
          ]),
        ),
      ],
    );

    final grouped = await container.read(groupedContactsProvider.future);

    expect(grouped.groups.keys, contains('A'));
    expect(grouped.groups.keys, isNot(contains(' ')));
  });

  test('handles emoji in display names', () async {
    final container = ProviderContainer(
      overrides: [
        contactsListProvider(spec: const ContactsListSpec.alphabetical())
            .overrideWithValue(
          AsyncValue.data([
            ContactSummary(displayName: '🔥 Fire Department', ...),
          ]),
        ),
      ],
    );

    final grouped = await container.read(groupedContactsProvider.future);

    expect(grouped.groups.keys, contains('#'));
  });
});
```

---

### 4. Contact Search Provider Tests

**File**: `test/features/contacts/application/contact_search_provider_test.dart`

```dart
group('ContactSearch', () {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('initializes with empty query', () {
    final query = container.read(contactSearchProvider);

    expect(query, isEmpty);
  });

  test('updateQuery changes state', () {
    final controller = container.read(contactSearchProvider.notifier);

    controller.updateQuery('Rob');

    final query = container.read(contactSearchProvider);
    expect(query, 'Rob');
  });

  test('updateQuery trims whitespace', () {
    final controller = container.read(contactSearchProvider.notifier);

    controller.updateQuery('  Rob  ');

    final query = container.read(contactSearchProvider);
    expect(query, 'Rob');
  });

  test('clearQuery resets to empty', () {
    final controller = container.read(contactSearchProvider.notifier);

    controller.updateQuery('Rob');
    controller.clearQuery();

    final query = container.read(contactSearchProvider);
    expect(query, isEmpty);
  });
});

group('filteredContactsProvider', () {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        contactsListProvider(spec: const ContactsListSpec.all())
            .overrideWithValue(
          AsyncValue.data([
            ContactSummary(
              displayName: 'Robert Smith',
              shortName: 'Rob',
              ...
            ),
            ContactSummary(
              displayName: 'Alice Johnson',
              shortName: 'Ali',
              ...
            ),
            ContactSummary(
              displayName: 'Roberto Garcia',
              shortName: 'Roberto',
              ...
            ),
          ]),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('returns all contacts when query is empty', () async {
    final filtered = await container.read(filteredContactsProvider.future);

    expect(filtered.length, 3);
  });

  test('filters by display name (case insensitive)', () async {
    container.read(contactSearchProvider.notifier).updateQuery('rob');

    final filtered = await container.read(filteredContactsProvider.future);

    expect(filtered.length, 2); // Robert, Roberto
    expect(filtered.every((c) => c.displayName.toLowerCase().contains('rob')), isTrue);
  });

  test('filters by short name', () async {
    container.read(contactSearchProvider.notifier).updateQuery('ali');

    final filtered = await container.read(filteredContactsProvider.future);

    expect(filtered.length, 1);
    expect(filtered[0].shortName, 'Ali');
  });

  test('returns empty list when no matches', () async {
    container.read(contactSearchProvider.notifier).updateQuery('zzz');

    final filtered = await container.read(filteredContactsProvider.future);

    expect(filtered, isEmpty);
  });

  test('handles special characters in query', () async {
    container.read(contactSearchProvider.notifier).updateQuery('rob@');

    final filtered = await container.read(filteredContactsProvider.future);

    // Should not throw, returns contacts matching the query
    expect(filtered, isA<List<ContactSummary>>());
  });
});
```

---

## Widget Test Specifications

### 5. FavoritesSection Widget Tests

**File**: `test/features/contacts/presentation/widgets/favorites_section_test.dart`

```dart
group('FavoritesSection', () {
  testWidgets('renders favorite contact cards', (tester) async {
    final favorites = [
      FavoriteContact(displayName: 'Alice', participantId: 1, ...),
      FavoriteContact(displayName: 'Bob', participantId: 2, ...),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteContactsProvider.overrideWithValue(AsyncValue.data(favorites)),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoritesSection()),
        ),
      ),
    );

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('shows empty state when no favorites', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteContactsProvider.overrideWithValue(const AsyncValue.data([])),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoritesSection()),
        ),
      ),
    );

    expect(find.text('No pinned contacts'), findsOneWidget);
    expect(find.text('Right-click any contact to pin'), findsOneWidget);
  });

  testWidgets('calls callback when favorite clicked', (tester) async {
    int? selectedId;
    final favorites = [
      FavoriteContact(displayName: 'Alice', participantId: 1, ...),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteContactsProvider.overrideWithValue(AsyncValue.data(favorites)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FavoritesSection(
              onContactSelected: (id) => selectedId = id,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Alice'));

    expect(selectedId, 1);
  });

  testWidgets('shows context menu on right-click', (tester) async {
    final favorites = [
      FavoriteContact(displayName: 'Alice', participantId: 1, ...),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteContactsProvider.overrideWithValue(AsyncValue.data(favorites)),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoritesSection()),
        ),
      ),
    );

    // Simulate right-click (secondary tap)
    await tester.tap(
      find.text('Alice'),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();

    expect(find.text('Unpin from Favorites'), findsOneWidget);
  });
});
```

---

### 6. AlphabetJumpBar Widget Tests

**File**: `test/features/contacts/presentation/widgets/alphabet_jump_bar_test.dart`

```dart
group('AlphabetJumpBar', () {
  testWidgets('renders all letters A-Z plus special characters', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlphabetJumpBar(
            availableLetters: ['A', 'B', 'Z', '#'],
            letterCounts: {'A': 5, 'B': 10, 'Z': 2, '#': 3},
            onLetterTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);
    expect(find.text('#'), findsOneWidget);
  });

  testWidgets('highlights available letters', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlphabetJumpBar(
            availableLetters: ['A', 'B'],
            letterCounts: {'A': 5, 'B': 10},
            onLetterTap: (_) {},
          ),
        ),
      ),
    );

    // Available letters should have normal color
    final aText = tester.widget<Text>(find.text('A'));
    expect(aText.style?.color, isNot(equals(Colors.grey[300])));

    // Unavailable letters should be grayed out
    final cText = tester.widget<Text>(find.text('C'));
    expect(cText.style?.color, equals(Colors.grey[300]));
  });

  testWidgets('calls callback when letter tapped', (tester) async {
    String? tappedLetter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlphabetJumpBar(
            availableLetters: ['A', 'B'],
            letterCounts: {'A': 5, 'B': 10},
            onLetterTap: (letter) => tappedLetter = letter,
          ),
        ),
      ),
    );

    await tester.tap(find.text('B'));

    expect(tappedLetter, 'B');
  });

  testWidgets('does not call callback for unavailable letters', (tester) async {
    String? tappedLetter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlphabetJumpBar(
            availableLetters: ['A'], // C not available
            letterCounts: {'A': 5},
            onLetterTap: (letter) => tappedLetter = letter,
          ),
        ),
      ),
    );

    await tester.tap(find.text('C'));

    expect(tappedLetter, isNull);
  });

  testWidgets('shows tooltip on hover', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlphabetJumpBar(
            availableLetters: ['A'],
            letterCounts: {'A': 15},
            onLetterTap: (_) {},
          ),
        ),
      ),
    );

    // Hover over letter A
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('A (15 contacts)'), findsOneWidget);
  });
});
```

---

## Integration Test Specifications

### 7. Favorites Flow Integration Test

**File**: `integration_test/favorites_flow_test.dart`

```dart
void main() {
  group('Favorites Flow', () {
    testWidgets('pin contact → appears in favorites → click → chats load',
        (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to contacts sidebar
      await tester.tap(find.byIcon(CupertinoIcons.person_2));
      await tester.pumpAndSettle();

      // Find a contact in the grouped selector
      await tester.tap(find.text('A')); // Expand A section
      await tester.pumpAndSettle();

      final contactFinder = find.text('Alice');
      expect(contactFinder, findsOneWidget);

      // Right-click contact
      await tester.tap(contactFinder, buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();

      // Click "Pin to Favorites"
      await tester.tap(find.text('Pin to Favorites'));
      await tester.pumpAndSettle();

      // Verify appears in favorites section
      expect(find.ancestor(
        of: find.text('Alice'),
        matching: find.byType(FavoritesSection),
      ), findsOneWidget);

      // Click favorite card
      await tester.tap(find.ancestor(
        of: find.text('Alice'),
        matching: find.byType(FavoritesSection),
      ));
      await tester.pumpAndSettle();

      // Verify chats load (check for chat list or chat cards)
      expect(find.byType(EnhancedChatCard), findsWidgets);
    });

    testWidgets('unpin contact → removes from favorites', (tester) async {
      // Setup: Assume Alice is already favorited
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to contacts sidebar
      await tester.tap(find.byIcon(CupertinoIcons.person_2));
      await tester.pumpAndSettle();

      // Find Alice in favorites section
      final aliceFavorite = find.ancestor(
        of: find.text('Alice'),
        matching: find.byType(FavoritesSection),
      );
      expect(aliceFavorite, findsOneWidget);

      // Right-click favorite
      await tester.tap(aliceFavorite, buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();

      // Click "Unpin from Favorites"
      await tester.tap(find.text('Unpin from Favorites'));
      await tester.pumpAndSettle();

      // Verify removed from favorites section
      expect(aliceFavorite, findsNothing);
    });

    testWidgets('enforce 10 favorite limit', (tester) async {
      // Setup: Pin 10 contacts first (mock provider or actual data)
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Try to pin 11th contact
      // ... (navigation and right-click steps)

      await tester.tap(find.text('Pin to Favorites'));
      await tester.pumpAndSettle();

      // Verify error dialog appears
      expect(find.text('Maximum Favorites Reached'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify contact not added
      expect(find.byType(FavoritesSection), findsNWidgets(10));
    });
  });
}
```

---

### 8. Search Flow Integration Test

**File**: `integration_test/contact_search_flow_test.dart`

```dart
void main() {
  group('Contact Search Flow', () {
    testWidgets('search → select → chats load', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to contacts sidebar
      await tester.tap(find.byIcon(CupertinoIcons.person_2));
      await tester.pumpAndSettle();

      // Click search field
      await tester.tap(find.byType(ContactSearchField));
      await tester.pumpAndSettle();

      // Type search query
      await tester.enterText(find.byType(ContactSearchField), 'Rob');
      await tester.pumpAndSettle(const Duration(milliseconds: 400)); // Wait for debounce

      // Verify result count appears
      expect(find.textContaining('contacts found'), findsOneWidget);

      // Click a search result
      await tester.tap(find.text('Robert Smith'));
      await tester.pumpAndSettle();

      // Verify chats load
      expect(find.byType(EnhancedChatCard), findsWidgets);
    });

    testWidgets('search no results → clear → all contacts restored', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to contacts sidebar
      await tester.tap(find.byIcon(CupertinoIcons.person_2));
      await tester.pumpAndSettle();

      // Search for non-existent contact
      await tester.tap(find.byType(ContactSearchField));
      await tester.enterText(find.byType(ContactSearchField), 'ZZZ');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      // Verify no results message
      expect(find.textContaining('No contacts found'), findsOneWidget);

      // Click clear button
      await tester.tap(find.byIcon(CupertinoIcons.clear));
      await tester.pumpAndSettle();

      // Verify all contacts restored (grouped selector visible)
      expect(find.byType(GroupedContactSelector), findsOneWidget);
      expect(find.textContaining('No contacts found'), findsNothing);
    });
  });
}
```

---

### 9. Jump Bar Flow Integration Test

**File**: `integration_test/jump_bar_flow_test.dart`

```dart
void main() {
  group('Jump Bar Flow', () {
    testWidgets('click letter → scrolls → select contact → chats load',
        (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to contacts sidebar
      await tester.tap(find.byIcon(CupertinoIcons.person_2));
      await tester.pumpAndSettle();

      // Click letter "M" in jump bar
      await tester.tap(find.ancestor(
        of: find.text('M'),
        matching: find.byType(AlphabetJumpBar),
      ));
      await tester.pumpAndSettle();

      // Verify M section is visible (check for section header)
      expect(find.textContaining('M ('), findsOneWidget);

      // Click a contact in M section
      await tester.tap(find.text('Michelle')); // Example contact
      await tester.pumpAndSettle();

      // Verify chats load
      expect(find.byType(EnhancedChatCard), findsWidgets);
    });
  });
}
```

---

## Manual Testing Checklist

### Small Dataset (10 contacts)

- [ ] UI renders without visual breaks
- [ ] Grouping works correctly
- [ ] Jump bar shows only available letters
- [ ] Empty sections don't appear
- [ ] Favorites section works
- [ ] Search works with limited results

### Medium Dataset (50 contacts)

- [ ] Grouping provides clear organization
- [ ] Jump bar is useful for navigation
- [ ] Section expand/collapse smooth
- [ ] Search responsive (<300ms)
- [ ] Scroll performance good
- [ ] Pin/unpin favorites works

### Large Dataset (500+ contacts)

- [ ] No jank during scrolling
- [ ] Search results appear quickly (<300ms)
- [ ] Section expand/collapse remains smooth
- [ ] Jump bar scroll animations fluid
- [ ] Favorites load instantly
- [ ] No memory issues

### Edge Cases

- [ ] All contacts start with same letter → UI graceful
- [ ] Contact names with emoji → groups correctly
- [ ] Contact names with numbers → "#" group works
- [ ] Leading/trailing spaces → trimmed correctly
- [ ] Very long contact names → truncated properly
- [ ] Empty display names → skipped (shouldn't happen)
- [ ] Pin 10th favorite → success
- [ ] Pin 11th favorite → error dialog
- [ ] Unpin last favorite → empty state shows

### Accessibility

- [ ] Tab through all interactive elements
- [ ] Arrow keys navigate within grouped selector
- [ ] Enter/Space select focused item
- [ ] Escape closes expanded sections
- [ ] VoiceOver announces all elements correctly
- [ ] Focus indicators visible and clear
- [ ] Color contrast meets WCAG AA

---

## Performance Benchmarks

### Target Metrics

| Scenario                       | Target Time        | Tool                 |
| ------------------------------ | ------------------ | -------------------- |
| Initial render (100 contacts)  | <50ms              | DevTools Timeline    |
| Initial render (500 contacts)  | <100ms             | DevTools Timeline    |
| Initial render (1000 contacts) | <200ms             | DevTools Timeline    |
| Search results (500 contacts)  | <300ms             | Stopwatch in code    |
| Jump bar scroll animation      | <300ms             | Visual inspection    |
| Section expand animation       | <200ms             | Visual inspection    |
| Scroll performance             | 60fps (16ms/frame) | DevTools Performance |

### How to Measure

1. **Initial Render**:

   ```dart
   final stopwatch = Stopwatch()..start();
   await tester.pumpWidget(MyApp());
   await tester.pumpAndSettle();
   stopwatch.stop();
   print('Initial render: ${stopwatch.elapsedMilliseconds}ms');
   ```

2. **Search Results**:

   ```dart
   final stopwatch = Stopwatch()..start();
   controller.updateQuery('Rob');
   await ref.read(filteredContactsProvider.future);
   stopwatch.stop();
   print('Search: ${stopwatch.elapsedMilliseconds}ms');
   ```

3. **Scrolling**:
   - Use Flutter DevTools → Performance tab
   - Record while scrolling
   - Check for dropped frames (target: 0)

---

## Test Data Setup

### Fixtures

**File**: `test/fixtures/contact_fixtures.dart`

```dart
List<ContactSummary> generateMockContacts(int count) {
  return List.generate(count, (i) {
    final names = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve', ...];
    return ContactSummary(
      participantId: i + 1,
      displayName: names[i % names.length] + ' ${i ~/ names.length}',
      shortName: names[i % names.length],
      totalChats: (i % 5) + 1,
      totalMessages: (i % 100) + 10,
      lastMessageDate: DateTime.now().subtract(Duration(days: i)),
      origin: ParticipantOrigin.working,
      handleCount: (i % 3) + 1,
    );
  });
}

List<FavoriteContact> generateMockFavorites(int count) {
  return List.generate(count, (i) {
    return FavoriteContact(
      participantId: i + 1,
      displayName: 'Favorite ${i + 1}',
      shortName: 'Fav${i + 1}',
      sortOrder: i,
      pinnedAtUtc: DateTime(2025, 1, 1).add(Duration(days: i)),
      lastInteractionUtc: DateTime(2025, 1, 15).subtract(Duration(days: i)),
      messageCount: (i + 1) * 10,
      chatCount: i + 1,
    );
  });
}
```

---

## Coverage Reports

### Command

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Target Coverage

- **Overall**: ≥75%
- **Business logic** (providers, controllers): ≥80%
- **UI widgets**: ≥70%
- **Domain entities**: ≥90%

---

**Next Update**: After Phase 6 completion, document final test results and coverage metrics.
