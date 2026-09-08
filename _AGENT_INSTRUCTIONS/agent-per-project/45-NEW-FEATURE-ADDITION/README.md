---
tier: project
scope: workflow
owner: agent-per-project
last_reviewed: 2026-09-08
source_of_truth: doc
links:
  - ../../agent-instructions-shared/INDEX.md
  - ./INDEX.md
  - ../40-FEATURES/README.md
tests: []
---

# New Feature Addition Workflow

This folder tracks feature work that is still in planning or active
development, plus historical feature proposals and retrospectives that remain
useful as rationale. Read [`INDEX.md`](INDEX.md) before treating any folder here
as current implementation guidance.

Follow this workflow whenever the user asks for a new capability that is not
yet represented in `40-FEATURES/`.

## Lifecycle Overview

1. **Kickoff** – Create a feature subfolder named `45-NEW-FEATURE-ADDITION/{feature-name}/`.
2. **Proposal** – Draft `PROPOSAL.md` summarizing goals, constraints, and open questions. Wait for user sign-off before planning.
3. **Planning** – Add `CHECKLIST.md`, `DESIGN_NOTES.md`, and `TESTS.md`. Flesh out the detailed checklist covering delivery, review, and verification steps.
4. **Execution** – Implement code while updating the checklist. Keep design notes in sync with any architectural decisions.
5. **Verification** – Ensure planned tests are written and passing. Capture any manual validation in `TESTS.md`.
6. **Completion** – Write `STATUS.md` and move the feature documentation into `40-FEATURES/{feature-name}/` once work ships, unless the folder is intentionally retained here as a historical planning record.

## Feature Folder Template

Each feature folder inside this directory should contain:
```
{feature-name}/
├── PROPOSAL.md
├── CHECKLIST.md
├── DESIGN_NOTES.md
├── TESTS.md
└── STATUS.md        # Added when feature is complete
```

Templates live under `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/`. Copy the feature brief template or create the proposal/checklist/test documents directly when creating a new feature so structure stays consistent.

## Working Agreement

- Do not start implementation until the proposal is approved.
- Keep `CHECKLIST.md` current; treat it as the single source of truth for progress.
- Move artifacts into `40-FEATURES/` once the feature is delivered when the feature has become stable, durable product guidance.
- Some older folders remain here as historical planning records. Do not treat a folder in this directory as active implementation guidance unless it is listed in the current-feature table below, linked from the current roadmap/checklist, or explicitly requested by the user.
- Archive or rename feature folders that the user cancels, documenting the reason in `STATUS.md`.

## Reference Material

- Workflow guide: `AGENTS.md`
- Feature brief template: `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/TEMPLATE-feature-brief.md`

## Active/Planning Feature Folders

The table below is the active/planning set recorded for this folder. Other
folders in this directory may be useful history, but they are not active
marching orders by default. Verify status through [`INDEX.md`](INDEX.md), the
current project roadmap, or the user's latest instruction before implementing.

| Feature | Key Docs |
| --- | --- |
| `archive-canonical-attachments/` | [`PROPOSAL.md`](archive-canonical-attachments/PROPOSAL.md), [`CHECKLIST.md`](archive-canonical-attachments/CHECKLIST.md), [`DESIGN_NOTES.md`](archive-canonical-attachments/DESIGN_NOTES.md), [`TESTS.md`](archive-canonical-attachments/TESTS.md) |
| `ephemeral-sidebar-projection/` | [`PROPOSAL.md`](ephemeral-sidebar-projection/PROPOSAL.md), [`CHECKLIST.md`](ephemeral-sidebar-projection/CHECKLIST.md), [`DESIGN_NOTES.md`](ephemeral-sidebar-projection/DESIGN_NOTES.md), [`TESTS.md`](ephemeral-sidebar-projection/TESTS.md) |
| `03-INTRODUCE-SIDEBAR-CONTENT-SEAM/` | [`PROPOSAL.md`](03-INTRODUCE-SIDEBAR-CONTENT-SEAM/PROPOSAL.md), [`CHECKLIST.md`](03-INTRODUCE-SIDEBAR-CONTENT-SEAM/CHECKLIST.md), [`DESIGN_NOTES.md`](03-INTRODUCE-SIDEBAR-CONTENT-SEAM/DESIGN_NOTES.md), [`TESTS.md`](03-INTRODUCE-SIDEBAR-CONTENT-SEAM/TESTS.md) |
| `04-CONVERSATION-TAGS/` | Exploratory package for durable Conversation Tags: [`PROPOSAL.md`](04-CONVERSATION-TAGS/PROPOSAL.md), [`CHECKLIST.md`](04-CONVERSATION-TAGS/CHECKLIST.md), [`DESIGN_NOTES.md`](04-CONVERSATION-TAGS/DESIGN_NOTES.md), [`TESTS.md`](04-CONVERSATION-TAGS/TESTS.md) |
| `05-CONVERSATION-INTENT-ARCHITECTURE/` | Exploratory architecture package defining the broader Conversation Intent seam underneath Favourites, Tags, Working Sets, Hidden state, Notes, and future user-confirmed classifications: [`PROPOSAL.md`](05-CONVERSATION-INTENT-ARCHITECTURE/PROPOSAL.md), [`CHECKLIST.md`](05-CONVERSATION-INTENT-ARCHITECTURE/CHECKLIST.md), [`DESIGN_NOTES.md`](05-CONVERSATION-INTENT-ARCHITECTURE/DESIGN_NOTES.md), [`TESTS.md`](05-CONVERSATION-INTENT-ARCHITECTURE/TESTS.md) |
| `06-STRUCTURED-CONVERSATION-RETRIEVAL/` | Structured Conversation Retrieval planning for describing remembered Conversation context with tokens: [`PROPOSAL.md`](06-STRUCTURED-CONVERSATION-RETRIEVAL/PROPOSAL.md), [`CHECKLIST.md`](06-STRUCTURED-CONVERSATION-RETRIEVAL/CHECKLIST.md), [`DESIGN_NOTES.md`](06-STRUCTURED-CONVERSATION-RETRIEVAL/DESIGN_NOTES.md), [`TESTS.md`](06-STRUCTURED-CONVERSATION-RETRIEVAL/TESTS.md) |
| `07-TAG-VISIBILITY-POLICY/` | Tag visibility policy attached to Tag definitions: [`PROPOSAL.md`](07-TAG-VISIBILITY-POLICY/PROPOSAL.md), [`CHECKLIST.md`](07-TAG-VISIBILITY-POLICY/CHECKLIST.md), [`DESIGN_NOTES.md`](07-TAG-VISIBILITY-POLICY/DESIGN_NOTES.md), [`TESTS.md`](07-TAG-VISIBILITY-POLICY/TESTS.md) |
| `08-CROSS-COLUMN-LAYOUT-TRACKS/` | Exploratory successor model for cross-column title/context wrappers using shared layout tracks: [`PROPOSAL.md`](08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md), [`CHECKLIST.md`](08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md), [`DESIGN_NOTES.md`](08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md), [`TESTS.md`](08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md) |
| `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/` | Completed generic Boolean Test and `ChoiceStep` consolidation. The active Onboarding Schedule now uses the generic grammar for Messages-history sufficiency and is rendered in production by the permanent Presence runner, with FDA Settings opening retained as an explicit specialist exception. Start with [`00-START-HERE.md`](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/00-START-HERE.md); implementation record [`20`](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/20-DURABLE-ACCEPTED-READINESS-IMPORT-HANDOFF-IMPLEMENTATION.md) records the durable accepted-readiness import handoff. |
| `28-ONBOARDING/` | Active Onboarding completion work covering the first-launch Journey, typed durable operation state, liveness, source anomalies, interruption, recovery, Presence projection, and a preservation-safe future Start Fresh contract. Start with [`README.md`](28-ONBOARDING/README.md). |
| `29-CONVERSATION-HEATMAP/` | Documentation-only planning for selected Conversation Card expansion and reuse of the existing calendar renderer, evidence-skeleton month lookup, exact-message anchor, and indexed timeline jump. Start with [`PROPOSAL.md`](29-CONVERSATION-HEATMAP/PROPOSAL.md). |
