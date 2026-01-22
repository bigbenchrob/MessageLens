# Example - End-to-End Onboarding Flow

This example shows how a new spec-driven system routes by feature only, while
the feature interprets inner spec variants and returns a system payload.

---

## Scenario

We want an onboarding step that explains contact name settings.

- The onboarding system defines an outer routing spec:
  - `OnboardingSpec.contacts(innerSpec)`
- The Contacts feature defines the inner spec variants:
  - `ContactsOnboardingSpec.nameSettings()`
  - `ContactsOnboardingSpec.cassetteSystemIntro()`

The essentials onboarding coordinator never interprets
`ContactsOnboardingSpec.nameSettings()`.

---

## Step 1 - Outer routing spec (essentials-owned)

`essentials/onboarding/domain/entities/onboarding_spec.dart`

Conceptual shape:

- OnboardingSpec.contacts(ContactsOnboardingSpec inner)
- OnboardingSpec.handles(HandlesOnboardingSpec inner)

The outer spec determines feature ownership. The inner spec is opaque to the
system.

---

## Step 2 - System coordinator routes by feature only

`essentials/onboarding/application/onboarding_coordinator_provider.dart`

Pseudocode:

- switch (outerSpec)
  - case contacts(inner): delegate to contacts feature
  - case handles(inner): delegate to handles feature

The coordinator does not inspect inner variants or format feature text.

---

## Step 3 - Feature coordinator routes inner variants

`features/contacts/application/onboarding/spec_coordinators/onboarding_spec_coordinator.dart`

Pseudocode:

- buildPayload(ContactsOnboardingSpec spec)
  - switch spec:
    - nameSettings(): delegate to a case handler
    - cassetteSystemIntro(): delegate to another case handler

The feature coordinator remains small and contains no repositories.

---

## Step 4 - Feature case handler produces a system payload

`features/contacts/application/onboarding/spec_cases/name_settings_step_case.dart`

Responsibilities:

- gather data needed for the step
- select copy and formatting
- decide anchors and actions
- return the onboarding system's payload model

Example payload fields (system-owned type):

- stepId
- title/body
- anchor reference
- placement preference
- dismiss rules
- optional media

---

## Step 5 - Essentials renders UI and controls lifecycle

The onboarding system uses the payload to:

- position overlays relative to anchors
- manage step progression
- handle dismissal
- control transitions and animations

The feature supplies meaning. The system owns lifecycle and presentation.

---

## Minimal example flow

Request:

OnboardingSpec.contacts(
  ContactsOnboardingSpec.nameSettings(),
)

Execution:

1) Essentials sees `.contacts(...)` and routes to contacts.
2) Contacts routes to a case handler.
3) The case handler returns `OnboardingStepModel(...)`.
4) Essentials renders the step and manages its lifecycle.

---

## Key rule (repeat)

Essentials routes by feature only.
Features interpret inner spec variants.
Systems own lifecycle and rendering mechanics.
