# Sidebar Cassette Spec-to-Widget Contract

This document defines the cassette-specific contract for turning a
`<Feature>CassetteSpec` into a sidebar widget tree.

It focuses on the async vs reactive boundary and the hard rules that keep the
sidebar system stable.

---

## Canonical cassette flow

CassetteSpec
-> Feature cassette coordinator (routing only)
-> Feature spec case / resolver (async meaning)
-> Sidebar cassette view model (data + chrome decisions)
-> Cassette widget coordinator chooses final chrome
-> Presentation widgets render and watch providers

---

## Async vs Reactive (the non-negotiable boundary)

Async meaning resolution happens before widgets are built:

- Coordinators return `Future<SidebarCassetteCardViewModel>`.
- Spec cases/resolvers may query repositories and format text.
- Chrome decisions are finalized before returning the view model.

Reactive UI happens after insertion into the widget tree:

- Child widgets may `ref.watch(...)` inside `build()`.
- Providers can stream updates and rebuild UI reactively.

If a coordinator calls `ref.watch()`, it is violating this contract.

---

## Hard rules (must appear in every cassette implementation)

- Coordinators never call `ref.watch()`.
- Coordinators may use `ref.read()` and await spec cases/resolvers.
- Chrome decisions (cardType/shouldExpand/isControl/etc.) are resolved
  before returning the view model.
- Feature code never determines app-level chrome by widget inspection.
- Reactive data access belongs in widgets after they are mounted.

---

## Minimum coordinator shape

The feature coordinator should be tiny:

- switch on spec variants
- delegate immediately to spec cases
- return a fully resolved view model

If it grows beyond a single screenful, refactor logic into spec cases.

---

## Standard reactive wrapper pattern

When a cassette body needs reactive data, wrap it in a widget that watches the
provider inside `build()`.

Example pattern:

```dart
class FeatureCassetteChild extends ConsumerWidget {
  const FeatureCassetteChild({
    super.key,
    required this.spec,
  });

  final FeatureCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(featureCassetteChildProvider(spec));
  }
}
```

The coordinator returns:

```dart
return SidebarCassetteCardViewModel(
  title: data.title,
  child: FeatureCassetteChild(spec: spec),
  shouldExpand: data.shouldExpand,
);
```

---

## Why this contract exists

- Prevents coordinators from becoming widgets.
- Keeps async work out of the widget tree.
- Ensures chrome decisions are centralized and consistent.
- Keeps sidebar rendering stable and debuggable.
