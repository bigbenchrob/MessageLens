The dominant blocker is the debugger launch pause, not FTS or the schema-validator patch. The native macOS window becomes visible before Dart produces its first frame, while Flutter is launched with `--start-paused`.

## Measured startup timeline

The four recent launches show the same interval:

| Native window/process check-in | Classification completed | Blank interval |
|---|---:|---:|
| 14:45:00.069 | 14:45:22.401 | 22.3 s |
| 15:01:02.165 | 15:01:24.100 | 21.9 s |
| 15:01:44.903 | 15:02:05.601 | 20.7 s |
| 15:16:24.525 | 15:16:47.566 | 23.0 s |

For the latest run:

1. Flutter tooling started at 15:16:04.
2. The native MessageLens process/window started at 15:16:24.5.
3. Flutter was launched with `--start-paused`.
4. Dart completed startup classification at 15:16:47.6.
5. Initial shell/panels rendered at 15:16:48.1–48.3, about 0.6–0.7 seconds later.
6. Background onboarding/monitor probes reached ready at 15:16:50.9, but the UI was already rendered.

The roughly 20-second build/install period before the native process starts is separate from the visible blank-window interval.

## Rendering gates

Before `runApp`, [main.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/main.dart:190) performs all of these sequentially:

1. Native archive claim and single-instance lock.
2. Dart-side archive admission and marker validation.
3. Legacy-journal existence check.
4. SQLite FFI initialization.
5. Awaited Rust library initialization.
6. Awaited macOS window configuration.
7. Awaited startup-flags method-channel call.
8. Provider-container construction.
9. Awaited `messageLensInstallationStateProvider.future`.
10. Persistent logger initialization.
11. For a completed installation, awaited overlay database open and window-state restoration.
12. Only then, `runApp`.

The native window is installed and displayed in [MainFlutterWindow.swift](/Users/rob/Development/FlutterProjects/remember_every_text/macos/Runner/MainFlutterWindow.swift:447) before Dart reaches `runApp`. This answers the first question: yes, the window is created before startup classification and related initialization finish.

At the application level, the exact data-dependent gate is:

[message_lens_installation_state_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/application/message_lens_installation_state_provider.dart:12)

```dart
await container.read(messageLensInstallationStateProvider.future)
```

That provider runs the SQLite evidence reader in an isolate, but `main()` still awaits it before rendering anything.

## Installation-evidence timing

The evidence reader sequentially inspects overlay, import, graph, and presence databases. Each inspection performs:

- File existence and size checks.
- Read-only SQLite open.
- `PRAGMA user_version`.
- `PRAGMA quick_check(1)`.
- Table inventory.
- Relevant row counts.
- A second overlay open for the onboarding-operation snapshot.

An exact standalone invocation of the actual reader against the development archive took:

- Cold run: 1.72 seconds
- Warm runs: 0.36 and 0.39 seconds
- Classification itself: effectively negligible

Separate conservative SQLite timings totalled about 3.4 seconds:

- Overlay: 1.32 s
- Import: 1.41 s
- Schema-3 graph including FTS tables: 0.54 s
- Presence: 0.16 s

Therefore, `messageLensInstallationStateProvider.future` is a genuine rendering gate, but it does not explain the recurring 21–23-second blank interval.

## Debugger pause

The active Flutter command contains `--start-paused`. Flutter’s local debug adapter explicitly documents that debug launches start paused, connect to the VM service, install breakpoints, and then resume in [flutter_adapter.dart](/Users/rob/Development/flutter/packages/flutter_tools/lib/src/debug_adapters/flutter_adapter.dart:237).

The native Flutter engine/window was active by 15:16:24.7, followed by an otherwise idle system-log gap until Dart-rendered activity appeared around 15:16:47–48. Combined with the much shorter measured application work, this identifies debugger attachment/resumption as the dominant blocker.

## Search and FTS involvement

The recent search changes are not performing a recurring FTS rebuild:

- `working_ss.db` remains schema 3.
- Its FTS index is healthy.
- The graph database rebuilds FTS only during a version `<3` to version `3` migration in [conversation_graph_database.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart:17).
- Because the database is already version 3, that migration does not run.
- The graph connection is opened later through a background Drift connection, after application rendering begins.
- The newly shared schema-version constant is compile-time metadata and performs no initialization or I/O.

FTS may modestly increase the work done by `quick_check`, but the measured graph inspection was only about 0.54 seconds.

## Timeouts and polling

There is no 30-second timeout in the startup path.

The only relevant startup timeout is `PRAGMA busy_timeout = 3000`, applied independently to SQLite connections. It matters only if a database is locked; no such contention was observed.

Other intervals are post-render and unrelated:

- Chat database polling: every 15 seconds.
- Attachment maintenance: every 5 minutes.
- Link-preview request timeout: 10 seconds and only when fetching a preview.
- No startup retry or polling loop uses approximately 30 seconds.

## Recommended correction

Two distinct UX improvements are possible:

1. For normal application startup, call `runApp` after secure archive admission but before installation classification. Render a safe startup shell while classification runs, and continue to gate all real database-backed content until validation succeeds. The existing `StartupApp.loading` screen cannot currently help because the provider is already awaited before `runApp`.

2. For debugger launches, a Dart loading screen cannot appear while the isolate is start-paused. Either:

   - run without debugging when breakpoint attachment is unnecessary; or
   - keep the native window hidden until Flutter’s first frame, or show a native launch placeholder before Dart resumes.

The first change would make the 0.4–3.4-second application validation visible. The second is what would address the dominant 21–23-second debug blank window.

No repository files were changed during this investigation. Temporary probes were created only under `/tmp` and removed. All database access performed by the diagnostics was read-only.