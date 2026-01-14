---
tier: project
scope: execution-checklist
author: GitHub Copilot (GPT-5-Codex Preview)
created: 2026-01-07
status: draft
links:
  - PROPOSAL.md
  - seed.txt
---

# Contact Naming Preferences – Execution Checklist

> **Guardrail**: Halt after each stage, gather findings, and confirm next-step approval before continuing.

## Stage 0 – Kickoff
- [ ] Confirm proposal approval and capture any scope adjustments.
- [ ] Align on target cassette/panel owners (Settings, Hero, Chooser).
- [ ] Verify overlay DB migrations are not required.
- [ ] Document testing expectations (unit, widget, manual scenarios).
- [ ] **Pause for review**

## Stage 1 – Data & Provider Readiness
- [ ] Audit existing providers for global name-mode preference (search for `ParticipantNameMode`).
- [ ] Specify where the global default will persist (existing settings table or new overlay entry).
- [ ] If new persistence needed, define Drift companion and application service plan (no schema changes without extra approval).
- [ ] Draft provider interfaces (no code edits yet) and record in execution notes.
- [ ] **Pause for review**

## Stage 2 – Settings Sidebar Enhancements
- [ ] Design radio/button layout skew to macOS sidebar style (mock or ASCII sketch acceptable).
- [ ] Identify target widget file(s) and impacted providers.
- [ ] Plan state flow (global provider ←→ UI component) including invalidation strategy.
- [ ] Outline analytics/telemetry impact if any.
- [ ] **Pause for review**

## Stage 3 – Hero Panel Editing Flow
- [ ] Map hero view file(s) and ViewSpec path for selected contact.
- [ ] Plan edit affordance (icon placement, keyboard shortcut) referencing existing design tokens.
- [ ] Define validator behavior for nickname/display fields (trimming, empty handling).
- [ ] Document mutation sequence (UI → application service → overlay DB) ensuring provider refresh.
- [ ] **Pause for review**

## Stage 4 – Chooser Touchpoints
- [ ] Decide on context menu text and shortcut to open hero edit state.
- [ ] Confirm navigation call uses existing ViewSpec pattern (no new routing primitives).
- [ ] Ensure contact list/search providers respond to overlay updates without additional work.
- [ ] Outline regression test plan for picker/search filtering.
- [ ] **Pause for review**

## Stage 5 – Polish, QA, and Launch Readiness
- [ ] Copy review: adopt user-facing terminology (“How names are shown”, “Use custom name”).
- [ ] Accessibility review: focus order, labels, voiceover, contrast.
- [ ] Testing checklist: unit tests, widget tests, manual verification scenarios.
- [ ] Rollback/feature-flag strategy if applicable.
- [ ] Release notes / documentation updates (e.g., `_AGENT_INSTRUCTIONS/40-FEATURES/contact-names`).
- [ ] **Pause for review**

## Stage 6 – Post-Launch Monitoring (Optional)
- [ ] Define metrics or logs to monitor name edits (if tooling available).
- [ ] Collect feedback pipeline (support, user research snippets).
- [ ] Schedule retrospective / follow-up tasks (e.g., override list in Settings).
- [ ] **Closeout**
