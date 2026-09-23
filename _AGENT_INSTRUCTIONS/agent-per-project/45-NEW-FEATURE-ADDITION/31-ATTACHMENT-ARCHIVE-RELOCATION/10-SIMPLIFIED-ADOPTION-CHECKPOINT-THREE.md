# Simplified Archive Adoption — Checkpoint Three

## Status and scope

Checkpoint Three implements the fresh approval-time revalidation specified by
`08-SIMPLIFIED-ARCHIVE-ADOPTION-DESIGN.md`. It closes the supported race
between a full `candidateComplete` comparison and a future explicit approval
without retaining a coordinator lock across human review and without hashing
payload contents a second time.

Checkpoint Two was reviewed and committed before this work began:

```text
3aba663de21e9aa4d7a5003ef7f9f17200ded0c0
feat(attachments): add archive candidate verifier
```

This checkpoint is application/domain safety infrastructure only. It does not
add Settings actions or UI, create a bookmark, persist `customExternal`, issue
a writable-root lease, create an adoption transaction, change the active
archive, invoke the retired relocation engine, or inspect any real archive.

## Revalidation architecture

`AttachmentArchiveApprovalRevalidator` accepts an
`AttachmentArchiveCandidateComplete`, never raw source or candidate paths. It
performs these checks in order:

1. acquire `ArchiveMutationOperation.attachmentArchiveAdoption` from the
   existing `ArchiveMutationCoordinator`;
2. validate the complete result's internally consistent outcome, coverage
   totals, SHA-256 evidence shape, configuration, generation, and canonical
   identity bindings;
3. resolve the current active archive through the injected application-owned
   location reader and compare configuration and generation;
4. resolve current bounded candidate access through an injected reader that is
   itself keyed by the exact complete result;
5. require both original and current positive candidate writability evidence;
6. recompute deterministic source and candidate structural snapshots through
   `AttachmentArchiveApprovalSnapshotReader`;
7. compare canonical identities, fingerprints, exact totals, grouped metadata
   references, preservation counts, debris counts, and allowed-extra totals;
8. return typed approval eligibility and release coordination.

The filesystem verifier implements both the expensive Checkpoint Two verifier
and the structural snapshot reader so the classification and deterministic
fingerprint contracts cannot drift. Source and candidate structural evidence
are recomputed independently. Source differences are compared first, giving a
deterministic conservative `sourceChanged` result when both roots differ.

## Coordinator semantics

The public `revalidate` method acquires the coordinator only when the approval
check begins. The scope is not held while a person reviews the earlier full
verification result. It excludes every independently owned MessageLens archive
mutation operation, including ordinary attachment reconciliation, for the
whole fresh traversal and comparison. Checkpoint Three releases the scope as
soon as it returns or fails because no activation follows yet.

`revalidateWithinApprovalScope` requires the exact opaque
`attachmentArchiveAdoption` capability. This is the Checkpoint Four seam:

```text
one coordinator-held attachmentArchiveAdoption operation
  -> fresh revalidation
  -> adoption transaction
  -> configuration switch
  -> post-switch candidate check
  -> success or rollback
```

Checkpoint Four can therefore retain one uninterrupted coordinator owner and
scope from the fresh source fingerprint through the future configuration
switch. A wrong-operation capability is rejected. The capability is
zone-bound, scope-bound, operation-bound, and invalid after release under the
existing coordinator contract.

## Input and identity binding

The revalidation APIs require the sealed `AttachmentArchiveCandidateComplete`
subtype. Behind, invalid, unavailable, and failed result variants cannot enter
the typed boundary. The complete evidence binds:

- the exact source configuration;
- source location generation;
- canonical source and candidate roots;
- source and candidate structural snapshot fingerprints;
- required, verified, metadata-reference, preservation, debris, and extra
  counts/bytes; and
- the strong Checkpoint Two content-coverage digest.

Approval-ready evidence retains the original complete-result object identity
and repeats the freshly proven configuration, generation, canonical roots,
fingerprints, content digest, and UTC revalidation time. No API accepts raw
paths to create approval eligibility.

## Source checks

The fresh source traversal repeats the Checkpoint Two deterministic grouped
metadata and complete filesystem structural model without reading file
contents. It detects:

- an added or removed preservation payload;
- size, type, modification-time, or change-time differences;
- grouped metadata path, size, hash-evidence, or reference-count differences;
- a newly introduced symbolic link, special entry, ambiguous path, unknown
  preservation shape, or metadata/filesystem mismatch;
- active configuration, generation, or canonical-root changes; and
- loss of positive source availability/readability.

These cases return `sourceChanged` or `sourceUnavailable`; no configuration or
archive authority is changed.

## Candidate checks

The candidate is re-resolved from bounded application-owned selection state,
not from a display path. Revalidation requires the same canonical root,
positive availability/readability, and physical writability both during the
full check and now. It detects:

- an added valid preservation extra;
- a removed required payload;
- size, type, modification-time, or change-time differences;
- a new symbolic link, special entry, ambiguous path, or unknown extra;
- canonical-root replacement;
- loss of availability; and
- loss of writability.

These cases return `candidateChanged`, `candidateUnavailable`, or
`candidateNoLongerWritable`. A changed candidate is never partially accepted.

## Typed result vocabulary

`AttachmentArchiveApprovalRevalidationOutcome` contains:

- `approvalReady`;
- `sourceChanged`;
- `candidateChanged`;
- `sourceUnavailable`;
- `candidateUnavailable`;
- `candidateNoLongerWritable`;
- `verificationEvidenceInvalid`; and
- `failed`.

Changed results mean that full Checkpoint Two verification must run again. No
outcome bypasses that requirement.

## Approval-ready capability decision

Checkpoint Three deliberately returns process-local
`AttachmentArchiveApprovalReadyEvidence`, not an opaque mutation capability.
It is immutable, has no serialization or persistence API, retains the exact
complete-result object, and cannot call any location controller or storage
boundary. It is comparison evidence only and grants no archive-location
mutation authority.

This is the smaller safe design authorized by the checkpoint. Checkpoint Four
must introduce the actual unforgeable verified-adoption permit inside the
continuously held coordinator operation, after revalidation and bookmark
resolution have succeeded.

## Four-second rehearsal race regression

The focused regression permanently models the observed development incident:

1. disposable source and candidate archives begin identical;
2. full Checkpoint Two verification returns `candidateComplete`;
3. during the simulated human-review interval, ordinary attachment ingestion
   acquires `attachmentReconciliation`, adds a valid source payload, and adds
   matching grouped metadata;
4. approval revalidation returns `sourceChanged` and the location object is
   unchanged;
5. the disposable candidate is updated with that payload;
6. a new full verification returns a new `candidateComplete`; and
7. immediate approval revalidation returns `approvalReady`.

The test also proves that both coordinator operations release normally and
that no activation/configuration mutation occurs.

## No-payload-rehash proof

The full verifier exposes an optional payload-hash-start instrumentation hook.
The focused test proves that full verification invokes it and fresh approval
revalidation invokes it zero times. Architecture tests additionally isolate
the structural snapshot and structural entry-inspection regions and forbid
calls to `hashFile`, `File.open`, or `readAsBytes` there.

Revalidation may enumerate all entries, read filesystem metadata, read grouped
overlay metadata, and hash compact structural evidence fields. It never opens
payload files for content reads. This remains safe for supported MessageLens
mutation because archive payloads are immutable, installed atomically without
overwrite, and all supported mutations participate in the coordinator.

## External mutation threat model

The coordinator excludes MessageLens-owned archive mutation; it cannot exclude
an arbitrary external process. Complete path/type/size traversal plus file and
directory modification/change-time evidence detects ordinary replacement.
Checkpoint Four must repeat the candidate fingerprint through the newly
resolved normal location after switching and before success.

A deliberately hostile process that replaces bytes while preserving every
observable path, type, size, modification-time, and change-time field is
outside the approved concurrency model. Supporting that stronger adversary
would require full content hashing at approval, contrary to this design; no
weaker claim is made here.

## Files changed

Production:

- `lib/essentials/archive_environment/domain/archive_mutation_operation.dart`;
- `lib/features/attachments/application/attachment_archive_approval_revalidator.dart`;
- `lib/features/attachments/application/attachment_archive_approval_snapshot_reader.dart`;
- `lib/features/attachments/domain/entities/attachment_archive_approval_revalidation.dart`;
- `lib/features/attachments/infrastructure/repositories/filesystem_attachment_archive_candidate_verifier.dart`.

Tests:

- `test/features/attachments/application/attachment_archive_approval_revalidator_test.dart`;
- `test/architecture/attachment_archive_approval_revalidation_architecture_test.dart`.

Documentation and release metadata:

- this record;
- `08-SIMPLIFIED-ARCHIVE-ADOPTION-DESIGN.md`;
- `CHANGELOG.md`;
- `pubspec.yaml`.

No dependency, generated-code, schema, migration, native, or Settings change
is required.

## Tests

Focused application coverage includes unchanged readiness; the exact rehearsal
race; added, removed, same-size-replaced, metadata-changed, reconfigured,
regenerated, recanonicalized, and unavailable source cases; added, removed,
same-size-replaced, symlinked, recanonicalized, unavailable, and read-only
candidate cases; zero content-hash reads; coordinator exclusion/release;
continuous Checkpoint Four scope; wrong-operation denial; and reconstruction
requiring a new structural check.

Architecture coverage proves no activation/persistence authority, relocation
runtime, parked-operation discovery, raw-path approval API, durable ready
evidence, payload hashing in structural traversal, Settings/public route, or
coordinator bypass.

Final validation results:

- 24 focused approval-revalidation tests passed;
- the combined revalidation and Checkpoint Two verifier run passed 49 tests;
- all 310 attachment feature/regression tests passed;
- the required architecture matrix, including the candidate-verifier and
  retired-mover-unreachable checks, passed all 405 tests;
- the full repository suite passed 2,477 tests with the existing one
  qualification-harness skip;
- `flutter analyze` reported no issues; and
- `git diff --check` passed.

## Deviations from the design

There is one intentionally deferred design element: this checkpoint returns
typed approval-ready comparison evidence instead of issuing a verified-adoption
permit. The approved design explicitly permits that smaller boundary when a
capability would complicate this checkpoint. The permit belongs to Checkpoint
Four, where it can bind the adoption transaction and resolved bookmark while
the coordinator remains continuously held.

No mandatory stop-and-report gate was encountered.

## Exact Checkpoint Four starting point

Checkpoint Four should begin with an internal adoption orchestrator that:

1. accepts an existing `AttachmentArchiveCandidateComplete` from the future
   ephemeral workflow;
2. acquires `attachmentArchiveAdoption` once;
3. calls `revalidateWithinApprovalScope` with that exact capability;
4. stops without side effects unless the outcome is `approvalReady`;
5. creates/resolves the candidate bookmark and proves exact canonical writable
   identity;
6. prepares the small adoption transaction and mints an unforgeable permit;
7. performs the permit-protected configuration switch;
8. resolves the normal location, rechecks the candidate fingerprint and lease,
   then completes or rolls back the transaction; and
9. releases the coordinator only after success or rollback is settled.

It must not reacquire between revalidation and switching, reuse this typed
ready evidence as mutation authority, introduce the Settings UI yet, or use
the retired relocation journal/runtime.
