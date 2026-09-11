---
tier: feature
scope: search-semantics
owner: agent-per-project
last_reviewed: 2026-09-11
source_of_truth: doc
links:
  - ./CHARTER.md
  - ./DOMAIN_AND_DATA_MAP.md
  - ../../45-NEW-FEATURE-ADDITION/30-SEARCH-ENHANCEMENT/04-DEFERRED-LINK-PREVIEW-SEARCH.md
tests:
  - test/essentials/search/application/message_text_search_query_test.dart
  - test/essentials/conversation_graph/infrastructure/message_text_fts_runtime_test.dart
  - test/essentials/search/infrastructure/repositories/graph_search_repository_test.dart
feature: search
doc_type: behavior-contract
status: current
last_updated: 2026-09-11
---

# Message Search Semantics

This document is the authoritative contract for ordinary message search.

## Raw Input And Term Completion

The editable query remains exactly as entered. Parsing must not trim or rewrite
the field value, and the first typed trailing space must remain visible.

Whitespace completes the preceding token:

| Input | Meaning |
| --- | --- |
| `p` | Unfinished one-character token; do not run a broad text search. |
| `p␠` | Completed exact token `p`. |
| `po` | Word-initial prefix `po*`. |
| `post` | Word-initial prefix `post*`. |
| `post␠` | Completed exact token `post`. |

An unfinished token of two or more characters uses word-initial prefix
matching. A whitespace-completed token uses exact token matching, including a
one-character token. Prefix matching never means arbitrary internal substring
matching: `post` can match `postmaster`, while it does not match `riposte`.

## Search Domains And Restrictions

For every ordinary parsed term, current matching evidence is:

```text
termHits(term) = visibleMessageTextHits(term) UNION messageTagHits(term)
```

- `message_text_fts` indexes visible `messages.text` only.
- GUIDs, sender values, semantic kind, item kind, and other hidden message
  metadata are not ordinary message-text evidence.
- Message tags are a separate overlay-owned search domain.
- `is:saved` is a filter, not a boolean alternative.
- Conversation, contact, handle, and other selected scopes are mandatory
  restrictions.

## AND And OR

- AND means **Match all terms**.
- OR means **Match any term**.

Each term can be satisfied by either visible message text or any tag belonging
to that message. Separate tags can satisfy separate terms in AND mode. After
term composition, saved and scope restrictions are applied, results are ordered
newest first, and only then is the final 500-result limit applied.

Typing the literal words `AND` or `OR` in the query field searches for those
words. Boolean mode is selected by the adjacent controls.

## Presentation

Highlighting consumes the same structured execution intent as search. Prefix
queries highlight matching token prefixes; completed terms highlight exact
tokens only. Result membership and displayed counts must derive from the same
completed search result.

## Deferred Link-Preview Domain

Apple-stored link-preview metadata appears useful, but it is not currently a
search domain. Future work must validate representative payload fixtures first,
remain offline, and use a separate `message_link_fts`-style domain rather than
widening `message_text_fts`. See the linked deferred audit note.
