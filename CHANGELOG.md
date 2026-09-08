# Changelog

All notable changes to MessageLens will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

`pubspec.yaml` is the source of truth for the app version. Significant user-facing or tester-facing changes must include both a version bump and a changelog entry in the same change.

## [Unreleased]

### Changed

- Selected Conversation cards now replace their compact activity glyph with
  the shared year-by-month heat map in both the main and Contact-derived
  Conversation lists. Populated months jump within the complete Conversation
  to that month's first message through the existing exact-message indexed
  anchor path; empty and pre-start months remain inert. Mode-aware selected
  surfaces and shared structural outlines keep sparse calendar grids legible
  in both light and dark appearances.

- Removed the obsolete Complete Erase whole-root replacement runtime. Every
  supported mutation now targets named resources, while Start Fresh preserves
  archive identity, durable user state, and archived attachments. A temporary
  fail-closed compatibility reader can remove only the unchanged obsolete
  transaction journal in two mechanically proven stale states; it cannot
  resume erasure, replace identity, or relaunch MessageLens.

- Removed the temporary April 2026 tester-installation fingerprint and its
  special startup/deletion route. MessageLens now treats every meaningful
  non-empty unmarked production root as a generic fail-closed remediation case;
  current owned roots continue through archive identity, per-store schema
  migration, and integrity verification. Preservation-safe Start Fresh remains
  unchanged.

- New-install startup now classifies installation state using read-only SQLite
  evidence before persistent logging or window-state restoration. A proven
  Virgin first import has its own fresh-construction boundary and cannot reach
  derived-data reset or checkpoint authority; inconsistent existing state must
  complete remediation and reclassify as Virgin before Ready can be shown.

- A coherent new production installation now begins first import without
  invoking the destructive, checkpoint-protected message-data reset. Reset is
  still mandatory when canonical environment evidence explicitly identifies
  inconsistent derived state. Onboarding support bundles now also include the
  actual process-local operation failure instead of reporting only the
  reconciled empty-database state.

- A genuinely new production installation now establishes its archive identity
  atomically before Onboarding begins. This bootstrap is permitted only for an
  absent or empty canonical production archive root (with the native instance
  lock allowed); every meaningful non-empty unmarked archive fails closed into
  generic remediation.

- Completed-installation startup and live message catch-up remain responsive
  on production-shaped external archives. Installation integrity inspection
  stays fail-closed and off the Flutter UI isolate; live graph mutation now
  releases its authority before attachment preservation begins, conventional
  attachment hashing runs off the presentation isolate, and opaque payloads
  are excluded before expensive file work. A transient sidebar/page-composition
  mismatch now falls back to truthful native cassette flow instead of asserting
  while a resolved Track matrix is not mounted.

- The first-run Journey path now represents six human-meaningful Episodes:
  Messages, History, Contacts, Ready, Import, and Start. Durable verification
  remains a mandatory typed coordinator gate; while it runs, Import stays
  current and Start remains unavailable, with failures returning to the typed
  Import failure presentation rather than creating a phantom Verify step.

- Start Fresh now hands off to Onboarding without the startup integrity gate
  later reclaiming the window during derived-store recreation. Startup
  admission is latched for the process, while fresh launches still fail closed;
  valid empty current-schema import and graph stores now count as a truthful
  virgin installation rather than an abandoned setup. Its verified operation
  surface also covers the one-frame native sidebar reconciliation, preventing
  the previous Settings sidebar from flashing during the Onboarding handoff.

- First-run setup now includes a compact live Journey path for Messages,
  history, Contacts, readiness, import, and handoff. It follows
  only the typed Onboarding coordinator, moves backward when prerequisite
  evidence regresses, remains stable during record-level import progress, and
  disappears before normal navigation is revealed.

- First-run import now takes visible Journey and sidebar ownership before
  requesting archive-mutation admission, preventing the normal sidebar from
  briefly reopening as maintenance begins. Startup recovery and Start Fresh
  authorization dialogs now use the same light canvas as the subsequent
  onboarding journey instead of a dark surrounding field.

- Onboarding now derives exactly one typed prerequisite, operation, or terminal
  Episode through `OnboardingJourneyCoordinator`. Returning from System
  Settings, dismissing a dialog, or rebuilding a provider cannot independently
  advance setup; Environment Readiness consumes one coherent evidence revision,
  and import remains gated through durable verification and terminal OK.

- Environment Readiness now presents one guided checking, blocker, ready, or
  failed episode instead of a diagnostics dashboard. Successful evidence is
  disclosed under Details, the import action remains above the fold, and
  verified first-run completion now yields through a single OK action to the
  canonical animated application sidebar without persisting a forced sidebar
  preference.

- Installation-state integrity and topology inspection now runs outside the
  Flutter UI isolate. Startup can render progress while inspecting a large
  archive, and Settings can show Start Fresh confirmation immediately from the
  already-established completed state; the service still performs a fresh
  authoritative classification before mutation.

- Advanced Start Fresh now resets the required-sources Presence run through
  Onboarding's executable repository composition, preserving its concrete Test
  Agent bindings. Completed installations no longer fail before derived-data
  reset with a missing `onboarding.messages-source-readable` Agent binding.

- Settings > Reset Message Data now delegates to the preservation-safe Start
  Fresh workflow instead of the retired direct database-reset path. The
  advanced action reclassifies the completed installation, requires explicit
  authorization, preserves preferences, setup history, overlays, and archived
  attachments, runs under Start Fresh mutation authority, and verifies virgin
  state before restarting Onboarding. Once authorization is accepted, a
  process-local operation surface now takes visible ownership before mutation;
  typed failures remain visible with retry or recovery actions, and stale
  asynchronous completions cannot affect a newer Start Fresh occurrence.

- Onboarding now recognizes virgin, resumable, completed, abandoned, and
  inconsistent MessageLens installations from durable evidence. Abandoned
  setups can explicitly Start Fresh by resetting only rebuildable import and
  conversation data; Apple sources, customizations, Presence history,
  diagnostics, archive identity, and archived attachments remain preserved.
  The former option-launch reset control no longer silently does nothing.

- Production-shaped Onboarding validation now interprets Apple's `p:` and
  `bp:` associated-message reference envelopes through one shared,
  source-scoped rule. This removes thousands of false unresolved-reaction
  anomalies while preserving every carrier message and maintaining exact
  current-source coverage.

- Onboarding now applies dependency-aware anomaly handling across Messages and
  Contacts source intake. Structurally valid evidence survives optional
  interpretation failures, unlinked messages retain canonical recovered
  ownership, invalid child edges are accounted without creating false
  relationships, and structural failures still stop completion safely.

- Onboarding now preserves unusual Messages handles under their authoritative
  source-scoped identity when phone/email normalization is unavailable. Their
  chats and messages remain usable, while opaque values cannot acquire false
  alias grouping or contact matches; durable progress records the bounded
  anomaly count without exposing raw identifiers.

- Onboarding Environment Readiness now reports maintenance instead of opening
  derived stores while any archive mutation is admitted. This removes
  readiness-induced SQLite contention and multi-second UI stalls during a
  production-shaped first import without weakening the importing operation's
  graph access.

- Onboarding now reports typed, real completed-work progress while importing
  source records, decoding rich text, and projecting row-oriented Conversation
  Graph data. Progress is persisted at bounded cadence and rendered from the
  durable operation snapshot; coarse operations remain honestly indeterminate.

- Onboarding now persists one typed operation snapshot for initial import,
  reimport, and automatic recovery. Relaunch distinguishes interrupted work
  from active work, top-level failures become terminal typed state, and
  completion requires fresh durable import and graph evidence rather than UI
  progress.

- Message History Coverage now aligns its shared Track title with the report's
  canonical center content column at every supported width. Its status icon and
  explicit headline replace the redundant status eyebrow, while Details now
  adds supporting evidence without repeating the primary count surface.

- Message History Coverage now presents its corrected current-Mac accounting
  as a calm Settings report: one precise conclusion, one compact exact-count
  surface, quiet recovered-message evidence, warning treatment only for real
  unaccounted exceptions, and secondary diagnostics under Details. Its
  Settings menu and center title now share Track A without constraining the
  expanded menu.

- Message History Coverage now reconciles every current Mac `chat.db` row by
  exact source identity against source-1 conversation-graph evidence. Imported
  historical archives no longer contaminate the report, impossible arithmetic
  fails instead of being clamped into success, and admitted maintenance is
  shown as temporarily unavailable without opening protected stores.

- Historical Archives now rejects abandoned folder inspections and imports at
  their asynchronous presentation boundaries, keeps admitted work bound to
  captured source evidence, and removes the superseded generic control-panel
  fallback. Existing chooser and disclosure controls now expose explicit
  accessibility semantics.

- Historical Archives can now recover a preflight-approved batch of missing
  attachment payloads from an admitted same-lineage MessageLens data folder.
  Recovery streams execution-time hashes and real byte progress, installs only
  through the atomic no-overwrite preservation writer under exact mutation
  authority, verifies final physical and metadata truth, and remains safe to
  retry after partial completion.
- MessageLens attachment-recovery preflight now exposes a reconciled forensic
  funnel in development Details, including relationship, identity-match, and
  physical-presence counts. Read-only comparison confirmed that the
  representative donor's zero-recoverable result is correct; normal user
  messaging and recovery authority are unchanged.
- MessageLens attachment-recovery preflight now paints truthful inspection
  state before work begins, compares indexed evidence in bounded batches, and
  reports real phase counts. It no longer hashes every donor payload or repeats
  whole-database integrity scans merely to preview recoverable attachments;
  those exact proofs remain required immediately before future installation.
- Historical Archives now treats selected MessageLens data folders as
  ephemeral attachment-recovery donors rather than durable sources. Documented
  pre-marker formats can reach the same read-only ready state as modern marked
  archives after exact Messages-lineage and per-attachment proof; no donor
  membership, synthetic identity, or source cartouche is created.
- Historical Archives now enables its MessageLens arm for safe, read-only
  attachment recovery inspection. A selected older MessageLens data folder is
  structurally qualified, admitted through the shared Messages-lineage
  authority, and compared with current attachment evidence before exact
  recoverable counts and bytes are shown. Modern marker identity remains
  optional diagnostic evidence. Recovery now proceeds only from that exact
  typed result through the canonical batch executor.
- Attachment preservation now has an atomic no-overwrite installation
  boundary for verified MessageLens archive payloads, mechanically gated by an
  exact-scope archive-mutation capability.
- Historical Archives now proves that a selected Mac Messages folder belongs
  to the current Messages history before registering it or offering import.
  Foreign and unverifiable folders fail closed with distinct explanations.

## [0.2.71] — 2026-08-21

### Changed

- Historical Archives now uses one typed, offline-capable source identity for
  inspection, registration, duplicate detection, persisted membership,
  presentation targeting, removal, and deterministic reimport. Removing an
  imported source no longer requires its external Messages folder to be
  mounted.
- The Historical Archives sidebar action now reads “Choose a Messages Folder
  to add...” so its purpose is explicit.

## [0.2.70] — 2026-08-21

### Fixed

- Historical Archives now keeps one stable center-column Track A-I skeleton
  across hub, selected-source, candidate, import, removal, and notice states.
  Workflow changes alter visible occupancy without changing the page's shared
  geometry contract.

## [0.2.69] — 2026-08-21

### Changed

- Historical Archives now models hub, candidate inspection, selected source,
  import, removal, notices, and orange correspondence as exclusive typed
  presentation states. Invalid combinations such as simultaneous import and
  removal progress or a duplicate notice attached to an active operation are
  no longer representable by the workflow state.

## [0.2.68] — 2026-08-20

### Fixed

- Historical Archives source qualification now uses typed evidence instead of
  display labels, ordinary graph-readiness observation stays out of the
  protected graph during admitted maintenance, and import/removal share a
  neutral graph-projection progress contract without depending on one
  another's operation service.

## [0.2.67] — 2026-08-20

### Changed

- Historical Archives now keeps Narrator and Directed Instrumentation in a
  stable operation layout, gives archive removal phase-specific commentary and
  real graph-rebuild progress, and leaves fully completed import/removal
  evidence visible for 1.5 seconds before returning to the hub.

## [0.2.66] — 2026-08-20

### Fixed

- Historical Archives Narrator commentary now becomes silent once combined
  history preparation finishes, instead of continuing to describe completed
  work during final verification. Directed Instrumentation remains visible and
  unchanged.

## [0.2.65] — 2026-08-20

### Changed

- Historical Archives now explains when import work changes from the selected
  Messages folder to the combined MessageLens history. Existing exact graph
  progress counts remain unchanged while their larger scope is made explicit.

## [0.2.64] — 2026-08-20

### Fixed

- Historical Archives no longer competes with Environment Readiness for the
  source-scoped import ledger while admitted maintenance is active. The
  canonical ledger connection also tolerates brief bounded SQLite contention,
  preventing an otherwise valid folder addition from failing immediately with
  `database is locked`.

## [0.2.63] — 2026-08-20

### Changed

- Historical Archives now gives the neutral Messages-folder chooser explicit
  theme-owned hover and pressed feedback. A fully verified folder addition
  restores the stable archive hub, leaves its new cartouche ordinary and
  unselected, and then presents a concise success acknowledgement over that
  truthful completed state.

## [0.2.62] — 2026-08-20

### Changed

- Historical Archives now paints its import-operation surface before admitted
  database work begins, gives its primary Add action perceptible token-owned
  hover and pressed feedback, and shows exact batched row counts while
  conversations, messages, and attachments are projected. The existing three
  import stages and five graph units remain intact, without estimated or
  elapsed-time-derived progress.

## [0.2.61] — 2026-08-20

### Changed

- Historical Archives now keeps a qualified Mac Messages folder visibly ready
  through incidental execution-gate refreshes, gives immediate feedback when
  import is authorized, reports five real conversation-preparation units, and
  briefly preserves the truthful all-Done state before returning to the hub.
  Cancel now abandons the current candidate without reopening the chooser, and
  successful imports no longer apply an unnecessary orange reference to their
  newly created archive cartouche.

## [0.2.60] — 2026-08-19

### Changed

- Historical Archives now carries a valid Mac Messages folder from inspection
  through explicit authorization, source import, conversation preparation, and
  final verification using Narrator and three truthful live instrumentation
  rows. The legacy giant control panel no longer owns the ordinary import
  journey, partial failures remain retryable without becoming imported-folder
  cartouches, and successful completion returns naturally to the archive hub.

## [0.2.59] — 2026-08-19

### Changed

- Historical Archives removal now presents three truthful live stages for
  removing imported messages, updating MessageLens history, and verifying
  completion. The archive cartouche remains visible but unavailable until the
  complete operation succeeds, and partial failures remain visible instead of
  being mistaken for successful removal.

## [0.2.58] — 2026-08-19

### Changed

- Removing a previously added Historical Archives folder now requires a clear
  destructive confirmation, presents one truthful live removal operation, and
  returns automatically to the empty archive hub once durable imported
  membership disappears. The original Messages folder and unrelated current
  Mac data remain untouched.

## [0.2.57] — 2026-08-19

### Changed

- Historical Archives now uses the shared Track matrix for its fixed upper
  sidebar geometry. The selected-source center story begins at the same
  structural coordinate as the known-folder cartouche list, while both
  variable content regions continue independently below that seam.

## [0.2.56] — 2026-08-19

### Changed

- Selecting a previously added Historical Archives folder now shows a quiet,
  human-readable account of what the folder is and what it contains, while
  leaving its identity in the selected sidebar cartouche. Technical details
  remain available on demand, and the existing confirmed removal flow is
  exposed with the established destructive styling.

## [0.2.55] — 2026-08-19

### Changed

- Historical Archives now renders archive-folder names one typographic step
  below their section heading while preserving metadata, spacing, cartouche
  chrome, and interaction behavior.

## [0.2.54] — 2026-08-19

### Changed

- Historical Archives now separates context, previously added folders, and
  adding a new folder with decisive visual breaks, while preserving compact
  heading relationships and the existing sidebar content and behavior.

## [0.2.53] — 2026-08-19

### Changed

- Historical Archives now gives its three established sidebar regions more
  breathing room, with wider major breaks, easier-to-scan guidance paragraphs,
  and a clearer pause before the unchanged folder chooser action.

## [0.2.52] — 2026-08-19

### Changed

- Historical Archives now uses the compact source labels **Mac Messages** and
  **MessageLens** and presents its Messages-folder instructions as three calm,
  equal-weight notes before the chooser. The future MessageLens source remains
  visibly disabled and inert.

## [0.2.51] — 2026-08-19

### Changed

- Historical Archives now presents a calmer sidebar hierarchy with compact
  **Messages Folders** and **MessageLens Folders** source labels, clear section
  spacing, and scan-friendly Messages-folder guidance before the single folder
  chooser action. The future MessageLens Folders arm remains disabled.

## [0.2.50] — 2026-08-19

### Changed

- Historical Archives now shows its permanent source-type hierarchy with
  **Messages Folders** selected and **MessageLens Data Folders** visibly
  disabled. Messages-folder membership, guidance, and folder selection remain
  the only active workflow, while redundant inner feature labeling has been
  removed.

## [0.2.49] — 2026-08-19

### Changed

- Historical Archives now asks the user to **Add a Messages Folder** and
  explains, before Finder opens, that the folder must contain `chat.db`, may
  have been moved or renamed, and may optionally include message attachments.
  The normal location is shown without exposing a user-specific filesystem
  path.

## [0.2.48] — 2026-08-19

### Fixed

- Historical Archives' gentle orange folder reference now changes intensity
  monotonically. The tint no longer produces a second visual peak while fading
  because every animation frame is composited over the ordinary cartouche
  surface rather than interpolated toward a transparent endpoint.

## [0.2.47] — 2026-08-19

### Changed

- Historical Archives now points gently to a previously added folder after a
  duplicate-folder notice: a light orange correspondence tint fades in, holds
  briefly, and fades completely away without the former pulse or glow. Reduced
  motion uses the same bounded meaning as a calm static treatment.

## [0.2.46] — 2026-08-19

### Changed

- Historical Archives sidebar cartouches now show only durable archive facts:
  a human-readable historical date range, ledger-backed message count, and the
  successful import date when that trustworthy completion fact exists. Dry-run
  workflow evidence and contradictory not-yet-imported wording no longer
  appear in **Folders Already Added**.

## [0.2.45] — 2026-08-18

### Fixed

- Choosing a folder without a Messages archive now ends the add attempt and
  explains the problem in a modal. Historical Archives remains at its empty
  hub without selecting, highlighting, or remembering the rejected folder.

## [0.2.44] — 2026-08-18

### Fixed

- Choosing an archive folder that has already been added now ends the add
  attempt and explains the duplicate in a modal. After dismissal, Historical
  Archives returns to its empty hub and briefly points to the matching sidebar
  folder in orange without selecting it or exposing import and management
  actions.

## [0.2.43] — 2026-08-17

### Changed

- Historical Archives now leaves its center panel empty until the user chooses
  an action. The sidebar's **Folders Already Added** list includes only archives
  with positive source-scoped imported message truth, so remembered preflight
  or removed sources no longer appear as if they were currently part of
  MessageLens. Existing-source details retain message and date facts without a
  redundant imported-status row.

## [0.2.42] — 2026-08-17

### Changed

- Historical Archives now opens as a neutral hub. Explicitly selecting a known
  archive gives it the canonical blue sidebar selection and opens a
  source-management context, while add-flow recognition remains a distinct
  orange cross-UI reference. Leaving Historical Archives clears transient
  selection and recognition state, and delayed inspection results cannot
  restore an abandoned presentation session.

## [0.2.41] — 2026-08-17

### Changed

- Historical Archives now keeps archive navigation in the sidebar and the
  active archive journey in the center panel. Known sources open by canonical
  identity, active journeys hide the competing sidebar add action, and fresh
  recognition of the same imported archive receives a new calm acknowledgment
  and referential pulse. Historical Archives and All Messages now share the
  same legible orange correspondence appearance while retaining independent
  event ownership.

## [0.2.40] — 2026-08-17

### Fixed

- Historical Archives now recognizes a selected archive that already has
  source-scoped imported messages, states that truth directly, and points to
  the matching known source with the existing orange referential signal. The
  import action is withheld, and source comparison counts now use distinct
  GUIDs on both sides so duplicate graph observations cannot produce
  impossible human-facing arithmetic.

## [0.2.39] — 2026-08-17

### Changed

- Historical Archives now opens with a calm Narrator-led journey for choosing,
  inspecting, rejecting, or approving an older Messages archive. Current
  inspection evidence replaces the permanent control-panel stack, while paths
  and technical diagnostics remain available under collapsed Details.

## [0.2.38] — 2026-08-17

### Fixed

- Historical archive import and removal can now construct the Conversation
  Graph resources they legitimately require after acquiring mutation
  authority, while unrelated readers remain mechanically excluded. Active
  archive maintenance no longer masquerades as graph failure or redirects the
  app into onboarding.

## [0.2.37] — 2026-08-16

### Fixed

- Historical Messages archives using Apple-epoch seconds now retain their
  actual dates during source-scoped import and graph projection. Archive
  preflight and import share the same canonical `DateConverter` normalization,
  while modern Apple-nanosecond timestamps remain unchanged.

## [0.2.36] — 2026-08-15

### Fixed

- Existing installations can now adopt the truthful Messages-source onboarding
  branches without redefining persisted FDA instruction Step 6302. Presence
  history and active Trip checkpoints remain intact, and canonical definition
  mutation is still rejected.

## [0.2.35] — 2026-08-15

### Fixed

- Messages-source onboarding now enters Full Disk Access remediation only for
  explicit permission-denial evidence. Missing, invalid, and otherwise
  unusable sources receive calm source-specific guidance and a fresh retry.

## [0.2.34] — 2026-08-15

### Fixed

- Automatic setup recovery now defers silently while another archive mutation
  is active, rechecks current environment truth when mutation authority becomes
  idle, and resumes only if recovery is still required. Denied work no longer
  loops or briefly displays recovery progress before admission.

## [0.2.33] — 2026-08-15

### Fixed

- Setup preparation and automatic-recovery failures now remain visible in the
  current process with calm **Try Again** and support actions instead of
  disappearing behind environment re-evaluation. Retry starts a fresh ordinary
  setup attempt; refresh and restart still derive truth from current files and
  probes.

## [0.2.32] — 2026-08-15

### Changed

- Automatic setup recovery now uses calm, phase-neutral wording that explains
  MessageLens found incomplete browsing data, is preparing another setup
  attempt, and requires the human to wait. It no longer implies a previous
  launch, broad local-data deletion, or an automatic setup restart.

## [0.2.31] — 2026-08-14

### Changed

- Automatic setup recovery no longer exposes import-ledger, Conversation-
  Graph, or projection heuristics in the ordinary recovery surface. The
  diagnostic reason remains available to classification, logs, development
  tooling, and support evidence; recovery behavior is unchanged.

## [0.2.30] — 2026-08-14

### Changed

- Calendar heatmaps and Conversation activity glyphs now share a discrete,
  two-regime activity scale: neutral greys distinguish sparse months, while
  sustained activity progresses from yellow through green, teal, blue, and
  deep purple. The complete legend now reflects the actual logarithmic-style
  bins, and month selection preserves the encoded activity fill.

## [0.2.29] — 2026-08-14

### Changed

- Stable setup failure screens now present only the failure orientation, retry
  action, and **Send Report To Developer** action. The redundant pre-action
  email/Finder explanation is gone, while report transport and all
  result-specific feedback remain unchanged.

## [0.2.28] — 2026-08-14

### Changed

- Stable setup failure screens no longer display the implementation-facing
  **Environment summary**. Retry and support actions remain visible, all probe
  and failure evidence remains in support reports, and readiness/FDA uses of
  the summary are unchanged.

## [0.2.27] — 2026-08-14

### Changed

- Stable setup failure screens no longer expose raw exceptions, timestamps,
  unsupported phase/launch claims, or duplicate support instructions in a
  **What to check** card. Diagnostic evidence remains available in support
  reports, while retry and support actions are unchanged.

## [0.2.26] — 2026-08-14

### Changed

- Stable setup failure screens now use one calm, phase-neutral heading and
  explanation instead of asking the human to distinguish import from graph
  preparation. Existing retry actions, support reporting, and diagnostic
  details remain available and unchanged.

## [0.2.25] — 2026-08-14

### Fixed

- Setup and direct-reimport progress now show one bounded, phase-neutral
  failure headline during controller-to-Gate handoff instead of exposing raw
  exception text. Full diagnostic errors remain available to logging,
  persistence, and support reporting.

## [0.2.24] — 2026-08-14

### Changed

- Successful initial setup and direct reimport now end with a calm
  **MessageLens is ready** handoff instead of exposing import, projection, and
  text-enrichment counters. The existing **Get Started** and **Done** actions
  retain their behavior, and diagnostic build reports remain available outside
  the primary completion surface.

## [0.2.23] — 2026-08-14

### Fixed

- First-run setup now displays the existing **Preparing setup…** progress
  surface while derived browsing data is reset, instead of leaving the import
  action apparently idle. Reset failure restores the existing readiness
  surface, and stale prior build results no longer mislabel preparation.

## [0.2.22] — 2026-08-14

### Changed

- Active first-run and rebuild progress now asks the human to keep MessageLens
  open while confirming that other applications may be used. The operation
  remains coarse, indeterminate, and explicitly non-cancellable.

## [0.2.21] — 2026-08-13

### Fixed

- Completing required-source onboarding after accepting sparse local Messages
  history now reveals the existing **Import My Messages** action and preserves
  that handoff across restart. Environment facts remain unchanged, and import
  still runs through the existing Onboarding gate.

## [0.2.20] — 2026-08-13

### Changed

- Production required-source onboarding now runs generic Tell, Test, fixed
  destination, and finite Choice Steps through the permanent Presence runner.
  Full Disk Access opening remains an explicit Onboarding-owned specialist
  integration, while import and graph construction remain owned by the
  existing Onboarding gate.

## [0.2.19] — 2026-08-13

### Added

- The Presence onboarding experiment now checks whether local Messages history
  is sufficiently populated. Sparse history receives calm guidance and a
  generic persisted choice to re-check a fresh source fact or continue with
  the currently available history.

## [0.2.18] — 2026-07-28

### Fixed

- Delayed attachment retry now revisits conventional attachments with declared
  MIME types, including video, audio, PDF, and document files, rather than
  limiting recovery to images. Opaque NULL/blank-MIME payloads remain excluded
  pending an explicit preservation policy.

## [0.2.17] — 2026-07-28

### Fixed

- Production archive adoption now accepts legacy overlay databases whose schema
  version predates already-completed retired-column cleanup. Overlay migrations
  remove retired columns only when they are present, preserving existing user
  intent while allowing the adopted archive to open normally.

## [0.2.16] — 2026-07-27

### Added

- MessageLens now admits each process to an explicitly identified production,
  development, or test archive before constructing persistent providers.
- High-risk archive mutations use one reentrant operation authority, and
  production maintenance can require a verified checkpoint receipt.
- Offline checkpoint tooling can inventory, hash, integrity-check, restore, and
  compare a disposable archive without using the active production archive.

### Changed

- Debug and Profile macOS builds now use the distinct
  `com.bigbenchsoftware.MessageLens.development` identity and the
  `MessageLens Development` product name. Production keeps its existing bundle
  identity, signing contract, archive location, and Full Disk Access continuity.
- All app-owned databases, attachments, logs, operational evidence, and window
  state now derive their paths from admitted archive authority.
- Development machines may select one complete machine-local archive root
  without creating attachment-specific path authority. Native and Dart
  admission must agree on the canonical external directory, and startup fails
  closed if it is unavailable.

### Security

- Development and tests fail closed instead of falling back to the production
  archive. The production packaging script verifies production archive
  metadata before signing and verifies identity, signature, and entitlements
  before packaging.

## [0.2.15] — 2026-07-26

### Changed

- Contacts now aligns its sidebar menu with the effective center-panel title
  through one shared page Track. Contact messages, recovered contact evidence,
  and selected Conversation evidence retain their feature-owned presentations,
  while both columns resume independent layout immediately below the title row.
- Recovered Deleted Messages and Recovered No-Handle Messages now align their
  sidebar menu and center-panel title in one shared page Track. Both columns
  resume their own native layout immediately afterward, avoiding false
  alignment between sidebar guidance and center evidence controls.

## [0.2.14] — 2026-07-26

### Fixed

- Incremental message imports no longer stop when overlapping AddressBook
  validation probes close. Each read-only probe now owns an isolated SQLite
  handle, allowing the change monitor to import newly detected Messages rows
  instead of repeatedly aborting the graph build with `database_closed`.
- macOS now admits only one ordinary MessageLens process into Flutter and
  database startup. A duplicate launch activates the existing instance and
  exits, preventing separately launched app copies from competing for writable
  graph, import, or overlay databases.

## [0.2.13] — 2026-07-24

### Fixed

- Unknown Sources investigation controls and source lists now continue
  immediately below the shared page identity row. Selecting, clearing, or
  dismissing a source no longer moves the sidebar when transient center-panel
  detail tracks expand or collapse.

## [0.2.12] — 2026-07-21

### Changed

- Unknown Sources center panels now retain a stable Messages identity derived
  from the active investigation. Selecting a source changes the subject beneath
  that identity, while idle states use the evidence region to explain what the
  current category contains and how it can be reviewed.

## [0.2.11] — 2026-07-20

### Changed

- Unknown Sources now retains a truthful center-panel investigation when no
  source is selected. Identify and Numeric IDs render their own quiet idle
  guidance instead of dropping the center ViewSpec and collapsing the page
  matrix; selecting or dismissing a source transitions between explicit idle
  and selected-source targets within the same Messages-owned presentation.

## [0.2.10] — 2026-07-20

### Fixed

- Dismissing an unfamiliar source now removes only that source from the loaded
  sidebar projection without replacing the list with a loading state. A
  successful dismissal also advances unfamiliar-source investigation
  provenance, so the dismissed source's center evidence becomes incompatible
  and disappears immediately.

## [0.2.9] — 2026-07-20

### Fixed

- The unfamiliar-source `Dismiss` action now uses the recoverable dismissed
  source workflow instead of merely marking the source reviewed. Source
  identity and Create/Link/Dismiss semantics are centralized behind Handles,
  while the complete message-evidence presentation remains Messages-owned.

## [0.2.8] — 2026-07-20

### Changed

- Unfamiliar-source review now uses the shared cross-column matrix: the sidebar
  top menu aligns with the selected source title, source details and controls
  occupy explicit center cells with visible breathing room, and the remaining
  cassette list begins level with the message evidence list.

## [0.2.7] — 2026-07-20

### Fixed

- Unfamiliar-source center evidence now carries opaque investigation
  provenance. Changing Identify/Numeric IDs, endpoint type, or Active/Dismissed
  makes evidence from the previous investigation mechanically incompatible, so
  stale Phone messages cannot persist beneath an Email or Numeric IDs list.

## [0.2.6] — 2026-07-19

### Changed

- Unfamiliar-source review now separates identity discovery from numeric sender
  ID review. Short codes are classified neutrally by endpoint shape, cannot
  enter the source-identification list, and no longer receive an unsupported
  `SPAM` verdict.
- Source-identification rows now focus on opening evidence and no longer carry
  routine per-row dismissal buttons. Dismissal remains available in the source
  evidence context, with overlay-backed recovery preserved.

## [0.2.5] — 2026-07-19

### Fixed

- Unfamiliar-source rows now use the full sidebar content lane while retaining
  their dedicated dismiss-action rail, preventing dates from being cropped and
  keeping the dismiss button aligned at the trailing edge.
- Unfamiliar-source message badges, timelines, hydrated rows, and in-scope
  searches now use the same canonical sender relationship, so sender-only
  evidence remains visible even when Apple Messages supplied no chat-membership
  edge.

## [0.2.4] — 2026-07-19

### Changed

- Canonical local-account identity now appears consistently in the first
  person across ordinary Conversation, Contact, handle, and message-evidence
  presentation: `Me` for participants, `me` in prose metadata, and `self` for
  self-only relationships. Personal contact names and local endpoints remain
  available only where identity or handle provenance is explicitly inspected.

## [0.2.3] — 2026-07-19

### Fixed

- Message evidence metadata now states direction and counterpart clearly as
  `received from <sender>` or `from me to <Conversation>`, instead of showing
  the ambiguous `received | ...` and incorrect `from me | me` labels.
- Messages in self-conversations now use the single metadata label `self` for
  both directions. MessageLens derives this from local account handles in the
  Messages source rather than comparing display names.
- Existing conversation graph databases now migrate their handle schema before
  self-conversation reads begin, preventing `no such column: h.is_me` failures.
- Startup now reconciles historical local-account handles from Apple Messages
  account and incoming-destination evidence, then projects only changed
  identity annotations. Existing self-conversations therefore acquire the
  `self` label without reimporting message history.

### Changed

- The right panel is now titled `Conversation excerpt` and identifies the
  selected message's month and year before the evidence begins, making temporal
  movement from broad Search results into Conversation context immediately
  visible. The temporal heading uses the established orange organizing-value
  accent, while the redundant `21-message excerpt...` caption has been removed.
- Every eligible All Messages row now offers `In conversation`, including
  ordinary and month-browsed messages outside text-search results.

## [0.2.2] — 2026-07-18

### Fixed

- Search query, mode, and heatmap changes now derive Conversation-context
  visibility from opaque investigation compatibility, preventing stale excerpts
  from overriding the current message evidence while preserving restorable
  stored context.

### Changed

- Search All Messages now presents a structurally aligned investigation status
  row, with delayed activity feedback for searches that take noticeable time
  and stable geometry when results complete. Its text now aligns with the
  visible Search-field edge, with explicit matrix spacing separating the rows.

## [0.2.1] — 2026-07-16

### Added

- Added the Search-page cross-column layout matrix so the Search, Messages,
  and Conversation workspaces negotiate one responsive vertical rhythm.
- Added developer diagnostics for inspecting resolved matrix cells and Track
  geometry across all three columns.

### Changed

- Search-page layout composition now lives in one explicit matrix, with
  feature-owned presentation metrics, placement-independent occupants, and
  complete cell-based rendering.
- Optional Conversation-panel content now preserves stable resting geometry
  before it appears, while larger live content can still expand the shared
  layout naturally.

### Fixed

- Opening the Conversation panel no longer causes the Search header controls
  and message results to jump from collapsed Track geometry.
- The sidebar top selector now opens its choices in an anchored overlay instead
  of overflowing its resolved cell and blocking page interaction.

## [0.2.0] — 2026-06-30

### Added

- MessageLens now uses the source-scoped conversation graph as the ordinary production data path for conversations, contacts, search, message evidence, attachments, and live updates.
- Added conversation-first navigation with graph-backed conversation signatures, favourites, participant-aware filtering, and shared message evidence views.
- Added graph-backed historical Messages archive import with preflight, dry-run estimates, import safety copy, source-scoped identity, and developer-gated archive removal controls.
- Added release readiness surfaces for Full Disk Access, source Messages data, AddressBook data, graph data, overlay storage, attachment archive storage, graph build state, and live update state.
- Added release smoke tooling with `tool/release_smoke.sh` and a manual real-data smoke checklist.

### Changed

- Message evidence now renders through one shared spine and header across contact, conversation, search, unfamiliar-source, recovered, and archive-derived scopes.
- Live message intake now updates the graph directly without ordinary `working.db` updates.
- Attachment evidence now resolves through graph topology plus overlay archive metadata, with visible fallback evidence when files are unavailable.
- Retired `macos_import.db` and `working.db` are treated as transitional cleanup/diagnostic storage rather than ordinary app authority.

### Fixed

- Contact and conversation labels now prefer user-assigned display names consistently before falling back to imported names or raw handles.
- Contact timelines preserve full-scope heatmap navigation while hydrating only visible message rows.
- Rich text enrichment for new messages is bounded to newly imported rows, restoring fast single-message intake while preserving decoded text.

## [0.1.16] — 2026-04-27

### Changed

- Settings now uses clearer subsection styling in the top menu, making grouped actions and persistent settings easier to scan in one flat list.
- The chosen-contact messages sidebar now reads as a calmer sequence of selection, context, explanation, controls, and visualization, with shared spacing and grouped-control chrome instead of feature-local layout tweaks.
- Support and Send Logs email drafts now target `messagelens@gmail.com`, keeping tester feedback routed to the shared project inbox.

### Fixed

- Window size now stays stable when moving MessageLens between monitors, instead of snapping to a smaller preset-looking frame on one display and expanding again on the other.
- Window placement restore now persists the intended size across sessions, preventing relaunches from restoring the old top-left position with an unexpectedly oversized window.

## [0.1.15] — 2026-04-26

### Added

- Settings now includes a Message History Coverage report with a durable sidebar selection and a derived center-panel report so testers can review coverage status in a stronger, more readable report surface.

### Fixed

- Transient Settings actions such as `Send logs…` and `Reset message data…` now fully replace the visible Settings child flow and no longer restore an older durable Settings child after switching away from Settings and back.

## [0.1.14] — 2026-04-25

### Added

- MessageLens now records structured import and migration pipeline incidents in a dedicated diagnostic layer, exports them with support bundles, and can show a direct center-panel failure page with a one-click “Send Report To Developer” action when a blocking pipeline failure occurs.

### Fixed

- Automatic import and migration diagnostics now surface post-onboarding pipeline failures inside the app instead of relying on users to navigate to the sidebar troubleshooting flow before sending logs.

## [0.1.13] — 2026-04-24

### Fixed

- Reset Message Data now refreshes onboarding after the completion dialog so testers are guided back into the reimport flow instead of being left on the settings reset panel.
- macOS startup no longer blocks the app shell on a redundant window-state load that could leave VS Code debug launches stuck on a black screen.

### Added

- Support bundles now include targeted reset-to-onboarding diagnostics so tester logs show when the databases were deleted, when the onboarding gate reclassified the environment, and when the readiness panel was shown.

## [0.1.12] — 2026-04-23

### Added

- Added a standalone MessageLens tester portal foundation under `web/tester-portal/` with centralized CSS palette tokens and shell styling for navigation, cards, links, buttons, and footer surfaces.

## [0.1.11] — 2026-04-22

### Fixed

- `chat_to_handle` migration validation now counts distinct final canonical memberships after handle alias collapse, so datasets with normalized handle variants like `citycenter` and `city center` no longer fail onboarding just because multiple source handles project to one canonical chat membership.

## [0.1.10] — 2026-04-19

### Changed

- Reset Message Data no longer quits the app after clearing the MessageLens databases. After the reset completes, the final dialog now dismisses back to the onboarding reimport panel already shown underneath.

## [0.1.9] — 2026-04-19

### Changed

- Reset Message Data now uses a two-dialog flow: the settings cassette shows only the destructive reset action, a pre-reset confirmation explains exactly what will and will not be deleted, and a final quit dialog appears only after the MessageLens databases have been cleared.

## [0.1.8] — 2026-04-19

### Changed

- Reset Message Data now shows a final completion dialog after the derived databases are deleted and waits for an explicit `OK` before quitting, making the forced quit and first-launch-style reimport path explicit.

## [0.1.7] — 2026-04-19

### Fixed

- Incremental message migrations now preserve declared migrator order for equally ready steps, preventing failed later migrators from leaving `chat_to_handle` empty and contact timelines stuck behind the latest imported messages.

## [0.1.6] — 2026-04-19

### Changed

- The settings sidebar now separates stable durable projection from ephemeral temporary flows, so one-off actions like `Send logs…` and `Reset message data…` no longer persist as if they were durable settings context.
- Durable settings context now rebuilds from flow state through local stable topology decisions, keeping `Text size…` and `Image size…` as persistent settings choices while temporary settings actions stay out of stable settings reconstruction.
- Sidebar topology and tests now enforce the stable-first then ephemeral-second projection model, including replace-only ephemeral settings flows and stable reconstruction from durable state.

## [0.1.5] — 2026-04-17

### Changed

- Settings now uses a single flat top menu with inert section headers and direct action choices instead of the previous nested submenu structure.
- Settings troubleshooting now routes through dedicated settings-owned cassettes, including a guided `Send logs…` flow and a `Reset message data…` flow that preserves user preferences and quits after reset.

### Added

- Appearance placeholders for `Text size…` and `Image size…` are now available from the flat settings top menu as direct action selections.

## [0.1.4] — 2026-04-17

### Added

- Diagnostic export now produces a support bundle that can include a privacy-safe `database_health.json` structural audit of the app-owned databases.

### Changed

- “Send Logs” and onboarding failure report flows now reveal or attach the support bundle instead of only a standalone diagnostic log file.

## [0.1.3] — 2026-04-16

### Added

- Holding Option at launch on macOS now opens a startup recovery dialog before normal app flow continues.
- The startup recovery dialog can export a diagnostic email draft with the app log plus import and migration audit logs when present.

## [0.1.2] — 2026-04-15

### Fixed

- macOS release builds now bundle and sign the Rust message-text extractor so fresh imports can decode `attributedBody` content instead of leaving nearly all messages blank.
- URL preview cards now receive the decoded message text they depend on, preventing false "Message does not contain a URL" placeholder errors after a clean import.

## [0.1.1] — 2026-04-15

### Fixed

- Handle canonicalization now uses a shared normalization contract across import and migration so the same real-world participant does not split into separate canonical handles.
- Onboarding now detects stale partial app-database state and automatically resets incomplete app databases before asking the user to retry setup.

## [0.1.0] — 2026-03-12

First build sent to testers.

### Added

- Full Disk Access gate — app detects missing FDA on first launch and walks the user through granting it in System Settings
- Data import onboarding — imports Messages and AddressBook databases on first run with progress overlay
- Reimport from Settings — "Reimport Data" action in Settings sidebar re-runs the full import pipeline
- Abort import — user can cancel an in-progress import
- Sidebar navigation with Messages, Contacts, and Settings modes
- Contact list with display name overlay merging (working DB + user overlays)
- Chat message viewer
- Dark mode support with semantic color tokens
- Developer panel for onboarding diagnostics
- Notarized and stapled DMG distribution via `tool/build_and_notarize.sh`
