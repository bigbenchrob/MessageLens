# Feature Spec Handling Flow

This document describes the **canonical flow** that occurs once a spec
(ViewSpec, CassetteSpec, or related) has been routed to a feature.

It focuses on *how* a feature processes a spec, not how the spec arrived there.

---

## The Canonical Flow

Every feature follows the same conceptual pipeline:

Spec  
→ Feature-level coordinator (routing only)  
→ Application-layer resolver / case handler  
→ View model or content payload  
→ App-level coordinator chooses UI chrome  
→ Presentation widgets render UI

Each stage has a sharply defined responsibility.

---

## Step-by-step Breakdown

### 1. A Spec Reaches the Feature

A spec arrives at a feature via an app-level coordinator.

Examples:

- A `CassetteSpec` routed by `CassetteWidgetCoordinator`
- A `ViewSpec` routed by a panel coordinator
- An information request routed by a future tooltip or onboarding coordinator

At this point, the spec is still **abstract** and **implementation-agnostic**.

---

### 2. Feature-level Coordinator (Routing Only)

Each feature exposes one or more coordinators whose only job is to:

- pattern-match on the feature’s spec type
- delegate immediately to application logic

Characteristics:

- Very small
- No data access
- No formatting
- No UI decisions

Example responsibilities:

- “This is an info-related spec”
- “This is a chooser-related spec”
- “This is a summary-related spec”

The coordinator does **not** attempt to answer:
- what data is required
- how the result should look
- what chrome should be used

---

### 3. Application-layer Resolver / Case Handler

This is where the feature’s **meaning and intelligence** live.

Responsibilities:

- Query repositories or services
- Apply business rules
- Compute derived values
- Format feature-specific copy
- Handle errors and fallbacks
- Produce a view model or content payload

This layer may be:
- synchronous or asynchronous
- complex
- stateful

It is expected to evolve as feature requirements change.

---

### 4. Return a View Model or Content Payload

Application logic returns a **data object**, not a fully composed UI.

This object expresses *intent*, not layout.

Examples of what it may contain:

- title / body text
- resolved counts or labels
- child widget content (unwrapped)
- semantic hints (e.g. “informational”, “control”, “summary”)

It does **not** specify:
- padding
- card shape
- borders
- header placement

---

### 5. App-level Coordinator Chooses Chrome

The app-level coordinator (e.g. cassette or panel coordinator):

- inspects the returned view model
- applies global UI policy
- chooses the appropriate shell or chrome

Examples:

- standard floating cassette card
- informational card
- naked / unframed content
- placeholder or error chrome

This ensures:
- consistent UI across features
- centralized control of layout evolution

---

### 6. Presentation Widgets Render UI

Finally, presentation widgets:

- receive fully resolved data
- render UI
- emit user interactions

They remain:
- dumb
- stateless (or locally stateful)
- unaware of specs or feature logic

---

## Why This Flow Matters

This strict separation:

- keeps features independent
- prevents cross-feature coupling
- centralizes UI policy
- avoids duplication
- allows new surfaces (tooltips, onboarding) to reuse feature logic

Any deviation from this flow should be considered an architectural exception
and documented explicitly.