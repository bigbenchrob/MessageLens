# Cassette Spec Handling — Common Failure Modes

This document enumerates **known, recurring mistakes** encountered when
refactoring or implementing feature-level cassette coordinators.

It exists to:
- prevent architectural regressions
- shorten agent feedback loops
- provide fast diagnostics when “something feels wrong”

If you are refactoring a cassette coordinator and are unsure whether your
approach is correct, **read this first**.

---

## Failure Mode 1: Calling `ref.watch()` inside a coordinator

### Symptom
- Coordinator code contains `ref.watch(...)`
- Coordinator tries to “react” to provider changes
- Widget updates appear inconsistent or unpredictable
- Async refactors become tangled or impossible

### Why This Is Wrong
- Coordinators are **not widgets**
- `ref.watch()` outside the widget tree does not participate in Flutter rebuilds
- It creates invisible reactive dependencies
- It violates the async contract of `CassetteWidgetCoordinator`

### Correct Approach
- Coordinators must use `ref.read()` only
- Any reactive behavior must be moved into:
  - a `ConsumerWidget`
  - or `HookConsumerWidget`
- The coordinator returns a widget that owns reactivity

### Litmus Test
> “Is this code inside a `build(BuildContext…)` method?”

- Yes → `ref.watch()` may be used  
- No → `ref.watch()` is forbidden

---

## Failure Mode 2: Treating the coordinator like a widget builder

### Symptom
- Coordinator constructs UI conditionally based on provider state
- Coordinator resembles a large `switch` full of UI logic
- The coordinator “feels like” a widget build method

### Why This Is Wrong
- Coordinators translate **spec → meaning**
- Widgets translate **meaning → pixels**
- Mixing the two collapses layering and destroys testability

### Correct Approach
- Coordinator:
  - routes specs
  - awaits spec_cases
  - assembles a view model
- Widget:
  - watches providers
  - reacts to state changes
  - renders UI

---

## Failure Mode 3: Returning widgets that are already watched

### Symptom
- Coordinator returns:

child: ref.watch(someWidgetProvider(…))

- Child widget already reflects provider state at return time

### Why This Is Wrong
- The coordinator is now implicitly reactive
- UI rebuilds are detached from Flutter’s lifecycle
- Async refactors become brittle

### Correct Approach
- Wrap reactive logic in a widget:

class SomeCassetteChild extends ConsumerWidget {
@override
Widget build(…) {
return ref.watch(someWidgetProvider(…));
}
}

- Coordinator returns `SomeCassetteChild(...)` as `viewModel.child`

---

## Failure Mode 4: Making card chrome depend on reactive state

### Symptom
- `shouldExpand`, `cardType`, or similar fields depend on provider values
- Coordinator tries to “watch” something to decide card structure

### Why This Is Wrong
- Card chrome is determined **before** the widget is inserted into the tree
- Reactive values may change after insertion
- This causes structural inconsistencies (wrong wrapper, wrong layout)

### Correct Approach
- Card chrome decisions must be:
  - final
  - non-reactive
  - resolved via spec_cases or repositories
- If a value can change over time, it belongs in the child widget

### Rule of Thumb
> If changing this value would require rebuilding the card wrapper,
> it cannot be reactive.

---

## Failure Mode 5: Confusing “async” with “reactive”

### Symptom
- Coordinator is made async to “wait for provider updates”
- Async is used as a substitute for reactivity

### Why This Is Wrong
- Async is **one-shot**
- Reactivity is **ongoing**
- They solve different problems

### Correct Mental Model
- Async in coordinators:
  - resolves meaning
  - fetches data
  - computes decisions
- Reactivity in widgets:
  - responds to state changes
  - rebuilds UI over time

---

## Failure Mode 6: Overusing spec_cases for UI state

### Symptom
- spec_cases try to manage UI loading states
- spec_cases return widgets
- spec_cases watch providers

### Why This Is Wrong
- spec_cases are application logic, not presentation
- They should return **data**, not UI

### Correct Approach
- spec_cases:
  - return plain objects
  - may be async
- presentation widgets:
  - handle loading, empty, error states
  - own user interaction

---

## Failure Mode 7: Adding new spec types without clarifying ownership

### Symptom
- New spec variants blur feature vs essentials responsibility
- App-level coordinators start knowing feature details
- Routing logic grows complex

### Why This Is Wrong
- Essentials routes by **feature only**
- Features own interpretation of inner specs

### Correct Approach
- Outer spec:
  - identifies the feature
- Inner spec:
  - defined and interpreted by the feature
- App-level coordinators remain dumb dispatchers

---

## Failure Mode 8: Treating async coordinators as incremental pipelines

### Symptom
- Expectation that partial results appear while building
- Attempts to “stream” cassette widgets

### Why This Is Wrong
- `CassetteWidgetCoordinator` produces:

Future<List>

- The list is published atomically

### Correct Approach
- Use stale-while-revalidate UI patterns
- Accept that the sidebar updates in discrete steps
- If per-cassette loading is required, handle it inside child widgets

---

## Failure Mode 9: Trying to enforce rules only via convention

### Symptom
- Repeated re-explanations
- Agents drift back into old patterns
- Inconsistent implementations across features

### Why This Happens
- Dart does not enforce architectural boundaries
- Conventions alone are fragile

### Mitigation (Current)
- This document
- The main contract document
- Repeated explicit instructions

### Mitigation (Future)
- Abstract base coordinator classes
- Lint rules
- Codegen scaffolds
- “Do not watch providers” assertions in debug mode

---

## Final Sanity Check

Before committing a cassette coordinator change, ask:

1. Does this coordinator call `ref.watch()`?  
 → If yes, it is wrong.

2. Does any reactive value affect card structure?  
 → If yes, refactor.

3. Is async used to resolve meaning, not to simulate reactivity?  
 → If no, rethink.

4. Could this logic live in a widget instead?  
 → If yes, move it there.

If all answers are correct, the implementation is likely sound.

