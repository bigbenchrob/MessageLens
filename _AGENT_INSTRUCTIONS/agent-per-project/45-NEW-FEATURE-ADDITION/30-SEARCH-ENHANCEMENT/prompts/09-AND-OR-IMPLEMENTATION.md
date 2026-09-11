
Please implement Stage 5 according to the completed read-only AND/OR audit.
The audit’s recommended product semantics are approved.
# Core product rule
### The AND/OR controls describe the relationship amongthe search terms the user entered, not the relationship among MessageLens’s internal storage/search domains.
For every ordinary structured query token:
### termHits(term) =
###     textHits(term)
###     UNION tagHits(term)
###     UNION futureSearchDomainHits(term)
### Then:
### AND:
###     intersection of termHits for every ordinary token

### OR:
###     union of termHits for every ordinary token
### After ordinary boolean composition:
### qualifiedHits =
###     ordinaryHits
###     INTERSECT applicable message scope
###     INTERSECT savedHits when is:saved is present

### results =
###     newest 500 qualified message IDs
### This is the authoritative model for Stage 5.
### Do not preserve the current domain-first AND behavior.
# Required examples
### Given:
### M1: text="invoice accountant", tag=tax, saved=true
### M2: text="invoice", tag=personal
### M3: text="holiday", tag=tax
### M4: text="unrelated", tags=[tax, urgent]
### the following must hold:
| Query | Mode | Expected |
|:-:|:-:|:-:|
| invoice | AND | M1, M2 |
| invoice | OR | M1, M2 |
| invoice accountant  | AND | M1 |
| invoice accountant  | OR | M1, M2 |
| invoice tax | AND | M1 |
| invoice tax | OR | M1, M2, M3, M4 |
| tax urgent  | AND | M4 |
| tax urgent  | OR | M1, M3, M4 |
| invoice tax is:saved | AND | M1 |
| invoice tax is:saved | OR | M1 |
Remember that existing exact/prefix semantics remain authoritative. For example, in invoice tax, invoice is complete/exact while final tax remains an active prefix unless followed by whitespace.
# Per-term cross-domain composition
### Refactor the graph-search repository so each structured token is independently evaluated against all participating ordinary term domains.
### Currently these are:
* FTS message text;
* message tags.

⠀A term matching both domains must still count as satisfying only one query term.
Deduplicate each term’s message-ID set before boolean composition.
Do not require all terms to occur:
* entirely within text;
* within one tag;
* or even within the same search domain.

⠀Thus a message can satisfy AND through:
* all terms in text;
* all terms in tags;
* terms distributed among separate tags;
* some terms in text and others in tags.

⠀Each resulting message itself must satisfy the query. Never combine evidence from different messages.
# Preserve structured tokens
### Do not flattenExactMessageTextSearchToken and PrefixMessageTextSearchToken back into generic strings or substring queries.
The Stage 1–4 exact/prefix behavior must remain unchanged.
Examples:
### post → prefix
### post→ exact
### bass tax → exact bass + prefix tax
AND/OR merely combines the resulting predicates.
# is:saved
### Keepis:saved outside ordinary boolean terms.
It remains a mandatory filter regardless of selected mode:
### ordinary boolean result
### AND saved
### Thus OR must never mean:
### invoice OR saved
### forinvoice is:saved.
Saved-only search must continue to work.
Do not resolve recovered-message saved semantics in this stage; the audit could not establish the intended product behavior. Preserve current recovered behavior and document that unresolved question.
# Scope
### Apply the applicable graph scope as a mandatory restriction:
* global;
* conversation;
* contact;
* handle;
* other existing graph scopes.

⠀Boolean satisfaction remains message-level.
Do not allow terms from:
* another message;
* another conversation outside scope;
* another contact/handle outside scope

⠀to collaborate in satisfying an AND query.
# Correct the 500-result composition
### The audit found that domain-specific and overlay candidate caps currently cause correctness failures.
### Correct this as part of Stage 5.
### The final 500-result cap must be appliedafter:
1. per-term domain union;
2. AND/OR composition across terms;
3. deduplication;
4. applicable scope;
5. is:saved filtering;
6. canonical date ordering.

⠀The final candidate selection must represent the newest 500 messages that actually satisfy the complete query.
Do not allow:
* tag results to consume the budget before text results;
* text results to consume the budget before tag results;
* unsaved results to consume the budget before saved filtering;
* out-of-scope results to consume the budget before scope filtering.

⠀Preserve canonical final ordering:
### date_utc DESC, then ss_id DESC
unless inspection of the current contract establishes a more authoritative equivalent.
The visible timeline may subsequently render those selected messages chronologically; do not alter that presentation behavior.
# Performance/correctness constraint
### Do not solve the final-cap problem simply by replacing each preliminary 500 cap with an arbitrary larger cap.
### Correctness requires that an otherwise valid result not disappear merely because it was the 501st candidate for one common term/domain.
### Design the composition so the final cap applies toqualified results.
Be mindful of:
* large two-character prefix result sets;
* SQLite parameter limits;
* large in-memory ID sets.

⠀Prefer an architecture that remains correct before optimizing it.
If the clean implementation requires a substantially different query/composition strategy than the audit anticipated, stop and explain before introducing a major new subsystem.
# Handle Messages / Handle Lens display defect
### Fix the two display integration defects identified by the audit:
* handle_messages_evidence_view.dart
* handle_lens_view.dart

⠀Both currently calculate matching IDs/counts but pass an unfiltered full skeleton to the timeline.
After this stage, the displayed timeline must actually reflect the calculated search matches.
Add focused widget tests proving that:
* nonmatching messages disappear from the displayed evidence;
* changing AND/OR changes displayed membership when appropriate;
* displayed count and displayed result set agree.

⠀Reuse existing filtered-skeleton behavior used by other message-search surfaces where possible rather than inventing another filtering mechanism.
# AND/OR UI wording
### Keep the visible controls compact:
### AND
### OR
Add appropriate tooltip/accessibility semantics:
* AND → Match all terms
* OR → Match any term

⠀Do not hide the controls for single-term queries. Their equivalence for one term is harmless, keeping them visible avoids layout movement, and the selected mode can persist as the user continues typing.
# Domain-neutral status wording
### The audit found status text such as:
### Message text contains "…"
This is no longer accurate because ordinary search can also match tags, and recovered search can match additional evidence.
Replace such wording with concise domain-neutral language consistent with existing UI style.
Prefer wording such as:
### Messages matching "…"
or the closest grammatically appropriate existing pattern.
Do not expose internal concepts such as FTS, tags-as-domain, unions, or search evidence domains to ordinary users.
# Tests first
### Before refactoring, add failing tests for the approved behavioral matrix.
### Cover at minimum:
* AND text/text;
* OR text/text;
* AND text/tag;
* OR text/tag;
* AND across two separate tags;
* OR across separate tags;
* exact + prefix combinations;
* duplicate match in text and tag;
* saved filtering under AND;
* saved filtering under OR;
* saved-only behavior;
* scoped multi-term searches;
* final newest-500 selection across domains;
* scope before final cap;
* saved filtering before final cap;
* Handle Messages actual filtering;
* Handle Lens actual filtering.

⠀Preserve existing Stage 1–4 regression coverage.
# Future link-preview invariant
### Do not implement link-preview search now.
### However, the composition architecture must permit a future Apple-stored link-preview domain to become simply another contributor:
### termHits(term) =
###     textHits(term)
###     UNION tagHits(term)
###     UNION linkPreviewHits(term)
### Adding that domain later should not require redesigning AND/OR semantics.
### Do not fetch or crawl URLs.
# Do not change
### Stage 5 must not change:
* query parser/token classes except where absolutely required by a discovered correctness issue;
* FTS schema;
* FTS tokenizer;
* FTS triggers;
* graph schema version;
* import/onboarding/intake;
* overlay storage schema;
* highlighting semantics;
* exact/prefix semantics;
* wildcard or phrase syntax;
* link-preview indexing;
* release metadata.

⠀Validation
### Run:
* parser tests;
* SearchService tests;
* graph-search repository tests;
* FTS runtime/repository tests;
* saved/tag tests;
* affected provider tests;
* Handle Messages tests;
* Handle Lens tests;
* shared AND/OR control tests;
* relevant presentation tests;
* architecture tripwires;
* flutter analyze;
* git diff --check.

⠀If feasible with repository fixtures, add a stress/correctness test proving that valid cross-domain or saved/scoped results beyond a preliminary 500 candidates are no longer lost.
Do not use private production data merely for performance testing.
# Deliverable
### Report:
1. Files changed
2. Boolean composition implementation
3. Per-term domain union behavior
4. AND behavior
5. OR behavior
6. Separate-tag AND behavior
7. is:saved behavior
8. Scope behavior
9. Deduplication
10. Ordering and final-500 behavior
11. How preliminary-cap correctness defects were removed
12. Handle Messages display fix
13. Handle Lens display fix
14. Tooltip/accessibility changes
15. Domain-neutral status wording
16. Tests added/updated
17. Validation results
18. Any performance implications
19. Remaining unresolved questions
20. git status
21. Recommended final close-out stage

⠀Do not implement link-preview search or release metadata after completing this stage.
