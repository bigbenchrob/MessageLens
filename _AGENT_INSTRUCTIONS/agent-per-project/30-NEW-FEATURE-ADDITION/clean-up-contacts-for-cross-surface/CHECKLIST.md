# Checklist: Clean Up Contacts Feature for Cross-Surface Spec System

**Branch**: `Ftr.cntct-audit`  
**Status**: NOT STARTED  
**Last Updated**: 2026-02-03

---

## Phase 1: Discovery — Audit Current Structure

### 1.1 Audit `application/` subfolders

#### `application/cassette_builders/` (LIKELY LEGACY)
- [ ] `contact_short_names_cassette_builder_provider.dart` — Check usages
- [ ] Decision: DELETE / KEEP / MOVE

#### `application/spec_coordinators/` (LIKELY LEGACY)
- [ ] `cassette_coordinator.dart` — Compare with `sidebar_cassette_spec/coordinators/cassette_coordinator.dart`
- [ ] `info_cassette_coordinator.dart` — Compare with `sidebar_cassette_spec/coordinators/info_cassette_coordinator.dart`
- [ ] Decision: DELETE / KEEP / MOVE

#### `application/spec_cases/` 
- [ ] `info_content_resolver.dart` — Compare with `sidebar_cassette_spec/resolvers/info_content_resolver.dart`
- [ ] Decision: DELETE / KEEP / MOVE

#### `application/spec_widget_builders/` (EMPTY)
- [ ] Confirm empty and DELETE folder

#### `application/use_cases/`
- [ ] `contact_chooser_view_builder_provider.dart` — Check usages
- [ ] Decision: DELETE / KEEP / MOVE

#### `application/view_spec/`
- [ ] Audit contents (ViewSpec handling, separate from cassette specs)
- [ ] Decision: Keep as-is (different concern)

#### `application/settings/`
- [ ] Audit contents (settings providers)
- [ ] Decision: Keep as-is (different concern)

---

### 1.2 Audit `application_pre_cassette/` (HIGH VALUE — MANY PROVIDERS)

| File | Status | Notes |
|------|--------|-------|
| `chats_for_participant_provider.dart` | ⬜ AUDIT | |
| `contact_group_key.dart` | ⬜ AUDIT | Domain-like, may move to domain |
| `contact_hero_metrics_provider.dart` | ⬜ AUDIT | |
| `contact_picker_mode.dart` | ⬜ AUDIT | Used by resolver_tools? |
| `contact_profile_provider.dart` | ⬜ AUDIT | |
| `contact_timeline_calculator.dart` | ⬜ AUDIT | |
| `contact_timeline_provider.dart` | ⬜ AUDIT | |
| `favorite_contacts_provider.dart` | ⬜ AUDIT | May be for future use |
| `favorite_contacts_repository_provider.dart` | ⬜ AUDIT | |
| `grouped_contacts_provider.dart` | ⬜ AUDIT | |
| `manual_handle_link_service.dart` | ⬜ AUDIT | |
| `manual_links_list_provider.dart` | ⬜ AUDIT | |
| `messages_for_handle_provider.dart` | ⬜ AUDIT | |
| `participant_merge_utils.dart` | ⬜ AUDIT | |
| `participants_for_picker_provider.dart` | ⬜ AUDIT | |
| `participants_search_provider.dart` | ⬜ AUDIT | |
| `sorted_chats_for_participant_provider.dart` | ⬜ AUDIT | |
| `unmatched_handles_provider.dart` | ⬜ AUDIT | |
| `virtual_participants_provider.dart` | ⬜ AUDIT | |

---

### 1.3 Audit `presentation/cassettes/` (LEGACY WIDGETS)

| File | Status | Notes |
|------|--------|-------|
| `contact_hero_summary_cassette.dart` | ⬜ AUDIT | Used by widget builders? |
| `contacts_enhanced_picker_cassette.dart` | ⬜ AUDIT | Used by _ContactsEnhancedPickerAdapter |
| `contacts_flat_menu_cassette.dart` | ⬜ AUDIT | Used by _ContactsFlatMenuAdapter |
| `recent_contacts_cassette.dart` | ⬜ AUDIT | May be unused (merged into chooser?) |
| `settings/contact_short_names_settings_cassette.dart` | ⬜ AUDIT | |

---

## Phase 2: Analysis — Document Findings

- [ ] Create table of all files with determination (KEEP/MOVE/DELETE/ARCHIVE)
- [ ] Document any providers needed for future features (e.g., favorites)
- [ ] Identify which widget builders are canonical vs. redundant
- [ ] Identify functionality gaps (e.g., recent contacts in grouped picker)

---

## Phase 3: Cleanup — Remove Legacy (REQUIRES APPROVAL)

### 3.1 Files confirmed for deletion
*(List files here after Phase 2 analysis, get user approval)*

- [ ] User approval received for deletion list

### 3.2 Execute deletions
*(Execute only after approval)*

---

## Phase 4: Consolidation — Fix Remaining Issues

- [ ] Remove adapter bridges where possible
- [ ] Ensure `ContactChooserWidget` or grouped picker shows recent contacts
- [ ] Update `feature_level_providers.dart` to reflect final structure
- [ ] Run `flutter analyze` — must pass
- [ ] Run `dart run build_runner build` — regenerate if needed

---

## Phase 5: Verification

- [ ] Manual test: Contact chooser shows recent contacts at top
- [ ] Manual test: Flat menu displays for < 6 contacts
- [ ] Manual test: Grouped picker displays for ≥ 6 contacts
- [ ] Manual test: Selecting contact shows hero summary
- [ ] Manual test: Contact short names settings works
- [ ] `flutter analyze` passes with no issues

---

## Phase 6: Completion

- [ ] Commit all changes with clear message
- [ ] Merge `Ftr.cntct-audit` to `main`
- [ ] Update STATUS.md
- [ ] Move documentation to `40-FEATURES/` if warranted
