# Design Notes: Contacts Feature Cross-Surface Cleanup

**Branch**: `Ftr.cntct-audit`  
**Last Updated**: 2026-02-03

---

## Current Architecture Analysis

### Cross-Surface Compliant Structure (`application/sidebar_cassette_spec/`)

```
sidebar_cassette_spec/
├── coordinators/
│   ├── cassette_coordinator.dart          # Routes ContactsCassetteSpec
│   ├── contacts_settings_coordinator.dart # Routes ContactsSettingsSpec
│   └── info_cassette_coordinator.dart     # Routes ContactsInfoSpec
├── resolvers/
│   ├── contact_chooser_resolver.dart      # Flat vs grouped decision
│   ├── contact_hero_summary_resolver.dart # Hero summary card
│   ├── info_content_resolver.dart         # Info cassette content
│   └── short_names_resolver.dart          # Short names settings
├── resolver_tools/
│   └── picker_mode_decision.dart          # Pure function for flat/grouped
└── widget_builders/
    ├── contact_chooser_widget.dart        # ✅ Has recent contacts support
    ├── contact_flat_list_widget.dart      # Simple flat list
    ├── contact_grouped_picker_widget.dart # ❌ Missing recent contacts
    └── contact_hero_summary_widget.dart   # Hero summary display
```

### Legacy Structure Still Present

```
application/
├── cassette_builders/                     # LEGACY - likely unused
│   └── contact_short_names_cassette_builder_provider.dart
├── spec_coordinators/                     # LEGACY - duplicates sidebar_cassette_spec/coordinators
│   ├── cassette_coordinator.dart
│   └── info_cassette_coordinator.dart
├── spec_cases/                            # LEGACY - duplicates sidebar_cassette_spec/resolvers
│   └── info_content_resolver.dart
├── spec_widget_builders/                  # EMPTY
├── use_cases/                             # LEGACY - may have usage
│   └── contact_chooser_view_builder_provider.dart
├── settings/                              # KEEP - settings providers
└── view_spec/                             # KEEP - ViewSpec handling (separate concern)
```

### Pre-Cassette Providers (`application_pre_cassette/`)

This folder contains providers that predate the cassette system. Many may still be in use:

**Likely Still Needed:**
- `grouped_contacts_provider.dart` — Used by grouped picker
- `participants_for_picker_provider.dart` — Contact list data
- `contact_profile_provider.dart` — Profile data for hero summary
- `contact_hero_metrics_provider.dart` — Metrics display
- `contact_picker_mode.dart` — Enum/logic for flat vs grouped (used by resolver_tools)

**Possibly Future Use:**
- `favorite_contacts_provider.dart` — Favorites feature not yet implemented
- `favorite_contacts_repository_provider.dart` — Favorites persistence

**Unknown:**
- `chats_for_participant_provider.dart`
- `contact_timeline_provider.dart` / `contact_timeline_calculator.dart`
- `participant_merge_utils.dart`
- Various handle-related providers

---

## Key Observations

### 1. Widget Builder Divergence

Two widget builders exist for contact selection:
- `ContactChooserWidget` — Full implementation with recent contacts, adapters to legacy cassettes
- `ContactGroupedPickerWidget` — Simpler, no recent contacts, direct implementation

The resolver (`contact_chooser_resolver.dart`) appears to use different widget builders based on contact count, but there's confusion about which path includes recent contacts.

### 2. Adapter Pattern in Use

`ContactChooserWidget` uses adapter classes to bridge to legacy cassettes:
```dart
class _ContactsFlatMenuAdapter extends ConsumerWidget { ... }
class _ContactsEnhancedPickerAdapter extends ConsumerWidget { ... }
```

These pass specs to legacy `ContactsFlatMenuCassette` and `ContactsEnhancedPickerCassette`, which violates the cross-surface spec contract (widget builders should not interpret specs).

### 3. Recent Contacts Implementation

Recent contacts is implemented in `ContactChooserWidget`:
```dart
final asyncRecents = ref.watch(recentContactsProvider);
// ...
return _CombinedContactPicker(
  recents: recents,
  mainPicker: mainPicker,
  // ...
);
```

This shows recent contacts as rows at the top, separated by a divider from the main picker.

---

## Recommended Decisions

### Decision 1: Canonical Contact Picker Widget

**Question:** Should `ContactChooserWidget` be the canonical implementation?

**Recommendation:** YES — but it needs cleanup:
1. Remove adapter classes
2. Inline the flat list rendering (don't delegate to legacy cassette)
3. Inline the grouped picker rendering (don't delegate to legacy cassette)
4. Keep recent contacts functionality

### Decision 2: Legacy Folder Disposition

| Folder | Recommendation |
|--------|----------------|
| `spec_coordinators/` | DELETE — duplicates `sidebar_cassette_spec/coordinators/` |
| `spec_cases/` | DELETE — duplicates `sidebar_cassette_spec/resolvers/` |
| `spec_widget_builders/` | DELETE — empty |
| `cassette_builders/` | AUDIT then DELETE if unused |
| `use_cases/` | AUDIT — may have unique functionality |
| `settings/` | KEEP — separate concern |
| `view_spec/` | KEEP — separate concern |

### Decision 3: `application_pre_cassette/` Disposition

**Recommendation:** Audit each file for usage. Files that are:
- Used by current code → KEEP in place OR move to appropriate layer
- Unused but valuable → ARCHIVE with documentation
- Unused and obsolete → DELETE

### Decision 4: Presentation Cassettes

| File | Recommendation |
|------|----------------|
| `contacts_flat_menu_cassette.dart` | DELETE after inlining into widget builder |
| `contacts_enhanced_picker_cassette.dart` | DELETE after inlining into widget builder |
| `contact_hero_summary_cassette.dart` | AUDIT — may be used directly |
| `recent_contacts_cassette.dart` | DELETE — functionality merged into ContactChooserWidget |

---

## Migration Strategy

1. **First:** Complete audit and get user approval for deletion list
2. **Second:** Update `ContactChooserWidget` to stop using adapters
3. **Third:** Delete legacy cassettes
4. **Fourth:** Clean up redundant widget builders (`ContactFlatListWidget`, `ContactGroupedPickerWidget`)
5. **Fifth:** Delete legacy application folders
6. **Sixth:** Organize `application_pre_cassette/` providers

---

## Open Architectural Questions

1. **Where should `application_pre_cassette/` providers live long-term?**
   - Option A: Move to `infrastructure/providers/`
   - Option B: Move to `application/data_providers/`
   - Option C: Leave in place with better naming

2. **Should we have multiple widget builders or one smart widget?**
   - Option A: Single `ContactChooserWidget` handles all modes
   - Option B: Separate builders but called from single resolver

3. **How to handle async data in widget builders?**
   - Currently: Widget builders do `ref.watch()` on repositories
   - Alternative: Resolver provides all data, widget is pure
