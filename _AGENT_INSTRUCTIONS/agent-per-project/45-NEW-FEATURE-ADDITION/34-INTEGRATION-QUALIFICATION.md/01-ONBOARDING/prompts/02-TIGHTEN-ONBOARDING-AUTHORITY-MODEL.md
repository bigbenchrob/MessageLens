Before implementation, tighten the authority model.

I do not want two independently mutable sources of truth for onboarding state.

OnboardingJourneyCoordinator must be the **single authority for user-visible onboarding phase and terminal outcome**.

OnboardingOperationSnapshot may be durable operation **evidence** only: operation identity, current operation phase, progress counters, resumability/recovery evidence, and failure details needed by the coordinator. It must not independently authorize or publish Journey success/failure/ready state, and presentation must not choose its onboarding state directly from the snapshot.

Establish an explicit one-way relationship:

operation execution/evidence → JourneyCoordinator → presentation

not:

JourneyCoordinator ↔ OperationSnapshot → presentation

Also require every operation snapshot to be scoped to a unique operation/generation so stale evidence from a previous operation cannot be combined with a new Journey state.

Please revisit the correction plan under that invariant before changing code, and report whether the existing architecture can support it without parallel authorities.

I would go one step further: **stop calling the snapshot an “authority”** in the design discussion. “Durable operation evidence” is much clearer.

The architecture is fine if there are several components with different responsibilities. The danger is several components each answering **“what state are we in?”**. That is exactly the multiple-chefs problem you’re pointing at.
