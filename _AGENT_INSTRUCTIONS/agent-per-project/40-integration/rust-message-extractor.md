# Rust Message Text Extractor

## Purpose
- Decodes the binary `attributedBody` column from macOS `chat.db` so that messages missing plain `text` still display content.
- Runs as a standalone native binary (`extract_messages_limited`) that the import pipeline shells out to during stage 7 “Extracting rich message content”.
- Without this binary roughly 90% of messages land in the ledger with empty bodies.

## Component Map
- Binary: `target/release/extract_messages_limited` (also searched for next to `Platform.resolvedExecutable` when the macOS app is bundled).
- Rust crate: `rust/rust/attributed-string-decoder/` (Cargo project that produces the binary and a minimal flutter_rust_bridge stub).
- Flutter adapter: `lib/essentials/db_importers/infrastructure/extraction/rust_message_extractor.dart` implements `MessageExtractorPort`.
- Provider wiring: `lib/essentials/db_importers/feature_level_providers.dart` exposes `dbImportMessageExtractorProvider`; `OrchestratedLedgerImportService` depends on it.
- Import consumer: `MessageRichTextImporter` (orchestrated pipeline) located at `lib/essentials/db_importers/infrastructure/sqlite/importers/message_rich_text_importer.dart`, invoked from `OrchestratedLedgerImportService`.
- Database sink: `SqfliteImportDatabase.updateMessageText` applies the extracted strings to `messages.text`.

## Runtime Flow (Ledger Import)
1. `_importMessages` records extraction candidates where `message.text` is empty and `message.attributedBody` is a non-null blob.
2. `_extractRichText` checks `extract_messages_limited` availability via `MessageExtractorPort.isAvailable()` (logs from `importDebugSettingsProvider`).
3. On success the service invokes `extractAllMessageTexts(limit: rustExtractionLimit, dbPath: messagesDbPath)`.
4. The adapter shells out with `Process.run(extractorPath, args)` and expects JSON:
   ```json
   {"messages":[{"rowid":123,"text":"…"}]}
   ```
5. `_applyExtractedMessageText` trims each string and updates `messages.text` inside `macos_import.db`.
6. The orchestrated importer follows the same pattern through `ImportContext.extractor` and writes progress into its scratchpad (`messages.richTextApplied`).

## Binary Interface
```
./extract_messages_limited [limit] [chat.db path]
```
- `limit` (optional) caps how many rows the extractor processes (default used in Dart: `rustExtractionLimit = 200000`).
- `chat.db path` tells the binary which Messages database to scan; if omitted it defaults to the working directory copy.
- Exit code `0` → success with JSON on stdout. Any non-zero exit code is treated as failure and the pipeline falls back to empty text.

## Building & Packaging
1. `cd rust/rust/attributed-string-decoder`
2. `cargo build --release --bin extract_messages_limited`
3. Copy the result to the location the Flutter app expects:
   ```bash
   cp target/release/extract_messages_limited ../../../target/release/
   ```
4. Ensure the binary is executable (`chmod +x target/release/extract_messages_limited`).
5. When distributing a bundled macOS app, place the binary next to the Flutter executable so `RustMessageExtractor.extractorPath` resolves it.

### Production Packaging Playbook (macOS App Bundle)
- Flutter copies everything located under `macos/Runner/` into the app bundle when it is registered in Xcode as a resource or copy-files build phase. Keep the Rust binary under source control at `macos/Runner/Resources/extract_messages_limited`.
- In Xcode, add the binary to the “Copy Files” build phase targeting `Contents/MacOS`. This ensures the release bundle contains the executable at `MyApp.app/Contents/MacOS/extract_messages_limited`, which is the first lookup location used by `RustMessageExtractor`.
- Automate bundling after `flutter build macos` by dropping a post-build script (example below) into `_scripts/package_rust_extractor.sh` and calling it from CI:
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail

  APP_ROOT="build/macos/Build/Products/Release/remember_every_text.app"
  DEST="$APP_ROOT/Contents/MacOS/extract_messages_limited"
  SRC="target/release/extract_messages_limited"

  if [[ ! -f "$SRC" ]]; then
    echo "Rust extractor missing at $SRC" >&2
    exit 1
  fi

  cp "$SRC" "$DEST"
  chmod 755 "$DEST"
  echo "Packaged Rust extractor → $DEST"
  ```
- When notarizing/distributing, codesign the binary alongside the app (`codesign --force --options runtime --sign "$IDENTITY" Contents/MacOS/extract_messages_limited`). Missing codesign causes Gatekeeper to quarantine the helper.
- Keep the binary’s version in sync with the source to avoid mismatched protocol errors; rebuild whenever the extractor CLI schema changes.

## Logging & Failure Modes
- Availability checks print to stdout:
  - `🔍 Checking Rust extractor availability at: …`
  - `📁 File exists: true/false`
  - `📊 File mode: 100755` (octal permissions).
- Missing binary → `_extractRichText` logs “extractor not available” and returns an empty map; import still succeeds but text stays blank.
- Non-zero exit codes bubble up as exceptions in `extractAllMessageTexts`; both pipelines catch the error, log, and continue without rich text.
- Watch `messages.richTextApplied` in import summaries to confirm the extractor ran.

## Validation Checklist
- `target/release/extract_messages_limited` exists and is executable.
- Running `./target/release/extract_messages_limited 5 /Users/rob/sqlite_rmc/messages/chat.db` emits JSON with `rowid` / `text` pairs.
- After an import, `macos_import.db` `messages.text` is populated for rows that previously had only `attributedBody`.

## Related References
- `_AGENT_CONTEXT/08-rust-message-extractor.md` (high-level background).
- `_AGENT_CONTEXT/11-orchestration-strategy.md` (import/migration overview).
- `_AGENT_INSTRUCTIONS/agent-per-project/20-migrations/migration-playbook.md` (links to schema expectations).
