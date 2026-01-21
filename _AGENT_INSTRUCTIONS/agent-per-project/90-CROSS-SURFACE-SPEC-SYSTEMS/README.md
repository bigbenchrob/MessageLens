# Cross-Surface Spec Systems

This folder documents a general architecture pattern:

A *spec-driven system* lives in `essentials/<system>/` and routes feature-specific
inner specs to feature-owned coordinators.

Examples of systems:

- navigation (ViewSpecs / panel stacks)
- sidebar (CassetteSpecs / cassette rack)
- onboarding (tour steps / cartouches)
- tooltips (anchored hints)
- future systems (help, tutorials, wizards, etc.)

This pattern prevents feature complexity from polluting global app space while
keeping the app-level routing uniform and scalable.

---

## Key idea

Essentials owns the system and the outer routing spec.
Features own the inner spec meaning and implementation.

Essentials does NOT contain feature subfolders.