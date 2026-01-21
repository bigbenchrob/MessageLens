# System Template (Essentials-Owned)

This document describes the canonical structure of an essentials-owned spec system.

Example systems:

- essentials/sidebar
- essentials/onboarding
- essentials/tooltips

---

## Essentials folder shape

essentials/<system>/
  application/
    <system>_state_provider.dart
    <system>_coordinator_provider.dart
  domain/
    entities/
      <system>_spec.dart          (outer routing spec only)
      <system>_view_model.dart    (system-specific payload)
  presentation/
    view/                         (system-level UI widgets)

---

## Outer routing spec

The outer spec is responsible only for routing by feature:

Example:

<System>Spec.contacts(Contacts<System>Spec inner)
<System>Spec.handles(Handles<System>Spec inner)

Essentials coordinator responsibilities:

- pattern-match on outer spec variant
- route inner spec to owning feature coordinator (via import alias)
- assemble system-level output if needed

Essentials must never interpret inner variants.

---

## System coordinator returns system payload

Each system has its own payload type.

Examples:

- sidebar returns SidebarCassetteCardViewModel (or similar)
- onboarding returns OnboardingCartoucheModel / overlay payload
- tooltips return TooltipModel

These are system-owned types, not feature-owned.

Features produce these payloads via feature-owned coordinators/cases.

---

## Lifecycle is system-specific

Each system defines its own lifecycle rules:

- sidebar: stack order + cassette chaining
- onboarding: step progression + anchors + dismissal
- tooltips: hover/focus rules + placement constraints

Do not force a system to mimic another system’s lifecycle.