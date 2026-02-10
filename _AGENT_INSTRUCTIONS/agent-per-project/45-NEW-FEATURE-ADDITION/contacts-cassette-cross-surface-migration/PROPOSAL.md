---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2026-01-21
source_of_truth: doc
status: awaiting_approval
links:
  - ../README.md
  - ../../90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
tests: []
---

# Feature Proposal: Contacts Cassette Cross-Surface Migration

## Summary

Migrate the Contacts feature's cassette system from the legacy `FeatureCassetteSpecCoordinator` pattern to the new cross-surface spec architecture documented in `90-CROSS-SURFACE-SPEC-SYSTEMS/`.

The new architecture separates concerns into:
- **spec_coordinators/** — routing only, pattern-match on spec variants
- **spec_cases/** — logic, data access, meaning resolution
- **spec_widget_builders/** — widget assembly only

This migration follows the successful pattern established by `InfoCassetteCoordinator` and `InfoContentResolver`.

## Motivation

Current problems:

- `FeatureCassetteSpecCoordinator` in `feature_level_providers.dart` mixes routing with widget building.
- `contact_chooser_view_builder_provider.dart` handles loading states, error states, and widget composition in one monolithic function.
- Legacy code in `application_pre_cassette/` is referenced but doesn't follow the new architecture.
- The coordinator returns `SidebarCassetteCardViewModel` synchronously, but future data needs require async.
- Pattern doesn't scale to multi-surface systems (tooltips, onboarding) that may reuse contact meaning.

Goals:

- Align Contacts cassette handling with the cross-surface spec architecture.
- Enable async data resolution (repository calls, computed values) at the coordinator level.
- Separate routing, logic, and assembly into distinct layers.
- Create a reusable pattern for other features to follow.
- Prepare for future multi-surface content sharing (same meaning, different surfaces).

## High-Level Design

### Current Architecture

```
CassetteWidgetCoordinator (essentials)
  → FeatureCassetteSpecCoordinator.buildForSpec(ref, spec)
    → spec.map(...)
      → contactChooserViewBuilder(ref, spec)  // builds widget directly
        → returns SidebarCassetteCardViewModel (sync)
```

### Target Architecture

```
CassetteWidgetCoordinator (essentials)
  → ContactsCassetteCoordinator.buildViewModel(spec)  // async
    → switch (spec)
      → case contactChooser:
          ChooserContentResolver.resolve()
          ChooserWidgetBuilder.build()
          return SidebarCassetteCardViewModel
      → case contactHeroSummary:
          HeroSummaryResolver.resolve()
          HeroSummaryWidgetBuilder.build()
          return SidebarCassetteCardViewModel
      → case recentContacts:
          RecentContactsResolver.resolve()
          ChooserWidgetBuilder.build()
          return SidebarCassetteCardViewModel
```

### Key Principles

1. **Coordinators route only** — no data fetching, no widget building
2. **Resolvers own meaning** — data access, business rules, formatting
3. **Builders assemble only** — take resolver output, produce widgets
4. **Async by default** — all coordinator methods return `Future<ViewModel>`

## Scope

In scope:

- Create `ContactsCassetteCoordinator` in `spec_coordinators/`
- Create resolvers in `spec_cases/` for each spec variant
- Create builders in `spec_widget_builders/` for widget assembly
- Update `CassetteWidgetCoordinator` to call new coordinator
- Migrate `contactChooser`, `recentContacts`, and `contactHeroSummary` variants
- Remove or deprecate `FeatureCassetteSpecCoordinator`
- Remove `contact_chooser_view_builder_provider.dart` from `use_cases/`
- Clean up `application_pre_cassette/` dependencies

Out of scope:

- Changes to the presentation-layer cassette widgets themselves
- Changes to `ContactsInfoCassetteSpec` handling (already migrated)
- Changes to `ContactsSettingsSpec` handling
- New spec variants or features
- Multi-surface content sharing (deferred to future work)

## Implementation Strategy (Phased)

### Phase 1: Create Coordinator Structure (No Breaking Changes)

**Step 1.1: Create `ContactsCassetteCoordinator`**
- New file: `spec_coordinators/cassette_coordinator.dart`
- Pattern-match on `ContactsCassetteSpec` variants
- Initially delegate to existing `contactChooserViewBuilder` (temporary bridge)
- Return `Future<SidebarCassetteCardViewModel>`

**Step 1.2: Wire into `CassetteWidgetCoordinator`**
- Update essentials coordinator to call new feature coordinator
- Export from `feature_level_providers.dart`

**Checkpoint:** App runs, uses new coordinator, behavior unchanged.

### Phase 2: Migrate Contact Chooser

**Step 2.1: Create `ChooserContentResolver`**
- Move picker mode resolution from `contact_chooser_view_builder_provider.dart`
- Move contacts + recents data orchestration
- Return structured payload (not widget)

**Step 2.2: Create `ChooserWidgetBuilder`**
- Take resolver output, build picker widget
- Reuse `ContactsFlatMenuCassette` and `ContactsEnhancedPickerCassette`
- Handle loading/error states

**Step 2.3: Update coordinator for `contactChooser`**
- Call resolver → call builder → return view model
- Remove bridge to `contactChooserViewBuilder`

**Checkpoint:** Contact chooser works via new architecture.

### Phase 3: Migrate Recent Contacts Variant

**Step 3.1: Extend or create `RecentContactsResolver`**
- Handle `recentContacts` spec variant
- Reuse chooser logic where appropriate

**Step 3.2: Update coordinator for `recentContacts`**

**Checkpoint:** Recent contacts variant works.

### Phase 4: Migrate Hero Summary

**Step 4.1: Create `HeroSummaryResolver`**
- Resolve contact data for hero display
- Compute summary line, available actions

**Step 4.2: Create `HeroSummaryWidgetBuilder`**
- Build `ContactHeroSummaryCassette` content

**Step 4.3: Update coordinator for `contactHeroSummary`**

**Checkpoint:** Hero summary works via new architecture.

### Phase 5: Cleanup

**Step 5.1: Remove legacy code**
- Remove `FeatureCassetteSpecCoordinator` from `feature_level_providers.dart`
- Remove `contact_chooser_view_builder_provider.dart`
- Review `application_pre_cassette/` for remaining dependencies
- Delete unused files

**Step 5.2: Update documentation**
- Document pattern in feature folder
- Update any stale agent instructions

## File Structure After Migration

```
features/contacts/application/
├── spec_coordinators/
│   ├── cassette_coordinator.dart          # Routes ContactsCassetteSpec
│   └── info_cassette_coordinator.dart     # Routes ContactsInfoCassetteSpec (done)
├── spec_cases/
│   ├── info_content_resolver.dart         # (done)
│   ├── chooser_content_resolver.dart      # Picker mode, data orchestration
│   ├── recent_contacts_resolver.dart      # Recent contacts data (optional, may merge)
│   └── hero_summary_resolver.dart         # Hero card data
├── spec_widget_builders/
│   ├── chooser_widget_builder.dart        # Builds picker widgets
│   └── hero_summary_widget_builder.dart   # Builds hero widget
├── settings/                              # (unchanged)
├── cassette_builders/                     # (review for removal)
└── use_cases/                             # (remove after migration)
```

## Risks & Mitigations

- **Risk: Breaking changes during migration cause app failures.**
  - Mitigation: Phased approach with temporary bridges; each phase is a checkpoint.

- **Risk: Resolver/builder split adds unnecessary complexity.**
  - Mitigation: Start simple; combine resolver+builder if separation proves unhelpful.

- **Risk: Existing presentation widgets need modification.**
  - Mitigation: Keep presentation layer unchanged; builders wrap existing widgets.

- **Risk: `application_pre_cassette/` has hidden dependencies.**
  - Mitigation: Audit dependencies before removing; move needed code to infrastructure.

## Success Criteria

- `ContactsCassetteCoordinator` handles all three spec variants (`contactChooser`, `recentContacts`, `contactHeroSummary`)
- All coordinator methods are async
- No direct widget building in coordinators
- `FeatureCassetteSpecCoordinator` is removed from `feature_level_providers.dart`
- `contact_chooser_view_builder_provider.dart` is deleted
- App behavior is unchanged from user perspective
- Pattern is documented and reusable for other features
