# Archive Adoption — Verified-Behind Remediation and Center Pane

## Status and prior checkpoint

The `.DS_Store` classification and folder-selection UX correction was reviewed
and committed before this work began:

```text
b3f2c5eb439bc24627ded9549a414b908413e09d
fix(attachments): clarify archive adoption and ignore Finder metadata
```

This revision remains unstaged and uncommitted. Production archive adoption is
still disabled. The real development rehearsal remains stopped, the WD archive
remains authoritative, and neither the WD nor Toshiba rehearsal archive was
opened or modified during implementation or disposable validation.

## Rehearsal findings

The first real rehearsal established two product facts:

1. the Attachment Archive workflow is too information-dense for a Settings
   sidebar cassette; and
2. a copied archive can be correct but slightly behind because new attachments
   arrive in the authoritative archive after the user makes the bulk copy.

The former is a placement problem. The latter is not corruption and should not
force a user to merge hash-bucket directories manually. It is safe only when
MessageLens can prove a finite, exact, purely additive difference.

## Settings center-pane architecture

`SettingsMenuActionId.attachmentArchive` remains the sidebar navigation item.
Its sidebar topology now projects no child cassette. The sidebar therefore
contains navigation only and does not render paths, verification results,
progress, or actions.

The existing Settings flow projects
`SettingsViewSpec.attachmentArchiveWorkflow`. The normal Settings ViewSpec
coordinator resolves that spec through `AttachmentArchivePanelResolver` to
`AttachmentArchivePanel`. The panel watches the existing attachments-owned
workflow provider; no duplicate Settings workflow state was introduced.

The center pane owns:

- current archive path, volume, and availability;
- copied archive path and volume;
- folder selection and explicit approval actions;
- preparation and determinate verification progress;
- complete, verified-behind, invalid, and unavailable results;
- switching and remediation progress;
- post-switch pending remediation; and
- success with both the active and retained-original locations.

Dynamic progress and results replace one another in the working region below
the selected copy. Stable heading/context content does not become an action
result surface. The panel uses existing Settings navigation and responsive
scroll/detail composition; it does not create a bespoke window or block first
usable UI.

The folder chooser continues to select the copied `attachment_archive`
directory itself. User-facing text uses physical paths, volume names, and task
language rather than `defaultInternal`, `customExternal`, `candidate`, or a
misleading location label such as “Internal.”

## Determinate verification progress

Verification has two presentation stages:

1. **Preparing archive check…** performs a read-only, metadata/structure-only
   source traversal to establish exact required preservation file and byte
   totals. It does not hash or read payload bodies.
2. **Checking archive copy…** performs the existing streaming source/candidate
   verification and reports `filesChecked / totalFiles`,
   `bytesChecked / totalBytes`, and a percentage.

The denominator is the authoritative source's required physical preservation
payload set:

- `totalFiles` is the number of required source payload files;
- `totalBytes` is the sum of their source sizes;
- one required payload advances the numerator exactly once, after its candidate
  outcome is known; and
- byte progress represents required preservation bytes whose complete,
  correct, missing, or conflicting outcome has been determined.

Source and candidate bytes can both be streamed for one comparison, but that
payload's authoritative size counts only once. Candidate-only allowed extras,
Finder `.DS_Store`, installer debris, directories, and metadata rows do not
inflate the denominator. If total bytes are zero, the percentage falls back to
the file fraction; an empty required set is complete.

Exact totals cannot be known before traversal without materializing the full
archive inventory. The preparation traversal is therefore the cheapest
truthful method and is reused as safety evidence: its structural fingerprint
and totals must match the hashing pass or verification fails as changed. It is
not a second payload-byte/hash scan and introduces no unbounded list.

Candidate extras are still scanned and classified after required source
coverage reaches 100 percent. They remain outside the progress denominator
because they are not required preservation payloads and including them would
make the meaning of “required files checked” unstable.

## Candidate decision contract

Verification keeps three safety classes:

- **Complete:** every required source preservation payload exists in the copy
  with the expected size and SHA-256 evidence, and all additional candidate
  entries are allowed.
- **Verified-behind:** every present required payload is correct and every
  absent payload has an exact source-relative path, size, and SHA-256. There
  are no conflicts, corrupt or unsafe entries, ambiguous paths, symlinks,
  special entries, unsupported shapes, or incomplete missing evidence.
- **Invalid/conflicting:** any present evidence is wrong, unsafe, ambiguous, or
  structurally unsupported. Adoption is denied and no automatic repair is
  attempted.

Complete and bounded verified-behind results may expose **Use This Copy**.
Invalid/conflicting results never do. A verified-behind result is also not
adoptable if exact missing evidence was truncated or if the final obligation
exceeds either 256 files or 1 GiB. That large-delta policy directs the user to
refresh/recreate the bulk copy externally; MessageLens does not turn a large
catch-up into an application-owned mover.

The exact `.DS_Store` rule is unchanged: a regular file whose basename is
exactly `.DS_Store` is ignored as filesystem metadata, never contributes
payload coverage, and is never deleted. A metadata reference to it fails
closed, and near names remain unknown/invalid.

## Final-delta refresh under coordination

The review-screen missing list is not authority. Pressing **Use This Copy**
acquires `ArchiveMutationOperation.attachmentArchiveAdoption` coordination and
holds that scope without interruption through final refresh, configuration
switch, writable-root proof, remediation, and final coverage proof.

Within that scope the service reruns full verification and requires:

- the same active source configuration, generation, and canonical source;
- the same candidate canonical identity, structural fingerprint, verified
  file/byte totals, and allowed-extra totals;
- every previously reviewed missing item to remain absent with exactly the
  same path, size, and SHA-256; and
- all count/byte growth to be explained solely by additional valid source
  payloads that are absent from the unchanged candidate.

Candidate changes, conflicts, removed/changed reviewed payloads, non-additive
source changes, unavailable roots, read-only status, or an over-limit final
delta stop before adoption and require another check.

## Switch first and point of no automatic rollback

For a verified-behind result the service:

1. durably writes the prepared transaction with the final exact missing set;
2. persists the candidate as the active archive;
3. resolves and proves the expected active candidate generation;
4. obtains and validates the ordinary Phase Four writable-root lease for that
   exact candidate configuration and root;
5. durably writes `activeRemediationPending`;
6. installs the finite historical set;
7. performs a full final-coverage verification; and
8. clears the transaction only after complete coverage is proven.

The point of no automatic rollback is step 5: the candidate configuration and
normal writable lease have both been proven under the coordinator, and the
post-switch obligation is durable. Before that point, Checkpoint Four rollback
semantics remain available. After it, ordinary writes may land in the
candidate, so any failure becomes **active candidate + pending historical
remediation**. The service never automatically returns writes to the retained
source after that boundary.

## Narrow remediation authority and canonical installer

`AttachmentArchiveRemediationAuthority` is internal and can be issued only for
one item in one active verified-behind transaction. It binds:

- transaction ID;
- retained source and candidate canonical identities;
- active candidate root and location generation;
- exact relative path, size, and SHA-256 payload evidence;
- the adoption coordinator capability;
- the current durable transaction;
- current location/configuration; and
- the matching Phase Four writable-root lease.

Every mutation boundary revalidates those facts. The authority explicitly
rejects destructive-reset use and cannot authorize source deletion, candidate
cleanup, an arbitrary path, another transaction, or another active root.

Remediation reuses `FilesystemAttachmentArchiveFileStore` and its existing
atomic no-overwrite install core. The exact-path entry point requires the typed
authority. It streams bytes into a sibling temporary file, flushes, verifies
the expected size and SHA-256, atomically installs without overwrite, and
verifies the installed destination. If the destination appears concurrently,
matching bytes are accepted idempotently; conflicting bytes are retained and
the operation fails pending. Source paths are resolved beneath the retained
canonical root without following links outside it.

No source payload or candidate extra is deleted. No conflicting destination is
overwritten. There is no capacity preflight, staging archive, folder rename,
directory finalizer, general synchronization, initial bulk copy, pause/resume
mover, or per-file copy receipt.

## Durable transaction and recovery

Adoption transaction format 2 retains backward reads for format 1. Format 1 is
interpreted as the unchanged complete-adoption transaction. Format 2 adds:

- kind `complete` or `verified_behind`;
- state `active_remediation_pending`; and
- a bounded immutable list of exact remediation payload path/size/SHA-256
  obligations.

The transaction remains capped at 256 KiB on disk. The obligation is also
bounded to 256 files and 1 GiB. It contains no manifest of already-present
content, copy receipts, staging identity, capacity evidence, per-item journal,
pause state, or resume cursor. Resume is idempotent: each fixed destination is
rechecked, matching completed items are accepted, and conflicting items stop
without overwrite.

Startup recovery remains cheap. It reads one small record and bounded
location/bookmark/root evidence; it does not inventory or hash an archive. An
`activeRemediationPending` transaction is never rolled back. Startup reports a
typed pending result, and the center pane offers **Resume Adding Missing
Attachments**. Explicit resume reacquires adoption coordination, proves the
active candidate and writable lease, resolves the exact retained source, and
continues the fixed obligation before final coverage verification.

If the retained source is unavailable, the candidate remains active and the
transaction remains pending. If the candidate is unavailable, it is not
recreated and the transaction remains pending. When either returns, explicit
resume can continue safely.

## Attachment resolution while remediation is pending

An archive record missing from the active candidate reports
`pendingHistoricalRemediation` only when its exact relative path occurs in the
active transaction and the current configuration/generation matches that
transaction. Resolution does not read the payload from the retained source and
does not use the old archive as a silent fallback. Records already present in
the candidate resolve normally. Ordinary ingestion after the switch uses the
active candidate through the normal writable-root authority.

## UX outcomes

A complete copy reports **Archive copy verified** and offers explicit use. A
bounded verified-behind copy reports **This copy is almost up to date**, shows
exact attachment/byte delta, explains switch-first remediation, confirms the
current archive remains unchanged, and offers explicit use.

Remediation reports exact completed/total attachments and bytes. Success shows
the new current archive and the original archive, states that all verified
attachments are available, and confirms that MessageLens did not delete the
original. Pending remediation states that the new archive remains active,
identifies the finite older attachment/byte obligation and retained source,
and offers explicit resume. No deletion action is offered.

## Disposable coverage

Disposable tests cover:

- unchanged complete adoption and all pre-switch rollback paths;
- behind-by-one/many evidence and exact bounded obligations;
- three missing payloads at review growing additively to five under the held
  coordinator, followed by switch-first installation and complete coverage;
- candidate change/conflict during final refresh;
- crash after two of five installs, reconstructed services, a new ordinary
  candidate-only payload, idempotent resume of the remaining fixed set, and
  complete final coverage;
- matching and conflicting concurrent destination appearance;
- retained-source and active-candidate unavailability after switch;
- typed pending attachment resolution without retained-source fallback;
- determinate verification/remediation totals and center-pane placement;
- sidebar navigation with no Attachment Archive child cassette;
- exact `.DS_Store` behavior;
- source byte-for-byte preservation, no overwrite, and no extra deletion; and
- architecture tripwires for bounded authority/transaction state, installer
  reuse, and continued absence of the retired general mover.

All filesystem scenarios use temporary disposable roots. No native production
code or schema/migration changed in this revision.

## Legacy-mover non-regression

The deleted relocation service, journal, staging, capacity API, filesystem
probe, finalizer, copy receipts, pause/resume engine, and mover activation
permit remain absent. Remediation is an exact, small, transaction-bound
historical obligation after an externally performed bulk copy. It cannot
discover, resume, or mutate the parked legacy relocation operation.

## Exact rehearsal restart point

Do not resume the real rehearsal until this revision is reviewed and
checkpointed and a separate instruction explicitly authorizes it.

At that point the real state is still:

```text
Authoritative source:
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/attachment_archive

Selected copy:
/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive
```

WD remains authoritative; Toshiba has not been adopted. Resume by launching
the qualified freshly built MessageLens Development app and selecting the
Toshiba copied `attachment_archive` directory again. Review the new center-pane
complete/verified-behind result before any explicit adoption. Do not relax the
development gate, change the current root, or infer that the prior selection
was adopted.

The abandoned legacy relocation artifacts remain parked and untouched.
