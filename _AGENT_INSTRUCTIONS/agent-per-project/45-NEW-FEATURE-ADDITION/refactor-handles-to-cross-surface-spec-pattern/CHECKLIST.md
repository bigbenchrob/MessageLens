# Handles Feature Refactoring — Progress Checklist

## Phase 1: Create Folder Structure
- [ ] Create `sidebar_cassette_spec/coordinators/`
- [ ] Create `sidebar_cassette_spec/resolvers/`
- [ ] Create `sidebar_cassette_spec/resolver_tools/`
- [ ] Create `sidebar_cassette_spec/widget_builders/`
- [ ] Create `info_cassette_spec/coordinators/`
- [ ] Create `info_cassette_spec/resolvers/`
- [ ] Create `info_cassette_spec/resolver_tools/`
- [ ] Create `info_cassette_spec/widget_builders/`
- [ ] Create `settings_cassette_spec/coordinators/`
- [ ] Create `settings_cassette_spec/resolvers/`
- [ ] Create `settings_cassette_spec/resolver_tools/`
- [ ] Create `settings_cassette_spec/widget_builders/`
- [ ] Create `view_spec/coordinators/`
- [ ] Create `view_spec/resolvers/`
- [ ] Create `view_spec/resolver_tools/`
- [ ] Create `view_spec/widget_builders/`

## Phase 2: Migrate HandlesCassetteSpec Handling

### Coordinator
- [ ] Create `sidebar_cassette_spec/coordinators/cassette_coordinator.dart`
- [ ] Move `FeatureCassetteSpecCoordinator` logic from feature_level_providers
- [ ] Rename class to `HandlesCassetteCoordinator`
- [ ] Update to async `buildViewModel()` returning `Future<SidebarCassetteCardViewModel>`
- [ ] Update to call resolver `.resolve()` methods with explicit params

### Resolvers
- [ ] `stray_handles_review_resolver.dart` from stray_handles_review_cassette_builder_provider
- [ ] `stray_handles_type_switcher_resolver.dart` from stray_handles_type_switcher_cassette_builder_provider
- [ ] `stray_handles_mode_switcher_resolver.dart` from stray_handles_mode_switcher_cassette_builder_provider
- [ ] `unmatched_handles_resolver.dart` from unmatched_handles_cassette_builder_provider
- [ ] `stray_phones_resolver.dart` from stray_phone_numbers_cassette_builder_provider
- [ ] `stray_emails_resolver.dart` from stray_emails_cassette_builder_provider

## Phase 3: Migrate HandlesInfoCassetteSpec Handling

### Coordinator
- [ ] Move `info_cassette_coordinator.dart` to `info_cassette_spec/coordinators/`

### Resolvers
- [ ] Move `info_content_resolver.dart` to `info_cassette_spec/resolvers/`
- [ ] Migrate `handles_info_card_cassette_builder_provider.dart` to resolver

## Phase 4: Migrate HandlesSettingsSpec Handling

### Coordinator
- [ ] Create `settings_cassette_spec/coordinators/settings_coordinator.dart`
- [ ] Move `SettingsCassetteSpecCoordinator` logic from feature_level_providers

### Resolvers
- [ ] `manual_linking_resolver.dart` from manual_linking_cassette_builder_provider
- [ ] `spam_management_resolver.dart` from spam_management_cassette_builder_provider

## Phase 5: Migrate ViewSpec Handling

### Coordinator
- [ ] Create `view_spec/coordinators/view_spec_coordinator.dart`
- [ ] Move `ViewSpecCoordinator` logic from feature_level_providers

## Phase 6: Clean Up feature_level_providers.dart
- [ ] Remove `part` directive and generated file reference
- [ ] Remove all @riverpod class definitions
- [ ] Convert to pure export statements
- [ ] Export coordinators from new locations
- [ ] Export state providers if needed externally

## Phase 7: Delete Old Folders
- [ ] Delete `cassette_builders/`
- [ ] Delete `settings/`
- [ ] Delete `spec_cases/`
- [ ] Delete `spec_coordinators/`
- [ ] Delete `spec_widget_builders/`

## Phase 8: Verification
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Run `flutter analyze` - fix any issues
- [ ] Update `cassette_widget_coordinator_provider.dart` imports if needed
- [ ] Run app with `flutter run -d macos`
- [ ] Test stray handles feature functionality
- [ ] Commit changes

---

## Status

**Current Phase**: Not started
**Blockers**: None
**Notes**: 
