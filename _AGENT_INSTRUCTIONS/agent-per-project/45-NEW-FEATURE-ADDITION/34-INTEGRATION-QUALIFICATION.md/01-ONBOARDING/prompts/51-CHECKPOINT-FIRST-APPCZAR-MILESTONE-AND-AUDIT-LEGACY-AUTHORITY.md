# MessageLens Feature 34
## 51 — Checkpoint the First AppCzar Milestone and Audit Legacy Semantic Authority

Response 50 qualified the first real AppCzar self-healing loop against live
development data.

Observed end-to-end behavior:

```text
fresh process
-> AppCzar observed current source/local delta = 59 messages
-> AppCzar selected Data Update
-> one Data Update coordinator ran
-> existing importer/projector imported 59 messages
-> existing attachment path preserved 13 attachments, 0 failed
-> old process terminated
-> a no-development-process boundary was observed
-> LaunchServices created a new PID
-> fresh AppCzar independently observed source/import/graph = 138882
-> source/local high-water = 155058
-> new messages = 0
-> fresh AppCzar selected virtual Operating Session
```

This is the first real qualification of:

> **Do it. Stop. Reassess.**

Before another coordinator becomes executable, checkpoint this milestone and
audit what legacy semantic-authority machinery is now demonstrably redundant or
in conflict with the AppCzar model.

This task is primarily a **checkpoint + read-only architecture audit**.

Do NOT implement Source Access Repair yet.
Do NOT make another coordinator executable.
Do NOT route production startup through AppCzar.
Do NOT delete legacy machinery yet unless a deletion is a tiny, mechanically
proven dead-code cleanup required to make the checkpoint coherent.
Do NOT change real data.
Do NOT launch production MessageLens.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Expected:

- branch `fix/onboarding-import-stuck-state`
- HEAD/upstream before checkpoint:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- accumulated Prompt 32 + 35 + 44 + 46 + 48 implementation present
- Prompt 49 and Prompt 50 were human experiments only
- current qualified development build:
  `0.2.131+149`
- index empty before staging
- shared-instructions submodule clean at
  `95326f515ef4719f155ce6e223990398daad6311`

Read Responses 32, 35, 44, 46, 48, 49, and 50 plus the canonical:

`MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`

Create a fresh external baseline manifest before any staging.

---

# 2. Treat Response 50 as milestone qualification evidence

Preserve the exact qualification facts:

- direct-launch source readability was restored only by human macOS permission
  action;
- AppCzar itself testified only that the Messages source was readable;
- source was naturally 59 messages ahead;
- Data Update ran exactly once;
- existing import/graph machinery reached 138882;
- 13 attachments were preserved, zero failed;
- old PID 5455 terminated;
- an explicit no-development-process boundary was observed;
- new PID 5921 launched;
- fresh AppCzar independently found:
  - source count 138882;
  - import count 138882;
  - graph count 138882;
  - source/local high-water 155058;
  - new messages 0;
- only the fresh process selected virtual Operating Session;
- no old AppCzar facts/progress appeared after restart.

Do not reinterpret or strengthen these observations.

---

# 3. Audit the accumulated diff before staging

Classify every tracked and intended untracked source/test/document change into:

1. Prompt 32 reset eligibility / invocation-time classification work;
2. Prompt 35 reset single-flight work;
3. Prompt 44 visible AppCzar harness;
4. Prompt 46 Fair-Witness correction;
5. Prompt 48 first live Data Update coordinator;
6. generated/build metadata legitimately belonging to those changes;
7. prompt/response documentation;
8. unrelated pre-existing files.

Produce an exact path inventory.

No unrelated file may be staged merely because it is currently modified or
untracked.

Do not use broad `git add .`.

---

# 4. Milestone checkpoint strategy

Prefer a safe checkpoint over artificial history reconstruction.

If the accumulated qualified implementation cannot be cleanly separated into
independent commits without partial-file/hunk surgery that risks changing the
qualified tree, create **one milestone implementation commit** containing the
entire qualified source/test/generated/release-metadata delta.

Recommended subject:

`feat(startup): establish AppCzar fair-witness self-healing loop`

The commit message body should summarize:

- reset correctness prerequisites;
- visible Fair-Witness AppCzar harness;
- source-readability semantics;
- truth-vs-significance presentation;
- one executable Data Update coordinator;
- reuse of existing incremental update machinery;
- real restart boundary;
- fresh post-restart reassessment;
- production startup still unchanged.

Prompt/Response Markdown artifacts may be committed separately if that is the
repository's established convention.

Do not perform risky partial staging solely to create prettier history.

---

# 5. Push a recovery anchor, but do not integrate

After local checkpoint validation:

- push the current branch normally;
- no force push;
- no rebase;
- no merge to `main`;
- no PR merge;
- no branch deletion.

Report the exact checkpoint commit and remote branch commit.

The purpose is to create a durable recovery anchor before the next architectural
step.

---

# 6. Read-only audit: which old semantic authorities are now obsolete?

Perform a source-grounded census of machinery that attempts to remember,
reconstruct, reconcile, or publish application-level startup/readiness state
across launches.

At minimum inspect:

- `MessageLensInstallationState` and any durable installation classifier;
- `OnboardingEnvironmentReport`;
- Journey coordinator / Trip / Step state;
- durable Onboarding operation snapshots/resume/reconciliation;
- Onboarding gate/status providers;
- Environment Readiness semantic surfaces;
- SidebarFlow persisted navigation/contact restoration;
- center-panel synchronization controllers;
- startup completion callbacks/handoffs;
- graph-admission/readiness semantic gates;
- startup failure/recovery dispositions;
- durable values that encode conclusions rather than source facts.

For each item classify it as exactly one of:

```text
KEEP AS FACT SOURCE
KEEP AS SAME-SESSION UI STATE
KEEP AS WORKER-INTERNAL MECHANISM
DEMOTE — no longer semantic authority
DELETE CANDIDATE — replaced by AppCzar model
UNKNOWN — requires additional source trace
```

Do not delete merely because a name sounds old.

Trace actual readers/writers/callers.

---

# 7. Apply the new authority test

For each old durable/status mechanism ask:

> If MessageLens starts in a brand-new process with none of this remembered
> conclusion available, can AppCzar determine the correct current disposition
> from independently observable facts?

If YES, the remembered conclusion has no current semantic-authority role.

A durable value may still be valid if it is itself a fact, for example:

- user-authored overlay content;
- user preferences that are merely preferences;
- archive-location configuration/identity;
- immutable provenance;
- source-derived imported rows;
- attachment payloads;
- bounded attempt counter used only by a coordinator retry policy.

Do not confuse durable storage with semantic authority.

---

# 8. Explicitly identify historical-intent machinery

Search for code whose purpose is effectively:

```text
last time we believed X
therefore start this launch assuming X
```

Examples include:

- restored selected contact/conversation;
- remembered onboarding phase;
- resumable app-level journey state;
- readiness flags;
- completed state used to classify the next launch;
- stale graph-admission references;
- startup handoff flags.

Record the exact path and caller chain.

The audit should distinguish:

```text
historical information that may be displayed
```

from:

```text
historical conclusion used as present semantic authority
```

Only the second category is architectural debt under AppCzar.

---

# 9. Preserve worker internals that are not semantic authority

Do not accidentally target legitimate implementation state.

Examples that may remain:

- bounded import pages;
- frozen source high-water inside a live worker;
- SQLite transaction boundaries;
- source import ledger/cursor representing imported source facts;
- graph schemas/versions;
- attachment archive configuration;
- exact mutation journal required for a bounded physical relocation operation;
- same-session provider state;
- `messageDataVersionProvider` as process-local cache invalidation.

Classify by meaning, not by whether something is called state.

---

# 10. Produce a deletion/demotion map, not a refactor

Output a dependency-aware map such as:

```text
Legacy semantic authority A
  readers:
  writers:
  current purpose:
  AppCzar replacement:
  disposition: DELETE CANDIDATE

Legacy mechanism B
  current purpose:
  still needed by worker:
  semantic-authority role:
  disposition: KEEP AS WORKER-INTERNAL MECHANISM
```

Order deletion candidates by dependency so later implementation can remove
outer semantic layers before or after inner workers safely.

Do not perform the deletion in Prompt 51.

---

# 11. Review the UNKNOWN -> Source Access Repair concern

Response 47 left one open Fair-Witness issue:

- conclusive source-access denial -> `Source Access Repair` is justified;
- genuinely inconclusive/UNKNOWN source readability does **not** prove a source
  access defect.

Audit the current evaluator and propose the smallest future correction.

Preferred conceptual outcome:

```text
conclusive access denial/unavailable
    -> Source Access Repair

inconclusive source readability
    -> Diagnostic Review / Indeterminate
```

Do not implement this correction in Prompt 51 unless it is literally a one-line
pure evaluator bug with existing tests proving the desired semantics. Default:
report only.

---

# 12. Review the next coordinator candidate

Evaluate, without implementing, whether `Source Access Repair` is the right next
bounded live coordinator.

Answer:

1. What exact current fact selects it?
2. Can MessageLens itself repair the condition, or must the human act in macOS
   System Settings?
3. What current source-readability observation should terminate its jurisdiction?
4. Should it poll/retest in-process while the user changes permission, or simply
   guide the user and request restart?
5. What would constitute an unsupported FDA claim?
6. Can it remain completely free of persisted journey/resume state?
7. What process boundary should end successful repair?
8. What tests would prove it cannot silently become a generic permission wizard?

Do not build it yet.

---

# 13. Validation before checkpoint completion

Run the appropriate accumulated validation after staging but before finalizing
the checkpoint:

1. focused AppCzar tests;
2. focused Data Update tests;
3. reset eligibility/single-flight tests;
4. mutation/authority regressions;
5. complete architecture suite;
6. analyzer;
7. full Flutter suite;
8. `git diff --check`;
9. staged diff check;
10. formatting/generated consistency.

If staged content differs from the qualified working tree in any source/test
file, explain why and revalidate that exact tree.

---

# 14. Project Conformance audit

Apply the canonical conformance standard to the accumulated milestone.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Do not create cosmetic work merely to empty the findings list.

If a real BLOCKER or SHOULD FIX appears, STOP before commit/push and report it.

---

# 15. Required response

Create Response 51.

Report:

1. baseline verification;
2. exact accumulated-diff inventory;
3. intended vs unrelated files;
4. checkpoint strategy chosen;
5. exact validation results;
6. Project Conformance verdict;
7. BLOCKER findings;
8. SHOULD FIX findings;
9. exact local checkpoint commit;
10. exact remote recovery-anchor commit;
11. branch/upstream status after push;
12. complete legacy semantic-authority census;
13. KEEP AS FACT SOURCE items;
14. KEEP AS SAME-SESSION UI STATE items;
15. KEEP AS WORKER-INTERNAL MECHANISM items;
16. DEMOTE items;
17. DELETE CANDIDATE items;
18. UNKNOWN items;
19. historical-intent caller chains;
20. dependency-ordered deletion/demotion map;
21. UNKNOWN-source-readability evaluator review;
22. recommendation for the next Source Access Repair design;
23. exact Git/worktree/index/submodule state after checkpoint;
24. confirmation no integration to main occurred.

Conclude exactly:

`FIRST APPCZAR MILESTONE CHECKPOINTED: YES / NO`

`RECOVERY ANCHOR PUSHED: YES / NO`

`LEGACY SEMANTIC-AUTHORITY AUDIT COMPLETE: YES / NO`

`READY TO DESIGN SOURCE ACCESS REPAIR: YES / NO`

Then STOP.
