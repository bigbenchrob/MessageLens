# MessageLens Feature 34
## Response 46 — Correct AppCzar Fair-Witness Testimony and Status Semantics

## 1. Baseline verification — PASS

- Worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`.
- Branch: `fix/onboarding-import-stuck-state`.
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`.
- Prompt 32 + Prompt 35 + Prompt 44 accumulated changes were present;
  Prompt 45 had made no source/test changes.
- Index: empty.
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.
- Fresh external baseline manifest:
  `/private/tmp/messagelens-prompt46-baseline-20261001.txt`, SHA-256
  `9b560497c4660305efc6890779f1d4e7413bada7d74e926440cb51f68ce9e997`.
- Baseline tracked diff SHA-256:
  `953b2c31773d49ce8589497c1ce725b72c0034e9e8f070e7ca6c76b1d75e1ed0`.
- Baseline contained 32 tracked worktree entries and 89 untracked files.

## 2. Exact unsupported FDA inference source

`AppCzarEvaluator._fullDiskAccessFact` mapped
`AppCzarSourceCondition.readable` to `Full Disk Access = TRUE` and
`accessDenied` to `Full Disk Access = FALSE`. Both values came exclusively
from the result of opening/querying the Messages source. The startup harness
duplicated the same inference in `_sourceAccessProgress`.

That evidence proves only whether the responsible process can currently read
the source. It does not report the state of the macOS setting. The inference
and all associated production copy were removed.

## 3. FDA-row removal/correction

- `AppCzarFactId.fullDiskAccess` was removed.
- `_fullDiskAccessFact` was removed.
- The duplicate startup row and pending row were removed.
- `Waiting for Full Disk Access.` was removed from AppCzar fact and UI copy.
- An AppCzar package census finds no production `Full Disk Access` literal.
- Tests and an architecture tripwire prevent the unsupported assertion from
  returning.

No macOS setting API or replacement inference was invented.

## 4. Final literal source-readability fact

The sole proposition is now `Messages source readable`:

- `readable` -> `TRUE`;
- conclusively `accessDenied` or `unavailable` -> `FALSE`;
- inconclusive `unknown` -> `UNKNOWN`.

Readable detail uses a count/high-water only when those observations are
present. Unreadable and unknown results preserve the literal probe reason and
cannot substitute zero counts or high-water values.

## 5. Duplicate-row simplification

The screen now has one source-access row:

`Messages database`

It presents one of:

- `Readable — <count> messages`;
- `Cannot currently be read`;
- `Readability unknown`;
- `Checking`.

Source sample stability remains a separate row because it is different
evidence: whether two bounded current samples agreed, not whether the source
could be opened.

## 6. Truth-vs-significance presentation design

`AppCzarPresentationProjector` is a pure downstream projection. It introduces
only the five presentation meanings required by Prompt 46:

- `healthy`;
- `attention`;
- `informational`;
- `unknown`;
- `pending`.

Significance is assigned per proposition. There is no generic
`TRUE -> green / FALSE -> red` mapping. The harness imports no
`AppCzarTruth`; it receives only projected rows. An architecture test proves
the evaluator cannot reference presentation significance, the projector
cannot instantiate the evaluator, and the harness cannot select tone from raw
truth.

## 7. `New messages = 0` presentation result

The internal `New source messages present = FALSE` fact remains useful for
deterministic selection. When current source and local live-import counts and
high-water values agree, its presentation is:

```text
New messages
0
Source and MessageLens are current.
```

Its significance is `healthy`, not `attention`.

## 8. Healthy-current presentation result

Healthy classification now requires comparable source/local counts and
high-water values, not a fabricated default. Equal values project as current,
and the preserved cautious diagnosis is:

`This appears to be a healthy current MessageLens installation.`

The virtual coordinator remains `Operating Session`.

## 9. Source-unavailable presentation result

A conclusive denied/unavailable probe presents:

```text
Messages database
Cannot currently be read
<literal probe reason>
```

No source count or high-water is shown. Source stability and new-message
comparison remain visibly unknown. An inconclusive probe instead says
`Readability unknown` and retains its literal reason.

## 10. Diagnosis wording result

The accepted source-access diagnosis is preserved exactly:

`The current Messages source cannot be inspected with the available access.`

It describes the current observation without asserting why access is
unavailable.

## 11. Virtual coordinator result

Unreadable or inconclusive current source evidence still selects exactly one
display-only value: `Source Access Repair`.

Readable/current evidence selects `Operating Session`; a proven positive
source delta selects `Data Update`. These remain enum data only. No
coordinator instance, callback, constructor seam, or execution path was added.

## 12. Provenance/details design

One default-collapsed `Assessment details` disclosure shows the bounded basis
for each visible row. It includes only evidence present in the assessment,
such as:

- read-only source-open result;
- source count/high-water when actually observed;
- bounded-sample agreement;
- database condition/schema/count when present;
- graph topology counts when present;
- archive condition/label/resolved path when present;
- exact source/local count and high-water comparison when present.

It shows no message/contact content, provider names, or SQL. Missing source
evidence cannot produce count/high-water provenance.

## 13. Observation/fact/presentation separation proof

The final one-way path is:

```text
read-only observation readers
-> AppCzarEvaluator facts + diagnosis + virtual coordinator
-> AppCzarPresentationProjector values/significance/provenance
-> AppCzarStartupHarness rendering
```

Every completed row declares its supporting `AppCzarFactId` set. Pending
projection has no fact identity or provenance because evaluation is not yet
complete. Presentation significance cannot feed the evaluator or coordinator
selection.

## 14. Focused evaluator tests — PASS

11/11 evaluator tests passed, including:

- deterministic selection from identical observations;
- denied access produces only the literal source-readable `FALSE` fact;
- no FDA fact/copy remains;
- exact source-access diagnosis and coordinator;
- healthy, incomplete, archive, local-repair, source-ahead, contradiction,
  and default-archive cases.

## 15. Focused presentation tests — PASS

11/11 pure-projector tests and 2/2 harness widget tests passed. They prove:

- readable and unreadable states contain no unsupported FDA statement;
- raw false does not generically choose attention/error tone;
- healthy no-delta presents `0` and current;
- positive delta is informational/actionable;
- unknown preserves a literal reason;
- unavailable evidence cannot claim a count/high-water;
- provenance includes only present evidence;
- each resolved row names its supporting facts;
- pending rows publish no unsupported evidence;
- the disclosure renders evidence while coordinator execution remains absent.

Final combined evaluator/presentation/widget/architecture rerun: 28/28 PASS.

## 16. Source-access tests — PASS

- SQLite source-reader fixtures: 2/2 PASS.
- Attachment-location read-only probe fixture: 1/1 PASS.
- Missing stores remain absent.
- Every source message row remains counted without anomaly filtering.
- Attachment-location observation leaves overlay bytes unchanged.
- Observation-order/generation tests passed in the 35-test focused group.

No real source or archive was used by these tests.

## 17. Architecture result — PASS

- AppCzar architecture isolation: 4/4 PASS.
- Complete `test/architecture` suite: PASS.
- AppCzar imports no onboarding, Environment Readiness, navigation,
  operation-snapshot, monitor, coordinator-provider, or Ball execution
  authority.
- SQLite readers retain read-only/query-only tripwires.
- Production startup routing remains unchanged by Prompt 46.
- Virtual coordinator remains non-executable data.

## 18. Analyzer result — PASS

`flutter analyze` completed with `No issues found`.

The first analyzer pass found one adjacent-string informational lint in the
new projector. It was corrected, formatted, and the clean analyzer was rerun.

## 19. Full Flutter-suite result — PASS

Final complete serialized suite:

- 2,797 passed;
- 1 intentionally skipped qualification worker;
- 0 failed;
- exit status 0.

For transparency, an initial default-parallel full run reported one failure in
the unrelated attachment-resolver test `archive enabled reports pending when
live file exists but archive does not`. The exact test immediately passed in
isolation. The complete suite was therefore rerun with `--concurrency=1`; the
same test and the entire inventory passed. No attachment implementation was
changed.

## 20. Diff/format/generated hygiene — PASS

- `git diff --check`: PASS.
- `git diff --cached --check`: PASS.
- Targeted `dart format --output=none --set-exit-if-changed`: 8 files,
  0 changed.
- `build_runner build --delete-conflicting-outputs`: PASS; generated outputs
  are consistent and no new generated drift was introduced.
- Index remains empty.
- Nothing was staged, committed, pushed, merged, or rebased.

## 21. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

- Fair Witness law is encoded in fact wording, projection shape, provenance,
  and tests.
- Unsupported FDA testimony is absent.
- Source readability is literal.
- Truth and presentation significance are one-way and separate.
- Healthy false is not rendered as an error.
- One diagnosis and one non-executable virtual coordinator remain.
- Production startup is unchanged by this correction.
- No real development/production data was accessed or mutated by the agent.

## 22. BLOCKER findings

`BLOCKER: 0`

No Prompt 46 blocker remains.

## 23. SHOULD FIX findings

`SHOULD FIX: 0`

No Prompt 46 conformance defect remains. The parallel-only test interference
was recorded rather than hidden; its isolated and complete serialized reruns
both pass and it is outside the AppCzar change surface.

## 24. Exact build identity/path/hashes

Exact build command:

```text
env PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  /Users/rob/Development/flutter/bin/flutter build macos --debug --no-pub
```

Result: PASS.

- Bundle:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- Executable:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development`
- Product: `MessageLens Development`.
- Bundle identifier: `com.bigbenchsoftware.MessageLens.development`.
- Version/build: `0.2.130+148`.
- Archive environment: `development`.
- Build identity: `developmentDebug`.
- Signing: ad hoc Debug; no TeamIdentifier.
- Executable timestamp: `2026-10-01 14:33:41 -0700`.
- Executable SHA-256:
  `6cf31b1df781adb8f35c3915417e81ccdda3d9c92c5e1cc7937846f61d8a3c21`.
- App.framework binary SHA-256:
  `5a38064b6c9d5ec0b8be8d1457d700588974c16745a836ad1e63d45d5329e6ee`.
- Debug Dart kernel SHA-256:
  `64b6183eb6b8bbe252e09564786db01a4f7fe65bc39df8f6233f45a16345bdd2`.
- Info.plist SHA-256:
  `d6d204b60d04f5104b55b927e950519b67892dad8d60e64d5fa66a9b224dbe93`.
- Aggregate App.framework regular-file SHA-256:
  `deaef7bf3e4a3ceac5506d701baf9a72cdb6e229130eb6e3d91e00ed5c89999f`.
- Aggregate bundle regular-file SHA-256:
  `d2ebc8fa6bd450eec3e16ad9cdb630901502de89791778f231ef3f4dc6187765`.

The build did not launch the app.

## 25. Exact Git/worktree/index/submodule state

- Branch: `fix/onboarding-import-stuck-state`.
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`.
- Tracked worktree entries: 32 accumulated modified files.
- Untracked files before this response: 91; after this response: 92.
- Index: empty.
- Current accumulated tracked diff SHA-256:
  `b33145a4f33145eeae5f24dbd183ab86e8bed9e2d1724c903de4fae6bc9fda3a`.
- Current AppCzar production/test directory manifest SHA-256:
  `5a16b0127ccb6be5787ea5c4333e1ede59908ad08befc6218920fcbcc193a897`.
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.
- All unrelated untracked files remain untouched.
- Prompt 46 changed only the intended AppCzar model/evaluator/projector/UI,
  focused tests/architecture tripwire, release metadata, and this response.

No production MessageLens app was launched. The agent did not open, inspect,
copy, move, delete, or mutate either real archive, any real MessageLens
database, `chat.db`, archive configuration, or abandoned relocation artifact.

## 26. Readiness for repeated direct-launch OFF/ON experiment

The corrected bundle is ready for the repeated human experiment, but two
handoff facts matter:

1. PID `17905` is an already-running direct-launch development instance,
   started `2026-10-01 13:15:42 -0700` with parent `launchd`. It predates the
   corrected build by more than an hour. The agent did not launch or stop it.
   The human must quit it normally before testing so LaunchServices cannot
   reactivate the old in-memory process.
2. `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is currently empty.
   After quitting PID 17905, set the exact WD development root as in Response
   45 before double-clicking the newly built bundle, and unset it after the
   experiment.

Expected OFF result: no FDA assertion; current source-readability result only;
unknown downstream comparison when unreadable; source-access diagnosis and
`Source Access Repair`.

Expected ON result: no FDA assertion; readable source with current
count/high-water; known comparison; healthy diagnosis and `Operating Session`
when all current evidence agrees.

FAIR-WITNESS TESTIMONY CORRECTED: YES

UNSUPPORTED FDA ASSERTION REMOVED: YES

TRUTH AND HEALTH PRESENTATION SEPARATED: YES

VISIBLE APPCZAR READY FOR REPEATED ACCESS EXPERIMENT: YES
