# MessageLens Feature 34
## 41 — Refine AppCzar as a Dependency-Ordered Fair-Witness Reconciler

Response 40 established that the AppCzar simplification is viable. Do **not** implement it yet.

Human review refined the model further:

> AppCzar does not collapse the whole environment into one giant semantic state. It behaves as a Fair Witness: it gathers current observations, evaluates dependency-ordered facts, allows TRUE/FALSE/UNKNOWN, may discover several deficiencies, selects exactly one actionable disposition deterministically, and maps that disposition to exactly one coordinator.

This is a **read-only design refinement**. No source/test changes, app launch, database mutation, Start Fresh, import, staging, commit, or push.

## 1. Baseline

Require:

- worktree `/Users/rob/Development/FlutterProjects/remember_every_text`
- branch `fix/onboarding-import-stuck-state`
- HEAD/upstream `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- Prompt 32 + Prompt 35 correction unchanged
- Prompt 39 still superseded/unimplemented
- Response 40 present
- index empty
- shared-instructions submodule clean.

Read Response 40 in full first.

## 2. Fair Witness rule

Adopt explicitly:

> **AppCzar reports only what current evidence directly establishes. It does not fill in the historical story.**

Good:

```text
FDA is currently absent.
The graph currently contains 138,822 messages.
The current source count is UNKNOWN because the source cannot be read.
```

Bad unless directly proven:

```text
FDA was revoked.
Onboarding was interrupted.
The graph is ten messages behind.
```

Reflect this in naming, diagnostics, coordinator selection, and future tests.

## 3. Four layers

Refine the target model into:

```text
OBSERVATIONS
    raw present evidence

        ↓

FACTS / FINDINGS
    TRUE / FALSE / UNKNOWN
    several may coexist

        ↓

DISPOSITION
    exactly one actionable unmet prerequisite

        ↓

COORDINATOR
    exactly one
```

Only the Disposition has top-level control significance.

## 4. Three-valued facts

Every derived fact is exactly:

```text
TRUE
FALSE
UNKNOWN
```

UNKNOWN is not FALSE.

Example:

```text
FDAIsAvailable = FALSE
MessagesSourceIsReadable = UNKNOWN
CurrentSourceInventoryIsKnown = UNKNOWN
GraphMatchesCurrentSource = UNKNOWN
```

Never substitute an old value for an UNKNOWN current fact.

## 5. Explicit dependency DAG

Design AppCzar facts as a directed acyclic graph.

A fact may be evaluated only when its prerequisites are sufficiently known.

Example shape only:

```text
FDAIsAvailable
      ↓
MessagesSourceIsReadable
      ↓
CurrentSourceInventoryIsKnown
      ↓
GraphCanBeComparedWithCurrentSource
      ↓
GraphMatchesCurrentSource
```

Independent branches may exist:

```text
OverlayIsReadable -> OverlayIsHealthy

ArchiveIsConfigured
      ↓
ArchiveVolumeIsPresent
      ↓
ArchiveIdentityIsCorrect
```

Derive the actual minimal DAG from MessageLens. Do not invent dependencies merely to force ordering.

## 6. DAG lives in code, not a database

Databases/OS probes provide observations.

The dependency graph expresses architectural truth and must be version-controlled program logic.

Do not propose mutable DB dependency tables.

## 7. Discovery order cannot matter

Invariant:

> **Same complete evidence set -> same fact graph -> same actionable frontier -> same disposition -> same coordinator.**

Do not use first failure found, Future completion order, widget mount order, or provider initialization order.

Independent probes may run concurrently where safe.

## 8. Define the actionable frontier

Propose a precise rule such as:

> A FALSE fact is actionable when the prerequisites needed to understand/remediate it are established and no unmet ancestor must be corrected first.

Downstream facts blocked by UNKNOWN are not actionable.

Make this mechanically testable.

## 9. Independent simultaneous deficiencies

Topological order alone cannot choose between independent roots.

Example:

```text
FDAIsAvailable = FALSE
ArchiveVolumeIsPresent = FALSE
OverlayIsHealthy = TRUE
```

Do not choose the first discovered.

Propose the smallest deterministic tie rule, preferably derived from:

- dependency dominance;
- observation-enabling prerequisites;
- preservation/safety boundaries;
- only if still necessary, a tiny explicit named root-domain precedence.

No hidden numeric priority scores.

A candidate principle to evaluate, not blindly adopt:

> Address first the deficiency whose correction makes the greatest amount of the remaining assessment knowable or protects the most fundamental safety boundary.

## 10. Descriptive naming

Fact/disposition names describe what current evidence establishes.

Prefer:

```text
FDAIsCurrentlyUnavailable
ThisLocalGraphIsInternallyHealthy
TheCurrentMessageSourceCannotBeInspected
ThisHealthyLocalDatasetIsBehindTheCurrentSource
TheConfiguredAttachmentArchiveIsCurrentlyUnavailable
TheEvidenceIsContradictory
```

Avoid historical/process-story names such as:

```text
OnboardingWasInterrupted
FDAWasRevoked
Updating
Remediating
InstallFailed
```

Long explicit names are acceptable.

## 11. Separate disposition from coordinator mapping

Target:

```text
observations
-> fact DAG
-> descriptive disposition
-> one exhaustive disposition-to-coordinator mapping
-> coordinator
```

AppCzar says what is presently true. A tiny exhaustive mapping says who handles it.

Coordinator names must not appear inside the descriptive disposition.

## 12. Rewrite Response 40's state table

Rework `ONBOARDING / UPDATING / REMEDIATING / OPERATING / CANNOT_DETERMINE`.

Determine which become:

- observations
- facts
- dispositions
- coordinators
- UI modes.

`ASSESSING` may remain a process phase.

`Operating` may remain a coordinator/session jurisdiction, but AppCzar should select it via a descriptive disposition such as `ThisAppearsToBeAHealthyCurrentInstallation`.

## 13. Preserve exactly-one-coordinator

After disposition:

> **Exactly one coordinator owns semantic control.**

A coordinator may run a Journey, ask the user, invoke workers, or acquire Ball tenure.

It cannot select another coordinator.

Its bounded terminal contract remains:

- `OK` when jurisdiction remains valid;
- `RESTART` when its work may have changed AppCzar-relevant facts.

## 14. Preserve restart as epistemic boundary

Examples:

```text
Initial build completes
-> RESTART
-> fresh AppCzar
-> fresh observations
-> healthy-current-installation disposition
-> Operating coordinator
```

```text
Start Fresh completes
-> RESTART
-> fresh AppCzar
-> no complete local dataset
-> Onboarding coordinator
```

No success callback may make MessageLens Operating.

## 15. Journey stays self-contained

AppCzar selects the Onboarding jurisdiction only.

The Journey runs its own present-reality tests and decides its own Trip/Step.

No durable Journey cursor.

## 16. Interrupted build stays disposable

Preserve Response 40's simplification:

- import/graph/rich-text progress in memory only;
- interrupted live-source build discarded and rebuilt;
- protected historical/non-live sources block unsafe deletion;
- archive payloads, overlay, Presence, configuration/identity remain protected.

Do not reintroduce resume state.

## 17. Repeated-failure fact remains policy only

Retain the smallest equivalent of:

`consecutive_initial_build_attempts`

It may influence retry policy but never current app classification or Journey position.

Audit whether AppCzar or Onboarding should read it; choose the simpler ownership.

## 18. Startup UI should expose the fact graph

Example:

```text
Checking MessageLens…

✓ Full Disk Access
✓ Messages database reachable
✓ MessageLens graph healthy

Messages on Mac                 138,832
Messages in MessageLens         138,822

? Graph currentness             waiting for source comparison
✓ Overlay                       healthy
✕ Attachment archive            volume unavailable
```

Do not display downstream conclusions before prerequisites are established.

UNKNOWN/pending must be explicit and truthful.

## 19. Keep Response 40's deletion direction

Do not redo the whole census unless necessary.

Verify that the DAG refinement still supports deletion/demotion of:

- historical installation classifier
- Environment readiness classifier
- durable operation snapshot
- resume/reconciliation state
- persisted navigation
- semantic failure rows
- completion handoffs.

The refinement must not add more semantic machinery than it removes.

## 20. Produce the concrete MessageLens fact DAG

Primary deliverable.

Cover only launch-disposition-relevant branches:

- root/data-folder safety
- FDA/source observability
- source inventory/currentness
- import/graph health/coherence
- overlay health
- Presence health if top-level relevant
- archive configuration/availability/identity
- incomplete disposable live-only derived data
- protected non-live historical-source material
- contradictory/unstable evidence.

For every node provide:

- plain-English name
- proposed code name
- direct observation or derived fact
- prerequisites
- TRUE meaning
- FALSE meaning
- UNKNOWN propagation
- whether FALSE is actionable
- coordinator mapping if it can become a disposition.

## 21. Plain-English disposition algorithm

Fit it on one page.

Target shape:

```text
1. Observe independent roots.
2. Evaluate facts whose prerequisites are sufficiently known.
3. Propagate UNKNOWN where required evidence cannot be established.
4. Continue until no more facts can be evaluated.
5. Find the actionable unmet-prerequisite frontier.
6. If no deficiency remains and healthy/current facts are proven:
      choose healthy-installation disposition.
7. If one actionable deficiency dominates:
      choose it.
8. If several independent actionable deficiencies remain:
      apply the one explicit deterministic tie rule.
9. If evidence is contradictory, unstable, or cannot produce a unique disposition:
      choose Cannot Determine.
10. Map the disposition to exactly one coordinator.
```

Refine to the smallest correct algorithm.

## 22. Future property tests

Design, do not implement, tests proving:

- observation completion order cannot change disposition;
- every coherent evidence set yields exactly one disposition;
- UNKNOWN never becomes FALSE or a historical value;
- downstream facts cannot evaluate before prerequisites;
- independent failures use the explicit tie rule;
- same evidence always yields same disposition;
- persisted Journey/sidebar/operation state cannot influence the DAG;
- no coordinator result feeds back into same-process AppCzar classification;
- only fresh launch constructs a new AppCzar assessment.

## 23. Scenario matrix

Run these through the DAG:

1. first launch, FDA absent;
2. FDA absent + archive volume absent;
3. FDA absent + healthy established graph;
4. graph healthy but source ahead;
5. graph unhealthy + source reachable;
6. partial live-only graph/import;
7. graph contains protected non-live historical-source material;
8. archive unavailable while source/graph healthy;
9. overlay corrupt;
10. source changes during assessment;
11. import killed halfway;
12. import completed but process dies before any completion callback;
13. Start Fresh completes;
14. contradictory facts / no unique disposition.

For each:

```text
observations
-> TRUE/FALSE/UNKNOWN facts
-> actionable frontier
-> disposition
-> coordinator
-> terminal behavior
```

Keep each concise.

## 24. Remaining real product decisions

Refine Response 40's open questions:

- Is Contacts reachability launch-level or coordinator-local?
- Is Presence health top-level or feature-local?
- Does any source delta require foreground Update, or may Operating absorb small deltas?
- What is the principled independent-root tie rule?
- What exact user choice follows repeated build failures?

Separate architecture necessities from product choices.

## 25. No implementation

Do not create classes, enums, providers, migrations, or delete old machinery yet.

Human review of the fact DAG comes first.

## 26. Required response

Create Response 41.

Report:

1. executive refinement summary
2. final Fair Witness rule
3. Observation / Fact / Disposition / Coordinator distinction
4. three-valued semantics
5. concrete MessageLens dependency DAG
6. UNKNOWN propagation
7. actionable-frontier definition
8. deterministic independent-root tie proposal
9. descriptive naming rules/examples
10. revised Response 40 state-table mapping
11. one-disposition / one-coordinator rule
12. restart epistemic boundary
13. Journey self-location
14. interrupted-build rule
15. repeated-failure fact ownership
16. startup assessment UI
17. disposition-selection algorithm
18. property/invariant test plan
19. 14-scenario walkthrough
20. changes to Response 40 deletion/demotion map
21. remaining product decisions
22. DAG-introduced implementation risks
23. whether this is simpler than Response 40
24. whether Prompt 39 remains superseded
25. exact Git/worktree/index/submodule state
26. confirmation nothing was modified.

Conclude exactly:

`FAIR-WITNESS APPCZAR REFINEMENT COMPLETE: YES / NO`

`APP DISPOSITION IS DEPENDENCY-DETERMINISTIC: YES / NO`

`DISCOVERY ORDER CAN AFFECT DISPOSITION: YES / NO`

`MULTIPLE ACTIONABLE DEFICIENCIES CAN RUN CONCURRENTLY: YES / NO`

`READY FOR HUMAN REVIEW OF THE FACT DAG: YES / NO`

Then STOP.
