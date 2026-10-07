# MessageLens Feature 34
## 78 — Checkpoint Onboarding Qualification and Audit the AppCzar Local Data Repair Jurisdiction

Response 77 completed the isolated human qualification of AppCzar Onboarding.

The live evidence now proves both sides of the Onboarding boundary:

```text
SAFE EMPTY
-> archive admission
-> AppCzar composition
-> AppCzar Onboarding
-> current Messages/Contacts prerequisites
-> existing initial-build pipeline
-> real process restart
-> fresh AppCzar
-> post-build Attachment Archive Repair
```

and:

```text
CONSEQUENTIAL PARTIAL
-> archive admission
-> AppCzar composition
-> Initial construction scope = consequential data present
-> NOT Onboarding
-> virtual Local Data Repair
-> no build
-> no cleanup
-> consequential data unchanged
```

This is a major milestone.

The development execution census is now:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Local Data Repair           VIRTUAL ONLY
Diagnostic Review           VIRTUAL ONLY
```

Production startup remains legacy and unchanged.

The next jurisdiction is **Local Data Repair**.

This prompt is deliberately **audit/design first** because Local Data Repair is
potentially destructive. It must not treat all incomplete or unhealthy local
state as disposable.

The governing rule is:

> **MessageLens may delete and reconstruct derived local data only when current
> evidence proves that every consequential byte being discarded is rebuildable
> from current authoritative sources and that no protected non-live/historical
> material, user intent, archive payload, configuration, or unique provenance
> would be destroyed.**

Do NOT implement Local Data Repair in this prompt unless the audit proves an
extremely narrow Stage One can be implemented mechanically without guessing.
Default: audit/design only.

Do NOT route production through AppCzar.
Do NOT make Diagnostic Review executable.
Do NOT perform any real repair/reset.
Do NOT access or mutate the real WD development archive or Toshiba attachment
archive.

---

# 1. Baseline

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`;
- current HEAD/upstream synchronized `0/0`;
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree.

Read:

- Response 40;
- Response 41;
- Response 71;
- Response 72;
- Response 77;
- current AppCzar evaluator/fact graph;
- current initial-construction scope reader;
- `MessageDataResetService`;
- Start Fresh implementation;
- historical-source import/removal machinery;
- current source-scoped import database schema/provenance model;
- conversation graph health/coherence readers;
- archive/overlay/Presence preservation boundaries;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Checkpoint Prompt 77 / Response 77 human qualification first

Prompt 77 made no source/test changes and is now governing live evidence.

Create a narrow documentation checkpoint containing Prompt 77 and Response 77
before any source edit.

Record exactly:

```text
AppCzar Onboarding human live qualification: PASS

Qualified safe-empty path:
    disposable admitted development root
    AppCzar composition
    AppCzar Onboarding
    source prerequisite owned by AppCzar Onboarding
    legacy Journey inert
    existing initial-build pipeline
    real process restart
    fresh AppCzar post-build disposition

Qualified unsafe path:
    consequential partial data
    NOT Onboarding
    virtual Local Data Repair
    no build
    no cleanup
    partial data unchanged
```

Also preserve the important live counts from the disposable successful build:

```text
source messages imported: 139071
working graph messages: 139071
post-build fresh disposition: Attachment Archive Repair
```

Push normally before any source edits.

No force push, rebase, squash, or unrelated staging.

---

# 3. Reconfirm current AppCzar execution census

Before auditing Local Data Repair, verify source still provides exactly:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Local Data Repair           VIRTUAL ONLY
Diagnostic Review           VIRTUAL ONLY
```

No generic dispatcher.

Production still uses the legacy startup composition.

If this differs, STOP AND REPORT.

---

# 4. Reconstruct the exact current Local Data Repair selection frontier

Source-trace every current AppCzar fact/disposition that can select the virtual
Local Data Repair destination.

At minimum classify these cases separately:

```text
A. consequential partial import/graph data
B. import/graph internally unhealthy or corrupt
C. import/graph pair structurally inconsistent
D. protected non-live/historical source material in an incomplete dataset
E. retired/unsupported derived artifacts
F. complete local dataset with incompatible current-source lineage
G. current source older/divergent from local derived data
H. local store evidence UNKNOWN/inconclusive
```

For each answer:

- current observation(s);
- TRUE/FALSE/UNKNOWN fact(s);
- selected descriptive disposition;
- whether current source maps it to Local Data Repair or Diagnostic Review;
- whether any current automatic action is actually safe.

Do not let one umbrella `localDataRepair` label hide materially different
safety classes.

---

# 5. Restore the F18–F21 protection model from current source

Response 41 defined the critical disposal-safety chain:

```text
F18  Protected non-live source material is present
F19  Incomplete derived data currently exists
F20  Incomplete derived data contains only live-source material
F21  Incomplete live-only data can be rebuilt from the current source
```

Audit how much of that model now exists in current code after the later
initial-construction work.

Specifically determine whether current source can prove:

```text
incomplete consequential data exists
AND
all consequential imported material belongs to the current live source
AND
no protected non-live/historical source is present
AND
all consequential local live-source facts are reconstructible from the
current authoritative source NOW
```

The last proposition is stronger than:

```text
all rows have source_id = live_chat_db
```

A row imported from the live source months ago may no longer exist in current
`chat.db`.

Do not equate live provenance with current reconstructibility.

---

# 6. Define current reconstructibility exactly

Design the minimum Fair-Witness fact required before destructive reset.

Conceptually:

```text
IncompleteLiveOnlyDerivedDataIsReconstructibleFromCurrentSource
```

It must answer whether every consequential local fact that would be deleted by
repair can be reconstructed from the current source state.

Audit possible evidence such as:

- canonical source identity;
- imported source row IDs / GUIDs;
- frozen/high-water coverage;
- current source `MAX(ROWID)`;
- current source message count;
- existence of every imported live-source key in current source;
- deletions from live Messages since import;
- attachment metadata relationships;
- graph rows derived only from imported current-source facts.

Prefer a bounded database comparison rather than materializing full rows.

If exact reconstructibility cannot be proven cheaply, identify the safest
coarser condition that still avoids data loss.

Never use historical operation state such as “previous build interrupted.”

---

# 7. Protected non-live/historical material

Audit how historical/non-live sources are represented in `macos_import_ss.db`.

Answer:

1. Can non-live source presence be proven with a bounded query?
2. Can the exact protected source identities/counts be enumerated?
3. Does `MessageDataResetService` currently delete the entire source-scoped
   import database, including historical/non-live rows?
4. Would any existing reset therefore destroy protected historical material?
5. Can live-derived repair be scoped without deleting historical rows, or would
   that require a new partial-import surgery path?
6. Is historical-source removal already owned by a separate explicitly
   authorized workflow?

Default safety rule:

```text
protected non-live/historical material present
-> NO automatic whole-derived-store reset
```

Do not invent a partial SQL deletion repair in this prompt.

---

# 8. Audit `MessageDataResetService` as a potential repair worker

Source-trace the exact current service.

Report:

- exact files/database families it deletes;
- SQLite sidecars it deletes;
- retired derived artifacts it deletes;
- provider close/invalidation sequence;
- basename/path validation;
- mutation authority/Ball path;
- locks/gates acquired;
- what it explicitly preserves;
- post-delete verification;
- idempotence/retry semantics;
- behavior if interrupted between files;
- whether it assumes a legacy Journey caller.

Preservation must include at minimum:

```text
user_overlays.db / user intent
presence.db
archive marker / identity
attachment_archive payloads
attachment archive configuration
preferences
logs/diagnostics unless explicitly ephemeral
```

Do not rely only on documentation; trace implementation.

---

# 9. Compare the three destructive/reset concepts

Keep these semantically distinct:

## Local Data Repair

System-selected jurisdiction because current local derived data cannot safely
support normal operation.

## Start Fresh

Explicit human command to discard enumerated rebuildable message data even when
the current installation may otherwise be usable.

## Historical source removal

Explicitly removes a selected protected historical source through its own
specialist workflow.

Audit overlap and reuse.

Local Data Repair must not inherit broader Start Fresh product meaning or
historical-source-removal authority merely because they share lower reset
mechanics.

---

# 10. Determine repair classes

Produce a typed Local Data Repair classification with the smallest useful set.

Conceptual target:

```text
rebuildableLiveOnlyPartial
    current evidence proves incomplete derived state
    no protected non-live material
    exact current-source reconstructibility proven

protectedHistoricalMaterial
    repair would require deleting protected non-live/historical data

unhealthyButReconstructibilityUnknown
    corruption/unsupported state prevents proving safe deletion

retiredDerivedResidue
    only specifically enumerated obsolete derived artifacts are present and
    current source/preservation stores are otherwise safe

lineageConflict
    complete or partial local data cannot be proven equivalent/reconstructible
    from current source

unknownOrConflicting
    evidence insufficient for a safe repair decision
```

Use fewer or differently named classes if source supports a cleaner taxonomy.

For each class specify:

- literal facts;
- whether Local Data Repair owns jurisdiction;
- whether automatic mutation is safe;
- whether human consent is required;
- whether only diagnostics/quit is allowed;
- terminal behavior.

---

# 11. Decide whether a rebuildable partial repair may be automatic

For the narrow class:

```text
rebuildableLiveOnlyPartial
```

audit whether repair should be:

### Option A — automatic

```text
Local Data Repair selected
-> prove current reconstructibility again
-> scoped reset
-> restart
-> fresh AppCzar
-> likely Onboarding
```

### Option B — explicit human confirmation

```text
show exact derived-store scope and preservation guarantees
-> user authorizes
-> scoped reset
-> restart
```

Prefer automatic only if the erased data is **provably derived, fully
reconstructible, and contains no unique user/historical value**.

Do not choose based on convenience.

Report the product/safety rationale.

---

# 12. Mutation authority and Ball

Design the exact Local Data Repair mutation path.

Preferred conceptual shape:

```text
AppCzar Local Data Repair disposition
-> occurrence-bound controller
-> fresh repair-safety revalidation
-> one admitted reset executor
-> ArchiveMutationCoordinator typed operation
-> MessageDataResetService lower mechanics
-> release Ball
-> stopAndDrain
-> real restart
-> fresh AppCzar
```

Audit whether an existing typed mutation operation is suitable.

Do not create nested independent Ball tenure.

Do not let `MessageDataResetService` self-authorize.

If current reset service already acquires mutation authority internally, decide
whether Local Data Repair should call it through its existing typed authority or
whether a narrow lower-mechanics extraction is required to avoid double tenure.

---

# 13. Repair-success terminal

Mandatory:

```text
safe repair completes
-> exact mutation tenure releases
-> Local Data Repair stops/drains
-> real process restart
-> fresh AppCzar
```

Never:

```text
reset complete
-> Local Data Repair invokes Onboarding
```

Fresh AppCzar decides from current facts whether the next jurisdiction is:

- Onboarding;
- Source Access Repair;
- Diagnostic Review;
- another Local Data Repair class;
- something else.

---

# 14. Repair failure terminal

Audit failure semantics.

A reset failure may leave a partially deleted derived state.

Therefore default rule:

```text
mutation admitted
-> any terminal success OR failure
-> drain
-> real restart
-> fresh AppCzar
```

unless source proves a failure occurred before any mutation began.

Do not remain in-process and claim the prior repair classification still holds
after mutation may have started.

---

# 15. Local Data Repair `stopAndDrain()` design

Design a lifecycle contract covering:

- initial read-only repair classification;
- any human confirmation;
- fresh safety revalidation;
- reset mutation;
- provider close/delete/invalidate sequence;
- Ball release;
- stale progress suppression;
- quit while read-only;
- quit while mutation is active.

As with other coordinators:

```text
close action admission synchronously
invalidate publication generation
await exact active work
await mutation tenure release
restart only after drain when required
```

No repair consent or classification survives process death.

---

# 16. Presentation semantics

Design a factual Local Data Repair surface.

Good examples:

```text
Local message data needs repair

The local import contains 1 message, but no complete conversation graph exists.
The current Messages source still contains the material needed to rebuild this
local data.
```

or:

```text
Local message data needs attention

This incomplete local dataset contains historical imported material. MessageLens
will not delete it automatically.
```

Do not say:

- “the previous import was interrupted”;
- “the database is disposable” unless that is literally proven;
- “nothing will be lost” unless exact protected/reconstructibility predicates
  support that statement;
- “repair succeeded” before fresh post-restart evidence.

---

# 17. Unsafe/corrupt data and Diagnostic Review boundary

Pay special attention to corruption.

If an import database is corrupt enough that MessageLens cannot prove whether
protected historical rows are present, it cannot safely delete the database
merely because it is a derived store.

Preferred rule:

```text
cannot inspect enough to prove repair safety
-> Diagnostic Review
```

not:

```text
corrupt derived DB
-> delete it
```

Determine whether current evaluator already follows this rule and what changes,
if any, are needed.

---

# 18. Retired derived artifacts

Audit specifically named retired files such as:

```text
macos_import.db
working.db
```

Determine:

- whether they may contain unique historical/protected material;
- whether current app ever reads them as authoritative data;
- whether `MessageDataResetService` deletes them today;
- whether they can be removed independently of active current stores;
- whether their mere presence should select Local Data Repair or simply be
  diagnostic residue.

Do not delete unknown legacy files merely because their names look retired.

---

# 19. Human qualification target design

Design the future human qualification using disposable fixtures only.

At minimum it should include:

## Fixture A — safely rebuildable live-only partial

```text
current import DB contains consequential partial live-source data
current source still proves exact reconstructibility
no non-live/historical material
no complete graph
-> Local Data Repair
-> repair
-> real restart
-> fresh AppCzar
-> Onboarding or another truthful jurisdiction
```

## Fixture B — protected non-live partial

```text
incomplete local data contains historical/non-live material
-> Local Data Repair or Diagnostic Review presentation
-> NO automatic reset
-> data fingerprint unchanged
```

## Fixture C — corrupt/unknown

```text
repair safety cannot be proven
-> Diagnostic Review
-> NO mutation
```

Do not create or run those fixtures in this audit.

---

# 20. Determine implementation feasibility

At the end of the audit answer:

> Can a narrow executable Local Data Repair Stage One be implemented using
> current fact readers plus existing scoped reset machinery while mechanically
> proving current reconstructibility and protected-data absence before deletion?

If NO:

- do not implement;
- identify exact missing fact/worker seams;
- propose the next narrow implementation prompt.

If YES:

still default to **audit-only** unless implementation is truly mechanical and
requires no new destructive semantics.

Given the destructive boundary, prefer a separate implementation prompt.

---

# 21. Project Conformance — audit scope

Run a conformance audit of the proposed design.

Require no unresolved conceptual contradiction around:

- current reconstructibility;
- protected historical material;
- overlay/archive preservation;
- mutation authority;
- restart boundary;
- Diagnostic Review fallback;
- one coordinator at a time;
- production unchanged.

For an audit-only result, report:

`PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)`

only if the design itself has no BLOCKER/SHOULD FIX findings.

---

# 22. No build or launch required for audit-only outcome

If no source/test implementation occurs:

- do not build;
- do not launch;
- do not touch real data;
- leave Prompt 78 / Response 78 untracked for the next checkpoint unless the
  repository convention explicitly checkpoints audit records immediately.

If source changes become necessary merely to obtain factual audit evidence,
STOP and report rather than silently turning this into an implementation task.

---

# 23. Required response

Create Response 78 and report:

1. baseline verification;
2. Prompt 77/Response 77 documentation checkpoint;
3. current AppCzar execution census;
4. exact current Local Data Repair selection frontier;
5. mapping of each Local Data Repair case to current facts/dispositions;
6. current F18–F21 implementation status;
7. exact current definition of consequential partial data;
8. exact current definition of protected non-live/historical data;
9. reconstructibility fact design;
10. proof live provenance alone is insufficient;
11. exact bounded source-comparison strategy;
12. historical/non-live representation in import DB;
13. protected-source inventory/readability result;
14. `MessageDataResetService` exact deletion inventory;
15. reset preservation inventory;
16. reset path/basename safeguards;
17. reset mutation/Ball/lock path;
18. reset interruption/idempotence behavior;
19. Start Fresh versus Local Data Repair distinction;
20. historical-source removal versus Local Data Repair distinction;
21. proposed Local Data Repair class taxonomy;
22. automatic-versus-human-confirmed repair decision;
23. exact safe repair predicate;
24. unsafe/corrupt -> Diagnostic Review rule;
25. retired-artifact result;
26. repair-success restart contract;
27. repair-failure restart contract;
28. Local Data Repair stopAndDrain design;
29. presentation semantics;
30. future qualification fixture design;
31. implementation-feasibility verdict;
32. BLOCKER findings;
33. SHOULD FIX findings;
34. whether implementation proceeded;
35. Project Conformance audit verdict;
36. final Git/worktree/index/submodule state;
37. readiness for executable Local Data Repair implementation;
38. readiness for Local Data Repair human qualification;
39. readiness for Diagnostic Review milestone;
40. readiness for production AppCzar cutover.

Conclude exactly:

`ONBOARDING HUMAN LIVE QUALIFICATION CHECKPOINTED: YES / NO`

`LOCAL DATA REPAIR JURISDICTION IS SOURCE-GROUNDED: YES / NO`

`CURRENT RECONSTRUCTIBILITY CAN BE PROVEN BEFORE DESTRUCTIVE RESET: YES / NO`

`PROTECTED NON-LIVE/HISTORICAL DATA BLOCKS AUTOMATIC RESET: YES / NO`

`MESSAGE DATA RESET PRESERVES USER INTENT AND ATTACHMENT ARCHIVE: YES / NO`

`CORRUPT/UNKNOWN REPAIR SAFETY FAILS CLOSED TO DIAGNOSTIC REVIEW: YES / NO`

`EXECUTABLE APPCZAR LOCAL DATA REPAIR IMPLEMENTED: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR LOCAL DATA REPAIR IMPLEMENTATION: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
