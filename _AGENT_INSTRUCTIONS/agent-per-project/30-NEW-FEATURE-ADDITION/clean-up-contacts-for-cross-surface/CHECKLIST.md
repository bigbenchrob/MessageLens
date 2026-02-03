# Checklist: Clean Up Contacts Feature for Cross-Surface Spec System

**Branch**: `Ftr.cntct-audit`  
**Status**: PHASE 4 COMPLETE  
**Last Updated**: 2026-02-03

> **⚠️ AUDIT CORRECTION:** Three files initially marked DELETE were discovered to be  
> used by the **messages feature**. They have been restored and marked KEEP.  
> These should eventually move to the messages feature (better DDD ownership).

---

## Phase 1: Discovery — Audit Current Structure

### 1.1 Audit `application/` subfolders

#### `application/cassette_builders/` (LIKELY LEGACY)
- [x] `contact_short_names_cassette_builder_provider.dart` — Check usages
- [x] **Decision: DELETE** — No usages found outside self-references

#### `application/spec_coordinators/` (LIKELY LEGACY)
- [x] `cassette_coordinator.dart` — Compare with `sidebar_cassette_spec/coordinators/cassette_coordinator.dart`
- [x] `info_cassette_coordinator.dart` — Compare with `sidebar_cassette_spec/coordinators/info_cassette_coordinator.dart`
- [x] **Decision: DELETE** — Both files duplicated in `sidebar_cassette_spec/coordinators/`. 
  - feature_level_providers.dart exports from NEW location
  - Both generate same provider names (`contactsCassetteCoordinatorProvider`, etc.)
  - Old location is unused legacy

#### `application/spec_cases/` 
- [x] `info_content_resolver.dart` — Compare with `sidebar_cassette_spec/resolvers/info_content_resolver.dart`
- [x] **Decision: DELETE** — USED BY OLD spec_coordinators/info_cassette_coordinator.dart
  - Old coordinator imports this; new coordinator has its own resolver
  - Will be deleted with spec_coordinators/

#### `application/spec_widget_builders/` (EMPTY)
- [x] Confirm empty and DELETE folder
- [x] **Decision: DELETE** — Empty folder

#### `application/use_cases/`
- [x] `contact_chooser_view_builder_provider.dart` — Check usages
- [x] **Decision: DELETE** — No live usages; only referenced in old migration docs

#### `application/view_spec/`
- [x] Audit contents (ViewSpec handling, separate from cassette specs)
- [x] **Decision: KEEP** — Different concern (center panel navigation)

#### `application/settings/`
- [x] Audit contents (settings providers)
- [x] **Decision: KEEP** — Different concern (user preferences)

---

### 1.2 Audit `application_pre_cassette/` (HIGH VALUE — MANY PROVIDERS)

**AUDIT FINDINGS:** Several files are actively imported:

| File | Status | Notes |
|------|--------|-------|
| `chats_for_participant_provider.dart` | 🗑️ DELETE | Only used by sorted_chats (which is also unused) |
| `contact_group_key.dart` | ✅ KEEP | Used by grouped_contacts_provider.dart (which is KEEP) |
| `contact_hero_metrics_provider.dart` | 🗑️ DELETE | No usages found |
| `contact_picker_mode.dart` | ✅ KEEP | Used by sidebar_cassette_spec/widget_builders/contact_chooser_widget.dart |
| `contact_profile_provider.dart` | ✅ KEEP | **USED BY MESSAGES FEATURE** (heatmap cassette) |
| `contact_timeline_calculator.dart` | ⚠️ KEEP | **AUDIT FIX:** Used by messages feature (heatmap) |
| `contact_timeline_provider.dart` | ⚠️ KEEP | **AUDIT FIX:** Used by messages feature (heatmap) |
| `favorite_contacts_provider.dart` | 📦 ARCHIVE | No usages; keep for future favorites feature |
| `favorite_contacts_repository_provider.dart` | 📦 ARCHIVE | No usages; keep for future favorites feature |
| `grouped_contacts_provider.dart` | ✅ KEEP | Used by presentation/widgets/grouped_contact_selector.dart |
| `manual_handle_link_service.dart` | 📦 ARCHIVE | No usages but mentioned in virtual-overlay-contacts proposal |
| `manual_links_list_provider.dart` | 🗑️ DELETE | No usages found |
| `messages_for_handle_provider.dart` | ⚠️ KEEP | **AUDIT FIX:** Used by messages feature (messages_for_handle_view) |
| `participant_merge_utils.dart` | ✅ KEEP | Used by infrastructure/repositories/contacts_list_repository.dart |
| `participants_for_picker_provider.dart` | ✅ KEEP | Used by presentation/widgets/contact_picker_dialog.dart |
| `participants_search_provider.dart` | 🗑️ DELETE | No usages found |
| `sorted_chats_for_participant_provider.dart` | 🗑️ DELETE | No usages found |
| `unmatched_handles_provider.dart` | 📦 ARCHIVE | Only used by manual_handle_link_service (which is archive) |
| `virtual_participants_provider.dart` | ✅ KEEP | Used by infrastructure/repositories/contacts_list_repository.dart |

**Legend:** ✅ KEEP (active use) | 🗑️ DELETE (no use) | 📦 ARCHIVE (future use)

---

### 1.3 Audit `presentation/cassettes/` (LEGACY WIDGETS)

| File | Status | Notes |
|------|--------|-------|
| `contact_hero_summary_cassette.dart` | 🗑️ DELETED | Replaced by widget_builders/contact_hero_summary_widget.dart |
| `contacts_enhanced_picker_cassette.dart` | 🗑️ DELETED | Replaced by widget_builders/contact_grouped_picker_widget.dart + recent_contacts_section.dart |
| `contacts_flat_menu_cassette.dart` | 🗑️ DELETED | Replaced by widget_builders/contact_flat_list_widget.dart + recent_contacts_section.dart |
| `recent_contacts_cassette.dart` | 🗑️ DELETED | Functionality moved to widget_builders/recent_contacts_section.dart |
| `settings/contact_short_names_settings_cassette.dart` | ✅ KEEP | Used by settings resolver |

---

## Phase 2: Analysis — Document Findings

- [x] Create table of all files with determination (KEEP/MOVE/DELETE/ARCHIVE)
- [x] Document any providers needed for future features (e.g., favorites)
- [x] Identify which widget builders are canonical vs. redundant
- [ ] Identify functionality gaps (e.g., recent contacts in grouped picker)

### Summary Table

| Path | Decision | Reason |
|------|----------|--------|
| **application/cassette_builders/** | 🗑️ DELETE ALL | No usages |
| **application/spec_coordinators/** | 🗑️ DELETE ALL | Duplicates sidebar_cassette_spec/coordinators/ |
| **application/spec_cases/** | 🗑️ DELETE ALL | Only used by deleted spec_coordinators |
| **application/spec_widget_builders/** | 🗑️ DELETE ALL | Empty folder |
| **application/use_cases/** | 🗑️ DELETE ALL | No live usages |
| **application/view_spec/** | ✅ KEEP | Different concern (center panel nav) |
| **application/settings/** | ✅ KEEP | Different concern (user prefs) |
| **application_pre_cassette/chats_for_participant_provider.dart** | 🗑️ DELETE | Unused |
| **application_pre_cassette/contact_group_key.dart** | ✅ KEEP | Used by grouped_contacts_provider |
| **application_pre_cassette/contact_hero_metrics_provider.dart** | 🗑️ DELETE | Unused |
| **application_pre_cassette/contact_picker_mode.dart** | ✅ KEEP | Used by widget_builders |
| **application_pre_cassette/contact_profile_provider.dart** | ✅ KEEP | Used by messages feature |
| **application_pre_cassette/contact_timeline_calculator.dart** | ⚠️ KEEP | **AUDIT FIX:** Used by messages feature |
| **application_pre_cassette/contact_timeline_provider.dart** | ⚠️ KEEP | **AUDIT FIX:** Used by messages feature |
| **application_pre_cassette/favorite_contacts_provider.dart** | 📦 ARCHIVE | Future feature |
| **application_pre_cassette/favorite_contacts_repository_provider.dart** | 📦 ARCHIVE | Future feature |
| **application_pre_cassette/grouped_contacts_provider.dart** | ✅ KEEP | Used by presentation |
| **application_pre_cassette/manual_handle_link_service.dart** | 📦 ARCHIVE | Future feature (virtual contacts) |
| **application_pre_cassette/manual_links_list_provider.dart** | 🗑️ DELETE | Unused |
| **application_pre_cassette/messages_for_handle_provider.dart** | ⚠️ KEEP | **AUDIT FIX:** Used by messages feature |
| **application_pre_cassette/participant_merge_utils.dart** | ✅ KEEP | Used by repository |
| **application_pre_cassette/participants_for_picker_provider.dart** | ✅ KEEP | Used by dialog |
| **application_pre_cassette/participants_search_provider.dart** | 🗑️ DELETE | Unused |
| **application_pre_cassette/sorted_chats_for_participant_provider.dart** | 🗑️ DELETE | Unused |
| **application_pre_cassette/unmatched_handles_provider.dart** | 📦 ARCHIVE | Future feature |
| **application_pre_cassette/virtual_participants_provider.dart** | ✅ KEEP | Used by repository |
| **presentation/cassettes/contact_hero_summary_cassette.dart** | 🗑️ DELETE | Replaced by widget_builder |
| **presentation/cassettes/recent_contacts_cassette.dart** | 🗑️ DELETE | No usages |

### Future Feature Providers (ARCHIVE, do not delete)

These providers exist for planned features and should be preserved:

1. `favorite_contacts_provider.dart` — Favorites feature
2. `favorite_contacts_repository_provider.dart` — Favorites persistence
3. `manual_handle_link_service.dart` — Virtual contacts feature
4. `unmatched_handles_provider.dart` — Virtual contacts feature

### Functionality Gap Identified

⚠️ **Recent Contacts Section Missing from ContactGroupedPickerWidget**

The `ContactsEnhancedPickerCassette` has a `_CombinedContactPicker` that includes recent contacts at the top. However, the new `ContactGroupedPickerWidget` does NOT include this section. The recent contacts functionality may need to be preserved/migrated.

---

## Phase 3: Cleanup — Remove Legacy (REQUIRES APPROVAL)

### 3.1 Files confirmed for deletion

**Folders to delete entirely:**
- `application/cassette_builders/`
- `application/spec_coordinators/`
- `application/spec_cases/`
- `application/spec_widget_builders/`
- `application/use_cases/`

**Individual files to delete from `application_pre_cassette/`:**
- `chats_for_participant_provider.dart` (+ .g.dart)
- `contact_hero_metrics_provider.dart` (+ .g.dart)
- `contact_timeline_calculator.dart`
- `contact_timeline_provider.dart` (+ .g.dart)
- `manual_links_list_provider.dart` (+ .g.dart)
- `messages_for_handle_provider.dart` (+ .g.dart)
- `participants_search_provider.dart` (+ .g.dart)
- `sorted_chats_for_participant_provider.dart` (+ .g.dart)

**Individual files to delete from `presentation/cassettes/`:**
- `contact_hero_summary_cassette.dart`
- `recent_contacts_cassette.dart`

- [x] **User approval received for deletion list**

### 3.2 Execute deletions
*(Executed 2026-02-03)*

**Deleted folders:**
- [x] `application/cassette_builders/`
- [x] `application/spec_coordinators/`
- [x] `application/spec_cases/`
- [x] `application/spec_widget_builders/`
- [x] `application/use_cases/`

**Deleted from application_pre_cassette/:**
- [x] `chats_for_participant_provider.dart` (+ .g.dart)
- [x] `contact_hero_metrics_provider.dart` (+ .g.dart)
- [x] `manual_links_list_provider.dart` (+ .g.dart)
- [x] `participants_search_provider.dart` (+ .g.dart)
- [x] `sorted_chats_for_participant_provider.dart` (+ .g.dart)

**Deleted from presentation/cassettes/:**
- [x] `contact_hero_summary_cassette.dart`
- [x] `recent_contacts_cassette.dart`

**Deleted test:**
- [x] `test/features/contacts/application/participants_search_provider_test.dart`

**⚠️ KEPT (audit correction - cross-feature dependencies):**
- `contact_timeline_provider.dart` (+ .g.dart) — used by messages feature
- `contact_timeline_calculator.dart` — used by messages feature
- `messages_for_handle_provider.dart` (+ .g.dart) — used by messages feature

---

## Phase 4: Consolidation — Fix Remaining Issues
*(Executed 2026-02-03)*

- [x] Remove adapter bridges where possible
  - Created `RecentContactsSection` widget for shared recent contacts display
  - Updated `contact_chooser_resolver.dart` to wrap pickers with recent contacts
  - Deleted adapter `contact_chooser_widget.dart` (no longer needed)
  - Deleted legacy cassettes `contacts_flat_menu_cassette.dart` and `contacts_enhanced_picker_cassette.dart`
- [x] Ensure `ContactChooserWidget` or grouped picker shows recent contacts
  - `RecentContactsSection` now displays at top of both flat and grouped pickers
  - Resolver decides whether to show recent contacts (business logic owned by resolver)
- [x] Update `feature_level_providers.dart` to reflect final structure
  - Already correct: exports coordinators, specs, settings (NOT resolvers or widget builders)
- [x] Run `flutter analyze` — must pass ✅
- [x] Run `dart run build_runner build` — regenerate if needed ✅

**New files created:**
- `widget_builders/recent_contacts_section.dart` — Shared recent contacts display widget

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
