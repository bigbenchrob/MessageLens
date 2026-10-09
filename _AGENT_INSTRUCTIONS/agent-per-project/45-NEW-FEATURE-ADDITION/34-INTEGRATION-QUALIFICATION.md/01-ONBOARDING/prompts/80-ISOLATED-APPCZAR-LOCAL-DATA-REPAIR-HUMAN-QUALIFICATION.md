# MessageLens Feature 34
## 80 — Isolated AppCzar Local Data Repair Human Qualification

Response 79 implemented the narrow executable AppCzar Local Data Repair Stage One
and passed automated/conformance validation.

The implemented safety contract is deliberately strict:

```text
rebuildableLiveOnlyPartial
    -> the sole executable Local Data Repair class

protectedMaterialPresent
sourceFactMissing
retiredArtifactsPresent
unsupportedOrCorrupt
unknown
    -> NO destructive Local Data Repair
```

Destructive repair now requires:

```text
current schema-wide reconstructibility TRUE
+ protected historical/non-live material absent
+ stable current Messages / Contacts evidence
+ exact archive/source/evidence binding
+ fresh immediate revalidation
-> one typed localDataRepair Ball tenure
-> reset exact active derived-store footprint
-> physical reset postcondition
-> release Ball
-> stop/drain
-> real restart
-> fresh AppCzar
```

This task human-qualifies that contract using **disposable fixtures only**.

There are four required experiments:

```text
A. exactly reconstructible live-only partial
   -> executable Local Data Repair
   -> physical reset
   -> real restart
   -> fresh AppCzar

B. live provenance but one required local fact is absent from current source
   -> reconstructibility FALSE
   -> NO reset

C. protected historical/non-live material
   -> NO whole-store reset

D. corrupt/unknown repair safety
   -> Diagnostic Review
   -> NO reset
```

Do NOT modify source/tests.
Do NOT rebuild.
Do NOT launch production MessageLens.
Do NOT point the development app at the real WD development root.
Do NOT access or mutate the active Toshiba attachment archive.
Do NOT use human consent to override FALSE/UNKNOWN repair safety.
Do NOT manually invoke the Local Data Repair controller.
Do NOT create partial SQL surgery for historical sources.

---

# 1. Repository and documentation preflight

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`;
- tracked worktree clean before qualification;
- index clean;
- ahead/behind `0/0`;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree.

Verify implementation commit is in ancestry:

`ceb12fef80b51c8cc340cca196d5e427419f084f`

Resolve the actual current HEAD/upstream from Git.

Prompt 79 / Response 79 form the implementation documentation checkpoint but
Response 79 cannot embed its own final documentation commit hash.

Before live qualification:

- if Prompt 79 / Response 79 are already committed and pushed, record the exact
  documentation commit and do not duplicate it;
- if they remain untracked, create the narrow documentation checkpoint now and
  push normally;
- do not stage unrelated untracked files.

No force push, rebase, squash, merge, or unrelated staging.

---

# 2. Exact artifact under test

Use exactly:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected:

- product/display/executable:
  `MessageLens Development`
- bundle identifier:
  `com.bigbenchsoftware.MessageLens.development`
- environment/build identity:
  `development / developmentDebug`
- version/build:
  `0.2.142 (160)`
- executable SHA-256:
  `639a3036283fb447402d2e10295d57b9a0d6feb2fdc110f0a927555b963d203a`
- `App.framework/App` SHA-256:
  `5b2fffe9e2f0bf9f62667ebc87b0f16e634932fd1f30a9f01c8da6e922e3346f`

If either hash differs, STOP AND REPORT.

Do not rebuild.

Confirm:

- no `MessageLens Development` process is running;
- production MessageLens, if running, remains untouched;
- `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty.

---

# 3. Reconfirm the Stage One contract from source

Perform a narrow source reconfirmation only.

Require:

```text
Local Data Repair executable class:
    rebuildableLiveOnlyPartial only

fresh repair-safety revalidation:
    before Ball acquisition

mutation:
    exactly one ArchiveMutationOperation.localDataRepair tenure

lower reset:
    resetActiveDerivedDataForLocalDataRepair
    active import + graph families only
    retired artifacts excluded

postcondition:
    target footprint absent
    preserved top-level evidence unchanged

terminal:
    release Ball
    drain
    real restart
    fresh AppCzar
```

Also reconfirm:

```text
Diagnostic Review remains virtual

protected/source-missing/retired/corrupt/unknown classes cannot mutate
```

Do not rerun the whole Prompt 79 audit.

---

# 4. Qualification observer

Local Data Repair may execute and restart quickly.

Before the first live experiment, establish a temporary external qualification
observer outside the repository that records, for the disposable fixture only:

- timestamp;
- MessageLens Development PID(s);
- existence of `macos_import_ss.db`;
- existence of its WAL/SHM sidecars;
- existence of `working_ss.db`;
- existence of its WAL/SHM sidecars;
- fixture marker UUID;
- hashes of selected preservation sentinels.

Use a bounded polling/logging method or another safe existing observer.

The observer:

- is read-only;
- must not modify app data;
- must not run against the real WD root;
- is qualification evidence only;
- must be stopped at cleanup.

Its purpose is to corroborate the reset/restart boundary if the fresh process
recreates derived stores quickly.

If no safe external observer can be established, continue only if application
logs plus fixture evidence can still prove the required physical boundary
without inference. Otherwise STOP AND REPORT.

---

# 5. Fresh disposable fixture parent

Do not reuse prior qualification fixtures.

Create a new unique parent, for example:

`/private/tmp/messagelens-appczar-local-repair-qualification-<timestamp>/`

with isolated roots:

```text
A-reconstructible/
B-source-missing/
C-protected-history/
D-corrupt-unknown/
```

Use current project fixture/schema APIs.

Requirements for every fixture:

- current development archive marker/identity;
- fixture-local `attachment_archive/`;
- unique archive UUID;
- no symlink into another archive;
- no copied real MessageLens database;
- no real MessageLens archive path;
- no use of Toshiba attachment archive;
- no manual invention of the SQLite schema.

Path guards:

```text
all fixture roots != real WD development root
all fixture attachment archives != Toshiba active archive
```

The real WD/Toshiba locations may receive only simple existence/path-inequality
guards.

---

# 6. Current-source fixture seam audit

Experiments A and B depend on the **current authoritative Messages source**.

Before constructing them, source-audit the exact Response 79 fixture/test seam
used to create reconstructible and source-missing partial data.

Prefer an existing test/helper or external qualification harness using current
project APIs.

For Fixture A, select the minimum current live source facts needed for the
narrow executable class.

Important:

- use source IDs/keys/projections only;
- do not record or report private message text;
- do not copy `chat.db`;
- read Apple Messages and AddressBook only through current read-only project
  seams;
- create the local partial fixture through current import-schema APIs.

If no reviewed seam can construct a genuinely Response-79-TRUE fixture without
manual schema fabrication, STOP AND REPORT.

---

# 7. Source-readability preflight

Record the human-visible FDA state for the exact development app.

Treat it only as configuration.

Fixture A requires current authoritative source evidence to be readable and
stable.

If the app later reports source unreadability/UNKNOWN before Local Data Repair
can be selected:

- do not interpret that as repair failure;
- perform only the already-qualified ordinary permission repair;
- discard/recreate Fixture A if its binding/evidence was generated before the
  permission/process change;
- rerun from a fresh fixture once current app source evidence is readable.

Do not weaken repair safety merely to get the test to run.

---

# 8. Fixture A — construct exact rebuildable live-only partial

Construct the narrowest fixture that current source and Response 79 prove is:

`rebuildableLiveOnlyPartial`

The fixture must satisfy the actual Stage One reader, not merely resemble it.

Expected conceptual shape:

```text
current development marker
fixture-local attachment archive

macos_import_ss.db:
    current schema
    canonical live Messages source identity
    canonical live AddressBook source identity
    small consequential live-only subset
    every populated destructive-domain fact still present/reconstructible
    in the current authoritative source NOW
    no non-live/historical source
    no retired artifacts

working_ss.db:
    absent or exact graph-empty shape required by Stage One
```

Use the minimum source-backed subset that exercises the current schema-wide proof.

Before launch record:

- raw/canonical fixture root;
- archive UUID;
- exact populated table counts;
- live/non-live source inventory;
- graph state;
- import DB SHA-256;
- preservation sentinel hashes;
- expected safety class;
- expected `mayResetDerivedStores == TRUE`.

Do not report message body/content.

---

# 9. Fixture A — configure development root

Set:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "<A_FIXTURE_ROOT>"
```

Verify exact readback and canonical form.

Confirm:

- no development process running;
- fixture != WD root;
- fixture archive != Toshiba;
- external qualification observer is pointed only at Fixture A.

---

# 10. Experiment A — AppCzar selects executable Local Data Repair

Direct-launch the exact artifact.

Record initial PID.

Required:

```text
archive admission
-> AppCzar composition
-> current safety evidence
-> rebuildableLiveOnlyPartial
-> Local Data Repair executable
```

Record visible factual classification/presentation.

There must be no:

- Onboarding;
- Operating;
- Journey;
- Start Fresh;
- historical-source removal;
- manual repair invocation.

Because Response 78/79 selected automatic repair for this exact class, the
coordinator may proceed without a human confirmation.

If it does not select the executable class, STOP and report the current facts;
do not force mutation.

---

# 11. Experiment A — pre-mutation revalidation

Observe the transition through fresh safety revalidation.

Record any visible phase such as:

```text
revalidating current repair safety
```

Corroborate from fixture-local log evidence where available.

Required:

```text
fresh proof still TRUE
exact occurrence/binding still current
-> mutation may begin
```

If evidence changed/staled:

```text
NO mutation
-> drain/restart
```

and the qualification does not proceed as a successful A case.

---

# 12. Experiment A — destructive reset

Allow the automatic disposable-fixture repair to execute.

Observe/record:

- PID;
- repair phase/status;
- any file-existence changes from the external observer;
- any error/warning.

Required mutation footprint:

```text
active macos_import_ss database family
active working_ss database family
```

only.

Forbidden:

- marker deletion/change;
- overlay deletion/change;
- Presence deletion/change;
- attachment archive deletion/change;
- retired-artifact cleanup;
- historical-source mutation;
- Apple source mutation;
- unrelated fixture-root deletion.

Do not interrupt mutation.

---

# 13. Experiment A — physical postcondition

Before interpreting any semantic result, establish the physical reset evidence.

Use the external observer, app logs, and bounded fixture inspection.

Require evidence that the authorized active derived footprint reached its reset
terminal and the preservation witnesses remained unchanged.

Record:

- target DB/WAL/SHM terminal evidence;
- marker UUID before/after;
- preservation sentinel hashes before/after;
- fixture attachment archive sentinel before/after.

Do not call this semantic repair success.

The only claim is:

```text
authorized physical reset footprint reached its terminal
```

---

# 14. Experiment A — real restart boundary

Required:

```text
Local Data Repair mutation/postcondition completes
-> Ball releases
-> old PID ends
-> fresh PID starts
-> fresh AppCzar
```

Record:

- old repair PID;
- disappearance;
- replacement PID;
- observable no-process interval if available;
- first fresh AppCzar presentation/disposition.

There must be no same-process handoff to Onboarding.

If fresh AppCzar selects Onboarding and automatically starts a new initial build,
that is allowed. Record it as a **new jurisdiction in the replacement process**.

Do not confuse any newly recreated derived databases with failure of the earlier
physical reset; use the observer timeline to distinguish them.

---

# 15. Experiment A — accept the truthful next jurisdiction

Fresh AppCzar decides the next state.

Likely possibilities include:

```text
Onboarding
Source Access Repair
Diagnostic Review
another current truthful disposition
```

If Onboarding automatically begins the full initial build, allow it to reach a
safe natural boundary rather than killing active mutation.

Do not authorize Attachment Archive Repair if a later post-build process reaches
it.

The Local Data Repair qualification requires only that fresh AppCzar—not the
repair coordinator—owns the next semantic decision.

---

# 16. End Experiment A

When all active work has settled:

- quit any remaining development process normally;
- confirm no process remains;
- unset the development root override;
- verify it is empty;
- stop Fixture A observer;
- preserve Fixture A and its observer log until Response 80 is written.

---

# 17. Fixture B — live provenance but missing current source fact

Construct a fresh isolated fixture using the current schema APIs whose local
row(s):

- carry canonical live-source provenance;
- are consequential;
- are structurally valid enough to inspect;
- but include at least one required source identity/fact that is **not present**
  in the current authoritative source.

Use the Response 79 tested `sourceFactMissing` pattern.

Do not mutate Apple Messages to create the absence.

Prefer a fixture-local source ROWID/GUID pair that current source comparison can
conclusively prove absent.

Before launch record:

- exact local counts;
- source inventory;
- graph state;
- import SHA-256;
- preservation sentinels;
- expected class:
  `sourceFactMissing`;
- expected:
  `mayResetDerivedStores == FALSE`.

---

# 18. Experiment B — prove provenance is insufficient

Configure the override to Fixture B and launch the exact artifact.

Required:

```text
archive admission
-> AppCzar composition
-> live provenance observed
-> current anti-difference fails
-> sourceFactMissing
-> NO destructive Local Data Repair
```

Record the exact visible diagnosis/disposition.

Expected under Response 79:

```text
Diagnostic Review
```

or the exact non-mutating virtual destination implemented by the evaluator.

Do not click or authorize anything.

Observe long enough to prove no reset begins.

Quit normally.

After quit require:

```text
before import SHA == after import SHA
counts unchanged
graph state unchanged
preservation sentinels unchanged
```

---

# 19. Fixture C — protected historical/non-live material

Construct a fresh current-schema fixture using the project's historical/non-live
source representation.

Required shape:

```text
incomplete/consequential local derived state
+ at least one protected non-live/historical source/fact
```

Use current source-registration/import APIs.

Do not manually invent historical source schema.

Record:

- exact protected source identity/type without exposing unrelated content;
- live/non-live counts;
- graph state;
- import SHA;
- expected class:
  `protectedMaterialPresent`.

---

# 20. Experiment C — protected data blocks whole-store reset

Launch against Fixture C.

Required:

```text
protected non-live/historical material present
-> whole-store reset NOT authorized
-> no Local Data Repair mutation
```

Record exact AppCzar diagnosis/disposition.

Do not invoke historical-source removal.

Quit normally.

Verify:

```text
import SHA unchanged
protected source inventory unchanged
graph state unchanged
preservation sentinels unchanged
```

Any whole-store deletion is an immediate FAIL.

---

# 21. Fixture D — corrupt / unknown repair safety

Create a fresh disposable current development archive with a local active derived
store that cannot be safely interpreted strongly enough to prove repair safety.

Use the narrowest reviewed corruption/unsupported fixture technique from
Response 79 tests.

Acceptable examples include:

- unreadable/corrupt current import DB;
- unsupported current schema fixture;

provided archive admission itself can still succeed and AppCzar can observe the
local-store problem.

Do not corrupt a real database.

Record prelaunch file hashes.

---

# 22. Experiment D — fail closed to Diagnostic Review

Launch against Fixture D.

Required:

```text
repair safety cannot be established
-> Diagnostic Review
-> Diagnostic only / virtual
-> NO mutation
```

There must be no attempt to delete the corrupt/unknown store merely to discover
what it contained.

Record exact visible facts/disposition.

Quit normally.

Verify all fixture hashes unchanged except explicitly identified harmless
fixture-local logs/lock artifacts.

---

# 23. One-Ball live corroboration

The human qualification cannot inspect hidden authority merely from UI.

Use only existing fixture-local logs/diagnostics if they expose mutation
admission/release without code change.

For Experiment A, corroborate where possible:

```text
one localDataRepair mutation occurrence
no overlapping second mutation
release before restart
```

Do not manufacture logs or add instrumentation.

The automated authority tests remain the formal proof of exactly one typed Ball
tenure; live evidence is corroborative.

---

# 24. Fair-Witness review

Confirm across all four experiments:

- reconstructibility TRUE came from current source comparison, not provenance;
- sourceFactMissing remained a known FALSE condition;
- protected history remained protected;
- corrupt/unknown was not reinterpreted as disposable;
- automatic mutation happened only for the exact executable class;
- physical reset was not called semantic repair success;
- fresh AppCzar owned the next jurisdiction after mutation;
- no historical story such as "interrupted import" was inferred;
- no old failure/cursor/consent selected current state.

---

# 25. Cleanup

At the end:

1. quit every MessageLens Development process;
2. verify none remains;
3. unset `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`;
4. verify empty;
5. leave FDA in its intended state;
6. stop any temporary qualification observer;
7. do not modify/stage/commit source or tests;
8. leave production MessageLens untouched;
9. preserve all four disposable fixture roots and observer logs until Response
   80 is complete.

No real MessageLens archive/database may be modified.

---

# 26. Qualification verdict

A full PASS requires:

## A — executable safe repair

```text
schema-wide current reconstructibility TRUE
-> Local Data Repair
-> automatic exact reset
-> physical postcondition PASS
-> real process boundary
-> fresh AppCzar
```

## B — source fact missing

```text
live provenance
+ current source anti-difference
-> NO reset
-> fixture unchanged
```

## C — protected historical/non-live

```text
protected material
-> NO whole-store reset
-> fixture unchanged
```

## D — corrupt/unknown

```text
repair safety UNKNOWN/unsupported
-> Diagnostic Review
-> NO reset
-> fixture unchanged
```

---

# 27. Required response

Create Response 80 and report:

1. exact Git HEAD/upstream state;
2. Prompt 79 implementation ancestry;
3. Prompt/Response 79 documentation checkpoint;
4. exact artifact/hash verification;
5. Stage One source reconfirmation;
6. qualification-observer method;
7. fixture parent and isolation proof;
8. current-source fixture-construction seam;
9. FDA/source preflight;
10. Fixture A raw/canonical path and UUID;
11. Fixture A populated-domain inventory;
12. Fixture A expected safety evidence;
13. Experiment A initial PID;
14. Experiment A AppCzar disposition;
15. Experiment A revalidation result;
16. Experiment A mutation-start evidence;
17. Experiment A exact physical reset footprint;
18. Experiment A postcondition result;
19. Experiment A preservation-witness result;
20. Experiment A Ball/log corroboration;
21. Experiment A old PID/restart boundary;
22. Experiment A replacement PID;
23. Experiment A fresh AppCzar disposition;
24. proof no same-process Onboarding handoff;
25. any subsequent Onboarding build/result;
26. Fixture B construction;
27. Fixture B source-missing proof;
28. Experiment B AppCzar class/disposition;
29. Experiment B no-mutation proof;
30. Fixture B before/after hash/count result;
31. Fixture C construction/protected-source facts;
32. Experiment C class/disposition;
33. Experiment C no-mutation proof;
34. Fixture C before/after result;
35. Fixture D corruption/unsupported construction;
36. Experiment D Diagnostic Review result;
37. Experiment D no-mutation proof;
38. Fixture D before/after result;
39. Fair-Witness verdict;
40. errors/warnings/evidence limitations;
41. cleanup result;
42. overall Local Data Repair human qualification verdict;
43. recommendation for qualification checkpoint;
44. readiness for Diagnostic Review milestone;
45. readiness for production AppCzar cutover.

Conclude exactly:

`RECONSTRUCTIBLE LIVE-ONLY PARTIAL DATA SELECTED EXECUTABLE LOCAL DATA REPAIR: YES / NO / NOT REACHED`

`SCHEMA-WIDE RECONSTRUCTIBILITY WAS REVALIDATED BEFORE MUTATION: YES / NO / NOT REACHED`

`AUTHORIZED PHYSICAL RESET POSTCONDITION PASSED: YES / NO / NOT REACHED`

`LOCAL DATA REPAIR ENDED AT A REAL PROCESS BOUNDARY: YES / NO / NOT REACHED`

`FRESH APPCZAR OWNED THE POST-REPAIR DISPOSITION: YES / NO / NOT REACHED`

`LIVE PROVENANCE WITH A MISSING CURRENT SOURCE FACT WAS NOT RESET: YES / NO / NOT REACHED`

`PROTECTED NON-LIVE/HISTORICAL DATA WAS NOT RESET: YES / NO / NOT REACHED`

`CORRUPT OR UNKNOWN REPAIR SAFETY REACHED DIAGNOSTIC REVIEW WITHOUT MUTATION: YES / NO / NOT REACHED`

`APPCZAR LOCAL DATA REPAIR HUMAN LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`READY TO CHECKPOINT LOCAL DATA REPAIR HUMAN QUALIFICATION: YES / NO`

`READY FOR DIAGNOSTIC REVIEW MILESTONE: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
