# MessageLens — Feature 34
## Response 111 — Protected-Reference Checkpoint and Read-Only FTS Equivalence Audit

Date: 2026-10-15
Mode: source/Git/documentation audit only; no database execution

## 1. Recovered execution checkpoint

The recoverable completed portion of Prompt 111 is its prerequisite Prompt
110 documentation checkpoint. The FTS audit had no existing Response 111 to
resume. No implementation is required or authorized by this prompt.

| Baseline item | Verified evidence |
| --- | --- |
| Repository | `/Users/rob/Development/FlutterProjects/remember_every_text` |
| Branch | `fix/onboarding-import-stuck-state` |
| HEAD | `5897918692f6f2614dc9189328d1309c31019e4c` |
| Upstream | `origin/fix/onboarding-import-stuck-state`, `0/0` |
| Remote branch | Read-only `git ls-remote` returned the same full HEAD |
| Tracked worktree / index | Both clean |
| Shared instructions | Clean at `95326f515ef4719f155ce6e223990398daad6311` |
| Worktrees | Four registered; exactly one on the Feature 34 branch |
| Pre-existing untracked files | 49 actual files, inventoried individually, including Prompt 111 |
| Response 111 before this audit | Absent |

The other registered worktrees are `remember_every_text-feature-35`,
`remember_every_text-main`, and
`remember_every_text.worktrees/gradle-fix-flutter-projects`. None was used.
The exact untracked path/hash inventory is preserved outside the repository:
`/private/tmp/messagelens-prompt111-recovered-untracked.json`.

`git show` establishes that HEAD contains exactly Prompt 110 and Response 110,
with subject `docs(feature34): record protected reference qualification`.
The latest Prompt 110 handoff in the previous chat, “Continue archive
relocation,” reports the same implementation/documentation hashes. These
claims were independently checked against Git and the remote tip. Its later
Prompt 111 turn failed during compaction and has no recorded deliverable.
Absence of a file cannot prove that no earlier informal reading occurred;
such reading supplies no reusable verified audit result.

Verified implementation ancestors:

| Evidence component | Commit |
| --- | --- |
| Production graph replay | `d364df01374abad9e1f8832fa04d70ed237715ff` |
| Graph material comparison | `1c1f8f62b1af73991b2317aac869dbc411557594` |
| Ledger material comparison | `f477f6858a62ab8849c9e0f254c9312cebea391a` |
| Bounded observation envelope | `281d7e01161ac779f281c397bac5c626a9eb320b` |
| Protected-reference comparison | `89aa7317b52f704689cdcecc36f81f0f31e46554` |

No documentation commit, staging, or push was repeated. The first remote
query failed because sandbox DNS could not resolve GitHub; the same read-only
query with network access succeeded. That failure was not treated as evidence
of remote divergence. No material baseline contradiction was found.

## 2. Architecture, scope, and assumptions

The source-scoped import ledger owns imported occurrences and enriched text.
Production graph repositories project that material into the Conversation
Graph; graph-owned triggers maintain the external-content text index. Search
reads graph text/topology and independently merges overlay tags/saved intent.
The evidence spine consumes canonical message IDs. Overlay intent, Presence,
historical provenance, and preserved attachment payloads are independent
obligations, not consequences of equal text-search results.

Assumptions are deliberately limited: current checked-in source defines the
writer/query contract; committed tests describe their assertions but were not
rerun; a dependency version does not establish the SQLite binary actually
loaded in an app process. No claim about any real populated installation is
made. Upstream SQLite source is comparative evidence, not the identified
MessageLens runtime.

The minimal plan was to recover Git provenance, trace production and existing
test seams, classify evidence and safety limits, then create only this
untracked response. Risks were false completion claims, overstated runtime
identity, and confusing content/finite-query equality with index equivalence.
Those are addressed by explicit provenance and separate UNKNOWN dimensions.

Hard invariants: no live/real data access; no source/test/generated/config/
schema/dependency/release edits; no tests, analyzer, build or app launch; no
observed-index repair; no overlay or payload mutation; no new jurisdiction,
mutation Ball, activation, reset authority, or Prompt 112 implementation.
The specific Prompt 111 response-writing authorization governs this single
documentation addition; no broader implementation approval is inferred.

## 3. Response 110 evidence boundaries

The two committed files under
`test/essentials/app_czar/application/reconstruction/` are
`protected_reference_equivalence.dart` and
`protected_reference_equivalence_test.dart`. Source inspection confirms
separate dimensions for overlay intent material, target identity,
compatibility resolution, source-occurrence provenance, and attachment
payload coverage. Exact schema gates are overlay 8, graph 3, and ledger 10.
The reader limits are 128 rows/table, 256 KiB canonical overlay material, and
32 diagnostic examples. It uses caller-supplied disposable handles.

Multiple GUID matches and competing normalized-handle representatives remain
UNKNOWN; a stable missing/rebound target can be FALSE. Archive compatibility
uses the live-source occurrence, not any matching historical raw ROWID.
Globally unavailable observations are not compared as empty worlds.
`attachmentPayloadCoverage` is explicitly unassessed UNKNOWN. Equal references
do not prove payload bytes or FTS correctness.

Response 110 records 12 focused, 244 regression, and 394 architecture passes
and clean analysis. These are historical recorded results, not fresh results
from this audit. The source and implementation checkpoint exist; the combined
populated reconstruction witness does not. Responses 102–110 are successive
evidence milestones, not interchangeable authorization. In particular,
Response 110's ambiguity classification supersedes the broader wording about
fallback ambiguity in the earlier Response 108 design.

## 4. Production FTS schema and writer census

Paths below are repository-relative source references at the verified HEAD.

| File / method | Actual behavior and limit |
| --- | --- |
| `lib/essentials/db/app_database_schema_versions.dart` | Graph version 3; ledger 10; overlay 8; Presence 9. Version equality alone does not verify existing object SQL. |
| `lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart`, `_createSchema`, `_createMessageTextSearchSchema` | Owns `messages` and FTS DDL below. `IF NOT EXISTS` does not replace a stale existing definition. |
| Same file, migration `onCreate` / `onUpgrade` | Create schema on creation; upgrades call schema creation and, when `from < 3 && to >= 3`, `_rebuildMessageTextSearchIndex`. |
| Same file, `_rebuildMessageTextSearchIndex` | Executes `INSERT INTO message_text_fts(message_text_fts) VALUES ('rebuild')`; mutating, not an observer API. |
| Same file, `clearProjectionRows` | Deletes graph material in one transaction, including messages, invoking delete triggers. Later reprojection is separate work. |
| `lib/essentials/conversation_graph/infrastructure/repositories/message_projection_repository.dart`, `SqliteMessageProjectionRepository` | Full or source/cursor-bounded ledger query, ordered by `ss_id`; transaction performs INSERT OR IGNORE then UPDATE when no insert occurred. `text = ?` is included even on repeated replay. No null-text exclusion. |
| Same repository, association/canonical-sender resolution | Uses same-source association GUID and current handle aliases; copies ledger `text` unchanged while deriving other message semantics. |
| `lib/essentials/conversation_graph/infrastructure/repositories/handle_projection_repository.dart` | Rewrites canonical sender references, not message text; affects handle search scope. |
| `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart`, `runOnce` | Imports and enriches before graph projection; handles → contacts → chat-handle → chats → messages → attachments → chat-message → message-attachment. Each stage has its own transaction boundary. |
| `lib/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart`, `enrichMissingText` | Bounded blob/decoder work, then `projectMessageRichTextSemantics`; conditionally persists normalized text only where `ss_id = ? AND text IS NULL`. |
| Sibling `message_rich_text_semantic_projection.dart` | Trims supplied decoded text; returns persist/empty/typed failure. Does not invoke decoder, read source, or own transaction. |
| `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_harness.dart`, `replayFull`, `replayIncrementalLive`, `removeHistoricalSource` | Injects production repositories into isolated production-schema stores; local-account facts are synthetic. Historical removal uses the existing removal service, which clears/reprojects graph material. |

Authoritative DDL, omitting only `IF NOT EXISTS` for compact presentation:

```sql
CREATE VIRTUAL TABLE message_text_fts USING fts5(
  text,
  content='messages',
  content_rowid='ss_id',
  tokenize='unicode61 remove_diacritics 2',
  prefix='2 3 4'
);
```

`messages.ss_id` is INTEGER PRIMARY KEY; `messages.text` is nullable TEXT.
No explicit `detail`, `columnsize`, rank, custom tokenizer, or locale option
is configured in this DDL. Runtime defaults must be recorded rather than
inferred from a different SQLite release.

The three exact trigger contracts are:

```sql
CREATE TRIGGER message_text_fts_after_insert AFTER INSERT ON messages
BEGIN
  INSERT INTO message_text_fts(rowid, text) VALUES (new.ss_id, new.text);
END;
CREATE TRIGGER message_text_fts_after_delete AFTER DELETE ON messages
BEGIN
  INSERT INTO message_text_fts(message_text_fts, rowid, text)
    VALUES ('delete', old.ss_id, old.text);
END;
CREATE TRIGGER message_text_fts_after_text_update AFTER UPDATE OF text ON messages
BEGIN
  INSERT INTO message_text_fts(message_text_fts, rowid, text)
    VALUES ('delete', old.ss_id, old.text);
  INSERT INTO message_text_fts(rowid, text) VALUES (new.ss_id, new.text);
END;
```

The update trigger is column-specific, not conditioned on unequal values.
Production message updates retain `ss_id`. An arbitrary identity-only UPDATE
would not trigger this maintenance contract; it is not a supported replay
operation. There is no ordinary application FTS optimize path in the searched
`lib/` source. Creating triggers over populated content does not itself prove
past indexing; only the explicit migration path rebuilds.

The rich-text chain is importer → ledger blob/nullable text → enricher →
extractor port/Flutter Rust Bridge decoder → canonical semantic projection →
conditional ledger update → message projector → graph text triggers. Decoder
availability, source bytes, and implementation identity remain separate from
an FTS scan. A successful token query cannot prove rich-text source fidelity.

## 5. Runtime census and the unmeasured boundary

`lib/essentials/db/feature_level_providers/persistent_database_providers.dart`
constructs the graph through `NativeDatabase.createInBackground(File(dbPath))`
after admission, then enables foreign keys and registers lifecycle ownership.
Search obtains this through `driftConversationGraphDatabaseProvider` and the
separate `overlayDatabaseProvider`. Neither provider is a safe read-only audit
opener: ordinary Drift construction permits writes and migrations.

`pubspec.lock` and `.dart_tool/package_config.json` resolve Drift 2.28.1 and
sqlite3 2.9.0. Local package source was inspected at:

- `/Users/rob/.pub-cache/hosted/pub.dev/drift-2.28.1/lib/native.dart`
- `/Users/rob/.pub-cache/hosted/pub.dev/sqlite3-2.9.0/lib/src/ffi/load_library.dart`

Drift NativeDatabase uses sqlite3 FFI. On macOS this sqlite3 loader tries
process symbols, then `/usr/lib/libsqlite3.dylib` if `sqlite3_version` is
unavailable. No application loader override or sqlite3_flutter_libs dependency
was found in the inspected app/lockfile paths. The sqflite Darwin dependency
does not establish the identity of the graph's FFI engine. Tests use
NativeDatabase memory/file constructors; the test process may resolve a
different library from the shipped process.

Actual loaded library version, `sqlite_source_id()`, compile options,
extension/tokenizer implementation, and loaded-image identity are **UNKNOWN**
in this audit. No SQL was executed to obtain them. A future disposable
qualification must capture `sqlite_version()`, `sqlite_source_id()`, sorted
`PRAGMA compile_options`, provider/package/platform identity, and successful
FTS behavior on the same connection. Merely finding an ENABLE_FTS5 option is
not a complete runtime identity proof. Source identity and empirical behavior
must be bound together; no system sqlite CLI result may substitute for Drift.

`message_text_fts_runtime_test.dart` already asserts representative case,
diacritic, punctuation, whitespace, Cyrillic, and prefix behavior on its
runtime. It uses a separate ordinary FTS table, not an adversarial populated
external-content table. Its assertions are not a census of today's loaded
app binary, Unicode normalization, or every grammar production.

## 6. Complete production search contract

The call chain is:

```text
features/messages/application/message_evidence/message_evidence_spine_provider.dart
  -> searchServiceProvider
  -> SearchService.searchGraphMessageIdsForIntent
  -> graphSearchRepositoryProvider
  -> SqliteGraphSearchRepository.searchMessageIds
```

Definitions live in `lib/essentials/search/application/`:
`search_service_provider.dart`, `search_service.dart`,
`graph_search_repository_provider.dart`, `graph_message_search.dart`, and
`message_text_search_query.dart`. The sole production MATCH site is
`lib/essentials/search/infrastructure/repositories/graph_search_repository.dart`.

The parser splits raw input with `\S+`, lowercases each token, recognizes
`is:saved`, makes a whitespace-completed token exact, and makes the unfinished
last token a prefix only when it has at least two runes. A single unfinished
rune produces no text token. Raw input remains separately retained; stable
execution identity distinguishes exact from prefix. Whitespace-separated input
is not an FTS phrase parser.

`_messageTextFtsClause` doubles embedded quotes, surrounds each application
token with double quotes, and appends `*` outside the quotes for prefix tokens.
SQL binds that expression; it does not interpolate user input. Thus raw FTS
operators are not the application's user-query language.

The complete MATCH statement is:

```sql
SELECT DISTINCT m.ss_id AS message_id
FROM message_text_fts
JOIN messages m ON m.ss_id = message_text_fts.rowid
/* scope joins below */
WHERE message_text_fts MATCH ?
  AND /* scope predicate below */
```

| Scope | Joins and predicate |
| --- | --- |
| Global | No extra join; `1 = 1` |
| Conversation | `JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id`; `ctm.chat_ss_id = ?` |
| Handle | Left join `handle_aliases scope_sender_alias` on raw sender; `COALESCE(m.sender_canonical_handle_ss_id, scope_sender_alias.canonical_handle_ss_id, m.sender_handle_ss_id) = ?` |
| Contact | Join chat-message and chat-handle by chat, left join handle aliases; `COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id) IN (...)` for supplied canonical handles |

Contact scope includes messages in conversations containing those handles,
not only messages sent by the contact. The evidence-spine caller obtains
those handles through `handlesForContactProvider` unless an explicit handle
was supplied. Missing scope IDs/empty contact handles produce an empty scope.
There is no relevance ordering, SQL LIMIT, date filter, spam predicate, or
NULL-text filter in the MATCH statement itself.

For every text token the repository unions text hits with tag hits. Native
tags come from all `message_intent_tags` rows. Compatibility tags come from
`getAllMessageUserTags`; GUID inputs are trimmed/deduplicated and resolved by
`GROUP BY guid HAVING COUNT(*) = 1`. Ambiguous GUIDs do not produce tag hits.
Tag matching uses the existing message-tag normalizer, exact tag/word matches,
and optional word prefixes; this is distinct from FTS tokenization. IDs are
filtered back to graph scope. Across tokens, all-terms intersects sets and
any-term unions sets. Matching the same message by tag and text is deduplicated.

Saved filtering reads `message_intent_overlays WHERE is_saved = 1`, merges
unique GUID-backed saved flags, applies scope, and intersects after term
combination. Saved-only queries start with the saved ID set. No text and no
saved filter returns empty. This code unions compatibility/native saved facts;
it does not implement a negative-native override subtraction here. That
literal behavior must be characterized, not replaced by a generalized overlay
precedence assumption.

`_sortAndLimitMessageIds` fetches dates in chunks of 400 IDs, compares date
strings descending (NULL becomes empty string), breaks ties by descending
`ss_id`, then takes the requested limit, default 500. Nonpositive limits return
empty. The limit bounds returned results, not candidate reads or memory.
No BM25/rank/snippet output is part of this repository contract.

Consequences: an orphan posting can be hidden by the messages join; a missing
text hit can be masked by a tag; a scope edge or saved flag can change results
without changing the index; the cap can hide older differences. Compare both
named raw MATCH row IDs and complete production requests, with separate
attribution. Never promote either finite corpus to exhaustive equivalence.

## 7. Diagnostics: read-only safety and evidence limits

The SQLite documentation distinguishes external-content reads from posting
reads, requires rank 1 for the special integrity command to compare external
content, and exposes `fts5vocab` instance tuples. Vocabulary construction uses
CREATE VIRTUAL TABLE, optionally in temp. Rebuild and optimize are modifying
commands. These contracts do not identify MessageLens's loaded runtime.
[SQLite FTS5 documentation](https://www.sqlite.org/fts5.html).

| Candidate | Safety / proof assessment |
| --- | --- |
| `SELECT ss_id, text FROM messages ORDER BY ss_id` plus schema SQL | Content evidence only, preserving NULL/empty/whitespace distinctions. No posting evidence. |
| `SELECT rowid, text FROM message_text_fts` | May expose external content; current harness `messageTextIndexRows` cannot certify internal tokens. |
| Named SELECT/MATCH through existing query semantics | Suitable bounded behavioral evidence on an independently read-only, stable connection; source/runtime qualification still required. |
| `INSERT INTO message_text_fts(message_text_fts) VALUES ('integrity-check')` | Enters virtual-table update machinery. Not admitted by a strict read-only observer even if a particular execution leaves no changed file pages. |
| Same INSERT with `rank = 1` | Adds external-content comparison; still a write-command interface, disposable controls only. No rollback-based safety exemption. |
| `PRAGMA integrity_check` / `quick_check` | Do not assume either exhaustive equivalence or absence of FTS participation. Coverage is runtime-dependent; must independently characterize precise implementation and read effects. |
| `fts5vocab` | Potential supported internal tuple evidence. No existing app reader/table. Temp DDL is still connection/schema mutation, not a SELECT-only observer. No observed setup is authorized here. |
| Direct shadow-table SELECTs | Raw storage may be readable, but bytes/segment organization are not a qualified semantic comparator. No private varint/posting decoder is authorized. |
| Rebuild, optimize, merge, repair | Writes; expected disposable graph/control fixtures only, never the observed real graph. |

An important correction to overly broad historical wording: current upstream
`fts5_main.c` registers `fts5IntegrityMethod` as `xIntegrity`. That method calls
`sqlite3Fts5StorageIntegrity(..., 0)`. Therefore an engine with this hook can
check internal FTS structures through the generic integrity machinery. It
does **not** request external-content agreement. Earlier wording that generic
integrity checks only cover ordinary b-trees must not be treated as universal.
This is upstream source evidence, not proof that this exact implementation is
loaded by MessageLens.
[SQLite FTS5 main source](https://raw.githubusercontent.com/sqlite/sqlite/master/ext/fts5/fts5_main.c).

The inspected storage implementation enables content checksums for external
content only when its argument is nonzero. That branch tokenizes content,
checks document sizes/totals, and passes a checksum to index integrity checking.
A successful checksum diagnostic is not a collision-free pairwise proof of
two arbitrary indices. Exact engine behavior and coverage remain unqualified.
[SQLite FTS5 storage source](https://raw.githubusercontent.com/sqlite/sqlite/master/ext/fts5/fts5_storage.c).

`sqlite3_stmt_readonly` alone is not a safety proof: it describes direct writes
and explicitly permits indirect side effects through functions/virtual tables.
[SQLite statement-readonly contract](https://www.sqlite.org/c3ref/stmt_readonly.html).
The application's `assertReadOnlySql` in
`lib/essentials/db/application/read_only_sql_guard.dart` is only a leading-word
allowlist accepting SELECT/PRAGMA/WITH. It is not an SQLite authorizer and does
not distinguish read and write PRAGMAs. Do not use it to qualify arbitrary SQL.

Existing probes are weaker still:

- `sqlite_message_lens_installation_evidence_reader.dart` under onboarding
  infrastructure opens read-only/query-only, checks required object names and
  targeted readability, and uses `SELECT rowid FROM message_text_fts LIMIT 1`.
  It does not compare trigger SQL or postings.
- `lib/features/environment_summary/infrastructure/repositories/sqlite_environment_evidence_repository.dart`
  checks existence/count. This cannot establish internal index completeness.
- `lib/essentials/db/infrastructure/repositories/database_health_audit_queries.dart`
  provides health query layers; graph health routes through the existing graph
  handle. This is not a specialized exhaustive FTS witness.

A potential future temp-vocabulary experiment must distinguish “observed main
file unchanged” from “no writes anywhere.” Even a supported complete instance
scan does not by itself independently validate prefix accelerators, storage
integrity, arbitrary query behavior, runtime identity, or resource completeness.
Its use on an observed installation needs separate design and runtime safety
qualification. No real databases may be ATTACHed to make comparison convenient.

## 8. Noninterchangeable evidence types

Recommended test-only result: a typed map of dimensions, each carrying its
own tri-state, assessed flag, reason, contract/corpus identity, and accepted
observation identity. Do not expose reset eligibility or a single ambiguous
`ftsEquivalent` boolean.

| Dimension | TRUE requires | FALSE requires | UNKNOWN includes |
| --- | --- | --- | --- |
| Schema/runtime compatible | Exact admitted schema/trigger/config and qualified engine identity | Stable known contract incompatibility | Unmeasured library/options, unsupported tokenizer, missing identity |
| Content equivalent | Complete bidirectional nullable `(ss_id,text)` equality under one binding | Stable missing/extra/changed pair | Incomplete scan, schema/read/budget failure |
| Bounded raw MATCH corpus equivalent | Every named expression and sorted row-ID result agrees | A reproducible named mismatch under qualified runtime/binding | Query failure, unsupported syntax, incomplete request execution |
| Bounded production-search corpus equivalent | Every named scope/token/mode/saved/limit request agrees in final order | Stable request result/order mismatch | Unknown overlay/scope binding or failed request |
| Qualified internal-index evidence | A separately validated supported inspection contract completes and agrees | A qualified inspection establishes a specific internal contradiction | Current default: unqualified/unavailable inspection |
| Exhaustive FTS semantic equivalence | A sound complete proof for the explicitly named query/index contract | A valid counterexample to that contract | All finite passes, missing internal/runtime coverage, incomplete proof |

Evidence is not a ladder where success automatically promotes to the next
row. A finite raw MATCH counterexample can refute universal query equivalence,
but a production mismatch caused only by saved state cannot refute index-only
equivalence. Content mismatch likewise need not imply different tokens.
Known contradictions remain visible beside unknown dimensions. Globally
unqualified observations must not generate invented missing-row FALSE values.
An unstable interval discards its contradictions as well as its successes.

No current evidence supports exhaustive TRUE. Actual populated results for
all dimensions remain unobserved. “UNKNOWN” is a proof limit, not a claim that
strict read-only exhaustive proof is impossible in principle.

## 9. Concrete disposable counterexamples and expected classifications

The following are proposed controls, not experiments run in Prompt 111.
Every setup mutation is confined to synthetic owned stores, followed by
closing writers and reopening observers read-only.

| Control | Coherent FALSE | What remains UNKNOWN / must not be inferred |
| --- | --- | --- |
| Remove update trigger, change content from `oldword` to `newword`, restore exact trigger DDL | Named old/new MATCH corpus differs from clean production replay | Content and final DDL may agree; internal proof unqualified |
| Remove an index entry with the documented special delete while retaining content | Missing named token hit | External-content SELECT may still agree |
| Add an index-only `ghostword` row absent from messages | Raw MATCH counterexample | Production join may hide it; production equality is only corpus equality |
| Delete content with delete trigger temporarily absent, then restore trigger | Raw stale posting can contradict expected raw corpus | Read/error behavior must be characterized; errors are not fabricated empty results |
| Repeated full replay, same-text update, text→NULL→empty→text, ordinary delete/reinsert | Any reproducible mismatch from clean expected writer behavior | Correct expected results are characterization prerequisites, not guesses |
| NULL, empty, whitespace, punctuation-only, rich-text success/empty/failure | Exact content distinction can be FALSE | Identical zero-token results do not erase material differences |
| `CAFÉ`, `cafe`, decomposed `cafe\u0301`, Greek/Cyrillic, emoji, `don't`, `co-op`, quotes | A named qualified case/prefix/phrase result differs | No universal Unicode normalization or tokenizer claim from these cases |
| Raw unquoted `co-op` / malformed quote syntax | Only a separately specified parser-behavior contract may report a contradiction | Search-equivalence result is UNKNOWN on query failure; production quoted token path is distinct |
| Missing chat edge, altered alias, saved flag, tag-only hit, equal dates, NULL date, low result cap | Named production request differs | Index equivalence cannot be blamed without raw evidence |
| Missing posting masked by an equal overlay tag | Raw corpus FALSE, possibly production corpus TRUE | Stable overlay/reference equality cannot upgrade raw or internal proof |
| Tokenizer/config/library/source-ID drift | Compatibility FALSE if exact known contract differs | Dependent semantics UNKNOWN until requalified; never compare unrelated snapshots as same source |
| Query error, corruption, FTS unavailable, timeout, cancelled scan | Qualified corruption check may separately refute integrity | Equivalence UNKNOWN; no exception-to-empty conversion |
| Matching start/end strings but unbound/replaced source or graph occurrence | Proven provenance mismatch FALSE in its own dimension | FTS reconstruction binding UNKNOWN; nominal fingerprint equality insufficient |
| First attempt changes during scan | No published FALSE from discarded evidence | Whole attempt UNKNOWN; Response 109 permits one fresh attempt only |

Protected intent must remain byte/material stable through these checks. No
overlay repair, reference rebinding, archive scan, historical donor deletion,
or payload operation is part of a text-index control.

## 10. Existing qualification inventory and boundedness

Inspected tests include:

- `test/essentials/conversation_graph/infrastructure/conversation_graph_database_test.dart`:
  DDL/triggers, insert/update/delete, NULL/empty behavior, schema-v2 backfill.
- `test/essentials/conversation_graph/infrastructure/message_text_fts_runtime_test.dart`:
  representative tokenizer behavior on NativeDatabase.
- `test/essentials/conversation_graph/application/messages/message_projector_test.dart`:
  actual writer IDs, repeat/update and FTS behavior, associations/classifications.
- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart`:
  actual replay, stale material, raw punctuation error, quoted phrase, 2/3/4
  prefix queries, Unicode, text replacement, NULL preservation.
- `test/essentials/search/infrastructure/repositories/graph_search_repository_test.dart`:
  exact/prefix, quoted syntax, metadata exclusion, four scopes, AND/OR,
  descending order, 500 cap, native/GUID saved and tags, cross-domain composition.
- `test/essentials/search/application/message_text_search_query_test.dart` and
  `search_service_test.dart`: parser/execution-intent and service contract.
- The Response 107 ledger comparator, Response 109 observation helper, and
  Response 110 protected-reference helper/tests remain independent evidence.

The graph harness `snapshot()` materializes all declared rows; its manifest
excludes FTS. `searchMessageIds` is raw MATCH with ascending rowid, not the
production search repository. The ledger comparator has a 10,000-row/table
guard but retains complete snapshots and indexes. Neither is production-scale.
The search repository also materializes all matches/tags before limiting.

A future populated verifier needs per-file stable read transactions, bounded
keyset pages and byte budgets, one attempt identity, independent expected
production-writer output, and streaming bidirectional comparison. No observed
index is built in place. Long readers can pin WAL and consume disk; SQL LIMIT
does not bound tokenizer/index work. Cancellation needs native interruption or
owned worker termination, not merely `Future.timeout` while work continues.
Do not close/delete resources underneath an active query.

One owner must close every statement/transaction/handle, then delete only its
unique disposable root, on success, failure, deadline, and cancellation.
Cleanup failure is explicit UNKNOWN. Diagnostics contain case/category tokens
and counts, never user text, token vocabularies, GUIDs, raw rows, or paths.
Expected stores can contain sensitive derived material in a future real-data
witness; disposable location, retention and cleanup therefore require their
own qualification. No such real-data work is authorized now.

The separate Response 109 envelope supplies at most two attempts and complete
discard on drift. This proposed FTS component owns one attempt, no retries.
Neither component establishes cross-file atomicity or an unobserved writer's
absence merely through equal start/end fingerprints.

## 11. Exactly one recommended Prompt 112 milestone

**Test-only FTS proof-level classification and adversarial disposable qualification.**

It is feasible through existing production schema/writer/search injection
seams. It should qualify content and named raw/production query contracts,
while keeping internal and exhaustive success explicitly UNKNOWN. It must
not implement a populated witness, live inspector, or reset policy.

### Exact allowed file list

Two new implementation/test files only:

1. `test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence.dart`
2. `test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence_test.dart`

Documentation records only, under the existing Feature 34 `01-ONBOARDING/`:

3. `prompts/111-CHECKPOINT-PROTECTED-REFERENCE-QUALIFICATION-AND-AUDIT-READ-ONLY-FTS-EQUIVALENCE.md`
4. `responses/111-CHECKPOINT-PROTECTED-REFERENCE-QUALIFICATION-AND-AUDIT-READ-ONLY-FTS-EQUIVALENCE.md`
5. `prompts/112-QUALIFY-TEST-ONLY-FTS-EVIDENCE-LEVELS-AND-ADVERSARIAL-DISPOSABLE-CONTROLS.md`
6. `responses/112-QUALIFY-TEST-ONLY-FTS-EVIDENCE-LEVELS-AND-ADVERSARIAL-DISPOSABLE-CONTROLS.md`

These are a proposed allowlist for the next prompt, not authority to create
Prompt 112 now. Existing replay/comparator/production files are reuse-only.

### Characterization before comparator implementation

First encode baseline characterization in the authorized new test file:

1. Record exact disposable Drift/SQLite identity and production DDL/triggers.
2. Reuse two independent production replay harness instances with identical
   fixed registry IDs; characterize repeat/update/delete and the existing raw
   query corpus before adding classification logic.
3. Demonstrate stale postings with equal content and restored equal trigger
   DDL, and a tag masking a missing text hit. Keep expected output built through
   actual writers; direct FTS edits are labeled adversarial controls only.
4. Close fixture writers before read observation. Characterize
   `sqlite3.open(..., mode: OpenMode.readOnly)` plus query-only and
   `NativeDatabase.opened(..., enableMigrations: false)` for graph/overlay
   wrappers supplied to the real search repository. The inspected Drift
   version exposes this seam. If it cannot preserve strict read-only behavior,
   stop; do not change production classes.
5. Establish that special integrity INSERT is rejected on the observed handle;
   inspect its result on a separate writable disposable control. Characterize
   generic PRAGMA integrity coverage, without assuming an xIntegrity hook.
   A zero-difference fixture hash alone is not proof that a command cannot write.

Only after these facts hold should the helper implement typed evidence.
The helper accepts bounded observations/read callbacks, not writer/provider
authority. The test owns fixture construction, close, fault injection, and
cleanup. Runtime-specific behavior must be recorded literally.

### Deterministic corpus

Retain the existing six-message canonical replay and its fixed source IDs.
Add at most 18 messages with deterministic packed source keys through the
existing disposable ledger and actual message projector. Exact proposed text
values: NULL, empty, space/tab/newline, `oldword`, `newword`, `ghostword`,
`CAFÉ`, `cafe\u0301`, `co-op`, `don't`, `post postmaster`, `under_score`,
`Привет мир`, `Καλημέρα`, `👩‍💻post`, `alpha beta alpha`, and embedded quotes.
Use fixed ISO UTC dates with an equal-date pair and one NULL date. Reuse
canonical chats/handles; introduce at most two fixed synthetic tags and two
saved flags plus a duplicate GUID control. No attachment bytes or native
decoder invocation; rich-text outcomes reuse the production semantic seam
with explicit synthetic decoder facts.

Named requests must include exact versus unfinished prefix and trailing
whitespace; prefixes 2/3/4; punctuation/quoted raw phrase; AND/OR; global,
conversation, canonical handle, contact; saved-only/saved-and-text; native and
unique/ambiguous GUID tags; tag-masked missing posting; date/ID ties and small
caps that hide older differences. Raw malformed expressions belong to a
separate failure control, not successful empty-search evidence.

Expected classifications: independent clean replays yield compatibility,
content and both bounded corpus dimensions TRUE; internal/exhaustive remain
UNKNOWN. Stable missing/extra postings produce named raw FALSE and refute
universal raw-query equality where qualified. Content-only, scope-only and
overlay-only changes report their own dimension. Unavailable runtime, schema,
query, cancellation, resource exhaustion, or binding drift yields affected
UNKNOWN. No unsupported method receives TRUE by default.

Optional diagnostic characterization within this same test file may compare
`fts5vocab` on separate writable disposable controls, with all setup explicit.
Do not add temp DDL to the observed reader or certify exhaustive evidence.
Do not decode or corrupt undocumented shadow bytes. A corruption/error result
may be injected at the read seam; label it simulated rather than physical
index-corruption qualification.

### Resource and cleanup assertions

Declare limits before work: 128 messages/world, 256 KiB total input text/world,
64 named requests, 128 IDs/request before any comparison truncation, 32
redacted diagnostic examples, six simultaneous database handles, and 32 MiB
total owned disposable disk. Fixture growth beyond a limit fails UNKNOWN;
it must never be silently truncated into equality. Read observers only after
closing setup writers. One-attempt monotonic deadline/cancellation hooks must
be deterministic in tests; no sleeps or automatic retries. Measure focused
elapsed time and RSS when attributable, without treating test-runner RSS as
incremental verifier memory or adding flaky timing assertions.

Inject failure/cancel before and after every read phase and during cleanup.
Assert every owned handle closes once, both world roots are removed only after
handles stop, original synthetic observed DB content/file hashes are unchanged,
no unexpected sidecar/temp path survives, and close/delete failure cannot
produce TRUE. Verify no source text appears in diagnostics. Native query
preemption and production-scale bounds remain later work if not demonstrable
through these bounded fixtures; do not overstate fake cancellation evidence.

### Validation, conformance, and stop gates

Run the new focused test, existing replay feasibility, graph schema/runtime,
message projector, search parser/service/repository, observation-envelope and
protected-reference tests. Run `test/architecture/forbidden_imports_test.dart`,
full `flutter analyze`, targeted formatting check, and Git whitespace checks.
No full-suite repetition unless required by a concrete failure or governing
instructions. No generator run is expected.

Place import/authority tripwires in the authorized test file: no production
consumer of the new helper; no AppCzar policy/coordinator, reset service,
archive capability, live path resolver, root lease, or provider composition;
no ATTACH, live repair, payload operation, or second tokenizer/query policy.
Exercise the production repository, not a copied implementation of it.

Stop if production changes, additional files, real data, dependency updates,
schema repair, guessed runtime equivalence, nondeterministic fixed fixtures,
unbounded retention, or unowned cleanup are necessary. If full production
search cannot run on a migration-disabled read-only synthetic wrapper, report
that seam limitation rather than weakening read-only semantics.

Checkpoint sequence: verify clean tracked baseline and preserved untracked
inventory; checkpoint only Prompt/Response 111 together if not already
checkpointed and explicitly authorized by Prompt 112; push normally; perform
characterization and the two-file implementation; validate and conduct the
canonical conformance audit; checkpoint exactly those two files if authorized;
then separately checkpoint Prompt/Response 112 as directed. Never stage
unrelated material, squash, rebase, force push, or activate production code.

## 12. Canonical Project Conformance verdict

Reviewed against: `AGENTS.md`; shared `00-global/agent-guardrails.md`; project
`README.md`, `DEVELOPER_GUIDE.md`, `00-START-HERE.md`,
`01-PROJECT/AGENT-PROMPT-HARNESS.md`, `01-PROJECT/02-architecture-overview.md`;
database access, overlay independence, `INVIOLATE_RULES.md`, Apple timestamp
authority; attachment preservation invariant; Feature 34 preparation
`MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; Prompt 111 and Responses
102–110. Current production code takes precedence over historical descriptions
of APIs and generic SQLite behavior.

Scope: HEAD `5897918692f6f2614dc9189328d1309c31019e4c` plus this one untracked
audit response. This is not a whole-Feature-34 implementation or readiness audit.

| Conformance category | Verdict |
| --- | --- |
| Reuse, layering, dependency direction | PASS: production writers/parser/search retained; proposed helper remains test-only |
| Single source of truth / project idioms | PASS: no schema, tokenizer, identity, timestamp, or policy authority introduced |
| Performance / lifecycle | PASS for audit/design: limits and current scale/cancellation gaps explicit; no production-scale claim |
| Privacy / logging | PASS: no user DB/payload reads; future diagnostics redacted |
| Mutation / authority | PASS: only this response created; no reset/cutover authority |
| State/error semantics | PASS: dimensions, contradictions, unknowns and discarded attempts separate |
| Dead code / generated / dependencies | No changes; no cleanup or generation needed |
| Tests / architecture | Source-inspected only; execution prohibited by Prompt 111, not claimed passed anew |
| Documentation agreement | Runtime-sensitive integrity wording qualified; older fallback ambiguity wording not promoted over Response 110 |
| UX | No UI changes; not applicable |

In-scope BLOCKER: 0. In-scope SHOULD FIX: 0. OPTIONAL implementation changes: 0.
Later destructive-readiness blockers remain: complete expected-ledger replay,
physical source/registry continuity, production-scale comparisons/resources,
coherent cross-store integration, exhaustive FTS proof, protected payload
coverage, and separate policy/human qualification. These are not waived by an
audit/design PASS. The seven jurisdictions are unchanged; inspected
`ProductionAppCzarActivation.isEnabled` still returns false.

PROJECT CONFORMANCE (AUDIT/DESIGN): PASS

## 13. Final state and continuing prohibitions

The intended and verified final delta is this one untracked response. HEAD,
branch, index, tracked files, shared-submodule state, and all 49 prior
untracked file hashes remain unchanged. Prompt 111 remains untracked; total
untracked files are now 50. No commit/push was necessary. No tests, analyzer,
build, app launch, real-source/database read, archive scan, payload operation,
environment/TCC/FDA/bookmark change, FTS repair, destructive Start Fresh,
mutation Ball, new jurisdiction, or production activation occurred.

Prompt 112 is a recommendation only. Exhaustive FTS equivalence remains
UNKNOWN; destructive Operating-owned Start Fresh / Stage 2C remains BLOCKED.

PROTECTED-REFERENCE QUALIFICATION CHECKPOINTED: YES

FTS SCHEMA, TRIGGERS, RUNTIME, AND SEARCH CALL GRAPH INVENTORIED: YES

CONTENT, BOUNDED SEARCH, AND INTERNAL FTS PROOF LEVELS DISTINGUISHED: YES

STRICTLY READ-ONLY EXHAUSTIVE FTS EQUIVALENCE SUPPORTED BY CURRENT EVIDENCE: UNKNOWN

DISPOSABLE FTS ADVERSARIAL QUALIFICATION PLAN GROUNDED: YES

COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE (AUDIT/DESIGN): PASS

READY FOR NARROW PROMPT 112: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
