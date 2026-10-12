# MessageLens Feature 34
## 92 — Checkpoint the Stage 2C Safety Stop and Audit the Shared Reconstruction-Equivalence Boundary

Response 91 correctly stopped the Operating-owned Start Fresh implementation at a mandatory destructive-safety gate. It found no existing read-only proof that an **established, populated** `macos_import_ss.db` plus `working_ss.db`—including graph relationships, rich-text projection, contact enrichment, canonical identities, and FTS—is wholly reconstructible from the **current** authoritative Messages/Contacts sources.

The exploratory Stage 2C edits were removed. No command, Ball, reset, host, build, launch, or mutation was retained. There is no executable AppCzar Start Fresh command yet. The production path remains legacy `StartupApp`; `ProductionAppCzarActivation.disabled` remains unconditional.

**This task is an audit/design prerequisite, not an attempt to retry Stage 2C implementation.** Before building a witness we need to determine exactly which real writer semantics can be shared, which material facts can be proven reconstructible now, which facts are irreducibly historical or volatile, and which smallest bounded extraction can be safely implemented first.

The governing Fair-Witness rule is:

> MessageLens must not delete an established derived store until current, read-only evidence proves that every consequential fact it would discard can be reconstituted from presently available authoritative inputs, and every independent protected record/reference would remain safe. Historical source provenance, matching row counts, and apparent rebuild success are not substitutes for that proof.

Do not invent a second importer or projector merely to make the proof possible. Do not quietly weaken this rule to compare message keys alone.

---

# 1. Baseline and scope

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- actual HEAD and upstream synchronized `0/0`;
- tracked worktree/index clean;
- exactly one Feature 34 worktree;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- no unrelated untracked files staged or modified.

Response 91 reports the starting HEAD as:

`937ad5d28c067d47bbbf5461ef010641c07ead9d`

Resolve the actual state from Git, do not assume it has remained unchanged. Verify Stage 2B implementation `3c5a5774aeea20d32587e00c0b75d046043ba9fb` and documentation `0c2ce29c17b44afb36790d675f5e0b364ab5cc2e` in ancestry.

Read in full:

- Response 78 and its Local Data Repair schema-wide safety audit;
- Response 79 and its implementation of the **empty-graph-only** reconstruction reader;
- Response 80 and its live Local Data Repair qualification;
- Response 85 whole-repository production cutover audit;
- Response 87 shell audit;
- Response 90 Operating Start Fresh audit;
- Response 91 failed implementation and exact missing-proof account;
- current importer, Contacts extraction, rich-text decoding, source registry/lineage code;
- current graph projector, canonical-handle derivation, FTS/index creation;
- attachment metadata/coverage, historical-source representation, overlay/Presence references;
- `MessageDataResetService`, existing physical witness, protected preservation code;
- canonical Project Conformance standard.

Create an external Git/source-only baseline manifest.

No real user data, real archive or current production/development database may be opened, read, enumerated, copied, or modified. No application build or launch. No fixtures or test runs are needed in this audit.

---

# 2. Checkpoint the stopped Prompt 91/Response 91 honestly

Prompt 91 and Response 91 remain untracked. Create one narrow **documentation-only** checkpoint containing exactly these two files. Check the staged diff, commit and push normally before proceeding with source audit.

The checkpoint must preserve the distinction:

```text
Stage 2C implementation: NOT IMPLEMENTED
Project Conformance for attempted implementation: FAIL (missing mandatory proof)
Compliance of fail-closed STOP: PASS
One unresolved implementation blocker: populated-footprint reconstructibility
Exploratory implementation edits: removed
AppCzar Start Fresh Ball / reset / route: not added
Legacy production Start Fresh: unchanged
Production AppCzar activation: disabled
```

Do not reclassify Prompt 91 as a successful Stage 2C implementation or create a source checkpoint for edits that were reverted. Record exact documentation commit and upstream state.

---

# 3. Reconfirm current authority census and non-interference

The existing seven AppCzar jurisdictions remain exactly:

```text
Data Update
Source Access Repair
Attachment Archive Repair
Onboarding
Local Data Repair
Diagnostic Review
Operating Session
```

Operating-owned Start Fresh remains an unimplemented *command*, not an eighth jurisdiction.

Confirm the current production selector remains `StartupApp`, development still selects AppCzar under exact admitted identity, and the process restarter remains development-only. Do not modify any selector, mutation capability, release metadata, signing, native admission, or operation gate.

---

# 4. Exact definitions: what does 'reconstructible' mean?

Define three distinct propositions without conflating them:

1. **Authoritative inputs currently obtainable:** Messages/Contacts source facts exist and can be read stably under the actual importer's semantics.
2. **Material equivalence:** every consequential local import/graph fact that deletion would lose can be regenerated from those current inputs, using the same canonical mappings, projections, and relevant deterministic configuration. Equality of GUIDs or counts alone is not enough.
3. **Independent preservation:** overlay, Presence, attachment archive, historical-source registry, user authored state, configuration, bookmarks, journals, receipts, and any references to derived identities remain unchanged and semantically safe after rebuild.

Specify the smallest exact `TRUE / FALSE / UNKNOWN` proposition for each. A complete positive reset authorization requires **all** relevant propositions TRUE at plan time and on fresh pre-Ball revalidation.

Do not infer reconstructibility from a previous successful import, a historical batch log, `source_id=live_chat_db`, `MAX(ROWID)`, or an absence of errors.

---

# 5. Schema-wide deletion footprint and column-level inventory

Source-trace the exact current schema—not just conceptual domain names—of the active import database and graph database, including relevant indexes and FTS virtual/shadow tables. Build a reproducibility matrix **for each consequential table and material column/relationship**.

At minimum cover import:

```text
source_registry
import_batches
messages
handles
chats
chat_to_message
chat_to_handle
contacts
contact_channels
attachments
message_to_attachment
```

and graph:

```text
messages
message_text_fts and its FTS material/maintenance
handles
canonical_handles
handle_aliases
chats
chat_to_message
chat_to_handle
contacts
contact_to_handle
attachments
message_to_attachment
```

Include any additional current schema facts found in the actual source and tables/views/triggers/FTS metadata important to reconstitution. Do not treat the enumerations above as complete if the source differs.

For each material fact record:

- its table/column (or index/virtual-table) and meaning;
- exact production writer and source file/method;
- original authority/source input(s);
- normalization/transformation or join rule;
- stable versus time-dependent/derived/cached nature;
- present availability of the input and failure modes;
- whether exact equivalence is required or some lossless semantic equivalence is demonstrably sufficient;
- whether the fact is protected, uniquely local, or linked to protected records;
- whether a read-only witness could prove it **without** running a mutating writer;
- existing automated test/fixture evidence, if any;
- the exact unresolved seam blocking proof.

A table left unclassified must force aggregate proof UNKNOWN, not become an implicitly disposable table.

---

# 6. Canonical importer transformation inventory

Trace source-to-import transformations including:

- canonical source and donor identities, row IDs/GUIDs, packed IDs, lineage;
- batches, high-water/cursors, timestamps and timezone normalization;
- chat and handle fields and joining keys;
- rich text, typedstream decode, reactions/edits/metadata when represented;
- attachment metadata, MIME, source path, per-message joins;
- Contacts name/organization/address/phone projections and mutable enrichment;
- nullable/deleted source values, duplicates and collision rules;
- error fallback semantics and skipped/opaque records.

For each transformation identify the **one current authoritative implementation** and whether it is pure today, can be made pure without changing behavior, or depends materially on a mutating repository/provider/transaction.

A helper with the same name but different SQL, decode policy, ordering, or handling of nulls does not count as shared semantics.

---

# 7. Canonical graph projection and FTS inventory

Trace import-to-graph transformations including:

- message body/text/rich content and media/attachment indicators;
- participant handles, canonicalization, alias expansion and deduplication;
- chat IDs and participant/group joins;
- contact resolution/linkage and missing-contact behavior;
- message-to-chat and message-to-attachment edges;
- FTS tokenization, normalization, field selection, maintenance, triggers and shadow/virtual tables;
- any graph-only synthesized field or classification;
- schema-version or feature-policy effects.

Identify which graph facts are **functions of current import facts** versus facts obtained independently from an external source or protected user input. A graph row count matching import row count does not prove equivalence.

Determine whether FTS requires comparison of an index's physical bytes or proof that the same canonical indexed content and schema/tokenizer configuration regenerate an equivalent search index. Justify the equivalence relation, not merely its convenience.

---

# 8. Volatile inputs and exact equality pitfalls

Audit where bytewise equality would be impossible or misleading even for a legitimate rebuild, including:

- import batch IDs, timings and counters;
- SQLite rowid allocation/order and WAL pages;
- schema migrations and creation timestamps;
- source/Contacts changes during the snapshot;
- indexing/tokenizer/library-version differences;
- rich-text fallback/decoder behavior;
- normalization upgrades;
- file paths or bookmarks that may change independently.

Distinguish incidental, safely reproducible metadata from **material but not currently reconstructible historical information**. Do not silently declare all metadata incidental: protected or operationally meaningful provenance can be consequential even if it is not shown in UI.

Propose a documented, per-domain semantic equivalence relation only where it can be proven without loss. For any unique historical or time-dependent fact whose loss matters, the result must be FALSE/UNKNOWN and Start Fresh must be refused.

---

# 9. Full populated-data comparison approaches

Compare at least these possible architectures against Response 91's prohibitions:

**A. Shared pure canonical row/projector functions plus bounded read-only anti-difference.** Production importer/projector and witness invoke the same functions, but the witness never opens a writable target or creates databases.

**B. Read-only source and target SQL joins against deterministic canonical projections.** Same domain mapping contract, no independently invented SQL semantics. Specify feasibility of cross-file SQLite attachment/read-only mode and connection isolation without copying real stores.

**C. A safely generated candidate model in memory without any persistent DB.** Consider only if truly bounded and does not silently duplicate FTS or rich-text policy.

**D. A conservative unambiguously safe subset rather than all established Operating installations.** If any populated graph is impossible to prove without a large refactor, identify whether a smaller but *still genuinely populated and material-equivalent* subset exists. Do not relabel an empty graph or one-message import as proof of full Operating reset.

For each: source reuse, needed extraction, equivalence proof, computational cost, SQLite/provider side effects, TOCTOU protection, protected-state interactions, and risk of a second semantic implementation. Recommend one explicit approach and reject unsupported ones.

This audit MUST NOT implement or run a candidate rebuild, create any database, or query real sources.

---

# 10. No second importer / projector authority

Design the dependency direction:

```text
canonical pure source-to-import transformations
        -> production importer
        -> read-only reconstruction witness

canonical pure import-to-graph transformations
        -> production graph projector
        -> read-only reconstruction witness
```

The witness must not become a competing importer, startup evaluator, background currentness worker, recovery coordinator, or new jurisdiction. It reports bounded physical/reconstruction evidence to an Operating-owned Start Fresh command only; AppCzar remains the sole top-level disposition authority.

Specify testable mechanical enforcement (import boundaries, forbidden dependencies, parity fixtures, no new writer/SQL implementation) to prevent later divergence.

---

# 11. Protected references and semantic equivalence after rebuild

Audit references from:

- `user_overlays.db` including favorites, tags, manual links, attachment archive registry, and preserved settings;
- `presence.db`;
- historical source registry and donor/recovery records;
- attachment coverage and content-addressed payload records;
- preferences, journals, bookmarks, location-generation references.

Determine whether any preserved record references a graph/import identifier whose reconstruction could change. Explain how referential validity and meaning would be proven **without modifying** those protected stores.

A byte-identical overlay with dangling or reinterpreted references is not sufficient preservation.

If a currently implemented writer cannot reproduce stable identities necessary to preserve user intent, record this as a blocking fact.

---

# 12. Source-absent attachment debt and external archive

Trace why Operating may admit known source-absent attachment debt yet Start Fresh must refuse any reset that could lose attachment identity, metadata, or link information.

Prove the boundary between reconstructing attachment **metadata and joins** and preserving archived **payload bytes**. Do not inspect payload bytes, use an archive payload scan as a source substitute, or allow the attachment archive to become a cleanup target.

Retired files, historical sources, pending relocation journals, unknown or conflicting archive generation, and uninspectable protected references must block a destructive command.

---

# 13. Stable present-tense snapshot and TOCTOU design

Design how one witness can establish a coherent read-only observation of:

- canonical Messages source identity, key set and material fields;
- current AddressBook fields when required;
- active import and graph material;
- relevant protected references and archive binding/generation;
- exact Operating occurrence and currentness state.

Specify transactions/snapshot semantics for source and local SQLite files as permitted by the current code, bounded paging and memory, identity/fingerprint checks, mutation-generation fences, and revalidation after human consent before Ball.

Do not treat two sampled counts as a whole-row snapshot or guarantee external sources cannot change between reads. Where no atomic cross-database snapshot exists, describe a strict fail-closed stability protocol and its remaining race risks.

---

# 14. Performance bounds and refusal semantics

A full graph can include over 100,000 messages and many relationships/FTS entries. Determine plausible bounds for observation duration, memory, per-page work, cancellation, and UI responsiveness. Define what happens when a comparison is prohibitively expensive or cannot complete: **UNKNOWN -> no Start Fresh mutation**, not an automatic fallback to a weaker proof.

Do not make detailed historical user data appear in diagnostic logs, UI, support bundles, or test fixtures.

---

# 15. Reuse of existing Stage One Local Data Repair proof

Separate:

- source-/import-domain machinery that Response 79 made trustworthy;
- its deliberately empty-graph precondition;
- missing full graph/FTS semantic equivalence;
- differences between an automatic repair disposition and voluntary Operating command.

Do not weaken Local Data Repair's existing fail-closed predicate or reuse a `TRUE` from that predicate as permission to reset a populated Operating graph.

A future shared lower reader may serve both use cases only if all old contracts remain intact and explicit tests prove no previously denied class becomes automatically repairable.

---

# 16. Incremental extraction plan—not one giant refactor

Produce the **smallest dependency-ordered milestones** that can safely deliver canonical shared transformations with zero behavior change to writers:

1. audit and select the first pure transformation family;
2. extract it without changing importer/projector output;
3. establish golden/parity/metamorphic tests using disposable or in-memory sources;
4. prove the production writer now actually calls the extracted function;
5. expose a read-only observational use in a later milestone;
6. repeat for other families until a complete populated-footprint witness is possible;
7. only then resume Operating Start Fresh implementation.

For each milestone: exact files likely touched, one observable acceptance condition, test scope, migration/compatibility impact, stop gates, and recovery checkpoint.

Prefer an initial slice that can be mechanically proven from code and existing tests. Do not try to extract rich-text decoding, Contacts enrichment, graph canonicalization, all joins and FTS simultaneously.

If no small extraction is semantically safe, say so and propose a narrower prerequisite design task rather than write speculative code.

---

# 17. Explicit option to stop the Start Fresh product feature

Compare the cost and remaining risk of complete proof extraction against leaving Start Fresh unavailable under AppCzar and preserving the established local dataset. Do not assert production cutover can safely proceed without feature parity; that is a separate product/authorization decision.

Any alternative such as creating a separate generation while retaining the old one must be labeled a **different feature design** requiring its own storage, identity, recovery and retention audit; it is not automatically authorized by this task.

---

# 18. Architecture and automated proof plan

Specify future tests for:

- every consequential source-to-import mapping and populated graph domain;
- rich-text and reactions/edits when source semantics require them;
- current Contacts changes and volatile enrichment;
- missing/deleted source facts, source identity mismatch, unstable source;
- historical/non-live, corrupt/unsupported/retired, and unreadable ledger;
- graph aliases/joins, FTS content and tokenizer/schema drift;
- protected overlay references and ID stability;
- source-absent attachment debt and archived metadata;
- zero writer/database creation by the witness;
- bounded memory, paging, cancellation and stale-generation refusal;
- TOCTOU revalidation and archive binding changes;
- unchanged importer/projector output before/after each pure extraction;
- no production activation, mutation Ball, restart, additional currentness worker, or eighth AppCzar jurisdiction.

Identify which tests can be added in the **first slice** and which remain downstream.

---

# 19. Audit-only execution rules

Default and intended result: **source-grounded design/audit only**.

Do not:

- edit application, test, generated, native, release, signing, or packaging source;
- run tests, formatters, analyzer, code generation, builds, installers or app launches;
- create/modify SQLite fixture files or real databases;
- touch WD/Toshiba production or development archives;
- change FDA/TCC, environment variables, markers, UUIDs, bookmarks or process state;
- run an importer, graph projector, Start Fresh service, reset, or migration;
- begin Stage 2D shell work or any cutover/rehearsal;
- create a generic framework or new semantic coordinator.

If source exploration suggests a code experiment is the only way to establish a required design fact, STOP with a precise unanswered question rather than silently turning this into implementation.

---

# 20. Project Conformance audit

Run the canonical Project Conformance audit **for the proposed design**, not for unimplemented code. PASS only if there are no unresolved conceptual BLOCKER/SHOULD FIX findings within the design scope; separately list prerequisite implementation blockers.

Verify one semantic authority, one canonical mapping implementation, present-tense proof, fail-closed unknowns, protected evidence preservation, bounded I/O, no second writer, no Ball in read-only proof, no production selector change, and no claims of implementation or human qualification.

---

# 21. Final Git/documentation handling

After checkpointing Prompt 91/Response 91, leave Prompt 92 and Response 92 untracked/unstaged for the next review checkpoint. Do not commit generated source, code edits, unrelated untracked content, or temporary manifests. Report exact checkpoint commit, upstream sync, index, worktree, and pinned shared submodule.

No implementation commit, release artifact, or build is expected.

---

# 22. Required Response 92

Create Response 92 and report:

1. baseline Git/branch/upstream/submodule;
2. Prompt 91/Response 91 **failed implementation, safe stop** documentation checkpoint;
3. seven-jurisdiction/disabled-production census;
4. exact deletion footprint and current schema version/column inventory;
5. imported table-by-table material mapping matrix;
6. graph/FTS table-by-table material mapping matrix;
7. actual source importer method/file authority for each family;
8. actual graph projector method/file authority for each family;
9. rich-text/typedstream/reaction source transformation result;
10. Contacts enrichment/projection source transformation result;
11. canonical handles, joins, identity, timestamp and attachments semantics;
12. import batch/ledger/provenance reproducibility classification;
13. FTS semantic equivalence and version/tokenizer drift;
14. stable versus temporal/incidental versus unique protected facts;
15. comparison of candidate witness architectures;
16. recommended single-source canonical mapping architecture;
17. source and target snapshot/stability/TOCTOU design;
18. source-absent historical messages and attachments refusal;
19. protected overlay/Presence/historical/archived-reference equivalence;
20. any irreducibly nonreconstructible fact;
21. exact positive proof predicate and UNKNOWN/FALSE rules;
22. performance and boundedness proposal;
23. existing Local Data Repair reader reuse, limits, and nonregression;
24. dependency-ordered extraction milestones with exact proposed files;
25. **smallest first implementation slice**, tests, and STOP gates;
26. why larger simultaneous refactor is rejected;
27. alternative of leaving AppCzar Start Fresh unavailable;
28. future end-to-end witness test/fixture plan;
29. future human qualification after witness and Stage 2C implementation;
30. Project Conformance design verdict and BLOCKER/SHOULD FIX findings;
31. whether implementation, test/build, fixture or real data work occurred;
32. final Git/index/worktree/submodule state;
33. readiness for the first shared-transform extraction;
34. readiness to resume actual Stage 2C Start Fresh;
35. readiness for Stage 2D, production rehearsal and cutover.

Conclude exactly:

```text
STAGE 2C UNSAFE IMPLEMENTATION STOP CHECKPOINTED: YES / NO
FULL POPULATED DATASET RECONSTRUCTION EQUIVALENCE CURRENTLY PROVEN: YES / NO
CURRENT WRITERS HAVE ONE SOURCE-GROUNDED REUSABLE TRANSFORMATION AUTHORITY: YES / NO
ALL CONSEQUENTIAL IMPORT AND GRAPH/FTS DOMAINS INVENTORIED: YES / NO
UNIQUE PROTECTED OR TEMPORAL FACTS ARE NOT SILENTLY CLASSIFIED DISPOSABLE: YES / NO
A BOUNDED READ-ONLY WITNESS DESIGN IS SOURCE-GROUNDED: YES / NO
OPERATING START FRESH IMPLEMENTED BY THIS PROMPT: NO
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO
PROJECT CONFORMANCE: PASS / FAIL (AUDIT/DESIGN SCOPE)
READY FOR FIRST NARROW SHARED-TRANSFORMATION EXTRACTION: YES / NO
READY TO RESUME STAGE 2C DESTRUCTIVE START FRESH IMPLEMENTATION: NO
READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
```

Then STOP.
