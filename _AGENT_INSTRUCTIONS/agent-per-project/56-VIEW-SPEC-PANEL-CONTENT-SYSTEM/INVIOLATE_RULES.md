# INVIOLATE RULES — View Spec Panel Content System

These rules govern how the center and right panels display content.
Violations are bugs.

---

## 1. Feature View Spec Coordinators Return `Widget` Synchronously

Every feature view spec coordinator **must** have this signature:

```dart
Widget buildForSpec(FeatureSpec spec)
```

No `Future`. No view model wrapper. No async. The widget owns its own loading state.

## 2. Widgets Own Their Reactive State

View spec widgets use `ref.watch()` internally to load and react to data.
The coordinator does not pre-fetch data or await readiness.
The panel system does not manage loading states for view spec content.

## 3. ViewSpec Is the Only Navigation Currency

All panel navigation goes through `PanelsViewState`:

```dart
ref.read(panelsViewStateProvider(mode).notifier).show(
  panel: WindowPanel.center,
  spec: ViewSpec.someFeature(SomeFeatureSpec.someVariant(...)),
);
```

No direct widget insertion into panels. No string-based routing.
No context-based navigation. ViewSpec sealed classes only.

## 4. Feature Specs Are Exhaustively Handled

The feature coordinator must handle **every** variant of its spec class.
Use `spec.when(...)` (not `spec.maybeWhen`) to get compile-time exhaustiveness.

## 5. View Spec Widget Builders Are Thin

Widget builders in `view_spec/widget_builders/` are thin wrappers that delegate
to `presentation/view/` for the actual view implementation.

Widget builders must not:
- Contain business logic
- Perform data fetching
- Make routing decisions

## 6. PanelStack Is Immutable

`PanelStack` and `PanelPage` are immutable value objects. All mutations go through
`PanelsViewState` notifier methods (`show`, `push`, `pop`, `closeAt`, `activate`, `clear`).

## 7. One Feature, One ViewSpec Variant, One Coordinator Entry

Each feature has exactly one `ViewSpecCoordinator` with one `buildForSpec()` method.
The `PanelCoordinator` calls it for all spec variants belonging to that feature.
Features must not expose multiple coordinators for different spec variants.

## 8. No Cross-Feature Imports in View Spec Code

A feature's `view_spec/` folder must not import another feature's coordinators,
resolvers, or widget builders. Cross-feature navigation is done by dispatching
a new `ViewSpec` through `PanelsViewState`, not by calling another feature's code.

## 9. Navigation Barrel Exports Only What Consumers Need

`lib/essentials/navigation/feature_level_providers.dart` exports:
- `PanelsViewState` provider (so anyone can trigger navigation)
- Feature spec re-exports (so navigation callers can construct specs)

It does not export the panel coordinator, panel widget providers, or panel stack internals.

## 10. `PanelCoordinator` Is the Only Place That Routes ViewSpec to Features

All `ViewSpec.when(...)` routing lives in `PanelCoordinator.buildForSpec()`.
No other code should pattern-match on `ViewSpec` to decide what widget to show.
Features pattern-match on their **own** spec type only.
