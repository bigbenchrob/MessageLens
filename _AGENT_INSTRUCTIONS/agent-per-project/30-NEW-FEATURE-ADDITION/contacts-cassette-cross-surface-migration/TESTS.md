# Contacts Cassette Cross-Surface Migration — Test Plan

This document outlines testing strategy for the migration.

---

## Testing Philosophy

Since this is a refactor (behavior preservation), testing focuses on:
1. **Regression prevention** — existing functionality works identically
2. **Integration verification** — new layers connect correctly
3. **Unit testing** — resolvers produce expected output

---

## Phase 1 Tests

### Manual Verification

- [ ] App launches without errors
- [ ] Open contact chooser → displays correctly
- [ ] Select contact → callback fires
- [ ] Open recent contacts → displays correctly
- [ ] Open hero summary → displays correctly

### Automated Tests

None required for Phase 1 (bridge only).

---

## Phase 2 Tests: Contact Chooser

### Unit Tests: ChooserContentResolver

Location: `test/features/contacts/application/spec_cases/chooser_content_resolver_test.dart`

```dart
// Test: Resolves flat picker mode correctly
// Test: Resolves enhanced picker mode correctly
// Test: Returns contacts list from repository
// Test: Returns recents list from repository
// Test: Handles empty contacts gracefully
// Test: Handles repository error gracefully
```

### Widget Tests: ChooserWidgetBuilder

Location: `test/features/contacts/application/spec_widget_builders/chooser_widget_builder_test.dart`

```dart
// Test: Builds flat picker for flat mode
// Test: Builds enhanced picker for enhanced mode
// Test: Shows loading state when content null
// Test: Shows error state for error content
```

### Integration Tests

- [ ] Contact chooser displays in sidebar
- [ ] Selecting contact triggers navigation
- [ ] Search in enhanced picker filters results

---

## Phase 3 Tests: Recent Contacts

### Unit Tests

```dart
// Test: Resolver returns recent contacts list
// Test: Recent contacts sorted by recency
// Test: Handles empty recents gracefully
```

### Integration Tests

- [ ] Recent contacts panel displays
- [ ] Selecting recent contact triggers callback

---

## Phase 4 Tests: Hero Summary

### Unit Tests: HeroSummaryResolver

Location: `test/features/contacts/application/spec_cases/hero_summary_resolver_test.dart`

```dart
// Test: Resolves contact data by ID
// Test: Computes summary line correctly
// Test: Returns available actions
// Test: Handles unknown contact ID
```

### Widget Tests: HeroSummaryWidgetBuilder

```dart
// Test: Builds hero card with contact info
// Test: Summary line displays correctly
// Test: Actions are tappable
```

### Integration Tests

- [ ] Hero summary displays for selected contact
- [ ] Actions trigger correct handlers

---

## Phase 5 Tests: Post-Cleanup

### Verification

- [ ] `flutter analyze` passes with no warnings
- [ ] `flutter test` passes all tests
- [ ] No imports reference deleted files
- [ ] App behavior identical to pre-migration

---

## Regression Test Matrix

| Feature | Pre-Migration | Post-Migration | Pass |
|---------|---------------|----------------|------|
| Flat contact picker | ✓ | | |
| Enhanced contact picker | ✓ | | |
| Contact selection callback | ✓ | | |
| Recent contacts list | ✓ | | |
| Hero summary display | ✓ | | |
| Hero summary actions | ✓ | | |
| Loading states | ✓ | | |
| Error states | ✓ | | |

---

## Test Coverage Targets

- Resolvers: 80%+ line coverage
- Builders: 70%+ line coverage
- Coordinator: Minimal (routing only, tested via integration)

---

## Notes

- Prefer widget tests over unit tests for builders (UI verification)
- Mock repositories in resolver tests
- Use `ProviderContainer` for isolated provider testing
