No files were changed. The smallest clean path is to introduce a structured query parser, preserve raw input separately from parsed search intent, and replace message-text `%term%` scans with a graph-native FTS5 index using the `unicode61` tokenizer.

## 1. Current architecture

### Data path

Both onboarding and periodic intake converge on the same graph projection:

```text
Apple chat.db
  → MessageImporter
  → source-scoped import ledger: messages.text
  → SqliteMessageProjectionRepository
  → conversation graph: messages.text
  → graph-backed search repository
```

Onboarding runs the complete import/build orchestration. Live intake:

- probes `chat.db` at startup;
- polls every 15 seconds;
- detects new rows using `message.ROWID`;
- imports rows beyond the saved source cursor;
- incrementally projects them into the graph.

Neither path presently builds a message-text search index.

### UI-to-SQL path

The common path is:

```text
MacosTextField
  → controller/listener or session notifier
  → surface-specific query trimming
  → MessageEvidenceScope
  → messageEvidenceTextMatchIdsProvider
  → SearchService
  → GraphSearchRepository
  → SqliteGraphSearchRepository
  → lower(column) LIKE '%term%'
  → message ss_id results
  → timeline skeleton filtered by those IDs
```

The search result contract is a list of graph `message.ss_id` values, ordered newest first and limited to 10,000.

### Current SQL domain

Despite method and UI names referring to message text, `_searchTextMessageIds()` searches each term across:

- `messages.text`
- message GUID
- sender handle
- canonical sender display handle
- semantic kind
- item kind

Each field uses:

```sql
lower(COALESCE(column, '')) LIKE '%term%'
```

This explains invisible metadata-only matches.

Tags are searched separately from the overlay database, then merged with text/metadata results. `is:saved` is parsed as a special operator.

## 2. Search surfaces

All of these ultimately use `messageEvidenceTextMatchIdsProvider` → `SearchService` → `SqliteGraphSearchRepository`:

| Surface | State ownership | Raw input retained? | Notable divergence |
|---|---|---:|---|
| Global All Messages | Riverpod family session | No, effectively | Presentation trims and feeds the value back into the field |
| Search-page All Messages tracks | Same global session | No | Receives `presentation.query`, already trimmed |
| Conversation messages | Local controller/state | Mostly | Query is trimmed before provider call |
| Contact messages | Local controller/state | Mostly | Query is trimmed before provider call |
| Handle messages | Local controller/state | Mostly | Query is trimmed before provider call |
| Handle Lens | Riverpod session | Yes in controls | Trimmed copy is sent to search |
| Recovered messages | Local controller/state | Mostly | Search still resolves through the graph repository |
| Unfamiliar-source/handle tracks | Handle Lens session | Yes in controls | Provider receives `session.query.trim()` |

`ConversationExcerptEvidenceScope` can technically route through the same matcher, but the visible excerpt is subsequently constrained to its context window.

## 3. Current normalization and synchronization

Normalization occurs at several levels.

### Presentation and scope layers

The following commonly call `.trim()` before constructing search scopes or invoking providers:

- global presentation provider;
- conversation view;
- contact view;
- handle view;
- recovered-message view;
- Handle Lens track occupants;
- Message Evidence Spine provider;
- scope stable keys and equality.

That means query identity currently treats `post` and `post ` as identical. Under the proposed semantics, they are different searches.

### Service layer

`SearchService`:

- splits on `RegExp(r'\s+')`;
- detects and removes `is:saved`;
- rejoins tokens;
- trims the result;
- separately attempts to detect trailing whitespace.

The service’s completion detection works when called directly, as its unit test demonstrates. In ordinary message-evidence searches, however, callers have already trimmed the query.

### Repository layer

`_searchTerms()`:

- splits on whitespace;
- passes each segment through `normalizeMessageTagValue`;
- removes empty results.

That tag normalizer:

- trims and collapses whitespace;
- lowercases;
- folds a fixed set of Latin diacritics;
- changes most punctuation into separators;
- changes hyphens into spaces.

This tag-specific function is being reused to prepare message-text SQL terms, but it does not tokenize stored message text equivalently. The SQL still searches the original text with `LIKE`. Query normalization and document tokenization are therefore not governed by one consistent tokenizer.

### Visible-controller rewrite

The confirmed global bug is in this cycle:

```text
controller: "post "
  → session.query: "post "
  → presentation.query: session.query.trim() = "post"
  → GlobalMessagesEvidenceView writes presentation.query into controller
  → visible controller becomes "post"
```

The reusable search-controls widget also synchronizes its internal controller to any changed `widget.query`. This is correct only if `widget.query` is raw UI state. On the global Search page it receives the trimmed presentation value instead.

## 4. Relevant reusable components

Useful existing boundaries are:

- `MessageEvidenceSearchControlsPresentation`: one shared editor/control presentation.
- `GlobalMessagesSearchSessionState` and `HandleLensSessionState`: suitable raw-query owners.
- `MessageEvidenceSearchMode`: the existing boolean-mode carrier.
- `SearchService`: appropriate home for converting raw input into search intent.
- `GraphSearchRepository`: the correct persistence abstraction.
- `GraphMessageSearchScope`: reusable global/conversation/contact/handle scoping.
- `ConversationGraphDatabase`: correct owner of a graph-native derived text index.
- `SqliteMessageProjectionRepository`: incremental writes already pass every projected message through one place.
- graph schema migration and graph rebuild/reset infrastructure.
- existing graph-search repository and service tests.

What is missing is a message-search query type. `normalizeMessageTagValue` and the tag token helpers are useful references, but they should not become the authority for message-text tokenization.

## 5. Conflicts with the desired semantics

| Desired behavior | Current behavior |
|---|---|
| `p` performs no broad text search | Searches `%p%` |
| `p ` means exact token `p` | Trailing space is usually lost; searches `%p%` |
| `po` means word-prefix `po*` | Searches `%po%` anywhere |
| `post` excludes `crosspost` | Matches `crosspost` |
| `post ` excludes `posting` | Matches `posting`; space may disappear |
| `bass pl` means exact `bass` + prefix `pl` | Both become unrestricted substrings |
| Raw editor text remains unchanged | Global presentation writes a trimmed value back |
| Text search yields visible text matches | Metadata can produce matches |
| Query and document use one token definition | Query uses a tag normalizer; document uses raw `LIKE` |

Scope keys also collapse `post` and `post ` through `.trim()`. Even after preserving the editor, this would allow Riverpod/provider caching to conflate semantically distinct searches unless scopes carry parsed intent or a completion-sensitive key.

Highlighting has a related problem: `SearchHighlightedText` performs case-insensitive substring highlighting. After FTS semantics change, it could still highlight `post` inside `crosspost` or fail to mirror Unicode token boundaries. It must be brought under the same parsed-token semantics or use FTS-derived match information.

## 6. Recommended technical approach

### Use a staged FTS5 implementation

I recommend FTS5 in the conversation graph, combined with an application-owned parser.

#### A. Introduce a structured token-semantics type

Conceptually:

```dart
final class MessageTextSearchQuery {
  final String rawInput;
  final List<MessageTextSearchToken> tokens;
  final bool hasTrailingWhitespace;
}

sealed class MessageTextSearchToken {
  String get normalizedText;
}

final class ExactMessageTextToken extends MessageTextSearchToken {}
final class PrefixMessageTextToken extends MessageTextSearchToken {}
```

The parser should establish:

- every non-final token is complete/exact;
- the final token is exact when raw input ends in whitespace;
- otherwise the final token is a prefix;
- an active one-character prefix is not sent to text search;
- a completed one-character token is retained;
- raw input is never reconstructed from parsed tokens.

Boolean combination stays outside the token model so the later AND/OR design can consume the same tokens.

The parser should also extract `is:saved` without destroying the raw editor value.

#### B. Add a graph-native FTS5 table

Recommended initial shape:

```sql
CREATE VIRTUAL TABLE message_text_fts USING fts5(
  text,
  content='messages',
  content_rowid='ss_id',
  tokenize='unicode61 remove_diacritics 2',
  prefix='2 3 4'
);
```

Important points:

- Index only visible message text.
- Use `messages.ss_id` as the FTS rowid.
- Do not put GUID, handles, semantic kind, or item kind into this table.
- Add insert, update, and delete triggers so projection updates and graph resets keep it synchronized.
- Backfill existing rows during schema migration with FTS’s rebuild operation.
- Keep tag and saved-filter searches as separate overlay domains.

`prefix='2 3 4'` accelerates the most interactive prefix lengths. Prefixes longer than four characters still work through a token-range scan; they do not require every possible prefix length to be indexed.

#### C. Generate FTS expressions internally

Do not pass raw user input as FTS syntax. The parser should escape every normalized token and the repository should construct a bound `MATCH` expression:

- exact `post` → `"post"`
- prefix `post` → `"post"*`
- exact `bass` plus prefix `pl` → `"bass" AND "pl"*`, subject to the existing mode
- active `p` alone → no text query
- completed `p ` → `"p"`

This preserves the “ordinary search box” design and prevents punctuation, quotes, `*`, `-`, parentheses, or FTS keywords from accidentally becoming query syntax.

#### D. Preserve raw UI state

Every search surface should retain `rawQuery`. A separately derived parsed query should drive:

- provider identity;
- search execution;
- status wording;
- highlighting.

Normalized state must never be written into the editor controller.

For the global surface specifically, `GlobalMessagesEvidencePresentationState.query` should either remain raw or be split explicitly into fields such as `rawQuery` and `searchQuery`. The view must synchronize only from `rawQuery`.

#### E. Separate search domains

The repository currently combines message text, metadata, tags, and saved status. The clean boundary is:

```text
message text matches (graph FTS)
tag matches (overlay)
saved-message filter (overlay)
optional future metadata search (separate explicit domain)
```

For this feature, message-text searches should stop querying metadata columns. Tags may continue participating if that is intentional product behavior, but they should not be hidden inside a method named “text search.” Ideally, the service combines explicitly named result sources.

## 7. How FTS5 maps to the semantics

SQLite’s default `unicode61` tokenizer is a strong fit, but it defines the searchable word boundary—not trailing query whitespace itself.

It provides:

- case-insensitive Unicode token matching;
- Latin diacritic folding;
- exact-token lookup;
- word-initial prefix queries using `*`;
- optional prefix indexes.

Examples:

| Parsed intent | FTS expression | Effect |
|---|---|---|
| unfinished `po` | `"po"*` | `post`, `possible`; not `support` |
| unfinished `post` | `"post"*` | `post`, `posting`, `postmaster`; not `crosspost` |
| completed `post ` | `"post"` | exact FTS token `post` |
| completed `p ` | `"p"` | exact one-character token |
| `bass pl` | `"bass" AND "pl"*` | exact `bass`, prefix `pl` |

SQLite documents that `unicode61` treats Unicode letters, numbers, and private-use characters as token characters; spaces and punctuation are separators. Prefix matching applies to the beginning of an indexed token. [SQLite FTS5 documentation](https://www.sqlite.org/fts5.html)

### Tokenization decisions

Default `unicode61` would normally yield these implications:

- `post.`, `(post)`, `post?`, and newlines: `post` is an exact token.
- emoji: generally separators, so `👩‍💻post` exposes `post` as a token.
- `co-op`: normally tokenized as `co`, `op`.
- `post-master`: normally `post`, `master`; exact `post` would match it.
- apostrophes: punctuation, so `don't` normally becomes `don`, `t`.
- underscores: punctuation/separator under the documented default.
- letters outside Latin scripts remain searchable as Unicode tokens.
- Latin diacritics are folded by default; `remove_diacritics 2` gives more complete handling than the default mode.

These choices must be accepted explicitly in product tests. In particular, whether exact `post` should match `post-master`, and whether `don` should match part of `don't`, are product decisions. If apostrophes or hyphens should remain inside words, `tokenchars` can change that, but doing so also changes prefix and exact-match behavior throughout the archive.

I recommend starting with unmodified punctuation boundaries and `remove_diacritics 2`, then documenting the behavior. It best matches the prompt’s “normal punctuation boundary” principle and avoids an app-specific tokenizer.

Do not use:

- `porter`, because stemming would undermine exact completed-token semantics;
- `trigram`, because it recreates arbitrary substring behavior.

## 8. FTS5 availability and assumption

The repository contains no existing FTS table, FTS abstraction, or `MATCH` query.

The locked `sqlite3` package is 2.9.0, and Drift opens the graph via `NativeDatabase.createInBackground`. On macOS, that package uses the SQLite supplied by the platform unless another SQLite library is bundled.

The local macOS SQLite runtime reports `ENABLE_FTS5=1`, and a local probe successfully created and queried an FTS5 table. However:

> I cannot establish from repository contents alone that every supported tester macOS runtime or every eventual platform build exposes FTS5.

Before committing to the migration, add an application-runtime/integration test that creates an in-memory FTS5 table using the exact Drift/SQLite path used by MessageLens. If MessageLens must support runtimes without FTS5, it should bundle a controlled SQLite build or fail the migration safely; silently falling back to `%term%` would violate the promised semantics.

## 9. Migration and index implications

### Schema migration

`ConversationGraphDatabase.schemaVersion` is currently 2. The implementation would require version 3.

The upgrade must:

1. create the FTS virtual table;
2. create synchronization triggers;
3. rebuild the FTS index from existing `messages`;
4. leave original graph rows untouched.

The graph database is derived and rebuildable, but existing users should not need a full chat import solely to obtain the index.

The current generic `onUpgrade` merely calls `_createSchema()`. Backfilling needs an explicit version-aware migration step. Calling `CREATE VIRTUAL TABLE IF NOT EXISTS` alone would leave an empty index for existing installations.

### New-message intake

Triggers on `messages` make periodic intake automatic:

```text
new graph message INSERT
  → FTS trigger
  → one indexed text row
```

Updates from rich-text enrichment or reprojection must also update the FTS row. Deletes and `clearProjectionRows()` must remove index entries.

The incremental cost should be modest relative to graph projection, though FTS segment maintenance adds writes. FTS5 performs incremental merging, limiting unpredictable per-insert merge work.

### Size

FTS duplicates token/index information and will materially increase `working_ss.db`. Exact size cannot be established without representative archive measurements. `prefix='2 3 4'` adds further index entries in exchange for responsive incremental searches.

Before shipping, benchmark:

- database size before/after indexing;
- migration time for a large tester archive;
- two-, three-, and four-character prefix latency;
- periodic intake latency.

### Result cap

The 10,000-ID contract can remain unchanged:

```sql
SELECT rowid
FROM message_text_fts
WHERE message_text_fts MATCH ?
ORDER BY ...
LIMIT 10000
```

Because ordering is currently newest-first rather than relevance-first, join matched rowids to `messages` and keep the present date/ID ordering. Do not silently switch to FTS rank.

## 10. Alternatives considered

### Keep `LIKE` and add boundary expressions

This could combine patterns such as start-of-string, whitespace, and punctuation checks, but SQLite does not provide a built-in Unicode-aware word-boundary operator for `LIKE`. Enumerating delimiters would be incomplete, difficult to keep aligned with highlighting, and still require full scans for every keystroke.

It is acceptable only as a temporary prototype, not the clean production path.

### Register a Dart regular-expression function

A regex could express boundaries more clearly, but every candidate row would still cross a query-function boundary and scan text. Unicode word semantics would need to be authored and maintained by MessageLens. It also provides no index acceleration.

### Store normalized token rows in an ordinary table

A table like `(message_ss_id, token, position)` could implement the exact behavior. It would give complete tokenizer control but would require MessageLens to own tokenization, migration, synchronization, prefix indexes, and query planning. That duplicates capabilities already present in FTS5.

### Use the current tag tokenizer

It is ASCII-oriented after normalization, has a hand-maintained diacritic map, and was designed for tags. Applying it to message documents would lose broader Unicode fidelity and create a parallel text representation. It should not be promoted into the message-text authority.

### Immediate custom FTS tokenizer

This provides maximum control but is disproportionate for the stated semantics. Start with `unicode61`, lock its behavior down with product tests, and revisit only if real message corpora expose unacceptable boundaries.

## 11. Exact proposed edit scope

The likely minimal production scope is:

### Query semantics

- Add a message-text query/token model under:
  - `lib/essentials/search/domain/` or the existing search application boundary.
- Add its focused parser tests under:
  - `test/essentials/search/domain/` or `application/`.

### Search service and repository contract

- [search_service.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/application/search_service.dart)
- [graph_message_search.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/application/graph_message_search.dart)
- [graph_search_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/infrastructure/repositories/graph_search_repository.dart)

### Graph schema and synchronization

- [conversation_graph_database.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart)
- possibly [message_projection_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/conversation_graph/infrastructure/repositories/message_projection_repository.dart) only if schema triggers are not chosen.

Triggers are preferable because they cover inserts, updates, deletion, resets, and tests without coupling every writer manually to search maintenance.

### Raw versus parsed presentation state

- [global_messages_search_session_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/application/message_evidence/global_messages_search_session_provider.dart)
- [global_messages_evidence_presentation_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/presentation/view_model/global_messages_evidence_presentation_provider.dart)
- [global_messages_evidence_view.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/presentation/view/global_messages_evidence_view.dart)
- [message_evidence_spine_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart)
- [message_evidence_scope.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/domain/message_evidence/message_evidence_scope.dart)
- the conversation, contact, handle, Handle Lens, recovered-message, and track-occupant callers currently passing `.trim()`.

### Highlighting

- [search_highlighted_text.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/presentation/widgets/search_highlighted_text.dart)

### Generated and release metadata

If provider signatures change, regenerate affected `*.g.dart`; do not hand-edit them.

Because this is tester-visible, release-worthy behavior, the eventual implementation also requires:

- `pubspec.yaml` version bump;
- `CHANGELOG.md` entry.

No source import schema needs modification. The index belongs only to the derived graph database.

## 12. Focused test plan

### Parser tests

Cover exactly:

- `''` and whitespace-only input;
- `p` → ignored active one-character prefix;
- `p ` → exact `p`;
- `po` → prefix `po`;
- `post` → prefix `post`;
- `post ` → exact `post`;
- `bass pl` → exact `bass`, prefix `pl`;
- `bass player ` → two exact tokens;
- tabs and newlines as completion whitespace;
- repeated spaces;
- mixed case and diacritics;
- FTS-special input escaped as ordinary text;
- `is:saved` extraction without changing raw input.

### FTS repository tests

Add records containing:

- `post`
- `posts`
- `posted`
- `posting`
- `postmaster`
- `crosspost`
- `support`
- `repository`
- punctuation forms from the prompt;
- newline boundaries;
- apostrophes;
- hyphens;
- emoji adjacent to words;
- accented Latin text;
- non-Latin words.

Assert all hard cases in both global and one constrained scope.

Also assert:

- metadata-only terms no longer match message text;
- tags and saved filters remain independently correct;
- newest-first ordering remains;
- 10,000 limit remains;
- inserted, updated, and deleted graph messages synchronize FTS.

### Database migration tests

Extend graph database tests to verify:

- a fresh version-3 database contains the FTS table and triggers;
- upgrading a version-2 database backfills existing messages;
- graph reset empties the index;
- reprojection repopulates it;
- FTS5 is available through the exact application database runtime.

### Provider and UI tests

Add tests for:

- the first trailing space remains visible;
- `post` and `post ` produce distinct parsed provider identities;
- all message-search surfaces preserve raw controller content;
- one-character unfinished input does not launch broad text search;
- completed one-character input does;
- highlight boundaries agree with result boundaries.

Existing relevant suites include:

- `test/essentials/search/application/search_service_test.dart`
- `test/essentials/search/infrastructure/repositories/graph_search_repository_test.dart`
- `test/essentials/search/presentation/widgets/search_highlighted_text_test.dart`
- `test/features/messages/application/message_evidence/message_evidence_spine_provider_test.dart`
- global/contact/handle/recovered/conversation presentation tests
- graph database migration tests
- message projector tests
- Handle Lens and unfamiliar-source track tests

## 13. Hard invariants to preserve

- Raw input remains byte-for-byte presentation state and is never rewritten by normalization.
- `post` and `post ` remain semantically distinct.
- Message search returns canonical graph `ss_id` values.
- Existing scope isolation remains intact.
- Result order remains newest-first.
- The 10,000-result ceiling remains explicit.
- Case matching remains insensitive.
- One-character active prefixes do not trigger broad text search.
- Completed one-character tokens remain searchable.
- Every imported message remains stored and renderable, including null-text and anomalous records.
- The index remains derived graph data and never becomes authoritative message content.
- Periodic import does not read or consult overlay data.
- Tags and saved status remain overlay-owned.
- No metadata-only match is described as a message-text match.
- Query escaping prevents ordinary input from becoming FTS syntax.
- Index migration never mutates Apple’s `chat.db` or the attachment archive.

## 14. Minimal implementation sequence

1. Add the structured parser and exhaustively test raw/completed/prefix semantics.
2. Change search contracts to accept parsed message-text intent while retaining the existing boolean mode unchanged.
3. Add FTS5 capability and tokenizer characterization tests.
4. Add graph schema version 3, FTS table, synchronization triggers, and migration backfill.
5. Replace only the message-text/metadata `LIKE` path with FTS `MATCH`.
6. Remove metadata columns from the text domain; preserve tag/saved combination explicitly.
7. Separate raw presentation input from parsed provider/search identity across every surface.
8. Correct boundary-aware highlighting.
9. Run migration, projection, repository, provider, and widget tests.
10. Benchmark a representative large archive for migration time, index growth, keystroke latency, and incremental-intake cost.
11. Add release metadata only when the implementation is approved.

The one decision I would resolve before implementation is the product definition of apostrophes and hyphens. My recommendation is to accept default `unicode61` separator behavior initially—so punctuation forms boundaries—and make that behavior explicit in tests. )$-IMPLEMENT-STAG