# Simplified Archive Adoption — Checkpoint Four

## Status and scope

Checkpoint Four implements the narrow verified-adoption configuration
transaction from `08-SIMPLIFIED-ARCHIVE-ADOPTION-DESIGN.md`. It begins with a
process-local `AttachmentArchiveCandidateComplete`, repeats the Checkpoint
Three approval check, bookmarks the candidate, switches the active
configuration, proves the normal location and writable-root authorities, and
either completes or restores the exact previous configuration.

Checkpoint Three was reviewed and committed before this work began:

```text
af795386ae3ff94166977e0f35459347db9b9768
feat(attachments): add archive adoption approval revalidation
```

This checkpoint remains internal. It does not add a Settings action or UI,
copy, move, synchronize, or delete payloads, use the parked relocation
operation, or depend on the legacy relocation runtime. All development used
disposable roots and in-memory/test databases.

## Uninterrupted coordinator scope

`AttachmentArchiveAdoptionService.adopt` acquires
`ArchiveMutationOperation.attachmentArchiveAdoption` once and calls
`revalidateWithinApprovalScope` with that same opaque capability. The scope is
retained through bookmark admission, both durable transaction states,
configuration switching, normal location resolution, post-switch structural
comparison, writable-root lease validation, transaction retirement, and any
required rollback.

There is no release/reacquire boundary after `approvalReady`. A regression
test pauses at bookmark creation immediately after fresh revalidation and
proves that an independently owned supported attachment-reconciliation
operation is denied until adoption releases the scope.

## Verified-adoption authority

`AttachmentArchiveAdoptionConfigurationAuthority` is a sealed application
type with a private constructor. Its two private implementations are issued
only by `AttachmentArchiveAdoptionAuthorityIssuer`:

- the verified authority permits the one exact intended activation and the
  one exact previous-configuration rollback;
- the recovery authority permits rollback only.

Issuance rereads the exact durable transaction. Verified issuance compares
the transaction ID, previous and intended configurations, source and candidate
canonical roots, source generation, verification content digest, both fresh
structural fingerprints, and verified count/byte totals with the fresh ready
evidence. It additionally requires two non-constructible process-local proofs:
one binds the exact ready-evidence object to the active coordinator capability,
and one binds that proof plus the intended configuration to the service's
successful bookmark admission. Every use also revalidates the exact zone-,
scope-, and operation-bound coordinator capability. The authority expires when
that scope ends and is never serialized.

Raw paths, bookmark bytes, arbitrary configurations, a candidate-complete
result alone, or stale approval-ready evidence cannot manufacture this
authority. The ordinary location-controller persistence method continues to
reject `customExternal(activeArchive)`.

## Bookmark admission

Bookmark work begins only after fresh approval revalidation succeeds. Adoption
uses the bookmark-only native interface, not the legacy capacity interface:

1. create the normal Foundation bookmark for the verified candidate root;
2. perform a bounded canonical/root-readability inspection of the returned
   resolved root;
3. resolve the bookmark through the normal native boundary;
4. require Foundation `available`, not `readOnly` or another unavailable
   status; and
5. require the resolved canonical root to equal the freshly verified
   candidate identity.

`lastKnownPath` is display metadata only. Adoption creates no directory and
performs no write probe.

## Transaction format and location

The single pending record is:

```text
<admitted MessageLens root>/.messagelens-attachment-adoption-transaction.json
```

It is directly beneath the admitted primary root and therefore outside
`attachment_archive`. The repository uses an exclusive transaction-specific
temporary file, flushes serialized JSON, and atomically renames it over the
record. Replacement and clearing require the exact transaction identity.

The version-one record contains only:

- format version and UUID transaction ID;
- `prepared` or `configurationPersisted` state;
- exact previous and intended configurations;
- source and candidate canonical identities;
- source location generation;
- verification content digest;
- source and candidate structural fingerprints;
- verified file and byte totals; and
- UTC creation/update timestamps.

It has no payload manifest, copy receipts, file progress, staging path,
capacity, pause/resume state, or relocation state.

## Durable ordering and location integration

The successful ordering is:

1. acquire adoption coordination;
2. freshly revalidate the exact complete result;
3. create and resolve the candidate bookmark;
4. construct `customExternal(activeArchive)` inside adoption;
5. durably write `prepared`;
6. reread the record and issue verified adoption authority;
7. persist the intended configuration through the authority-protected
   location controller/notifier boundary;
8. durably replace the record with `configurationPersisted`;
9. resolve `AttachmentArchiveLocation` normally;
10. require the intended configuration, `customAvailable`, the candidate
    canonical root, and exactly the next location generation;
11. recompute the candidate-only structural fingerprint and exact verified
    count/byte totals;
12. obtain the normal Phase Four writable-root admission;
13. require matching root, generation, mode, and configuration identity;
14. require destructive reset to remain denied;
15. validate the lease for adoption at `operationStart`;
16. clear the exact pending transaction; and
17. report `adopted` and release coordination.

No special adoption write path exists. Successful adoption proves that normal
future attachment ingestion/recovery sees the candidate through the already
established Phase Four authority.

## Post-switch structural check

After normal location resolution, the verifier performs a candidate-only
structural traversal. It compares the canonical identity, structural
fingerprint, verified file count, and verified bytes with the fresh approval
evidence. It does not reread grouped metadata, traverse the previous source,
or rehash payload contents. A candidate change enters rollback and can never
return success.

## Rollback

Every failure after `prepared` becomes durable invokes rollback while the same
coordinator scope remains active. Rollback rereads the durable record and then:

- restores the exact previous configuration when current equals intended;
- avoids a redundant persistence write when current already equals previous;
- fails closed and retains the transaction when current matches neither;
- resolves the previous default root or previous bookmark normally;
- performs bounded canonical/readability inspection against the recorded
  source identity; and
- clears the transaction only after the previous normal location authority is
  proven.

If the previous source is temporarily unavailable, the intended configuration
remains explicit, the transaction remains pending, and the typed result is
`rollbackPendingPreviousUnavailable`. There is no silent fallback and no false
success. A later recovery attempt can complete the deterministic rollback once
the previous root is available.

## Startup recovery

`attachmentArchiveAdoptionRecoveryProvider` is invoked during persistent
startup. It reads only the one small transaction record, the current location
configuration/state, one necessary bookmark resolution, and bounded root
identity/readability evidence. It never inventories or hashes either archive,
reads grouped attachment metadata, or consults the legacy relocation journal.

For `prepared`, current previous configuration is safely abandoned after the
previous root is proven; current intended is conservatively rolled back. For
`configurationPersisted`, current intended is rolled back. An unrelated
configuration returns `configurationConflict`; an unavailable previous source
or any unproven rollback retains pending recovery. Startup never infers that
payload movement occurred because adoption performs none.

## Completed receipt decision

No completed-adoption receipt is persisted. After success the active location
configuration already provides the new display path and volume. Checkpoint
Five can keep the process-local prior-source presentation state while the
workflow is visible; adding durable informational state is unnecessary for
configuration correctness and would expand persistence without granting any
safe authority.

## Typed outcomes

The application result distinguishes:

- `adopted`;
- `noPendingRecovery`;
- `preparedTransactionAbandoned`;
- `sourceChangedCheckAgain`;
- `candidateChangedCheckAgain`;
- `sourceUnavailable`;
- `candidateUnavailable`;
- `candidateNoLongerWritable`;
- `rollbackRestoredPrevious`;
- `rollbackPendingPreviousUnavailable`;
- `configurationConflict`; and
- `failed`.

The result exposes only whether recovery remains required; it does not invite
UI-owned transaction or rollback logic.

## Failure injection and races

Disposable integration coverage injects the required A–L failures: before and
after `prepared`, before and after configuration persistence, after the
`configurationPersisted` write, during new-location resolution, after an
external post-switch candidate change, before admission, at lease validation,
during rollback persistence, with the previous source unavailable, and with
an unrelated configuration during recovery.

Every case proves that source and candidate directories remain present and
payload content is unchanged except for the test's explicit simulated external
candidate mutation. Configuration ends adopted, restored, or in an explicit
pending recovery state; false success is impossible.

Checkpoint Three retains source/candidate changes immediately before fresh
revalidation and the exact four-second rehearsal regression. Checkpoint Four
adds post-persistence candidate change and continuous-coordinator exclusion.

## Legacy isolation and architecture tripwires

Architecture tests prove:

- adoption code imports no relocation service, journal, manifest, progress,
  capacity, staging, finalizer, or relocation activation permit;
- startup recovery has no verifier, metadata, hash, recursive-list, or legacy
  relocation dependency;
- Settings contains no adoption activation reference;
- adoption persistence callers are confined to the location controller and
  notifier seams;
- the transaction serializes no mover state;
- ordinary persistence rejects a raw active bookmark;
- the authority expires outside its coordinator scope;
- successful adoption requires the normal Phase Four lease; and
- external destructive reset remains denied.

The legacy mover remains compiled but disconnected and inert. Its parked
operation was not accessed or modified.

## Files changed

Production adds the adoption authority, provider composition, transaction and
recovery services, bookmark-only boundary, transaction entity/store, and
bounded root inspector. It extends the location controller/notifier with
authority-protected adoption methods, the verifier with candidate-only
structural comparison, startup composition with bounded recovery, and the
public feature seam with only the recovery provider.

Tests add focused adoption/rollback/recovery and architecture suites, and
adapt the Checkpoint Three recording reader to the candidate-only method.
Generated Riverpod output, this record, `CHANGELOG.md`, and `pubspec.yaml` are
included. There are no schema, migration, dependency, native implementation,
or Settings changes.

## Deviations from the design

The optional representative payload-resolution step is omitted because the
approved structural and content evidence already binds every required payload,
the post-switch structural traversal proves the same candidate, and the normal
writable-root lease proves operational authority. Sampling would weaken the
complete-evidence statement while rereading every payload would duplicate full
verification.

The optional completed receipt is also omitted for the smaller persistence
surface described above. Recovery always rolls intended configuration back to
previous rather than trying to finish an interrupted adoption at startup; this
keeps startup bounded and conservative.

No mandatory stop-and-report gate was encountered.

## Exact Checkpoint Five starting point

Checkpoint Five may expose the internal adoption service through the
simplified Settings workflow. It should retain the ephemeral complete result,
call the typed adoption service only from the explicit final action, map typed
outcomes to the approved terminology, and present the retained previous source
without making it fallback authority.

Checkpoint Five must not weaken the adoption authority, move rollback into UI,
recreate the mover workflow, persist stale approval-ready evidence, permit
ordinary active configuration setters, enable external destructive reset, or
delete either archive.
