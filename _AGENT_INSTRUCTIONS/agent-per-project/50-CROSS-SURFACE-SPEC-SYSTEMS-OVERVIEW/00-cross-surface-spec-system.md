# Cross-Surface Spec System — Architecture Overview

## What This System Does

The app displays content across multiple **UI surfaces** — a sidebar, a center panel,
a right panel (future), tooltips (future). Each surface shows a mix of content from
different features (messages, contacts, handles, etc.).

The cross-surface spec system provides a **uniform architecture** for:
- Describing what each surface should display (via sealed spec classes)
- Routing specs to the owning feature
- Having features produce surface-appropriate payloads
- Composing those payloads into the final UI

---

## The Surfaces

| Surface | Sealed class | State model | Feature returns | Async? |
|---|---|---|---|---|
| **Left sidebar** (cassettes) | `CassetteSpec` | `CassetteRack` (ordered list) | `Future<SidebarCassetteCardViewModel>` | Yes |
| **Center panel** | `ViewSpec` | `PanelStack` (pages with tabs) | `Widget` | No |
| **Right panel** (future) | `ViewSpec` | `PanelStack` | `Widget` | No |
| **Tooltips** (future) | TBD | TBD | TBD | TBD |
| **Settings sidebar** (future) | `CassetteSpec` (settings mode) | `CassetteRack` | `Future<SidebarCassetteCardViewModel>` | Yes |

---

## The Universal Pattern

Despite surface-specific differences, every surface follows the same structural flow:

```
Surface state changes
    │
    ▼
App-level coordinator (in essentials/)
    │  iterates specs
    │  routes each to the owning feature
    │
    ▼
Feature coordinator (in feature/application/<surface>_spec/coordinators/)
    │  pattern-matches feature spec
    │  calls exactly one resolver
    │
    ▼
Resolver (in feature/application/<surface>_spec/resolvers/)
    │  receives explicit parameters
    │  performs logic, constructs payload
    │  calls widget builder for UI content
    │
    ▼
Widget builder (in feature/application/<surface>_spec/widget_builders/)
    │  assembles widgets from decided inputs
    │
    ▼
Payload returned to app-level coordinator
    │
    ▼
App-level applies chrome / layout → UI
```

Detailed documentation of this pattern: [52 — Feature Handling of X-Surface Specs](../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/)

---

## Spec Class Hierarchy

### Two-level sealed classes

Each surface uses a **two-level** sealed class structure:

1. **Top-level spec** (owned by essentials) — one variant per feature
2. **Feature spec** (owned by the feature) — one variant per view/behavior

Example — sidebar cassettes:

```dart
// Level 1: essentials-owned — which feature?
CassetteSpec.contacts(ContactsCassetteSpec spec)
CassetteSpec.messages(MessagesCassetteSpec spec)

// Level 2: feature-owned — which view within the feature?
ContactsCassetteSpec.contactChooser()
MessagesCassetteSpec.heatMap()
```

Example — panel content:

```dart
// Level 1: essentials-owned
ViewSpec.messages(MessagesSpec spec)
ViewSpec.contacts(ContactsSpec spec)

// Level 2: feature-owned
MessagesSpec.forContact(contactId: 42)
MessagesSpec.globalTimelineV2()
```

### Ownership rule

- **Level 1** (CassetteSpec, ViewSpec) → essentials owns definition and routing
- **Level 2** (feature specs) → the feature owns definition and interpretation

---

## State Models

### Sidebar: CassetteRack

A flat, ordered list of `CassetteSpec`. Supports:
- **Cascade**: placing spec A automatically determines specs B, C below it
- **Rack mutations**: replace-and-cascade, truncate, push, update

The rack is mode-dependent (`SidebarMode.messages` vs `SidebarMode.settings`).

Detail: [54 — Sidebar Cassette Spec System](../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/)

### Panels: PanelStack

A stack of `PanelPage` objects per `WindowPanel`. Supports:
- **Show**: replace with a single page
- **Push/pop**: stack pages (tabs)
- **Activate**: switch between stacked pages

Detail: [56 — View Spec Panel Content System](../56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/)

---

## App-Level Coordinators

Two app-level coordinators dispatch to features:

### CassetteWidgetCoordinator

- Watches `CassetteRackState` → iterates each `CassetteSpec`
- Routes to feature cassette coordinators via `spec.when(...)`
- Awaits `Future<SidebarCassetteCardViewModel>` from each feature
- Wraps each view model in card chrome (`SidebarCassetteCard`, etc.)
- Returns `List<Widget>`

**Location:** `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`

### PanelCoordinator

- Watches `PanelsViewState` → reads active page's `ViewSpec`
- Routes to feature view spec coordinators via `spec.when(...)`
- Gets `Widget` back synchronously
- Renders in `PanelStackSurface`

**Location:** `lib/essentials/navigation/application/panel_coordinator_provider.dart`

---

## Feature-Level Folder Convention

Every feature that participates in a surface has a dedicated folder:

```
feature/application/
  sidebar_cassette_spec/
    coordinators/
    resolvers/
    resolver_tools/
    widget_builders/
  view_spec/
    coordinators/
    resolvers/
    resolver_tools/
    widget_builders/
```

Each surface gets its own folder. The 4-subfolder structure is mandatory.

---

## Barrel File Convention

Features expose coordinators via `feature_level_providers.dart`:

```dart
export 'application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export 'application/view_spec/coordinators/view_spec_coordinator.dart';
```

App-level code imports features with aliases:

```dart
import '.../features/messages/feature_level_providers.dart' as messages_feature;
```

No other import path into a feature is permitted.

---

## Cross-Surface Interactions

Sidebar cassette widgets can trigger panel navigation:

```dart
// Inside a cassette widget builder (sidebar)
ref.read(panelsViewStateProvider(SidebarMode.messages).notifier).show(
  panel: WindowPanel.center,
  spec: ViewSpec.messages(MessagesSpec.forContact(contactId: contactId)),
);
```

This is the **only** permitted cross-surface interaction pattern:
dispatch a spec through the target surface's state provider.

Features must not reach into another surface's coordinator, rack state,
or rendering internals.

---

## Design Principles

1. **Specs are data, not behavior** — they describe intent, features interpret
2. **Surfaces are independent** — each has its own state model, coordinator, and rendering
3. **Features are unaware of surface chrome** — they return payloads, not wrapped UI
4. **The pattern is boring and uniform** — every surface works the same structural way
5. **Cross-surface coupling is minimal** — only through spec dispatch to state providers
6. **Compile-time safety** — sealed classes ensure exhaustive handling of all cases
