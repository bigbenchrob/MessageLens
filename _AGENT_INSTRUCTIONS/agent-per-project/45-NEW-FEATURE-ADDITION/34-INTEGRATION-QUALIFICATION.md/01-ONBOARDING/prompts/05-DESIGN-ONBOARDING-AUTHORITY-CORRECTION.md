# MessageLens Clean-Slate Integrated Qualification
## 05 — Design the Onboarding Authority Correction

The canonical contradiction is resolved and the forensic audit is complete.

Read in full before doing anything:

Top-level onboarding foundation records:

- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`

Completed forensic responses:

- `responses/03-ONBOARDING-AUTHORITY-FORENSIC-AUDIT.md`
- `responses/04-RESOLVE-CANONICAL-ONBOARDING-AUTHORITY-CONTRADICTION.md`

Corrected canonical onboarding documents:

- `25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md`
- `25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md`

Also read all canonical Journey/Trip/Step, Environment Readiness, Presence
scheduler/currentness, Riverpod-provider, and project architecture rules cited
by the forensic audit.

The governing invariant is now explicit:

> **Evidence may be distributed. Journey authority may not be.**

This task is a **design task only**.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT apply the parked WIP patch.
Do NOT launch MessageLens Development.
Do NOT repeat Start Fresh or import.
Do NOT access real databases or attachment archives.

---

# 1. Checkpoint the canonical authority correction first

Before beginning the correction design, verify that the only tracked changes are
the two approved canonical onboarding-document edits from Prompt 04.

If and only if that is true:

1. stage only:
   - `25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md`
   - `25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md`
2. run `git diff --cached --check`;
3. commit them as a documentation-only architecture checkpoint.

Suggested commit:

`docs(onboarding): restore journey-only authority`

Do not stage:

- qualification prompts/responses;
- the two top-level Feature 34 forensic foundation documents unless already
  intentionally tracked by repository policy;
- unrelated untracked files;
- the parked WIP patch.

If any other tracked change exists, STOP AND REPORT.

After the documentation checkpoint, the tracked worktree and index must again be
clean before design work continues.

---

# 2. Preserve the parked failed-fix patch

The earlier unfinished fix remains preserved outside the worktree at:

`/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`

Do not apply it.

You may inspect it read-only only if it helps explain a design choice or avoid
repeating a failed approach.

It is not an approved implementation.

The new design must derive from the forensic audit and canonical architecture,
not from preserving the shape of that patch.

---

# 3. Accepted forensic findings

Treat these as established:

1. `OnboardingJourneyCoordinator` is the sole literal writer of
   `OnboardingJourneyState`.

2. That is not enough to make it the sole effective authority.

3. Current production presentation has exactly four Journey-semantic state
   influencers:
   - Journey state — legitimate;
   - `OnboardingEnvironmentReport` — side door;
   - `ConversationGraphBuildController` — side door;
   - `OnboardingOperationSnapshot` — side door.

4. There are exactly three direct presentation side doors.

5. The observed stuck modal was caused by two interacting defects:
   - the long-lived coordinator command continued using its notifier `ref` after
     a watched dependency changed, preventing failure publication;
   - presentation combined stranded Journey state with stale graph/snapshot
     evidence outside the Journey.

6. Operation identity is strong inside the snapshot controller but incomplete
   end-to-end.

7. Current Journey running states do not bind the active operation ID.

8. Presentation does not validate operation identity/generation.

9. Failure persistence/logging/provider invalidation can prevent Journey failure
   publication.

10. Existing widget and architecture tests explicitly encode the invalid
    side-door architecture.

11. No snapshot schema migration is required merely to restore sole authority.

12. The generic Presence scheduler is a positive identity/currentness pattern,
    but production Onboarding must remain its typed Episode architecture rather
    than resurrecting the retired Presence onboarding scheduler.

---

# 4. Human decisions that govern the design

The forensic audit left four policy questions. Resolve them in the design using
the following decisions.

## 4.1 `recoveryDisposition`

`recoveryDisposition` is **operation evidence/capability**, not Journey retry
policy.

It may state facts such as whether durable work is resumable and from which safe
boundary.

Only `OnboardingJourneyCoordinator` decides whether the current Journey offers:

- Continue Setup;
- Retry;
- restart from a safe boundary;
- another Journey action.

Do not let the snapshot encode the user-visible retry decision.

## 4.2 Restart/interruption policy

Reconciliation of interrupted durable evidence may happen automatically.

Long-running user onboarding work must **not automatically resume execution**
merely because an old snapshot exists.

The coordinator may bind reconciled interrupted evidence to the new process's
current Journey occurrence only after validating:

- operation kind;
- exact durable stage/substage;
- current installation/environment prerequisites;
- recovery capability;
- current Journey compatibility.

The ordinary user-facing result is an explicit coordinator-owned action such as
**Continue Setup**.

Existing separately designed automatic derived-data recovery may remain
automatic only where canonical architecture already explicitly authorizes it and
the coordinator owns the decision.

Do not blur interrupted user import with automatic recovery.

## 4.3 Dormant legacy/development surfaces

Do not broaden this correction into speculative cleanup.

- Development diagnostic surfaces may remain if they inject/display evidence
  without becoming Journey authority.
- Dormant production legacy awaiting-content branches should be removed only
  after source/use proof shows they are unreachable and their removal is a
  natural consequence of the authority cutover.
- Otherwise record them as separate cleanup.

## 4.4 Modal dismissibility

Active work may remain non-dismissible **only while the coordinator proves that
the currently displayed Journey operation is the matching active operation**.

Failure, interruption, cancellation, or retryable state must always expose an
actionable Journey state.

This correction does not require adding a generic close button.

---

# 5. Design the stable coordinator lifetime

The first root defect is a lifetime error:

`OnboardingJourneyCoordinator.build()` watches evidence whose change can
invalidate the notifier while one of its own long-running commands is still
executing.

Design the smallest canonical Riverpod architecture that ensures:

- the object/state owner required to finish or fail a command cannot be
  invalidated by evidence changes caused by that command;
- external evidence remains reactive;
- only one Journey authority exists;
- no global singleton or second state machine is introduced;
- normal provider disposal/reconstruction semantics remain testable;
- startup/restart can reconstruct Journey from authoritative evidence.

Evaluate the actual repository's established Riverpod idioms.

At minimum compare the relevant merits of:

- a stable Journey notifier using `ref.listen`/event ingestion rather than
  `watch`-driven self-reconstruction;
- a stable command/state owner plus a narrow evidence-bridge provider;
- another existing project pattern that better satisfies the same invariant.

Choose one design.

Do not leave multiple options unresolved unless direct code constraints make a
human decision genuinely necessary.

Explain exactly why the chosen provider lifecycle cannot reproduce the observed
`!_didChangeDependency` stale-`ref` failure.

---

# 6. Design the Journey-owned operation identity

The coordinator must own or bind operation identity before publishing the
corresponding running Episode.

Design the exact sequence for first import, reimport, and resumable interrupted
work.

For a newly starting operation, the design must answer:

1. who allocates/obtains the operation ID;
2. when mutation admission occurs;
3. when the durable operation snapshot begins;
4. when the Journey publishes a running Episode;
5. what identity that Episode carries;
6. what identity the executor receives;
7. how progress/failure/completion returns;
8. how every update is matched to the current Journey occurrence and operation;
9. when identity is retired.

Avoid the current order in which the Journey can enter a running state before
the operation ID is visible to it.

Reuse the snapshot controller's existing UUID/currentness machinery where
possible rather than inventing another unrelated operation ID system.

---

# 7. Define the Journey-owned operation projection

Design a narrow immutable projection owned by current Journey state.

It should expose only what presentation needs after coordinator validation.

Candidate evidence includes:

- operation ID;
- operation kind;
- stage;
- substage;
- progress value when truthful;
- progress revision;
- bounded counts/units;
- interpreted failure state;
- available Journey actions.

Do not simply embed a live provider/controller.

Do not make the widget interpret `recoveryDisposition`.

Do not duplicate the entire durable snapshot unnecessarily.

Specify:

- exact proposed type(s);
- which Journey Episodes carry it;
- which fields are copied/projected from durable evidence;
- which fields are interpreted by the coordinator;
- how monotonic revision/currentness is enforced;
- how stale evidence is rejected;
- what presentation sees when no numeric percentage exists.

---

# 8. Remove all three presentation side doors

Design the cutover so that `OnboardingOverlay` and related production
presentation stop deriving Journey semantics directly from:

- `onboardingEnvironmentReportProvider`;
- `conversationGraphBuildControllerProvider`;
- `onboardingOperationSnapshotProvider`.

For each current direct read, specify its lawful replacement.

Examples:

- prerequisite copy/details may come from the coherent
  `journey.evidence.report`;
- operation progress comes from the Journey-owned operation projection;
- graph success/failure copy comes from the coordinator's interpretation of the
  current operation, not raw graph state.

Do not create three new wrapper providers that preserve the same authority
split.

The end state must be:

> Journey state in, widgets out.

---

# 9. Define failure publication ordering

Design every operation catch/failure path around this invariant:

> A valid Journey failure/retry state must be publishable even if logging,
> durable failure persistence, provider invalidation, diagnostics, or another
> evidence producer fails.

Specify the required ordering.

The design should ordinarily make Journey failure publication the first
non-fallible semantic transition once the coordinator knows the operation
failed.

Then perform fallible work such as:

- logging;
- snapshot failure persistence;
- failure-store persistence;
- report invalidation;
- diagnostics;

as best-effort or separately contained evidence work.

Address each failure weakness listed in the forensic audit:

- snapshot `runStage` failure persistence masking original error;
- graph-failure store persistence before Journey failure;
- logger/ref reads before failure publication;
- durable-verification failure path;
- reimport admission/begin failures;
- automatic recovery final conversion.

Explain how the original error remains observable without allowing evidence
persistence failure to strand the Journey.

---

# 10. Bind user actions to Journey occurrence

The forensic audit identified action paths that validate only state type at
entry and can cross async gaps.

Design whether and where typed actions should carry or capture:

- Journey occurrence;
- expected Episode;
- operation ID.

At minimum address:

- retry;
- terminal dismiss/OK;
- Continue Setup;
- any delayed callback capable of acting on a later compatible-looking Episode.

Borrow the stale-interaction rejection idea from Presence/advanced Start Fresh
where useful.

Do not over-tokenize synchronous buttons that cannot survive an async gap unless
there is a concrete stale-action risk.

---

# 11. Restart and reconciliation design

Define the authoritative restart sequence.

At minimum cover:

- no operation snapshot;
- running snapshot from prior process -> interrupted reconciliation;
- exact resumable substage;
- non-resumable failure;
- completed snapshot whose Journey terminal acknowledgement never occurred;
- stale completed snapshot unrelated to the current Journey;
- current prerequisites changed since the operation ran.

Specify:

- what evidence is loaded;
- who interprets it;
- when a new Journey occurrence is created;
- whether/when an old operation ID remains relevant;
- when **Continue Setup** appears;
- how stale durable completion is prevented from directly creating terminal
  presentation.

No direct snapshot-to-widget reconstruction is permitted.

---

# 12. Preserve specialist ownership

The design must not turn `OnboardingJourneyCoordinator` into a god object.

Keep existing specialists responsible for their work:

- source-scoped import;
- graph construction;
- durable operation evidence;
- reset;
- completion verification;
- archive mutation admission;
- FDA/environment probing;
- Contacts probing.

The coordinator owns:

- current Journey occurrence;
- current Episode;
- operation binding/currentness;
- interpretation of evidence;
- user-visible action policy;
- what happens next.

Clearly state the dependency direction.

---

# 13. Test-first correction architecture

Design the tests that should fail before implementation and pass afterward.

## Architecture tripwires

Require tests that prohibit onboarding presentation semantic dependencies on:

- raw environment report provider;
- raw graph controller provider;
- raw operation snapshot provider.

Require running Journey states to carry bound current-operation identity where
applicable.

## Deterministic replay

Design current production Episode replays for at least:

- FDA absent -> leave -> FDA restored;
- local-history confirmation;
- Contacts blocker;
- first import success;
- first import failure -> retry -> success;
- interrupted import -> Continue Setup;
- durable verification failure;
- terminal acknowledgement;
- restart.

## Hostile asynchronous noise

Inject:

- late graph success from operation A;
- late snapshot progress from A;
- late failure from A;
- provider reconstruction;
- delayed callback from prior Journey occurrence;
- duplicate evidence revision.

Prove operation/Journey B is unchanged.

## Failure independence

Inject failures in:

- logging;
- snapshot failure persistence;
- failure-store persistence;
- report invalidation;
- completion evidence persistence.

Prove Journey always reaches its defined failure/retry Episode.

---

# 14. Migration/compatibility design

The forensic audit concluded no snapshot schema migration is required merely to
restore authority.

Confirm that conclusion.

Specify how existing version-1 snapshots will be interpreted after the
correction.

Do not bump snapshot format merely to rename conceptual ownership.

If a schema/version change actually becomes necessary for operation identity
binding, STOP AND REPORT with the exact reason rather than inventing migration
work.

---

# 15. Cutover sequencing

Design implementation phases that never leave two user-visible authorities
active at once.

A preferred conceptual order is:

1. failing tests/tripwires;
2. stable coordinator lifetime;
3. Journey-owned operation identity/projection;
4. evidence currentness/revision acceptance;
5. failure-order hardening;
6. presentation cutover;
7. side-door removal;
8. obsolete state cleanup;
9. deterministic/conformance/full validation.

But inspect real dependency constraints and propose the safest exact sequence.

No intermediate checkpoint may intentionally leave presentation reading both the
new Journey projection and an old semantic side door.

---

# 16. Documentation updates required after implementation

Do not edit them now beyond the already approved canonical checkpoint.

The design should identify future changes required to:

- canonical onboarding authority docs;
- import/migration coordination docs;
- Project Conformance Audit Standard;
- generic Journey/Presence feature-integration rules;
- implementation/qualification record;
- architecture tests.

The eventual Project Conformance mandatory question should be equivalent to:

> For every changed stateful workflow, enumerate every component capable of
> advancing, completing, failing, retrying, cancelling, dismissing, or changing
> user-visible workflow state. Is exactly one component authoritative, and are
> all durable or asynchronous evidence sources operation-identity-bound inputs
> to that authority rather than direct presentation inputs?

Do not update the conformance standard until implementation has proved the rule
works.

---

# 17. Required design response

Create:

`01-ONBOARDING/responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`

The response must include:

1. documentation checkpoint commit;
2. final provider/lifetime architecture;
3. final state-flow diagram;
4. exact operation-start sequence;
5. Journey operation identity model;
6. Journey operation projection type/fields;
7. evidence acceptance/currentness rules;
8. presentation cutover mapping for each of the three side doors;
9. failure-publication ordering;
10. action/occurrence binding rules;
11. restart/reconciliation policy;
12. specialist ownership/dependency direction;
13. test-first matrix;
14. compatibility/migration conclusion;
15. exact implementation phases;
16. files/symbols expected to change;
17. obsolete code/tests expected to be removed;
18. documentation changes deferred until implementation proof;
19. open human decisions, if any;
20. mandatory stop gates for implementation.

Do not implement code in this task.

---

# Mandatory stop gates

STOP AND REPORT if:

- the chosen stable coordinator lifetime requires a second Journey state owner;
- current Riverpod/project rules make a stable sole authority impossible without
  a broader architectural change;
- operation identity cannot be bound before running-state publication;
- presentation cannot be cut off from all three raw semantic sources without
  losing required truthful information;
- restoring failure independence requires swallowing operation errors;
- restart semantics cannot distinguish stale evidence from current resumable
  work;
- a snapshot schema migration becomes necessary;
- the correction would require changes to attachment archive authority,
  database schema, or production data;
- another canonical authority contradiction is found.

Do not design through a stop gate.

---

# Final response

Conclude with exactly:

`ONBOARDING AUTHORITY CORRECTION DESIGN COMPLETE: YES / NO`

If YES, also conclude:

`SAFE TO BEGIN TEST-FIRST ONBOARDING AUTHORITY CORRECTION: YES / NO`

Then STOP.
