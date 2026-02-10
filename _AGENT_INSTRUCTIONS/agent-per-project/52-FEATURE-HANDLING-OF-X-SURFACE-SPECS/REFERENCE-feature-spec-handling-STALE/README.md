# Feature Spec Handling

This folder documents **how features process incoming specs** and transform them
into concrete UI output.

It complements two existing architectural pillars:

- **ViewSpec Navigation** (`60-NAVIGATION/`)
  - Defines how panel-specific content is selected and routed
- **CassetteSpec Sidebar System** (`01-CASSETTE-SYSTEM/`)
  - Defines how sidebar content is composed as a vertical stack

Those systems describe **how specs are routed**.

This folder describes **what happens once a spec reaches a feature**.

---

## Why this exists

Specs (ViewSpec, CassetteSpec, Info-related specs) are intentionally abstract.
They describe *user intent* or *navigation state*, not implementation details.

Without a clear feature-side handling model, it becomes easy to:

- leak UI decisions into app-level coordinators
- duplicate logic across features
- blur boundaries between application logic and presentation
- make future extensions (tooltips, onboarding, etc.) painful

This documentation establishes a **uniform, scalable pattern** for:

- feature-level coordinators
- application-layer decision logic
- content reuse across multiple UI surfaces
- clean responsibility boundaries

---

## What is covered here

This folder documents:

- How **feature-level coordinators** handle specs
- The role of **application-layer spec coordinators and case handlers**
- Separation of **content resolution** from **UI surface rendering**
- How cassette-specific logic generalizes to:
  - info cards
  - tooltips
  - onboarding / guidance
- Naming and namespacing conventions for Riverpod-generated providers
- Responsibility boundaries between:
  - app-level coordinators
  - feature-level coordinators
  - application logic
  - presentation widgets

---

## What is explicitly not covered

This folder does *not* redefine:

- Cassette stack mechanics
- CassetteSpec child chaining
- ViewSpec navigation state
- Widget layout, styling, or theming

Those topics are documented elsewhere and assumed as prior knowledge.

---

## Intended audience

These documents are written for:

- **Human maintainers** reasoning about architecture
- **AI agents** generating or modifying feature code
- **Future contributors** onboarding into the system

Clarity, explicit boundaries, and repeatable patterns are prioritized
over brevity.