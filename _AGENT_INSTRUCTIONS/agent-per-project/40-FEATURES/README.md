---
tier: project
scope: features
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ../30-NEW-FEATURE-ADDITION/README.md
  - ./chat-handles/CHARTER.md
  - ../50-USE-CASE-ILLUSTRATIONS/README.md
tests: []
---

# Features Library

This directory documents every shipped feature. Each child folder should represent a stable capability that has graduated from `30-NEW-FEATURE-ADDITION/`.

## Feature Index

| Feature | Key Docs |
| --- | --- |
| `contact-favourites/` | [`RECENTS-FAVORITES.md`](contact-favourites/RECENTS-FAVORITES.md) — Picker section precedence, de-duplication, and semantic preservation rules |
| `identify-stray-handles/` | [`MASTER_PLAN.md`](identify-stray-handles/MASTER_PLAN.md) — 3-phase plan: overlay schema + virtual participants → sidebar review + Handle Lens → polish & bulk ops |

## Required Files Per Feature

Create or maintain the following documents inside every feature folder:

| File | Purpose |
| --- | --- |
| `CHARTER.md` | Captures mission, outcomes, stakeholders, and open questions. |
| `DOMAIN_AND_DATA_MAP.md` | Lists aggregates, tables, and external systems touched by the feature. |
| `STATE_AND_PROVIDER_INVENTORY.md` | Catalogues Riverpod providers, state objects, and invalidation rules. |
| `INTERACTIONS_AND_NAVIGATION.md` | Describes user flows, ViewSpec entry points, and cross-feature touchpoints. |
| `TESTING_AND_MONITORING.md` | Defines automated coverage, fixtures, and telemetry expectations. |
| `WORK_LOG.md` | Tracks ongoing changes, decisions, and follow-up items. |

## Using the Templates

Reusable markdown templates for each file live in `agent-instructions-shared/AGENT_PER_PROJECT_SCHEMA/per_project_folder_file_schema.yaml` under the `templates` section. When you migrate a feature from `30-NEW-FEATURE-ADDITION/`, copy in the templates and populate them with project-specific details. Existing features should adopt the same structure for consistency.

## Migration Workflow

1. **Promote a Feature**: Move the feature folder from `30-NEW-FEATURE-ADDITION/{feature}` to `40-FEATURES/{feature}` once it ships.
2. **Apply Templates**: Ensure all required files exist and are filled out using the templates as a starting point.
3. **Backfill History**: Update `WORK_LOG.md` with past milestones and decisions.
4. **Link Documentation**: Cross-reference supporting docs (database guides, provider notes, etc.) so future contributors have a complete map.

## Adding New Features Directly

For features that already exist but lack documentation, create a folder here and populate the six required files using the templates. This keeps the feature library consistent regardless of whether work began in the new-feature staging area.
