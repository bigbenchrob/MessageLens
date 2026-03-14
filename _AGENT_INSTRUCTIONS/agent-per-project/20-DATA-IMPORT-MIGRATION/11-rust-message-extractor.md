---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ../10-DATABASES/01-db-import.md
---

# Rust Message Text Extractor

## Purpose
- Decode the binary `attributedBody` column from macOS `chat.db` so that messages missing plain `text` still display content.
- Run as a standalone native binary (`extract_messages_limited`) that the import pipeline shells out to during stage 7 "Extracting rich message content".
- Without this binary roughly 90% of messages land in the ledger with empty bodies, breaking search and UI rendering.

## Component Map
- Binary: `target/release/extract_messages_limited` (also searched for next to `Platform.resolvedExecutable` when the macOS app is bundled).
- Rust crate: `rust/rust/attributed-string-decoder/` (Cargo project that produces the binary and flutter_rust_bridge bindings).
- Flutter adapter: `lib/essentials/db_importers/infrastructure/extraction/rust_message_extractor.dart` implements `MessageExtractorPort`.
- Provider wiring: `lib/essentials/db_importers/feature_level_providers.dart` exposes `dbImportMessageExtractorProvider` for orchestrators.
- Import consumer: `lib/essentials/db_importers/infrastructure/sqlite/importers/message_rich_text_importer.dart` invokes the extractor and applies results to the ledger.
- Database sink: `SqfliteImportDatabase.updateMessageText` persists decoded bodies into `macos_import.db`.

## Runtime Flow (Ledger Import)
1. `_importMessages` records extraction candidates where `message.text` is empty and `message.attributedBody` is a non-null blob.
2. `_extractRichText` checks `extract_messages_limited` availability via `MessageExtractorPort.isAvailable()` (toggled by `importDebugSettingsProvider`).
3. On success the service invokes `extractAllMessageTexts(limit: rustExtractionLimit, dbPath: messagesDbPath)`.
4. The adapter shells out with `Process.run(extractorPath, args)` and expects JSON shaped like:
   ```json
  {"messages":[{"rowid":123,"text":"..."}]}
   ```
5. `SqfliteImportDatabase.updateMessageText` trims each string, writes it to `messages.text`, and promotes misclassified text-bearing rows from `attachment-only` / `unknown` / `balloon` to `text` while preserving meaningful types like `reaction-carrier`.
6. The orchestrated importer persists scratchpad stats (`messages.richTextApplied`) so migration and UI telemetry can confirm the extractor ran.

## Binary Interface
```
./extract_messages_limited [limit] [chat.db path]
```
- `limit` (optional) caps how many rows the extractor processes (Flutter default: `rustExtractionLimit = 200000`).
- `chat.db path` points to the Messages database copy to scan; defaults to the working directory when omitted.
- Exit code `0` -> success with JSON on stdout. Any non-zero exit code is treated as failure and the pipeline falls back to empty text.

## Building & Packaging
1. `cd rust/rust/attributed-string-decoder`
2. `cargo build --release --bin extract_messages_limited`
3. Copy the result to the location the Flutter app expects:
   ```bash
   cp target/release/extract_messages_limited ../../../target/release/
   ```
4. Ensure the binary is executable (`chmod 755 target/release/extract_messages_limited`).
5. For bundled macOS builds, place the binary next to the Flutter executable so `RustMessageExtractor.extractorPath` resolves it.

### Production Packaging Playbook (macOS App Bundle)
- Flutter copies everything under `macos/Runner/` when registered as a resource or Copy Files build phase. Keep the Rust binary under source control at `macos/Runner/Resources/extract_messages_limited`.
- In Xcode, add the binary to the "Copy Files" build phase targeting `Contents/MacOS`. This ensures the release bundle contains `MyApp.app/Contents/MacOS/extract_messages_limited`, the first lookup location used by `RustMessageExtractor`.
- After `flutter build macos`, run a post-build script (e.g., `_scripts/package_rust_extractor.sh`) that copies the binary into the bundle and sets executable bits:
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail

  APP_ROOT="build/macos/Build/Products/Release/MessageLens.app"
  DEST="$APP_ROOT/Contents/MacOS/extract_messages_limited"
  SRC="target/release/extract_messages_limited"

  if [[ ! -f "$SRC" ]]; then
    echo "Rust extractor missing at $SRC" >&2
    exit 1
  fi

  cp "$SRC" "$DEST"
  chmod 755 "$DEST"
  echo "Packaged Rust extractor -> $DEST"
  ```
- Codesign the binary alongside the app (`codesign --force --options runtime --sign "$IDENTITY" Contents/MacOS/extract_messages_limited`). Missing codesign causes Gatekeeper to quarantine the helper.
- Rebuild whenever the extractor CLI schema changes to avoid protocol mismatches between Dart and Rust.

## Logging & Failure Modes
- The extractor now writes structured diagnostics through `AppLogger` with source `RustMessageExtractor`.
- Logged context includes:
  - resolved `extractorPath`
  - current working directory
  - `chat.db` path passed to the helper
  - extraction limit
  - availability result
  - exit code, stderr, and decoded message count
- Missing binary or unreadable helper -> the importer logs extractor unavailability, writes `messages.richTextApplied = 0`, and the run still succeeds structurally with mostly blank message text.
- Non-zero exit codes bubble up as exceptions in `extractAllMessageTexts`; the rich-text importer catches the exception, records the failure in import logs, and continues without rich text.
- Watch both `messages.richTextApplied` and the message text counts in `import_log` to confirm the extractor ran and meaningfully updated rows.

## Validation Checklist
- `target/release/extract_messages_limited` exists and is executable.
- Running `./target/release/extract_messages_limited 5 /Users/rob/sqlite_rmc/messages/chat.db` emits JSON with `rowid` / `text` pairs.
- After an import, `macos_import.db` `messages.text` is populated for rows that previously had only `attributedBody`.

## Related References
- `_AGENT_CONTEXT/08-rust-message-extractor.md` (high-level background).
- `_AGENT_CONTEXT/11-orchestration-strategy.md` (import/migration overview).
- `../10-DATABASES/10-group-import-working.md` (contract binding import and projection).
- `./20-migration-orchestrator.md` (downstream projection responsibilities).
