---
tier: project
scope: use-case-illustrations
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ../30-NEW-FEATURE-ADDITION/README.md
  - ./manual-handle-to-contact-linking.md
tests: []
---

---
tier: project
scope: use-case-illustrations
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ../30-NEW-FEATURE-ADDITION/README.md
  - ./manual-handle-to-contact-linking.md
tests: []
---

# Use Case Illustrations

This directory captures narrative walk-throughs of shipped capabilities. Each illustration explains how a user intention travels through UI, providers, services, migrations, and databases so future maintainers understand both **what** happens and **why** it happens that way.

## Why These Narratives Matter
- Clarify the user problem that sparked the feature and the trade-offs we made.
- Show how changes ripple across layers (UI, Riverpod, Drift, Rust, overlays).
- Preserve institutional knowledge that can be lost in scattered PRs or code comments.
- Accelerate onboarding by providing a single document that links code, docs, and data.

## Recommended Contents
Every illustration should include:
- **User Problem** – the pain point or scenario we are solving.
- **Solution Overview** – architecture pattern or workflow we chose.
- **System Impact** – affected modules, providers, migrations, and tables.
- **Design Decisions** – key alternatives considered and trade-offs.
- **Data Flow** – step-by-step trace from user action to persisted state.
- **Cross-References** – links to proposals, checklists, schemas, and code.
- **Future Work** – open questions, performance notes, or planned extensions.

## When to Write One
- Before implementing a new multi-layer feature (draft here to align collaborators).
- Immediately after shipping work that required touching multiple aggregates.
- When onboarding new contributors who need the “big picture” for a complex area.

## Relationship to Other Folders
- `30-NEW-FEATURE-ADDITION/` tracks work-in-progress checklists and designs; link to those docs from the illustration.
- `40-FEATURES/` holds the enduring reference docs for each feature; use-case illustrations complement them by telling the narrative.
- Database and migration guides (`10-DATABASES/`, `20-DATA-IMPORT-MIGRATION/`) provide the schema detail you can reference here.

## Current Illustrations
- `manual-handle-to-contact-linking.md` – documents the manual linking workflow from UI trigger through overlay persistence and index rebuilds.

Author new files using the templates defined in `agent-instructions-shared/AGENT_PER_PROJECT_SCHEMA/per_project_folder_file_schema.yaml` (`use_case_illustration` for new docs, `use_case_readme` for this README). Update the list above whenever additional illustrations are added.
