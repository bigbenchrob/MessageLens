---
tier: project
scope: documentation-pass
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: doc
links:
  - ./README.md
  - ./01-PROJECT/05-CURRENT-STATE.md
tests: []
---

# Tester Archive-Import Memory Remediation Reconciliation

Date: 2026-09-15

Scope: Reconciled standing architecture, onboarding, database-health,
source-database, build, distribution, and feature documentation with the
bounded-memory implementation and the published `0.2.111+129` tester artifact.
Historical incident chronology remains in Feature 32; current subsystem docs
now describe the corrected architecture directly.

## Changes

| File or group | Change | Reason |
| --- | --- | --- |
| `00-START-HERE.md`, `README.md`, `01-PROJECT/00-overview.md`, `01-PROJECT/02-architecture-overview.md`, `01-PROJECT/05-CURRENT-STATE.md`, `DEVELOPER_GUIDE.md` | Added the bounded source-import and rich-text architecture to the highest-authority reading paths and current project mental model. | Prevents the remediation from remaining discoverable only through an incident folder. |
| `20-DATA-IMPORT-MIGRATION/01-overview.md`, `10-import-orchestrator.md`, `11-rust-message-extractor.md`, `15-table-importers.md`, `30-incremental-mode-flag.md`, and new `12-bounded-message-import-and-rich-text-enrichment.md` | Replaced current-path whole-corpus and helper-binary descriptions with the frozen-frontier, keyset-page, byte-bounded, `ss_id`-based, FFI-decoder, transaction, and retry contracts; retained the deleted 200,000-row limit only as explicitly historical evidence and repaired retired/current cross-references. | Makes the implementation's actual memory and fidelity boundaries canonical without falsifying retired-framework history. |
| `10-DATABASES/00-all-databases-accessed.md`, `10-DATABASES/10-group-import-working.md`, `15-MACOS-SOURCE-DATABASES/10-CHAT-DB.md`, `15-MACOS-SOURCE-DATABASES/20-external-tools-and-rust-crates.md`, `30-ESSENTIALS/README.md`, `40-FEATURES/messages/DOMAIN_AND_DATA_MAP.md` | Aligned database/source/ownership maps with bounded import, FFI decoding, source-scoped identity, and the fact that retired `macos_import.db` no longer owns archive-source metadata. | Removes parallel descriptions that could reintroduce corpus-sized reads, retired-store writes, or ambiguous identity. |
| `25-ONBOARDING-AND-ARCHIVE/README.md`, `00-overview.md`, `10-onboarding-gate.md`, `20-environment-readiness.md`, `30-import-migration-coordination.md`, `60-reimport-and-ongoing-sync.md`, `ATTACHMENT-PRESERVATION-INVARIANT.md` | Documented exact persisted operation substages, coarse readiness separation, privacy-safe operation evidence, durable continuation, current Journey authority, and reuse of the bounded path for setup, reimport, historical archives, and synchronization; refreshed the preservation-path audit without weakening it. | Makes interruption, recovery, and preservation semantics agree across onboarding documents. |
| `12-DATABASE-HEALTH-AUDIT/README.md`, `00-overview.md`, `06-interpreting-startup-database-logs.md` | Updated schema authority to `1.1.0`, documented privacy-safe enrichment aggregates, exact operation evidence, and packaged runtime metadata. | Replaces coarse or stale support-bundle interpretation with current diagnostics. |
| `60-BUILD-CONSIDERATIONS/README.md`, `01-rust-ffi-dylib-bundling.md`, `02-macos-fda-grant-continuity.md` | Documented packaged metadata authority, FFI decoder packaging, artifact identity verification, and the distinction between qualifying a build and publishing it. | Preserves bundle/signing/FDA continuity and prevents silent publication rebuilds. |
| `65-DISTRIBUTION/README.md`, `65-DISTRIBUTION/10-render-tester-portal.md` | Recorded publication of the exact qualified/notarized `0.2.111+129` DMG and its SHA-256 without rebuilding, while retaining the outstanding low-memory target-Mac gate. | Makes tester-portal state factual without overstating qualification. |
| `45-NEW-FEATURE-ADDITION/32-TESTER-ARCHIVE-IMPORT-FAILURE/13-PHASE-4-AND-RELEASE-QUALIFICATION.md` | Added a chronological publication addendum and clarified which git/artifact facts belonged to qualification time. | Preserves historical evidence instead of retroactively rewriting the incident. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this reconciliation. | Maintains the documentation audit trail. |

No production code, tests, generated files, build artifacts, or portal files
were changed in this pass.

---

# Complete Legacy-Tester Installation Erasure

Date: 2026-08-27

Scope: Codified the separately authorized whole-installation erase operation,
its strict distinction from preservation-safe Start Fresh, and its canonical
archive/environment boundaries.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/28-ONBOARDING/responses/16-COMPLETE-LEGACY-TESTER-CLEAN-INSTALL-ERASE-ALL-MESSAGELENS-OWNED-DATA-IMPLEMENTATION.md` | Added the implementation, ownership inventory, authority, interruption, verification, and tester-rollout record. | Provides one durable Feature 28 reference for the destructive operation. |
| `25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md` | Added the sole separately authorized whole-installation exception while preserving ordinary reset rules. | Prevents complete erasure from being mistaken for a weakening of Start Fresh. |
| `25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md` | Documented the distinct operation and its handoff to the six-node Journey. | Keeps Onboarding ownership and preservation semantics explicit. |
| `50-ENVIRONMENT-SAFETY/00-overview.md` | Added erase-only admission, canonical-root safety, durable recovery, new identity, and virgin proof. | Makes the environment authority chain complete for legacy roots. |
| `10-DATABASES/00-all-databases-accessed.md` | Added the no-database erase-only authority and complete-erasure archive exception. | Prevents obsolete schemas from being opened or migrated before deletion. |
| `45-NEW-FEATURE-ADDITION/28-ONBOARDING/README.md` | Indexed the response and updated Feature 28 status. | Keeps the work package navigable. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the release-facing operation and advanced the version. | Synchronizes tester-facing behavior and release metadata. |

---

# Generalized Delayed Attachment Retry

Date: 2026-07-28

Scope: Replaced the historical image-only maintenance-sweep contract with a
declared-MIME eligibility policy for conventional attachments while retaining
an explicit boundary around opaque plugin payloads.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md` | Documented type-agnostic delayed retry for conventional declared-MIME attachments and the separate NULL/blank-MIME payload policy question. | Makes the canonical archive contract match the corrected candidate policy. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Split the former 12-row residual into three retryable QuickTime rows and nine policy-blocked plugin payloads. | Distinguishes implementation capability, pending production validation, and unresolved preservation semantics. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-PRESERVATION-AUTHORITY.md` | Replaced the image-only limitation with the declared-MIME policy and production verification gate. | Keeps live-preservation authority accurate without claiming an undeployed production recovery. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/COMPLETION-REPORT.md` | Refined remaining follow-up into QuickTime deployment validation and plugin-payload policy. | Preserves a bounded, actionable production closeout. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-facing recovery correction and advanced the release version. | Keeps release metadata synchronized with a significant preservation fix. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/DELAYED-ATTACHMENT-RETRY.md` | Added a concise implementation record describing the image-only defect, declared-MIME correction, plugin-payload boundary, and production follow-up. | Gives the bounded correction one direct reference without rewriting historical cutover evidence. |

---

# External Development Archive Root

Date: 2026-07-27

Scope: Recorded the machine-local, development-only relocation of the complete
MessageLens development archive to the external WD Elements volume.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `50-ENVIRONMENT-SAFETY/00-overview.md` | Added the development root-override contract, native/Dart agreement, fail-closed behavior, complete-root ownership, and preservation of the internal archive. | Makes the operational safety rule canonical without changing production or test policy. |
| `01-PROJECT/03-data-locations.md` | Documented default and machine-local development roots and clarified that all listed archive paths derive from one admitted root. | Prevents future attachment-specific or provider-specific path authority. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Added the current external development root and its bounded status. | Keeps the workstream index synchronized with the implemented development environment. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/COMPLETION-REPORT.md` | Recorded the override as a bounded implementation adjustment and summarized runtime evidence. | Preserves why and how the complete archive was relocated. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/VALIDATION-RESULTS/development-path-manifest.md` | Added external-root startup evidence and retained the remaining full-workflow validation obligation. | Distinguishes verified admission/routing from the still-pending complete interactive manifest. |
| `CHANGELOG.md` | Added the development external-root capability to the current release entry. | Records the tester-facing development environment change. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Production Data Protection Non-Production Completion

Date: 2026-07-27

Scope: Promoted the verified Slices 0-8 implementation into canonical
environment, database, build, and Production Readiness documentation while
keeping production adoption explicitly blocked.

## Changes

| File or folder | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Replaced planning status with the implemented non-production boundary and adoption gate. | Makes the workstream entry point reflect current code. |
| `PROPOSAL.md`, `IMPLEMENTATION-PLAN.md`, `QUESTIONS.md`, and `VALIDATION.md` | Recorded implemented status, bounded Profile/Release adjustment, completed slices, and remaining evidence. | Separates validated architecture from production claims. |
| `COMPLETION-REPORT.md` | Added the Slices 0-8 implementation record, deviations, evidence, and remaining production prerequisites. | Provides one authoritative implementation closeout. |
| `PRODUCTION-ADOPTION-RUNBOOK.md` | Added a blocked planning runbook with preconditions, procedure, and abort rules. | Prepares Slice 9 without authorizing or touching production. |
| `VALIDATION-RESULTS/` | Added retained static, native, path, test, operation, checkpoint, and artifact evidence. | Records objective non-production validation and its limitations. |
| `50-ENVIRONMENT-SAFETY/00-overview.md` | Replaced the placeholder with the canonical archive admission, mutation authority, recovery, and current production-status contract. | Promotes the implemented safety boundary to its permanent owner. |
| `10-DATABASES/00-all-databases-accessed.md` | Replaced mutable physical-root guidance with admitted authority and environment-scoped storage. | Prevents recreation of the retired global path seam. |
| `60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md` | Documented development identity, archive-scoped native admission, and artifact verification. | Preserves production FDA identity while making development separation explicit. |
| `90-DATA-INGESTION-REVIEW/00-PRODUCTION-READINESS-MASTER-PLAN.md` and index files | Updated project status and links. | Keeps top-level orientation consistent with the completed boundary. |

No production archive, marker, or adoption report was created.

# Production Readiness Master Plan

Date: 2026-07-27

Scope: Established the authoritative project overview for the coordinated
review of onboarding, production protection, historical ingestion, archive
integrity, validation, and production health.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/00-PRODUCTION-READINESS-MASTER-PLAN.md` | Created the authoritative project purpose, authority boundary, development/production contract, shared workstream requirements, seven workstreams, progression, invariants, non-goals, and completion criteria. | Gives every subsequent ingestion and onboarding task one governing project contract while preserving existing runtime ownership. |
| `90-DATA-INGESTION-REVIEW/README.md` | Promoted the folder into the project index, linked the master plan and seed, and documented the planned workstream package structure. | Makes the master plan the obvious entry point and keeps future focused packages collected under one shared program. |
| `README.md` | Updated the canonical project map to describe sequence 90 as the authoritative Production Readiness project. | Makes the new program discoverable to future developers and agents. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation pass. | Maintains the documentation audit trail. |

---

# Data Ingestion Review Folder Reuse

Date: 2026-07-27

Scope: Reassigned documentation sequence 90 from the unused use-case
illustration collection to the forthcoming onboarding and archival-ingestion
review.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/README.md` | Created the new working-package entry point and linked current canonical ingestion, onboarding/archive, and database documentation. | Gives the coming review a clear scope without prematurely replacing current architecture. |
| `90-DATA-INGESTION-REVIEW/archive/legacy-use-case-illustrations/` | Preserved the former sequence-90 narrative material as explicitly historical reference. | Reuses the top-level sequence without discarding prior information or letting it define the new review. |
| `README.md` and `_ui_renders/old/documentation_tree` | Replaced the old use-case folder entry with the Data Ingestion Review package. | Keeps the canonical project map and retained documentation-tree rendering free of the retired path. |
| `40-FEATURES/README.md`, `40-FEATURES/chat-handles/CHARTER.md`, and completed feature packages | Removed inbound references to the retired sequence-90 and older sequence-50 use-case folders. | Prevents stale documentation paths from implying that the retired collection remains an active authority. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation maintenance pass. | Maintains the documentation audit trail. |

---

# Column-Specific Shared Track Boundary Refinement

Date: 2026-07-26

Scope: Tightened the new shared-boundary documentation to distinguish matrix
resolution from per-column renderer consumption and to prevent implementation
examples from becoming architectural prescriptions.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/07-column-specific-shared-track-boundaries.md` | Defined native flow, replaced “stops rendering matrix cells” with precise `TrackCellView` consumption language, marked Unknown Sources occupants as current examples, and added the explicit non-goal that boundaries are not performance optimizations. | Keeps complete-matrix resolution distinct from column rendering lifetime and centers truthful composition as the purpose. |
| `09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md` | Elevated common y-positioning and independent shared lifetimes into governing principles. | Gives the conceptual leap constitutional weight in the canonical layout contract. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md` | Clarified that column-specific boundaries affect rendering lifetime only. | Prevents readers from interpreting the matrix, resolver, or composition authority as partial. |
| `09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md` | Replaced cell-level “after A1” boundary wording with Track-level “Column 1 participates through Track A” wording. | Keeps occupancy coordinates distinct from the column's declared shared Track boundary. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this refinement. | Maintains the project documentation audit trail. |

---

# Sidebar Native-Flow Spacing Handoff

Date: 2026-07-26

Scope: Corrected the Track-to-cassette handoff so column-specific shared
boundaries do not unconditionally erase the sidebar cassette coordinator's
resolved section rhythm.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/essentials/navigation/application/panel_widget_providers.dart` | Added a generic native-flow spacing handoff policy. Unknown Sources preserves coordinator-resolved cassette rhythm; Search remains flush because its shared Track composition already supplies separation. | Keeps Track geometry and cassette-stack spacing under their proper owners without feature padding or filler Tracks. |
| `test/essentials/navigation/application/panel_widget_providers_test.dart` | Added focused assertions that Unknown Sources preserves its first native cassette gap while Search's explicit flush handoff ignores an otherwise supplied leading cassette gap. | Protects both sides of the generic seam contract. |
| `09-CROSS-COLUMN-LAYOUT/07-column-specific-shared-track-boundaries.md` | Codified Native-Flow Ownership Restoration as the governing seam principle and documented the two generic spacing handoff modes. | Makes clear that ending shared Matrix participation restores the native layout system's complete responsibilities, not merely its rendering order. |
| `09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md` | Cross-referenced Native-Flow Ownership Restoration from the concrete cassette seam. | Directs future sidebar work to the ownership rule instead of inventing Tracks or local margins for native-flow rhythm. |
| `09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md` | Recorded that the app-control-to-filter gap is cassette-owned after Column 1 leaves the Matrix at Track A. | Keeps the concrete page description aligned with the canonical ownership rule. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this implementation and documentation pass. | Maintains the project documentation audit trail. |

---

# Column-Specific Shared Track Boundaries

Date: 2026-07-24

Scope: Promoted the Unknown Sources sidebar boundary into a general
PageTrackLayoutMatrix rule distinguishing the final page Track from each
column's explicitly declared final shared Track.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/07-column-specific-shared-track-boundaries.md` | Added the canonical rule, relationship test, non-inference constraint, native-flow seam, Unknown Sources and Search examples, and durable invariants. | Makes column-specific shared lifetimes discoverable as a general Matrix capability rather than an Unknown Sources implementation detail. |
| `09-CROSS-COLUMN-LAYOUT/README.md` | Added the new document to folder ownership and reading order. | Gives future developers an obvious route to the boundary contract. |
| `09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md` | Added per-column shared participation to the core contract and ownership model. | Prevents the final page Track from being mistaken for every column's rendering lifetime. |
| `09-CROSS-COLUMN-LAYOUT/01-column-band-wrappers.md` | Documented how a renderer consumes an explicit column boundary without inferring it from occupancy. | Connects the architectural rule to current cell rendering mechanics. |
| `09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md` | Reframed the sidebar seam as one application of the general column-specific boundary. | Preserves cassette ownership while avoiding a sidebar-only interpretation of the capability. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Recorded Search's explicit F boundary and clarified that it is not inferred from occupancy or cassette type. | Provides a second current page example demonstrating that boundaries are composition-specific. |
| `09-CROSS-COLUMN-LAYOUT/05-anatomy-of-track-cell-rendering.md` | Added the declared rendering lifetime to the mechanical rendering chain. | Explains why empty cells inside a boundary render while trailing cells after it do not. |
| `09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md` | Linked the page-specific implementation to the canonical general rule. | Keeps the example subordinate to the architecture it demonstrated. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md` | Extended the matrix architecture and invariants with explicit per-column shared lifetimes. | Preserves the architectural evolution in the original matrix work package. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation pass. | Maintains the project documentation audit trail. |

---

# Documentation Pass Log

## 2026-08-22 - MessageLens Historical Archives ready state

- Added Feature 26 response 50 documenting the enabled MessageLens arm through
  structural qualification, archive-instance identity, shared Messages-lineage
  admission, and exact read-only attachment recovery preflight.
- Updated the canonical historical-source identity guide with the two-arm
  product distinction and MessageLens archive-instance identity rule.
- Updated the Feature 26 index and broad MessageLens data-folder audit to
  replace obsolete disabled-arm and arbitrary donor-ingestion assumptions.
- Recorded that recovery mutation remains intentionally absent until an
  aggregate batch executor owns iteration, interruption, and terminal truth.

## 2026-08-21 - MessageLens attachment matching and safe recovery

- Added Feature 26 response 47 documenting the exact Apple Messages to
  MessageLens attachment identity chain, relationship proof, payload/path
  safety, typed classifications, aggregate preflight, mutation boundary,
  idempotency, and donor lifecycle recommendation.
- Corrected the broad MessageLens archive audit so its attachment section
  reflects the narrowed same-lineage payload-recovery contract rather than the
  superseded arbitrary donor-merge model.
- Recorded the dormant Attachments-owned matcher and read-only payload
  inspector. No MessageLens recovery segment, copy operation, or schema change
  was enabled.

Date: 2026-07-09

Scope: Autonomous maintenance pass confined to
`_AGENT_INSTRUCTIONS/agent-per-project/`.

## Summary

This pass updated the project documentation to reflect the current graph-era
and UI-walk state of MessageLens. It focused on correcting stale active
ownership claims, clarifying the current product/release phase, adding a
current-state orientation document, and improving discoverability of the large
RIO migration-history folder.

No application source code, tests, configs, generated files, database files, or
assets were modified as part of this documentation pass.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `README.md` | Updated `last_reviewed`; added current project phase quick fact; linked current-state, Essentials, Conversations, UI-walk, and release-exit docs; updated RIO description. | The top-level index still emphasized graph migration and did not orient future agents to the current product/UI-walk phase or the new Conversations feature boundary. |
| `01-PROJECT/05-CURRENT-STATE.md` | Created current-state snapshot. | Future agents need a concise answer to "what is current now?" without reading the entire graph migration history. |
| `01-PROJECT/02-architecture-overview.md` | Updated active feature list; added `features/conversations` ownership; clarified boundaries among Conversations, Messages, Search, and `essentials/conversation_graph`; linked current-state/release docs. | The architecture overview still listed `chats` as active and did not reflect the Conversation ownership repair. |
| `30-ESSENTIALS/README.md` | Updated current `ViewSpec` list to include `ViewSpec.conversations` and `ViewSpec.settings`; removed the stale active `ViewSpec.import` claim; clarified sidebar-independent system specs. | The active navigation model now routes Conversation specs through the Conversations feature; the old import spec wording was stale. |
| `40-FEATURES/README.md` | Updated `last_reviewed`; marked `chats/` as historical; added `conversations/`; corrected current code module inventory; removed stale active `reactions` module claim. | The code tree now has `features/conversations` and no active `features/chats` or `features/reactions` module. |
| `40-FEATURES/conversations/README.md` | Created canonical Conversations feature boundary document. | Conversation presentation was previously documented indirectly through UI-walk and migration notes; it now has a discoverable feature-owned home. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/README.md` | Added current-status guidance, navigation guide, and `85-RELEASE-EXIT-PLAN.md` to reading flow. | The folder accumulated many specialized numbered docs; a clearer index was lower-risk than physically moving historical documents. |
| `95-WALK-UI-TREE/README.md` | Added note that the UI walk is the active product-improvement phase and should not expand into unrelated hardening. | Aligns UI work with Document 85's release-first rule. |
| `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` | Updated from the earlier rigid four-band/AppPanelBandColumn framing to the current title/context/content-start band model and sidebar content-start seam. | The code now includes `TitleColumnBand` and `ContextColumnBand`; the old README text was stale and over-rigid. |
| `DOCUMENTATION_PASS_LOG.md` | Created this log. | Required by the documentation-pass request. |

## Structure Decisions

The `55-READERS-INTEGRATORS-ORCHESTRATORS/` folder was not physically
reorganized during this pass.

Reason:

- Many files are historical but still useful as audit evidence.
- Moving them would risk breaking existing links and obscuring their chronology.
- A current-status guide and reading categorization solves the immediate
  discoverability problem with less churn.

The `40-FEATURES/chats/` folder was not deleted or moved.

Reason:

- It remains useful historical context for older chat terminology.
- The active docs now explicitly state that current user-facing Conversation
  ownership belongs to `features/conversations`.

## Important Concepts Clarified

- The current project phase is product release and UI/UX walk, not continuing
  graph migration as an end in itself.
- The ordinary data spine is graph-first:
  `chat.db / AddressBook -> macos_import_ss.db -> working_ss.db -> graph read models -> Message Evidence Spine -> overlay intent`.
- Retired `macos_import.db` and `working.db` are cleanup/diagnostic inventory,
  not ordinary app authorities.
- `features/conversations` owns user-facing Conversation identity
  presentation.
- `features/messages` owns message evidence surfaces, not Conversation cards,
  glyphs, favourites, or excerpt panel structure.
- `essentials/conversation_graph` owns graph facts and projection/build
  behavior, not user-facing Conversation widgets.
- Search requests Conversation excerpts; Conversations renders the Conversation
  lens; Messages renders the message evidence rows.
- X-column layout currently uses a title band and context band, with content
  beginning after the context band.

## Needs Verification / Human Review

- The documentation says no active `lib/features/chats` or
  `lib/features/reactions` module was present in the July 2026 code inventory.
  Re-check if either module is deliberately reintroduced later.
- Some historical `42-SPEC-SYSTEM/REFERENCE/` documents still mention older
  `ViewSpec.chats` and `ViewSpec.import` examples. They were left unchanged
  because they live under `REFERENCE/`; future agents should not treat them as
  current implementation guidance.
- The exact release readiness status for onboarding, archival import, and final
  smoke testing remains governed by `55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md`
  and should be verified against the current app before release decisions.
- The X-column layout implementation is active UI-walk work. The docs now
  describe the current direction, but visual tuning remains a design/review
  matter rather than a completed universal layout standard.

---

# Documentation Information Architecture Pass

Date: 2026-07-09

Scope: Structural and navigational review confined to
`_AGENT_INSTRUCTIONS/agent-per-project/`.

## Summary

This pass treated the documentation as a navigation product. It improved
discoverability and current-vs-history signaling without moving large
historical folders or rewriting technical content.

No application source code, tests, configs, generated files, database files, or
assets were modified as part of this IA pass.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `00-START-HERE.md` | Created cold-start orientation page. | New readers needed one short entry point that distinguishes current mode, canonical owners, and historical reference areas. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md` | Created topic-based index. | The folder combines durable invariants with numbered graph-migration history; topic navigation is safer than physical reorganization. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Created staging/history index. | The folder contains active planning, migrated guidance, and historical proposals; readers need to verify currency before implementing. |
| `45-NEW-FEATURE-ADDITION/README.md` | Linked `INDEX.md`; clarified active/planning table wording; updated review date. | The README previously implied the folder was mainly active work; it now flags the mixed staging/history role. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/README.md` | Linked `TOPIC_INDEX.md` from Current Status. | Future readers should not infer document currency from file number alone. |
| `README.md` | Linked `00-START-HERE.md` from the opening section and frontmatter; added a Large Folder Navigation section for `45` and `55` indexes. | The top-level index now has a clearer first-read path and makes the large-folder navigation aids discoverable. |
| `DOCUMENTATION_INFORMATION_ARCHITECTURE_REPORT.md` | Created IA report. | Required deliverable documenting strengths, weaknesses, structural changes, unchanged folders, and recommendations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this IA-pass section. | Required change log for documentation maintenance. |

## Structure Decisions

The pass intentionally avoided moving large historical folder trees.

Reason:

- Existing links and chronological evidence are valuable.
- The main problem was navigation, not missing content.
- Index files reduce confusion without creating link churn.

## Needs Verification / Human Review

- Confirm whether `45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/`,
  `archive-canonical-attachments/`, and `ephemeral-sidebar-projection/` remain
  the intended active/planning feature folders.
- Consider a later archive taxonomy for `45-NEW-FEATURE-ADDITION/` only after
  the current release/UI-walk phase.

---

# Documentation Ownership Audit

Date: 2026-07-09

Scope: Analytical ownership audit confined to
`_AGENT_INSTRUCTIONS/agent-per-project/`.

## Summary

This pass examined how major architectural and product concepts are distributed
across the documentation. It identified canonical owners, secondary references,
duplicate explanations, historical/evolutionary documents, and ownership gaps.

No documentation content was consolidated, no files were moved, and no
application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `DOCUMENTATION_OWNERSHIP_AUDIT.md` | Created ownership audit report. | Required deliverable identifying canonical owners, secondary references, duplicate explanations, conflicts, and future documentation-improvement recommendations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this ownership-audit log entry. | Required by the documentation ownership audit request. |

## Major Concepts Audited

- Current project phase
- Architectural Constitution
- DDD feature ownership
- Essentials ownership
- Provider conventions and public seams
- Database ownership and physical DB access
- Overlay database and overlay independence
- Source-scoped import and graph projection
- Conversation Graph
- Conversations and the One Conversation principle
- Message Evidence Spine
- Messages and message evidence presentation
- Contacts and contact identity
- Search
- Discovery, Organize By, and Conversation Lenses
- ViewSpecs and panel architecture
- Sidebar architecture and cassette system
- X-column layout grammar
- Readers, Integrators, and Orchestrators
- Onboarding
- Archive/recovery and attachment reachability
- Retired databases and retained storage
- UI Walk process
- Feature planning/history
- Build/release/FDA continuity

## Needs Verification / Human Review

- Consider creating a current `40-FEATURES/contacts/README.md` if the Contacts
  UI/UX walk expands, because contact identity is well documented but the
  user-facing Contacts feature lacks a single current owner comparable to
  Conversations.
- Consider creating a focused current Search owner document under
  `30-ESSENTIALS/` or the UI-walk Search area once the Search/All Messages
  walkthrough settles.
- When active sidebar content-seam work stabilizes, promote the durable outcome
  from `45-NEW-FEATURE-ADDITION/03-INTRODUCE-SIDEBAR-CONTENT-SEAM/` into the
  canonical sidebar/layout documentation.

---

# Developer Guide Creation

Date: 2026-07-09

Scope: Created a cohesive first-read developer guide and made it discoverable
from the project documentation entry points.

## Summary

This pass synthesized the current canonical MessageLens documentation into a
senior-engineer orientation guide. It explains the product purpose, mental
model, architectural philosophy, feature ownership, data flow, UI philosophy,
common mistakes, and how to read the rest of the documentation.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `DEVELOPER_GUIDE.md` | Created new developer guide. | Required deliverable; gives future developers and fresh agents a coherent mental model before reading detailed reference documentation. |
| `00-START-HERE.md` | Added `DEVELOPER_GUIDE.md` as the first Fast Path item. | The guide is intended to be the recommended first document for new contributors. |
| `README.md` | Added entry-point wording and Large Folder Navigation link for `DEVELOPER_GUIDE.md`. | Makes the guide discoverable from the main per-project index. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Required change log for documentation work. |

## Needs Verification / Human Review

- The guide is intentionally narrative rather than exhaustive. If future work
  changes the current phase, Conversation ownership, Message Evidence Spine, or
  retired database policy, update the guide rather than letting it drift into
  historical guidance.

---

# Conversations Architectural Walkthrough

Date: 2026-07-09

Scope: Performed an architectural walkthrough of the Conversations feature as a
user-facing journey and ownership boundary.

## Summary

This pass reviewed the Conversations feature against the Developer Guide,
current-state documentation, Architectural Constitution, Conversation feature
boundary documentation, and UI Walk principles. It evaluated the user journey
from Conversations entry through Favourites/Browse, Conversation selection,
message evidence, in-conversation search, Search -> Conversation excerpt
navigation, and Favourite state.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `CONVERSATIONS_ARCHITECTURAL_WALKTHROUGH.md` | Created architectural walkthrough report. | Required deliverable; records strengths, opportunities, architectural drift risks, UX drift risks, scalability concerns, and release-oriented recommendations for Conversations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this walkthrough log entry. | Required by the walkthrough request. |

## Needs Verification / Human Review

- Decide during the UI Walk whether the Conversations metadata search field
  should be removed, renamed, or retained with clearer scope.
- Before expanding beyond Core Favourites, review whether favourite overlay
  provider ownership should remain in `essentials/conversation_graph` or move
  to a Conversations/overlay-intent boundary.
- Promote the durable X-column/sidebar content seam rules into canonical UI
  documentation once that active layout work stabilizes.

---

# Conversation Tags Feature Package

Date: 2026-07-09

Scope: Created an exploratory feature work package for Conversation Tags under
`45-NEW-FEATURE-ADDITION/`.

## Summary

This pass created the canonical exploratory work package for durable
Conversation Tags. It defines tags as user-created semantic labels attached to
canonical Conversation identity, stored as overlay/user intent, and designed to
support future retrieval and discovery without becoming folders.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Created package overview. | Provides entry point, principles, package contents, and exploratory status. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/PROPOSAL.md` | Created proposal. | Defines purpose, rationale, product philosophy, architectural direction, relationships to Favourites/Working Sets/Search/Discovery, non-goals, and open questions. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/DESIGN_NOTES.md` | Created design notes. | Records storage, overlay, identity, UX, scalability, sync/export, AI-assistance, and anti-pattern considerations. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/CHECKLIST.md` | Created phased checklist. | Records planning, product decisions, architecture plan, minimal slice, cross-lens integration, management/scale, and completion criteria. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/TESTS.md` | Created future validation plan. | Captures product, architectural, functional, UX, cross-feature, and data-integrity validation expectations for future implementation. |
| `45-NEW-FEATURE-ADDITION/README.md` | Added Conversation Tags to active/planning table. | Makes the new package discoverable as exploratory planning work. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added Conversation Tags to active/potentially active planning folders. | Prevents the package from becoming orphaned and clarifies that it is not implementation guidance yet. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this feature-package log entry. | Required by the feature package request. |

## Needs Verification / Human Review

- Decide whether Conversation Tags should move from exploratory package to
  active implementation.
- Decide whether first version includes tag color.
- Decide whether Core Favourites should remain separate from tag
  infrastructure or eventually share overlay primitives.

---

# Conversation Intent Architecture Package

Date: 2026-07-09

Scope: Created an exploratory architecture work package for Conversation Intent
under `45-NEW-FEATURE-ADDITION/` and lightly amended the Conversation Tags
package to reference the broader seam.

## Summary

This pass defined Conversation Intent as user-authored or user-confirmed
metadata attached to stable Conversation identity. The package positions
Favourites, Tags, Working Sets, Hidden state, Notes, saved investigations, and
future confirmed AI classifications as user intent attached to the one
canonical Conversation rather than separate containers or sidebar-owned list
types.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/README.md` | Created package overview. | Provides entry point, package contents, governing idea, and relationship to Conversation Tags. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/PROPOSAL.md` | Created architecture proposal. | Defines Conversation Intent, conceptual model, ownership, product philosophy, relationship to Tags, non-goals, open questions, and acceptance criteria. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/DESIGN_NOTES.md` | Created design notes. | Records ownership, retrieval implications, relationships to existing concepts, UX implications, overlay considerations, lifetimes, and anti-patterns. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/CHECKLIST.md` | Created architecture checklist. | Records concept approval, existing-intent audit, shared model, Tags-on-intent, retrieval, and completion criteria phases. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/TESTS.md` | Created validation plan. | Captures future product, architectural, regression, tags-on-intent, retrieval, AI suggestion, and data-integrity validation. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Added Conversation Intent relationship. | Clarifies that Tags are one durable form of broader Conversation Intent while the Tags package remains focused. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/PROPOSAL.md` | Added Conversation Intent relationship section. | Positions Tags as a feature built on the broader intent seam rather than a tag-only special case. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/DESIGN_NOTES.md` | Added Conversation Intent design note. | Clarifies the general seam without expanding tag-specific design scope. |
| `45-NEW-FEATURE-ADDITION/README.md` | Added Conversation Intent package to active/planning table. | Makes the architecture package discoverable. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added Conversation Intent package to active/potentially active planning folders. | Prevents the package from becoming orphaned and clarifies exploratory status. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this architecture-package log entry. | Required by the work package request. |

## Needs Verification / Human Review

- Confirm that "Conversation Intent" is the preferred durable term.
- Decide whether existing Core Favourites should eventually migrate onto shared
  intent primitives or remain separate until Tags prove the need.
- Decide whether Working Sets are durable intent, session intent, or both.

---

# Structured Conversation Retrieval Work Package

Date: 2026-07-11

Scope: Created an exploratory work package for Structured Conversation
Retrieval under `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/`.

## Summary

This pass defined Structured Conversation Retrieval as a product and
architectural model for retrieving Conversations through structured tokens over
Conversation identity, metadata, and Conversation Intent. It explicitly
distinguishes Conversation Retrieval from All Messages Search: retrieval answers
"Which Conversation am I trying to work with?", while message search answers
"Where was this said?"

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md` | Created package overview. | Provides entry point, package contents, core distinction, relationship to Conversation Intent, and exploratory status. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/PROPOSAL.md` | Created proposal. | Defines purpose, product philosophy, tokenized retrieval model, relationships to Intent/Lenses/Search, architectural direction, non-goals, and acceptance criteria. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/DESIGN_NOTES.md` | Created design notes. | Records token semantics, candidate sources, retrieval semantics, UX risks, ownership boundaries, and minimal first-slice direction. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/CHECKLIST.md` | Created phased checklist. | Records concept approval, token model, ownership planning, UI walk planning, future implementation slices, and completion criteria. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/TESTS.md` | Created future validation plan. | Captures product, interaction, retrieval, ownership, lens, regression, and non-goal validation expectations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this work-package log entry. | Required by the work package request. |

## Needs Verification / Human Review

- Decide final user-facing label for Structured Conversation Retrieval.
- Decide first-slice token types.
- Decide whether first-slice token combination is AND-only.
- Decide whether this should replace the current Conversation metadata search
  field during the UI walk.
- Return to the Conversation Intent open-question cycle and link
  `05-categories-of-conversation-intent.md` from the main Intent package after
  the current interruption is resolved.

## Follow-Up Edit

Date: 2026-07-11

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/PROPOSAL.md` | Added the sentence "Structured Conversation Retrieval is not a query language. It is a language for describing remembered context." | Captures the intended product philosophy more precisely. |
| `DOCUMENTATION_PASS_LOG.md` | Logged this follow-up edit. | Maintains documentation pass traceability. |

---

# Conversation Intent Consolidation Pass

Date: 2026-07-11

Scope: Consolidated the approved Conversation Intent open-question decisions
into the canonical package documents under
`45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/`.

## Summary

This pass updated the Conversation Intent package from exploratory proposal
language into an approved architectural reference. The evaluation documents in
`01-OPEN-QUESTION-EVALUATION/` remain untouched as the decision record. The
canonical package now reflects the settled decisions for Core Favourites,
intent lifetimes, Working Sets, Suppressed visibility state, categories of
Conversation Intent, and Conversation Notes. Saved Investigations are now
explicitly identified as a separate future workspace architecture outside this
package.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/README.md` | Updated status and package overview; added settled decisions and decision-record links. | Makes the package read as the canonical architecture while preserving evaluation documents as rationale. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/PROPOSAL.md` | Consolidated approved decisions on categories, lifetimes, Tags, Favourites, Suppressed state, Working Sets, Notes, and Saved Investigations. | Removes resolved questions from proposal framing and records the resulting architecture. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/DESIGN_NOTES.md` | Replaced speculative sections with approved behavior and terminology; narrowed remaining design questions. | Keeps design notes focused on current architecture and unresolved implementation-level choices. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/CHECKLIST.md` | Marked concept decisions as approved and retained implementation/audit items as future work. | Separates settled architecture from pending implementation planning. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/TESTS.md` | Updated validation language for Suppressed state, Conversation Notes, and note-presence retrieval. | Aligns future validation strategy with approved architecture. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this consolidation entry. | Required by the consolidation request. |

## Needs Verification / Human Review

- Confirm whether the remaining design questions in `DESIGN_NOTES.md` are the
  correct ones to leave open before implementation planning.
- Decide when to convert the approved architecture into a concrete
  implementation slice.

---

# Conversation Tags Consolidation Pass

Date: 2026-07-11

Scope: Consolidated the Conversation Tags work package under
`45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/` after Conversation Intent became
the canonical architecture for user-authored Conversation meaning.

## Summary

This pass refocused Conversation Tags as a tag-specific product and UX package.
The package now treats Tags as durable Meaning intent built on Conversation
Intent, references Structured Conversation Retrieval where tags may later be
consumed as remembered-context tokens, and avoids re-explaining the broader
intent architecture.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Updated status, links, package framing, and governing principles. | Makes the package a focused tag feature specification rather than a duplicate architecture package. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/PROPOSAL.md` | Reframed the core model as tag-specific; delegated storage/identity/overlay ownership to Conversation Intent; revised retrieval/search relationship; narrowed open questions. | Keeps architecture in Conversation Intent and leaves only tag-specific product questions open. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/DESIGN_NOTES.md` | Collapsed duplicated architecture into an inherited-architecture summary; focused notes on tag UX, presentation, editing, scaling, and tag-specific questions. | Preserves useful tag design guidance while avoiding redefinition of the approved Conversation Intent seam. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/CHECKLIST.md` | Updated statuses, phase names, product decisions, and cross-lens items. | Separates settled Conversation Intent architecture from remaining tag implementation decisions. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/TESTS.md` | Reframed validation as tag-specific and linked to Conversation Intent validation for general architecture. | Prevents duplicate validation ownership and adds tag-specific UX/retrieval checks. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this consolidation entry. | Required by the redirection request. |

## Needs Verification / Human Review

- Confirm whether the remaining tag-specific open questions are the right set
  before implementation planning.
- Decide whether the first implementation slice should include retrieval by tag
  or only tag creation/assignment/display.

---

# Conversation Tags Open Question Evaluation: Tag Creation Workflow

Date: 2026-07-11

Scope: Added a tag-specific product decision record under
`45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/`.

## Summary

This pass evaluated the correct workflow for creating, editing, and managing
Conversation Tags. The recommendation is Conversation-first tagging: users
should create and apply tags while looking at a Conversation, with a secondary
Tag Manager reserved for cleanup, rename, deletion, and scale.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/07-tag-creation-and-management-workflow.md` | Created evaluation document. | Records the recommendation for Conversation-first tag creation, secondary tag management, duplicate prevention, card presentation, retrieval relationship, UX risks, and first-slice direction. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this evaluation entry. | Required by the open-question evaluation request. |

## Needs Verification / Human Review

- Confirm whether the first implementation slice should include only
  create/apply/remove/display, or also a minimal secondary rename/delete
  management surface.

## Follow-Up Refinement

Date: 2026-07-11

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/07-tag-creation-and-management-workflow.md` | Added the governing product principle that Tags should be discovered through use, refined the secondary management role, and documented authoring/retrieval symmetry. | Strengthens the product rationale without reopening the Conversation-first recommendation. |
| `DOCUMENTATION_PASS_LOG.md` | Logged this follow-up refinement. | Maintains documentation pass traceability. |

---

# Conversation Tags Implementation Readiness Audit

Date: 2026-07-11

Scope: Repository-aware implementation readiness audit for Conversation Tags,
confined to `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/`.

## Summary

This pass inspected current Core Favourites persistence, overlay database
conventions, canonical Conversation identity, Conversation read models,
Conversation card surfaces, action/provider boundaries, and test infrastructure.
It concluded that Tags are ready for a narrow first implementation slice, but
should not begin with a broad generic Conversation Intent framework.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/IMPLEMENTATION_READINESS_AUDIT.md` | Created repository-aware readiness audit and first-slice plan. | Maps the settled tag product direction onto the current codebase before implementation begins. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Linked the readiness audit from package contents. | Makes the implementation planning document discoverable. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation pass traceability. |

## Needs Verification / Human Review

- Confirm the recommended first implementation surface: Conversations sidebar
  card first, then Contact By Conversation and right Conversation excerpt panel.
- Confirm that first-slice tag storage should use first-class overlay tables
  rather than an overlay settings JSON blob.

---

# Conversation Tags First Slice Implementation Plan

Date: 2026-07-12

Scope: Added the concrete first vertical-slice implementation plan for
Conversation Tags under
`45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/`.

## Summary

This pass translated the approved Conversation Intent architecture, Conversation
Tags package, and implementation readiness audit into a narrow implementation
plan. The slice proves one complete workflow: create a Tag in Conversation
context, attach it to the canonical Conversation, persist it in overlay storage,
merge it into Conversation read models, display it in canonical Conversation
presentation, and preserve it across restart.

No application source code, tests, configs, generated files, database files, or
assets were modified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/FIRST_SLICE_IMPLEMENTATION_PLAN.md` | Created first-slice implementation plan. | Defines affected features, overlay additions, providers/actions, read-model changes, UI changes, test strategy, migration considerations, implementation order, and explicit non-goals. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Linked the first-slice plan from package contents. | Makes the implementation plan discoverable before coding begins. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation pass traceability. |

## Needs Verification / Human Review

- Approve or revise the plan assumptions before implementation:
  Conversations sidebar as first surface, first-class overlay tables, separate
  tag definitions/assignments, and no global Tag Manager in the first slice.

---

# Conversation Tags First Vertical Slice Implementation Documentation

Date: 2026-07-12

Scope: Updated the Conversation Tags work package to reflect the implemented
first vertical slice.

## Summary

The first Conversation Tags slice now supports creating/applying/removing tags
from a Conversation in the Conversations sidebar, persisting tags in overlay
storage, merging tag state into Conversation signature display models, and
displaying tag labels on the canonical Conversation card for the first surface.

Application code, tests, generated files, and overlay schema were changed as
part of the implementation. This log entry records only the documentation
updates made after implementation.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Marked first slice implemented and summarized implemented/deferred scope. | Keeps the package entry point current without claiming full tag feature completion. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/CHECKLIST.md` | Checked off completed planning, first-slice, overlay, identity, and display items. | Distinguishes implemented first-slice behavior from future tag management/retrieval work. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/TESTS.md` | Added implemented first-slice test coverage summary. | Records what is currently proven by tests versus future validation needs. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/FIRST_SLICE_IMPLEMENTATION_PLAN.md` | Marked plan implemented and added outcome/deferred sections. | Preserves the plan as historical implementation context. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this implementation documentation entry. | Maintains traceability for documentation changes. |

## Needs Verification / Human Review

- Manual app verification: create a tag on a Conversation in the Conversations
  sidebar, restart the app, and confirm the tag remains visible on that card.
- Architecture test still reports one unrelated pre-existing layout debug color
  literal in `lib/config/theme/widgets/layout/vertical_column_bands.dart`.

---

# Conversation Tags Post-Implementation Architectural Review

Date: 2026-07-12

Scope: Reviewed the implemented first Conversation Tags vertical slice against
the approved Conversation Intent architecture, Conversation Tags package,
Structured Conversation Retrieval package, readiness audit, and first-slice
implementation plan.

## Summary

The review concluded that the first Conversation Tags vertical slice validates
the approved architecture. Tags are persisted as overlay-owned Conversation
Intent, graph projection remains untouched, Conversation-owned read/action
providers merge tags at read time, and the canonical Conversation Card remains
pure presentation. No code changes were recommended before the next slice.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/POST_IMPLEMENTATION_ARCHITECTURAL_REVIEW.md` | Created post-implementation architectural review. | Records architectural validation, implementation observations, deviations, debt, lessons, and next-slice recommendations. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Manually verify the first slice in the running app: create a tag, apply it to
  a Conversation, remove it, restart, and confirm persistence.
- Choose the second implementation slice explicitly before expanding tag
  display, retrieval, or management behavior.

---

# Structured Conversation Retrieval Tag Token Slice

Date: 2026-07-12

Scope: Implemented and documented the first Structured Conversation Retrieval
vertical slice: Tag tokens in the Conversations sidebar Browse list.

## Summary

The Conversations Browse retrieval field now consumes existing Conversation
Tags. Typing a partial Tag name suggests known Tags, accepting a suggestion
creates a visible token, and selected Tag tokens filter Conversation signatures
with simple AND semantics. The slice does not search message bodies and does not
own Tag definitions or assignments.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md` | Marked the Tag-token vertical slice implemented and recorded implemented/deferred scope. | Keeps the package entry point current. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/PROPOSAL.md` | Added implemented first-slice section. | Records that Tag-token retrieval now proves the model without implementing other token types. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/DESIGN_NOTES.md` | Updated minimal first-slice direction and open questions. | Distinguishes implemented Tag-token behavior from future retrieval work. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/CHECKLIST.md` | Checked off approved/implemented first-slice items. | Tracks implementation progress while preserving future phases. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/TESTS.md` | Added implemented test coverage summary. | Records focused validation for known Tag suggestions and AND filtering. |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Noted that Structured Conversation Retrieval consumes existing Tags as tokens. | Clarifies ownership: Tags remain Conversation Intent; retrieval consumes them. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Verification

- `flutter test test/features/conversations/application/conversation_retrieval/conversation_retrieval_tag_token_test.dart test/features/conversations/application/conversation_signatures/conversation_signature_display_provider_test.dart --reporter expanded`
- `flutter analyze`

## Needs Verification / Human Review

- Manual app verification: create two Tags, tag several Conversations, type a
  partial Tag, accept the suggestion, add a second Tag token, remove a token,
  and confirm the Conversation list updates immediately.

---

# Tag Visibility Policy Work Package

Date: 2026-07-12

Scope: Created a new feature-planning package for Tag Visibility Policy using
`04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/08-tag-visibility-policy.md`
as the seed.

## Summary

The new package records the approved direction that Conversation visibility is
best modeled as policy attached to Tag definitions rather than as a separate
Conversation-level suppression mechanism. It preserves the key behavior:
ordinary Browse can exclude low-value classes of Conversations, while explicit
Structured Conversation Retrieval by Tag still returns those Conversations.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/README.md` | Created package overview. | Establishes the package, governing principles, and relationship to Tags, Conversation Intent, and retrieval. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/PROPOSAL.md` | Created feature proposal. | Defines product rationale, core model, ownership, first-slice direction, and non-goals. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/DESIGN_NOTES.md` | Created design notes. | Captures UX language, browse-vs-retrieval semantics, conflict cases, and first-slice UI considerations. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/CHECKLIST.md` | Created phased checklist. | Provides a future implementation and validation sequence without starting code work. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/TESTS.md` | Created validation strategy. | Records persistence, read-model, UI, architecture, and manual verification expectations. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added `06-STRUCTURED-CONVERSATION-RETRIEVAL/` and `07-TAG-VISIBILITY-POLICY/` to active planning folders. | Keeps the feature-planning index discoverable and current. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Confirm first implementation slice before code changes.
- Decide final user-facing language for the visibility action: for example,
  "Suppress from Browse", "Hide Conversations with this Tag", or "Show only
  when requested".

---

# Tag Visibility Policy First Slice

Date: 2026-07-12

Scope: Implemented and documented the first Tag Visibility Policy vertical
slice.

## Summary

Conversation Tag definitions now carry an overlay-owned visibility policy.
Tags default to ordinary visibility, can be marked as suppressing ordinary
Browse from the existing Conversation Tag editor, and are merged into
Conversation read models at read time. Default Conversations Browse excludes
Conversations carrying suppressing Tags, while explicit Structured Conversation
Retrieval by that Tag still returns them.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/README.md` | Marked the first slice implemented and summarized actual behavior. | Keeps the package entry point current. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/PROPOSAL.md` | Recorded the implemented first-slice shape. | Distinguishes approved architecture from deferred feature expansion. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/DESIGN_NOTES.md` | Added implemented first-slice answers. | Captures the current UI and behavior without closing future wording questions. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/CHECKLIST.md` | Checked off completed first-slice items. | Tracks implementation progress. |
| `45-NEW-FEATURE-ADDITION/07-TAG-VISIBILITY-POLICY/TESTS.md` | Added implemented focused verification coverage. | Records how the slice is validated. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Verification

- `flutter test test/essentials/db/infrastructure/data_sources/local/overlay/overlay_database_test.dart test/features/conversations/infrastructure/repositories/overlay_conversation_tag_repository_test.dart test/features/conversations/application/conversation_tags/conversation_tag_actions_provider_test.dart test/features/conversations/application/conversation_signatures/conversation_signature_display_provider_test.dart test/features/conversations/application/conversation_retrieval/conversation_retrieval_tag_token_test.dart test/features/conversations/presentation/widgets/conversation_signature_card_test.dart --reporter compact`
- `flutter analyze`

## Needs Verification / Human Review

- Manual app verification: mark a low-value Tag as suppressed from Browse,
  confirm default Browse excludes matching Conversations, then retrieve that
  Tag explicitly and confirm the Conversations return.

---

# Contact-Backed Conversation Tags Linkage

Date: 2026-07-13

Scope: Linked the deferred Contact Tags evaluation from higher-order planning
documents without changing implementation scope.

## Summary

The Contact Tags evaluation identifies a likely future need for
Contact-backed Conversation Tags: identity-backed retrieval coordinates that
refer to canonical Contact identity instead of copied display text. This pass
made that evaluation discoverable from the Conversation Tags, Conversation
Intent, Structured Conversation Retrieval, and feature-planning index entry
points while preserving it as deferred work.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/README.md` | Added the Contact Tags evaluation to links, package contents, deferred scope, and a short deferred section. | Makes the concept discoverable from the Tag package without implying implementation approval. |
| `45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/README.md` | Linked the Contact Tags evaluation as related deferred Conversation Intent work. | Records that Contact-backed tags relate to intent/retrieval but are not part of the current slice. |
| `45-NEW-FEATURE-ADDITION/06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md` | Added a deferred Contact retrieval coordinate section. | Ensures future Contact-token work finds the Contact Tags reasoning. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Updated the Conversation Tags row to mention deferred Contact-backed Conversation Tags. | Improves top-level retrieval. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- None. This was linkage only; implementation remains deferred.

---

# Conversation Card Chat Hook Evaluation

Date: 2026-07-13

Scope: Created a UI/UX evaluation for optionally showing formatted chat hooks
on one-to-one Conversation Cards.

## Summary

The evaluation records a future refinement for Conversation Cards: one-to-one
cards may need a quiet secondary `via ...` line to distinguish multiple
canonical Conversations that resolve to the same Contact display name. The
document keeps this independent from Contact-backed Conversation Tags:
Contact-backed Tags are retrieval coordinates, while formatted chat hooks are
visual disambiguation metadata.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/conversation-card-chat-hook.md` | Created UI/UX evaluation. | Captures rationale, proposed behavior, one-to-one-only scope, relationship to Contact Tags, risks, and recommendation without implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- None. This is an evaluation document only; implementation remains deferred.

---

# Conversation Card Chat Hook Presentation Evaluation

Date: 2026-07-13

Scope: Added a follow-up UI/UX evaluation for the visual presentation of the
one-to-one Conversation Card chat hook after real-data use.

## Summary

The evaluation records that the chat hook is not ordinary metadata; it is an
identity qualifier explaining why multiple one-to-one Conversations can share
the same Contact display name. The recommendation is to evaluate a future
refinement where hooks are shown conditionally for duplicate display identities,
drop the `via` prefix, and render as a smaller near-title line within the
Conversation identity block.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/conversation-card-chat-hook-presentation.md` | Created UI/UX evaluation. | Captures visual hierarchy, typography, conditional display, relationship to glyphs and Contact Tags, risks, and a future implementation-slice recommendation. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- None. This is an evaluation document only; no implementation was performed.

---

# Cross-Column Layout Canonical Documentation

Date: 2026-07-14

Scope: Created a top-level canonical documentation folder for page-level
cross-column vertical alignment and linked it from the relevant documentation
indexes.

## Summary

The vertical alignment work for MessageLens had become hard to find because its
mechanics were spread across active UI-walk notes, Conversation ownership
documents, and the sidebar content-seam work package. This pass created
`09-CROSS-COLUMN-LAYOUT/` as the durable documentation home for the mechanical
contract: title/context column bands, content-start alignment, wrapper behavior,
and the sidebar cassette content-start seam.

The UI-walk and feature-package documents remain valuable design history. The
new folder is now the place to look when a future developer or agent needs to
understand how left, center, and right panels line up across the window.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/README.md` | Created canonical folder overview. | Establishes this folder as the source of truth for cross-column layout mechanics. |
| `09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md` | Created durable alignment contract. | Defines the title band, context band, content-start invariant, ownership rules, and current band heights. |
| `09-CROSS-COLUMN-LAYOUT/01-column-band-wrappers.md` | Created wrapper mechanics reference. | Documents `TitleColumnBand`, `ContextColumnBand`, child placement, debug margins, and the relationship to older `app_panel_bands.dart` support primitives. |
| `09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md` | Created sidebar seam reference. | Documents how the cassette system participates through `SidebarCassetteLayoutAnchor.preferredContentStart` without surrendering sidebar ownership. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Created current applied Search-page note. | Captures the present left/center/right mapping and known tuning issue around search-control placement. |
| `09-CROSS-COLUMN-LAYOUT/04-design-history-and-cross-references.md` | Created history/cross-reference guide. | Links the canonical contract back to UI-walk history, sidebar seam design notes, and Conversation ownership repair documents. |
| `README.md` | Added `09-CROSS-COLUMN-LAYOUT/` to the canonical map and clarified that `95-WALK-UI-TREE/` now contains historical layout review notes. | Makes the new canonical layout home discoverable from the project index. |
| `00-START-HERE.md` | Added cross-column vertical alignment to canonical owners. | Gives cold-start readers an obvious destination for layout alignment questions. |
| `07-CENTER-PANEL-LAYOUTS/README.md` | Added cross-column alignment to out-of-scope concerns. | Clarifies that center-panel layout does not own page-wide alignment. |
| `08-SIDEBAR-LAYOUTS/README.md` | Added cross-column alignment/content-start seams to out-of-scope concerns. | Clarifies that sidebar layout does not own peer-panel alignment. |
| `95-WALK-UI-TREE/README.md` | Pointed cross-column mechanics to `09-CROSS-COLUMN-LAYOUT/`. | Separates active UI review/history from durable layout mechanics. |
| `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` | Added a notice that canonical mechanics now live in `09-CROSS-COLUMN-LAYOUT/`. | Preserves the old folder as design history while preventing future agents from treating it as the only source of truth. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this log entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Review whether the current band heights documented here (`TitleColumnBand` 72,
  `ContextColumnBand` 166) should be treated as stable tokens or still as
  Search-page-specific provisional values.
- Review the known Search-page tuning issue: the search controls may still sit
  too close to the content below. The new docs record where that should be
  solved, not the final visual tuning.

---

# Cross-Column Layout Terminology Rename

Date: 2026-07-14

Scope: Renamed the cross-column alignment vocabulary from earlier geometric
band names to title/context bands in code and documentation.

## Summary

The previous labels described geometry but not the role of each aligned region.
This pass renamed the public wrapper classes and related implementation
terminology to `TitleColumnBand` and `ContextColumnBand` so future agents can
reason about the bands by purpose: the title band owns panel identity, and the
context band owns pre-content scope, controls, or object context.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Renamed the public wrapper classes to `TitleColumnBand` and `ContextColumnBand`. | Aligns code entities with the durable cross-column layout vocabulary. |
| `lib/config/theme/widgets/layout/app_panel_bands.dart` | Renamed transitional frame constants/parameters to title/context wording. | Prevents older support primitives from preserving stale terminology. |
| `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart` | Updated wrapper usage and renamed the internal evidence context-band helper. | Keeps message evidence header implementation aligned with the shared layout contract. |
| `lib/features/conversations/presentation/view/conversation_excerpt_panel_view.dart` | Updated wrapper usage and renamed title/context frame parameters and helper. | Keeps the conversation excerpt panel aligned with the shared layout contract. |
| `lib/essentials/navigation/application/panel_widget_providers.dart` | Updated wrapper usage and renamed sidebar seam internals to context-zone wording. | Keeps the cassette content-start seam vocabulary consistent with the shared contract. |
| `09-CROSS-COLUMN-LAYOUT/` | Updated canonical layout documentation to title/context terminology. | Makes this folder the clear source for current naming and mechanics. |
| `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` | Updated historical UI-walk bridge terminology. | Preserves historical context while pointing to current names. |
| `README.md` | Updated canonical-map wording. | Keeps the project index aligned with current layout language. |
| `DOCUMENTATION_PASS_LOG.md` | Updated the immediately preceding cross-column entry and appended this rename entry. | Maintains traceability for the terminology change. |

## Needs Verification / Human Review

- None beyond normal UI review of the existing cross-column layout tuning. This pass is a terminology and symbol rename, not a layout behavior change.

---

# Cross-Column Layout Tracks Work Package

Date: 2026-07-14

Scope: Created a new exploratory feature work package for a potential successor
to the current fixed title/context band cross-column layout model.

## Summary

The current cross-column layout contract in `09-CROSS-COLUMN-LAYOUT/` remains
the canonical implemented model. This pass created
`45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/` to explore a more
general track-based model before any implementation work begins.

The package records the proposed direction: columns declare preferred heights
for shared horizontal layout tracks, the page resolves each track by maximum
required height, and each participating column renders inside the resolved
track plan. The first future implementation slice is explicitly limited to the
Search page, with only the sidebar top menu participating in Track A.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Created package overview. | Establishes status, scope, relationship to the current canonical layout docs, and first-slice limits. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Created proposal. | Defines layout tracks, height resolution, ownership, non-goals, and Search-page-first success criteria. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Created design notes. | Captures product rationale, architectural rationale, variable-content handling, sidebar participation, migration strategy, risks, and open questions. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Created phased checklist. | Records decision gates and a conservative implementation path without approving implementation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Created validation strategy. | Defines future unit, widget, regression, and manual tests for a track-based implementation. |
| `45-NEW-FEATURE-ADDITION/README.md` | Added active/planning rows for `06`, `07`, and `08`, and updated review date. | Keeps the workflow README aligned with the current numbered planning folders. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added `08-CROSS-COLUMN-LAYOUT-TRACKS/` to the active/planning table and updated review date. | Makes the new package discoverable while clarifying that `09-CROSS-COLUMN-LAYOUT/` remains the implemented reference. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Review whether the track concept should use semantic names such as
  `identity/context/content` or ordinal names such as `Track A/Track B`.
- Review whether preferred heights should be declared by models, widgets, or
  layout adapters before implementation begins.
- Confirm that the first implementation slice should remain Search-page-only
  and should not solve autonomous sidebar cassette placement.

---

# Cross-Column Layout Tracks Flutter Investigation

Date: 2026-07-14

Scope: Added a Flutter implementation investigation to the Cross-Column Layout
Tracks work package.

## Summary

This pass evaluated which Flutter layout mechanisms best fit the approved
layout-track architecture. The recommendation is to start with ordinary widget
composition plus explicit, model-published layout requirements. The page should
resolve a shared track plan and pass resolved heights into compatibility
wrappers, rather than using post-frame measurement, `CustomMultiChildLayout`, or
custom render objects in the first slice.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/FLUTTER_IMPLEMENTATION_INVESTIGATION.md` | Created Flutter implementation investigation. | Evaluates ordinary composition, `LayoutBuilder`, inherited plans, provider-driven models, `CustomMultiChildLayout`, `MultiChildRenderObjectWidget`, and custom `RenderBox`; recommends model-published requirements for the first Search-page slice. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added the investigation to package contents. | Makes the new implementation guidance discoverable. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Confirm whether first-slice requirements should be computed locally in the
  Search page or exposed through a narrowly scoped page-level provider.
- Confirm whether track IDs should remain ordinal (`Track A`, `Track B`) during
  the prototype or become semantic names before implementation.

---

# Cross-Column Layout Tracks Terminology Refinement

Date: 2026-07-14

Scope: Refined terminology in the Cross-Column Layout Tracks work package so
the package describes declarative track requirements rather than preferred
widget heights.

## Summary

This pass updated the package language from the older height-centered framing to
the settled track-centered model. The recommended terms are now `TrackId`,
`TrackRequirement`, and `ResolvedTrackPlan`. The documentation now emphasizes
that the page does not ask widgets how tall they are after layout. Instead,
participating columns or layout adapters declare what each Track requires, the
page resolves a shared TrackPlan, and columns render within that resolved plan.

Height remains the first requirement supported by the proposed architecture, but
the wording now leaves room for future requirements such as minimum height,
compact variants, alignment preferences, and overflow policy.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Reframed the package overview around declared track requirements and a shared `ResolvedTrackPlan`. | Clarifies that tracks, not preferred heights, are the architectural abstraction. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Replaced height-centered language with `TrackRequirement` / `ResolvedTrackPlan` terminology and added explicit declarative architecture wording. | Records the governing model: columns declare requirements; the page resolves and distributes the plan. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Updated ownership and variable-content language to center on `TrackRequirement` values. | Keeps design notes aligned with the broader requirement model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Updated future implementation checklist entries to use `TrackRequirement` and `ResolvedTrackPlan`. | Ensures a future implementation starts with the current naming. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/FLUTTER_IMPLEMENTATION_INVESTIGATION.md` | Replaced `LayoutTrackRequirement`, `ResolvedLayoutTrackPlan`, and preferred-height wording with `TrackRequirement`, `ResolvedTrackPlan`, and declarative requirement language. | Keeps Flutter implementation guidance consistent with the approved terminology. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Updated validation wording from preferred heights to declared height requirements. | Aligns future tests with the track requirement model. |
| `DOCUMENTATION_PASS_LOG.md` | Appended this entry. | Maintains documentation traceability. |

## Needs Verification / Human Review

- Confirm final code symbol names during implementation. The package now
  recommends `TrackId`, `TrackRequirement`, and `ResolvedTrackPlan`, but no code
  has been changed in this documentation-only pass.

---

# Cross-Column Layout Tracks Track A Implementation

Date: 2026-07-14

Scope: Implemented the first vertical slice of the Cross-Column Layout Tracks
architecture for Search-page Track A only.

## Summary

This pass proves the declarative track model without expanding into Track B,
sidebar cassette placement, or broad page migration. The Search page now scopes
a resolved Track A plan when `Search all messages` is active. The existing
`TitleColumnBand` compatibility wrapper consumes that resolved height, so the
sidebar top menu, center title, and right Conversation title share the same
page-owned identity-track allocation.

The existing wrapper system remains in place. `ContextColumnBand`, sidebar
cassette flow, Contacts, Conversations, and other pages were not migrated.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Added `TrackId`, `TrackRequirement`, `ResolvedTrackPlan`, `ResolvedTrackPlanScope`, and the Search-page Track A plan. | Provides the minimal feature-neutral track model for the first slice. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Let `TitleColumnBand` consume a resolved Track A height while preserving existing fallback behavior. | Keeps the existing wrapper system while moving Track A height ownership to the page plan. |
| `lib/essentials/navigation/presentation/view/workspace_layout.dart` | Scoped the left/center workspace with the Search-page Track A plan only when Search all messages is active. | Limits the first slice to the Search page and avoids affecting other sidebar modes. |
| `lib/essentials/navigation/presentation/view/macos_app_shell.dart` | Scoped the right panel with the same Search-page Track A plan when Search all messages is active. | Lets the Conversation right panel participate in Track A without moving ownership into Search widgets. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Added focused tests for track resolution and `TitleColumnBand` resolved/default height behavior. | Verifies the Track A proof slice independently of the full Search page tree. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Marked Track A as first-slice implemented and recorded deferred work. | Keeps the work package current. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Added implementation status. | Separates proven Track A behavior from future architecture. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Updated migration strategy with completed Track A steps. | Records actual implementation progress without treating Track B as done. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Checked off Track A-only implementation items and left Track B/sidebar work deferred. | Maintains planning accuracy. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added implemented Track A test coverage. | Makes the validation path discoverable. |

## Verification

- `flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact`
- `flutter analyze`

## Deferred

- Track B negotiation.
- Sidebar cassette participation beyond the top menu.
- Contacts / Conversations page migration.
- Wrapper retirement.
- Search-page visual retuning beyond Track A ownership.

---

# Cross-Column Layout Tracks Track B Implementation

Date: 2026-07-14

Scope: Implemented the second vertical slice of the Cross-Column Layout Tracks
architecture for Search-page Track B only.

## Summary

This pass proves that additional tracks can be added incrementally. Track B is
the supporting identity track for the Search page. Only the center message
evidence metadata subheader renders visible content in Track B. The sidebar and
right panel declare empty Track B participation and receive the same resolved
allocation.

Track B was refined to be tight to the metadata line rather than functioning as
a general spacing band. Search-scope explanatory text remains below Track B
with the search controls instead of being clipped inside the metadata track.

Search controls, sidebar orientation text, Conversation Cards, excerpt
descriptions, and cassette placement were deliberately left outside Track B.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Added `TrackId.trackB` and changed the Search page plan to include Track A and a tight Track B requirement. | Proves multi-track resolution and empty peer participation without using Track B as hidden spacing. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Let `ContextColumnBand` consume a resolved Track B height while preserving fallback behavior. | Keeps the compatibility wrapper while moving Track B height ownership to the page plan. |
| `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart` | Split the fixed-frame Search-page header so metadata occupies Track B, while search-scope text and search/actions remain below it when a track plan is present. | Ensures Track B contains only supporting identity metadata and can remain tight. |
| `lib/features/conversations/presentation/view/conversation_excerpt_panel_view.dart` | Added an empty Track B allocation before the existing Conversation Card/excerpt block when a track plan is present. | Keeps right-panel Track B empty without moving Conversation Card content into Track B. |
| `lib/essentials/navigation/application/panel_widget_providers.dart` | Changed the Search sidebar seam to render an empty Track B allocation, then continue the existing cassette chain below it. | Keeps sidebar Track B empty and avoids automatic cassette placement. |
| `lib/essentials/navigation/presentation/view/workspace_layout.dart` | Updated the Search page to use the Track A/Track B plan. | Applies the second slice without changing non-Search surfaces. |
| `lib/essentials/navigation/presentation/view/macos_app_shell.dart` | Updated the right panel to use the Track A/Track B plan. | Applies empty right-panel Track B participation for Search. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Added Track B resolution and `ContextColumnBand` resolved/default behavior coverage. | Verifies the Track B proof slice independently of the full Search page tree. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Marked Track B as implemented and documented empty participation. | Keeps the work package current. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated implementation status and Track B examples. | Clarifies that Track B is metadata-only in this slice. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Updated sidebar participation and migration notes. | Records the implemented empty-track behavior. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Checked off Track B-only implementation items and left later tracks deferred. | Maintains planning accuracy. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added Track B validation notes. | Makes the new test expectations discoverable. |

## Verification

- `flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact`
- `flutter analyze`

## Deferred

- Track C or later tracks.
- Search controls migration.
- Conversation Card / excerpt description migration.
- Sidebar cassette participation beyond empty Track B.
- Contacts / Conversations page migration.
- Wrapper retirement.

---

# Cross-Column Layout Tracks Content-Tight Occupied Tracks

Date: 2026-07-14

Scope: Tightened the Search-page Track A/Track B implementation and updated the
Cross-Column Layout Tracks package.

## Summary

Colored track diagnostics showed that occupied tracks were still preserving
hidden slack from old compatibility-wrapper padding and broad fixed requirement
values. This pass records and implements the stricter invariant: occupied
tracks are exactly as tall as their tallest natural occupant; intentional
spacing belongs in explicit empty tracks.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Replaced broad Search-page Track A/Track B requirements with named natural occupant contracts for the sidebar top menu trigger, panel title line, and metadata line. | Prevents old spacing constants from functioning as hidden track height. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Removed top/bottom compatibility-wrapper padding whenever a resolved track is present. | Ensures resolved occupied tracks contain content only, not discretionary vertical spacing. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Updated resolved Track A/Track B expectations to use the named natural occupant contracts. | Keeps the track proof tests aligned with the content-tight invariant. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added the content-tight occupied-track rule and explicit empty-track spacing principle. | Makes the current layout rule discoverable. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Clarified that occupied track height resolves from natural occupant requirements and excludes breathing room. | Prevents future track slices from reintroducing hidden spacing. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Added wrapper guidance for resolved tracks. | Documents the compatibility-wrapper constraint. |

---

# Cross-Column Layout Tracks Flush Track A Start

Date: 2026-07-14

Scope: Removed the Search-page page-top inset from the resolved track plan.

## Summary

Visual review confirmed Track A and Track B were content-tight, but Track A was
still separated from the top of the page content surface by a page-top inset.
This pass sets the Search-page inset to zero so Track A starts flush. Any future
separation above Track A should be represented by an explicit shim track rather
than an implicit inset.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Set the Search-page `pageTopInset` requirement to `0`. | Removes hidden space above Track A. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Updated the Search-page Track A test to assert no hidden top inset. | Protects the flush-start contract. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Documented that Search Track A starts flush with the content surface. | Keeps implementation notes current. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Replaced page-top inset language with explicit flush-start language. | Prevents future confusion between track height and page spacing. |

---

# Cross-Column Layout Tracks Track A Geometry Correction

Date: 2026-07-14

Scope: Refined the Search-page Track A implementation so the page-top inset is
separate from the resolved Track A height.

## Summary

The second-slice visual check showed that Track B was correctly narrow, but the
metadata still started too low because Track A was preserving the old 72-pixel
title-wrapper allocation. This pass separates page top inset from Track A
height. Track A is now resolved from actual occupant requirements, while the
page-top inset is represented as its own page-owned value in the resolved track
plan.

This avoids hiding vertical spacing inside Track A and keeps the sequence:

```text
page top inset
Track A: selector / title / title
Track B: empty / metadata / empty
```

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Added `pageTopInset` to `ResolvedTrackPlan` and reduced Search-page Track A requirements to occupant-sized values. | Separates page inset from Track A allocation. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | When a resolved Track A plan is present, renders the page-top inset outside the Track A band and removes embedded top padding from the band itself. | Prevents legacy wrapper padding from becoming hidden track height. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Added coverage proving page-top inset is added outside resolved Track A height. | Protects the corrected geometry. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Documented page-top inset as separate from Track A. | Keeps the work package aligned with the implementation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Added architectural note that page insets are not track requirements. | Prevents future confusion between insets and tracks. |

## Verification

- `flutter test test/config/theme/widgets/layout/cross_column_track_plan_test.dart --reporter compact`
- `flutter analyze`

---

# TrackOccupant Architecture Analysis

Date: 2026-07-15

Scope: Added an exploratory architecture analysis for a future TrackOccupant
seam in the Cross-Column Layout Tracks package.

## Summary

The first layout-track slices proved Track A and Track B negotiation, but the
current implementation still uses page-level numeric requirements for title,
metadata, and top-menu occupants. This documentation pass analyzes a
`TrackOccupant` model that would let presentation contracts declare track
requirements without querying rendered widgets or using post-frame measurement.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Added a full architecture analysis covering definition, API shape, requirement context, text/control/glyph/card handling, alternatives, risks, testing, and first implementation candidate. | Gives the proposed TrackOccupant seam a single discoverable planning document before any implementation work. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Linked the new TrackOccupant analysis from package contents. | Keeps the work package index current. |

---

# TrackOccupant Implementation-Plan Constraint Refinement

Date: 2026-07-15

Scope: Incorporated implementation-plan decisions into the TrackOccupant
architecture analysis.

## Summary

The TrackOccupant analysis now records the settled constraints for a future
first-slice implementation plan: all visible track content uses occupants,
empty cells have no occupant, constant and calculated requirements share the
same abstraction, shim tracks are ordinary fixed-height occupants, and the
coordinator remains feature-blind.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Added implementation-plan constraints and refined sections on empty cells, shim tracks, constant requirements, calculated requirements, coordinator responsibility, and first-slice scope. | Ensures the future implementation plan follows the revised architecture without implying implementation approval. |

---

# TrackOccupant Presentation Construction Wording

Date: 2026-07-15

Scope: Refined TrackOccupant terminology in the Cross-Column Layout Tracks
package.

## Summary

Replaced Flutter-specific "widget construction" phrasing with presentation
construction language. The architecture now reads as requirement calculation
plus construction of the presentation widget, which better captures the
conceptual boundary while preserving the concrete Flutter implementation shape.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Reworded TrackOccupant ownership and API sections from "widget construction" to "construction of the presentation widget" / "presentation construction." | Keeps the architecture concept durable while still acknowledging the current Flutter implementation. |

---

# TrackOccupant First Implementation Slice

Date: 2026-07-15

Scope: Updated the Cross-Column Layout Tracks work package after implementing
the first Search-page TrackOccupant slice.

## Summary

Search-page Track A/B requirements are now derived from declarative occupants
instead of page-owned numeric declarations. The documentation now records that
the first occupant slice is implemented while preserving the deferred scope for
future tracks, sidebar cassette participation, Conversation Cards, glyphs, and
Contacts migration.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Updated status and implemented-slice notes to describe occupant-derived Track A/B requirements and empty cells as omitted occupants. | Keeps the package narrative aligned with the implementation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added Phase 4A for the first TrackOccupant slice and marked focused occupant tests complete. | Makes remaining layout-track work discoverable without implying broader migration is done. |

---

# TrackOccupant Implementation Audit

Date: 2026-07-15

Scope: Verified the first TrackOccupant implementation slice against the
approved implementation seed.

## Summary

The audit found the first TrackOccupant slice architecturally sound. Search
Track A/B requirements are occupant-derived, empty cells contribute no
requirements, and the implementation remains within the approved first-slice
scope. The report records two caveats for future slices: finite-width
requirement contexts are still deferred, and the Track B plan currently uses a
representative metadata string because Track B is a single-line height track.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT/IMPLEMENT_TRACK_OCCUPANT_AUDIT.md` | Added implementation audit and verification report. | Provides the requested analysis report in the new TrackOccupant folder. |

---

# Cross-Column Track C Shim Slice

Date: 2026-07-15

Scope: Updated the Cross-Column Layout Tracks package after implementing the
first explicit Search-page shim track.

## Summary

Track C now models the first intentional cross-column spacing shim. The package
documents that empty spacing should be represented as an ordinary fixed-height
track occupant rather than as hidden padding inside Track A, Track B, or their
compatibility wrappers.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Updated package status and implemented-slice notes to include Track C as a fixed-height shim track. | Records that the Search page now separates metadata from supporting search content using an explicit empty track. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added Phase 4B for the Track C shim slice and focused shim validation. | Makes the next layout-track increment discoverable while preserving deferred scope for later tracks. |

---

# Track Cell And Shim Clarification

Date: 2026-07-15

Scope: Clarified Cross-Column Layout Tracks terminology and shim-track
ownership after the first Track C slice.

## Summary

The layout-track package now explicitly states that spacing shims are ordinary
tracks whose height is contributed by one `FixedHeightTrackOccupant` in one
cell. Peer cells honor the resolved allocation but do not contain duplicate
shim occupants. The package also now uses the `<Track letter><Column number>`
cell vocabulary, such as A1, B2, and C3.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added track-cell vocabulary and clarified the C1/C2/C3 Track C mapping. | Makes the current Search-page layout inspectable and prevents treating Track C as direct page-plan metadata. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Added shim-track and track-cell sections. | Records the settled architectural rule that spacing and content use the same occupant negotiation mechanism. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated older Track C examples so Track C is no longer described as primary content in the current Search-page implementation. | Removes stale terminology that conflicted with the implemented Track C shim. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added validation expectations for one C2 shim occupant and empty C1/C3 cells. | Ensures future tests protect against direct fixed-height track overrides or duplicate shim occupants. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Refined Track C checklist items around C2 ownership and empty C1/C3 cells. | Aligns implementation tracking with the settled cell vocabulary. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Updated the shim example to C1/C2/C3 and removed shim representation from open questions. | Marks the shim architecture as settled by implementation. |

---

# Track Semantic Neutrality Correction

Date: 2026-07-15

Scope: Corrected Cross-Column Layout Tracks terminology so tracks remain
ordinal geometric coordinates only.

## Summary

The previous Track C wording implied that a track could have an intrinsic role,
such as spacing or shim behavior. The corrected model is that tracks know only
their ordinal identity and resolved geometry. Meaning belongs to occupants and
to the page composition that places those occupants.

Current Search-page occupancy is documented as cell-specific:

- A1: Search top menu occupant.
- A2: "All messages" text occupant.
- A3: "Conversation" text occupant.
- B1: no occupant.
- B2: metadata text occupant.
- B3: no occupant.
- C1: no occupant.
- C2: `FixedHeightTrackOccupant(height: 8)`.
- C3: no occupant.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Replaced semantic track descriptions with Search-page cell occupancy. | Makes clear that Track A/B/C are coordinates, not roles. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Reframed examples around occupant placement rather than track meaning. | Prevents future implementations from teaching the coordinator semantic track roles. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Replaced shim-track terminology with fixed-height spacing occupant language. | Keeps spacing under the same occupant negotiation mechanism without assigning meaning to the track. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Renamed the implemented C2 slice around fixed-height occupant placement. | Keeps implementation tracking aligned with semantic-neutral track vocabulary. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Updated validation language to check C2 fixed-height occupant behavior rather than a shim track. | Ensures tests protect the generic track model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Updated empty-cell and spacing guidance to avoid semantic track roles. | Clarifies that spacing and content both use occupants. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT/IMPLEMENT_TRACK_OCCUPANT.md` | Updated the implementation seed language around fixed-height spacing occupants. | Prevents older seed text from reintroducing shim-track terminology. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT/IMPLEMENT_TRACK_OCCUPANT_AUDIT.md` | Replaced Track A/B summaries with A1/A2/A3 and B1/B2/B3 occupancy. | Aligns audit language with the corrected model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT/IMPLEMENT_TRACK_OCCUPANT_CHECK.md` | Updated the next-slice recommendation language. | Keeps future work framed around occupants, not semantic tracks. |
| `lib/essentials/navigation/presentation/layout/search_page_track_plan.dart` | Renamed the Search-page C2 height constant and updated occupancy comments. | Removes semantic track naming from code. |
| `lib/config/theme/widgets/layout/cross_column_track_plan.dart` | Updated `FixedHeightTrackOccupant` comments. | Clarifies that fixed-height allocation belongs to the occupant. |
| `lib/config/theme/widgets/layout/vertical_column_bands.dart` | Updated compatibility-wrapper comments. | Avoids implying fixed semantic meanings for Track A/B. |
| `test/config/theme/widgets/layout/cross_column_track_plan_test.dart` | Updated fixed-height occupant test wording. | Keeps test intent aligned with semantic-neutral tracks. |

---

# Track Cell Alignment Principle

Date: 2026-07-15

Scope: Added Track Cell Alignment as a future Cross-Column Layout Tracks
architecture principle.

## Summary

The layout-track package now distinguishes three independent concepts:

- track geometry: the resolved height and position of a shared track;
- occupant requirement: the natural space requested by an occupant;
- track cell alignment: placement of an occupant inside an already-resolved
  cell allocation.

Track Cell Alignment belongs to page composition. It is not a property of the
track, the `TrackOccupant`, or the underlying presentation widget. Initial
alignment options should remain limited to top, center, and bottom. Alignment
must not alter track requirements, resolved track height, or negotiation, and
must not become hidden padding.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added Track Cell Alignment overview and clarified that designers may use semantic language while the layout engine records only geometry and occupancy. | Gives future readers the top-level mental model before implementation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Added architectural rule separating track geometry, requirements, and alignment. | Establishes page-composition ownership of cell placement. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Added detailed ownership, examples, and padding distinction for Track Cell Alignment. | Prevents alignment from becoming hidden spacing or occupant-owned behavior. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added a future Track Cell Alignment phase. | Records the implementation boundary without authorizing code changes. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added future alignment test expectations. | Ensures future implementation proves alignment does not affect negotiation. |

---

# Conversation Card TrackOccupant Natural Height

Date: 2026-07-15

Scope: Recorded the replacement of the temporary fixed Conversation Card track
requirement with a natural, width-aware `ConversationSignatureCardTrackOccupant`
requirement.

## Summary

The current Search-page composition may now place a Conversation Card occupant
in C3 when the right Conversation excerpt is visible. That occupant no longer
uses a fixed placeholder height. It derives its natural requirement from the
same `ConversationSignatureCardPresentationMetrics` used by the rendered
Conversation Card, so glyph row count, card chrome, finite width, hooks, and
tags are represented in the requirement without teaching the page coordinator
Conversation semantics.

Track C remains semantically neutral. The documentation records C3 occupancy,
not a Track C role.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Updated current Search-page occupancy so C3 may contain a `ConversationSignatureCardTrackOccupant`; documented variable-height negotiation. | Makes the implemented C3 slice discoverable while preserving track semantic neutrality. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Replaced stale C3-empty wording with optional Conversation Card occupancy and shared metrics guidance. | Records why the page no longer owns a Conversation Card height constant. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added Phase 4C and validation items for the C3 Conversation Card occupant. | Tracks the completed vertical slice and its boundaries. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added focused Conversation Card metric and occupant tests to the validation map. | Documents the tests proving width-aware natural height and rendered/calculated parity. |

---

# Canonical Conversation Card Width

Date: 2026-07-15

Scope: Codified canonical `ConversationSignatureCard` width as a presentation
contract shared by rendered cards and track-occupant requirement calculation.

## Summary

The Conversation Card width is now documented as part of canonical Conversation
Card presentation. Containers must accommodate the card and may place it inside
wider space, but they do not stretch it or redefine its glyph geometry. This
makes glyph row count and natural-height requirements deterministic across the
Conversations sidebar and right/end Conversation excerpt panel.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added the canonical card-width contract and authoritative metrics symbol. | Makes the top-level layout package explain why C3 card requirements do not depend on panel width. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated Search-page occupancy examples and added the stable card-width principle. | Prevents stale C3-empty language and records the presentation ownership boundary. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Clarified that canonical card width, not ambient container width, drives card glyph geometry. | Keeps the TrackOccupant model deterministic while preserving semantic-neutral tracks. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added completed canonical-width implementation and validation items. | Records the implementation boundary and expected checks. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added canonical-width test expectations. | Ensures future tests protect the single width source of truth. |

---

# End-Panel Conversation Card Centering

Date: 2026-07-15

Scope: Recorded the presentation refinement that centers the fixed-width
canonical Conversation Card in the right/end Conversation excerpt panel.

## Summary

The canonical Conversation Card width remains stable and owned by the
Conversation Card presentation contract. The right/end Conversation excerpt
panel may center that fixed-width card when the panel is wider than the card.
This is horizontal presentation placement, not Track Cell Alignment and not a
new Track abstraction.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Clarified that right/end panel card centering is presentation placement, not track-system behavior. | Prevents a small visual refinement from broadening Track Cell Alignment. |

---

# Search-Page C2 Search Controls Occupancy

Date: 2026-07-15

Scope: Recorded the Search-page layout-track update that places the Message
Evidence post-metadata support/search-control group in cell C2.

## Summary

The old fixed 8 px C2 spacing occupant has been replaced by a
Message-Evidence-owned post-metadata controls occupant. The track remains
semantically neutral: the current Search-page composition places the
support/search-control group in C2 and bottom-aligns it inside the resolved
allocation when another cell contributes a taller requirement.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Replaced stale C2 spacing language with C2 post-metadata controls occupancy. | Keeps the canonical layout-track overview aligned with the current Search-page composition. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated Search-page occupancy tables from an 8 px spacing occupant to the Message Evidence controls occupant. | Prevents Track C from being misread as a semantic shim track. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Documented C2 bottom alignment for the support/search-control group. | Records the page-composition placement rule without broadening the track model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Updated Phase 4B to describe the post-metadata controls occupant slice. | Keeps implementation checklist history current. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added expectations for the C2 controls occupant and bottom-aligned track cell behavior. | Documents the focused regression surface. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TRACK_OCCUPANT_ARCHITECTURE_ANALYSIS.md` | Rewrote a fixed-height spacing example to avoid naming current Search-page C2 as a spacing cell. | Preserves semantic-neutral track language after C2 gained visible controls. |

---

# Search-Page D-Track Supporting Text Occupancy

Date: 2026-07-15

Scope: Recorded the Search-page layout-track update that separates the Message
Evidence search controls from supporting context text, and places the right
Conversation excerpt label in the same ordinal track.

## Summary

The current Search-page composition now uses C2 for the Message Evidence search
controls, D2 for the Message Evidence supporting context line, and D3 for the
right Conversation excerpt label when the excerpt panel is visible. Tracks
remain semantically neutral; these cells record only current occupancy.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Updated the current occupancy example with C2, D2, and D3 occupants. | Keeps the overview aligned with the implemented Search-page composition. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Updated Search-page occupancy tables to include Track D cells. | Prevents stale combined C2 wording from obscuring the current composition. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Generalized the occupancy example so it describes occupied cells rather than a semantic track role. | Reinforces semantic-neutral track documentation. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added D2 supporting-context occupant coverage to the test map. | Documents the focused regression surface for the new split. |

---

# Search-Page E-Track Fixed-Height Occupancy

Date: 2026-07-15

Scope: Recorded the Search-page layout-track update that adds an ordinal E
track with one fixed-height 16 px occupant.

## Summary

The current Search-page composition now includes an E track whose resolved
height is contributed by one ordinary `FixedHeightTrackOccupant(height: 16)`.
All three columns render the resolved E allocation before primary content.
Track E has no semantic meaning; it is only an ordinal coordinate with current
occupancy.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/README.md` | Added current E occupancy and clarified that the layout engine records geometry and occupancy, not spacer semantics. | Keeps the overview aligned with the current Search-page composition. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/PROPOSAL.md` | Added E occupancy to the Search-page examples. | Makes the current ordinal track plan discoverable. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/DESIGN_NOTES.md` | Added E occupancy to the current composition example. | Preserves the semantic-neutral track model. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/CHECKLIST.md` | Added Phase 4E for the fixed-height E occupant slice. | Records the implementation boundary and validation expectations. |
| `45-NEW-FEATURE-ADDITION/08-CROSS-COLUMN-LAYOUT-TRACKS/TESTS.md` | Added the E fixed-height occupant expectation to the test map. | Documents the focused regression surface. |

---

# Cross-Column Track Cell Rendering Anatomy

Date: 2026-07-16

Scope: Added a durable explanation of how Search-page track occupants,
requirements, resolved plans, scopes, and `TrackCellColumnBand` wrappers become
the Flutter widget tree.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/05-anatomy-of-track-cell-rendering.md` | Created a mechanical walkthrough of the rendering chain from page composition through `ResolvedTrackPlanScope` to track-cell rendering. | Gives future readers an obvious reference for how cross-column track coordination works in Flutter widget terms. |
| `09-CROSS-COLUMN-LAYOUT/README.md` | Added the anatomy document to the canonical reading order and link metadata. | Makes the new explanation discoverable from the durable cross-column layout index. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation addition. | Maintains the project documentation change log. |

---

# Track System Matrix Refactor — First Pass

Date: 2026-07-16

Scope: Established the concise current-state diagnosis and migration direction
for replacing the Search page's row-only Track requirement plan with an
authoritative two-dimensional page composition.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Created the work-package index and four-pass reading order. | Distinguishes canonical pass documents from their seed guidance and keeps the refactor scope discoverable. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/01-CURRENT-TRACK-SYSTEM-ANATOMY.md` | Created the concise current-system diagnosis, target direction, responsibility split, and migration outline. | Records why shared row-height negotiation is valuable but insufficient without one complete cell-level composition authority. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the first matrix-refactor documentation pass. | Maintains the project documentation change log. |

---

# Track System Matrix Refactor — Second Pass

Date: 2026-07-16

Scope: Established the canonical `PageTrackLayoutMatrix` architecture for the
Search-page refactor without beginning implementation planning or source work.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md` | Created the canonical matrix architecture, responsibility chain, constraint-to-claim flow, resolution model, lifecycle invariant, and temporary migration bridge. | Makes the matrix the explicit composition authority while preserving feature-owned presentation and semantic-neutral Track infrastructure. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Linked Document 02 in the package reading order. | Makes the approved target architecture discoverable. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the second matrix-refactor documentation pass. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Proposal Refinement

Date: 2026-07-16

Scope: Tightened the canonical matrix proposal before implementation planning
without changing its architecture or migration strategy.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md` | Simplified the title, elevated the composition-authority axiom, required complete matrix membership, strengthened presentation-derived dimensional truth, clarified page/cell placement ownership, and made renderer simplicity explicit. | Removes remaining terminology ambiguity while preserving the approved matrix architecture and one-matrix layout-tuning philosophy. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the canonical proposal refinement. | Maintains the project documentation change log. |

---

# Track System Matrix Refactor — Third Pass

Date: 2026-07-16

Scope: Converted the approved `PageTrackLayoutMatrix` architecture into a
five-phase, continuously runnable Search-page migration plan.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md` | Created the canonical migration plan with compatibility boundaries, repository-aware seams, phase objectives, verification gates, retirement steps, and completion criteria. | Gives implementation a practical sequence while keeping the matrix authoritative and the row-plan bridge temporary. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Added Document 03 to the package links and reading order. | Makes the executable migration plan discoverable after the target architecture. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the third matrix-refactor documentation pass. | Maintains the project documentation change log. |

---

# Track System Matrix Refactor — Fourth Pass

Date: 2026-07-16

Scope: Established the living implementation, evidence, compatibility
retirement, and completion record for the approved Search-page matrix
migration without beginning source implementation.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Created the phase dashboard, evidence sections, final matrix record, compatibility retirement ledger, verification ledger, deviation record, and final completion gate. | Gives implementation one durable authority for recording actual progress and proof without duplicating the architecture or migration plan. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Added Document 04 to package links and the canonical reading order. | Completes navigation through diagnosis, architecture, migration, and implementation evidence. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/01-CURRENT-TRACK-SYSTEM-ANATOMY.md` | Replaced stale matrix-owned-placement shorthand with the approved page/cell responsibility split. | Keeps the current-state document consistent with the refined canonical architecture. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the fourth matrix-refactor documentation pass. | Maintains the project documentation change log. |

---

# Track System Matrix Refactor — Package Consistency Pass

Date: 2026-07-16

Scope: Verified Documents 01–04 as one coherent package after completion of the
four documentation passes.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Added package status, relevant test reference, and complete Documents 01–04 navigation. | Makes it immediately clear that architecture and planning are complete while source implementation has not started. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/01-CURRENT-TRACK-SYSTEM-ANATOMY.md` | Added canonical successor links and replaced stale next-pass wording with the completed document sequence. | Prevents the current-state diagnosis from reading like unfinished work. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md` | Linked the migration plan and standardized presentation-construction language. | Keeps architecture terminology and navigation consistent. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md` | Standardized feature-owned presentation-construction wording. | Avoids suggesting that generic Track infrastructure owns feature widgets. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the package consistency pass. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Phase 1

Date: 2026-07-16

Scope: Recorded the verified, behavior-neutral introduction of matrix identity
and validation infrastructure for the Search-page migration.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Marked Phase 1 verified and recorded the final APIs, source/test locations, compatibility evidence, analyzer result, and absence of an active rendering path. | Preserves exact implementation evidence before the Search-page matrix bridge begins. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Updated package status and linked the new matrix infrastructure test. | Keeps the package index aligned with source progress. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the Phase 1 implementation evidence update. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Phase 2 Automated Evidence

Date: 2026-07-16

Scope: Recorded the Search-page matrix composition, temporary row-plan adapter,
single-scope distribution, focused tests, analyzer result, and remaining manual
verification gate.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Marked Phase 2 in progress; recorded its source seams, exact 15-cell matrix, removed occupant-bag paths, temporary adapter, one-plan distribution, automated evidence, pre-existing architecture-test failure, and pending visual/lifecycle checks. | Preserves exact evidence without marking the phase verified before manual Search-page review. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Updated package status and added the Search-page composition test. | Keeps the package index aligned with implementation progress. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the Phase 2 evidence update. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Phase 3 Contract Evidence

Date: 2026-07-16

Scope: Recorded the placement-independent occupant API, presentation
constraints, dimensional claims, focused verification, and the remaining
feature-presentation delegation boundary before cell rendering.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Marked Phase 3 in progress; recorded final claim contracts, migrated occupants, 42 passing focused tests, clean analyzer, unchanged architecture-test exception, retired placement APIs, and the three compatibility presentations still awaiting Phase 4. | Preserves exact implementation truth without claiming that dimensional adapters already own live feature presentation construction. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Updated package status for the Phase 3 contract migration. | Keeps the package index aligned with source progress. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the Phase 3 evidence update. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Phase 4 Resolution Foundation

Date: 2026-07-16

Scope: Recorded the immutable resolved matrix, complete resolved-cell model,
`CellId` renderer, one-time claim resolution, focused verification, and the
remaining feature-presentation preparation seam before live renderer migration.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Marked Phase 4 in progress and recorded resolved-matrix APIs, distribution, renderer behavior, 45 passing focused tests, clean analyzer, compatibility status, and the live presentation migration gate. | Distinguishes proven matrix resolution from the still-pending removal of local renderer authority. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Updated package status and test index for the resolved-matrix slice. | Keeps the package index aligned with source progress. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the Phase 4 resolution-foundation evidence. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Live Cell Renderer Migration

Date: 2026-07-16

Scope: Recorded feature-owned presentation preparation and direct `CellId`
rendering across the Search sidebar, center message-evidence header, and right
Conversation excerpt panel.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Marked Phase 3 verified; recorded the three live matrix render paths, cassette-boundary preservation, 68 passing focused tests, clean analyzer, compatibility status, and remaining manual Phase 4 checks. | Distinguishes completed matrix authority in the active Search path from fallback retirement and manual lifecycle proof. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Updated package status for the live renderer migration. | Keeps package orientation aligned with source progress. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this implementation evidence update. | Maintains the project documentation change log. |

---

# Search Track Width-Contract Verification

Date: 2026-07-16

Scope: Reconciled the Search matrix's only currently width-sensitive occupant
without inventing page geometry that the current window host does not expose.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Recorded the D3 canonical-width contract and the remaining host constraint for future fluid-width occupants. | Distinguishes a truthful feature presentation contract from guessed end-sidebar geometry. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this width-contract verification. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Compatibility And Constraint Audit

Date: 2026-07-16

Scope: Audited remaining row-plan consumers and the presentation constraints
used by resolved matrix claims after the Search row bridge was removed.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Recorded that no production row-plan scope remains, identified live non-matrix wrapper consumers, and added truthful per-column width constraints as a Phase 4 verification blocker. | Prevents premature compatibility deletion and prevents infinite-width claims from being mistaken for completed resize/wrapping support. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this audit. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Row Bridge Retirement

Date: 2026-07-16

Scope: Recorded removal of the Search page's temporary matrix-to-row-plan
adapter after all three live Track regions migrated to complete `CellId`
rendering.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Marked the temporary adapter removed and distinguished it from generic fallback wrappers still awaiting a consumer audit. | Preserves accurate retirement evidence without claiming unrelated compatibility code is already safe to delete. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the row-bridge retirement evidence. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Prepared Evidence Boundary

Date: 2026-07-16

Scope: Recorded the Messages-owned presentation boundary that supplies both the
global evidence source view and Search-page matrix occupants without allowing
layout code to initiate evidence-skeleton reads.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Documented the prepared evidence state, ownership correction, focused and full architecture results, provider test, and Phase 4 decision. | Preserves the distinction between feature-owned evidence composition and page-owned occupant placement. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Added the prepared-presentation test and updated package status. | Keeps package orientation aligned with the live implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this implementation evidence update. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Row-Only Compatibility Retirement

Date: 2026-07-16

Scope: Removed the dormant row-plan model, scope, renderers, wrappers, and
wrapper-only tests after confirming that the Search page renders entirely by
complete `CellId` and that non-matrix surfaces can use ordinary presentation
composition.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Recorded compatibility deletion, zero-reference scan, 23 passing focused tests, 350 passing architecture tests, and clean analyzer; left manual verification open. | Completes automated Phase 5 evidence without overstating visual verification. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Updated package status to automated Phase 5 retirement complete. | Keeps package orientation current. |
| `09-CROSS-COLUMN-LAYOUT/README.md` | Redirected the canonical reading path from wrappers to matrix/cell rendering. | Prevents new readers from adopting retired row-only mechanics. |
| `09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md` | Replaced wrapper ownership with matrix, resolver, occupant, and complete-cell ownership. | Aligns the durable contract with the implemented architecture. |
| `09-CROSS-COLUMN-LAYOUT/01-column-band-wrappers.md` | Replaced stale wrapper instructions with current matrix mechanics while retaining the filename for historical links. | Preserves navigation without preserving retired guidance. |
| `09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md` | Updated sidebar participation to A1-E1 complete-cell rendering. | Documents how the cassette seam now consumes the shared matrix. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Updated Search sidebar and troubleshooting guidance to matrix occupancy, claims, and alignment. | Makes the current applied layout discoverable. |
| `09-CROSS-COLUMN-LAYOUT/05-anatomy-of-track-cell-rendering.md` | Rewrote the rendering anatomy from the retired row plan to feature preparation, page matrix, resolution, scope, and `TrackCellView`. | Gives future developers an accurate mechanical explanation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this retirement and documentation-promotion pass. | Maintains the project documentation change log. |

---

# PageTrackLayoutMatrix Implementation — Full-Suite Proof

Date: 2026-07-16

Scope: Completed broad automated verification after retiring the row-only
compatibility system.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Recorded all 1,313 repository tests passing, the content-sized ordinary evidence-header fallback, the corrected display-phone expectation, and the remaining manual verification gate. | Preserves complete automated retirement evidence without claiming visual verification that has not yet been performed. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this full-suite proof. | Maintains the project documentation change log. |
# PageTrackLayoutMatrix Implementation — Minimum Cell Reservations

Date: 2026-07-16

Scope: Recorded the page-owned resting-geometry mechanism introduced after
manual Search verification showed optional right-panel cells collapsing before
their live occupants appeared.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md` | Added `MatrixCell.minimumReservedHeight`, its resolution rule, ownership, lifecycle purpose, and prohibitions. | Makes stable reactive geometry part of the canonical architecture without weakening truthful live claims. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/03-PAGE-TRACK-LAYOUT-MATRIX-MIGRATION-PLAN.md` | Added reservation implementation and verification requirements. | Ensures lifecycle stability is included in migration completion criteria. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Recorded the observed collapse, implemented C3/D2/D3 reservations, feature-owned metric sources, tests, and remaining verification. | Preserves implementation evidence and the exact Search-page occupancy correction. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Updated package status with the resting-geometry correction. | Keeps package orientation aligned with source. |
| `09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md` | Added the durable ownership and resolution rules for page-owned minimum cell reservations. | Prevents empty-cell guidance from incorrectly implying that optional content must collapse shared geometry. |
| `09-CROSS-COLUMN-LAYOUT/01-column-band-wrappers.md` | Updated the active resolver description with effective-height calculation. | Keeps the retained historical filename pointed at current matrix mechanics. |
| `09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md` | Clarified how empty sidebar cells participate in reserved shared geometry. | Keeps cassette flow compatible with the page matrix without introducing placeholder occupants. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Recorded C3, D2, and D3 reservation sources, deliberate zero reservations, and lifecycle verification expectations. | Makes the applied Search composition and its resting geometry discoverable. |
| `09-CROSS-COLUMN-LAYOUT/05-anatomy-of-track-cell-rendering.md` | Added reservations and effective-height resolution to the mechanical rendering chain. | Gives future developers an accurate account of how absent optional content preserves page geometry. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Recorded 29 focused layout tests, 350 architecture tests, all 1,320 repository tests, and clean analyzer after the reservation correction. | Completes automated proof while leaving the renewed visual lifecycle check explicit. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/README.md` | Added full-suite verification to the package status. | Keeps package orientation aligned with the completed automated proof. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation change log. |

# Search Page Matrix Tuning — Conversation Card B3

Date: 2026-07-16

Scope: Moved the optional Conversation Card and its feature-derived minimum
reservation from C3 to B3 while leaving the Search controls in C2.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Updated the current occupancy and reservation tables from C3 to B3. | Keeps the canonical applied-layout record synchronized with the matrix. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Updated the final matrix, reservation record, and compatibility evidence for B3. | Records the page-composition tuning without changing generic Track semantics. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this matrix tuning pass. | Maintains the project documentation change log. |

---

# Search Top Menu — Track-Safe Overlay Presentation

Date: 2026-07-16

Scope: Recorded the correction that keeps the sidebar top selector's transient
expanded options outside its resolved A1 geometry.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Documented that A1 claims only the closed trigger and that expanded options use an anchored overlay. | Prevents future interactive Track occupants from expanding inline beyond their resolved cells. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Recorded the overflow defect and overlay correction in the implementation decision ledger. | Preserves why transient menu presentation must remain separate from matrix geometry. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation change log. |

---

# Search Page Matrix Feature Close-Out

Date: 2026-07-16

Scope: Reconciled canonical, work-package, and UI-walk documentation after the
Search-page matrix migration and final top-menu interaction fix were verified.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md` | Replaced the last active wrapper-era prohibition with resolved-matrix-cell language. | Keeps the canonical contract aligned with the retired wrapper path. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Replaced the obsolete tuning note with the completed matrix status and durable tuning rule. | Records the reviewed Search-page result rather than an issue that has been resolved. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/02-AUTHORITATIVE-PAGE-TRACK-LAYOUT-MATRIX-PROPOSAL.md` | Corrected the page-specific occupancy example from C3 to B3. | Keeps the architectural example synchronized with the final matrix. |
| `45-NEW-FEATURE-ADDITION/INDEX.md` | Added the completed matrix-refactor package and its canonical handoff. | Makes the feature history and current owner discoverable. |
| `95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/README.md` | Added a current-outcome notice and marked the former band/wrapper material as design history. | Prevents UI-walk history from being mistaken for current mechanics. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded version 0.2.1+19 and the user-visible matrix behavior. | Closes the release-worthy feature with synchronized release metadata. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this close-out pass. | Maintains the documentation change log. |

Other MessageLens pages remain separately reviewed future adoption work; they
are not incomplete scope in this Search-page feature package.

---

# Search Investigation Compatibility

Date: 2026-07-18

Scope: Replaced the temporary imperative Conversation-excerpt dismissal with a
Search-owned generation identity and stored-versus-effective compatibility.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md` | Defined stored panel state, effective panel presentation, opaque investigation provenance, and derived visibility. | Makes declarative compatibility the canonical panel rule rather than scattered clearing commands. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/All-Messages/search_investigation_compatibility.md` | Recorded Search identity semantics, transitions, excerpt compatibility, restoration, and ownership. | Gives the All Messages UI walk one durable reference for the implemented investigation seam. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/All-Messages/01-PENDING-IMPLEMENTATIONS.md` | Recorded the deferred Context action for every Search-displayed message. | Preserves the next UI slice without expanding this state-management correction. |
| `CHANGELOG.md` | Reframed the 0.2.2 fix around investigation compatibility and restorable stored context. | Accurately describes the final user-visible behavior after removing the temporary imperative workaround. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation pass. | Maintains the project documentation change log. |

---

# Search Investigation Compatibility Canonicalization

Date: 2026-07-18

Scope: Promoted the verified Search investigation generation and
stored-versus-effective panel behavior from an implementation/UI-walk record
into current project, feature, essentials, and canonical spec documentation.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `00-START-HERE.md` and `README.md` | Added Search investigation compatibility to the cold-start and canonical documentation maps. | Makes the owning documents discoverable without searching historical UI-walk material. |
| `01-PROJECT/05-CURRENT-STATE.md` and `DEVELOPER_GUIDE.md` | Added the primary-investigation/subordinate-context mental model and declarative effective-panel rule. | Establishes the behavior as current project architecture, not a local Search workaround. |
| `30-ESSENTIALS/README.md` | Distinguished stored from effective panel state and documented the ownership boundary between shared Search execution, Messages interaction state, Conversations provenance, and navigation compatibility. | Prevents app orchestration and feature semantics from drifting together. |
| `40-FEATURES/README.md` and `40-FEATURES/search/` | Updated the Search charter, provider inventory, interaction rules, and verification requirements for `SearchInvestigationId`. | Gives Search one canonical feature-level explanation of transitions and restoration semantics. |
| `40-FEATURES/conversations/README.md` | Recorded that Conversation excerpts carry opaque originating provenance without owning or interpreting it. | Preserves the Search/Conversations ownership boundary. |
| `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`, `30-panel-viewspec-system.md`, and `90-invariants-and-contracts.md` | Replaced imperative clearing language with the invariant that incompatible stored state must cease to be effective; added Search cross-reference. | Codifies derivation over repair for all future panel work. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/All-Messages/search_investigation_compatibility.md` | Linked the UI-walk record to its canonical feature and panel owners. | Preserves implementation context without competing with canonical documentation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this canonicalization pass. | Maintains the project documentation change log. |

No application source, tests, configuration, generated files, databases, or
assets were changed by this documentation pass.

---

# Search Investigation Status Row

Date: 2026-07-18

Scope: Replaced the Search page's static supporting-context line with one
state-aware Track occupant derived from the existing evidence request.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `40-FEATURES/search/STATE_AND_PROVIDER_INVENTORY.md` | Recorded the existing presentation provider as the owner of derived investigation status and distinguished semantic state from presentation-local delay. | Prevents a second loading-state authority from emerging. |
| `40-FEATURES/search/INTERACTIONS_AND_NAVIGATION.md` | Documented the stable status-row lifecycle, 175 ms activity delay, shared leading-slot alignment, and explicit spacing ownership. | Makes the user-visible behavior and ownership durable. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Replaced D2's former supporting-context description with the Search Investigation Status occupant and current geometry contract. | Keeps the canonical Search matrix synchronized with source. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Updated the final matrix and resting-reservation record for the new D2 occupant. | Preserves the implementation history without assigning semantics to Track D itself. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/All-Messages/search_investigation_compatibility.md` | Added the implemented status presentation to the Search UI-walk record. | Connects investigation compatibility and visible investigation feedback. |
| `CHANGELOG.md` | Recorded the delayed, stable Search status row under version 0.2.2. | Keeps release metadata synchronized with the user-visible change. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation change log. |

---

# Conversation Excerpt Header Simplification

Date: 2026-07-19

Scope: Renamed the right Search-page panel to `Conversation excerpt` and
removed the redundant bounded-window caption from E3.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/essentials/navigation/presentation/layout/search_page_conversation_track_occupants.dart` and `search_page_track_plan.dart` | Renamed the A3 title occupant and made E3 explicitly empty. | Makes the panel identity precise and removes obsolete caption geometry from the authoritative matrix. |
| `lib/features/conversations/presentation/view/conversation_excerpt_panel_track_metrics.dart` and `conversation_excerpt_panel_view.dart` | Removed the excerpt-label presentation contract and updated matrix and fallback panel titles. | Keeps Conversations as the presentation owner without retaining an unused label path. |
| `lib/essentials/navigation/presentation/view/macos_app_shell.dart` | Removed retired E3 occupant and reservation inputs. | Keeps page composition synchronized with the smaller Conversations-owned input boundary. |
| Focused matrix and Conversation excerpt tests | Updated title, occupancy, and retired-caption expectations. | Protects the exact requested hierarchy and explicit empty E3 cell. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md`, `05-anatomy-of-track-cell-rendering.md`, the matrix implementation record, and the Message Evidence UI-walk documents | Replaced the earlier caption-based hierarchy with the current title, temporal orientation, and excerpt composition. | Gives future maintainers one accurate description while retaining historical evolution where useful. |
| `CHANGELOG.md` | Updated version 0.2.3's user-visible description. | Keeps release metadata synchronized with the refinement. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this implementation and documentation update. | Maintains the project documentation change log. |

---

# Search Investigation Status Alignment

Date: 2026-07-18

Scope: Aligned the Search Investigation Status presentation with the visible
text-field edge and represented its vertical separation as an explicit matrix
occupant.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md` | Updated the Search sidebar seam to render A1 through F1. | Keeps sidebar participation synchronized with the complete page matrix. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Recorded D1's 2 px occupant, E2/E3 status and excerpt occupancy, F1's existing final separation, and the visible field-edge alignment contract. | Makes current page composition and spacing ownership discoverable without assigning semantics to tracks. |
| `45-NEW-FEATURE-ADDITION/09-TRACK-SYSTEM-MATRIX-REFACTOR/04-PAGE-TRACK-LAYOUT-MATRIX-IMPLEMENTATION.md` | Updated the final matrix and implementation evidence from A-E to A-F. | Preserves an accurate implementation record. |
| `CHANGELOG.md` | Added the visible alignment and explicit matrix-spacing refinement to version 0.2.2. | Keeps release notes synchronized with the user-facing Search polish. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation change log. |

---

# Conversation Excerpt Temporal Orientation

Date: 2026-07-19

Scope: Added explicit month/year orientation to the Search page's Conversation
excerpt without changing its established Track sequence.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Recorded the C3 temporal-orientation occupant, its source, hierarchy, and lack of a separate resting reservation. | Keeps the canonical matrix description synchronized with current composition. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/shared_message_evidence_surface.md` | Added temporal orientation to the reviewed Conversation-context behavior and issue resolution. | Preserves the user-experience rationale alongside the evidence-surface review. |
| `CHANGELOG.md` | Recorded the user-visible Conversation excerpt orientation refinement. | Keeps release notes synchronized with current behavior. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation change log. |

---

# Mechanical Impossibility Principle

Date: 2026-07-19

Scope: Named and codified the architectural preference for making invalid
states structurally impossible rather than relying on procedural detection or
cleanup.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md` and `10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md` | Added the canonical Mechanical Impossibility Principle, its practical limits, the Cricket Ball, PageTrackLayoutMatrix, Search investigation compatibility, and Valve #3 examples; named it in the mandatory entry document; and linked to the owning mechanism documents. | Gives an organically recurring project pattern a durable constitutional name without presenting it as absolute dogma. |
| `DEVELOPER_GUIDE.md` | Named the existing derivation-over-repair guidance and linked it to the canonical constitutional section. | Gives new developers the principle's mental model near the start of the guide without duplicating the full explanation. |
| `09-CROSS-COLUMN-LAYOUT/00-cross-column-layout-contract.md` | Linked matrix composition authority to the Mechanical Impossibility Principle. | Connects the current layout contract to its higher-order architectural rationale. |
| `40-FEATURES/search/INTERACTIONS_AND_NAVIGATION.md` | Linked investigation-aware effective presentation to the Mechanical Impossibility Principle. | Makes clear that incompatible stored context is rendered impossible rather than imperatively cleared. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/10-ARCHITECTURE-CONTRACT.md` | Linked exclusive execution ownership to the Mechanical Impossibility Principle. | Records why the execution gate is authority, not merely contention detection. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation pass. | Maintains the project documentation change log. |

No application source, tests, configuration, generated files, databases, or
assets were changed by this documentation pass.

---

# Conversation Excerpt Temporal Accent

Date: 2026-07-19

Scope: Refined the existing month/year orientation heading with the established
orange organizing-value accent while preserving its matrix placement and
typographic hierarchy.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/features/conversations/presentation/view/conversation_excerpt_panel_track_metrics.dart` | Changed the shared temporal-orientation `title3` style from primary text to system orange at 84% opacity. | Makes the excerpt's temporal anchor immediately legible while keeping it subordinate to the panel title. |
| `09-CROSS-COLUMN-LAYOUT/03-search-page-current-implementation.md` | Recorded the temporal heading's semantic color treatment and unchanged no-divider layout. | Keeps the canonical Search matrix presentation description synchronized with the UI. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/shared_message_evidence_surface.md` | Documented orange as the temporal organizing-value accent for this surface. | Preserves the reviewed rationale in the UI-walk record. |
| `CHANGELOG.md` | Extended the 0.2.3 temporal-orientation release note with the color refinement. | Keeps release metadata synchronized with the in-progress user-facing change. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation change log. |

---

# All Messages Conversation Navigation

Date: 2026-07-19

Scope: Extended the existing `In conversation` workflow from text-search
results to every eligible All Messages row carrying canonical Conversation
identity.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/features/messages/presentation/view/global_messages_evidence_view.dart` | Replaced query/scope eligibility checks with canonical Conversation identity while preserving active-excerpt suppression and investigation provenance. | Makes Conversation navigation consistent across ordinary, month-browsed, and searched All Messages evidence. |
| `test/features/messages/presentation/view/global_messages_evidence_view_test.dart` | Added unfiltered open, missing-identity, and exact-active-excerpt coverage. | Protects the broadened workflow and its eligibility boundaries. |
| `40-FEATURES/search/INTERACTIONS_AND_NAVIGATION.md` and the shared Message Evidence UI-walk review | Documented that Search text is not an eligibility gate for Conversation navigation. | Keeps feature and UX guidance aligned with the shared evidence-row behavior. |
| `CHANGELOG.md` | Added the user-visible workflow under version 0.2.3. | Keeps release metadata synchronized with the current release slice. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this implementation and documentation update. | Maintains the project documentation change log. |

---

# Message Evidence Counterpart Labels

Date: 2026-07-19

Scope: Replaced ambiguous message sender metadata with explicit direction and
counterpart language across the shared message evidence surface.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `lib/features/messages/domain/message_evidence/message_evidence_row_data.dart` and `application/message_evidence/message_evidence_spine_provider.dart` | Added optional canonical Conversation display identity to prepared evidence rows, including batched initial hydration. | Gives outgoing evidence the recipient identity that sender-only message facts cannot provide. |
| `lib/features/messages/presentation/widgets/message_evidence/message_evidence_row.dart` | Changed metadata to `received from <sender>` and `from me to <Conversation>`, with an honest `from me` fallback when canonical identity is unavailable. | Makes direction and counterpart immediately understandable without route-specific presentation logic. |
| Focused message evidence provider and widget tests | Added canonical-title hydration and outgoing-label coverage; updated incoming-label expectations. | Protects both the read path and rendered language. |
| Shared Message Evidence UI-walk review and `CHANGELOG.md` | Recorded the common metadata grammar and user-visible correction. | Keeps UX and release documentation synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this implementation and documentation update. | Maintains the project documentation change log. |

---

# Self-Conversation Identity And Evidence Labels

Date: 2026-07-19

Scope: Added source-derived local-account handle identity so messages sent
between the user's own devices use one stable `self` metadata label.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `10-DATABASES/12-identity-model-contacts-handles-participants.md` | Documented local account handles as imported source evidence, their derivation from Messages account fields, and their projection into Conversation identity. | Prevents future code from mistaking message direction or a matching display title for self identity. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/shared_message_evidence_surface.md` | Added the `self` metadata grammar and its Conversation-level ownership. | Keeps the shared evidence UX contract aligned with the implemented behavior. |
| `CHANGELOG.md` | Recorded the user-visible self-conversation label correction. | Keeps release metadata synchronized with the implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation change log. |

---

# Self-Conversation Graph Migration Correction

Date: 2026-07-19

Scope: Corrected the graph database migration lifecycle so existing
`working_ss.db` files receive the new `handles.is_me` column before reads.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `CHANGELOG.md` | Recorded the existing-database migration correction. | Makes the release-visible failure and its resolution explicit. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded the correction and regression coverage. | Maintains the project documentation change log. |

---

# Historical Local-Account Handle Reconciliation

Date: 2026-07-19

Scope: Added startup reconciliation for historical self-owned Messages
endpoints without reimporting message records.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `10-DATABASES/12-identity-model-contacts-handles-participants.md` | Documented metadata-only startup reconciliation and canonical matching of phone URI/number variants. | Clarifies how historical local identities become graph facts without conflating direction with endpoint identity. |
| `CHANGELOG.md` | Recorded the existing-data correction under version 0.2.3. | Keeps release metadata synchronized with the user-visible fix. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this implementation documentation update. | Maintains the project documentation change log. |

---

# Local-Account Identity Documentation Consolidation

Date: 2026-07-19

Scope: Propagated the historical local-account reconciliation contract from the
canonical identity document into the source, lifecycle, orchestration,
Conversation ownership, current-state, and message-evidence guides.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `10-DATABASES/12-identity-model-contacts-handles-participants.md` | Added lifecycle ownership, execution-gate, and read-model invalidation details to the canonical local-account identity section. | Makes the complete implemented path discoverable in the identity source of truth. |
| `10-DATABASES/04-db-chat.md` | Documented `chat.account_login`, incoming `message.destination_caller_id`, `message.is_from_me`, canonical endpoint matching, and the metadata-only historical scan. | Records precisely which Apple source facts support local-account identity and what they do not mean. |
| `20-DATA-IMPORT-MIGRATION/01-overview.md` | Added startup local-account reconciliation to the active graph lifecycle and clarified that the monitor calls the graph-build service rather than importer/projector internals. | Keeps current import/build orchestration aligned with the implemented ownership boundary. |
| `55-READERS-INTEGRATORS-ORCHESTRATORS/30-INVARIANTS.md` | Added the source-fact-to-presentation invariant for local-account identity. | Prevents future display heuristics and direct orchestration across importer/projector boundaries. |
| `40-FEATURES/conversations/README.md` | Added the Conversations feature's consumption rule for projected self-conversation identity. | Clarifies that Conversations owns semantics and read-model exposure, not source derivation. |
| `01-PROJECT/05-CURRENT-STATE.md` | Added a concise current-state summary of historical reconciliation and self-conversation derivation. | Gives new contributors the current behavior without duplicating the canonical details. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/shared_message_evidence_surface.md` | Linked the `self` UX grammar to historical reconciliation and the canonical identity document. | Connects user-facing language to its source-derived architectural basis. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this consolidation pass. | Maintains the documentation audit trail. |

---

# Canonical First-Person Identity Presentation

Date: 2026-07-19

Scope: Extended canonical `handles.is_me` identity through ordinary
Conversation, Contact, handle, and message-evidence presentation.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `10-DATABASES/12-identity-model-contacts-handles-participants.md` | Defined local-account precedence and the `Me` / `me` / `self` presentation grammar. | Establishes one canonical source and prevents widget-local name comparisons. |
| `40-FEATURES/conversations/README.md` | Documented group-participant, self-only title, and chat-hook behavior. | Keeps Conversation-owned presentation aligned with the shared identity resolver. |
| `DEVELOPER_GUIDE.md` and `01-PROJECT/05-CURRENT-STATE.md` | Added the first-person identity model to contributor orientation and current-state guidance. | Makes the implemented rule discoverable without requiring schema archaeology. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/shared_message_evidence_surface.md` | Extended the evidence grammar beyond row metadata to titles and participant lists. | Keeps UX language consistent across ordinary evidence surfaces. |
| Shared recovered-evidence presentation | Routed recovered and unlinked sender labels through the same canonical resolver and documented `received from me` when no self-only Conversation relationship is available. | Prevents an incomplete relationship from leaking the user's imported personal name. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible change as version `0.2.4+22`. | Keeps release metadata synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Unknown Sources Total Center Projection

Date: 2026-07-20

Scope: Recorded the explicit idle/selected-source target model for the active
Unknown Sources investigation.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md` | Added the total-presentation projection rule and linked the first implemented example. | Establishes that an active investigation without a selection owns a truthful idle target rather than an absent center ViewSpec. |
| `45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/PROPOSAL.md` | Recorded the single Messages-owned `handleInvestigation` spec with explicit idle and selected-source targets. | Keeps the feature architecture aligned with implementation and preserves Handles-owned investigation meaning. |
| `09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md` | Replaced the obsolete no-occupant idle description with the real A2/B2 idle occupancy and truthful omission of source-specific cells. | Clarifies that layout stability follows from real investigation presentation, not minimum Track heights or fillers. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible change as version `0.2.11+29`. | Keeps release metadata synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Unfamiliar-Source Review Row Geometry

Date: 2026-07-19

Scope: Corrected the unfamiliar-source review list's narrow-sidebar geometry
so its feature-owned dismiss rail is not also reserved by the cassette frame.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md` | Clarified that trailing action space has one owner: either the shared cassette envelope or the feature-owned body. | Prevents double-gutter layouts from clipping row metadata and displacing actions. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible correction as version `0.2.5+23`. | Keeps release metadata synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Unfamiliar-Source Evidence Scope Parity

Date: 2026-07-19

Scope: Unified unfamiliar-source counts, timeline enumeration, hydration, and
search around canonical sender identity rather than optional chat membership.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `40-FEATURES/messages/DOMAIN_AND_DATA_MAP.md` | Defined standalone handle scope as canonical sender evidence and made chat membership optional provenance. | Prevents valid sender-only records from disappearing from the shared evidence spine. |
| `95-WALK-UI-TREE/10-Messages-Sidebar/Message-Evidence-Center-Panel/shared_message_evidence_surface.md` | Recorded the reported badge/timeline mismatch and the cross-surface scope-parity rule. | Keeps unfamiliar-source counts, evidence, and search tied to one user-visible meaning. |
| `CHANGELOG.md` | Recorded the user-visible unfamiliar-source evidence correction under version `0.2.5`. | Keeps release metadata synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Unknown-Source Investigation Separation

Date: 2026-07-19

Scope: Defined and recorded the first implemented separation between unknown
source identification and neutral numeric-sender review.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/UNKNOWN_SOURCES/PROPOSAL.md` | Promoted the approved proposal to first-slice implementation status and recorded the typed endpoint, compatible read-model, cassette-navigation, and recovery boundaries. | Keeps the architectural decision and its implemented extent in one discoverable working package. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible investigation separation as version `0.2.6+24`. | Keeps release metadata synchronized with the new workflow. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this architecture and release-documentation update. | Maintains the project documentation audit trail. |

---

# Unfamiliar-Source Investigation Compatibility

Date: 2026-07-20

Scope: Made selected handle evidence subordinate to the unfamiliar-source
investigation episode that created it.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `40-FEATURES/chat-handles/INTERACTIONS_AND_NAVIGATION.md` | Documented opaque unfamiliar-source investigation provenance and the controls that begin a new episode. | Establishes the canonical Handles navigation rule and prevents imperative panel cleanup. |
| `45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/PROPOSAL.md` | Recorded the implemented sidebar/center compatibility seam. | Keeps the approved proposal aligned with the shipped architectural correction. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible correction as version `0.2.7+25`. | Keeps release metadata synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Unfamiliar-Source Cross-Column Composition

Date: 2026-07-20

Scope: Applied the canonical page matrix to the unfamiliar-source sidebar and
selected-handle evidence header.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md` | Recorded the page-specific matrix occupancy, shared handle-lens session, and post-matrix cassette continuation. | Gives future developers one direct explanation of how the sidebar and center evidence align without sharing ownership. |
| `09-CROSS-COLUMN-LAYOUT/README.md` and `02-sidebar-cassette-content-start-seam.md` | Added the unfamiliar-source composition to the canonical reading path and generalized the seam from Search-only wording. | Keeps the generic seam accurate now that a second cassette-driven page participates. |
| `45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/PROPOSAL.md` | Recorded the implemented cross-column composition slice. | Keeps the feature work package aligned with the implemented page architecture. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible layout change as version `0.2.8+26`. | Keeps release metadata synchronized with the implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Unfamiliar-Source Track Contract Audit

Date: 2026-07-20

Scope: Clarified page/feature ownership, made finite-width source metrics
dimensionally truthful, and named fixed-height diagnostics by composition
purpose.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md` | Added the Navigation/app-shell/Messages/Handles ownership chain, documented the adaptive metrics claim, and clarified the page-wide separator contributed from I1. | Preserves the intentional feature boundary and explains shared geometry without assigning semantics to ordinal Tracks. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Handle-Lens Center-Panel Responsibility Correction

Date: 2026-07-20

Scope: Corrected source-review workflow and identity ownership while preserving
the Messages-owned ViewSpec and presentation.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `40-FEATURES/chat-handles/CHARTER.md` | Defined Handles ownership of source identity and source-review semantics. | Prevents rendering features from reimplementing Handles business rules. |
| `40-FEATURES/messages/CHARTER.md` | Defined Messages ownership of the complete handle-lens ViewSpec presentation and its dependency on Handles seams. | Preserves one-feature/one-ViewSpec ownership without semantic leakage. |
| `45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/PROPOSAL.md` | Recorded the implemented per-source payload, workflow facade, and corrected dismissal behavior. | Keeps the feature package aligned with implementation. |
| `95-WALK-UI-TREE/20-Responsibility-for-center-panel/completion-report.md` | Added the requested implementation and verification report. | Provides a durable close-out adjacent to the task and audit. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible correction as version `0.2.9+27`. | Keeps release metadata synchronized with the fixed Dismiss behavior. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Unfamiliar-Source Dismissal Transition

Date: 2026-07-20

Scope: Completed Dismiss as a source-granular projection update and a
declarative unfamiliar-source investigation transition.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `40-FEATURES/chat-handles/INTERACTIONS_AND_NAVIGATION.md` | Defined successful dismissal as a post-persistence investigation transition and recorded source-granular projection updates. | Prevents stale center evidence and whole-list loading resets without imperative panel cleanup. |
| `45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/PROPOSAL.md` | Recorded the implemented dismissal lifecycle and independent active/dismissed projection behavior. | Keeps the feature package aligned with the completed user workflow. |
| `95-WALK-UI-TREE/20-Responsibility-for-center-panel/completion-report.md` | Added the follow-up correction, event order, and regression coverage. | Completes the prior ownership report with the observed runtime transition. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible fix as version `0.2.10+28`. | Keeps release metadata synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Persistent Center-Panel Identity Proposal Refinement

Date: 2026-07-21

Scope: Refined the Unknown Sources persistent center-panel identity proposal
before implementation.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/01-PERSISTENT-CENTER-PANEL-IDENTITY/proposal.md` | Defined persistent identity as header content, investigation orientation as the first post-header reading content, and center identity as a derived projection of the active investigation. Clarified that the idle explanation replaces evidence rather than the header and retained the Matrix boundary. | Records why the presentation hierarchy exists without turning its current body placement into a universal rule. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Persistent Center-Panel Identity Implementation

Date: 2026-07-21

Scope: Implemented stable investigation-derived identity, selected-source
subject hierarchy, and explanatory Unknown Sources idle evidence.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/01-PERSISTENT-CENTER-PANEL-IDENTITY/proposal.md` | Recorded the implemented presentation contract, selected hierarchy, loading behavior, and Matrix boundary. | Closes the approved work package without promoting the pattern into a universal framework. |
| `45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/PROPOSAL.md` | Added the implemented persistent center-panel identity slice. | Keeps the parent feature proposal synchronized with current behavior. |
| `09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md` | Updated A2/B2 occupancy and the idle evidence-region presentation. | Keeps the canonical page composition accurate. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible hierarchy and orientation change as version `0.2.12+30`. | Keeps release metadata synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this implementation documentation pass. | Maintains the project documentation audit trail. |

---

# Unknown Sources Sidebar Shared-Track Boundary

Date: 2026-07-24

Scope: Ended Unknown Sources sidebar Matrix participation after the persistent
A1/A2 identity row so transient selected-source center details cannot move the
independent cassette flow.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md` | Documented page-declared sidebar shared-track boundaries and the Unknown Sources A-row boundary. | Makes the generic renderer consume explicit page composition instead of assuming every Matrix row precedes every cassette chain. |
| `09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md` | Replaced the obsolete B1-I1 continuation with independent sidebar flow after A1 and moved the 16 px center header/evidence occupant to I2. | Records the truthful persistent peer relationship and removes accidental coupling to transient center details. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible layout correction as version `0.2.13+31`. | Keeps release metadata synchronized with the fixed sidebar behavior. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Recovered Messages Track A Composition

Date: 2026-07-26

Scope: Aligned the recovered-message sidebar menu and center title through one
truthful shared Track while preserving independent layout below it.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/08-recovered-messages-page-current-implementation.md` | Added the canonical current composition for Recovered Deleted Messages and Recovered No-Handle Messages. | Establishes that only A1/A2 share geometry and that both columns resume their native flows immediately afterward. |
| `09-CROSS-COLUMN-LAYOUT/README.md` | Added the recovered-message composition to the canonical index and reading order. | Makes the page-specific application discoverable from the cross-column layout entry point. |
| `09-CROSS-COLUMN-LAYOUT/07-column-specific-shared-track-boundaries.md` | Added Recovered Messages as a second concrete shared-boundary example. | Shows that a page may truthfully end both sidebar and center shared lifetimes at Track A. |
| `CHANGELOG.md` and `pubspec.yaml` | Recorded the user-visible alignment change as version `0.2.15+33`. | Keeps release metadata synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Contacts Track A Composition

Date: 2026-07-26

Scope: Aligned the Contacts sidebar menu with the title supplied by the feature
that owns the effective center ViewSpec.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `09-CROSS-COLUMN-LAYOUT/09-contacts-page-current-implementation.md` | Added the canonical current Contacts composition and its Messages/Conversations occupant ownership chain. | Establishes that only A1/A2 share geometry and that both columns resume native flow after Track A. |
| `09-CROSS-COLUMN-LAYOUT/README.md` | Added the Contacts composition to the canonical index and reading order. | Makes the page-specific application discoverable from the cross-column layout entry point. |
| `09-CROSS-COLUMN-LAYOUT/07-column-specific-shared-track-boundaries.md` | Added Contacts as a concrete shared-boundary example. | Demonstrates that Navigation may place an occupant prepared by the effective center ViewSpec owner without taking presentation ownership. |
| `CHANGELOG.md` | Recorded the user-visible Contacts title alignment in the current release entry. | Keeps release notes synchronized with implementation. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Production Data Protection Current-State Audit

Date: 2026-07-27

Scope: Completed the read-only static audit of environment resolution,
production archive reachability, mutation authority, safeguards, and runtime
verification requirements for Production Readiness Workstream 1.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/CURRENT-STATE-AUDIT.md` | Added the complete current-state audit, evidence classifications, escape paths, runtime verification matrix, and minimum conditions before onboarding work. | Establishes that ordinary debug launches can currently mutate the production archive while preserving the distinction between read-only Apple sources and writable app-owned stores. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Marked the static audit complete, linked the report, and summarized its central findings. | Makes the workstream status and next evidence boundary immediately discoverable. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Production Data Protection Architecture Proposal

Date: 2026-07-27

Scope: Converted the Workstream 1 audit findings into a fail-closed production
archive identity, admission, mutation-authority, and recovery architecture.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PROPOSAL.md` | Defined production/development/test archive identities, pre-provider validation, archive-scoped process admission, operation-specific mutation authority, recovery evidence, migration phases, invariants, and acceptance criteria. | Establishes the mechanical boundary that prevents ordinary development and tests from mutating the permanent archive while preserving production FDA continuity. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Advanced the workstream status, linked the proposal, and summarized the proposed boundary. | Keeps the workstream reading order and implementation authorization state explicit. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Production Data Protection Decisions And Plans

Date: 2026-07-27

Scope: Resolved the proposal's bounded implementation decisions and defined the
phased implementation and validation programs without authorizing code or
production operations.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/QUESTIONS.md` | Settled development identity, native/Dart handoff, archive marker, environment-scoped state, initial mutation authority, checkpoint evidence, production adoption, development FDA, and production build decisions. | Removes architectural ambiguity before implementation planning while preserving runtime verification obligations. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/IMPLEMENTATION-PLAN.md` | Defined ten reviewable slices from baseline tripwires through production adoption and canonical documentation promotion. | Prevents partial isolation from being mistaken for safety and keeps production adoption separately authorized. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/VALIDATION.md` | Defined static, native, disposable runtime, operation-concurrency, recovery, artifact, and production-adoption validation gates. | Specifies the objective evidence required before claiming production protection. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Advanced workstream status and linked the decisions and plans. | Makes the complete Workstream 1 planning sequence discoverable and preserves the no-implementation authorization boundary. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Production Preservation Authority Refinement

Date: 2026-07-27

Scope: Clarified the architectural distinction between archive admission and
the authority responsible for preserving newly arriving production data.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-PRESERVATION-AUTHORITY.md` | Defined authority assignment to one production archive identity, single-process exercise, redundant development preservation, heartbeat freshness, cursor evidence, preservation-pass outcomes, and the provisional operating procedure. | Makes preservation responsibility and liveness objectively demonstrable without conflating them with archive admission. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Added the preservation-authority document to metadata, reading order, and the next production planning gate. | Makes the follow-on requirement discoverable without implying that production adoption or authority designation has been authorized. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Production Preservation Continuity Gate

Date: 2026-07-27

Scope: Promoted continuity of live production preservation from follow-on work
to a blocking prerequisite for every Production Readiness implementation slice.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-PRESERVATION-AUTHORITY.md` | Marked the architecture blocking and added the per-slice authority, evidence, continuity, and handoff admission contract. | Prevents implementation from proceeding while newly arriving production data lacks an actively verified preservation owner. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Changed workstream status and next gate to block subsequent slices on preservation continuity. | Makes the prerequisite visible at the workstream entry point. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/IMPLEMENTATION-PLAN.md` | Added preservation continuity as the third sequencing constraint and a mandatory slice-admission checklist. | Applies the authority contract mechanically to every implementation slice rather than treating it as deferred health work. |
| `90-DATA-INGESTION-REVIEW/00-PRODUCTION-READINESS-MASTER-PLAN.md` | Added a project-wide blocking preservation principle and constrained Production Health to observing, not owning, the guarantee. | Propagates the prerequisite across all workstreams while preserving responsibility boundaries. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---

# Production Preservation Slice Admission And Implementation Plan

Date: 2026-07-27

Scope: Applied the blocking preservation-continuity gate before further code
implementation and defined the implementation sequence required to make
production preservation authority mechanically enforceable.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/VALIDATION-RESULTS/preservation-continuity-admission-2026-07-27.md` | Recorded the legacy Debug process, production-root activity, preservation evidence, and the initially incomplete transition diagnosis; the later correction is recorded below. | Demonstrates that process presence is not authority or liveness and preserves the audit trail leading to the corrected handoff plan. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRESERVATION-AUTHORITY-IMPLEMENTATION-PLAN.md` | Defined ownership, durable evidence, freshness, exclusivity, phased implementation, validation, and production handoff. | Converts the blocking architecture into a bounded implementation sequence without authorizing production adoption. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md` | Linked the new plan and admission report and summarized the current blocked state. | Makes the gate and required next action visible from the workstream entry point. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/IMPLEMENTATION-PLAN.md` | Linked the dedicated preservation-authority sequence and current admission result. | Keeps the master implementation plan synchronized with the blocking prerequisite. |
| `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/VALIDATION-RESULTS/README.md` | Indexed the read-only admission report and distinguished it from disposable runtime validation. | Preserves the production-contact boundary while making operational evidence discoverable. |
| `DOCUMENTATION_PASS_LOG.md` | Recorded this documentation update. | Maintains the project documentation audit trail. |

---
# 2026-07-27 - Correct production preservation transition authority

- Updated
  `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-PRESERVATION-AUTHORITY.md`
  to recognize the already-running legacy Debug process as the bounded
  provisional preservation process and to reject the months-old installed app
  as an automatic successor.
- Added
  `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-PRESERVATION-HANDOFF-PLAN.md`
  defining preparation, rehearsal, staging, authorized cutover, rollback, and
  normal production/development coexistence.
- Corrected
  `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/VALIDATION-RESULTS/preservation-continuity-admission-2026-07-27.md`
  so it no longer instructs the developer to stop the preservation process and
  launch an obsolete installed build.
- Updated the workstream README, implementation plans, adoption runbook, and
  validation index to use the corrected transition sequence.
- No process was stopped or launched, no application was installed, and no
  production archive content was changed.

---

# 2026-07-27 - Prepare production candidate and adoption rehearsal

- Updated the Production Data Protection README, implementation plan,
  preservation-authority contract, handoff plan, adoption runbook, validation
  plan, completion report, and validation index to reflect the revised
  operational fact: Debug is isolated and production preservation is currently
  interrupted.
- Added
  `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/VALIDATION-RESULTS/production-candidate-and-adoption-rehearsal-2026-07-27.md`
  with signed-candidate identity evidence, disposable checkpoint/adoption
  evidence, catch-up and attachment-preservation rehearsal results, rollback
  limits, and remaining authorization boundaries.
- Marked the earlier preservation-continuity admission conclusion as
  historical and superseded without deleting its audit evidence.
- Documented the exact checkpoint, restore, adoption, admission, and
  pre-mutation rollback commands for the separately authorized real cutover.
- Recorded 68 focused regression tests, 352 architecture tripwires, 1,442 full
  Flutter regression tests, and a clean analyzer result.
- No production application was installed or launched, and no production
  archive content was marked, restored, adopted, or mutated.

---

# 2026-07-28 - Verify backup and separate adoption inventory

- Added
  `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/VALIDATION-RESULTS/final-cutover-preparation-2026-07-28.md`
  with signed-artifact identity, notarization failure, external recovery-backup
  verification, production archive inventory, cutover sequence, and remaining
  authorization boundary.
- Updated the Production Data Protection README, implementation plan,
  validation plan, completion report, preservation-authority contract, handoff
  plan, adoption runbook, and validation index.
- Replaced the real-cutover requirement for a second full archive copy with the
  verified existing external backup plus a small read-only in-place adoption
  inventory. Full checkpoint/restore remains the disposable recovery rehearsal
  mechanism.
- Recorded that Apple notarization is blocked by a missing or expired developer
  agreement. The signed DMG was not installed, launched, or represented as a
  final cutover artifact.
- No production marker was created, no application was installed or launched,
  and neither the production archive nor external backup was modified.

---

# 2026-07-28 - Execute production archive cutover

- Added
  `90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/VALIDATION-RESULTS/production-cutover-2026-07-28.md`
  as the authoritative execution record for the authorized in-place adoption,
  installed artifact, migration incident and correction, catch-up, live
  preservation, overlay retention, development isolation, and bounded
  attachment residual.
- Updated the Production Data Protection README, implementation plan,
  validation plan, completion report, adoption runbook, preservation-authority
  contract, preservation handoff plan, and Production Readiness master plan to
  reflect that production adoption is complete.
- Updated the validation-results index and marked the final preparation report
  as historical preparation evidence superseded by the executed cutover
  record.
- Recorded that all 12 image attachments from the interrupted initial catch-up
  were recovered, while nine plugin payload attachments and three QuickTime
  videos remain a bounded reconciliation gap because delayed retry is currently
  image-only.
- Recorded that Debug used only the configured external development archive and
  that the installed production application remained the production
  preservation process.

---

# 2026-08-09 - Explain database access authority in plain English

- Added
  `10-DATABASES/access_authority_documentation/010-DATABASE-ACCESS-IN-PLAIN-ENGLISH.md`
  as a human-oriented translation guide for the post-production-readiness data
  access architecture.
- Explained the development/production motivation, archive root as the complete
  MessageLens data folder, archive admission as folder/build validation,
  `ArchiveAccessAuthority` as the validated ticket, and persistent providers as
  individual store openers beneath that ticket.
- Distinguished archive access authority, protected mutation coordination,
  the narrower derived maintenance/read-suppression signal, and source-scoped
  imported-record identity.
- Preserved the three-question summary and translation dictionary while
  correcting historical filenames and avoiding the inaccurate implication
  that maintenance locking universally revokes all database access.
- Linked the guide from the canonical database inventory. No application code,
  tests, configuration, databases, or assets were changed.

---

# 2026-08-09 - Implement the real FDA Presence slice

- Added
  `21-PRESENCE-ITERATION-SIMPLE/03-SCHEDULE-TRIP-EXPERIMENT/90-REAL-FDA-ONBOARDING-IMPLEMENTATION.md`
  as the implementation record for the development-only five-Trip FDA
  Schedule.
- Updated `30-SYSTEM-BOUNDARIES.md` for the concrete Settings-opening authority,
  real FDA client adapter, new Step subtype, and real fixture boundaries.
- Updated the two plain-English Presence database guides for the schema-v5
  payload-free `open_fda_settings` subtype.
- Generated the real FDA topology artifact from persisted definitions. No
  production onboarding architecture was changed.
- Recorded successful verification: 52 focused Presence tests, 354
  architecture tripwires, clean analyzer output, successful debug macOS build,
  code generation, formatting, and whitespace validation.

---

# 2026-08-09 - Investigate the inaccurate FDA test

- Added
  `45-NEW-FEATURE-ADDITION/22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/03-INACCURATE-FDA-TEST-INVESTIGATION.md`
  with the concrete Presence-to-onboarding provider trace, exact protected
  source path, and exact file operation used by the current FDA probe.
- Recorded that the runtime uses `MacosFullDiskAccess` without a fake,
  provider override, or cached result, but only opens and closes a plain
  read-only file descriptor rather than performing an SQLite source read.
- Distinguished the proven effective-access result from the unobservable macOS
  authority behind it, recording the evidenced responsible-process,
  development-signing, and file-specific `com.apple.macl` considerations.
- Recorded that production onboarding shares the same narrow probe and that a
  future truthful check should execute a minimal read-only query against the
  protected `message` table. No FDA behavior, Presence route, Schedule, source
  access policy, application code, or tests were changed.

---

# 2026-08-09 - Implement truthful Messages source readiness

- Added
  `45-NEW-FEATURE-ADDITION/22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/04-TRUTHFUL-MESSAGES-SOURCE-READINESS-IMPLEMENTATION.md`
  as the implementation record for the corrected protected-source probe,
  operational authority naming, copy revision, five-Trip assessment, restart
  seam, and specialist/Step/user knowledge boundaries.
- Linked the preceding inaccurate-probe investigation to its corrective
  implementation record.
- Updated `21-PRESENCE-ITERATION-SIMPLE/30-SYSTEM-BOUNDARIES.md` so the narrow
  Presence authority means Messages source readability rather than claiming
  knowledge of the macOS Full Disk Access switch.
- Recorded that the existing Conversation Graph source-probe reader is reused,
  the exact SQLite operation is read-only and schema-specific, diagnostic
  failures remain specialist-owned, and production onboarding remains outside
  this development-only Presence slice.

---

# 2026-08-10 - Record the manual FDA-off readiness result

- Updated the truthful Messages source-readiness implementation record with the
  observed FDA-off development run.
- Recorded from the append-only Presence trace that a fresh Trip 202 readiness
  Step ran at 06:32:18 and selected readable Trip 205; this was not stale run
  restoration.
- Recorded that the app was launched beneath the VS Code Flutter debug chain,
  the Debug artifact was ad hoc signed, and `chat.db` carried `com.apple.macl`.
- Clarified that the operational probe truthfully established effective SQLite
  readability for that process, while a controlled unreadable-path test needs
  a directly launched, stably signed development artifact without a privileged
  launcher in its responsible-process chain. No application code changed.

---

# 2026-08-10 - Prepare the isolated FDA experiment artifact

- Updated the truthful Messages source-readiness implementation record with the
  exact standalone experiment identity, development-root contract, mutual
  native/Dart admission rule, process-lock consequence, and isolated build
  procedure.
- Recorded that the experiment uses
  `com.bigbenchsoftware.MessageLens.fdaexperiment`, embeds only the established
  external development archive root, and is signed with the installed Apple
  Development identity.
- Recorded that the build path neither changes nor launches production or the
  normal development application and performs no TCC/Full Disk Access changes.

---

# 2026-08-10 - Validate the isolated FDA restart route

- Added
  `45-NEW-FEATURE-ADDITION/22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/05-MANUAL-FDA-RESTART-VALIDATION.md`
  as the focused manual evidence record for the directly launched, separately
  signed FDA experiment.
- Updated the truthful source-readiness implementation record with the exact
  unreadable -> remediation -> Settings -> restart -> verification -> readable
  route and the first presentation observed after restart.
- Traced the initial apparently stale confirmation to Schedule 5 run 10, which
  was still active at occurrence `5105` in the shared development
  `presence.db`; the experiment host rendered that checkpoint truthfully.
- Recorded that `Run Again` completed the transition to new run 11 at
  occurrence `5101`, and that restart later reconstructed run 11 at verification
  occurrence `5104` before a fresh SQLite source read selected confirmation.
- Confirmed that no code correction, run-history deletion, database reset,
  bundle-specific run rule, second runtime authority, or change to Schedule,
  Trip, Step routing, Scheduler, or checkpoint semantics was warranted.

---

# 2026-08-10 - Plan the next real onboarding concern

- Added
  `45-NEW-FEATURE-ADDITION/22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/06-NEXT-REAL-ONBOARDING-CONCERN-PLAN.md`
  from the current production onboarding evaluator, gate, Environment
  Readiness presentation, and Address Book source-resolution implementation.
- Recorded the complete blocker precedence after Messages readability and
  identified viable local Address Book discovery/readability as the immediate
  next independent source blocker.
- Proposed a bounded Schedule extension with one narrow
  `ContactsSourceReadinessStep`, one Contacts remediation loop, and a combined
  source-readiness confirmation, while preserving existing FDA Steps.
- Recorded that the Messages-only confirmation has no independent semantic or
  restart value once the Contacts test follows and should be replaced by the
  combined final confirmation in a newly identified Schedule definition.
- Confirmed that Trip, Scheduler, routing, checkpoint, restart, and trace
  semantics need no change, and isolated the separate product decision created
  by production treating Contacts as mandatory while current copy describes it
  as primarily contextual enrichment.
- No application code, tests, configuration, databases, generated files, or
  production onboarding behavior changed.

---

# 2026-08-10 - Implement Contacts source readiness

- Added
  `45-NEW-FEATURE-ADDITION/22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/07-CONTACTS-SOURCE-READINESS-IMPLEMENTATION.md`
  as the implementation and manual-validation record for the next source
  readiness slice.
- Recorded reuse of the existing Address Book repository through a disposable
  development-client adapter and a narrow Presence-owned Boolean authority.
- Recorded schema version 6, the class-table Contacts readiness subtype, the
  new Schedule 6 identities and topology, and preservation of Schedule 5
  history.
- Recorded removal of the Messages-only confirmation from the active fixture,
  the ordinary Contacts remediation loop, restart behavior, user-facing copy,
  and focused test evidence.
- Updated the current Presence system-boundary document for the fifth concrete
  Step subtype and its specialist ownership chain.
- Preserved the unresolved production contradiction between Contacts as a hard
  blocker and Contacts as contextual enrichment; no production integration or
  product-policy change was made.

---

# 2026-08-10 - Add disposable Contacts-source test seam

- Added
  `45-NEW-FEATURE-ADDITION/22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/08-DISPOSABLE-CONTACTS-SOURCE-TEST-SEAM.md`
  as the implementation and manual-test record for controlled Contacts
  unavailability.
- Recorded the explicit Address Book `Sources` root as the chosen injection
  point, preserving ordinary repository discovery, candidate validation, and
  read-only SQLite querying.
- Documented the development-archive paths for the deliberately missing source
  root and the machine-local source-mode file needed to preserve the laboratory
  condition across restart.
- Added the exact unavailable, restart, retry, source-switch, and recovery
  procedure, including the requirement that Contacts-only failure never enter
  FDA remediation.
- Updated the Contacts readiness implementation record to link to the controlled
  procedure instead of suggesting manipulation of a live source.
- Confirmed that production Contacts composition and all Presence semantics
  remain unchanged.

---

# 2026-08-10 - Correct Schedule 6 definition-name collisions

- Recorded that Trip and Step definition names are globally unique persisted
  identities in the current Presence schema, not Schedule-local labels.
- Updated the required-sources implementation record with Schedule 6's own
  `required_sources_*` diagnostic names while preserving IDs, routing, copy,
  and execution behavior.
- Added regression coverage that preloads Schedule 5's retained Trip and Step
  names before inserting Schedule 6, protecting coexistence in an established
  development `presence.db`.

---

# 2026-08-12 - Consolidate Presence and onboarding ownership

- Created
  `45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/`
  with a start page, repository-wide ownership inventory, target ownership
  proposal, first-moves record, and prompt/response folders.
- Established the distinction between generic Presence execution machinery,
  onboarding-owned workflow meaning, specialist expertise, and disposable
  development/inspection tooling.
- Moved the required-sources Schedule, FDA and Contacts integration adapters,
  and their real provider composition from the experiment feature into the
  permanent `lib/essentials/onboarding/application/` home.
- Moved the corresponding focused tests under
  `test/essentials/onboarding/application/` and updated consumers/imports.
- Recorded the onboarding-specific Step classes, subtype tables, authority
  contracts, and repository reconstruction branches as unresolved boundary
  pressure requiring the later TestStep/Agent design; no such generalization
  was attempted.
- Updated feature-planning, onboarding/archive, Essentials, Presence boundary,
  and real-onboarding documentation for the clarified ownership model.
- Preserved production `OnboardingGate`, `presence.db`, routing, checkpoint,
  restart, trace, diagram, visualization, and source-readiness behavior.
- Verified the move with 65 focused Onboarding tests, 47 Presence/harness
  tests, 354 architecture tripwires, a clean analyzer, a successful macOS
  Debug build, formatting, checked Mermaid regeneration, and
  `git diff --check`.

---

# 2026-08-12 - Propose generic TestStep and opaque Agent resolution

- Added the design-only
  `04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md` to the Presence
  consolidation package.
- Evaluated numeric, stable-string, scoped/versioned, and hybrid persisted
  Agent identities; recommended a typed owner-qualified opaque string.
- Recommended one Boolean-only `TestAgent`, an immutable explicitly injected
  `TestAgentResolver`, and Schedule-scoped fail-fast resolution during
  executable definition reconstruction.
- Defined generic Test Agent/Test Step persistence, SQLite/runtime integrity
  boundaries, onboarding and future-consumer walkthroughs, migration of the
  two proven tests, and bounded failure semantics.
- Kept `OpenFdaSettingsStep` outside TestStep and recorded it as transitional
  debt rather than prematurely designing an Action Step.
- Updated the consolidation package navigation and corrected its Onboarding
  package cross-reference. No application source, tests, generated files,
  database, schema, or build configuration changed.

---

# 2026-08-12 - Implement generic Test Agent contracts

- Added the opaque `TestAgentId`, minimal Boolean `TestAgent` contract, and
  immutable explicit `TestAgentResolver` under `essentials/presence`.
- Added explicit duplicate-binding and missing-binding configuration failures;
  ordinary `false` results and Agent exceptions retain their original meaning.
- Recorded why explicit bindings and immutable construction make duplicate and
  order-dependent composition failures mechanically rejectable.
- Added focused identity, Agent, resolver, immutability, and architecture
  coverage while leaving the current FDA and Contacts execution paths intact.
- Added
  `05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md` and linked it from the
  consolidation start page and feature-addition index.
- Made no database, schema, generic TestStep, repository reconstruction,
  provider composition, or onboarding behavior change.

---

# 2026-08-12 - Add generic persisted Test grammar

- Advanced `presence.db` from schema version 6 to 7 and added the identity-only
  `test_agent_definitions` table plus the generic Boolean-routing
  `test_step_definitions` table.
- Added `test` to the permitted base Step discriminator without introducing
  executable generic `TestStep` reconstruction.
- Declared the stable Messages- and Contacts-readiness Agent identities and
  prepared identity-preserving generic rows from existing specialized
  definitions while retaining their active specialized base types.
- Applied the approved stop condition because current runtime reconstruction
  cannot consume `type = test`; documented the required atomic Slice 3 type
  cutover rather than introducing a half-runnable live database.
- Added file-backed migration evidence preserving Schedule, Trip, Step,
  occurrence, run, checkpoint, trace, and route identities, plus fresh-schema
  foreign-key and uniqueness coverage.
- Updated both plain-language Presence database guides and added
  `06-GENERIC-TESTSTEP-ADDITIVE-SCHEMA-IMPLEMENTATION.md` to the consolidation
  package navigation.
- Left runtime Agent resolution, current specialized Steps and authorities,
  providers, Schedule behavior, and production onboarding unchanged.

---

# 2026-08-12 - Activate the generic TestStep runtime

- Advanced `presence.db` from schema version 7 to 8 and atomically activated
  the generic `test` discriminator for the already-prepared FDA and Contacts
  test definitions without changing their IDs, routes, runs, checkpoints, or
  trace history.
- Added the generic `TestStep`, whose opaque `TestAgentId` is resolved through
  the repository's injected `TestAgentResolver`; Presence contains no active
  Messages- or Contacts-specific test reconstruction.
- Made Schedule definition reconstruction the fail-fast executable-definition
  boundary before run creation, replacement, or advancement so a missing Agent
  binding cannot create a run, append trace, or move a checkpoint.
- Retained the old FDA and Contacts subtype tables as frozen migration evidence;
  active reconstruction and subtype integrity ignore them.
- Added a deliberately temporary onboarding composition bridge that binds the
  two existing source-readiness specialists to their stable Agent identities;
  broader onboarding ownership cleanup remains Slice 4 work.
- Added focused runtime, migration-continuation, resolver, routing, no-mutation,
  exception, topology, and architecture coverage.
- Updated the Presence database teaching guides and created
  `07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md` as the Slice 3
  implementation record.
- Regenerated Drift/Riverpod outputs and the checked Schedule Mermaid artifact;
  verified 139 Presence, Onboarding, and harness tests, all 356 architecture
  tripwires, a clean analyzer, a successful macOS Debug build, formatting, and
  `git diff --check`.

---

# 2026-08-12 - Finalize Onboarding Test Agent composition

- Made Onboarding the single owner of the two persisted source-readiness Agent
  identities, their concrete Boolean Test Agents, and the explicit two-binding
  contribution consumed by application composition.
- Retired the redundant Messages and Contacts readiness-authority interfaces
  and their transitional providers/adapters; each Test Agent now delegates
  directly to the existing Messages or Address Book specialist boundary.
- Moved immutable resolver construction out of the onboarding Schedule builder
  and into the current Presence experiment application-composition provider.
- Preserved fresh development Contacts source substitution by selecting the
  concrete real/unavailable Agent on every evaluation.
- Kept generic Presence ignorant of Onboarding IDs, providers, and specialist
  meaning; `OpenFdaSettingsStep` remains the one explicitly deferred
  Onboarding-specific dependency.
- Created
  `08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md` and updated the
  consolidation package, feature index, and Onboarding ownership summary.
- Verified 145 Presence, Onboarding, and development-harness tests, all 359
  architecture tripwires, a clean analyzer, current generated outputs, checked
  Mermaid regeneration, a successful macOS Debug build, formatting, and
  `git diff --check`.

---

# 2026-08-12 - Consolidate Presence TestStep architecture

- Created
  `09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md` as the canonical post-Slice-4
  ownership, runtime, persistence, migration-evidence, and remaining-debt
  audit.
- Confirmed the active persisted path is generic from
  `step_definitions.type = test` through opaque `TestAgentId` resolution,
  `TestStep`, `Trip`, and `PresenceScheduler`; no workflow-specific Boolean
  branch remains in repository reconstruction.
- Confirmed Onboarding owns its Agent IDs, concrete Agents, binding
  contribution, workflow copy, and routes, while specialist source readers
  retain SQL, Address Book, and platform expertise.
- Classified the retained FDA and Contacts Boolean subtype tables as frozen
  migration evidence. Active repository code neither reads nor writes them;
  generated Drift APIs remain because mechanically removing their write
  surface would require an unjustified schema-level change.
- Replaced obsolete architecture checks centered on retired classes with
  positive dependency-boundary checks for generic Test reconstruction,
  specialist independence, application composition, frozen-table inactivity,
  and Scheduler/Trip ignorance.
- Updated the consolidation navigation, feature indexes, Essentials and
  Onboarding ownership guides, the canonical database index, and both
  plain-language `presence.db` guides. Marked the pre-generic inventory and
  first mechanical move as historical records without rewriting Slices 1-4.
- Confirmed `OpenFdaSettingsStep`, `FdaSettingsOpeningAuthority`, and their
  active subtype table are the sole remaining domain-specific Presence debt;
  no `ActionStep` or replacement abstraction was introduced.
- Made no schema, migration, runtime, Schedule topology, copy, production
  onboarding, provider, or generated-source change in this consolidation pass.
- Verified 145 Presence, Onboarding, migration, and development-harness tests;
  all 361 architecture tripwires; a clean analyzer; checked Mermaid
  regeneration; a successful macOS Debug build; formatting; and
  `git diff --check`. Code generation was not required.

---

# 2026-08-12 - Plan the next real Presence workflow concern

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md`
  from a code-first trace of the production Onboarding environment classifier,
  gate, source probes, user actions, import state, and graph readiness.
- Identified local Messages history sufficiency as the immediate concern after
  required-source readability and retained Onboarding as the owner of its
  meaning and threshold policy.
- Confirmed the factual assessment fits the completed generic Boolean
  `TestStep` and opaque Agent architecture, while the production `Import
  Anyway` path exposes one concrete two-destination user-choice requirement.
- Confirmed no second operation-shaped Step appeared and that `ActionStep` has
  not earned a design pass.
- Preserved `confirm_required_sources_readable` as an independently meaningful
  restart checkpoint separating source access from source-history sufficiency.
- Recorded the current `COUNT(*)` versus importable-message-count distinction
  as an explicit pre-implementation measurement-contract decision rather than
  silently changing production semantics.
- Updated the package start page and feature-addition indexes for
  discoverability. No application code, schema, generated source, production
  onboarding, Schedule topology, or runtime behavior changed.

---

# 2026-08-12 - Implement the Messages history sufficiency TestAgent

- Created
  `11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md` as the
  bounded implementation record for the next Onboarding factual specialist.
- Preserved production's `COUNT(*) FROM message` semantics and shared its
  existing 10/11 Onboarding policy with the new Agent without changing state,
  blocker, gate, or presentation behavior.
- Added the stable opaque identity
  `onboarding.messages-source-history-sufficient`, a routing-agnostic concrete
  Test Agent, and a narrow count reader over the existing read-only Onboarding
  database probe.
- Made unavailable counts fail truthfully instead of fabricating a Boolean and
  verified every evaluation performs a fresh factual read.
- Extended the Onboarding binding contribution and development resolver
  composition to three distinct Agents while leaving generic Presence
  contracts unchanged.
- Added focused threshold, real SQLite all-row count, missing-GUID, failure,
  fresh-read, provider, binding, resolver, parity, and architecture coverage.
- Updated the package navigation, feature indexes, and Onboarding ownership
  guide. The active required-sources Schedule, Mermaid topology, `presence.db`,
  production gate, copy, presentation, routing, checkpointing, and trace were
  unchanged.
- Verified 17 focused tests, 82 complete Onboarding tests, 61 complete Presence
  tests, 14 development-harness tests, all 362 architecture tripwires, clean
  analysis, provider regeneration, unchanged Schedule diagram regeneration, a
  successful macOS Debug build, formatting, and `git diff --check`.

---

# 2026-08-13 - Propose ChoiceStep and generic Presence presentation

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`
  as the bounded design for finite persisted user choices and generic Presence
  rendering.
- Established the mechanical routing distinction: configuration chooses for
  `FixedDestinationStep`, an Agent result chooses for `TestStep`, and human
  selection of an opaque configured option chooses for `ChoiceStep`.
- Recommended a durable Step-scoped `ChoiceValue`, ordered persisted options,
  required configured destinations, and a context-bound choice selection
  operation which receives only that value.
- Elevated the governing definition: `ChoiceStep` is distinguished by a human
  selecting one durable opaque value from two or more persisted options, not
  by whether those options appear as buttons, radio controls, menus, or lists.
- Made labels explicitly mutable presentation copy while values, destinations,
  and routing identity remain stable; Presence displays labels and resolves
  values without understanding either semantically.
- Preserved Trip-granular restart and checkpoint authority: no pending choice
  or current Step is persisted before the selected Trip destination commits.
- Kept Presence domain and execution free of Flutter and workflow meaning.
  Onboarding's workflow definition owns labels, opaque values, destinations,
  and Agent bindings; a permanent Presence presentation layer owns ordinary
  rendering for self-describing generic Step shapes.
- Distinguished generic Step mechanics already evidenced by the development
  host from its disposable trace, Mermaid, live-map, source-substitution,
  Run Again, and diagnostic controls.
- Retained a narrow workflow/specialist presentation escape hatch only for a
  Step whose UI requires domain expertise not expressed by generic grammar;
  `OpenFdaSettingsStep` remains the current unresolved example.
- Preserved stale-interaction rejection without exposing Step or Trip identity
  to presentation by binding the selection callback privately to the current
  ChoiceStep execution context.
- Rejected presentation-side routing, fake Test Agents, specialized sparse
  history Steps, generic interaction payloads, widget-owning Steps, and any
  inference that this requirement justifies `ActionStep`.
- Updated package navigation. No application code, schema, generated source,
  Schedule topology, production onboarding, or onboarding copy changed.

---

# 2026-08-13 - Implement the pure ChoiceStep domain contract

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md`
  as the bounded implementation record for ChoiceStep Slice 1.
- Added generic immutable `ChoiceValue` and `ChoiceOption` domain values plus
  a finite `ChoiceStep` which maps only configured opaque values to persisted
  Trip identities.
- Enforced two-or-more cardinality, Step-scoped value uniqueness, explicit
  unknown-value failure, preserved ordering, and defensive immutability while
  allowing duplicate labels and shared destinations.
- Kept Choice grammar free of UI, workflow meaning, Agents, providers,
  database infrastructure, and Onboarding dependencies.
- Left `presence.db`, repository reconstruction, Scheduler, Trip routing,
  presentation, active Schedule topology, and production onboarding unchanged.
- Added explicit fail-closed compatibility cases where the new sealed subtype
  made existing persistence and development-topology switches exhaustive;
  neither boundary gained Choice support.
- Added focused domain and architecture coverage and updated package indexes.
- Verified 19 focused Choice tests, 94 complete Presence/development-harness
  tests, 82 complete Onboarding tests, all 363 architecture tripwires, clean
  analysis, formatting, and `git diff --check`.

---

# 2026-08-13 - Persist the generic ChoiceStep grammar

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md`
  as the bounded implementation record for ChoiceStep Slice 2.
- Advanced `presence.db` additively to schema version 9 with a Choice subtype
  marker and ordered option rows carrying only opaque value, label, position,
  and required Trip destination.
- Extended the definition writer and repository reconstruction path while
  preserving the existing exactly-one-active-subtype invariant, domain-owned
  minimum cardinality, terminal placement, and Schedule-local destination
  closure.
- Added file-backed v8-to-v9 migration evidence proving existing Schedule,
  Trip, Tell Step, run checkpoint, and append-only trace preservation plus
  active foreign-key enforcement for the new tables.
- Kept Scheduler, Trip runtime, development topology, presentation, active
  Onboarding topology, selected-choice state, and execution trace behavior
  unchanged.
- Updated the package indexes, Slice 1 cross-reference, and plain-English
  Presence database guide to distinguish persisted Choice grammar from later
  runtime support.
- Verified 34 focused Choice domain/persistence/migration tests, all 63
  Presence infrastructure tests, all 109 Presence/development-harness tests,
  all 82 Onboarding tests, all 364 architecture tripwires, clean analysis,
  regenerated Drift output, formatting, and `git diff --check`.

---

# 2026-08-13 - Complete the current terminal ChoiceStep at runtime

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md`
  as the bounded implementation record for ChoiceStep Slice 3.
- Added one Choice-specific, context-bound runtime callable through which a
  caller reports only the selected opaque `ChoiceValue`.
- Kept current Step, Trip, occurrence, destination, and Schedule geometry
  private to Presence; no general Step-input or interaction-token framework
  was introduced.
- Reused the existing Trip result, repository checkpoint, restart authority,
  and universal execution-trace path rather than creating Choice-specific
  routing or persistence.
- Added private activation and exact-current-Step checks so an interaction can
  complete only the ChoiceStep for which it was issued, including when a later
  ChoiceStep uses the same opaque value.
- Added fail-closed handling for unknown values, autonomous Choice completion,
  nonterminal ChoiceSteps, stale interactions, and rapid repeated selection.
- Left Flutter presentation, active Onboarding topology, selected-value
  persistence, current-Step persistence, Choice trace fields, and development
  topology visualization outside this slice.
- Updated package indexes and the plain-English Presence database guide with
  the runtime boundary and unchanged Trip-granular restart semantics.
- Verified 12 focused Choice runtime tests, 46 combined Choice domain,
  persistence, migration, and runtime tests, all 121 Presence/development-
  harness tests, all 82 Onboarding tests, all 365 architecture tripwires,
  clean analysis, formatting, and `git diff --check`.

---

# 2026-08-13 - Render generic Presence Step shapes

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/16-GENERIC-PRESENCE-PRESENTATION-IMPLEMENTATION.md`
  as the bounded implementation record for ChoiceStep Slice 4.
- Added a permanent Presence application projection that consumes full domain
  Steps and emits only presentation-safe generic shapes and bound operations.
- Added one permanent exhaustive presenter for Tell, Test, Fixed Destination,
  and finite Choice mechanics, with an explicit specialist marker for the
  transitional FDA Settings Step.
- Projected each Choice option to ordered persisted label plus opaque
  `ChoiceValue`; no destination, Step identity, Trip identity, occurrence, or
  Schedule geometry reaches Flutter.
- Rendered finite choices as ordinary ordered macOS buttons without persisted
  styling metadata or semantic interpretation of opaque values.
- Added in-flight disabling as UX feedback while preserving Slice 3's runtime
  activation and repeated-selection checks as correctness authority.
- Kept source substitution, Mermaid, live topology, execution trace,
  diagnostics, Run Again, and FDA-specific copy/behavior in the development
  harness.
- Relocated the already-proven minimal Presence presentation tokens from the
  disposable host to the permanent Presence presentation home.
- Left the active Onboarding Schedule, `presence.db`, checkpointing, trace,
  restart semantics, and all workflow copy unchanged.
- Updated package indexes and added a positive architecture tripwire protecting
  the destination-free, workflow-agnostic presentation boundary.
- Verified 12 focused projection/widget tests, 58 combined Choice tests, all
  133 Presence/development-harness tests, all 82 Onboarding tests, all 366
  architecture tripwires, clean analysis, formatting, and `git diff --check`.

---

# 2026-08-13 - Use generic ChoiceStep in active Onboarding

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/17-ONBOARDING-MESSAGES-HISTORY-CHOICE-WORKFLOW-IMPLEMENTATION.md`
  as the implementation record for ChoiceStep Slice 5.
- Extended the active required-sources Schedule with a Messages-history
  sufficiency Test Trip and a sparse-history guidance Trip containing two Tell
  Steps and one generic terminal ChoiceStep.
- Persisted the exact opaque Choice values `recheck` and `import_anyway` with
  their labels and destination geometry in the Schedule definition; no
  workflow-specific presentation or runtime translation was introduced.
- Routed Re-check back through the factual TestAgent so each attempt performs
  a fresh `COUNT(*) FROM message` evaluation, while Import Anyway converges on
  the existing required-sources confirmation Trip.
- Added a transactional, fail-closed definition-extension path that preserves
  existing run checkpoints and trace history while retaining stable
  occurrence-to-Trip identity.
- Extended the generic topology projector to render persisted Choice options
  as ordinary explicit edges and regenerated the checked Onboarding Schedule
  artifact.
- Updated the package indexes, release metadata, and plain-English Presence
  database guide to record active Choice usage and distinguish additive
  definition evolution from schema migration.
- Documented that a real sparse-source manual run remains blocked on a safe,
  development-only Messages-source substitution; no real `chat.db` data was
  changed for this slice.
- Verified all 230 Presence, development-harness, and Onboarding tests, all 366
  architecture tripwires, clean analysis, formatting, `git diff --check`, and
  a successful debug macOS build.

---

# 2026-08-13 - Integrate generic Presence runner into production Onboarding

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/18-PRODUCTION-GENERIC-PRESENCE-RUNNER-INTEGRATION.md`
  as the production-integration implementation record.
- Added the permanent, workflow-agnostic `PresenceRunner` for generic Tell,
  Test, Fixed Destination, and Choice execution/presentation.
- Added the production Onboarding composition provider and blocking host for
  the real required-source Schedule and real specialist TestAgent bindings.
- Preserved `OpenFdaSettingsStep` as an explicit Onboarding specialist and
  reused the established FDA presentation without introducing an Action Step.
- Kept import, graph construction, recovery, completion, and reimport under the
  existing `OnboardingGate` and operational overlay.
- Added production-host tests for sufficient history, sparse-history Re-check,
  Import Anyway, and the FDA specialist path, plus permanent-runner tests for
  generic and autonomous Step behavior.
- Added architecture tripwires preventing workflow-value translation,
  development-harness leakage, and Onboarding semantics in permanent Presence.
- Updated the package indexes, Onboarding gate guide, release notes, and app
  version to `0.2.20+38`.
- Verified all 237 Presence, development-harness, and Onboarding tests, all 369
  architecture tripwires, clean analysis, formatting, `git diff --check`, and
  a successful debug macOS build.

---

# 2026-08-13 - Audit the post-readiness Onboarding handoff

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/19-POST-READINESS-ONBOARDING-HANDOFF-AUDIT.md`
  as the code-grounded audit of the production boundary after required-source
  Presence completion.
- Established that Presence completion checkpoints the final Trip and removes
  only its presentation; `OnboardingGate` observes no completion event and
  continues to derive its independent state from `OnboardingEnvironmentReport`.
- Documented that import does not start automatically. The existing
  Environment Readiness panel invokes `OnboardingGate.startImportAndGraphBuild`
  only after a human presses the import action.
- Identified the concrete sparse-history handoff defect: the route reached
  through the persisted `import_anyway` option completes Presence, but the
  unchanged sparse report reveals a legacy source-warning panel with no import
  action.
- Inventoried source import, graph projection, reset, progress, failure,
  recovery, completion, restart, and attachment-archive ownership using current
  code as authority where older documentation was stale.
- Recommended one bounded next slice: derive the existing import-readiness
  handoff from the completed required-sources Schedule without adding schema,
  another acceptance flag, a new import screen, or a generic operation Step.
- Concluded that `ActionStep` remains unearned because FDA Settings opening and
  initial graph construction have materially different mutation, progress,
  restart, recovery, and result semantics.
- Updated the package start page and Feature Addition index. No application
  code, schema, workflow definition, run state, FDA behavior, import behavior,
  recovery behavior, or presentation was changed.

---

# 2026-08-13 - Repair durable accepted-readiness import handoff

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/20-DURABLE-ACCEPTED-READINESS-IMPORT-HANDOFF-IMPLEMENTATION.md`
  as the implementation record for the post-Presence Onboarding handoff.
- Documented the separate authorities of current environment facts and durable
  required-sources Schedule completion, and the Environment Readiness surface
  that composes them.
- Recorded that sparse accepted sources now expose the existing **Import My
  Messages** action while sparse unaccepted sources remain at **Re-check**.
- Recorded restart reconciliation from the existing Schedule run checkpoint,
  with no trace lookup, Choice-value recovery, or duplicate acceptance flag.
- Updated the package start page, Feature Addition indexes, Onboarding gate
  guide, release notes, and app version to `0.2.21+39`.
- Preserved historical implementation records and left environment facts,
  Schedule geometry, Presence completion, FDA, import, graph build, recovery,
  and failure semantics unchanged.

---

# 2026-08-13 - Audit initial import and Conversation Graph build lifecycle

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md`
  as the code-grounded audit of the production operation beginning with
  **Import My Messages**.
- Traced the action through Environment Readiness, `OnboardingGate`, archive
  mutation admission, destructive derived-data reset, the controller, and all
  17 source-import and graph-projection stages.
- Distinguished one outer admitted Gate action from the nested, single
  `ConversationGraphBuildController.runOnce()` data-construction lifecycle.
- Inventoried live, completion-only, durable, and ephemeral progress evidence;
  documented that current APIs support calm coarse progress but not truthful
  stage names, percentage, remaining time, resume, or cancellation.
- Established that **Abort Import** neither signals nor stops the active build
  and that its attempted reset is denied by the active mutation owner, making
  the control materially misleading.
- Documented caught failure, abrupt termination, partial-store, recovery, and
  restart semantics, including the limits of import batches and readiness
  probes as durable evidence.
- Recorded the nested mutation-policy caveat: the outer `onboardingImport`
  policy is not currently a superset of nested `messageDataReset` reopen and
  checkpoint policy.
- Recommended exactly one next implementation slice: remove the false Abort
  affordance while preserving all current operation and restart behavior.
- Confirmed that a generic operation Step remains unearned and that Presence
  may eventually own the surrounding human sequence but not the destructive
  operation.
- Updated the package start page and Feature Addition index. No application
  code, UI, import logic, recovery, persistence, schema, or Presence behavior
  was changed.

---

# 2026-08-14 - Remove misleading Abort Import affordance

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/22-REMOVE-MISLEADING-ABORT-IMPORT-IMPLEMENTATION.md`
  as the implementation record for Audit 21's single recommended correction.
- Removed **Abort Import** from active first-run progress without introducing a
  replacement Cancel, Stop, cleanup, return, or retry command.
- Removed the now-unused `OnboardingOverlayActions.abortImport()` and
  `OnboardingGate.abortImport()` forwarding path after repository-wide caller
  search confirmed it was presentation-only.
- Preserved `MessageDataResetService` and all legitimate first-run preparation,
  reimport, explicit reset, failure, and automatic-recovery uses.
- Added focused production-overlay tests proving first-run and reimport progress
  remain visible and explicitly non-cancellable.
- Preserved mutation admission, reset, controller, orchestrator, source import,
  graph projection, failure persistence, recovery, restart, completion,
  Presence, and schema behavior.
- Updated the package start page and Feature Addition index.
- Verified 28 focused tests, all 113 Onboarding and Environment Readiness
  tests, all 372 architecture tripwires, clean analysis and formatting,
  `git diff --check`, and a successful debug macOS build without launching the
  app or accessing the production archive.

---

# 2026-08-14 - Audit production import progress surface

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md`
  as a code-grounded inventory of the first-run, direct-reimport, completion,
  failure, and recovery presentations.
- Mapped every active-progress, completion, and failure statement to its
  supporting operational fact and identified coarse truth, diagnostic detail,
  and unsupported implications.
- Documented that `importing` and `buildingGraph` are visually shared staging
  states rather than two real operations, and that production Reset Message
  Data currently returns through the ordinary import gate instead of calling
  the otherwise implemented direct-reimport API.
- Inventoried all currently available live facts and concluded that process-
  local elapsed time is technically supportable but not yet useful enough to
  add.
- Established the narrow truthful guidance that MessageLens must remain open
  while work runs, while the human may use other applications.
- Rejected live stage telemetry, percentage, ETA, resume, and cancellation as
  unsupported or unearned by current human need.
- Selected **minimal calm** as the best presentation philosophy and recommended
  exactly one next slice: replace the repetitive active-progress paragraph
  with concise keep-open and use-other-apps guidance.
- Updated the package start page and Feature Addition index. No application
  code, copy in code, Gate state, telemetry, persistence, operation lifecycle,
  or Presence behavior was changed.

---

# 2026-08-14 - Add truthful keep-open progress guidance

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/24-TRUTHFUL-KEEP-OPEN-PROGRESS-GUIDANCE-IMPLEMENTATION.md`
  as the implementation record for Audit 23's single recommended slice.
- Replaced the repetitive first-run/direct-reimport progress paragraph with
  shared guidance to keep MessageLens open while confirming that other
  applications may be used in the meantime.
- Preserved controller-derived coarse headlines, the indeterminate activity
  indicator, layout, completion, failure/recovery, and explicit
  non-cancellability.
- Expanded production-overlay tests to prove the shared guidance, truthful
  first-run/reimport headings, indeterminate progress, absence of old copy,
  absence of unsupported stage/percentage/ETA/resume claims, and absence of
  cancellation controls.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.22+40`.
- No Gate, archive mutation, reset, controller, orchestrator, restart,
  persistence, Presence, or schema behavior changed.
- Verified both focused progress cases, all 113 Onboarding and Environment
  Readiness tests, all 372 architecture tripwires, clean analysis and targeted
  formatting, `git diff --check`, and a successful debug macOS build without
  launching the app.

---

# 2026-08-14 - Audit pre-overlay import-start acknowledgement

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md`
  as a code-grounded trace from **Import My Messages** through admission, the
  current FDA-readiness guard, destructive reset, Gate staging, and the first
  progress frame.
- Established that the meaningful invisible period is reset: the Environment
  Readiness surface and enabled import action remain unchanged until reset has
  completed.
- Confirmed that button/action state does not acknowledge or serialize the
  request; mutation exclusion currently comes from the coordinator, followed
  later by the Gate guard and controller in-flight reuse.
- Documented admission denial, FDA-false, and reset-throw boundaries and the
  unwind requirements any earlier loading presentation must preserve.
- Corrected the architectural description of the current FDA safety check: it
  reads a cached keep-alive readiness provider and does not force a fresh source
  probe in this path.
- Compared button-local activity, the existing full overlay, and a separate
  acknowledgement state. Recommended only the existing Gate-owned overlay.
- Recommended exactly one next slice: publish the existing `importing` /
  **Preparing setup…** state after admission and the FDA guard but before reset,
  keep preparation copy independent of stale controller terminal state, and
  clear the ephemeral override if reset throws.
- Kept direct reimport, production Reset Message Data, FDA freshness, reset
  failure redesign, nested mutation policy, telemetry, cancellation,
  persistence, and Presence outside the recommended slice.
- Updated the package start page and Feature Addition index. No application
  code, tests, Gate ordering, reset, mutation policy, FDA behavior, controller,
  persistence, or Presence was changed.

---

# 2026-08-14 - Codify attachment preservation as a hard invariant

- Created
  `25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md` as the
  canonical statement that archived attachment payloads are MessageLens
  preservation data and never ordinary reset, reimport, recovery, migration,
  or cleanup targets.
- Established the three explicit data categories: authoritative external
  sources that are never our deletion target, rebuildable MessageLens derived
  stores, and MessageLens preservation data that must be treated like gold.
- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`
  as the code-grounded implementation and audit record.
- Audited first-run reset, direct reimport, automatic recovery, explicit
  message-data reset, development reset, adoption/restore cleanup, migration,
  test cleanup, and the dormant specialist archive-clearing API.
- Confirmed that ordinary reset paths use a private basename allow-list for
  four rebuildable database files and their SQLite sidecars; they do not walk
  directories or target the attachment archive, overlay, Presence, or
  preferences data.
- Recorded `ArchiveSettings.clearArchive()` as a dormant specialist destructive
  capability with no active caller, not as permission for ordinary reset or
  recovery code to delete preservation data.
- Added a production-shaped filesystem regression proving derived databases
  are removed while a nested binary archived payload and durable sibling stores
  remain byte-for-byte unchanged.
- Added an architecture tripwire that fixes the reset allow-list to the four
  approved derived-store categories and rejects archive references, broad
  directory traversal, and recursive deletion in the reset boundary.
- Cross-referenced the invariant from project database/data-location guidance,
  the Onboarding and Archive package, pipeline invariants, feature-package
  navigation, and `AGENTS.md`.
- Verified the focused filesystem preservation tests, 35 focused archive and
  onboarding tests, all 373 architecture tripwires, clean Flutter analysis,
  targeted formatting, and `git diff --check`.
- No runtime behavior, database schema, archive payload, source database,
  production data, reset ordering, recovery behavior, migration behavior, or
  Presence behavior was changed.

---

# 2026-08-14 - Show first-run preparation during derived-data reset

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md`
  as the implementation record for Audit 25's single recommended correction.
- Moved the existing first-run `OnboardingStatus.importing` transition and
  painted-frame wait after mutation admission and the current FDA guard but
  before derived-data reset.
- Reused the existing **Preparing setup…** blocking progress surface while
  reset is pending; no new status, component, provider, copy, or persistence
  was introduced.
- Made first-run preparation presentation authoritative over stale terminal
  graph-controller state, preserving an indeterminate indicator and preventing
  old success or failure output from mislabelling a new attempt.
- Added reset-failure unwind that clears preparation, restores the existing
  readiness presentation, invalidates the environment report, and preserves
  the original thrown error and stack trace.
- Added focused coverage for pending reset, visible preparation, controller
  non-start, duplicate starts, FDA false, reset failure, stale controller
  success/failure, transition to active graph build, and ordinary completion.
- Preserved mutation admission, FDA provider behavior, reset semantics,
  attachment preservation, controller lifecycle, import/projection,
  persistence, automatic recovery, direct reimport, Reset Message Data,
  cancellation, and Presence behavior.
- Updated package navigation, the Feature Addition index, changelog, and app
  version to `0.2.23+41`.
- Verified 20 focused tests, all 121 Onboarding, Environment Readiness, and
  graph-controller tests, all 373 architecture tripwires, clean analysis and
  formatting, `git diff --check`, and a successful debug macOS build without
  launching the app or accessing the production archive.

---

# 2026-08-14 - Audit the initial setup completion surface

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md`
  as a code-grounded audit of the successful initial import and Conversation
  Graph completion experience.
- Traced controller success through the Gate's process-local `complete`
  override, report-driven completion overlay, **Get Started** dismissal, and
  database-derived ordinary startup after restart.
- Recorded that **Get Started** commits no data and is a deliberate human
  handoff rather than an operational completion requirement.
- Inventoried and classified the current success icon, **Import Complete!**
  heading, absent explanatory copy, three conditional report metrics, and the
  **Get Started** / **Done** action distinction.
- Defined the exact meanings of **Imported**, **Projected**, and **Text
  enriched**, and concluded that their expected differences expose pipeline
  architecture without giving an ordinary human useful reassurance.
- Recommended calm human completion as the product philosophy and concluded
  that primary completion metrics should be removed rather than replaced by an
  unearned aggregate.
- Established a completion truth budget that permits readiness and local
  browsing-data claims while prohibiting implications of complete or permanent
  attachment archival.
- Recommended exactly one future implementation slice: replace the diagnostic
  primary completion body with one shared calm readiness handoff while
  retaining the existing success icon and context-appropriate action.
- Updated the package start page and Feature Addition index. No application
  code, operation lifecycle, completion persistence, Presence behavior,
  failure/recovery behavior, attachment archival behavior, or metrics were
  changed.

---

# 2026-08-14 - Implement the calm initial setup completion handoff

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/29-CALM-INITIAL-SETUP-COMPLETION-HANDOFF-IMPLEMENTATION.md`
  as the implementation record for Audit 28's single recommended completion
  correction.
- Replaced the production **Import Complete!** heading with **MessageLens is
  ready** and added the bounded supporting sentence **Your local browsing data
  is prepared.**
- Removed **Imported**, **Projected**, and **Text enriched** chips only from the
  ordinary production completion surface. `ConversationGraphBuildReport`, its
  counters and timings, logging, and the development Onboarding diagnostics
  remain unchanged.
- Retained the themed success icon, shared first-run/reimport completion
  component, and existing **Get Started** / **Done** action distinction.
- Added focused successful-report widget coverage proving the calm copy, icon,
  action labels, absent primary metrics, absent archival-completeness claims,
  and unchanged dismissal dispatch.
- Extended the real Gate lifecycle coverage to prove both completion actions
  still return the Gate to `notNeeded` and select the Messages sidebar.
- Preserved process-local completion, database-derived restart readiness,
  build/report semantics, failure/recovery, Presence, reimport operations, and
  attachment archival behavior.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.24+42`.
- Verified 22 focused completion and Gate tests, all 110 Onboarding tests, all
  3 Conversation Graph build-controller tests, all 373 architecture tripwires,
  clean Flutter analysis and formatting, `git diff --check`, and a successful
  debug macOS build without launching the app or accessing the production
  archive.

---

# 2026-08-14 - Audit initial setup failure and recovery presentation

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md`
  as a code-grounded audit of every materially different setup failure,
  abrupt-termination, retry, and automatic-recovery path.
- Established that mutation-admission and reset failures sit outside the
  controller catch, while service resolution, all import/enrichment/join and
  graph-projection stages, and post-build version publication currently share
  one caught controller lifecycle.
- Verified that every actively caught controller failure is persisted through
  the coarse graph-projection key, so that record does not prove source import
  completed or identify the failed stage.
- Recorded that raw `ConversationGraphBuildState.lastError` can become the
  active-progress headline during failure handoff and can remain there
  indefinitely if durable failure recording fails.
- Inventoried the exact import-failure, graph-failure, automatic-recovery, and
  report-export content, including timestamps, raw errors, technical reset
  reasons, retry labels, and support-bundle behavior.
- Identified unsupported copy that infers completed import, graph-specific
  failure, or a previous-launch origin from evidence that proves none of those
  things.
- Confirmed that retry always starts with allow-listed derived-store reset and
  reruns the complete build rather than resuming, while preserving overlay data,
  preferences, and archived attachment payloads.
- Recommended calm human truth with secondary diagnostics as the long-term
  hierarchy and concluded that no richer failure taxonomy is needed for a
  truthful primary surface.
- Recommended exactly one next implementation slice: replace the transient raw
  controller-error headline with a fixed phase-neutral human statement while
  preserving all diagnostic evidence and operational behavior.
- Updated the package start page and Feature Addition index. No application
  code, tests, schema, failure mechanics, retry, recovery, reset, attachment
  archival, mutation coordination, or Presence behavior was changed.

---

# 2026-08-14 - Bound the active-progress failure headline

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md`
  as the implementation record for Audit 30's single recommended correction.
- Replaced raw `ConversationGraphBuildState.lastError` presentation during the
  controller-to-Gate handoff with **MessageLens couldn't finish preparing
  browsing data.**
- Applied the same phase-neutral headline to first-run setup and direct
  reimport while preserving **Preparing setup…** precedence during fresh
  pre-reset work.
- Preserved raw controller error state, logging, persisted failure records,
  support reporting, stable failure surfaces, retry, recovery, and reset.
- Added focused presentation and controller coverage for hidden technical
  errors, retained diagnostic evidence, both active Gate modes, preparation
  precedence, and unchanged running/success presentation.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.25+43`.

---

# 2026-08-14 - Make stable setup failure copy phase-neutral

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md`
  as the implementation record for Audit 30's next bounded correction.
- Replaced **Import Attempt Failed** and **Messages Could Not Be Prepared**
  with one shared primary heading: **MessageLens couldn't finish setup**.
- Replaced both phase-specific explanatory paragraphs with **MessageLens
  couldn't finish preparing your browsing data. You can try again.**
- Preserved separate persistence buckets, branch-specific retry labels and
  dispatch, support-report export, raw diagnostic notes, timestamps,
  environment summaries, retry mechanics, recovery, reset, and Presence.
- Added focused widget coverage proving shared primary copy, absent unsupported
  phase claims, retained raw diagnostics, unchanged retry dispatch, and
  functional support-report export.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.26+44`.

---

# 2026-08-14 - Audit stable failure diagnostic information hierarchy

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md`
  as a code-grounded inventory and classification of every secondary item on
  the stable initial-setup failure surface.
- Established **calm primary + secondary support** as the preferred hierarchy:
  ordinary reading order should retain retry and visible support access while
  raw errors, timestamps, environment probes, and internal store facts remain
  in support/developer diagnostics.
- Confirmed that a local **Technical Details** disclosure is not yet earned
  because no supported user decision depends on the details and the support
  bundle already preserves their diagnostic value.
- Recorded that current previous-launch and inferred failed-phase statements
  are unsupported by persisted timestamp and probe evidence.
- Classified the existing overlay overflow as primarily an information-density
  and unbounded-diagnostic problem, not yet evidence for scrolling, smaller
  typography, reduced spacing, or expanded card geometry.
- Recommended exactly one next implementation slice: remove the **What to
  check** card from ordinary `importFailed` and `graphProjectionFailed`
  presentation while preserving persistence, report export, Environment
  Summary, actions, and operation behavior.
- Recorded the automatic-recovery reason panel and broad “clearing that data”
  wording as a later separate hierarchy concern governed by the attachment-
  preservation boundary.
- Updated the package start page and Feature Addition index. No application
  code, tests, schema, persistence, retry, recovery, reset, support bundle,
  attachment archive, or Presence behavior was changed.

---

# 2026-08-14 - Remove What to check from stable setup failures

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md`
  as the bounded implementation record for Audit 33's single recommendation.
- Removed branch-specific notes from ordinary `importFailed` and
  `graphProjectionFailed` presentation, eliminating the complete **What to
  check** card from those two stable failure surfaces.
- Removed raw exception text, timestamps, unsupported previous-launch and
  failed-phase claims, internal store notes, clean-pass wording, and duplicate
  report guidance from ordinary reading order without adding a Technical
  Details disclosure.
- Preserved failure persistence, environment probes, logs, database health,
  support-report headers and bundles, Environment Summary, retry labels and
  dispatch, report export, transport caption, automatic recovery, reset, and
  attachment preservation.
- Removed dead stable-failure note and timestamp formatting helpers from the
  presentation file; other Onboarding states retain the shared advice card.
- Restored the focused stable-failure widget tests to default typography by
  removing the prior test-only reduced text scale. Both branches now fit the
  unchanged 920-pixel card envelope without overflow or geometry changes.
- Strengthened support-report coverage for retained raw import/graph errors and
  recorded timestamp evidence.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.27+45`.

---

# 2026-08-14 - Remove Environment Summary from stable setup failures

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md`
  as the bounded implementation record for the next Audit 33 correction.
- Removed **Environment summary** only from ordinary `importFailed` and
  `graphProjectionFailed` presentation, including all five summary rows.
- Preserved the settled primary copy, branch-specific retry actions, visible
  support action, email/Finder transport caption, automatic recovery, reset,
  and attachment preservation.
- Preserved all environment probes, raw failures, timestamps, logs, and
  support-report evidence; the presentation change does not alter report data
  or diagnostic authority.
- Added focused coverage proving stable-failure suppression and retention on a
  non-failure readiness surface at default typography without geometry changes.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.28+46`.

---

# 2026-08-14 - Remove support transport caption from stable setup failures

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/36-REMOVE-SUPPORT-TRANSPORT-CAPTION-STABLE-FAILURE-IMPLEMENTATION.md`
  as the bounded implementation record for Audit 33's final stable-failure
  reading-order correction.
- Removed the pre-action explanation of email attachment and Finder fallback
  from ordinary `importFailed` and `graphProjectionFailed` presentation.
- Preserved **Send Report To Developer**, support-bundle generation and
  contents, recipient and transport behavior, and existing snackbar feedback.
- Added direct widget coverage for email-draft success, Finder fallback, and
  report-generation failure feedback using the production presentation
  callback.
- Preserved the settled primary copy, branch-specific retry actions, earlier
  **What to check** and **Environment summary** removals, diagnostics,
  recovery, reset, attachment preservation, and Presence.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.29+47`.

---

# 2026-08-14 - Audit automatic recovery presentation

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/37-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md`
  as a code-grounded trace of the automatic derived-store recovery lifecycle,
  visible surface, success, reset failure, mutation denial, and abrupt-
  termination behavior.
- Established that recovery removes only allow-listed rebuildable MessageLens
  browsing stores, does not alter authoritative Apple sources or preservation
  data, and returns to environment re-evaluation rather than automatically
  rerunning or resuming setup.
- Recorded that **previous/earlier setup attempt** is not a proven process-
  history claim and that **local data** / **clearing that data** is overbroad
  against the attachment-preservation boundary.
- Recommended calm, non-interactive recovery with an indeterminate activity
  indicator; no percentage, stage, cancellation, resume, or user action is
  supported by current mechanics.
- Determined that `resetAppDatabasesReason` is diagnostic implementation detail
  that changes no human action and should leave ordinary recovery reading order
  while remaining in the environment report, Gate/reset logs, development
  diagnostics, probes, and support evidence.
- Recommended exactly one next implementation slice: remove the bordered reset-
  reason card from the production recovery widget without changing heading,
  body, operation behavior, persistence, reset policy, diagnostics, attachment
  preservation, or Presence.
- Updated the package start page and Feature Addition index. No application
  code, tests, schema, persistence, recovery mechanics, reset behavior,
  attachment archive, or Presence behavior was changed.

---

# 2026-08-14 - Remove automatic-recovery diagnostic reason

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md`
  as the bounded implementation record for Audit 37's single recommendation.
- Removed the bordered `resetAppDatabasesReason` card from the ordinary
  production `recoveringFailedAttempt` surface.
- Preserved the existing recovery heading, body, icon, indeterminate activity
  indicator, and non-interactive lifecycle without adding replacement details
  or controls.
- Preserved reason generation, environment classification, Gate and reset
  logs, development-panel diagnostics, support evidence, reset semantics,
  mutation admission, and the attachment-preservation allow-list.
- Added focused default-typography coverage proving a non-null reason remains
  absent from production recovery while the recovery message and activity
  indicator remain visible, no controls appear, and the layout reports no
  exception.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.31+49`.

---

# 2026-08-15 - Use calm, truthful automatic-recovery copy

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/39-CALM-TRUTHFUL-AUTOMATIC-RECOVERY-COPY-IMPLEMENTATION.md`
  as the bounded implementation record for Audit 37's recovery-copy
  correction.
- Replaced **Cleaning Up A Previous Setup Attempt** with **Preparing
  MessageLens to try again**.
- Replaced unsupported prior-attempt, broad local-data, deletion, and automatic-
  restart language with a precise statement that MessageLens found incomplete
  browsing data, is preparing another setup attempt, and the human should wait.
- Preserved the recovery icon, indeterminate activity indicator, non-
  interactive surface, diagnostic-reason removal, classification, logs,
  development diagnostics, recovery mechanics, reset semantics, and attachment-
  preservation boundary.
- Strengthened focused coverage against historical, destructive, restart, and
  internal-architecture language while retaining default-typography layout and
  no-control assertions.
- Updated the package start page, Feature Addition index, changelog, and app
  version to `0.2.32+50`.

---

# 2026-08-15 - Audit recovery and pre-build failure state

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md`
  because document number 40 is occupied by the automatic-recovery
  presentation audit.
- Traced first-run admission, FDA, reset, automatic recovery, direct reimport,
  and explicit Settings reset through the current Gate, mutation coordinator,
  reset service, persistence, environment classification, and presentation
  paths.
- Distinguished four operational truths: prerequisite blocking, busy denial,
  other pre-action admission failure, and admitted reset failure. Kept settled
  controller failure as a separate later boundary.
- Verified that admitted reset failure can leave partially changed derived
  stores, while filesystem probes remain the correct durable restart authority
  and existing failure records do not truthfully prove reset failure.
- Verified that the reset allow-list remains confined to rebuildable
  MessageLens derived stores and cannot target authoritative Apple sources,
  source attachment payloads, archived attachment payloads, overlay intent,
  Presence state, or preferences.
- Recommended exactly one next implementation slice: a process-local
  Onboarding preparation-failure state for first-run reset failure, automatic-
  recovery reset failure, and non-contention automatic-recovery admission
  failure, without new persistence, reset mechanics, or attachment policy.
- Updated the package start page and Feature Addition index. Corrected current-
  facing references to the renumbered
  `40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md` while preserving historical log
  entries.
- No application code, tests, schemas, Gate behavior, persistence, mutation
  coordination, reset behavior, Presence behavior, or attachment behavior was
  changed.

---

# 2026-08-15 - Implement stable process-local onboarding retry

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md`
  as the implementation record for Audit 41's bounded recommendation.
- Added the process-local `OnboardingStatus.preparationFailed` state for
  admitted first-run reset failure, admitted automatic-recovery reset failure,
  and non-contention automatic-recovery admission failure.
- Reused the existing setup entry point for **Try Again**, retained the existing
  support-report path, and kept the previous failure visible until a new attempt
  is admitted.
- Kept FDA blocking, ordinary mutation contention, controller-owned persisted
  failure, Settings reset, Presence, and attachment-preservation behavior
  unchanged.
- Recorded that automatic recovery remains suppressed while the process-local
  failure is visible; deliberate refresh or retry reopens current environment
  evaluation.
- Updated the canonical Onboarding Gate documentation, package start page, and
  Feature Addition index. Bumped the application version to `0.2.33+51` and
  added the matching changelog entry.

---

# 2026-08-15 - Audit automatic-recovery mutation-busy deferral

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md`.
- Traced the exact Gate, post-frame callback, suppression, coordinator-denial,
  self-invalidation, and unchanged-environment-report path and established that
  it forms a real retry cycle while the Gate remains watched.
- Distinguished ordinary mutation contention from non-contention admission
  error and admitted reset failure. Busy denial remains outside
  `preparationFailed` because recovery never starts and changes no files.
- Inventoried current mutation owners and verified that their feature-specific
  completion effects differ, while the coordinator's final locked-to-idle
  publication is the universal fact-change seam.
- Recommended one bounded Gate-owned correction: defer process-locally while
  busy, observe coordinator release, obtain fresh environment truth, and retry
  only if recovery remains warranted. Recovery presentation should begin only
  after admission.
- Rejected timers, polling, backoff, queued work, durable deferral state, a new
  human-visible status, busy UI, coordinator scheduling, first-run expansion,
  policy changes, reset changes, and attachment-policy changes.
- Updated the package start page and Feature Addition index. No application
  code, tests, schemas, mutation behavior, reset behavior, Presence behavior,
  or attachment behavior was changed.

---

# 2026-08-15 - Implement automatic-recovery mutation-busy deferral

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/52-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-IMPLEMENTATION.md`.
- Replaced the automatic-recovery denial/self-invalidation cycle with one
  Gate-owned process-local deferral enum that distinguishes waiting for
  mutation release from waiting for completed fresh environment truth.
- Added a lifecycle-bound listener selecting only the coordinator's `isLocked`
  fact. Locked-to-idle release now invalidates Environment Readiness, and the
  Gate rejects Riverpod's retained value while that provider is refreshing.
- Moved `recoveringFailedAttempt` publication inside the admitted recovery
  action, so denied work remains silent and never exposes recovery progress.
- Preserved `preparationFailed` for non-contention admission errors and admitted
  reset failures; ordinary contention remains non-failure.
- Added deterministic Gate coverage for no repeated denial, release-driven
  fresh evaluation, recovery/no-recovery outcomes, a second-owner race,
  release-before-catch, disposal, and process reconstruction.
- Updated the canonical Gate guide, package start page, Feature Addition index,
  changelog, and application version to `0.2.34+52`.
- Added no timer, polling, backoff, queue, persistence, status, busy UI,
  coordinator API, reset change, mutation-policy change, Presence dependency,
  or attachment behavior.

---

# 2026-08-15 - Audit user-initiated setup mutation-busy feedback

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/53-USER-INITIATED-SETUP-MUTATION-BUSY-FEEDBACK-AUDIT.md`.
- Traced the current Environment Readiness and blocking failure-overlay setup
  actions through their action providers, `OnboardingGate`, and
  `ArchiveMutationCoordinator`.
- Confirmed ordinary busy denial runs no setup action, reset, controller, or
  file mutation, leaves Gate/environment truth unchanged, and currently escapes
  through an unhandled or unobserved UI Future without human feedback.
- Distinguished an explicit denied command from automatic recovery intent and
  rejected replay, queues, timers, polling, durable busy state, owner-label
  exposure, proactive button disabling, and `preparationFailed` reuse.
- Recommended one bounded next slice: return a narrow Onboarding-owned
  `admitted` / `busy` / `notApplicable` start outcome and render only `busy` as
  a standard transient snackbar from the active presentation.
- Verified the recommendation preserves FDA, controller-failure, reset,
  mutation-policy, Environment Readiness, Presence, and attachment-preservation
  boundaries. No application code or tests were changed.

---

# 2026-08-15 - Validate end-to-end production onboarding

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md`.
- Verified release composition routes through `MacosAppShell`,
  `OnboardingGate`, `OnboardingPresenceHost`, the real authored Schedule, real
  Onboarding Agents, `PresenceScheduler`, and `PresenceRunner` rather than the
  development harness.
- Found that every debug launch bypassed the production-shaped shell and
  mounted `LinearPresenceExperimentHost`. Corrected that bounded validation
  blocker by making the harness opt-in through
  `PRESENCE_DEVELOPMENT_HARNESS=true` and added an architecture tripwire.
- Executed realistic source-readiness, FDA, Contacts, sparse-history Choice,
  durable acceptance, import/build, completion, preparation failure,
  controller failure, automatic recovery, busy-deferral, restart, and
  attachment-preservation seams with disposable/test storage.
- Recorded one remaining P1 production defect: the Boolean Messages readiness
  result routes missing or invalid source data into FDA remediation and can
  strand the person in incorrect guidance. Also recorded the production-
  inaccurate `MessageLens Development` FDA copy as P2.
- Distinguished all code/test evidence from manual visual validation still
  required. No production archive or archived attachment payload was used as
  experimental material.
- Updated the package start page and Feature Addition index. No Presence
  grammar, Schedule topology, Gate state, persistence, reset semantics,
  attachment archival, or production release composition was changed.

---

# 2026-08-15 - Correct Messages-source vs FDA readiness

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/55-TRUTHFUL-MESSAGES-SOURCE-VS-FDA-READINESS-IMPLEMENTATION.md`.
- Recorded the concrete evidence boundary: explicit POSIX permission denial
  warrants FDA guidance; missing, invalid-schema, query, and ambiguous I/O
  failures remain bounded source-unavailable outcomes.
- Documented the process-local specialist observation, its two generic Boolean
  Onboarding projections, additive Schedule branches, and fresh retry behavior.
- Updated the package start page, Feature Addition index, canonical Onboarding
  Gate guide, changelog, and version. Historical implementation records remain
  unchanged.

---

# 2026-08-15 - Correct observed Onboarding Step redefinition

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/56-OBSERVED-ONBOARDING-STEP-REDEFINITION-BLOCKER-IMPLEMENTATION.md`.
- Traced the production-observed conflict to Slice 55 changing only the Tell
  payload of canonical Step 6302 from **MessageLens Development** to
  **MessageLens** under its existing identity in Trip 303.
- Recorded why the definition-immutability guard was correct and why restoring
  the historical payload was safer than introducing replacement FDA topology
  around a terminal Settings-opening Step.
- Documented preservation of active Trip checkpoints, execution history,
  additive source-classification Trips, Test-route reconciliation, and
  occurrence-position reconciliation.
- Strengthened the Presence database walkthrough with the rule that persisted
  definition IDs are semantic identities rather than mutable authored slots.
- Updated the package start page, Feature Addition index, Slice 55 record,
  changelog, and app version to `0.2.36+54`.

---

# 2026-08-15 - Hand off Presence guidebook lifecycle

- Created
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md`.
- Recorded the production-shaped Step 6302 failure as evidence that runtime
  definition reconciliation is the wrong assumed cross-version lifecycle,
  without weakening the current immutability guard or adding migration logic.
- Established the next-feature direction: `presence.db` contains one installed
  guidebook edition plus convenient same-generation execution state; that
  state may be discarded wholesale when the guidebook generation changes.
- Restored the blank-stare ownership boundary: Presence reads opaque guidebook
  geometry while Onboarding answers domain questions without knowing Schedule,
  Trip, Step, occurrence, or routing identities.
- Distinguished disposable guidebook position from durable human intent that
  remains meaningful independently of Presence geometry.
- Closed Feature Addition 23 as the active home for guidebook installation,
  replacement, runtime authority, reconciliation removal, and cross-version
  state policy. Updated its start page and the Feature Addition index.
- No application code, schema, runtime behavior, Overlay data, or
  `presence.db` contents changed in this documentation handoff.

---

# 2026-08-16 - Start production archive recovery feature

- Created
  `45-NEW-FEATURE-ADDITION/26-PRODUCTION-ARCHIVE-RECOVERY/00-START-HERE.md`.
- Established the emergency objective of recovering valuable historical
  Messages records and preserved archived image payloads from the known March
  2026 MessageLens Application Support archive into the known current
  production archive.
- Declared the March archive a read-only donor, the current archive production,
  and the initial investigation strictly read-only with mutation of neither
  authorized.
- Restated that archived attachment payloads are preservation data to be
  treated like gold and that byte-different logical collisions must never be
  overwritten silently.
- Registered the first operative task as a read-only donor/current archive
  inventory and explicitly deferred generalized archive-ingestion product
  design.
- Updated the Feature Addition index. No archive was inspected, no database or
  attachment payload was accessed, and no recovery implementation was begun.

---

# 2026-08-16 - Audit March 2026 attachment relational bridge

- Created
  `45-NEW-FEATURE-ADDITION/26-PRODUCTION-ARCHIVE-RECOVERY/responses/01-MARCH-2026-ATTACHMENT-RELATIONAL-BRIDGE-AUDIT.md`.
- Resolved the supplied donor path to its actual content beneath a literal `:`
  directory and confirmed the configured production archive root from current
  application policy and cutover documentation.
- Demonstrated the donor-message-GUID and donor-attachment-GUID bridge through
  live-source source-scoped identities and current graph topology for 33,011 of
  33,018 checkpointed donor pairs (99.9788%).
- Measured 30,743 deterministic donor payloads present, 30,736 direct mappings,
  30,382 intact current archive entries, and 354 mapped payloads apparently
  recoverable without changing message history.
- Recorded the seven-row relational residue, path/filesystem residue, current
  archive residue, and the donor WAL limitation without introducing heuristic
  fallback matching.
- Identified the existing snapshot reader, source-scoped mapper,
  content-addressed writer, and mutation coordinator as the eventual recovery
  seam. The next bounded step is a read-only recovery plan; no payload was
  copied and no recovery operation was run.
- Recorded that an initial SQLite `mode=ro` schema probe updated only the donor
  `chat.db-shm` coordination sidecar metadata; all quantitative work then used
  immutable database access, and database/WAL/payload content remained
  unchanged.
- Disclosed that the already-running production app independently advanced the
  import and graph stores by three messages during the first pass. Repeated all
  decisive counts after an eight-second stability window; bridge, residue,
  archive-coverage, and recovery-opportunity results were unchanged.
- Updated the package start page and Feature Addition index. No application
  code, database schema, message history, archive metadata, or attachment
  payload changed.

---

# 2026-08-16 - Close March 2026 production archive recovery investigation

- Generated the exact 354-row detailed recovery manifest outside Git at
  `/tmp/messagelens-production-archive-recovery/march-2026-recoverable-attachments.csv`.
- Reproduced Audit 01 exactly: 354 apparently recoverable payloads totaling
  445,063,249 bytes, with the same blank, image, and QuickTime MIME
  distribution and no discrepancies.
- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/02-MARCH-2026-RECOVERY-MANIFEST-AND-CLOSURE.md`
  containing only non-sensitive aggregates, the local manifest path and
  digest, the read-only safety boundary, explicit exclusions, and the final
  stop decision.
- Updated the Feature 26 start page and Feature Addition index to mark the work
  suspended and complete for now by explicit user decision.
- Used immutable/read-only database access and queried no message text. No
  archive writer ran; no attachment was copied; no database, archive metadata,
  message history, application code, or attachment payload changed.

---

# 2026-08-16 - Audit historical Messages donor ingestion feasibility

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/03-HISTORICAL-MESSAGES-2012-2016-INGESTION-AUDIT.md`.
- Resolved the task's `Messages_2016` wording against the actual supplied
  `Messages_2012` donor and established its real 2012-07-25 through 2017-06-11
  range from immutable SQLite evidence.
- Counted 8,882 donor messages, 86 chats, 77 handles, 773 attachment records,
  and their source topology; confirmed database integrity, delete-journal
  mode, and an empty WAL.
- Measured 6,513 exact GUID overlaps with the current live source and 2,369
  absent GUIDs, including all 1,352 donor messages from 2012-2013.
- Confirmed the current source-scoped Historical Archives workflow registers a
  separate source, imports source facts, and projects them without resetting
  live-source facts, Overlay intent, or the attachment archive. Recorded that
  overlapping GUIDs intentionally remain separate source-scoped occurrences.
- Established that attachment metadata is imported but attachment payload
  recovery is neither required nor performed by this message-history slice.
- Identified the current non-immutable historical source opener as a donor
  preservation caveat and specified a verified read-only disposable
  `chat.db` input copy for the rehearsal.
- Defined the exact development-root staging-clone procedure, baseline and
  post-import checks, restart/catch-up checks, and the boundary against direct
  promotion of a stale development clone.
- Updated the Feature 26 start page and Feature Addition index to mark the
  package temporarily reopened only for this separate historical-message task.
- No staging clone was created, no app was launched, no ingestion ran, and no
  donor, production database, Overlay row, archive metadata, or attachment
  payload was mutated.

---

# 2026-08-16 - Correct Historical Archives maintenance-lock sequencing

- Recorded the first disposable staging import failure in
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/04-HISTORICAL-IMPORT-MAINTENANCE-LOCK-CORRECTION.md`.
- Established by immutable inspection that no source `3` registration, import
  rows, graph rows, or attachment-preservation changes occurred; only the
  retryable Historical Archives failure status was written to Overlay.
- Documented the exact self-blocking provider chain and the correction: prepare
  the feature-owned graph import service before mutation admission, retain that
  prepared connection for the owner, and continue refusing fresh unrelated
  graph opens while maintenance blocking is active.
- Clarified the canonical database-access documents that the maintenance signal
  gates connection creation and does not reactively revoke an existing handle.
- Updated the Feature 26 start page and Audit 03 status wording. No database
  schema, source identity, donor, staging data, production archive, or
  attachment payload was changed by this documentation pass.

---

# 2026-08-16 - Centralize historical Apple timestamp normalization

- Recorded the successful 8,882-message staging import and its timestamp
  collapse in
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/05-HISTORICAL-APPLE-TIMESTAMP-NORMALIZATION-CORRECTION.md`.
- Established `lib/core/util/date_converter.dart` as the sole Apple timestamp
  authority for old Apple-second and modern Apple-nanosecond values.
- Added the mandatory canonical rule in
  `10-DATABASES/13-apple-timestamp-conversion.md`, linked it from the project
  index, `db-chat`, `INVIOLATE_RULES.md`, and `AGENTS.md`, and recorded the
  architecture tripwire that rejects parallel epoch arithmetic.
- Documented the owned source-scoped removal/reprojection path as the preferred
  disposable staging reset, with clone recreation as the fail-closed fallback.
- Separately recorded the observed temporary Onboarding diversion during
  Historical Archives import without changing that UX in this task.
- No production archive, frozen snapshot, donor, staging database, source
  record, schema, or attachment payload was modified.

---

# 2026-08-16 - Verify corrected historical import end to end

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/06-HISTORICAL-IMPORT-POST-CORRECTION-VERIFICATION.md`.
- Confirmed by immutable inspection that source `3` is registered once and
  contains exactly 8,882 messages in both import ledger and graph, spanning
  2012-07-25 through 2017-06-11 with zero 2000/2001 collapse rows.
- Matched representative donor raw Apple-second values through the canonical
  `DateConverter` expectations to identical ledger and graph ISO-UTC values.
- Confirmed source `1` remains intact at 136,943 matched ledger/graph rows; the
  one-row increase is ordinary live-source catch-up after the earlier baseline.
- Confirmed the source-3 topology counts reproduce the donor audit and all
  active staging databases pass immutable quick and integrity checks.
- Found no user-intent mutation during the historical import window. Recorded
  the legitimate Historical Archives workflow metadata update.
- Established that the historical source supplied no payload folder and that
  no historical-source payload write was identified.
  One later archive write came from the ordinary live Messages attachment
  source and is reported separately rather than misattributed to the import.
- Recorded the observed Onboarding diversion, transient readiness alarms,
  unclear lifecycle transitions, oversized control panel, and action ambiguity
  as the next Feature 26 concern without investigating or changing them.
- No import, removal, reset, application launch, production access, donor
  mutation, schema change, or attachment-payload mutation was performed by this
  verification pass.

---

# 2026-08-17 - Restore owner-aware archive mutation resource admission

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/08-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-IMPLEMENTATION.md`.
- Recorded that protected provider construction retains the requesting Dart
  Zone, allowing the existing private mutation-owner context to identify the
  caller without public owner IDs or capability tokens.
- Codified the hard caller-specific-scope invariant: resource permission comes
  from the requesting branch's current operation, while aggregate active
  scopes preserve the strongest safety restriction.
- Replaced the provisional Historical Archives pre-open sequencing workaround
  with coordinator-owned, operation-specific graph admission for admitted
  historical import/removal owners.
- Documented that message-data reset may close an existing graph handle but may
  not construct a fresh graph before deleting derived data.
- Clarified that `dbMaintenanceLockProvider` is a coarse readiness/presentation
  signal, not the owner-specific resource authority, and that legitimate
  maintenance is not graph projection failure or onboarding action.
- Updated Feature 26 links for the new `responses/` organization and refreshed
  the Feature Addition index.
- No database schema, archive data, donor, staging data, production data, or
  attachment payload was changed by this pass.

---

# 2026-08-17 - Audit Historical Archives removal readiness redirect

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/09-HISTORICAL-REMOVAL-ONBOARDING-REDIRECT-AUDIT.md`.
- Recorded immutable current-state evidence separately from the intermediate
  removal state reconstructed from application logs.
- Confirmed source-1 ledger and graph data remain intact at 136,943 messages,
  source 3 is singular and fully reimported at 8,882 messages, and all checked
  staging databases pass integrity checks.
- Traced removal through source-qualified ledger deletion, full graph clearing,
  and successful reprojection of all remaining source-1 facts without invoking
  the broad onboarding message-data reset.
- Established that the old running build misclassified deliberately incomplete
  graph state during maintenance, causing Onboarding center-panel navigation;
  a later historical reimport, not source-1 loss, explains the apparently
  persistent readiness state.
- Added a forensic initiator addendum: the only production entry point is the
  explicit Historical Archives **Begin Import** interaction; removal,
  automatic recovery, and background observers do not call historical import.
- Recorded that the first source-3 batch began about 9.1 seconds after removal
  had returned the ledger and graph to a ready source-1-only state. This timing
  is consistent with the user's recalled click, but cannot prove it because no
  durable button-press or mutation-admission-start event exists.
- Recommended validating the already implemented owner-aware maintenance
  classification against the exact removal/reimport lifecycle before making a
  further correction.
- No database, import, removal, recovery, application launch, production data,
  snapshot, donor, or attachment payload was modified by this audit.

---

# 2026-08-17 - Audit fresh-start readiness gating anomaly

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/10-FRESH-START-GATING-ANOMALY-AUDIT.md`.
- Confirmed by immutable inspection that the intended staging archive remains
  healthy at 145,825 import and graph messages, with source 1 at 136,943 and
  source 3 at 8,882.
- Established that the screenshot came from the ordinary external development
  archive, not the staging clone: its import and graph databases both contain
  zero messages, its live source cursor was 153111, and it has no attachment
  archive.
- Traced startup from archive-root admission through the environment report,
  gate fallback and final classification, and center-panel synchronization.
- Recorded the exact count probes and UI mapping that produced both displayed
  `Not prepared yet` facts; each matched its admitted on-disk database.
- Disproved stale failure state, maintenance state, provider race, and latched
  panel selection as causes. Classified the observation as a process-scoped
  staging-root override not surviving a later normal development launch.
- Recommended explicitly supplying and verifying the staging root for every
  fresh rehearsal process; no gate implementation change was made.
- No database, application code, import, removal, recovery, reset, GUI launch,
  production data, snapshot, donor, or attachment payload was modified.

---

# 2026-08-17 - Design Historical Archives Narrator and Directed Instrumentation

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md`.
- Inventoried every current Historical Archives information group and
  classified it as primary journey, directed instrumentation, decision
  evidence, completion evidence, details/diagnostics, or developer-only.
- Defined the full journey from source selection through preflight, import,
  completion, imported-source management, removal, and retryable or diagnostic
  failure.
- Established a modest Historical Archives-specific grammar: transition
  statement, instrumentation tableau, resolved/active/failure rows, decision
  surface, completion surface, and collapsed Details.
- Preserved the rule that only genuine human decisions produce controls and
  that all known safe intermediate work proceeds automatically.
- Identified existing source inspection, dry-run, mutation-gate, import,
  removal, and source-metadata facts that can drive truthful presentation.
- Recorded the current real-time instrumentation limit: import and removal
  expose only operation boundaries and final results, not live internal stage
  observations. The design forbids timer-derived or inferred progress.
- Proposed five bounded implementation slices that replace presentation before
  considering any service-level observability seam.
- No application code, workflow behavior, schema, archive, import, removal,
  recovery, GUI state, production data, snapshot, donor, or attachment payload
  was changed.

---

# 2026-08-17 - Implement Historical Archives Narrator slice 01

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/12-NARRATOR-SLICE-01-IMPLEMENTATION.md`.
- Recorded the bounded no-source, inspecting, failed-inspection, and
  ready-for-import Narrator + Directed Instrumentation implementation.
- Documented the typed inspection-evidence snapshot and explicit presentation
  stage used to project existing workflow truth without moving execution or
  mutation ownership.
- Recorded which permanent control-panel elements are bypassed in this slice
  and which later workflow states intentionally retain the legacy surface.
- Preserved technical evidence under collapsed Details rather than deleting
  diagnostics from the Historical Archives experience.

---

# 2026-08-17 - Implement already-imported Narrator reference signal

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/13-NARRATOR-ALREADY-IMPORTED-REFERENCE-SIGNAL-IMPLEMENTATION.md`.
- Recorded the canonical classification rule: an archive is already imported
  only when its canonical source key is registered in the source-scoped import
  ledger and that source has a positive imported-message count.
- Documented that preflight-only registration, sidebar labels, and overlay
  workflow metadata do not establish imported truth.
- Recorded the already-imported Narrator composition and the deliberate absence
  of Import Archive and ordinary comparison evidence.
- Documented the sidebar's canonical source-key targeting and reuse of orange
  as referential correspondence rather than warning or selection.
- Established explicitly that the monotonically increasing pulse occurrence is
  process/presentation state only. It is neither durable source metadata nor a
  component of source identity.
- Recorded the distinct-GUID denominator correction and the projection-level
  coherence invariant that prevents impossible human-facing comparison
  arithmetic without clamping.
- Confirmed that no schema or persistence-format change was introduced.

---

# 2026-08-17 - Refine Historical Archives sidebar reference interaction

- Created
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/14-NARRATOR-SIDEBAR-REFERENCE-REFINEMENT-IMPLEMENTATION.md`.
- Recorded the responsibility split in which the center panel owns the active
  archive journey while the sidebar owns context, source navigation, and
  referential correspondence.
- Documented exact canonical-source-key navigation from Known Archive Source
  cartouches and the absence of import, removal, inspection, or chooser side
  effects from that action.
- Established that preflight-only persisted source knowledge is read-only and
  cannot authorize import without a fresh folder selection and inspection.
- Recorded extraction of the established All Messages orange correspondence
  appearance while preserving independent feature ownership of reference
  semantics, pulse occurrence, animation, and reduced-motion behavior.
- Documented fresh repeated-recognition acknowledgment and the invariant that
  its occurrence remains process/presentation state, not durable metadata or
  source identity.
- Confirmed that no schema, persistence format, source identity, import,
  removal, archive mutation, production data, staging data, donor, or
  attachment payload was changed.

## 2026-08-17 — Historical Archives hub and selection context

- Added Feature 26 response
  `15-HISTORICAL-ARCHIVES-HUB-AND-SELECTION-CONTEXT-IMPLEMENTATION.md`.
- Recorded the explicit `hub`, `existingSource`, and `addArchive` presentation
  contexts; the blue-selection/orange-reference distinction; transient
  navigation reset; and presentation-session protection against late async
  results.
- Updated release notes for the user-facing Historical Archives context
  correction.

## 2026-08-17 — Historical Archives hub semantic cleanup

- Added Feature 26 response
  `16-HISTORICAL-ARCHIVES-HUB-SEMANTIC-CLEANUP-IMPLEMENTATION.md`.
- Recorded that remembered source identity and current sidebar membership are
  distinct truths.
- Established **Folders Already Added** membership as canonical historical
  source identity plus a positive source-scoped imported message count.
- Documented the silent hub, removal of redundant imported-status
  presentation, normal message-data refresh behavior, and preservation of
  canonical identity for later add-flow recognition.
- Confirmed that no schema, source registration, archive mutation, import,
  removal, production data, staging data, donor, or attachment payload was
  changed.

## 2026-08-18 — Historical Archives duplicate-folder boundary

- Added Feature 26 response
  `17-HISTORICAL-ARCHIVES-DUPLICATE-FOLDER-BOUNDARY-IMPLEMENTATION.md`.
- Recorded duplicate folder selection as a failed Add action owned by a modal,
  not an existing-source selection or center-panel Narrator state.
- Documented hub restoration before post-dismissal orange correspondence and
  the bounded pulse, linger, fade, and complete reference-clear lifecycle.
- Established occurrence-plus-presentation-session guards for stale modal
  dismissal and reference expiry, including protection against an older timer
  clearing a newer occurrence.
- Confirmed that duplicate handling performs no source persistence, import,
  removal, graph projection, database mutation, or attachment operation.

## 2026-08-18 — Historical Archives invalid-folder boundary

- Added Feature 26 response
  `18-HISTORICAL-ARCHIVES-INVALID-FOLDER-BOUNDARY-IMPLEMENTATION.md`.
- Established that a selected folder earns add/import center-panel context only
  after it contains a regular Messages `chat.db` and passes basic source
  inspection.
- Classified `Missing` as a pre-context qualification rejection while retaining
  `Read failed` as a distinct, not-yet-generalized inspection failure.
- Documented the modal-only invalid-folder flow, virgin hub restoration, and
  the absence of blue selection or orange referential correspondence.
- Confirmed that the ephemeral notice carries only occurrence/session guards
  and that invalid selection performs no source persistence or archive
  mutation.

## 2026-08-19 — Historical Archives gentle reference fade

- Added Feature 26 prompt and response records for the Historical Archives
  gentle referential-attention refinement.
- Established that referential attention should be the smallest visual change
  sufficient to direct human attention.
- Replaced the Historical Archives pulse/glow presentation with a 750 ms light
  orange fade-in, one-second hold, and two-second fade-out that returns exactly
  to ordinary unselected chrome.
- Recorded reduced-motion behavior as a calm static treatment with the same
  bounded workflow lifetime.
- Preserved canonical source identity separately from process-only reference
  occurrence and presentation-session guards.
- Confirmed that All Messages correspondence, duplicate semantics, archive
  persistence, mutation authority, and database behavior were not changed.

## 2026-08-19 — Historical Archives monotonic reference fade correction

- Added Feature 26 response
  `21-HISTORICAL-ARCHIVES-MONOTONIC-REFERENCE-FADE-CORRECTION.md`.
- Recorded that transparent endpoint interpolation caused the observed double
  intensity peak despite a correctly ordered animation-strength sequence.
- Replaced decoration interpolation with opaque tint and border compositing
  driven directly by one bounded reference-strength value.
- Added regression coverage for opaque frames, monotonic sampled intensity,
  exact ordinary final chrome, and preserved reduced-motion behavior.
- Confirmed that timing, occurrence/session safety, modal semantics, source
  identity, persistence, and archive operations remain unchanged.

## 2026-08-19 — Historical Archives Messages-folder guidance

- Added Feature 26 response
  `22-HISTORICAL-ARCHIVES-MESSAGES-FOLDER-GUIDANCE-IMPLEMENTATION.md`.
- Recorded **Historical Archives** as the umbrella concept and **Messages
  Folder** as the concrete object selected by the current macOS source arm.
- Documented sidebar ownership of pre-chooser orientation, the regular
  `chat.db` structural requirement, and optional `Attachments` content.
- Preserved the silent virgin center panel and confirmed that guidance creates
  no workflow context, source identity, persistence, or archive mutation.

## 2026-08-19 — Historical Archives source-type hierarchy

- Added Feature 26 response
  `23-HISTORICAL-ARCHIVES-SOURCE-TYPE-SEGMENTED-CONTROL-IMPLEMENTATION.md`.
- Recorded Historical Archives as the umbrella Settings identity and Messages
  Folders / MessageLens Data Folders as its two intended source arms.
- Documented Messages Folders as the only enabled arm and the second segment
  as presentation-only, visibly disabled, and mechanically unable to dispatch
  workflow behavior.
- Recorded removal of the redundant inner Historical Archives heading and the
  source-neutral umbrella introduction.
- Confirmed that no MessageLens Data Folder workflow, persistence, source
  specialist, archive mutation, or database model was introduced.

## 2026-08-19 — Historical Archives sidebar hierarchy polish

- Added Feature 26 response
  `24-HISTORICAL-ARCHIVES-SIDEBAR-HIERARCHY-POLISH-IMPLEMENTATION.md`.
- Shortened the disabled future source arm to **MessageLens Folders** without
  adding an execution path or placeholder content.
- Recorded the three-level spacing grammar used to separate source selection,
  known folders, guidance topics, and their subordinate text.
- Structured Messages-folder guidance into a concise source contract, normal
  location, older-copy guidance, and optional Attachments guidance before the
  sole chooser action.
- Confirmed that the virgin Historical Archives hub still leaves the center
  panel empty and that no workflow, source, persistence, or mutation semantics
  changed.

## 2026-08-19 — Historical Archives sidebar simplification

- Added Feature 26 response
  `25-HISTORICAL-ARCHIVES-SIDEBAR-SIMPLIFICATION-IMPLEMENTATION.md`.
- Replaced the source labels with compact **Mac Messages** and **MessageLens**
  wording while preserving the disabled future arm.
- Reduced the umbrella introduction to one source-neutral sentence and removed
  the redundant instruction to choose a source below.
- Collapsed the Messages-folder mini-heading hierarchy into three concise,
  equal-weight notes that retain the `chat.db`, normal location, moved/renamed
  copy, and optional Attachments facts.
- Confirmed that the sole chooser remains below guidance and that the virgin
  center panel, cartouches, modal boundaries, source semantics, persistence,
  and mutation behavior remain unchanged.

## 2026-08-19 — Historical Archives sidebar breathing room

- Added Feature 26 response
  `26-HISTORICAL-ARCHIVES-SIDEBAR-BREATHING-ROOM-IMPLEMENTATION.md`.
- Recorded that the established sidebar hierarchy was already semantically
  complete and that this pass added no information or behavior.
- Increased the shared-token major breaks between source selection, known
  folders, and adding another folder from `24px` to `32px`.
- Increased equal-weight guidance paragraph cadence from `8px` to `16px` and
  the guidance-to-chooser handoff from `16px` to `24px`.
- Confirmed that all copy, widths, source labels, disabled state, cartouches,
  center-panel silence, workflow, persistence, and archive semantics remain
  unchanged.

## 2026-08-19 — Historical Archives decisive section spacing

- Added Feature 26 response
  `27-HISTORICAL-ARCHIVES-DECISIVE-SECTION-SPACING-IMPLEMENTATION.md`.
- Recorded why the previous `32px` major separation remained perceptually
  insufficient despite being structurally correct.
- Established `56px` major section breaks, `24px` guidance rhythm, a `32px`
  guidance-to-action handoff, and the preserved `8px` heading/content bond.
- Documented that large section separation and internal paragraph rhythm are
  distinct layout responsibilities.
- Confirmed that the pass changes no content, workflow, source, persistence,
  mutation, cartouche, modal, navigation, or center-panel behavior.

## 2026-08-19 — Historical Archives cartouche title hierarchy

- Moved known archive-folder titles from the `controlValue` typography token
  to the existing, slightly smaller semibold `headline` token.
- Preserved the stronger **Folders Already Added** heading, its compact
  heading-to-cartouche relationship, subordinate metadata, cartouche chrome,
  selection, correspondence, and all archive behavior.

## 2026-08-19 — Historical archive selected-source story

- Added Feature 26 response
  `28-HISTORICAL-ARCHIVE-SELECTED-SOURCE-STORY-IMPLEMENTATION.md`.
- Recorded the compositional rule that the selected sidebar cartouche owns
  archive identity while the center panel owns meaning and management.
- Replaced selected-source Narrator instrumentation with a dedicated human
  story using the established readable-width, left-aligned vertical center
  panel composition.
- Documented that successful import dates require
  `lastImportSuccess == true` and `lastImportFinishedAtUtc` and use the shared
  `DateLabelFormatter`.
- Recorded why current persisted evidence cannot truthfully support a numeric
  unique-contribution claim and why omission is required.
- Restored the existing confirmed removal entry with canonical destructive
  theme tokens while preserving removal execution and mutation authority.

## 2026-08-19 — Historical archive selected-source Track alignment

- Added Feature 26 response
  `29-HISTORICAL-ARCHIVE-SELECTED-SOURCE-TRACK-ALIGNMENT-IMPLEMENTATION.md`.
- Recorded Historical Archives Tracks A-E as the fixed shared upper region and
  the trailing edge of E as the handoff to independent native flows.
- Documented that the cartouche list and selected-source story share a start
  coordinate without either variable-height region becoming a Track occupant.
- Recorded truthful text/control dimensional claims and reuse of the approved
  `AppSpacing` transitions as ordinary fixed-height occupants.
- Confirmed that no dynamic row alignment, magic top inset, scroll
  synchronization, source/persistence change, or workflow change was added.

## 2026-08-19 — Historical Archives removal journey

- Audited the existing source-scoped removal path and recorded that it exposes
  only operation-level start/finish/failure, not live deletion or reprojection
  stages.
- Documented the destructive confirmation, original-folder safety guarantee,
  coarse Directed Instrumentation, durable membership transition back to the
  hub, failure behavior, source-identity preservation, and staging review in
  `26-PRODUCTION-ARCHIVE-RECOVERY/responses/30-HISTORICAL-ARCHIVE-REMOVAL-JOURNEY-IMPLEMENTATION.md`.

## 2026-08-19 — Historical archive removal directed instrumentation

- Recorded the three real Historical Archives removal stages and their exact
  service/workflow observation boundaries.
- Documented the transient busy-cartouche presentation rule, terminal
  membership verification, and truthful partial-failure behavior.
- Reaffirmed that progress is event-driven rather than timer-driven and that
  removal never writes to source folders or preservation data.

## 2026-08-19 — Mac Messages ingestion directed instrumentation

- Added Feature 26 response
  `32-MAC-MESSAGES-INGESTION-NARRATOR-DIRECTED-INSTRUMENTATION-IMPLEMENTATION.md`.
- Recorded the audited pre-authorization inspection and post-authorization
  source-import, graph-projection, read-model refresh, and final-verification
  sequence.
- Documented the import service's typed descriptive observation seam and its
  mapping to three truthful human-facing rows.
- Recorded explicit import authorization, omission of a redundant confirmation
  modal, finalized cartouche membership, bounded success correspondence, and
  truthful partial-failure retry behavior.
- Reaffirmed source-1 protection, donor immutability, owner-aware mutation
  authority, Tracks A-E, and `DateConverter` as the sole Apple timestamp
  authority.

## 2026-08-20 — Mac Messages ingestion temporal coherence

- Added Feature 26 response
  `33-MAC-MESSAGES-INGESTION-TEMPORAL-COHERENCE-IMPLEMENTATION.md`.
- Documented the gate-derived disappearing-action defect and the invariant that
  a qualified candidate remains visibly ready while temporary mutation
  authority changes only the Add action's enabled state.
- Recorded center-owned Cancel semantics, immediate operation presentation,
  and the event-loop yield that lets truthful operation state paint before
  expensive work begins.
- Audited the seven graph-projector calls and grouped them into five real,
  monotonic execution units without inventing record-level progress.
- Established a 750 ms post-execution all-Done presentation dwell guarded by
  presentation-session ownership.
- Removed success-created orange correspondence while preserving duplicate
  folder reference semantics and all source, mutation, removal, Track, donor,
  and attachment boundaries.

## 2026-08-20 — Historical Archives import responsiveness and real progress

- Recorded the concrete authorization-to-first-paint defect and the new
  end-of-frame presentation barrier.
- Documented the shared primary-button hover/pressed correction.
- Profiled all five real graph units on an isolated fixture and recorded their
  exact workloads and relative durations.
- Codified exact batched counts for Conversations, Messages, and Attachments,
  plus the deliberate coarse treatment of composite Participants and
  Relationships units.
- Preserved the three-stage import story, five-unit hierarchy, completion
  dwell, source safety, and DateConverter invariant.

## 2026-08-20 — Historical Archives completion and chooser feedback

- Added Feature 26 response
  `35-MAC-MESSAGES-IMPORT-COMPLETION-AND-CHOOSER-FEEDBACK-IMPLEMENTATION.md`.
- Recorded the shared secondary-button normal, hover, and pressed grammar used
  by **Choose Messages Folder...**, with no artificial delay before Finder.
- Documented the exact terminal-success prerequisites, preserved 750 ms
  all-Done dwell, restored-hub ordering, and process-only success notice.
- Confirmed that `OK` is acknowledgement only and that a successfully added
  cartouche receives neither orange correspondence nor automatic blue
  selection.

## 2026-08-20 — Historical Archives import-ledger contention correction

- Added Feature 26 response
  `36-HISTORICAL-ARCHIVE-IMPORT-LEDGER-CONTENTION-CORRECTION.md`.
- Recorded the staging failure caused by an Environment Readiness count probe
  opening `macos_import_ss.db` while Historical Archives owned maintenance.
- Codified that Environment Readiness opens neither derived store for
  observational counts during admitted maintenance and instead reports the
  truthful maintenance state.
- Documented the canonical import ledger's three-second busy timeout as
  bounded contention tolerance rather than resource authority.
- Recorded that the failed staging attempt left one deterministic source
  registration, no source-3 batch or message rows, no graph projection, and no
  attachment operation, so the existing clone remains safe to retry.

## 2026-08-20 — Historical Archives Narrator scope transition

- Added Feature 26 response
  `37-MAC-MESSAGES-NARRATOR-SCOPE-TRANSITION-IMPLEMENTATION.md`.
- Recorded the typed transition from selected-folder source addition to
  combined MessageLens history preparation.
- Codified that Narrator intervenes when human meaning or scope changes, while
  Directed Instrumentation retains ownership of factual work and exact
  denominators within that scope.
- Confirmed that the 8,882-message source count and the roughly 150,000-message
  combined graph workload are distinct truthful facts, with no synthetic
  progress introduced.

## 2026-08-20 — Historical Archives Narrator lifecycle

- Added Feature 26 response
  `38-NARRATOR-LIFECYCLE-AND-STALE-COMMENTARY-IMPLEMENTATION.md`.
- Recorded the typed boundary at which combined-history commentary expires and
  final verification becomes intentionally Narrator-silent.
- Codified that Narrator commentary exists only while its interpretation is
  current and that silence is preferable to paraphrasing self-explanatory
  Directed Instrumentation.
- Audited removal and confirmed that its operation-wide Narrator statement
  remains truthful through final removal verification.

## 2026-08-20 — Stable Narrator Track and removal lifecycle

- Added Feature 26 response
  `39-STABLE-NARRATOR-TRACK-REMOVAL-JOURNEY-AND-TERMINAL-PERCEPTION-IMPLEMENTATION.md`.
- Recorded center-only Historical Archives Tracks F-I for page identity,
  explicit transitions, and a typography-derived two-line Narrator allocation.
- Corrected the earlier spatial lifecycle record: Narrator silence now leaves
  its structural Track present so Directed Instrumentation remains fixed.
- Documented truthful removal progress: source deletion remains one coarse
  transaction while remaining-history rebuilding exposes the five real graph
  projector units and existing numeric callbacks.
- Codified phase-specific removal commentary, Narrator-silent verification,
  and a 1,500 ms all-Done perceptual receipt after execution completes.
- Propagated the reusable spatial-continuity and completed-evidence principles
  to the canonical Presence Rendering document.

## 2026-08-20 — Historical Archives architecture-conformance audit

- Added Feature 26 response
  `40-HISTORICAL-ARCHIVES-ARCHITECTURE-CONFORMANCE-AUDIT.md` with the explicit
  architecture checklist, complete workflow-state table, database lifecycle
  map, risk-ranked findings, and bounded remediation boundary.
- Codified that all ordinary graph-readiness observation, not only Environment
  Readiness row counts, must stop before opening protected derived stores
  during admitted maintenance.
- Recorded the deferred design questions around workflow-state mechanical
  impossibility, the Historical Archives state-dependent center Track
  boundary, and offline-capable canonical source identity.

## 2026-08-21 — Historical Archives typed presentation state

- Added Feature 26 response
  `41-HISTORICAL-ARCHIVES-TYPED-PRESENTATION-STATE-IMPLEMENTATION.md` with the
  final sealed state variants, transition table, durable/transient truth
  boundary, notice/reference strategy, and mechanical guarantees.
- Updated the architecture-conformance audit to mark D1 resolved while keeping
  the Track-boundary, source-identity, and legacy-schema findings separate.
- Recorded that candidate inspection evidence, imported-source facts, import
  progress, removal progress, modal notices, and orange correspondence now
  exist only in their truthful presentation variants.
- Preserved the established mutation authority, persistence, source identity,
  Track geometry, Narrator lifecycle, controls, copy, and archive behavior.

## 2026-08-21 — Historical Archives stable center Track skeleton

- Added Feature 26 response
  `42-HISTORICAL-ARCHIVES-STABLE-CENTER-TRACK-SKELETON-IMPLEMENTATION.md` with
  the page-specific A-I occupancy map, all 13 typed variants, the post-I center
  seam, and the independent post-E sidebar flow.
- Updated the architecture-conformance audit to mark D2 resolved while leaving
  D3 source identity and D4 legacy-schema mechanics separate.
- Elevated the reusable rule that a column's shared Track boundary is stable
  page composition: presentation variants may change visible occupancy, but
  not the column's declared shared lifetime.
- Recorded that the variable cartouche list remains outside center geometry
  and that no selected-row synchronization, magic top inset, or new spacer was
  introduced.

## 2026-08-21 — Historical Archives canonical source identity

- Added the canonical database rule
  `10-DATABASES/14-historical-archive-source-identity.md` defining
  `HistoricalArchiveSourceIdentity` as the sole authority for Historical
  Archives source identity.
- Added Feature 26 response
  `43-HISTORICAL-ARCHIVE-CANONICAL-SOURCE-IDENTITY-IMPLEMENTATION.md` documenting
  the former online/offline authority split, the final typed API, all identity
  consumers, compatibility handling, and preserved boundaries.
- Updated the Feature 26 architecture-conformance audit to mark D3 resolved;
  D4 remains the only deferred finding from that sequence.
- Updated the project database index and Feature 26 navigation so the identity
  rule is unavoidable in future Historical Archives work.

## 2026-08-21 - MessageLens data-folder Historical Archives audit

- Added Feature 26 response
  `44-MESSAGELENS-DATA-FOLDER-HISTORICAL-ARCHIVES-AUDIT.md` with the canonical
  archive anatomy, qualification boundary, identity recommendation, data
  classification, provenance strategy, and staged implementation boundary for
  the future MessageLens source arm.
- Established source kind plus archive instance ID as the recommended durable
  outer source identity; path remains locator evidence only, and byte-identical
  copies retaining the marker remain one logical source.
- Identified donor-qualified provenance as the fact-import gate because raw
  donor keys such as `live-chat-db` and `live-address-book` are recipient-local
  reserved identities and cannot be merged directly.
- Separated source-fact import, attachment preservation, and overlay recovery
  into distinct contracts while preserving the existing sealed presentation
  model, A-I Track skeleton, mutation authority, and source identity authority.
- Confirmed that read-only identity/qualification work may begin with the
  MessageLens segment still disabled, while mutation remains blocked pending
  provenance, lineage, attachment, and overlay decisions.

## 2026-08-21 - MessageLens attachment-recovery lineage proof

- Added Feature 26 response
  `45-MESSAGELENS-ATTACHMENT-RECOVERY-LINEAGE-PROOF.md` documenting the narrowed
  attachment-only product contract, reversible source-scoped identity,
  supported local `chat.db` lineage, exact ROWID/GUID admission semantics,
  typed evidence, performance findings, and future per-message proof.
- Marked the general MessageLens data-folder merge assumptions in response 44
  as superseded design history without erasing the audit.
- Updated the Feature 26 start page to record that donor message, graph,
  source-registry, and overlay ingestion is not part of the current
  MessageLens-folder direction.
- Recorded the dormant schema-free implementation and its fail-closed
  `sameLineage`, `contradictoryLineage`, and `insufficientEvidence` contract.
## 2026-08-21 — Shared Historical Archives Messages lineage admission

- Promoted the attachment-specific ROWID/GUID proof to the canonical
  `essentials/source_scoped_import` authority.
- Documented the shared anchor/evidence contract, Mac and MessageLens evidence
  adapters, fail-closed threshold, workflow ordering, and source-identity
  distinction.
- Added the Feature 26 implementation record and linked the earlier proof and
  project/database indexes without rewriting historical records.
## 2026-08-21 - Preservation-safe attachment recovery infrastructure

- Strengthened the canonical attachment file store with verified temporary
  writes and macOS `link(2)` atomic no-overwrite installation.
- Added the dormant typed MessageLens recovery installer with payload-first,
  metadata-second ordering and retry reconciliation after metadata failure.
- Added read-only donor and canonical-current evidence adapters without donor
  migration or ad-hoc current database construction.
- Updated the canonical attachment archive guide with the no-overwrite writer
  rule, crash semantics, ownership inventory, and metadata ordering invariant.
- Added Feature 26 response
  `48-PRESERVATION-SAFE-ATTACHMENT-RECOVERY-INFRASTRUCTURE.md` and removed the
  byte-identical untracked Prompt 46 duplicate.
- Corrected the implementation record after worktree verification showed that
  mutation admission was described but not enforced at the dormant installer
  boundary. The archive mutation coordinator now mints an opaque capability
  valid only in the exact admitted async scope, and the installer rejects
  stale or wrong-operation capabilities before any payload or metadata access.

## 2026-08-22 - Pre-marker MessageLens archive qualification audit

- Added Feature 26 response
  `51-BACKWARD-COMPATIBLE-MESSAGELENS-ARCHIVE-QUALIFICATION-AUDIT.md` recording
  the exact missing-marker rejection and its current invalid-folder modal.
- Verified read-only that representative May, June, and July 2026 pre-marker
  archives are genuine, healthy MessageLens formats whose existing attachment
  evidence schemas remain compatible with the current donor adapter.
- Recorded the blocking identity finding: those generations persisted no
  `archiveInstanceId` or equivalent durable archive identifier, and later
  production adoption minted a new UUID rather than recovering one.
- Updated the canonical historical source-identity rule and Feature 26 index so
  future work cannot derive legacy identity from paths, filenames, timestamps,
  filesystem metadata, or an invented content hash.
- Stopped without code, donor mutation, marker creation, lineage weakening, or
  attachment recovery because the prompt's legacy-identity stop condition was
  met.

## 2026-08-22 - Ephemeral MessageLens recovery donors

- Added Feature 26 response
  `52-EPHEMERAL-MESSAGELENS-RECOVERY-DONORS-IMPLEMENTATION.md` documenting the
  durable Mac Messages source versus ephemeral MessageLens recovery-donor
  boundary.
- Corrected the canonical historical source-identity guide: MessageLens donors
  no longer require or produce `HistoricalArchiveSourceIdentity`; marker UUIDs
  are optional diagnostic evidence only.
- Marked the Prompt 51 missing-identity stop conclusion as superseded while
  preserving its read-only historical-format evidence.
- Recorded the supported pre-marker schema tuples, mandatory lineage and
  per-attachment gates, repeated-selection semantics, and prohibition on donor
  registration, cartouches, synthetic identity, marker creation, and writes.

## 2026-08-22 - MessageLens attachment preflight performance

- Added Feature 26 implementation record
  `53-MESSAGELENS-ATTACHMENT-PREFLIGHT-PERFORMANCE-AND-OBSERVABILITY-IMPLEMENTATION.md`.
- Recorded the controlled representative-donor improvement from 210.505
  seconds to 7.455 seconds, including exact phase timings and the original
  manual run's additional approximately 40 GB hash burden.
- Codified the preflight-versus-execution proof boundary in the canonical
  attachment archive guide: preflight inventories metadata, paths, presence,
  and size; future execution performs exhaustive database integrity and fresh
  payload SHA-256 validation immediately before no-overwrite installation.
- Updated the Feature 26 index with the final Directed Instrumentation,
  completed-work batching, first-paint, cancellation, and safety invariants.

## 2026-08-22 - Zero-recoverable attachment forensic validation

- Added Feature 26 response
  `54-FORENSIC-VALIDATION-OF-ZERO-RECOVERABLE-ATTACHMENTS.md` with the complete
  real donor/current evidence funnel and representative traces.
- Recorded that all donor archive identities and managed paths are represented
  in the current archive; zero recoverable is correct and matching semantics
  were not weakened.
- Documented filesystem authority for payload presence, canonical source-ID
  decoding, Prompt 53 semantic parity, classification reconciliation, and the
  bounded development diagnostics correction.

## 2026-08-22 - Batch attachment recovery and controlled-loss validation

- Added Feature 26 implementation record
  `55-BATCH-ATTACHMENT-RECOVERY-AND-CONTROLLED-LOSS-END-TO-END-VALIDATION.md`.
- Codified the exact preflight-set to execution-revalidation to canonical
  no-overwrite installer chain under caller-specific
  `attachmentReconciliation` authority.
- Recorded real count/byte progress, typed item-versus-systemic failure policy,
  final evidence verification, and journal-free idempotent retry semantics.
- Updated the canonical attachment archive guide and Feature 26 index from the
  prior dormant/read-only boundary to the implemented batch operation.
- Documented the read-only controlled-loss manifest helper, mandatory human
  deletion timing, and end-to-end rehearsal sequence without adding any
  product deletion path.

## 2026-08-22 - Controlled-loss attachment recovery validation

- Added Feature 26 validation record
  `56-CONTROLLED-LOSS-MESSAGELENS-ATTACHMENT-RECOVERY-VALIDATION.md` documenting
  the human-controlled seven-file, 918,067-byte end-to-end recovery result.
- Recorded exact preflight agreement, real recovery presentation, independent
  post-recovery size/SHA-256 verification, unchanged donor evidence, and the
  zero-recoverable idempotency rescan.
- Updated the canonical attachment archive guide and Feature 26 index with a
  concise reference while preserving the test's bounded evidence scope.
- Kept the machine-specific controlled-loss manifest outside the repository.

## 2026-08-22 - Feature 26 final release readiness

- Added
  `57-FEATURE-26-FINAL-RELEASE-READINESS-AND-CONFORMANCE.md` with the final
  two-arm product contract, invariant checklist, audit findings, bounded
  corrections, verification evidence, and closure decision.
- Classified Historical Archives as ready with two deferred non-blockers: the
  unused generated legacy Drift write surface and an optional future split of
  the large but correctly owned workflow coordinator.
- Recorded removal of the unreachable generic control panel, stale-session
  admission and persistence guards, captured operational evidence, and
  feature-local accessibility semantics.
- Updated the Feature 26 start document from temporarily reopened to complete.
- Confirmed that the prompt folder contains no byte-identical duplicate files.
## 2026-08-22 - Feature 27 Message History Coverage opening audit

- Created the Feature 27 Message History Coverage work package and preserved
  its opening prompt as `seed.md`.
- Added the read-only semantics and architecture audit.
- Established that the current denominator is every live
  `chat.db.message` row, while graph categories count every durable source.
- Recorded staging proof that 8,882 Historical Archives rows contaminate the
  current-Mac numerator.
- Recorded the false-complete clamp, missing identity reconciliation,
  maintenance-state gap, and correlated-query performance defect.
- Defined a row-identity-based terminal partition, honest product states, and
  ordered implementation slices. No application code or data changed.

## 2026-08-22 - Message History Coverage correctness architecture

- Added the Feature 27 implementation record and work-package index.
- Codified exact current `chat.db.message.ROWID` reconciliation across the
  source-scoped import and source-1 Conversation Graph evidence boundaries.
- Recorded the mutually exclusive conversation-linked, recovered/unlinked,
  and unaccounted partition and removal of defensive arithmetic clamps.
- Added the permanent maintenance, historical-source exclusion, attachment
  donor exclusion, and set-query invariants to the canonical database guide.
- Recorded the typed complete, incomplete, temporarily unavailable, and failed
  report states and the minimal presentation adaptation.
- Recorded representative staging query improvement from a greater-than-30
  second bounded failure to 0.10 seconds for all 137,340 source-1 rows.
- Recorded clean verification: 29 focused tests, 410 focused-plus-architecture
  tests, 201 broader database/Settings tests, the complete 1,951-test Flutter
  suite, analyzer, formatting, diff check, and macOS debug build.

## 2026-08-22 - Message History Coverage product presentation

- Added the Feature 27 product-presentation implementation record, including
  the opening dense-dashboard audit and final copy for every typed report state.
- Recorded the uncertainty-proportional hierarchy, recovered-message treatment,
  exact-actionability boundary, no-Narrator decision, stable loading behavior,
  accessibility contract, and A1/A2 Track mapping.
- Updated the canonical center-panel report guidance so concise healthy reports
  no longer manufacture dashboard rows or cards merely to satisfy a template.
- Updated the Feature 27 and feature-planning indexes, changelog, and release
  version for the user-facing Settings refinement.

## 2026-08-22 - Message History Coverage final conformance

- Added the final Feature 27 state and layout conformance implementation
  record and classified the feature as ready.
- Recorded the root cause of the A2 title misalignment and the shared
  Settings-owned horizontal content-column contract used by both Track and
  native-flow presentation.
- Recorded the icon-plus-headline status decision, additive Details content,
  all-state accessibility review, unchanged count surface, and preserved
  Prompt 02 semantic invariants.
- Updated the Feature 27 index, changelog, and release version for the final
  user-facing layout refinement.

## 2026-08-23 - Feature 28 Onboarding opening audit

- Created the Feature 28 Onboarding work package and preserved its opening
  prompt as `seed.md`.
- Added the comprehensive read-only Journey, failure, recovery, persistence,
  performance, prerequisite, and Start Fresh audit.
- Recorded the current archive-admission, Presence prerequisite, Gate,
  source-import, Conversation Graph, reset, maintenance, completion, restart,
  and attachment-preservation ownership boundaries.
- Established the truthful iCloud boundary: MessageLens requires the desired
  history to be locally present in the Mac's readable `chat.db`, but cannot
  prove remote-device settings or synchronization completeness.
- Classified the Option-launch no-op deletion promise, unbounded indeterminate
  work, malformed-record whole-stage abort risk, and abandoned-installation
  recovery gap as release blockers ahead of visual redesign.
- Defined a preservation-safe Start Fresh contract that never deletes Apple
  sources, overlay intent by accident, or `attachment_archive/`.
- Recorded clean existing verification: 155 Onboarding/readiness tests, 32
  focused source-import/graph-build tests, and 381 architecture tripwires.
- Changed no application code, schema, database, source data, or runtime
  behavior.

## 2026-08-23 - Durable Onboarding operation snapshot foundation

- Added the Feature 28 implementation record for the typed durable Onboarding
  operation snapshot and liveness foundation.
- Updated the canonical Onboarding Gate guide with the operation, mutation,
  persistence, completion-proof, and restart-reconciliation authority chain.
- Clarified the canonical Presence feature boundary: a feature may project one
  durable typed operation snapshot into Presence without transferring
  operational or mutation authority.
- Recorded the four current typed stages, UUID operation/session semantics,
  observation-driven progress evidence, bounded write cadence, top-level
  failure routing, and no-schema overlay-settings persistence.
- Preserved the next-slice boundary: execution-opportunity-aware stall/watchdog
  classification remains unimplemented, as do Start Fresh and record-level
  anomaly quarantine.
- Recorded clean final verification: 1,991 complete Flutter tests, 406
  architecture tests, 186 focused source-import/graph tests, clean analyzer and
  formatting checks, and a successful macOS debug build.

## 2026-08-23 - Onboarding stall-detection prerequisite audit

- Recorded the Prompt 03 stage-by-stage liveness inventory and stopped before
  adding a watchdog because its explicit safety prerequisites are absent.
- Confirmed that Flutter's macOS lifecycle surface reports activation and
  visibility, not system sleep/wake or process suspension.
- Classified all four current typed Onboarding stages as
  unobservable/unbounded for stall purposes; selected graph projection row
  observers are real but are not yet a complete Onboarding progress contract.
- Preserved the distinctions between typed failure, restart interruption,
  prerequisite waiting, and a future evidence-backed stall conclusion.
- Defined the next prerequisite as production-shaped progress/no-event
  measurement plus a tested macOS execution-opportunity adapter.
- Changed no application code, persistence format, presentation, timeout,
  retry, cancellation, or runtime behavior.

## 2026-08-23 - Onboarding real-progress instrumentation

- Added the Feature 28 implementation record for typed, service-owned source
  import, rich-text, and Conversation Graph progress observations.
- Documented the unchanged four-stage Onboarding model and the new typed
  substage vocabulary, exact denominators, completed-work numerators, bounded
  1,000-row durable cadence, same-value deduplication, and safe source-ROWID
  failure context.
- Updated canonical Onboarding, import-coordination, and Presence guidance so
  presentation consumes the durable operation snapshot and never invents
  progress by inspecting repositories or using timers.
- Recorded the truthful coarse boundaries that remain for reset, preparation,
  durable verification, and fast set-based graph work.
- Preserved the liveness conclusion: production-shaped no-observation bounds
  and trustworthy execution-opportunity evidence are still required before
  any watchdog or stall threshold can be justified.
- Recorded clean final verification: 85 focused progress tests, 382
  architecture tripwires, 2,002 complete Flutter tests, clean analyzer and
  formatting checks, and a successful macOS debug build.

## 2026-08-24 - Production-shaped Onboarding liveness evidence

- Profiled a complete 137,360-message first import into a disposable admitted
  development archive using the canonical read-only Messages and Contacts
  source boundaries.
- Recorded the full 48.94-second Journey, per-substage durations, first-progress
  latency, healthy observation gaps, frame responsiveness, database counts,
  snapshot-write volume, and the two remaining coarse relationship projections.
- Documented and corrected unrelated Environment Readiness derived-store reads
  during admitted Onboarding mutation. The correction removed two SQLite busy
  waits, reduced completion from 57.32 to 48.94 seconds, and reduced the worst
  observed frame from about 3.21 seconds to 0.43 seconds without changing graph
  connection authority.
- Preserved the no-watchdog conclusion: enumerable work is human-observable,
  but execution opportunity and healthy variance remain insufficient for a
  mechanical stall threshold; the 8.13-second set-based edge projection needs
  truthful internal evidence first if automated liveness is pursued.
- Recorded that the disposable import and graph stores agree exactly and pass
  SQLite quick checks, while no attachment payload was archived.

## 2026-08-24 - Dependency-aware handle anomaly preservation

- Added the Feature 28 dependency map for handles, chats, messages,
  attachments, reactions, and contacts without creating a generic row-skipping
  policy.
- Codified the distinction between authoritative source-scoped handle identity
  and optional phone/email normalization.
- Documented deterministic opaque-handle preservation, exclusion from alias
  grouping and contact matching, typed anomaly accounting, privacy boundaries,
  and structural failure criteria.
- Updated the canonical identity, data-fidelity, and Onboarding operation
  guides with the rule: preserve source identity and relationships whenever
  interpretation is optional; fail when continuing would make graph truth
  false or structurally incomplete.
- Recorded that no schema, user-facing anomaly surface, or policy for adjacent
  source domains was introduced.

## 2026-08-24 - Dependency-aware source anomaly policy

- Added the Feature 28 implementation record and dependency table for chats,
  messages, rich text, attachments, reactions, Contacts, and relationship
  edges.
- Documented the fixed typed anomaly totals carried through source progress,
  Conversation Graph observations, and the durable Onboarding operation
  snapshot without source payload or per-record persistence.
- Codified canonical recovered/unlinked ownership for structurally valid
  messages without a chat edge, endpoint-validated child-edge omission, and
  optional interpretation degradation without fabricated values.
- Preserved fail-closed boundaries for required identity, message direction,
  source database integrity, and unavailable run-wide rich-text decoding.
- Updated the canonical Onboarding, import/graph, and data-fidelity guidance;
  no schema, completion-state, watchdog, or presentation redesign was added.

## 2026-08-24 - Production-shaped Onboarding anomaly validation

- Recorded a complete 137,363-message disposable first import with exact
  source/graph reconciliation, PII-safe representative evidence, SQLite
  integrity checks, and Feature 27 coverage of 116,623 conversation-linked,
  20,740 recovered, and zero unaccounted messages.
- Classified the observed typed anomaly totals by rate and consequence. Opaque
  handles and unavailable Contacts enrichment were recurrent but structurally
  contained; rich-text and corrected unresolved-reaction outcomes were rare;
  attachment, timestamp, relationship-omission, and fatal counts were zero.
- Documented and corrected a systemic measurement defect caused by comparing
  Apple's `p:` and `bp:` associated-message envelopes as raw GUIDs. Import and
  graph projection now share one source-owned interpretation without changing
  source identity, persistence schema, or completion authority.
- Recorded 45.52-second completion, bounded durable diagnostics, the
  recommendation to keep ordinary success calm while exposing exact totals
  under Details, and one remaining release check: a fresh corrected staging run
  must persist the corrected unresolved-reaction count of 7.

## 2026-08-25 - Corrected Onboarding anomaly validation confirmation

- Recorded a fresh corrected 137,373-message first import in a disposable
  admitted development archive.
- Confirmed that the completed durable operation snapshot persists exactly 7
  unresolved reaction targets with all three typed stages complete and no
  failure.
- Reconciled 137,373 import messages to 137,373 graph messages, including
  116,633 conversation-linked and 20,740 recovered messages with zero
  unaccounted.
- Confirmed exact source/graph edge parity, zero dangling graph endpoints, two
  singular live source registrations, and successful `quick_check` and
  `integrity_check` results for all four archive databases.
- Marked Feature 28 production-shaped anomaly validation complete without
  broadening into Start Fresh, watchdog thresholds, or user-facing anomaly
  presentation.

## 2026-08-25 - Installation classification and preservation-safe Start Fresh

- Added the typed virgin, resumable, completed, abandoned, and
  remediation-required installation classifier, with durable database truth
  taking precedence over stale operation snapshots.
- Recorded the exhaustive persistent-artifact ownership policy and the
  decision to reset only enumerated rebuildable stores inside the admitted
  root rather than invent archive-root rotation.
- Codified preservation of overlays, Presence history, logs, preferences,
  archive identity, and archived attachment payloads.
- Replaced the option-launch reset no-op with classifier-driven startup,
  explicit authorization, mutation admission, and post-reset virgin-state
  verification.

## 2026-08-26 - Guided Environment Readiness and Onboarding handoff

- Replaced the readiness dashboard contract with a typed checking, blocked,
  ready, or failed Episode projection and bounded Details evidence.
- Recorded current Contacts-required pipeline truth and honest local-only
  Messages/iCloud guidance.
- Made first-run Onboarding the temporary owner of canonical sidebar
  visibility without storing or overriding normal user preference.
- Defined verified terminal **OK** as the human handoff that releases Presence,
  opens normal navigation with native animation, and moves focus to the normal
  mode control.
- Clarified in the Track contract that temporary window/sidebar visibility is
  not Track geometry and does not alter page matrices.

## 2026-08-26 - Single-authority typed Onboarding Journey

- Replaced the canonical dual Gate/Presence prerequisite narrative with one
  `OnboardingJourneyCoordinator` transition authority and a sealed typed
  Episode model.
- Documented coherent evidence revisions, dependency-ordered blocker
  selection, explicit commanded transitions, backward evidence transitions,
  and typed human-action gating.
- Recorded FDA, Contacts, local-history, startup, Start Fresh, durable
  operation, terminal acknowledgement, lifecycle, and stale-occurrence
  ownership.
- Marked the production prerequisite Presence host and Schedule authority as
  retired from application composition while preserving laboratory fixtures
  and the read-only Gate compatibility seam.
- Updated the canonical Onboarding and Environment Readiness guides and the
  Feature 28 index.

## 2026-08-26 - Live Onboarding Journey path

- Recorded the seven-node Messages, History, Contacts, Ready, Import, Verify,
  and Start projection of the typed Onboarding Journey.
- Codified coordinator-only authority, truthful backward movement, import-node
  stability, terminal disappearance, accessible narration, and reduced-motion
  behavior.
- Documented the Track audit: full-window Onboarding has no peer columns, so
  its shallow fixed path is a native presentation region rather than a
  semantically false `PageTrackLayoutMatrix`.

## 2026-08-26 - Start Fresh startup-admission correction

- Recorded that startup installation classification is a one-shot process
  admission decision rather than an ongoing application presentation authority.
- Documented the observed post-reset race in which a later transient evidence
  inspection reclaimed an already admitted application.
- Corrected virgin-state terminology so valid empty derived stores are judged
  by consequential durable contents rather than file existence.
- Preserved initial fail-closed startup behavior, persistent-store protection,
  and the existing Start Fresh deletion allow-list.
- Recorded that the verified Start Fresh surface covers the post-frame sidebar
  ownership reconciliation before yielding to the Onboarding presentation.

## 2026-08-26 - Human Journey nodes and durable verification gate

- Audited Messages, History, Contacts, Ready, Import, Verify, and Start against
  the human-Episode criterion.
- Reduced the visible and accessible path to Messages, History, Contacts,
  Ready, Import, and Start while preserving
  `OnboardingVerifyingDurableReadiness` as a mandatory typed internal gate.
- Documented current production-shaped verifier work and timing, the failure
  projection, and the invariant that Start cannot exist before durable proof.
- Clarified in canonical Presence coordination that not every internal state or
  completion predicate is a human Episode requiring presentation.

## 2026-08-27 - Feature 28 final Onboarding conformance

- Corrected the final release-readiness prompt to use the canonical six-node
  Messages, History, Contacts, Ready, Import, and Start human Journey.
- Recorded the final authority, prerequisite, mutation, operation, liveness,
  verification, startup, Start Fresh, preservation, data-fidelity,
  accessibility, and handoff audit.
- Proved that durable verification remains a mandatory internal Coordinator
  gate: Import stays current until proof succeeds, and verification failure
  never exposes Start.
- Classified Feature 28 as ready with bounded non-blockers for watchdog policy,
  unmounted compatibility/laboratory cleanup, and broader anomaly
  presentation.
- Preserved the distinction between the human Journey topology and the richer
  internal Coordinator state machine; no application behavior or database
  schema changed in this pass.

## 2026-08-28 - Completed-installation validation responsiveness

- Recorded production-shaped external-drive evidence separating strict startup
  classification from live graph and attachment catch-up work.
- Documented the rejected concurrent classifier experiment: fail-closed SQLite
  integrity scans remain sequential because parallel scans contend on one
  physical hard drive.
- Recorded the corrected graph-to-attachment mutation boundary, conventional
  attachment candidate policy, off-presentation-isolate hashing, and early
  unsafe-extension rejection.
- Documented the native-flow fallback used only when a Track-enabled sidebar
  rack is observed without its page's resolved matrix during a transient frame.
- Confirmed that no schema, preservation allow-list, source data, or completed
  installation state changed during diagnosis.

## 2026-08-29 - Legacy tester install recognition

- Recorded the exact pre-source-scoped `macos_import.db` v4, `working.db` v3,
  and `user_overlays.db` v3 positive fingerprint and current-artifact absence
  requirements.
- Documented the standalone read-only/query-only SQLite inspection boundary
  and its typed proven, not-legacy, and inspection-failed outcomes.
- Replaced the former broad unmarked-root erase inference with positive legacy
  proof and a non-destructive restricted startup projection.
- Clarified that ordinary Development cannot reproduce the production-only
  native identity gate without unjustified new fixture infrastructure.
## 2026-08-29 - Feature 28 Legacy Tester Compatibility Deletion

- Recorded the exact April-era legacy tester cohort and the two-part deletion
  authority: positive read-only fingerprint plus explicit human authorization.
- Documented the owned-root deletion boundary, external-source exclusion,
  durable crash convergence, canonical virgin verification, and automatic
  handoff to the six-node Onboarding Journey.
- Updated the Feature 28 index and status to remove the generalized Complete
  Erase Settings rollout and identify the low-level root replacement as dormant
  internal infrastructure.

# 2026-08-29 - Tester Distribution Artifact 0.2.99+117

- Added the Feature 28 release verification record for the signed, notarized,
  stapled, and Gatekeeper-accepted `0.2.99+117` production tester DMG.
- Recorded exact production identity, hash, notarization submission, portal
  files, tester instructions, automated evidence, and the unproven external
  publication boundary.
- Updated the Feature 28 index to distinguish verified local release readiness
  from the separate human-controlled website publication step.

## 2026-09-02 - Virgin installation archive-regime audit

- Traced native admission, first marker creation, Dart startup classification,
  provider construction, the six-node Onboarding Journey, and first import.
- Recorded the common cause of the first external tester failures: existing-
  installation preservation remained callable before meaningful existing state
  had been positively established.
- Distinguished first identity creation from archive adoption and first import
  mutation serialization from reset/checkpoint authority.
- Identified preclassification overlay/window-state construction and the
  remaining conditional reset call edge inside fresh first import.
- Defined exact Virgin, Current, legacy tester, and Remediation paths, proposed
  dependency tripwires, and separated near-term corrections from dead Complete
  Erase and retired Presence cleanup.

## 2026-09-02 - Virgin first import and read-only startup classification

- Recorded the dedicated Virgin fresh-import boundary and removal of every
  reset/checkpoint call edge from positively classified Ready to Import.
- Documented the separate failed-installation remediation intent and the rule
  that remediation must reclassify Virgin before Ready can exist.
- Recorded read-only/query-only operation-snapshot inspection and startup
  ordering before persistent logging and completed-only window restoration.
- Preserved first-marker authority, Current startup, exact legacy deletion,
  remediation distinctions, mutation serialization, and attachment safety.
- Explicitly deferred Audit 28 Complete Erase cruft and retired Presence/schema
  cleanup slices.

## 2026-09-06 - Whole-root replacement removal

- Removed Complete Erase as a supported runtime capability and documented the
  permanent named-resource mutation model.
- Reaffirmed Start Fresh as an enumerated reset that preserves archive identity,
  overlay and Presence state, preferences, diagnostics, and archived attachment
  payloads.
- Documented the temporary fail-closed compatibility reader for the obsolete
  Complete Erase journal, including its exact one-file cleanup authority and
  the `0.4.0` plus 2027-09-01 sunset floor.
- Updated current database, Onboarding, and attachment-preservation guidance;
  retained earlier Complete Erase records solely as historical evidence.
