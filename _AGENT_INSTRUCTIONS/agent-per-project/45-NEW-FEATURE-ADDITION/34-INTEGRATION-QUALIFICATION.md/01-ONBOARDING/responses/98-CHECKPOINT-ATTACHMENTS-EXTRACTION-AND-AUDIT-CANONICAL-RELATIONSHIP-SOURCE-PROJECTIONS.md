# Response 98 — Canonical Relationship Source-Projection Audit

## Scope and result

This response records the audit-only milestone authorized by Prompt 98. It
verifies the already-checkpointed Attachments extraction, inventories the
current relationship import authorities, distinguishes source-ledger
relationships from derived Conversation Graph edges, and designs one narrow
next extraction. It does not extract a projection, modify production code or
tests, implement a reconstruction witness, enable destructive Start Fresh, or
activate production AppCzar.

The audit selects the source-scoped **Chat-Message relationship** row
transformation for Prompt 99. Its persisted row is the only audited join row
that retains a unique raw relationship identity, it uses no import batch or
clock, and its deterministic formation depends only on the admitted source
facts plus `SourceScopedRowKey`. Source endpoint existence checks remain with
the importer.

No Flutter test, analyzer, build, installed-app launch, or live-data operation
was performed. Validation consisted of source, schema, call-graph, existing
test, Git, and governing-response inspection as required by Prompt 98.

## 1. Verified baseline

The verified baseline and final tracked state are:

```text
Repository: /Users/rob/Development/FlutterProjects/remember_every_text
Branch: fix/onboarding-import-stuck-state
HEAD: 30bc9ea79846ee7ecc2730710998bc5801b42499
Upstream: origin/fix/onboarding-import-stuck-state
Divergence: 0 ahead / 0 behind
Tracked worktree: clean
Index: clean
Shared-instructions submodule:
  95326f515ef4719f155ce6e223990398daad6311
  clean, heads/main
Feature 34 worktrees on this branch: exactly one
```

All required implementation checkpoints are ancestors of HEAD:

```text
a36feac8a48d1702aad5830076157830d6efb975  Contacts projection
d77d08c6c55e18ade47983fb959b8023c893283c  Messages projection
ae6aa6496e9dd98378c61be1aa7d7984d7207f4c  Handles projection
10732e2986c5e40f7d097f35e2d12daff663fc4f  Chats projection
417a7ef1b24b12991649edc978bd3d0326a6720a  Attachments projection
```

Prompt 97 and Response 97 were already committed and pushed together in:

```text
30bc9ea79846ee7ecc2730710998bc5801b42499
docs(appczar): record Attachments source projection extraction
```

The implementation immediately below it is:

```text
417a7ef1b24b12991649edc978bd3d0326a6720a
refactor(import): extract canonical Attachments source projection
```

No duplicate documentation checkpoint was created.

The baseline contained 49 pre-existing untracked files, including Prompt 98.
They were left untouched. Creation of this response adds exactly one untracked
file, so the final untracked count is 50. No external baseline manifest was
needed or created.

## 2. Production relationship-import inventory

### Dedicated raw Messages join importers

The production source-scoped import has exactly three dedicated relationship
importers connecting the five scalar record families:

| Source family | Production importer | Ledger table | Full/incremental |
|---|---|---|---|
| `chat_message_join` | `ChatMessageJoinImporter` | `chat_to_message` | full and after source message ROWID |
| `chat_handle_join` | `ChatHandleJoinImporter` | `chat_to_handle` | full only |
| `message_attachment_join` | `MessageAttachmentJoinImporter` | `message_to_attachment` | full and after source message ROWID |

The source-scoped archive import service imports scalar records before these
relationships. The live Conversation Graph build follows the same dependency
shape: chats, handles, contacts, messages, rich-text enrichment, and
attachments precede the three relationship imports; graph projection follows
ledger import. Full versus incremental join selection is owned by the existing
orchestrator, not by a row transformation.

Each importer receives an explicit `sourceId`, defaulting to
`liveChatDbSourceId`. Historical archive import first establishes its own
registered source identity and injects that identity. The relationship
importers do not discover or canonicalize the source registry themselves.

### Other relationship-shaped production data

Two additional paths were identified, but neither is a fourth raw Messages
join importer:

1. `contact_channels` is a source-scoped relationship-shaped ledger table
   produced by the already-qualified Contacts import/projection. It connects a
   source contact identity to an email or phone value. Its pure row formation
   and typed omission decisions were extracted in Response 93. It is not a
   raw `chat.db` relationship and is not a Prompt 99 candidate.
2. `messages.sender_handle_ss_id` is an embedded optional reference formed by
   the already-qualified Message source projection in Response 94. It packs a
   positive raw `message.handle_id`; it is not a separate relationship table,
   performs no endpoint-existence lookup, and is already inside the canonical
   Message transformation.

The Conversation Graph's `contact_to_handle` table is also relationship data,
but it is a derived graph association. It is produced by stateful matching of
ledger contact-channel values to graph handle aliases. It is not a raw source
relationship and must not be folded into any of the three source join
extractions.

Rich-text enrichment is message-column enrichment, not a separate persisted
relationship family.

## 3. Exact source queries, order, and paging

### Chat-Message

Full import executes:

```sql
SELECT cmj.ROWID AS source_rowid,
       cmj.chat_id,
       cmj.message_id,
       c.ROWID AS existing_chat_rowid,
       m.ROWID AS existing_message_rowid
FROM chat_message_join cmj
LEFT JOIN chat c ON c.ROWID = cmj.chat_id
LEFT JOIN message m ON m.ROWID = cmj.message_id
ORDER BY cmj.ROWID ASC
```

Incremental import inserts this clause before the ordering:

```sql
WHERE cmj.message_id > ?
```

The argument is the orchestrator-owned starting source Message ROWID. The
entire result is materialized in one query. There is no keyset page size or
other relationship-level paging.

### Chat-Handle

```sql
SELECT chj.ROWID AS source_rowid,
       chj.chat_id,
       chj.handle_id,
       c.ROWID AS existing_chat_rowid,
       h.ROWID AS existing_handle_rowid
FROM chat_handle_join chj
LEFT JOIN chat c ON c.ROWID = chj.chat_id
LEFT JOIN handle h ON h.ROWID = chj.handle_id
ORDER BY chj.ROWID ASC
```

This is always a full, fully materialized scan. It has no incremental method
and no paging.

### Message-Attachment

Full import executes:

```sql
SELECT maj.ROWID AS source_rowid,
       maj.message_id,
       maj.attachment_id,
       m.ROWID AS existing_message_rowid,
       a.ROWID AS existing_attachment_rowid
FROM message_attachment_join maj
LEFT JOIN message m ON m.ROWID = maj.message_id
LEFT JOIN attachment a ON a.ROWID = maj.attachment_id
ORDER BY message_id ASC, attachment_id ASC
```

Incremental import inserts:

```sql
WHERE maj.message_id > ?
```

before the same ordering. The entire result is materialized; there is no page.

These existing full-result scans are an audit finding, not authority to change
work bounds during extraction. Prompt 99 must preserve the selected importer's
query and ordering exactly.

## 4. Identity and persisted schema

`SourceScopedRowKey.pack(sourceId, sourceRowId)` is the one canonical packed
identity utility. It allocates the source ID and source row ID into a bounded,
reversible integer key. The relationship importers must not reproduce its bit
layout.

### Chat-Message identity

- Raw relationship identity: `chat_message_join.ROWID`.
- Persisted relationship identity: `ss_id = pack(sourceId, join ROWID)`.
- Source Chat endpoint: raw `chat_id` and
  `chat_ss_id = pack(sourceId, chat_id)`.
- Source Message endpoint: raw `message_id` and
  `message_ss_id = pack(sourceId, message_id)`.
- The raw relationship ROWID is retained, so two raw rows with the same
  endpoints remain distinguishable when their join ROWIDs differ.

Complete ledger schema:

```text
chat_to_message
  ss_id INTEGER PRIMARY KEY
  source_id INTEGER NOT NULL
  source_rowid INTEGER NOT NULL
  source_chat_rowid INTEGER NOT NULL
  source_message_rowid INTEGER NOT NULL
  chat_ss_id INTEGER NOT NULL
  message_ss_id INTEGER NOT NULL
  UNIQUE(source_id, source_rowid)
  indexes: chat_ss_id; message_ss_id;
           (source_id, source_message_rowid)
```

The current table declares no source, batch, or endpoint foreign keys.

### Chat-Handle identity

- Raw join ROWID is required and reported as progress context, but is not
  persisted.
- Persisted identity is the composite endpoint provenance:
  `(source_id, source_chat_rowid, source_handle_rowid)`.
- Endpoints are packed independently from the same injected source ID.
- Multiple raw source join rows with identical endpoints collapse at the
  ledger boundary.

Complete ledger schema:

```text
chat_to_handle
  source_id INTEGER NOT NULL
  source_chat_rowid INTEGER NOT NULL
  source_handle_rowid INTEGER NOT NULL
  chat_ss_id INTEGER NOT NULL
  handle_ss_id INTEGER NOT NULL
  batch_id INTEGER NOT NULL
  UNIQUE(source_id, source_chat_rowid, source_handle_rowid)
  FOREIGN KEY source_id -> source_registry(source_id)
  FOREIGN KEY batch_id -> import_batches(batch_id)
  indexes: chat_ss_id; handle_ss_id
```

The endpoint IDs are raw source-row identities, not canonicalized handle text
identities.

### Message-Attachment identity

- Raw join ROWID is required and reported as progress context, but is not
  persisted.
- The current importer binds both endpoints to its one injected `sourceId`.
- Persisted uniqueness is the four-part source/endpoint tuple. Duplicate raw
  source join rows for the same endpoint pair collapse.

Complete ledger schema:

```text
message_to_attachment
  message_source_id INTEGER NOT NULL
  attachment_source_id INTEGER NOT NULL
  source_message_rowid INTEGER NOT NULL
  source_attachment_rowid INTEGER NOT NULL
  message_ss_id INTEGER NOT NULL
  attachment_ss_id INTEGER NOT NULL
  batch_id INTEGER NOT NULL
  UNIQUE(message_source_id, source_message_rowid,
         attachment_source_id, source_attachment_rowid)
  FOREIGN KEY message_source_id -> source_registry(source_id)
  FOREIGN KEY attachment_source_id -> source_registry(source_id)
  FOREIGN KEY batch_id -> import_batches(batch_id)
  indexes: message_ss_id; attachment_ss_id;
           (message_source_id, source_message_rowid)
```

### Contact-channel schema for completeness

```text
contact_channels
  source_id INTEGER NOT NULL
  source_contact_rowid INTEGER NOT NULL
  contact_ss_id INTEGER NOT NULL
  kind TEXT NOT NULL CHECK kind IN ('email', 'phone')
  value TEXT NOT NULL
  label TEXT
  batch_id INTEGER NOT NULL
  UNIQUE(source_id, source_contact_rowid, kind, value)
  FOREIGN KEY source_id -> source_registry(source_id)
  FOREIGN KEY batch_id -> import_batches(batch_id)
  indexes: contact_ss_id; value
```

Its owner-existence set, channel normalization, omissions, and row formation
remain the Contacts authority qualified by Response 93.

## 5. Stateful endpoint, duplicate, and omission policy

All three dedicated join importers prove endpoint existence against the
currently opened source database through the `LEFT JOIN` aliases selected by
their queries. They do **not** look up endpoint rows in the import ledger.
Scalar-before-relationship orchestration is a separate ordering invariant.

For every row, the importer requires a valid join ROWID (`int`, or rounded
`double`). A missing or malformed join ROWID throws the importer's established
direct `StateError`. Endpoint raw IDs accept `int` or rounded `double`; an
invalid or absent endpoint ID, or a null `existing_*_rowid` from either source
join, makes the relationship incomplete.

An incomplete relationship is omitted alone. The importer does not invent an
endpoint, recover from the graph, or discard the scalar record. It increments
the family's typed omission counter and proceeds:

```text
omittedChatMessageRelationshipCount
omittedChatHandleRelationshipCount
omittedMessageAttachmentRelationshipCount
```

Every admitted relationship is written with `insertIgnore`. An ignored
duplicate increments examined/completed work but not inserted work. Conflict
handling never updates an existing relationship.

The pure extraction must therefore receive only importer-admitted endpoint
facts. Moving `existing_*` interpretation into a pure module would create a
second endpoint-resolution authority and is prohibited.

## 6. Transactions, batches, progress, errors, and closure

### Transactions and batches

- **Chat-Message:** no batch is allocated. One ledger write transaction wraps
  the complete selected result.
- **Chat-Handle:** a batch is allocated, using the current UTC clock, before
  the source is opened and before the query. One later transaction wraps all
  relationship rows. The batch therefore survives an open, query, row,
  write, or progress failure.
- **Message-Attachment:** the source is opened and queried first. Empty input
  reports `0/0`, allocates no batch, and returns. Nonempty input allocates one
  batch before the one relationship-row transaction. That batch survives a
  later transactional failure.

The transaction does not include source query execution or batch allocation.
An exception from row conversion, packing, insert-ignore persistence, or an
in-transaction progress observer propagates and rolls back relationship rows
in that transaction. Query failures propagate before row mutation. No
importer catches and reclassifies the original error.

### Progress and anomaly evidence

Each importer publishes an initial event with zero completed work and the
materialized row count. It then publishes after every admitted or omitted raw
join row with:

- the family-specific work unit;
- cumulative completed count;
- fixed total count;
- the raw join ROWID as `lastCompletedSourceRowId`; and
- the cumulative typed omission count.

Results return examined, inserted, and omitted counts. Duplicate rows are
examined and completed but not inserted or anomalous.

### Source lifecycle

After successful `openReadOnly`, every importer closes the source in `finally`
after success, query failure, row failure, write failure, or observer failure.
If source opening itself fails, there is no opened handle to close. The
Chat-Handle batch has already been allocated on that path; the other two have
not allocated a batch at source-open time.

All of these execution points are observable production behavior and must be
frozen before any selected importer is edited.

## 7. Source-ledger relationships versus graph edges

The source-scoped ledger preserves source provenance needed by later graph
projection. The graph repositories read those ledger rows and create topology
edges in a separate Conversation Graph transaction:

| Ledger relationship | Graph projection | Graph persisted identity |
|---|---|---|
| `chat_to_message` | `SqliteChatToMessageProjectionRepository` | primary key `(chat_ss_id, message_ss_id)` |
| `chat_to_handle` | `SqliteChatToHandleProjectionRepository` | unique `(chat_ss_id, handle_ss_id)` |
| `message_to_attachment` | `SqliteMessageToAttachmentProjectionRepository` | unique `(message_ss_id, attachment_ss_id)` |

The graph uses `INSERT OR IGNORE` and collapses relationships to endpoint
topology. It does not retain raw join ROWID, source row provenance, or import
batch lineage. Chat-Message and Message-Attachment graph projectors can read a
bounded ledger suffix using the existing source/message cursor; Chat-Handle
projects its ledger relationship set without that cursor.

`contact_to_handle` is materially different. The contact projector reads
ledger contacts and channels, reads current graph handles and aliases, builds
normalized lookup keys, and inserts matching graph edges with the observed
handle value. Its association decision depends on current graph state and the
canonical handle-key interpretation. It must remain with the graph projection
owner.

No source projection may import Conversation Graph repositories, query graph
state, or output graph rows. Conversely, graph topology cannot serve as proof
of the original source relationship because it has discarded source
relationship identity and lineage.

## 8. Purity classification

### Pure deterministic candidates

For all three join families, these operations are potentially pure:

- interpreting explicit raw relationship and endpoint integer facts;
- packing an admitted source relationship or endpoint with
  `SourceScopedRowKey`;
- constructing one complete immutable ledger value map from explicit
  `sourceId`, endpoint facts, and (where applicable) importer-owned `batchId`.

For Chat-Message, the entire seven-column admitted-row formation is pure and
requires no clock or batch input. This is the narrowest candidate.

### Stateful resolution that remains importer-owned

- Source path and read-only database opening.
- Full versus incremental query selection and starting cursor.
- Query SQL, ordering, and materialization.
- Current source endpoint-existence proof via `LEFT JOIN` evidence.
- Source-registry/source-ID ownership and orchestration.
- Scalar-before-relationship ordering.
- Batch creation, batch timestamp, and batch lifecycle.
- Selection of which admitted relationship is passed to the pure projection.
- Result accumulation and anomaly jurisdiction.

### Mutation and lifecycle that remains importer-owned

- Ledger transaction boundaries.
- `insertIgnore` persistence and duplicate suppression.
- Inserted/examined/omitted counts.
- Progress publication and last-completed evidence.
- Rollback and direct error propagation.
- Source closure.

The graph's endpoint matching, alias normalization, edge persistence, and
projection lifecycle remain graph-owned. Attachment coverage and archive
repair remain separate read/mutation authorities.

## 9. Reconstruction limits

The current source can reproduce a relationship only when the relevant source
join row and both source endpoints still exist and the same source identity is
admitted now. “Originally imported from live source” is not proof that the
relationship is reconstructible from the current live source.

### Chat-Message

The ledger retains the original join ROWID, source ID, raw endpoints, and
packed endpoints. That is strong historical evidence of what was imported,
but current-source reconstruction still fails when the join row or either
endpoint has since disappeared. A graph edge alone cannot recover the lost
join ROWID or source provenance.

### Chat-Handle

The ledger retains source and endpoint identities plus batch lineage, but not
the raw join ROWID. Therefore identical raw duplicate join rows have already
collapsed and cannot be reconstructed exactly as raw relationship records.
Current source disappearance of a join or endpoint is likewise not repaired by
the ledger or graph. Later changes to handle text canonicalization do not
change the packed raw handle endpoint, but they can change derived
contact-to-handle graph associations.

### Message-Attachment

The ledger retains the source identities, endpoint row IDs, packed endpoints,
and batch, but not the raw join ROWID. Duplicate raw source joins for the same
endpoint pair cannot be recovered as distinct facts. A currently missing
message, attachment, or join cannot be inferred from the archive payload or
from a graph edge. Archive coverage proves payload preservation, not source
relationship provenance.

### Historical and orphan cases

A historical/non-live relationship requires the originally registered source
identity and authoritative source, not the current live source. Orphaned
imported scalar records do not authorize invention of a relationship. The
existing orphan/recovery paths are separate and were not changed or treated as
join authorities.

Consequently, the five scalar projections plus a future set of pure join-row
projections will still not constitute a complete populated reconstruction-
equivalence witness.

## 10. Actual-writer characterization feasibility and current coverage

All three production importers can be exercised with a synthetic
`ReadOnlySourceDatabase`, a disposable actual `ImportDatabase`, the existing
port interfaces, and `SourceScopedRowKey`. No real source or archive is needed.

The smallest useful relational fixture has source endpoint tables plus the
selected join table, with:

- at least two valid ordered joins;
- a raw duplicate endpoint pair where the family's uniqueness semantics make
  that relevant;
- a join missing each endpoint in turn;
- a rerun against the same ledger;
- an empty selection;
- an incremental boundary where supported; and
- an injected failure/observer and close-capable source double for rollback
  and lifecycle paths.

Current regression evidence includes:

- `relationship_anomaly_policy_test.dart` for broken Chat-Message and
  Chat-Handle endpoint omission while retaining valid relationships;
- `message_attachment_join_importer_test.dart` for canonical endpoint rows,
  idempotence, incremental import, and broken-child omission;
- chat topology flow tests for raw relationship import, incremental import,
  graph idempotence, and graph incremental projection;
- handle topology flow coverage for Chat-Handle import/projection;
- graph projector unit/infrastructure tests, including Message-Attachment
  canonical edges, idempotence, and incremental projection;
- contact importer and contact projector tests for channels and stateful
  contact-to-handle matching; and
- schema and anomaly architecture tests.

This is useful regression coverage, but no existing Chat-Message-specific
actual-writer characterization freezes the complete persisted row maps,
numeric coercions, exact progress sequence, empty and duplicate results,
transaction rollback, observer failure, and source closure together. Prompt 99
must establish that evidence against the unchanged importer before editing it.

## 11. Architecture risks and mechanical enforcement

| Risk | Required Prompt 99 enforcement |
|---|---|
| A second endpoint-resolution authority | AST test: pure module has no SQL/database ports and production importer retains both `LEFT JOIN` endpoint proofs and omission branch |
| Duplicated packed-key logic | AST test: `SourceScopedRowKey.pack` appears only in the canonical relationship projection for row formation; importer invokes that projection once |
| Missing-endpoint policy drift | Actual-writer parity fixtures for missing Chat and missing Message, exact omission/result/progress equality |
| Relationship identity/uniqueness drift | Exact seven-column row maps, two same-endpoint/different-join identities, and rerun idempotence |
| Database lookup hidden in a “pure” helper | Dependency allowlist plus bans on SQLite, DAO, ledger, repository, provider, `Future`, I/O, and injected callback/capability types |
| Transaction-boundary drift | AST assertion that importer still owns one `writeTransaction`; failure fixture proving rollback |
| Query/order/incremental drift | Freeze exact source rows/order and cursor-bound result before and after; production SQL remains importer-local |
| Progress/anomaly drift | Freeze complete observer event sequence for valid, omitted, duplicate, empty, and failure paths |
| Graph canonicalization drift | Pure module forbidden from Conversation Graph imports; run graph topology regressions unchanged |
| Historical provenance drift | Direct projection vectors for live and non-live source IDs; complete source and endpoint lineage map equality |
| Attachment evidence coupling | Architecture ban on archive/payload/coverage/repair imports and run relevant attachment regressions |
| New unbounded work | Assert extraction adds no loop/query; selected importer query and materialization remain byte-for-semantic equivalent |
| Source-lifecycle regression | Close observations after success and each query/write/progress failure |
| Mutation-authority broadening | Pure return is immutable data only; no transaction, port, capability, coordinator, AppCzar, or callback dependency |
| AppCzar jurisdiction change | Architecture diff/forbidden-import checks and existing AppCzar/Onboarding regressions; no AppCzar files in checkpoint |

## 12. Recommended extraction order

### Prompt 99: Chat-Message source relationship

Chat-Message is the safest first extraction because:

1. its admitted row is a complete deterministic function of the explicit
   source relationship ROWID, the two raw endpoint ROWIDs, and `sourceId`;
2. it retains a unique raw relationship identity rather than collapsing to a
   composite endpoint key;
3. it has no batch ID, clock, or batch-lifecycle input;
4. endpoint existence remains visibly and mechanically importer-owned;
5. `SourceScopedRowKey` is the only canonical utility required;
6. the actual writer can be exercised through existing ports and a disposable
   real ledger; and
7. current anomaly and topology regressions provide a strong base while the
   missing full characterization can be added before production edits.

### Remaining order

```text
1. Chat-Message          Prompt 99
2. Chat-Handle           after its own pre-edit characterization
3. Message-Attachment    after its own pre-edit characterization
```

Chat-Handle precedes Message-Attachment because its source and ledger shape is
smaller, even though it must preserve batch allocation before source opening.
Message-Attachment comes last because it combines batch/no-batch empty
behavior, incremental message-bound selection, two separately named source-ID
columns, and attachment-related regression obligations.

`contact_channels` needs no new extraction: Response 93 already established
its canonical transformation. Derived `contact_to_handle` must remain a
separate stateful graph concern unless a future audit explicitly authorizes
work there.

## 13. Exact Prompt 99 implementation design

### Permitted production files

Only:

```text
lib/essentials/source_scoped_import/application/chat_message_joins/
  chat_message_join_importer.dart
  chat_message_relationship_source_projection.dart  (new)
```

No provider, generated, schema, migration, graph, FTS, rich-text, archive,
AppCzar, Start Fresh, `pubspec.yaml`, or `CHANGELOG.md` file is justified by
this internal behavior-preserving extraction.

### Permitted tests

```text
test/essentials/source_scoped_import/application/chat_message_joins/
  chat_message_join_importer_characterization_test.dart  (new)
  chat_message_relationship_source_projection_test.dart  (new)

test/architecture/
  chat_message_relationship_source_projection_authority_test.dart  (new)
```

Existing regression files should remain unchanged unless Prompt 99 encounters
a literal stop gate and documents why the exact design cannot be implemented.

### Typed pure contract

The proposed module defines:

```text
ChatMessageRelationshipSourceProjectionInput
  raw sourceRelationshipRowId
  raw sourceChatRowId
  raw sourceMessageRowId
  factory fromSourceRow(...)
  established int/double coercion and required-field errors

ProjectedSourceChatMessageRelationship
  sourceRelationshipRowId
  immutable complete ledgerValues

projectSourceChatMessageRelationship(
  input,
  sourceId,
) -> ProjectedSourceChatMessageRelationship
```

The immutable output map must contain exactly:

```text
ss_id
source_id
source_rowid
source_chat_rowid
source_message_rowid
chat_ss_id
message_ss_id
```

The function reuses only `SourceScopedRowKey`; it owns no source endpoint
proof. The importer may construct the typed input early so its required join
ROWID remains the canonical progress identity, but it must continue to inspect
the query's `existing_chat_rowid` and `existing_message_rowid` itself. It calls
the projection only after both raw endpoint IDs and both stateful source
endpoint proofs are present.

### Importer-owned behavior frozen before edits

Before changing production code, the actual-writer characterization must pass
against the unchanged importer and freeze:

- exact SQL-observable ordering for full and incremental selections;
- complete persisted seven-column maps and row order;
- live and non-live source identities and packed endpoint identities;
- integer and rounded-double raw identities plus malformed identity errors;
- two same-endpoint raw joins with different join ROWIDs;
- insert-ignore rerun behavior;
- Chat-missing and Message-missing omission behavior;
- exact result counters and all progress/anomaly events;
- empty source behavior;
- incremental boundary behavior;
- transaction rollback after an admitted prior row;
- observer/write/query/open error propagation; and
- source closure on every post-open success/failure path.

The characterization must use a disposable actual import ledger for persisted
row evidence. Test doubles may be used only where necessary to inject lifecycle
or transaction failures that the actual disposable writer cannot safely
produce.

### Post-extraction parity and direct tests

Rerun the unchanged characterization after extraction and require equality of
every persisted value, order, result, error, progress event, anomaly count,
transaction outcome, and lifecycle observation.

Direct pure tests must cover:

- all seven persisted columns;
- immutable output;
- live and non-live source IDs;
- lower/upper valid packed identities and invalid bounds;
- integer/double coercion and required-field failures;
- duplicate endpoint facts with distinct relationship ROWIDs; and
- proof that irrelevant source fields cannot affect output.

The AST/dependency test must prove a synchronous, immutable, narrowly imported
module; one production call site; no duplicate row formation; no SQL, database,
provider, graph, archive, AppCzar, callback, I/O, clock, batch, progress, or
mutation dependency; and continued importer ownership of the query, endpoint
proof, omission branch, transaction, insert-ignore, progress, result, and
source closure.

### Regression and conformance validation

Prompt 99 should run, in order:

1. the pre-edit characterization alone;
2. the unchanged characterization plus direct projection and AST tests after
   extraction;
3. source-scoped import relationship and schema regressions;
4. Conversation Graph chat/topology regressions;
5. attachment/archive and AppCzar/Onboarding regressions sufficient to prove
   the hard boundaries remain untouched;
6. the complete architecture suite;
7. `flutter analyze`; and
8. the complete deterministic Flutter suite if required by the Feature 34
   checkpoint standard in force at implementation time.

No build or installed-app launch is needed for a pure extraction. Generated
consistency, Dart formatting, `git diff --check`, and
`git diff --cached --check` must be clean.

Project Conformance must find no parallel identity or endpoint authority, no
dependency inversion, no capability or persistence leak into the pure module,
no broadened work, and exact behavior parity.

### Checkpoint sequence

1. Reverify the clean synchronized baseline and preserve all untracked files.
2. Add only the characterization test and run it against unchanged production.
3. Stop if actual behavior contradicts this audit or cannot be frozen.
4. Add the pure module, make the smallest importer substitution, and add direct
   plus architecture tests.
5. Complete parity, regression, analyzer, formatting, generated-consistency,
   diff, and conformance checks.
6. Review/stage only the five authorized implementation/test files.
7. Commit the implementation with a narrow relationship-projection message and
   push normally only when Prompt 99 explicitly authorizes that checkpoint.
8. Create and separately checkpoint Prompt 99/Response 99 documentation, again
   only as Prompt 99 prescribes.

### Stop gates

Stop rather than improvise if:

- the unchanged production writer cannot be characterized through current
  ports and a disposable ledger;
- current behavior contradicts this query, schema, ordering, omission,
  progress, transaction, or lifecycle inventory;
- endpoint proof would need to move into the pure module;
- the pure module would require a database, clock, batch allocation,
  capability, callback, graph lookup, or mutable global state;
- exact before/after output or observer parity fails;
- schema, migration, provider generation, graph semantics, attachment/archive
  evidence, AppCzar, or Start Fresh would need to change;
- an architecture assertion cannot establish sole row-formation authority; or
- an unrelated tracked or submodule change appears.

## 14. Project Conformance

The proposed Prompt 99 architecture has one narrow deterministic owner and
keeps every stateful decision, mutation, and lifecycle action with its current
owner. It neither weakens nor duplicates source identity, endpoint evidence,
database, graph, archive, or AppCzar authority.

```text
PROJECT CONFORMANCE: PASS
BLOCKER: 0
SHOULD FIX: 0
```

There is no current design blocker. The documented test-coverage gaps are
mandatory pre-edit characterization work in Prompt 99, not permission to
assume parity and not a defect requiring a Prompt 98 code change.

## 15. Final Git state and continuing prohibitions

After creating this response:

- branch and HEAD remain `fix/onboarding-import-stuck-state` at
  `30bc9ea79846ee7ecc2730710998bc5801b42499`;
- upstream remains synchronized `0/0`;
- tracked worktree and index remain clean;
- the shared-instructions submodule remains unchanged and clean;
- all 49 pre-existing untracked files remain untouched;
- this Response 98 is the only new untracked file, producing 50 untracked
  files total; and
- nothing was staged, committed, pushed, built, installed, or launched.

This audit and the proposed extraction do not prove populated reconstruction
equivalence. Destructive Operating-owned Start Fresh, Stage 2C resumption,
production AppCzar activation, and production cutover remain prohibited.

ATTACHMENTS EXTRACTION CHECKPOINTED: YES

RELATIONSHIP IMPORTER INVENTORY COMPLETE: YES

SOURCE-SCOPED AND GRAPH RELATIONSHIP AUTHORITIES DISTINGUISHED: YES

PURE RELATIONSHIP TRANSFORMATION CANDIDATES IDENTIFIED: YES

STATEFUL ENDPOINT RESOLUTION REMAINS WITH EXISTING OWNERS: YES

ACTUAL-WRITER CHARACTERIZATION FEASIBLE FOR SELECTED FAMILY: YES

FIRST RELATIONSHIP EXTRACTION SELECTED: Chat-Message source relationship

FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS

READY FOR PROMPT 99 IMPLEMENTATION: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
