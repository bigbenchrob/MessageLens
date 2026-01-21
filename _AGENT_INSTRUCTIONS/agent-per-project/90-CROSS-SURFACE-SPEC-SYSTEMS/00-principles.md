# Principles

This architecture generalizes the same high-level idea used by ViewSpecs and
CassetteSpecs:

“Central dispatcher routes a feature-specific spec to the owning feature,
which interprets it and returns a system-appropriate payload.”

---

## 1) Systems are independent

Do not cram unrelated surfaces into an existing system.

Examples:

- Info cassettes are sidebar concerns.
- Tooltips have different lifecycle and anchoring rules.
- Onboarding has progression, triggers, anchors, overlays.

They may share content (meaning) but should not share machinery (state/chains).

---

## 2) Essentials is system-owned, not feature-owned

`essentials/<system>/` contains:

- system state providers
- system-level coordinators
- system UI surfaces and view models
- outer routing spec type: `<System>Spec.<feature>(innerSpec)`

Essentials does NOT contain feature subfolders.

Essentials must remain agnostic to feature-specific inner spec variants.

---

## 3) Features own meaning

Each feature defines:

- inner spec unions (variants)
- enums/keys/constants for meaning
- feature-side coordinators/cases/builders to handle the inner spec

Features interpret and resolve meaning into system-specific payloads.

---

## 4) Routing is by feature only

System coordinator pattern-matches only on the outer spec:

- OnboardingSpec.contacts(...)
- TooltipSpec.handles(...)
- SidebarSpec.messages(...)

It then delegates to the owning feature.

It does not inspect the inner feature spec variants.

---

## 5) Share meaning, not machinery

Cross-surface reuse should occur at the “meaning” layer:

- keys
- content resolvers
- domain computations

Do NOT reuse cassette pipeline to implement onboarding.
Do NOT express onboarding as a cassette spec.



