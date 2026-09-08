Yes. The requirement is now clear, and I think the prompt needs to be unusually explicit because otherwise Codex will continue treating the existing architecture as something to preserve and refine.

There are actually **two instructions**, not one:

1. Implement the tiny, temporary compatibility courtesy you originally wanted.
2. **Delete the architectural experiment that grew around it.**

And I would specifically tell Codex that **the existing archive-admission/version-fingerprint regime is not an invariant to preserve**. It is the thing being removed.

One nuance: I would not phrase the temporary rule literally as “if the folder doesn't look like the current version, delete it” without authorization. A folder could be damaged, unexpected, or someday contain something valuable. For these remaining two testers, the equally simple and safer rule is:

> **If a pre-existing MessageLens Application Support folder exists when this release starts, tell the user that old test data was found and offer to move the entire old folder to the Trash. If there is no folder, create the current installation normally.**

No fingerprint. No database inspection. No attempt to identify which April build it was. **Existence is the only test**, because you already know the population to whom this build is being distributed.

And after these two testers are through, **remove even that temporary existence check.**

I would give Codex this:

> **PRE-CONFIRMED / PRE-APPROVED: this is an explicit architectural removal and simplification task. Proceed without requesting authorization to preserve existing archive-admission/version-fingerprint machinery.**
> 
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
> 
> # Read this before doing anything
> 
> The previous requirements around legacy tester detection were misunderstood and dramatically over-engineered.
> 
> This prompt **supersedes the product assumptions behind the legacy/archive fingerprint work of the last approximately two weeks.**
> 
> Do not treat that machinery as architecture to preserve.
> 
> Much of it is now explicitly targeted for deletion.
> 
> # The actual problem
> 
> Three people received an old MessageLens tester build in April 2026.
> 
> They may therefore have an old MessageLens Application Support data folder.
> 
> That old data has **no value**.
> 
> It does not need:
> 
> - migration;
> - adoption;
> - identification;
> - schema inspection;
> - archive fingerprinting;
> - preservation;
> - recovery;
> - compatibility analysis.
> 
> The developer could simply have told each tester:
> 
> > Go to `~/Library/Application Support`, find the MessageLens data folder, and delete it before installing this release.
> 
> The entire intended feature was merely to save those testers from having to do that manually.
> 
> That is all.
> 
> # Evidence that the existing approach is wrong
> 
> Tester 1, who had **never installed MessageLens**, received:
> 
> `ArchiveAdmissionException(ArchiveAdmissionFailure.missingMarker)`
> 
> because the application expected evidence from a previous MessageLens installation where none could possibly exist.
> 
> Tester 2, who **did install the April build**, received:
> 
> `ArchiveAdmissionException(ArchiveAdmissionFailure.nonEmptyUnmarkedArchive)`
> 
> because `working.db` did not match the exact legacy fingerprint the new machinery expected.
> 
> The tester then manually deleted the old MessageLens Application Support folder and reported:
> 
> > Works!
> 
> > Great app
> 
> That manual deletion is the product behavior we were trying to automate.
> 
> The fingerprint regime prevented the desired operation instead of enabling it.
> 
> # Governing decision
> 
> **STOP TRYING TO IDENTIFY THE OLD VERSION.**
> 
> We do not care which old MessageLens build produced the folder.
> 
> We do not care what schema its databases contain.
> 
> We do not care whether its fingerprint matches April `4/3/3`.
> 
> We do not care whether it has an archive marker.
> 
> We do not care whether it contains `working.db`, `macos_import.db`, an attachment directory, overlays, Presence, or anything else.
> 
> For this temporary tester-release compatibility path:
> 
> > **The existence of pre-existing MessageLens-owned Application Support data is the only relevant fact.**
> 
> # Temporary compatibility behavior
> 
> This build is being supplied only to the remaining known early testers/new testers during this bounded rollout.
> 
> At production startup:
> 
> ## No existing MessageLens Application Support folder
> 
> This is a new installation.
> 
> Proceed directly through the ordinary current Virgin initialization and Onboarding.
> 
> No archive/version/fingerprint inspection.
> 
> No exception because a marker is missing.
> 
> No attempt to infer historical state.
> 
> ## Existing MessageLens Application Support folder
> 
> Before opening or interpreting anything inside it, present one simple compatibility question:
> 
> **Old MessageLens test data found**
> 
> Suggested copy:
> 
> > MessageLens found data left by an earlier test version. This release needs to start with a clean setup.
> > 
> > I can move the old MessageLens data to the Trash and continue. Your Apple Messages and Contacts will not be changed.
> 
> Actions:
> 
> - **Cancel**
> - **Move Old Data to Trash and Continue**
> 
> On confirmation:
> 
> - close/use no databases inside that old folder;
> - move the **entire MessageLens-owned Application Support folder** to the macOS Trash;
> - do not inspect its schema;
> - do not inspect its contents;
> - do not preserve anything inside it;
> - do not migrate anything;
> - create a normal current Virgin installation;
> - continue into the ordinary six-node Onboarding Journey.
> 
> Prefer moving the folder to Trash rather than permanently deleting it if this can be done cleanly with existing macOS APIs.
> 
> If Trash introduces substantial new machinery, STOP and report that fact rather than building a trash-management subsystem. The developer can choose permanent deletion or manual instructions.
> 
> # Critical scope boundary
> 
> This behavior is **temporary rollout scaffolding for the remaining early testers**.
> 
> It is NOT:
> 
> - a general legacy-version compatibility system;
> - an archive-admission architecture;
> - a permanent migration policy;
> - a supported historical-installation taxonomy;
> - a foundation for future upgrades.
> 
> Once the remaining early testers have successfully installed the current release, this temporary pre-existing-folder check and deletion offer will itself be removed.
> 
> Document it accordingly.
> 
> # EXPUNGE the fingerprint/version-admission regime
> 
> Perform a repository-wide audit and remove the machinery whose purpose is to assign, recognize, compare, reject, or route MessageLens installations based on historical archive/version fingerprints.
> 
> The desired outcome is not “make the exceptions less visible.”
> 
> The desired outcome is:
> 
> > **The obsolete concepts cease to exist in production code.**
> 
> Search for and audit every reference to at least:
> 
> - `ArchiveAdmissionException`
> - `ArchiveAdmissionFailure`
> - `missingMarker`
> - `nonEmptyUnmarkedArchive`
> - `legacyTesterInstall`
> - `legacyTesterInstallDetected`
> - `LegacyTesterInstallInspector`
> - `ReadOnlySqliteLegacyTesterInstallInspector`
> - legacy `4/3/3` fingerprint constants;
> - table-fingerprint comparison;
> - schema-fingerprint comparison used for startup admission;
> - legacy tester archive access modes;
> - archive-version/fingerprint routing;
> - startup surfaces that expose archive-admission failures;
> - tests whose only purpose is to enforce this discarded regime;
> - documentation presenting the regime as permanent architecture.
> 
> **Do not merely leave these dormant. Remove them.**
> 
> # Archive identity: distinguish current ownership from historical fingerprinting
> 
> Do not blindly delete every use of the word `archive`.
> 
> Some current concepts may still have legitimate purposes unrelated to legacy-version detection, for example:
> 
> - one canonical MessageLens data root;
> - process locking;
> - attachment archive ownership;
> - Historical Archives;
> - source-scoped import identities;
> - mutation serialization;
> - current database paths.
> 
> Preserve those only if they serve a current product requirement.
> 
> But challenge any current requirement that says:
> 
> > “Before MessageLens can start, it must prove that this folder possesses some historical archive identity/version.”
> 
> For a Virgin install, that proposition is false by definition.
> 
> For this bounded tester cleanup, an old folder's contents are deliberately irrelevant.
> 
> # Archive marker audit
> 
> Determine whether `.messagelens-archive.json` and `ArchiveAccessAuthority` still serve a necessary **current-runtime ownership/safety purpose independent of historical version detection**.
> 
> If yes:
> 
> - retain only that minimal current purpose;
> - creation on a Virgin install must be ordinary initialization;
> - missing historical marker must never produce a user-facing legacy/version exception.
> 
> If their only remaining purpose is supporting the discarded admission/fingerprint regime, remove them.
> 
> Do not assume they must remain merely because many components currently reference them.
> 
> Trace the actual requirement.
> 
> # Exception cleanup
> 
> The tester should never again see:
> 
> `ArchiveAdmissionException(...)`
> 
> or:
> 
> `ArchiveAdmissionFailure...`
> 
> Those are internal implementation concepts that have leaked directly into the product.
> 
> If archive admission exceptions remain for genuinely necessary current safety checks, they must not carry the discarded historical/version taxonomy and must never be rendered raw to users.
> 
> Prefer deleting the obsolete exception hierarchy entirely if current root validation can use ordinary typed startup results.
> 
> # Startup simplification
> 
> Desired production startup should become conceptually:
> 
> `resolve canonical current MessageLens Application Support location`
> 
> then:
> 
> **folder absent**
> → Virgin initialization
> → Onboarding
> 
> **folder present during this temporary rollout**
> → ask whether to Trash old test data
> → Yes
> → Trash folder
> → Virgin initialization
> → Onboarding
> 
> There should be no intermediate:
> 
> - marker archaeology;
> - schema archaeology;
> - legacy fingerprint;
> - exact historical-version recognition;
> - archive-admission exception.
> 
> # Important current-installation consideration
> 
> Do not accidentally make every normal future launch offer to delete a successfully installed current MessageLens data folder.
> 
> This temporary compatibility path must have a simple bounded activation mechanism appropriate to this tester release.
> 
> Determine the smallest mechanism.
> 
> Examples might include:
> 
> - a release-scoped one-time compatibility flag;
> - presence/absence of a **current** installation completion fact created by this release;
> - another trivial current-generation indicator.
> 
> But do NOT recreate fingerprinting under another name.
> 
> The distinction needed is only:
> 
> > “Has this current release already successfully established its own installation?”
> 
> versus:
> 
> > “Did I arrive at this rollout with pre-existing MessageLens data?”
> 
> If even that requires elaborate persistent machinery, STOP. The fallback is to instruct the two remaining testers to manually Trash the folder.
> 
> # Development arm
> 
> Preserve the ordinary separation between:
> 
> - MessageLens Production data;
> - MessageLens Development data.
> 
> Do not reintroduce arbitrary roots or environment-override gymnastics for this feature.
> 
> Development testing should be comprehensible:
> 
> 1. prepare Development as though an old folder exists;
> 2. launch;
> 3. see the delete-old-data question;
> 4. confirm;
> 5. old Development data disappears;
> 6. current Virgin Onboarding begins.
> 
> If necessary, provide a tiny Development-only preparation script/command.
> 
> No synthetic archive identities.
> 
> No 4/3/3 databases.
> 
> No 37 GB clones.
> 
> # Existing current production data
> 
> The developer's own current production installation contains valuable state and must not be destroyed by this temporary tester behavior.
> 
> Before implementing the temporary folder-existence rule, prove how the developer's already-current installation is distinguished from a tester arriving with pre-release data.
> 
> This distinction must be simple and current-generation-based.
> 
> Do not inspect historical schema fingerprints to make it.
> 
> STOP if there is no simple safe distinction.
> 
> # Tests to REMOVE
> 
> Delete tests whose only purpose is to prove:
> 
> - exact April `4/3/3` recognition;
> - rejection because the old fingerprint is imperfect;
> - `missingMarker` legacy admission failure;
> - `nonEmptyUnmarkedArchive` fingerprint rejection;
> - legacy schema/table fingerprint routing;
> - obsolete archive access modes created for this regime.
> 
> Do not retain tests for behavior we explicitly no longer want.
> 
> # Tests to ADD/KEEP
> 
> Prove the simple requirements:
> 
> 1. no existing data folder → Virgin Onboarding;
> 2. temporary-rollout old folder exists → compatibility prompt;
> 3. Cancel changes nothing;
> 4. confirm moves/deletes only the MessageLens-owned folder;
> 5. Apple Messages untouched;
> 6. Contacts untouched;
> 7. external Historical Archive/donor sources untouched;
> 8. after cleanup → ordinary Virgin Onboarding;
> 9. successfully established current installation is never offered deletion on subsequent launch;
> 10. Development and Production remain isolated;
> 11. no raw internal exception reaches presentation;
> 12. repository contains no production reference to discarded 4/3/3 fingerprint logic;
> 13. repository contains no obsolete tester-version classifier;
> 14. startup does not inspect old DB schemas before offering cleanup.
> 
> # Repository-wide cruft removal
> 
> This is an authorized deletion pass.
> 
> Remove dead:
> 
> - classes;
> - enums;
> - providers;
> - access modes;
> - services;
> - exception cases;
> - presentation surfaces;
> - tests;
> - fixtures;
> - imports;
> - documentation;
> - architecture tripwires
> 
> that exist solely because of the over-engineered legacy/archive-version regime.
> 
> Do not preserve dead abstractions for hypothetical future use.
> 
> Git is the archive.
> 
> # Documentation
> 
> Create:
> 
> `30-TEMPORARY-EARLY-TESTER-DATA-FOLDER-CLEANUP-AND-ARCHIVE-FINGERPRINT-REGIME-REMOVAL.md`
> 
> Document:
> 
> - original actual requirement;
> - how the implementation expanded beyond it;
> - tester failures caused by that expansion;
> - exact concepts/classes removed;
> - what minimal current archive/root machinery remains and why;
> - temporary rollout behavior;
> - how current installations are protected;
> - Development test procedure;
> - explicit plan to remove the temporary cleanup prompt after the remaining testers install successfully.
> 
> Mark the temporary code clearly with a removal condition:
> 
> > Remove after the remaining April 2026 tester cohort has successfully installed the current MessageLens generation.
> 
> # Verification
> 
> Run:
> 
> - repository-wide searches for discarded concepts;
> - startup tests;
> - Virgin Onboarding tests;
> - current-installation startup tests;
> - temporary cleanup tests;
> - Development/Production isolation tests;
> - attachment/archive preservation tests that remain relevant;
> - Historical Archives tests;
> - mutation-authority tests that remain relevant;
> - architecture tripwires after obsolete ones are removed;
> - full Flutter suite;
> - `flutter analyze`;
> - formatting;
> - `git diff --check`;
> - macOS debug build.
> 
> # Stop conditions
> 
> STOP before implementation if:
> 
> - distinguishing the developer's current production installation from the two old tester folders requires historical fingerprinting;
> - simple folder cleanup cannot be safely bounded to MessageLens-owned Application Support;
> - moving to Trash requires a large new subsystem;
> - removing `ArchiveAdmissionException` or related machinery would weaken a genuinely current safety requirement that cannot be represented more simply;
> - this task begins generating another generalized compatibility framework.
> 
> If a stop condition is reached, recommend the fallback:
> 
> > Tell the remaining two testers exactly where the old MessageLens Application Support folder is and ask them to move it to Trash manually.
> 
> That fallback is preferable to another architectural regime.
> 
> # Final report
> 
> Return:
> 
> - exact temporary rollout rule;
> - how a current installation is protected from accidental deletion;
> - whether Trash or permanent deletion is used;
> - exact user-visible copy;
> - complete list of fingerprint/version-admission concepts removed;
> - any archive/root machinery retained and the concrete current requirement for each retained piece;
> - repository search proving obsolete concepts are gone;
> - tests removed;
> - tests added;
> - version/build;
> - documentation path;
> - commit hash;
> - worktree status;
> - exact instruction for the remaining two testers;
> - exact condition under which the temporary cleanup code itself should be deleted.
> 
> Acceptance standard:
> 
> > This release solves a temporary two-tester problem with a temporary two-tester solution. MessageLens does not attempt to identify, migrate, classify, fingerprint, or understand their obsolete data. It offers to remove the old MessageLens-owned folder and then behaves exactly as a new installation. The generalized historical archive/version-admission regime created for this problem is removed from the codebase rather than refined.

One thing I would **not** compromise on is the stop condition concerning your own production data. The simple solution is correct, but Codex must first demonstrate a trivial way to distinguish **“Rob's current valid installation”** from **“pre-existing data arriving with this rollout.”** If that distinction itself starts becoming elaborate, the correct answer is no code at all: send the remaining two testers one Finder path and be finished with it.

And the Signal screenshot is rather perfect empirical evidence: once the tester manually deleted Application Support, the next two messages were **“Works!”** and **“Great app.”** That is about as clear an acceptance test as we're likely to get.