# Rust Message Extractor Documentation

## Critical Importance

The Rust message extractor is **absolutely essential** for proper message text extraction. Without it:

- ~90% of messages will appear to have empty text content
- Only messages with plain `text` field content will be readable
- The majority of iMessage content stored in binary `attributedBody` fields will be lost

## Architecture Overview

### Why Rust is Required

macOS Messages stores rich text (formatted messages, emojis, links, etc.) in a binary `attributedBody` field using Apple's proprietary NSAttributedString format. This binary data cannot be easily parsed in Dart/Flutter and requires native code with Apple frameworks access.

### Text Storage Pattern

```
Messages Database Storage:
├── message.text (plain text) - ~10% of messages
└── message.attributedBody (binary NSAttributedString) - ~90% of messages
```

## File Locations

### Rust Source Code

```
rust/
├── rust/
│   └── attributed-string-decoder/
│       ├── Cargo.toml
│       ├── src/
│       │   ├── lib.rs          # Main library code
│       │   ├── api.rs          # Flutter bridge API
│       │   └── frb_generated.rs # Generated bridge code
│       └── target/
│           ├── debug/
│           │   └── extract_messages_limited
│           └── release/
│               └── extract_messages_limited
```

### Expected Binary Location

```
target/release/extract_messages_limited
```

This is where the Flutter app looks for the extractor binary.

### Flutter Integration

```
lib/essentials/db_importers/infrastructure/extraction/
└── rust_message_extractor.dart
```

## Building the Extractor

### From Source Directory

```bash
cd rust/rust/attributed-string-decoder
cargo build --release --bin extract_messages_limited
```

### Copy to Expected Location

```bash
cp rust/rust/attributed-string-decoder/target/release/extract_messages_limited target/release/
```

### One-Command Build & Install

```bash
cd rust/rust/attributed-string-decoder && \
cargo build --release --bin extract_messages_limited && \
cp target/release/extract_messages_limited ../../../target/release/
```

## Runtime Behavior

### Availability Check

The Flutter app automatically checks for the extractor:

```dart
Future<bool> isAvailable() async {
  final path = extractorPath; // "target/release/extract_messages_limited"
  final file = File(path);
  return file.existsSync();
}
```

### Console Output Examples

**Extractor Available:**

```
🔍 Checking Rust extractor availability at: target/release/extract_messages_limited
📁 File exists: true
📊 File mode: 100755
```

**Extractor Missing:**

```
🔍 Checking Rust extractor availability at: target/release/extract_messages_limited
📁 File exists: false
```

### Import Process Integration

1. **Check Availability**: App checks if extractor exists
2. **Extract Text**: If available, processes all `attributedBody` fields
3. **Fallback Mode**: If missing, imports proceed but with limited text content
4. **Update Database**: Extracted text is stored in import database

### API Contract

The extractor expects:

- **Input**: Messages database path (optional)
- **Output**: JSON with message ROWID → extracted text mapping

```bash
./extract_messages_limited [limit] [db_path]
```

**Output Format:**

```json
{
  "messages": [
    { "rowid": 1, "text": "Hello world! 👋" },
    { "rowid": 2, "text": "Check out this link: https://example.com" },
    { "rowid": 3, "text": "🎉 Celebration time!" }
  ]
}
```

## Troubleshooting

### Binary Missing

**Symptom**: `📁 File exists: false`
**Solution**: Build and copy binary to `target/release/extract_messages_limited`

### Permission Denied

**Symptom**: Process execution fails
**Solution**: Ensure binary is executable: `chmod +x target/release/extract_messages_limited`

### Build Failures

**Requirements**:

- Rust toolchain installed
- macOS with Xcode command line tools
- Access to Apple frameworks (Foundation, etc.)

### Import Success Without Extractor

**Behavior**: Import completes but most message text is empty
**Fix**: Add extractor and re-run import for complete text extraction

## Development Notes

### Source Project Origin

The Rust code was originally developed in the `remember_this_text` project and has been copied to maintain the extractor functionality.

### Dependencies

- `flutter_rust_bridge` - For Dart ↔ Rust communication
- Apple Foundation frameworks - For NSAttributedString parsing
- `serde_json` - For JSON output formatting

### Maintenance

- Keep Rust source in sync if core logic changes
- Rebuild binary when updating Rust dependencies
- Test extractor availability in CI/CD pipelines

## Integration with Import Process

### OrchestratedLedgerImportService Flow

1. **Initialize**: Check extractor availability
2. **Import Messages**: Process messages table normally
3. **Extract Rich Text**: If extractor available, process `attributedBody` fields
4. **Update Records**: Replace empty/partial text with extracted content
5. **Complete**: Import finishes with full message text content

### Performance Impact

- **With Extractor**: ~10-20% longer import time, 90% more text content
- **Without Extractor**: Faster import, 90% content loss
- **Recommendation**: Always use extractor for production imports

The extractor is essential for a complete Messages import experience.
