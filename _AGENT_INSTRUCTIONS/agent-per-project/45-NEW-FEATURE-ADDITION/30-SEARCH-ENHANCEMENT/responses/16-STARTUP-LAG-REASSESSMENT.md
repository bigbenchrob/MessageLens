The delay is application-side, not caused by debugging or `--start-paused`. The dominant blocker is `messageLensInstallationStateProvider.future`, specifically full SQLite `PRAGMA quick_check(1)` scans performed sequentially before `runApp`.

## Run Without Debugging command

The live Flutter process used:

```text
.../dart .../flutter_tools.snapshot run
  --machine
  --dart-define=flutter.inspector.structuredErrors=false
  -d macos
  --devtools-server-address http://127.0.0.1:9101/
  --target /Users/rob/Development/FlutterProjects/remember_every_text/lib/main.dart
```

`--start-paused` was absent.

Flutter spent approximately 21.5 seconds building before creating the native window. That is tooling overhead, but it occurs before the white window appears and does not explain the blank-window interval.

## Run Without Debugging timeline

Times are UTC on September 12, 2026.

| Time | Operation | Duration |
|---|---|---:|
| 14:46:57.527 | Native window `awakeFromNib` begins | — |
| 14:46:57.527 | Native archive claim | <1 ms |
| 14:46:57.527–57.915 | Single-instance claim | 388 ms |
| 14:46:57.915–57.947 | Create Flutter view controller | 32 ms |
| 14:46:57.947–58.024 | Register plugins | 77 ms |
| 14:46:58.407 | Dart `main` begins | 880 ms after native start |
| 14:46:58.438–58.646 | Archive admission, legacy-journal check and marker validation | 208 ms |
| 14:46:58.646–58.649 | SQLite FFI initialization | 2 ms |
| 14:46:58.649–58.669 | Rust initialization | 20 ms |
| 14:46:58.669–58.689 | macOS window configuration | 20 ms |
| 14:46:58.689–58.691 | Startup-flags method channel | 2 ms |
| 14:46:58.694–58.696 | MediaKit initialization | 3 ms |
| 14:46:58.697–58.698 | Provider-container construction | 2 ms |
| 14:46:58.699–14:47:11.253 | `messageLensInstallationStateProvider.future` | **12,554 ms** |
| 14:47:11.253–11.259 | Logger initialization | 6 ms |
| 14:47:11.259–11.369 | Window-state restoration | 110 ms |
| 14:47:11.369 | `runApp` called | — |
| 14:47:11.502 | First Flutter frame | 132 ms after `runApp` |

Total native-window-to-first-frame time: **13.975 seconds**.

The installation-evidence provider’s 12.54 seconds breaks down as follows:

| Database operation | Total | `quick_check` portion |
|---|---:|---:|
| `user_overlays.db` | 66 ms | 32 ms |
| `macos_import_ss.db` | **7,079 ms** | **7,063 ms** |
| `working_ss.db` | **5,224 ms** | **5,212 ms** |
| `presence.db` | 147 ms | 3 ms |
| Overlay operation-snapshot read | 14 ms | — |

Thus, 12.275 seconds—about 88% of the entire white-window interval—was spent in two integrity scans.

## Direct `.app` launch

Launching the already-built executable directly, with no VS Code or Flutter tool involved, produced:

- Native window to first Flutter frame: **13.010 seconds**
- Installation-state provider: **11.734 seconds**
- Import `quick_check`: **6.582 seconds**
- Graph `quick_check`: **4.987 seconds**

The roughly one-second difference from the no-debug launch is ordinary disk/cache variation. Direct launch therefore has essentially the same blank interval.

## Exact blocker

The blocking chain is:

1. [main.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/main.dart:277) awaits `messageLensInstallationStateProvider.future`.
2. [message_lens_installation_state_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/application/message_lens_installation_state_provider.dart:12) awaits the evidence reader.
3. The reader runs off the UI isolate, but checks all four databases sequentially.
4. [sqlite_message_lens_installation_evidence_reader.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart:161) executes `PRAGMA quick_check(1)`.
5. `runApp` is not reached until every check finishes.

The isolate prevents UI-thread blocking, but because no Flutter application has been installed yet, there is still nothing available to render.

`quick_check(1)` does not mean “check one page”; `1` limits the number of reported errors. SQLite still traverses the database structures.

## Relationship to recent changes

- The startup schema-version correction and shared `conversationGraphSchemaVersion` constant add no measurable runtime work.
- `working_ss.db` is healthy schema 3. No Drift graph migration or FTS rebuild occurred during startup.
- The evidence reader opens the graph directly in read-only mode; the normal graph provider is not opened before the first frame.
- FTS is indirectly relevant because its shadow tables increase the graph’s scan size:
  - `working_ss.db`: 69,550,080 bytes
  - FTS shadow tables: 20,025,344 bytes, approximately 28.8% of the graph database
- However, the largest blocker remains the 144,461,824-byte import database, which is unrelated to FTS.

There is no 20- or 30-second timeout involved. The configured SQLite `busy_timeout` is 3 seconds, the native file lock is explicitly non-blocking, and no retry/poll loop accounts for the observed duration. The interval is accumulated database I/O; colder external-drive conditions can reasonably push the measured 13–14 seconds toward the tester’s approximately 20 seconds.

## Appropriate corrective direction

Two improvements are possible:

1. Call `runApp` earlier and show a visible startup/classification screen while the evidence provider completes.
2. Reconsider whether full integrity scans are required on every healthy launch—possibly reserving them for suspicious state, unclean shutdowns, recovery, or a background health audit.

The first addresses the white-window experience. The second addresses the underlying startup cost. Both require a preservation-safety review before implementation.

All temporary instrumentation was removed, the isolated database clone was deleted, and the debug `.app` was rebuilt from the restored sources. `git diff --check` passes. No real database was modified. The shared submodule remains clean, and only the pre-existing schema-validator patch and pre-existing untracked files remain in the worktree.