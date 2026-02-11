---
tier: proposal
status: draft
owner: @rob
last_reviewed: 2025-11-18
related_features:
  - navigation-system
  - contacts-sidebar
  - chats-sidebar
---

# Self-Assembling Sidebar Proposal

## Problem Statement
- The current ViewSpec navigation works cleanly for single-feature center panel pages but breaks down for the left sidebar.
- Sidebar content is a mixture of shared controls ("Show messages from:"), contact pickers, chat lists, unmatched handles, and upcoming message widgets that render simultaneously.
- Each feature currently duplicates header UI or reaches across boundaries to inject its content, leading to tight coupling and inconsistent state management.

## Goals
- Allow the left sidebar to compose multiple feature widgets vertically without a central hard-coded layout.
- Preserve ViewSpec as the navigation contract while letting each component specify the next component in the column.
- Ensure that changing a selection at any level rebuilds everything beneath it, keeping UI and state aligned.
- Maintain compatibility with existing Riverpod providers and keep incremental adoption possible.

## High-Level Approach
1. **Introduce `SidebarColumnSpec`:** a ViewSpec payload that simply seeds the column with an initial `SidebarSegmentSpec` (e.g., `SidebarSegmentSpec.topMenu`).
2. **Segment Providers:** each feature exposes a provider that returns a `SidebarSegment` value object containing:
   - `Widget build(WidgetRef ref)` – renders its portion.
   - `SidebarSegmentSpec? nextSpec` – the next segment to attach, or `null` to terminate the chain.
   - `bool isSticky` – optional hint to keep the segment even if the next segment changes (for static headers).
3. **Sidebar Column Coordinator:** a lightweight coordinator loops from the initial spec, requesting each segment provider in turn and stacking the resulting widgets top-down until `nextSpec` is `null` or safety limits are hit.
4. **Invalidation Rules:** when user interaction changes a segment's state (e.g., a different contact is selected), that segment updates its provider state; the coordinator watches segment specs and rebuilds from that point downward.
5. **Feature Responsibilities:**
   - **Top Menu:** emits the first functional spec derived from the user choice (contacts, unmatched handles, global messages).
   - **Contacts Segment:** decides between flat list or enhanced picker; emits a `MessagesSpec.allContactMessages` when a contact is selected.
   - **Messages Segment:** renders an all-messages summary for the selected contact and unconditionally emits a `ChatsSpec.viewModePicker`.
   - **Chats Segment:** renders the mode picker and, based on the current mode, emits either chat lists or future message visualizations.

## Implementation Plan
1. **Spec Definitions:**
   - Add `SidebarSegmentSpec` sealed class alongside existing ViewSpecs.
   - Add `SidebarColumnSpec` variant to `SidebarSpec` that carries an initial `SidebarSegmentSpec`.
2. **Coordinator & Surface:**
   - Create `sidebarColumnCoordinatorProvider` in `lib/essentials/navigation/presentation/view_model/`.
   - Add a `SidebarColumnSurface` widget in `presentation/view/` that consumes the coordinator and renders the segment widgets in order.
3. **Segment Contracts:**
   - Define `SidebarSegment` data class and `SidebarSegmentBuilder` type alias.
   - Update existing features (contacts, chats, unmatched handles) to expose segment builders that conform to the new contract.
   - Move duplicated header logic into a shared `TopMenuSegment` under `essentials/navigation/presentation/widgets/`.
4. **State Updates:**
   - Update `panelsViewStateProvider` to seed the sidebar with `SidebarSpec.column(initialSegment: SidebarSegmentSpec.topMenu())`.
   - Ensure each segment writes its selection to a Riverpod provider so downstream segments receive updated data via `.select` watchers.
5. **Migration Path:**
   - Step 1: wire the coordinator but let it call existing widgets (minimal change).
   - Step 2: refactor contacts and chats features to emit segment specs rather than direct navigation calls.
   - Step 3: re-implement unmatched handles and future heat map segments using the same pattern.

## Impacts
- **Positive:** removes duplicated UI, clarifies responsibilities, makes it easy to insert new sidebar experiences (e.g., message heat map).
- **Risks:** recursive segment assembly must guard against cycles and runaway builds. We will cap the maximum depth (e.g., 10 segments) and log a warning if exceeded.
- **Performance:** segment widgets are normal Flutter widgets; rebuild cost matches existing approach. Hooking rebuilds to provider invalidation avoids unnecessary work.

## Open Questions
- Should `SidebarSegmentSpec` include explicit priority ordering for future parallel segments (e.g., dual-column layouts)?
- Do we allow multiple segments to declare the same next spec, or does the coordinator enforce one-to-one relationships?
- How do we expose analytics/telemetry for segment transitions without coupling features to logging infrastructure?

## Next Steps
1. Collect feedback on the segment chain contract and naming.
2. Prototype the coordinator with the current contacts + chats workflow.
3. Decide how message heat map and global views plug into the chain.
4. Once approved, break implementation into small PRs: spec definitions, coordinator, contacts refactor, chats refactor, unmatched handles, future segments.
