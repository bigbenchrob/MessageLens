---
tier: project
scope: navigation
owner: agent-per-project
last_reviewed: 2026-09-08
source_of_truth: doc
links:
  - ./README.md
  - ../40-FEATURES/README.md
  - ../95-WALK-UI-TREE/README.md
tests: []
---

# Feature Planning Index

This folder is a mixed staging and history area. It contains active feature
plans, implemented-feature retrospectives, abandoned or superseded proposals,
and design/audit material that was intentionally preserved.

Do not assume that a folder here is current implementation guidance merely
because it exists.

## How To Use This Folder

1. Start with the current owner:
   - shipped feature guidance: [`../40-FEATURES/`](../40-FEATURES/)
   - active UI/UX walk: [`../95-WALK-UI-TREE/`](../95-WALK-UI-TREE/)
   - source-scoped graph and evidence invariants:
     [`../55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md`](../55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md)
2. Use this folder for proposal history, rationale, audits, or explicitly
   active feature-planning folders.
3. Before implementing from a folder here, verify that it is listed as active
   below, linked by a current roadmap, or explicitly named by the user.

## Active Or Potentially Active Planning Folders

These folders were still listed as active/planning in the workflow README at
the time of this IA pass. Verify status before implementation.

Latest package 23 work: the
[truthful Messages-source vs FDA correction](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/55-TRUTHFUL-MESSAGES-SOURCE-VS-FDA-READINESS-IMPLEMENTATION.md)
resolves Validation 54's remaining P1. Only explicit permission-denial evidence
now enters FDA remediation; other unusable-source outcomes receive bounded
source guidance through the unchanged generic Presence Boolean grammar. The
[existing-installation correction](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/56-OBSERVED-ONBOARDING-STEP-REDEFINITION-BLOCKER-IMPLEMENTATION.md)
preserves canonical Step 6302 and lets that additive topology reconcile without
resetting `presence.db` or weakening definition immutability.

Feature Addition 23 is now closed at its natural architectural boundary. Its
[guidebook lifecycle handoff](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md)
records the production evidence and transfers guidebook installation,
generation/replacement, runtime definition authority, removal of runtime
reconciliation, and cross-version Presence-state policy to the next sibling
feature addition. The package remains historical and may receive factual
corrections; it is no longer the active home for that work.

| Folder | Current reading |
| --- | --- |
| [`03-INTRODUCE-SIDEBAR-CONTENT-SEAM/`](03-INTRODUCE-SIDEBAR-CONTENT-SEAM/) | Active design-planning area for aligning sidebar cassette chains with the X-column layout work. |
| [`04-CONVERSATION-TAGS/`](04-CONVERSATION-TAGS/) | Implemented first slice for durable user-created semantic labels attached to canonical Conversation identity. Also contains deferred evaluations such as Contact-backed Conversation Tags as identity-backed retrieval coordinates. |
| [`05-CONVERSATION-INTENT-ARCHITECTURE/`](05-CONVERSATION-INTENT-ARCHITECTURE/) | Exploratory architecture package defining Conversation Intent as the broader overlay/user-intent seam under Favourites, Tags, Working Sets, Hidden state, Notes, saved investigations, and future user-confirmed classifications. |
| [`06-STRUCTURED-CONVERSATION-RETRIEVAL/`](06-STRUCTURED-CONVERSATION-RETRIEVAL/) | Structured retrieval planning for describing remembered Conversation context with tokens. First implemented slice consumes Tag tokens. |
| [`07-TAG-VISIBILITY-POLICY/`](07-TAG-VISIBILITY-POLICY/) | Planning package for visibility policy attached to Tag definitions, including suppressing low-value Conversation classes from ordinary browsing while keeping them explicitly retrievable. |
| [`08-CROSS-COLUMN-LAYOUT-TRACKS/`](08-CROSS-COLUMN-LAYOUT-TRACKS/) | Foundational architecture package that evolved fixed title/context column bands into page-resolved horizontal layout tracks. Its Track and occupant model is now implemented and further refined by package 09; current operating guidance lives in `09-CROSS-COLUMN-LAYOUT/`. |
| [`09-TRACK-SYSTEM-MATRIX-REFACTOR/`](09-TRACK-SYSTEM-MATRIX-REFACTOR/) | Completed Search-page migration to one authoritative `PageTrackLayoutMatrix`, placement-independent occupants, complete `CellId` rendering, and stable optional-panel geometry. Canonical operating guidance now lives in `09-CROSS-COLUMN-LAYOUT/`; this package preserves architecture, migration, and verification evidence. |
| [`23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/`](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/) | Completed generic Boolean Test and `ChoiceStep` consolidation, including schema-v9 persistence, runtime, presentation, and production integration. The active Onboarding Schedule now uses that grammar for Messages-history sufficiency and the permanent Presence runner renders it in production; FDA Settings opening remains an explicit specialist exception. The accepted-readiness [handoff implementation](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/20-DURABLE-ACCEPTED-READINESS-IMPORT-HANDOFF-IMPLEMENTATION.md) composes durable Schedule completion with unchanged environment facts so sparse accepted sources can reach the existing import action. The [initial import and graph-build audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md) records the real reset/build boundary, progress and restart limits, and false Abort contract; the bounded [implementation follow-up](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/22-REMOVE-MISLEADING-ABORT-IMPORT-IMPLEMENTATION.md) removes that false affordance. The [progress-surface audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md) establishes minimal calm as the best experience supportable from current facts, and its [bounded implementation](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/24-TRUTHFUL-KEEP-OPEN-PROGRESS-GUIDANCE-IMPLEMENTATION.md) replaces repetitive progress prose with truthful keep-open and use-other-apps guidance without stage telemetry. The [pre-overlay gap audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md) identifies the invisible pre-reset interval; its [bounded implementation](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md) moves the existing Gate-owned preparation overlay ahead of reset without adding command state or persistence. The [attachment preservation safety record](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md) codifies that archived payloads are preservation data and mechanically protects the reset allow-list. The [initial-setup completion audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md) traces the transient completion handoff; its [bounded implementation](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/29-CALM-INITIAL-SETUP-COMPLETION-HANDOFF-IMPLEMENTATION.md) replaces primary pipeline metrics with a calm readiness statement while preserving diagnostic reports, transient completion, and the existing action behavior. The [failure and recovery surface audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md) separates caught failures from inferred incomplete state and defines the human failure truth budget. Its first [bounded implementation](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md) prevents raw controller exceptions from becoming active-progress headlines; the next [stable-copy implementation](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md) unifies import- and graph-bucket primary failure narratives without changing diagnostics or operation mechanics. The [secondary-information audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md) recommends calm primary copy plus visible secondary support and no Technical Details disclosure; its bounded corrections remove [What to check](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md), [Environment Summary](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md), and the [pre-action transport caption](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/36-REMOVE-SUPPORT-TRANSPORT-CAPTION-STABLE-FAILURE-IMPLEMENTATION.md) from ordinary stable-failure reading order while preserving diagnostics, retry/support behavior, post-action feedback, and other summary uses. The [automatic-recovery presentation audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md) establishes calm, non-interactive recovery as the truthful philosophy, places the internal reset reason outside ordinary reading order, and records that cleanup only enables a later setup attempt rather than rerunning or resuming setup. Its bounded implementations remove the [heuristic reason card](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md) and replace unsupported prior-attempt/deletion language with [calm, truthful recovery copy](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/39-CALM-TRUTHFUL-AUTOMATIC-RECOVERY-COPY-IMPLEMENTATION.md), while preserving classification, diagnostics, recovery mechanics, and the reset allow-list. The [recovery and pre-build failure-state audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md) distinguishes prerequisite blocking, busy denial, other pre-action admission failure, and admitted reset failure, and recommends one process-local Onboarding preparation-failure state as the next bounded slice while retaining filesystem probes as durable restart authority. Its [bounded implementation](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md) keeps failed first-run and automatic preparation outcomes visible for the current process, reuses ordinary retry and support behavior, and preserves environment truth on refresh and restart without adding persistence or changing reset, controller, FDA, busy-denial, Presence, Settings, or attachment behavior. The [automatic-recovery mutation-busy deferral audit](23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md) proves the unchanged-report denial loop, identifies the coordinator's existing reactive release seam, and recommends one Gate-owned event-driven re-evaluation slice without timers, queueing, persistence, new status, busy UI, or recovery/reset policy changes. |
| [`24-HEATMAP-COLOR-REVISION/`](24-HEATMAP-COLOR-REVISION/) | Implemented two-regime calendar heatmap encoding: neutral sparse-activity greys followed by an intentionally chromatic, sequential sustained-activity scale. The package records why perceived magnitude—not globally monotonic luminance—is the governing invariant. |
| [`26-PRODUCTION-ARCHIVE-RECOVERY/`](26-PRODUCTION-ARCHIVE-RECOVERY/) | Temporarily reopened for a separate historical-message recovery task. The March attachment [relational bridge audit](26-PRODUCTION-ARCHIVE-RECOVERY/responses/01-MARCH-2026-ATTACHMENT-RELATIONAL-BRIDGE-AUDIT.md) and [closure](26-PRODUCTION-ARCHIVE-RECOVERY/responses/02-MARCH-2026-RECOVERY-MANIFEST-AND-CLOSURE.md) remain final and authorize no payload recovery. The 8,882-message 2012-2017 donor has now completed a successful disposable staging rehearsal; the [post-correction verification](26-PRODUCTION-ARCHIVE-RECOVERY/responses/06-HISTORICAL-IMPORT-POST-CORRECTION-VERIFICATION.md) confirms source-scoped import, timestamps, and graph projection. Owner-aware graph admission has replaced the provisional pre-open workaround. Historical Archives UX/lifecycle behavior is the next concern. |
| [`27-MESSAGE-HISTORY-COVERAGE/`](27-MESSAGE-HISTORY-COVERAGE/) | Active current-Mac coverage work package. The exact source-identity partition and fast set query are implemented; the product presentation now gives complete results a calm conclusion and compact evidence surface while making real unaccounted exceptions primary. |
| [`28-ONBOARDING/`](28-ONBOARDING/) | Active Onboarding completion work. The opening audit reconstructs the Journey and release blockers; the first implementation slice adds one typed durable operation snapshot, terminal failure routing, process-restart interruption, durable reconciliation, and a Presence projection seam without a schema change. |
| [`29-CONVERSATION-HEATMAP/`](29-CONVERSATION-HEATMAP/) | Active documentation-only planning package for expanding the selected Conversation Card into the existing year-by-month heatmap and reusing the evidence skeleton plus exact-message anchor path for coarse temporal navigation. |
| [`archive-canonical-attachments/`](archive-canonical-attachments/) | Attachment/archive planning material. Verify against `25-ONBOARDING-AND-ARCHIVE/`, `55/84`, and current archive/recovery work before implementation. |
| [`ephemeral-sidebar-projection/`](ephemeral-sidebar-projection/) | Sidebar projection planning material. Verify against the canonical spec/cassette system and current UI-walk direction before implementation. |

## Migrated Or Canonicalized Elsewhere

These folders contain useful rationale, but the canonical home for day-to-day
guidance now lives elsewhere.

| Folder | Canonical owner now |
| --- | --- |
| [`01-CONVERSATION-TOPOLOGY-PRESENTATION/`](01-CONVERSATION-TOPOLOGY-PRESENTATION/) | Conversation presentation and UI work now lives under `40-FEATURES/conversations/`, `95-WALK-UI-TREE/`, and the message evidence spine docs in `55/69`. |
| [`02-UNIFIED-MESSAGE-EVIDENCE-HEADER/`](02-UNIFIED-MESSAGE-EVIDENCE-HEADER/) | Shared message evidence UI work now belongs to the UI walk and message evidence spine documentation. |
| [`database-health-audit/`](database-health-audit/) | Implemented database health architecture lives under `12-DATABASE-HEALTH-AUDIT/`. |
| [`enhanced-onboarding-flow/`](enhanced-onboarding-flow/) and [`enhanced-onboarding-readiness-panel/`](enhanced-onboarding-readiness-panel/) | Onboarding/archive guidance lives under `25-ONBOARDING-AND-ARCHIVE/`. |
| [`living-attachments-archive/`](living-attachments-archive/) and [`living-attachments-deterministic/`](living-attachments-deterministic/) | Current archive/recovery guidance lives under `25-ONBOARDING-AND-ARCHIVE/` and `55/84`. |
| [`settings-cassette-system/`](settings-cassette-system/), [`sidebar-cassette-role-system/`](sidebar-cassette-role-system/), [`sidebar-flow-state-introduction/`](sidebar-flow-state-introduction/) | Canonical sidebar/spec guidance lives under `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/` and the active UI walk. |

## Historical Proposal Archive

Most other folders are retained as historical proposal, spike, retrospective,
or refinement material. They are useful for:

- understanding why a decision was made;
- recovering a discarded idea;
- tracing the evolution of a shipped feature;
- auditing an older implementation path.

They are not current marching orders unless a current document links to them.

## Information Architecture Notes

This folder is intentionally not deeply reorganized yet.

Reason:

- It preserves chronological and conversational development history.
- Many links in current and historical docs refer to these paths.
- A navigation index improves discoverability without breaking those links.

If the folder continues to grow, prefer adding a small `archive/` taxonomy only
after the current release/UI-walk phase, and only with link-preserving redirect
notes.
