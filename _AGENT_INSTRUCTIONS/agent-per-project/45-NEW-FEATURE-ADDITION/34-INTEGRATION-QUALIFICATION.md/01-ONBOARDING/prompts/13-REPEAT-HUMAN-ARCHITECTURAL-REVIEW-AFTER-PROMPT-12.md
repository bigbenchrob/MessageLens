# MessageLens Clean-Slate Integrated Qualification
## 13 — Repeat Human Architectural Review After Prompt 12

Prompt 12 reports that the remaining Prompt 11 findings have been corrected:

- exact command-specific current-report authorization is now enforced;
- non-external policy-withdrawal races are covered deterministically;
- semantic-consumer discovery is now repository-wide;
- shell/config traversal exemptions were removed;
- traversal stops are now traversed or mechanically proven transitively safe.

This task repeats the **full human architectural gate** against the actual
current unstaged implementation.

It is read-only.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT apply the parked WIP patch.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`
- `responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`
- `responses/06-IMPLEMENT-ONBOARDING-AUTHORITY-CORRECTION.md`
- `responses/07-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/08-CORRECT-ONBOARDING-AUTHORITY-REVIEW-FINDINGS.md`
- `responses/09-REPEAT-HUMAN-ARCHITECTURAL-REVIEW.md`
- `responses/10-CORRECT-POST-AWAIT-PREREQUISITE-CURRENTNESS-AND-SEMANTIC-CENSUS.md`
- `responses/11-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-AFTER-PROMPT-10.md`
- `responses/12-CORRECT-EXACT-COMMAND-CURRENTNESS-AND-COMPLETE-SEMANTIC-CENSUS.md`
- corrected canonical Onboarding authority documents.

Governing invariant:

> **Evidence may be distributed. Journey authority may not be.**

The purpose is to decide whether the complete current implementation is now
architecturally safe for **final full validation before checkpoint**.

# 1. Baseline and diff identity

Expected:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- index: empty
- tracked worktree: 47 modified files and 2 deleted files from the reviewed Onboarding correction
- intended untracked implementation/test files remain present
- shared-instructions submodule: clean
- parked WIP patch: unchanged and unapplied

Confirm Prompt 12 changed only the intended Onboarding implementation/test paths plus its response record. If unrelated tracked changes are present, STOP AND REPORT.

# 2. Repeat the complete architecture review

Do not review only Prompt 12. Re-evaluate the entire current Onboarding correction against:

1. sole Journey authority;
2. stable coordinator lifetime;
3. operation identity/currentness;
4. exact command authorization;
5. prerequisite precedence;
6. action provenance/currentness;
7. retained failed/interrupted evidence semantics;
8. startup-only durable-evidence adoption;
9. restart/reconciliation;
10. Journey-owned operation projection;
11. failure-publication ordering;
12. semantic presentation side doors;
13. specialist ownership/dependency direction;
14. architecture-test quality;
15. deletion/compatibility seams;
16. complete diff-shape/safety sanity.

The review must prove that Prompt 12 did not close one race by introducing another source of authority or policy duplication.

# 3. Verify exact command authorization from actual source

Inspect the current command-specific predicates and every mutation-capable caller.

Confirm that the coordinator now has distinct positive authorization rules for:

- initial import;
- reimport;
- interrupted Continue Setup;
- automatic recovery.

For each command verify that the latest coherent report is checked **after the last relevant await and immediately before mutation**.

Required property:

> The latest report must still authorize the exact command being executed, not merely lack an external blocker.

Trace first import, Retry of first import, reimport, Retry of reimport, Continue Setup, automatic-recovery begin, and automatic-recovery reset after progress persistence.

Confirm there is no await between the final command-specific authorization and the mutation boundary.

# 4. Review each exact-command predicate for semantic correctness

## Initial import

Verify that initial import is permitted only when the latest report still represents a valid initial-import state, including the accepted sparse/local-history case where applicable.

Confirm it is denied for already-ready installation, reset-required automatic recovery, app-owned failure requiring another Journey decision, maintenance, and external prerequisite blockers.

## Reimport

Verify that explicit Settings reimport uses its own canonical policy and is not accidentally tied to first-import semantics.

## Continue Setup

Verify that the final continuation predicate uses the same reconciliation/safe-boundary semantics that decide whether retained interrupted evidence is resumable. Confirm `ready` supersedes interruption.

## Automatic recovery

Verify that automatic recovery requires the current report to still positively require automatic reset/recovery immediately before both `begin` and reset.

# 5. Review deterministic non-external withdrawal races

Inspect the five new completer-held races.

Confirm they actually suspend execution at the claimed boundary and then change the latest coherent report to a non-external state that withdraws the exact command predicate.

Verify coverage for:

1. initial import -> current report no longer permits initial import;
2. reimport -> current report no longer permits reimport;
3. Continue Setup -> `ready` supersedes interruption;
4. automatic recovery -> reset requirement disappears before `begin`;
5. automatic recovery -> reset requirement disappears after `begin` but before destructive reset.

For each test confirm no timing sleep is the proof mechanism; begin/resume/reset counters prove the mutation was untouched; identity/retained evidence remains truthful; and the coordinator derives the correct current Journey Episode.

# 6. Reconfirm retained evidence semantics

Verify that stopping a stale command does not destroy or misattribute durable evidence.

Confirm:

- Retry stopped before replacement `begin` retains the prior failed UUID;
- a genuinely new admission/begin failure remains UUID-less;
- Continue Setup stopped before `resume` preserves interrupted UUID/session/status;
- automatic recovery stopped after `begin` but before reset retains truthful failed/retryable evidence rather than becoming success;
- resurfacing retained evidence after compatibility returns uses a current Journey occurrence;
- stale captured actions cannot act on resurfaced state.

# 7. Reconfirm prerequisite precedence

Verify the visible rule remains:

```text
current external prerequisite truth
        >
retained app-owned failure/interruption
```

for Messages/FDA, local Messages/source availability, local-history confirmation, and Contacts access.

Ensure exact-command helpers did not weaken this precedence.

# 8. Reconfirm startup-only unbound adoption

Verify unbound failed/interrupted evidence may be adopted only during the bounded startup reconciliation window; the window closes permanently; later unbound snapshot emissions remain history/diagnostics only; replay after terminal acknowledgement cannot move normal application; operation A cannot be rebound after operation B begins; and legitimate startup interruption is still adopted once.

# 9. Re-review repository-wide semantic root discovery

Inspect the current authority architecture test.

Confirm every non-generated Dart file under `lib/` is considered for semantic consumer discovery.

Verify production consumer discovery is based on Journey-semantic interfaces/identifiers rather than selected directories.

A conforming consumer moved to another feature, `lib/shared/...`, a generic resolver/read-model area, or shell/navigation infrastructure must remain inside the census automatically.

Confirm comments and string literals do not create false semantic roots.

# 10. Re-review transitive traversal and safe-stop policy

For each local dependency reached from a semantic consumer, confirm the test either traverses it or mechanically proves the complete property that makes it a safe terminal seam.

Review specifically shell, config, intent adapters, provider barrels, logging/diagnostic barrels, center-panel helpers, Advanced Start Fresh seams, graph-status sheet, and development diagnostic panel.

Confirm the development panel remains the sole bounded raw-evidence presentation exception and cannot feed raw facts back into production Journey semantics.

# 11. Verify virtual census tests exercise the real policy

Inspect the synthetic dependency-graph tests.

Confirm they use the same root-discovery/traversal/stop logic as the production census.

They must prove arbitrary shared wrapper discovery, shell-imported hidden raw evidence rejection, hidden raw evidence behind an apparent intent adapter rejection, config-hidden semantic wrapper rejection, legitimate narrow intent adapter acceptance, and the bounded development diagnostic exception.

Failure messages should expose the dependency path.

# 12. Review the census for overfitting

Ensure the architecture test protects semantic properties rather than freezing the current layout.

Check whether a conforming file move, private helper rename, or internal refactor would still pass without editing unrelated allowlists.

Stable named seams are acceptable where they represent actual architecture contracts.

# 13. Reconfirm stable coordinator lifetime and sole authority

Confirm:

- `OnboardingJourneyCoordinator` remains the sole writer/selector of `OnboardingJourneyState`;
- it remains keep-alive;
- changing evidence enters by listeners/event ingestion;
- changing evidence is not `ref.watch`ed from `build()` in a way that can reconstruct the owner mid-command;
- no self-invalidation exists;
- no production caller invalidates the Journey provider;
- the four exact-command helpers interpret one `_latestReport`, not separate caches/state machines;
- presentation does not participate in authorization.

The original stale-`ref` bug must remain impossible by construction.

# 14. Reconfirm operation identity and Journey projection

Trace one first-import attempt end to end and compare retry, reimport, and Continue Setup.

Confirm one logical operation UUID per attempt; retry obtains a new UUID only after successful replacement `begin`; Continue Setup retains the validated interrupted UUID and changes process session only through persisted `resume`; wrong ID/session/revision/stage/substage evidence is rejected; Journey projection remains immutable/data-only; raw `recoveryDisposition` is not presentation policy; unknown progress is indeterminate; and no graph-state or elapsed-time fallback fabricates completion.

# 15. Reconfirm UUID-less failure semantics

Confirm UUID-less failure remains UUID-less; failed-command intent remains coordinator/Journey state; first-import Try Again retries first import; reimport Try Again retries reimport; automatic recovery uses its intended policy; environment-only failure uses truthful Re-check semantics; nonrecoverable/manual failures expose no false retry; and retained old UUIDs are never attached to a newly failed admission/begin.

# 16. Reconfirm failure publication ordering

Confirm Journey failure publishes first; snapshot failure persistence, failure-store, logging, diagnostics, and refresh happen only afterward; secondary boundaries may fail independently; and the original operation error remains primary.

Exact-command currentness changes must not have introduced new fallible provider work ahead of failure publication.

# 17. Reconfirm specialist ownership

The coordinator may own Journey occurrence/Episode, current coherent report retention, exact-command policy interpretation, operation binding/currentness, action policy, and next-state choice.

It must not own FDA/Contacts probing mechanics, import implementation, graph construction, reset mechanics, snapshot persistence mechanics, archive mutation authority, or durable-completion proof mechanics.

# 18. Diff-shape and safety sanity

Inspect the complete current unstaged delta for duplicate authority/state, duplicate report caches, stale temporary race/census machinery, dead Prompt 12 code, contradictory comments, accidental API widening, generated mismatch, unrelated refactoring, database schema changes, attachment/archive authority changes, and privacy/data-safety regressions.

Do not broaden into aesthetic cleanup.

# 19. Validation scope

Prompt 12 already reports:

- focused tests: 88 passed;
- authority architecture tests: 13 passed;
- complete architecture suite: 500 passed;
- analyzer: clean;
- `git diff --check`: clean;
- Project Conformance correction delta: PASS.

Do not run the complete repository Flutter suite during this review.

Rerun only a narrow test if source inspection reveals a specific unresolved question.

If this review passes, the next task will run **final full validation before checkpoint**.

# 20. Required response

Create:

`01-ONBOARDING/responses/13-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-AFTER-PROMPT-12.md`

Report:

1. baseline/diff identity;
2. sole-authority/lifetime verdict;
3. exact-command authorization verdict;
4. initial-import predicate verdict;
5. reimport predicate verdict;
6. Continue Setup predicate verdict;
7. automatic-recovery predicate verdict;
8. deterministic withdrawal-race verdict;
9. retained-evidence verdict;
10. prerequisite-precedence verdict;
11. startup-adoption verdict;
12. operation identity/projection verdict;
13. UUID-less failure/action verdict;
14. failure-order verdict;
15. semantic root-discovery verdict;
16. transitive stop/leaf verdict;
17. virtual census-test verdict;
18. census overfitting verdict;
19. specialist-boundary verdict;
20. diff-shape/safety verdict;
21. concrete BLOCKER findings;
22. concrete SHOULD FIX findings;
23. OPTIONAL findings;
24. narrow tests rerun, if any;
25. exact Git status;
26. final architectural recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`POST-PROMPT-12 HUMAN ARCHITECTURAL REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO PROCEED TO FINAL FULL VALIDATION BEFORE CHECKPOINT: YES / NO`

Then STOP.
