# MessageLens Feature 34
## 75 — Rerun Isolated AppCzar Onboarding Human Qualification After Canonical-Root Fix

Prompt 74 corrected the pre-AppCzar development-override admission defect found
by Prompt 73.

The failed Prompt 73 experiment proved:

```text
raw override
    /private/tmp/.../safe-empty

native canonical root
    /tmp/.../safe-empty

Dart canonical root
    /private/tmp/.../safe-empty

exact-root agreement
    FAILED

result
    ArchiveAdmissionFailure.nonCanonicalRoot
```

Prompt 74 corrected native development-override canonicalization to POSIX
`realpath` semantics while preserving independent Dart derivation and exact
root equality.

Prompt 74 validation established:

```text
PROMPT 73 FAILURE WAS PRE-APPCZAR ARCHIVE ADMISSION: YES

NATIVE AND DART NOW DERIVE THE SAME DEVELOPMENT OVERRIDE ROOT: YES

INDEPENDENT EXACT-ROOT AGREEMENT IS STILL ENFORCED: YES

PRODUCTION DEVELOPMENT-OVERRIDE REJECTION IS UNCHANGED: YES

VALID DISPOSABLE DEVELOPMENT ROOTS CAN BE ADMITTED: YES

APPCZAR ONBOARDING SEMANTICS CHANGED: NO

PROJECT CONFORMANCE: PASS
```

This task reruns the human qualification that Prompt 73 could not reach.

This is a qualification task only.

Do NOT modify source/tests.
Do NOT stage, commit, push, merge, rebase, or rebuild.
Do NOT launch production MessageLens.
Do NOT use the populated development archive as the qualification root.
Do NOT access or mutate the active Toshiba attachment archive.
Do NOT bypass or relax canonical-root admission.
Do NOT authorize Attachment Archive Repair if it appears after the disposable
initial build.

---

# 1. Exact repository and artifact preflight

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `cc5847c1e311ef9b81a3223e1be2388429e4e02b`;
- ahead/behind `0/0`;
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree.

Verify these commits are ancestors of HEAD:

- Prompt 73 failed-qualification checkpoint:
  `3d06155f9583231253cd49068f93779691ca3bcd`
- Prompt 74 implementation:
  `182d96812dc6c96e14387d5af51c235d41d0de0b`

Use exactly:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected artifact:

- product/display/executable:
  `MessageLens Development`
- bundle identifier:
  `com.bigbenchsoftware.MessageLens.development`
- version/build:
  `0.2.140 (158)`
- executable SHA-256:
  `fc884969590b34b358ad9c45c233012f1ca9bbf0a0203cbbad68119414b9f882`
- `App.framework/App` SHA-256:
  `46374aa98731246b1f4758b23dc6cba04848fed35c8066a09021e73035c2fa0c`

If either hash differs, STOP AND REPORT.

Do not rebuild.

Confirm:

- no `MessageLens Development` process is running;
- the production app PID `801`, if still present, is left untouched;
- `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty before setup.

---

# 2. Reconfirm the corrected admission contract from source

Before creating fixtures, perform a narrow source read to reconfirm the Prompt 74
contract remains present:

```text
development override present
-> native independently realpath-canonicalizes
-> Dart independently filesystem-canonicalizes
-> exact equality required
-> production override still rejected
```

Do not rerun the entire Prompt 74 audit.

Record the exact production methods/files involved and confirm no subsequent
commit changed their semantics.

---

# 3. Create fresh disposable qualification roots

Do NOT reuse Prompt 73's old fixture roots.

Create a unique new parent, for example:

`/private/tmp/messagelens-appczar-onboarding-qualification-<timestamp>/`

with isolated children:

```text
safe-empty/
unsafe-partial/
```

Use the same reviewed current project fixture/admission seam from Prompt 73/74
or a safer equivalent now present in source.

Requirements:

- current development archive marker/identity;
- current schema APIs;
- fixture-local attachment archive only;
- no copied real MessageLens database;
- no real archive path;
- no symlink into a real archive;
- each fixture gets a distinct archive instance UUID.

Before launch, resolve and record each absolute path after canonicalization.

Hard guards:

```text
safe fixture != real WD development root
unsafe fixture != real WD development root
safe attachment archive != Toshiba active archive
unsafe attachment archive != Toshiba active archive
```

Do not list, inspect, or copy the populated WD development root beyond a simple
existence/path inequality guard.

---

# 4. SAFE fixture construction

Construct a current admitted development root whose initial-construction facts
are affirmatively safe.

Expected physical shape:

```text
current development archive marker
fixture-local attachment_archive/
no source-scoped import database
no conversation graph database
no consequential partial rows
no non-live/historical source material
no retired derived artifact
no corrupt store
no overlay requirement merely to prove emptiness
```

If current code prefers current healthy-empty import/graph stores instead of
absence, that is acceptable only if the typed initial-scope reader classifies the
shape `safeEmpty`.

Before launch, record:

- resolved fixture root;
- archive UUID;
- marker environment/format;
- import-store presence/count;
- graph-store presence/count;
- non-live-source count;
- retired-artifact status;
- expected `InitialConstructionScopeObservation`.

No manual schema invention.

---

# 5. Human-visible permission preflight

Record the visible Full Disk Access setting for the exact
`MessageLens Development.app`.

Treat the toggle only as configuration.

Do not change FDA unless Onboarding naturally reaches a source-readability
prerequisite requiring human action.

The development app may read the user's normal Apple Messages and Contacts
sources.

It must not write them.

---

# 6. Configure SAFE fixture launch contract

Set:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "<SAFE_FIXTURE_ROOT>"
```

Verify exact readback.

Also record the canonicalized form expected by the corrected admission contract.

Before launch confirm:

- no MessageLens Development process is running;
- selected root is the safe fixture;
- selected root is not the WD development root;
- selected root is not nested in another MessageLens root;
- fixture archive is not Toshiba.

---

# 7. SAFE Experiment A — archive admission must succeed

Direct-launch the exact artifact:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record PID.

First prove Prompt 74 fixed the original failure:

```text
archive admission succeeds
-> no nonCanonicalRoot alert
-> AppCzar begins
```

If `nonCanonicalRoot` or another archive-admission failure occurs, STOP AND
REPORT.

Do not bypass it.

---

# 8. Fresh AppCzar must select Onboarding

Allow fresh AppCzar to gather current evidence.

Required:

```text
safe initial-construction scope TRUE
no complete local dataset
-> AppCzar Onboarding
```

Record any visible factual assessment rows and the exact Onboarding screen.

There must be:

- no legacy Journey rail;
- no Environment Readiness semantic authority;
- no Source Access Repair solely because the dataset is absent;
- no Local Data Repair;
- no Diagnostic Review unless a genuinely unknown/conflicting fact appears;
- no Conversations workspace.

If safe-empty current evidence does not select Onboarding, STOP AND REPORT.

---

# 9. Messages prerequisite behavior

Record the actual current branch.

## If source readable

Report:

```text
Messages prerequisite: satisfied
```

and continue.

## If conclusive source unreadable

Onboarding must retain jurisdiction.

Required:

```text
same Onboarding occurrence
-> literal source-readability prerequisite
-> no Source Access Repair handoff
```

Use the existing human action only if naturally required.

`Check Again` must be explicit/single-flight.

If successful and the same jurisdiction remains valid:

```text
same PID / same Onboarding occurrence
-> prerequisite rechecked
-> continue self-location
```

Do not claim FDA state from readability.

## If source UNKNOWN

Expected:

```text
Onboarding stop/drain
-> real restart
-> fresh AppCzar
-> Diagnostic Review
```

STOP the safe-build qualification and report the literal evidence.

Do not force an FDA branch if source is already readable.

---

# 10. Contacts prerequisite behavior

Record the exact typed current Contacts result.

Acceptable satisfied outcomes:

```text
viableWithContacts
viableEmpty
```

If a conclusive human-remediable prerequisite occurs:

```text
same Onboarding occurrence
-> literal Contacts condition
-> human action if supported
-> Check Again
```

If current evidence is invalid/corrupt/UNKNOWN/conflicting:

```text
stop/drain
-> restart
-> fresh AppCzar
```

Do not alter real Contacts data.

Do not call Contacts optional.

---

# 11. Onboarding self-location and build admission

Once prerequisites are satisfied, record the in-memory Onboarding transition.

Expected conceptual path:

```text
checkingPrerequisites
-> all current prerequisites satisfied
-> one admitted initial build
```

Verify the product does not wait on obsolete Journey ceremony if Response 72
removed it.

Record whether initial build begins automatically or after a still-valid
same-session user action.

There must be exactly one build admission.

---

# 12. Observe the initial build

Record:

- PID;
- visible factual stage labels;
- message import progress if shown;
- Contacts stage if shown;
- rich-text stage if shown;
- graph projection stage if shown;
- any error/warning.

The execution path must remain:

```text
AppCzar Onboarding
-> ConversationGraphBuildController.runOnce()
-> existing graphBuild mutation tenure
-> existing service/orchestrator
-> existing importers/projectors
```

Do not infer worker identity only from UI. Corroborate from source/log evidence
if available without changing code.

There must be:

- no cleanup/reset;
- no second importer;
- no Start Fresh;
- no Attachment Archive Repair inside Onboarding;
- no normal application UI.

---

# 13. Build-success process boundary

When the initial worker completes, observe carefully.

Required:

```text
worker completes
-> graphBuild tenure releases
-> Onboarding stops/drains
-> old PID disappears
-> fresh PID starts
-> fresh AppCzar assesses from current durable facts
```

Record:

- old PID;
- last Onboarding status observed;
- old PID disappearance;
- new PID;
- whether a no-process interval is observed;
- first fresh AppCzar facts/disposition.

Forbidden:

```text
old PID
-> "Ready to Start"
-> Conversations
```

If normal Operating UI appears, it must belong to a new PID after fresh AppCzar.

---

# 14. Accept the truthful fresh post-build jurisdiction

The safe fixture does not need to end in Operating.

Accept the current facts.

Possible fresh dispositions include:

```text
Data Update
Attachment Archive Repair
Operating
Local Data Repair
Diagnostic Review
```

Record exactly what fresh AppCzar selects and why.

If Attachment Archive Repair appears:

- allow the read-only partition to settle;
- record the factual counts;
- DO NOT authorize a preservation batch.

The qualification criterion is fresh authority, not a predetermined final state.

---

# 15. Durable SAFE-fixture verification

After fresh AppCzar has classified the result, inspect only the disposable safe
fixture with bounded read-only methods.

Record:

- `macos_import_ss.db` presence and message count;
- source ledger/high-water if useful;
- `working_ss.db` presence and message/chat/edge counts;
- archive marker/UUID;
- overlay/configuration stores created as ordinary consequences;
- any fixture-local attachment metadata/state;
- absence of any durable Journey cursor used to resume/finish Onboarding.

Do not inspect the real development data root.

---

# 16. Onboarding stopAndDrain corroboration

From the live safe experiment, record evidence that:

- no stale Onboarding progress appears under the replacement PID;
- no second initial build auto-starts after restart;
- old PID is gone before fresh AppCzar owns the next jurisdiction;
- no same-process semantic completion handoff occurred.

Do not deliberately terminate the app mid-build.

Automated tests remain the proof for interrupted-worker draining.

---

# 17. End SAFE experiment

Quit any remaining development process normally.

Verify no development process remains.

Unset:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

Verify empty.

Preserve the safe fixture until Response 75 is written.

---

# 18. Construct CONSEQUENTIAL PARTIAL fixture

Create a fresh isolated unsafe fixture.

The purpose is not corruption.

It must contain **valid but consequential partial derived data** sufficient to
make Stage One unsafe.

Preferred shape:

```text
current development marker
+ current source-scoped import database
+ at least one valid live-source imported message row
+ graph absent or incomplete
+ no non-live source required for this test
```

Use current schema/project APIs.

Do not manually invent SQLite schema.

Before launch record:

- fixture root;
- archive UUID;
- import DB schema version;
- message count;
- live-source count;
- non-live-source count;
- graph presence/count;
- exact `InitialConstructionScopeObservation` expected;
- SHA-256/fingerprint of the consequential import store.

---

# 19. Configure CONSEQUENTIAL PARTIAL fixture

Set the launchd override to the unsafe fixture.

Verify exact readback and canonicalized value.

Confirm:

- no development process running;
- fixture != WD root;
- fixture archive != Toshiba;
- before-launch import DB fingerprint/count captured.

---

# 20. Experiment B — AppCzar must refuse Onboarding

Direct-launch the same exact artifact.

Record PID.

Archive admission must first succeed.

Then allow fresh AppCzar assessment.

Required:

```text
consequential partial derived data
-> safe initial-construction scope FALSE
-> NOT Onboarding
```

Expected current destination is likely virtual:

```text
Local Data Repair
```

or, if current facts are insufficient/conflicting:

```text
Diagnostic Review
```

Record exact facts and disposition.

If Onboarding executes, STOP and report FAIL.

---

# 21. Prove no build or cleanup on partial data

Do not click any repair action.

Observe long enough to establish the selected virtual disposition is stable.

Verify:

- no Onboarding controller;
- no graph-build worker;
- no reset/cleanup;
- no import deletion;
- no graph deletion;
- no Start Fresh;
- no normal workspace.

Quit normally.

After quit, inspect only the unsafe fixture.

Require:

```text
before import fingerprint == after import fingerprint
message count unchanged
live-source count unchanged
graph state unchanged
```

If any consequential derived data was automatically deleted or rebuilt,
qualification FAILS.

---

# 22. Optional protected non-live extension

Only if an existing fixture helper makes this trivial and safe, construct a third
disposable fixture containing protected non-live/historical imported material.

Expected:

```text
protectedNonLiveData
-> NOT Onboarding
```

Do not manually manipulate complex schema solely for this optional subtest.

If not exercised, report:

`NOT EXERCISED`.

---

# 23. Fair-Witness review

Across both required experiments confirm:

- safe-empty scope is positively established;
- safe-empty + source FALSE, if observed, stays Onboarding;
- source UNKNOWN is not called denial;
- Contacts zero is not called failure;
- Contacts failure taxonomy remains literal;
- build success is not called Operating success;
- fresh process owns the post-build disposition;
- partial data is not called empty or disposable;
- no prior Journey result/cursor selects present state;
- failed Prompt 73 state is not remembered as authority.

---

# 24. Cleanup

At the end:

1. quit all MessageLens Development processes;
2. verify none remain;
3. unset `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`;
4. verify empty;
5. leave FDA in its intended pre-test state;
6. do not modify/stage/commit source/tests;
7. do not touch production PID `801`;
8. preserve both fixture roots until Response 75 is written.

Do not access or mutate the real WD development data or Toshiba archive beyond
path inequality/existence guards.

---

# 25. Qualification verdict

A full PASS requires both:

## A — Safe empty

```text
archive admission succeeds
-> fresh AppCzar
-> Onboarding
-> existing build pipeline
-> real process restart
-> fresh AppCzar owns next disposition
```

## B — Consequential partial

```text
archive admission succeeds
-> fresh AppCzar
-> NOT Onboarding
-> no cleanup
-> no build
-> consequential fixture data unchanged
```

Messages/Contacts human-remediation branches may be NOT EXERCISED if they do
not arise naturally.

---

# 26. Required response

Create Response 75 and report:

1. exact Git HEAD/upstream state;
2. Prompt 74 implementation ancestry;
3. exact artifact/hash verification;
4. corrected canonical-root contract reconfirmation;
5. fresh fixture-construction seam;
6. safe fixture absolute/canonical path;
7. safe fixture archive identity;
8. proof safe fixture isolation;
9. FDA preflight;
10. safe launchd raw/canonical value;
11. Experiment A PID;
12. archive-admission result;
13. fresh AppCzar initial-scope facts;
14. Onboarding selection result;
15. Messages prerequisite result;
16. Contacts prerequisite result;
17. Onboarding self-location result;
18. build-admission behavior;
19. visible build stages/progress;
20. proof existing pipeline was used;
21. proof no cleanup/reset occurred;
22. old Onboarding PID terminal behavior;
23. replacement PID;
24. fresh post-build AppCzar disposition;
25. proof no same-process Operating handoff;
26. safe fixture durable import/graph result;
27. proof no durable Journey cursor;
28. stopAndDrain live corroboration;
29. unsafe fixture construction method;
30. unsafe fixture absolute/canonical path;
31. unsafe archive identity;
32. exact consequential partial facts;
33. unsafe launchd raw/canonical value;
34. Experiment B PID;
35. unsafe archive-admission result;
36. unsafe initial-scope classification;
37. Local Data Repair / Diagnostic Review result;
38. proof Onboarding did not execute;
39. proof graph build did not execute;
40. proof cleanup/reset did not execute;
41. unsafe before/after fingerprint/count result;
42. optional protected-non-live result;
43. Fair-Witness verdict;
44. errors/warnings/evidence limitations;
45. cleanup result;
46. overall Onboarding Stage One human qualification verdict;
47. recommendation for checkpointing;
48. readiness for Local Data Repair milestone;
49. readiness for Diagnostic Review milestone;
50. readiness for production AppCzar cutover.

Conclude exactly:

`CORRECTED DISPOSABLE ROOT PASSED ARCHIVE ADMISSION: YES / NO`

`SAFE EMPTY FIXTURE SELECTED APPCZAR ONBOARDING: YES / NO / NOT REACHED`

`INITIAL BUILD USED THE EXISTING PIPELINE: YES / NO / NOT REACHED`

`INITIAL BUILD ENDED AT A REAL PROCESS BOUNDARY: YES / NO / NOT REACHED`

`FRESH APPCZAR OWNED THE POST-BUILD DISPOSITION: YES / NO / NOT REACHED`

`CONSEQUENTIAL PARTIAL FIXTURE WAS REFUSED BY ONBOARDING: YES / NO / NOT REACHED`

`NO CLEANUP OR BUILD OCCURRED ON CONSEQUENTIAL PARTIAL DATA: YES / NO / NOT REACHED`

`APPCZAR ONBOARDING HUMAN LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`READY TO CHECKPOINT ONBOARDING HUMAN QUALIFICATION: YES / NO`

`READY FOR LOCAL DATA REPAIR MILESTONE: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
