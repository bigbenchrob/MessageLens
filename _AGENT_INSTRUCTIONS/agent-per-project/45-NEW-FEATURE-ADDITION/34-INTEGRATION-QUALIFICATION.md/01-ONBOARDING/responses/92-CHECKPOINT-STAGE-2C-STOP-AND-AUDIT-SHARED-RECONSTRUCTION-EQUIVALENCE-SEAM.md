# Response 92 — Checkpoint Stage 2C Stop and Audit Shared Reconstruction Equivalence Seam

Date: 2026-10-11

Scope: checkpoint the already-approved Stage 2C safety stop, then perform a read-only source and architecture audit. This response does not implement Start Fresh, a reconstruction witness, a shared transformation seam, production AppCzar activation, or any database/archive mutation.

## 1. Baseline and audit boundary

The audit began on `fix/onboarding-import-stuck-state` at `937ad5d28c067d47bbbf5461ef010641c07ead9d`, synchronized with its upstream. The tracked worktree and index were clean. The shared-instructions submodule was clean at `95326f515ef4719f155ce6e223990398daad6311`. Only the previously known unrelated untracked files and Prompt 92 were present.

The audit was source-only. I did not run tests, analysis, code generation, a build, MessageLens, fixture builders, or any database command. I did not inspect or mutate a real Messages database, MessageLens database, attachment archive, bookmark, preference, or external-drive artifact.

The source-only baseline manifest is outside the repository at `/private/tmp/messagelens-prompt92-baseline-manifest.md`.

## 2. Stage 2C stop checkpoint

I inspected and checkpointed only Prompt 91 and Response 91:

- commit: `0da40b75d4f6aca972d7ac745a41079c4bc6d479`
- subject: `docs(appczar): record Stage 2C safety stop`
- pushed branch: `origin/fix/onboarding-import-stuck-state`
- post-push divergence: `0 0`

The checkpoint records the reason destructive Start Fresh must remain unavailable: the current code has no proof that rebuilding populated import, graph, and FTS state would be semantically equivalent while preserving every independent/protected fact. Prompt 92 and this response are intentionally not part of that checkpoint and remain untracked for review.

## 3. Current AppCzar authority census

The current source exposes seven explicit AppCzar jurisdictions:

1. Data Update
2. Source Access Repair
3. Attachment Archive Repair
4. Onboarding
5. Local Data Repair
6. Diagnostic Review
7. Operating Session

Operating-owned Start Fresh is a command surface contemplated by Stage 2C, not an eighth jurisdiction. Its destructive implementation was removed at the Prompt 91 stop.

The authority flow remains one-way: current evidence is observed, AppCzar chooses exactly one disposition, and one bounded coordinator owns the admitted work. Operating Session cannot acquire reset authority merely because it is already running. Production AppCzar activation remains disabled; production still uses its existing startup composition. The development AppCzar composition requires an already admitted official development application identity, while operation-specific mutation policies remain independently narrower.

## 4. Exact reset footprint and schema inventory

`MessageDataResetService` defines the active rebuildable footprint by explicit database families, not by deleting a broad data root:

| Logical store | Physical family | Schema | Start Fresh disposition | Local Data Repair disposition |
|---|---|---:|---|---|
| Source-scoped import ledger | `macos_import_ss.db`, `-wal`, `-shm` | 10 | delete/rebuild | delete/rebuild |
| Conversation graph and FTS | `working_ss.db`, `-wal`, `-shm` | 3 | delete/rebuild | delete/rebuild |
| Retired import artifact | `macos_import.db`, `-wal`, `-shm` | retired | delete if present | preserve |
| Retired graph artifact | `working.db`, `-wal`, `-shm` | retired | delete if present | preserve |

The following are outside that deletion footprint and must remain untouched:

- `user_overlays.db` family, schema 8;
- `presence.db` family, schema 9;
- `attachment_archive/` payloads, manifest, generation, and active-location configuration;
- source/archive bookmarks and security-scoped authorization state;
- app preferences, installation/setup state, historical-source registry, donor configuration, and logs except for ordinary append-only runtime behavior;
- the macOS Messages and Contacts sources.

This explicit file inventory prevents broad-root deletion, but file selection alone does not prove semantic reconstruction equivalence. The active stores contain stable identifiers and derived relationships referenced by protected stores.

## 5. Source-scoped import transformation matrix

The import schema is defined in `lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart`. The current production writers live under `lib/essentials/source_scoped_import/application/`.

| Material domain | Consequential fields and mapping | Current writer behavior | Equivalence status |
|---|---|---|---|
| `source_registry` | `source_id`, unique `source_key`, kind, label, creation time | Ensures a live source and records operational creation time | Identity is material; creation time is temporal and not yet classified safely |
| `import_batches` | batch ID, source ID, start/finish time, notes | Allocates auto IDs and wall-clock timestamps | Operational/provenance semantics are not yet proven ignorable |
| `messages` | packed `ss_id`; source row ID; GUID; sender; direction; normalized Apple dates; text; attributed-body blob; association/thread fields; raw types; error and source flags; batch | Keyset-pages current `chat.db`; preserves every row; converts dates through `DateConverter`; enriches some text later | Writer mapping is private and stateful; no reusable canonical row transformation exists |
| `handles` | packed ID; source ID/row; raw handle; service; `is_me`; batch | Imports raw identities, then derives/updates `is_me` from accounts/messages/current ledger state | Ordering and prior-state dependencies are material and not isolated |
| `chats` | packed ID; GUID; service; group IDs; last-read date; batch | Copies rows with service fallback and timestamp conversion | Mapping is private to importer |
| `chat_to_message` | source and packed chat/message identities | Omits edges whose endpoints cannot be resolved; inserts uniquely | Omission behavior and endpoint timing must be shared exactly |
| `chat_to_handle` | source chat/handle identities and packed endpoints | Omits unresolved endpoints; inserts uniquely | Same blocker as other joins |
| `contacts` | packed contact ID; names; organization; display name; created date; batch | AddressBook-specific reading with fallback/omission rules | Some pure helpers exist, but full row formation is not canonicalized |
| `contact_channels` | contact identity; kind; normalized value; label; batch | Email and phone normalization; rejects invalid owners/values | Partly covered by `contact_source_projection.dart`; importer still owns consequential decisions |
| `attachments` | packed ID; GUID; filename/transfer name; UTI/MIME; bytes; created date; batch | Incremental source-row import and date normalization | Mapping is private; source availability is temporal |
| `message_to_attachment` | separate message/attachment source identities and packed endpoints | Omits unresolved endpoints; inserts uniquely | Required by archive coverage and protected archive records; not safely reproducible from an absent source |

Material indexes include source cursors, GUID/identifier lookup, display/channel lookup, join lookup, and incremental cursors. Their logical behavior matters, although byte-for-byte B-tree layout does not.

## 6. Conversation graph and FTS transformation matrix

The graph schema is defined in `lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart`. Production projection repositories live under `lib/essentials/conversation_graph/infrastructure/repositories/`.

| Graph domain | Consequential projection | Current authority | Equivalence blocker |
|---|---|---|---|
| `messages` | copies stable ID/GUID/sender/direction/date/text; resolves associated-message ID; resolves canonical sender; derives semantic kind, item kind, sparse/system/source flags | `message_projection_repository.dart` | Resolution and classification are embedded in the mutating repository |
| `handles` | copies raw handles | `handle_projection_repository.dart` | Coupled to alias rebuild |
| `canonical_handles` | groups normalized identities; selects display/service by preference score and stable tie-break | same repository | Grouping, scoring, and tie-break are semantic identity authority, not a cache detail |
| `handle_aliases` | maps each raw handle to canonical identity and records alias kind/normalization | same repository | Protected overlay references depend on the resulting IDs retaining meaning |
| `chats` | copies GUID/service/read date; derives `is_group` from projected participants | `chat_projection_repository.dart` | Depends on edge projection order and participant state |
| `chat_to_message` | copies valid stable pairs | corresponding projection repository | Edge completeness and endpoint identity matter |
| `chat_to_handle` | copies valid stable pairs | corresponding projection repository | Drives group classification |
| `contacts` | trims/falls back names and suppresses nonmeaningful/unknown-only rows | `contact_projection_repository.dart` | Different domain from source contact mapping; rules are private |
| `contact_to_handle` | converts channels to normalized handle keys and selects canonical matches | same repository | Contact-to-canonical linkage depends on shared identity semantics and projection order |
| `attachments` | copies stable attachment metadata | `attachment_projection_repository.dart` | Drives visible metadata and archive coverage |
| `message_to_attachment` | copies valid stable message/attachment pairs | corresponding projection repository | Required for exact attachment coverage and archive association |
| `message_text_fts` | FTS5 external-content index over message text with `unicode61 remove_diacritics 2`, prefix `2 3 4`, maintained by insert/delete/text-update triggers | schema/triggers plus SQLite FTS | Logical indexed content/configuration can be compared; physical shadow-table bytes cannot |

There is no single pure graph transformation module consumed both by these production writers and by a read-only witness.

## 7. Importer authority finding

The importers are the de facto transformation authorities today, but their authority is distributed among database-writing classes. They combine:

- source SQL and paging;
- schema interpretation;
- `SourceScopedRowKey.pack` identity construction;
- timestamp conversion;
- normalization and fallback decisions;
- anomaly accounting;
- endpoint existence and edge omission;
- progress and batch mutation.

The exact current writer entry points are:

| Family | Current authoritative file and method(s) |
|---|---|
| Source registry and import batches | `infrastructure/import_database_provider.dart`: `SqliteSourceScopedImportLedger.insertImportBatch(...)` and `_ensureLiveSource(...)` |
| Messages | `application/messages/message_importer.dart`: `MessageImporter.importNewMessages(...)`; private row readers and `_senderHandleSsId(...)` |
| Rich-text completion | `application/messages/message_rich_text_enricher.dart`: `enrichMissingText(...)`, `enrichMissingTextAfterSourceRowId(...)`, `enrichMissingTextForSource(...)`, and `_enrichMissingText(...)` |
| Handles and local-account identity | `application/handles/handle_importer.dart`: `importNewHandles(...)`, `reconcileLocalAccountIdentity(...)`, `_interpretIdentifier(...)`, and `_readLocalAccountHandleKeys(...)` |
| Chats | `application/chats/chat_importer.dart`: `importChats(...)` |
| Contacts and channels | `application/contacts/contact_importer.dart`: `importContacts(...)` and `_insertChannel(...)`, assisted but not fully governed by `contact_source_projection.dart` |
| Attachments | `application/attachments/attachment_importer.dart`: `importAttachments(...)` |
| Chat/message joins | `application/chat_message_joins/chat_message_join_importer.dart`: `importJoins(...)`, `importJoinsAfterSourceMessageRowId(...)`, and `_importJoinsWhere(...)` |
| Chat/handle joins | `application/chat_handle_joins/chat_handle_join_importer.dart`: `importJoins(...)` |
| Message/attachment joins | `application/message_attachment_joins/message_attachment_join_importer.dart`: `importJoins(...)`, `importJoinsAfterSourceMessageRowId(...)`, and `_importJoinsWhere(...)` |

Tests exercise outputs, but a future witness would have to reimplement the same transformations to predict them. Two independently maintained implementations could agree accidentally on common cases while diverging on nulls, anomalies, legacy rows, ordering, or normalization. Therefore current tests do not establish a shared reconstruction-equivalence authority.

Existing focused evidence includes message, rich-text, contact, attachment, message/attachment-join, source-key, associated-reference, anomaly-count, paging, source-database, archive-import, and import-database tests under `test/essentials/source_scoped_import/`. There are no equally direct importer tests for every handle/chat/chat-edge transformation. More importantly, the existing tests prove writer behavior in cases; they do not prove that a read-only observer and the writer share one transformation implementation.

## 8. Projector authority finding

The graph projectors are likewise the only current authorities for their outputs. They read the import ledger and mutate graph tables while resolving associations, canonicalizing handles, linking contacts, classifying messages, and deriving group state. Their semantics are split across repositories and projection ordering.

The exact current repository entry points are:

| Family | Current authoritative file and method(s) |
|---|---|
| Messages and classifications | `infrastructure/repositories/message_projection_repository.dart`: `projectMessages(...)`, `projectMessagesAfterSourceRowId(...)`, `_projectMessagesWhere(...)`, `_resolveAssociatedMessageSsId(...)`, `_resolveSenderCanonicalHandleSsId(...)`, `_semanticKind(...)`, `_itemKind(...)`, and `_isSparseArtifact(...)` |
| Handles, canonical handles, aliases | `handle_projection_repository.dart`: `projectHandles()`, `projectLocalAccountIdentity()`, `_rebuildHandleAliases()`, `_interpretIdentifier(...)`, `_synchronizeMessageCanonicalHandles()`, and `_removeContactEdgesWithoutCanonicalHandle()` |
| Chats and group state | `chat_projection_repository.dart`: `projectChats(...)` and `_participantCount(...)` |
| Contacts and canonical-handle linkage | `contact_projection_repository.dart`: `projectContacts()` and `_handleSsIdsByKey()` plus its private meaningful-contact predicate |
| Attachments | `attachment_projection_repository.dart`: `projectAttachments(...)`, `projectAttachmentsAfterSourceRowId(...)`, and `_projectAttachmentsWhere(...)` |
| Chat/message edges | `chat_to_message_projection_repository.dart`: `projectEdges()`, `projectEdgesAfterSourceMessageRowId(...)`, and `_projectEdgesWhere(...)` |
| Chat/handle edges | `chat_to_handle_projection_repository.dart`: `projectEdges()` |
| Message/attachment edges | `message_to_attachment_projection_repository.dart`: `projectEdges()`, `projectEdgesAfterSourceMessageRowId(...)`, and `_projectEdgesWhere(...)` |
| FTS content maintenance | `conversation_graph_database.dart`: `message_text_fts` declaration and its insert/delete/text-update triggers |

A witness that queried expected rows with new SQL would create a second semantic implementation. A witness that invoked the mutating repositories would violate read-only proof and could not safely target a disposable candidate without additional authority/binding work. The correct first move is to extract bounded pure transformations from the writers, not to duplicate their algorithms in a checker.

Existing graph evidence includes message, attachment, contact, chat/message, chat/handle, and message/attachment projector tests; handle/chat topology flows; graph build orchestration; database schema; and FTS runtime tests under `test/essentials/conversation_graph/`. These are valuable parity anchors, but they do not cover every private canonicalization/classification branch as a reusable contract, nor do they prove protected-reference equivalence after a populated rebuild.

## 9. Rich-text, payload, and anomalous-message semantics

`message_importer.dart` retains attributed-body blobs and imports anomalous rows rather than suppressing them. `message_rich_text_enricher.dart` later reads bounded candidates whose text is absent, calls the Rust attributed-string decoder, trims usable output, and updates import text. Empty/failed extraction does not fabricate text.

Consequences for equivalence:

- raw source rows, blobs, flags, and anomalous records must remain present;
- decoded text depends on the exact decoder behavior/version and its limits;
- the witness may not silently substitute current text rules for the rules that created retained historical data;
- decoder failure/limit behavior and retry ordering are material;
- message summary/payload-source flags cannot be inferred merely from displayed text.

Until the decoder contract and the canonical message projection are explicitly shared and versioned, rich-text material keeps the aggregate proof UNKNOWN.

## 10. Contacts transformation finding

Contacts are the best first extraction candidate because `contact_source_projection.dart` already contains pure helpers for:

- trimming nonempty values;
- composing display names from first/middle/last with organization fallback;
- email normalization;
- phone normalization through the canonical handle utility with raw fallback;
- Apple timestamp conversion through `DateConverter`.

However, `contact_importer.dart` still owns full row formation, invalid-primary-key handling, invalid-channel-owner handling, fallback behavior, batching, and source order. Graph contact projection separately decides meaningful contacts and canonical-handle linkage. Thus Contacts are not yet a completed shared seam, but the existing pure helper makes them the smallest low-risk place to begin one.

## 11. Canonical identities, joins, timestamps, and attachments

Reconstruction equivalence must cover more than visible message text:

- packed source-scoped IDs must be identical for the same physical source identity;
- message GUID association normalization and resolution must select the same target;
- canonical handle grouping, display selection, service preference, alias kind, and tie-breaks must be identical;
- chat/message, chat/handle, contact/handle, and message/attachment edges must preserve the same endpoint meanings;
- all Apple timestamps must continue through `DateConverter`; no witness may reproduce epoch/unit logic;
- attachment stable IDs, source row IDs, metadata, joins, GUIDs, and archive-relative provenance must agree;
- omission of an unresolved edge is a consequential result that must itself be explained, not silently treated as equivalent.

Stable integer equality is necessary where protected data stores those integers, but semantic identity equality is the real requirement.

## 12. Batch, provenance, and operational metadata

Import batch IDs and wall-clock timestamps are generated during writing. Some values may ultimately be classified as operational rather than user-visible material, but that exclusion is not currently proven. Before excluding them, the design must show that no protected store, recovery path, cursor, diagnostic, archive record, or subsequent projector uses them to determine identity, completeness, or provenance.

The witness must therefore distinguish:

- deterministic material that must match exactly;
- deterministic material that may match by an explicit normalized representation;
- temporal/operational material that is deliberately excluded by a documented nondependency proof;
- material whose role is still unknown.

Any unclassified domain makes the overall result UNKNOWN, not TRUE.

## 13. FTS equivalence definition

FTS equivalence must not mean byte equality of SQLite shadow tables, page layout, WAL state, or internal row allocation. A safe logical proof requires all of the following:

1. the same declared FTS5 schema, content table/rowid binding, tokenizer options, prefix configuration, and maintenance triggers;
2. the same indexed `(message ss_id, text)` material after canonical message projection and rich-text enrichment;
3. a successful bounded FTS integrity/maintenance check;
4. selected deterministic query probes covering diacritics, prefixes, null/empty text, updates, deletes, and anomalous records;
5. no unsupported SQLite/FTS version drift.

If configuration or library behavior cannot be proven compatible, FTS is UNKNOWN and destructive Start Fresh is refused.

## 14. Stable, temporal, and protected fact classification

| Class | Examples | Required treatment |
|---|---|---|
| Stable source identity | source keys/row IDs, packed IDs, GUIDs, normalized handle keys | Exact semantic preservation |
| Stable derived meaning | canonical handle membership, message semantic kind, group status, graph edges | Recompute only through the shared production transformation and compare |
| Temporal source fact | current Messages/Contacts rows, attachment file availability, source high-water | Bind to a stable bounded observation; drift fails closed |
| Operational metadata | batch IDs/times, progress counters, WAL layout | Exclude only after explicit nondependency proof |
| Protected independent intent | favourites, tags, annotations, visibility, participant/handle overrides | Never delete; prove references retain the same meaning |
| Preservation data | archived payload bytes, hash/provenance, archive generation/location | Never treat as cache; preserve and validate binding |
| Unknown | unsupported schema, unreadable source, unclassified column or relationship | Overall reconstruction result UNKNOWN |

No unique protected or temporal fact was classified as disposable merely because it resides near derived data.

## 15. Candidate witness architectures

### A. Shared pure canonical transformations

Extract deterministic row/edge/classification functions from production importers and projectors. Writers and the witness consume the same typed functions. Source I/O, database writes, progress, and capabilities remain outside the pure seam.

Strength: removes parallel semantic implementations. Weakness: requires several small behavior-preserving extractions before full proof is possible.

### B. Bounded read-only anti-difference witness

Read current sources and existing derived stores through independent read-only connections, apply the shared transformations, and compare page counts, keyed digests, and first mismatches. Use two-pass stability fences and protected-reference checks.

Strength: does not construct or mutate a candidate database. Weakness: only trustworthy after A supplies canonical transformations.

### C. Full in-memory candidate reconstruction

Build an entire candidate import/graph/FTS database and compare it.

Rejected as the primary design: it duplicates orchestration, can consume unbounded memory/disk for more than 100,000 messages and blobs, risks exercising mutating infrastructure during proof, and still needs A to avoid a second implementation. It may later be useful only as a bounded disposable end-to-end test.

### D. Current narrow reset subset

Authorize only cases already proven by Local Data Repair: empty/absent graph plus narrowly reconstructed live-only import facts.

Valid but not a populated Start Fresh solution. It is already represented by Local Data Repair and must not be relabeled as general reconstruction equivalence.

## 16. Recommended architecture

Use A and B together:

```text
current source/read-only retained facts
        │
        ▼
shared typed canonical transformations
        │
        ├── production import/project writers
        └── bounded read-only anti-difference witness
                    │
                    ▼
       tri-state material-equivalence evidence
```

The witness must remain a Fair Witness. It reports facts and mismatch evidence; it does not grant destructive authority. AppCzar remains the semantic policy authority, Operating remains the command host, and any later reset mutation must occur only inside one freshly admitted typed Ball whose binding includes the proven evidence generation.

Separate read-only database connections are preferable to cross-attaching real stores. Cross-database SQL is not necessary to establish keyed logical equality and would widen accidental-write and path-confusion risk.

Mechanical enforcement should include an architecture test that keeps pure transformation modules free of SQLite handles, provider refs, filesystem access, clocks, mutation capabilities, and UI dependencies; requires the production writer and witness to import the same concrete transformation module; forbids the witness from importing writer repositories or opening/creating writable databases; and flags fresh transformation SQL in the witness. Golden/parity fixtures then prove the writer's before/after output, while metamorphic tests cover ordering and paging invariance. The shared functions should be concrete typed functions/value objects rather than an injectable strategy that permits writer and witness to receive different semantics.

## 17. Snapshot coherence and TOCTOU design

SQLite read transactions can stabilize each database independently, but there is no atomic snapshot spanning Messages, Contacts, import, graph, overlay, presence, archive configuration, and the filesystem. The bounded design must therefore use two-sample coherence:

1. capture source identity, schema, high-water/count, and page/keyed digests;
2. capture import/graph schemas and material digests;
3. capture protected-store reference digests and archive binding/generation;
4. repeat the material boundary sample;
5. accept the evidence only when both samples agree;
6. after human confirmation, rerun a short pre-Ball fence; any drift aborts and returns to fresh AppCzar assessment.

The operation binding must include a unique occurrence/generation, canonical data root, source identities, archive instance/generation, schema versions, and the accepted fingerprints. Evidence from a prior operation cannot combine with a new command. The witness cannot retain a capability or mutation callback.

## 18. Source-absent retained material

Current Messages and Contacts are not guaranteed to contain every historical fact already present in MessageLens. Messages may have been deleted from the live source; attachments may no longer exist at their source paths; historical donor imports may have contributed data outside the live source.

Therefore:

- absence from the current source is not authorization to delete a retained row;
- the archive is preservation data, not an alternate source database for message reconstruction;
- a retained row may be reconstructed only from a still-authoritative source/donor whose identity and transformation are proven;
- if no authoritative donor remains, populated destructive reconstruction must refuse;
- a future product decision to discard such data would be a separate destructive policy, not equivalence.

## 19. Protected-reference preservation audit

The overlay schema stores independent user intent whose referents depend on graph/import identity:

- participant overrides and favourite contacts reference graph participant/contact IDs;
- chat overrides reference graph chat IDs;
- message annotations reference graph message IDs;
- message flags and tags use message GUIDs;
- conversation tag assignments use conversation IDs;
- handle-to-participant overrides and handle visibility use canonical-handle/participant identities;
- dismissed handles use normalized handle strings;
- archived-attachment records bind message GUID, import attachment identity, relative archive path, hash, generation, and provenance.

Preserving the overlay file byte-for-byte is insufficient if reconstruction assigns an existing integer or GUID a different meaning or omits a referenced entity. The witness must validate every protected reference domain, classify allowed unresolved historical references explicitly, and refuse on ambiguity.

The presence database contains independent scheduling/trip/step/test-execution state and is outside derived reconstruction. No message/graph foreign-key use was identified in this audit, but it must remain untouched and its independence must remain covered by tests.

## 20. Currently irreducible blockers

The following facts cannot yet be derived safely by a read-only witness using one shared authority:

- populated import rows whose source facts are no longer present and have no admitted donor;
- canonical handle/contact meanings while writer-only grouping, scoring, and linkage rules remain embedded in repositories;
- rich-text output without pinning the exact decoder contract/version and failure semantics;
- populated graph message classifications and association resolution without extracted canonical functions;
- FTS semantics under unsupported SQLite/FTS configuration drift;
- operational batch/provenance values until their nondependency is proven;
- any unclassified protected reference or temporal attachment-source condition.

These are proof blockers, not a request to weaken admission or to grandfather existing data.

## 21. Formal tri-state reconstruction predicate

Define three independent tri-state witnesses:

`reconstructionInputsAvailable`

- TRUE only when every required source/donor identity, schema, cursor, mapping configuration, decoder contract, and read authorization is available in a coherent sample.
- FALSE when a required input is conclusively absent or incompatible.
- UNKNOWN when it is unreadable, unstable, unsupported, or unclassified.

`materialReconstructionEquivalent`

- TRUE only when every consequential import, graph, edge, classification, attachment, and logical FTS domain matches the output of the shared canonical transformations.
- FALSE on any material mismatch.
- UNKNOWN when any domain cannot be evaluated completely.

`independentPreservationEquivalent`

- TRUE only when protected stores and archive data are unchanged, every retained protected reference keeps the same meaning, and archive identity/generation/configuration remain coherent.
- FALSE on mutation, dangling/rebound identity, or archive mismatch.
- UNKNOWN on unreadable, unstable, or unclassified evidence.

The future destructive eligibility predicate is:

```text
inputs == TRUE
AND material equivalence == TRUE
AND independent preservation == TRUE
AND fresh pre-Ball fence == TRUE
```

FALSE or UNKNOWN in any conjunct refuses Start Fresh. No score, majority, fallback, or stale evidence can authorize it.

## 22. Performance, privacy, and boundedness

The witness design must remain usable with the observed data scale and must not expose message content:

- keyset pagination, not offset scans;
- bounded page sizes consistent with current importers (approximately 200–500 rows);
- bounded attributed-body bytes and decoder work;
- streaming keyed hashes/counts plus the first small set of mismatch identities, not full in-memory copies;
- cancellation and cooperative yielding between pages;
- explicit time/row/byte budgets, with exhaustion reported as UNKNOWN;
- no message text, contact value, blob, source path, or attachment payload in ordinary logs;
- diagnostic output limited to schemas, counts, stable opaque IDs, digest summaries, and classified mismatch reason;
- no network activity.

Digest equality is an optimization, not the authority. Digests must be domain-separated, ordered by stable keys, include schema/transformation-version identity, and be backed by focused mismatch reads when unequal.

## 23. Relationship to Local Data Repair

`sqlite_app_czar_local_data_repair_safety_reader.dart` already provides a strong bounded proof for a deliberately narrow situation. It uses separate read-only connections, exact data-root binding, schema/integrity checks, retired-artifact absence, live-only import provenance checks, source comparisons, Contacts evidence when required, and stable fingerprints. It fails closed.

That proof correctly requires the graph to be absent/empty. It must not be generalized by deleting the empty-graph condition or treating its live-only safety result as proof for populated graph/FTS reconstruction.

Reusable lower-level techniques include read-only connection discipline, schema/integrity probes, keyset paging, fingerprinting, and two-sample stability. Its final predicate and jurisdiction remain Local Data Repair-specific.

## 24. Required extraction milestones

The bounded sequence and likely source/test boundaries are:

| Milestone | Likely files | Observable acceptance and stop gate |
|---|---|---|
| 1. Contacts source projection | `contact_source_projection.dart`, `contact_importer.dart`, new `contact_source_projection_test.dart`, existing `contact_importer_test.dart` | Identical contact/channel rows and omissions; stop on ordering, progress, AddressBook compatibility, or schema change |
| 2. Message source projection | new sibling typed transformation file, `message_importer.dart`, message importer tests | Identical IDs, dates, nullable fields, flags, anomaly results, and every input row retained; stop on SQL/page/decoder behavior change |
| 3. Handle/chat/attachment/join source projection | respective importer files plus narrow sibling transformation files and existing family tests | Identical rows, packed IDs, endpoint omissions, and reconciliation; stop on state/order or cursor change |
| 4. Versioned rich-text contract | `message_rich_text_enricher.dart`, a narrow decoder-contract adapter/model, Rust/Dart boundary tests | Same candidate selection, byte limits, decoded text, and failure semantics; stop if decoder cannot be pinned without behavior change |
| 5. Basic graph projection | message/attachment and three edge projection repositories plus pure sibling transformations and projector tests | Identical graph rows/edges/classifications; stop on query/order/schema differences |
| 6. Identity/contact/chat graph projection | handle, contact, and chat projection repositories plus pure sibling transformations and tests | Identical canonical IDs, aliases, contact edges, display choices, and group flags; stop on any protected-reference identity drift |
| 7. Logical FTS evidence | `conversation_graph_database.dart`, a read-only FTS evidence reader, FTS runtime/architecture tests | Same declared FTS contract and indexed keyed text/query probes; stop on unsupported SQLite/tokenizer drift |
| 8. Complete witness | new bounded AppCzar evidence reader/models/providers under the existing Operating command boundary; architecture and protected-reference tests | All three item-21 propositions computed without a writer or writable DB; stop on unclassified domain, write capability, or stale binding |
| 9. End-to-end qualification | disposable fixture builders/tests and later human prompt/response only | Known fixtures yield exact TRUE/FALSE/UNKNOWN outcomes and zero protected mutation; stop before any real data |
| 10. Stage 2C reconsideration | a later separately approved prompt; existing reset service/Operating command boundary only | Fresh proof plus pre-Ball fence can bind one command; stop if proof or preservation is not entirely TRUE |

Each milestone must be behavior-preserving, independently reviewable, and covered by focused parity tests before the next one begins.

Each milestone should end in its own recovery checkpoint only after focused tests, architecture enforcement, full analysis, and the project-conformance audit pass. A failed parity check restores the pre-extraction checkpoint; it does not get normalized into a new expected result. No milestone may opportunistically continue into the next family.

## 25. First narrow shared-transformation extraction

The recommended first slice is Contacts source projection only.

Production scope:

- extend `lib/essentials/source_scoped_import/application/contacts/contact_source_projection.dart` with typed immutable canonical contact and channel projection results, including explicit omission reasons;
- change `contact_importer.dart` to consume those results without changing SQL, ordering, progress, batching, database schema, visible behavior, or error policy.

Test scope:

- add `test/essentials/source_scoped_import/application/contacts/contact_source_projection_test.dart`;
- update `contact_importer_test.dart` to prove the writer consumes the shared seam;
- cover null/whitespace names, middle-name composition, organization fallback, unknown/empty values, email case/trim, phone normalization/fallback, labels, invalid owner/primary keys, and Apple timestamps.

Acceptance criterion: representative pre-extraction and post-extraction ledger row maps and omission decisions are identical, and the production importer has exactly one route to those decisions.

Stop if the extraction changes source ordering, anomaly/progress behavior, AddressBook compatibility, schema, provider authority, or requires a migration. This slice does not authorize a witness or Start Fresh.

## 26. Why a large refactor is rejected

Extracting every importer, projector, FTS rule, and protected-reference check in one change would make behavioral parity difficult to review and could combine identity changes with destructive authority work. It would also produce a large generated-code and test surface before any single seam was proven.

The correct strategy is a series of small pure-function extractions from existing writers, with the writer kept as the only mutation boundary. No new orchestration framework, general execution enum, alternate database layer, or parallel policy authority is justified.

## 27. Honest unavailable alternative

If a milestone encounters behavior that cannot be made deterministic from admitted evidence—especially source-absent rows, unsupported schemas, ambiguous protected references, or decoder drift—the correct result is to leave populated Start Fresh unavailable.

There is no requirement that every existing installation become resettable. Diagnostic Review is the safe jurisdiction for evidence that cannot select normal use or an automatic repair. A future explicit export/recovery/destructive-discard product decision would require separate architecture and human authorization.

## 28. Future automated end-to-end qualification

After the shared transformations and witness exist, disposable tests must cover at least:

- empty and populated live-only datasets;
- every nullable/anomalous message form, including attachment-only and reaction/system records;
- rich-text success, empty extraction, bounded failure, and decoder-version mismatch;
- handle aliases, normalization collisions, service preference, and stable tie-breaks;
- contact name/channel edge cases and canonical linkage;
- chat group-state and all join omission cases;
- attachment metadata/edge coverage with source-present and source-absent payloads;
- protected overlay references before and after a disposable rebuild;
- retired artifacts and unsupported schema versions;
- source/donor disappearance and mid-scan mutation;
- FTS inserts, updates, deletes, prefixes, diacritics, null text, and integrity;
- restart/stale-generation rejection and pre-Ball drift;
- failure injection between deletion, reconstruction, projection, and verification, with recoverable fail-closed behavior.

The end-to-end candidate may use disposable copies only. It must never point destructive code at either real archive or real MessageLens data.

## 29. Future bounded human qualification

A later human qualification must use a purpose-built disposable development fixture with a known manifest. It must record:

- exact build identity, executable hash, bundle ID, PID, branch/commit, and canonical fixture root;
- source/donor schemas and stable fingerprints;
- before/after inventories and hashes for every derived and protected family;
- the witness generation and exact Ball binding;
- visible confirmation text naming the precise deletion/reconstruction scope;
- reconstruction progress, interruption behavior, restart behavior, and terminal disposition;
- protected overlay semantics and archive payload hashes after reconstruction;
- logical FTS probes and browsing parity;
- explicit classification of ordinary bootstrap files such as locks/logs.

The fixture must be independently destroyed after qualification. If a required UNKNOWN/unstable case cannot be constructed without touching real data, the qualification stops rather than manufacturing an outcome.

## 30. Project-conformance review

This design was reviewed against:

- the global agent guardrails;
- the project README and its database/provider rules;
- `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`;
- the database access and overlay-independence rules;
- the record-level fidelity rule;
- the Apple timestamp conversion authority;
- the attachment-preservation invariant;
- AppCzar exclusive-authority/Ball-tenure architecture already established by Feature 34/35;
- the production activation seam and Stage 2A/2B/2C records.

Conformance result for this audit/design scope: PASS.

Conceptual BLOCKER findings in the proposed design: none. Conceptual SHOULD FIX findings in the proposed design: none. The design deliberately reports the following implementation blockers instead of disguising them as conformance success: canonical transformation extraction is incomplete; the read-only witness does not exist; several protected-reference domains remain unproven; and no populated end-to-end qualification exists.

There is one conceptual transformation authority in the proposed design, because writers and witness share pure typed functions. Database mutation remains in existing centralized providers/repositories. Protected intent is not projected into derived stores. Every source record remains visible/imported; anomalies are not suppressed. `DateConverter` remains the sole Apple timestamp authority. The archive is never deleted or treated as cache. Privacy, boundedness, cancellation, generation binding, and fail-closed UNKNOWN behavior are explicit.

The unresolved items are implementation prerequisites, not unreported design defects: the shared transformations and witness do not yet exist, so destructive Stage 2C cannot resume.

## 31. Actions deliberately not performed

This prompt made no production, generated-code, test, schema, migration, documentation-index, version, changelog, release-metadata, or Xcode-project change. It ran no test, analyzer, formatter, generator, build, fixture, database, or application. It did not access or modify either real archive, any real database, archive configuration, bookmarks, external drives, or abandoned relocation artifacts.

No Stage 2C Start Fresh implementation was restored. No Stage 2D work, production-identity rehearsal, or production AppCzar cutover was started.

## 32. Final Git and worktree state

At response preparation:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `0da40b75d4f6aca972d7ac745a41079c4bc6d479`
- upstream: `origin/fix/onboarding-import-stuck-state`
- divergence: `0 0`
- tracked worktree: clean
- index: clean
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- Feature 34 worktrees: exactly one, the primary worktree
- other registered worktrees: the separate Feature 35 worktree, `main` worktree, and an unrelated Gradle worktree
- untracked files: the pre-existing known unrelated set plus Prompt 92 and this Response 92; none staged

## 33. Readiness for the first extraction

READY FOR FIRST NARROW SHARED-TRANSFORMATION EXTRACTION: YES.

The Contacts source-projection slice in item 25 is bounded, behavior-preserving, independently testable, and does not require destructive authority. It should be proposed and reviewed in a new prompt before implementation.

This readiness is not permission to extract other domains opportunistically, add the witness, restore Start Fresh, or change production activation.

## 34. Readiness to resume Stage 2C

READY TO RESUME STAGE 2C DESTRUCTIVE START FRESH IMPLEMENTATION: NO.

The current writers do not yet provide one reusable transformation authority; populated import/graph/FTS equivalence is unproven; protected-reference equivalence is unproven; and source-absent/decoder/provenance facts remain irreducible. The exact stop established by Prompt 91 therefore remains in force.

## 35. Stage 2D, rehearsal, and cutover readiness

Stage 2D, any staged production-identity rehearsal, and production AppCzar cutover remain blocked. A development-only composition seam does not authorize production. The prerequisites are the complete extraction sequence, bounded witness implementation, automated qualification, human disposable-fixture qualification, a fresh whole-repository production-cutover audit, and separate explicit authorization.

STAGE 2C UNSAFE IMPLEMENTATION STOP CHECKPOINTED: YES

FULL POPULATED DATASET RECONSTRUCTION EQUIVALENCE CURRENTLY PROVEN: NO

CURRENT WRITERS HAVE ONE SOURCE-GROUNDED REUSABLE TRANSFORMATION AUTHORITY: NO

ALL CONSEQUENTIAL IMPORT AND GRAPH/FTS DOMAINS INVENTORIED: YES

UNIQUE PROTECTED OR TEMPORAL FACTS ARE NOT SILENTLY CLASSIFIED DISPOSABLE: YES

A BOUNDED READ-ONLY WITNESS DESIGN IS SOURCE-GROUNDED: YES

OPERATING START FRESH IMPLEMENTED BY THIS PROMPT: NO

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)

READY FOR FIRST NARROW SHARED-TRANSFORMATION EXTRACTION: YES

READY TO RESUME STAGE 2C DESTRUCTIVE START FRESH IMPLEMENTATION: NO

READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO

PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO

STOP.
