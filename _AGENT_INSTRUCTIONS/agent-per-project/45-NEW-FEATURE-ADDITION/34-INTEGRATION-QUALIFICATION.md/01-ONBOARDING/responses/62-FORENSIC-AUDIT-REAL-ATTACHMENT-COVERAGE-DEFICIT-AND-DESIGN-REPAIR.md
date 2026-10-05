# MessageLens Feature 34
## Response 62 — Forensic Audit of the Real Attachment-Coverage Deficit and Repair Design

Date: 2026-10-04

## Executive result

The production-shaped probe result was reproduced exactly:

```text
required        18,281
covered          4,440
missing         13,841
unverifiable         0
condition       incomplete
```

All 13,841 uncovered keys lack a durable `archived_attachments` record. None is
a broken record-backed archive object. The current archive's 4,440
record-backed required keys are all represented by safe, regular, exact-size
payload files.

The audit did **not** find a valid basis for narrowing Prompt 59's required
universe. The established service skips a candidate whose source payload is
not locally available and retries it later, but that is an operation outcome,
not a policy statement that the current graph relationship ceases to require
durable coverage. Treating only currently readable source files as required
would lose the exact graph-commit/preservation-failure/source-eviction case
Prompt 59 was designed to reconstruct.

The 13,841 are therefore real durable-coverage deficits under the current
whole-graph contract. They are **not** 13,841 proven missing archive files,
readable source payloads, failed attempts, lost payloads, or copy jobs. The
last-imported retained path returned not-found for 13,835 keys under this audit
process, six retained paths were present but unreadable here, and authoritative
current `chat.db` path evidence was unavailable. Automatic repairability is
therefore only partial/unknown by item and is not complete for the population.

Existing archived payloads remain preservation data even when they fall
outside the current graph-required set. That retention invariant should remain
separate from the Prompt 59 current-dataset coverage proposition; all such
current records were intact in this audit.

No repair was run and no production semantics were changed in this prompt.

## 1. Baseline verification

The fresh external manifest is:

`/private/tmp/messagelens-prompt62-baseline-20261004T155540Z.md`

It records:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- ahead/behind: `0/0`;
- index: empty;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- Prompt 60 tracked binary-diff SHA-256:
  `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`;
- baseline complete-porcelain SHA-256:
  `e47e3fe0699852e75f205b8da331ac9e89b0ee4a39ce5c5d3d423bd6564287d8`;
- development launch environment: unset;
- no MessageLens Development process running.

A separate production `/Applications/MessageLens.app` process, PID `801`, was
observed and left completely untouched.

## 2. Prompt 60 Stage Two integrity

Before the audit, the complete Prompt 60 inventory was captured: 18 modified
tracked files and 14 new source/generated/test files. The manifest records a
SHA-256 for each new Stage Two file.

After every query and after writing only this response:

- the tracked binary-diff SHA-256 remains exactly
  `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`;
- every one of the 14 new Stage Two files retains its baseline SHA-256;
- the same 18 tracked paths remain modified;
- the same 14 Stage Two implementation/test paths remain untracked;
- the index remains empty.

Prompt 60 Stage Two is byte-for-byte intact and remains pending human
qualification.

## 3. Exact reproduced coverage observation

The exact production `ReadOnlyAppCzarAttachmentCoverageProbe` was invoked from
a temporary, read-only Flutter test harness against the admitted development
identity:

```text
data root
  /Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development

archive root
  /Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive

archive instance UUID
  e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5

archive mode / write policy
  custom_external / active_archive
```

Two material samples agreed:

| Evidence | Result |
|---|---:|
| Required | 18,281 |
| Covered | 4,440 |
| Missing | 13,841 |
| Unverifiable | 0 |
| Condition | `incomplete` |
| Archive scope identity | `700d1133585d15caff73465cc48ae9c525f6975b737406010bade7b21e248f7b` |
| Archive generation | 0 |

Ordinary source growth did not change the Prompt 61 count.

## 4. Mutually exclusive uncovered-reason partition

The exact production compatibility key is:

```text
(message GUID, original live attachment ROWID)
```

It is not the packed source-scoped attachment ID by itself. The 13,841 keys
partition as follows:

| Current-evidence reason | Count |
|---|---:|
| 1. No durable `archived_attachments` record | 13,841 |
| 2. Record exists; referenced archive file absent/nonregular | 0 |
| 3. Record exists; file size disagrees | 0 |
| 4. Record exists; path unsafe/unverifiable | 0 |
| 5. Conflicting/duplicate durable record evidence | 0 |
| 6. Current observation scope/generation mismatch | 0 |
| 7. Required graph identity ambiguous | 0 |
| 8. Other/currently unclassifiable record defect | 0 |

The raw eligible relationship count and distinct required-key count are both
18,281. There are no blank message GUIDs and no duplicate compatibility keys.
Three attachment endpoints participate in more than one message relationship;
the message GUID component keeps those relationship keys unambiguous.

## 5. No-record physical-candidate partition

The current archive is content-addressed. A canonical payload path is derived
from the payload SHA-256, which the graph does not retain for these no-record
keys. A filename or byte-size resemblance cannot prove object identity.

The metadata-only physical inspection established:

- all 4,155 managed physical payload paths are already represented by one or
  more durable records;
- the archive contains no `_by_id` payload that can be mapped
  deterministically to one of the 13,841 source attachment ROWIDs;
- there are no symlinks;
- the only extra regular file is Finder's `.DS_Store`, which is excluded by
  archive policy;
- an unrecorded key could still have bytes identical to an already indexed
  content-addressed object, but proving that would require trusted hash
  evidence that is unavailable without reading source payload bytes.

The safe partition is therefore:

| No-record physical result | Count |
|---|---:|
| A. Matching physical candidate proven | 0 |
| B. No possible matching candidate proven | 0 |
| C. Physical correspondence cannot safely be established | 13,841 |

The zero in B is deliberate. The lack of an unindexed file does not rule out
content deduplication with an indexed object. No metadata-only record may be
manufactured from that possibility.

## 6. Current source-payload availability

The audit process could not open the live
`~/Library/Messages/chat.db` read-only: macOS returned
`authorization denied`. That database is the authoritative refreshed-path
source used by the production archiver, so this audit cannot truthfully label
the 13,841 live payloads available or absent from current Messages state.

A secondary metadata-only observation used the exact paths retained in the
graph and import ledger. All 13,841 keys have a matching source-1 import row;
all are import batch 5 from 2026-10-01; none has a blank path; and every import
path equals its graph-retained path. `lstat`/access checks, without opening any
payload, found:

| Last-imported retained-path observation | Count |
|---|---:|
| Regular path present and proven readable | 0 |
| Regular path present but unreadable/unverifiable here | 6 |
| Retained path absent | 13,835 |
| Other entity/metadata error | 0 |

The six present files total 2,212,781 bytes by metadata and each size matches
its retained graph/import size. Because current `chat.db` could have a newer
path, the authoritative classification required by Prompt 62 is:

| Authoritative live-source class | Count |
|---|---:|
| Source payload currently available | 0 proven |
| Source payload currently absent | 0 authoritatively proven |
| Source path present but unreadable/unverifiable | 6 |
| Source evidence unavailable/unknown | 13,835 |

The 13,835 absent retained paths are not evidence of permanent loss. Messages
may have changed a path or may redownload a payload later.

## 7. Temporal and source-range distribution

For the 13,841 no-record relationships:

```text
message source ROWID range      14 .. 154,994
attachment source ROWID range   2 .. 47,131
message date range              2014-02-05 .. 2026-09-30 UTC
```

Year totals are:

| Year | No-record keys |
|---:|---:|
| 2014 | 19 |
| 2015 | 20 |
| 2016 | 105 |
| 2017 | 94 |
| 2018 | 145 |
| 2019 | 268 |
| 2020 | 612 |
| 2021 | 569 |
| 2022 | 920 |
| 2023 | 1,309 |
| 2024 | 2,494 |
| 2025 | 4,105 |
| 2026 | 3,181 |

The 2024–2026 population is 9,780, or 70.66% of the total. This is not a
narrow ancient tail.

Monthly counts, Jan through Dec with zeroes retained, are:

```text
2014   0,   1,   0,   6,   0,   0,   0,   3,   1,   6,   2,   0
2015   1,   0,   2,   0,   0,   0,   1,   6,   3,   7,   0,   0
2016   3,   4,   3,   1,   6,   0,   6,   8,   3,  29,  33,   9
2017   2,  15,  26,   8,  14,  20,   6,   1,   1,   0,   1,   0
2018   2,   0,  23,  16,   3,   1,  15,   5,  26,  21,  24,   9
2019  20,  14,   8,  17,  17,  25,  35,  26,  24,  35,  28,  19
2020  60,  58,  40,  49,  44,  28,  75,  49,  38,  68,  55,  48
2021  43,  16,  42,  47,  61,  49,  71,  54,  46,  45,  56,  39
2022  71,  48,  36,  49,  62,  66,  67, 114, 143,  92,  82,  90
2023  71,  28,  68,  99, 119,  88, 111, 176, 172, 161, 124,  92
2024 181, 182, 118, 231, 313, 262, 250, 208, 183, 228, 177, 161
2025 197, 180, 334, 272, 319, 301, 391, 398, 467, 414, 441, 391
2026 355, 448, 376, 411, 250, 312, 529, 358, 142,   0,   0,   0
```

Every no-record row was rebuilt into import batch 5 on 2026-10-01. That rebuild
timestamp does not reconstruct when the payload was first seen or whether it
was locally available during any earlier archive-enabled run.

The durable settings contain no `attachment_archive_enabled` row, so current
behavior uses the enabled default, but there is no durable activation time.
Archive records carry archive timestamps, not obligation-start timestamps:
4,421 were recorded in September 2026 and 23 in October 2026, spanning
2026-09-08 through 2026-10-03. The real Toshiba adoption occurred on
2026-09-21, but adoption proved parity with the previously authoritative
archive, not completeness against the graph. Neither Git history nor message
date may be promoted into a missing policy boundary.

The last durable bounded-sweep receipt began at
2026-10-01T19:07:28.712520Z and completed at
2026-10-01T19:07:29.781247Z: 100 scanned, 0 newly archived, 100 skipped,
0 failed. It describes one chunk, not the whole 13,841 population, but it is
evidence of non-failing skip outcomes rather than a broad thrown-error burst.
The durable receipt does not retain enough per-item reason detail to partition
those 100 skips further.

## 8. Prompt 59 required-universe audit

Prompt 59 correctly identified the current conventional preservation-required
class:

- live-source message and attachment endpoints;
- nonblank message GUID;
- nonblank filename/path;
- nonblank MIME type;
- compatibility identity `(message GUID, original live attachment ROWID)`.

Its blank-MIME exclusion is consistent with the present explicit policy for
opaque Apple/extension payloads. Production and canonical documentation also
establish the following operation behavior:

- archiving acts when the file exists at the source path;
- `_resolveArchivableSourcePath` tries the retained path and then a refreshed
  live `chat.db` path, returning `null` when neither exists;
- `_archiveRows` records that case as `skipped`, not failed;
- the bounded sweep retries later specifically so files that appear later can
  be ingested;
- missing attachment bytes remain a visible availability state rather than
  being suppressed.

Those outcomes do not narrow the durable obligation. `skipped` describes what
one worker could do with the source bytes available at that moment; the
periodic retry exists because the uncovered graph key remains outstanding.
Prompt 59 deliberately stopped using operation counters as semantic authority.
Changing the required set to only files readable now would allow this sequence
to disappear from fresh evidence:

```text
graph/import commits a required relationship
-> preservation fails
-> Apple evicts the source payload
-> fresh AppCzar sees no currently readable source
```

That would defeat the reconstructibility requirement Prompt 59 introduced.

No narrower attachment class or date boundary exists in source. The current
setting is enabled by default; no durable historical activation timestamp is
recorded; adoption proved archive-to-archive parity rather than declaring all
other graph attachments exempt. A message date, Git commit date, import batch,
or adoption date cannot be invented as a policy cutoff.

Therefore every member of the current conventional set remains
preservation-required under the current contract. A missing source changes the
**repair class**, not the truth that durable coverage is absent. The whole-graph
required universe in Prompt 59 is valid as written.

One adjacent retention concern remains separate: every existing archived
payload is preservation data even if ingestion is disabled or its relationship
later leaves the graph. Prompt 59's current-dataset proposition is not a full
archive-retention integrity census. That should be kept as a separate factual
invariant rather than used to narrow the required graph universe. In the real
audit, all 4,444 existing records and their 4,155 distinct payloads were intact.

## 9. Current archive-record and graph statistics

| Statistic | Count |
|---|---:|
| Total graph attachment relationships | 40,337 |
| Live-source graph relationships | 40,337 |
| Blank/missing filename/path | 4,873 |
| Nonblank filename but blank/NULL MIME | 17,183 |
| Conventional live preservation-required keys | 18,281 |
| Distinct attachment endpoints among those keys | 18,278 |
| Durable `archived_attachments` records | 4,444 |
| Current conventional keys with records | 4,440 |
| Current conventional keys without records | 13,841 |
| Records outside current conventional set | 4 |
| True records with no current graph relationship | 0 |
| Duplicate compatibility keys | 0 |
| Distinct record-backed payload paths | 4,155 |
| Record-backed payload paths absent/nonregular | 0 |

The four records outside the conventional set still have current graph
relationships; they are outside only because MIME is blank. They remain
retention-required facts.

The 4,444 records reference 4,155 distinct managed payload files totaling
3,710,279,017 bytes. There are 256 shared paths covering 545 records, with at
most six records per path. No shared path has inconsistent size/hash evidence.
All 4,444 records have structurally valid hashes. The physical archive has one
additional 34,820-byte `.DS_Store`; it is Finder metadata, not a payload.

## 10. Exact meaning of 13,841

The number means exactly:

> 13,841 distinct conventional live graph relationship keys have no durable
> `archived_attachments` record under Prompt 59's whole-current-graph query.

It does not establish:

- 13,841 missing archive files;
- 13,841 readable source payloads;
- 13,841 failed archive attempts;
- 13,841 payloads lost;
- 13,841 required copies;
- 13,841 safe metadata-only reconciliations.

All record-backed required objects are intact, but durable coverage is absent
for 13,841 required keys. That is a real coverage deficit under the current
contract. Source evidence determines how each key can be repaired; it does not
erase the uncovered durable fact.

## 11. Automatic repair classes

These classes can be automatic when fresh item-level evidence proves their
preconditions:

### A. Current source readable, exact key has no valid record

Use the current live Messages attachment row to prove the exact compatibility
identity and source path, then use the established payload writer:

```text
read/verify current source identity
-> stream/hash source
-> verified temporary copy
-> atomic no-overwrite install
-> durable object record after payload
```

### B. Durable record exists, payload is absent/wrong, current source readable

Re-preserve the exact payload only after a reviewed primitive can reconcile a
record-backed defect. The current ordinary ingestion primitive returns
`alreadyArchived` as soon as a record exists, so it is not sufficient as-is.

### C. Trusted physical payload, record absent

Metadata reconciliation is automatic only when a current source hash or a
trusted manifest proves exact identity and the file's size/hash. No current
real key met that standard in this audit.

### D. Retained record outside the current graph

Verify and retain it. Never delete it merely because it is not in the current
automatic candidate set.

## 12. Manual or unverifiable classes

Automatic repair must stop at evidence that does not prove identity:

- source payload absent at the authoritative current path;
- current source database/path evidence inaccessible or unstable;
- unsafe/symlink/nonregular archive path;
- conflicting record size/hash/path evidence;
- source payload and record-backed object both unavailable;
- historical donor or old archive needed to recover bytes;
- a physical content-addressed object that merely resembles a missing key.

Possible human actions are to restore source access, allow Messages to
redownload the item, reconnect an exact historical source/donor volume, or use
the existing verified historical recovery workflow. This task does not design
an `ignore missing` or exclusion control.

## 13. Are uncovered requirements already physically preserved?

None is proven. There are zero unindexed managed payload files and zero legacy
`_by_id` candidates. Deduplication against an already indexed content object
remains possible for some keys, but cannot be associated with a no-record key
without trusted content identity. Therefore all 13,841 remain metadata-only
correspondence UNKNOWN, not proven physically absent and not covered.

## 14. Are uncovered requirements unavailable from current source?

Not authoritatively determinable in this process. The last-imported paths show
13,835 absent and six present-but-unreadable here, but current `chat.db` access
was denied. The production refreshed-path lookup may observe a different path.
No permanent-loss claim is justified.

## 15. Correct Attachment Archive Repair selection contract

An executable repair must not be selected from
`AppCzarVirtualCoordinator.attachmentArchiveRepair` alone. That same enum is
currently used both for an unavailable archive root and for incomplete
coverage.

The exact selection predicate should require one coherent current assessment:

```text
virtual coordinator == attachmentArchiveRepair
AND diagnosis kind == attachmentArchiveCoverageIncomplete
AND attachmentCoverageComplete fact == FALSE
AND attachmentArchiveAvailable fact == TRUE
AND archive scope identity, generation, and resolved path all match
AND no newer assessment generation has replaced this one
```

Coverage UNKNOWN remains Diagnostic Review. Archive-root
unavailability retains its separate non-executable diagnosis unless separately
designed.

## 16. Proposed bounded coordinator jurisdiction

One top-level Attachment Archive Repair coordinator should own exactly one
admitted occurrence:

1. re-read coherent current evidence rather than using the startup count;
2. page and partition exact actionable keys;
3. automatically preserve only current-source identities that are proven and
   writable through the existing archive service boundary;
4. verify every committed object fact;
5. publish factual counts for nonautomatic classes;
6. drain mutation work;
7. restart the process only after committed archive changes settle, or after
   an explicit human reassessment request following changed external evidence.

If the partition contains only source-absent, manual, or unverifiable items,
the coordinator remains on a bounded human-action surface. It must not restart
automatically into the same conclusive FALSE assessment.

It must not evaluate source/local message currentness, invoke Data Update,
admit Operating, or hand off to another coordinator in-process.

## 17. Internal typed sub-operations

One coordinator should own typed worker steps rather than creating multiple
top-level coordinators:

```text
recomputeCoverage
classifyUncovered
preserveAvailableSourcePayloads
verifyCoverage
reportManualRequirements
```

Two implementation seams must be established first:

1. A shared typed, paginated read-only evidence reader must expose the exact
   Prompt 59 universe and item classification once for both AppCzar and repair.
   The present startup probe exposes only aggregate/private evidence; copying
   its SQL into a coordinator would create drift.
2. A narrow admitted live-source preservation primitive must accept the outer
   callback-local mutation capability and writable-root lease. The existing
   public methods acquire their own tenure, while the private single-item
   primitive skips immediately if any record exists. Repair must not nest a
   Ball or bypass the existing writer.

These are the first implementation steps and hard stop gates, not permission
to introduce a generic `execute(coordinatorEnum)` dispatcher.

## 18. Progress and final-success/restart semantics

Factual progress may say:

```text
Checking attachment coverage…
N source payloads are currently preservable but lack valid coverage

Already covered                       N
Available from Messages               N
Source currently absent               N
Source evidence unavailable           N
Record-backed payload needs recovery  N

Preserving                            X / Y
Verifying current evidence…
```

It must not say that all attachments are safe, that recovery is complete, or
that an absent-source candidate is lost.

The worker does not author semantic success:

```text
one or more bounded archive mutations settle
-> exact occurrence drains
-> real process restart
-> fresh AppCzar reconstructs current coverage
```

Only fresh coverage TRUE may allow evaluation to continue. FALSE
may present remaining manual requirements. UNKNOWN returns to fresh diagnostic
assessment. There is no in-process coordinator chaining.

When no automatic mutation is possible, the coordinator does not enter a
restart loop. It stays on the factual human-action surface. A process restart
then occurs only because the human explicitly requests reassessment after
changing access/source/donor evidence.

## 19. Mutation authority and concurrency

The mutation path should be:

```text
Attachment Archive Repair occurrence
-> ArchiveMutationOperation.attachmentReconciliation
-> one ArchiveMutationCoordinator.runWithCapability callback
-> one current AttachmentArchiveWritableRootLease
-> existing verified payload-preservation writer
-> payload install before object-record commit
```

The capability and lease remain callback-local. Every protected boundary
revalidates the exact operation and lease. No direct coordinator filesystem
write, persistent capability retention, nested mutation tenure, or
metadata-first commit is permitted.

## 20. Batching and performance

Recommended bounds:

- compatibility-key keyset pages of 50–100;
- bounded overlay lookups and filesystem metadata checks;
- one source payload streamed at a time through the existing writer;
- no payload accumulation or whole-source hash table in memory;
- progress publication throttled by item count/time;
- no unbounded archive walk and no full-payload pre-scan;
- one current atomic install allowed to drain before cancellation completes.

The real population is large enough that `readAllAvailableLive()` and a
whole-list UI model are not suitable repair seams.

## 21. Interruption and natural resume

Do not add a Journey cursor or a durable semantic success flag. On interruption:

1. stop admitting new items;
2. await the exact in-flight writer through metadata commit or failure;
3. release the lease and Ball;
4. permit the caller to exit, without scheduling an automatic restart merely
   because unresolved manual items remain;
5. on the next explicit launch/reassessment, recompute from current graph,
   source, records, and payload metadata.

Completed object records are durable facts. Unfinished items remain eligible
on the next fresh pass. That is sufficient natural resumability.

## 22. Human intervention requirements

For nonautomatic classes the UI must report aggregate, privacy-safe evidence
and the narrow next action:

- source inspection unavailable: restore access and recheck in a fresh
  process;
- payload not local: allow Messages to download it, then let the ordinary
  sweep/recheck run;
- historical bytes required: reconnect or select a trusted historical donor
  through the existing verified recovery workflow;
- unsafe/conflicting evidence: stop and present diagnostic detail without
  mutating either copy.

Any future choice to exclude an unrecoverable payload from policy would be a
new explicit user-authored fact and needs separate design review.

## 23. FDA-toggle anomaly

The development FDA entry again changed from human-visible ON before Prompt 61
launch to OFF after launch. Source Access Repair handled the resulting failed
read correctly. In Prompt 62 the audit process likewise could not read live
`chat.db` even after an escalated read-only attempt.

This remains a separate environment/signing/tooling issue. It is relevant only
to why source availability is UNKNOWN here; it does not explain or alter the
archive-record counts. It was not investigated further.

## 24. Privacy and read-only confirmation

Real-data access was limited to:

- query-only/immutable SELECTs over the development graph, import, and overlay
  stores;
- the production-shaped read-only coverage probe;
- archive `stat`/`lstat`, type, path-shape, and exact-size checks;
- privacy-safe aggregate dates, ROWID ranges, counts, and byte totals;
- `lstat`/access checks on retained source paths.

No message text, contact name, or private filename was emitted. No payload was
opened, copied, moved, deleted, renamed, hashed, or modified. No database,
archive setting, archive record, real archive object, or FDA setting was
written. The production MessageLens process was untouched and was not
interacted with beyond observing process metadata.

## 25. Audit-only code/test changes

No repository production or test code changed. One temporary harness exists
outside the worktree:

`/private/tmp/messagelens_prompt62_exact_probe.dart`

It calls the exact production probe and contains no mutation path. The only
repository write made by Prompt 62 is this response document, as required.

## 26. Validation

- Exact production-shaped coverage probe: **1/1 passed**.
- Two complete material samples agreed on 18,281 / 4,440 / 13,841 / 0.
- Independent query-only aggregate reproduction matched the production probe.
- All 4,155 distinct record-backed paths: regular, present, exact recorded
  size; no symlinks.
- Prompt 60 tracked diff hash: unchanged.
- Prompt 60 14 new-file hashes: unchanged.
- Index: empty.
- Shared submodule: clean at required commit.
- No analyzer, generator, build, or product test suite was run because no
  production/test code changed.

## 27. BLOCKER findings

No policy/required-universe blocker was found. The current whole-graph
conventional universe remains the governing contract.

The following are hard implementation prerequisites and stop gates, not
unresolved product-policy questions:

1. **Repair needs a shared key-level evidence reader.** The current probe is
   aggregate/private; duplicated repair SQL would create two definitions of
   the fact.
2. **The ordinary writer is not yet the exact repair primitive.** Public entry
   points self-acquire tenure, and the private item path treats any existing
   record as already archived even when its payload is defective.
3. **The virtual enum is not a sufficient execution predicate.** It also
   denotes archive-root unavailability.
4. **The audit could not pre-count the automatic subset.** Terminal-side live
   `chat.db` access was denied. The coordinator must obtain a fresh,
   source-authoritative item partition at execution time and fail closed to
   diagnostic/manual evidence where it cannot.

Implementation must stop rather than improvise if the exact existing mutation
operation cannot describe the required writer, if capability/lease proof would
escape the admitted callback, or if the shared reader cannot preserve one
Prompt 59 universe for both startup and repair.

## 28. SHOULD FIX findings

1. Preserve separate diagnostic counts for record-backed integrity failures,
   source-available repair items, source-absent/manual recovery items, and
   UNKNOWN source evidence.
2. Make the exact conventional-candidate/key definition one shared typed
   query boundary used by startup, sweep, and repair.
3. Keep retained archive-record integrity independent of the ingestion-enabled
   preference.
4. Consider a distinct read-only retained-object integrity fact for durable
   records outside the current graph-required universe; do not overload or
   narrow Prompt 59 coverage to achieve it.
5. Resolve the separate development FDA/signature continuity anomaly before
   relying on terminal-side live-source forensics.

## 29. Exact Git/worktree/index/submodule state

At final audit handoff:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- ahead/behind: `0/0`;
- index: empty;
- tracked Prompt 60 files: the same 18 modified paths;
- tracked diff SHA-256:
  `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`;
- Stage Two new source/generated/test files: the same 14, all with unchanged
  baseline hashes;
- this Response 62: one new untracked documentation file;
- physical untracked files: 63 total, comprising the unchanged baseline 62
  plus this response;
- all previously known unrelated untracked files: untouched;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- final complete porcelain: exactly the baseline manifest inventory plus this
  Response 62 path; verified after the response write;
- final complete-porcelain inventory SHA-256:
  `0ba2c1a8ea0a84ac689085fd3d9e1e6b2b25dc2e038610db7290470627a1d16d`;
- both `git diff --check` and `git diff --cached --check`:
  pass.

Nothing was staged, committed, pushed, merged, or rebased.

## 30. Readiness to implement Attachment Archive Repair

Ready for a separately authorized implementation prompt. The required universe
is valid, the executable selection predicate is exact, the single-coordinator
jurisdiction is bounded, the internal sub-operations and authority path are
defined, and nonautomatic evidence fails closed. Implementation must begin by
establishing the shared key-level reader and callback-local writer seam, then
repair only the source/identity classes proven at runtime. Prompt 62 itself
made no such implementation.

## 31. Readiness to rerun Prompt 61

Not ready. Prompt 61 should remain pending unchanged. After bounded repair and
any required human recovery, only a fresh AppCzar process observing coverage
TRUE may admit Operating and allow the Stage Two live-currentness qualification
to be rerun.

PROMPT 59 REQUIRED ATTACHMENT UNIVERSE VALID: YES

REAL ATTACHMENT COVERAGE DEFICIT CONFIRMED: YES

DEFICIT AUTOMATICALLY REPAIRABLE IN WHOLE: NO

ATTACHMENT ARCHIVE REPAIR DESIGN READY: YES

OPERATING STAGE TWO TREE REMAINS INTACT: YES

READY TO IMPLEMENT ATTACHMENT ARCHIVE REPAIR: YES
