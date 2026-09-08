---
tier: project
scope: onboarding-and-archive
owner: agent-per-project
last_reviewed: 2026-09-05
source_of_truth: audit
---

# Whole-Root Replacement and Complete Erase Removal Audit

## Status

Audit complete. No production code, schema, database, archive, or user data was
changed during this work.

Baseline inspected:

- branch: `Ftr.archive-recovery`
- commit: `05652d18`
- application version: `0.2.103+121`
- audit date: 2026-09-05

This audit follows the April tester fingerprint removal completed in
`32-APRIL-TESTER-FINGERPRINT-AND-LEGACY-ADMISSION-REMOVAL-IMPLEMENTATION.md`.
The fingerprint subsystem and the whole-root replacement subsystem were
historically connected, but they are not the same thing. The former has been
removed. The latter remains in the tree and is the subject of this audit.

## Executive conclusion

The generalized whole-Application-Support-root replacement system is no longer
owned by any current product workflow. It should be removed.

In particular:

- Start Fresh is an enumerated rebuildable-store reset. It does not require or
  authorize deletion of the Application Support root.
- automatic onboarding recovery is an enumerated derived-data reset. It does
  not require whole-root replacement;
- message-data reset, historical archive operations, attachment recovery,
  archive adoption, checkpoint tooling, and database schema migration all have
  narrower, explicit mutation boundaries;
- the Complete Erase UI and dispatcher path have no current production source
  that requests them;
- `ArchiveAccessMode.completeEraseOnly` has no current production constructor;
- interrupted Complete Erase startup recovery is therefore the only remaining
  production entry into the broad eraser, and it exists to resume an obsolete
  operation rather than to serve a current product capability.

There is one compatibility exception. A manually distributed tester build may
have written `.messagelens-complete-installation-erase.json` before the current
version was installed. Removing the pending-transaction probe without a
transition would strand that state. This exception justifies a temporary,
fail-closed compatibility reader. It does **not** justify retaining automatic
whole-root deletion, replacement UUID generation, replacement marker
installation, or automatic destructive transaction resumption.

The correct end state is:

1. remove every current code path capable of deleting or replacing the complete
   MessageLens Application Support root;
2. retain only a narrowly scoped legacy transaction recognizer for a bounded
   compatibility period;
3. let that recognizer delete only the transaction file in states proven safe;
4. fail closed and direct the user to support/offline recovery for ambiguous or
   partially erased states;
5. remove the compatibility recognizer after the declared support window.

## Stop-condition result

The prompt's transaction-probe stop condition is met for an **immediate,
unconditional removal** of the pending-transaction reader:

- builds `0.2.97+115` and `0.2.99+117` contained paths capable of creating the
  transaction file;
- those builds were used in the tester-distribution stream even though there is
  no matching Git release tag;
- a tester can therefore legitimately arrive at the current build with a stale
  or interrupted transaction record.

Accordingly, this audit does not recommend deleting recognition of that file in
the first removal slice. It recommends removing all destructive resumption and
replacing the current reader with a temporary fail-closed compatibility seam.

No other stop condition was found:

- no current workflow genuinely requires whole-root replacement;
- Start Fresh does not require it;
- production checkpoint recovery does not replace a live root at runtime;
- marker identity can be separated cleanly from replacement-identity machinery;
- the removal does not require a database schema or user-data migration.

## Scope and terminology

This audit uses four distinct terms:

### Start Fresh

A user-authorized reset of explicitly enumerated rebuildable stores. It
preserves durable user intent, configuration, and attachment preservation data.

### Checkpoint

An offline, verified copy used for disaster recovery, adoption safety, or
diagnostics. Checkpoint creation and verification are not root replacement.
Restoration is allowed only into an absent disposable destination, not over the
active Application Support root.

### Archive adoption

The in-place admission of an existing unmarked production archive after exact
inventory and checkpoint verification. Adoption installs initial ownership
identity; it does not delete or replace the root.

### Whole-root replacement / Complete Erase

The obsolete transaction that recursively deletes all MessageLens-owned
Application Support contents except its lock and transaction file, creates a
new root identity, verifies virgin state, and relaunches the application.

These operations must not be conflated. In particular, the word “reset” must
never be used to widen Start Fresh into whole-root deletion.

## Current production call graph

### Whole-root replacement graph

The remaining runtime graph is:

```text
main.dart::_admitArchive
  -> FileSystemCompleteInstallationEraseStore.readPending()
  -> if transaction exists:
       create replacement ArchiveAccessAuthority(new UUID)
       -> eraseOwnedState()
       -> installVirginIdentity()
       -> CompleteInstallationEraseVirginVerifier.verify()
       -> complete() [delete transaction]
       -> continue ordinary admission
```

A second graph remains structurally present but is unreachable in current
production construction:

```text
StartupApp
  -> authority.mode == ArchiveAccessMode.completeEraseOnly
  -> _EraseOnlyStartup
  -> CompleteInstallationEraseAuthorizationDialog
  -> CompleteInstallationEraseService.eraseAndRelaunch()
```

`ArchiveAccessMode.completeEraseOnly` is exercised by tests but has no current
production constructor. `_EraseOnlyStartup` is therefore dead product code.

A third graph remains in presentation/dispatch code but has no current producer:

```text
SidebarActionIntent.CompleteInstallationEraseRequested
  -> SidebarActionDispatcher
  -> CompleteInstallationEraseAction.request()
  -> CompleteInstallationEraseService.eraseAndRelaunch()
```

No production code constructs `CompleteInstallationEraseRequested`. Current
Settings architecture tests explicitly protect the absence of that action from
the visible reset surface.

### Start Fresh graph

```text
StartFreshService
  -> verify eligibility
  -> ArchiveMutationOperation.startFresh
  -> reset source/import ledgers and supersede active scheduling state
  -> MessageDataResetService.resetDerivedDataForStartFresh()
  -> classify archive evidence
  -> require the expected virgin onboarding state
  -> refresh providers/UI
```

`MessageDataResetService` removes the enumerated source-scoped import and
conversation-graph stores and cleans retired derived stores. It preserves the
overlay database, preferences, and `attachment_archive/`. It never deletes the
Application Support root.

### Automatic onboarding recovery graph

```text
OnboardingJourneyCoordinator._runAutomaticRecovery()
  -> ArchiveMutationOperation.automaticRecovery
  -> MessageDataResetService.resetDerivedData()
  -> re-read and classify archive evidence
```

The Settings reimport path uses the same scoped reset service. Neither path
calls the Complete Erase store or service.

## Workflow ownership matrix

| Workflow | Actual mutation boundary | Whole-root replacement needed? | Audit result |
| --- | --- | --- | --- |
| Start Fresh | Enumerated rebuildable graph/import stores and ledgers | No | Keep scoped reset; prohibit widening |
| Automatic onboarding recovery | Enumerated derived stores | No | Keep scoped recovery |
| Message Data Reset | Active derived stores plus specifically named retired cleanup files | No | Keep explicit inventory |
| Archive adoption | Verified in-place marker creation with rollback limited to the unchanged marker | No | Keep |
| Historical archive import | Source-scoped import/projection state | No | Keep |
| Historical archive removal | Selected historical source state | No | Keep |
| Attachment recovery | Individual verified payloads and recovery metadata | No | Keep |
| Checkpoint creation | Read-only copy and verification | No | Keep |
| Checkpoint verification | Read-only hashes, inventory, marker, and SQLite health | No | Keep |
| Offline checkpoint restore | Absent disposable destination only | No | Keep; retain overwrite refusal |
| Support diagnostics | Read-only inspection and explicit scoped tools | No | Keep |
| Production initialization | Ownership admission and ordinary store opening | No | Keep |
| Development initialization | Explicit development archive root and ordinary admission | No | Keep |
| Virgin startup | Evidence classification and onboarding | No | Keep |
| Database schema migration | Per-database Drift migration | No | Keep |
| CLI checkpoint recovery | Offline/disposable destination | No | Keep |
| CLI production adoption | Verified in-place marker adoption | No | Keep |
| Interrupted Complete Erase | Recursive root deletion plus replacement identity | Yes, by definition | Obsolete operation; remove destructive resumption |

## Complete component inventory

| Component | Original consumer | Current callers | Current product purpose | Recommendation |
| --- | --- | --- | --- | --- |
| `CompleteInstallationEraseStore` | Generalized Complete Erase and April tester cleanup | Complete Erase service, `main.dart` pending recovery, tests | Defines transaction, broad erase, replacement identity, and completion contract | **REMOVE** as a broad-erasure interface; extract only a temporary legacy transaction reader |
| `FileSystemCompleteInstallationEraseStore` | Complete Erase runtime implementation | Complete Erase provider, `main.dart`, tests | Recursively deletes the root and installs a replacement marker | **REMOVE** broad deletion and replacement behavior; retain no recursive delete implementation |
| `CompleteInstallationEraseTransaction` | Crash-safe Complete Erase resumption | Store, `main.dart`, tests | Recognizes a possibly distributed stale transaction | **KEEP BUT REHOME**, temporarily, as a read-only legacy compatibility record |
| `.messagelens-complete-installation-erase.json` | Durable destructive transaction journal | `readPending()` and transaction completion | Compatibility evidence from old tester builds | **KEEP BUT REHOME** handling; delete only the file in proven-safe states |
| `CompleteInstallationEraseService` | Execute erase, install virgin identity, relaunch | Action/provider and `_EraseOnlyStartup` | No current supported product capability | **REMOVE** |
| Complete Erase service provider and generated provider | Dependency wiring | Action and startup branch | Wires obsolete destructive service | **REMOVE** |
| `CompleteInstallationEraseAction` and provider | Visible Settings/sidebar action | Dispatcher branch; no current intent producer | Dead user-facing operation | **REMOVE** |
| `CompleteInstallationEraseAuthorizationDialog` | Destructive confirmation | Action and `_EraseOnlyStartup` | UI for obsolete operation | **REMOVE** |
| `CompleteInstallationEraseOverlay` / host | Show progress above app shell | Mounted by `MacosAppShell` | Dead UI host with no current operation | **REMOVE** |
| `CompleteInstallationErasePresentation` | Progress/error state | Service/action/overlay | State model for obsolete operation | **REMOVE** |
| `SidebarActionIntent.CompleteInstallationEraseRequested` | Settings action dispatch | Dispatcher only; no constructor | Dead intent type | **REMOVE** |
| Complete Erase dispatcher branch | Route Settings action | No current producer | Dead dispatch branch | **REMOVE** |
| `ArchiveAccessMode.completeEraseOnly` | Admit archive solely to erase it | startup/store/coordinator branches and tests; no production constructor | None | **REMOVE** |
| `_EraseOnlyStartup` | Restricted startup after special admission | Unreachable branch in `StartupApp` | None | **REMOVE** |
| `ArchiveMutationOperation.completeInstallationErase` | Serialize destructive mutation | Complete Erase service and tests | None after service removal | **REMOVE** |
| Complete-Erase-only coordinator capability branch | Permit only Complete Erase in restricted mode | Coordinator and tests | None after access-mode removal | **REMOVE** |
| Replacement UUID generation in Complete Erase | Give erased root a new identity | Complete Erase service | None after broad replacement removal | **REMOVE** |
| `installVirginIdentity()` | Install replacement marker after deletion | service and `main.dart` recovery | None after destructive resumption removal | **REMOVE** |
| `CompleteInstallationEraseVirginVerifier` | Verify replacement created an empty owned root | service, `main.dart`, tests | Thin operation-specific wrapper | **REMOVE**; retain generic evidence reader/classifier |
| `ApplicationRelauncher.relaunchAfterArchiveReplacement()` | Relaunch after root replacement | Complete Erase provider only | None after service removal | **REMOVE** |
| `MacosApplicationRelauncher` | macOS implementation of replacement relaunch | Complete Erase provider only | None after service removal | **REMOVE** |
| Native `relaunchAfterArchiveReplacement` channel handler | Relaunch packaged or development app after erase | Dart relaunch adapter only | None after service removal | **REMOVE** |
| Complete Erase feature-level exports | Public access to action/service/presentation | Import consumers and tests | Obsolete public surface | **REMOVE** |
| Archive ownership marker and UUID | Initial identity and current-root validation | admission, adoption, checkpoint, evidence classification | Permanent archive identity | **KEEP** |
| Generic archive evidence reader/classifier | Admission, onboarding, reset validation, diagnostics | Multiple current workflows | Permanent classification seam | **KEEP** |
| Archive root safety policy | Validate canonical roots and reject unsafe targets | Archive/checkpoint/adoption code where directly used | General safety invariant independent of erase | **KEEP**, but remove erase-only call sites |
| Start Fresh/reset store inventory | Scoped rebuildable-data removal | current onboarding and settings flows | Supported recovery model | **KEEP** |
| Checkpoint service and CLI | Offline verified recovery | current tooling/tests | Supported offline recovery | **KEEP** |

## Start Fresh must remain enumerated

The current distinction is architecturally sound and must become an explicit
tripwire:

- Start Fresh may remove only stores named by the reset service;
- the source-scoped import and conversation graph databases are rebuildable;
- retired `macos_import.db` and `working.db` are explicit cleanup artifacts, not
  authority-bearing stores;
- the overlay database contains durable user intent and is preserved;
- preferences/configuration are preserved unless a separately named operation
  owns a specific key;
- `attachment_archive/` is preservation data and is never reset;
- the Application Support root and its ownership marker are preserved.

Any future need to reset another artifact must add that artifact to an explicit
inventory with a preservation analysis. It must not introduce a generic root
eraser.

## Checkpoints are not runtime root replacement

The checkpoint subsystem has three independently useful responsibilities:

1. **creation** — copy an admitted archive while recording exact evidence;
2. **verification** — validate marker identity, inventory, hashes, and SQLite
   health;
3. **offline restore** — materialize a verified checkpoint into an absent,
   disposable destination.

The filesystem implementation refuses to restore over an existing archive. If
restore validation fails, it removes only the new disposable restore root that
the operation itself created. The CLI makes the offline/disposable restriction
explicit and does not launch MessageLens.

These are safe, current capabilities. They neither need nor authorize a runtime
primitive that removes the active Application Support root.

## Marker and UUID ownership

The archive marker and UUID remain permanent. They are needed for:

- first ownership claim on a genuinely virgin root;
- verified adoption of an existing unmarked archive;
- current-root identity validation;
- checkpoint identity and inventory verification;
- refusal when a root belongs to another environment or identity.

What should be removed is specifically the **replacement** identity machinery:

- generating a new UUID as part of Complete Erase;
- persisting that UUID in a destructive transaction;
- installing a new marker after recursive deletion;
- constructing temporary authority from the replacement UUID to continue the
  erase.

Initial identity and verified in-place adoption are not replacement. Their
marker creation paths must remain.

## Pending transaction compatibility

### Current behavior

`main.dart::_admitArchive` treats any readable pending Complete Erase
transaction as authority to continue the destructive operation automatically.
It creates authority from `newArchiveUuid`, erases the root, installs a virgin
marker, verifies the virgin state, deletes the transaction, and then resumes
ordinary admission.

That behavior is no longer acceptable. A stale journal is evidence that an old
operation may have started; it is not present-day authorization to delete the
root.

### Could a released build have created it?

Yes. The transaction implementation appeared in the manually distributed
tester line. Git tags do not fully describe that distribution history. A user
could have initiated the generalized erase in `0.2.97+115`, or the legacy tester
cleanup path in `0.2.99+117`, and then installed a newer build before the
transaction was completed or removed.

### Temporary compatibility behavior

Replace the current store/service dependency in startup admission with a small,
read-only legacy transaction recognizer. It may inspect:

- whether the transaction file exists and parses;
- whether its recorded environment matches the active environment;
- whether a current marker exists;
- whether the marker UUID equals `newArchiveUuid`;
- the generic archive evidence classification and integrity result.

It must not expose recursive deletion or marker installation.

Safe handling matrix:

| Observed state | Allowed behavior |
| --- | --- |
| Transaction parses; environment matches; current marker UUID differs from `newArchiveUuid`; ordinary current archive admission and integrity succeed | Treat as pre-erase stale journal; delete only the transaction file; continue ordinary admission |
| Transaction parses; environment matches; current marker UUID equals `newArchiveUuid`; generic evidence proves a valid virgin owned root | Treat as post-install stale journal; delete only the transaction file; continue virgin onboarding |
| No transaction | Continue ordinary admission |
| Malformed transaction | Fail closed; do not delete root or transaction automatically; provide diagnostic/support guidance |
| Environment mismatch | Fail closed |
| Marker missing | Fail closed; this may be a partially erased legacy state |
| Marker UUID equals replacement UUID but archive is not proven virgin | Fail closed |
| Marker differs and ordinary admission/integrity fails | Fail closed |
| Unexpected files, partial databases, symlinks, identity ambiguity, or any unclassified evidence | Fail closed |

The current transaction record does not contain the old marker UUID. Therefore
the safe pre-erase cleanup case cannot prove old identity by journal comparison;
it must instead require successful ordinary admission and integrity of the
current archive before deleting only the stale journal.

The recognizer should emit a structured diagnostic when it encounters any
nontrivial state. Ambiguous cases belong to explicit offline recovery or support,
not an automatic destructive startup path.

### Compatibility sunset

The recognizer should carry:

- a clearly named legacy type and filename constant;
- a removal issue or dated release criterion;
- metrics/logging sufficient to establish whether the legacy file is still
  encountered;
- no dependency on Complete Erase UI, service, mutation operation, or access
  mode.

After the declared compatibility window, remove the recognizer and retain only
a non-destructive diagnostic for an unexpected obsolete file if ongoing support
policy calls for it.

## Complete Erase product remnants

The following remnants do not represent a hidden current feature:

- `ArchiveAccessMode.completeEraseOnly` has no production constructor;
- `_EraseOnlyStartup` is guarded by that unconstructed mode;
- `CompleteInstallationEraseRequested` has no production producer;
- the overlay host remains mounted but has no live current operation to show;
- the dispatcher and action remain reachable only if dead intent construction
  is reintroduced;
- the service is reached today through pending-transaction startup recovery,
  not a supported user command.

These components should be removed together so the obsolete capability cannot
be accidentally reactivated by a future UI or admission change.

## Relaunch audit

`ApplicationRelauncher` and `MacosApplicationRelauncher` exist solely for
`relaunchAfterArchiveReplacement()`. The native macOS method-channel handler has
the same single purpose.

The native implementation contains a useful historical correction:

- packaged production relaunch uses LaunchServices via `open -n`;
- development relaunch invokes the current executable directly and preserves
  `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`, avoiding LaunchServices opening an
  unrelated installed production app.

That correction is valid but has no independent current caller. It should be
removed with the replacement feature rather than retained as unused native
surface. If MessageLens later needs a general relaunch capability, it should be
introduced under a purpose-neutral API with its own current consumer and tests;
the obsolete archive-replacement API should not be repurposed speculatively.

## Safe whole-root deletion primitive

The filesystem eraser contains substantial defensive checks: it rejects `/`,
`/Volumes`, the home directory, a symlink root, symlink descendants, source
`chat.db`, and nested archive markers. Those checks reduce the blast radius of
an inherently broad operation, but they do not create a current product owner.

There should be no reusable production primitive capable of recursively deleting
the active MessageLens Application Support root. Safety checks for canonical
root resolution may remain where checkpoint, adoption, or admission code uses
them. The recursive deletion loop and erase-specific exemptions must be removed.

Offline support tooling should continue to use absent disposable destinations
and exact inventories. It should not inherit or preserve a dormant runtime root
eraser “just in case.”

## Virgin verifier

`CompleteInstallationEraseVirginVerifier` is an operation-specific wrapper. Its
only purpose is to assert that Complete Erase produced a virgin root. It has no
independent product responsibility after broad replacement is removed.

Remove the wrapper and its tests. Keep the generic evidence reader and archive
state classifier used by normal onboarding, Start Fresh validation, diagnostics,
and the temporary legacy transaction recognizer.

## Tests and architecture tripwires

### Remove with the dead feature

- Complete Erase service tests;
- Complete Erase filesystem-store tests;
- Complete Erase authorization-dialog tests;
- Complete Erase operation-surface/overlay tests;
- Complete Erase virgin-verifier tests;
- Complete Erase-specific coordinator capability cases;
- Complete Erase-specific generated-provider expectations;
- native relaunch tests that exist only for archive replacement.

### Retain

- Start Fresh service and authorization tests;
- `onboarding_start_fresh_architecture_test.dart` boundaries;
- virgin onboarding boundary tests;
- checkpoint create/verify/offline-restore tests;
- production adoption tests;
- historical archive import/removal graph-admission tests;
- attachment archive preservation and attachment recovery tests;
- archive admission and marker identity tests;
- per-store migration tests;
- the Settings resolver assertion that Complete Erase is not exposed.

### Rewrite or strengthen

`complete_installation_erase_boundary_test.dart` currently proves that Complete
Erase is distinct from Start Fresh and inventories the eraser implementation.
After removal, replace it with a negative architecture tripwire that proves:

- production code contains no recursive active-root erase interface;
- Start Fresh does not import a whole-root store/service;
- no `completeEraseOnly` admission mode exists;
- no Complete Erase sidebar intent or operation is constructible;
- `attachment_archive/` remains outside every reset inventory;
- checkpoint restore refuses an existing destination;
- the temporary legacy transaction recognizer has no broad deletion or marker
  installation dependency.

Add focused compatibility tests for every row of the pending-transaction safe
handling matrix. In particular, prove that missing markers, malformed journals,
integrity failures, partial roots, and unexpected evidence never cause root
deletion or replacement marker creation.

## Documentation disposition

Current source-of-truth documentation should be updated in the removal change:

- remove claims that generalized whole-installation erase is a supported
  advanced recovery operation;
- describe Start Fresh exclusively as an enumerated rebuildable-store reset;
- remove Complete Erase exceptions from current attachment-preservation rules;
- document the temporary legacy transaction recognizer and its sunset criterion;
- document offline checkpoint restore as absent-destination-only;
- document the permanent marker/adoption/migration model below.

Historical implementation responses and audits may remain as historical records.
They should not be rewritten to imply that the old design never existed. Where
the documentation index makes a historical document look current, label or
relocate the index entry rather than editing the historical record's substance.

## Proposed permanent mutation model

The long-term model has four layers:

### 1. Root ownership

- a genuinely virgin root receives its first ownership marker and UUID;
- a verified existing unmarked archive may be adopted in place;
- an owned root must validate against its existing marker;
- identity mismatch or ambiguous evidence fails closed.

### 2. Store lifecycle

- each active database owns its schema version and migrations;
- migrations occur in place at the store boundary;
- retired stores are removed only by explicit filename inventory;
- no store upgrade delegates to root replacement.

### 3. Recovery

- Start Fresh and automatic recovery delete only enumerated rebuildable stores;
- overlay/user-intent data remains independent;
- attachment preservation data is inviolate;
- checkpoint restore targets an absent disposable root;
- adoption is verified and in place;
- ambiguous production roots require explicit offline recovery or support.

### 4. Mutation coordination

- every supported mutation has a named `ArchiveMutationOperation`;
- coordinator capabilities correspond only to current operations;
- broad filesystem authority is not granted through a special “erase-only”
  admission mode;
- transaction journals authorize resumption only of current, bounded operations;
- obsolete journals are compatibility evidence, never fresh destructive
  authorization.

## Recommended verdict

**REMOVE** the generalized whole-root replacement capability.

**KEEP** the archive marker/UUID identity system, verified initial/adoption
claims, generic evidence classification, explicit per-store migrations, scoped
Start Fresh/reset, checkpoint tooling, historical archive operations, and
attachment recovery/preservation.

**KEEP BUT REHOME TEMPORARILY** only the legacy pending-transaction parser and
single-file cleanup logic required to recognize tester state without resuming
destruction.

## Exact bounded implementation slice

This is the recommended implementation sequence. It is intentionally split so
the stale-transaction compatibility boundary is installed before destructive
resumption is removed.

### Slice 1 — compatibility seam

1. Add a narrowly named legacy Complete Erase transaction reader outside the
   active archive-mutation store abstraction.
2. Implement the safe handling matrix above using ordinary admission, marker
   validation, generic evidence classification, and integrity checks.
3. Permit deletion of only
   `.messagelens-complete-installation-erase.json`, and only in the two proven
   safe states.
4. Add structured diagnostics and fail-closed UI/support guidance for every
   ambiguous state.
5. Add compatibility tests proving the recognizer cannot delete any other file
   or install/change a marker.

### Slice 2 — remove destructive runtime capability

1. Replace `main.dart` automatic Complete Erase resumption with the compatibility
   recognizer.
2. Remove `CompleteInstallationEraseStore` and its filesystem implementation.
3. Remove the Complete Erase service, action, providers, generated providers,
   presentation model, dialog, overlay, and app-shell host.
4. Remove `ArchiveAccessMode.completeEraseOnly` and `_EraseOnlyStartup`.
5. Remove `ArchiveMutationOperation.completeInstallationErase` and coordinator
   special cases.
6. Remove the sidebar intent and dispatcher branch.
7. Remove replacement UUID generation and replacement marker installation.
8. Remove the operation-specific virgin verifier.
9. Remove the Dart and native archive-replacement relaunch surfaces.
10. Remove obsolete feature-level exports.

### Slice 3 — tests and documentation

1. Remove tests that exist only to validate the dead capability.
2. Convert the boundary test into negative broad-deletion tripwires.
3. Retain and run Start Fresh, virgin onboarding, checkpoint, adoption,
   historical archive, attachment preservation/recovery, admission, and schema
   migration suites.
4. Update current architecture and onboarding documentation.
5. Add the compatibility seam's explicit sunset criterion to the release plan.

### Slice 4 — compatibility sunset

After the declared tester-support window:

1. remove the legacy transaction parser and cleanup path;
2. decide whether an unexpected obsolete filename remains a diagnostic-only
   startup refusal or is handled solely through support tooling;
3. retain the negative no-whole-root-deletion architecture tripwires.

No database schema migration, archive rewrite, attachment move, or user-data
conversion is part of these slices.

## Verification required for the implementation

The implementation change should run, at minimum:

- `dart format` on changed Dart files;
- `flutter analyze`;
- focused legacy transaction compatibility tests;
- Start Fresh and message-data-reset tests;
- archive admission, marker, checkpoint, and adoption tests;
- attachment archive preservation and recovery tests;
- historical archive import/removal tests;
- architecture tripwires for forbidden whole-root deletion;
- the full Flutter test suite before release;
- a production macOS build under the existing bundle identifier and signing
  requirements.

Manual scenarios should include ordinary owned startup, virgin startup,
development archive startup, a safe stale pre-erase journal, a safe stale
post-install journal, malformed journal, missing marker/partial legacy state,
and a current archive with failed integrity.

## Audit evidence index

Primary implementation areas inspected:

- `lib/main.dart`
- `lib/essentials/archive_environment/application/`
- `lib/essentials/archive_environment/domain/`
- `lib/essentials/archive_environment/infrastructure/`
- `lib/essentials/onboarding/application/`
- `lib/essentials/onboarding/domain/`
- `lib/essentials/onboarding/infrastructure/system/`
- `lib/essentials/onboarding/presentation/`
- `lib/essentials/navigation/presentation/view/macos_app_shell.dart`
- `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`
- `lib/essentials/sidebar/domain/sidebar_action_intent.dart`
- `macos/Runner/MainFlutterWindow.swift`
- checkpoint, adoption, reset, historical archive, attachment recovery,
  onboarding, architecture, and Complete Erase tests under `test/`
- current onboarding, archive, database, attachment-preservation, build, and
  release documentation
- Git history introducing the replacement transaction and its tester cleanup
  consumer

## Worktree safety note

The worktree was already dirty before this audit. Existing modified and
untracked files were treated as user-owned and were not altered. This audit
adds only this document. No implementation work has been authorized or
performed by this audit.
