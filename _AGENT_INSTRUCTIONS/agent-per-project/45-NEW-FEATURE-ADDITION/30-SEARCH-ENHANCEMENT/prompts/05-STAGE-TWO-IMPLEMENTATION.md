Stage One looks good, and the actual parser matches the report. Two details are especially worth preserving: it uses `runes.length` for the one-character threshold rather than UTF-16 code units, and punctuation is deliberately retained rather than prematurely imposing a home-grown tokenizer.

One architectural nuance I’d tighten for Stage Two: **raw input should remain presentation state, but it should not necessarily become repository/search-cache identity wholesale.** We need `post` and `post ` to be distinct because their parsed intents differ; we do *not* necessarily want `post ` and `post    ` to cause distinct persistence searches just because their raw strings differ. The parser object can retain exact `rawInput`, while execution should be driven by its structured intent.

I’d proceed with Codex’s proposed boundary, with that distinction made explicit.



Please implement **Stage 2 only** of the message-text search redesign.

Stage 1 is complete and introduced:

- `MessageTextSearchQuery`
- `MessageTextSearchToken`
- `ExactMessageTextSearchToken`
- `PrefixMessageTextSearchToken`

with focused tests.

The purpose of Stage 2 is to make this structured query representation the authoritative path from `SearchService` to the graph-search repository, eliminating the current duplicate/destructive message-text parsing.

**Do not implement FTS5 yet.**
**Do not change the graph schema.**
**Do not change UI/controller behaviour yet.**
**Do not redesign AND/OR.**
**Do not attempt to deliver the final exact/prefix search semantics using clever `LIKE` expressions.**

## Branch and worktree

Work only on:

`feature/message-text-search`

Before editing:

1. confirm the current branch;
2. inspect `git status`;
3. preserve unrelated untracked work, especially `.vscode/settings.json` and `30-SEARCH-ENHANCEMENT/`.

Do not modify, delete, stage, stash, or commit unrelated work.

## Stage 2 objective

Today the search pipeline reparses and normalizes raw strings at multiple levels.

The desired architecture is conceptually:

```text
raw user query
    ↓
MessageTextSearchQuery.parse(...)
    ↓
SearchService
    ↓
structured message-text search intent
    ↓
GraphSearchRepository
    ↓
current temporary SQL implementation
```

There should be **one authoritative interpretation of message-text query tokens**.

The repository should no longer independently split arbitrary raw search strings and run message-text terms through the tag normalizer.

## Important distinction: raw input vs execution identity

`MessageTextSearchQuery.rawInput` must continue to preserve the user's exact editor contents.

However, do not unnecessarily make byte-for-byte raw editor text the identity of repository execution.

For example:

```text
post
```

and:

```text
post␠
```

have different parsed search intent and therefore must remain different searches.

But:

```text
post␠
```

and:

```text
post␠␠␠␠
```

may have identical executable intent even though their raw presentation states differ.

Likewise, repeated internal whitespace may produce identical token intent.

Please preserve the architectural distinction between:

1. **raw presentation state**, which must remain exact;
2. **parsed search intent**, which determines execution.

Do not prematurely conflate those concepts in provider/repository APIs or caching keys.

We will address presentation/provider identity comprehensively in a later stage.

## SearchService

Refactor `SearchService` so that Stage 1's parser becomes authoritative for message-text term interpretation.

Specifically inspect and remove or replace duplicated logic that currently:

- splits raw queries on whitespace;
- trims/rejoins message-text terms;
- separately detects trailing whitespace;
- separately detects/removes `is:saved`;
- treats message search terms as undifferentiated strings.

Do not remove behavior that is still required for tags or other independent search domains.

The service should be able to distinguish and preserve:

- exact message-text tokens;
- prefix message-text tokens;
- `filterSaved`;
- raw input where needed by higher layers.

Do not reconstruct raw input from parsed tokens.

## `is:saved`

Stage 1 already parses `is:saved` structurally.

Make that the authoritative interpretation for message-search queries.

Avoid having `SearchService` independently rediscover/remove the same operator through a second parsing implementation.

Existing saved-message behaviour must remain operational.

Do not redesign the saved filter or its overlay ownership.

## Repository contract

Adjust `GraphSearchRepository` and `SqliteGraphSearchRepository` as needed so the persistence boundary receives **structured message-text intent**, rather than reparsing a raw query string itself.

Choose the smallest clean contract consistent with existing architecture.

It may accept:

- `MessageTextSearchQuery`;
- a list of structured `MessageTextSearchToken`s;
- or a narrower execution-specific value derived from the parsed query.

Prefer the narrowest representation the repository actually needs.

The repository should not need exact raw editor text merely to execute a search.

### Important temporary constraint

The existing SQL may continue using its current substring `LIKE` behavior during this stage.

That means Stage 2 is an **architectural plumbing stage**, not the stage in which:

`post`

and:

`post `

finally return different database results.

Do not create elaborate temporary SQL merely to simulate the eventual FTS behaviour.

It is acceptable for exact and prefix tokens temporarily to execute through the same old substring mechanism, provided:

- their distinct structured types reach the persistence boundary intact;
- no information is lost;
- tests make the temporary limitation explicit;
- Stage 3 can replace that implementation cleanly with FTS.

## Remove inappropriate message-text normalization

The previous audit found that the repository currently runs message-text terms through `normalizeMessageTagValue`.

That is a tag-specific normalization function and must not remain the authority for message-text search.

Remove that coupling from the message-text path if Stage 2 permits doing so safely.

Do not alter tag normalization itself.

Do not introduce a replacement custom tokenizer.

Document tokenization and punctuation semantics remain responsibilities of the future FTS backend.

## Metadata search

The current "message text" SQL also searches:

- GUID;
- sender handle;
- canonical sender display handle;
- semantic kind;
- item kind.

Do **not** redesign this domain in Stage 2 unless changing the repository contract requires separating it structurally.

If practical, make the distinction explicit in types or private methods so Stage 3 can replace the actual message-text path without ambiguity.

But do not make unrelated user-visible search-scope changes yet.

If metadata-only matching remains temporarily, state that clearly in the report.

## AND/OR

Preserve existing `MessageEvidenceSearchMode` behaviour.

Do not reconsider the product semantics yet.

If the current repository combines terms according to AND/OR, continue doing so using the structured token list while treating exact/prefix token kinds equivalently for temporary `LIKE` execution.

The token-kind information must nevertheless remain available.

## Tests

Add or update focused tests proving the architectural contract.

At minimum establish that:

- `SearchService` uses `MessageTextSearchQuery.parse()` rather than duplicating parsing;
- `p` produces no executable text token at the repository boundary;
- `p ` reaches the boundary as exact `p`;
- `po` reaches it as prefix `po`;
- `post` reaches it as prefix `post`;
- `post ` reaches it as exact `post`;
- `bass pl` reaches it as exact `bass` + prefix `pl`;
- `is:saved` is structurally recognized without corrupting message-text intent;
- raw input does not need to be reconstructed downstream;
- repository-side message-text parsing no longer uses `normalizeMessageTagValue`;
- existing AND/OR plumbing remains unchanged;
- existing saved/tag behaviour remains passing.

Where appropriate, use test doubles/fakes to capture the exact structured value arriving at the repository boundary rather than inferring it indirectly from current `LIKE` result behaviour.

Do **not** write tests falsely claiming exact/prefix result semantics are already implemented. Those belong to the FTS stage.

## Regression coverage

Run:

- Stage 1 parser tests;
- `SearchService` tests;
- graph-search repository tests;
- directly affected saved/tag search tests;
- any other focused suites required by changed contracts.

Run scoped analysis and formatting according to project conventions.

## Scope constraints

Do not modify:

- graph schema version;
- FTS/database migration;
- message projection;
- import pipeline;
- presentation search controllers;
- global/contact/handle/recovered UI state;
- highlighting;
- result ordering;
- 10,000-result ceiling;
- release metadata.

Generated files may be regenerated if a changed provider/interface genuinely requires it, but avoid provider/UI signature work that belongs to a later stage.

## Deliverable

Report:

1. Files changed
2. Old parsing/normalization logic removed
3. New `SearchService` flow
4. Repository contract change
5. How exact/prefix token identity survives to the persistence boundary
6. `is:saved` handling
7. Any tag or metadata behaviour intentionally left unchanged
8. Tests added/updated
9. Tests and analysis run
10. Temporary limitations that remain because SQL is still `LIKE`
11. Git status
12. Recommended Stage 3 boundary

Do not proceed to FTS5, schema migration, UI/controller changes, or highlighting after completing this stage.

If this comes back clean, **Stage Three is where the project becomes materially riskier**: FTS5 capability characterization, tokenizer behaviour, schema v3, synchronization triggers, and backfill. I’d keep all of that together because the index and its lifecycle really need to be validated as one coherent unit.
