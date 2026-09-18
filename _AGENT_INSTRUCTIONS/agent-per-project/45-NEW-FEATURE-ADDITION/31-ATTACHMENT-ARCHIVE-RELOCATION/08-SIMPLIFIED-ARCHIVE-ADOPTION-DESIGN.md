# Simplified Attachment Archive Adoption Design

## Audit status

This document supersedes the Phase Five/Six **product design** in
`05-PHASE-FIVE-IMPLEMENTATION-RECORD.md`,
`06-PHASE-SIX-IMPLEMENTATION-RECORD.md`, and the execution plan in
`07-DEVELOPMENT-RELOCATION-REHEARSAL-READINESS.md`. Those records remain useful
historical and qualification evidence. This document does not supersede the
Phase One-Four location, availability, and mutation-authority architecture.

This was a read-only design audit. The only repository change made by the
audit is this document. No production code, generated file, test, dependency,
release metadata, bookmark, setting, database, attachment payload, relocation
journal, staging directory, qualification evidence, mounted volume, or
application runtime state was changed.

The parked operation remains exactly as found:

```text
operation: 5c20c87a-c6d6-4489-8887-ae629301884f
stage: inventoryComplete
source authority: defaultInternal on WD_ELEMENTS
copy/verification/activation: not begun
```

### Implementation checkpoint status

Checkpoint One disconnects the legacy relocation workflow from Settings,
sidebar action dispatch, public feature seams, and ordinary runtime
composition. The legacy engine remains temporarily compiled inside the narrow
attachments-owned legacy boundary for controlled extraction and removal. Its
development qualification predicate remains exact but has no production
consumer. The parked operation is inert and untouched. Candidate verification
and adoption are not implemented in this checkpoint.

Checkpoint Two adds an isolated, read-only candidate-verification core. It
extracts the reusable grouped metadata and preservation-aware traversal rules
without depending on the legacy mover service, and produces typed, ephemeral
evidence for a later adoption checkpoint. It is not connected to Settings and
cannot activate, persist, copy, repair, probe, or otherwise mutate either
archive. See `09-SIMPLIFIED-ADOPTION-CHECKPOINT-TWO.md` for the implemented
contract, evidence format, validation coverage, and Checkpoint Three handoff.

## 1. Executive summary

MessageLens should stop being an archive-copy program. The user copies the
`attachment_archive` directory with Finder, `rsync`, or another tool. In
MessageLens, the user selects that copied directory. MessageLens then proves
that every preservation payload in the **current active archive** is present
with equivalent content, asks for explicit approval, briefly revalidates that
neither root changed, and switches the bookmark-backed location. The original
archive is retained and MessageLens never deletes it.

The Phase One-Four architecture remains the foundation: archive-relative
identity, bookmark-backed external roots, availability-aware reads, generation
invalidation, no fallback, and generation/configuration-bound write authority.
Phase Five's metadata grouping, safe traversal, preservation classification,
streaming SHA-256 comparison, narrow activation authority, and rollback ideas
are reusable after extraction. Its copier, durable relocation journal,
receipts, capacity checks, staging/finalization, pause/resume, and long-running
progress system are not part of the new production design.

The full relocation journal is not required for activation. A small durable
**adoption transaction record** is sufficient to close only the configuration
switch crash window. It stores previous and intended configurations plus
verified identities; it stores no payload manifest, copy receipt, or progress.

No mandatory stop-and-report condition was found. The simplified design can
retain Phase Four's safety, requires no attachment-row or database-schema
migration, can revalidate source changes in bounded work, and can roll back the
configuration without modifying either physical archive.

## 2. New product contract

The product contract is:

1. The current configured archive remains authoritative until adoption fully
   commits.
2. The user independently creates or updates a copy of the archive.
3. **Use Existing Archive…** selects the copied `attachment_archive` directory
   itself, not its parent and not a MessageLens-owned staging directory.
4. MessageLens reads both roots and validates current-source coverage. It does
   not add, replace, rename, move, or delete any payload in either root.
5. A candidate can be activated only from a successful verification result
   tied to exact source configuration, source location generation, canonical
   source identity, canonical candidate identity, and root snapshot evidence.
6. Activation requires a separate explicit **Use This Archive** action.
7. That action reacquires archive mutation coordination and revalidates the
   verification evidence. A changed source or candidate returns to review; it
   never activates optimistically.
8. Activation persists `customExternal(activeArchive)` only through an
   unforgeable verified-adoption authority, resolves the normal location
   provider, proves canonical identity and availability, and proves issuance
   of a valid Phase Four writable-root lease.
9. Attachment rows retain `archive_relative_path`. No absolute paths are
   written and no rows are migrated.
10. On any switching failure, the previous configuration is restored and
    proved authoritative. Both physical archives remain untouched.
11. MessageLens never silently falls back to the retained original.
12. Original-archive deletion, reclamation, reverse relocation, and automatic
    synchronization are outside this workflow.

The central invariant is:

> Every classifiable preservation payload that exists in the authoritative
> active archive at adoption time must exist at the same safe relative path in
> the candidate with equivalent content before the candidate can become
> active.

## 3. Phase One-Four architecture retained

The following remains authoritative and should not be weakened or
reimplemented inside adoption:

- `AttachmentArchiveLocationConfiguration` remains the versioned root
  selection. The existing serialized write-policy spelling may remain for
  compatibility even if Dart/UI terminology changes from relocation to
  adoption.
- Attachment identity remains `archive_relative_path` plus archive-root
  resolution. No schema migration or absolute-path rewrite is needed.
- External identity remains a security-scoped bookmark. `lastKnownPath` is
  display metadata only and is never filesystem authority.
- `AttachmentArchiveLocationState` continues to distinguish available,
  read-only, unavailable, denied, missing, and invalid states. Unavailable is
  not interpreted as a missing attachment.
- Effective location changes continue to advance location generation and
  revoke stale paths and writable-root leases.
- Mount/unmount/rename/application-activation events continue to refresh
  bounded location state; they do not trigger recursive verification.
- A configured external archive remains authoritative while disconnected. No
  internal fallback is introduced.
- `AttachmentArchiveWritableRootLease` remains opaque and bound to canonical
  root, configuration, and generation. Mutation paths continue to revalidate
  it at their existing boundaries.
- An external archive becomes writable only after verified activation. Folder
  selection alone remains read-only/ineligible for mutation.
- External recursive clearing/reset remains denied. Recovery and ingestion
  remain deferred while the active external archive is unavailable.
- The canonical verified payload installer and its atomic no-overwrite
  behavior remain unchanged for ordinary ingestion and recovery. Only the
  relocation-specific use of it is retired.
- Existing raw-path authority and public-provider-seam architecture tests
  remain. They should be extended for adoption rather than deleted.
- Phase Three's Settings location/availability presentation remains the base
  state. Phase Six's generic status-line and enabled-action rendering can be
  retained.

The semantic baseline is the Phase Four checkpoint, not a literal branch
reset: later safe changes to shared files must be reviewed and adapted rather
than blindly reverted.

## 4. Phase Five/Six keep/reuse/retire classification

Categories are: **A** keep unchanged, **B** reuse/simplify, **C** retire from
production, and **D** retain only as test/architecture or historical support.

| Component | Category | Target disposition |
| --- | --- | --- |
| Relocation state machine | C | Replace its 16 copy-oriented stages with small ephemeral adoption states: idle, checking, ready, behind, invalid, adopting, succeeded, failed. |
| Relocation journal | C | Do not use it for new work or startup reconstruction. Replace only the switch crash window with a small adoption transaction record. |
| Manifest format | B/C | Reuse the manifest-entry concept in-memory/streaming; retire durable relocation `manifest.ndjson` and its operation directory. |
| Copy receipts | C | Delete from production; adoption creates no copies and has nothing to resume. |
| Destination capacity API | C | Remove the Dart interface, method-channel method, Swift implementation, and native capacity test. |
| `PrivacyInfo.xcprivacy` Disk Space declaration | C | Remove the `E174.1` disk-space declaration and Xcode registration if a final repository/build audit confirms no other code uses that required-reason API. |
| Staging-directory model | C | Remove managed staging/final child names and all staging cleanup/probe behavior. The selected directory is the candidate root. |
| Filesystem-semantics probe | C | Remove hard-link/flush/exclusive-rename probing; MessageLens does not construct the candidate. |
| Hard-link no-overwrite relocation installer | C/A | Retire it from relocation. Keep the pre-existing canonical installer unchanged for normal ingestion and recovery. |
| Exclusive rename finalizer | C | Delete the relocation-only Darwin finalizer and tests. |
| Relocation copy engine | C | Delete copy/temp/install/reconcile/finalize code. |
| Relocation pause/resume | C | Delete durable pause/resume. A verification check may be cancelled and restarted, but has no resumable payload work. |
| Relocation progress monitor | C | Delete journal polling. Verification may publish ephemeral files/bytes checked directly from its running provider. |
| Source-stability reconciliation | B | Replace aggregate count/byte comparison with deterministic source and candidate snapshot fingerprints plus short fresh revalidation at approval. |
| Relocation activation gate/permit | B | Replace journal/receipt-dependent authority with an unforgeable verified-adoption permit issued only after successful fresh revalidation. |
| Candidate/source inventory code | B | Extract safe canonical traversal, metadata validation, and classification; remove staging, capacity, and copy dependencies. |
| Metadata reader | B | Retain grouped, paged metadata queries and conflict detection; rename from relocation to adoption/verification terminology. |
| Streaming SHA-256 verifier | B | Retain streaming hashes and source/candidate equality checks; remove receipt coupling. |
| Unreferenced-preservation classification | B | Retain canonical hash and legacy `_by_id` recognition; strengthen hash-named extra validation. |
| Settings relocation workflow | B/C | Reuse Settings composition, status lines, action dispatch, accessibility, and retained-source language; replace all mover states/actions/copy text. |
| Production/development execution gate | D | Keep an exact fail-closed development qualification gate while adoption is under test. It is not the production product contract and needs separate release authorization. |
| Retained-source presentation | B | Keep and simplify. Persist only a compact completed-adoption receipt if post-relaunch display is desired. |
| Bookmark/location configuration switching | B | Reuse the normal bookmark controller, generation publication, and location resolution; rename the narrow verified method from relocation to adoption. |
| Rollback configuration switching | B | Keep the reversible sequence; authorize it with the adoption permit and small pending transaction, not the relocation journal. |
| Phase Six generic supplemental card/status-line widget | A | It is not mover-specific and can render adoption result/status rows unchanged. |
| Settings enabled-action semantics and typed dispatch | A | Retain the generic no-callback-when-disabled and semantic button behavior; replace only relocation-specific intents. |
| Phase Five/Six implementation records and disposable acceptance fixtures | D | Preserve as historical rationale and reusable test-data patterns; do not treat them as the active product specification. |

## 5. Candidate verification contract

### Admission

The selected candidate must:

- be an existing readable directory selected as the archive root itself;
- resolve canonically through a bookmark without using the display path as a
  fallback;
- not be the same canonical directory as the source and not be nested in
  either direction with the source;
- not be a symlink; and
- resolve as writable/available before adoption, because it must support
  future ordinary archive writes. Verification itself remains read-only and
  creates no probe file.

The basename need not be used as authority. The chooser and help text should
ask for the copied `attachment_archive` directory, while structural validation
determines whether the selected root is usable.

### Deterministic, bounded traversal

Extract the Phase Five traversal into an adoption verifier. Traverse without
following links and yield entries in deterministic lexical relative-path
order. Sorting one directory at a time bounds memory by the largest directory,
not total archive size. Hash file streams incrementally; never materialize a
payload or the complete archive in memory.

For the authoritative source:

- reject absolute, empty, `.`/`..`, escaping, or non-normalized paths;
- reject symlinks in the root or any component and reject special entries;
- group duplicate metadata rows by `archive_relative_path`;
- fail verification if grouped rows disagree on size or non-null hash;
- require every metadata-known path to name a regular source file of the
  recorded size;
- classify valid content-addressed and legacy `_by_id` files without metadata
  as unreferenced preservation payloads;
- classify only the existing exact installer-temporary pattern as operational
  debris, exclude it from required coverage, and report it; and
- fail with `verificationFailed` if the authoritative source contains an
  unknown regular-file shape. Source anomalies are not silently omitted.

For every required source payload, inspect the exact candidate relative path:

- absent is a behind item, not corruption;
- symlink, special entry, unsafe component, directory-in-place-of-file, or
  size mismatch is a candidate conflict;
- when metadata contains SHA-256, hash both source and candidate and require
  both to match it; and
- when metadata has no hash, hash both and require exact equality.

The result contains source/candidate canonical identities, source
configuration and generation, required file/byte totals, verified totals,
metadata row count, unreferenced count, debris count, allowed-extra totals,
missing totals, bounded diagnostic examples, a strong content-coverage digest,
and structural snapshot fingerprints for both roots. Diagnostic path lists
must be capped (for example, first 100 stable relative paths) while exact
counts and bytes remain complete.

No verification result writes hashes back to metadata.

### Typed result

Use a sealed result vocabulary equivalent to:

- `candidateComplete`;
- `candidateBehind`;
- `candidateInvalid`;
- `sourceUnavailable`;
- `candidateUnavailable`; and
- `verificationFailed`.

`candidateComplete` is the only result eligible for the later approval step.
Conflicts/unsafe candidate contents take precedence over `candidateBehind` so
the UI never describes a conflicting copy as merely stale.

## 6. Candidate-behind semantics

`candidateBehind` means one or more classifiable current-source preservation
payloads are absent from an otherwise non-conflicting candidate. This is an
expected synchronization state, not archive corruption and not an exception.

The result reports:

- exact missing payload count;
- exact total missing bytes;
- a bounded, stable list of missing `archive_relative_path` examples;
- the source/candidate paths and verification time; and
- any separately classified allowed extras or debris.

Activation is disabled. The UI says, for example:

> 1 new attachment (3.1 MB) has been archived since this copy was made.
> Update your external copy, then choose Check Again.

MessageLens does not copy the missing files. **Check Again** performs a fresh
comparison against the then-current active archive; it does not reuse the old
source manifest as authority.

## 7. Candidate-extra semantics

Candidate extras do not weaken the coverage invariant. Classify them as:

1. **Valid content-addressed preservation extra.** The path has
   `<first-two-hash-characters>/<64-character-lowercase-SHA-256><safe extension>`
   shape and the file's SHA-256 equals the filename identity. Allow, preserve,
   and report count/bytes.
2. **Valid legacy preservation extra.** A regular file has the exact supported
   `_by_id/<numeric-id><safe extension>` shape. Allow, preserve, hash for
   evidence, and report count/bytes. Absence of current metadata is not
   deletion authority.
3. **Recognized installer debris.** An exact canonical installer-temporary
   name is non-preservation debris. Ignore for coverage, report it, and do not
   delete it. The first implementation should not invent a broad debris
   allowlist.
4. **Unknown or conflicting extra.** A regular entry outside supported archive
   shapes, a hash-named entry whose content contradicts its name, a path that
   collides under canonical filesystem semantics, a symlink, a special entry,
   an unsafe path, or structurally ambiguous content makes the candidate
   `candidateInvalid`.

This is preservation-biased without accepting arbitrary ambiguity: valid
unreferenced payloads are retained, debris is never silently deleted, and
unknown structures fail closed with bounded path evidence.

Empty safe directories do not affect coverage. They may be reported but are
not payloads.

## 8. Source-change race closure

Do not keep an archive mutation lock across human review.

During full verification, capture two kinds of evidence in deterministic
order:

- a strong content digest derived from relative path, size, classification,
  metadata evidence, and actual SHA-256; and
- a structural snapshot fingerprint derived from every safe directory/file
  relative path, type, size, modification/change timestamps, classification,
  and grouped metadata evidence.

Also capture the source location configuration, location generation, and
canonical source and candidate roots. Keep a ready result process-local; after
provider reconstruction or app relaunch the user must **Check Again**. This
avoids treating stale persisted verification as activation authority.

When **Use This Archive** is pressed:

1. acquire the existing archive mutation coordinator with a narrowly named
   adoption operation;
2. prove the current active configuration, generation, and canonical root
   still match the ready result;
3. repeat deterministic structural/metadata traversal for both source and
   candidate without hashing payload bytes;
4. compare both fresh snapshot fingerprints and all totals to the ready
   result;
5. if either differs, release coordination, discard activation eligibility,
   and return to review with “The archive changed and must be checked again”;
6. if unchanged, continue directly into the adoption transaction while the
   coordinator remains held.

This revalidation is O(number of entries), bounded in memory, and performs no
multi-gigabyte copy or payload rehash. Its safety relies on the existing
archive invariant that MessageLens installs immutable content-addressed files
with atomic no-overwrite semantics and that all supported MessageLens archive
mutations participate in the coordinator. Change timestamps plus complete
path/type/size traversal also detect ordinary external replacement. A hostile
actor deliberately changing bytes while preserving all filesystem evidence is
outside the supported concurrency model; if that threat is later included,
activation must rerun full hashes rather than weaken the proof.

After switching, repeat the candidate root fingerprint through the resolved
normal location before committing success. This narrows external interference
across the switch and fails into rollback.

## 9. Verified adoption/activation transaction

The ready result itself grants no configuration authority. Inside the
coordinator-held approval action:

1. perform the fresh revalidation in Section 8;
2. create or refresh a bookmark for the candidate root itself;
3. resolve that bookmark and require available/writable status plus exact
   canonical equality with the verified candidate;
4. construct the intended `customExternal(activeArchive)` configuration;
5. atomically write a small versioned pending adoption record beneath the
   admitted primary MessageLens root, outside `attachment_archive`;
6. issue an opaque verified-adoption permit bound to transaction ID, previous
   configuration, intended configuration, source generation/canonical root,
   candidate canonical root, and the verified fingerprints;
7. persist the intended configuration only through the permit-protected
   location-controller method;
8. resolve through `AttachmentArchiveLocation`, require the expected normal
   generation change, exact intended configuration, `customAvailable`, and
   exact candidate canonical root;
9. recheck the candidate structural fingerprint and resolve a deterministic
   representative set from the verified result;
10. obtain `AttachmentArchiveWritableRootAdmission`, require its lease root to
    equal the candidate, and validate it at `operationStart` for the adoption
    operation;
11. write a compact completed-adoption receipt containing only prior display
    location, new display location/volume, timestamp, transaction ID, and
    verified count/bytes if ongoing retained-source presentation is desired;
12. mark/remove the pending transaction atomically and publish success.

The pending adoption record is not a relocation journal. It has no manifest,
receipt stream, file progress, staging name, capacity, pause state, or resume
state. Its sole purpose is deterministic recovery from a process loss between
configuration writes. Suggested states are `prepared` and
`configurationPersisted`.

Startup recovery checks this tiny record before allowing new adoption. If the
intended configuration is persisted, it completes the same canonical
location/lease validation or restores the previous configuration. If neither
configuration matches, it fails closed for explicit recovery. It never infers
payload movement and never alters either root.

## 10. Rollback

Any exception after the pending record is durable and before success invokes
rollback through the same verified-adoption permit:

1. read the current location;
2. if it equals the intended configuration, persist the exact previous
   configuration through the permit-protected rollback method;
3. if it already equals the previous configuration, make no redundant write;
4. if it equals neither, retain the transaction and fail closed as an
   unrelated configuration conflict;
5. resolve the previous configuration normally;
6. require its canonical root to equal the verified prior source and require
   it to be authoritative/available; and
7. record/report rollback failure or success without modifying either archive.

If the previous archive is temporarily unavailable, do not claim rollback
completion and do not delete the transaction record. Present recovery-needed
state and retry only when the prior root can be proved. This is configuration
recovery, not source fallback.

## 11. Simplified Settings UX

The normal current-location card remains. For an eligible available archive:

```text
Attachment Archive
Internal (or External)
<current path>
Available

[Use Existing Archive…]
```

Selection immediately begins a read-only check:

```text
Checking archive copy…
<files and bytes checked, if useful>
```

Progress is ephemeral and accessibility text-based. It does not survive
relaunch and is never called copy progress. A user may cancel the check; no
filesystem state needs cancellation or cleanup.

Ready:

```text
Archive copy verified

Current archive: <source>
Candidate archive: <candidate>
4,039 files / 3.46 GB verified
<optional allowed-extra summary>

Everything currently stored in the active attachment archive is present in
this copy.

[Cancel] [Use This Archive]
```

Behind:

```text
Archive copy is not up to date

The active archive contains 1 attachment (3.1 MB) that is not present in the
selected copy.

[Choose Another Folder] [Check Again]
```

Invalid/unavailable:

```text
Selected folder cannot be used as an attachment archive
<specific typed reason and bounded path evidence>

[Choose Another Folder]
```

If the approval recheck finds change:

```text
The archive changed since it was checked
No location was changed. Check the copy again before using it.

[Check Again]
```

Success:

```text
External archive active
<path>
Available

The original archive remains at: <old path>
Keep the original for a few days while you confirm normal operation.
MessageLens has not deleted it.
```

There is no delete, reclaim, restore-default shortcut, or automatic update
action.

## 12. Terminology changes

Remove production wording that says or implies MessageLens moves/copies the
archive. Current strings/actions requiring replacement include:

| Current Phase Six wording/action | Replacement |
| --- | --- |
| `Move…` / `AttachmentArchiveMoveRequested` | `Use Existing Archive…` / `AttachmentArchiveUseExistingRequested` |
| `Choose Destination` | `Choose Archive Copy` |
| destination parent / managed destination | candidate archive / selected archive copy |
| `Preparing Archive Move` | `Checking Archive Copy` |
| `Review Archive Move` | `Archive Copy Verified` |
| `Begin Relocation` | `Use This Archive` |
| `Retry Preflight` | `Check Again` |
| `Choose Another Location` | `Choose Another Folder` |
| `Copying Attachment Archive` | remove |
| `Pause` / `Resume` relocation | remove |
| `Finalizing Attachment Archive` | remove |
| `Activating Attachment Archive` | `Switching Archive Location` |
| `Archive Move Cancelled` | ordinary cancelled check/selection; no durable cancellation state |
| `Archive Move Could Not Continue` | `Archive Copy Could Not Be Verified` or `Archive Location Was Not Changed` |
| `Attachment Archive Moved Successfully` | `External Archive Active` |
| relocation operation ID | adoption transaction ID only in diagnostics, not normal success copy |
| capacity, copied, verified-copy status rows | required/verified coverage, missing, extras, and check-time rows |

The domain/application class vocabulary should similarly use `adoption`,
`candidate`, `verification`, and `switch`, reserving `relocation` for the
retired historical implementation and its parked artifacts.

## 13. Parked-operation disposition

Operation `5c20c87a-c6d6-4489-8887-ae629301884f` is historical rehearsal state,
not an adoption candidate and not a source of activation authority. During
implementation:

- never resume, refresh, cancel, migrate, or auto-delete it;
- stop composing the relocation workflow/journal discovery into Settings so
  the parked record becomes inert rather than executable;
- do not interpret its inventory manifest as current verification;
- keep the WD source authoritative and default-internal; and
- do not use the Toshiba staging directory as the manually copied candidate.

Known checkpoint evidence is:

- journal stage `inventoryComplete`;
- 4,038 inventoried files, 3,458,323,348 bytes, and 4,322 metadata rows;
- zero copied/verified files and no activation;
- manifest SHA-256 beginning `216235d`;
- one legitimate later payload made the source 4,039 files and 4,323 metadata
  rows, demonstrating that the old manifest is stale;
- the operation-owned Toshiba staging directory is empty and the managed final
  destination is absent; and
- independent source evidence records 4,039 files, 3,461,590,538 bytes, with
  aggregate digest beginning `70713`.

The safest later cleanup, only after explicit approval, is:

1. quit MessageLens Development and make the old relocation code unreachable;
2. read-only revalidate exact operation ID, `inventoryComplete`, no
   copy/verification/activation, current default-internal authority, empty
   exact staging directory, and absent exact final directory;
3. inventory exact cleanup targets and stop on any extra entry or mismatch;
4. optionally preserve checksummed journal/manifest copies as diagnostic
   evidence outside runtime roots;
5. remove only the exact empty staging directory
   `.messagelens-attachment-relocation-5c20c87a-c6d6-4489-8887-ae629301884f`;
6. remove `current.json` only if it still points exactly to this operation,
   then remove only that exact operation directory below
   `.attachment_archive_relocations`;
7. remove a now-empty relocation parent only after proving it contains no
   other operation; and
8. leave the Toshiba parent, WD source archive, and qualification evidence in
   place unless each receives separate explicit deletion approval.

The qualification evidence should be retained through the simplified
rehearsal because it is useful independent source evidence. Any later removal
must target only
`qualification_evidence/attachment_archive_relocation/5c20c87a-c6d6-4489-8887-ae629301884f`
after exact inspection and explicit approval. No cleanup occurs as part of
adoption implementation or startup.

## 14. Development rehearsal plan

1. First retire all callable Settings routes to the old mover while preserving
   its parked artifacts.
2. Keep the admitted WD development archive authoritative.
3. Create a new clearly named Toshiba directory outside the old operation
   staging/final names.
4. The user manually copies the WD `attachment_archive` into that directory.
5. Launch the exact authorized `MessageLens Development` identity.
6. Choose the copied `attachment_archive` through **Use Existing Archive…**.
7. Require full candidate verification against the current WD source.
8. If WD gained payloads, require `candidateBehind`; update the manual copy and
   choose **Check Again**.
9. On `candidateComplete`, inspect totals, extras, and source/candidate paths.
10. Explicitly choose **Use This Archive** and require fresh race revalidation,
    bookmark activation, canonical resolution, and a valid writable lease.
11. Confirm WD remains byte-for-byte untouched using the independent baseline
    policy, and confirm the Toshiba candidate is active.
12. Test representative image/video/document resolution, new ingestion,
    relaunch, Toshiba disconnect/reconnect, launch while absent, and reconnect
    after launch.
13. Confirm Messages/search remain usable while Toshiba is absent and there is
    no fallback to WD.
14. Do not delete or retire WD after the rehearsal.

The development gate must continue to match exact environment, build identity,
bundle ID, product name, canonical primary root, and archive instance. The
production identity remains denied until separately reviewed and authorized.

## 15. Production workflow

The eventual production flow is:

1. Rob manually copies the production `attachment_archive` from its current
   Application Support location to an external destination.
2. Rob selects the copied archive directory in MessageLens.
3. MessageLens verifies current-source coverage and candidate structure.
4. If the candidate is behind, Rob updates the copy with the filesystem tool
   and selects **Check Again**.
5. After a complete result, Rob explicitly selects **Use This Archive**.
6. MessageLens revalidates, switches the bookmark-backed configuration,
   resolves it, and proves writable authority.
7. The original internal archive remains untouched.
8. Rob operates from the external archive for several days and exercises
   disconnect/reconnect/relaunch/ingestion behavior.
9. Any later source deletion is a separate product, design, review, and
   authorization. It is not implied by successful adoption.

No MessageLens-owned 39-GB transfer, capacity calculation, staging directory,
or copy-resume state is involved.

## 16. Complexity reduction inventory

Relative to the Phase Four checkpoint, Phase Five/Six and the development gate
added approximately 4,799 production insertions and 44 deletions under `lib/`
and `macos/` (net 4,755), plus approximately 2,621 test insertions. The largest
current production pieces are the 1,068-line relocation service, 737-line
relocation filesystem, 658-line relocation domain model, 269-line journal
store, and roughly 537 Phase Six lines added to the Settings resolver.

### Production files that can be deleted after replacement

- `application/attachment_archive_relocation_progress_monitor.dart`;
- `application/attachment_archive_relocation_journal_store.dart`;
- `infrastructure/repositories/filesystem_attachment_archive_relocation_journal_store.dart`;
- `infrastructure/repositories/darwin_exclusive_directory_finalizer.dart`;
- their generated/provider exports where no replacement uses them; and
- `macos/Runner/PrivacyInfo.xcprivacy` plus its Xcode resource entries, only
  after confirming the disk-space declaration is its sole remaining purpose.

The old relocation-named domain, service, filesystem interface/implementation,
provider, activation gate, enablement provider, and Settings action provider
should also disappear **as named**, but their small reusable portions should
first move into focused adoption/verification files. This is replacement, not
blind deletion.

### Files to reduce or adapt substantially

- `attachment_archive_relocation.dart`: replace journal/copy/progress types
  with compact candidate-result and snapshot-evidence types.
- `attachment_archive_relocation_service.dart`: retain only verification and
  switch orchestration in a smaller adoption service.
- `filesystem_attachment_archive_relocation_file_system.dart`: retain safe
  traversal/classification/hash comparison; remove preflight writes, capacity,
  copy, temp cleanup, destination coverage equality, and finalization.
- `attachment_archive_relocation_provider.dart`: replace journal discovery,
  monitor, pause, resume, cancel, and run with ephemeral checking/adoption
  state.
- `attachment_archive_relocation_activation_gate.dart`: replace manifest and
  receipt validation with verified-result/fresh-snapshot authority.
- `attachment_archive_relocation_metadata_reader.dart` and its overlay
  implementation: rename and retain grouped/paged reads.
- `attachment_archive_location_controller.dart` and location provider: retain
  narrow activation/rollback methods but rename their permit dependency.
- Settings resolver/payload/actions/coordinator/sidebar intents/dispatcher:
  collapse mover stages to checking/result/adoption actions.
- folder chooser: select the candidate archive itself and use **Choose Archive
  Copy**.
- feature-level exports and generated Riverpod files: regenerate around the
  adoption seam.

### Native and privacy removal

Remove only the `availableCapacityForImportantUsage` Dart contract,
method-channel branch, Swift method/error types, and focused native test. Keep
bookmark creation/resolution and location events. If no remaining declared API
requires the disk-space reason, remove `E174.1` and the now-empty manifest file
and project references; otherwise preserve unrelated declarations.

### Settings actions/intents removed

Remove Move, Choose Another Destination, Retry Preflight, Begin Relocation,
Pause Relocation, Resume Relocation, and Cancel Relocation. Add Use Existing,
Check Again, Choose Another Folder, Cancel Check/Review, and Use This Archive.

### Expected reduction

The target is approximately 1,500-2,000 production lines for the verifier,
ephemeral workflow, small transaction/receipt store, and Settings adoption UI.
That implies a net removal of roughly 2,700-3,300 production lines, or about
57-69% of the current Phase Five/Six production delta. Generated output may
move the exact count. Test code should also become smaller, but safety coverage
rather than a line target controls test retention.

### Documentation

Keep records 05-07 as historical evidence and mark this document as their
product-design supersession. Later implementation records and changelog text
must say MessageLens verifies/adopts an existing copy and does not copy or
move payloads.

## 17. Test strategy

### Retain unchanged

- all Phase One-Four location, availability, reconnect, read-resolution,
  generation, writable-lease, installer, reset-denial, recovery deferral, and
  raw-path authority tests;
- Settings generic rendering, accessibility, and disabled-action tests that do
  not encode mover behavior; and
- bookmark native tests unrelated to capacity.

### Adapt

- metadata grouping/paging/conflicting-evidence tests;
- traversal tests for unsafe paths, missing metadata-known files, symlinks,
  special entries, canonical unreferenced payloads, legacy `_by_id`, installer
  debris, and bounded enumeration;
- SHA tests for known hash, null hash, source mismatch, candidate mismatch,
  and hash-named extra identity;
- end-to-end disposable tests into manual-copy candidate verification,
  behind/update/check-again, explicit adoption, lease issuance, retained
  source, disconnect/reconnect/relaunch, and rollback;
- architecture tests so only the adoption service constructs/persists
  `activeArchive` and widgets cannot perform filesystem/configuration work;
- gate tests for exact development qualification and production denial; and
- Settings tests for ready, behind, invalid, unavailable, changed-before-use,
  success, and rollback states.

### Add

- candidate has all source files plus valid extras: complete;
- candidate missing one/many source files: behind with exact count/bytes and
  capped diagnostics;
- missing plus a conflicting candidate entry: invalid precedence;
- candidate root equal/nested with source: invalid;
- changed source configuration/generation/path before approval: no switch;
- added source payload with same aggregate byte total: fingerprint changes;
- same-size replaced source or candidate file with changed timestamp: no
  switch;
- changed candidate after full verification: no switch;
- ready result discarded after provider/app reconstruction;
- process failure before configuration write, after configuration write, and
  before lease validation: deterministic complete-or-rollback recovery;
- unrelated configuration during recovery: fail closed;
- previous source unavailable during rollback: pending recovery, no false
  success;
- no writes to either archive during selection, checking, behind, invalid,
  cancel, or rollback; and
- no interaction with a parked legacy relocation journal.

### Retire

- capacity calculations and native capacity decoding tests;
- staging preflight/hard-link/exclusive-rename probe tests;
- copy receipt ordering/reconciliation and journal pointer recovery tests;
- copy interruption, pause/resume, progress polling, finalization, and managed
  destination tests; and
- UI tests for copy/finalize/pause/resume/capacity/move states.

All filesystem tests use disposable temporary roots and in-memory/test overlay
databases. No production or development archive is accessed by automated
tests.

## 18. Migration from current branch implementation to simplified implementation

1. Add a supersession note to active implementation planning; retain the old
   records and parked artifacts.
2. Make the old relocation workflow unreachable from the Settings coordinator,
   dispatcher, public provider seam, and execution gate. Add an architecture
   test proving no production action can call the mover. Do not delete its
   files or read/mutate its journal in this step.
3. Introduce adoption result/snapshot models and a pure verifier contract with
   disposable tests.
4. Extract metadata reading, deterministic traversal, classification, and
   streaming hashes from relocation code into adoption-named components.
5. Implement the short source/candidate fingerprint revalidation and prove it
   runs under existing mutation coordination.
6. Replace relocation activation authority with verified-adoption authority
   and implement the small pending transaction plus startup recovery tests.
7. Adapt location-controller verified persistence/rollback names while
   preserving private construction and Phase Four lease rules.
8. Replace Settings mover states, strings, intents, and actions with the
   simplified workflow; keep the exact development-only qualification gate.
9. Run code generation and the complete Phase One-Four regression,
   architecture, adoption, Settings, native-bookmark, analyze, and full test
   suites.
10. Only after replacement tests pass, delete mover-only code, capacity native
    code, obsolete generated files/tests, and obsolete privacy declaration.
11. Verify the legacy parked operation remains byte-for-byte/inert and that no
    startup code reads or mutates it.
12. Commit/checkpoint the implementation before any manual archive copy or
    development rehearsal.
13. Execute the new development rehearsal only under separate explicit
    authorization. Parked-operation cleanup remains a later, separately
    approved task.

No step migrates a relocation journal into adoption authority.

## 19. Risks and edge cases

- **External mutation during review:** fresh source and candidate fingerprints
  deny activation and require Check Again.
- **External mutation in the final switch interval:** coordination blocks
  MessageLens writers; pre/post candidate fingerprint checks narrow the
  remaining external race. Hostile evidence-preserving mutation is out of the
  supported model and would require full rehash-at-use.
- **Long verification:** production may require hashing roughly twice the
  archive size. It is read-only and streaming but may take time. Show truthful
  files/bytes checked and support cancellation/restart, not pause/resume.
- **Candidate behind during a busy import:** expected typed outcome. The user
  updates and checks again; MessageLens never fills the gap.
- **Metadata conflicts or missing source files:** fail as source verification,
  never hide anomalous records or activate from incomplete evidence.
- **Valid unreferenced content:** include source unreferenced payloads in
  required coverage and allow independently valid candidate extras.
- **Unknown candidate entries:** fail closed with capped diagnostics; never
  auto-delete or silently bless them.
- **Case/Unicode filesystem differences:** compare canonicalized path semantics
  and reject collisions/ambiguity. Tests must include case-sensitive source
  versus case-insensitive candidate behavior.
- **Read-only candidate:** verification can explain the condition, but adoption
  is denied because future ingestion needs a writable lease.
- **Candidate disconnect:** return candidateUnavailable and retain current
  source authority. Reconnect requires Check Again.
- **Source disconnect:** return sourceUnavailable; no candidate can become
  authoritative without current-source proof.
- **Crash during switch:** the small pending transaction completes validation
  or rolls back; it never resumes copy work.
- **Rollback source unavailable:** leave explicit pending recovery and do not
  claim success or fallback.
- **Adopting from an already external source:** the same contract applies;
  deleting or “Restore Default” remains a separately verified copy/adoption
  workflow, not a pointer flip.
- **Retained-source UI after relaunch:** use a compact adoption receipt only;
  it is informational and confers no mutation/deletion authority.
- **Legacy parked journal:** it must be ignored by adoption and removed only by
  the exact separately approved cleanup procedure.
- **Privacy manifest removal:** confirm no other direct or dependency-driven
  use requires the declaration before deleting it.

## 20. Recommended implementation sequence

The first implementation step should be a safety checkpoint: disconnect the
old relocation workflow from every production/Settings action and add an
architecture test proving the mover cannot be invoked, while leaving all old
code and operation `5c20c87a-c6d6-4489-8887-ae629301884f` untouched.

Then proceed in these checkpoints:

1. adoption result and verifier contracts;
2. extracted deterministic inventory, metadata, preservation classification,
   and streaming hash implementation;
3. behind/extras/invalid tests and disposable full-verification acceptance;
4. fresh snapshot race revalidation under mutation coordination;
5. verified-adoption permit, small pending transaction, rollback, and crash
   recovery;
6. location-controller integration and Phase Four lease validation;
7. simplified Settings state/actions/terminology and exact development gate;
8. removal of mover/capacity/staging/journal code and obsolete tests;
9. full validation and a reviewable checkpoint; and
10. separately authorized manual development rehearsal, followed only later by
    separately authorized parked-operation cleanup.

The retained production core is: Phase One-Four location/availability/write
authority; grouped metadata; safe deterministic inventory; preservation
classification; streaming SHA-256 verification; explicit verified bookmark
adoption; small crash-safe configuration rollback; Settings status/action
composition; and retained-source messaging.

The retired production core is: MessageLens-owned copy, destination capacity,
staging, filesystem probes, copy receipts, relocation journal/state machine,
pause/resume, polling progress, exclusive finalization, and mover-specific UI.

**SIMPLIFIED DESIGN READY TO IMPLEMENT: YES**
