Stage 5 is committed on `feature/message-text-search`.

Commit: `0a56bf762578702719333320c20901fedf5c7915`

Message: `fix(search): apply AND and OR across search terms`

The affected test suite passed 141 tests, architecture checks passed 374 tests, and `flutter analyze` reported no issues. The protected `.vscode/settings.json` and search-enhancement instruction directory remain untracked and untouched.

## Link-preview audit conclusion

Apple-stored preview metadata appears useful enough to pursue, but it should be deferred to a separate feature branch. The repository already contains the beginnings of a decoder, but there is no representative automated payload fixture, its field coverage has not been validated across macOS versions, and historical payload preservation is presently incomplete.

### 1–4. Sources, fields, and current support

| Source | Repository evidence | Current MessageLens handling |
|---|---|---|
| `message.text` | Ordinary visible URL or message text | Imported, projected, and indexed in `message_text_fts` |
| `message.attributedBody` | Apple typedstream rich-text blob | Raw blob retained in the import ledger; decoder extracts only the first plausible plain-text string; object attributes and preview metadata are not retained |
| `message.message_summary_info` | Opaque source BLOB | Only a Boolean “was present” flag survives; bytes are discarded |
| `message.payload_data` | Opaque source BLOB | Only a Boolean “was present” flag survives; bytes are discarded |
| `attachment` plus `message_attachment_join` | Filename/path, transfer name, UTI, MIME type and message association | Imported and projected |
| `.pluginPayloadAttachment` file | Existing Rust plist parser expects `richLinkMetadata` | Decoder is exported but not used by production import, projection, UI, or search |
| Native `LPMetadataProvider` | Fetches current metadata from a URL | UI-only, network-dependent, transient 24-hour memory cache; unsuitable for historical indexing |

The source importer reads all three message blobs, but only preserves `attributedBody`; summary and payload bytes become presence flags ([message_importer.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/source_scoped_import/application/messages/message_importer.dart:34), [import_database_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart:438)).

The existing local plist decoder recognizes:

- `title`
- `summary`
- `siteName`
- one undifferentiated `URL`/`url`
- nested image URL
- nested icon URL
- nested video URL

See [api.rs](/Users/rob/Development/FlutterProjects/remember_every_text/rust/rust/attributed-string-decoder/src/api.rs:31).

The repository does not establish:

- separate original and canonical URLs;
- distinct page title versus preview title;
- publisher/provider;
- keywords;
- page MIME/content type;
- any additional separate Messages database containing preview semantics.

Attachment UTI/MIME values describe the Apple attachment wrapper, not necessarily the linked page.

The current attributed-body decoder only scans resolved primitive strings and returns the first plausible message-text candidate ([api.rs](/Users/rob/Development/FlutterProjects/remember_every_text/rust/rust/attributed-string-decoder/src/api.rs:4)). Consequently, it does not demonstrate that link objects are present in `attributedBody`, and it cannot preserve their structured properties.

The production preview UI instead extracts the literal URL from visible message text and asks `LPMetadataProvider` to fetch it ([message_attachment_evidence_tiles.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/presentation/widgets/message_evidence/message_attachment_evidence_tiles.dart:162), [LinkPreviewPlugin.swift](/Users/rob/Development/FlutterProjects/remember_every_text/macos/Runner/LinkPreviewPlugin.swift:46)). That pathway must remain outside any historical search index.

### 5. Historical and backfill feasibility

Offline backfill is feasible for some records, but coverage is not yet guaranteed:

- Attachment records and their message joins already preserve the path and canonical association.
- Newly imported attachments are included in the immediate source-range archive pass regardless of MIME type, provided archiving is enabled and the file still exists.
- The later five-minute retry sweep deliberately excludes null/blank-MIME attachments. Repository documentation identifies `.pluginPayloadAttachment` files as common examples of these opaque rows ([sqlite_graph_attachment_archive_candidate_reader.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/attachments/infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader.dart:156)).
- Manual full archiving is type-agnostic and may preserve still-present preview files.
- Historical recovery can preserve payload files when the selected snapshot includes an Attachments directory and cross-snapshot mapping succeeds.
- Existing `attributedBody` blobs can be reprocessed from the import ledger.
- Existing `message_summary_info` and `payload_data` cannot be reprocessed from the ledger because their bytes were discarded; they would require a read-only source re-import.

Therefore, a future backfill could decode available live or archived `.pluginPayloadAttachment` files without network access. It cannot recover files already evicted by Apple and never archived.

### 6. Canonical message identity

The mapping is already structurally sound:

- Message identity is `SourceScopedRowKey.pack(sourceId, sourceRowId)`.
- Attachments receive the same source-scoped identity treatment.
- `message_to_attachment` records both `message_ss_id` and `attachment_ss_id` ([message_attachment_join_importer.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/source_scoped_import/application/message_attachment_joins/message_attachment_join_importer.dart:69)).
- The graph projects that association directly ([conversation_graph_database.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart:316)).

A decoded preview record should therefore be keyed by its source-scoped attachment identity and carry `message_ss_id`. GUID-only association should not be the primary search identity.

### 7–12. Recommended search behavior

Recommended searchable fields:

- title;
- summary/description;
- site name;
- stored page URL and its derived host/domain;
- additional semantic strings only if later fixtures establish them.

Do not index:

- image, icon, or video asset URLs;
- binary thumbnail data;
- attachment filenames;
- wrapper UTI/MIME values;
- inferred keywords not actually persisted by Apple.

A separate `message_link_fts` domain is warranted. `message_text_fts` should remain restricted to visible message text ([conversation_graph_database.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart:110)).

Stage 5 already has the correct composition point: it gathers a result set for every term, unions text and tag evidence into that term, and then applies AND or OR across term sets ([graph_search_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/infrastructure/repositories/graph_search_repository.dart:28)).

The eventual addition is naturally:

```text
termHits(term) =
    textHits(term)
    UNION tagHits(term)
    UNION linkPreviewHits(term)
```

No special query syntax is needed. Link-preview FTS can consume the same parsed tokens:

- unfinished token → prefix;
- whitespace-completed token → exact;
- AND → every term must be satisfied, possibly by different evidence domains;
- OR → any term may be satisfied.

For explainability, decoded records should retain individual fields and match provenance. That would support labels such as `Matched link preview: Thermocouple Calibration Guide`. The current repository returns only message IDs, so explanation would require an additional match-evidence result or lookup rather than contaminating the ID-selection API.

### 13. Migration and backfill implications

A future implementation should include:

1. Sanitized representative Apple payload fixtures before settling the schema.
2. A source-derived `message_link_previews` table keyed by preview/attachment identity and `message_ss_id`.
3. A separate `message_link_fts` table over approved semantic fields.
4. An idempotent local decoder stage after attachment and join ingestion.
5. Decoder version/status information so malformed or unsupported payloads remain diagnosable.
6. An offline backfill over available live and preserved archive payloads.
7. Explicit handling for files missed because null-MIME preview payloads are excluded from periodic retry.
8. Search provenance sufficient for an eventual match explanation.
9. Message-data version invalidation after newly decoded metadata becomes searchable.
10. No calls to `LPMetadataProvider`, HTTP clients, crawlers, or other network enrichment.

The backfill must also respect the graph/overlay boundary: ordinary graph projection should not start reading overlay state directly. Archive lookup should remain behind an attachment feature port, and decoded source facts should be persisted before ordinary graph projection consumes them.

### 14–15. Tests and remaining unknowns

Existing evidence includes:

- one Rust fixture for attributed-body plain-text extraction;
- synthetic tests identifying and collapsing `.pluginPayloadAttachment` resources;
- synthetic tests proving null/blank-MIME payloads are excluded from periodic archive retry;
- URL preview widget tests that mock the network-backed native service;
- a tracked manual diagnostic script aimed at one private local payload ([test_url_preview_parser.dart](/Users/rob/Development/FlutterProjects/remember_every_text/test_url_preview_parser.dart:1)).

There is no checked-in, non-private `.pluginPayloadAttachment` or rich-link plist fixture. The manual script was not run.

Representative data is therefore still needed to establish:

- which fields are populated in practice;
- incoming versus outgoing differences;
- macOS/iOS version differences;
- whether the files are direct plists, keyed archives, or multiple formats;
- how multiple preview resources relate to one link;
- whether summary/payload message blobs contain additional useful metadata;
- prevalence and historical coverage.

### 16–17. Proposed scope and recommendation

The feature appears worthwhile, but the exact implementation should begin with a fixture-and-decoder validation slice, followed by source-fact persistence, separate FTS indexing, offline backfill, cross-domain search composition, and explainability tests.

Recommendation: **defer link-preview indexing to a subsequent feature branch**. Stage 5’s lower-level semantics are now stable, while link-preview search has independent decoder, preservation-policy, migration, fixture, and provenance concerns that deserve their own reviewable history.

No source files or release metadata were changed during this audit. The post-commit worktree contains only the two explicitly protected untracked paths.

::git-commit{cwd="/Users/rob/Development/FlutterProjects/remember_every_text"}
