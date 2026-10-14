# MessageLens — Feature 34
## Response 105 — Checkpoint Graph Audit and Implement Disposable Production Graph Replay Feasibility Harness

**Date:** 2026-10-14

## 1. Outcome

Prompt 105 is complete. The Prompt 104 graph audit/design record was already checkpointed and pushed, and a test-only disposable replay harness now characterizes the actual production Conversation Graph writers against isolated production-schema ledger and graph databases.

This is feasibility evidence, not a populated reconstruction witness and not destructive eligibility. No production implementation, schema, generated source, provider, AppCzar jurisdiction, reset path, dependency, release metadata, or archive behavior changed.

## 2. Verified baseline and checkpoint sequence

Pre-edit state was verified as:

- repository: `/Users/rob/Development/FlutterProjects/remember_every_text`
- branch: `fix/onboarding-import-stuck-state`
- baseline HEAD: `7771b5c136646e3772b841304c72cdd05152394e`
- upstream: `origin/fix/onboarding-import-stuck-state`, synchronized `0 ahead / 0 behind`
- tracked worktree and index: clean
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- Feature 34 branch worktrees: exactly one
- source-only baseline SHA-256: `95a8d37b8045cef2b79bbe401cc544ae45ff333ca57fdedecab110f6a5c2b512`
- untracked inventory: 49 pre-existing entries, including Prompt 105; all unrelated entries were preserved

Prompt 104 and Response 104 were already committed together and pushed at:

`7771b5c136646e3772b841304c72cdd05152394e` — `docs(appczar): record graph reconstruction audit`

The eight source-projection implementations and the rich-text extraction ancestry, including `e340bdca0c6b8af9d40ab312a7f455d2fd9910db`, were verified before implementation. No duplicate documentation checkpoint was created.

The implementation checkpoint is:

`d364df01374abad9e1f8832fa04d70ed237715ff` — `test(graph): characterize production replay feasibility`

It contains only the two authorized test files and has been pushed.

## 3. Authorized files and production isolation

The implementation added only:

- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_harness.dart`
- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart`

The harness creates a unique directory whose name begins with `messagelens_production_graph_replay_`, then opens only:

- `<temporary-root>/ledger/import.db`
- `<temporary-root>/graph/conversation.db`

Both are real production-schema `ImportDatabase` and `ConversationGraphDatabase` files. Every path is checked to remain beneath the canonical temporary root. Explicit guards reject Messages, Application Support, and `/Volumes` paths. Database handles are closed and the unique root is deleted in `finally`, including test failures.

No app provider graph, native Messages/Contacts location, admitted MessageLens root, archive bookmark, external drive, attachment archive, overlay database, or real user content was opened. The application was not built or launched.

## 4. Actual production repositories and ordering

The harness directly constructs the existing public production repositories, with the disposable ledger and graph injected:

1. `SqliteHandleProjectionRepository`
2. `SqliteContactProjectionRepository`
3. `SqliteChatToHandleProjectionRepository`
4. `SqliteChatProjectionRepository`
5. `SqliteMessageProjectionRepository`
6. `SqliteAttachmentProjectionRepository`
7. `SqliteChatToMessageProjectionRepository`
8. `SqliteMessageToAttachmentProjectionRepository`

The full replay follows the production dependency order:

1. handles
2. local-account identity
3. contacts
4. chat-to-handle edges
5. chats
6. messages
7. attachments
8. chat-to-message edges
9. message-to-attachment edges

The incremental characterization calls only the existing incremental entry points for messages, attachments, chat-to-message, and message-to-attachment. No second transformation implementation or test-only production seam was introduced.

Historical removal uses the existing source-scoped graph removal service and its injected production repositories. It does not manually edit graph material.

## 5. Deterministic synthetic corpus and source binding

The bounded fixture uses fixed source-registry identities and deterministic source row IDs. Its full projection contains:

- 6 messages
- 5 handles
- 2 contacts
- 3 chats
- 3 attachments
- 6 chat-to-message edges
- 3 message-to-attachment edges

The fixture includes live Messages, live AddressBook, and historical source identities. It exercises:

- ambiguous normalized phone aliases and canonical alias preference
- an unnormalizable handle
- an injected local-account email identity
- competing contact channels
- one-to-one, group, and historical chats
- participant-derived group state and participant ordering
- text, null text, present rich text, associated-message GUID, and missing associated GUID cases
- duplicate raw relationship rows
- source-registry identity changes
- attachment and all three relationship projection families
- production FTS triggers and representative queries

Changing an otherwise identical historical source from one fixed registry identity to another changes the packed projected identities, confirming that registry binding materially participates in graph identity.

## 6. Complete material comparison boundary

Every replay snapshot reads full sorted material rows from all current graph tables:

- `messages`
- `message_text_fts`
- `handles`
- `canonical_handles`
- `handle_aliases`
- `chats`
- `chat_to_message`
- `chat_to_handle`
- `contacts`
- `contact_to_handle`
- `attachments`
- `message_to_attachment`

Test assertions compare deterministic maps bidirectionally and report missing keys, extra keys, and changed values. This comparator remains test-only and is not a production reconstruction witness or eligibility evaluator.

## 7. Characterized behavior

All eight focused cases passed and established the following current behavior:

1. **Empty replay:** the bounded source-scoped fixture projects through all actual repositories into an empty production-schema graph.
2. **Repeated replay:** a second full replay is materially identical for the bounded fixture.
3. **Stale populated state:** an existing stale contact name, stale chat `is_group` value, and an extra relationship edge survive replay. This confirms literal `INSERT OR IGNORE`/additive nonconvergence; the harness does not repair or hide it.
4. **Full versus incremental:** supported incremental message/attachment/edge entry points produce the same measured material as a full replay for the bounded appended portion.
5. **Historical removal/reprojection:** existing removal APIs remove the historical material and relevant edges, preserve the original source-registry rows, and reprojection restores the prior measured graph.
6. **Aliases and semantic references:** canonical alias preference, contact competition, local-account `is_me`, group classification, sender references, associated-message resolution, missing associated endpoints, rich-text result, and null-text preservation follow production behavior.
7. **Source-registry identity:** changing the fixed registry identity changes packed graph identities rather than silently preserving the old identity.
8. **Stage failure:** an injected stop after message projection leaves the earlier committed writer stages visible. The writers do not provide one global graph transaction. Disposal still closes both databases and removes the bounded temporary root.

## 8. FTS evidence and limitations

Production-schema triggers were exercised through the actual message writer. The bounded query corpus covers case folding, diacritics, punctuation represented as a quoted phrase, 2/3/4-character prefixes, Unicode text, text updates, and null-text rows.

The raw unquoted query `co-op` is parsed by SQLite FTS as query syntax and failed with `no such column: op`; the representative punctuation assertion therefore uses the quoted phrase `"co-op"`. This is retained as a query-language limitation, not normalized away as an internal equivalence proof.

This finite external query corpus does **not** qualify exhaustive FTS internal-table equivalence, tokenizer behavior for every input, or production search semantics beyond the observed cases.

## 9. Known nonconvergence and failure boundaries

The harness deliberately preserves these production facts:

- existing contact values are not converged by replay where the writer uses insert-ignore behavior
- existing chat values, including stale group state, are not converged in that case
- extra relationship edges are additive and remain unless a separate supported removal path removes their source material
- repository stages commit independently; failure after one stage exposes already committed preceding stages
- full and incremental equivalence is characterized only where an existing production incremental entry point exists
- source-scoped removal is characterized only through the existing historical removal API

No test claims cross-repository global transactionality or converts a known difference into success by weakening the comparison.

## 10. Performance evidence

The final focused run completed successfully. A separately measured run reported:

- wall time: `2.49` seconds
- user CPU: `2.12` seconds
- system CPU: `0.58` seconds
- maximum resident set size reported by `/usr/bin/time -l`: `504872960` bytes
- peak memory footprint reported by `/usr/bin/time -l`: `144507720` bytes

Those memory figures describe the whole Flutter test runner/process and do not isolate incremental harness RSS. Therefore the approximate 64 MiB incremental-memory target is **NOT QUALIFIED** and no contrary claim is made. The measured wall time is below the 10-second design target, but no flaky time assertion was added.

## 11. Validation results

Final-state validation attributable to implementation commit `d364df01374abad9e1f8832fa04d70ed237715ff`:

- focused harness: **PASS**, 8/8 tests
- architecture enforcement: **PASS**, 394/394 tests
- `flutter analyze`: **PASS**, no issues, 7.6 seconds
- `dart format --output=none --set-exit-if-changed`: **PASS**, 2 files checked, 0 changed
- cached and working diff whitespace checks: **PASS**
- production/generated consistency: **PASS**; no `lib/`, macOS, Rust, dependency, release-metadata, or generated-source diff
- staged implementation inventory: **PASS**; exactly the two authorized test files
- full Flutter suite: **NOT RUN** because the canonical Project Conformance standard did not require it for this test-only milestone and Prompt 105 directs that it not be run unless required

No unexplained nondeterminism, live dependency leakage, path escape, unbounded fixture, schema change, or mandatory safety failure was observed.

## 12. Explicitly NOT QUALIFIED

Prompt 105 does not establish:

- equivalence between an arbitrary populated production graph and fresh replay
- a complete populated reconstruction witness
- protected overlay/direct-reference compatibility or anti-join safety
- exhaustive FTS internal material equivalence
- full-size production-corpus time, memory, or cancellation bounds
- isolated incremental RSS near 64 MiB
- arbitrary cancellation at every writer boundary
- coherent two-sample source/ledger/graph observation
- local-account fidelity derived from a live Messages source
- safe destructive graph replacement or Start Fresh authorization
- production AppCzar cutover readiness

These omissions remain UNKNOWN or separate future evidence milestones. They are not treated as negative proof or silently promoted to TRUE.

## 13. Project Conformance review

Review scope was exactly the two new test files against baseline `7771b5c136646e3772b841304c72cdd05152394e`, under the global guardrails, project README, canonical Project Conformance standard, Prompt 105, Responses 102–104, and the current database/identity/projection rules.

Findings:

- **BLOCKER:** 0
- **SHOULD FIX:** 0
- **OPTIONAL:** 0

The harness reuses the existing production repositories rather than duplicating production semantics. Its infrastructure imports are appropriate to isolated writer characterization. It creates no new authority, provider graph, policy, coordinator, mutation capability, or state. Database identity remains source-registry grounded. Overlay and archive preservation boundaries are untouched. The corpus and resources are bounded and deterministic. The generated/dependency/release surfaces are unchanged.

**PROJECT CONFORMANCE: PASS**

## 14. Git and untracked preservation

The implementation checkpoint was pushed before this response was written. Immediately afterward, HEAD and upstream were synchronized at `d364df01374abad9e1f8832fa04d70ed237715ff`, the tracked worktree and index were clean, and the shared-instructions submodule remained clean at `95326f515ef4719f155ce6e223990398daad6311`.

At that boundary the same 49 pre-existing untracked files remained. The two test files were no longer untracked because they were checkpointed. Prompt 105 remained among the 49 entries; no unrelated untracked file was modified, staged, or removed. This response is the only additional file created for the separate documentation checkpoint.

## 15. Continuing prohibitions

No populated witness, graph repair, protected-reference validator, destructive Start Fresh, Stage 2C authorization, new AppCzar jurisdiction, production AppCzar activation, live database/archive access, or production cutover was begun. The seven AppCzar jurisdictions remain unchanged and production AppCzar activation remains OFF.

GRAPH AUDIT CHECKPOINTED: YES

ACTUAL PRODUCTION GRAPH WRITERS EXERCISED ONLY AGAINST DISPOSABLE DATABASES: YES

NO LIVE OR ADMITTED ROOT ACCESSED: YES

EMPTY/REPEATED/STALE GRAPH BEHAVIOR CHARACTERIZED: YES

FTS AND PROTECTED-REFERENCE LIMITATIONS RETAINED: YES

COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS

READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
