# INVIOLATE RULES — Feature Spec Handling

These rules govern how **every** feature handles specs from **any** UI surface.
Violations are bugs. No exceptions, no "temporary" workarounds.

---

## 1. Coordinator = Router, Nothing More

A feature coordinator:
- Pattern-matches the feature spec
- Extracts payload values
- Calls **exactly one** resolver
- Returns the resolver's result

A coordinator **must not**:
- Perform IO or database access
- Construct widgets or view models itself
- Pass the spec object to the resolver
- Call multiple resolvers or compose results
- Contain business logic beyond pattern matching

## 2. Resolvers Receive Explicit Parameters, Never Specs

Resolvers receive **extracted values** from the coordinator — never the spec object.
This prevents resolvers from coupling to spec structure and ensures they remain
independently testable.

## 3. Widget Builders Are Dumb

Widget builders:
- Receive fully-decided inputs
- Assemble widgets
- **Never** interpret specs, perform IO, or make branching decisions

If a widget builder needs to decide what to show, logic has leaked out of the resolver.

## 4. Specs Are Domain Data

Feature spec classes live in `domain/spec_classes/`. They are pure sealed/freezed
classes describing intent. They must not import application, infrastructure, or
presentation code.

## 5. One Barrel, One Entry Point

`feature_level_providers.dart` is the **only** file external code may import
from a feature. It exports coordinators and spec classes. It does **not** export
resolvers, resolver tools, or widget builders.

## 6. Surface-Specific Contracts Are Non-Negotiable

| Surface | Coordinator must return | Method signature |
|---|---|---|
| Sidebar cassette | `Future<SidebarCassetteCardViewModel>` | `buildViewModel(spec, {required int cassetteIndex})` |
| View spec (panel) | `Widget` | `buildForSpec(spec)` |

Do not return a different type. Do not wrap the return in additional objects.
Do not add optional metadata alongside the return.

## 7. 4-Folder Structure Is Mandatory

Every surface-spec folder must contain exactly these subfolders:

```
coordinators/
resolvers/
resolver_tools/
widget_builders/
```

No additional subfolders. No flattening files into the parent.

## 8. No Feature Cross-Talk

A feature's coordinator/resolver must never import another feature's
coordinator, resolver, or widget builder. If shared logic is needed,
extract it to a shared domain or application service.

## 9. App-Level Owns Chrome, Features Own Content

- Features return **data** (view models) or **content** (widgets)
- App-level coordinators decide card type, chrome, layout, ordering
- Features must not return pre-wrapped card widgets to the sidebar system
- Features must not reach into essentials sidebar/navigation state

## 10. No Wrapper Types

If the system needs additional data to cross the feature → essentials boundary:
- For cassettes: add a field to `SidebarCassetteCardViewModel`
- For view specs: the Widget is self-contained

Never introduce `Result`, `Response`, `WidgetWithMetadata`, or any parallel
payload type alongside the canonical return.

## 11. Error and Empty States Are Content

- Cassette resolvers encode errors/empty as fields on the view model — never throw
- View spec resolvers return error/empty widgets — never throw or return null
- Loading is represented by the pending `Future` (cassettes) or is handled
  within the widget's own reactive state (view specs)
