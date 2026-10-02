# MessageLens Feature 34
## 42 — Human Architecture Review of the AppCzar Fair-Witness Fact DAG

Response 41 is a strong refinement and is **not** yet permission to implement.

This task is a bounded architecture review of the proposed Fair-Witness fact DAG.
The goal is to make the control model simpler, more mechanical, and easier for a
human to hold in their head before any production code is changed.

Do NOT modify source or tests.
Do NOT launch MessageLens.
Do NOT mutate databases.
Do NOT implement AppCzar.
Do NOT stage, commit, or push.

---

# 1. Preserve the accepted foundation

Treat these as provisionally accepted unless the review finds a contradiction:

- AppCzar begins every process with no remembered semantic answer.
- AppCzar observes current reality only.
- facts are TRUE / FALSE / UNKNOWN;
- UNKNOWN is not FALSE and never borrows history;
- facts form a version-controlled dependency DAG;
- discovery/completion order cannot affect the result;
- several factual deficiencies may coexist;
- exactly one actionable disposition is selected;
- exactly one coordinator is selected;
- coordinators do not select successor coordinators;
- jurisdiction-changing work ends in restart;
- only fresh AppCzar assessment may establish a healthy operating installation;
- no durable Journey cursor;
- no cross-session initial-import resume;
- old semantic state, navigation restore, operation snapshots, readiness
  conclusions, and success handoffs remain deletion targets;
- Ball/track remains orthogonal mutation authority.

---

# 2. Primary review question: is the DAG still too complicated?

Response 41 proposes F00–F26.

Do not assume all 27 facts belong in AppCzar.

For every node ask:

> Does AppCzar need this fact to choose the one coordinator that owns the next
> jurisdiction?

If not, move it down into the selected coordinator as a coordinator-local test.

The target is the smallest possible launch DAG.

Examples to scrutinize:

- archive access detail beyond “usable / unavailable / unsafe”;
- import-vs-graph substructure that may belong to local-data inspection;
- Presence health if it does not block the whole app;
- attachment pending-work detail that may belong to Update;
- individual integrity subfacts that could be collapsed into a single
  independently observed health fact without losing safety.

Do not hide complexity in one opaque Boolean. But also do not make AppCzar know
facts that only a specialist coordinator needs.

Produce a reduced-DAG proposal if possible.

---

# 3. Review the independent-root tie rule

Response 41 currently proposes this root-domain order:

1. evidence coherence
2. preserved-data safety
3. source observability
4. local-dataset viability
5. currentness
6. healthy current installation

This causes:

```text
FDA unavailable + configured archive volume unavailable
-> archive/preservation remediation first
```

This is deterministic, but the human design discussion originally suggested
that a foundational observation dependency such as FDA might naturally come
first because it unlocks a large portion of the remaining assessment.

Review whether the proposed ordering is:

- mechanically implied by safety/dependency;
- a product policy;
- or an arbitrary priority list in disguise.

Do not use numeric priority.

Compare at least these candidate principles:

### A. Preservation-first
Never proceed past any known threat to irreducible/preserved data.

### B. Knowability-first
Repair the deficiency that unlocks the greatest amount of currently UNKNOWN
assessment.

### C. Hard safety before knowability
Only deficiencies that imply possible data loss/corruption outrank
observation-enabling prerequisites such as FDA. Mere unavailability does not.

### D. Another smaller mechanical rule
Propose one only if it is clearly simpler.

The result must explain exactly what happens for:

- FDA missing + archive volume absent;
- FDA missing + overlay corrupt;
- FDA missing + graph corrupt;
- archive unavailable + graph corrupt;
- multiple preservation-store failures.

Distinguish “unavailable” from “unsafe/corrupt” if that materially changes the
ordering.

---

# 4. Review coordinator lifetime and the meaning of OK

Response 41 says coordinators may end `OK` while waiting/choosing.

That may conflict with the simpler foreground model:

```text
AppCzar assessing
OR
one coordinator owns the app
OR
the user is interacting inside that coordinator/session
```

Clarify:

- Is user interaction a phase **inside** the currently selected coordinator?
- Does an Onboarding coordinator remain alive while the user is in System
  Settings or making a Journey choice?
- If so, it has not terminated and should not return `OK`.
- What, exactly, does coordinator terminal `OK` mean?
- Which coordinators can legitimately terminate `OK`?
- Is `OK` needed at all outside the Operating coordinator / non-changing
  diagnostic actions?

Prefer the smallest terminal vocabulary.

A coordinator must never disappear while its Journey still semantically owns
the user experience.

---

# 5. Review the role of disposition

Keep the conceptual distinction:

```text
observations -> facts -> selected actionable condition -> coordinator
```

But test whether the term `Disposition` adds useful precision or unnecessary
terminology.

Could the selected object simply be called:

- `ActionableFinding`;
- `SelectedFinding`;
- or another plain-English term?

Do not rename for aesthetics alone. The goal is that a human can explain the
system without specialist jargon.

---

# 6. Fair-Witness naming review

Review every proposed actionable state name.

Require:

- present tense;
- only what current evidence establishes;
- no historical narrative;
- no coordinator/action name;
- no claim stronger than the visible side of the house.

Prefer explicit names even when long.

Identify any Response 41 names that still smuggle in inference.

---

# 7. Re-evaluate healthy-installation proof

`ThisAppearsToBeAHealthyCurrentInstallation` must be reachable only when all
facts actually required for normal operation are known TRUE.

Review whether Response 41 currently requires too much or too little.

Especially decide:

- Contacts: launch-level requirement or coordinator-local?
- Presence: launch-level requirement or feature-local?
- external attachment archive: must Operating be blocked when unavailable?
- source currentness: must be established before Operating?
- tiny source delta: Update jurisdiction first, or Operating can absorb it?

Keep architecture questions separate from product choices.

---

# 8. Review incomplete-build treatment

Confirm that AppCzar needs only enough evidence to distinguish:

- no complete local dataset;
- complete healthy local dataset;
- local data unsafe/corrupt/ambiguous;
- protected non-live historical material that forbids automatic disposal.

Avoid reconstructing the history of how partial data arose.

Confirm no operation UUID, stage, batch cursor, recovery disposition, or
completion flag is required.

---

# 9. Review repeated-failure ownership

Response 41 correctly removes the retry counter from AppCzar.

Review whether the simplest rule is:

- Onboarding owns `consecutive_initial_build_attempts`;
- increment immediately before a fresh rebuild begins;
- clear only after a fresh AppCzar has independently selected the healthy
  installation and Operating begins;
- failure to clear cannot revoke Operating.

Confirm this does not create a semantic handoff.

---

# 10. Review startup UI against the reduced DAG

The startup screen should show only facts AppCzar truly needs or facts that are
clearly useful to the user.

Avoid turning the startup UI into a dump of every internal node.

Propose the smallest useful user-facing list.

For example:

```text
Checking MessageLens…

✓ Full Disk Access
✓ Messages database            138,832
✓ MessageLens data             healthy; 138,822
  New messages                      10
✓ Overlay                      healthy
✕ Attachment archive           unavailable
```

If internal subfacts are needed for reasoning but not useful to the user, keep
them out of the UI.

---

# 11. Review the property-test model

Keep the strong Response 41 properties:

- permutation/discovery-order independence;
- total deterministic selection;
- UNKNOWN preservation;
- DAG acyclicity;
- ancestor dominance;
- protection of historical/non-live data;
- no historical-state influence;
- exhaustive coordinator mapping;
- no same-process semantic feedback.

Identify any additional property needed by the revised tie rule or reduced DAG.

---

# 12. Produce the final human-scale whiteboard model

The most important deliverable is a one-page model that a non-specialist can
understand.

It should fit approximately into:

```text
LAUNCH
  ↓
AppCzar observes current facts
  ↓
dependency graph determines what can be known
  ↓
several problems may be visible
  ↓
one mechanical rule selects the one problem to deal with first
  ↓
one coordinator
  ↓
user interaction / work
  ↓
OK if nothing fundamental changed
OR
RESTART if the world may now classify differently
```

If the final explanation needs more than this plus a small fact graph, keep
simplifying.

---

# 13. Deletion direction must remain intact

This review must not rescue the old complexity merely because the new DAG is
being simplified.

The following remain deletion/demotion targets unless a concrete correctness
proof requires otherwise:

- historical installation semantic classifier;
- Environment semantic readiness classifier;
- durable operation snapshot;
- resume/reconciliation machinery;
- persisted Journey position;
- semantic failure persistence;
- automatic navigation restoration;
- readiness/incident center sync;
- completion/success handoffs.

---

# 14. No implementation

Stop after design review.

Do not create AppCzar code or change providers.

---

# 15. Required response

Create Response 42 and report:

1. executive human-review verdict;
2. whether F00–F26 is too large for AppCzar;
3. proposed reduced launch DAG;
4. facts moved down into coordinators;
5. final independent-root selection rule;
6. FDA + archive-unavailable result;
7. FDA + overlay-corrupt result;
8. FDA + graph-corrupt result;
9. archive-unavailable + graph-corrupt result;
10. multiple-preservation-failure result;
11. final coordinator lifetime model;
12. final meaning of `OK`;
13. whether `OK` can be removed from any coordinator classes;
14. whether `Disposition` terminology is retained or simplified;
15. Fair-Witness naming corrections;
16. final healthy-installation predicate;
17. Contacts launch-policy decision recommendation;
18. Presence launch-policy decision recommendation;
19. archive availability Operating-policy recommendation;
20. source-delta Operating-policy recommendation;
21. incomplete-build rule confirmation;
22. repeated-failure ownership confirmation;
23. final startup UI fact list;
24. property-test changes;
25. one-page whiteboard model;
26. confirmation Response 40 deletion direction remains intact;
27. remaining true product decisions;
28. whether architecture is now simpler than Response 41;
29. exact Git/worktree/index/submodule state;
30. confirmation nothing was modified.

Conclude exactly:

`APPCZAR FACT-DAG HUMAN REVIEW COMPLETE: YES / NO`

`LAUNCH DAG REDUCED TO HUMAN-SCALE: YES / NO`

`INDEPENDENT-ROOT SELECTION RULE IS MECHANICAL: YES / NO`

`COORDINATOR LIFETIME MODEL IS UNAMBIGUOUS: YES / NO`

`READY TO DESIGN IMPLEMENTATION GATES: YES / NO`

Then STOP.
