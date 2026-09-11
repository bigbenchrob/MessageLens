Stage 5 audit is complete. No files were modified.

The branch is `feature/message-text-search` at `7458a604`. The only working-tree entries remain the two protected untracked paths:

- `.vscode/settings.json`
- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/30-SEARCH-ENHANCEMENT/`

## 1. Current AND/OR architecture

The normal graph-message search path is:

```text
raw editor text
  → MessageTextSearchQuery.parse
  → structured exact/prefix tokens + is:saved flag
  → MessageEvidenceSearchMode
  → SearchMode / matchAnyTerm
  → graph search repository
  → FTS message IDs + tag message IDs
  → domain-level union
  → optional saved intersection
  → timeline skeleton filtering
```

Key boundaries:

- The parser preserves raw input and produces structured tokens in [message_text_search_query.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/application/message_text_search_query.dart:17).
- The presentation mode is `allTerms` or `anyTerm` in [message_evidence_search_mode.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/domain/message_evidence/message_evidence_search_mode.dart:1).
- `SearchService` converts that to `matchAnyTerm` and passes the same structured tokens to the repository in [search_service.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/application/search_service.dart:25).
- The actual domain composition occurs in [graph_search_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/infrastructure/repositories/graph_search_repository.dart:18).
- Result IDs are normally used as a membership set against an existing chronological timeline in [message_evidence_skeleton.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/domain/message_evidence/message_evidence_skeleton.dart:56).

The search box does not parse user-written boolean syntax. Typing `AND` or `OR` in the box searches for those literal words. Boolean mode comes only from the adjacent controls.

## 2. Exact current behavior

For normal graph messages, the effective calculation is:

```text
textResults =
  messages whose FTS text satisfies ALL/ANY tokens

tagResults =
  messages having one individual tag value that satisfies ALL/ANY tokens

results =
  tagResults UNION textResults

if is:saved:
  results = results INTERSECT savedMessages
```

In AND mode, that is effectively:

```text
(text contains ALL terms)
OR
(one tag contains ALL terms)
```

It is not:

```text
for EACH term:
  text OR any tag may satisfy that term
```

There is an additional tag limitation: separate tags on the same message cannot currently collaborate. A message tagged separately with `tax` and `urgent` does not satisfy AND search `tax urgent ` because each tag row is evaluated against the entire query.

OR mode is already algebraically equivalent to the desired behavior, before cap/order effects:

```text
text(A) OR text(B) OR tag(A) OR tag(B)
```

## 3. Search-domain classification

| Evidence or constraint | Classification | Current behavior |
|---|---|---|
| `messages.text` through `message_text_fts` | Term-matching domain | FTS5 exact/prefix matching |
| `message_intent_tags` | Term-matching domain | Current message-ID-keyed overlay tags |
| `message_user_tags` | Term-matching domain | GUID-keyed compatibility tags; ambiguous GUIDs are rejected |
| `is:saved` | Filter | Removed from ordinary tokens and intersected after term matching |
| Global/conversation/contact/handle | Scope constraint | Applied through graph relationships |
| Conversation excerpt | Scope constraint | Global matches are intersected with excerpt membership |
| Conversation tags | Not participating | They are not message-search evidence |
| GUID, sender, semantic kind, item kind | Not participating in normal search | Older reader methods can search them, but the active search-box path does not call those methods |
| Attachments/filenames | Not participating in normal search | No normal graph-message search domain |
| Link-preview metadata | Not implemented | No participation |
| Recovered-message metadata | Recovered-only term evidence | See below |

The FTS table contains only `text`, as established in [conversation_graph_database.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart:110).

Recovered-message search is different. It combines these fields into one local searchable string:

- sender label;
- contact name;
- service;
- item type;
- semantic kind;
- message text;
- attachment transfer name.

It then applies exact/prefix AND/OR through [message_text_search_matching.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/application/message_text_search_matching.dart:77). It does not use FTS or tags.

## 4. Cross-domain AND behavior

For the example:

```text
message text: invoice from accountant
tag: tax
query: invoice tax
```

The parsed tokens are:

- exact `invoice`;
- prefix `tax`.

Current AND result: excluded.

Why:

- FTS rejects it because `tax` is absent from the message text.
- Tag search rejects it because the `tax` tag does not also contain `invoice`.
- The repository then unions two empty results.

The mismatch arises at:

- separate whole-query text search;
- separate whole-query tag search;
- union at [graph_search_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/infrastructure/repositories/graph_search_repository.dart:30).

The same failure occurs when two terms are distributed across two separate tags.

## 5. Cross-domain OR behavior

For the same example, current OR includes the message:

- FTS satisfies `invoice`; and
- tag search satisfies `tax`;
- either is sufficient.

Therefore, current OR has the intended membership algebra for ordinary-sized result sets.

It can still lose valid results because each domain is capped before the final union and tags are merged before text. A sufficiently large tag result can consume the 500-result budget and exclude newer text-only matches.

## 6. `is:saved` behavior

The parser recognizes `is:saved` case-insensitively in any token position and removes it from the ordinary token list.

Normal graph behavior is correctly filter-like:

```text
ordinary boolean result
AND saved
```

The AND/OR mode never turns `is:saved` into an alternative ordinary term. Saved-only search also works and is mode-independent.

There are two conflicts:

1. Term results are capped before saved filtering. A saved message outside the initial 500 ordinary matches can be lost rather than becoming part of the newest 500 saved matches.
2. Recovered-message search explicitly returns no matches whenever `filterSaved` is true in [message_evidence_spine_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart:887). Thus `is:saved` excludes every recovered message, including saved-only searches.

The repository does not establish whether recovered messages are intended to support overlay saving, so that product decision remains unresolved.

## 7. Duplicate, ordering, and cap behavior

Deduplication is sound:

- duplicate tag rows resolve to one message ID;
- graph-native and GUID-keyed tag hits are deduplicated;
- text/tag duplicates are removed by `_mergeIds`;
- timeline filtering converts IDs to a set again.

A message matching the same term in both text and tags appears once.

Ordering and capping are less sound:

- FTS text results are scoped, sorted newest-first, and capped at 500.
- Tag candidates are initially ranked by match score and message ID, merged and capped, then scoped and date-sorted.
- Saved candidates are merged and capped before scope/date ordering.
- Final composition puts tag results before text results and stops at 500.
- Saved filtering happens after that cap.

Consequences:

- The final repository list is not necessarily globally newest-first across domains.
- The final 500 are not necessarily the newest 500 qualifying messages.
- Scoped tag/saved searches can miss valid results because global candidates are capped before scope filtering.
- Saved searches can return fewer than 500 despite additional qualifying saved messages existing beyond the preliminary cap.

The visible timeline subsequently discards repository ranking and preserves its normal oldest-to-newest conversation ordering, initially positioned at the latest result. That chronological UI behavior is intentional; “newest-first” should therefore be interpreted as result selection and repository ordering, not row rendering direction.

## 8. Scope behavior

Boolean satisfaction is message-level. No ordinary search combines term A from one message with term B from another message.

Current scopes are:

- conversation: message belongs to the selected chat;
- handle: message sender resolves to the selected canonical handle;
- contact: message belongs to a chat associated with one of the contact’s canonical handles;
- global: unrestricted graph messages.

Scope predicates are defined in [graph_search_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/infrastructure/repositories/graph_search_repository.dart:265).

Nuances:

- Contact scope is chat participation, not strictly “this contact was the sender.”
- Tag/saved candidates are scoped after preliminary global collection and capping.
- Conversation-excerpt search obtains globally capped matches and then intersects them with the excerpt. An excerpt match can therefore be missed if it falls outside the newest 500 global matches.
- `ContactMessageSearchEvidenceScope` always requests AND internally, but it is currently only used in provider tests; the interactive contact view uses the selectable mode correctly.

There is also a display integration defect: both [handle_messages_evidence_view.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/presentation/view/handle_messages_evidence_view.dart:75) and [handle_lens_view.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/presentation/view/handle_lens_view.dart:340) calculate matching IDs and counts but pass the unfiltered full skeleton to the timeline. Their AND/OR controls therefore change the count but do not actually hide nonmatching messages.

## 9. Existing UI wording

The shared control displays only:

- `AND`
- `OR`

in [message_evidence_header.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart:575).

There are currently:

- no tooltips;
- no “Match all terms” / “Match any term” explanations;
- no explicit button semantics, selected-state accessibility description, or keyboard-specific control behavior;
- no mode-specific result description.

Several status lines say:

```text
Message text contains "…"
```

That is inaccurate for normal results matched through tags and for recovered results matched through metadata or attachment names. The count and empty-result wording—“messages match…”—is appropriately domain-neutral.

AND/OR remain visible for empty and single-term queries. For a single term they are redundant, but leaving them visible is reasonable: it avoids layout movement and preserves the selected mode as the user types a second term.

## 10. Existing test coverage

| Scenario | Coverage |
|---|---|
| AND text/text | Yes |
| OR text/text | Yes |
| Exact + prefix under both modes | Yes, same text/text test |
| Single graph-native tag | Yes |
| AND tag/tag | No |
| OR tag/tag | No |
| AND text/tag | No |
| OR text/tag | No direct multi-term test |
| Saved filtering with AND | Partial: one ordinary term |
| Saved filtering with OR | No |
| Duplicate text/tag match | No |
| Scoped multi-term boolean search | No |
| Text ordering and 500 cap | Yes |
| Cross-domain ordering/cap | No |
| UI AND/OR callback | Yes |
| Service propagation of OR | Yes |
| Recovered exact/prefix | Yes |
| Recovered multi-term AND/OR | No |
| Handle view result filtering | No |

The principal backend AND/OR test is [graph_search_repository_test.dart](/Users/rob/Development/FlutterProjects/remember_every_text/test/essentials/search/infrastructure/repositories/graph_search_repository_test.dart:295).

## 11. Missing behavioral matrix

Using:

```text
M1: text="invoice accountant", tag=tax, saved=true
M2: text="invoice", tag=personal
M3: text="holiday", tag=tax
M4: text="unrelated", tags=[tax, urgent]
```

| Query | Mode | Current | Recommended |
|---|---|---|---|
| `invoice` | AND | M1, M2 | M1, M2 |
| `invoice` | OR | M1, M2 | M1, M2 |
| `invoice accountant ` | AND | M1 | M1 |
| `invoice accountant ` | OR | M1, M2 | M1, M2 |
| `invoice tax` | AND | none | M1 |
| `invoice tax` | OR | M1, M2, M3, M4 | same |
| `tax urgent ` | AND | none | M4 |
| `tax urgent ` | OR | M1, M3, M4 | same |
| `invoice tax is:saved` | AND | none | M1 |
| `invoice tax is:saved` | OR | M1 | M1 |

`invoice tax` retains the existing structured meaning: exact `invoice`, active prefix `tax`. A trailing space would make both tokens exact.

## 12. Recommended user-facing AND semantics

> AND — Match all terms.

Every ordinary query token must be satisfied by at least one participating term domain on the same message.

That permits:

- all terms in text;
- all terms in tags;
- terms spread across separate tags;
- text/tag combinations;
- future text/tag/link-preview combinations.

Filters such as `is:saved` and scope constraints remain mandatory restrictions outside this boolean choice.

## 13. Recommended user-facing OR semantics

> OR — Match any term.

A message qualifies if any ordinary query token matches any participating term domain.

This largely preserves current OR membership semantics while correcting cap, ordering, saved-filter, and scoped-candidate artifacts.

## 14. Recommended internal composition model

Use term-first composition:

```text
termHits(term) =
  textHits(term)
  UNION tagHits(term)
  UNION futureDomainHits(term)

ordinaryHits =
  AND mode: intersection of every termHits set
  OR mode:  union of every termHits set

qualifiedHits =
  ordinaryHits
  INTERSECT scope
  INTERSECT savedHits when is:saved is present

results =
  newest 500 qualified message IDs
```

Each term’s domain union must be deduplicated before AND counting. Otherwise one term matching both text and tags could incorrectly count as two satisfied terms.

No participating domain should apply the final 500 cap independently.

## 15. Future link-preview accommodation

A future Apple-stored link-preview domain becomes one more contributor to `termHits(term)`:

```text
termHits(term) =
  textHits(term)
  UNION tagHits(term)
  UNION linkPreviewHits(term)
```

Nothing about AND, OR, saved filtering, scoping, or deduplication changes. No crawling or network retrieval is needed.

## 16. Exact proposed edit scope

Core boolean work:

- [graph_search_repository.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/search/infrastructure/repositories/graph_search_repository.dart:18)
- [graph_search_repository_test.dart](/Users/rob/Development/FlutterProjects/remember_every_text/test/essentials/search/infrastructure/repositories/graph_search_repository_test.dart:295)

Display correctness discovered by this audit:

- `handle_messages_evidence_view.dart` and its widget test
- `handle_lens_view.dart` and its widget test

Domain-neutral wording/accessibility:

- `message_evidence_header.dart` and its test
- the existing one-line “Message text contains…” producers in global, conversation, contact, handle, Handle Lens, and recovered presentations
- their existing presentation/widget tests where applicable

Expected not to change:

- parser or token classes;
- FTS schema, tokenizer, triggers, or schema version;
- search-service contract;
- overlay schema or writes;
- import/onboarding/intake code;
- highlighting;
- link-preview work;
- release metadata until the final close-out stage.

## 17. Risks and invariants

Hard invariants:

- Preserve exact versus prefix token objects without converting back to substring queries.
- `is:saved` remains a filter.
- Scope remains message-level.
- A message appears at most once.
- Apply the 500 cap only after boolean composition, scope, and filters.
- Preserve newest-first final candidate selection.
- Do not change FTS or overlay storage.
- Do not join or dual-write graph and overlay databases.
- Do not add link-preview or network behavior.

Primary implementation risk: per-term searches can produce large candidate sets, especially for two-character prefixes. Correctness forbids blindly limiting each term to 500, because the 501st match for a common term could be the newest message satisfying all terms. Final ordering must also avoid exceeding SQLite parameter limits when sorting a large composed ID set.

Assumptions not established from the repository:

- Whether recovered messages are intended to participate in `is:saved`.
- Whether tag relevance scoring should have any product effect beyond breaking ties before the current cap; the UI currently discards that order.
- Whether the stated newest-first contract refers specifically to repository selection, as the visible timeline is deliberately chronological.

## 18. Minimal implementation sequence

1. Add failing repository matrix tests for text/tag AND, separate-tag AND, OR, saved under both modes, deduplication, scope, and final cap/order.
2. Refactor repository composition to union domains per structured token, then intersect or union across tokens.
3. Move saved filtering, scope completion, canonical date ordering, and the 500 cap to the end.
4. Fix the two handle views so calculated match IDs filter the displayed skeleton.
5. Add `Match all terms` / `Match any term` tooltip and accessibility wording; replace domain-specific “Message text contains…” status text.
6. Run focused search/provider/view tests, architecture tests, and `flutter analyze`; manually verify the fixture matrix.

The core diagnosis is confirmed: current AND exposes storage domains. The appropriate correction is “OR across domains for each term, then AND or OR across the terms.”