# TL;DR — Feature Spec Handling (For Agents)

This is the short version.  
If you are writing or modifying feature code, follow this.

---

## The Core Rule

Specs describe intent.  
Features interpret intent.  
App-level coordinators compose UI.  
Widgets render.

Never collapse these roles.

---

## Canonical Flow

Spec  
→ Feature coordinator (routing only)  
→ Application-layer resolver / case handler (logic + data)  
→ View model or content payload  
→ App-level coordinator chooses UI chrome  
→ Presentation widgets render

---

## Feature Coordinator Rules

Feature coordinators:

- pattern-match on feature specs
- delegate immediately
- are intentionally tiny

They must NOT:

- query repositories
- apply business rules
- format text
- choose card chrome
- assemble widgets

If logic appears here, it is in the wrong place.

---

## Application Layer Rules

Application-layer code (resolvers / case handlers):

- owns feature meaning
- may query repositories
- may compute values
- may format feature-specific text
- may be async
- may contain try/catch

This is where complexity belongs.

---

## Info / Help / Guidance Content

Informational text is a **content domain**, not a UI surface.

Rules:

- Keys are feature-local enums
- Features resolve keys → surface-agnostic content
- Sidebar cards, tooltips, onboarding all reuse the same resolver
- Never duplicate key interpretation across surfaces

---

## UI Chrome Decisions

- Features return data, not wrapped cards
- App-level coordinators decide:
  - card type
  - chrome
  - layout
- Do NOT infer chrome by inspecting widget types

Centralize UI policy.

---

## Widget Builders vs Widgets

Widget builders (application layer):

- assemble widget subtrees
- must not think or fetch data

Presentation widgets:

- render UI
- emit events
- contain no business logic

If a widget needs data access, the architecture is wrong.

---

## Namespacing Rules

- Provider names are generic
- Feature ownership is expressed via import aliases
- Always import feature providers with an alias
- feature_level_providers.dart is the only public entry point

Never rely on globally unique provider names.

---

## When Unsure

Ask:

1. Is this logic interpreting feature meaning?  
   → application-layer resolver

2. Is this just routing based on a spec?  
   → feature coordinator

3. Is this choosing layout or chrome?  
   → app-level coordinator

4. Is this drawing pixels?  
   → presentation widget

Put the code there.