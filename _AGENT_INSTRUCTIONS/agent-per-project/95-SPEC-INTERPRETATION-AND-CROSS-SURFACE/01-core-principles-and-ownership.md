# Core Principles and Ownership

This document defines ownership boundaries and the routing model shared by all
spec-driven systems.

---

## 1) Systems are independent

Do not cram unrelated surfaces into a single system.

Examples:

- Sidebar cassettes are a sidebar system concern.
- Tooltips have anchoring and lifecycle rules that are not cassette rules.
- Onboarding has progression and dismissal rules that are not cassette rules.

They may share meaning, but they must not share machinery.

---

## 2) Essentials is system-owned, not feature-owned

`essentials/<system>/` contains:

- system state providers
- system coordinators
- system payload models
- the outer routing spec: `<System>Spec.<feature>(innerSpec)`

Essentials never contains feature subfolders and never interprets feature
semantics.

---

## 3) Features own meaning

Each feature owns:

- inner spec unions (variants)
- keys/enums/constants that express meaning
- feature coordinators, spec cases, and resolvers for that system

Features interpret and resolve meaning into system-specific payloads.

---

## 4) Routing is by feature only

System coordinators pattern-match on the outer spec variant:

- `OnboardingSpec.contacts(inner)`
- `TooltipSpec.handles(inner)`
- `SidebarSpec.messages(inner)`

They route to the owning feature and never inspect inner spec variants.

---

## 5) Coordinators route, resolvers interpret

- `spec_coordinators` route only.
- `spec_cases` or `resolvers` perform async meaning resolution.
- `spec_widget_builders` assemble widgets with no business logic.
- Presentation widgets render and may watch providers.

If a coordinator or widget is interpreting meaning, the boundary is broken.

---

## 6) Chrome decisions belong to app-level coordinators

Features return a view model or content payload.
App-level coordinators apply chrome and layout policy.

Never infer chrome by inspecting widget types.

---

## 7) Namespacing and entry points

- Providers may use generic names within a feature.
- App-level code must import each feature via an alias.
- `features/<feature>/feature_level_providers.dart` is the only public entry.

This avoids collisions and keeps feature ownership explicit.

---

## 8) Share meaning, not machinery

Cross-surface reuse happens at the meaning layer:

- keys
- content resolvers
- domain computations

Do not reuse cassette pipelines to implement onboarding or tooltips.
