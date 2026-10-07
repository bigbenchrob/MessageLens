# MessageLens Feature 34
## 79 — Implement AppCzar Local Data Repair Stage One

Prompt 78 completed the Local Data Repair audit/design and correctly stopped
before implementation.

The controlling audit conclusion is:

> Current code cannot yet prove **schema-wide current reconstructibility** before
> destructive reset.

Local Data Repair therefore remains virtual.

Prompt 78 identified three missing implementation seams that must be added
before any destructive repair may execute:

```text
1. current schema-wide reconstructibility evidence

2. explicit AppCzar Local Data Repair mutation authority

3. a reset physical postcondition that proves only the authorized derived scope
   changed before the process restarts
```

This task implements those seams and the narrowest executable Local Data Repair
Stage One permitted by Response 78.

Read **Response 78 in full before editing** and treat its exact audit findings,
taxonomy, safety classes, consent decision, reset inventory, mutation-path
findings, and postcondition requirements as controlling. Do not substitute this
prompt's shorthand for a more precise Response 78 conclusion.

The governing rule remains:

> **MessageLens may delete derived local data only when current evidence proves
> that every consequential fact within the authorized reset footprint can be
> reconstructed from current authoritative sources, and that no protected
> non-live/historical material, user intent, attachment archive payload,
> configuration, identity, or unique provenance will be destroyed.**

Do NOT make Diagnostic Review executable.
Do NOT route production startup through AppCzar.
Do NOT perform a real repair/reset.
Do NOT access or mutate the real WD development root or Toshiba archive.
Do NOT broaden Start Fresh semantics.
Do NOT invent partial SQL surgery for historical sources.
Do NOT delete data based only on live-source provenance.

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

Verify the Prompt 77 qualification checkpoint is in ancestry:

`3fd20ffd2d26a0305e92948bf7b1c5cada0c9798`

Read:

- Response 41;
- Response 71;
- Response 72;
- Response 77;
- Response 78;
- current AppCzar evaluator/fact graph;
- current initial-construction scope reader;
- current source-scoped import schema;
- current live Messages source readers;
- current Contacts/AddressBook readers;
- conversation graph schema/readers;
- `MessageDataResetService`;
- Start Fresh;
- historical-source import/removal;
- archive mutation/Ball authority;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Checkpoint Prompt 78 / Response 78 first

Prompt 78 was audit-only and Prompt/Response 78 remain untracked.

Create a narrow documentation checkpoint containing only Prompt 78 and Response
78 before source edits.

Record accurately:

```text
AppCzar Onboarding human live qualification:
    PASS

Local Data Repair:
    VIRTUAL ONLY

Audit result:
    current code cannot yet prove schema-wide reconstructibility before reset

Implementation required:
    current reconstructibility evidence
    explicit repair mutation authority
    reset physical postcondition

Production AppCzar cutover:
    NOT YET
```

Preserve Response 78's exact BLOCKER / SHOULD FIX results and its chosen repair
taxonomy/consent policy.

Push normally before source edits.

No force push, rebase, squash, or unrelated staging.

---

# 3. Reconfirm the execution census

Before editing require:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Local Data Repair           VIRTUAL ONLY
Diagnostic Review           VIRTUAL ONLY
```

After this task only one item may change:

```text
Local Data Repair
    -> EXECUTABLE TOP-LEVEL COORDINATOR
```

Diagnostic Review remains virtual.

No generic coordinator dispatcher.

---

# 4. Implement one current repair-safety evidence boundary

Create the narrowest shared read-only evidence seam required by Response 78,
conceptually:

```text
LocalDataRepairSafetyObservation
```

Use the repository's preferred naming.

It must be:

- current;
- snapshot-free;
- independent of old Journey/failure state;
- archive-root / archive-identity bound;
- source-identity bound;
- read-only;
- bounded/paged;
- explicit about TRUE / FALSE / UNKNOWN evidence;
- usable both by AppCzar disposition evaluation and by the repair controller's
  immediate pre-mutation revalidation.

Do not create a second semantic classifier beside AppCzar.

The observation must distinguish at least the exact repair classes that Response
78 approved.

---

# 5. Implement schema-wide reconstructibility, not message-count plausibility

This is the central safety requirement.

Do not define reconstructibility as any of:

```text
all rows have source_id == live_chat_db

local message count <= source message count

local high-water <= source MAX(ROWID)

every local message GUID still exists

the database was created by the live importer

the prior operation looked interrupted
```

Those are evidence fragments, not the complete proposition.

The new fact must prove that the **entire consequential reset footprint** is
rebuildable from authoritative current source inputs under the current importer
semantics.

Use Response 78's audited reset inventory as the scope.

At minimum account for every current source-scoped import domain whose contents
will be destroyed by reset, including, where present in current schema:

- source registry / source identity;
- messages;
- chats;
- handles;
- Contacts / contact channels or equivalent enrichment rows;
- rich-text-derived message content;
- attachment metadata;
- chat-message relationships;
- chat-handle relationships;
- message-attachment relationships;
- import ledger / source cursor / batch provenance;
- any other consequential current schema table deleted with
  `macos_import_ss.db`.

Then prove that the Conversation Graph is derived from that reconstructible
import state or independently include any graph-only consequential fact in the
repair-safety proof.

Do not silently ignore a current table because the Stage One fixture happens not
to populate it.

If any consequential table cannot be proven reconstructible from current
authoritative sources, repair safety is not TRUE.

---

# 6. Prefer source-grounded anti-difference evidence

Implement the bounded comparison strategy approved by Response 78.

The desirable logical shape is:

```text
local consequential fact set
MINUS
facts reconstructible from current authoritative sources
=
empty
```

for every destructive domain.

Prefer bounded SQL key/provenance comparisons, indexed existence checks, or
other current database evidence over loading full corpora into Dart.

The implementation may use per-domain readers if that is clearer, but there
must be one aggregate repair-safety proposition.

Required qualities:

- bounded pages/chunks;
- deterministic ordering;
- no payload-byte scan;
- no attachment archive traversal;
- no full rich-text blob materialization merely to prove membership;
- no unbounded in-memory key set;
- coherent source sampling so source change during proof yields UNKNOWN;
- fail closed if source identity/binding changes during proof.

Measure fixture performance.

---

# 7. Messages-domain reconstructibility

At minimum prove for current live-source message facts that would be discarded:

- canonical live source identity matches;
- every consequential imported live message key required by current schema is
  still represented by the current authoritative Messages source;
- key identity uses the strongest existing stable source identity available
  (ROWID/GUID combination or the audited equivalent);
- missing/deleted source rows make reconstructibility FALSE, not TRUE;
- source read failure or unstable comparison makes reconstructibility UNKNOWN.

Do not equate current `MAX(ROWID)` coverage with row existence.

---

# 8. Attachments and relationship reconstructibility

The reset deletes attachment metadata and relationship rows in the import/graph
stores, not the durable attachment archive payloads.

Prove that any import/graph attachment **metadata and joins** being discarded are
reconstructible under the existing current-source importer.

Keep distinct:

```text
source attachment metadata / relationships
```

from:

```text
durable MessageLens attachment archive payload
```

The latter must remain outside reset scope and outside reconstructibility
destruction.

Do not require archived payload bytes to exist in Apple Messages merely to
rebuild metadata if Response 78's audit says metadata reconstruction has a
different authoritative source contract.

Follow the actual importer semantics.

---

# 9. Contacts/enrichment reconstructibility

Use the current typed Contacts prerequisite/evidence added for AppCzar
Onboarding.

The repair proof must honor the current importer's actual dependency on the
AddressBook source.

If current imported contact/enrichment rows are part of the deleted import
database, determine from Response 78 and source whether safety requires:

- exact current-source membership for those rows; or
- only a currently viable authoritative AddressBook source from which the
  importer deterministically rebuilds current enrichment.

Do not weaken this distinction by guess.

If Contacts evidence is invalid/corrupt/UNKNOWN, destructive repair safety is
UNKNOWN and must not execute.

---

# 10. Protected non-live/historical material

The evidence boundary must prove protected non-live/historical material absence
before whole-import-store reset.

If any protected historical/non-live source is present:

```text
whole-store automatic reset forbidden
```

Do not create partial live-row deletion.

Do not call historical-source removal.

Historical-source removal remains its own explicitly authorized specialist
workflow.

If source inventory cannot be read strongly enough to prove protected material
absence:

```text
repair safety UNKNOWN
-> Diagnostic Review
```

not Local Data Repair mutation.

---

# 11. Corrupt / unsupported / unreadable local stores

A corrupt store must not become safer merely because reset mechanics can delete
it.

Required:

```text
cannot inspect enough local content/provenance to prove reconstructibility
-> repair safety UNKNOWN
-> Diagnostic Review
-> no mutation
```

If Response 78 identified a narrower conclusively safe corrupt-store case,
implement only that exact case.

Otherwise keep corrupt/unsupported cases non-executable.

---

# 12. Retired derived artifacts

Implement Response 78's exact conclusion for specifically enumerated retired
derived artifacts such as:

```text
macos_import.db
working.db
```

Do not infer arbitrary unknown legacy files are disposable.

If retired artifacts may contain unique protected material, they must not be
deleted automatically without the exact current evidence Response 78 requires.

If the audit concluded they are mechanically obsolete derived residue, keep
their allowlist explicit and separately tested.

---

# 13. Exact repair-safety proposition

Expose a pure derived proposition, conceptually:

```text
localDataRepairMayResetDerivedStores
```

TRUE only when every required precondition is TRUE.

The conjunction must include Response 78's exact rules, including at least:

```text
AppCzar selected the narrow repair class

current archive/root binding coherent

local reset footprint exactly known

consequential derived data exists

protected non-live/historical material absent

current authoritative source(s) readable and stable

schema-wide reconstructibility TRUE

no corrupt/unsupported/unknown evidence that weakens the proof
```

FALSE means a known reason prevents this repair.

UNKNOWN means evidence is insufficient or unstable.

Do not collapse FALSE and UNKNOWN.

---

# 14. AppCzar evaluator integration

Refine the current Local Data Repair frontier only as required by Response 78.

The important separation is:

```text
repairable local-derived condition
    -> executable Local Data Repair

known protected / lineage condition that requires non-destructive human review
    -> whichever virtual disposition Response 78 specifies

repair safety UNKNOWN / corrupt / conflicting
    -> Diagnostic Review
```

Do not route every local-store problem to executable repair.

Do not make Diagnostic Review executable.

AppCzar itself remains read-only.

---

# 15. Revalidate immediately before mutation

AppCzar assessment is not mutation authorization.

The Local Data Repair coordinator must perform a fresh repair-safety read
immediately before acquiring mutation authority.

Bind the authorized repair plan to:

- coordinator occurrence;
- assessment generation;
- archive root / instance UUID / generation or equivalent binding;
- current live source identity/fingerprint;
- current repair-safety evidence fingerprint;
- exact reset footprint.

If any binding changed:

```text
NO MUTATION
-> stop/drain
-> restart
-> fresh AppCzar
```

Do not refill, substitute, or downgrade the proof.

---

# 16. Local Data Repair mutation authority

Add an explicit typed archive-mutation operation for Local Data Repair if
Response 78 found no suitable existing type.

Conceptual path:

```text
AppCzar Local Data Repair disposition
-> AppCzarLocalDataRepairController
-> admitted executor
-> fresh repair-safety revalidation
-> ArchiveMutationCoordinator.runWithCapability(localDataRepair)
-> MessageDataResetService lower reset mechanics
-> physical postcondition verification
-> capability returns
-> Ball releases
-> stopAndDrain
-> real restart
-> fresh AppCzar
```

Requirements:

- exactly one Ball tenure;
- no nested independent mutation tenure;
- no diagnostic owner label used as authority;
- no direct reset call without the typed capability;
- no worker self-authorization;
- no Start Fresh semantic wrapper;
- no Journey action context.

If `MessageDataResetService` currently owns an internal authority layer that
would cause double tenure, extract the smallest lower mechanics seam rather than
stacking two Balls.

---

# 17. Human consent policy

Use **exactly the decision made in Response 78** for the narrow
rebuildable-live-only repair class.

Do not revisit the product decision unless implementation reveals a source
contradiction.

If Response 78 chose automatic repair, the controller may admit the reset only
after fresh current proof is TRUE.

If Response 78 chose explicit human confirmation:

- display the exact reset footprint;
- display the preservation guarantees that are actually proven;
- bind consent to the exact current evidence/occurrence;
- invalidate consent on any evidence/binding change;
- do not persist consent.

Never use human confirmation to override UNKNOWN safety.

---

# 18. Separate Local Data Repair from Start Fresh

Local Data Repair is system-selected because current local derived state cannot
support normal operation.

It must not inherit Start Fresh behavior such as:

- user-requested reset of an otherwise healthy dataset;
- Journey snapshot/failure resets;
- Presence schedule restart unless Response 78 explicitly proves that is required
  by the lower physical repair;
- semantic transition to Onboarding;
- broad "fresh start" presentation.

Reuse only the audited lower derived-store reset mechanics.

Start Fresh remains a separate user command.

---

# 19. Separate Local Data Repair from historical-source removal

Local Data Repair may not delete a protected historical/non-live source merely
to make whole-store reset safe.

If such material is present:

```text
no automatic destructive Local Data Repair
```

Historical-source removal remains separately selected, separately authorized,
and source-specific.

Do not call that workflow from Local Data Repair in-process.

---

# 20. Implement a physical reset postcondition

Worker return is not proof that the authorized physical repair completed.

Add the narrow postcondition seam identified by Response 78.

After the reset mechanics return, but before declaring the mutation occurrence
complete, prove from filesystem/database facts that:

- every authorized active derived database family in the reset footprint is
  absent or in the exact reset terminal form specified by current mechanics;
- SQLite sidecars targeted by reset are absent;
- explicitly authorized retired derived artifacts are absent if included;
- no unexpected MessageLens-owned file was deleted;
- archive marker / admitted archive identity remains the same;
- `user_overlays.db` preservation condition still holds;
- `presence.db` preservation condition still holds;
- attachment archive configuration remains;
- attachment archive payload root remains outside the deletion set and still
  has the same authority binding;
- no historical/non-live source-specific mutation occurred.

Use the minimum safe evidence needed; do not recursively hash the attachment
archive.

This postcondition proves only:

```text
the authorized reset footprint reached its physical terminal
```

It does NOT prove:

```text
MessageLens is now Onboarding
MessageLens is healthy
repair succeeded semantically
```

Fresh AppCzar owns those statements after restart.

---

# 21. Failure semantics

Distinguish:

## Failure before mutation begins

If fresh proof fails or authority admission fails before any destructive step:

```text
no mutation
-> factual failure
-> stop/drain
-> restart if jurisdiction may have changed
```

## Failure after mutation may have begun

```text
partial physical reset may exist
-> no in-process retry
-> no success claim
-> drain
-> release Ball
-> real restart
-> fresh AppCzar
```

The next process reconstructs current facts from disk.

Do not persist a semantic repair cursor.

---

# 22. `stopAndDrain()`

Implement the same qualified lifecycle pattern:

```text
close action admission synchronously
invalidate publication generation
cancel/ignore stale read-only callbacks
await exact in-flight proof/mutation Future
await physical postcondition attempt
await Ball release
suppress stale publication
restart only after drain when required
```

Ordinary quit:

```text
drain
-> no scheduled restart
```

No consent, repair class, proof, or progress survives process death.

---

# 23. Presentation

Create a factual AppCzar Local Data Repair surface.

It should distinguish at least:

```text
checking repair safety

repairable current derived data

protected historical/non-live material

repair safety cannot be established

repairing local message data

restart required
```

Use Response 78's exact class vocabulary where more precise.

Good copy is current and literal.

Do not say:

- previous import was interrupted;
- the data is disposable before proof;
- nothing can be lost;
- repair succeeded semantically;
- Onboarding will run next.

If a destructive action requires human confirmation, state exactly which
MessageLens-derived stores will be reset and what preservation facts are proven.

---

# 24. Development host integration

Add one explicit Local Data Repair host branch to the AppCzar development
composition.

Post-change census:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Local Data Repair           EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Diagnostic Review           VIRTUAL ONLY
```

No generic dispatcher.

Production remains legacy.

---

# 25. Focused reconstructibility tests

Use disposable temp stores/source fixtures only.

At minimum prove:

1. the exact Prompt 77-style one-message live-source partial fixture is
   reconstructible only when that exact source fact still exists;
2. deleting that source message from the current source makes reconstructibility
   FALSE;
3. source unreadability makes reconstructibility UNKNOWN;
4. source change during comparison makes reconstructibility UNKNOWN;
5. non-live/historical source presence blocks whole-store reset;
6. unknown protected-source inventory blocks reset;
7. every consequential current import-schema domain participates in the proof;
8. a deliberately unmatched attachment/join/domain fixture cannot be declared
   reconstructible;
9. Contacts evidence required by current importer participates correctly;
10. graph-only consequential rows are either proven derived from reconstructible
    import state or block repair;
11. no attachment payload bytes are scanned;
12. comparison remains bounded in memory/work pages.

---

# 26. Reset-postcondition tests

At minimum prove:

1. exact active import DB family removed;
2. exact graph DB family removed or reaches the audited terminal form;
3. SQLite WAL/SHM sidecars removed;
4. only enumerated retired artifacts are removed;
5. overlay survives;
6. Presence survives;
7. marker/UUID survives;
8. attachment archive directory/payload sentinel survives;
9. attachment archive configuration survives;
10. unrelated archive-root sentinel survives;
11. postcondition fails if a targeted derived artifact remains;
12. postcondition fails if a preserved identity/config fact changes.

Do not use real archive data.

---

# 27. Authority/lifecycle tests

At minimum prove:

1. only exact executable Local Data Repair disposition starts the controller;
2. Diagnostic Review remains virtual;
3. fresh safety revalidation occurs before Ball acquisition/mutation;
4. stale assessment/evidence prevents mutation;
5. one typed Local Data Repair Ball tenure only;
6. no nested independent reset tenure;
7. reset worker cannot self-authorize;
8. success waits for physical postcondition;
9. success releases Ball before restart;
10. postcondition failure still drains/restarts;
11. mutation failure drains/restarts;
12. pre-mutation refusal performs no deletion;
13. ordinary quit drains without scheduled restart;
14. stale progress cannot publish after drain;
15. no same-process Onboarding handoff;
16. no durable repair cursor/consent.

---

# 28. Safety-class tests

Cover every Response 78 repair class.

At minimum:

```text
rebuildable live-only partial
    -> executable Local Data Repair

protected historical/non-live material
    -> no automatic reset

corrupt/unsupported with unknown contents
    -> Diagnostic Review

lineage conflict / source divergence
    -> no destructive repair unless Response 78 explicitly proved a safe class

unknown/conflicting evidence
    -> Diagnostic Review
```

Retired-artifact behavior must exactly match Response 78.

---

# 29. Regression matrix

Run:

1. schema-wide reconstructibility tests;
2. source comparison tests;
3. protected-source tests;
4. reset mechanics tests;
5. reset-postcondition tests;
6. Local Data Repair controller/executor/presentation tests;
7. mutation/Ball regressions;
8. AppCzar evaluator/frontier tests;
9. Onboarding regressions;
10. Data Update regressions;
11. Source Access Repair regressions;
12. Attachment Archive Repair regressions;
13. Operating regressions;
14. historical-source workflow regressions;
15. Start Fresh regressions;
16. archive authority/composition regressions;
17. complete architecture suite;
18. analyzer;
19. full deterministic Flutter suite;
20. `git diff --check`;
21. formatting/generated consistency;
22. debug macOS development build.

Do not launch the built app.

---

# 30. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Explicitly verify:

- destructive repair depends on current schema-wide reconstructibility;
- live provenance alone is insufficient;
- protected non-live/historical data blocks whole-store reset;
- corrupt/unknown safety fails closed;
- AppCzar remains read-only;
- one typed mutation authority owns reset;
- no nested Ball;
- reset footprint is allow-listed;
- reset postcondition is physical, not semantic;
- user intent / Presence / archive identity / attachment archive preserved;
- no Start Fresh semantic reuse;
- no historical-source removal authority borrowed;
- restart after any mutation terminal;
- no durable repair cursor;
- Diagnostic Review still virtual;
- production unchanged.

---

# 31. Checkpoint and build

If validation passes:

1. create a narrow implementation commit;
2. build the exact development artifact without launching;
3. create Prompt 79 / Response 79 documentation checkpoint;
4. push normally.

Recommended implementation subject:

`feat(startup): add source-grounded local data repair`

Record:

```text
AppCzar Local Data Repair:
    IMPLEMENTED: YES
    AUTOMATED VALIDATION: PASS
    HUMAN LIVE QUALIFICATION: PENDING

Diagnostic Review:
    VIRTUAL ONLY

Production AppCzar cutover:
    NOT YET
```

No force push, rebase, squash, or unrelated staging.

---

# 32. Build identity

Advance version/build sequentially if project convention requires it.

Report:

- bundle path;
- product/display name;
- bundle identifier;
- environment/build identity;
- version/build;
- executable SHA-256;
- App.framework SHA-256.

Do not launch.

---

# 33. Next human qualification

If Prompt 79 passes, the next task must use disposable fixtures only.

At minimum:

## Fixture A — exactly reconstructible live-only partial

```text
consequential partial import/graph state
+ every reset-footprint fact reconstructible now
+ no protected non-live data
-> Local Data Repair
-> repair under one Ball
-> physical postcondition
-> restart
-> fresh AppCzar
-> truthful next jurisdiction
```

## Fixture B — local fact missing from current source

```text
live provenance
but current source no longer contains required fact
-> reconstructibility FALSE
-> NO reset
```

## Fixture C — protected historical/non-live

```text
protected material present
-> NO whole-store reset
-> fingerprint unchanged
```

## Fixture D — corrupt/unknown

```text
cannot prove contents/safety
-> Diagnostic Review
-> NO mutation
```

Do not create or run those fixtures in Prompt 79.

---

# 34. Stop gates

STOP AND REPORT if:

- Response 78 cannot be implemented without weakening its reconstructibility
  requirement;
- any current schema domain in the reset footprint lacks a trustworthy
  reconstructibility proof;
- destructive safety would depend only on `source_id == live_chat_db`;
- protected historical material cannot be distinguished before reset;
- corrupt/unknown local state would need deletion to inspect it;
- Local Data Repair would require Start Fresh semantic authority;
- reset cannot be placed under exactly one Ball;
- physical postcondition cannot distinguish targeted deletion from preservation;
- Diagnostic Review would need to become executable in the same change;
- production routing must change;
- Project Conformance cannot reach PASS.

---

# 35. Required response

Create Response 79 and report:

1. baseline verification;
2. Prompt 78/Response 78 documentation checkpoint;
3. pre-change execution census;
4. Response 78 controlling implementation findings;
5. repair-safety observation design;
6. exact repair class taxonomy;
7. schema-wide reset-footprint inventory;
8. schema-wide reconstructibility algorithm;
9. Messages-domain comparison;
10. chat/handle/relationship comparison;
11. attachment metadata/join comparison;
12. Contacts/enrichment comparison;
13. source-registry/ledger/provenance comparison;
14. graph reconstructibility proof;
15. boundedness/performance result;
16. protected non-live/historical rule;
17. corrupt/unsupported UNKNOWN rule;
18. retired-artifact rule;
19. exact repair-safety proposition;
20. AppCzar frontier/evaluator change;
21. pre-mutation revalidation/binding;
22. mutation-operation type;
23. one-Ball authority path;
24. consent-policy implementation;
25. Start Fresh separation;
26. historical-source-removal separation;
27. reset lower-mechanics reuse/extraction;
28. physical reset-postcondition design;
29. exact preservation assertions;
30. success terminal;
31. mutation/postcondition failure terminal;
32. stopAndDrain behavior;
33. presentation semantics;
34. development host integration;
35. post-change execution census;
36. reconstructibility focused tests;
37. protected-source tests;
38. reset-postcondition tests;
39. authority/lifecycle tests;
40. safety-class tests;
41. existing coordinator regressions;
42. historical-source/Start Fresh regressions;
43. architecture result;
44. analyzer result;
45. full Flutter-suite result;
46. diff/format/generated hygiene;
47. Project Conformance verdict;
48. BLOCKER findings;
49. SHOULD FIX findings;
50. implementation checkpoint commit;
51. documentation checkpoint commit;
52. pushed recovery anchor;
53. exact build identity/path/hashes;
54. final Git/worktree/index/submodule state;
55. readiness for isolated Local Data Repair human qualification;
56. readiness for Diagnostic Review milestone;
57. readiness for production AppCzar cutover.

Conclude exactly:

`SCHEMA-WIDE CURRENT RECONSTRUCTIBILITY IS PROVEN BEFORE RESET: YES / NO`

`LIVE PROVENANCE ALONE CAN AUTHORIZE LOCAL DATA RESET: YES / NO`

`PROTECTED NON-LIVE/HISTORICAL DATA BLOCKS WHOLE-STORE RESET: YES / NO`

`CORRUPT OR UNKNOWN REPAIR SAFETY FAILS CLOSED: YES / NO`

`LOCAL DATA REPAIR USES EXACTLY ONE TYPED BALL TENURE: YES / NO`

`RESET POSTCONDITION PROVES ONLY THE AUTHORIZED PHYSICAL FOOTPRINT CHANGED: YES / NO`

`EXECUTABLE APPCZAR LOCAL DATA REPAIR IMPLEMENTED: YES / NO`

`DIAGNOSTIC REVIEW REMAINS VIRTUAL: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR ISOLATED LOCAL DATA REPAIR HUMAN QUALIFICATION: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
