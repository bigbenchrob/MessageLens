# Cassette Spec → Widget Translation Contract

This document defines the **architectural contract** for translating
sidebar cassette specs into sidebar widgets.

It exists to prevent responsibility drift between:
- app-level routing
- feature-level coordinators
- asynchronous data resolution
- reactive widget trees

This contract applies specifically to the **CassetteWidgetCoordinator flow**
and all **feature-level cassette coordinators** it invokes.

---

## 1. Scope of This Document

This document applies **only** to:

- Translating **sidebar cassette specs** into **sidebar cassette widgets**
- The flow that begins in:
  - `CassetteWidgetCoordinator`
- And continues through:
  - feature-level cassette coordinators
  - spec cases / resolvers
  - widget builders
  - presentation widgets

It does **not** apply to:
- ViewSpecs (panel navigation)
- Onboarding flows
- Tooltips
- Other cross-surface spec systems (those have analogous but separate contracts)

---

## 2. High-Level Flow (Authoritative)

The canonical flow for sidebar cassette rendering is:

Spec  
→ Feature-level Coordinator (routing only)  
→ spec_cases / resolvers (async, one-shot)  
→ spec_widget_builders (optional)  
→ presentation widgets (reactive)

Key point:

**CassetteWidgetCoordinator is responsible for orchestration.  
Feature-level coordinators are responsible for meaning.  
Widgets are responsible for reactivity.**

---

## 3. CassetteWidgetCoordinator Responsibilities

### 3.1 Role

`CassetteWidgetCoordinator` is the **app-level dispatcher** that:

- Reads the current cassette spec stack
- Routes each `CassetteSpec` to the correct feature
- Awaits a fully-formed `SidebarCassetteCardViewModel`
- Converts that view model into an actual sidebar widget

### 3.2 Async Contract

Because feature-side spec handling *may* require async work:

- `CassetteWidgetCoordinator.build(...)` **must be async**
- The provider exposes:

AsyncValue<List>

This means:

- While building: `loading`
- When complete: `data(List<Widget>)`
- No partial results are emitted

### 3.3 What CassetteWidgetCoordinator Does *Not* Do

- It does **not** inspect feature-specific spec variants
- It does **not** watch feature providers
- It does **not** compute card meaning
- It does **not** contain business logic

---

## 4. Feature-Level Cassette Coordinator Contract

### 4.1 Role

A feature-level cassette coordinator:

- Receives a **feature-specific cassette spec**
- Asynchronously returns a **SidebarCassetteCardViewModel**
- Acts as a **translator**, not a renderer

Conceptual signature:

Future buildViewModel(FeatureCassetteSpec spec)

### 4.2 Hard Rule: No Reactive Watching

**Feature-level coordinators MUST NOT call `ref.watch()`**

Why:

- Coordinators are not widgets
- Watching providers here does not participate in Flutter’s rebuild cycle
- It creates invisible, fragile coupling to reactive state
- It makes async orchestration impossible to reason about

Allowed:
- `ref.read()`
- `await` on spec cases / resolvers

Forbidden:
- `ref.watch()`
- Returning widgets that are already the *result* of watching providers

---

## 5. The View Model: Two Categories of Data

`SidebarCassetteCardViewModel` contains **two fundamentally different kinds of data**.

Understanding this distinction is critical.

---

### 5.1 Category A: Structural / Chrome-Determining Data (Must Be Final)

These properties determine **how the cassette card itself is built**.

They **must be in their final state** before the view model is returned,
because the card widget is constructed immediately afterward.

Examples:

- `cardType` (standard / info / naked)
- `shouldExpand`
- `isControl`
- `isNaked`
- `sectionTitle`
- `title` / `subtitle` when used to select card chrome
- Presence or absence of a child widget

Rules for this category:

- Values must be resolved *before* returning the view model
- They may require async work
- They MUST NOT depend on reactive provider watching
- They are computed via:
  - `spec_cases`
  - resolvers
  - repositories (via `ref.read`)

If a value affects how the card is wrapped or laid out, it belongs here.

---

### 5.2 Category B: Child Widget Content (May Be Reactive)

The `child` widget (if present) represents **content**, not structure.

This widget:

- Is inserted into the sidebar widget tree
- Participates in Flutter’s rebuild cycle
- May freely watch providers

Examples:

- Contact chooser lists
- Recent contacts
- Search results
- Loading spinners inside the cassette body
- Any interactive UI

Rules for this category:

- The coordinator returns a widget instance
- That widget may be a `ConsumerWidget` or `HookConsumerWidget`
- All `ref.watch()` calls belong *inside the widget tree*
- The coordinator does not await final values here

**Reactivity lives in widgets, not in coordinators.**

---

## 6. View Models Without Child Widgets

Not all cassette view models contain a child widget.

Examples:
- Info-only cards
- Textual explanation cards
- Placeholder or empty-state cards

In these cases:

- The view model is fully resolved by the coordinator
- The card is rendered directly from view model fields
- No reactive subtree exists

This is why feature-level coordinators are async even if some cases are trivial:
other cases may require async resolution.

---

## 7. spec_cases, spec_widget_builders, and Their Roles

### 7.1 spec_cases / resolvers

- Take a spec
- Perform async or sync computation
- May call repositories
- Return **plain data objects**
- Never return widgets
- Never watch providers

Purpose:

**Resolve meaning from a spec.**

---

### 7.2 spec_widget_builders

- Take resolved data
- Assemble widgets
- May return presentation widgets
- Do not perform business logic

Purpose:

**Bridge resolved meaning to presentation.**

---

### 7.3 Presentation Widgets

- Own all reactive state
- Use `ref.watch()` freely
- Handle loading, empty, and error states locally

Purpose:

**Render UI and react to state changes.**

---

## 8. Hard Rules Summary (Non-Negotiable)

1. Coordinators do not watch providers
2. Coordinators may await spec cases
3. Card-structure decisions must be final before returning a view model
4. Child widgets own reactivity
5. Async exists to resolve meaning, not to simulate widget rebuilds
6. If a value affects card chrome, it cannot be reactive

---

## 9. Why This Contract Exists

Without this separation:

- Async flows become untraceable
- UI rebuilds happen “by accident”
- Coordinators turn into pseudo-widgets
- Feature refactors regress repeatedly

This contract provides a **conceptual equivalent to an interface**:
it enforces responsibility boundaries that Dart itself cannot encode.

Future work may add:
- abstract base coordinators
- lint rules
- codegen helpers

But this document is the authoritative rulebook today.

---

## 10. If You Are Unsure

Ask this question:

**“Does this value affect how the card is built, or only what appears inside it?”**

- *How it’s built* → resolve in coordinator (possibly async)
- *What appears inside* → let the widget watch providers

That single question resolves most ambiguity.

