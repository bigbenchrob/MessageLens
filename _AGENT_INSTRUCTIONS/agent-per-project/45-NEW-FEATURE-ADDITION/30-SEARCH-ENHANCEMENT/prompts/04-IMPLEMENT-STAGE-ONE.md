Absolutely.



Please implement **Stage 1 only** of the message-text search redesign: the structured query model/parser and its focused tests.

Do **not** add FTS5 yet.
Do **not** change database schema.
Do **not** alter repository SQL.
Do **not** change UI/controller behaviour yet.
Do **not** redesign AND/OR.

The goal of this stage is to make the intended search semantics explicit, testable, and reusable before any persistence or UI integration work begins.

## Branch

Work only on:

`feature/message-text-search`

Before editing, confirm the branch and inspect `git status`.

Preserve unrelated untracked work, especially:

- `.vscode/settings.json`
- `30-SEARCH-ENHANCEMENT/`

Do not modify, delete, stage, or commit those unless they are already intentionally part of the search documentation workflow.

## Desired architecture

Introduce an application/domain-level representation of parsed message-text search intent.

The exact filenames and class names may follow existing project conventions, but conceptually we need something equivalent to:

```dart
final class MessageTextSearchQuery {
  final String rawInput;
  final List<MessageTextSearchToken> tokens;
  final bool hasTrailingWhitespace;
}
```

with token semantics equivalent to:

```dart
sealed class MessageTextSearchToken {
  String get normalizedText;
}

final class ExactMessageTextToken extends MessageTextSearchToken {}

final class PrefixMessageTextToken extends MessageTextSearchToken {}
```

Do not treat those exact names or shapes as mandatory if there is a cleaner fit with existing project conventions.

The important requirement is that downstream code can distinguish:

- exact completed tokens;
- active prefix tokens;
- raw user input;
- trailing-whitespace completion state.

## Required semantics

### Empty input

`''`

and whitespace-only input should produce no message-text search tokens.

Raw input must still be preserved exactly.

### One-character unfinished token

Input:

`p`

should produce no executable broad message-text prefix token.

We do not want a one-character active prefix to search the whole archive.

The parser should nevertheless preserve enough state that the UI/search layer can understand the raw input if needed.

### Completed one-character token

Input:

`p `

should produce:

- exact token `p`

The trailing whitespace means the user has explicitly completed the token.

### Two-or-more-character unfinished token

Input:

`po`

should produce:

- prefix token `po`

Likewise:

`post`

should produce:

- prefix token `post`

This means "word beginning with `post`", not arbitrary substring matching.

### Completed token

Input:

`post `

should produce:

- exact token `post`

The query parser is not responsible for deciding punctuation boundaries inside stored message text. That will later be handled by the document tokenizer/search backend.

### Multiple tokens

Input:

`bass pl`

should produce:

- exact token `bass`
- prefix token `pl`

Input:

`bass player `

should produce:

- exact token `bass`
- exact token `player`

All non-final tokens are complete by virtue of a separator following them.

The final token is:

- exact if raw input ends with whitespace;
- prefix if raw input does not end with whitespace and its normalized length is at least two;
- ignored for broad text search if it is an unfinished one-character token.

## Whitespace

Treat ordinary whitespace consistently, including:

- spaces;
- repeated spaces;
- tabs;
- newlines.

Any whitespace after a token marks that token as complete.

Do not collapse or reconstruct the raw input field.

## Raw input invariant

The parser must preserve the exact raw input string it receives.

For example:

```text
"bass   pl"
```

must remain available as exactly:

```text
"bass   pl"
```

even if parsed token semantics normalize the separators.

Do not use parsed/normalized text as a replacement for UI input state.

This distinction is foundational to fixing the disappearing-space bug later.

## Normalization

Please investigate and reuse appropriate existing normalization infrastructure where it genuinely applies, but do **not** make the existing tag normalizer authoritative for message-text tokenization merely because it is available.

The previous audit found that the tag normalizer:

- lowercases;
- folds some diacritics;
- converts punctuation;
- changes hyphens into spaces.

That was designed for tags, not message-text search.

For this stage, normalization should be deliberately minimal and compatible with future `unicode61` FTS tokenization.

At minimum:

- case-insensitive matching must remain possible;
- do not accidentally introduce stemming;
- do not turn arbitrary punctuation into user-visible query syntax;
- do not prematurely invent custom document-token rules.

If exact Unicode/diacritic normalization should live in the FTS layer rather than this parser, keep the parser correspondingly simple and explain that choice.

## `is:saved`

Preserve the existing `is:saved` behaviour, but parse it structurally rather than destructively rewriting the raw input.

For example:

`invoice is:saved`

should expose:

- message-text token intent for `invoice`;
- saved-message filter intent;
- unchanged raw input.

Likewise test `is:saved` in different token positions if current behaviour allows it.

Do not redesign the saved filter in this pass.

## FTS-special characters

Although FTS is not being implemented yet, the parser/model must not encourage raw user input to become future FTS syntax.

Inputs containing characters such as:

- `"`
- `*`
- `-`
- `(`
- `)`
- `:`

should remain ordinary user input at this layer unless an already-supported operator such as `is:saved` is explicitly recognized.

Do not implement wildcard syntax.

Do not implement phrase syntax.

Do not implement exclusions.

## AND/OR

Leave `MessageEvidenceSearchMode` behaviour unchanged.

Do not redesign how tokens are combined.

The structured token model should simply make it possible for the later boolean layer to consume exact and prefix tokens correctly.

## Tests

Add focused parser/domain tests covering at least:

```text
''                  → no text tokens
'   '               → no text tokens
'p'                 → no executable prefix token
'p '                → exact p
'po'                → prefix po
'post'              → prefix post
'post '             → exact post
'bass pl'           → exact bass + prefix pl
'bass player '      → exact bass + exact player
```

Also cover:

- repeated spaces;
- leading whitespace;
- tabs;
- newlines;
- final tab/newline completion;
- mixed case;
- raw-input preservation;
- one-character tokens in non-final positions;
- `is:saved`;
- `is:saved` extraction without mutating raw input;
- FTS-special punctuation remaining ordinary input;
- any normalization assumptions made by the implementation.

Include tests proving that:

`post`

and:

`post `

produce distinct parsed intent.

That distinction must never be lost through equality, hashing, provider identity, or future caching.

## Reuse and placement

Before creating new files, inspect:

- `lib/essentials/search/domain/`
- `lib/essentials/search/application/`
- existing search-domain types;
- Freezed/value-object conventions;
- Riverpod/provider equality requirements;
- current `SearchService` token handling.

Reuse project conventions rather than creating a parallel style.

However, do not force this model into an unsuitable existing tag-specific abstraction.

## Scope constraints

This stage should not modify:

- `conversation_graph_database.dart`;
- graph schema version;
- migration code;
- message projection;
- FTS tables;
- graph repository SQL;
- highlighting;
- search-field controllers;
- presentation providers;
- result ordering;
- the 10,000-result limit;
- AND/OR behaviour.

If implementing the parser absolutely requires touching an existing search service file for extraction/reuse, keep that change narrowly scoped and explain why.

## Validation

Run the focused new tests plus any directly affected existing search tests.

Also run static analysis on the changed scope if consistent with project workflow.

Do not perform broad unrelated cleanup.

## Deliverable

Report:

1. Files changed
2. Query model introduced
3. Exact parsing rules implemented
4. Normalization choices
5. `is:saved` handling
6. Tests added
7. Tests run and results
8. Any assumptions or unresolved product decisions
9. `git status`
10. Recommended Stage 2 boundary

Do not proceed into FTS5 implementation after completing this stage.

This gives Codex a very narrow first implementation target while locking in the behaviour we actually care about before the database work starts.