# INVIOLATE RULES — Cross-Surface Spec Systems

These rules apply to **all** spec-driven UI surfaces. Surface-specific rules
are in the respective folders (54 for cassettes, 56 for panel content).

---

## 1. Every Surface Uses Two-Level Sealed Specs

- **Level 1**: Essentials-owned sealed class (`CassetteSpec`, `ViewSpec`) with one variant per feature
- **Level 2**: Feature-owned sealed class (`MessagesCassetteSpec`, `MessagesSpec`) with one variant per view/behavior

No flat specs. No string-based routing. No enum-based dispatch.

## 2. Each Surface Has Exactly One App-Level Coordinator

- Sidebar cassettes → `CassetteWidgetCoordinator`
- Panel content → `PanelCoordinator`

No additional coordinators may be introduced for the same surface.
All routing from top-level spec to feature goes through the single coordinator.

## 3. Features Return Surface-Appropriate Payloads, Not Chrome

| Surface | Feature returns |
|---|---|
| Sidebar cassettes | `Future<SidebarCassetteCardViewModel>` |
| Panel content | `Widget` |

Features must never return pre-wrapped card widgets to the sidebar.
Features must never return view models to the panel system.
The return type is dictated by the surface, not the feature.

## 4. Coordinator = Router. Always.

At both the app level and the feature level, coordinators:
- Pattern-match specs
- Route to the appropriate handler
- Return the handler's result

Coordinators must not contain business logic, IO, widget construction,
or view model assembly. Those belong in resolvers.

## 5. Resolvers Receive Values, Not Specs

Coordinators extract payload values from specs and pass them as explicit
parameters to resolvers. Resolvers never receive, store, or interpret spec objects.

## 6. No Cross-Feature Imports

Features must not import another feature's coordinators, resolvers, or widget builders.
The only permitted cross-feature interaction is dispatching a spec through a
surface state provider (e.g., `panelsViewStateProvider`).

## 7. Barrel Files Are the Only Feature Entry Point

External code imports `feature_level_providers.dart` — nothing else from the feature.
Barrel files export coordinators and spec classes. They do not export resolvers,
resolver tools, or widget builders.

## 8. Feature Specs Are Domain Data

Spec classes live in `domain/spec_classes/`. They are pure, immutable, serializable
descriptions of intent. They must not import application, infrastructure, or
presentation code.

## 9. The 4-Folder Structure Is Mandatory for All Surfaces

Every surface-spec folder inside a feature must contain:

```
coordinators/
resolvers/
resolver_tools/
widget_builders/
```

This applies equally to `sidebar_cassette_spec/`, `view_spec/`, and any future
surface folders.

## 10. No Wrapper Types, No Parallel Payloads

Each surface has exactly one payload type. If more data needs to cross the
feature → essentials boundary, add fields to the existing type.
Never introduce `Result`, `Response`, `WidgetWithMetadata`, or parallel models.

## 11. Errors and Empty States Are Content, Not Exceptions

Features encode error and empty states within the payload (view model fields
for cassettes, error widgets for panels). Features must not throw exceptions
across the feature → essentials boundary.
