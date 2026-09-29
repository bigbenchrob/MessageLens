# MessageLens Clean-Slate Integrated Qualification
## 14 — Re-Anchor Onboarding to Ball-and-Track Authority

Prompt 13 exposed that the remaining runtime defect is a mechanical authority/provenance failure, not a failure of sole Journey authority.

The bad loop is:

```text
Onboarding command
-> acquires mutation authority
-> its own acquisition publishes "locked"
-> environment report sees "locked"
-> report becomes maintenanceInProgress
-> admitted command asks whether it may proceed
-> its own lock can cause it to deny itself
```

We have solved this class of problem before with the **Ball And Track / Mechanical Impossibility** model:

> **If you are not holding the ball, you cannot be on the track.**

And conversely:

> **The operation holding the ball cannot be denied access to the track merely because the track is occupied by the operation holding the ball.**

This is a **read-only architecture rediscovery and design task**.

Do NOT modify production code or tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT apply the parked WIP patch.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

The goal is to stop adding more exceptions around `maintenanceInProgress` and instead restore mechanically correct ownership.

## 1. Read the current authority history

Read in full:

- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`
- `responses/03-ONBOARDING-AUTHORITY-FORENSIC-AUDIT.md`
- `responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`
- `responses/07-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/08-CORRECT-ONBOARDING-AUTHORITY-REVIEW-FINDINGS.md`
- `responses/10-CORRECT-POST-AWAIT-PREREQUISITE-CURRENTNESS-AND-SEMANTIC-CENSUS.md`
- `responses/11-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-AFTER-PROMPT-10.md`
- `responses/12-CORRECT-EXACT-COMMAND-CURRENTNESS-AND-COMPLETE-SEMANTIC-CENSUS.md`
- `responses/13-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-AFTER-PROMPT-12.md`
- corrected canonical Onboarding authority documents.

Do not treat Prompt 13 as an invitation to add another Boolean exception.

## 2. Rediscover the earlier Ball And Track solution

Search current source, canonical docs, architecture records, tests, and Git history for the prior Ball And Track / Mechanical Impossibility design.

Look for:

- mutation owner;
- lock owner;
- re-entrant mutation ownership;
- same-owner access;
- async `Zone` ownership;
- operation identity propagated through `Zone`;
- lease/capability/owner token;
- `ArchiveMutationCoordinator`;
- `dbMaintenanceLockProvider`;
- nested/descendant protected-resource access;
- fail-closed unrelated maintenance.

Establish from repository evidence:

1. what problem the earlier model solved;
2. what the “ball” actually was in code;
3. how owner identity was created and propagated;
4. how same-owner descendants proved authority;
5. how unrelated callers were denied;
6. whether that mechanism still exists today;
7. whether Onboarding currently bypasses or discards that provenance.

Classify historical conclusions as VERIFIED HISTORY / STRONGLY SUPPORTED INFERENCE / UNKNOWN.

## 3. Reconstruct the current mutation authority

Inspect `ArchiveMutationCoordinator` and relevant mutation-state types.

Document:

- admission API;
- published lock/mutation state;
- all identity/provenance fields;
- whether state distinguishes no owner / self owner / foreign owner;
- whether private async `Zone` identity exists;
- how re-entrant/same-owner access works;
- how release occurs;
- whether ownership survives awaits safely.

Do not invent a new token until the existing mechanism is fully understood.

## 4. Find the exact provenance-loss point

Trace:

```text
ArchiveMutationCoordinator authority
-> published mutation state
-> onboardingEnvironmentReportProvider
-> OnboardingEnvironmentReport
-> OnboardingJourneyCoordinator
-> exact-command authorization
```

Identify the precise point where an owner-aware fact becomes an ownerless fact such as `isLocked == true` or `maintenanceInProgress`.

Answer explicitly:

> Does the current environment-report path collapse “locked by me” and “locked by someone else” into the same value?

If yes, identify the exact symbol/call site.

## 5. Re-state the Mechanical Impossibility rule

The design must guarantee:

```text
if no mutation owner:
    command may attempt admission

if this exact command owns the admitted mutation authority:
    its own lock cannot deny it

if another owner holds mutation authority:
    deny / wait / fail closed according to existing policy

if ownership cannot be proven:
    deny
```

A command must not reason “maintenance probably means me.” It must mechanically prove ownership, or that distinction must be resolved before the report becomes denial evidence.

## 6. Choose where ownership belongs

Evaluate the real code and choose the smallest conforming design among:

### A. Owner-aware environment evidence
Preserve typed ownership provenance into the environment report so Journey can distinguish self-owned from foreign maintenance.

### B. Separate prerequisites from mutation admission
Keep environment report as installation truth, but do not use aggregate self-caused maintenance to re-authorize a command that already holds the mutation authority. Final authorization uses independent prerequisites + exact command policy + Journey/operation currentness + proof of held lease.

### C. Existing Ball/Track capability
If the coordinator already propagates a same-owner capability/Zone identity, reuse it directly so the admitted command can prove “I hold the ball.”

A hybrid is acceptable only if responsibilities remain singular and explicit.

Choose based on repository evidence, not aesthetics.

The selected design must:
- reuse existing authority machinery where possible;
- keep unrelated maintenance fail-closed;
- prevent self-denial by construction;
- preserve one Journey semantic authority;
- require no presentation knowledge of mutation ownership;
- remain testable with real lock/report behavior.

## 7. Clarify Environment Report semantics

Define whether `maintenanceInProgress` means:
- any mutation is active;
- unrelated mutation blocks this observer;
- diagnostic aggregate state not suitable for same-owner authorization;
- or another precise concept.

Distinguish:

> “What is true of the installation/environment?”

from:

> “May this already-admitted command continue?”

If report remains owner-agnostic, explicitly prohibit treating self-caused aggregate maintenance as the final denial answer for the owner.

## 8. Preserve exact-command policy without tail-chasing

Keep the positive command-specific predicates from Prompt 12:

- initial import eligibility;
- explicit reimport eligibility;
- interrupted continuation eligibility;
- automatic recovery/reset eligibility.

But make final authorization operate on the correct facts:

```text
same Journey command?
same action/occurrence?
same operation binding where applicable?
still owns admitted mutation authority?
independent prerequisites still valid?
exact command predicate still true?
    -> mutate
otherwise
    -> stop / rederive Journey
```

The command's own admitted lock must not appear in the “independent prerequisites still valid?” answer.

Do not regress to broad no-blocker checks, cached pre-admission reports, skipped post-await checks, accepting all maintenance, or enum special-casing without ownership proof.

## 9. Design production-realistic race tests

The current `_ImmediateArchiveMutationCoordinator` removes the critical behavior.

Design completer-controlled tests using the real lock/report relationship or an equivalent lock-publishing coordinator.

Cover:

### First import
- valid Ready-to-Import;
- acquire lock-publishing authority;
- report observes self-owned maintenance;
- command still reaches `begin`;
- foreign maintenance or independent prerequisite withdrawal still stops it.

### Reimport
Same proof from canonical reimport state.

### Continue Setup
- valid interruption;
- acquire self-owned authority;
- self-maintenance does not cancel `resume`;
- foreign maintenance or true continuation-policy withdrawal does cancel it.

### Automatic recovery
- self-owned lock alone does not cancel its own reset;
- clearing `shouldResetAppDatabasesBeforeImport` still stops reset;
- foreign/unproven lock remains fail-closed.

No timing sleeps as proof.

Tests must prove both:
- self-owned lock does not deny;
- foreign/unproven lock does deny.

## 10. Audit `maintenanceInProgress -> OnboardingNormalApplication`

Prompt 13 found `_journeyFromEnvironment` maps maintenance to `OnboardingNormalApplication`.

Determine:
- why this mapping exists;
- whether it is canonical;
- whether safe for first-run/interrupted Onboarding;
- whether it was intended only for unrelated application maintenance;
- whether it can release normal application while Onboarding work remains outstanding.

Do not change it in this design task.

Classify it as correct / context-dependent / obsolete drift / separate blocker.

## 11. Resolve the two bounded census design gaps

Prompt 13 also found:
1. raw graph/controller evidence is missing from the main side-door policy;
2. `OnboardingStatus`-only user-visible consumers are not semantic roots.

Design only the bounded corrections:
- one unified raw-evidence side-door set including environment, snapshot/controller, reconciliation, and graph/controller evidence;
- make `OnboardingStatus` a root signal where it controls user-visible Onboarding routing/presentation;
- add virtual tests for a semantic root reaching raw graph evidence and an `OnboardingStatus`-only consumer;
- retain narrowly proved exceptions for development diagnostics and independent graph-status UI.

Do not redesign the whole census again unless evidence requires it.

## 12. Produce the simplified final authority graph

Include one diagram showing:
- Journey authority;
- independent prerequisite evidence;
- operation evidence;
- Ball/Track mutation admission;
- admitted owner identity;
- command execution;
- presentation.

It must make this state mechanically impossible:

```text
command owns mutation authority
+
command denied because its own authority made the track busy
```

There should be no circular “ask the consequence of my own lock whether my lock is allowed” path.

## 13. Define the smallest implementation boundary

Do not implement.

Specify the minimum production/test files expected to change.

Prefer:
1. reuse existing Ball/Track owner identity;
2. preserve provenance instead of creating parallel state;
3. change the final authorization input/contract;
4. use realistic lock/report tests;
5. close the two bounded census gaps;
6. leave unrelated Onboarding architecture untouched.

Explicit non-goals:
- no change to sole Journey authority;
- no new operation UUID model;
- no startup-adoption redesign;
- no prerequisite-precedence redesign;
- no failure-order redesign;
- no presentation side-door restoration;
- no archive-preservation change;
- no database schema change;
- no snapshot-v1 format change unless repository evidence proves unavoidable.

## 14. Stop gates

STOP AND REPORT if:
- the earlier Ball/Track model cannot be found and a new capability system would be required;
- current mutation state has no trustworthy owner provenance and adding it materially changes mutation architecture;
- same-owner handling would weaken unrelated-maintenance fail-closed behavior;
- the fix would restore direct presentation evidence;
- environment-report changes would create a second authority;
- `maintenanceInProgress -> OnboardingNormalApplication` is independently unsafe and requires broader Journey redesign;
- any schema/data/archive migration is necessary;
- another canonical contradiction is found.

## 15. Required response

Create:

`01-ONBOARDING/responses/14-BALL-AND-TRACK-ADMITTED-COMMAND-AUTHORITY-DESIGN.md`

Report:

1. baseline;
2. rediscovered Ball/Track history;
3. current mutation authority/provenance;
4. exact provenance-loss point;
5. Mechanical Impossibility invariant;
6. selected design;
7. rejected alternatives;
8. Environment Report semantic role;
9. post-admission authorization contract;
10. command-specific Ball/Track interaction;
11. realistic race-test design;
12. `maintenanceInProgress -> OnboardingNormalApplication` finding;
13. bounded census corrections;
14. final authority graph;
15. smallest implementation boundary;
16. expected changed files/symbols;
17. explicit non-goals;
18. open human decisions;
19. stop gates;
20. recommendation for next implementation prompt.

Do not modify implementation.

Conclude exactly:

`BALL-AND-TRACK AUTHORITY DESIGN COMPLETE: YES / NO`

If YES, also conclude:

`MECHANICAL SELF-DENIAL CAN BE MADE IMPOSSIBLE: YES / NO`

Then STOP.
