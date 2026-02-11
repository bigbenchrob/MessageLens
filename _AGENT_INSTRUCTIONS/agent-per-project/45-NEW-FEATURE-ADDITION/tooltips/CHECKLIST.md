# Tooltips System - Implementation Checklist

**Status:** 🟢 Phase 4 - Manual Testing Required  
**Last Updated:** 2026-02-04  
**Branch:** `Ftr.tooltip`

---

## Pre-Implementation

- [x] Proposal approved by user
- [x] Open questions resolved (see PROPOSAL.md)
- [x] Design notes finalized

---

## Phase 1: Essentials Scaffolding

### Domain Layer
- [x] Create `lib/essentials/tooltips/domain/entities/tooltip_spec.dart`
  - [x] Define `TooltipSpec` sealed class with `contacts` variant
  - [x] Run build_runner for Freezed generation

### Application Layer
- [x] Create `lib/essentials/tooltips/application/tooltip_coordinator.dart`
  - [x] Route `TooltipSpec` variants to feature coordinators
  - [x] Return `TooltipContent` (text + optional config)

### Presentation Layer
- [x] Create `lib/essentials/tooltips/presentation/tooltip_wrapper.dart`
  - [x] Accept `TooltipSpec` and child widget
  - [x] Implement hover detection with debounce
  - [x] Resolve spec via coordinator on hover
  - [x] Display tooltip with theme-consistent styling

### Providers
- [x] Create `lib/essentials/tooltips/feature_level_providers.dart`
  - [x] Export public API

### Verification
- [x] `flutter analyze` passes
- [x] Build_runner generates all files

---

## Phase 2: Contacts Feature Integration

### Domain Layer
- [x] Create `lib/features/contacts/domain/spec_classes/contacts_tooltip_spec.dart`
  - [x] Define `ContactsTooltipSpec` sealed class with `editDisplayName` variant
  - [x] Run build_runner

### Application Layer
- [x] Create `lib/features/contacts/application/tooltips_spec/coordinators/contacts_tooltip_coordinator.dart`
  - [x] Route `ContactsTooltipSpec` variants to resolvers
  - [x] Resolve `editDisplayName` → "Edit display name"

### Providers
- [x] Update `lib/features/contacts/feature_level_providers.dart`
  - [x] Export tooltip coordinator and spec

### Wire to Essentials
- [x] Update `TooltipCoordinator` to import and call contacts coordinator

### Verification
- [x] `flutter analyze` passes
- [x] Build_runner generates all files

---

## Phase 3: Hero Card Update

### Presentation Changes
- [x] Update `lib/features/contacts/presentation/widgets/contact_highlight_row.dart`
  - [x] Replace "edit" text link with pencil icon
  - [x] Wrap icon in `TooltipWrapper`
  - [x] Pass `ContactsTooltipSpec.editDisplayName()`

### Visual Verification
- [x] Pencil icon displays correctly
- [x] Tooltip appears on hover after delay
- [x] Tooltip text reads "Edit display name"
- [x] Tooltip styling matches macOS aesthetic
- [x] Icon click still triggers edit dialog

---

## Phase 4: Polish & Edge Cases

- [x] Tooltip prefers above target (set `preferBelow: false` as default)
- [x] Auto-repositions if no room above (Flutter Tooltip handles this)
- [x] Test rapid mouse in/out (no flicker)
- [x] Test tooltip near edge of window (positioning)
- [x] Verify tooltip disappears when dialog opens
- [x] Dark mode styling correct
- [x] Light mode styling correct

---

## Phase 5: Documentation & Completion

- [x] Update `DESIGN_NOTES.md` with final decisions
- [x] Complete `TESTS.md` with manual verification results
- [x] Write `STATUS.md` marking feature complete
- [ ] Move folder to `40-FEATURES/tooltips-system/`
- [ ] Update cross-surface spec system docs if needed

---

## Sign-Off

- [x] User verifies tooltip behavior
- [x] User approves hero card appearance
- [x] Feature marked complete
