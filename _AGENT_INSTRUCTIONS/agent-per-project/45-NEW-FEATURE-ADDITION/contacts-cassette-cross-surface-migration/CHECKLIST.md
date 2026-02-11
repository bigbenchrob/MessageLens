# Contacts Cassette Cross-Surface Migration — Checklist

This file tracks granular implementation steps. Update checkboxes as work completes.

---

## Phase 1: Create Coordinator Structure

### Step 1.1: Create ContactsCassetteCoordinator

- [x] Create file `lib/features/contacts/application/spec_coordinators/cassette_coordinator.dart`
- [x] Define `ContactsCassetteCoordinator` class with `@riverpod` annotation
- [x] Accept `ContactsCassetteSpec` as parameter
- [x] Pattern-match on spec variants using switch expression
- [x] For now, bridge to existing `contactChooserViewBuilder` for `contactChooser` variant
- [x] Return `Future<SidebarCassetteCardViewModel>`
- [x] Run code generation: `dart run build_runner build --delete-conflicting-outputs`
- [x] Verify no analyzer errors

### Step 1.2: Wire into CassetteWidgetCoordinator

- [x] Update `cassette_widget_coordinator_provider.dart` to import new coordinator
- [x] Add case for `ContactsCassetteSpec` → call `ContactsCassetteCoordinator`
- [x] Export coordinator from `feature_level_providers.dart`
- [ ] Run app and verify behavior unchanged

### Step 1.3: Phase 1 Checkpoint

- [ ] App launches without errors
- [ ] Contact chooser cassette displays correctly
- [ ] Recent contacts displays correctly
- [ ] Hero summary displays correctly
- [ ] No regressions in sidebar behavior

---

## Phase 2: Migrate Contact Chooser

### Step 2.1: Create ChooserContentResolver

- [ ] Create file `lib/features/contacts/application/spec_cases/chooser_content_resolver.dart`
- [ ] Define `ChooserContentResolver` class with `@riverpod`
- [ ] Accept `ContactChooserSpec` as parameter
- [ ] Move picker mode resolution logic from `contact_chooser_view_builder_provider.dart`
- [ ] Return structured `ChooserContent` payload (Freezed class)
- [ ] Define `ChooserContent` with: `pickerMode`, `contacts`, `recents`, `selectedId`, etc.
- [ ] Run code generation

### Step 2.2: Create ChooserWidgetBuilder

- [ ] Create file `lib/features/contacts/application/spec_widget_builders/chooser_widget_builder.dart`
- [ ] Define builder function or class
- [ ] Accept `ChooserContent` as input
- [ ] Build appropriate widget (`ContactsFlatMenuCassette` or `ContactsEnhancedPickerCassette`)
- [ ] Handle loading state (return loading placeholder)
- [ ] Handle error state (return error placeholder)

### Step 2.3: Update Coordinator for contactChooser

- [ ] Update `ContactsCassetteCoordinator` case for `contactChooser`
- [ ] Call `ChooserContentResolver` to get content
- [ ] Call `ChooserWidgetBuilder` to get widget
- [ ] Construct and return `SidebarCassetteCardViewModel`
- [ ] Remove bridge to legacy `contactChooserViewBuilder`

### Step 2.4: Phase 2 Checkpoint

- [ ] Contact chooser (flat) works correctly
- [ ] Contact chooser (enhanced picker) works correctly
- [ ] Loading states display properly
- [ ] Error states display properly
- [ ] Contact selection triggers correct callbacks

---

## Phase 3: Migrate Recent Contacts

### Step 3.1: Create RecentContactsResolver (or extend ChooserResolver)

- [ ] Determine if separate resolver needed or can extend ChooserContentResolver
- [ ] Handle `recentContacts` spec variant
- [ ] Return appropriate `ChooserContent` payload

### Step 3.2: Update Coordinator for recentContacts

- [ ] Add case in coordinator for `recentContacts`
- [ ] Wire resolver → builder → view model

### Step 3.3: Phase 3 Checkpoint

- [ ] Recent contacts variant works via new architecture
- [ ] No regressions

---

## Phase 4: Migrate Hero Summary

### Step 4.1: Create HeroSummaryResolver

- [ ] Create file `lib/features/contacts/application/spec_cases/hero_summary_resolver.dart`
- [ ] Accept `ContactHeroSpec` as parameter
- [ ] Resolve contact data for hero display
- [ ] Compute summary line, available actions
- [ ] Return `HeroSummaryContent` payload (Freezed)

### Step 4.2: Create HeroSummaryWidgetBuilder

- [ ] Create file `lib/features/contacts/application/spec_widget_builders/hero_summary_widget_builder.dart`
- [ ] Accept `HeroSummaryContent` as input
- [ ] Build `ContactHeroSummaryCassette` content

### Step 4.3: Update Coordinator for contactHeroSummary

- [ ] Add case in coordinator for `contactHeroSummary`
- [ ] Wire resolver → builder → view model

### Step 4.4: Phase 4 Checkpoint

- [ ] Hero summary works via new architecture
- [ ] Summary line displays correctly
- [ ] Actions work correctly
- [ ] No regressions

---

## Phase 5: Cleanup

### Step 5.1: Remove Legacy Code

- [ ] Remove `FeatureCassetteSpecCoordinator` from `feature_level_providers.dart`
- [ ] Delete `lib/features/contacts/application/use_cases/contact_chooser_view_builder_provider.dart`
- [ ] Audit `application_pre_cassette/` for remaining dependencies
- [ ] Move any needed code to proper locations
- [ ] Delete unused files from `application_pre_cassette/`

### Step 5.2: Verify No Dead Code

- [ ] Run analyzer: `flutter analyze`
- [ ] Check for unused imports/exports
- [ ] Remove any orphaned files

### Step 5.3: Update Documentation

- [ ] Update this folder's STATUS.md to `completed`
- [ ] Document pattern in feature folder README (if needed)
- [ ] Update any stale agent instructions referencing old pattern

### Step 5.4: Final Checkpoint

- [ ] All tests pass
- [ ] App behavior unchanged from user perspective
- [ ] No analyzer warnings
- [ ] Pattern is clean and documented
