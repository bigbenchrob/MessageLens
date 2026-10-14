# MessageLens — Feature 34
## Response 102 — Relationship Checkpoints and Populated Reconstruction-Equivalence Audit

**Date:** 2026-10-14
**Mode:** Read-only architecture and evidence audit
**Implementation performed:** None

## Executive result

The eight canonical source-scoped projections are committed, pushed, and
present in the current branch ancestry. They establish exact parity for the
narrow source-row-to-import-ledger transformations that they own. They do not
establish that a populated MessageLens installation can be destroyed and
reconstructed without losing consequential state.

The current implementation has no complete, read-only witness that binds one
coherent source observation to the active import ledger, rich-text
materialization, Conversation Graph, FTS index, historical/non-live material,
user-authored overlay references, Presence, and attachment-archive identity.
There are known conditions that must produce `FALSE`, and unreadable,
unstable, unsupported, or incomplete evidence that must produce `UNKNOWN`.
Neither result authorizes deletion.

Accordingly:

- destructive Operating-owned Start Fresh / Stage 2C remains blocked;
- production AppCzar activation remains off;
- the seven AppCzar jurisdictions are unchanged;
- the next safe milestone is characterization and extraction of the canonical
  rich-text semantic projection, not reset implementation.

## 1. Exact repository baseline

### Git state

- Repository: `/Users/rob/Development/FlutterProjects/remember_every_text`
- Branch: `fix/onboarding-import-stuck-state`
- Baseline HEAD: `540a52c908724629cefbb7ee4db113509a9edd99`
- Upstream: `origin/fix/onboarding-import-stuck-state`
- Ahead / behind: `0 / 0`
- Tracked worktree: clean
- Index: clean
- Shared-instructions submodule:
  `95326f515ef4719f155ce6e223990398daad6311`, clean
- Pre-existing untracked entries before this response: 49
- Prompt 102 was among those pre-existing untracked entries and was not
  modified.

Registered worktrees were inventoried as:

1. primary: `/Users/rob/Development/FlutterProjects/remember_every_text`
2. Feature 35: `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`
3. main: `/Users/rob/Development/FlutterProjects/remember_every_text-main`
4. Gradle repair:
   `/Users/rob/Development/FlutterProjects/remember_every_text.worktrees/gradle-fix-flutter-projects`

No other worktree was modified or used.

### Projection checkpoint chain

The following implementation and documentation checkpoints are ancestors of
the baseline HEAD and are present on the synchronized upstream:

| Family | Implementation checkpoint | Documentation checkpoint |
|---|---|---|
| Contacts | `a36feac8a48d1702aad5830076157830d6efb975` | `ee5425dd06d3a2a07cea6f22faaba6e1bc17515f` |
| Messages | `d77d08c6c55e18ade47983fb959b8023c893283c` | `7c4af5b3f3eef96449fd3347af50afb049e82509` |
| Handles | `ae6aa6496e9dd98378c61be1aa7d7984d7207f4c` | `e6bf408f2ae9bf32b2ccde37ac9ca13461f1e339` |
| Chats | `10732e2986c5e40f7d097f35e2d12daff663fc4f` | `242b517c96ae45201c9a67e0e1e012203ad36735` |
| Attachments | `417a7ef1b24b12991649edc978bd3d0326a6720a` | `30bc9ea79846ee7ecc2730710998bc5801b42499` |
| Relationship audit | — | `857b3607a27d1b1a0e0edaf0badfcb3d06d61100` |
| Chat–Message | `59f86153eaeb67cf89e73c8380d38722fcf09d92` | `d526762e5f3dc3363c163025723f70c1953e3218` |
| Chat–Handle | `32b18a6add2e0280f089f21db0af48a4aaebcc12` | `b629f853d6c96496c0f70779f7e33a7c469fd6ac` |
| Message–Attachment | `b788c07e0bfead2e67f47027ff43fdf50423f494` | `540a52c908724629cefbb7ee4db113509a9edd99` |

Prompt 101 and Response 101 were already committed and pushed together by
`540a52c908724629cefbb7ee4db113509a9edd99`; no duplicate checkpoint was
created.

## 2. Consequential populated footprint

The active derived stores use source-scoped import schema version 10 and
Conversation Graph schema version 3. Overlay and Presence are independent
stores at schema versions 8 and 9 respectively.

### Active import-ledger material

The active source-scoped import database contains:

- source and execution context: `source_registry`, `import_batches`;
- source entities: `messages`, `handles`, `chats`, `contacts`,
  `contact_channels`, `attachments`;
- exact source relationships: `chat_to_message`, `chat_to_handle`,
  `message_to_attachment`;
- raw attributed-body bytes on imported message material and the later
  materialized `text` value produced by rich-text enrichment.

Source registry identity, source kind, source key, batch membership, source
row identity, and stable MessageLens `ss_id` values are consequential. Batch
timestamps and notes are operational evidence, but their referential
coherence is still consequential. No difference is permissible merely because
a column looks operational; each field must first be classified.

### Conversation Graph material

The graph contains:

- `messages` with source-independent semantic classification fields;
- `handles`, `canonical_handles`, `handle_aliases`;
- `chats`, `chat_to_message`, `chat_to_handle`;
- `contacts`, `contact_to_handle`;
- `attachments`, `message_to_attachment`;
- FTS5 `message_text_fts` and its content-table triggers.

Graph endpoint pairs do not retain every source-ledger provenance fact. In
particular, graph topology can collapse multiple source relationship rows into
one edge. Graph counts or matching topology therefore cannot prove exact
source-ledger reconstruction.

### Reset behavior presently available

The active reset service closes the source-scoped import and graph providers,
then deletes the enumerated active derived database files and sidecars:

- `macos_import_ss.db` and its SQLite sidecars;
- `working_ss.db` and its SQLite sidecars.

The broader legacy/advanced reset path can additionally enumerate retired
`macos_import.db` and `working.db`. This is not evidence that any current
installation is safe to reset. Deletion is irreversible with respect to source
material that no longer exists or cannot now be read.

### Protected and independent state

The following must not be treated as rebuildable derived data:

- `user_overlays.db`: favourites, tags, notes, visibility/spam decisions,
  manual associations, and other authored intent;
- `presence.db`: installation/operation presence and operational continuity;
- archived attachment payloads and archive manifest/generation/instance UUID;
- archive location mode, canonical root, marker, bookmark/configuration, and
  admitted archive binding;
- historical and non-live source registry entries and donor provenance;
- operation journals, transactions, failures, receipts, and recovery evidence;
- preferences, setup history, navigation state, logs, and external references.

The attachment archive is preservation data, not a cache. It remains outside
the reset set. Its existence or coverage cannot establish which message-to-
attachment relationship rows existed in an unavailable source.

### Domain-by-domain reconstructibility requirements

| Domain | Source of truth and current writer | Reset effect | Protected dependencies | Proof required before reset |
|---|---|---|---|---|
| Source registry | admitted source identities; source-scoped import orchestration | deleted with import DB | historical/non-live source identity, batch provenance | every retained source occurrence is presently observable or independently preserved and bound |
| Import batches | import orchestration | deleted | audit/recovery references | material-to-batch references coherent; operational differences explicitly classified |
| Eight ledger families | current Messages/Contacts sources through the eight canonical projections and importers | deleted | historical sources, graph rows, overlay/archive references | complete bidirectional material anti-diff under one stable observation |
| Rich text | raw attributed-body bytes plus Rust decoder and Dart enricher | decoded `text` lost | rendered/search text, semantic graph/FTS | byte availability, decoder identity, exact semantic result, and failure policy reproduced |
| Graph | graph build orchestrator and stateful repositories | deleted | overlay identifiers, UI references, archive relationships | disposable replay with exact production behavior plus bidirectional graph anti-diff |
| FTS | graph message writes plus FTS5 triggers | deleted | search behavior | exact schema/tokenizer/trigger identity and query-relevant disposable equivalence |
| Overlay | user-authoritative overlay writers | must be preserved | graph/contact/handle/message identifiers | every referenced identity either survives independently or is proved recreated identically |
| Presence/operations | presence and operation-specific writers | preserved/selectively managed | recovery and single-flight semantics | explicit classification; no accidental reset or stale cross-generation authority |
| Archive | archive actions and admitted archive authority | must be preserved | payloads, manifest, generation, UUID, location | same archive identity and generation before/after; no payload mutation |

## 3. The eight shared source projections

Each source projection is usable without importing a database writer or
mutation capability. The surrounding importer still owns source selection,
identity admission, endpoint lookup, batching, persistence, uniqueness, and
progress/failure behavior.

### Writer and projection edges

| Family | Production call edge | Canonical typed transform | Consequential behavior outside transform |
|---|---|---|---|
| Contacts | `ContactImporter` reads source contact/channel rows and calls the projection before ledger inserts | `projectSourceContact` and `projectSourceContactChannel` | source occurrence, enrichment availability, omitted contacts/channels, valid-contact membership, batch/progress, insert constraints |
| Messages | `MessageImporter` maps query rows to projection input and calls the projection before ledger persistence | `MessageSourceProjectionInput` → `projectSourceMessage` → `ProjectedSourceMessage` | source registry/batch, paging/high-water, `ss_id` allocation, anomaly accounting, insert/upsert semantics, later rich-text enrichment |
| Handles | `HandleImporter` calls the projection before handle persistence | `HandleSourceProjectionInput` → `projectSourceHandle` | source identity, local-account observation/reconciliation, batching, uniqueness, persistence |
| Chats | `ChatImporter` calls the projection before chat persistence | `ChatSourceProjectionInput` → `projectSourceChat` | source selection, batch, `ss_id`, uniqueness, persistence |
| Attachments | `AttachmentImporter` calls the projection before attachment persistence | `AttachmentSourceProjectionInput` → `projectSourceAttachment` | source/batch, paging, payload path availability, uniqueness, persistence; no archive-copy authority is acquired |
| Chat–Message | `ChatMessageJoinImporter` validates endpoints, then projects and persists | `ChatMessageRelationshipSourceProjectionInput` → `projectSourceChatMessageRelationship` | missing endpoint omission, relation-row `ROWID`, endpoint lookup, full/incremental scope, uniqueness, batching/persistence |
| Chat–Handle | `ChatHandleJoinImporter` validates endpoints, then projects and persists | `ChatHandleRelationshipSourceProjectionInput` → `projectSourceChatHandleRelationship` | missing endpoint omission, endpoint lookup, full scope, tuple uniqueness, batching/persistence |
| Message–Attachment | `MessageAttachmentJoinImporter` validates endpoints, then projects and persists | `MessageAttachmentRelationshipSourceProjectionInput` → `projectSourceMessageAttachmentRelationship` | missing endpoint omission, endpoint lookup, full/incremental scope, tuple uniqueness, batching/persistence |

### What parity proves—and does not prove

The qualification checkpoints prove that, for characterized inputs, the
importers now route through the extracted pure functions without changing
their observed output. They do not prove:

- that every current source row was observed under one stable source revision;
- that every persisted ledger row has a current authoritative source row;
- that a missing endpoint was safe to omit rather than historical evidence;
- that no extra ledger row came from a now-unavailable non-live source;
- that `ss_id`, source occurrence, batch, and provenance bindings can be
  recreated identically;
- that post-import rich-text, graph, FTS, or protected references match.

### Required bidirectional checks

For every family, a future witness must report separately:

1. expected projected rows missing from the ledger;
2. persisted material rows absent from the observed authoritative projection;
3. same identity with unequal material values;
4. source key/occurrence/provenance mismatch;
5. duplicate/cardinality mismatch;
6. endpoint rows omitted because either side was unavailable;
7. observation instability or incomplete paging.

For `chat_to_message`, the source relation row identity is retained in the
ledger, so duplicate endpoint pairs with distinct source relationship rows are
materially distinct. `chat_to_handle` and `message_to_attachment` use endpoint
tuple uniqueness because the source does not expose the same retained raw join
identity. The graph stores endpoint topology only and cannot substitute for
these ledger proofs.

## 4. Rich-text / typedstream boundary

### Current production path

`MessageRichTextEnricher` selects imported messages whose `text` is null and
whose attributed-body bytes exist. It freezes a candidate count and high-water
`ss_id`, pages candidates in groups of 500 with an approximate 8 MiB page
target, and refuses an individual blob above 8 MiB. It loads exact expected
blob lengths, calls the Flutter Rust Bridge adapter, trims the returned text,
and conditionally updates only rows where `text IS NULL`.

The Rust boundary is the synchronous
`decode_typedstream_blob(Vec<u8>) -> Result<String, String>` function. The
decoder uses `crabstep` typedstream parsing and applies explicit input and
traversal limits, including the 8 MiB envelope, marker/reference limits,
property-depth limit, and node-count limit. Panic is converted to an error.
The current semantic selection returns the last accepted, trimmed, nonempty
candidate not beginning with internal `__` or `NS` markers.

Per-record decoder failure or an empty result leaves the anomalous message
visible with no enriched text and is logged/counted. Decoder unavailability or
frozen-candidate disagreement is systemic evidence, not permission to omit a
message.

### Equivalence boundary

Two distinct claims must not be conflated:

- **Byte-exact equivalence:** the same attributed-body bytes are still
  available and bound to the same source message occurrence.
- **Semantic equivalence:** the same qualified decoder implementation,
  dependency/version/platform assumptions, trimming and candidate policy
  produce the same persisted text or the same typed failure/anomaly.

The repository has no shared typed pure boundary for the complete per-record
semantic decision. The Rust decoder is deterministic for a supplied byte
vector, but candidate admission, size handling, empty/error classification,
conditional materialization, and counts remain embedded in the stateful
enricher. A future witness cannot safely reimplement those rules.

If source bytes disappeared, the decoder is unavailable, the supported
envelope changes, or a source scan changes during observation, rich-text
reconstructibility is `UNKNOWN` unless a known material mismatch independently
establishes `FALSE`.

## 5. Conversation Graph and canonical identities

### Actual writer order

The graph build orchestration imports the source ledger, enriches rich text,
then projects handles, contacts, chat–handle edges, chats, messages,
attachments, chat–message edges, and message–attachment edges. Full and
incremental paths do not all use the same scope:

- handles, contacts, chat–handle relationships, and chats are full projections;
- messages can project after a source-row cursor;
- chat–message and message–attachment can project incrementally after a
  source-message cursor;
- attachments project incrementally only in the qualifying new-message/new-
  attachment case and otherwise may project fully or be skipped;
- archive import/removal paths also invoke graph projectors.

### Consequential stateful transforms

The following graph semantics are not the eight simple source projections:

- **Messages:** resolve same-source associated-message GUIDs; resolve sender
  canonical handles from current alias state; classify semantic/item kind,
  system/sparse status, evidence flags, and error code; upsert every message.
- **Handles:** upsert handles; rebuild canonical handles and aliases using
  normalization and deterministic preference; reconcile local accounts;
  rewrite message canonical sender references; remove invalid contact edges.
- **Contacts:** filter empty/placeholder contacts; normalize channels; match
  contact channels against graph alias/canonical identities; create the first
  eligible `contact_to_handle` edge.
- **Chats:** derive `is_group` from the graph's current participant-edge count;
  current insert behavior does not necessarily rewrite an already-present
  chat row.
- **Attachments:** insert or update graph material fields from ledger
  attachments.
- **Relationships:** reduce exact source-ledger relationships to graph endpoint
  pairs with `INSERT OR IGNORE`, discarding raw join identity and source
  provenance.

These transforms are stateful but potentially reproducible in a disposable
graph only when their complete inputs, ordering, schema, source occurrence,
and prior-state assumptions are explicit. They are presently unproven as a
read-only populated equivalence witness.

### Unsafe graph differences

A reset is unsafe if any of the following are observed:

- an existing graph row or edge has no authoritative reconstructible input;
- a source-ledger relation would recreate different graph topology;
- canonical handle/alias choices differ;
- an overlay references a graph identity absent from the expected recreated
  identity set;
- a contact link or group-chat classification differs because graph state or
  ordering differs;
- incremental and full projection produce materially different final state;
- cross-source/historical provenance is collapsed and cannot be recovered.

## 6. FTS equivalence

The graph uses FTS5 table `message_text_fts` with:

- external content table: `messages`;
- content row identity: message `ss_id`;
- indexed field: `text`;
- tokenizer: `unicode61 remove_diacritics 2`;
- prefix configuration: `2 3 4`;
- insert, delete, and update triggers on graph `messages`.

Ordinary graph projection relies on those triggers. Schema migration can issue
an FTS `rebuild`, but no live rebuild was run or is authorized by this audit.

Row counts are insufficient. A read-only proof requires the same graph schema,
SQLite/FTS configuration, enriched message text, and row identities. The safe
comparison is to construct a disposable graph from the bound expected material
through the production schema/writers, then compare normalized FTS row
identity/text material and a bounded query corpus in both directions. Any
disposable index mutation must be confined outside the admitted live root.
Failure to load equivalent FTS support or any query-result disagreement is
`UNKNOWN` or `FALSE` as appropriate; it is never a reason to rebuild the live
index during diagnosis.

## 7. Known `FALSE` and `UNKNOWN` cases

### `FALSE` examples

- A historical/non-live ledger row has no presently available authoritative
  source occurrence and would be deleted.
- A formerly imported live message, relationship, handle, chat, attachment, or
  contact is now absent from the live source but remains consequential.
- A raw source relationship row or tuple cannot be reproduced even though a
  collapsed graph edge still exists.
- An overlay favourite, tag, note, manual link, or other authored record points
  to an identity absent from the proved recreated set.
- A persisted decoded text value, canonical-handle choice, contact link,
  message classification, group status, attachment edge, or FTS result differs
  from the bound expected output.
- A required archived payload or required archive relationship is known absent
  and no preserved authoritative record can restore it.
- Material exists in an active/retired store but no supported production
  transform can recreate it.

### `UNKNOWN` examples

- Messages, Contacts, a historical source, or a required store cannot be read.
- The source changes between the beginning and end material samples or between
  bounded pages.
- A scan is incomplete, a page fails, schema is unsupported, or evidence
  conflicts.
- The attributed-body bytes or qualified decoder are unavailable, or decoder
  behavior cannot be bound to the current implementation.
- A source occurrence cannot be distinguished from another database at the
  same path.
- Archive UUID/root/generation or ledger source identity changes during the
  observation.
- Graph or FTS equivalence cannot be evaluated within the bounded resource
  envelope.
- Presence, journal, transaction, or recovery evidence cannot be classified as
  preserved operational state versus consequential material.

### `TRUE` requirement

`TRUE` requires a coherent proof across every required material domain, not an
absence of detected errors. All required sources and occurrences must be
bound; all scans must be stable and complete; ledger, rich text, graph, and
FTS must compare bidirectionally; protected references must remain valid; and
archive/presence/operation state must be preserved. Any `FALSE` dominates.
Otherwise any unresolved `UNKNOWN` prevents `TRUE`.

Archive coverage is only payload-availability evidence. It does not prove
message-to-attachment source relationship provenance, and it cannot upgrade a
relationship `FALSE` or `UNKNOWN` to `TRUE`.

## 8. Smallest complete future read-only witness

The future witness should be a Fair Witness evidence reader, not a coordinator,
policy, evaluator, or reset service. It must acquire no mutation Ball.

### Binding and observation model

One witness generation should bind:

- admitted archive instance UUID, canonical data root, attachment root and
  generation;
- exact source-registry identity and physical source occurrence/fingerprint;
- current source schema and stable opening identity;
- import, graph, overlay, and Presence schema versions;
- application/build identity and projection/decoder implementation identity;
- bounded observation start/end material samples.

The reader should use a stable read-only source transaction when supported and
also compare bounded material samples before and after the paged scan. One
mismatch permits at most the specified bounded retry; a second mismatch is
`UNKNOWN`. It must not loop until evidence happens to agree.

### Bounded comparison pipeline

1. Inventory live, historical, and non-live source occurrences plus protected
   references before reading derived material.
2. Page each authoritative source with explicit row and byte budgets,
   high-water/cursor evidence, cancellation, and a total time/memory envelope.
3. Route source rows through the exact qualified canonical source projections.
4. Compare expected import-ledger material bidirectionally, separating
   classified material fields from operational batch/timestamp fields while
   still checking referential coherence.
5. Reproduce rich-text semantic outcomes through the shared qualified boundary
   using exact bound bytes and decoder identity.
6. Replay production graph transforms into a disposable database with the
   production ordering and compare every material table/edge in both
   directions, including aliases, classifications, and references.
7. Build/query only the disposable FTS index, then compare row identity/text
   and a bounded diagnostic query corpus with the live read-only index.
8. Verify every overlay, archive, Presence, journal, receipt, and historical
   reference either remains independent/preserved or resolves to an expected
   recreated identity.
9. Publish typed domain evidence and a conjunction result of
   `TRUE`/`FALSE`/`UNKNOWN`, with exact mismatch diagnostics and no command.
10. If destructive work is ever separately authorized, rerun the complete
    bound observation immediately before deletion and require the same
    generation/occurrence/evidence fingerprint. This audit does not authorize
    that consumer.

The witness must never retain capability, mutate a live derived store, repair
evidence, infer policy, or publish an AppCzar jurisdiction.

## 9. Evidence-gap matrix

| Domain | Existing production source / qualified evidence | Missing proof | Minimal synthetic/disposable characterization | Architecture enforcement | Performance / stop gate |
|---|---|---|---|---|---|
| Source binding and registry | admission authority, source registry/import batches | coherent physical occurrence and stable scan across all sources | synthetic replacement-at-same-path and mid-scan-change cases | witness imports read-only evidence seams only | stop on identity change, unreadable source, or unbounded retry |
| Contacts/channels | qualified canonical projection; importer parity | full anti-diff, omitted-row justification, historical source availability | paged synthetic source/ledger with missing, extra, duplicate, placeholder and unavailable enrichment | projection must remain DB/mutation-free | stop if omission loses material or paging is unstable |
| Messages | qualified 22-column projection; importer parity | complete paging, `ss_id`/batch/provenance identity, enriched-text distinction | boundary/high-water and missing/extra/value/provenance fixtures | no record suppression; DateConverter remains sole timestamp authority | stop on changed high-water, source occurrence, or anomaly suppression |
| Handles | qualified canonical projection | local-account reconciliation and final alias/canonical equivalence | ambiguous aliases, service variants, `is_me`, cross-source collision fixtures | source transform remains independent of graph repository | stop if normalization preference cannot be reproduced |
| Chats | qualified canonical projection | final group status and existing-row behavior | participant-count/order and pre-existing graph fixtures | source chat transform must not consult graph | stop if replay order changes material result |
| Attachments | qualified canonical projection | source-path availability, archive binding and edge/payload distinction | source-present/absent, duplicate, changed metadata, same payload/different relation fixtures | no archive mutation capability | stop on archive generation/root change or payload I/O requirement |
| Chat–Message | qualified relation projection, including source relation row identity | complete relation-row anti-diff and collapsed-graph provenance | duplicate endpoint pairs with distinct raw relation IDs | ledger projection independent of graph | stop if graph topology is used as provenance proof |
| Chat–Handle | qualified tuple projection | complete tuple anti-diff and missing-endpoint effects | duplicate tuple, absent endpoint, cross-source fixtures | no graph writer import | stop if omitted endpoint is unexplained |
| Message–Attachment | qualified tuple projection | complete tuple anti-diff and payload-vs-relation distinction | same attachment bytes with changed/missing relationship fixtures | archive coverage cannot authorize relation equivalence | stop on unavailable endpoint or archive identity conflict |
| Rich text | production enricher and Rust decoder; existing focused tests | shared per-record semantic decision, decoder fingerprint, byte/semantic anti-diff | boundary-size, empty, whitespace, panic/error, unavailable decoder, version-change fixtures | pure semantic projection may not import DB, graph, reset, archive, or capability types | stop if exact parity requires Rust behavior change or real data |
| Graph | production repositories/orchestrator | complete disposable replay equivalence; state/order/full-vs-incremental parity | synthetic multi-source graph with alias/contact/group/classification/duplicate-edge cases | witness may depend on read-only output contracts, never graph mutation against live store | stop on live write, nondeterminism, or unresolved historical input |
| FTS | schema, tokenizer and triggers | query-relevant equivalence and runtime compatibility | disposable production-schema graph plus bounded query corpus | no live rebuild API reachable by witness | stop if FTS implementation/config cannot be matched |
| Overlay/protected refs | overlay schema and merged readers | total reference inventory and recreated-target proof | dangling message/handle/chat/contact and historical-target fixtures | overlay remains authoritative and independent | any dangling protected reference is `FALSE` |
| Presence/operations | Presence schema and operation journals | material/operational classification and cross-generation safety | stale generation, unfinished operation, receipt and journal fixtures | evidence only; no semantic authority migration | stop on unclassified or conflicting operation evidence |
| Archive | admitted archive authority and coverage readers | relation provenance and same-generation preflight | same bytes/different UUID, generation change, missing relation, disconnected root | no payload/location mutation; archive invariant test | stop on any binding change or unavailable evidence |

## 10. Exact Prompt 103 recommendation

### Milestone

**Characterize and extract the canonical per-record rich-text semantic source
projection.**

This comes first because rich-text materialization is the first consequential
production transform after the eight now-qualified source-ledger projections,
and both graph message material and FTS depend on its output. Building an
anti-diff reader or disposable graph first would force it either to duplicate
rich-text semantics or to accept a second authority. This recommendation is
not based merely on a preference for another pure function; it closes the
earliest demonstrated shared-semantic gap in the dependency chain.

### Permitted implementation scope

- Add one typed, DB-free rich-text source-projection model/function under
  `lib/essentials/source_scoped_import/application/messages/`.
- Route only the existing per-record `MessageRichTextEnricher` decision through
  that function with exact behavior parity.
- Add focused characterization/parity tests under the matching test path.
- Add one architecture test enforcing that the pure projection cannot import
  database, graph, archive, reset, AppCzar/coordinator, or mutation-capability
  types.
- Update only Prompt/Response 103 and release/documentation metadata if the
  governing Prompt 103 explicitly requires them.

No Rust code, schema, writer ordering, reset logic, witness aggregator, graph,
FTS, AppCzar jurisdiction, or production composition may change.

### Mandatory pre-edit characterization

Before editing production code, characterize current behavior for:

- existing non-null text;
- null text with valid decoded output;
- trimming and empty/whitespace decoder output;
- exact 8 MiB boundary and over-limit input;
- expected-length mismatch;
- per-record decoder error/panic conversion;
- systemic decoder unavailability;
- conditional `text IS NULL` persistence behavior;
- frozen candidate count/high-water mismatch;
- anomaly and progress counts without suppressing a source record.

The extracted function should own only the deterministic single-record
semantic result. Paging, source observation, Rust invocation, DB reads/writes,
transactions, progress, retries, and systemic failure remain with their
existing specialists.

### Validation expectations

1. Pre-edit characterization tests pass against the current implementation.
2. The same tests pass after routing production through the extracted function.
3. Direct pure-function tests cover every typed outcome and boundary.
4. Architecture tests prove the new file has no mutation or persistence
   dependency.
5. Existing rich-text/import tests, forbidden-import architecture tests, full
   Flutter tests, and analyzer pass on the final code state, subject to the
   future Prompt 103 validation instructions.
6. Generated files change only if legitimately required by an explicitly
   approved provider annotation; none is expected for this pure function.

### Prompt 103 stop gates

Stop rather than improvise if:

- current behavior cannot be characterized without reading real user data;
- parity requires changing Rust decoder behavior, limits, dependency versions,
  schema, or persisted output;
- the decision depends on mutable page/batch/DB state that cannot be separated
  into explicit typed input;
- the function would need a database, graph, archive, reset, coordinator,
  policy, or mutation-capability dependency;
- any source record would become suppressed or any anomaly swallowed;
- focused parity, architecture, full-suite, or analyzer evidence contradicts
  the proposed extraction.

Prompt 103 must end after that extraction/checkpoint. It must not begin the
complete populated witness.

## 11. Dependency-ordered roadmap

1. **Further shared transformations:** Prompt 103 rich-text semantic
   projection, followed by separately authorized characterization of stateful
   graph semantics only where a shared deterministic boundary is actually
   needed. Do not bulk-extract repositories.
2. **Complete populated read-only witness:** bind coherent observations; run
   ledger anti-diffs; reproduce rich text; replay graph/FTS only in disposable
   stores; verify protected references; publish typed evidence only.
3. **Adversarial and human qualification:** source replacement/instability,
   historical disappearance, decoder failure, graph collisions, FTS drift,
   archive generation change, dangling overlay references, bounded-resource
   failure, restart/currentness, and real UI diagnostics without live mutation.
4. **Operating-owned Start Fresh:** only after a separately reviewed policy
   consumes a freshly revalidated `TRUE` witness and preserves all independent
   state. Design, implementation, and destructive qualification remain future
   work.
5. **Production-safe shell and cutover:** only after all seven jurisdictions,
   production identity/FDA continuity, release packaging, rollback, and
   production-specific human qualification are separately complete.

## 12. Project Conformance

**Audit/design verdict: PASS.**

The audit used current source as authority, kept source-ledger projections
separate from graph topology, preserved central database boundaries, retained
DateConverter authority, treated overlay intent and the attachment archive as
protected, and introduced no parallel state authority or mutation path.

Readiness findings for destructive Stage 2C:

- **BLOCKER: 7**
  1. no coherent all-source occurrence/observation binding;
  2. no complete bidirectional import-ledger anti-diff;
  3. no shared and fingerprinted rich-text semantic projection;
  4. no qualified disposable graph equivalence replay;
  5. no query-relevant FTS equivalence proof;
  6. no complete historical/protected-reference preservation proof;
  7. no fresh same-binding pre-mutation revalidation contract.
- **SHOULD FIX: 2**
  1. make material-versus-operational field classification explicit in future
     evidence diagnostics;
  2. establish bounded paging, byte, time, and disposable-store resource
     envelopes before human qualification.

These are blockers to destructive readiness, not failures of this read-only
audit. No blocker was concealed or converted into authorization.

## 13. Final repository and safety state

This response is the only file created by the audit and remains untracked for
review. Prompt 102 and all unrelated untracked files remain untouched. No
source, test, schema, generated, release, dependency, packaging, tracked
documentation, database, archive, app, FDA/TCC, bookmark, environment, S3, or
installed-app state was changed. No build, analyzer, or Flutter suite was run.

Continuing prohibitions remain in force: no Prompt 103 implementation, no
destructive Stage 2C, no mutation Ball, no AppCzar jurisdiction changes, and no
production activation or cutover.

EIGHT SOURCE-SCOPED PROJECTIONS CHECKPOINTED: YES
POPULATED RECONSTRUCTION FOOTPRINT INVENTORIED: YES
RICH-TEXT, GRAPH, AND FTS EQUIVALENCE GAPS IDENTIFIED: YES
PROTECTED AND HISTORICAL DATA BOUNDARIES IDENTIFIED: YES
COMPLETE READ-ONLY POPULATED WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES
PROJECT CONFORMANCE (AUDIT/DESIGN): PASS
READY FOR NARROW PROMPT 103: YES
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
