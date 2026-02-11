# Universal Spec Handling Pattern

## The Problem This Solves

The app has multiple UI surfaces (sidebar, center panel, right sidebar, tooltips…)
that each need features to produce content. Without a shared pattern, each surface
invents its own wiring and features accumulate inconsistent handling code.

This document defines the **one pattern** all surfaces use.

---

## The Flow

```
┌─────────────────────────────────────────────────────────┐
│  essentials (app-level)                                 │
│                                                         │
│  Surface state (rack state, panel state…)               │
│       │                                                 │
│       ▼                                                 │
│  App-level coordinator                                  │
│  • Iterates specs                                       │
│  • Routes each spec to the owning feature               │
│  • Wraps returned payload in surface chrome              │
│                                                         │
│       │  calls feature via barrel import                │
│       ▼                                                 │
├─────────────────────────────────────────────────────────┤
│  feature (application layer)                            │
│                                                         │
│  Feature coordinator                                    │
│  • Pattern-matches feature spec                         │
│  • Extracts payload values                              │
│  • Calls exactly one resolver                           │
│       │                                                 │
│       ▼                                                 │
│  Resolver                                               │
│  • Receives explicit parameters (never the spec)        │
│  • Performs domain lookups / logic                       │
│  • Calls widget builder to assemble UI subtree          │
│  • Returns the surface-appropriate payload              │
│       │                                                 │
│       ▼                                                 │
│  Widget builder                                         │
│  • Receives fully-decided inputs                        │
│  • Assembles widgets — no decisions, no IO              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

The payload returned to the app-level coordinator varies by surface:

| Surface | Coordinator returns | Async? |
|---|---|---|
| Sidebar cassette | `Future<SidebarCassetteCardViewModel>` | Yes |
| View spec (center/right panel) | `Widget` | No (sync) |

Future surfaces (tooltips, settings sidebar, etc.) will define their own
payload type but follow the same structural flow.

---

## The 4-Folder Structure

Every feature that handles a surface spec **must** organize its application-layer
code in this structure:

```
feature_name/
  application/
    sidebar_cassette_spec/       ← one folder per surface type
      coordinators/              ← routing only
      resolvers/                 ← logic + payload construction
      resolver_tools/            ← shared helpers (pure functions, providers)
      widget_builders/           ← dumb widget assembly
    view_spec/                   ← another surface
      coordinators/
      resolvers/
      resolver_tools/
      widget_builders/
```

### Naming conventions

The surface folder is named after the spec type it handles:

| Surface | Folder name |
|---|---|
| Sidebar cassettes | `sidebar_cassette_spec/` |
| Center/right panel content | `view_spec/` |
| Sidebar cassette (settings mode) | `sidebar_settings_spec/` (when needed) |
| Tooltips | `tooltips_spec/` (when needed) |

### What lives in each subfolder

**`coordinators/`** — Feature-level coordinators
- One file per coordinator (usually one per surface)
- Pattern-matches the feature spec → calls one resolver
- **No IO, no widget construction, no business logic**
- Cassette coordinators: `buildViewModel(spec, {required int cassetteIndex})`
- View spec coordinators: `buildForSpec(spec)`

**`resolvers/`** — Domain logic and payload construction
- One file per spec variant (or per logical group)
- Receives explicit parameters from the coordinator (never the spec itself)
- Constructs the surface-appropriate payload
- **Cassette resolvers** return `Future<SidebarCassetteCardViewModel>`
- **View spec resolvers** return `Widget` (sync, via widget builder call)

**`resolver_tools/`** — Shared helpers
- Pure functions, data-fetching providers, formatters
- Used by resolvers within the same surface
- No routing, no specs, no widgets

**`widget_builders/`** — Widget assembly
- Receives fully-decided inputs → returns widgets
- **Sidebar cassette widget builders** are `ConsumerWidget` classes (they live in the
  sidebar and `ref.watch()` for reactive updates)
- **View spec widget builders** are thin functions or classes that delegate to
  `presentation/view/` for heavy lifting
- **Never** interprets specs, never performs IO, never makes branching decisions

---

## Spec Classes Live in Domain

Feature-specific spec classes are **domain data** — pure descriptions of intent:

```
feature_name/
  domain/
    spec_classes/
      <feature>_cassette_spec.dart
      <feature>_view_spec.dart     ← (if feature-owned; or may live in essentials)
```

Spec classes must not import application, infrastructure, or presentation code.

---

## Barrel File: `feature_level_providers.dart`

Each feature exposes a single barrel file as its **only public API**:

```dart
// feature_name/feature_level_providers.dart

export 'application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export 'application/view_spec/coordinators/view_spec_coordinator.dart';
export 'infrastructure/repositories/some_repository_provider.dart';
```

### Must export:
- Feature coordinator(s)
- Spec class(es) (when feature-owned)
- Domain types required by callers (enums, etc.)

### Must NOT export:
- Resolvers
- Resolver tools
- Widget builders
- Infrastructure implementations

### Visibility rule
Code outside the feature may **only** import `feature_level_providers.dart`.
Any other import path is a violation.

---

## How App-Level Coordinators Use Features

App-level coordinators import features with **aliases** to prevent provider name collisions:

```dart
import 'package:remember_this_text/features/messages/feature_level_providers.dart'
    as messages_feature;
import 'package:remember_this_text/features/contacts/feature_level_providers.dart'
    as contacts_feature;
```

Then dispatch:

```dart
// Cassette system — routes CassetteSpec to feature
spec.when(
  messages: (innerSpec) => ref
      .read(messages_feature.messagesCassetteCoordinatorProvider.notifier)
      .buildViewModel(innerSpec, cassetteIndex: cassetteIndex),
  contacts: (innerSpec) => ref
      .read(contacts_feature.contactsCassetteCoordinatorProvider.notifier)
      .buildViewModel(innerSpec, cassetteIndex: cassetteIndex),
  // ...
);

// Panel system — routes ViewSpec to feature
spec.when(
  messages: (innerSpec) => ref
      .read(messages_feature.viewSpecCoordinatorProvider.notifier)
      .buildForSpec(innerSpec),
  contacts: (innerSpec) => ref
      .read(contacts_feature.viewSpecCoordinatorProvider.notifier)
      .buildForSpec(innerSpec),
  // ...
);
```

---

## Contract Differences by Surface

### Sidebar cassettes

- Coordinator method: `buildViewModel(spec, {required int cassetteIndex})`
- Returns: `Future<SidebarCassetteCardViewModel>`
- Resolvers: `@riverpod` Notifier classes with `resolve(...)` method
- Widget builders: `ConsumerWidget` classes (reactive, `ref.watch()`)
- App-level wraps the returned view model in card chrome (`SidebarCassetteCard`, `SidebarInfoCard`, etc.)

### View spec (panel content)

- Coordinator method: `buildForSpec(spec)`
- Returns: `Widget` (synchronous)
- Resolvers: Plain classes with `resolve(...)` method (not Riverpod notifiers)
- Widget builders: Thin — delegate to `presentation/view/` for the actual view
- App-level renders the returned widget directly in the panel surface

### Why the difference

Sidebar cassettes are a **managed stack** where the app-level system owns chrome,
ordering, and composition. Features return structured data (the view model) and the
system wraps it.

View specs are **full-panel content** where the feature owns most of the rendering.
The app-level system just slots the widget into a panel. There's no chrome layer to
interpose, so features return widgets directly.

---

## Ownership Summary

| Responsibility | Owner |
|---|---|
| Surface state (rack state, panel state) | essentials |
| Spec routing to features | essentials (app-level coordinator) |
| Chrome and layout | essentials |
| Feature spec definitions | feature / domain |
| Feature coordinators | feature / application |
| Resolvers and logic | feature / application |
| Widget builders | feature / application |
| View model construction | feature / application |
| Presentation views | feature / presentation |

No ownership overlaps.
