# Overview & Goals

This document defines the **problem space** and **design goals** for feature-side
handling of specs.

It should be read before diving into individual coordinators or folder layouts.

---

## The Core Problem

The application uses multiple spec systems:

- **ViewSpec** — panel-level navigation
- **CassetteSpec** — sidebar composition
- **Info-related specs** — explanatory or guidance content

These specs are intentionally **high-level and declarative**.

They answer:
> “What does the user want to see?”

They do **not** answer:
> “How should this be built?”  
> “What data is required?”  
> “What UI chrome should be used?”

If those questions are answered inconsistently, architectural erosion occurs.

---

## Common Failure Modes

Without a clear feature-side handling model, systems tend to drift toward:

- **Bloated app-level coordinators**
  - Central code starts making feature-specific decisions
- **Spec explosion**
  - New spec variants created just to express UI choices
- **Feature leakage**
  - One feature building or querying another feature’s data
- **Inconsistent UI**
  - Similar concepts rendered differently across features
- **Poor extensibility**
  - Adding tooltips or onboarding requires duplicating logic

This folder exists to prevent those outcomes.

---

## Design Goals

### 1. Features own meaning

Each feature is the sole authority on:

- what its specs mean
- what data they require
- how they should be interpreted

No other part of the app should need to understand feature semantics.

---

### 2. Coordinators route, they do not decide

Feature-level coordinators:

- pattern-match on specs
- delegate immediately to application logic

They must **not**:
- query repositories
- format text
- choose UI chrome
- assemble widgets

---

### 3. Application layer does the thinking

The application layer inside each feature:

- performs data access
- applies business rules
- formats domain-specific content
- produces view models or content payloads

This is where complexity is allowed to live.

---

### 4. App-level coordinators compose UI

High-level coordinators (e.g. cassette or panel coordinators):

- receive view models from features
- decide *how* those models are presented
- enforce consistent layout and chrome

This ensures UI policy is centralized.

---

### 5. Presentation is dumb and replaceable

Presentation widgets:

- render given data
- emit user interactions

They must never:
- contain business logic
- query repositories
- understand specs directly

---

## High-Level Flow

The canonical flow this documentation enforces:

Spec
→ Feature Coordinator (routing only)
→ Application-layer resolver / case handler
→ View model or content payload
→ App-level coordinator chooses chrome
→ Presentation widgets render UI

This pattern is repeated consistently across:
- sidebar cassettes
- panel views
- informational content
- future guidance surfaces

---

## Relationship to Other Documentation

This folder builds on:

- Cassette system philosophy and flow
- ViewSpec navigation architecture

Those documents explain **how specs move**.

This folder explains **how specs are interpreted once they arrive**.