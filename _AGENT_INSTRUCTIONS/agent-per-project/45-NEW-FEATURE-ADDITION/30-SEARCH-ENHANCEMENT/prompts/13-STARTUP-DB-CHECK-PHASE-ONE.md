



Please implement **Startup Stage 1 only**.

The goals are:

1. finish and checkpoint the existing schema-3 startup-validator correction;
2. move `runApp` / the restricted startup shell ahead of installation classification;
3. preserve the current classification semantics exactly for now.

Do **not** yet remove `PRAGMA quick_check`.
Do **not** yet redesign fast-vs-deep database validation.
Do **not** yet change escalation policy.
Do **not** begin link-preview work.

## Current context

The current startup regression has two distinct findings:

- a schema-version validation bug was already identified and patched on `codex/fix-startup-graph-schema`;
- the current startup path still awaits `messageLensInstallationStateProvider.future` before `runApp`, causing the native window to remain blank while database validation completes.

The completed read-only startup audit recommends:

```text
fail-closed archive admission
→ render restricted Flutter startup shell
→ installation classification
→ normal app only after admission
```

This stage should implement only that sequencing change.

## Part 1 — Finish the schema-3 validator patch

Current patch reportedly introduces:

`conversationGraphSchemaVersion = 3`

in:

`lib/essentials/db/app_database_schema_versions.dart`

and makes both:

- `ConversationGraphDatabase`
- `SqliteMessageLensInstallationEvidenceReader`

consume that shared constant.

Regression coverage already proves:

- schema 3 accepted;
- populated schema-3 FTS graph classified as completed;
- unsupported future schema 4 rejected.

Please first inspect the current branch/worktree and verify that patch is still exactly as described.

If clean and validated, commit it separately.

Suggested commit message:

`fix(startup): share current graph schema version`

Do not combine the startup sequencing work into this commit.

## Part 2 — Render before installation classification

Refactor startup so the Flutter app is installed and can render a restricted startup surface **before** `messageLensInstallationStateProvider.future` completes.

### Preserve true pre-render safety gates

These must remain before `runApp`:

- native archive/build/environment admission;
- single-instance lock;
- Dart archive marker/root/environment validation;
- legacy destructive-journal decision;
- minimum Flutter binding/runtime initialization required to render;
- SQLite FFI if required by the startup shell/provider path;
- startup flags if they determine which startup surface must appear;
- provider-container construction.

Do not weaken or move these merely for speed.

### Move installation classification after `runApp`

Today `main.dart` awaits installation classification before the app exists.

Change the flow conceptually to:

```text
safe archive admission
→ construct provider container
→ runApp
→ render StartupApp
→ StartupApp observes installation-state provider
→ show loading state while unresolved
→ transition to existing completed/onboarding/remediation states
```

The key requirement is:

> while `messageLensInstallationStateProvider.future` is unresolved, the user sees a real Flutter startup screen rather than a blank native window.

Use existing `StartupApp` / loading infrastructure where practical rather than introducing a parallel startup UI.

The prior audit identified an existing loading surface in `main.dart`; reuse it if suitable.

## Restricted startup shell

While classification is pending:

- do not construct the normal application shell;
- do not open writable persistent database providers merely because Flutter has rendered;
- do not initialize feature providers that may mutate databases;
- do not perform normal window-state restoration through the overlay provider;
- do not start background import/intake/maintenance;
- do not expose user actions that assume database admission succeeded.

The visible UI can be minimal.

For now something equivalent to:

`Checking databases…`

with an activity indicator is sufficient.

Do not spend time polishing final UX copy in this stage.

## Preserve classification semantics

This stage must **not** change the current installation-evidence reader behavior.

In particular:

- `PRAGMA quick_check(1)` still occurs exactly where it currently does;
- exact import/graph count reconciliation remains;
- startup classification decisions remain unchanged;
- remediation/onboarding/completed-state logic remains unchanged.

We are changing **when the result is awaited relative to rendering**, not what result is produced.

This separation is important so performance and safety changes can be reviewed independently.

## Deferred initialization

Inspect current pre-`runApp` initialization and move only clearly safe items to after successful classification if required by the new sequencing.

The audit suggested that these do not need to block the startup shell:

- Rust library initialization;
- MediaKit initialization;
- persistent logger initialization;
- overlay/window-state restoration.

However, do not move them gratuitously in this stage unless needed to get the shell rendering correctly.

If an item is moved, explain why and ensure no startup behavior regresses.

Prefer the smallest sequencing change.

## Window behavior

The native macOS window already appears before Dart rendering.

After this stage, once Dart reaches `runApp`, the first Flutter frame should show the startup shell promptly.

Do not hide the native window or add a native launch screen in this stage.

## Tests

Add/update focused tests proving:

1. unresolved installation-state provider renders the loading/startup shell;
2. normal `App` is not built while classification is unresolved;
3. completed classification transitions to the normal application;
4. onboarding/remediation classifications still transition to their existing surfaces;
5. schema-3 healthy installation still classifies correctly;
6. unsupported future schema still fails closed;
7. writable/persistent providers are not opened merely by rendering the loading shell;
8. archive admission still occurs before `runApp`.

Where architecture tests already exist for startup ordering, update them instead of duplicating coverage.

## Validation

Run at minimum:

- startup installation-state surface tests;
- installation evidence reader tests;
- classifier/provider tests;
- graph database tests relevant to schema 3;
- architecture checks;
- `flutter analyze`;
- `git diff --check`;
- macOS build if consistent with project workflow.

Also perform a manual timing verification using:

- Run Without Debugging;
- direct `.app` launch if practical.

Report:

- native-window-to-first-Flutter-frame time;
- whether the blank white interval is replaced by the visible startup shell;
- total classification time.

Do not claim startup is “fast” yet; `quick_check` is intentionally still present in this stage.

## Git hygiene

Preserve unrelated untracked files.

Do not stage or commit personal `.vscode/settings.json` or unrelated prompt files.

If the schema fix lives on a temporary branch, integrate it cleanly into the startup work branch according to existing repository conventions, preserving its separate commit.

Do not rewrite unrelated history.

## Deliverable

Report:

1. branch and starting HEAD;
2. schema-fix commit hash;
3. files changed for startup sequencing;
4. exact pre-`runApp` steps that remain;
5. what now renders while classification is pending;
6. confirmation that classification semantics are unchanged;
7. any initialization moved post-render;
8. tests added/updated;
9. validation results;
10. manual launch timing;
11. git status;
12. recommended Stage 2 boundary.

Recommended Stage 2 should be the next safety-policy change:

- split bounded fast inspection from expensive `quick_check`;
- keep exact logical reconciliation initially;
- add typed escalation into deep checks.

Do not implement Stage 2 in this pass.
