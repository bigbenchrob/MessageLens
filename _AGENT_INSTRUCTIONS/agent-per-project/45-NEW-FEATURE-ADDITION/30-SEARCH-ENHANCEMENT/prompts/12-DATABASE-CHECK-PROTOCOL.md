
Please perform a **read-only audit** of MessageLens startup database validation and propose a safer, faster two-tier startup policy.

Do not edit files yet.

## Context

Recent startup profiling established that MessageLens currently performs `PRAGMA quick_check(1)` on all four databases before `runApp`, and that the import and graph database scans account for most of the visible blank-window delay.

The current observed cost is roughly:

- `macos_import_ss.db` quick check: ~7 seconds
- `working_ss.db` quick check: ~5 seconds

Together, those two scans account for most of the startup delay.

The intended UX direction is:

1. Render a real Flutter startup shell promptly.
2. Perform **cheap health checks** appropriate to the normal expectation that databases are healthy.
3. Show a visible status such as:
   - “Checking databases…” with a spinner
   - then a brief success state such as “Databases okay”
4. Only if the cheap checks reveal something suspicious should MessageLens escalate to a full integrity scan.
5. During escalation, explain what is happening, e.g.:
   - “MessageLens found something suspicious with one or more databases. Please wait while a more thorough check is performed.”
6. After the full scan, choose an appropriate safe outcome:
   - continue if healthy;
   - perform a safe known recovery/remediation path if supported;
   - or present a clear diagnostic/logging path if manual intervention is required.

The objective is to preserve MessageLens’s safety guarantees **without performing expensive full integrity scans on every healthy launch**.

## Audit goals

Please determine:

### 1. What startup validation currently does

Trace the full startup validation pipeline from native window creation through `runApp`.

For each step, identify:

- what it checks;
- why it exists;
- whether it is required before rendering;
- whether it mutates anything;
- typical measured cost;
- worst-case blocking behavior.

Classify each current check as:

- cheap and suitable every launch;
- moderate but acceptable after first frame;
- expensive and suitable only on suspicion;
- unnecessary/redundant.

### 2. What `quick_check` is protecting us from

For each database:

- `user_overlays.db`
- `macos_import_ss.db`
- `working_ss.db`
- `presence.db`

identify what corruption/failure modes `PRAGMA quick_check(1)` can detect that the cheaper existing checks cannot.

Also identify which serious conditions are already caught by:

- file existence;
- file size;
- read-only open;
- `PRAGMA user_version`;
- required-table inventory;
- targeted row/count queries;
- schema expectations;
- archive marker validation;
- current onboarding evidence classification.

The goal is to understand what safety we actually lose if `quick_check` is removed from the normal fast path.

### 3. Design a cheap “healthy launch” gate

Recommend the smallest set of checks that can reasonably establish:

> “This installation looks normal enough to proceed.”

These should ideally be very fast and should avoid traversing the full database.

Evaluate candidates such as:

- file exists;
- file is non-empty where expected;
- SQLite opens read-only successfully;
- expected schema version;
- required tables exist;
- one or two lightweight targeted reads;
- expected archive/source identity markers;
- other existing invariants.

Do not assume every current check belongs in the fast path.

For each proposed fast check, explain exactly what failure would trigger escalation.

### 4. Define escalation criteria

Specify which conditions should cause MessageLens to run a full integrity scan.

Examples might include:

- SQLite open failure;
- unsupported or unexpected schema version;
- missing required table;
- malformed expected metadata;
- previous unclean shutdown;
- failed migration marker;
- prior recorded integrity failure;
- unexpected archive/source identity;
- targeted query failure;
- other evidence of suspicious state.

Do not invent persistent flags unless they are clearly justified and fit existing architecture.

### 5. Evaluate clean-shutdown / trust-state options

Investigate whether MessageLens already records enough state to distinguish:

- clean shutdown;
- interrupted/crashed shutdown;
- incomplete migration;
- incomplete onboarding/recovery;
- previously validated healthy installation.

If not, assess whether a small durable health/trust marker would be worthwhile.

Do not implement one yet.

If such a marker is proposed, describe:

- where it should live;
- when it is set;
- when it is cleared;
- what events invalidate it;
- how to avoid trusting stale state after schema or data changes.

### 6. UI sequencing

Evaluate how startup can be reorganized so Flutter renders before database validation completes.

The desired conceptual flow is:

```text
native window
→ initialize minimum runtime
→ runApp
→ render safe startup shell
→ perform cheap checks
→ healthy: enter normal app
→ suspicious: show explanatory deep-check state
→ run full integrity checks
→ continue / remediate / diagnostic path
```

Identify which existing pre-`runApp` operations must remain before rendering for safety and which can safely move afterward.

Do not weaken archive admission, single-instance safety, or other true preconditions merely for speed.

### 7. Deep-check behavior

If escalation occurs, define:

- which databases should receive `quick_check`;
- whether checks can run in parallel safely;
- whether `integrity_check` is ever warranted instead;
- how progress should be represented;
- what evidence should be retained for diagnosis;
- when MessageLens can continue despite a warning;
- when it must stop.

Do not implement automatic repair logic unless an already-existing safe repair path clearly applies.

### 8. Failure UX

Recommend a simple user-facing state model, for example:

#### Normal

“Checking databases…”

then briefly:

“Databases okay”

#### Suspicious

“MessageLens found something suspicious with one or more databases. Please wait while a more thorough check is performed.”

#### Deep check healthy

“Database check completed. Everything looks okay.”

#### Deep check failure

Explain:
- which database is affected;
- whether MessageLens can continue;
- whether recovery is available;
- how to collect/export diagnostics or logs.

Do not finalize exact copy unless useful; focus first on states and transitions.

### 9. Preservation-safety review

MessageLens has strong preservation requirements.

Explicitly identify any risk introduced by:

- rendering before validation finishes;
- allowing normal UI access before cheap checks complete;
- deferring integrity checks;
- running deep checks in the background;
- trusting a prior healthy state.

Recommend appropriate gating so users cannot write/change state in ways that could worsen a suspicious installation.

### 10. Performance target

Propose a realistic startup target for the fast path.

The goal should be something like:

- first Flutter frame quickly after process launch;
- cheap database validation comfortably sub-second where possible;
- certainly no repeated 10–20 second integrity scan on normal healthy launches.

Do not fabricate measurements; use existing measured costs where available.

## Deliverable

Return:

1. current startup validation pipeline;
2. classification of each current check by cost/necessity;
3. what safety `quick_check` currently provides;
4. proposed fast-path checks;
5. exact escalation triggers;
6. clean-shutdown / trust-marker recommendation;
7. proposed post-`runApp` sequencing;
8. deep-check policy;
9. failure-state UX model;
10. preservation-safety constraints;
11. expected performance improvement;
12. exact proposed edit scope;
13. test plan;
14. risks and unresolved questions;
15. recommended minimal implementation sequence.

Do not modify source files.
Do not alter any databases.
Do not begin link-preview work.

That should give us the evidence needed to redesign startup without accidentally weakening the safety model.