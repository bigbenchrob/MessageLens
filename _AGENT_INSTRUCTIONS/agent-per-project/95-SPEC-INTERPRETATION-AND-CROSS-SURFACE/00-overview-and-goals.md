# Overview and Goals

This document defines the problem space and design goals for feature-side spec
interpretation across all spec-driven systems (sidebar, panels, onboarding,
tooltips, and future surfaces).

Read this before diving into templates or system-specific guidance.

---

## The Core Problem

The application uses multiple spec systems:

- ViewSpec (panel navigation)
- CassetteSpec (sidebar composition)
- Info-related specs (explanatory content)
- Cross-surface specs (onboarding, tooltips, future systems)

These specs are intentionally high-level and declarative.

They answer:
"What does the user want to see?"

They do not answer:
"How should this be built?"
"What data is required?"
"What UI chrome should be used?"

If those questions are answered inconsistently, architectural erosion follows.

---

## Common Failure Modes

Without a clear model, systems drift toward:

- Bloated app-level coordinators making feature-specific decisions
- Spec explosion to express UI chrome instead of intent
- Feature leakage (one feature querying or constructing another)
- Inconsistent UI policies across features and surfaces
- Duplicated meaning across onboarding/tooltips/sidebar info

This documentation exists to prevent those outcomes.

---

## Design Goals

### 1) Features own meaning

Each feature is the sole authority on:

- what its specs mean
- what data they require
- how they should be interpreted

No other layer should need to understand feature semantics.

### 2) Coordinators route, they do not decide

Feature coordinators:

- pattern-match on specs
- delegate immediately to application logic

They must not:

- query repositories
- format text
- choose UI chrome
- assemble widgets

### 3) Application layer does the thinking

Feature application logic:

- queries data
- applies business rules
- formats feature-specific content
- produces view models or content payloads

### 4) App-level coordinators compose UI

App-level coordinators:

- receive resolved payloads
- choose UI chrome
- enforce consistent layout policy

### 5) Presentation stays dumb and reactive

Widgets:

- render given data
- emit interactions
- may watch providers only after insertion into the widget tree

They do not interpret specs or access repositories directly.

---

## Canonical Flow (Do Not Contradict)

Spec
-> Feature coordinator (routing only)
-> Application-layer resolver / case handler
-> View model or content payload
-> App-level coordinator chooses chrome
-> Presentation widgets render UI

This flow applies to sidebar cassettes, panels, tooltips, onboarding, and any
future spec-driven system.

---

## Relationship to Other Documentation

This folder focuses on spec interpretation and cross-surface ownership.
It does not redefine:

- Cassette stack mechanics
- ViewSpec navigation state
- Widget layout, theming, or styling

Those topics live elsewhere.
