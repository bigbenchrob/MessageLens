---
tier: project
scope: navigation
owner: agent-per-project
last_reviewed: 2026-08-30
source_of_truth: doc
links:
  - ./README.md
  - ./01-PROJECT/05-CURRENT-STATE.md
  - ./00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md
  - ./95-WALK-UI-TREE/README.md
tests: []
---

# Start Here

Use this page when opening the MessageLens documentation cold.

It answers three questions:

1. What is current?
2. What is canonical?
3. What is historical reference?

## Fast Path

Read these first:

1. [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md) - cohesive mental model for new
   developers and fresh agents.
2. [`README.md`](README.md) - top-level documentation map.
3. [`01-PROJECT/05-CURRENT-STATE.md`](01-PROJECT/05-CURRENT-STATE.md) -
   current project phase, active data spine, and feature ownership.
4. [`00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md`](00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md) -
   architectural constitution entry point.
5. [`95-WALK-UI-TREE/README.md`](95-WALK-UI-TREE/README.md) - active UI/UX
   review process.
6. [`55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md`](55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md) -
   release-first decision rule.

## Current Project Mode

The current project mode is:

```text
Ship MessageLens.
```

The graph migration is now supporting infrastructure. Architecture hardening
should normally be deferred unless it directly unblocks release readiness,
archive/recovery correctness, onboarding, readiness evaluation, user-visible
correctness, or an active UI-walk review.

## Canonical Owners

| Question | Start with |
| --- | --- |
| Current architecture and code ownership | `01-PROJECT/05-CURRENT-STATE.md`, `01-PROJECT/02-architecture-overview.md` |
| Constitutional architecture rules | `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/` |
| Database access and overlay rules | `10-DATABASES/` |
| Source import, graph build, and live polling | `20-DATA-IMPORT-MIGRATION/` |
| Onboarding and archive/recovery | `25-ONBOARDING-AND-ARCHIVE/` |
| Essentials, navigation, panels, sidebar, search | `30-ESSENTIALS/` |
| Search investigation identity and context compatibility | `40-FEATURES/search/INTERACTIONS_AND_NAVIGATION.md`, `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md` |
| Feature ownership | `40-FEATURES/` |
| Cross-column vertical alignment | `09-CROSS-COLUMN-LAYOUT/` |
| Cross-surface specs and ViewSpec/cassette architecture | `42-SPEC-SYSTEM/` |
| Project-wide Presence interaction system | `43-PRESENCE/` |
| Message Evidence Spine and graph-migration history | `55-READERS-INTEGRATORS-ORCHESTRATORS/` |
| Tester release publication and public download | `65-DISTRIBUTION/` |
| Active UI/UX walk and design language | `95-WALK-UI-TREE/` |

## Historical Reference Areas

Some folders preserve history and audit evidence. They are valuable, but they
are not automatically current implementation guidance.

| Folder | How to read it |
| --- | --- |
| `45-NEW-FEATURE-ADDITION/` | Feature proposals, plans, retrospectives, and in-flight design work. Use its `INDEX.md` before reading individual folders. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/` | Durable RIO invariants plus graph migration history. Use its `TOPIC_INDEX.md` before treating a numbered document as current. |
| `42-SPEC-SYSTEM/REFERENCE/` | Reference and earlier spec-system material. Canonical guidance lives under `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/`. |
| `40-FEATURES/chats/` | Historical chat terminology. Current user-facing Conversation ownership lives in `40-FEATURES/conversations/` and `lib/features/conversations`. |

## Current Terminology

- Use **Conversation** for the canonical graph communication entity.
- Use **Message Evidence Spine** for the shared message display path.
- Use **Favourites/Core Favourites**, not pinned conversations, for global
  user intent attached to Conversation entities.
- Use **Conversation Lens** internally and **Organize by** in UI language for
  conversation organization modes.
- Treat a **Search investigation** as one opaque investigative episode. Equal
  query values reached later do not restore subordinate context from an older
  episode.
- Treat `macos_import.db` and `working.db` as retired cleanup/diagnostic
  inventory, not ordinary app authorities.

## When Unsure

Prefer the most current, highest-level owner:

1. `01-PROJECT/05-CURRENT-STATE.md`
2. the relevant subsystem README
3. the relevant canonical architecture doc
4. historical/audit docs only for background and rationale

If documents conflict, prefer the newer current-state, canonical, or release
documents and record the inconsistency for cleanup.
