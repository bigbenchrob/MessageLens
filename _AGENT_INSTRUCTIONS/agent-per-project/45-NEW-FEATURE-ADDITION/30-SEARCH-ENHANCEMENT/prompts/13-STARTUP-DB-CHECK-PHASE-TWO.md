



We have completed Startup Stage One.

Current state:

- Branch: `codex/fix-startup-graph-schema`
- Starting HEAD for the Stage One work: `e9971be8f5411c9e69c9a807add74e7acbb5b20e`
- Schema-fix commit: `18926d23b5dac315c3d719024e47f73776abac02`
- Current app version after Stage One edits: `0.2.108+126`
- The authoritative graph schema version is `3` in:
  `lib/essentials/db/app_database_schema_versions.dart`
- Both Drift and installation validation now consume that shared version.
- No FTS schema, migration, rebuild, or user database was changed.

Stage One changed startup so the long installation-classification check now runs behind a visible restricted Flutter shell rather than before `runApp`.

The first Flutter frame appears in roughly 1 second. The expensive classification still takes roughly 12–13 seconds, largely because `PRAGMA quick_check(1)` deliberately remains in the admission path.

The normal `App`, writable providers, persistent logger, persistent error reporting, background intake, and completed-installation window restoration remain gated until installation classification succeeds.

Classification semantics were intentionally preserved in Stage One:

- `PRAGMA quick_check(1)`
- schema/table inspection
- exact import/graph count reconciliation
- existing classification/failure behavior

all still remain in place.

## Stage Two objective

Investigate and design the next startup improvement:

**Separate cheap, bounded startup inspection from expensive SQLite integrity validation, with an explicit typed escalation policy.**

The objective is to make ordinary startup admission substantially faster without weakening data-integrity guarantees or silently changing installation-classification semantics.

Do NOT begin by editing files.

First perform a read-only architectural audit and report your findings and proposed implementation plan.

## Questions the audit must answer

### 1. Map the current validation pipeline

Identify every startup operation involved in installation classification, in execution order.

For each operation, report:

- what it validates
- which database(s) it touches
- whether it is read-only
- whether its runtime is expected to scale with database size
- whether it is bounded or potentially expensive
- what typed result or failure it currently produces
- what downstream code relies on that result

Pay particular attention to:

- `PRAGMA quick_check(1)`
- schema version checks
- expected table/index checks
- import database inspection
- graph database inspection
- exact import/graph count reconciliation
- onboarding / virgin-installation boundaries
- repair / incompatible / corrupt classifications
- any startup flags or prior state that influence validation

### 2. Determine exactly what `quick_check(1)` protects against

Do not treat `quick_check` as a generic “safety check.”

Identify the concrete corruption classes or failure modes that the rest of the current startup inspection would NOT detect if `quick_check(1)` were skipped.

Also identify any failures currently attributed to `quick_check` that are already independently detectable by:

- opening the database
- reading schema metadata
- querying expected tables
- count reconciliation
- Drift/open-time failures
- other existing checks

The goal is to understand the actual incremental protection provided by `quick_check`.

### 3. Identify all callers and assumptions

Find every caller, test, provider, startup state, UI surface, or architectural invariant that currently assumes that successful installation classification implies that `quick_check(1)` has already passed.

Report whether removing `quick_check` from every ordinary startup would violate any current documented or tested invariant.

### 4. Measure or estimate the cost distribution

If practical without modifying user data, identify the relative cost of:

- database open
- schema inspection
- table/index existence checks
- exact import/graph reconciliation
- `quick_check(1)`

Prefer existing instrumentation or a disposable isolated clone/test fixture.

Do not add persistent instrumentation yet.

The purpose is to establish whether `quick_check` is in fact the dominant cost and whether exact reconciliation is cheap enough to remain in Stage Two unchanged.

### 5. Propose a typed two-tier validation model

Design a model with two conceptual levels:

#### Tier A — bounded startup inspection

This should contain only operations suitable for the ordinary startup admission path.

Candidates may include:

- database openability
- schema/version checks
- required structural checks
- exact logical reconciliation if it is sufficiently cheap

Do not assume all of these belong here; justify each one.

#### Tier B — escalated integrity validation

This is where expensive integrity checking such as `PRAGMA quick_check(1)` would live.

Define explicit typed states/results. Do not use loosely coupled booleans such as:

- `needsDeepCheck`
- `isProbablyOkay`
- `skipQuickCheck`

unless they are merely internal implementation details behind a stronger domain model.

The startup state model should make it impossible, or at least difficult, to accidentally treat:

- bounded inspection success
- full integrity validation success
- integrity validation pending
- integrity validation required
- integrity validation failed

as equivalent states.

### 6. Propose the escalation policy

The most important Stage Two design question is:

**Under exactly what circumstances must expensive integrity validation run?**

Investigate what evidence is already available that could support escalation, such as:

- first launch after migration/schema transition
- detected structural inconsistency
- failed logical reconciliation
- unclean or interrupted prior startup/shutdown
- prior validation failure
- explicit repair workflow
- database replacement/import
- version transition
- periodic validation marker
- explicit user-requested validation
- other existing startup metadata

Do not invent a complicated policy merely because these possibilities exist.

Recommend the minimum policy that is:

- understandable
- deterministic
- testable
- durable
- difficult to bypass accidentally

If the repository currently lacks enough trustworthy evidence to implement a safe conditional policy, say so explicitly.

### 7. Clarify when admission is allowed

For each proposed typed state, specify whether the normal app may be admitted.

In particular, answer:

- Can the app be admitted after bounded inspection while a non-required integrity check runs later?
- If so, what is the precise distinction between “optional/background integrity check” and “required-before-admission integrity check”?
- What happens if a deferred integrity check later fails?
- Are writable providers allowed before that check completes?
- Is background intake allowed?
- Should the startup shell ever transition to a restricted repair state instead of the full app?

Do not weaken current safety behavior without making that change explicit.

### 8. Preserve Stage One boundaries

Stage Two must not regress the Stage One architecture.

The following remain hard constraints unless you identify a compelling architectural contradiction:

- `runApp` remains early.
- The restricted startup shell remains visible during classification.
- Normal writable application state remains gated until admission.
- Virgin/onboarding paths remain isolated correctly.
- Native archive claim / single-instance behavior remains before Flutter startup where currently required.
- No user database may be modified merely for timing or experimentation.
- Do not touch FTS schema or rebuild behavior unless a direct dependency is discovered.
- Preserve unrelated worktree changes.
- Avoid broad refactors or formatting churn.

### 9. Keep exact logical reconciliation unchanged initially

Unless your audit demonstrates that count reconciliation is itself a major startup cost or architecturally inseparable from `quick_check`, Stage Two should leave its semantics unchanged.

We want to isolate one variable:

**moving expensive physical SQLite integrity checking out of the ordinary critical path when safe to do so.**

Do not optimize several independent validation mechanisms in the same stage.

### 10. Tests and architecture tripwires

Identify the tests that must change or be added.

At minimum, propose coverage for:

- ordinary bounded validation success
- escalation-required state
- integrity validation success
- integrity validation failure
- no accidental admission while required validation is pending
- ordinary startup does not invoke expensive validation when policy says it is unnecessary
- escalation conditions reliably invoke it
- virgin/onboarding behavior remains unchanged
- schema mismatch still fails correctly
- logical reconciliation failure still fails correctly
- startup state transitions are explicit and deterministic

If useful, add architecture tests that prevent future code from reintroducing heavyweight integrity validation into the ordinary admission path accidentally.

## Deliverable

Return a read-only investigation report containing:

1. Current startup validation flow
2. Cost/risk analysis of each stage
3. Exact incremental role of `PRAGMA quick_check(1)`
4. All callers and assumptions tied to its current placement
5. Proposed typed validation-state model
6. Proposed escalation policy
7. Admission rules for every state
8. Minimal file-edit scope
9. Test plan
10. Risks and unresolved questions
11. Recommended implementation sequence

Do not edit any files until this report is complete.

If the audit reveals that moving `quick_check` off the ordinary critical path cannot be done safely with the evidence currently persisted by the app, say so. In that case, propose the smallest prerequisite needed to make Stage Two safe rather than silently weakening validation.

The desired outcome is not merely “startup is faster.”

The desired outcome is:

> ordinary startup performs only bounded work required to establish sufficient confidence for admission, while expensive physical integrity validation is governed by an explicit typed escalation policy that preserves or improves the application's current safety guarantees.
