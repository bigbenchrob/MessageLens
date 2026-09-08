Use this:

> **PRE-CONFIRMED / PRE-APPROVED: perform this bounded read-only removal audit without requesting further authorization.**
> 
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
> 
> This prompt is READ-ONLY.
> 
> Do not implement removals yet.
> 
> Do not modify application code, schemas, databases, production data, tester data, or current archives.
> 
> The purpose is to identify and remove the failed April-tester fingerprint/admission experiment from the permanent architecture, while preserving the parts of MessageLens that genuinely belong in a long-lived product.
> 
> # Product decision
> 
> The remaining two April testers will be instructed manually to delete their old MessageLens Application Support folder before installing the current build.
> 
> Therefore:
> 
> > MessageLens no longer needs to recognize, fingerprint, classify, route, delete, migrate, or otherwise understand the April 2026 tester installations.
> 
> The temporary compatibility experiment is over.
> 
> This audit should determine exactly what can be deleted.
> 
> # Long-term compatibility model
> 
> Looking forward, MessageLens should handle future upgrades through ordinary persistence evolution:
> 
> **Current data root ownership**
> →
> **per-store schema version**
> →
> **known migration path**
> →
> **integrity verification**
> 
> Application releases are not database versions.
> 
> Example:
> 
> - MessageLens 3.0 through 3.4 may all use import schema 13;
> - MessageLens 4.1 may introduce import schema 14;
> - future code migrates schema `13 → 14`;
> - it does not fingerprint the entire data folder to infer which app release created it.
> 
> This is the permanent model to protect.
> 
> # Central question
> 
> Perform a repository-wide audit and answer:
> 
> > Which classes, enums, providers, access modes, exceptions, startup branches, tests, fixtures, docs, and low-level helpers exist solely because we attempted to recognize and specially handle the April tester data folders?
> 
> Those are candidates for deletion.
> 
> At the same time, identify which surrounding “archive” concepts serve genuine current or future product requirements and must remain.
> 
> # Explicitly targeted experiment
> 
> Search for everything connected to:
> 
> - `legacyTesterInstall`
> - `legacyTesterInstallDetected`
> - `LegacyTesterInstallInspector`
> - `ReadOnlySqliteLegacyTesterInstallInspector`
> - legacy `4/3/3` schema constants
> - legacy table fingerprints
> - April tester recognition
> - April tester deletion
> - `Delete Old Data and Continue`
> - special legacy archive access authority
> - legacy root-replacement handoff
> - tests/fixtures whose only purpose is exact April recognition
> - documentation presenting this compatibility path as permanent
> 
> Also trace related pieces of:
> 
> - `ArchiveAdmissionException`
> - `ArchiveAdmissionFailure`
> - `missingMarker`
> - `nonEmptyUnmarkedArchive`
> - archive marker validation
> - `ArchiveAccessMode`
> - startup routing
> 
> Do not assume every reference to these broader concepts belongs to the failed experiment. Prove purpose before recommending deletion.
> 
> # Distinguish five categories
> 
> Classify every relevant component into:
> 
> ## A — April tester experiment only
> 
> Exists solely to detect or specially handle the obsolete April installations.
> 
> Recommendation should normally be:
> 
> **REMOVE**
> 
> ## B — Current root ownership/safety
> 
> Examples may include:
> 
> - canonical Production/Development data-root separation;
> - process locking;
> - preventing arbitrary filesystem roots;
> - current archive UUID if it has a real ownership role.
> 
> Recommendation:
> 
> **KEEP**, but simplify if legacy assumptions leaked into it.
> 
> ## C — Per-database schema evolution
> 
> Examples:
> 
> - Drift/sqflite `schemaVersion`;
> - migrations;
> - schema snapshots;
> - integrity checks.
> 
> Recommendation:
> 
> **KEEP**
> 
> This is the intended 2032 upgrade mechanism.
> 
> ## D — Current preservation/recovery capability
> 
> Examples:
> 
> - attachment preservation;
> - Historical Archives;
> - donor/recovery sources;
> - mutation serialization;
> - Start Fresh for current installations if still a product requirement.
> 
> Recommendation:
> 
> **KEEP** if genuinely current.
> 
> ## E — Historical cruft unrelated to April tester recognition
> 
> Old Complete Erase surface, retired Presence coupling, dead admission enums, old one-time cutover helpers, etc.
> 
> Recommendation:
> 
> report separately.
> 
> Do not mix these into the April-removal recommendation unless their removal is mechanically coupled and low-risk.
> 
> # Phase 1 — exact dependency graph
> 
> Starting from the April legacy inspector and deletion presentation, trace:
> 
> - callers;
> - callees;
> - providers;
> - access modes;
> - mutation operations;
> - startup branches;
> - presentation surfaces;
> - relaunch/root-replacement infrastructure;
> - tests;
> - docs.
> 
> Produce:
> 
> | Component | Why it exists | April-only? | Other live purpose? | Recommendation |
> 
> # Phase 2 — exception regime audit
> 
> Audit `ArchiveAdmissionException` and `ArchiveAdmissionFailure`.
> 
> For every failure case, document:
> 
> - current caller;
> - current product meaning;
> - whether it exists only because of historical/legacy fingerprinting;
> - whether it can reach raw user presentation.
> 
> In particular inspect:
> 
> - `missingMarker`
> - `nonEmptyUnmarkedArchive`
> 
> Determine whether they are still necessary after April recognition is removed.
> 
> Desired principle:
> 
> > A brand-new install is not an archive-admission failure.
> 
> If the whole exception hierarchy survives only because startup was framed as “admit an archive,” challenge that architecture explicitly.
> 
> Do not delete current safety checks merely to remove ugly names.
> 
> # Phase 3 — archive marker / UUID audit
> 
> Determine exactly what `.messagelens-archive.json` and archive UUID accomplish today independent of the April experiment.
> 
> Ask:
> 
> - Does it prevent Production/Development cross-use?
> - Does it identify attachment/archive ownership?
> - Does it protect restore/checkpoint operations?
> - Does it prevent two physical roots from masquerading as one?
> - Is it required by current persistent providers?
> - Is it merely residue from the old archive-admission regime?
> 
> Give one verdict:
> 
> - KEEP AS-IS
> - KEEP BUT SIMPLIFY
> - REMOVE
> 
> Do not preserve it simply because many files currently reference it.
> 
> # Phase 4 — future migration model audit
> 
> Prove that ordinary future application upgrades can be handled through per-store schema versions and migrations without installation fingerprints.
> 
> For:
> 
> - `macos_import_ss.db`
> - `working_ss.db`
> - `user_overlays.db`
> - `presence.db`
> 
> document:
> 
> - current schema version;
> - migration authority;
> - how a future older supported schema would be detected;
> - how migration would proceed;
> - how an unsupported-too-old schema would fail.
> 
> Confirm that no April folder fingerprint is required for this.
> 
> # Phase 5 — root existence versus current installation
> 
> Audit whether startup currently needs a concept broader than:
> 
> - no current root/state;
> - current supported state;
> - inconsistent/damaged current state.
> 
> Once April recognition is removed, determine whether special legacy startup routing still has any live purpose.
> 
> Prefer ordinary current schema/integrity checks over installation archaeology.
> 
> # Phase 6 — root-replacement machinery
> 
> The April deletion path reused crash-convergent root-replacement machinery originating in generalized Complete Erase.
> 
> Determine whether that low-level machinery still has another live current purpose.
> 
> Separate:
> 
> - root-replacement transaction/store;
> - safe owned-root deletion;
> - relaunch after root replacement;
> - generalized Complete Erase product UI;
> - April tester deletion UI.
> 
> Recommend what remains after both April handling and user-facing Complete Erase are gone.
> 
> If nothing uses root replacement afterward, mark it for removal.
> 
> # Phase 7 — tests to remove
> 
> Inventory tests whose only purpose is proving discarded behavior, including:
> 
> - exact `4/3/3` recognition;
> - table fingerprint matching;
> - legacy schema mismatch rejection;
> - special legacy authority;
> - legacy delete authorization;
> - April root-replacement handoff;
> - raw admission failure scenarios that no longer exist.
> 
> Do not preserve obsolete tests just to keep test count high.
> 
> # Phase 8 — docs to retire
> 
> Identify canonical/response/prompt documents that describe the April compatibility mechanism.
> 
> Historical implementation records may remain as historical records if repository convention requires that.
> 
> But ensure no canonical architecture document tells future agents:
> 
> > MessageLens handles old versions through folder fingerprinting.
> 
> That statement must disappear from current architecture.
> 
> # Phase 9 — proposed permanent startup model
> 
> Recommend the simplest startup model after removal.
> 
> Conceptually it should resemble:
> 
> **Production/Development root resolution**
> →
> **current ownership/marker initialization if needed**
> →
> **minimal read-only current-store evidence**
> →
> one of:
> 
> - Virgin
> - Current
> - Remediation
> 
> Future old-but-supported installations should ordinarily appear as Current-with-older-schema and migrate through store-owned migration logic.
> 
> There should be no April-specific Legacy top-level case.
> 
> # Phase 10 — proposed permanent upgrade model
> 
> Document how MessageLens 9.0 in 2032 should handle old installs:
> 
> 1. locate its current owned data root;
> 2. inspect each current persistent store's schema version;
> 3. migrate supported older schemas;
> 4. verify integrity/reconciliation;
> 5. fail with bounded remediation if a schema is unsupported or corrupt.
> 
> No inference from folder shape.
> 
> No app-version fingerprint.
> 
> No historical release classifier.
> 
> No `4/3/3` archaeology.
> 
> # Phase 11 — concrete removal plan
> 
> Produce the smallest implementation sequence.
> 
> Prefer:
> 
> ### Slice A — remove April tester recognition/presentation
> 
> Delete inspector, fingerprints, special access mode, startup branch, UI, tests.
> 
> ### Slice B — remove April deletion/root-replacement ownership
> 
> Delete special mutation authority and handoff.
> 
> Retain low-level root replacement only if another live product path requires it.
> 
> ### Slice C — simplify admission exceptions/marker semantics
> 
> Only where Audit evidence proves legacy assumptions are dead.
> 
> ### Slice D — update canonical docs/tripwires
> 
> Make per-store migration the explicit permanent compatibility model.
> 
> Do not combine unrelated schema-history cleanup from Response 23 unless necessary.
> 
> # Release safety
> 
> This cleanup follows real tester evidence:
> 
> - one tester solved the issue by manually deleting the old Application Support folder;
> - the remaining testers can be instructed to do the same.
> 
> Therefore the April compatibility code no longer serves a required user path.
> 
> Still protect the developer's current production installation and all current tester installations.
> 
> No real archive should be mutated during this audit.
> 
> # Verification
> 
> Because this is read-only:
> 
> - repository-wide symbol search;
> - caller/callee tracing;
> - focused archive/startup/migration test inspection;
> - architecture tripwire inspection;
> - `git diff --check`.
> 
> Do not run destructive tests against real data.
> 
> # Documentation
> 
> Create:
> 
> `31-APRIL-TESTER-FINGERPRINT-REGIME-REMOVAL-AND-PERMANENT-UPGRADE-MODEL-AUDIT.md`
> 
> Document:
> 
> - original April problem;
> - why the fingerprint solution is being retired;
> - exact dependency graph;
> - April-only components;
> - exception findings;
> - marker/UUID verdict;
> - root-replacement verdict;
> - future per-store migration model;
> - tests/docs to remove;
> - proposed permanent startup model;
> - exact removal slices.
> 
> # Stop conditions
> 
> STOP and report if:
> 
> - April fingerprinting is unexpectedly required by a current supported installation;
> - removal would make the developer's current production archive unreadable;
> - root ownership cannot be separated from historical fingerprinting;
> - future schema migration currently depends on folder fingerprinting;
> - deleting the experiment would require broad persistence redesign.
> 
> Do not keep bad architecture merely because removing it exposes another problem. Report that problem clearly.
> 
> # Final report
> 
> Return:
> 
> - whether the April fingerprint regime can be completely removed;
> - exact production symbols/files to remove;
> - exact tests to remove;
> - exact docs/tripwires to change;
> - marker/UUID KEEP / SIMPLIFY / REMOVE verdict;
> - root-replacement KEEP / SIMPLIFY / REMOVE verdict;
> - permanent startup model;
> - permanent 2032 upgrade/migration model;
> - smallest implementation sequence;
> - documentation path.
> 
> Acceptance standard:
> 
> > The audit should make clear which parts of MessageLens exist because of a two-tester April compatibility experiment and which parts belong in a durable product. The former should be removable. The latter should support future upgrades through explicit per-database schema migration, not by trying to infer application history from the shape of an Application Support folder.

That should give Codex enough room to be surgical without letting it reinterpret “remove the experiment” as “design Archive Framework 2.0.”