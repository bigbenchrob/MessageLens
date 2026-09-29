# MessageLens Clean-Slate Integrated Qualification
## 12 — Correct Exact-Command Currentness and Complete the Semantic Census

Prompt 11 correctly failed the repeated architectural review.

Two issues remain:

1. **BLOCKER:** the final post-await guard proves only broad prerequisite
   compatibility, not that the latest coherent report still authorizes the
   exact command about to mutate state.
2. **SHOULD FIX:** the semantic-dependency census is broader than before but
   still contains root-discovery and traversal-stop gaps that weaken its claim
   to protect the authority boundary repository-wide.

This task corrects those findings only.

Do NOT redesign the overall Onboarding authority architecture.
Do NOT apply the parked WIP patch.
Do NOT stage or commit.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.
Do NOT edit canonical/conformance documentation in this task.

Read in full:

- `responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`
- `responses/06-IMPLEMENT-ONBOARDING-AUTHORITY-CORRECTION.md`
- `responses/08-CORRECT-ONBOARDING-AUTHORITY-REVIEW-FINDINGS.md`
- `responses/10-CORRECT-POST-AWAIT-PREREQUISITE-CURRENTNESS-AND-SEMANTIC-CENSUS.md`
- `responses/11-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-AFTER-PROMPT-10.md`
- corrected canonical Onboarding authority documents.

Governing invariant:

> **Evidence may be distributed. Journey authority may not be.**

The required mutation rule is now stronger and explicit:

> After the final relevant await, the coordinator must prove both:
>
> 1. the latest coherent prerequisite truth is current; and
> 2. that same current report still authorizes the **exact command** that is
>    about to mutate state.

A broad “no external blocker” check is insufficient.

---

# 1. Baseline

Expected:

- branch: `fix/onboarding-import-stuck-state`
- HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- index: empty
- tracked worktree: the reviewed Onboarding correction delta only
- shared-instructions submodule: clean
- parked WIP patch: unchanged and unapplied

Confirm Prompt 11 changed no implementation.

If unrelated tracked changes are present, STOP AND REPORT.

---

# 2. Replace the broad latest-report guard with exact-command authorization

Inspect the current `_latestPrerequisitesPermitCommand` helper and all callers.

Replace the broad shared negative predicate with command-specific current-report
authorization.

The coordinator must answer, for the **latest coherent report**:

> Is this exact command still authorized now?

Do not infer authorization from:

- the rendered Episode;
- an old action context alone;
- absence of external blockers alone;
- the originally observed report;
- the fact that a command token is still active.

The latest report must positively satisfy the current command predicate.

---

# 3. Define exact predicates for each mutation-capable command

Use existing typed environment/report classifications and canonical Journey
policy. Do not duplicate probing logic.

## 3.1 Initial import

Immediately before `begin(initialImport, ...)`, require that the latest report
still represents a state from which **initial import is currently valid**.

At minimum reject a report that has become:

- already ready / normal-ready;
- automatic-recovery/reset-required;
- another app-owned failure state requiring a different Journey decision;
- any current external prerequisite blocker.

Preserve the already accepted local-history semantics as part of the current
Journey/report compatibility.

The predicate should express positive import eligibility, not merely
`!externalBlocker`.

## 3.2 Reimport

Immediately before `begin(reimport, ...)`, require the latest report still
permits explicit reimport under the canonical Settings/reimport policy.

If reimport is intentionally broader than first import, encode that explicitly.

Do not inherit broad permission accidentally from the same helper used by
initial import or automatic recovery.

Current external prerequisite blockers must still deny the mutation.

## 3.3 Interrupted Continue Setup

Immediately before `resume(operationId)` require that the latest report still
permits continuation of that exact retained interruption.

The predicate must be the same semantic decision used when retained interrupted
evidence is surfaced/reconciled.

In particular:

- `ready` must supersede interruption and deny resume;
- current prerequisite incompatibility must deny resume;
- wrong stage/substage/recovery capability must deny resume;
- the exact operation identity/session/status checks remain required.

Do not maintain two subtly different “can continue?” policies.

## 3.4 Automatic recovery

Immediately before both:

- automatic-recovery `begin`; and
- destructive/reset mutation after any awaited progress persistence,

require that the latest report still says automatic recovery/reset is currently
required.

At minimum the predicate must revalidate the current typed reset/recovery fact
such as:

`shouldResetAppDatabasesBeforeImport == true`

or the canonical equivalent.

If that predicate becomes false, the stale recovery command must stop even when
no external blocker exists.

A late `ready` report must therefore cancel the obsolete reset path.

---

# 4. Keep one coordinator-owned command-policy decision per command

Avoid scattering policy across multiple call sites.

Prefer small private helpers with explicit semantics, for example:

- `_latestReportAllowsInitialImport(...)`
- `_latestReportAllowsReimport(...)`
- `_latestReportAllowsInterruptedContinuation(...)`
- `_latestReportAllowsAutomaticRecovery(...)`

or an equally clear typed dispatch.

Requirements:

- each helper interprets the already-coherent latest report;
- no helper performs probing/I/O;
- no helper creates another state cache;
- no helper becomes a second Journey authority;
- report incompatibility publishes/derives the truthful current Journey Episode
  through the coordinator;
- command/action/operation identity checks remain separate and explicit.

Do not reuse one broad helper if the commands have different predicates.

---

# 5. Preserve post-await mutation ordering

For every mutation-capable path, re-verify:

```text
await
-> latest report exact-command authorization
-> action/command/operation identity currentness
-> mutation
```

or an equivalent ordering with no await between the final combined authorization
and the mutation.

Cover:

- initial import begin;
- initial-import Retry begin;
- reimport begin;
- reimport Retry begin;
- Continue Setup resume;
- automatic-recovery begin;
- automatic-recovery reset after progress persistence.

No mutation may occur on stale command policy.

---

# 6. Add deterministic non-external predicate-withdrawal races

Use completers. Do not use timing sleeps as proof.

At minimum add these races.

## 6.1 Automatic recovery: begin withdrawn

Start from a report requiring automatic recovery/reset.

Hold controller acquisition.

While held, publish a latest coherent report that:

- has no external blocker;
- no longer requires automatic recovery/reset; and
- is `ready` or otherwise truthfully supersedes the recovery predicate.

Release acquisition.

Assert:

- `begin` is not called;
- reset/import mutation does not run;
- no fabricated UUID appears;
- Journey derives/publishes the truthful current Episode.

## 6.2 Automatic recovery: reset withdrawn after begin

Allow automatic recovery to begin.

Hold the awaited progress-evidence persistence immediately before reset.

While held, publish a coherent report that clears the reset requirement without
introducing an external blocker.

Release persistence.

Assert:

- reset is not called;
- the bound operation is left in a truthful coordinator-owned retained/failure
  state as required by the existing policy;
- presentation reflects current Journey truth;
- no stale recovery mutation proceeds.

## 6.3 Interrupted continuation superseded by readiness

Expose a valid Continue Setup Episode.

Hold controller acquisition after the user invokes the real Continue action.

While held, publish a coherent `ready` report that canonically supersedes the
retained interruption.

Release acquisition.

Assert:

- `resume` is not called;
- operation UUID/process-session/status remain unchanged;
- Journey derives/publishes the truthful ready/current Episode;
- the old Continue action is stale/inert.

## 6.4 Initial import exact-policy withdrawal

Start from valid Ready-to-Import.

Hold the last awaited acquisition before `begin`.

While held, publish a coherent non-external report that no longer authorizes
initial import—for example one requiring automatic recovery/reset or already
ready, whichever is canonical and easiest to construct truthfully.

Release acquisition.

Assert:

- initial-import `begin` is not called;
- executor/import mutation does not run;
- Journey derives/publishes the truthful current Episode.

## 6.5 Reimport policy

Add at least one race proving the explicit reimport predicate, not a shared
negative blocker test.

If canonical reimport remains permitted across a report transition that would
deny initial import, prove that intentionally.

If it should be denied, prove the denial.

The test should document the actual canonical reimport policy.

---

# 7. Preserve retained-evidence semantics when a stale command is stopped

Reconfirm the Prompt 08/10 behavior:

- retry stopped before replacement `begin` retains the prior failed UUID
  privately;
- a genuinely new admission/begin failure remains UUID-less;
- Continue Setup stopped before `resume` preserves the interrupted identity;
- automatic recovery stopped after `begin` but before reset does not silently
  become success;
- current Journey occurrence changes truthfully where required so stale actions
  remain stale.

Do not fix exact-command authorization by discarding durable evidence.

---

# 8. Complete semantic-consumer root discovery

Prompt 11 found that traversal is repository-wide **after roots are chosen**, but
root discovery itself remains selected-path based.

Strengthen root discovery so all production Onboarding-semantic consumers are
discovered mechanically.

The architecture test should not rely primarily on a hand-maintained list such
as:

- one presentation directory;
- one readiness directory;
- shell;
- one observer.

Design a repository-wide discovery rule for production Dart under `lib/` that
finds files capable of consuming/routing Onboarding Journey semantics.

Possible mechanical signals may include imports/references to:

- `OnboardingJourneyState`;
- `OnboardingGate`;
- approved Journey projections/action contexts;
- Onboarding routing/ViewSpec seams;
- other typed public Journey semantic interfaces.

The exact implementation is yours to derive from the repository, but the
property must be:

> Moving a conforming Onboarding semantic consumer to another feature or shared
> presentation directory does not silently remove it from the census.

Avoid scanning comments/strings as semantic dependencies where AST/import-level
resolution can be used.

---

# 9. Remove the shell traversal exemption

Prompt 11 found that `MacosAppShell` is present in the root set but explicitly
skipped by the transitive traversal.

Remove that exemption or replace it with a mechanically complete proof.

The shell and every local wrapper it imports must be unable to reach raw
Onboarding semantic evidence behind an adapter.

A direct source-spelling check alone is insufficient.

The shell may terminate at:

- Journey state;
- read-only compatibility projection derived solely from Journey;
- narrow action/intent seams;
- other mechanically proven safe leaves.

---

# 10. Make traversal stops transitively safe

Every explicit traversal stop/leaf must satisfy one of two rules:

1. **Traverse it**, or
2. **Mechanically prove the complete property that makes it safe.**

Apply this to:

- configuration leaves;
- action providers/adapters;
- provider barrels;
- logging/diagnostic barrels;
- center-panel helpers;
- advanced Start Fresh seams;
- any other allowlisted stop.

In particular:

## Config

Do not merely scan config files for direct raw symbol spellings.

Either traverse their local imports or prove they cannot import code capable of
Onboarding semantic reads.

## Action adapters

An action adapter stop must mechanically exclude:

- state publication;
- `ref.watch` semantic ownership;
- direct or transitive raw environment evidence;
- raw graph/controller evidence;
- raw operation snapshot evidence;
- reconciliation evidence.

If an adapter imports another local adapter/read model, traverse it unless that
callee independently satisfies the same safe property.

## Provider barrels

Continue requiring narrow `show` imports where appropriate, but ensure the
allowed symbols themselves terminate at safe Journey/intent/diagnostic seams.

Do not trust a barrel merely because its filename is known.

---

# 11. Make the virtual tests exercise production stop semantics

Prompt 11 found that the virtual action-adapter test proves traversal in general
but does not exercise the actual stop exemption used for production adapters.

Correct that.

Add virtual/synthetic dependency-graph tests that use the same decision logic as
production traversal.

At minimum prove:

1. a semantic wrapper under an arbitrary `lib/shared/...` directory is found;
2. a shell-imported wrapper reaching raw evidence is found;
3. an adapter that qualifies as a production “stop” but imports a hidden raw
   evidence wrapper is rejected;
4. a config leaf that imports a hidden semantic wrapper is rejected;
5. a genuinely narrow intent-only adapter is accepted;
6. the explicit development diagnostic panel remains the one bounded exception
   without creating a route back into production semantic presentation.

The test should exercise the real census policy, not a simplified parallel toy
policy.

---

# 12. Reduce layout/private-symbol coupling

Where possible, replace:

- exact path lists;
- exact private method-name expectations;
- exact source-text spellings;

with semantic/import/dependency properties.

Some named seams are legitimate and stable:

- `OnboardingJourneyCoordinator`;
- the development diagnostic exception;
- canonical Journey state types;
- deliberately narrow public intent/compatibility boundaries.

But a conforming file move or private rename should not require architecture
test changes unless the semantic boundary itself changed.

Do not over-generalize so far that the test becomes opaque or impossible to
debug.

Failure output should still show the dependency path that violated the rule.

---

# 13. Reconfirm there is still no current production side door

While hardening the census, independently inspect current source.

Confirm:

- production presentation/routing still consumes Journey-owned semantics only;
- development raw-evidence presentation remains isolated;
- no Prompt 12 helper/wrapper becomes a new semantic authority;
- no exact-command helper is called from presentation.

The census is a tripwire, not the authority itself.

---

# 14. Focused validation

Run:

- coordinator exact-command/currentness tests;
- new completer-based non-external withdrawal races;
- retained-evidence regression tests;
- focused Journey presentation/action tests if copy/actions change;
- authority architecture tests;
- complete architecture suite;
- `flutter analyze --no-pub`;
- formatting of changed Dart files;
- generation only if annotated/generated input changed;
- `git diff --check`.

Do not run the full repository Flutter suite yet.

That belongs after the repeated architectural gate passes.

---

# 15. Project Conformance correction-delta review

Re-run the correction-delta conformance check specifically against:

- exact-command current-report authorization;
- no stale mutation after awaited policy withdrawal;
- one Journey authority;
- no second prerequisite cache/state machine;
- repository-wide semantic consumer discovery;
- transitively safe architecture-test stops;
- zero current raw presentation side doors.

Require:

- zero BLOCKER;
- zero SHOULD FIX.

Do not edit the Project Conformance Standard yet.

---

# 16. Leave everything unstaged and uncommitted

Even if all focused validation passes:

- do not stage;
- do not commit;
- do not push;
- do not merge;
- do not launch MessageLens Development.

The next step is another read-only human architectural review.

---

# Required response record

Create:

`01-ONBOARDING/responses/12-CORRECT-EXACT-COMMAND-CURRENTNESS-AND-COMPLETE-SEMANTIC-CENSUS.md`

Report:

1. baseline;
2. exact-command authorization model;
3. initial-import predicate;
4. reimport predicate;
5. continuation predicate;
6. automatic-recovery predicate;
7. final post-await mutation ordering;
8. deterministic predicate-withdrawal race tests;
9. retained-evidence behavior;
10. semantic-consumer root-discovery mechanism;
11. shell traversal correction;
12. transitive stop/leaf proof;
13. virtual census tests;
14. layout/private-symbol coupling reduction;
15. current production side-door check;
16. changed files;
17. focused test results;
18. architecture result;
19. analyzer result;
20. generation result if applicable;
21. `git diff --check`;
22. Project Conformance verdict;
23. remaining BLOCKER findings;
24. remaining SHOULD FIX findings;
25. exact Git status;
26. any stop gate.

Conclude exactly:

`PROMPT 11 ARCHITECTURAL FINDINGS CORRECTED: YES / NO`

If YES, also conclude:

`READY TO REPEAT HUMAN ARCHITECTURAL REVIEW: YES / NO`

Then STOP.
