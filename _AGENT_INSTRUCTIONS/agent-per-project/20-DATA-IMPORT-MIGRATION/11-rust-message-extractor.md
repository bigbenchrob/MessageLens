---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ./12-bounded-message-import-and-rich-text-enrichment.md
  - ../60-BUILD-CONSIDERATIONS/01-rust-ffi-dylib-bundling.md
tests:
  - ../../../rust/rust/attributed-string-decoder/src/api.rs
  - ../../../test/essentials/source_scoped_import/application/messages/message_rich_text_enricher_test.dart
---

# Rust Attributed-Body Decoder

## Current Runtime Boundary

MessageLens decodes Apple `attributedBody` values through the in-process
Flutter Rust Bridge function `decodeTypedstreamBlob`. The bundled
`attributed_string_decoder.framework` supplies that function in a packaged
macOS app.

The active initial-import, reimport, live-sync, and Historical Archives paths do
not ask the standalone `extract_messages_limited` executable to scan
`chat.db`. They read bounded BLOB pages from `macos_import_ss.db` and pass a
bounded `Map<ss_id, Uint8List>` to `MessageExtractorPort`.

## Component Map

- Rust decoder and resource envelope:
  `rust/rust/attributed-string-decoder/src/api.rs`
- Dart adapter:
  `lib/essentials/source_scoped_import/infrastructure/extraction/rust_message_extractor.dart`
- Port:
  `lib/essentials/source_scoped_import/domain/ports/message_extractor_port.dart`
- Enrichment coordinator:
  `lib/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart`
- FFI packaging:
  `60-BUILD-CONSIDERATIONS/01-rust-ffi-dylib-bundling.md`

## Decode Flow

1. Source message import preserves `attributed_body_blob` in the source-scoped
   ledger.
2. The enricher freezes a missing-text candidate window and reads bounded
   metadata pages without BLOB values.
3. It partitions work by BLOB byte length and materializes only within-budget
   payloads.
4. The Dart adapter iterates the `ss_id`-keyed map and calls
   `decodeTypedstreamBlob` once per record.
5. A successful non-empty result is persisted with
   `WHERE ss_id = ? AND text IS NULL`.
6. Graph projection copies the resulting text into graph message evidence.

The adapter reports progress at completion and every 1,000 records within the
already bounded call. The coordinator's smaller byte pages remain the memory
authority.

## Native Resource Envelope

The wrapper validates input before invoking `crabstep` 0.2.1 and bounds the
resolved-property walk:

| Resource | Limit | Failure behavior |
| --- | ---: | --- |
| Typedstream input | 8 MiB | Returned error before parsing |
| `0x84` control markers | 1,024 | Returned error before parsing |
| Consecutive reference-like bytes | 1,024 | Returned error before parsing |
| Resolved property depth | 256 | Returned error |
| Resolved property nodes | 65,536 | Returned error |

The property walk is iterative. `catch_unwind` converts a panic inside the
accepted resource envelope into an ordinary decoder error.

These are per-record native limits. The Dart coordinator separately enforces a
default 8 MiB cumulative decoder-page target, a matching 8 MiB per-record
materialization ceiling, and 500-record candidate metadata pages.

## Record-Local Failure Semantics

The Dart adapter catches one record's native error and continues. Empty,
malformed, unexpectedly structured, oversized, or otherwise undecodable data
therefore yields no decoded text for that `ss_id`; the coordinator counts it as
decode unavailable and preserves the source row and BLOB evidence.

Decoder availability itself is checked with a small known-good in-process
smoke BLOB. If that run-wide check fails, enrichment fails systemically rather
than presenting a corpus-wide successful no-op.

## Source Identity

The integer keys crossing the decoder port are opaque work IDs. In production
rich-text enrichment they are canonical message `ss_id` values, not Apple
source `ROWID` values. Native callback IDs, decoded maps, and persistence must
retain those keys unchanged.

## Standalone Helper Compatibility

`RustMessageExtractor.extractAllMessageTexts(...)` and the bundled
`extract_messages_limited` executable remain compatibility/diagnostic
interfaces. They are not called by the active graph or Historical Archives
enrichment paths and their optional row limit is not a safety bound for those
paths.

The current Rust Cargo manifest declares the FFI library, not a maintained
`extract_messages_limited` binary target. The Xcode and distribution scripts
still copy/sign an existing helper executable when one is present. Do not claim
that `cargo build --release --bin extract_messages_limited` regenerates it from
the current crate, and do not make release correctness depend on an
undocumented helper rebuild path. The active decoder is the rebuilt and bundled
FFI framework.

## Building and Packaging the Active Decoder

```text
cd rust/rust/attributed-string-decoder
cargo build --release
```

The `Bundle Rust FFI Library` Xcode phase packages
`libattributed_string_decoder.dylib` as the versioned
`attributed_string_decoder.framework`. `main.dart` resolves that framework
relative to `Platform.resolvedExecutable`, avoiding LaunchServices working-
directory dependence.

Production packaging must sign the embedded framework with the app's Developer
ID identity and retain hardened runtime. See the build document for the exact
framework structure and verification rules.

## Verification

- Rust unit tests cover valid, empty, truncated, malformed-length,
  control-marker, reference-run, deterministic-random, large, and over-limit
  inputs.
- `cargo clippy --all-targets --all-features -- -D warnings` must pass.
- Enricher tests cover byte partitioning, over-limit non-materialization,
  duplicate source ROWIDs across sources, interruption boundaries, and
  preservation of undecodable records.
- Packaged-process qualification must exercise the production coordinator and
  FFI decoder behavior, not substitute the legacy helper full-scan interface.
