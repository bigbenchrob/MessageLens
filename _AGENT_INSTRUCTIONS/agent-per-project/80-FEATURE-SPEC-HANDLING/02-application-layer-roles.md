# Application Layer Roles

This document defines the roles that live inside a feature’s application layer
when handling specs.

The application layer is where meaning, rules, and data access are allowed to exist.
It is intentionally richer than coordinators and intentionally more abstract than widgets.

---

## Why This Layer Exists

Specs are abstract.
Presentation widgets are concrete.

The application layer exists to bridge that gap.

It is responsible for:
- interpreting feature intent
- gathering required data
- applying business rules
- producing a resolved representation suitable for UI composition

---

## Core Application-Layer Roles

A feature’s application layer may contain several distinct roles.
Not all features need all roles, but the separation should be respected.

---

## 1. Spec Coordinators

Location:

features/<feature>/application/spec_coordinators/

Purpose:

Spec coordinators act as routers between incoming specs and application logic.

Responsibilities:

- Accept feature-specific specs
- Pattern-match on spec variants
- Delegate immediately to the appropriate resolver or case handler

Non-responsibilities:

Spec coordinators must not:

- query repositories
- format text
- perform business logic
- decide UI chrome
- assemble widgets

They should remain small enough to scan visually in seconds.

---

## 2. Spec Case Handlers / Resolvers

Location:

features/<feature>/application/spec_cases/

Purpose:

Spec case handlers (also called resolvers or use cases) are the primary owners
of feature logic.

They answer:

“Given this spec (or key), what does it mean?”

Responsibilities:

- Query repositories or services
- Apply business rules
- Perform computation and aggregation
- Format feature-specific text
- Handle errors and fallbacks
- Return a resolved view model or content payload

Characteristics:

- May be async
- May contain try/catch
- May evolve frequently
- May depend on infrastructure-layer providers

This is where complexity is expected and encouraged to live.

---

## 3. Content Resolvers (for Reusable Meaning)

Some feature logic represents content that must be reused across multiple UI
surfaces (for example: info cards, tooltips, onboarding).

In these cases, features should expose content resolvers that map keys to
resolved content.

Responsibilities:

- Own the semantic meaning of keys
- Produce surface-agnostic content payloads
- Avoid UI-specific assumptions

These resolvers prevent duplication when the same explanation appears in
multiple places.

---

## 4. Widget Builders (Optional)

Location:

features/<feature>/application/widget_builders/

Purpose:

Widget builders exist only when widget assembly itself is reusable or
non-trivial.

Responsibilities:

- Convert resolved data into widget subtrees
- Encapsulate repeated widget assembly patterns

Strict limitations:

Widget builders must:

- not query repositories
- not apply business rules
- not interpret specs
- not choose card chrome

If a “builder” needs to think, it belongs in a resolver instead.

---

## Summary Table

Role | Thinks? | Fetches Data? | Builds Widgets?
---- | ------- | ------------- | ---------------
Spec Coordinator | No | No | No
Case Handler / Resolver | Yes | Yes | No
Content Resolver | Yes | Yes | No
Widget Builder | No | No | Yes
Presentation Widget | No | No | Yes

---

## Key Principle

All feature intelligence lives in the application layer —
but only in resolvers and case handlers, never in coordinators or widgets.