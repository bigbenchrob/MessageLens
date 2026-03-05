---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-03-05
links:
  - ../../../lib/essentials/logging/application/message_logger.dart
  - ../../../lib/essentials/logging/application/navigation_logger.dart
  - ../../../lib/main.dart
  - ../../agent-per-project/60-BUILD-CONSIDERATIONS/01-rust-ffi-dylib-bundling.md
tests: []
feature: diagnostic-logging
status: proposed
created: 2026-03-05
---

# Feature Proposal — Diagnostic Logging & "Send Logs"

**Branch**: (TBD — e.g. `Ftr.logging`)
**Status**: Proposed — awaiting review
**Created**: 2026-03-05

---

## Overview

Add a production-grade diagnostic logging system that captures everything relevant to troubleshooting — user actions, navigation flow, errors, import/migration events — to a persistent rotating log file. A user experiencing an issue selects **"Send Logs"** from the Settings top menu, which packages the log into a ready-to-send email, giving the developer (and the AI agent reviewing the log) a complete picture of what led to the problem.

## User Value

**Problem**: When a distributed user hits an issue, there is no way to retrieve diagnostic information. All current logging is in-memory (lost on quit), uses bare `print()`/`debugPrint()` (invisible in release builds), and has no export path to the developer.

**Solution**: A file-backed structured log that:
- Survives app restarts
- Captures the full user journey (navigation, settings changes, data operations, errors)
- Can be sent to the developer with one click from the Settings menu
- Is formatted for both human and AI-agent consumption

**Benefits**:
- Developer can diagnose issues from a log file without screen-sharing
- AI agent can ingest the structured log and trace the exact sequence of events
- Errors are never silently swallowed — every unhandled exception is captured with full context

---

## Scope

### Phase 1 — Core Log Infrastructure (This Proposal)

1. **Global error capture** — `FlutterError.onError` + `PlatformDispatcher.onError` + `runZonedGuarded` in `main()` to catch all unhandled exceptions and route them through the logging system.

2. **File-backed log writer** — A `LogFileWriter` service that appends structured log lines (one JSON object per line, aka JSONL) to a rotating log file in the app's data directory. Rotation: retain current + 1 previous file, ~2 MB cap per file.

3. **Unified `AppLogger` provider** — Replace the current `MessageLogger` with a single `AppLogger` Riverpod provider that:
   - Accepts log entries at levels: `debug`, `info`, `warn`, `error`
   - Each entry: timestamp, level, source tag, message, optional structured context map
   - Writes synchronously to the in-memory buffer (for UI display) AND asynchronously to the log file
   - Subsumes the existing `MessageLogger` interface so current call sites continue to work

4. **Navigation logging integration** — Wire the existing `NavigationLogger` to write through `AppLogger` instead of maintaining a parallel list. Every spec transition, toolbar click, and panel change is logged.

5. **Import/migration event logging** — Replace the `print()` calls in the import debug settings system (`ImportDebugSettingsState.logDatabase()`, `.logProgress()`, `.logError()`) with `AppLogger` calls. These events become part of the persistent log regardless of debug toggle state (the toggle can control verbosity level instead).

6. **"Send Logs" menu item** — Add a `SettingsMenuChoice.sendLogs` variant. When selected, the app:
   - Collects the current + previous log files
   - Prepends a header block with app version, macOS version, uptime, database sizes
   - Opens the user's default email client via `url_launcher` with a pre-filled `mailto:` URI containing the support address and subject line
   - Simultaneously reveals the log file in Finder (via `NSWorkspace.shared.activateFileViewerSelecting`) so the user can drag-attach it

7. **Remove dead code** — Delete the standalone `MessageLogger` (subsumed by `AppLogger`) and clean up the ~118 bare `print()`/`debugPrint()` call sites, routing meaningful ones through `AppLogger` and deleting pure debug noise.

### Out of Scope (Future Phases)

- **Log viewer UI panel** — A ViewSpec.diagnostics panel showing live log stream with filtering. Useful but not needed for the "send to developer" workflow.
- **Automatic crash reporting** — Sentry/Crashlytics integration. Overkill for a single-developer macOS app with a small user base.
- **Remote log upload** — HTTP-based log submission. The mailto + Finder approach is simpler and doesn't require server infrastructure.
- **Structured analytics/telemetry** — Usage patterns, feature adoption metrics. Different concern from diagnostic logging.

---

## Dependencies

### Technical Dependencies (Existing)
- ✅ `url_launcher` — already in pubspec, used for link previews
- ✅ `path_provider` — already in pubspec, used in `PathsHelper`
- ✅ `NavigationLogger` — already captures spec transitions, will be rewired
- ✅ `SettingsMenuChoice` enum — already defines the menu; needs one new variant
- ✅ Sidebar cassette cascade system — well-documented pattern for adding menu items

### Technical Dependencies (New)
- `dart:io` `File`/`IOSink` — for log file writing (no new packages needed)
- Platform channel or `url_launcher` — for `mailto:` URI and Finder reveal

### Domain Dependencies
- None — logging is a cross-cutting infrastructure concern, not a domain feature

---

## Architecture Impact

### Modified Components

| File | Change |
|------|--------|
| `lib/main.dart` | Add `FlutterError.onError`, `PlatformDispatcher.onError`, wrap `runApp` in `runZonedGuarded` |
| `lib/features/sidebar_utilities/domain/sidebar_utilities_constants.dart` | Add `SettingsMenuChoice.sendLogs` variant |
| `lib/essentials/sidebar/domain/entities/cascade/sidebar_utility_topology.dart` | Add `sendLogs` case to settings cascade switch |
| `lib/essentials/logging/application/navigation_logger.dart` | Rewire to write through `AppLogger` instead of parallel list |
| `lib/essentials/db_importers/application/debug_settings_provider.dart` | Replace `print()` calls with `AppLogger` |
| ~15 files with meaningful `print()`/`debugPrint()` | Route through `AppLogger` or delete |

### New Components

| File | Purpose |
|------|---------|
| `lib/essentials/logging/application/app_logger.dart` | Unified `AppLogger` Riverpod provider — levels, structured entries, routes to file writer |
| `lib/essentials/logging/infrastructure/log_file_writer.dart` | File I/O: append JSONL lines, rotation, size management |
| `lib/essentials/logging/infrastructure/log_export_service.dart` | Collects log files, builds header, triggers mailto + Finder reveal |
| `lib/essentials/logging/domain/log_entry.dart` | Freezed `LogEntry` value object (timestamp, level, source, message, context) |

### Deleted Components

| File | Reason |
|------|--------|
| `lib/essentials/logging/application/message_logger.dart` | Subsumed by `AppLogger` |
| `lib/essentials/logging/application/message_logger.g.dart` | Generated code for deleted provider |

---

## Detailed Design

### Log Entry Format (JSONL — one object per line)

```json
{"ts":"2026-03-05T14:23:01.455Z","lvl":"info","src":"NavigationLogger","msg":"Panel transition: center → ViewSpec.messages(forChat: 42)","ctx":{"panel":"center","chatId":42}}
{"ts":"2026-03-05T14:23:01.830Z","lvl":"info","src":"ChatDbChangeMonitor","msg":"Polling: 3 new messages detected","ctx":{"newCount":3,"pollCycleMs":15000}}
{"ts":"2026-03-05T14:23:05.120Z","lvl":"error","src":"FlutterError","msg":"RenderBox was not laid out","ctx":{"stack":"#0 RenderBox.size...","widget":"MessageBubble"}}
```

**Why JSONL**: Each line is independently parseable. An AI agent can ingest the file line-by-line without needing a JSON array wrapper. Grep-friendly. Append-only (no need to maintain valid JSON across writes).

**Fields**:
- `ts` — ISO 8601 UTC timestamp with milliseconds
- `lvl` — `debug`, `info`, `warn`, `error`
- `src` — originating class/system name (for filtering)
- `msg` — human-readable message
- `ctx` — optional structured key-value context (IDs, counts, durations, stack traces)

### Log File Location & Rotation

```
~/Library/Logs/RememberEveryText/
├── app.log          ← current session (append-only)
└── app.log.1        ← previous session (rotated on start)
```

**Why `~/Library/Logs/`**: This is the macOS-standard location for application logs. It's accessible without sandbox entitlements, survives app updates, and is where a macOS user (or AppleCare) would naturally look. Console.app can also browse this directory.

**Rotation strategy**:
- On app launch, if `app.log` exists and exceeds 2 MB, rename to `app.log.1` (overwriting any existing `.1`)
- During runtime, if a write would push `app.log` past 2 MB, rotate immediately
- Maximum disk usage: ~4 MB (2 files × 2 MB cap)
- At `~200 bytes/line`, 2 MB ≈ 10,000 log entries — roughly a full day of heavy use

### AppLogger Provider

```dart
@Riverpod(keepAlive: true)
class AppLogger extends _$AppLogger {
  late final LogFileWriter _writer;

  @override
  List<LogEntry> build() {
    _writer = LogFileWriter();
    ref.onDispose(_writer.close);
    return [];
  }

  void log(LogLevel level, String message, {String? source, Map<String, dynamic>? context}) {
    final entry = LogEntry(
      timestamp: DateTime.now().toUtc(),
      level: level,
      source: source,
      message: message,
      context: context ?? const {},
    );
    // In-memory buffer (capped at 500 entries for UI display)
    state = [...state.skip(state.length >= 500 ? 1 : 0), entry];
    // Async file write (fire-and-forget; logging must never block the app)
    _writer.append(entry);
  }

  void info(String message, {String? source, Map<String, dynamic>? context}) =>
      log(LogLevel.info, message, source: source, context: context);
  void warn(String message, {String? source, Map<String, dynamic>? context}) =>
      log(LogLevel.warn, message, source: source, context: context);
  void error(String message, {String? source, Map<String, dynamic>? context}) =>
      log(LogLevel.error, message, source: source, context: context);
  void debug(String message, {String? source, Map<String, dynamic>? context}) =>
      log(LogLevel.debug, message, source: source, context: context);
}
```

### Global Error Capture (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... existing sqflite, RustLib, window_utils init ...

  final container = ProviderContainer(/* ... */);

  // Capture Flutter framework errors (layout, rendering, gestures)
  FlutterError.onError = (details) {
    container.read(appLoggerProvider.notifier).error(
      details.exceptionAsString(),
      source: 'FlutterError',
      context: {
        'library': details.library ?? 'unknown',
        'stack': details.stack?.toString().split('\n').take(10).join('\n') ?? '',
      },
    );
  };

  // Capture platform-level errors (plugin crashes, isolate errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    container.read(appLoggerProvider.notifier).error(
      error.toString(),
      source: 'PlatformDispatcher',
      context: {'stack': stack.toString().split('\n').take(10).join('\n')},
    );
    return true; // Prevent app termination
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RememberEveryTextApp(),
    ),
  );
}
```

### "Send Logs" Flow

When the user selects **Settings → Send Logs**:

1. **No cascade needed** — Unlike other settings choices that open sidebar panels, "Send Logs" is an **imperative action**, not a navigation destination. The menu item triggers a one-shot operation.

2. **Collect & package**:
   - Flush the current in-memory buffer to disk
   - Read `app.log` + `app.log.1` (if exists)
   - Prepend a system info header:
     ```
     === Remember Every Text — Diagnostic Log ===
     App Version: 1.2.3 (build 45)
     macOS: 15.3.1 (24D70)
     Dart: 3.9.2 / Flutter: 3.35.4
     Uptime: 2h 14m
     Working DB: 12.3 MB | Import DB: 45.1 MB | Overlay DB: 0.8 MB
     Exported: 2026-03-05T14:30:00Z
     =============================================
     ```
   - Write combined output to a timestamped file in a temp location:
     `~/Library/Logs/RememberEveryText/diagnostic_2026-03-05_143000.log`

3. **Present to user**:
   - Open `mailto:` URI via `url_launcher`:
     ```
     mailto:support@rememberthis.text?subject=Diagnostic%20Log%20-%202026-03-05&body=Please%20attach%20the%20log%20file%20that%20was%20just%20opened%20in%20Finder.%0A%0ADescribe%20the%20issue%20here%3A%0A
     ```
   - Simultaneously reveal the exported log file in Finder via `Process.run('open', ['-R', exportedLogPath])` so the user can drag it into the email as an attachment
   - Show a brief in-app confirmation banner: *"Log file exported and revealed in Finder. Please attach it to the email."*

**Why mailto + Finder reveal instead of auto-attach**: macOS `mailto:` URIs don't support attachments. `NSSharingService` could auto-attach but requires a platform channel for minimal gain. The Finder reveal approach is simple, reliable, and doesn't need native code. The user drags one file.

### What Gets Logged (Source Coverage)

| Source Tag | What It Captures | Current State → Change |
|------------|-----------------|----------------------|
| `App` | App launch, shutdown, version info | New |
| `FlutterError` | Layout errors, render overflows, gesture failures | New (via `FlutterError.onError`) |
| `PlatformDispatcher` | Plugin crashes, isolate errors | New (via `PlatformDispatcher.onError`) |
| `Navigation` | Every panel/spec transition, toolbar click, sidebar cascade change | Existing `NavigationLogger` → rewire to `AppLogger` |
| `Import` | Ledger import start/complete/fail, row counts, duration | Existing `print()` calls → replace with `AppLogger` |
| `Migration` | Migration orchestrator steps, table migrator progress, errors | Existing `print()` calls → replace with `AppLogger` |
| `ChatDbMonitor` | Auto-sync poll results, new message counts | Existing `print()` calls → replace with `AppLogger` |
| `RustFFI` | `RustLib.init` success/failure, decode errors | Existing `try/catch` in `main.dart` → add logging |
| `WindowState` | Window resize/move/screen-change saves | Existing `catchError` → add logging |
| `Database` | DB open, close, migration version changes | New (at provider init sites) |
| `Settings` | User preference changes (overlay writes) | New |

### What Does NOT Get Logged

- Message content (privacy — only message IDs and counts)
- Contact names or phone numbers (privacy — only contact IDs)
- File system paths containing the username (sanitize to `~/...`)
- Debug-level entries in release mode (compile-time constant gate)

---

## Settings Menu Integration

### SettingsMenuChoice Addition

```dart
enum SettingsMenuChoice {
  contacts(id: 'contacts', label: 'Contacts'),
  sendLogs(id: 'send_logs', label: 'Send Logs');

  // ... existing constructor and methods
}
```

### Cascade Handling — Imperative Action, Not Navigation

Unlike `contacts` which cascades to a settings panel, `sendLogs` triggers an action and returns `null` from the cascade (no child cassette):

```dart
settingsMenu: (selectedChoice) {
  switch (selectedChoice) {
    case SettingsMenuChoice.contacts:
      return sidebarUtilitySettingsToContactsSettings();
    case SettingsMenuChoice.sendLogs:
      return null; // Imperative action — no cascade
  }
},
```

The action itself fires from the widget builder's `onSelected` callback, which calls `LogExportService.exportAndPresent()` before reverting the menu selection back to the previously selected non-action choice. This keeps the menu stateless for action items.

---

## Success Criteria

### Functional
- [ ] All unhandled Flutter and platform errors are captured to the log file
- [ ] Navigation events (panel transitions, toolbar clicks, sidebar cascades) are logged
- [ ] Import and migration operations are logged with start/complete/fail and durations
- [ ] Log files rotate correctly at ~2 MB boundary
- [ ] "Send Logs" produces a timestamped export file and opens email + Finder
- [ ] Log file is valid JSONL (each line parses independently)
- [ ] App launches and operates normally when log directory is missing (auto-creates)
- [ ] Logging never blocks the UI thread or causes jank

### Quality
- [ ] Zero bare `print()`/`debugPrint()` calls remain in lib/ (except in generated files)
- [ ] `flutter analyze` passes with no new warnings
- [ ] Log file write errors are silently absorbed (logging must never crash the app)

### UX
- [ ] "Send Logs" is discoverable in the Settings top menu
- [ ] Email opens within 1 second of menu selection
- [ ] Finder reveals the log file simultaneously
- [ ] In-app confirmation is brief and non-blocking

---

## Complexity Estimate

**Rating**: Medium

**Justification**:
- Log entry model and file writer: straightforward file I/O
- Global error capture: well-documented Flutter pattern
- Settings menu addition: follows established cassette system — one enum variant, one cascade case
- Rewiring existing loggers: mechanical but spread across ~20 files
- Export service: `url_launcher` mailto + `Process.run` for Finder reveal
- No new platform channels, no new packages, no database schema changes

**Estimated Effort**: 2–3 sessions

| Session | Work |
|---------|------|
| 1 | `LogEntry` model, `LogFileWriter`, `AppLogger` provider, global error capture in `main.dart` |
| 2 | Rewire `NavigationLogger`, replace `print()` calls across import/migration/monitor, delete `MessageLogger` |
| 3 | `LogExportService`, `SettingsMenuChoice.sendLogs`, menu integration, cleanup, verify `flutter analyze` |

---

## Risks & Mitigation

### Risk 1: File I/O performance impact
- **Likelihood**: Low
- **Impact**: Medium (jank during heavy logging)
- **Mitigation**: All file writes are fire-and-forget async. The `IOSink` is opened once and buffered by the OS. Benchmarks show single-line appends at <0.1ms. If needed, batch writes with a 100ms debounce timer.

### Risk 2: Log file grows uncontrolled
- **Likelihood**: Low (rotation is the first thing implemented)
- **Impact**: Low (macOS has abundant disk)
- **Mitigation**: Hard 2 MB cap with rotation. Maximum 4 MB on disk. Rotation runs on both startup and mid-session.

### Risk 3: Breaking existing `MessageLogger` consumers
- **Likelihood**: Medium (3 known call sites)
- **Impact**: Low (compile-time — missing provider reference)
- **Mitigation**: `AppLogger` maintains the same `info()`/`warn()`/`error()` API. Update the 3 call sites (`manual_handle_link_service.dart`, `macos_app_shell.dart`, `search/feature_level_providers.dart`) to use `appLoggerProvider` — direct find-and-replace.

### Risk 4: `mailto:` URI doesn't open email client
- **Likelihood**: Low (macOS always has Mail.app as default handler)
- **Impact**: Medium (user can't send log)
- **Mitigation**: Fall back to just revealing the file in Finder with a message: *"Please email this file to support@..."*. The Finder reveal is the reliable path; email is a convenience.

### Risk 5: Privacy — sensitive data in logs
- **Likelihood**: Medium (easy to accidentally log a name or number)
- **Impact**: High (user trust)
- **Mitigation**: Log only IDs (chat ID, contact ID, handle ID), never content or PII. Source tags make it easy to audit what each system logs. Document the "never log content" rule in INVIOLATE_RULES.

---

## Testing Strategy

### Unit Testing
- `LogEntry` serialization: round-trip to JSONL and back
- `LogFileWriter`: write, rotation at size threshold, handles missing directory
- `AppLogger`: log levels, in-memory buffer cap at 500, integration with writer
- `LogExportService`: header generation with system info, file concatenation

### Integration Testing
- Global error capture: throw in a widget → verify error appears in log file
- Navigation logging: trigger a spec transition → verify JSONL line in file
- Import logging: run a mock import step → verify structured log entry

### Manual Verification
- Launch release build via Finder → verify `~/Library/Logs/RememberEveryText/app.log` exists after 30 seconds
- Use the app for 5 minutes → verify log has navigation, polling, and any error entries
- Select "Send Logs" → verify email opens and Finder reveals the file
- Restart app → verify log rotation (old entries in `.log.1`, fresh entries in `.log`)

---

## Approval

- [ ] User/stakeholder reviewed
- [ ] Technical approach approved
- [ ] Ready to proceed to CHECKLIST.md

---

## Notes

### Design Decision: JSONL over SQLite for logs
**Why**: Logs are write-heavy, append-only, and read rarely (only on export). A text file is simpler, doesn't require Drift schema, doesn't risk locking conflicts with the app's working databases, and is directly human-readable. An AI agent can process JSONL line-by-line without loading the entire file into memory.

### Design Decision: `~/Library/Logs/` over app data directory
**Why**: This is the macOS-conventional location for application logs. It's where `Console.app` looks, where support engineers expect logs, and it separates diagnostic data from application state. It also survives database resets/reimports.

### Design Decision: mailto + Finder reveal over NSSharingService
**Why**: `NSSharingService` would require a platform channel (~50 lines of Swift + method channel boilerplate) to auto-attach the file to an email. The mailto + Finder reveal approach requires zero native code, uses the existing `url_launcher` package, and is only one drag-and-drop step for the user. If users find this friction unacceptable, we can add the platform channel in a future phase.

### Design Decision: Imperative action in settings menu, not a panel
**Why**: "Send Logs" is a one-shot action, not a stateful panel. Adding it as a `SettingsMenuChoice` enum variant with `null` cascade is the lightweight approach. The menu reverts to the previous selection after the action fires, so it behaves like a button rather than a tab.

### Open Question: Debug-level logging in release builds
**Recommendation**: Gate `debug`-level entries behind `kDebugMode` (compile-time constant). This eliminates high-frequency noise (e.g., every widget rebuild) from release logs while keeping `info`/`warn`/`error` always active. The `AppLogger.debug()` method simply returns early in release mode.

### Open Question: Log sanitization depth
**Recommendation**: Start with ID-only logging (no content, no PII). If a specific diagnostic scenario requires more context (e.g., "what was the message body that caused the decode failure?"), add opt-in verbose mode that the developer can ask the user to enable temporarily. Never include PII in default logging.
