Implemented and committed Startup Stage Two on `codex/fix-startup-graph-schema`.

Commit: `305a0860f6d574bd37e1c0d6bc60897eb7d07630`
Message: `perf(startup): reserve integrity scans for suspicious state`

### Result

- Work began at `18926d23b5dac315c3d719024e47f73776abac02`.
- Stage One remains separate at `a5a5f43b94bea0b1398d986f83ff5442d525fa36`.
- Stage Two is a separate 31-file checkpoint.
- Version is now `0.2.109+127`.
- `working_ss.db` remains schema 3.
- The authoritative graph version remains [`conversationGraphSchemaVersion = 3`](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/db/app_database_schema_versions.dart:6).
- No schema, FTS, import, graph projection, reset-target, or user-database changes were made.

### Validation model

The new typed model in [startup_installation_validation.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/domain/startup_installation_validation.dart:1) separates:

- bounded structural inspection;
- deep physical integrity validation;
- final startup admission.

The healthy path now performs read-only schema, required-object, targeted-read, FTS-readability, operation-snapshot, and exact import/graph reconciliation checks. It does not execute `quick_check`.

Deep validation is isolated in [sqlite_message_lens_installation_integrity_validator.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_integrity_validator.dart:1).

Escalation covers zero-byte files, invalid SQLite, corruption/I/O errors, missing objects, targeted-read failures, malformed snapshots, import/graph or topology mismatch, incomplete onboarding operations, older schemas, and critical workflow boundaries. Busy/locked databases become contention states; unsupported future schemas are rejected without a pointless deep scan.

A successful deep scan cannot override structural, schema, logical, or preservation failures.

Legacy journal cleanup and Start Fresh retain full fail-closed validation. Start Fresh validates before mutation and again after reset.

### Startup UX and timing

The restricted shell now visibly reports:

- `Checking databases…`
- `Databases okay`
- the deeper-check explanation;
- truthful database-count progress;
- restricted remediation on failure.

Measured against disposable copies on the same external drive:

| Launch | Before: first frame | After: first frame | Bounded inspection | After: normal admission |
|---|---:|---:|---:|---:|
| Direct `.app` | 13.010s | 1.168s | 1.664s | 3.003s |
| Run Without Debugging | 13.975s | 1.403s | 1.550s | 3.129s |

The actual Run Without Debugging command contained no `--start-paused`. The remaining dominant startup cost is the deliberately retained exact import/graph count reconciliation, but it now runs behind a visible first frame.

### Verification

- Focused onboarding/startup suite: 268 passed
- Conversation Graph database suite: 9 passed
- Complete architecture suite: 434 passed
- `flutter analyze`: no issues
- `git diff --check`: passed
- Final non-instrumented macOS debug build: succeeded
- Healthy-path validator spy: no deep validation calls
- Suspicious fixtures: implicated databases invoke deep validation
- Live database sizes/timestamps unchanged
- No live WAL/SHM files created
- Temporary instrumentation and disposable database copies removed
- Shared instructions submodule: clean

The branch is three commits ahead and zero behind `main`. Tracked worktree state is clean; only the ten previously known untracked settings/prompts/responses remain untouched. Nothing was pushed.

Recommended next step: manually verify several ordinary restarts, then integrate these three startup commits while preserving their history. Link-preview work has not begun.

::git-stage{cwd="/Users/rob/Development/FlutterProjects/remember_every_text"}
::git-commit{cwd="/Users/rob/Development/FlutterProjects/remember_every_text"}
