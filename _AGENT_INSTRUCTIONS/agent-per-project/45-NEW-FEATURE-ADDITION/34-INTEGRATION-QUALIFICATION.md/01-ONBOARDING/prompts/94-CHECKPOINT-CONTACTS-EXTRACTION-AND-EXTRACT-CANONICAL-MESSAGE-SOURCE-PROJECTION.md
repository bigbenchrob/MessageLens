# MessageLens — Feature 34
## Prompt 94 — Checkpoint Contacts Extraction and Extract the Canonical Messages Source Projection

**Milestone:** Second narrow shared-transformation extraction, following Response 92's reconstruction-equivalence audit and Response 93's qualified Contacts source-projection extraction.

**Governing status:** The Contacts extraction passed. A **complete populated import/Conversation Graph/FTS reconstruction-equivalence witness does not exist**. Operating-owned destructive Start Fresh remains **BLOCKED**. Production AppCzar activation remains **OFF**. This prompt must not attempt to lift either restriction.

### Principle

> First characterize what the actual production Messages importer writes. Then extract only its existing deterministic source-row-to-ledger transformation into one typed, pure function consumed by that same importer. Its output, omissions (if any), anomalies, paging, progress, and database effects must be observationally identical before and after.

The extraction is **not** a new message importer, a new source reader, a witness, or a change in import policy. Do not create a second interpretation of Apple Messages.

---

## 1. Preflight and exact Git baseline

Work only in the primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- synchronized HEAD/upstream (`0/0`), tracked worktree and index clean;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one worktree on the Feature 34 branch;
- known unrelated untracked paths untouched;
- implementation checkpoint `a36feac8a48d1702aad5830076157830d6efb975` in ancestry;
- Response 92 audit checkpoint `7d4f33de7495f34e28fa4ad079e1d0bcf6bd99e5` in ancestry.

Find the actual current HEAD and compare with the final Prompt 93 handoff. Do not assume that Response 93's body contains its own later documentation-commit hash. If Prompt 93 and Response 93 have already been committed and pushed together, verify and report that checkpoint. If not, make **only** the narrow Prompt 93/Response 93 documentation checkpoint and normal push **before source edits**. Do not duplicate it.

Capture a fresh Git/source-only baseline manifest outside the repository, including the current Messages importer and its adjacent test, identity, DateConverter, source-scoped schema, and graph boundary files. Do not inspect real user data.

Read the canonical Project Conformance standard, global project instructions, Responses 91–93, and the code actually being extracted before editing.

If any preflight differs in a material way, **STOP AND REPORT**.

---

## 2. Allowed scope, and hard exclusions

**Allowed production source:**

- `lib/essentials/source_scoped_import/application/messages/message_importer.dart`;
- one narrowly named pure sibling, e.g. `message_source_projection.dart`;
- only the minimal existing pure utility import required by those two files.

**Allowed tests:**

- an actual-production-writer pre/post characterization test using synthetic source/ledger fixtures;
- focused pure projection tests;
- a narrowly scoped AST/import-boundary architecture test;
- existing Messages importer tests only where needed for exact parity, not revised meaning.

**Do not change:**

- Messages `chat.db` query SQL, joins, ordering, keyset/page selection, transaction boundaries, chunk sizes, or error policy;
- database schema, Drift migrations, source registry, batch allocation, ledger insert methods, uniqueness or `insertIgnore` behavior;
- `message_rich_text_enricher.dart`, Rust typedstream decoder, blob decoding, attributed-body enrichment lifecycle, or rich-text policy;
- handle importer, handle canonicalization/projector, chat importer, attachments importer, Contacts importer or the just-qualified Contacts projection;
- graph projectors, classification, canonical handle aliases, FTS, `working_ss.db`, full build orchestrator;
- AppCzar observation/evaluator/coordinators, Local Data Repair, Operating currentness, Start Fresh/Settings, seven-jurisdiction census;
- archive/attachment payloads, overlays, Presence, historical source registry, bookmark/configuration, process restarters, admission, adoption gate;
- production composition policy, always-disabled activation, bundle/signing/entitlements, packaging, release metadata except if required by an independently applicable repository rule.

Do not build, install, or launch MessageLens. Do not open or query real Apple Messages/Contacts, real MessageLens database/archive, WD development root, or Toshiba attachment archive. All tests use synthetic/in-memory/disposable data.

If a clean pure extraction requires editing another source importer/projector, expanding the schema, or changing the current SQL, **STOP** rather than broadening scope.

---

## 3. Source-trace the actual Messages importer first

Before writing code, enumerate the concrete dataflow of `MessageImporter.importNewMessages(...)`, including any other current entry point whose row-construction semantics it shares:

1. source query and selected raw columns;
2. source row identity (ROWID, GUID and lineage);
3. sorted keyset/page boundaries and incremental high-water selection;
4. source-scoped ID construction via `SourceScopedRowKey.pack`;
5. sender-handle resolution, including `_senderHandleSsId(...)` and any ledger/source lookup;
6. every Apple timestamp conversion through `DateConverter`;
7. nullable/raw text and attributed-body handling, without decoding new content;
8. direction/type, associations/thread GUIDs, source/error/system flags, and all anomalous messages;
9. batch ID insertion and other operational metadata;
10. exact ledger insert row shape, collision/duplicate behavior, and progress/anomaly reporting;
11. exception behavior and failure classification.

Enumerate **every persisted column** of the current `messages` import table from the actual schema and row-insert code. Do not infer column names from earlier prose or use an incomplete list. Distinguish material identity/content fields from operational batch/source metadata. For every field state whether the importer currently passes, converts, resolves, supplies default, or leaves it null.

Preserve all existing records. Anomalous/reaction/attachment-only/system rows must not be silently dropped merely because they are not ordinary text messages.

**Special caution:** If sender resolution or a fallback requires querying a database, the query stays in the importer. The pure projection receives the **already-resolved value and the explicit raw facts**. It must not know a DAO, SQLite handle, Riverpod provider, global source, clock, or mutation capability.

---

## 4. Characterize the actual writer before changing it

Create a focused characterization harness that invokes the **existing production `MessageImporter`** against a disposable synthetic `ReadOnlySourceDatabase` and the actual source-scoped import ledger/database API. Do **not** characterize a handwritten expected transformation as a substitute for the writer.

Before editing production code, capture and save deterministic expected results from that importer:

- complete persisted `messages` row/value maps in stable source order;
- exact packed IDs, source IDs/ROWIDs and GUIDs;
- the existing sender/association/lookup behavior;
- every date conversion, including null/zero/boundary/negative cases as applicable to current code;
- null/blank/Unicode/message-text/attributed-body values and raw flags;
- source-scoped batches and batch references;
- duplicate/incremental re-import behavior;
- anomaly counts and progress begin/update/finish events;
- rows retained despite unusual types, missing associations, source flags or absent message text;
- any actual omission/refusal decisions.

Include enough synthetic rows to exercise more than one keyset page if the fixture can do so without becoming broad or slow. Keep text/blobs entirely fixture-local. Never output user content to logs.

Compare operational wall-clock timestamps by their **existing semantic contract** (for example UTC/type/presence), not a fabricated fixed time. Keep exact row and identity equality for all deterministic material fields.

Run the characterization suite **on unmodified production code**, record its passing baseline and fixture row/progress summaries, and only then begin extracting functions. If the baseline cannot be made deterministic using supported existing APIs without changing SQL or behavior, **STOP AND REPORT**.

---

## 5. Extract one shared typed canonical projection

Create the smallest pure synchronous boundary that represents the current source-row transformation, conceptually:

```dart
MessageSourceProjectionResult projectSourceMessage(
  ... raw source columns,
  ... explicit sourceId / batchId,
  ... explicitly resolved sender or association inputs,
);
```

Use the codebase's actual naming and value-object conventions; the example is not a prescribed signature.

Requirements:

- Typed immutable input/output for consequential raw and projected facts. Prefer named fields over untyped positional data.
- The projected row exposes the **same exact insert-value shape** the existing ledger writer already accepts. Do not create another insertion policy.
- Any current refusal/omission (only if source tracing proves one exists) has a typed source-grounded reason. Do not introduce new filtering.
- Preserve raw attributed-body bytes and all existing message fields exactly; **do not** perform rich-text decoding or enrichment.
- Delegate to existing `SourceScopedRowKey`, `DateConverter`, and other canonical pure helpers rather than duplicating their logic.
- Database-dependent sender/association resolution remains importer-owned, performed at the same point and ordering as before, then provided explicitly to the pure projection.
- Preserve source identity, GUID reference normalization, anomaly flags, NULL/default behavior, and the exact ledger insert shape.
- No I/O, SQL, `Future`, `Stream`, `Timer`, wall clock, filesystem, native plugin, provider, progress callback, mutation capability, or UI import in the projection.
- No new versioned decoder, classifier, row reader, or general import framework.

Modify the production importer to call the shared projection for the **existing** row-formation path. It still owns all source I/O, queries, paging, stateful lookups, transactions, batches, writes, errors, progress, and lifecycle.

There must be **one** canonical row-mapping path in the importer after extraction, with no duplicate residual transformation branch. Keep the projection concrete so a future witness cannot receive an alternative strategy implementing different semantics.

If the existing behavior depends on unextractable state in a way that cannot be passed explicitly without moving the lookup or changing ordering, narrow the slice further or STOP. Explain exactly what is missing; do not counterfeit purity.

---

## 6. Direct projection tests

Test every field/decision in the actual schema, including:

- packed identity and source lineage;
- raw GUID, associated references, sender/handle and all existing resolved fields;
- timestamp conversion through the current authority;
- null/empty/whitespace/Unicode text and attributed-body blob preservation;
- unusual system, reaction, direction, service/error/source flags;
- absent lookup targets and existing fallback semantics;
- any proven invalid/omitted row behavior;
- immutable output and no source-row mutation;
- an irrelevant context change leaving canonical output unchanged, and a material input change causing the correct output change.

Do not amend baseline expectations to accommodate the extraction. If post-extraction output differs, restore/fix the implementation, not the test fixture.

---

## 7. Writer parity after extraction

Rerun **the identical** pre-extraction characterization without changing its expected persisted row maps, selection/query expectations, ordering, or progress assertions.

Require:

```text
pre-extraction actual writer output
==
post-extraction actual writer output
```

for all material deterministic rows, IDs, associations, anomalous records, omissions, counts, error behavior, and progress events.

Run incremental/multi-page parity where the source contract supports it. Confirm that rich-text enrichment still runs separately through the prior owner and that no new decoder or enriched-text interpretation was introduced.

Also verify regression against the just-extracted Contacts projection; changes in the Messages file must not alter Contacts import behavior or source registry/batch policies.

---

## 8. Architecture enforcement

Add focused mechanical assertions that:

1. the pure projection package is free from DAO/SQLite, Riverpod, Flutter, I/O, clocks, workers, mutating importers, process and archive authority;
2. the Messages importer uses that **one actual projection implementation**, not a local reimplementation;
3. the existing row identity/date utility authorities remain in use;
4. raw source SQL, paging and transaction ownership remain in the importer;
5. the rich-text enricher and graph/FTS writers are unchanged;
6. no second source scanner or AppCzar fact/evaluator is added;
7. neither Start Fresh nor Local Data Repair receives a new destructive eligibility result;
8. the seven-jurisdiction census, production activation disabled, adoption gate, and one currentness worker remain intact.

Prefer AST/dependency boundary assertions to brittle string matches, while enforcing actual concrete call edges where useful.

---

## 9. Validation matrix

Run in dependency order:

1. frozen pre-extraction Messages writer characterization (already recorded);
2. direct pure Messages projection tests;
3. unchanged production importer characterization after extraction;
4. existing Messages importer/rich-text/enrichment/source-scoped ledger tests;
5. source-scoped import, DateConverter, Contacts extraction and identity tests;
6. graph message/classification/handle/FTS regressions (without editing graph code);
7. Onboarding/Data Update/Local Data Repair/Operating currentness regressions;
8. archive/attachment/historical-source regressions;
9. AppCzar development and inactive production composition regressions;
10. complete architecture/forbidden-import suite;
11. `flutter analyze`;
12. complete deterministic `flutter test` suite;
13. formatting, generated-code consistency if applicable, `git diff --check`, staged diff hygiene;
14. canonical Project Conformance audit (BLOCKER 0, SHOULD FIX 0).

No app build/launch and no real-data qualification.

Report actual unique full-suite counts; do not sum overlapping focused groups.

---

## 10. Stop gates

**STOP AND REPORT; leave no exploratory source diff or partially changed importer** if any of the following occurs:

- original production writer behavior cannot be characterized before editing;
- unchanged pre/post characterization differs in even one material row/decision;
- an anomalous message would be omitted, normalized differently, or enriched at a different time;
- a query, paging or transaction boundary must change;
- sender/association/stateful lookup would move to a pure module or run in a new order;
- an existing source field is not accounted for in the canonical output;
- the extraction depends on copying DateConverter, packed-ID, decoder, association or classification rules into a second implementation;
- touching graph, FTS, rich-text enricher, handles/chats/attachments/Contacts importer, or changing schema becomes necessary;
- Start Fresh or reconstruction equivalence would be represented as proved by this partial slice;
- any mutation authority/adoption/production activation would change;
- full conformance or tests cannot pass.

A safety stop is a legitimate and truthful outcome. Do not commit a half-extracted module.

---

## 11. Git checkpoints and recovery anchor

If, and only if, source parity and every validation gate pass:

- commit a narrow implementation, suggested subject:
  `refactor(import): extract canonical Messages source projection`;
- stage only intended source/test/architecture files;
- push normally without rebase, force, squash, unrelated staging, or submodule changes;
- write `Response 94` in the numbered Feature 34 `01-ONBOARDING/responses/` directory;
- checkpoint Prompt 94 and Response 94 as a separate documentation-only commit, then push normally;
- report the exact implementation commit, final documentation commit and synchronized branch state (documentation response cannot contain its own resulting hash; give it in final handoff).

No build identity/hash is required because this prompt does not build an artifact.

If a stop gate is hit, restore the tracked source/tests to the baseline and produce an uncommitted Response 94 explaining the factual blocker, following the precedent from Response 91. Do not represent the stop as an implementation PASS.

---

## 12. Required Response 94

Record, with concrete source/test evidence:

1. baseline branch/HEAD/upstream/submodule/worktree verification;
2. exact Prompt 93 / Response 93 documentation checkpoint or recovery;
3. immutable input source and pre-edit production writer call graph;
4. complete import messages-table persisted column inventory;
5. exact source query ordering/page/transaction/batch/progress inventory;
6. stateful sender/association lookup ownership;
7. raw text/blob/rich-text enrichment boundary;
8. current anomaly/omission/duplicate semantics;
9. pre-edit characterization fixture creation and **actual writer** output;
10. baseline test result before source edit;
11. canonical pure projection input/output/result contract;
12. canonical utility reuse and no duplicated logic;
13. actual importer consumer call edge and removed duplicate row mapping;
14. unchanged SQL/paging/transactions/lineage/progress;
15. post-edit unchanged-characterization comparison;
16. explicit anomaly, unusual rows and rich-text preservation;
17. direct projection test matrix/result;
18. source-scoped ledger / Contacts parity regression result;
19. graph, FTS, update, Onboarding and currentness regression results;
20. AppCzar and archive authority regression results;
21. architecture enforcement and forbidden imports;
22. analyzer / full Flutter / formatting / generated-code / diff hygiene;
23. actual Project Conformance verdict and BLOCKER / SHOULD FIX;
24. bounded implementation diff inventory and implementation checkpoint hash;
25. documentation checkpoint and pushed recovery anchor;
26. final branch/upstream/index/worktree/submodule status;
27. readiness for the **next separate small extraction**;
28. explicit blocked state of full reconstruction witness, Stage 2C, Stage 2D, staged rehearsal and production activation.

Conclude exactly:

`CONTACTS EXTRACTION CHECKPOINTED: YES / NO`

`ACTUAL MESSAGES IMPORTER CHARACTERIZED BEFORE EDITS: YES / NO`

`CANONICAL MESSAGES SOURCE PROJECTION IS PURE AND SHARED: YES / NO`

`PRODUCTION MESSAGES IMPORTER HAS ONE CANONICAL ROW-TRANSFORMATION PATH: YES / NO`

`MESSAGES PERSISTED OUTPUT, ANOMALIES, AND PROGRESS PARITY: PASS / FAIL / NOT REACHED`

`NO RICH-TEXT, GRAPH, FTS, OR OTHER IMPORTER BEHAVIOR CHANGED: YES / NO`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT NARROW SHARED-TRANSFORMATION EXTRACTION: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then **STOP**. Do not begin handle/chat/attachment/join extraction, rich-text work, graph projection, reconstruction witness, or production cutover in the same task.
