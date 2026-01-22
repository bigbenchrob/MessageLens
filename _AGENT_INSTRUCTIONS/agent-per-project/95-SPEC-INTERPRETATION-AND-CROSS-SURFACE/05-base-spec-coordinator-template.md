# Base Spec Coordinator Template

This template standardizes feature-level spec coordinators across systems.
It includes a "soft enforcement" pattern that keeps `ref.watch()` out of
coordinators and keeps async meaning resolution out of widgets.

---

## Design constraints

- Coordinators are `@riverpod` generated notifiers.
- Coordinators return a `Future<...PayloadModel>` for the system.
- Coordinators never call `ref.watch()`.
- Coordinators delegate immediately to spec cases/resolvers.

---

## Generic coordinator template

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '<file>.g.dart';

/// Routes <Feature><System>Spec -> <System>PayloadModel.
///
/// Contract:
/// - MUST NOT call ref.watch()
/// - MAY use ref.read()
/// - MAY await spec cases/resolvers
/// - MUST return fully resolved chrome decisions for the system payload
@riverpod
class <Feature><System>SpecCoordinator extends _$<Feature><System>SpecCoordinator {
  @override
  void build() {}

  Future<<System>PayloadModel> buildPayload(
    <Feature><System>Spec spec,
  ) async {
    switch (spec) {
      // TODO: Add one case per spec variant.
      default:
        throw StateError(
          'Unhandled <Feature><System>Spec variant: ${spec.runtimeType}',
        );
    }
  }

  // Read-only helper (soft enforcement).
  T read<T>(ProviderListenable<T> provider) => ref.read(provider);
}
```

Notes:
- The coordinator is intentionally small.
- All meaning resolution belongs in spec cases/resolvers.

---

## Sidebar-specific coordinator shape

For sidebar cassettes, the return type is:

`Future<SidebarCassetteCardViewModel> buildViewModel(<Feature>CassetteSpec spec)`

Chrome decisions such as `cardType`, `isControl`, and `shouldExpand` must be
resolved before returning the view model.

---

## Child widget wrapper template (reactive data)

Use a wrapper widget when reactive data is required:

```dart
class <CassetteChildWidget> extends ConsumerWidget {
  const <CassetteChildWidget>({
    super.key,
    required this.spec,
  });

  final <Feature><System>Spec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(<reactiveWidgetProvider>(spec));
  }
}
```

The coordinator returns the wrapper widget as the child.

---

## Soft enforcement techniques

- Naming conventions: coordinators expose `read(...)`, not `watch(...)`.
- CI grep (optional):
  - Search for `ref.watch(` inside `features/**/application/**/spec_coordinators/`.
  - Fail the build with a clear message if found.

---

## Checklist

- No `ref.watch()` in coordinators
- Switch statement handles all spec variants
- Chrome decisions resolved before returning payload
- Widget reactivity lives in `ConsumerWidget` wrappers
