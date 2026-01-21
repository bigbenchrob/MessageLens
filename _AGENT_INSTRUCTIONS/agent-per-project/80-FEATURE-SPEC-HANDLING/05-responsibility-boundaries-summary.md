# Responsibility Boundaries Summary

This document summarizes responsibility boundaries across the system when handling
feature-level specs.

It is intended as a quick reference and a final consistency check.

---

## App-Level Coordinators

Examples:

- CassetteWidgetCoordinator
- PanelCoordinator
- Future surface coordinators (tooltips, onboarding)

Responsibilities:

- Route specs to the appropriate feature
- Coordinate composition across features
- Choose UI chrome and layout based on view models
- Enforce global presentation policy

Must not:

- Query feature repositories
- Interpret feature semantics
- Format feature-specific content
- Build feature-specific widgets

---

## Feature-Level Coordinators

Responsibilities:

- Accept feature-specific specs
- Pattern-match on spec variants
- Delegate immediately to application-layer logic

Must not:

- Fetch data
- Perform business logic
- Format text
- Decide UI chrome
- Assemble widgets

Feature coordinators exist to keep routing explicit and shallow.

---

## Application-Layer Logic

Includes:

- Spec case handlers
- Content resolvers
- Use-case utilities

Responsibilities:

- Own feature meaning
- Apply business rules
- Fetch and compute data
- Format feature-specific content
- Handle errors and fallbacks
- Produce resolved view models or content payloads

This is where complexity belongs.

---

## Widget Builders (Application Layer)

Responsibilities:

- Assemble widget subtrees from resolved data
- Encapsulate repeated widget patterns

Must not:

- Interpret specs
- Access repositories
- Apply business rules
- Choose card chrome

Widget builders are optional and should remain simple.

---

## Presentation Widgets

Responsibilities:

- Render UI
- Emit user interactions

Must not:

- Access repositories
- Interpret specs
- Contain business logic
- Know about other features

Presentation widgets are dumb by design.

---

## The One-Sentence Rule

Specs describe intent.  
Features interpret intent.  
App-level coordinators compose UI.  
Widgets render.

---

## Architectural Payoff

Following these boundaries results in:

- Clear feature ownership
- Minimal cross-feature coupling
- Centralized UI policy
- Easy extension to new surfaces
- Code that is friendly to both humans and agents