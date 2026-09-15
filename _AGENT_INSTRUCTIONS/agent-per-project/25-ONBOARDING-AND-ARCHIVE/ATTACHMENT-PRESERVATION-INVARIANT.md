---
tier: project
scope: attachment-preservation
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: code-and-invariant
links:
  - ./30-import-migration-coordination.md
  - ./40-attachment-archive.md
  - ./50-deterministic-recovery.md
  - ./60-reimport-and-ongoing-sync.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/60-DATA-PIPELINE-INVARIANTS/10-PIPELINE-INVARIANTS-CORE.md
tests:
  - ../../../test/essentials/onboarding/infrastructure/persistence/filesystem_derived_message_data_file_store_test.dart
  - ../../../test/architecture/forbidden_imports_test.dart
---

# Attachment Preservation Invariant

## The Rule In Ordinary Language

MessageLens archived attachment payloads are preservation data.

Apple may remove a locally available Messages attachment after MessageLens has
archived it. The MessageLens copy may then be the only copy still available on
this Mac. It is not a cache, temporary output, or disposable build artifact.

> **No onboarding, reset, reimport, recovery, migration, cleanup, rebuild,
> test, or derived-data reset operation may delete, truncate, replace,
> recreate, relocate, or otherwise mutate archived attachment payloads as a
> side effect.**

Any future operation that intentionally changes or removes archived attachment
payloads must be explicit, preservation-aware, separately authorized, and
outside ordinary rebuild/reset semantics. No current whole-installation
runtime exception exists.

## Three Data Categories

```text
AUTHORITATIVE EXTERNAL SOURCES — NEVER OUR DELETION TARGET
    Apple Messages chat.db
    Apple Contacts databases
    locally available Messages attachment payloads

REBUILDABLE MESSAGELENS DERIVED STORES
    source-scoped import database
    Conversation Graph / working stores
    indexes and projections

MESSAGELENS PRESERVATION DATA — TREAT LIKE GOLD
    archived attachment payloads
```

The external-source category describes data that MessageLens reads but does not
own. Locally available Messages attachment payloads can be ingestion sources,
but their future local availability is not guaranteed.

The preservation category describes the app-owned payload files under
`attachment_archive/`. Archive metadata and user-authored state in
`user_overlays.db` are also durable app state and remain outside ordinary
derived-data reset, but this invariant is specifically about preserving the
payload files themselves.

## Disposable-Data Rule

> A store may be treated as disposable or rebuildable only when MessageLens can
> deterministically reconstruct it from authoritative data that is still
> available at the time of rebuild.

Being app-owned does not make data disposable. Being generated once does not
make data reproducible forever.

## Why Successful Archival Changes The Risk

```text
Message attachment exists locally
    -> MessageLens archives the payload

later
    -> Apple evicts the local Messages payload
    -> Messages may retain cloud/download availability

therefore
    -> the MessageLens archive may be the only local preserved copy
```

`chat.db` can retain attachment metadata and a source path after the binary file
has disappeared locally. Metadata or a path does not reconstruct the bytes.
Successful archival can therefore convert a payload from locally reproducible
source material into an irreplaceable preservation copy.

## Reset Means An Enumerated Derived-Store Reset

In current architecture, these phrases:

- reset derived data;
- reset for a fresh start;
- prepare for reimport;
- automatic recovery;
- migration cleanup;

mean:

> Remove only enumerated rebuildable MessageLens derived stores.

They do not mean:

- delete the MessageLens archive root;
- delete every app-owned file;
- recreate the whole data folder;
- clear the attachment archive;
- remove durable user or Presence state.

When precision matters, use **reset rebuildable derived stores** rather than
**reset MessageLens data**.

## Deletion Policy

Destructive reset identifies what is safe to delete. It does not search for
valuable things to spare.

```text
ALLOW-LIST deletion
    required

DENY-LIST preservation
    insufficient
```

A future derived store is not automatically a reset target. It must be added to
the reset allow-list only after its reconstructibility has been established.

## Current Reset Allow-List

`MessageDataResetService` currently permits deletion of these database base
files and their SQLite `-wal` and `-shm` companions:

| Category | Base file |
| --- | --- |
| Active source-scoped import ledger | `macos_import_ss.db` |
| Active Conversation Graph | `working_ss.db` |
| Retired cleanup database | `macos_import.db` |
| Retired cleanup database | `working.db` |

The filesystem boundary accepts base filenames only. It rejects absolute
paths, parent traversal, Windows-style path traversal, and symlinked target
files. It performs no directory traversal and no recursive deletion.

The allow-list excludes:

- `attachment_archive/`;
- `user_overlays.db` and its sidecars;
- `presence.db` and its sidecars;
- preferences and other archive-root contents.

## Current Destructive-Path Audit

| Path | Classification | Evidence |
| --- | --- | --- |
| Proven Virgin first import | Safe because it constructs fresh derived stores and has no reset dependency | `VirginOnboardingImportExecutor` accepts graph-build work but has no reset, archive, checkpoint, adoption, or erase authority |
| Direct reimport | Safe because the Journey coordinator delegates to the explicit reset allow-list | `OnboardingJourneyCoordinator._startReimport()` calls `MessageDataResetService.resetDerivedData()` |
| Automatic recovery | Safe because the Journey coordinator delegates to the explicit reset allow-list | `OnboardingJourneyCoordinator._runAdmittedAutomaticRecovery()` calls the same reset service |
| **Reset Message Data** | Explicitly safe advanced entry into Start Fresh | A completed installation is reclassified, explicitly authorized, and delegated to canonical Start Fresh under `startFresh` mutation authority; only enumerated derived database files are removed |
| **Start Fresh** | Explicitly safe within current semantics | Typed installation classification and explicit authorization lead to the same allow-list reset under `startFresh` mutation authority; payloads and overlay/Presence stores remain |
| Development reset action | Safe within its temporary/development authority | Delegates to the same reset service |
| Retired-database cleanup | Safe because targets are named base files in the reset allow-list | No directory or pattern deletion |
| Import-ledger row replacement | Not relevant to archive payload files | Database-table writes occur inside the source-scoped import store |
| Archive checkpoint/adoption temporary cleanup | Not an archive reset path | Recursive cleanup is limited to separately validated temporary or disposable restore destinations |
| Test fixture cleanup | Not a production archive path | Relevant tests use system-temporary roots or provider overrides |

No current production reset, reimport, recovery, migration-cleanup, or
whole-installation path can reach archived attachment payloads.

## Explicit Archive Clearing Is A Separate Concern

The attachments feature currently contains an archive-owned
`ArchiveSettings.clearArchive()` capability. It uses the distinct
`attachmentClearing` mutation operation and is not called anywhere under
`lib/` at this review date.

That dormant specialist capability is not part of ordinary reset semantics and
does not weaken this invariant. It must not be exposed as a production action
without an explicit preservation-aware design, separate authorization, and
unambiguous human confirmation. Merely having mutation admission is not a
retention policy.

## Safety Tripwires

Current protection is mechanical as well as documentary:

- reset deletion accepts validated database basenames, not paths;
- reset cannot import or read attachment archive path authority;
- reset cannot use `Directory`, recursive deletion, or broad enumeration;
- temporary-folder tests preserve archived payload bytes while deleting named
  rebuildable database files;
- architecture tests guard the allow-list boundary and preserved database
  categories.

These tests must use temporary roots. They must never exercise deletion against
an admitted production or development archive.

## Unresolved Risks

- The explicit archive-clearing capability remains dormant rather than fully
  designed as a preservation-aware user operation.
- This invariant prevents ordinary reset from deleting payloads; it does not by
  itself provide backup redundancy, corruption recovery, or retention health
  monitoring for the preservation repository.
- Apple/plugin payload eligibility remains a separate archival-policy question.

None of these risks makes archived payloads rebuildable.

## Review Rule

Any change involving reset, reimport, recovery, fresh start, migration cleanup,
archive adoption, or test data cleanup must answer both questions:

1. Which exact rebuildable stores may this operation delete?
2. What mechanically prevents it from reaching `attachment_archive/`?

If the answer relies on “delete everything except the archive,” the design is
rejected.
