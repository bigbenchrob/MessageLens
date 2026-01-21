# Example — End-to-End Onboarding Flow (Outer Spec → Feature → Payload)

This document walks through a concrete example of a new spec-driven system:
`essentials/onboarding`.

It demonstrates how essentials routes by **feature only**, while the feature
interprets **inner spec variants** and returns a system-specific payload.

---

## Scenario

We want an onboarding tour step that explains contact name settings.

- The onboarding system defines an outer routing spec:
  - `OnboardingSpec.contacts(innerSpec)`
- The Contacts feature defines the inner spec variants:
  - `ContactsOnboardingSpec.nameSettings()`
  - `ContactsOnboardingSpec.cassetteSystemIntro()`
  - etc.

The essentials onboarding coordinator **must not** know what
`ContactsOnboardingSpec.nameSettings()` means.

---

## Step 1 — Outer Routing Spec (Essentials-Owned)

`essentials/onboarding/domain/entities/onboarding_spec.dart`

Conceptual shape:

- OnboardingSpec.contacts(ContactsOnboardingSpec inner)
- OnboardingSpec.handles(HandlesOnboardingSpec inner)
- etc.

Key property:

- The outer spec variant determines feature ownership.
- The inner spec is carried as opaque data from the system’s point of view.

---

## Step 2 — Onboarding Coordinator Routes by Feature Only (Essentials-Owned)

`essentials/onboarding/application/onboarding_coordinator_provider.dart`

Pseudocode:

- switch (outerSpec)
  - case contacts(inner):
      call contacts onboarding coordinator with inner
  - case handles(inner):
      call handles onboarding coordinator with inner
  - ...

The onboarding coordinator does NOT:

- switch on `ContactsOnboardingSpec` variants
- format feature-specific text
- compute feature-specific values

It only routes.

---

## Step 3 — Feature Onboarding Coordinator Routes Inner Variants (Feature-Owned)

`features/contacts/application/onboarding/spec_coordinators/onboarding_spec_coordinator.dart`

Pseudocode:

- buildViewModel(ContactsOnboardingSpec spec):
  - switch spec:
    - nameSettings():
        delegate to a case handler that resolves this step
    - cassetteSystemIntro():
        delegate to another case handler
    - ...

This feature coordinator remains small and contains no repositories.

---

## Step 4 — Feature Case Handler Produces a System Payload (Feature-Owned)

`features/contacts/application/onboarding/spec_cases/name_settings_step_case.dart`

Responsibilities:

- gather any data needed for the step
- select the copy / explanatory text
- decide anchors (what UI element this step points to)
- decide actions (next/back/close triggers)
- return the onboarding system’s payload model

Example payload fields (system-owned type):

- stepId
- title/body
- anchor reference (route name, widget key, etc.)
- preferred placement (above/below/right)
- dismiss rules
- optional media

This payload type lives in `essentials/onboarding`, not in the feature.

---

## Step 5 — Essentials Uses Payload to Render the UI (Essentials-Owned)

The onboarding system takes the payload and performs system-level behavior:

- positions overlay relative to anchor
- controls progression between steps
- handles dismissal
- controls transitions/animations
- optionally persists completion state

The feature does NOT implement these behaviors.

The feature only supplies the payload describing what the step is.

---

## Minimal Example Flow

Request:

OnboardingSpec.contacts(
  ContactsOnboardingSpec.nameSettings(),
)

Execution:

1) essentials/onboarding:
   - sees `.contacts(...)`
   - calls contacts onboarding coordinator

2) contacts feature:
   - receives `ContactsOnboardingSpec.nameSettings()`
   - routes to a case handler

3) contacts case handler:
   - returns `OnboardingStepModel(...)`

4) essentials/onboarding:
   - renders step overlay and controls lifecycle

---

## Why This Matters

This example demonstrates the architecture’s key benefits:

- Essentials remains stable even as features add onboarding variants.
- Features can expand onboarding meaning without touching global routing logic.
- The onboarding system can evolve (animations, anchors, persistence) independently.
- Cross-surface meaning (shared content keys) can be reused without forcing systems to merge.

---

## Key Rule (Repeat)

Essentials routes by feature only.  
Features interpret inner spec variants.  
Systems own lifecycle and rendering mechanics.