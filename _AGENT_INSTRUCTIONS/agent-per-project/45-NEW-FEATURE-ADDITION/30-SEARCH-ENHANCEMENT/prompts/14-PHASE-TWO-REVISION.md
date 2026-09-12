Here is the Stage Two implementation prompt, with the policy decision stated explicitly so Codex does not try to preserve the old “scan every page every launch” guarantee.



Please implement **Startup Stage 2**.

Stage One is complete: MessageLens now renders a restricted startup shell before installation classification finishes.

This stage changes the startup safety policy deliberately:

> **Full physical database integrity validation is NOT required on every ordinary healthy launch.**

The new product policy is:

> Every launch performs cheap structural/logical validation.
> Full `PRAGMA quick_check(1)` validation is reserved for suspicious state and explicitly safety-critical workflows.

This is an intentional policy change. Do not build extra receipt/quarantine infrastructure merely to preserve the old per-launch full-scan guarantee.

Do not begin link-preview work.

## Core startup behavior

Healthy path:

```text
archive admission
→ runApp
→ “Checking databases…”
→ fast bounded inspection
→ logical classification
→ “Databases okay”
→ normal app
```

Suspicious path:

```text
archive admission
→ runApp
→ “Checking databases…”
→ fast inspection finds suspicious evidence
→ explain that a deeper check is needed
→ run quick_check only on implicated database(s)
→ continue / remediation / diagnostics
```

## Policy decisions

The following are approved:

1. Ordinary healthy startup does **not** require `quick_check`.
2. Bounded structural/logical evidence is sufficient for ordinary startup admission.
3. Full physical integrity validation remains required for:
   - suspicious startup evidence;
   - interrupted/failed onboarding or contradictory durable facts;
   - known older schema before writable migration;
   - legacy destructive-journal cleanup;
   - Start Fresh authorization/verification;
   - explicit repair/diagnostic requests.
4. No positive “trusted database” receipt is required for this stage.
5. No generic clean-shutdown marker is required.
6. No revocable runtime quarantine system is required merely to enable healthy fast-path admission.
7. Existing preservation guarantees around destructive workflows remain unchanged.

## Part 1 — Introduce typed separation

Refactor the current startup validation model so these concepts are distinct:

- bounded structural inspection;
- integrity validation;
- installation classification/admission.

The exact type names may follow repository conventions, but the model should be equivalent to:

```text
BoundedInspection
IntegrityValidation
StartupAdmission / StartupValidationState
```

Do not retain one ambiguous `isUsable` Boolean that means both “structurally plausible” and “full integrity scan passed.”

The code should make it explicit whether a database:

- passed bounded inspection;
- requires deep validation;
- passed deep validation;
- failed structurally/logically;
- failed physical integrity validation.

## Part 2 — Split bounded inspection from `quick_check`

Refactor the SQLite installation evidence reader so normal bounded inspection does **not** execute:

```sql
PRAGMA quick_check(1)
```

Move physical integrity validation behind an explicit deep-check path.

The bounded reader should remain strictly read-only.

For every existing database, retain appropriate cheap checks such as:

- path exists;
- non-zero size;
- read-only SQLite open;
- `query_only`;
- `PRAGMA user_version`;
- required schema-object inventory;
- bounded targeted reads.

Use the audit’s proposed structural checks as guidance.

## Part 3 — Fast-path checks

For a healthy current installation, use the bounded checks necessary to establish:

> “This installation is structurally and logically plausible enough to admit.”

### `user_overlays.db`

At minimum:

- expected schema version;
- required preservation/user-intent tables;
- onboarding-operation snapshot read/parse;
- no full integrity scan.

Reuse the same connection for the operation snapshot if practical.

### `macos_import_ss.db`

At minimum:

- expected schema version;
- `messages` table;
- `source_registry`;
- bounded message-presence check;
- non-live-source detection using `EXISTS` where possible;
- existing exact message-count evidence may remain for this stage if required by classification.

### `working_ss.db`

At minimum:

- expected schema version;
- required graph tables;
- `message_text_fts`;
- expected FTS triggers for schema 3;
- bounded message/chat/edge presence checks;
- one bounded FTS read sufficient to prove the FTS object is readable;
- existing exact message-count evidence may remain for this stage.

### `presence.db`

At minimum:

- expected schema version;
- required tables;
- bounded reads.

Do not add broad new inventories that recreate the cost of `quick_check`.

## Part 4 — Escalation triggers

Escalate to deep physical validation when bounded inspection finds suspicious evidence.

Implement explicit typed triggers for at least:

- zero-byte database;
- invalid SQLite / `NOTADB`;
- `SQLITE_CORRUPT`;
- unexplained I/O failure;
- missing required object at current schema;
- bounded targeted-read failure;
- malformed onboarding snapshot;
- import/graph logical mismatch;
- interrupted/failed/running onboarding operation that requires validation before continuation;
- known older supported schema before writable migration;
- legacy destructive-journal path;
- Start Fresh mutation boundary.

Treat:

- `SQLITE_BUSY`
- `SQLITE_LOCKED`

as contention, not corruption.

Do not label unsupported future schema as corruption. Reject it directly as unsupported.

## Part 5 — Deep-check behavior

Deep validation should:

- use `PRAGMA quick_check(1)`;
- run only against implicated databases unless the suspicion is cross-store;
- check both import and graph when their relationship is suspect;
- remain read-only;
- not automatically repair;
- not automatically reset;
- not migrate databases.

A successful physical check does **not** override:

- unsupported schema;
- missing required objects;
- logical contradiction;
- failed preservation rules.

If deep validation succeeds and all logical checks also pass, admission may continue.

## Part 6 — Startup UX

Use the restricted startup shell introduced in Stage One.

Required visible states:

### Fast check

`Checking databases…`

with an activity indicator.

### Fast-path healthy

Briefly indicate:

`Databases okay`

Do not introduce a gratuitous fixed delay solely to display this message.

### Escalation

When deeper validation is required, show a clear explanation along the lines of:

`MessageLens found something suspicious with one or more databases. Please wait while a more thorough check is performed.`

Also show truthful progress such as:

`Checking working_ss.db`

or:

`Checking database 1 of 2`

Do not invent percentage progress.

### Deep-check failure

Remain in restricted mode and present the existing remediation/diagnostic path as appropriate.

Do not expose the normal app until admission succeeds.

## Part 7 — Preserve critical full-validation workflows

Do not weaken these paths:

### Legacy destructive journal

Keep full fail-closed integrity proof before journal cleanup if that is the current safety contract.

### Start Fresh

Keep fresh authoritative validation at the destructive mutation boundary and after reset as currently required.

Do not make those paths use the weaker healthy-launch policy merely because ordinary startup now does.

## Part 8 — Keep exact logical reconciliation for now

Do not optimize away exact import/graph message-count reconciliation in this stage unless required by the typed refactor.

The audit showed it is not the main startup cost.

The expensive `quick_check` removal is the approved optimization.

Do not replace exact counts with high-water heuristics yet.

## Part 9 — Tests

Add/update tests proving:

### Fast path

- normal bounded inspection never executes `quick_check`;
- healthy schema-3 graph passes bounded inspection;
- healthy completed installation reaches normal app without full integrity scan;
- no user database is modified;
- no WAL/SHM files are created by inspection;
- normal app is not exposed before admission.

### Escalation

- missing required object escalates;
- malformed SQLite escalates appropriately;
- targeted-read corruption escalates;
- import/graph mismatch deep-checks both;
- interrupted/failed onboarding escalates;
- busy/locked produces contention state, not corruption;
- future unsupported schema fails closed without pointless `quick_check`;
- older supported schema requires deep validation before migration.

### Deep validation

- requested target executes `quick_check`;
- unrelated databases are not scanned unnecessarily;
- deep-pass cannot override structural/schema/logical failure;
- deep-failure remains restricted/remediation state.

### Critical workflows

- legacy journal cannot be cleared without full integrity proof;
- Start Fresh still requires full integrity proof at the existing mutation boundaries.

### UI

- first frame shows `Checking databases…`;
- healthy fast path transitions to normal app;
- escalation state renders explanatory text;
- deep-check progress identifies current database/count;
- failure never constructs normal app.

### Architecture

Add or update tripwires ensuring:

- bounded reader source cannot contain `quick_check`;
- startup bounded inspection cannot depend on normal writable database providers;
- archive admission still precedes `runApp`;
- normal app remains gated on typed admission.

## Part 10 — Validation and timing

Run:

- focused onboarding/startup tests;
- installation evidence reader tests;
- classifier/provider tests;
- legacy journal tests;
- Start Fresh tests;
- graph database tests;
- architecture suite;
- `flutter analyze`;
- `git diff --check`;
- macOS build.

Then manually measure:

- direct `.app` launch;
- Run Without Debugging.

Report:

1. native-window-to-first-Flutter-frame;
2. duration of bounded inspection;
3. total time to normal application admission;
4. confirmation that healthy startup performs no `quick_check`;
5. confirmation that suspicious fixtures still invoke deep validation.

Do not fabricate performance claims.

## Git hygiene

Preserve unrelated untracked files.

Commit Stage One separately if it is not already committed.

Then commit Stage Two separately with a message such as:

`perf(startup): reserve integrity scans for suspicious state`

Do not squash unrelated history.

## Out of scope

Do not change:

- database schema versions;
- FTS schema/triggers;
- import pipeline;
- graph projection;
- exact/prefix search semantics;
- link-preview work;
- attachment archive policy;
- reset targets;
- user data;
- release metadata beyond what project convention requires for this tester-visible behavior.

## Deliverable

Report:

1. branch and starting HEAD;
2. Stage One commit status/hash;
3. files changed;
4. typed validation model introduced;
5. bounded fast-path behavior;
6. exact escalation triggers implemented;
7. deep-check policy;
8. preserved full-validation workflows;
9. startup UX states;
10. tests added/updated;
11. validation results;
12. launch timing before/after;
13. confirmation healthy startup no longer runs `quick_check`;
14. any remaining bottlenecks;
15. git status;
16. recommended next step.

Do not begin link-preview implementation after this stage.

This prompt makes the key product decision explicit: **we are intentionally trading the old “scan every page every launch” guarantee for a fast, evidence-based healthy-launch policy, while preserving full scans where they are actually justified.**
