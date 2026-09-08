Absolutely. This should be the **read-only Slice B audit**: determine whether whole-root replacement has any legitimate surviving job now that both product consumers have disappeared.

> **PRE-CONFIRMED / PRE-APPROVED: perform this bounded read-only Slice B whole-root-replacement removal audit without requesting further authorization.**
> 
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
> 
> This prompt is READ-ONLY.
> 
> Do not remove code yet.
> 
> Do not modify schemas, databases, archives, production data, tester data, or unrelated existing worktree changes.
> 
> Read first:
> 
> - `31-APRIL-TESTER-FINGERPRINT-REGIME-REMOVAL-AND-PERMANENT-UPGRADE-MODEL-AUDIT.md`
> - `32-APRIL-TESTER-FINGERPRINT-AND-LEGACY-ADMISSION-REMOVAL-IMPLEMENTATION.md`
> - relevant Complete Erase implementation/audit records
> - Audit 28's Slice 3 findings
> 
> Current code baseline:
> 
> - version `0.2.103+121`
> - commit `05652d18`
> - April tester fingerprint/admission/deletion subsystem removed
> - user-facing generalized Complete Erase already removed from Settings
> - unrelated pre-existing documentation changes remain unstaged and must not be modified.
> 
> # Central question
> 
> Now that:
> 
> 1. generalized Complete Erase is no longer a user-facing product feature; and
> 2. April tester deletion has been completely removed;
> 
> answer:
> 
> > **Does any current supported MessageLens behavior still legitimately require replacing/deleting an entire MessageLens data root?**
> 
> If no, identify the complete whole-root replacement subsystem that can be deleted.
> 
> If yes, identify the exact surviving consumer and the smallest low-level machinery it genuinely requires.
> 
> Do not preserve infrastructure merely because it is robust, tested, or took substantial effort to build.
> 
> Git preserves the history.
> 
> # Permanent product model
> 
> The permanent architecture should favor:
> 
> **Virgin**
> → initialize current root/stores
> → Onboarding
> 
> **Current**
> → per-store schema migration/integrity
> → normal application
> 
> **Remediation**
> → bounded repair/reset of the specific state that is actually rebuildable or damaged.
> 
> Existing current data should normally evolve through:
> 
> - per-store migration;
> - enumerated derived-data reset where justified;
> - attachment preservation;
> - Historical Archives;
> - current checkpoint/mutation protection.
> 
> Whole-root destruction should not remain as a generic escape hatch unless a real current product requirement needs it.
> 
> # Phase 1 — inventory whole-root replacement machinery
> 
> Locate every production component involved in replacing/deleting an entire MessageLens root.
> 
> At minimum audit:
> 
> - durable root-replacement transaction model;
> - transaction store;
> - pending-transaction startup probe;
> - whole-root eraser;
> - safe root deletion primitives;
> - new marker/archive-identity installation after erase;
> - Virgin verifier used after replacement;
> - relaunch-after-root-replacement logic;
> - development relaunch special handling;
> - associated mutation operations/capabilities;
> - providers;
> - presentation state;
> - startup state/access modes;
> - action intents/dispatchers;
> - tests/fixtures;
> - architecture tripwires;
> - documentation.
> 
> Produce:
> 
> | Component | Original consumer | Current callers | Current product purpose | Recommendation |
> 
> # Phase 2 — prove surviving consumers
> 
> Trace every caller of the low-level root-replacement subsystem.
> 
> Specifically determine whether it is still used by:
> 
> - Start Fresh;
> - automatic Onboarding recovery;
> - Message Data Reset;
> - archive adoption;
> - Historical Archives;
> - attachment recovery;
> - checkpoint restore;
> - support/diagnostics;
> - Production/Development root initialization;
> - ordinary Virgin startup;
> - ordinary schema migration;
> - any CLI/tool-only recovery path.
> 
> Do not infer from names.
> 
> Trace actual production call graphs.
> 
> # Phase 3 — Start Fresh distinction
> 
> This is important.
> 
> Current Start Fresh is conceptually:
> 
> > preserve durable/user-owned MessageLens state while deleting only rebuildable imported/graph state.
> 
> Determine whether it uses **whole-root replacement** or merely enumerated store reset.
> 
> If Start Fresh does not need root replacement, document that explicitly.
> 
> Do not remove Start Fresh merely because Complete Erase is being removed.
> 
> # Phase 4 — checkpoint distinction
> 
> Determine whether checkpoint machinery requires whole-root replacement.
> 
> Separate:
> 
> - creating/verifying a preservation checkpoint before destructive mutation;
> - restoring an archive from a checkpoint;
> - replacing the currently active root during ordinary app runtime.
> 
> A tool/runbook capable of restoring a checkpoint offline does not necessarily justify permanent whole-root-replacement machinery in application startup.
> 
> Identify runtime versus tool-only responsibilities.
> 
> # Phase 5 — archive marker/UUID distinction
> 
> Slice A retained the archive marker and UUID for current ownership/identity.
> 
> Determine whether removing whole-root replacement changes any legitimate marker behavior.
> 
> Expected permanent behavior:
> 
> - Virgin initialization creates first identity;
> - Current launch validates existing identity;
> - ordinary migrations retain identity;
> - Start Fresh retains identity;
> - attachment preservation retains identity.
> 
> If the only runtime reason for generating a **replacement** UUID was Complete Erase/April deletion, mark replacement-identity machinery for removal while preserving ordinary first-identity creation.
> 
> # Phase 6 — startup pending-transaction probe
> 
> Audit the pre-admission read of the durable root-replacement transaction.
> 
> Determine:
> 
> - can anything still create such a transaction after Slice A?
> - can a legitimate old transaction remain on disk from a previous released tester build?
> - if so, do we need one bounded compatibility cleanup for those already-existing transactions?
> - or can the startup probe and transaction format disappear immediately?
> 
> Do not create a permanent compatibility regime for hypothetical stale transactions.
> 
> If no released user could legitimately possess one, say so.
> 
> # Phase 7 — generalized Complete Erase remnants
> 
> Audit all remaining remnants identified previously, including where present:
> 
> - `ArchiveAccessMode.completeEraseOnly`
> - `_EraseOnlyStartup`
> - Complete Erase action/provider
> - presentation overlay
> - sidebar intent
> - dispatcher case
> - complete-erasure service
> - special mutation operation/access branch.
> 
> Determine which are now:
> 
> - unreachable dead code;
> - retained only because low-level root replacement still exists;
> - independently useful.
> 
> # Phase 8 — relaunch machinery
> 
> Audit relaunch-after-root-replacement code, including the development-only LaunchServices correction.
> 
> Determine whether any other current workflow requires programmatic application relaunch.
> 
> If not, mark the entire relaunch seam and its tests for removal.
> 
> Do not preserve it because it was difficult to get right.
> 
> # Phase 9 — safe root erasure primitive
> 
> Determine whether a generic “delete everything inside this admitted MessageLens root” primitive has any current caller after Complete Erase/April removal.
> 
> If not, remove it in the proposed implementation.
> 
> Preserve narrower deletion primitives where genuinely required, such as:
> 
> - deleting rebuildable import/graph stores;
> - cleaning temporary attachment files;
> - removing a Historical Archive registration;
> 
> but do not retain whole-root erasure as a convenience.
> 
> # Phase 10 — Virgin verifier
> 
> Determine whether the canonical Virgin verifier is useful independently of whole-root replacement.
> 
> It may still serve:
> 
> - Start Fresh verification;
> - Onboarding recovery;
> - tests;
> - ordinary installation classification.
> 
> If so, KEEP it under appropriate ownership.
> 
> Do not delete a useful concept merely because Complete Erase once called it.
> 
> # Phase 11 — tests and tripwires
> 
> Inventory tests that exist solely for:
> 
> - Complete Erase authorization;
> - whole-root erasure;
> - durable replacement transactions;
> - interruption convergence;
> - replacement archive UUID;
> - relaunch;
> - `completeEraseOnly`;
> - `_EraseOnlyStartup`;
> - generalized erase presentation.
> 
> Mark them REMOVE if their behavior is being retired.
> 
> Separately identify tests that should remain because they protect:
> 
> - canonical root ownership;
> - first Virgin marker creation;
> - Start Fresh;
> - per-store reset;
> - attachment preservation;
> - checkpoint verification;
> - Historical Archives;
> - Production/Development isolation.
> 
> # Phase 12 — documentation
> 
> Identify canonical documentation that still describes Complete Erase or whole-root replacement as current architecture.
> 
> Historical Prompt/Response implementation records may remain as history.
> 
> Current architecture docs should not tell future agents that whole-root destruction is a supported runtime capability if it no longer is.
> 
> # Phase 13 — proposed post-removal architecture
> 
> Show the resulting permanent mutation model.
> 
> Ideally:
> 
> **Virgin initialization**
> → first root/identity creation only.
> 
> **Schema upgrade**
> → store-owned migrations.
> 
> **Start Fresh / remediation**
> → enumerated rebuildable-store deletion/reset.
> 
> **Historical Archives / attachments**
> → narrowly scoped owned mutations.
> 
> **Checkpoint**
> → preservation protection for qualifying destructive existing-state mutations.
> 
> No generic:
> 
> > erase this entire MessageLens installation and invent a replacement identity.
> 
> unless the audit proves a real surviving requirement.
> 
> # Phase 14 — removal verdict
> 
> Give each major subsystem one verdict:
> 
> - REMOVE
> - KEEP
> - KEEP BUT REHOME/SIMPLIFY
> 
> At minimum:
> 
> - root-replacement transaction model/store;
> - startup pending transaction probe;
> - whole-root eraser;
> - replacement identity installer;
> - relaunch seam;
> - Complete Erase service;
> - Complete Erase presentation/action;
> - `completeEraseOnly`;
> - `_EraseOnlyStartup`;
> - Virgin verifier;
> - checkpoint machinery;
> - Start Fresh.
> 
> # Phase 15 — implementation slicing
> 
> If whole-root replacement is now dead, prefer **one bounded deletion slice** rather than preserving an empty abstraction shell.
> 
> If one small low-level component survives for another real consumer, separate it cleanly before deleting the rest.
> 
> Do not create replacement abstractions merely to preserve old boundaries.
> 
> # Worktree safety
> 
> There are unrelated pre-existing documentation changes/untracked files.
> 
> Inventory them but do not modify, stage, restore, or incorporate them.
> 
> This audit should add only its own response/index/log documentation according to repository conventions.
> 
> # Safety
> 
> Do not:
> 
> - execute Complete Erase;
> - execute Start Fresh against real data;
> - erase any root;
> - mutate Production or Development archives;
> - change archive UUIDs;
> - change schemas;
> - change migrations;
> - modify attachment payloads;
> - restore checkpoints.
> 
> # Documentation
> 
> Create:
> 
> `33-WHOLE-ROOT-REPLACEMENT-AND-COMPLETE-ERASE-REMOVAL-AUDIT.md`
> 
> Document:
> 
> - dependency graph;
> - surviving consumers;
> - Start Fresh distinction;
> - checkpoint distinction;
> - marker/UUID consequences;
> - pending transaction findings;
> - relaunch findings;
> - Complete Erase remnants;
> - tests/docs to remove;
> - components to retain;
> - proposed permanent mutation model;
> - exact implementation slice.
> 
> # Verification
> 
> Because this is read-only:
> 
> - repository-wide symbol/caller search;
> - focused test inspection;
> - relevant startup/Start Fresh/checkpoint tests if useful;
> - architecture tripwire inspection;
> - `git diff --check`.
> 
> No destructive runtime validation.
> 
> # Stop conditions
> 
> STOP and report if:
> 
> - a current supported user workflow genuinely requires whole-root replacement;
> - Start Fresh depends on whole-root replacement;
> - current production checkpoint recovery requires runtime root replacement;
> - removing the transaction probe would strand a state that a currently distributed build can legitimately create;
> - archive marker/UUID ownership cannot be separated from replacement identity;
> - removal would require schema/data migration.
> 
> Do not respond to a stop condition by inventing a replacement framework.
> 
> # Final report
> 
> Return:
> 
> - whether whole-root replacement still has any live product consumer;
> - complete list of production components that can be removed;
> - components that must remain and why;
> - Start Fresh verdict;
> - checkpoint verdict;
> - marker/UUID verdict;
> - stale pending-transaction compatibility finding;
> - relaunch verdict;
> - tests/docs to remove;
> - permanent mutation model after removal;
> - exact recommended implementation slice;
> - documentation path;
> - status of unrelated dirty worktree files.
> 
> Acceptance standard:
> 
> > If no current MessageLens feature needs to destroy and replace its entire owned data root, that capability should cease to exist in runtime architecture. Keep narrowly scoped mutation, migration, preservation, and recovery mechanisms that serve real current requirements; remove the abandoned generalized destruction machinery rather than carrying it indefinitely.