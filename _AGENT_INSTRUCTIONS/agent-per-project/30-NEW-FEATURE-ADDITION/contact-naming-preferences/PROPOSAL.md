---
tier: project
scope: planning
author: GitHub Copilot (GPT-5-Codex Preview)
created: 2026-01-07
status: draft
links:
  - seed.txt
  - ../manual-handle-to-contact-linking/PROPOSAL.md
---

# Contact Naming Preferences – Settings Sidebar Integration Proposal

## 1. Context
- Overlay database now persists `ParticipantOverrides` rows with `nickname`, `displayNameOverride`, and `nameMode`.
- Contact picker, search, and list providers already consume nickname/display overrides; global name-mode preference is not yet surfaced in UI.
- User goal: expose a coherent naming system in Settings while keeping per-contact tweaks contextual (hero card) and the chooser uncluttered.

## 2. User Mental Model (from seed)
- Primary intent: “Call this person _this_.” Global policies are secondary.
- Design must emphasise per-contact edits as the canonical flow, with Settings acting as the default rule-set and review surface.

## 3. Experience Overview
- **Global Default (Settings Sidebar)**
  - Section title: “How names are shown”.
  - Radio group options (mirrors `ParticipantNameMode` when scoped globally):
    1. First name only
    2. First initial + last name
    3. Nickname when available (fallback to first name)
  - Helper text: “Applies to contacts without custom settings.”
  - Data persists in the overlay database layer alongside other user overrides.
- **Per-Contact Overrides (Hero Panel)**
  - Inline edit affordance (e.g., pencil icon) reveals:
    - Radio set: Inherit default, First name only, First initial + last name, Use nickname, Use custom display name.
    - Nickname field enabled when nickname mode selected.
    - Display-name override field enabled when override mode selected.
  - Persist via overlay DB helpers (`setParticipantNameMode`, `setParticipantNickname`, `setParticipantDisplayNameOverride`).
- **Chooser List**
  - Stays read-only; provide contextual action (keyboard shortcut or context menu) that navigates to hero editing state.
  - Avoid inline text fields to maintain scanability.

## 4. Architecture Alignment
- Preserve working/overlay separation: all writes go through `overlayDatabaseProvider`; merged views remain provider-driven.
- Riverpod patterns: continue using generated providers (`@riverpod`, `part '...g.dart'`).
- Navigation respects ViewSpec pipeline; the sidebar relies on `SidebarMode`-keyed cassette racks so settings panels remain isolated from navigation stacks.
- macOS styling: reuse existing sidebar components and hero layout primitives to maintain platform consistency.

## 5. Implementation Phasing
1. **Data & Provider Audit**
  - Confirm global setting source of truth within the overlay database layer.
   - Identify missing repository/provider hooks for global name mode.
2. **Settings Sidebar Enhancements**
   - Introduce new section with radio controls.
   - Wire to global preference provider; ensure updates invalidate dependent selectors.
3. **Hero Panel Editing**
   - Add per-contact edit affordance, binding to overlay mutations.
   - Ensure optimistic UI updates align with provider cache invalidation.
4. **Chooser Touchpoints**
   - Add context menu / shortcut to jump into hero edit flow via ViewSpec navigation.
   - Confirm search/picker providers surface updated names immediately.
5. **Polish & QA**
   - Copy audit (terminology swap from “Short name” to user-facing phrasing).
   - Accessibility: keyboard navigation, voiceover labels.
   - Analytics/logging hooks if applicable.

Each phase will be reviewed before execution per guardrails.

## 6. Risks & Mitigations
- **Mismatch between name-mode enum and UI labels** → Provide mapping layer + tests.
- **Race conditions on overlay writes** → Centralise mutations in application services and invalidate providers.
- **User confusion over dual overrides (nickname vs display)** → Inline helper text, disable irrelevant controls.

## 7. Resolved Decisions
- Persist all new naming preferences within the overlay database; plan future backup strategy separately.
- Do not surface a global list of per-contact overrides in Settings—overrides remain contextual to each contact.
- No dedicated undo/redo flow is required; users can adjust overrides directly as needed.

## 8. Next Steps
- Review and approve this proposal.
- Upon approval, lock scope for Phase 1 and build corresponding checklist items.
