# Base SpecCoordinator Template (Sidebar Cassettes)

This document provides a **template and enforcement pattern** for feature-level
spec coordinators used by the sidebar cassette system.

Goal:
- standardize structure across features
- reduce refactor drift
- provide practical “soft enforcement” of architectural rules
  (especially: **no `ref.watch()` in coordinators**)

This template is designed for Riverpod **generated notifier providers**.

---

## 1) Design Constraints

- Feature coordinators are implemented as `@riverpod class ... extends _$...`
- Coordinators must return:

  `Future<SidebarCassetteCardViewModel> buildViewModel(Spec spec)`

- Coordinators must **not** call `ref.watch()` (ever)
- Reactive dependencies must live in **widgets**, not coordinators

Dart cannot enforce “no ref.watch()” at the type system level, but we can:
- structure the code so misuse is difficult
- provide debug-time checks and naming patterns
- isolate “safe access” helpers

---

## 2) Recommended Folder Shape (per feature)

features/<feature>/application/cassettes/
  spec_coordinators/
    cassette_spec_coordinator.dart
  spec_cases/
    ...
  spec_widget_builders/
    ...

presentation/
  cassettes/
    <cassette_child_widgets>.dart
  widget_builders/
    <reactive_widget_provider_builders>.dart   (if needed)

---

## 3) Template: Feature Cassette Spec Coordinator

Create:

`features/<feature>/application/cassettes/spec_coordinators/cassette_spec_coordinator.dart`

This template:
- standardizes method names (`buildViewModel`)
- standardizes error handling for non-exhaustive specs
- provides explicit helper methods for “read-only” access
- encourages delegation to spec_cases

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../../../essentials/sidebar/domain/entities/features/<feature>_cassette_spec.dart';

// Import spec_cases and widget_builders as needed.
// import '../spec_cases/...';
// import '../spec_widget_builders/...';

part 'cassette_spec_coordinator.g.dart';

/// Coordinator that maps <Feature>CassetteSpec -> SidebarCassetteCardViewModel.
///
/// ## Contract:
/// - MUST NOT call ref.watch()
/// - MAY use ref.read()
/// - MAY await spec_cases/resolvers
/// - MUST return fully-resolved chrome decisions (cardType, shouldExpand, etc.)
/// - MUST return child widgets that own their reactivity (ConsumerWidget, etc.)
@riverpod
class <Feature>CassetteSpecCoordinator extends _$<Feature>CassetteSpecCoordinator {
  @override
  void build() {}

  /// Public entrypoint used by CassetteWidgetCoordinator.
  Future<SidebarCassetteCardViewModel> buildViewModel(
    <Feature>CassetteSpec spec,
  ) async {
    switch (spec) {
      // TODO: Add one case per spec variant.
      //
      // Example:
      // case <Feature>CassetteSpecSomeVariant(:final someField):
      //   return await _someVariant(someField);

      default:
        // If you add a new spec variant and forget to handle it,
        // crash loudly rather than returning null/empty UI.
        throw StateError(
          'Unhandled <Feature>CassetteSpec variant: ${spec.runtimeType}',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Variant handlers (private)
  // ---------------------------------------------------------------------------

  // Example private handler pattern:
  //
  // Future<SidebarCassetteCardViewModel> _someVariant(String someField) async {
  //   final data = await read(someCaseProvider.notifier).resolve(someField);
  //   final child = read(someWidgetBuilderProvider.notifier).build(data);
  //   return SidebarCassetteCardViewModel(
  //     title: data.title,
  //     child: child,
  //     shouldExpand: data.shouldExpand,
  //   );
  // }

  // ---------------------------------------------------------------------------
  // Read-only helpers (soft enforcement)
  // ---------------------------------------------------------------------------

  /// Read helper intentionally named `read` (not `watch`).
  ///
  /// Convention:
  /// - Coordinators use `read(...)` only.
  /// - Widgets use `watch(...)` only (inside build()).
  ///
  /// This does not provide language-level enforcement, but it makes mistakes
  /// stand out in code review and in diffs.
  T read<T>(ProviderListenable<T> provider) => ref.read(provider);
}
```

## 4) Template: Info Cassette Spec Coordinator (per feature)

If your feature has an Info spec type:

`features/<feature>/application/cassettes/spec_coordinators/info_cassette_coordinator.dart`

Use the same structure:
	•	buildViewModel(FeatureInfoSpec spec)
	•	switch + throw StateError(...)
	•	read(...) helper
	•	delegate to InfoContentResolver / spec_cases

---

## 5) Child Widget Wrapper Template (for reactive cassette content)

If a cassette’s body needs to watch providers, create a wrapper widget:

`features/<feature>/presentation/cassettes/<cassette_child>.dart`

```dart
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../essentials/sidebar/domain/entities/features/<feature>_cassette_spec.dart';
import '../widget_builders/<reactive_widget_provider>.dart';

class <CassetteChildWidget> extends ConsumerWidget {
  const <CassetteChildWidget>({
    super.key,
    required this.spec,
  });

  final <Feature>CassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // All reactivity lives here:
    return ref.watch(<reactiveWidgetProvider>(spec));
  }
}
```

Then coordinator returns:

```dart
return SidebarCassetteCardViewModel(
  title: '...',
  child: <CassetteChildWidget>(spec: spec),
);
```

## 6) "Soft Enforcement" Techniques (Recommended)

Because Dart cannot prohibit ref.watch() inside notifiers, use:
	•	Naming conventions
	•	Wrapper helpers
	•	CI greps (optional)

6.1 Naming conventions
	•	Coordinators expose only read(...) helper
	•	Coordinators do not mention “watch” anywhere
	•	Widget wrappers contain all ref.watch(...)

6.2 CI grep (optional but effective)

Add a lightweight check in CI or a pre-commit hook:
	•	Search for ref.watch( inside:
	•	features/**/application/**/spec_coordinators/

If found, fail the build with a clear message.

This is surprisingly effective for agent-generated code.

6.3 Review checklist
	•	No ref.watch in coordinators
	•	Chrome decisions (cardType/shouldExpand/etc.) computed before returning VM
	•	Reactive data belongs in child widgets

---

## 7) Summary: What This Template Buys You
	•	Consistent coordinator shape across features
	•	Clear insertion points for spec_cases
	•	Loud failures for unhandled spec variants
	•	Practical mitigation against the “coordinator becomes a widget” regression
	•	Clear guidance to agents about where reactivity belongs