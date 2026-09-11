# Changelog

All notable changes to MessageLens will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

`pubspec.yaml` is the source of truth for the app version. Significant user-facing or tester-facing changes must include both a version bump and a changelog entry in the same change.

## [Unreleased]

No unreleased changes yet.

## [0.2.37] — 2026-09-11

### Added

- Message search now uses responsive word-prefix matching while a word is being
  typed and exact whole-token matching after whitespace, including completed
  one-character terms. FTS5 searches visible message text only, while message
  tags remain a separate participating search domain.

### Fixed

- Search fields now preserve the first trailing space immediately, eliminating
  the need to press Space twice, and highlighting follows the same prefix and
  exact-token rules as result selection.
- AND and OR now mean **Match all terms** and **Match any term** across visible
  message text and tags. Saved-message filtering remains mandatory in either
  mode.
- Search now composes and filters the complete candidate set before selecting
  the final 500 newest results. Nonmatching rows no longer remain visible in
  Handle Messages or Handle Lens, and result counts agree with displayed
  membership.
- Ordinary message-text queries no longer produce hidden matches from message
  identifiers, sender metadata, or semantic classification fields.

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
