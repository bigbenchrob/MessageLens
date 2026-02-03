# Proposal: Clean Up Contacts Feature for Cross-Surface Spec System

**Status**: DRAFT — Awaiting approval before implementation  
**Branch**: `Ftr.cntct-audit`  
**Created**: 2026-02-03

---

## Goal

Audit and clean up the contacts feature to fully conform to the cross-surface spec system architecture, removing legacy code paths while preserving any functionality that may have future utility.

## Background

The contacts feature has accumulated multiple architectural layers during the migration to the cross-surface spec system:

1. **`application/sidebar_cassette_spec/`** — New cross-surface compliant structure (coordinators, resolvers, widget_builders, resolver_tools)
2. **`application/`** — Mixed legacy folders (use_cases, spec_coordinators, cassette_builders, spec_cases, spec_widget_builders)
3. **`application_pre_cassette/`** — Pre-refactor providers (many still potentially in use)
4. **`presentation/cassettes/`** — Legacy cassette widgets that receive specs

### Current State

The cross-surface spec system has been partially implemented:
- ✅ `sidebar_cassette_spec/coordinators/` — Three coordinators exist and are being used
- ✅ `sidebar_cassette_spec/resolvers/` — Four resolvers exist
- ⚠️ `sidebar_cassette_spec/widget_builders/` — Widget builders exist but some bridge to legacy cassettes
- ⚠️ Multiple legacy folders remain with unclear usage status

### Known Issues

1. **`ContactGroupedPickerWidget`** — Does not display recent contacts section (functionality may be missing)
2. **`ContactChooserWidget`** — Contains recent contacts but uses adapters to legacy cassettes
3. **Legacy adapters** — `_ContactsFlatMenuAdapter` and `_ContactsEnhancedPickerAdapter` pass specs to legacy widgets

## Scope

### In Scope

1. Audit all files in `application/` subfolders to determine usage
2. Audit all files in `application_pre_cassette/` to determine usage
3. Identify which legacy cassettes in `presentation/cassettes/` are still needed
4. Document providers that may have future utility (e.g., recent contacts, favorites)
5. Remove confirmed-unused legacy code
6. Update widget builders to stop bridging to legacy cassettes where possible
7. Ensure recent contacts functionality is preserved in the final implementation

### Out of Scope

1. Migrating handles or messages features (separate work)
2. Changes to domain layer
3. Changes to infrastructure layer (repositories are fine)
4. New feature development

## Constraints

1. **No functionality loss** — Must verify recent contacts, favorites, grouped/flat switching all work
2. **Request approval before deletion** — Any file deletion must be approved by user
3. **All changes on feature branch** — Keep `main` clean until audit complete
4. **Passes analyzer** — All changes must pass `flutter analyze`

## Open Questions

1. Should `application_pre_cassette/` providers be moved to infrastructure or application layer, or remain as-is?
2. Is `favoriteContactsProvider` used anywhere currently, or is it for future use?
3. Should the `ContactChooserWidget` be the canonical path, replacing both `ContactFlatListWidget` and `ContactGroupedPickerWidget`?

## Success Criteria

1. [ ] All legacy folders in `application/` either deleted or documented as needed
2. [ ] `application_pre_cassette/` files audited — each marked as KEEP/MOVE/DELETE
3. [ ] No adapter bridges to legacy cassettes (or documented why they remain)
4. [ ] Recent contacts section displays in grouped picker
5. [ ] `flutter analyze` passes
6. [ ] Feature works in running app (manual testing)

## Risks

1. **Hidden dependencies** — Legacy code may be imported from unexpected places
2. **Functionality regression** — Recent contacts or favorites may break
3. **Time sink** — Deep archeology may be required to trace all usages

## Approval

- [ ] User approves proposal before checklist execution begins
