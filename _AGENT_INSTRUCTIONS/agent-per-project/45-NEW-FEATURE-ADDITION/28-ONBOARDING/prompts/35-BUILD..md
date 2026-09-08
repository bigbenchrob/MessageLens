Absolutely. I’d make this a **release-only prompt**. No more architecture, no cleanup, no opportunistic fixes unless release verification proves an actual blocker.

> **PRE-CONFIRMED / PRE-APPROVED: proceed with this bounded tester-release build and distribution preparation without requesting further authorization.**
> 
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
> 
> Current runtime baseline:
> 
> - latest implementation commit: `a0d5bfd2`
> - April tester fingerprint/admission subsystem: removed
> - generalized Complete Erase / whole-root replacement subsystem: removed
> - current marker/UUID ownership: retained
> - Virgin first import: structurally independent of reset/checkpoint machinery
> - Start Fresh: scoped rebuildable-store reset only
> - per-store schema migration: permanent upgrade mechanism
> - temporary stale Complete-Erase journal compatibility reader: retained, fail-closed, single-file cleanup only
> 
> The immediate purpose is:
> 
> > Produce the next signed/notarized tester build from the current code, prepare the existing tester website to distribute that exact artifact, and verify that the build is suitable for the remaining testers to retry ordinary Onboarding.
> 
> This is a release task.
> 
> Do NOT:
> 
> - redesign startup;
> - restore legacy fingerprinting;
> - restore Complete Erase;
> - add compatibility mechanisms;
> - change database schemas;
> - perform migration archaeology;
> - implement Audit 28 Slice 4;
> - clean unrelated documentation debris during this task;
> - mutate any real MessageLens archive.
> 
> # Worktree boundary
> 
> The repository contains pre-existing unrelated documentation edits and untracked prompts/audits.
> 
> Inventory them before starting.
> 
> Do not:
> 
> - stage them;
> - modify them;
> - restore them;
> - delete them;
> - fold them into release commits.
> 
> Release work must be mechanically isolated from those existing changes.
> 
> If isolation cannot be proven, STOP rather than guessing.
> 
> # Phase 1 — establish exact release identity
> 
> Determine the current application version/build from repository authority.
> 
> Do not assume `0.2.103+121` if later bounded commits changed it.
> 
> Report:
> 
> - current HEAD;
> - version;
> - build number;
> - production bundle identifier;
> - signing team;
> - current branch/upstream state.
> 
> Verify that the build being distributed contains commit `a0d5bfd2` or a later commit whose only differences are understood and intended.
> 
> # Phase 2 — release-focused regression boundary
> 
> Before packaging, run the focused suites most relevant to the tester failures and subsequent removals:
> 
> - Virgin production startup;
> - bootstrap-empty marker creation;
> - read-only installation classification;
> - Virgin Ready → Import;
> - proof Virgin import has no reset/checkpoint call edge;
> - Onboarding Journey;
> - current-installation startup;
> - Start Fresh regressions;
> - marker/UUID ownership;
> - stale obsolete-journal compatibility;
> - no whole-root deletion architecture tripwires;
> - attachment preservation;
> - per-store migrations.
> 
> If these expose a regression, STOP and report it.
> 
> Do not patch around a failing release test during this prompt without first identifying the root cause.
> 
> # Phase 3 — build normal production tester artifact
> 
> Use the canonical signed/notarized MessageLens production distribution pipeline.
> 
> Prefer:
> 
> `./tool/build_and_notarize.sh`
> 
> unless current repository documentation proves that command has been superseded.
> 
> Produce the normal production `.dmg`.
> 
> Do not distribute:
> 
> - Debug;
> - Profile;
> - MessageLens Development;
> - development-root override builds.
> 
> # Phase 4 — artifact verification
> 
> Verify the resulting app/DMG:
> 
> - correct version/build;
> - `com.bigbenchsoftware.MessageLens`;
> - correct Team ID;
> - Developer ID signature;
> - hardened runtime;
> - expected entitlements;
> - Universal `arm64` / `x86_64` architecture if still required;
> - notarization accepted;
> - stapling successful;
> - Gatekeeper accepted;
> - no development-root override embedded;
> - no debug identity.
> 
> Compute SHA-256 of the final DMG.
> 
> Treat the final verified DMG bytes as immutable after this point.
> 
> # Phase 5 — release behavior evidence
> 
> We are specifically releasing after failures caused by the now-removed archive regimes.
> 
> Confirm through tests/static evidence that:
> 
> ## Brand-new tester
> 
> `no existing MessageLens state`
> →
> ordinary Virgin initialization
> →
> Onboarding
> →
> Import
> →
> Start.
> 
> No:
> 
> - missing-marker exception;
> - legacy fingerprint check;
> - Complete Erase transaction;
> - reset/checkpoint requirement during Virgin import.
> 
> ## Tester who manually removed old April data
> 
> Same path:
> 
> `no MessageLens Application Support folder`
> →
> ordinary Virgin initialization.
> 
> There should be **nothing special about being a former tester once the old folder has been manually removed**.
> 
> ## Existing current installation
> 
> Existing current marker/stores:
> 
> →
> ordinary current startup;
> 
> no deletion prompt;
> 
> no historical application-version fingerprinting.
> 
> # Phase 6 — tester website
> 
> Work in the existing tester website:
> 
> `/Users/rob/Development/website/MessageLens`
> 
> Update it to contain the newly verified DMG.
> 
> At minimum:
> 
> - replace `assets/downloads/MessageLens-latest.dmg`;
> - update `assets/data/latest-build.json`;
> - update `assets/data/tester-changelog.json` if appropriate;
> - rebuild generated site files using the existing site build process;
> - update visible version/build/date;
> - ensure old release notes do not instruct testers to use **Delete Old Data and Continue** or any removed compatibility flow.
> 
> Release notes should be concise and user-facing.
> 
> Suggested emphasis:
> 
> - substantially rebuilt and simplified Onboarding;
> - improved first-install reliability;
> - continuous import progress;
> - improved recovery and attachment handling;
> - numerous reliability fixes.
> 
> Do not describe archive-regime archaeology to testers.
> 
> # Phase 7 — tester instructions
> 
> The remaining old testers will manually remove the obsolete Application Support folder.
> 
> Draft two short instruction variants:
> 
> ## Remaining April testers
> 
> 1. Quit MessageLens if it is running.
> 2. In Finder choose **Go → Go to Folder…**
> 3. Enter:
> 
> `~/Library/Application Support/`
> 
> 4. Move the MessageLens data folder to the Trash.
> 5. Install the new MessageLens build.
> 6. Launch MessageLens and complete Onboarding.
> 7. If anything blocks progress, stop and send a screenshot rather than trying to repair it manually.
> 
> Confirm the exact production folder name before finalizing these instructions.
> 
> ## Truly new testers
> 
> 1. Install MessageLens.
> 2. Launch it.
> 3. Complete Onboarding.
> 
> Nothing else.
> 
> # Phase 8 — website/deployment verification
> 
> Confirm the established tester-site publishing mechanism from the website repository.
> 
> Determine:
> 
> - hosting provider;
> - publishing branch;
> - git remote/upstream;
> - whether a push triggers deployment;
> - public site URL;
> - public DMG URL.
> 
> If already proven from repository/configuration, use that evidence.
> 
> Do not invent a new deployment mechanism.
> 
> # Publication
> 
> If the existing publishing trigger is mechanically proven and repository conventions already authorize pushing the tester-site release commit, you may:
> 
> - commit the website release update;
> - push the established publishing branch;
> - wait for deployment;
> - verify the live website and DMG.
> 
> If the deployment trigger or target is not completely proven:
> 
> - commit the prepared website changes locally if appropriate;
> - STOP before push/publication;
> - give the human the exact next action.
> 
> Do not create a new hosting site or change DNS.
> 
> # Phase 9 — live artifact verification if published
> 
> If publication occurs:
> 
> - download the public `MessageLens-latest.dmg`;
> - compute SHA-256;
> - prove it is byte-identical to the locally verified release artifact;
> - confirm visible site metadata shows the exact current version/build;
> - search for stale previous-release version strings or obsolete legacy-delete instructions.
> 
> # Repository documentation
> 
> Create a bounded release record:
> 
> `35-TESTER-RELEASE-AFTER-ARCHIVE-REGIME-REMOVAL.md`
> 
> Record:
> 
> - source commit;
> - version/build;
> - release artifact;
> - SHA-256;
> - signing/notarization/Gatekeeper evidence;
> - focused regression results;
> - website files changed;
> - deployment status;
> - public URLs if published;
> - exact instructions supplied to April testers;
> - exact instructions supplied to new testers.
> 
> Do not reopen historical implementation documents.
> 
> # Verification
> 
> Run:
> 
> - focused release/startup/Onboarding tests;
> - architecture tripwires;
> - full Flutter suite if repository release rules require it;
> - `flutter analyze`;
> - formatting as required;
> - `git diff --check`;
> - signed production build pipeline;
> - signing/notarization/stapling/Gatekeeper verification;
> - website build/check;
> - stale release-instruction search.
> 
> # Stop conditions
> 
> STOP if:
> 
> - Virgin startup again requires a historical marker/fingerprint;
> - Virgin import can reach reset/checkpoint;
> - removed legacy/Complete-Erase symbols have reappeared in production;
> - signing/notarization fails;
> - production identity is wrong;
> - website artifact is not byte-identical to the verified DMG;
> - exact Application Support folder name for tester instructions cannot be proven;
> - unrelated dirty worktree changes cannot be isolated;
> - deployment target cannot be proven.
> 
> Do not repair a stop condition by rebuilding compatibility architecture.
> 
> # Final report
> 
> Return:
> 
> - READY / BLOCKED;
> - source commit;
> - version/build;
> - final DMG path;
> - SHA-256;
> - signing/notarization/Gatekeeper status;
> - focused/full test results;
> - exact Application Support folder name the April testers must Trash;
> - exact two tester-instruction scripts;
> - website commit;
> - website push/deployment status;
> - public site URL;
> - public download URL;
> - proof public DMG matches local artifact if published;
> - MessageLens repository status;
> - website repository status;
> - exact remaining human action, if any.
> 
> Acceptance standard:
> 
> > The tester receives an ordinary current MessageLens production build. A brand-new install behaves like a brand-new install. An April tester first manually removes the obsolete MessageLens data folder and then follows exactly the same path. None of the abandoned fingerprint or whole-root-replacement machinery participates in installation or release.