

Please perform a **read-only Stage 5 audit** of MessageLens AND/OR search semantics.

Do not edit files yet.

Stages 1–4 have established:

- natural incremental search;
- unfinished terms as word-initial prefixes;
- whitespace-completed terms as exact tokens;
- FTS5-backed message-text search;
- preserved raw editor input;
- aligned highlighting;
- tags as a separate overlay-owned search domain;
- saved state as a separate overlay-owned filter.

We now need to make the AND/OR controls behave in the way an ordinary user would naturally expect.

Do not implement anything until the current behavior and desired product semantics have been compared explicitly.

## Branch

Work only on:

`feature/message-text-search`

Confirm branch and `git status`.

Stage 4 may have just been checkpoint-committed. Preserve unrelated untracked files, including:

- `.vscode/settings.json`
- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/30-SEARCH-ENHANCEMENT/`

Do not alter them during this audit.

# Product starting point

The search header presents AND and OR as user-facing boolean controls.

The natural interpretation appears to be:

### AND

Every entered search term must be satisfied by the message/searchable evidence.

### OR

At least one entered search term must be satisfied.

The user should not need to know which internal search domain supplied a match.

For example, suppose a message:

- contains the word `invoice` in message text;
- has the tag `tax`.

Then a search for:

`invoice tax`

in **AND** mode would naturally be expected to find that message even if:

- `invoice` matched message text;
- `tax` matched the tag.

Likewise, in **OR** mode, a message should qualify if either term is satisfied by an applicable searchable domain.

This is only the proposed product interpretation. First establish exactly what the current architecture does.

# Important distinction: terms versus domains

Please investigate whether the current implementation effectively calculates something like:

```text
(text contains ALL terms)
OR
(tags contain ALL terms)
```

rather than:

```text
for EACH term:
    term may be satisfied by text OR tag
```

If so, demonstrate this with concrete examples and identify precisely where that behavior arises.

For example, with:

```text
message text: "invoice from accountant"
tags: tax
query: "invoice tax"
```

determine whether current AND mode finds or excludes the message and why.

Do the corresponding analysis for OR.

# Exact/prefix semantics must remain intact

The Stage 1–4 token model is authoritative.

For example:

`bass tax`

contains:

- exact `bass` if followed by whitespace before `tax`;
- active prefix `tax` if it is the final unfinished token.

AND/OR must combine those structured token predicates without flattening them back into generic substring strings.

Do not reconsider exact/prefix semantics during this audit.

# Search domains to audit

Identify every domain currently participating in the search-box result calculation, including at least:

- FTS message text;
- tags;
- `is:saved`;
- any remaining metadata/search domains;
- scope constraints such as conversation/contact/handle.

For each, determine whether it is:

1. a **term-matching domain**;
2. a **filter**;
3. a **scope constraint**.

This distinction is important.

My initial expectation is:

- message text = term-matching domain;
- tags = term-matching domain;
- `is:saved` = filter;
- conversation/contact/handle restriction = scope;
- link-preview metadata, when implemented later = another term-matching domain.

Please verify rather than assume.

# `is:saved`

Audit how `is:saved` currently interacts with AND/OR.

My expectation is that `is:saved` should remain a **filter**, not an ordinary boolean search term.

Thus:

`invoice is:saved`

means roughly:

```text
search for invoice
AND restrict results to saved messages
```

regardless of whether the AND or OR button is selected.

Likewise, a saved-only search should continue to work.

Do not redesign `is:saved` unless the current implementation conflicts with that model; report any conflict.

# Single-term behavior

Verify explicitly that AND and OR are necessarily equivalent for a single ordinary search term.

If so, consider whether the UI should continue showing both controls unchanged during a one-term query or whether that is harmless enough to leave alone.

Do not change the UI in this audit.

# Multi-term AND

Evaluate the most intuitive rule:

> Every ordinary query token must match at least one participating term-matching domain for the same message.

Conceptually:

```text
AND over terms
    OR over searchable domains
```

For terms A and B across text and tags:

```text
(textMatches(A) OR tagMatches(A))
AND
(textMatches(B) OR tagMatches(B))
```

This would allow:

- A in text + B in text;
- A in tag + B in tag;
- A in text + B in tag;
- A in tag + B in text.

Determine whether this is technically clean with the existing architecture.

# Multi-term OR

Evaluate:

> A message qualifies if any ordinary query token matches any participating term-matching domain.

Conceptually:

```text
OR over terms
    OR over searchable domains
```

For A and B:

```text
textMatches(A)
OR tagMatches(A)
OR textMatches(B)
OR tagMatches(B)
```

Determine whether this differs materially from current behavior.

# Duplicate/cross-domain matches

Determine how result IDs are currently:

- unioned;
- intersected;
- deduplicated;
- ordered;
- capped.

Pay particular attention to a message that matches the same term in both text and tags.

No message should appear twice merely because two domains satisfied it.

Preserve newest-first ordering and the current 500-result contract unless the audit uncovers a correctness issue requiring discussion.

# Scope constraints

Verify that AND/OR operates **inside** the existing search scope.

For example, a contact-scoped search should not obtain an AND match by combining evidence from different messages or from messages outside that contact scope.

Each resulting message should individually satisfy the boolean query.

Explicitly confirm that boolean satisfaction is message-level, not conversation-level or result-set-level.

# Future extensibility

We have explicitly deferred a possible future searchable domain containing Apple-stored link-preview metadata.

Do not implement it now.

However, evaluate whether the proposed boolean architecture naturally supports adding another term-matching domain later:

```text
text
OR tag
OR link-preview metadata
```

for each term.

We should avoid an AND/OR implementation that has to be redesigned every time another searchable evidence domain is added.

# UI semantics

Audit:

- labels;
- tooltips;
- accessibility descriptions;
- status/result descriptions;
- any explanatory text associated with AND/OR.

Determine whether the current UI accurately describes actual behavior and whether wording should change if the proposed semantics are adopted.

The intended mental model should be explainable very simply:

**AND — Match all terms**

**OR — Match any term**

Users should not need to understand internal search domains.

Do not implement wording changes yet.

# Tests

Identify existing tests for:

- AND text/text;
- OR text/text;
- AND tag/tag;
- OR tag/tag;
- AND text/tag;
- OR text/tag;
- saved filtering with AND;
- saved filtering with OR;
- duplicate matches across domains;
- scoped boolean searches;
- exact/prefix terms under boolean combination.

Identify missing coverage.

Construct a proposed behavioral matrix using concrete fixtures such as:

```text
Message 1:
text = "invoice accountant"
tags = tax

Message 2:
text = "invoice"
tags = personal

Message 3:
text = "holiday"
tags = tax
```

Then show expected results for representative searches under AND and OR.

# Deliverable

Return:

1. Current AND/OR architecture
2. Exact current behavior
3. Search domains classified as term domain / filter / scope
4. Cross-domain AND behavior
5. Cross-domain OR behavior
6. `is:saved` behavior
7. Duplicate/result-order/cap behavior
8. Scope behavior
9. Existing UI wording
10. Existing test coverage
11. Missing test coverage
12. Recommended user-facing AND semantics
13. Recommended user-facing OR semantics
14. Recommended internal composition model
15. How that model accommodates future link-preview search
16. Exact proposed edit scope
17. Risks and invariants
18. Minimal implementation sequence

Explicitly flag any assumption that cannot be established from the repository.

Do not modify any files.

Once we get that response, I expect the actual implementation may be considerably smaller than Stages 3–4. The important thing is getting the algebra right: **AND/OR should describe the relationship among the words the user typed, not expose how MessageLens happens to store different kinds of searchable evidence.**