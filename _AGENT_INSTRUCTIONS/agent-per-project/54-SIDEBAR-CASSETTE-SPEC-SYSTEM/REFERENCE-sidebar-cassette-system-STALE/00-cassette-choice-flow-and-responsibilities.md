---
tier: project
scope: cassettes
owner: agent-per-project
last_reviewed: 2025-12-21
source_of_truth: doc
links:
  - ../README.md
  - ../60-NAVIGATION/navigation-overview.md
tests: []
---

# Cassette Content Control: Choice Flow & Responsibilities

## Goal

Keep **cassette-content decision logic inside the owning feature**.

Other parts of the app (like the cassette stack builder) should be able to say:

- “Give me a contact chooser cassette”

…without knowing whether the contacts feature will render a flat list, a grouped picker, or something else.

## Why this matters

If you model “flat vs enhanced” as different cassette spec variants (for example `ContactsCassetteSpec.flatMenu` vs `ContactsCassetteSpec.enhancedPicker`), you force the choice *outside* the contacts feature (often into essentials code like `CassetteWidgetCoordinator`).

That creates:

- Cross-feature coupling (essentials must know contacts UI variants)
- Harder evolution (changing contact chooser rules requires editing non-contacts code)
- Broken layering (business decisions leak into composition/plumbing layers)

Instead:

- **Essentials owns the cassette stack + spec plumbing**
- **Each feature owns its own decision rules and rendering choices**

## Canonical flow (Contacts: `contactChooser`)

### High-level flow

1. **A state change occurs** that affects the sidebar cassette stack (selection, navigation, etc.).
2. `CassetteWidgetCoordinator` (essentials) reacts by rebuilding the stack top-to-bottom from the current `CassetteRackState`.
3. For each `CassetteSpec` in the rack, the coordinator delegates to the owning feature’s coordinator.
   - Example: `CassetteSpec.contacts(ContactsCassetteSpec.contactChooser())`
4. `ContactsCassetteCoordinator` (feature-level) does **only spec-to-builder routing**:
   - Pattern-matches `ContactsCassetteSpec`
   - For `contactChooser`, delegates into the **application layer**
5. `contactChooserViewBuilderProvider` (application/use_cases) contains the **actual decision logic**:
   - Loads required data (e.g., total contact count)
   - Applies business rules (e.g., choose flat vs grouped)
   - Returns the appropriate presentation cassette widget
6. Presentation cassettes are **dumb renderers**:
   - `ContactsFlatMenuCassette` / `ContactsEnhancedPickerCassette`
   - No cross-feature knowledge
   - No business rule decisions

### Responsibility matrix

- `lib/essentials/sidebar/domain/entities/cassette_spec.dart`
  - Defines cassette stack structure (`CassetteSpec`, child chaining)
  - Defines feature cassette spec variants (e.g., `ContactsCassetteSpec.contactChooser()`)
  - Must not encode feature-specific chooser decisions

- `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`
  - Rebuilds the stack from `CassetteRackState`
  - Delegates to feature coordinators
  - Must not decide “flat vs grouped” (feature-owned)

- `lib/features/<feature>/feature_level_providers.dart` (feature coordinator)
  - Routes `FeatureCassetteSpec` → application-level view builder
  - Minimal logic: pattern matching + delegation only

- `lib/features/<feature>/application/use_cases/*view_builder_provider.dart`
  - Owns decision logic using real data
  - Coordinates which presentation cassette widget to build

- `lib/features/<feature>/presentation/cassettes/*`
  - Render UI and emit user events
  - Should remain interchangeable and independent

## Benefits

- Other features can request “a contact chooser” without knowing implementation
- Decision logic lives in the application layer where it belongs
- Cassettes don’t know about each other
- Matches the existing “spec → coordinator → view builder → dumb widget” pattern used in other features (e.g., messages)

## Notes for agents

- When adding a new chooser mode, do **not** add new `ContactsCassetteSpec.<mode>()` variants unless the *spec itself* truly represents different user intent/state.
- Prefer: keep a single `contactChooser` spec and extend the application-layer decision logic.
