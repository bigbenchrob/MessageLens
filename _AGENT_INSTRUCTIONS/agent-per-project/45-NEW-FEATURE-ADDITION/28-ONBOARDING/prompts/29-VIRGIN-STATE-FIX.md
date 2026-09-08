Here is the next prompt, grounded in Audit 28 and limited to **Slices 1 and 2 only**. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md

> **PRE-CONFIRMED / PRE-APPROVED: implement Audit 28 Slices 1 and 2 only, without requesting further authorization.**
> 
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
> 
> Read first:
> 
> - `28-VIRGIN-INSTALL-ARCHIVE-REGIME-SIMPLIFICATION-AUDIT.md`
> - Responses 24, 26, and 27 covering the two tester-reported virgin-install failures and their point corrections.
> 
> Current tester build `0.2.101+119` already fixes the two observed failures:
> 
> - bootstrap-empty production root can receive its first marker;
> - coherent Virgin first import no longer unconditionally invokes checkpoint-gated reset.
> 
> This task is **not** another symptom fix.
> 
> Its purpose is to make those fixes **mechanically permanent** by removing the remaining architectural call paths that let Virgin startup/import depend on existing-archive machinery.
> 
> Do **not** implement Audit 28 Slices 3 or 4 in this task.
> 
> Do **not** remove generalized Complete Erase cruft yet.
> 
> Do **not** alter Start Fresh / old Presence coupling yet.
> 
> Do **not** change schema versions or migration histories.
> 
> # Governing invariant
> 
> A brand-new MessageLens installation must not execute, construct, or depend upon machinery whose purpose is to preserve, reset, recover, adopt, or delete a previous MessageLens installation.
> 
> The intended Virgin path is:
> 
> `native root/build proof`
> →
> `bootstrap-empty proof`
> →
> `first marker/identity creation`
> →
> `minimal read-only classification = Virgin`
> →
> `construct Onboarding state`
> →
> `Messages → History → Contacts → Ready`
> →
> `Import My Messages`
> →
> `create/populate fresh import and graph stores`
> →
> `durable verification`
> →
> `Start`.
> 
> No reset.
> 
> No checkpoint.
> 
> No archive adoption.
> 
> No migration.
> 
> No recovery transaction unless there is positive durable evidence of an interrupted operation.
> 
> ## Slice 1 — make Virgin first import structurally fresh
> 
> Audit 28 found that `_startImportAndGraphBuild()` still always enters an `environmentPreparation` stage that calls `_prepareForFreshStartIfNeeded()`, and that helper retains a conditional edge to `MessageDataResetService`. This means the coherent Virgin path behaves correctly today, but reset remains callable from the first-import graph. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> Remove that call edge.
> 
> Required outcome:
> 
> > A positively classified Virgin `Ready → Import` path has no callable route to `MessageDataResetService`, `messageDataReset`, or checkpoint authority.
> 
> Do this by separating:
> 
> ### Virgin first import
> 
> Fresh construction only:
> 
> - authorize `ArchiveMutationOperation.onboardingImport`;
> - create/populate `macos_import_ss.db`;
> - create/populate `working_ss.db`;
> - perform current enrichment/projection work;
> - run durable verification;
> - advance to Start only on success.
> 
> ### Existing failed/partial-install remediation
> 
> If durable evidence says existing derived state requires reset or recovery:
> 
> - classify/project that condition **before** Ready can be constructed;
> - route through the existing bounded recovery/remediation path;
> - only after remediation has mechanically produced Virgin may the normal Virgin Ready Episode exist.
> 
> Do not make `Ready` mean:
> 
> > ready unless Import later decides to reset something.
> 
> `Ready` must certify that the next operation is fresh import.
> 
> ### Public action boundary
> 
> Audit whether `startImportAndGraphBuild()` currently accepts states other than the true Ready/Virgin authorization state, including `OnboardingOperationFailed`.
> 
> Separate retry/recovery intent from fresh first-import intent if necessary.
> 
> Do not keep a convenience API that allows the same method to mean:
> 
> - fresh creation;
> - retry;
> - cleanup/reset.
> 
> Prefer fewer, more truthful entry points.
> 
> ### Preserve mutation coordination
> 
> First import still performs real writes and must continue through `ArchiveMutationCoordinator`.
> 
> Do not confuse:
> 
> `does not require preservation/reset machinery`
> 
> with:
> 
> `does not require mutation serialization`.
> 
> Keep the existing concurrency/resource admission needed to protect import/graph writes.
> 
> ## Slice 1 tests
> 
> Add focused tests proving:
> 
> 1. positively classified Virgin Ready → Import cannot invoke `MessageDataResetService`;
> 2. Virgin first import never requests `ArchiveMutationOperation.messageDataReset`;
> 3. Virgin first import never requires verified checkpoint authority;
> 4. import and graph stores are created/populated directly;
> 5. failed/partial installation requiring reset cannot construct Ready;
> 6. remediation must finish and reclassify Virgin before Ready becomes available;
> 7. retry/recovery intent cannot enter the fresh Virgin import entry point;
> 8. current successful production-shaped Virgin import behavior remains unchanged.
> 
> Add an architecture tripwire that makes the forbidden dependency visible at compile/source-test level:
> 
> > Virgin first-import implementation must not import/reference/call `MessageDataResetService`.
> 
> Do not rely only on a mock returning “reset not needed.”
> 
> # Slice 2 — classify before writable provider construction
> 
> Audit 28 found that installation classification is not truly observational in construction:
> 
> - `windowStateServiceProvider.restoreWindowState()` opens/creates `user_overlays.db` before classification;
> - `messageLensInstallationStateProvider` resolves the writable overlay-backed `onboardingOperationControllerProvider` merely to obtain snapshot evidence;
> - persistent logging creates `application_logs/` before top-level classification. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> The desired ordering is:
> 
> `archive claim/root/marker authority`
> →
> `minimal read-only installation evidence`
> →
> `classify Virgin / Current / Remediation`
> →
> `construct only that case's writable providers/presentation`. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> Implement that ordering without introducing another database/container/bootstrap framework.
> 
> ## Read-only operation snapshot evidence
> 
> Classification still needs durable Onboarding operation evidence.
> 
> Replace the current dependency on the live writable `OnboardingOperationSnapshotController` with a narrow read-only evidence seam.
> 
> Requirements:
> 
> - read existing overlay snapshot only if the file exists;
> - read/query SQLite read-only/query-only;
> - do not create `user_overlays.db`;
> - do not migrate it;
> - do not instantiate the writable operation controller;
> - absence of overlay/snapshot on pristine Virgin is ordinary absence, not error.
> 
> Reuse existing installation-evidence infrastructure where possible.
> 
> Do not create a second overlay ownership model.
> 
> ## Window state
> 
> Move window-state restoration until after full-mode classification proves the installation path where ordinary current writable providers are appropriate.
> 
> For Virgin:
> 
> - no overlay DB should be created merely to restore historical geometry that cannot exist.
> 
> For Current:
> 
> - preserve normal window-state restoration behavior after classification.
> 
> For Remediation:
> 
> - do not migrate/create overlay state merely because presentation needs to render.
> 
> For exact legacy:
> 
> - current persistent providers remain forbidden exactly as today.
> 
> ## Persistent logging
> 
> Audit 28 recommends persistent logging only after case selection, with ephemeral/preclassification diagnostics before then. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> Make the smallest safe correction that prevents pristine classification from creating `application_logs/`.
> 
> Do not build a generalized logging subsystem.
> 
> Preserve enough preclassification diagnostics to explain admission/classification failures.
> 
> If current native/stderr/ephemeral logging already provides that, use it.
> 
> Persistent archive logging may start immediately after the installation case has been selected and full current authority is appropriate.
> 
> ## Slice 2 tests
> 
> Prove:
> 
> 9. pristine production classification creates no SQLite database files;
> 10. pristine classification creates no `user_overlays.db`;
> 11. pristine classification creates no `presence.db`;
> 12. pristine classification creates no import/graph DBs;
> 13. pristine classification does not restore overlay-backed window state;
> 14. current completed classification still restores window state afterward;
> 15. operation snapshot evidence is read-only;
> 16. a pre-existing operation snapshot is classified correctly without constructing the writable controller;
> 17. Remediation inspection performs no migration/write;
> 18. exact legacy restricted authority still cannot open current providers;
> 19. persistent logging begins only after appropriate case selection;
> 20. classification failure does not accidentally create ordinary archive state.
> 
> ## Preserve marker semantics
> 
> Do not undo the tester correction.
> 
> The current marker model is correct:
> 
> - missing marker + bootstrap-empty root = Virgin initialization;
> - missing marker + meaningful state = Legacy or Remediation;
> - first marker creation belongs to `ArchiveAdmissionService`;
> - archive identity exists before MessageLens begins durable writes. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> Do not move marker creation into the installation classifier.
> 
> Do not treat first marker creation as adoption.
> 
> ## Preserve the exact legacy path
> 
> Keep:
> 
> `meaningful unmarked root`
> →
> `exact read-only 4/3/3 proof`
> →
> `restricted legacy authority`
> →
> explicit delete authorization
> →
> crash-convergent root replacement
> →
> canonical Virgin
> →
> normal Onboarding.
> 
> Legacy deletion must terminate in the **same Virgin path** as an installation that never existed before. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> No special legacy state may leak into the new process.
> 
> ## Preserve Current installations
> 
> This simplification must not weaken:
> 
> - archive marker validation;
> - attachment preservation;
> - Historical Archives;
> - source-scoped identities;
> - maintenance serialization;
> - Start Fresh authorization;
> - checkpoint protection for destructive existing-state operations;
> - current production archive readability.
> 
> The desired Current path remains:
> 
> `validate marker`
> →
> `minimal read-only classification = Current`
> →
> `restore preferences/window state`
> →
> `open normal providers lazily`
> →
> normal app. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> ## Remediation behavior
> 
> Keep `resumable`, `abandoned`, and `remediationRequired` behavior where they represent real distinct authorization/recovery semantics.
> 
> Do not collapse those enums in this task.
> 
> At the product level they may all remain under Remediation, but their existing safe actions must remain intact.
> 
> ## Explicitly out of scope — Audit 28 Slice 3
> 
> Do NOT yet remove:
> 
> - `ArchiveAccessMode.completeEraseOnly`;
> - `_EraseOnlyStartup`;
> - Complete Erase idle overlay/action/provider remnants;
> - sidebar intent/dispatcher remnants;
> - low-level root-replacement transaction infrastructure.
> 
> Audit 28 identifies these as historical cruft, but not current tester blockers. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> ## Explicitly out of scope — Audit 28 Slice 4
> 
> Do NOT yet:
> 
> - remove retired required-sources Presence Schedule coupling from Start Fresh;
> - collapse `resumable`/`abandoned`;
> - perform migration archaeology/schema cleanup.
> 
> Those remain separate cleanup.
> 
> ## Architecture tripwires
> 
> Implement/protect at minimum:
> 
> - bootstrap-empty production root receives exactly one first marker;
> - meaningful unmarked root can never receive initial marker;
> - exact legacy inspection never runs for bootstrap-empty root;
> - minimal installation classification cannot import writable DB providers;
> - minimal classification cannot create canonical DB files;
> - window-state restoration cannot occur before full-mode classification;
> - positively classified Virgin import has no call edge to `MessageDataResetService`;
> - `onboardingImport` cannot require checkpoint authority;
> - reset/checkpoint requires positive meaningful-state or failed-operation evidence;
> - legacy deletion terminates in canonical Virgin;
> - Start Fresh/Complete Erase cannot influence ordinary Virgin startup;
> - Current installation preservation remains unchanged;
> - Unknown/damaged meaningful state remains fail-closed.
> 
> These correspond to the invariants identified in Audit 28. 28\-VIRGIN\-INSTALL\-ARCHIVE\-REGIME\-SIMPLIFICATION\-AUDIT.md
> 
> ## Manual/product validation
> 
> Do not manufacture special roots or external clones.
> 
> Use existing focused fixtures for structural proof.
> 
> If safe, perform one ordinary Development-arm Virgin reset/onboarding run after implementation to confirm the human path remains:
> 
> `Messages → History → Contacts → Ready → Import → Start`
> 
> and that Import proceeds without any reset/checkpoint presentation.
> 
> Do not touch Production to prove this.
> 
> The tester can retry the production build separately after the implementation is released.
> 
> ## Documentation
> 
> Create:
> 
> `29-VIRGIN-FIRST-IMPORT-AND-READ-ONLY-STARTUP-CLASSIFICATION-SIMPLIFICATION-IMPLEMENTATION.md`
> 
> Document:
> 
> - old forbidden Virgin call edges;
> - final Virgin import call graph;
> - read-only installation-classification seam;
> - window-state ordering;
> - logging ordering;
> - preserved marker semantics;
> - preserved Current/Legacy/Remediation behavior;
> - tests/tripwires;
> - remaining Slice 3/4 cruft explicitly deferred.
> 
> Update Feature 28 index/documentation log.
> 
> Update version/changelog according to repository rules.
> 
> ## Verification
> 
> Run:
> 
> - virgin startup tests;
> - first-import tests;
> - installation-classifier tests;
> - archive admission tests;
> - operation snapshot tests;
> - window-state tests;
> - legacy tester recognition/deletion regressions;
> - Start Fresh regressions;
> - checkpoint/mutation policy tests;
> - Onboarding Journey tests;
> - architecture tripwires;
> - full Flutter suite;
> - `flutter analyze`;
> - formatting;
> - `git diff --check`;
> - macOS debug build.
> 
> Commit and push if clean.
> 
> ## Stop conditions
> 
> STOP rather than broadening scope if:
> 
> - fresh import cannot be separated from remediation without redesigning the Journey Coordinator;
> - read-only snapshot evidence requires schema migration or writable store construction;
> - moving window restoration breaks Current startup semantics in a way requiring broad shell redesign;
> - preclassification logging cannot be made non-persistent without losing essential fail-closed diagnostics;
> - Current/Legacy preservation would be weakened;
> - implementing these slices requires removing Slice 3/4 machinery at the same time.
> 
> ## Final report
> 
> Return:
> 
> - whether Virgin import now has zero reset/checkpoint call edges;
> - exact fresh-import entry point;
> - exact remediation entry point;
> - whether classification is now fully read-only after marker admission;
> - what files may exist immediately after pristine classification;
> - when overlay/window-state persistence begins;
> - when persistent logging begins;
> - proof Current behavior remains intact;
> - proof Legacy deletion rejoins ordinary Virgin;
> - tests/verification;
> - version/build;
> - documentation path;
> - commit hash;
> - branch/worktree status;
> - exact remaining Slice 3/4 cruft deferred.
> 
> Acceptance standard:
> 
> > Once the root and first archive identity are safely admitted, a truly Virgin installation is classified using observation only, and its first import constructs fresh stores directly. No mechanism whose purpose is to reset, checkpoint, recover, adopt, or erase pre-existing MessageLens state is reachable from that path.