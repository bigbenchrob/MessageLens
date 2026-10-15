# Feature 34 — Response 112

## Result and recovered checkpoint

Completed the bounded, test-only FTS evidence milestone. Six claims remain separate. Clean content and finite raw/production corpora pass; physically stale, missing and ghost postings are detected even when tags, joins or result limits make production results equal. Internal-index and exhaustive semantic equivalence remain UNKNOWN/unassessed. This is not a populated reconstruction witness or destructive-readiness decision.

Repository evidence, rather than a previous chat's completion claim, established the starting state. Work stayed in `/Users/rob/Development/FlutterProjects/remember_every_text`, branch `fix/onboarding-import-stuck-state`. Initial HEAD was `5897918692f6f2614dc9189328d1309c31019e4c`; upstream was 0/0; tracked worktree and index were clean. The shared-instructions submodule was clean at `95326f515ef4719f155ce6e223990398daad6311`.

The four existing worktrees were preserved:

| Worktree suffix | Branch | HEAD at recovery |
|---|---|---|
| `remember_every_text` | `fix/onboarding-import-stuck-state` | `5897918692f6f2614dc9189328d1309c31019e4c` |
| `remember_every_text-feature-35` | `feature/exclusive-authority-tenure` | `09b1c767cc01410da5799273206e2ab2a4d3b283` |
| `remember_every_text-main` | `main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f` |
| `remember_every_text.worktrees/gradle-fix-flutter-projects` | `agents/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37` |

Exactly one worktree had the Feature 34 branch. A source-only manifest recorded 3,991 tracked file hashes and 51 untracked file hashes. Both proposed implementation paths were absent, so their pre-edit hashes were **not applicable (new files)**. All manifest hashes were checked again before implementation checkpoint and were unchanged. No existing file was overwritten, restored, cleaned or stashed. The complete starting untracked inventory appears below.

Verified ancestry includes:

- Production replay: `d364df01374abad9e1f8832fa04d70ed237715ff`.
- Graph comparison: `1c1f8f62b1af73991b2317aac869dbc411557594`.
- Ledger evidence: `f477f6858a62ab8849c9e0f254c9312cebea391a`.
- Coherent observation: `281d7e01161ac779f281c397bac5c626a9eb320b`.
- Protected reference implementation: `89aa7317b52f704689cdcecc36f81f0f31e46554`.
- Prompt/Response 110 documentation: `5897918692f6f2614dc9189328d1309c31019e4c`.

Prompt 111 and Response 111 were present but untracked. They alone were committed and normally pushed as `fd0da1fcc84e5dcfa792734889cc7703ec7b2159` (`docs(feature34): audit read-only FTS evidence boundaries`) before implementation. Upstream was verified 0/0. No duplicate checkpoint was created.

## Scope and ownership

Implementation checkpoint `478dc11fef099202fcb18e62d88501152ffc5739` (`test(graph): qualify bounded FTS evidence levels`) contains exactly:

| New file | Final SHA-256 |
|---|---|
| `test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence.dart` | `a9abd6702971f5e3a67555434d406a04040aab1b2f25c001a378bd0e825005ee` |
| `test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence_test.dart` | `f9ba3c4efc72153e6aee38040d37f1d57cc1216bbdafebf39ee9a1f24ba23df3` |

The checkpoint was normally pushed to `origin/fix/onboarding-import-stuck-state`; remote tracking was 0/0. This response and the exact Prompt 112 are the subsequent, separate documentation-only checkpoint. Its self-referential commit ID is reported in the final handoff, not fabricated inside this file.

No production, existing harness/test, schema/migration, generated, dependency, release, native, archive, provider, policy, coordinator or activation file changed. No actual Messages/Contacts/MessageLens database, preservation payload, admitted root, external archive drive, TCC/FDA, bookmark or S3 operation was used. No app was built, installed or launched. Git push was the only requested publication operation.

The pure helper imports only `dart:convert`. It accepts evidence observations, compares them and owns one attempt's awaited cleanup. SQLite, filesystem ownership, actual production parser/repository calls and disposable fault construction stay in the test adapter. It neither defines SQL/tokenization policy nor emits reset, Ball, coordinator or AppCzar authority.

## Characterization before classification

Three characterization tests were made to pass before creating the classification helper. They used two independently allocated production-schema fixtures, fixed source IDs and actual existing replay/projector APIs. They verified exact schema/trigger SQL, underlying SQLite identity, content and raw/search results, repeat replay, same-text update, delete/reinsert, text → NULL → empty → text, and restored-trigger stale postings masked by an overlay tag. The actual production parser and repository ran unchanged. No finding contradicted Response 111's source audit.

The six-message canonical replay fixture was extended by exactly 18 messages, for 24 total. Added rows 100–117 in source 1 cover NULL, empty, whitespace, oldword/newword/ghostword, CAFÉ, decomposed café, co-op, don't, post postmaster, under_score, Cyrillic, Greek, emoji, repeated words and embedded quotes. Actual rich-text semantic projection receives synthetic persist, empty and failure facts; no native decoder is invoked. The inherited fixture retains associated/missing references and source IDs 1, 2 and 3. Added rows use a fixed ISO timestamp, ties and one NULL date (row 110). There are exactly two tags and two saved flags; the duplicate-GUID variant assigns row 117 the row-110 GUID.

`id(n)` below means the unchanged `SourceScopedRowKey.pack(sourceId: 1, sourceRowId: n)`:

- Raw exact post returns IDs 110, 114, 115 in ID order; emoji preceding post does not suppress that token.
- Raw CAFE includes original fixture IDs 40, 41 and added 106, 107.
- Raw ghostword returns ID 105 in the clean graph.
- Production `post ` returns 115, 114, 110, with the NULL-date row last.
- Saved-only returns 103, 110; AND post/alpha returns 115; OR returns 115, 114, 110.
- GUID-compatible tag compat returns 110 only when its GUID is unambiguous.
- Raw unquoted co-op and an unterminated quote throw SQLite errors; the production parser's quoted term grammar is exercised separately.

Pre-comparison log: `/private/tmp/messagelens-prompt112-characterization.log` (3 passed). Final focused log: `/private/tmp/messagelens-prompt112-focused.log` (22 passed). These are local execution artifacts; the durable assertions and runtime record are in the committed test and this response.

## Measured schema and loaded runtime

These identities were obtained through the same SQLite handles wrapped by migration-disabled NativeDatabase/Drift and used by the real search repository, not inferred from a dependency lockfile or command-line SQLite. `PRAGMA user_version` returned 3; FTS5 availability was confirmed by successfully executing MATCH. Both independent connections agreed.

Whitespace-normalized SQL read from `sqlite_master` and asserted in characterization:

```sql
CREATE VIRTUAL TABLE message_text_fts USING fts5( text, content='messages', content_rowid='ss_id', tokenize='unicode61 remove_diacritics 2', prefix='2 3 4' )
CREATE TRIGGER message_text_fts_after_insert AFTER INSERT ON messages BEGIN INSERT INTO message_text_fts(rowid, text) VALUES (new.ss_id, new.text); END
CREATE TRIGGER message_text_fts_after_delete AFTER DELETE ON messages BEGIN INSERT INTO message_text_fts(message_text_fts, rowid, text) VALUES ('delete', old.ss_id, old.text); END
CREATE TRIGGER message_text_fts_after_text_update AFTER UPDATE OF text ON messages BEGIN INSERT INTO message_text_fts(message_text_fts, rowid, text) VALUES ('delete', old.ss_id, old.text); INSERT INTO message_text_fts(rowid, text) VALUES (new.ss_id, new.text); END
```

The schema assertion also requires all five named objects, including messages with `ss_id INTEGER PRIMARY KEY`. Evidence records the complete returned messages DDL and four FTS definitions. Runtime identity and sorted compile options:

```json
{
  "version": "3.51.0",
  "source": "2025-06-12 13:14:41 f0ca7bba1c5e232e5d279fad6338121ab55af0c8c68c84cdfb18ba5114dcaapl",
  "options": [
    "ATOMIC_INTRINSICS=1",
    "BUG_COMPATIBLE_20160819",
    "CCCRYPT256",
    "CODEC=see-cccrypt",
    "COMPILER=clang-21.0.0",
    "DEFAULT_AUTOVACUUM",
    "DEFAULT_CACHE_SIZE=2000",
    "DEFAULT_CKPTFULLFSYNC",
    "DEFAULT_FILE_FORMAT=4",
    "DEFAULT_JOURNAL_SIZE_LIMIT=32768",
    "DEFAULT_LOOKASIDE=1200,102",
    "DEFAULT_MEMSTATUS=0",
    "DEFAULT_MMAP_SIZE=0",
    "DEFAULT_PAGE_SIZE=4096",
    "DEFAULT_PCACHE_INITSZ=20",
    "DEFAULT_RECURSIVE_TRIGGERS",
    "DEFAULT_SECTOR_SIZE=4096",
    "DEFAULT_SYNCHRONOUS=2",
    "DEFAULT_WAL_AUTOCHECKPOINT=1000",
    "DEFAULT_WAL_SYNCHRONOUS=1",
    "DEFAULT_WORKER_THREADS=0",
    "DIRECT_OVERFLOW_READ",
    "DQS=3",
    "ENABLE_API_ARMOR",
    "ENABLE_BYTECODE_VTAB",
    "ENABLE_COLUMN_METADATA",
    "ENABLE_DBSTAT_VTAB",
    "ENABLE_FTS3",
    "ENABLE_FTS3_PARENTHESIS",
    "ENABLE_FTS3_TOKENIZER",
    "ENABLE_FTS4",
    "ENABLE_FTS5",
    "ENABLE_LOCKING_STYLE=1",
    "ENABLE_MATH_FUNCTIONS",
    "ENABLE_NORMALIZE",
    "ENABLE_PREUPDATE_HOOK",
    "ENABLE_RTREE",
    "ENABLE_SESSION",
    "ENABLE_SETLK_TIMEOUT",
    "ENABLE_SNAPSHOT",
    "ENABLE_SQLLOG",
    "ENABLE_STMT_SCANSTATUS",
    "ENABLE_UNKNOWN_SQL_FUNCTION",
    "ENABLE_UPDATE_DELETE_LIMIT",
    "HAS_CODEC_RESTRICTED",
    "HAVE_ISNAN",
    "MALLOC_SOFT_LIMIT=1024",
    "MAX_ATTACHED=10",
    "MAX_COLUMN=2000",
    "MAX_COMPOUND_SELECT=500",
    "MAX_DEFAULT_PAGE_SIZE=8192",
    "MAX_EXPR_DEPTH=1000",
    "MAX_FUNCTION_ARG=127",
    "MAX_LENGTH=2147483645",
    "MAX_LIKE_PATTERN_LENGTH=50000",
    "MAX_MMAP_SIZE=1073741824",
    "MAX_PAGE_COUNT=1073741823",
    "MAX_PAGE_SIZE=65536",
    "MAX_SQL_LENGTH=1000000000",
    "MAX_TRIGGER_DEPTH=1000",
    "MAX_VARIABLE_NUMBER=500000",
    "MAX_VDBE_OP=250000000",
    "MAX_WORKER_THREADS=8",
    "MUTEX_UNFAIR",
    "OMIT_AUTORESET",
    "OMIT_LOAD_EXTENSION",
    "STMTJRNL_SPILL=131072",
    "SYSTEM_MALLOC",
    "TEMP_STORE=1",
    "THREADSAFE=2",
    "USE_URI"
  ],
  "schema": 3
}
```

## Strict read-only observation

All setup graph/ledger/overlay writers close before independent observation readers open. Reader paths resolve inside the uniquely allocated harness root. Both SQLite opens specify `OpenMode.readOnly`, both set `PRAGMA query_only = ON`, and both Drift wrappers use `NativeDatabase.opened(..., enableMigrations: false)`. The real `SqliteGraphSearchRepository` receives these wrappers, never the admitted provider graph.

The comparison adapter performs fixed SELECTs and only the inspection PRAGMAs `compile_options` and `user_version`; query_only is the one connection safety-setting PRAGMA during opening. Runtime and schema inspection use SELECTs. There is no ATTACH, vocabulary table, shadow-byte decoding, successful temp DDL, repair or migration. The refusal test deliberately attempts graph DML, rank-0/rank-1 special FTS integrity commands, rebuild, optimize, trigger removal, main/temp virtual-table creation, user_version mutation and overlay DML. Every attempt throws `SqliteException`. These refused probes are separate from actual comparison and do not authorize such interfaces on real observed material.

Whole-root file manifests cover every owned file, including any WAL/SHM or unexpected temporary files, without following links. SHA-256 before observation is compared with after-reader-close evidence, before root deletion. Schema is also compared during observation. File identity supports the read-only construction; it is not a substitute for it. Opening failures dispose opened raw handles; close completion is tracked. An unconfirmed reader close prevents root deletion.

## Six independent dimensions

`FtsEvidenceResult` carries an immutable six-entry map, expected/observed runtime-schema identities, expected/observed binding identities, the named corpus identity and bounded diagnostics. Each dimension contains typed truth, assessed flag and reason. The common envelope binds all six claims; there is no overall equivalence/authorization boolean.

| Dimension | TRUE | FALSE | UNKNOWN |
|---|---|---|---|
| schemaRuntimeCompatibility | qualified exact identity agreement | coherent known runtime/schema difference | missing/unsupported/unstable evidence |
| contentMaterialEquivalence | same ID presence and nullable text in both directions | stable ID/text mismatch, including NULL versus empty | unavailable content or disqualified observation |
| boundedRawMatchCorpusEquivalence | every named finite request executes and ordered IDs agree | stable mismatch for a named qualified request | error/limit without a coherent contradiction |
| boundedProductionSearchCorpusEquivalence | every named actual repository request agrees | stable production result mismatch | error/limit without a coherent contradiction |
| qualifiedInternalIndexEvidence | never emitted here | never emitted here | always unassessed; no qualified inspection contract |
| exhaustiveFtsSemanticEquivalence | never emitted here | never emitted here | always unassessed; finite corpus only |

Binding drift, replacement, unqualified snapshot, source-registry mismatch, cancellation, deadline, budget or cleanup failure discards the affected observation and makes the first four claims UNKNOWN. Known compatibility mismatch is FALSE for compatibility and UNKNOWN for dependent comparisons. A content read error affects content; individual query errors affect their respective corpus. A stable named mismatch can establish that finite corpus FALSE despite another request failing. An exception is never translated to an empty result. Internal/exhaustive claims stay UNKNOWN even when raw mismatch exists: this milestone does not invent a separate internal-inspection contract.

## Full bounded corpus

Corpus envelope name: `synthetic-112-v1`. The clean comparison executes 13 raw requests and 20 production requests. Special adversarial comparisons use the explicitly listed subset/control under the same synthetic fixture version; request index in diagnostics refers to that supplied finite list.

| Raw name | MATCH expression |
|---|---|
| old | `"oldword"` |
| new | `"newword"` |
| ghost | `"ghostword"` |
| case | `"CAFE"` |
| phrase | `"co-op"` |
| prefix2 | `"po"*` |
| prefix3 | `"pos"*` |
| prefix4 | `"post"*` |
| greek | `"Καλημέρα"` |
| cyrillic | `"ПРИВЕТ"` |
| repeat | `"alpha beta"` |
| apostrophe | `"don"` |
| underscore | `"score"` |

In the following table, `<space>` denotes an actual trailing space and therefore completion of the final term. Default scope is global, default matching is AND and the test repository request limit is 500; the pre-observation message bound is 128 and the fixture contains 24. Returned IDs above 128 are rejected before comparison.

| Production name | Parser input | Overrides |
|---|---|---|
| exact | `post<space>` | — |
| prefix | `post` | — |
| prefix2 | `po` | — |
| prefix3 | `pos` | — |
| punctuation | `co-op<space>` | — |
| quoted | `"quote"<space>` | — |
| all | `post alpha<space>` | AND |
| any | `post alpha<space>` | OR |
| case | `CAFÉ<space>` | — |
| decomposed | `café<space>` | decomposed Unicode |
| saved | `is:saved` | parser-derived saved filter |
| saved-text | `post is:saved` | parser-derived saved + text |
| tag-masked | `oldword<space>` | native overlay tag |
| guid-tag | `compat<space>` | GUID compatibility tag |
| cap | `post` | limit 1 |
| zero | `post` | limit 0 |
| single | `p` | single-character parser behavior |
| conversation | `post` | conversation id(30) |
| handle | `post` | handle id(10) |
| contact | `post` | canonical handles [id(10)] |

No tokenizer, parser translation or production query is copied into the helper. All production query meaning is delegated to the existing parser and repository.

## Adversarial evidence

Physical disposable controls:

- **Stale posting with equal content and restored DDL:** update row 103 from oldword to newword with the trigger, drop the text-update trigger, restore its text to oldword without the trigger, then restore the exact original trigger SQL. Content and schema equal clean replay. Raw oldword loses 103 and raw newword gains 103. The oldword overlay tag makes production oldword results equal. Content TRUE, raw FALSE, selected production TRUE.
- **Missing hit:** special FTS delete of row-103 oldword during writable setup only; content unchanged, raw FALSE, tag-masked production TRUE.
- **Ghost posting:** add ghostword posting for absent message ID 999 during writable setup only; raw sees the extra ID, actual production joins exclude it. Content TRUE, raw FALSE, selected production TRUE.
- **Capped masking:** remove row-110 post posting while top result 115 remains. Raw FALSE; production cap-1 equality remains TRUE only for that named request.
- **Overlay-only:** delete the native tag and clear its saved flag. Content/raw stay TRUE; production corpus FALSE.
- **Ambiguous GUID:** duplicate the row-110 GUID on 117. Raw stays TRUE; GUID-compatible tag/saved exclusion changes production results to FALSE.
- **Malformed raw expression:** unterminated quote fails on the real read-only engine; raw dimension UNKNOWN/readFailure, not empty-success.
- **Transitions:** literal repeated full replay, same-text update, delete/reinsert and NULL/empty transitions run through unchanged production replay/writer behavior.

Simulated evidence controls are explicitly separate: content-only NULL/empty difference; version/source/options/schema/tokenizer drift; missing runtime qualification; snapshot/source-registry/fingerprint/occurrence drift; before/after-read exceptions; excessive rows/bytes/requests/results/handles/disk; cancellation/deadline at each boundary; close failure; redaction overflow. Real-reader cancellation and an injected post-cleanup failure additionally verify actual closing/root deletion and UNKNOWN. These tests do not claim physical disk failure, native hang preemption or real graph replacement experiments.

## Bounds, lifecycle and privacy

Limits are fixed at 128 messages and 256 KiB input text per world; 64 total named requests; 128 returned IDs per request before comparison; 32 diagnostic examples; six simultaneously open handles; 32 MiB owned disposable disk; one attempt without retries. Resource checks precede observation and repeat at the end. The physical adapter measures actual row/text totals, handle accounting and disposable file sizes; raw/content reads use LIMIT 129 to detect overflow rather than silently truncate to equality. Production results cannot exceed the prechecked 128-message world, and returned-list limits are checked independently. Owned filesystem hashing rejects oversized input before reading it.

Eight read phases per minimal world are tested before and after failure. Deterministic injected monotonic clock/cancellation checks exercise all 34 boundaries across both worlds, including post-close checks. No wall-clock sleeps, `Future.timeout`, background retry or claim of native preemption exists. Every started read is awaited before close; cleanup is awaited without timing out a still-active handle. Root deletion follows confirmed closes. A real closure failure retains the root and returns UNKNOWN; the suite's cleanup failure injection happens after successful physical cleanup. Thus the qualification covers fail-closed classification and successful close/delete ordering, not guaranteed recovery from arbitrary OS cleanup failure.

Diagnostic strings contain only categories and request indexes, never texts, raw queries, IDs, exception payloads or paths. A 100-row mismatch yields 32 examples while retaining count 100. Runtime logging prints engine identity only. Observation bindings intentionally retain synthetic occurrence/fingerprint/registry identity in the result envelope, separate from redacted diagnostics. Fixture source-registry donor-root prefixes are replaced by a fixed `<synthetic-root>` token; source IDs and other registry evidence are retained. All DB data is synthetic.

Final focused run measured **4.25 seconds real**, 3.70 user, 1.26 system. `/usr/bin/time -l` reported **517,849,088 bytes maximum resident set size** and **146,735,944 bytes peak memory footprint**. These measurements cover the entire Flutter test runner; helper incremental RSS was not attributable and is not claimed. No production scalability/exhaustiveness conclusion follows from the small fixture.

## Validation and literal intermediate failures

| Gate | Final result |
|---|---|
| Initial characterization before helper | 3 passed |
| Final focused characterization/evidence | 22 passed |
| Existing regression selection | 127 passed |
| Architecture forbidden-import suite | 394 passed |
| Full flutter analyze | No issues found |
| Targeted dart format | 2 files, 0 changed |
| Git diff and staged diff checks | Passed |
| Source/untracked baseline hashes | All unchanged |

The regression selection was exactly:

```text
test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart
test/essentials/conversation_graph/infrastructure/conversation_graph_database_test.dart
test/essentials/conversation_graph/infrastructure/message_text_fts_runtime_test.dart
test/essentials/conversation_graph/application/messages/message_projector_test.dart
test/essentials/search/application/message_text_search_query_test.dart
test/essentials/search/application/search_service_test.dart
test/essentials/search/infrastructure/repositories/graph_search_repository_test.dart
test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation_test.dart
test/essentials/app_czar/application/reconstruction/protected_reference_equivalence_test.dart
```

Commands used `flutter test ... --reporter expanded`, `flutter test test/architecture/forbidden_imports_test.dart --reporter expanded`, full `flutter analyze`, targeted `dart format --output=none --set-exit-if-changed`, and Git diff checks. Logs are `/private/tmp/messagelens-prompt112-{characterization,focused,regression,architecture,analyze,format}.log`. No generation or full Flutter suite was needed.

Intermediate outcomes, not hidden by final PASS:

1. Initial sandboxed Flutter invocation could not update SDK engine.stamp; no tests ran. The required SDK-cache access was then approved.
2. First characterization execution failed all three tests because the new test omitted sqflite FFI bootstrap. Initialization was added only to the new file.
3. Next characterization had two passes and one failure: expected raw post IDs omitted the synthetic emoji-post row 114. The expectation was corrected to observed production tokenization, consistent with Response 111. Three characterization tests then passed before helper creation.
4. An expanded 21-test run passed; analyzer reported five informational style findings. The new files were corrected and analysis passed.
5. Adding the required NULL date changed the new fixture's saved ordering; one expected order failed. The assertion was corrected to actual date/ID semantics (103 before 110), without changing production ordering.
6. First full architecture run had 393 passes and one failure: the new test contained an `ignore: avoid_print` suppression for runtime output. It was replaced by explicit stdout output, with no suppression or architecture allowlist change. The rerun passed all 394.
7. Conformance tightened path containment, partial reader-open cleanup, confirmed-close-before-delete behavior, resource failure reason classification and schema object completeness. Focused tests passed again; formatting and the applicable architecture/analyzer checks passed. No production assertion or semantics was weakened.

## Project Conformance Audit

Scope: branch `fix/onboarding-import-stuck-state`, implementation base `fd0da1fcc84e5dcfa792734889cc7703ec7b2159`, complete two-file addition reviewed while unstaged, checkpointed as `478dc11fef099202fcb18e62d88501152ffc5739`. This is the Prompt 112 bounded milestone audit, not an end-of-Feature-34 or whole-repository destructive-readiness audit.

**Reviewed against:**

- `AGENTS.md`.
- `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`.
- `_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/dart.md`.
- `_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/riverpod-provider-patterns.md` (no new provider required).
- `_AGENT_INSTRUCTIONS/agent-per-project/README.md` and its architecture/database instruction index.
- `_AGENT_INSTRUCTIONS/agent-per-project/01-PROJECT/02-architecture-overview.md`.
- `_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/00-all-databases-accessed.md`.
- `_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/07-overlay-database-independence.md`.
- `_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/INVIOLATE_RULES.md`.
- `_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/13-apple-timestamp-conversion.md`.
- `_AGENT_INSTRUCTIONS/agent-per-project/25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md`.
- Feature 34 `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`.
- Prompt 112, Response 111 in full, qualified evidence Responses 105–110, existing replay harness, source-identity modules and current production graph/search code.

| Checklist | Finding |
|---|---|
| Reuse before invention | NO ISSUE: existing replay, projection, schema, rich-text facts, parser and repository reused; new helper separates evidence levels existing comparators do not represent |
| Layering/ownership/dependencies | NO ISSUE: pure test helper; infrastructure confined to disposable test adapter; no production import of helper |
| Single source of truth | NO ISSUE: SQL is inspected/asserted, not installed as a replacement production schema; parser remains authoritative |
| Project idioms | NO ISSUE: typed immutable evidence, explicit braces/async lifecycle; no providers/generated model needed |
| Performance/bounds | NO ISSUE within fixed synthetic limits; no production scalability claim |
| Privacy/logging | NO ISSUE: synthetic data only, bounded redacted diagnostic categories, runtime-only output |
| Mutation/authority | NO ISSUE: setup-only faults, read-only observed handles, no mutation authorization |
| State/error semantics | NO ISSUE: six dimensions, stable contradiction versus UNKNOWN, exceptions never empty |
| Dead/superseded machinery | NO ISSUE: no production retirement or competing production path introduced |
| Tests/architecture | NO ISSUE after suppression correction; focused, regression and architecture gates pass |
| Generated/dependency hygiene | NO ISSUE: no generated or dependency changes |
| Documentation agreement | NO ISSUE: finite proof limits and simulated versus physical cases explicit |
| UX/theme/navigation | Not applicable: no UI changed |

Unresolved **BLOCKER: 0; SHOULD FIX: 0; OPTIONAL: 0**. Reviewed cleanup and diagnostic issues were fixed within the two allowed files. No scope expansion or undocumented exception was needed.

PROJECT CONFORMANCE: PASS

## Remaining uncertainty and next narrow recommendation

Internal/exhaustive index proof is still UNKNOWN. Matching finite requests cannot establish all possible tokenizer/query/posting behavior. No qualified internal-inspection contract, complete populated witness, retained/live observation lifecycle, native query preemption or destructive authority is implemented. No new confidence should be inferred for an untested engine version, corpus or real archive.

The next separate evidence milestone should first specify how the already qualified content/finite-query dimensions bind to a coherent retained observation, while explicitly carrying internal/exhaustive UNKNOWN. It must not combine these into a reset capability. Any internal inspection would need its own strictly read-only qualified contract and approval scope. Prompt 113 was not implemented.

## Starting untracked inventory and preservation evidence

These 51 paths were untracked at the Prompt 112 baseline. Their SHA-256 values were verified unchanged before checkpointing. The Prompt/Response 111 pair and Prompt 112 become tracked by the prescribed documentation checkpoints; the other **48** remain untracked and preserved. Response 112 and the two implementation files are the only newly created files for this milestone. Final tracked worktree/index cleanliness, upstream 0/0 and submodule cleanliness are verified after the documentation checkpoint and reported in the handoff.

| Baseline path | SHA-256 |
|---|---|
| `.vscode/settings.json` | `933c353ad8b3136063dda9f1a6e7e7389782177552a98cb48b5e437547ad752a` |
| `Screenshot 2026-10-07 at 10.25.14 AM.png` | `a06fd4a0eb7ed11a20c7f9dd3948faada0e55fd2cfdff49a71b5ec7d919740c1` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/26-PRODUCTION-ARCHIVE-RECOVERY/prompts/01-RESUME-ARCHIVE-RECOVERY.md` | `cd0ca608ebda449a35ccd0c673f4241e2c43edfc3d5d6d1bd213c281d30b7fbf` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/30-SEARCH-ENHANCEMENT/prompts/16-DOCUMENTATION-ENHANCEMENT.md` | `74f5efe4c71cf3a1c39f62014fc723940863137e3b1d04e051962e5b90267783` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/02-ATTACHMENT-ARCHIVE-LOCATION-CONTD.md` | `321d752dd2c95bfa192ae1d110b8ee42e34280d1b42d0a8995b66e2f338020ab` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/03-REDIRECTION.md` | `310d02a58afb4ce374537c4f299913a9a6dde90b806d5a783748ef489eaa0454` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/04-BEGIN-PHASE-THREE.md` | `344e8498ff4cd17ae334a6f3bc14184dbb47a46d055df7c327bfc6883483cecb` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/05-BEGIN-PHASE-FOUR.md` | `0f3e989655d360b0d0cebd57c4dc3bf6a623d2b397322b6e819a70a3cddc3aa5` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/06-INVESTIGATE-UI-REGRESSION.md` | `b429f8c66f88ba4904d877be52a71ec13f6ee1fdd922bbf8028b972f48864f0e` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/07-PHASE-FOUR-IMPLEMENTATION.md` | `c353e1230ce1cfd3611496afe9a39c49a60b5db39d12fcbc947eeb04526d974c` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/08-PHASE-SIX.md` | `2db03e0b9f6c798fff7fdb8f9be2bfa60a69af176c44c538460d26b5f1933a46` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/09-EXTERNAL-DRIVE-TEST-DESTINATION.md` | `a334ee2b89f41306d62328091da0db0926f89d2845a727830ea0cfb969568b65` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/10-CHECKPOINT-GATE.md` | `4a037f187ec98f71b7557060ff3cbc953dfd20a32cc4ce67cc59c3b2df61de4b` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/11-REDIRECTION-HUMAN-INPUT.md` | `b599e6f0f40dab38007a17c7a25b40b552e7b6cdce4ac5b9d80ffcf29ba59cdb` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/12-APPROVAL.md` | `5a6f8a501f96a15968bc7a576ce9cc6cf3231ccbcb3e9420967020ad77aca516` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/13-CHECKPOINT-TWO.md` | `0c221bb94e44b7a1f45add37b7c8d3132640590b9d35f6d734164f2c10dd82b4` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/14-CHECKPOINT-THREE.md` | `6cebc4f33627fdb004c39081cb953c5191ca801bcfdb6aa827552ab967657c71` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/15-CHECKPOINT-FOUR.md` | `a9c274e4333e0b15922cc9fb3ec087918b037e702b3bfde9f10f7f71366e1faa` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/16-CHECKPOINT-FIVE.md` | `ff346a86f83ab7d60b1fcccd7b36e89c19c5c541e80949f98a14a29dd5256777` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/17-RETIRE-LEGACY-MOVER.md` | `9df0940ca37e4972f912a2207019dfe17e1efaa294ce3aead297dceba6a67202` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/18-SIDEBAR-CHOOSE-UI-MESS.md` | `2b23a630159bd672c204fbf86d78859a31408b8d525e9fea4fa94debee6a4da5` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/19-UI-AND-TASK-REVISION.md` | `12bd5a433def65c966b3fec0e4809ce86ea511e2b3dfaa1580fd47728c16ec37` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/20-POST-ADOPTION-AUDIT.md` | `95cfc62c392835e814dfd63a1bd7507c31a2554c9e4c2e75cfcbc45f745b77c8` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/prompts/21-POST-REHEARSAL-CORRECTION.md` | `19ee329516e1b00a443ff6621b34750b69880d94ad22daf4cca9e81e3be72e4d` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/responses/02-RESPONSE.md` | `c97396d02728ed1c80430027224cdb1884ca91b497233488ab90bd69e8f7b09d` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/responses/03-RESPONSE.md` | `25490d9183ebed3bfd92589ce822037426e2fc7f98abd4cf58f1b39e7d171e40` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/31-ATTACHMENT-ARCHIVE-RELOCATION/responses/04-RESPONSE.md` | `a79ca38fc3c3390fded19d14c1927108c8feb2897b929fa52dfe9ce72aa61af1` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/01-CLEAN_SLATE_QUALIFICATION.md` | `74b54d7af3220ab81b2692cf2ea731911e0b381ab34a8df1948f99c88dd52f24` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/01-PRE-INTEGRATION-BRANCH-AUDIT.md` | `507cc0458e84e1e45ee25ca57f99d66060e6057d76c012fdb6168906c1c94928` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/02-PRE-INTEGRATION-BRANCH-AUDIT-RESULT.md` | `79a7010db97ea9f22efd03b1d6fc3d777aaa6466b6d35e1e05f1f5df56b2f958` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/02-VERIFY-QUIESCENCE-AND-PREPARE-SNAPSHOT-RESPONSE.md` | `d8eb53659576bbee5cd7267a881f02864bfe71858ed675d847b6f83c7c82af60` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/02-VERIFY-QUIESCENCE-AND-PREPARE-SNAPSHOT.md` | `23c1918a31e0c8cb4d5ba1f70f7a6d89c8d4ffac3f7345995254c1cbcc3654e4` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/03-CREATE-AND-VERIFY-DEVELOPMENT-SNAPSHOT.md` | `563b533c9a57a38684a8a9f0f5c1d6101daed9f19f7d10865c1766734ad5c978` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/03-PRE-MERGE-PROJECT-CONFORMANCE-AUDIT.md` | `779cf0dc8c0c9f3a770f15e58941c3442cc44873aa199e21264e76dd7ca2b9f8` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/04-FEATURE-31-PROJECT-CONFORMANCE-AUDIT.md` | `e785a67065498a1ea918eaab59fb720f671a2045a090ec7616a167744f3d18cb` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/04-RERUN-AND-VERIFY-DEVELOPMENT-SNAPSHOT-RESPONSE.md` | `4ce2fac00cbe420844ea4fe017cb860cbd63a4c458deed8a1527a868a62c4971` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/04-RERUN-AND-VERIFY-DEVELOPMENT-SNAPSHOT.md` | `852d9c4390e1c2e05c1981dbb334e726225be0212235d14a6c9c7d725b6db7bf` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/05-BUILD-AND-VERIFY-INTEGRATED-DEVELOPMENT-APP-RESPONSE.md` | `93bf295ed68f248e9d2fd6de83dcbf0c2e9bd0a26adfc3e914b1e668308a568b` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/05-BUILD-AND-VERIFY-INTEGRATED-DEVELOPMENT-APP.md` | `39eb83835192d082971b93d90ec067378b3f19968bd981f0d11f63202841e1f4` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/05-FEATURE-33-PROJECT-CONFORMANCE-AUDIT.md` | `ef180449d5f5f7fcdc03b2c1cb6d9492d32a5c47ba7261a0752f8d6644c799b3` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/06-CORRECT-PROJECT-CONFORMANCE-FINDINGS.md` | `dccd51051e2c4f03cc0fa27e758ada9818d71b1ed0000d1639b3bbbaf7a23e42` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/06-FIRST-INTEGRATED-LAUNCH-AND-PRE-RESET-VERIFICATION.md` | `875a5311a41516a65f09350132f28724d76f6d225344a638619de50035dce827` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/07-SIMPLIFIED-FIRST-LAUNCH-AND-START-FRESH.md` | `a0a9b328a7d6a9c819cd78c8bdd889cc49aa87da5192119cf5d9a86e721a5326` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/08-INTEGRATE-CORRECTED-FEATURES-INTO-MAIN.md` | `28a447f387d831535aea2c2ac41afd8fd396a63e88333240c351ac7a5551bb1c` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md` | `b8c1026e0df060bd5a403e836d6dd176cdc7557db866a9f5c022146b652c3d20` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/prompts/111-CHECKPOINT-PROTECTED-REFERENCE-QUALIFICATION-AND-AUDIT-READ-ONLY-FTS-EQUIVALENCE.md` | `d915c6d29dacc7dcfe6a10ba0fb9a4692d7bad52fe43bf79ff9e338357d9b358` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/prompts/112-QUALIFY-TEST-ONLY-FTS-EVIDENCE-LEVELS-AND-ADVERSARIAL-DISPOSABLE-CONTROLS.md` | `5f84c08292c4fffa7fdb0df242aefe3cc51cc1741fe3ae0ff087f827910977b6` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/prompts/message_lens_S3_backup_updated.zsh` | `4545aa0ed51520a366ee70576598a5b6b7960f428a0ec0b2ed1ad28efac6f3b9` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/prompts/message_lens_project_S3_backup.zsh` | `54e169f5f221309983675094b1caa5def95b5511dd511b90e4de19807209492b` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/prompts/message_lens_project_S3_restore_test.zsh` | `2e23057f0f5308d25cca231da614fa6a0746ce31a3e5706baf3eacaddc1453bf` |
| `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/responses/111-CHECKPOINT-PROTECTED-REFERENCE-QUALIFICATION-AND-AUDIT-READ-ONLY-FTS-EQUIVALENCE.md` | `128964327bf1519c6512ccf3c0a5c4e14fd6f457e070cdb57fe98130ccfad805` |

PROTECTED-REFERENCE QUALIFICATION CHECKPOINTED: YES

FTS SCHEMA AND ACTUAL DISPOSABLE RUNTIME IDENTITY RECORDED: YES

OBSERVED DISPOSABLE SEARCH CONNECTION STRICTLY READ ONLY: YES

SIX INDEPENDENT FTS EVIDENCE DIMENSIONS IMPLEMENTED: YES

CLEAN REPLAY CONTENT/RAW/PRODUCTION BOUNDED CORPORA: PASS

STALE POSTING WITH EQUAL CONTENT DETECTED: YES

TAG OR LIMIT MASKING CANNOT PROMOTE INDEX EVIDENCE: YES

INTERNAL FTS INDEX EQUIVALENCE EXHAUSTIVELY PROVEN: NO

COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS

READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
