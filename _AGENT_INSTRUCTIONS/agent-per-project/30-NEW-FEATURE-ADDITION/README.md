---
tier: project
scope: workflow
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ../agent-instructions-shared/INDEX.md
  - ../40-FEATURES/README.md
tests: []
---

# New Feature Addition Workflow

This folder tracks feature work that is still in planning or active development. Follow this workflow whenever the user asks for a new capability that is not yet represented in `40-FEATURES/`.

## Lifecycle Overview

1. **Kickoff** – Create a feature subfolder named `30-NEW-FEATURE-ADDITION/{feature-name}/`.
2. **Proposal** – Draft `PROPOSAL.md` summarizing goals, constraints, and open questions. Wait for user sign-off before planning.
3. **Planning** – Add `CHECKLIST.md`, `DESIGN_NOTES.md`, and `TESTS.md`. Flesh out the detailed checklist covering delivery, review, and verification steps.
4. **Execution** – Implement code while updating the checklist. Keep design notes in sync with any architectural decisions.
5. **Verification** – Ensure planned tests are written and passing. Capture any manual validation in `TESTS.md`.
6. **Completion** – Write `STATUS.md` and move the feature documentation into `40-FEATURES/{feature-name}/` once work ships.

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

Templates live under `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/`. Copy them when creating a new feature so structure stays consistent.

## Working Agreement

- Do not start implementation until the proposal is approved.
- Keep `CHECKLIST.md` current; treat it as the single source of truth for progress.
- Move artifacts into `40-FEATURES/` once the feature is delivered so this folder only contains active work.
- Archive or rename feature folders that the user cancels, documenting the reason in `STATUS.md`.

## Reference Material

- Workflow guide: `AGENTS.md`
- Proposal template: `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/feature-proposal-template.md`
- Checklist template: `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/feature-checklist-template.md`
- Testing template: `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/feature-tests-template.md`
