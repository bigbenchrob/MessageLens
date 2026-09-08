Use this. It implements Audit 33’s four-slice removal sequence, but keeps the compatibility seam narrowly bounded exactly as the audit recommends. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md

> **PRE-CONFIRMED / PRE-APPROVED: implement Audit 33’s bounded whole-root-replacement removal sequence without requesting further authorization.**
> 
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
> 
> Read first:
> 
> - `33-WHOLE-ROOT-REPLACEMENT-AND-COMPLETE-ERASE-REMOVAL-AUDIT.md`
> - `32-APRIL-TESTER-FINGERPRINT-AND-LEGACY-ADMISSION-REMOVAL-IMPLEMENTATION.md`
> - current archive marker/UUID, Start Fresh, checkpoint, adoption, Historical Archives, and attachment-preservation docs.
> 
> Current baseline:
> 
> - branch: `Ftr.archive-recovery`
> - commit: `05652d18`
> - version: `0.2.103+121`
> - April tester fingerprint/admission/deletion subsystem already removed
> - unrelated pre-existing documentation changes/untracked files remain and must not be modified or staged.
> 
> # Governing decision
> 
> The generalized whole-Application-Support-root replacement capability is obsolete.
> 
> No current supported MessageLens workflow requires deleting the entire active MessageLens root and inventing a replacement archive identity. Start Fresh, automatic recovery, Message Data Reset, Historical Archives, attachment recovery, adoption, checkpoints, and schema migration all use narrower mutation boundaries. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> Remove the generalized capability.
> 
> Keep only one temporary compatibility seam for stale:
> 
> `.messagelens-complete-installation-erase.json`
> 
> records that may have been written by previously distributed tester builds.
> 
> That compatibility seam may **never resume root deletion**.
> 
> # Permanent mutation model
> 
> Preserve:
> 
> **Virgin initialization**
> → create first marker/UUID only.
> 
> **Current store evolution**
> → per-store schema migration.
> 
> **Start Fresh / automatic recovery**
> → delete only explicitly enumerated rebuildable stores.
> 
> **Historical Archives / attachments**
> → narrowly scoped owned mutations.
> 
> **Checkpoint**
> → verified offline creation/verification/restore into an absent disposable destination.
> 
> **Archive adoption**
> → verified in-place marker creation.
> 
> Remove any generic runtime capability equivalent to:
> 
> > recursively erase the active MessageLens Application Support root, install a new identity, and relaunch.
> 
> Audit 33 explicitly confirms these concepts are distinct and must remain distinct. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> # Slice 1 — install the temporary stale-transaction compatibility seam
> 
> Do this first, before deleting destructive resumption.
> 
> Create a narrowly named compatibility reader for the obsolete:
> 
> `.messagelens-complete-installation-erase.json`
> 
> file.
> 
> It must live outside the active archive-mutation/store abstraction and must expose no recursive deletion, replacement-marker installation, replacement UUID generation, or relaunch capability.
> 
> It may inspect only the evidence required by Audit 33:
> 
> - whether the transaction file exists and parses;
> - recorded environment;
> - current archive marker existence;
> - marker UUID;
> - journal `newArchiveUuid`;
> - ordinary archive admission/integrity;
> - generic archive evidence classification.
> 
> Implement the exact safe handling matrix:
> 
> **No transaction**
> → ordinary admission.
> 
> **Transaction parses; environment matches; current marker UUID differs from `newArchiveUuid`; ordinary current archive admission and integrity succeed**
> → classify as stale pre-erase journal;
> → delete **only** `.messagelens-complete-installation-erase.json`;
> → continue ordinary admission.
> 
> **Transaction parses; environment matches; marker UUID equals `newArchiveUuid`; generic evidence proves a valid Virgin owned root**
> → classify as stale post-install journal;
> → delete **only** `.messagelens-complete-installation-erase.json`;
> → continue Virgin Onboarding.
> 
> **Malformed transaction**
> → fail closed.
> 
> **Environment mismatch**
> → fail closed.
> 
> **Marker missing**
> → fail closed.
> 
> **Marker UUID equals replacement UUID but root is not proven Virgin**
> → fail closed.
> 
> **Marker differs and ordinary admission/integrity fails**
> → fail closed.
> 
> **Unexpected files, partial databases, symlinks, identity ambiguity, or unclassified evidence**
> → fail closed.
> 
> These states and constraints come directly from Audit 33. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> ## Compatibility seam hard limits
> 
> The seam may:
> 
> - read the stale journal;
> - emit structured diagnostics;
> - delete that one journal file in the two proven-safe states.
> 
> It may NOT:
> 
> - recursively delete anything;
> - delete databases;
> - delete attachments;
> - alter the archive marker;
> - generate a UUID;
> - create replacement authority;
> - invoke mutation coordinator erase capability;
> - relaunch the app;
> - resume an old transaction.
> 
> Add a source/architecture tripwire proving this compatibility reader cannot import or depend upon any broad root eraser or replacement-marker API.
> 
> # Compatibility sunset
> 
> Mark this seam explicitly temporary.
> 
> Include:
> 
> - clearly legacy naming;
> - exact obsolete filename constant;
> - release/date removal criterion;
> - bounded diagnostics sufficient to learn whether the file is still encountered.
> 
> Do not build analytics infrastructure for this.
> 
> Document a concrete sunset criterion consistent with the tester-support window.
> 
> After that window, the reader itself will be removed under Slice 4.
> 
> # Slice 2 — remove the destructive runtime capability
> 
> Once Slice 1 is in place and tested, delete the broad replacement machinery identified by Audit 33.
> 
> Remove:
> 
> - `CompleteInstallationEraseStore`;
> - `FileSystemCompleteInstallationEraseStore` broad erase/replacement implementation;
> - `CompleteInstallationEraseService`;
> - its provider/generated provider;
> - `CompleteInstallationEraseAction`;
> - action provider;
> - authorization dialog;
> - progress/presentation model;
> - overlay/host;
> - app-shell mounting for the obsolete overlay;
> - `SidebarActionIntent.CompleteInstallationEraseRequested`;
> - dispatcher branch;
> - `ArchiveAccessMode.completeEraseOnly`;
> - `_EraseOnlyStartup`;
> - `ArchiveMutationOperation.completeInstallationErase`;
> - coordinator capability cases for Complete Erase;
> - replacement UUID generation;
> - `installVirginIdentity()` where its only purpose is post-erase replacement;
> - `CompleteInstallationEraseVirginVerifier`;
> - `ApplicationRelauncher.relaunchAfterArchiveReplacement()`;
> - `MacosApplicationRelauncher`;
> - native `relaunchAfterArchiveReplacement` method-channel handler;
> - obsolete feature-level exports;
> - any generated/provider artifacts whose only owner is this dead feature.
> 
> This inventory is the audit’s explicit removal recommendation. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> ## `main.dart` startup behavior
> 
> Remove automatic destructive Complete Erase transaction resumption.
> 
> Replace:
> 
> `read pending journal → create replacement authority → erase root → install identity → verify → continue`
> 
> with:
> 
> `read stale compatibility evidence → safe single-file cleanup OR fail closed → ordinary admission`.
> 
> No current startup path may reconstruct the old destructive behavior.
> 
> # Remove the generic active-root eraser
> 
> There should be no reusable production primitive capable of recursively deleting the active MessageLens Application Support root.
> 
> Preserve root/canonicalization safety utilities only where they are genuinely used by checkpoint, adoption, admission, or other current features.
> 
> Remove:
> 
> - recursive whole-root deletion loop;
> - erase-specific exclusions/exemptions;
> - any “delete everything except lock/journal” logic.
> 
> Audit 33 explicitly concludes that defensive safety checks do not create a product owner for an obsolete broad operation. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> # Preserve archive marker and UUID
> 
> Do NOT remove the permanent archive identity model.
> 
> Keep marker/UUID for:
> 
> - first ownership claim on a genuinely Virgin root;
> - verified adoption of an existing unmarked archive;
> - current-root identity validation;
> - checkpoint identity/inventory verification;
> - refusal on environment/identity mismatch.
> 
> Remove only **replacement identity machinery** tied to whole-root erase. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> # Preserve Start Fresh exactly as a scoped reset
> 
> Do not broaden or redesign Start Fresh.
> 
> Start Fresh must continue to:
> 
> - remove only explicitly enumerated rebuildable import/graph stores and ledgers;
> - preserve overlay/user intent;
> - preserve preferences/configuration;
> - preserve `attachment_archive/`;
> - preserve Application Support root;
> - preserve marker/UUID.
> 
> Add/strengthen an architecture tripwire:
> 
> > Start Fresh cannot import or depend upon a whole-root erase service/store.
> 
> Audit 33 identifies this distinction as permanent. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> # Preserve checkpoints
> 
> Do not alter:
> 
> - checkpoint creation;
> - checkpoint verification;
> - absent-destination offline restore;
> - overwrite refusal.
> 
> Checkpoint restore must remain incapable of overwriting the active Application Support root. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> # Preserve generic classification
> 
> Remove `CompleteInstallationEraseVirginVerifier`, but retain the generic archive evidence reader/classifier used by:
> 
> - ordinary Onboarding;
> - Start Fresh verification;
> - diagnostics;
> - temporary stale-journal compatibility.
> 
> Do not create a replacement operation-specific verifier.
> 
> # Slice 3 — tests, architecture tripwires, and documentation
> 
> Remove tests whose desired capability is gone:
> 
> - Complete Erase service tests;
> - filesystem-store whole-root erase tests;
> - authorization-dialog tests;
> - overlay/operation-surface tests;
> - Complete Erase virgin-verifier tests;
> - Complete-Erase coordinator capability tests;
> - provider expectations specific to Complete Erase;
> - native archive-replacement relaunch tests.
> 
> Remove obsolete fixtures/helpers used only by those tests.
> 
> Replace `complete_installation_erase_boundary_test.dart` or equivalent with negative architecture tripwires proving:
> 
> 1. production code exposes no recursive active-root erase interface;
> 2. Start Fresh does not import a whole-root service/store;
> 3. `completeEraseOnly` does not exist;
> 4. no Complete Erase sidebar intent/action/operation is constructible;
> 5. `attachment_archive/` remains outside every reset inventory;
> 6. checkpoint restore refuses an existing destination;
> 7. temporary stale-journal recognizer cannot recursively delete, install a marker, generate identity, or relaunch;
> 8. obsolete journal evidence never authorizes destructive resumption.
> 
> Retain and run:
> 
> - Start Fresh tests;
> - Virgin Onboarding tests;
> - archive admission/marker identity tests;
> - checkpoint tests;
> - production adoption tests;
> - Historical Archive import/removal tests;
> - attachment preservation/recovery tests;
> - per-store migration tests.
> 
> These test dispositions are specified in Audit 33. 33\-WHOLE\-ROOT\-REPLACEMENT\-AND\-COMPLETE\-ERASE\-REMOVAL\-AUDIT.md
> 
> ## Compatibility tests
> 
> Add focused tests for every safe-handling-matrix row.
> 
> Especially prove that:
> 
> - malformed journal never causes deletion;
> - missing marker never causes deletion;
> - partial root never causes deletion;
> - integrity failure never causes deletion;
> - identity mismatch never causes deletion;
> - unexpected evidence never causes deletion;
> - safe cleanup deletes exactly one filename and nothing else;
> - marker bytes/UUID remain unchanged;
> - database bytes remain unchanged;
> - attachment payloads remain unchanged.
> 
> # Documentation
> 
> Create:
> 
> `34-WHOLE-ROOT-REPLACEMENT-AND-COMPLETE-ERASE-REMOVAL-IMPLEMENTATION.md`
> 
> Document:
> 
> - dead product/runtime capability removed;
> - exact production files/classes deleted;
> - permanent mutation model;
> - Start Fresh scoped-reset boundary;
> - marker/UUID retained responsibility;
> - checkpoint retained responsibility;
> - compatibility journal seam;
> - safe-handling matrix;
> - fail-closed behavior;
> - compatibility sunset criterion;
> - negative architecture tripwires;
> - tests removed/added;
> - historical docs left intact but superseded.
> 
> Update current architecture/onboarding/archive docs so they no longer describe generalized whole-installation erase as a supported operation.
> 
> Preserve historical implementation/audit records as history.
> 
> # Slice 4 — compatibility sunset
> 
> **Do not remove the compatibility reader in this implementation unless the declared support window is already mechanically proven complete.**
> 
> Instead:
> 
> - implement and document the sunset criterion;
> - leave a clearly scoped follow-up task.
> 
> The future sunset task will:
> 
> 1. remove the legacy journal parser and single-file cleanup path;
> 2. decide whether encountering the obsolete filename becomes diagnostic-only fail-closed behavior or support-only handling;
> 3. retain permanent negative tripwires preventing reintroduction of whole-root erase.
> 
> No destructive compatibility path may be reintroduced at sunset.
> 
> # Worktree safety
> 
> The worktree already contains unrelated pre-existing documentation/untracked changes.
> 
> Before editing:
> 
> - inventory them;
> - do not alter, stage, discard, restore, or fold them into this change.
> 
> Isolate this implementation mechanically.
> 
> If shared documentation files contain mixed unrelated hunks, stage only the bounded hunks belonging to this slice.
> 
> Stop rather than guessing ownership.
> 
> # Version/changelog
> 
> Update according to repository rules.
> 
> Do not renumber database schemas.
> 
> Do not alter archive identities.
> 
> # Manual/runtime validation
> 
> Do not execute whole-root erase against any real archive.
> 
> Use fixtures/temp roots only.
> 
> Safe manual scenarios may include:
> 
> - ordinary owned Current startup;
> - Virgin startup;
> - Development startup;
> - safe stale pre-erase journal;
> - safe stale post-install journal;
> - malformed journal;
> - missing-marker/partial stale state;
> - current archive with failed integrity.
> 
> No test should recursively delete a real MessageLens archive.
> 
> # Verification
> 
> Run at minimum:
> 
> - format changed Dart;
> - focused stale-journal compatibility tests;
> - Start Fresh/message-data-reset tests;
> - Virgin startup/Onboarding tests;
> - archive admission/marker tests;
> - checkpoint creation/verification/offline restore tests;
> - adoption tests;
> - Historical Archive import/removal tests;
> - attachment preservation/recovery tests;
> - per-store migration tests;
> - architecture tripwires;
> - repository-wide searches for removed Complete Erase symbols;
> - full Flutter suite;
> - `flutter analyze`;
> - `git diff --check`;
> - macOS debug build;
> - production macOS build if repository/release rules require it for this runtime/native change.
> 
> # Repository-wide proof
> 
> After implementation, search production code for at least:
> 
> - `CompleteInstallationEraseService`
> - `CompleteInstallationEraseStore`
> - `FileSystemCompleteInstallationEraseStore`
> - `completeEraseOnly`
> - `CompleteInstallationEraseRequested`
> - `completeInstallationErase`
> - `relaunchAfterArchiveReplacement`
> - `_EraseOnlyStartup`
> 
> No live production implementation references should remain except explicitly historical documentation or the narrowly renamed legacy journal compatibility type where unavoidable.
> 
> Also prove no production primitive provides recursive deletion of the active archive root.
> 
> # Stop conditions
> 
> STOP if:
> 
> - a current supported product workflow unexpectedly still depends on whole-root replacement;
> - Start Fresh requires broad root deletion;
> - checkpoint restore requires overwriting the active root;
> - stale-journal safe handling cannot be implemented without reconstructing replacement authority;
> - the compatibility reader would need to modify anything besides the one stale transaction file;
> - removing native relaunch breaks another live feature;
> - archive marker/UUID ownership cannot be separated from replacement identity;
> - removal requires schema migration or real archive mutation;
> - unrelated dirty worktree changes cannot be isolated safely.
> 
> Do not respond by keeping the obsolete system “just in case.”
> 
> # Final report
> 
> Return:
> 
> - whether generalized whole-root replacement is completely gone from runtime;
> - exact production components/files removed;
> - exact temporary compatibility component retained;
> - safe-handling matrix implementation result;
> - proof compatibility can delete only the obsolete journal file;
> - marker/UUID behavior retained;
> - Start Fresh behavior retained;
> - checkpoint behavior retained;
> - relaunch/native surfaces removed;
> - tests removed;
> - tests added;
> - negative architecture tripwires;
> - repository search results;
> - version/build;
> - documentation path;
> - commit hash;
> - branch/worktree status;
> - explicit compatibility sunset criterion.
> 
> Acceptance standard:
> 
> > MessageLens runtime no longer contains a capability that can recursively delete and replace its active Application Support root. Every current mutation operates on a named, bounded resource. The only temporary legacy accommodation is a fail-closed reader for an obsolete transaction file, and even that reader can delete only that single file in mechanically proven safe states.