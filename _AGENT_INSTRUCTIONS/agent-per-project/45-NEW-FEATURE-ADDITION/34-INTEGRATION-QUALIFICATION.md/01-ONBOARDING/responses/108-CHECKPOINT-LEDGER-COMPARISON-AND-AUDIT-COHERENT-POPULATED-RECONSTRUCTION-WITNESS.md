# MessageLens — Feature 34
## Response 108 — Checkpoint Ledger Comparison and Audit Coherent Populated Reconstruction-Witness Architecture

**Date:** 2026-10-14
**Task type:** Read-only architecture and design audit
**Result:** The ledger comparator checkpoint is present and pushed. The repository has useful disposable material-comparison components, but it does not yet have a coherent populated reconstruction witness. No reset authority follows from the existing evidence.

## 1. Fair Witness baseline

The repository was inspected before this response was created.

- Repository: `/Users/rob/Development/FlutterProjects/remember_every_text`
- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `0ca390259ab2ddbbdc35889d39551b77ac8d63b1`
- Upstream: `origin/fix/onboarding-import-stuck-state`
- Ahead/behind: `0/0`
- Tracked worktree: clean
- Index: clean
- Feature 34 worktrees on this branch: exactly one
- Shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- Pre-existing untracked inventory: 49 entries before this response, including untracked Prompt 108; none was modified

Prompt 107 and Response 107 were already committed and pushed together. The documentation checkpoint is:

```text
0ca390259ab2ddbbdc35889d39551b77ac8d63b1
docs(feature34): record ledger material equivalence qualification
```

The corresponding implementation checkpoint is:

```text
f477f6858a62ab8849c9e0f254c9312cebea391a
test(import): qualify ledger material equivalence
```

Both are ancestors of HEAD. No duplicate Prompt 107 checkpoint was created.

The nine canonical transformations and the Response 105–107 implementation checkpoints required by Prompt 108 were verified as ancestors. In particular, the source transformations for contacts, messages, handles, chats, attachments, the three relationship families, and rich-text semantics are all present. This audit did not rerun suites whose attributable results are already recorded in Responses 105–107.

## 2. Scope and method

This was source/test inspection only. I did not:

- edit tracked source, tests, schema, generated files, or release metadata;
- build or launch MessageLens;
- open a real Messages, Contacts, MessageLens, Presence, overlay, graph, or import database;
- inspect WD or Toshiba archives or any attachment payload;
- mutate an archive, FTS index, database, permission, bookmark, or environment;
- stage, commit, push, merge, or activate production AppCzar;
- implement a reconstruction witness or authorize destructive Start Fresh.

The only repository write is this untracked Response 108.

## 3. Reusable evidence-seam inventory

### 3.1 Canonical source transformations

| Seam | Kind | Capabilities | Suitable future use | Populated-installation limit |
|---|---|---:|---|---|
| `projectContactSourceRows` | Production pure projection | None | Reuse for expected contact and channel rows | Row-bounded, but admission/omission and paging remain caller-owned |
| `projectMessageSourceRow` | Production pure projection | None | Reuse for all source message facts, packed identity, timestamps, and attributed-body bytes | One row at a time; source window and occurrence identity are outside it |
| `projectHandleSourceRow` | Production pure projection | None | Reuse for normalized handle material | `isMe` remains caller-supplied evidence |
| `projectChatSourceRow` | Production pure projection | None | Reuse for chat material without participant inference | Does not establish endpoint existence or additive writer semantics |
| `projectAttachmentSourceRow` | Production pure projection | None | Reuse for source attachment metadata | Deliberately has no payload/archive access and proves no payload coverage |
| `projectChatMessageRelationshipSourceRow` | Production pure projection | None | Reuse after endpoint admission | Does not itself prove either endpoint exists |
| `projectChatHandleRelationshipSourceRow` | Production pure projection | None | Reuse after endpoint admission | Does not itself prove either endpoint exists |
| `projectMessageAttachmentRelationshipSourceRow` | Production pure projection | None | Reuse after endpoint admission | Does not itself prove either endpoint exists |
| `projectMessageRichTextSemanticResult` | Production pure semantic projection | None after decoder evidence is supplied | Reuse for persist/empty/failure semantics | Decoder identity and execution remain external evidence |

These seams are immutable and capability-free. They are necessary but not sufficient. They do not own source occurrence identity, source registry allocation, import batch lineage, paging, existing-row admission, duplicate handling, or transaction semantics.

### 3.2 Production source reading and stateful import semantics

`MessageImporter.importNewMessages` is production code. It:

- opens the Messages source read-only;
- freezes a count and high-water for rows after the current ledger cursor;
- reads keyset pages of 500 by source `ROWID`;
- checks existing GUIDs in chunks of 500;
- performs one ledger transaction per page;
- uses insert-ignore behavior for already admitted occurrences;
- validates that the completed count matches the frozen window;
- closes the source in `finally` and yields between pages.

It is a mutating importer and cannot be run against live stores by a read-only witness. Its incremental cursor also does not rediscover mutations below the previous cursor. A witness must reuse its admitted rules in a disposable replay or a separately authorized read-only characterization seam; it must not infer them only from the pure row projections.

`SqfliteSourceDatabaseOpener` is a production read-only source opener. It uses `readOnly: true`, `singleInstance: false`, `PRAGMA query_only=ON`, and a bounded busy timeout. It can be reused for a source occurrence only if the future witness adds bounded paging, identity binding, and interval stability. Its API does not expose a single transaction spanning all source queries.

The present lineage reader validates live source GUID/`ROWID` against packed ledger identity, but materializes all source rows and all corresponding ledger rows. It is capability-free and read-only but is not suitable for a populated installation without pagination and resource limits.

Historical source identity is production code. A Mac Messages historical source key is the normalized absolute path to its `chat.db`, prefixed by the historical source kind. Registration calls `getOrCreateSource`, so registry allocation is stateful. Path identity remains usable when offline, but path identity alone does not prove that a later file at the same path is the same physical occurrence.

### 3.3 Import-ledger material evidence

Response 107 qualified a test-only comparator over disposable production-schema ImportDatabase instances. It covers all 11 ledger tables:

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

It validates schema shape, column material, null/missing distinctions, blob equality, packed identities, references, and bidirectional missing/extra/changed rows. The qualified timestamp exception is narrow: `source_registry.created_at_utc` and `import_batches.started_at_utc`/`finished_at_utc` are operational, so exact bytes may differ only after required/null/UTC/batch-lifecycle semantics are validated. No other field receives that exception.

The snapshot reader rejects a table above 10,000 rows. It then retains every captured row and comparison index in memory. The diagnostic limit bounds retained examples, not scanning, total diff counting, or material retention. It is suitable for disposable qualification fixtures, not a populated production installation.

### 3.4 Graph replay and material evidence

Responses 105–106 qualified a test-only disposable production-writer replay and comparator. The replay uses actual production repositories against disposable ImportDatabase and ConversationGraphDatabase instances. The graph comparator covers every column of the 11 material graph tables:

```text
messages
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

It performs bidirectional missing/extra/changed comparisons and preserves null-versus-absent distinctions. It deliberately retains the known stateful nonconvergence cases: additive or insert-ignore writers can leave stale contacts, chats, edges, or other rows in an observed populated graph even when another additive replay over that graph succeeds.

The harness owns disposable paths and closes/deletes them, including failure cleanup. Its graph snapshot has no row bound and retains all table material in memory. Its comparator also builds complete in-memory indices and full key unions. It is therefore a feasibility/characterization harness, not a production-scale witness.

### 3.5 FTS evidence

Conversation Graph schema version 3 uses an external-content FTS5 table:

```text
content='messages'
content_rowid='ss_id'
tokenize='unicode61 remove_diacritics 2'
prefix='2 3 4'
```

AFTER INSERT, DELETE, and UPDATE OF `text` triggers maintain the index. Production search uses `MATCH`, joins the graph `messages` table, applies scope and overlay tag logic, orders results, and applies limits.

Existing disposable tests establish FTS5 availability and a finite corpus covering case, diacritics, quoted punctuation, prefix, Unicode, update, and null cases. They also preserve a known unquoted punctuation/parser behavior. These are useful runtime characterizations, not exhaustive index proof.

The current graph replay helper's `SELECT rowid, text FROM message_text_fts` is not an internal-index comparison. For an external-content FTS table, apparent column results can be supplied from the content table. Equality there proves neither that every token is indexed nor that no stale token remains.

### 3.6 Overlay and protected intent

Overlay schema version 8 contains user-authored or compatibility references that are not rebuildable graph projection:

| Table | Referencing columns | Reference form |
|---|---|---|
| `participant_overrides` | `participant_id` | Direct graph contact ID |
| `chat_overrides` | `chat_id` | Direct graph chat ID |
| `message_annotations` | `message_id` | Direct graph message ID |
| `message_user_flags` | `message_guid` | Stable message GUID fallback |
| `message_user_tags` | `message_guid` | Stable message GUID fallback plus overlay tag |
| `conversation_tag_assignments` | `conversation_id`, `tag_id` | Direct canonical conversation ID plus overlay-local tag |
| `handle_to_participant_overrides` | `handle_id`, optional `participant_id`, optional virtual participant | Canonical handle/contact or overlay-local bridge |
| `favorite_contacts` | `participant_id` | Direct graph contact ID |
| `handle_visibility_overrides` | `handle_id` | Direct graph canonical handle ID |
| `dismissed_handles` | `normalized_handle` | Normalized-value fallback |
| `archived_attachments` | `message_guid`, `import_attachment_id`, archive material | Message GUID plus unscoped live attachment source `ROWID` compatibility tuple |
| `virtual_participants`, `overlay_settings`, tags | Overlay-local IDs/values | Protected overlay state, not graph projection |

Overlay intent must be read only. The witness may prove references; it may not rewrite keys, select a new canonical representative, delete dangling rows, or copy intent into graph projection.

### 3.7 Presence and operation evidence

Presence schema version 9 contains independent schedule, trip, step, occurrence, test-agent, choice-option, run, and append-only execution-trace state. No graph/source foreign-key dependency was found in the audited schema. It remains protected independent state. Its existence, schema, identity, and interval stability must be proven, but it must not be invented as graph reconstruction evidence.

Attachment archive evidence includes:

- an archive marker with format, environment, archive UUID, and creation time;
- immutable admitted root/environment/build/bundle/product identity;
- attachment-location configuration, resolved root, availability, and location generation;
- checkpoint receipts bound to environment, archive UUID, canonical root, manifest digest, and verification time;
- generation-bound adoption transactions with transaction UUID, previous/intended configuration, source/candidate canonical identities, source generation, structural fingerprints, verification digest, counts/bytes, and bounded remediation payloads;
- generation-bound repair observations and authorizations derived from current required/source evidence;
- callback-local mutation capability and writable-root leases for actual repair writes.

Receipts, transactions, journals, and authorizations are operation/safety evidence. They are not proof that ledger or graph material is reconstructible. A future read-only witness must inventory and fingerprint them so that an operation cannot change beneath a scan. It must never retain or request their mutation capabilities.

## 4. Required coherent cross-store observation contract

### 4.1 Bound observation identity

One witness attempt requires an immutable `ReconstructionObservationBinding` containing at least:

1. **Installation/archive identity**
   - admitted environment, archive UUID, canonical data root, marker format and digest;
   - attachment configuration, resolved attachment root, archive-scope identity, and location generation.
2. **Source-occurrence identity**
   - every live, historical, and non-live source key/kind/label;
   - canonical source path plus a read-only physical-occurrence fingerprint stronger than path alone;
   - source schema/application identity, bounded high-water/count, and stable file identity where supported;
   - exact ledger `source_registry` allocation and occurrence-to-source-ID mapping.
3. **Store identity**
   - canonical import-ledger, graph, overlay, and Presence paths;
   - schema/user versions, read-only/query-only state, journal mode, WAL identity, and file occurrence fingerprints;
   - import batch and source registry material needed to bind replay provenance.
4. **Protected operation identity**
   - overlay and Presence material fingerprints/generations;
   - archive adoption/repair journals, checkpoint receipts, pending operation IDs, and current operation generation;
   - attachment archive marker/location generation and protected-reference evidence generation.
5. **Implementation identity**
   - MessageLens build and bundle identity;
   - canonical projection contract revision;
   - rich-text decoder/runtime identity;
   - ledger schema/writer and graph schema/writer identity;
   - SQLite library version, compile options, FTS5 availability, tokenizer/query-parser contract.

The binding is evidence only. It carries no database handle, root capability, mutation capability, writer, coordinator, or policy result.

### 4.2 Bounded interval protocol

For one attempt:

1. Capture a compact **start fingerprint set** for every bound identity above.
2. Open each database/source independently read-only and query-only.
3. For each SQLite file, use one read transaction or immutable disposable snapshot whose lifetime covers all pages from that file.
4. Stream bounded pages into incremental canonical digests and bounded diagnostics. Do not retain full populated tables.
5. Derive expected ledger only in a disposable writer replay bound to the captured source occurrences.
6. Derive expected graph only from that expected disposable ledger.
7. Perform read-only protected-reference and FTS evidence checks against expected and observed identities.
8. Capture the same compact **end fingerprint set** after all readers have closed.
9. Accept the attempt only when start/end material fingerprints match and every individual snapshot retained its own verified identity throughout.
10. On the first interval mismatch, discard all material/digests and retry once from a new complete start fingerprint.
11. On a second mismatch, timeout, cancellation, unreadable input, identity ambiguity, or resource limit, return UNKNOWN and close/delete all owned disposable resources.

This is a bounded two-attempt rule. It is not an open-ended stabilization loop.

### 4.3 No cross-file atomicity claim

Separate read transactions can stabilize each SQLite database independently. They cannot produce an atomic instant across Messages `chat.db`, historical sources, the import ledger, graph, overlay, Presence, archive marker/configuration, and filesystem journals. WAL snapshots are database-file scoped. Even simultaneous `BEGIN` calls do not create a distributed transaction.

Therefore a matching start/end envelope supports only this claim:

> No material identity/fingerprint observed by the protocol changed over the bounded interval, and each per-file read came from one stable file-local snapshot.

It does not prove that all stores committed at the same instant. If an unobserved writer can change material without changing an included fingerprint, the protocol is incomplete and the answer remains UNKNOWN.

The current AppCzar assessment is not this protocol. It launches independent observations with `Future.wait`, then stores their results under one in-memory assessment generation. The generation prevents an old UI assessment from overwriting a newer one; it does not establish cross-store snapshot coherence.

### 4.4 Race analysis

| Race | Required evidence | Result when detected or unprovable |
|---|---|---|
| New Messages rows arrive during scan | Source occurrence/high-water/count and material fingerprint start/end | Retry once, then UNKNOWN |
| Import batch commits during scan | Ledger file/WAL/schema plus registry/batch/material digest start/end | Retry once, then UNKNOWN |
| Graph projection commits during scan | Graph file/WAL/schema/material digest start/end | Retry once, then UNKNOWN |
| Overlay or Presence changes | Protected-store digest/generation start/end | Retry once, then UNKNOWN |
| Attachment repair/adoption occurs | Archive marker, location generation, operation/journal/receipt fingerprint start/end | Retry once, then UNKNOWN |
| Source is replaced at the same path | Physical occurrence fingerprint plus schema/high-water/material digest | UNKNOWN unless identity is proven stable; path equality is insufficient |
| Process restarts | Attempt/process identity and ownership token | Discard; a new process starts a new attempt |
| Historical source becomes unavailable | Bound occurrence cannot be reopened/verified | UNKNOWN, not an empty source |
| Existing material differs while another domain is unreadable | Preserve the known contradiction | FALSE for the overall reconstruction claim, with incomplete domains reported separately |

### 4.5 Typed decision semantics

**TRUE** requires all of the following in one accepted interval:

- all required occurrences are known and stable;
- expected ledger replay is referentially and materially equal under the narrow operational timestamp contract;
- expected graph replay is materially equal in both directions;
- protected references resolve without ambiguity against both expected and observed identity sets;
- required FTS proof reaches its explicitly defined level;
- archive, Presence, journals, receipts, resources, and implementation identities remain stable;
- no limit, timeout, cancellation, cleanup, or unobserved-dependency gap occurred.

**FALSE** requires a known, coherent contradiction: a stable missing/extra/changed material row; a dangling or ambiguously rebound protected reference; a duplicate identity violating a required uniqueness premise; a registry reallocation; a stable source/ledger/graph provenance mismatch; or an archive-generation mismatch.

**UNKNOWN** covers unreadable/absent required evidence, changing interval fingerprints, unsupported FTS exhaustiveness, source replacement ambiguity, exceeded bounds, cancellation, failed cleanup whose ownership cannot be established, or any dependency not included in the envelope.

Known coherent contradiction takes precedence over incompleteness: the overall answer is FALSE when at least one contradiction is proven from the accepted interval, while unknown domains remain listed as unknown. A contradiction assembled across mismatched interval fingerprints is not coherent and cannot be promoted to FALSE; that attempt is UNKNOWN.

## 5. Boundedness, cancellation, and cleanup design

### Required production-scale limits

A future witness contract must declare before reading:

- maximum rows per page and maximum encoded bytes per page;
- maximum total rows and bytes per domain;
- maximum diagnostics per table/domain;
- a monotonic deadline for the full attempt and per-page work;
- a cancellation token checked before and after every I/O page, decoder batch, digest update, and writer replay transaction;
- maximum two complete coherence attempts;
- maximum disposable disk usage and minimum free-space reserve;
- maximum simultaneously open handles/transactions;
- deterministic cleanup ownership for every source handle, transaction, database, temporary directory, and worker isolate.

The intended memory shape is `O(page bytes + fixed digest state + bounded diagnostics)`, not `O(all source + all ledger + all graph rows)`. Full diff counts may require streaming merge-joins over sorted keys or external sorted runs; they must not be achieved by retaining every row and key union.

### Current gaps

- The ledger comparator has a 10,000-row/table guard but full material retention.
- The graph snapshot has no row bound and fully materializes every table.
- Both comparators construct in-memory indices/key unions.
- Diagnostic count limits do not bound scan time, total rows, total bytes, or memory.
- Neither comparator exposes a deadline or cancellation token.
- The current lineage reader fully materializes source and ledger rows.
- Production source reading is paged, but the API does not expose one file-local snapshot spanning all witness pages.
- AppCzar's assessment generation is UI/currentness control, not I/O cancellation or snapshot ownership.
- Disposable replay cleanup is strong for the existing harness, but a future multi-store attempt needs one explicit owner that closes all readers before deleting all disposable material and reports cleanup failure without converting UNKNOWN to TRUE.

These are feasibility blockers for direct reuse on a populated installation.

## 6. FTS proof boundary

Three different claims must remain separate:

1. **Graph content equality** — expected and observed `messages.ss_id/text` match. This is necessary and already expressible by graph material comparison.
2. **Indexed search behavior over a bounded corpus** — production-compatible MATCH expressions return the same ordered message IDs for named cases. Disposable tests can prove this finite contract for a specified SQLite/FTS/tokenizer/query-parser identity.
3. **Exhaustive internal index equivalence** — every token/posting/prefix entry is correct and no stale internal entry remains. Current application APIs do not prove this.

SQLite `PRAGMA integrity_check` validates database b-tree consistency, not semantic external-content FTS equality. The audited code exposes no strictly read-only production helper that compares all FTS5 shadow structures to a canonical expected index. Direct shadow-table interpretation would be SQLite-version/format dependent and would itself need qualification. The FTS5 integrity-check/rebuild command paths are writes and are forbidden on an observed live graph.

Safe observed-graph checks are limited to:

- read-only schema/trigger SQL and runtime/compile-option identity;
- graph `messages` material equality;
- read-only bounded MATCH query corpus with ordered IDs;
- ordinary read-only database integrity checks that do not rebuild, optimize, repair, or mutate.

Disposable diagnostics may build a fresh expected graph/index, exercise the exact production query corpus, deliberately corrupt/omit trigger effects in disposable copies, and prove that selected diagnostics detect those fixtures. They do not make the corpus exhaustive.

Until a separately qualified strictly read-only exhaustive index proof exists, exhaustive FTS equivalence is UNKNOWN. A finite corpus must never be reported as proof of all possible searches.

## 7. Protected-reference and historical anti-join contract

### 7.1 Direct identity checks

The witness must stream bidirectional identity sets and prove:

- every direct overlay contact/chat/message/canonical-handle reference resolves in the observed graph;
- the same protected reference resolves to the same semantic object in the expected graph;
- every relationship endpoint in expected and observed ledger/graph material exists;
- every registry `source_id` retains its exact source key/kind allocation;
- packed source-scoped IDs decode to the expected source allocation and raw source row ID;
- no historical occurrence required by ledger/batch provenance is missing or silently treated as zero rows.

A stable missing endpoint is FALSE. An unreadable table or unavailable historical occurrence is UNKNOWN.

### 7.2 Fallback and compatibility checks

- A message GUID fallback is valid only when the GUID is unique in the relevant expected and observed scope and resolves to the same message occurrence. Zero, duplicate, or divergent matches are FALSE when the material is stable; unreadable scope is UNKNOWN.
- A normalized handle fallback must be unique under the exact canonical normalization contract. A changed canonical representative that redirects protected intent is FALSE even if the normalized string still exists elsewhere.
- `archived_attachments(message_guid, import_attachment_id)` requires the message GUID to be unique and the unscoped attachment row ID to belong to the admitted live source occurrence. It must not bind to an identical raw `ROWID` from a historical source.
- Conversation IDs, contact/channel identities, and virtual-participant bridges require explicit namespace/type checks; numeric equality across namespaces is not identity.
- Missing historical source identity, source registry reallocation, or a different physical source at the same path is not waivable provenance debt.

### 7.3 Archive evidence

For every archived attachment compatibility row, the witness must distinguish:

- relationship provenance (message/attachment source occurrence and join);
- metadata record coherence (relative path, size, content hash, generation);
- payload availability/coverage.

Payload coverage alone does not prove that the attachment belongs to the reconstructed message or source occurrence. A covered payload with ambiguous relationship provenance remains FALSE or UNKNOWN according to whether the ambiguity is known or unreadable.

An archive UUID/root/location-generation change during the interval invalidates the attempt. A stable mismatch between a protected record's expected generation/scope and the admitted archive is FALSE.

### 7.4 Presence and operations

Presence and operation journals receive read-only schema, identity, material-fingerprint, and start/end stability checks. They do not receive invented graph anti-joins. If a journal or receipt explicitly names an archive UUID/root/generation/transaction, that explicit binding must resolve. Pending or unknown operation state prevents TRUE; it does not authorize completing, rolling back, or deleting the operation.

## 8. Expected ledger and graph construction feasibility

### 8.1 Expected ledger

Pure transformations alone cannot reproduce all ledger semantics. Expected material also depends on:

- occurrence registration and exact `source_id` allocation;
- import batch lifecycle;
- source window/high-water admission;
- existing GUID and insert-ignore decisions;
- endpoint existence and omission decisions;
- historical source ordering/provenance;
- rich-text decoder results;
- transaction/page behavior.

The safest feasible route is an **actual-writer replay into a disposable production-schema ledger**, never a live store:

1. Bind and stabilize all source occurrences and the existing registry allocation contract.
2. Seed only the exact registry/allocation state required to preserve identity, with explicit provenance for the seed.
3. Run the canonical production projections plus importer-owned admission rules against the stable read-only source snapshots.
4. Write expected rows through production ledger repositories into the disposable database.
5. Validate operational timestamps by Response 107's UTC/lifecycle contract rather than byte equality.
6. Compare all remaining material exactly and bidirectionally.

This replay still needs qualification. Running the mutating production importer against a live ledger is prohibited. Reimplementing importer admission in an ad hoc test mapper risks a second authority and is not acceptable reconstruction proof.

### 8.2 Expected graph

The qualified production graph replay harness can consume the bound expected disposable ledger and produce an expected disposable graph. It must use the exact graph writer ordering, rich-text results, source registry identities, and implementation/runtime identity captured by the observation binding.

The resulting clean expected graph must be compared directly with the observed populated graph. Replaying writers additively over the observed graph and seeing no error is not equivalence. The known stale-populated nonconvergence remains a real FALSE counterexample: stale contacts, chats, edges, or material can survive an additive replay even when the clean expected replay is correct.

No stale row receives an automatic waiver. No difference establishes repairability or reset eligibility. A reconstruction witness reports evidence; AppCzar policy remains unchanged.

## 9. Evidence and stop-gate matrix

| Domain | Authoritative/current evidence | Exact unproven requirement | Counterexamples | Smallest disposable qualification | Envelope / cleanup / authority rule |
|---|---|---|---|---|---|
| Source occurrence | Read-only source opener; per-family source queries; canonical projections | Physical occurrence identity, one file-local snapshot, bounded complete paging | TRUE: stable complete pages; FALSE: stable source material contradicts ledger; UNKNOWN: replacement/unreadable/drift | Two source copies at same path identity, WAL arrival, bounded pages | Deadline/cancel each page; source handles closed; no source writes |
| Registry/batches | Schema-v10 ledger comparator; UTC lifecycle checks | Exact source allocation/provenance and stable batch universe | Reallocated source ID FALSE; missing historical source UNKNOWN; bad UTC lifecycle FALSE | Disposable registry allocation/order and batch fixtures | Preserve operational timestamp exception only; no live registration |
| Messages | Canonical projection and MessageImporter characterization | Full admitted window including below-cursor mutation semantics | Missing/changed stable row FALSE; unreadable blob UNKNOWN | Adversarial duplicate GUID, null/blob/anomaly, below-cursor mutation | Stream by stable key; no record suppression |
| Handles | Canonical projection/interpreter | Stable `isMe`, normalization, source occurrence binding | Canonical representative drift FALSE; unavailable evidence UNKNOWN | Duplicate normalized handle and changed representative | Bounded normalization map/external sort; no overlay consultation |
| Chats | Canonical projection | Exact stateful insert-ignore/admission semantics | Stale chat FALSE; unknown source fields UNKNOWN | Existing conflicting chat and clean replay | Stream rows; no participant inference added |
| Attachments | Canonical metadata projection | Complete source metadata and occurrence binding | Stable missing attachment FALSE; missing payload alone is separate | Null/degraded path and same raw ID across sources | No payload reads needed for metadata comparison |
| Three relationships | Pure packed projections | Endpoint admission and exact provenance | Dangling/extra edge FALSE; missing endpoint evidence UNKNOWN | Missing endpoint, duplicate edge, source-ID collision | Merge-join endpoint sets; no inferred edges |
| Contacts/channels | Canonical projection | Exact omission reasons and AddressBook occurrence identity | Omitted valid channel FALSE; unreadable owner/source UNKNOWN | Invalid owner/value plus valid multi-channel rows | Paged source; no overlay/user-intent input |
| Rich text | Canonical semantic projection; decoder result seam | Exact decoder/runtime identity and bounded decoding | Stable semantic mismatch FALSE; decoder unavailable UNKNOWN | Bytes for persist/empty/failure and runtime mismatch | Batch/deadline/cancel; no dropping anomalous record |
| Ledger material | 11-table comparator, 10k/table | Streaming production-scale exact equality | Any stable missing/extra/changed row FALSE; bound exceeded UNKNOWN | Multi-page sort/merge with >10k fixture | `O(page)` memory; disposable only; no live mutation |
| Graph material | Production replay, 11-table comparator | Streaming populated comparison and coherent expected ledger | Stale material FALSE; graph changing UNKNOWN | Stale additive nonconvergence plus multi-page graph | Disposable expected graph; observed graph query-only |
| FTS | Schema/triggers/runtime and finite query corpus | Exhaustive internal index correctness, or explicit lower proof level | Query mismatch FALSE; finite corpus pass leaves exhaustive UNKNOWN | Disposable fresh/stale token, trigger update/delete, parser corpus | Never rebuild/optimize live; bind SQLite/FTS identity |
| Overlay/protected refs | Schema-v8 typed inventory | Complete streamed anti-joins and semantic fallback uniqueness | Dangling/ambiguous/rebound stable ref FALSE; unreadable UNKNOWN | Duplicate GUID/handle, dangling direct ID, namespace collision | Overlay read-only; no intent rewriting or graph dual-write |
| Historical/non-live | Canonical path source key and registry | Physical occurrence identity, availability, exact allocation/provenance | Reallocation/replacement FALSE; offline required source UNKNOWN | Same path/new file, same raw IDs across sources | One snapshot per occurrence; never treat offline as empty |
| Archive identity | Marker, admitted authority, location generation, repair/adoption evidence | One stable UUID/root/generation/operation envelope | Stable scope mismatch FALSE; mid-scan change UNKNOWN | Generation/marker change and pending transaction fixtures | Read-only fingerprints; no root lease or mutation capability |
| Presence/operations | Presence schema/state; receipts/journals/transaction records | Complete independent protected-state inventory and stable interval | Explicit binding mismatch FALSE; unreadable/pending UNKNOWN | Presence drift and transaction-generation mismatch | No invented graph dependency; no operation completion |
| Resources/lifecycle | Existing disposable harness cleanup | Deadlines, cancellation, disk/RSS/file limits, single cleanup owner | Limit/cancel/cleanup ambiguity UNKNOWN | Cancel every phase; injected close/delete failure | Fail closed; never infer completeness from no exception |

## 10. Remaining blockers and SHOULD FIX findings

### Blocking before a complete populated witness

1. No coherent cross-store interval binding exists.
2. No production-scale streaming ledger or graph comparator exists.
3. No bounded, cancellable expected-ledger actual-writer replay exists.
4. The source APIs do not yet expose one stable snapshot across all witness pages.
5. Protected-reference anti-joins and fallback uniqueness are not qualified.
6. Historical source physical-occurrence identity is weaker than required for replacement-at-same-path detection.
7. Exhaustive FTS internal-index equivalence is unsupported by current application APIs.
8. Presence and operation-evidence inventory has not been integrated into one interval fingerprint.
9. No full resource, cancellation, and cleanup failure qualification exists.
10. Known populated graph nonconvergence is real and cannot be waived.

### SHOULD FIX, without broadening Prompt 108

- Define a typed, capability-free coherent-observation evidence model before combining more comparators.
- Make every future material reader expose row/byte/time limits and cancellation explicitly.
- Keep expected replay test-only/disposable until it has adversarial identity, resource, and cleanup qualification.
- Give FTS results an explicit proof-level enum so a corpus result cannot be presented as exhaustive equivalence.
- Give every protected fallback an explicit uniqueness/namespace result rather than a boolean found/not-found result.
- Record unobserved dependency and cleanup failures as typed UNKNOWN reasons.

## 11. Exactly one recommended Prompt 109 milestone

### Selection

**Implement a test-only bounded coherent-observation envelope and stability classifier for disposable evidence readers.**

This is the smallest dependency-ordered step. Protected-reference and FTS qualifications would still be unsafe to combine into a reconstruction claim without a coherent interval. The milestone does not scan real data, compare full populated material, implement policy, or authorize reset.

### Exact permitted files

Only these two new files should be permitted:

```text
test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation.dart
test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation_test.dart
```

If production code, schema, generated files, pubspec, CHANGELOG, or any additional test/helper file is required, Prompt 109 must stop for design review.

### Read-only/test-only boundary

The model should accept injected capability-free callbacks returning compact immutable start/end fingerprints and bounded phase results. It must not import mutation capabilities, writable roots, production coordinators, AppCzar evaluator policy, or database writers. It may own only disposable fake resources created by its tests.

The result should distinguish:

- coherent interval accepted;
- known coherent contradiction retained;
- unknown because of instability, missing evidence, resource limit, timeout, cancellation, or cleanup failure.

It must not name or expose reset eligibility.

### Characterization before edits

Before implementation, record tests proving the present facts:

- one AppCzar assessment generation does not imply cross-store snapshot coherence;
- graph and ledger comparators consume already captured snapshots and do not establish interval stability;
- the existing two-sample Messages source check is source-local only.

If those facts are contradicted by current source, stop rather than duplicate an existing authority.

### Required adversarial tests

1. Matching start/end fingerprints accept one coherent interval.
2. First mismatch discards all evidence; one complete retry that matches is accepted.
3. Second mismatch returns UNKNOWN with exactly two attempts.
4. Archive UUID/root/location-generation/marker drift returns UNKNOWN.
5. Source occurrence, registry, ledger, graph, overlay, Presence, journal/receipt, or implementation fingerprint drift returns UNKNOWN.
6. A known contradiction inside an accepted interval remains FALSE even if another domain is unknown.
7. A contradiction assembled across mismatched intervals is UNKNOWN, not FALSE.
8. Timeout and explicit cancellation stop further reads and return UNKNOWN.
9. Row, byte, memory/disk-budget, or diagnostic-bound failure returns UNKNOWN.
10. Every owned fake reader/resource closes exactly once on success, retry, failure, timeout, and cancellation.
11. Operational timestamps may be excluded from material identity only after supplied lifecycle validation succeeds.
12. No callback, handle, capability, or evidence from discarded attempt one is retained by attempt two.

### Performance envelope

- At most two complete attempts.
- Fixed-size fingerprint state plus bounded diagnostics.
- Test with at least 10,001 synthetic page records while retaining no more than one page and fixed metadata.
- Deterministic fake monotonic deadline; no wall-clock sleeps.
- Cancellation checked between every phase/page.
- No real database, archive, filesystem payload, or FDA access.

### Validation and conformance

Prompt 109 should require:

- focused tests for both exact permitted files;
- the relevant AppCzar/reconstruction test group;
- architecture forbidden-import tests;
- full `flutter analyze` with attributable results;
- formatting check;
- Project Conformance review proving test-only placement, capability freedom, no parallel evaluator/policy authority, no database construction outside allowed disposable test seams, no record suppression, and no attachment mutation.

### Git sequence

1. Verify Prompt 108/Response 108 disposition exactly as the next prompt prescribes; do not assume this untracked response is checkpointed.
2. Checkpoint documentation separately if explicitly authorized.
3. Implement only the two permitted Prompt 109 files, leave unstaged for review unless the prompt explicitly authorizes a checkpoint.
4. Never combine unrelated untracked files.

### Stop conditions

Stop if the milestone requires:

- any production source change;
- an AppCzar evaluator or jurisdiction change;
- a mutation capability, writer, root lease, or live database/archive access;
- more than two attempts or an unbounded reader;
- a claim of cross-file atomicity;
- a policy result such as safe-to-reset;
- suppression of a known contradiction because another domain is unknown;
- more files than the exact permitted set;
- cleanup whose ownership cannot be established.

## 12. Final repository state and prohibitions

At the end of this audit:

- tracked worktree and index remain clean;
- branch and HEAD remain `fix/onboarding-import-stuck-state` at `0ca390259ab2ddbbdc35889d39551b77ac8d63b1`;
- upstream relationship remains synchronized `0/0`;
- shared-instructions submodule remains clean at `95326f515ef4719f155ce6e223990398daad6311`;
- all pre-existing untracked files remain untouched;
- Prompt 108 and this Response 108 remain untracked for review;
- no application, real database, real archive, payload, build, permission, or production AppCzar state was accessed or changed.

The seven AppCzar jurisdictions remain unchanged. Production AppCzar activation remains off. This response grants no authority to implement or run destructive Operating-owned Start Fresh.

LEDGER COMPARISON CHECKPOINTED: YES
COHERENT SOURCE/LEDGER/GRAPH OBSERVATION CONTRACT DEFINED: YES
FTS PROOF LIMITS EXPLICIT: YES
PROTECTED/HISTORICAL REFERENCE REQUIREMENTS INVENTORIED: YES
BOUNDEDNESS AND CANCELLATION GAPS IDENTIFIED: YES
COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES
PROJECT CONFORMANCE (AUDIT/DESIGN): PASS
READY FOR NARROW PROMPT 109: YES
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
