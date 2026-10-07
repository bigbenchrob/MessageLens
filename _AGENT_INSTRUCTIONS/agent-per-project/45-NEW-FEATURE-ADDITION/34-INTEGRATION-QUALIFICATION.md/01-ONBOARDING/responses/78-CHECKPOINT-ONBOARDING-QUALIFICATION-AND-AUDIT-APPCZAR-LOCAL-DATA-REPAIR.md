# MessageLens Feature 34
## Response 78 — Checkpoint Onboarding Qualification and Audit the AppCzar Local Data Repair Jurisdiction

Date: 2026-10-07

This response records the Prompt 77/Response 77 qualification checkpoint and
the requested read-only Local Data Repair audit. No Local Data Repair source,
test, generated, release-metadata, or project implementation was added.

## 1. Baseline verification

The required baseline passed before the checkpoint:

- primary worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- pre-checkpoint HEAD and upstream:
  `15c1e9787af09223287e842a293a98a53d632ff2`;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree: the primary worktree. The other listed Git
  worktrees belong to separate branches/features;
- unrelated untracked files were left untouched.

A fresh external manifest was created at:

`/private/tmp/messagelens-prompt78-baseline-20261007.md`

It records the baseline branch, commit, submodule, worktree, untracked-file,
and Prompt/Response hashes outside the repository worktree.

Reviewed against:

- Responses 40, 41, 71, 72, and 77;
- Prompt 78;
- current AppCzar domain, evaluator, assessment provider, observation reader,
  startup harness, and presentation projector;
- the current physical installation-evidence reader and initial-scope
  classifier;
- `MessageDataResetService`, its filesystem store, database file registry, and
  mutation-operation policy;
- Start Fresh service, action, and artifact policy;
- source-scoped import schema, source identities, lineage readers, and
  historical-source import/removal services;
- graph health/coherence readers;
- archive, overlay, Presence, marker, and mutation-authority boundaries;
- MessageLens Project Conformance Audit Standard;
- applicable repository guardrails, database/preservation rules, and the
  exclusive-authority architecture.

No real archive, real database, or application process was opened by this
audit.

## 2. Prompt 77 / Response 77 documentation checkpoint

Prompt 77 and Response 77 alone were staged and checked. The checkpoint is:

- commit: `3fd20ffd2d26a0305e92948bf7b1c5cada0c9798`;
- message: `docs(onboarding): record AppCzar qualification`;
- push: successful;
- local/upstream after push: `0/0` at the same commit.

The checkpoint records:

```text
AppCzar Onboarding human live qualification: PASS

Qualified safe-empty path:
    disposable admitted development root
    AppCzar composition
    AppCzar Onboarding
    source prerequisite owned by AppCzar Onboarding
    legacy Journey inert
    existing initial-build pipeline
    real process restart
    fresh AppCzar post-build disposition

Qualified unsafe path:
    consequential partial data
    NOT Onboarding
    virtual Local Data Repair
    no build
    no cleanup
    partial data unchanged
```

The successful disposable build imported `139071` source messages, projected
`139071` graph messages, and reached fresh post-build Attachment Archive
Repair.

## 3. Current AppCzar execution census

Source reconfirms exactly:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Local Data Repair           VIRTUAL ONLY
Diagnostic Review           VIRTUAL ONLY
```

`AppCzarStartupHarness` has explicit branches for Data Update, Onboarding,
Source Access Repair, Attachment Archive Repair, and Operating. It has no Local
Data Repair or Diagnostic Review executor branch and no generic
`execute(coordinator)` dispatcher. Successfully admitted official development
builds use the AppCzar composition. Production still selects legacy startup.

## 4. Exact current Local Data Repair selection frontier

The current evaluator selects virtual Local Data Repair from three coarse
frontiers:

1. initial-construction scope is `retiredOrUnsupportedMaterial` or
   `unhealthy`;
2. import, graph, or overlay observation is `unhealthy`;
3. initial scope is `consequentialData` or `protectedNonLiveData` while
   `localDatasetComplete` is not `TRUE`.

This frontier is source-grounded: it is rebuilt from present physical database
observations, not from a durable Journey cursor or an assertion that an earlier
operation was interrupted. It is not yet a mutation-safety frontier. Several
materially different safety classes collapse into the same virtual label.

## 5. Mapping of each Local Data Repair case to current facts/dispositions

| Case | Current observation/fact | Current disposition/mapping | Automatic action safe now? |
|---|---|---|---|
| A. Consequential partial import/graph data | At least one import-message, graph-message, graph-chat, or graph-edge count is positive; `initialConstructionScopeSafe=FALSE`; `localDatasetComplete!=TRUE` | `localDataNeedsRepair` -> virtual Local Data Repair | No. Present live provenance and partial counts do not prove current reconstructibility. |
| B. Import/graph internally unhealthy or corrupt | Bounded inspection `failed`, schema unsupported/mismatched, or import/graph observation `unhealthy` | Failed inspection/unsupported scope -> virtual Local Data Repair; inconclusive/contended inspection -> Diagnostic Review | No. Failure may hide protected source inventory. |
| C. Import/graph structurally inconsistent | Simple count/topology mismatch can make `localDatasetComplete=FALSE` and consequential scope selects Local Data Repair | Virtual Local Data Repair where the shallow observations detect it | No. Full graph-health/coherence is not an AppCzar fact; deeper inconsistency may be missed by the current completeness test. |
| D. Protected non-live/historical material in an incomplete dataset | The current existence-style `nonLiveSourceCount` is positive; scope is `protectedNonLiveData`; completeness not TRUE | `localDataNeedsRepair` -> virtual Local Data Repair | No. Whole-store reset would delete protected rows. |
| E. Retired/unsupported derived artifacts | Retired named files exist, a store schema is unsupported, or schema version mismatches | `localDataNeedsRepair` -> virtual Local Data Repair | No as one umbrella action. Presence/name alone does not prove absence of unique historical data. |
| F. Complete dataset with incompatible current-source lineage | No explicit current AppCzar lineage-equivalence fact exists | If count/high-water becomes backward or contradictory, Diagnostic Review; equal count/high-water can fail to expose a same-sized lineage divergence | No. Current source does not reliably select Local Data Repair for this class. |
| G. Current source older/divergent from local derived data | Source count or max ROWID lower than local makes `sourceAheadOfLocal=UNKNOWN` | Diagnostic Review | No. Count/high-water does not prove row identity or recoverability. |
| H. Local-store evidence UNKNOWN/inconclusive | Database observation `unknown`, scope `unknown`, contention, or other inconclusive read | Diagnostic Review | No, correctly fail-closed for UNKNOWN. |

The critical defect for a future executable coordinator is not the current
virtual routing. It is that positively `unhealthy`/unsupported evidence routes
to Local Data Repair before repair safety or protected provenance can be
proved.

## 6. Current F18–F21 implementation status

Response 41's protection chain is only partly represented:

- **F18 — protected non-live material present:** partially present. The
  physical reader runs an indexed/bounded `EXISTS` query for any
  `source_registry.source_id` outside the two reserved live IDs. The field is
  called `nonLiveSourceCount`, but its value is only `0` or `1` existence
  evidence.
- **F19 — incomplete consequential derived data exists:** coarsely present.
  Positive import/graph counts plus failure of the current shallow complete-
  dataset predicate establish consequential partial state.
- **F20 — incomplete data contains only live-source material:** implied only by
  F18's absence-style result. Exact source identities and per-source row
  families are not carried into an AppCzar fact.
- **F21 — incomplete live-only data is reconstructible from the current
  source:** absent. Neither count/high-water comparison nor source ID proves
  that every deleted fact still exists in current Messages/Contacts sources.

Current code therefore cannot prove the entire required conjunction.

## 7. Exact current definition of consequential partial data

The initial-scope classifier calls data consequential when no earlier
contention, unsupported-schema, failed-inspection, retired-artifact, or non-live
source condition applies and at least one of these counts is positive:

- source-scoped import `messages`;
- graph `messages`;
- graph `chats`;
- graph `chat_to_message` edges.

It is partial for evaluator purposes when `localDatasetComplete != TRUE`.
Current completeness means healthy import and graph observations, a positive
import-message count, equal import/graph message counts, and positive graph
chat and edge counts. This is intentionally narrower than full graph integrity
and broader than exact source reconstructibility.

## 8. Exact current definition of protected non-live/historical data

The source-scoped import database records every source in `source_registry`
with `source_id`, canonical `source_key`, `source_kind`, optional label, and
creation time. Reserved live sources are current Messages and current Address
Book. Historical Messages archives use their own canonical source identity and
non-live source kind.

Current initial-scope evidence defines protected non-live presence as:

```sql
EXISTS(
  SELECT 1
  FROM source_registry
  WHERE source_id NOT IN (live_chat_db_id, live_address_book_id)
  LIMIT 1
)
```

That bounded query proves presence/absence under a readable supported schema.
It does not enumerate exact identities or row counts.

## 9. Reconstructibility fact design

The minimum new Fair-Witness fact is:

```text
IncompleteLiveOnlyDerivedDataIsReconstructibleFromCurrentSources
```

It may be `TRUE` only when one coherent bounded observation proves all of the
following:

1. the admitted root, source identities, schemas, and source sample are stable;
2. every source-scoped import source is one of the currently authoritative live
   sources required by the rows being deleted;
3. no protected non-live source exists;
4. every consequential imported source key and relationship that reset would
   delete still has a compatible authoritative source fact now;
5. graph rows are only derivations of those proven import facts and contain no
   independent source/provenance class;
6. attachment payload preservation and user-intent stores are outside the
   deletion set;
7. a second fresh proof immediately before mutation still agrees with the
   classified occurrence.

FALSE means current evidence positively proves lost/divergent source material.
UNKNOWN means any required table, source, identity, or comparison could not be
proved. Only TRUE can authorize automatic reset.

## 10. Proof live provenance alone is insufficient

`source_id = live_chat_db` proves where a row originally came from. It does not
prove that the same source row still exists in today's `chat.db`, that the GUID
still agrees, that a relationship or attachment metadata row remains present,
or that current Contacts can reconstruct Address Book-derived rows.

A historical deletion from Messages, source replacement, restored/rotated
database, ROWID reuse, or changed relationship can leave a locally imported
live-origin fact that is no longer reconstructible. Provenance is necessary,
not sufficient.

## 11. Exact bounded source-comparison strategy

The preferred implementation is a dedicated read-only infrastructure witness,
not full-table Dart materialization:

1. open the admitted import ledger and authoritative source databases read-only
   under one bounded source-sample occurrence;
2. verify the exact live source-registry identities and prove no non-live
   registry row;
3. use indexed SQL `NOT EXISTS`/anti-join queries in both directions for each
   consequential source-backed table family, beginning with Messages identity
   `(source_rowid, guid)` and extending to handles, chats, chat/message and
   chat/handle relationships, attachments, message/attachment relationships,
   contacts, and contact channels;
4. require zero missing local keys, zero identity contradictions, zero malformed
   identity rows, and zero unsupported source families;
5. verify graph derivation coherence against the proven import ledger using the
   existing graph-health semantics rather than treating count equality as
   integrity;
6. take a second bounded material sample; one mismatch permits one complete
   retry, and a second mismatch yields UNKNOWN/Diagnostic Review;
7. return counts/digests and typed truth only, never message text or a
   materialized row manifest;
8. rerun the proof at mutation admission.

Existing lineage-anchor readers materialize all ROWID/GUID anchors and their
current admission threshold proves lineage compatibility rather than complete
reconstructibility. They cannot be reused as F21 unchanged.

The safest coarser condition available without this new witness is: do not
automatically delete a consequential source-scoped import database at all.
That avoids data loss but does not provide useful Local Data Repair.

## 12. Historical/non-live representation in the import DB

`source_registry` is the source authority. Source-backed tables use
`source_id`/source-row identifiers and unique source-scoped keys. The schema
includes import batches, messages, handles, chats, chat/message links,
chat/handle links, contacts, contact channels, attachments, and
message/attachment links. Historical sources therefore coexist in the same
physical `macos_import_ss.db` as live-source facts.

## 13. Protected-source inventory/readability result

1. Bounded non-live presence: **yes**, with the current `EXISTS` query.
2. Exact source identity enumeration: **feasible but not currently exposed to
   AppCzar**. A bounded ordered query over the small `source_registry` can
   return source ID/key/kind/label plus per-source aggregate counts.
3. Whole-ledger reset includes protected rows: **yes**.
4. Existing whole-store reset could destroy protected historical material:
   **yes**.
5. Live-only repair without deleting historical rows would require a new
   partial-ledger surgery/reprojection workflow: **yes**. It is out of scope and
   must not be invented here.
6. Historical-source removal has a separate owner: **yes**. It uses explicit
   source identity, `historicalArchiveRemoval` mutation authority, source-
   scoped ledger deletion, and graph reprojection from remaining sources.

Default rule:

```text
protected non-live/historical material present
-> no automatic whole-derived-store reset
```

## 14. `MessageDataResetService` exact deletion inventory

The service deletes four enumerated database base names from the admitted data
directory:

- active `macos_import_ss.db`;
- active `working_ss.db`;
- retired `macos_import.db`;
- retired `working.db`.

For each it also deletes an existing regular-file `-wal` and `-shm` sidecar.
It closes the source-scoped import database if its base file exists, closes the
conversation-graph connection if active, deletes active files, deletes retired
files, invalidates providers that were open, bumps `messageDataVersion`, and
records an existence check.

The existence result is logged only. Remaining files do not cause the method to
fail, so the current postcondition is not strong enough for an executable
repair success claim.

## 15. Reset preservation inventory

The enumerated deletion set excludes and therefore preserves:

- `user_overlays.db` and user intent;
- `presence.db`;
- the archive marker/instance identity;
- `attachment_archive/` and all archived payloads;
- attachment archive configuration/bookmark evidence;
- application preferences;
- logs/diagnostics;
- derived media and unrelated files;
- archive instance lock state.

`MessageDataResetService` itself does not reset Journey/operation evidence or
Presence scheduling. Start Fresh performs additional selective overlay and
Presence work above this lower service.

## 16. Reset path/basename safeguards

The filesystem store accepts base names only. It rejects empty values,
absolute paths, values that differ from their basename, and backslash-bearing
values. It joins the validated basename to the admitted database directory and
deletes only regular files with `followLinks: false`, so it does not follow or
delete symlinks.

The production caller uses the closed `AppDatabaseFile` enumeration. There is
no broad-root recursive deletion. The post-delete weakness remains: existence
is observed and logged, not enforced as an exception.

## 17. Reset mutation/Ball/lock path

`resetDerivedData()` currently self-authorizes by calling
`ArchiveMutationCoordinator.runWithCapability` with operation
`messageDataReset` and owner label `message-data-reset`. That operation blocks
database reopen and requires the verified production checkpoint policy.

`resetDerivedDataForStartFresh(capability)` instead requires the caller's
existing `startFresh` capability and reuses lower mechanics without a nested
Ball tenure.

The Archive Mutation Coordinator holds the singular Exclusive Authority Ball
and call-local typed capability. Provider/connection close plus the operation's
database-reopen gate are the operative local guards. No separate repair lock or
durable repair lease exists.

Local Data Repair must not call the self-authorizing method from inside another
tenure. It needs a new narrow typed `localDataRepair` operation and a
capability-taking lower reset entry point (or equivalent extraction), with one
controller-owned tenure only.

## 18. Reset interruption/idempotence behavior

Per-file deletion is idempotent: missing regular files are skipped, and a retry
can continue deleting remaining enumerated files. The entire operation is not
atomic. Interruption can leave one active database deleted while another, a
sidecar, or retired file remains.

Database-close failures are logged and deletion continues. There is no durable
reset journal. A delete error propagates, but post-delete leftovers merely log.
Therefore no in-process classification remains trustworthy once mutation may
have begun. Any terminal success or failure after mutation admission requires
drain and real restart.

## 19. Start Fresh versus Local Data Repair

Start Fresh is an explicit human advanced command. It owns its own eligibility,
confirmation, typed `startFresh` capability, operation/failure cleanup,
Presence-run supersession, lower derived-data reset, and virgin-state
validation.

Local Data Repair is system-selected from current AppCzar facts. It may act
automatically only on a narrower freshly proved rebuildable class. It must not
inherit Start Fresh's product consent, legacy Journey semantics, broad caller
authority, or additional overlay/Presence reset behavior merely because both
can reuse lower enumerated file mechanics.

## 20. Historical-source removal versus Local Data Repair

Historical-source removal is an explicit specialist workflow for one selected
canonical historical source. It obtains `historicalArchiveRemoval` authority,
deletes only that source's ledger rows, preserves donor files and other source
facts, then reprojects the graph.

Local Data Repair has no authority to select or remove a protected historical
source. Presence of such material blocks automatic whole-store reset. Any
source-specific removal remains in the specialist workflow.

## 21. Proposed Local Data Repair class taxonomy

| Class | Literal facts | Jurisdiction/action | Terminal |
|---|---|---|---|
| `rebuildableLiveOnlyPartial` | Partial consequential active derived data; exact live-source identities only; no protected source; all deleted source-backed facts currently reconstructible; graph purely derived; preservation stores healthy | Local Data Repair; automatic mutation is safe after fresh revalidation; no human consent adds safety | Drain, release Ball, restart |
| `protectedHistoricalMaterial` | Incomplete state includes any non-live/historical source, or exact inventory cannot exclude it | Local Data Repair attention or future Historical Protection presentation; no automatic mutation | Diagnostics/quit; specialist human workflow only |
| `unhealthyReconstructibilityUnknown` | Corruption/unsupported inspection prevents proving source inventory or reconstructibility | Diagnostic Review, not executable repair | Diagnostics/quit/reassess only |
| `retiredDerivedResidue` | Only explicitly recognized retired files exist; active/preservation facts safe; a dedicated bounded classifier proves their allowed content is non-authoritative and non-unique | Local Data Repair only after that classifier exists; otherwise Diagnostic Review | If safely removed: restart; otherwise no mutation |
| `lineageConflict` | Current and local identities diverge, local is ahead, or complete reconstructibility is FALSE | Diagnostic Review by default; no automatic reset | Diagnostics/quit; future explicit recovery design |
| `unknownOrConflicting` | Any safety prerequisite UNKNOWN, unstable, or contradictory | Diagnostic Review | No mutation |

This taxonomy is smaller and safer than treating every unhealthy derived file
as disposable.

## 22. Automatic-versus-human-confirmed repair decision

Choose **automatic** only for `rebuildableLiveOnlyPartial`, because the exact
predicate proves the deleted files are entirely derived, currently
reconstructible, and contain no protected/user/archive value. A confirmation
dialog cannot compensate for missing proof and would imply that a human can
authorize otherwise-unsafe deletion.

All other classes permit no automatic mutation. Protected historical removal
uses its existing explicit specialist workflow. Unknown/corrupt/lineage cases
go to diagnostics rather than to a generic destructive confirmation.

## 23. Exact safe repair predicate

Automatic Local Data Repair is admitted only when every term is TRUE in one
current occurrence and revalidated immediately before mutation:

```text
archive authority is still admitted and authentic
AND AppCzar composition identity still matches
AND active import/graph state is consequential and incomplete
AND active import schema and source inventory are readable and supported
AND exact source registry contains only required current live sources
AND protected non-live/historical source presence is FALSE
AND schema-wide current-source reconstructibility is TRUE
AND graph derivation/coherence evidence contains no independent value
AND overlay, Presence, marker, archive binding, and archive payload boundaries
    are healthy/preserved
AND retired files are absent or separately proven safe by an explicit classifier
AND evidence is stable across the bounded comparison
AND one localDataRepair mutation capability is admitted
```

Any FALSE selects its truthful non-automatic class. Any UNKNOWN or
contradiction selects Diagnostic Review. Evidence from classification cannot be
reused after the mutation-admission revalidation.

## 24. Unsafe/corrupt -> Diagnostic Review rule

Required rule:

```text
cannot inspect enough to prove protected absence and reconstructibility
-> Diagnostic Review
-> no reset
```

Current evaluator follows this for `unknown`/contended observations, but not
for every positive `failed`, `unhealthy`, or unsupported-schema observation;
those currently select virtual Local Data Repair. That is harmless while Local
Data Repair is virtual, but it must be corrected before an executable repair
branch exists. The selected coordinator may present a safe sub-classification,
but mutation admission must remain mechanically unreachable for this evidence.

## 25. Retired-artifact result

`macos_import.db` and `working.db` are retired cleanup/diagnostic files and have
no current central application providers. `MessageDataResetService` deletes
them today. Their mere presence also makes initial scope
`retiredOrUnsupportedMaterial` and selects virtual Local Data Repair.

Their names and retirement status do not prove that a particular existing file
lacks unique historical material. They must not be removed independently by an
automatic Stage One until a bounded, version-aware classifier proves they are
recognized derived residue with no protected value. Otherwise their presence
belongs in Diagnostic Review. No unknown legacy filename may be generalized
into the deletion set.

## 26. Repair-success restart contract

```text
fresh safety proof TRUE
-> acquire one localDataRepair capability
-> enumerated reset completes and strict absence postcondition passes
-> release exact mutation tenure
-> stopAndDrain Local Data Repair
-> real process restart
-> fresh AppCzar assessment
```

Local Data Repair never invokes Onboarding directly and never hands off to
Operating in the same process.

## 27. Repair-failure restart contract

If failure is proved before capability admission and before mutation starts,
the read-only occurrence may present the failure or be retried. Once mutation
is admitted or any close/delete begins, every terminal success or failure must:

```text
invalidate stale publication
-> await active reset and Ball release
-> real process restart
-> fresh AppCzar assessment
```

A partially deleted state is not evaluated with the old occurrence.

## 28. Local Data Repair `stopAndDrain()` design

The controller is occurrence-bound and memory-only. It must:

1. synchronously close action admission;
2. invalidate its publication generation so late progress cannot publish;
3. cancel/ignore pending read-only classification publication;
4. if confirmation is ever shown for a non-automatic diagnostic path, discard
   it on close or process death;
5. await the exact fresh revalidation task;
6. await the exact reset task if mutation was admitted;
7. await capability/Ball release;
8. restart only after drain when mutation may have begun;
9. allow ordinary quit after read-only work drains when no mutation began.

No repair classification, consent, or cursor survives process death.

## 29. Presentation semantics

The surface must report facts and the permitted next action, for example:

```text
Local message data needs repair

The local import contains 1 message, but no complete conversation graph exists.
Current source comparison proves that this derived data can be rebuilt.
MessageLens will preserve your favourites, settings, and attachment archive.
```

For protected/unknown evidence:

```text
Local message data needs attention

This incomplete dataset contains historical imported material, or its source
inventory cannot be proved. MessageLens will not delete it automatically.
```

It must never infer an interrupted operation, call a store disposable before
proof, promise “nothing will be lost” without the full predicate, or claim
repair success before fresh post-restart AppCzar evidence.

## 30. Future qualification fixture design

Use disposable admitted development roots only:

- **Fixture A — rebuildable live-only partial:** create a supported import
  ledger with consequential current live-source facts, no non-live registry,
  and no complete graph. Prove exact reconstructibility; expect Local Data
  Repair, enumerated reset, real restart, then fresh truthful disposition
  (normally Onboarding). Verify overlay/archive/marker fingerprints unchanged.
- **Fixture B — protected non-live partial:** add a canonical historical source
  and source-scoped rows to an incomplete dataset. Expect a non-automatic
  protected presentation or Diagnostic Review. Verify every database/file
  fingerprint unchanged.
- **Fixture C — corrupt/unknown:** make the ledger unreadable or provenance
  inconclusive. Expect Diagnostic Review and zero mutation authority/reset.
- **Fixture D — lineage conflict:** use a live-origin local row no longer present
  or identity-compatible in the current source. Expect no reset.
- **Fixture E — interruption:** inject failure after the first enumerated delete,
  verify drain/restart, and verify the replacement process alone classifies the
  partial result.

No fixture was created or run in this audit.

## 31. Implementation-feasibility verdict

**NO using only the current fact readers and current reset contract.** Current
source lacks:

1. an exact schema-wide current reconstructibility witness;
2. an AppCzar-visible exact protected-source inventory;
3. full graph coherence in the repair-safety predicate;
4. a caller-held `localDataRepair` mutation operation and lower reset entry
   point;
5. a strict post-delete verification failure;
6. the evaluator boundary that sends uninspectable/corrupt safety evidence to
   Diagnostic Review.

The next narrow implementation prompt should add those seams and implement only
`rebuildableLiveOnlyPartial`. It must keep protected, retired-unclassified,
lineage-conflicting, corrupt, and unknown classes non-mutating. A separate
implementation prompt is required.

## 32. BLOCKER findings

These are blockers to any executable Local Data Repair built from current
source, not contradictions in the audit design:

1. **No F21 reconstructibility authority.** Count/high-water/live source ID
   cannot authorize whole-ledger deletion.
2. **Corrupt/unsupported routing is too coarse.** Positive unhealthy evidence
   can select Local Data Repair when provenance is unreadable.
3. **Reset authority shape is wrong for a coordinator.** The general reset
   method self-authorizes and no `localDataRepair` operation exists.
4. **Reset postcondition is observational only.** Surviving files are logged,
   not a terminal failure.
5. **Retired-file safety is unproved.** Current reset deletes named retired
   files without a Stage One content/provenance classifier.

All five are explicitly resolved by the proposed next-stage design: add the
read-only witnesses, fail-closed mapping, one typed caller-held capability,
strict postcondition, and no retired-file deletion absent separate proof.

## 33. SHOULD FIX findings

There are no unresolved SHOULD FIX findings in the proposed audit design.

For the later implementation, rename the existence-style
`nonLiveSourceCount` or replace it with a typed presence plus exact inventory;
calling a `0/1` EXISTS result a count is misleading. This is part of the
required fact-seam correction rather than optional cleanup.

## 34. Whether implementation proceeded

No. Prompt 78 remained audit/design only. No production, generated, test,
pubspec, changelog, native, or project file changed. No build, launch, fixture,
real repair, or real data/archive access occurred.

## 35. Project Conformance audit verdict

`PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)`

The design:

- reuses the source-scoped schema, graph-health semantics, reset file store,
  Archive Mutation Coordinator, Exclusive Authority Ball, and restart boundary;
- adds no second import/rebuild pipeline or authority;
- keeps presentation non-authoritative;
- requires bounded SQL evidence rather than full-row Dart materialization;
- minimizes privacy exposure to typed counts/digests;
- preserves overlay/user intent, Presence, archive configuration/identity, and
  payloads;
- prevents historical-removal authority from leaking into Local Data Repair;
- distinguishes FALSE from UNKNOWN and fails closed;
- keeps exactly one coordinator and one mutation tenure;
- leaves production startup unchanged.

The BLOCKER list above describes missing current implementation seams. The
proposed design does not leave those contradictions unresolved or claim an
implementation is presently safe.

No validation suite was run because no implementation changed. Source tracing,
the existing checkpointed qualification, and read-only Git inspection support
this audit-only verdict.

## 36. Final Git/worktree/index/submodule state

Before writing this untracked response:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `3fd20ffd2d26a0305e92948bf7b1c5cada0c9798`;
- upstream: `3fd20ffd2d26a0305e92948bf7b1c5cada0c9798`;
- ahead/behind: `0/0`;
- tracked worktree: clean;
- index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree: the primary worktree;
- Prompt 78 and Response 78 are untracked, alongside only the known unrelated
  untracked files. Those unrelated files remain untouched.

## 37. Readiness for executable Local Data Repair implementation

**NO for immediate implementation with current seams.** The next narrow
implementation prompt is well-defined, but it must first implement and validate
the reconstructibility/protected-inventory witnesses, typed mutation entry,
strict reset postcondition, and Diagnostic fallback. Destructive behavior must
remain unreachable until those parts pass conformance review.

## 38. Readiness for Local Data Repair human qualification

**NO.** No executable Local Data Repair exists, and no automatic repair class
can yet be mechanically admitted. Human qualification follows the separate
implementation and validation checkpoint.

## 39. Readiness for Diagnostic Review milestone

**YES for a separate audit/design milestone; NO for executable human
qualification.** The present audit identifies the required Diagnostic boundary
for corruption, unsupported provenance, lineage conflict, and unknown repair
safety. Diagnostic Review itself remains virtual and unchanged.

## 40. Readiness for production AppCzar cutover

**NO.** Local Data Repair and Diagnostic Review remain virtual, destructive
repair safety is not implemented, and production correctly remains on legacy
startup.

`ONBOARDING HUMAN LIVE QUALIFICATION CHECKPOINTED: YES`

`LOCAL DATA REPAIR JURISDICTION IS SOURCE-GROUNDED: YES`

`CURRENT RECONSTRUCTIBILITY CAN BE PROVEN BEFORE DESTRUCTIVE RESET: NO`

`PROTECTED NON-LIVE/HISTORICAL DATA BLOCKS AUTOMATIC RESET: YES`

`MESSAGE DATA RESET PRESERVES USER INTENT AND ATTACHMENT ARCHIVE: YES`

`CORRUPT/UNKNOWN REPAIR SAFETY FAILS CLOSED TO DIAGNOSTIC REVIEW: NO`

`EXECUTABLE APPCZAR LOCAL DATA REPAIR IMPLEMENTED: NO`

`PROJECT CONFORMANCE: PASS`

`READY FOR LOCAL DATA REPAIR IMPLEMENTATION: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`
