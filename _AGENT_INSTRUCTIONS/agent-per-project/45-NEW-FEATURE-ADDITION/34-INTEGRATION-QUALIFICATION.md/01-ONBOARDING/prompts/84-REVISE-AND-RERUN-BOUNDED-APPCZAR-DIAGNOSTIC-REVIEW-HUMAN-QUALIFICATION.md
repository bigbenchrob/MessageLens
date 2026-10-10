# MessageLens Feature 34
## 84 — Revise and Rerun Bounded AppCzar Diagnostic Review Human Qualification

### Why this protocol replaces Prompt 83

Response 83 correctly stopped before fixture creation. The current application does not expose a safe, deterministic development fixture seam for a genuinely `AppCzarSourceObservation.unknown` Messages-source result. Ordinary supported source failures are classified as **known** denial/unavailability. Unexpected exceptions alone reach that `UNKNOWN` branch. Forcing one would require changes or fault injection forbidden by Prompt 83.

**This was a fixtureability failure, not a demonstrated Diagnostic Review defect.** No fixtures were created and no app was launched. Do not misreport any of the unexecuted original experiments as having passed or failed at runtime.

The separately reviewed decision governing Prompt 84 is **protocol revision, not a new production or development UNKNOWN-observation injection seam**. Preserve all automated tests for source-UNKNOWN and the 22 Diagnostic selection frontiers. Record that genuine Messages-source UNKNOWN remains **automated-qualified only**, not human-live-qualified.

The revised *mandatory* human scope consists of three already source-grounded, safely constructible Diagnostic frontiers and two independently observed lifecycle experiments:

- **A — corrupt/unsupported local derived store:** Diagnostic Review, literal bounded failure, no mutation; hold stable for at least 90 seconds.
- **B — consequential live-provenance partial with a required current source fact missing:** known reconstruction-safety `FALSE`, Diagnostic Review, no reset.
- **C — protected historical/non-live material:** Diagnostic Review, no reset or historical removal.
- **R — explicit restart:** from one stable Diagnostic occurrence, one **Try Assessment Again** click, old PID exits, a distinct PID performs fresh AppCzar assessment, no automatic further retry.
- **Q — explicit Quit:** a separate Diagnostic launch, **Quit** once, normal exit, and no relaunch for at least 60 seconds.

Additional frontiers (retired artifacts, source/local anti-direction, archive-binding uncertainty, genuine observed UNKNOWN, unstable sample) are **optional live extensions only when current fixture seams can construct them safely without source modification or deceptive evidence**. They retain automated coverage otherwise. Do not treat an optional extension as a hidden mandatory stop gate.

A PASS under this revised protocol means **PASS — BOUNDED HUMAN SCOPE**, never “all six original classes live-qualified.” Production cutover is still **NOT AUTHORIZED**, even after a PASS; only a later separately approved whole-repository cutover audit can consider readiness.

---

# 1. Baseline and evidence checkpoint

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require branch `fix/onboarding-import-stuck-state`, clean tracked worktree/index, upstream ahead/behind `0/0`, one Feature 34 worktree, and clean shared instructions submodule `95326f515ef4719f155ce6e223990398daad6311`.

Expected baseline HEAD from Response 83:

`f37fef27c06539e0477164c54b2d99ad56fa75ac`

Resolve actual current HEAD/upstream from Git; if they have advanced, inspect the changes and stop if the source/artifact contract no longer matches. Verify Diagnostic Review implementation commit is in ancestry:

`6d4fa52004b463464102a889ceed9b642226ab10`

Before any fixture work, checkpoint **only** Prompt 83 and Response 83 as a failed/not-executed qualification record. Preserve:

```text
Prompt 83: stopped at fixtureability gate
No fixtures, launch, repair, reset, or real data access
No genuine source UNKNOWN could be manufactured safely
Diagnostic Review live result: NOT QUALIFIED
Production cutover: NO
```

Push the narrow documentation checkpoint normally; no unrelated staging, force push, rebase, squash, or merge. Keep Prompt 84/Response 84 unstaged during qualification, following the project convention.

If the human has not approved the revised scope, present the precise mandatory/optional change before launch and STOP for approval. No source edits are authorized by this prompt.

---

# 2. Exact unchanged development artifact

Use exactly:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected:

```text
product: MessageLens Development
bundle: com.bigbenchsoftware.MessageLens.development
environment/build: development / developmentDebug
version/build: 0.2.143 (161)
executable SHA-256:
  cda1c9d0ae86f64abb27824ef8b174f23325a9767a9b1445d23607d567742dcd
App.framework/App SHA-256 (dereferenced):
  cb1fc8d8e4dfc07b7bf1720ab061387145b5eaea2359270b0b48197abd7dd58b
```

If identity or hash differs, STOP. Do not rebuild, patch, or relaunch production. Confirm no MessageLens Development process is running and `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty.

---

# 3. Narrow current-source and fixtureability preflight

Read the exact current Diagnostic selection/host implementation and the reviewed disposable fixture methods used in Responses 77 and 80. Confirm:

```text
completed AppCzar Diagnostic assessment
-> one immutable occurrence / one frozen generation
-> Diagnostic Review screen
-> explicit process-restarter only when human presses Try Assessment Again
-> ordinary exit for Quit
```

Confirm Diagnostic itself does not construct Journey/Environment Readiness, worker, reader, Ball, reset, attachment writer, historical remover, polling, or export provider.

For A/B/C identify a deterministic fixture builder that:

- uses current project schema/admission APIs;
- does not copy a real MessageLens DB, Apple Messages DB, Contacts DB, or archive payload;
- creates only distinct admitted **development** archive roots in temporary storage;
- does not mutate Apple Messages or Contacts;
- uses current live Messages **read-only identity evidence** only if needed for B;
- creates no unsupported synthetic UNKNOWN result.

Do not construct all fixture classes before proving that each mandatory class has a safe seam. If A, B, or C cannot be safely built, STOP AND REPORT the exact class, without modifying code to make it pass.

Known denial/unavailability may be reported literally if observed, but is **not** a substitute for genuine `UNKNOWN` and must not be forced into Diagnostic Review when another coordinator owns it.

---

# 4. Isolation, manifests, and observer

Create one new unique `/private/tmp/messagelens-appczar-diagnostic-qualification-...` parent containing separate A/B/C fixture roots, plus a separate launch for Q. Each root requires its own current-format marker, distinct archive UUID, fixture-local attachment directory, and no symlinks into another root.

Before each launch record canonical absolute path, UUID, schema/version facts where readable, consequential row counts, exact protected sentinel names, and a sorted inventory with SHA-256 for existing files.

Hard path guards:

```text
fixture root != real WD development root
fixture archive != active Toshiba attachment archive
fixture root is not nested in any real root
```

Do not inspect the real WD or Toshiba contents; use only path/existence inequality guards.

Use a bounded read-only observer for exact MessageLens Development PIDs, fixture file events, and process exit/relaunch. Store evidence outside the repository. Its observations are corroborative, not semantic authority. Never infer an unobserved zero-PID interval.

**Bootstrap distinction:** Ordinary fixture-local app startup may create lock files, logs, settings, or healthy empty stores. Compare protected original fixtures/sentinels and classify *every* inventory difference by source and time. Do not silently ignore new files; do not label benign bootstrap as Diagnostic data mutation without evidence. A change to protected fixture evidence is a stop gate.

---

# 5. Common Diagnostic presentation checks

For each mandatory A/B/C launch require:

- exactly one `MessageLens needs a diagnostic review` screen;
- literal selected AppCzar diagnosis and a bounded factual summary;
- one assessment generation and one capture time;
- explicit notice that this is a bounded snapshot, not continuously refreshed;
- TRUE, FALSE, UNKNOWN, or literal conflict only where the **captured** observations support them;
- expandable bounded Technical evidence;
- only **Try Assessment Again** and **Quit**;
- no normal Operating workspace or legacy Journey;
- no reset, repair, preservation, adoption, export, copy, or historical removal actions.

Record generation, time, diagnosis, and technical details without exposing message text, contacts, attachment bytes, or unnecessary identifiers.

The Diagnostic view must not change semantic rows during a single PID. Watch **one stable A Diagnostic occurrence for at least 90 seconds**. Require the same generation, capture time, diagnosis, and PID with no spontaneous reassessment/restart. This qualifies the **no-loop behavior for a stable known diagnostic condition**, **not** stable genuine source UNKNOWN.

---

# 6. Experiment A — corrupt or unsupported derived store

Using a reviewed deterministic fixture seam, create a disposable active import store that is conclusively corrupt/unsupported (e.g. a non-SQLite file at the exact import path), while archive admission remains valid.

Require:

```text
archive admitted
-> AppCzar Diagnostic Review
-> affected import store named
-> literal bounded SQLite/read failure evidence
-> no claim of virginity/disposability/reconstructibility
-> no repair or reset
```

Record protected store SHA/count/inventory before and after. Use this case for the 90-second stability observation.

---

# 7. Experiment B — live provenance but missing current source fact

Use the Response 80 source-missing fixture design: a valid current-schema partial import with live-source lineage but a required ROWID/GUID (or audited identity) that current read-only source evidence proves absent. Do **not** delete a real Messages row to induce absence.

Require:

```text
AppCzar Local Data Repair safety = sourceFactMissing
known reconstructibility FALSE
-> Diagnostic Review
-> “Required current source fact missing” or exact equivalent
-> NO Local Data Repair execution or reset
```

No fabricated source UNKNOWN, FDA-off claim, or causal history. Verify protected import SHA, row counts, marker, and archive sentinel unchanged.

---

# 8. Experiment C — protected historical/non-live data

Use current source-registration schema APIs to create a fixture with one consequential historical/non-live source and protected rows. No real historical archive donor may be copied.

Require:

```text
protected material present
-> Diagnostic Review
-> current protected/historical classification shown literally
-> no reset, history removal, or archive mutation
```

Verify exact protected-source identity/count and all protected sentinels byte-for-byte unchanged after quit.

---

# 9. Experiment R — one explicit real restart

Use a **fresh A-class launch** (or a fresh equivalent admitted stable Diagnostic fixture). Allow Diagnostic to settle. Record original PID, generation, capture time, and protected evidence.

Press **Try Assessment Again exactly once**.

Require:

```text
one human action
-> old occurrence closes/drains
-> old PID exits
-> new and distinct PID launches
-> native/Dart archive admission runs again
-> fresh AppCzar reassesses
-> new Diagnostic occurrence from current facts, if unchanged
```

The new process must not inherit an automatic retry intention. Observe the new Diagnostic screen for a bounded period (at least 90 seconds) without clicking anything; it must remain stable with no additional relaunch. Record new generation/time literally; process-local generation numbers need not increase numerically across PIDs.

Do not press Try Assessment Again again. Never claim an unobserved zero-PID interval.

This proves repeat-stability for a **known diagnostic**. It does **not** qualify a new genuinely UNKNOWN source outcome.

---

# 10. Experiment Q — Quit without relaunch

Use a separate fresh A-class Diagnostic launch. Do not reuse the process on which restart was pressed.

Press **Quit exactly once**. Require old PID exits and **no replacement development PID** appears over an external observation interval of at least 60 seconds. No process restarter may be invoked for Quit. Protected fixture evidence stays unchanged.

If Quit fails or relaunch occurs, STOP AND REPORT rather than killing the process to manufacture PASS.

---

# 11. Optional additional Diagnostic frontiers

Only **after A/B/C/R/Q have all qualified** and only if source audit proves a safe deterministic fixture, Codex may exercise independently:

- retired or unsupported derived artifact;
- source/local count or high-water anti-direction;
- incoherent archive/coverage/actionability binding;
- genuinely unstable source sampling without modifying source data during display;
- naturally occurring genuine source UNKNOWN (no injection).

No extension is required for the bounded PASS. Record each as `NOT EXERCISED` if no safe seam exists. Do not replace missing evidence with a fabricated result. Do not let optional tests delay or contaminate the mandatory scope.

The existing automated 22-frontier suite remains authoritative for branches not exercised live.

---

# 12. No-mutation, Fair-Witness, and cleanup

After every launch/quit compare the protected original inventory and hashes against the prelaunch manifest. Preserve fixture-level logs separately so ordinary bootstrap changes can be classified. Require no Diagnostic-initiated mutation, no reset, no preservation operation, no historical-source removal, no persisted Diagnostic generation/consent, and no archive payload change.

Confirm no development processes remain, stop the external observer, unset the root override, verify `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty, and leave production MessageLens untouched. Leave FDA in the pre-test intended state; record any macOS prompt literally.

Preserve only the exact temporary fixture roots/manifests long enough to write Response 84. Do not stage, commit, or upload their contents. Do not modify source, tests, generated files, release metadata, or build. Do not begin production cutover.

---

# 13. Qualification scope and verdict

A full **revised bounded-scope PASS** requires all of:

```text
A: corrupt/unsupported -> Diagnostic, literal evidence, no mutation
B: sourceFactMissing -> known FALSE, Diagnostic, no mutation
C: protected non-live -> Diagnostic, no mutation
R: one explicit restart -> distinct new PID, fresh assessment, no retry loop
Q: Quit -> exit, no relaunch for >=60 seconds
stable A snapshot -> >=90 seconds, no autonomous reassessment/restart
protected fixture data -> unchanged
real data -> untouched
```

If any required behavior is not observed, report FAIL / NOT REACHED as appropriate; do not broaden the definition of PASS.

Even with all passes:

```text
Diagnostic Review human qualification: PASS — REVISED BOUNDED SCOPE
Genuine Messages-source UNKNOWN human qualification: NOT EXERCISED
All six original Prompt 83 experiment classes live-qualified: NO
Automated 22-frontier qualification: previously passed, unchanged
Production AppCzar cutover: NOT AUTHORIZED
```

---

# 14. Required Response 84

Create Response 84 with:

1. exact Git HEAD/upstream/branch/submodule and Prompt 83 failed-documentation checkpoint;
2. exact artifact version, executable/App.framework hashes;
3. evidence that current source/test seams support A, B, and C without unsafe injection;
4. temporary parent, UUIDs, canonical paths and hard isolation guards;
5. external observer method and its limitations;
6. A diagnosis, frozen display, bounded technical read failure, 90-second stability and protected before/after evidence;
7. B source-missing TRUE evidence and known repair-safety FALSE, display and unchanged data;
8. C protected-source evidence, literal display and unchanged data;
9. R single user action, old/new PID evidence, fresh assessment, no later loop;
10. Q separate launch, Quit, >=60-second no-relaunch observation;
11. all inventory differences including ordinary bootstrap artifacts classified explicitly;
12. all optional frontiers exercised or NOT EXERCISED, with reasons;
13. Fair-Witness verdict, remaining genuine-source-UNKNOWN live coverage gap;
14. source/test/build non-mutation and real-archive non-access proof;
15. cleanup, final Git/worktree/index/submodule state;
16. exact qualification verdict, whether ready to checkpoint, and readiness only for a **separate audit** of production cutover (not authorization to cut over).

Conclude exactly:

```text
REVISED A/B/C DIAGNOSTIC FRONTIERS LIVE QUALIFIED: YES / NO
KNOWN RECONSTRUCTION-SAFETY FALSE STAYED DISTINCT FROM UNKNOWN: YES / NO
ONE FROZEN DIAGNOSTIC OCCURRENCE REMAINED STABLE FOR 90 SECONDS: YES / NO
TRY ASSESSMENT AGAIN USED EXACTLY ONE REAL PID RESTART: YES / NO
REPLACEMENT PROCESS DID NOT AUTO-RETRY: YES / NO
QUIT EXITED WITHOUT RELAUNCH FOR AT LEAST 60 SECONDS: YES / NO
NO DIAGNOSTIC REPAIR/RESET/HISTORY/ARCHIVE MUTATION: YES / NO
PROTECTED FIXTURE DATA UNCHANGED: YES / NO
REAL ARCHIVES AND REAL DATABASES UNTOUCHED: YES / NO
GENUINE MESSAGES-SOURCE UNKNOWN LIVE QUALIFIED: NO
ALL ORIGINAL PROMPT 83 CLASSES LIVE QUALIFIED: NO
REVISED BOUNDED APPCZAR DIAGNOSTIC HUMAN QUALIFICATION: PASS / FAIL
READY TO CHECKPOINT REVISED DIAGNOSTIC QUALIFICATION: YES / NO
READY FOR SEPARATE PRODUCTION-CUTOVER AUDIT: YES / NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
```

Then STOP. Do not implement new seams or begin a production audit/cutover.
