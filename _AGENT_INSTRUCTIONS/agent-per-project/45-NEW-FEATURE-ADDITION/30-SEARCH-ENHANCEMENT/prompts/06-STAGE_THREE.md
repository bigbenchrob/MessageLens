


Please implement **Stage 3** of the message-text search redesign: the graph-native FTS5 index and its complete database lifecycle.

Stages 1 and 2 are complete.

The current architecture is now:

```text
raw query
  → MessageTextSearchQuery.parse()
  → structured MessageTextSearchToken values
  → SearchService
  → GraphSearchRepository
  → temporary LIKE executor
```

The repository receives structured tokens and does **not** receive or reconstruct raw editor text.

Stage 3 should replace the temporary message-text/metadata `LIKE` executor with a graph-native FTS5 implementation while preserving the structured-query architecture.

Do **not** change UI/controller behaviour yet.
Do **not** change highlighting yet.
Do **not** redesign AND/OR.
Do **not** implement wildcard or phrase syntax.
Do **not** change the current 500-result limit.

## Branch and worktree

Work only on:

`feature/message-text-search`

Before editing:

1. confirm the current branch;
2. inspect `git status`;
3. preserve unrelated untracked work, including:
   - `.vscode/settings.json`
   - `30-SEARCH-ENHANCEMENT/`

Do not delete, stash, stage, commit, or otherwise alter unrelated work.

The existing Stage One and Stage Two changes are intentional feature work and should be preserved.

---

# Part A — Prove FTS5 and tokenizer behaviour first

Before altering the graph schema, add or run focused characterization tests using the **same SQLite/Drift runtime path MessageLens actually uses**.

Do not rely solely on the host `sqlite3` command-line binary.

Establish that the application's runtime supports:

```sql
CREATE VIRTUAL TABLE ... USING fts5(...)
```

If FTS5 is unavailable through the actual runtime, **stop Stage 3 without implementing a fallback** and report the finding.

Do not silently revert to `%term%`.

## Characterize `unicode61`

Use:

```text
unicode61 remove_diacritics 2
```

as the candidate tokenizer.

Before making its behaviour a production invariant, characterize at least:

- ordinary ASCII words;
- case-insensitive matching;
- Latin diacritics;
- punctuation;
- period/comma/question-mark boundaries;
- parentheses;
- tabs/newlines;
- apostrophes;
- hyphens;
- underscores;
- emoji adjacent to text;
- representative non-Latin Unicode text.

Specifically establish actual runtime behaviour for examples such as:

```text
post
post.
(post)
post?
post-master
don't
crosspost
👩‍💻post
```

and exact/prefix FTS queries corresponding to them.

The product-level invariants we already know are:

- prefix `post` must match words beginning with `post`;
- prefix `post` must not match `crosspost`;
- exact `post` must not match `postmaster`;
- ordinary punctuation such as `. , ? ( )` should allow `post` to be treated as a token;
- completed one-character tokens must be searchable;
- unfinished one-character prefixes must not execute.

For apostrophes and hyphens, use the characterization results to determine what default `unicode61` does. Unless the behaviour is clearly unacceptable, prefer the default tokenizer over introducing app-specific token rules.

Report any surprising behavior explicitly.

---

# Part B — Graph-native FTS index

If Part A succeeds, add a graph-owned FTS5 table for **visible message text only**.

Conceptually the intended shape is similar to:

```sql
CREATE VIRTUAL TABLE message_text_fts USING fts5(
  text,
  content='messages',
  content_rowid='ss_id',
  tokenize='unicode61 remove_diacritics 2',
  prefix='2 3 4'
);
```

You may adjust the exact SQL if required by the existing Drift/database architecture, but explain any deviation.

## Important domain invariant

The FTS table should index only `messages.text`.

Do **not** index:

- GUID;
- sender handle;
- canonical sender display handle;
- semantic kind;
- item kind;
- tags;
- saved state.

Those are separate domains.

The current temporary repository method `_searchTextAndMetadataMessageIds` should cease to be the message-text implementation.

As part of Stage 3, message-text search should stop returning invisible metadata-only matches.

Do not invent a replacement metadata search feature. If metadata search is wanted later, it should become explicit.

Tags and saved state remain overlay-owned.

---

# Part C — Schema version and migration

Inspect the actual graph schema version on this branch before editing. The previous audit reported version 2; verify rather than assuming.

If still appropriate, migrate to the next schema version.

The upgrade path for an existing database must:

1. create the FTS virtual table;
2. create whatever synchronization mechanism is required;
3. backfill/index all existing message text;
4. leave authoritative `messages` rows untouched.

Existing users must **not** need to re-import Apple's `chat.db` merely to obtain the FTS index.

The graph is derived/rebuildable, but the ordinary migration should be able to populate the index from the existing graph database.

Do not modify Apple source databases or import ledgers.

---

# Part D — FTS synchronization lifecycle

The FTS index must remain derived from and synchronized with `messages`.

Prefer database-level synchronization, such as appropriate FTS external-content triggers, if that fits the existing architecture cleanly.

Cover all relevant lifecycle events:

- message INSERT;
- message text UPDATE;
- message DELETE;
- rich-text/reprojection update paths;
- graph clearing/reset;
- graph rebuild/reprojection.

A newly projected message should become searchable without a separate global rebuild.

Periodic intake should automatically keep FTS current through the same projection lifecycle.

If trigger-based synchronization is used, test the actual trigger behaviour rather than assuming it works.

Do not add manual search-index maintenance to every writer unless triggers prove unsuitable.

---

# Part E — Execute structured tokens with FTS

Replace the temporary message-text `LIKE` execution with FTS `MATCH`.

The repository already receives:

- `ExactMessageTextSearchToken`
- `PrefixMessageTextSearchToken`

Map them internally to FTS semantics.

Conceptually:

```text
Exact("post")   → exact FTS token post
Prefix("post")  → FTS prefix post*
Exact("p")      → exact FTS token p
```

An unfinished one-character prefix should already have been removed by Stage One and therefore should not reach the repository as executable text intent.

## Escaping is mandatory

Raw token text must **never** be passed directly into FTS query syntax.

The application owns the query language.

Characters such as:

```text
"
*
-
(
)
:
```

must remain ordinary search input at this stage.

Construct/escape FTS expressions internally so user text cannot accidentally become:

- wildcard syntax;
- phrase syntax;
- column syntax;
- boolean syntax;
- exclusion syntax;
- malformed MATCH input.

Do not expose FTS query language to users.

Add focused tests for this.

---

# Part F — Multiple structured tokens

Preserve the existing `matchAnyTerm` plumbing without redesigning it.

For now:

- `matchAnyTerm == false` should combine executable text tokens using the existing all-terms meaning;
- `matchAnyTerm == true` should combine them using the existing any-term meaning.

Do not make a product judgment about AND/OR yet.

The important requirement is that each individual token's exact/prefix meaning remains intact.

For example, the structured intent:

```text
Exact("bass")
Prefix("pl")
```

must execute using those respective FTS semantics.

Do not flatten both back into generic strings.

---

# Part G — Scope and result ordering

Preserve all existing graph scopes:

- global;
- conversation;
- handle;
- contact canonical handles.

FTS matching must still respect those scopes.

Preserve the existing result contract:

- canonical graph `message.ss_id`;
- newest-first ordering;
- current explicit result limit of **500**.

Do **not** switch to FTS relevance ranking.

The repository should join/filter FTS matches against graph messages as necessary to preserve the current ordering:

```text
date_utc descending
then ss_id descending
```

Verify the exact current ordering before editing and preserve it.

---

# Part H — Tag and saved composition

Tags remain a separate overlay search domain.

Saved state remains a separate overlay filter.

Do not migrate either into FTS.

Existing behaviour for:

```text
invoice is:saved
```

should remain operational.

Be particularly careful that replacing message-text SQL does not accidentally break the existing result merge/intersection logic between:

- FTS text matches;
- tag matches;
- saved filtering.

If there are existing ambiguities in how text and tags combine under AND/OR, preserve current behaviour for Stage 3 and report them for the later AND/OR pass.

---

# Required repository semantics

After Stage 3, these result-level behaviours should hold.

Given messages containing:

```text
post
post.
post,
(post)
post?
posting
posted
posts
postmaster
crosspost
support
repository
decompose
```

then:

### Prefix `po`

should find word tokens beginning `po`, such as:

```text
post
posting
possible
point
```

and should not match a token merely because `po` occurs internally.

### Prefix `post`

should match:

```text
post
posting
posted
posts
postmaster
```

but not:

```text
crosspost
```

### Exact `post`

should match standalone/tokenized `post`, including ordinary punctuation boundaries, but not:

```text
posting
posted
posts
postmaster
crosspost
```

### Exact one-character token

`p ` at the parser/service level ultimately produces exact `p`, and FTS must support that search.

### Internal substring

`ic`

must not match:

```text
ridiculous
```

merely because `ic` occurs inside the token.

---

# Tests

Add comprehensive focused tests in four groups.

## 1. Runtime/tokenizer characterization

Verify actual MessageLens SQLite runtime support and lock down accepted `unicode61` behavior.

## 2. Repository FTS semantics

Cover:

- exact token;
- prefix token;
- exact one-character token;
- word-initial rather than arbitrary substring matching;
- punctuation boundaries;
- `crosspost` exclusion;
- special-character escaping;
- case;
- diacritics;
- characterized apostrophe/hyphen behaviour;
- representative Unicode.

Test at least global scope and one constrained scope.

## 3. FTS lifecycle

Verify:

- fresh database contains the index;
- migration from the previous schema version backfills pre-existing messages;
- INSERT becomes searchable;
- UPDATE changes indexed text;
- DELETE removes the indexed entry;
- graph reset clears appropriately;
- rebuild/reprojection restores it.

Use the actual graph database path/mechanism rather than a disconnected toy database wherever practical.

## 4. Regression

Run existing:

- Stage One parser tests;
- SearchService tests;
- graph-search repository tests;
- graph migration tests;
- projection tests;
- saved/tag search tests;
- directly affected Message Evidence tests;
- architecture tripwires.

Also run scoped/full analysis according to project rules and `git diff --check`.

---

# Performance characterization

Do not undertake a large optimization project yet, but collect enough evidence to catch an obviously unsuitable implementation.

If an appropriate representative fixture/database is already available without accessing user-private production data, measure:

- FTS backfill/migration time;
- index size increase;
- two-character prefix query latency;
- longer-prefix query latency;
- incremental insert/update cost.

Do not access external/private user Application Support databases merely to satisfy this benchmark unless project rules already provide an approved test fixture.

If representative performance cannot be established from repository fixtures, state that explicitly rather than inventing measurements.

---

# Scope constraints

Stage 3 may modify:

- graph database schema/migration;
- graph search repository;
- narrowly related database helpers;
- focused tests/fixtures required for FTS;
- structured-token-to-FTS query generation.

Stage 3 should **not** modify:

- search text fields;
- controller synchronization;
- global/contact/handle/recovered presentation query trimming;
- provider identities;
- highlighting;
- AND/OR controls or product semantics;
- wildcard UI syntax;
- quoted phrase syntax;
- release metadata;
- the 500-result limit.

Do not perform broad unrelated refactors.

---

# Stop conditions

Stop and report instead of improvising if:

1. FTS5 is unavailable through MessageLens's actual SQLite runtime;
2. the required migration cannot safely backfill existing graph databases;
3. `unicode61` exhibits behaviour that fundamentally violates the established word-prefix/exact-token product semantics;
4. implementing FTS would require changing authoritative import data rather than derived graph data.

Do not silently implement a weaker fallback.

---

# Deliverable

Report:

1. FTS5 runtime verification
2. `unicode61` characterization results
3. Product decisions implied by apostrophe/hyphen/punctuation behaviour
4. Files changed
5. Graph schema/migration changes
6. FTS table/index configuration
7. Synchronization mechanism
8. Structured-token → FTS expression mapping
9. FTS escaping strategy
10. Removal of metadata-only text matches
11. Scope/order/500-result-cap preservation
12. Tag and saved-filter preservation
13. Migration/lifecycle tests
14. Search-semantic tests
15. Regression tests and analysis results
16. Any performance measurements available
17. Remaining limitations
18. `git status`
19. Recommended Stage 4 boundary

Do not proceed into UI/controller-state or highlighting changes after completing this stage.

One small correction to our earlier planning is now explicit in that prompt: **500 is the invariant**, not 10,000. I like that Codex caught that rather than blindly implementing a number from our audit.