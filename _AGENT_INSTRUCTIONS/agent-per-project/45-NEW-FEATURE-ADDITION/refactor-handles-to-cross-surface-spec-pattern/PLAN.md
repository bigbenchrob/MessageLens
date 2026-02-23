# Refactor Handles Feature to Cross-Surface Spec Pattern

## Goal

Refactor the handles feature folder structure to conform to the cross-surface spec
system design rules documented in `50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/`.

### Success Criteria

1. **Nothing in `handles/application/` should be left that does not conform to
   the prescribed pattern** — one surface folder per UI surface containing:
   `coordinators/`, `resolvers/`, `resolver_tools/`, `widget_builders/`

2. **No spec interpretation code in `feature_level_providers.dart`** — this file
   should strictly be a barrel file exporting:
   - Spec class definitions
   - Coordinator providers
   - Enums needed externally

---

## Current Structure (non-conforming)

```
handles/application/
├── cassette_builders/                    # Flat folder with "builder" providers
│   ├── handles_info_card_cassette_builder_provider.dart
│   ├── stray_emails_cassette_builder_provider.dart
│   ├── stray_handles_mode_switcher_cassette_builder_provider.dart
│   ├── stray_handles_review_cassette_builder_provider.dart
│   ├── stray_handles_type_switcher_cassette_builder_provider.dart
│   ├── stray_phone_numbers_cassette_builder_provider.dart
│   └── unmatched_handles_cassette_builder_provider.dart
├── settings/                             # Settings builders
│   ├── manual_linking_cassette_builder_provider.dart
│   └── spam_management_cassette_builder_provider.dart
├── spec_cases/                           # Misplaced resolver
│   └── info_content_resolver.dart
├── spec_coordinators/                    # Misplaced coordinator
│   └── info_cassette_coordinator.dart
├── spec_widget_builders/                 # Empty
└── state/                                # State providers (can stay)
    └── stray_handle_mode_provider.dart
```

### Problems

1. No surface-organized folders (`sidebar_cassette_spec/`, `view_spec/`, etc.)
2. "Builder" providers doing resolver work (business logic + widget construction)
3. `feature_level_providers.dart` contains spec interpretation logic (`spec.when(...)`)
4. Disconnected folder naming (cassette_builders, spec_cases, spec_coordinators)
5. Missing `resolver_tools/` and `widget_builders/` folders

---

## Target Structure (conforming)

```
handles/application/
├── sidebar_cassette_spec/               # HandlesCassetteSpec surface
│   ├── coordinators/
│   │   └── cassette_coordinator.dart    # Pattern-matches HandlesCassetteSpec
│   ├── resolvers/
│   │   ├── stray_handles_review_resolver.dart
│   │   ├── stray_handles_type_switcher_resolver.dart
│   │   ├── stray_handles_mode_switcher_resolver.dart
│   │   ├── unmatched_handles_resolver.dart
│   │   ├── stray_phones_resolver.dart
│   │   └── stray_emails_resolver.dart
│   ├── resolver_tools/                   # Empty initially
│   └── widget_builders/
│       ├── stray_handles_review_widget_builder.dart
│       ├── stray_handles_type_switcher_widget_builder.dart
│       └── stray_handles_mode_switcher_widget_builder.dart
├── info_cassette_spec/                   # HandlesInfoCassetteSpec surface
│   ├── coordinators/
│   │   └── info_cassette_coordinator.dart
│   ├── resolvers/
│   │   └── info_content_resolver.dart
│   ├── resolver_tools/
│   └── widget_builders/
├── settings_cassette_spec/              # HandlesSettingsSpec surface
│   ├── coordinators/
│   │   └── settings_coordinator.dart    # Pattern-matches HandlesSettingsSpec
│   ├── resolvers/
│   │   ├── manual_linking_resolver.dart
│   │   └── spam_management_resolver.dart
│   ├── resolver_tools/
│   └── widget_builders/
├── view_spec/                            # HandlesSpec (center panel) - future
│   ├── coordinators/
│   │   └── view_spec_coordinator.dart
│   ├── resolvers/
│   ├── resolver_tools/
│   └── widget_builders/
└── state/                                # Non-surface state (keep as-is)
    └── stray_handle_mode_provider.dart
```

---

## Reference: Contacts Feature (conforming)

```
contacts/application/
├── sidebar_cassette_spec/
│   ├── coordinators/
│   │   ├── cassette_coordinator.dart
│   │   ├── contacts_settings_coordinator.dart
│   │   └── info_cassette_coordinator.dart
│   ├── resolvers/
│   │   ├── contact_chooser_resolver.dart
│   │   ├── contact_hero_summary_resolver.dart
│   │   └── contact_selection_control_resolver.dart
│   ├── resolver_tools/
│   └── widget_builders/
│       ├── contact_chooser_widget_builder.dart
│       └── contact_hero_summary_widget_builder.dart
├── tooltips_spec/
│   └── coordinators/
│       └── contacts_tooltip_coordinator.dart
├── view_spec/
│   └── view_spec_coordinator.dart
└── services/
```

---

## Stepwise Migration Plan

### Phase 1: Create Folder Structure

1. Create `handles/application/sidebar_cassette_spec/` with subfolders
2. Create `handles/application/info_cassette_spec/` with subfolders
3. Create `handles/application/settings_cassette_spec/` with subfolders
4. Create `handles/application/view_spec/` with subfolders (placeholder)

### Phase 2: Migrate HandlesCassetteSpec Handling

**Coordinator:**
1. Move `FeatureCassetteSpecCoordinator` from `feature_level_providers.dart` to
   `sidebar_cassette_spec/coordinators/cassette_coordinator.dart`
2. Rename to `HandlesCassetteCoordinator`
3. Update to call resolvers with explicit params (not specs)

**Resolvers (from cassette_builders/):**
For each builder provider:
1. Move to `sidebar_cassette_spec/resolvers/`
2. Rename from `*_cassette_builder_provider.dart` to `*_resolver.dart`
3. Refactor provider class name to `*Resolver`
4. Extract widget construction to widget_builders/ if needed
5. Ensure resolver receives explicit params, not specs

| Old file | New location |
|---|---|
| `stray_handles_review_cassette_builder_provider.dart` | `resolvers/stray_handles_review_resolver.dart` |
| `stray_handles_type_switcher_cassette_builder_provider.dart` | `resolvers/stray_handles_type_switcher_resolver.dart` |
| `stray_handles_mode_switcher_cassette_builder_provider.dart` | `resolvers/stray_handles_mode_switcher_resolver.dart` |
| `unmatched_handles_cassette_builder_provider.dart` | `resolvers/unmatched_handles_resolver.dart` |
| `stray_phone_numbers_cassette_builder_provider.dart` | `resolvers/stray_phones_resolver.dart` |
| `stray_emails_cassette_builder_provider.dart` | `resolvers/stray_emails_resolver.dart` |

### Phase 3: Migrate HandlesInfoCassetteSpec Handling

1. Move `info_cassette_coordinator.dart` from `spec_coordinators/` to
   `info_cassette_spec/coordinators/`
2. Move `info_content_resolver.dart` from `spec_cases/` to
   `info_cassette_spec/resolvers/`
3. Move `handles_info_card_cassette_builder_provider.dart` to
   `info_cassette_spec/resolvers/` (or merge with info_content_resolver)

### Phase 4: Migrate HandlesSettingsSpec Handling

1. Move `SettingsCassetteSpecCoordinator` from `feature_level_providers.dart` to
   `settings_cassette_spec/coordinators/settings_coordinator.dart`
2. Move `manual_linking_cassette_builder_provider.dart` to
   `settings_cassette_spec/resolvers/manual_linking_resolver.dart`
3. Move `spam_management_cassette_builder_provider.dart` to
   `settings_cassette_spec/resolvers/spam_management_resolver.dart`

### Phase 5: Migrate ViewSpec Handling (Placeholder)

1. Move `ViewSpecCoordinator` from `feature_level_providers.dart` to
   `view_spec/coordinators/view_spec_coordinator.dart`
2. Keep as placeholder until HandlesSpec is defined

### Phase 6: Clean Up feature_level_providers.dart

Convert to pure barrel file:

```dart
// handles/feature_level_providers.dart

// Coordinators
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/info_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/settings_cassette_spec/coordinators/settings_coordinator.dart';
export './application/view_spec/coordinators/view_spec_coordinator.dart';

// Spec classes (if feature-owned)
// export './domain/spec_classes/handles_spec.dart';

// State providers needed externally
export './application/state/stray_handle_mode_provider.dart';
```

**Remove:**
- `part 'feature_level_providers.g.dart';`
- All `@riverpod` class definitions
- All imports except those being re-exported

### Phase 7: Delete Old Folders

Once migration is verified:
1. Delete `cassette_builders/`
2. Delete `settings/`
3. Delete `spec_cases/`
4. Delete `spec_coordinators/`
5. Delete `spec_widget_builders/`

### Phase 8: Update Imports

1. Update `cassette_widget_coordinator_provider.dart` if import paths changed
2. Update any other essentials code that imports handles feature
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Run `flutter analyze` and fix any issues

---

## Checklist

- [ ] Phase 1: Create folder structure
- [ ] Phase 2: Migrate HandlesCassetteSpec handling
- [ ] Phase 3: Migrate HandlesInfoCassetteSpec handling
- [ ] Phase 4: Migrate HandlesSettingsSpec handling
- [ ] Phase 5: Migrate ViewSpec handling
- [ ] Phase 6: Clean up feature_level_providers.dart
- [ ] Phase 7: Delete old folders
- [ ] Phase 8: Update imports, build, verify
- [ ] Final: Run app, test stray handles feature

---

## Notes

- The `state/` folder can remain — it's for non-surface-specific state management
- Widget builders may be optional if widgets are simple enough to inline in resolvers
- The contacts feature uses `services/` for business services — handles may need this too
- Generated `.g.dart` files will be recreated by build_runner after moves
