# Simplified Archive Adoption — Checkpoint Five

## Status and checkpoint boundary

Checkpoint Five implements the production-quality simplified Settings
workflow from `08-SIMPLIFIED-ARCHIVE-ADOPTION-DESIGN.md`, while retaining the
exact development-only execution gate. It does not authorize production
adoption or a manual development rehearsal.

Checkpoint Four was reviewed and committed before this work began:

```text
562b824f2b39728c1034c1170a4cd7e4aa1cc1b0
feat(attachments): add verified archive adoption transaction
```

The legacy mover remains compiled but unreachable. Its parked operation is not
discovered, read, resumed, changed, cancelled, migrated, or deleted.

## Settings architecture reused

The workflow continues through the existing data-only Settings chain:

```text
Settings cassette spec
  -> Settings coordinator
  -> attachment archive resolver
  -> inert cassette payload
  -> shared supplemental renderer/action list
  -> typed sidebar intent
  -> sidebar action dispatcher
  -> attachments-owned workflow notifier
```

The renderer contains no archive traversal, payload hashing, bookmark work,
configuration persistence, location-controller mutation, or adoption-authority
construction. It renders typed payload data and dispatches typed intents only.

The attachments-owned notifier is process-local and keep-alive for the current
application process. It privately retains the exact complete verification
object needed by Checkpoint Four. Neither the public workflow state nor the
Settings payload contains that result, a bookmark, structural fingerprints,
configuration authority, or a writable-root lease. Provider/application
reconstruction therefore discards readiness and requires another check.

## Intents and actions

Checkpoint Five adds exactly these Settings intents:

- `AttachmentArchiveUseExistingRequested`;
- `AttachmentArchiveChooseAnotherFolderRequested`;
- `AttachmentArchiveCheckAgainRequested`;
- `AttachmentArchiveUseCandidateRequested`; and
- `AttachmentArchiveCancelCheckRequested`.

The sidebar dispatcher maps them only to the adoption workflow notifier. It
does not import or invoke the verifier, adoption service, bookmark adapter,
location provider, configuration store, or legacy relocation runtime.

The user-facing actions are **Use Existing Archive…**, **Choose Another
Folder**, **Check Again**, **Use This Archive**, and **Cancel**. There are no
Move, Begin Relocation, preflight, capacity, copy, pause, resume, staging,
finalization, or mover-cancellation actions.

## Candidate chooser and admission

The existing directory chooser now uses **Choose Archive Copy**. Help text asks
the user to select the copied `attachment_archive` directory itself.

After selection, the attachments application boundary creates and resolves an
ephemeral Foundation bookmark and derives bounded native availability and
writability evidence. It retains neither that bookmark as active configuration
nor any display path as filesystem authority. Selection does not persist
`activeArchive`, create an adoption transaction, invoke Checkpoint Four, or
modify either archive.

The adoption transaction creates a fresh bookmark again only after explicit
**Use This Archive** approval and fresh Checkpoint Three revalidation.

## Checking, progress, and cancellation

Checking is an ephemeral full Checkpoint Two verification. Settings presents
**Checking archive copy…**, current/candidate paths, and the available phase,
file count, and byte count. The copy says explicitly that neither archive is
being changed.

Cancellation advances a process-local operation token. The verifier observes
that token through its existing cancellation callback between bounded work and
streaming hash chunks. A cancelled or superseded check cannot publish a late
result. No progress, manifest, receipt, or cancellation record is persisted,
and there is no filesystem cleanup.

## Complete, behind, invalid, and unavailable presentation

`candidateComplete` presents both canonical paths, verified file/byte totals,
valid candidate extras, and candidate volume. **Use This Archive** is offered
only when the fresh verification evidence says the candidate is physically
writable. A readable but read-only complete copy receives calm explanatory
text plus **Choose Another Folder** and **Check Again**.

`candidateBehind` is a normal synchronization state. Settings reports the
exact missing count and bytes, tells the user to update the external copy, and
offers **Choose Another Folder** and **Check Again**. MessageLens never copies
the missing payload or activates the candidate.

`candidateInvalid` shows the verifier's specific typed reason and only offers
**Choose Another Folder**. Source and candidate unavailability remain distinct:
an unavailable source prevents verification, while an unavailable candidate
leaves the current source authoritative. No state introduces internal
fallback.

## Check Again and approval-change behavior

**Check Again** reacquires fresh ephemeral bookmark availability evidence and
runs a completely new Checkpoint Two verification against the then-current
active archive. It does not reuse the prior source inventory as authority.

If Checkpoint Four reports `sourceChangedCheckAgain` or
`candidateChangedCheckAgain`, Settings presents **The archive changed since it
was checked**, confirms that no location changed, discards the ready result,
and requires **Check Again**. After the new complete result, the user must
explicitly choose **Use This Archive** again. There is no automatic reverify
and activate path.

`verificationEvidenceInvalid`, `sourceUnavailable`, `candidateUnavailable`,
and `candidateNoLongerWritable` retain their typed, safe explanations rather
than collapsing into a generic failure.

## Switching and adoption boundary

Only `AttachmentArchiveUseCandidateRequested` calls the Checkpoint Four
application boundary, and only while the private ready result is current and
writable. Settings presents **Switching archive location…** while the short
transaction runs. It never presents copy, move, transfer, or finalization
progress.

Checkpoint Four remains responsible for the uninterrupted coordinator scope,
fresh approval revalidation, bookmark admission, durable pending transaction,
authority-protected configuration switch, normal location resolution,
post-switch candidate fingerprint, Phase Four writable-root lease, success,
and rollback. No authority moved into the workflow, dispatcher, resolver,
payload, or widget.

## Success and retained source

Only `AttachmentArchiveAdoptionOutcome.adopted` becomes **External archive
active**. The presentation shows the new path and volume, identifies the
retained original path, recommends keeping it for a few days, and states that
MessageLens has not deleted it.

The original is not called a backup, is not runtime fallback, and receives no
deletion authority. No delete-old-archive action or cleanup timer exists.

## Rollback and startup recovery

`rollbackRestoredPrevious` states that the location was not changed, the exact
previous location was restored, and both folders remain untouched.

`rollbackPendingPreviousUnavailable` states that recovery is waiting for the
previous archive. `configurationConflict` states that the archive location
changed unexpectedly and MessageLens did not guess which root is authoritative.
Neither state claims success or performs configuration repair in presentation
code.

Settings projects the typed keep-alive Checkpoint Four startup-recovery result.
That small durable pending switch record remains distinct from process-local
verification readiness. A relaunch discards ready evidence but continues the
existing bounded pending-transaction recovery contract.

## Development gate

The adoption workflow is enabled only when every exact field matches:

```text
environment: development
build: developmentDebug / developmentProfile / developmentRelease
bundle: com.bigbenchsoftware.MessageLens.development
product: MessageLens Development
root: /Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
archive instance: e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5
```

Every single-field mismatch, the complete production identity, the FDA
experiment identity, the test identity, and pre-admission state are denied.
There is no flag, preference, environment variable, hidden override, or
persisted switch. Tests override the generated provider directly with
disposable dependencies.

## Legacy isolation

The simplified workflow imports and invokes no relocation journal, relocation
service, progress monitor, capacity API, staging path, copy receipt, exclusive
finalizer, or relocation activation permit. The public Settings seam exports
no legacy action shell. Architecture tests preserve the existing
legacy-mover-unreachable checks and add workflow-specific tripwires.

Operation `5c20c87a-c6d6-4489-8887-ae629301884f` remains parked and inert. No
implementation or automated test resolves a real development/production root
or searches for that operation.

## Tests and disposable acceptance

Focused tests cover:

- internal available, external available, external unavailable, read-only, and
  permission-denied current-location presentation with no fallback;
- the exact development gate and every single-field mismatch;
- chooser cancellation, bookmark-backed candidate selection, and proof that
  selection alone does not adopt;
- ephemeral progress, cancellation, and suppression of late results;
- complete totals/extras and writable-only **Use This Archive** eligibility;
- behind exact count/bytes, fresh **Check Again**, and no auto-copy;
- invalid typed reasons and distinct source/candidate unavailability;
- both approval-time changed outcomes and all Checkpoint Four typed outcomes;
- switching before success, rollback, pending recovery, conflict, and no false
  success;
- ready-state loss after provider reconstruction;
- typed intent-to-workflow dispatch; and
- Settings/widget/payload authority and legacy-isolation architecture rules.

The disposable end-to-end Settings test uses an admitted temporary archive,
an in-memory overlay database, a user-created candidate directory, the real
filesystem verifier, the normal typed intents/dispatcher/resolver, and the real
Checkpoint Four transaction service. It:

1. verifies an initially complete copy;
2. adds a source payload and metadata after review;
3. receives the changed/check-again result on approval;
4. updates the candidate as an external user action;
5. performs a fresh complete check;
6. explicitly adopts;
7. proves the external candidate is the normal active location and writable
   lease root with destructive reset denied;
8. proves source and candidate payload snapshots did not change during
   adoption;
9. proves the tiny transaction is retired and no legacy relocation directory
   exists; and
10. separately injects a post-configuration-write failure and proves exact
    rollback, no pending record, unchanged payloads, and no false success.

No real archive, application database, mounted volume, bookmark setting, or
parked operation is accessed by these tests.

## Deviations from the design

No completed-adoption receipt was added, consistent with Checkpoint Four. The
retained original path is process-local success presentation and disappears on
relaunch; current location remains durable truth.

The chooser's explanatory sentence is rendered in the Settings card rather
than a native accessory view because the existing file-selector contract
supports confirm-button text but no cross-platform explanatory accessory.

No mandatory stop-and-report gate was encountered.

## Exact next step

Checkpoint Five must first receive a full review/checkpoint. After approval:

1. remove obsolete mover-only production code;
2. validate the repository after simplification; and
3. separately authorize the new development rehearsal.

Production adoption is not automatically authorized, the development rehearsal
must not begin from this checkpoint, and parked-operation cleanup remains a
separate explicitly approved task.
