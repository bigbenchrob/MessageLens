The recommended policy is:

```text
fail-closed archive admission
→ render a restricted Flutter startup shell
→ bounded structural checks
→ logical installation classification
→ normal app only when admitted
→ quick_check only when evidence is suspicious
```

This preserves the important safety boundary while removing whole-file integrity scans from every healthy launch.

## 1. Current startup pipeline

| Operation | Purpose | Mutates? | Must precede rendering? | Measured cost |
|---|---|---:|---:|---:|
| Native build/archive claim | Validates environment, bundle identity, signing and canonical root | No | Yes | <1–41 ms |
| Single-instance claim | Prevents two MessageLens processes using one archive | Creates/locks the instance-lock file | Yes | 100–388 ms |
| Flutter controller/plugins | Starts Flutter engine and platform channels | No database mutation | Yes | 109–122 ms |
| Dart archive admission | Revalidates native claim and validates/creates archive marker | May create the first marker | Yes | 208–326 ms |
| Legacy erase-journal compatibility | Prevents continuation through an unresolved destructive operation | May delete only a proven-stale journal | Yes | Cheap when absent; potentially a full evidence scan when present |
| SQLite FFI | Enables desktop SQLite | No | Before database probing | 2 ms |
| Rust library | Supports URL-preview parsing | No | No; only before URL parsing | 20–25 ms |
| macOS window configuration | Applies window style | Window-only | Preferably before first frame | 10–20 ms |
| Startup flags | Reads option-launch state via method channel | No | Before deciding startup UI | 2–4 ms |
| MediaKit | Initializes media runtime | No database mutation | No; defer until normal admission | ~3 ms |
| Provider container | Injects archive authority and brightness | No | Before `runApp` | ~2 ms |
| Installation-state provider | Reads and classifies four databases | No | Must finish before normal app, but not before startup shell | **11.7–12.6 s** |
| Logger initialization | Opens persistent log output | Yes, log files | After safe classification | ~6 ms |
| Overlay/window restoration | Opens Drift overlay and restores geometry | May create/migrate/index overlay DB | After validation | ~110 ms |
| `runApp` → first frame | Creates Flutter UI | No DB mutation itself | — | 128–132 ms |

The controlling await is [main.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/main.dart:277). The provider calls the reader at [message_lens_installation_state_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/application/message_lens_installation_state_provider.dart:12).

The existing `StartupApp` already has a loading surface at [main.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/main.dart:421), but the provider is awaited before `runApp`, so users cannot see it.

### Worst cases

- External-volume filesystem operations have no application-level timeout.
- Each SQLite connection has a three-second busy timeout, potentially adding contention delay per database.
- `quick_check` duration is proportional to database size and has no application timeout.
- If the obsolete erase journal is present, archive admission itself invokes the full evidence reader and may later be followed by a second classification read.

## 2. Classification of current checks

| Check | Classification | Recommendation |
|---|---|---|
| Archive environment/root/signature validation | Cheap, every launch | Keep pre-render |
| Native single-instance lock | Cheap, every launch | Keep pre-render |
| Archive marker parsing and identity validation | Cheap, every launch | Keep pre-render |
| Legacy-journal existence check | Cheap, every launch | Keep pre-render |
| File existence and non-zero size | Cheap, every launch | Keep |
| SQLite read-only open and `query_only` | Cheap normally, every launch | Keep |
| `PRAGMA user_version` | Cheap, every launch | Keep |
| Required-table/object inventory | Cheap, every launch | Keep and modestly strengthen |
| Operation-snapshot read/parse | Cheap, every launch | Keep |
| Non-live-source detection | Cheap because `source_registry` is small | Keep, preferably as `EXISTS` |
| Exact import/graph message counts | Moderate | Run after first frame; retain until a safer bounded substitute is proven |
| Graph chat and edge `COUNT(*)` | Redundant overprecision | Replace with `EXISTS`; classifier only needs `> 0` |
| Full `quick_check` on every database | Expensive | Suspicion-only |
| Second overlay open for operation snapshot | Redundant | Read snapshot through the first inspection connection |
| Explicit Dart claim validation immediately before service revalidation | Redundant but negligible | Optional later cleanup |
| Rust and MediaKit before startup shell | Unnecessary on critical path | Defer |
| Persistent logger/window restoration before first frame | Moderate and potentially mutating | Move after database admission |

Supplementary immutable read-only probes found:

- Existing import count queries: 2.45 seconds.
- Existing graph count queries: 0.85 seconds.
- Proposed bounded import checks: 0.61 seconds.
- Proposed bounded graph/FTS checks: 0.10 seconds.

Those are current-cache observations, not guaranteed startup benchmarks, but they confirm that exact counts should not be treated as free.

## 3. What `quick_check` protects

SQLite documents `quick_check` as an O(N) low-level consistency scan. It checks most of what `integrity_check` checks, except UNIQUE constraints and whether index contents agree with table contents. Neither check detects foreign-key violations; that requires `foreign_key_check`. See the official [SQLite PRAGMA documentation](https://www.sqlite.org/pragma.html#pragma_quick_check).

It detects latent problems in database pages that ordinary startup queries never touch, including malformed records, missing or multiply-owned pages, ordering problems, freelist corruption, and some constraint violations.

It does not prove:

- import and graph contain the same logical records;
- foreign keys are valid;
- indexes agree semantically with their tables;
- FTS external-content rows agree with `messages`;
- user data is semantically correct;
- a completed import was logically complete.

### Per database

| Database | Additional protection from `quick_check` |
|---|---|
| `user_overlays.db` | Finds latent physical corruption in user-intent, archive-metadata and settings tables not touched by startup |
| `macos_import_ss.db` | Traverses the whole derived import ledger, including tables not involved in startup classification |
| `working_ss.db` | Traverses graph tables and FTS shadow-table storage; does not prove the FTS index matches `messages` semantically |
| `presence.db` | Finds latent corruption in schedule definitions, checkpoints and execution trace tables not touched by the two required-table checks |

Overlay and Presence deserve the most conservative failure treatment because they contain durable, non-rebuildable state. Import and graph are derived stores, but historical-source evidence means they still cannot always be reset automatically.

## 4. Safety already provided by cheaper checks

The current cheaper checks already detect:

- wrong build/environment/archive root;
- invalid production signature;
- malformed or wrong-environment archive marker;
- missing database files;
- zero-byte files;
- invalid SQLite headers and many immediately accessible-page failures;
- unsupported future schema versions;
- missing critical tables;
- malformed onboarding-operation metadata;
- databases that fail targeted reads;
- absent graph topology;
- exact import/graph message-count disagreement;
- incomplete or interrupted onboarding;
- incomplete installations containing historical sources;
- presence of retired derived artifacts.

Therefore, removing `quick_check` from the normal path does not remove archive admission, schema compatibility, logical onboarding classification, or partial-installation detection. The lost protection is specifically proactive discovery of latent physical corruption in untouched pages.

## 5. Proposed healthy-launch gate

### Common checks for every existing database

1. Confirm the expected path exists and is non-zero.
2. Open it using the existing one-off read-only SQLite boundary.
3. Set `query_only`.
4. Read `user_version`.
5. Require the current version for the uncomplicated fast path.
6. Inventory required schema objects through `sqlite_master`.
7. Execute bounded `SELECT 1 … LIMIT 1` reads against critical tables.
8. Close the connection without creating WAL/SHM files.

A known older schema should not be treated as corrupt, but it should leave the fast path because opening the normal provider may migrate it.

### Database-specific checks

- `user_overlays.db`
  - Require `overlay_settings` and critical preservation tables.
  - Read and parse the onboarding-operation snapshot on the same connection.
  - Absence is acceptable where existing installation semantics permit creating a new overlay.

- `macos_import_ss.db`
  - Require `messages` and `source_registry`.
  - Determine empty/non-empty with a bounded row read.
  - Detect non-live sources using `EXISTS`, not a full count.
  - Optionally read the highest `ss_id` through the primary key.

- `working_ss.db`
  - Require `messages`, `chats`, `chat_to_message`, `message_text_fts`, and the expected FTS triggers for schema 3.
  - Use bounded reads to establish message, chat and edge presence.
  - Execute a bounded FTS read so a missing/unreadable FTS object escalates.
  - Optionally compare its highest message `ss_id` with import.

- `presence.db`
  - Require `schedule_definitions` and `schedule_runs`.
  - Execute bounded reads against both.

### Cross-store gate

Normal application admission requires either:

- a coherent virgin state; or
- both derived stores at current schema, readable, structurally present and logically plausible.

For the first implementation, I recommend retaining exact import/graph message-count reconciliation after the first frame. Replacing that equality test with high-water marks alone should wait until source-scoped identity parity and interrupted incremental-update behavior are formally proven.

## 6. Exact escalation triggers

| Trigger | Response |
|---|---|
| Archive marker/root/environment/signature mismatch | Fail immediately; do not inspect or open app databases |
| Legacy erase journal present | Keep the existing fail-closed compatibility flow |
| Zero-byte or non-SQLite file | Remediation/manual diagnosis; a deep check may be impossible |
| `SQLITE_BUSY`/`LOCKED` | Show contention state and allow retry; do not mislabel it as corruption |
| `SQLITE_CORRUPT`, `NOTADB`, or unexplained I/O failure | Deep-check the implicated database if it can be opened |
| Schema version greater than supported or version 0 | Stop; a deep check cannot make the schema supported |
| Known older schema | Deep-check that database before permitting a writable migration |
| Required object missing at current schema | Deep-check implicated database, but do not continue merely because it reports physically healthy |
| Bounded query failure | Deep-check implicated database |
| FTS table/trigger missing or unreadable | Graph/FTS-specific diagnostic path |
| Import/graph population, high-water or exact-count mismatch | Deep-check both derived stores |
| Malformed onboarding snapshot | Deep-check overlay, then require manual/recovery classification |
| Snapshot says running/interrupted/failed | Deep-check stores involved in that operation and enter existing recovery semantics |
| Completed snapshot contradicts durable facts | Deep-check both derived stores and stop normal admission |
| Previously recorded integrity failure | Deep-check again before clearing that failure, if such recording is later implemented |

The mere presence of `-wal`, `-shm`, or journal files should not trigger a deep check: those files can be normal. A read-only open that cannot deal with their state is the meaningful signal.

## 7. Clean-shutdown/trust marker

MessageLens does not currently maintain a global clean-shutdown marker.

It does maintain useful operation-specific evidence:

- onboarding status;
- operation and process-session IDs;
- completed/interrupted/failed state;
- stage, substage and progress;
- the obsolete destructive-operation journal.

That is enough to detect the highest-risk interrupted workflows, but not a generic application crash.

I do not recommend adding a positive “database trusted” marker in the minimal implementation:

- import and graph change through periodic intake;
- overlay changes through user actions and window state;
- Presence changes through execution;
- reliably invalidating a shared marker before every mutation would become cross-cutting;
- clean-shutdown callbacks are not reliable during force quit or power loss;
- a marker stored inside a database cannot establish that database’s health.

If a receipt is added later, it should be an atomic archive-root sidecar tied to archive instance ID, app build, schema vector, file identity and completed check type. It must only supplement—not replace—the fast structural checks. A durable prior-failure/quarantine receipt would provide more safety value than a positive trust receipt.

## 8. Proposed post-`runApp` sequencing

```text
native claim and single-instance authority
→ Dart archive admission and legacy-journal resolution
→ Flutter binding + SQLite FFI + window configuration + startup flags
→ construct provider container
→ runApp
→ restricted StartupApp shell: “Checking databases…”
→ fast read-only structural gate
→ moderate logical reconciliation
   ├─ healthy → “Databases okay”
   │           → logger/error handlers
   │           → safe persistent DB opens/migrations
   │           → window restoration
   │           → deferred Rust/MediaKit readiness
   │           → build normal App
   └─ suspicious → remain in restricted shell
                  → explain deep check
                  → run implicated quick_check operations
                  → continue/recovery/diagnostic decision
```

Archive admission, marker validation, single-instance authority and the legacy destructive-journal decision remain pre-render.

The normal `App` must not be constructed offstage while checks run, because widget/provider initialization could open writable databases.

## 9. Deep-check policy

- Run `quick_check(1)` only against implicated databases.
- Check both import and graph when their logical relationship is suspect.
- Check all active databases only when the trigger is archive-wide or cannot be localized.
- Separate read-only connections against separate files are logically safe in parallel, but parallel import/graph scans may make an external spinning disk slower through I/O contention. Sequential checks with visible per-database progress are the safer default.
- Use `integrity_check` only for explicit checkpoint/adoption or specialist diagnostics. It is more expensive and unnecessary merely to decide whether startup must stop.
- Use `foreign_key_check` only for a specific relational suspicion; neither integrity pragma covers foreign keys.
- Record database key, triggering fast-check result, schema version, file size, check start/end time and bounded SQLite error text. Do not record user rows or message content.
- Do not automatically repair.
- A successful deep physical check permits continuation only if schema and logical installation classification also pass.

The existing Phase 1 database-health audit should not be reused directly for startup escalation. It opens provider-managed databases—which may migrate or create indexes—and performs numerous counts and relational scans. Its report model and support-bundle format may be reusable, but startup inspection must retain a raw read-only boundary.

## 10. Failure-state UX

A compact state model is sufficient:

- `checkingFast`: “Checking databases…”
- `fastHealthy`: “Databases okay”
- `checkingDeep`: explanation plus current database and completed-database count
- `deepHealthy`: physical check passed; continue only if logical classification also passes
- `recoveryAvailable`: existing safe recovery path is available and requires explicit authorization
- `manualInterventionRequired`: database, reason, preservation implications, Export Diagnostics and Quit
- `archiveAdmissionFailed`: native fail-closed surface

Do not show percentage progress unless SQLite exposes real work progress. “Checking 2 of 4 databases” is truthful; “63%” would not be.

The current support-bundle exporter needs special attention: resolving it opens normal database providers. A suspicious-startup export path must instead use already-collected read-only evidence and must not trigger migrations.

## 11. Preservation-safety constraints

- Rendering the startup shell before validation is safe only if it has no normal application providers or write actions.
- Normal UI remains inaccessible until the gate passes.
- Persistent overlay, import, graph and Presence providers must not open before the result allows them.
- Older schemas receive deep validation before migration.
- A failed preservation store never enters automatic reset.
- Derived-store recovery must still check historical-source evidence.
- No deep check runs concurrently with import, graph projection or other archive mutation.
- Background checks after admitting normal writes are not an adequate substitute for the startup gate.
- `attachment_archive/` remains completely outside inspection, reset and remediation.
- Exporting diagnostics from failure state must remain read-only with respect to every database.

## 12. Performance target

Based on the measured path:

- Native-window-to-first-Flutter-frame target: approximately 1–1.5 seconds on the measured development machine.
- Bounded large-database probe target: comfortably around one second where storage permits.
- Normal admission with the existing exact count reconciliation may still take roughly 2.5–4 seconds, but it will occur behind a visible Flutter state.
- Healthy launches should perform no 10–20-second `quick_check`.
- A deep check may still take that long, but only with an explanation and visible progress.

## 13. Exact proposed edit scope

A minimal implementation would affect:

- [main.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/main.dart) — call `runApp` before classification and defer persistent initialization.
- [message_lens_installation_evidence_reader.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/application/message_lens_installation_evidence_reader.dart) — distinguish fast and deep inspection.
- [message_lens_installation_state.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/domain/message_lens_installation_state.dart) or a new narrowly owned startup-check model — typed phases/triggers/results.
- [sqlite_message_lens_installation_evidence_reader.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart) — bounded fast checks, shared connection for snapshot, explicit deep check.
- [message_lens_installation_state_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/application/message_lens_installation_state_provider.dart) — coordinate fast, reconciliation and escalation phases.
- Generated Riverpod output only if provider signatures change.
- [diagnostic_report_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/logging/application/diagnostic_report_provider.dart) or a separate startup-safe exporter — avoid opening writable providers in failure state.
- Existing and new tests under `test/essentials/onboarding/`, `test/startup_installation_state_surface_test.dart`, and relevant architecture tests.
- `CHANGELOG.md` and `pubspec.yaml` because this is tester-visible startup behavior.

No database schema, migration, FTS schema, import pipeline, graph projector, reset implementation or user database should change.

## 14. Test plan

- Fast inspection never issues `quick_check`.
- Deep inspection issues it only for requested databases.
- Healthy schema-3 FTS graph passes the fast path.
- Future schema fails closed.
- Older schema escalates before any migration/provider open.
- Missing table, zero-byte file, malformed SQLite and targeted-read error escalate correctly.
- Malformed/running/interrupted onboarding snapshots gate normal UI.
- Import/graph mismatch deep-checks both.
- Preservation-store failure never exposes Start Fresh unless existing policy explicitly permits it.
- Pristine inspection creates no files.
- Database bytes, modification times and WAL/SHM inventory remain unchanged.
- First widget pump displays “Checking databases…” while the provider is unresolved.
- Normal `App` is not built during fast check, deep check or failure.
- Deep-check progress and healthy/failure transitions render correctly.
- Architecture tests prove archive admission precedes `runApp`, while logger/window restoration and persistent database providers follow successful classification.
- Temp-fixture contention tests distinguish busy/locked from corruption.
- Focused onboarding/startup tests, graph DB tests, architecture tests, `flutter analyze`, `git diff --check`, and a macOS debug build.
- Manual direct `.app` and Run Without Debugging timing verification.

## 15. Risks and unresolved questions

- Whether highest-`ss_id` parity is sufficient to replace exact message counts across live, historical and recovered records must be proven.
- Generic SQLite `quick_check` does not establish FTS external-content consistency; FTS needs a separate diagnostic policy.
- Older-schema migration policy needs an explicit list of versions still supported.
- Startup-safe diagnostic export needs separation from the provider-managed health audit.
- Legacy erase-journal handling can still delay the first frame in its rare suspicious state.
- External-volume read-only opens can still stall below SQLite’s control.
- A fast check and later provider open have a small time-of-check/time-of-use gap.
- “Databases okay” should not introduce a gratuitous fixed delay merely to display the message.

## Recommended minimal implementation sequence

1. Complete the existing schema-3 validator correction as its own checkpoint.
2. Render the restricted startup shell before installation classification, without changing classification semantics.
3. Split bounded inspection from `quick_check`; retain exact logical reconciliation after the first frame.
4. Add typed escalation triggers and per-database deep checks.
5. Make startup failure export read-only and migration-free.
6. Measure the resulting normal path.
7. Only then consider replacing exact message counts with bounded high-water evidence or a durable receipt.

No source files or databases were changed during this audit. `git diff --check` remains clean, and the shared instructions submodule remains clean.