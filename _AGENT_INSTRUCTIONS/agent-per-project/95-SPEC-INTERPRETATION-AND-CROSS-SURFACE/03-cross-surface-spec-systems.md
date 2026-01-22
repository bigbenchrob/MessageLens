# Cross-Surface Spec Systems

This document defines the shared architecture pattern for systems such as
onboarding, tooltips, sidebar, and future spec-driven surfaces.

---

## The system pattern

A spec-driven system lives in `essentials/<system>/` and owns:

- system state providers
- system coordinator
- system payload models
- the outer routing spec: `<System>Spec.<feature>(innerSpec)`

Features own the inner spec variants and the meaning of those variants.

---

## Routing rule (feature only)

System coordinators must only pattern-match on the outer spec variant and
delegate to the owning feature coordinator.

They must not:

- inspect inner spec variants
- interpret feature keys
- format feature-specific copy
- query feature repositories

---

## Feature execution model

Inner spec
-> feature system coordinator (routing only)
-> feature spec cases / resolvers (logic + data)
-> system payload model (system-owned type)
-> essentials system renders UI and controls lifecycle

Features return payloads. Systems control lifecycle and presentation policy.

---

## Content reuse across surfaces (meaning vs machinery)

Some meaning must appear on multiple surfaces (info cards, tooltips, onboarding).
This is solved by sharing meaning, not machinery.

Recommended pattern:

- feature-local keys (enums) describe what needs explaining
- a content resolver maps keys to surface-agnostic content payloads
- each surface converts resolved content into its own payload/UI

This avoids duplicated copy and keeps surfaces decoupled.

---

## System template (essentials-owned)

```
essentials/<system>/
  application/
    <system>_state_provider.dart
    <system>_coordinator_provider.dart
  domain/
    entities/
      <system>_spec.dart
      <system>_payload_model.dart
  presentation/
    view/
```

---

## Feature template (per system)

```
features/<feature>/application/
  <system>/
    spec_coordinators/
    spec_cases/
    spec_widget_builders/   (optional)
```

---

## Non-negotiables

- Essentials has no feature subfolders.
- App-level routing is by feature only.
- Coordinators do not call `ref.watch()`.
- Do not reuse cassette flows to implement onboarding or tooltips.
