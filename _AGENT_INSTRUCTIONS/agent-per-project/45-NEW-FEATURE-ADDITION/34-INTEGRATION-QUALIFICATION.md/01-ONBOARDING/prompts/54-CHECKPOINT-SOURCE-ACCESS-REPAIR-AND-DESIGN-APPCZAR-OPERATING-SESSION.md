# MessageLens Feature 34
## 54 — Checkpoint Source Access Repair and Design the AppCzar Operating Session

Response 53 exercised the second live AppCzar coordinator against the real development environment.

Observed live sequence:

```text
PID 71916
fresh AppCzar
-> conclusive Messages-source unreadability
-> Source Access Repair

human restores macOS access
-> explicit Check Again
-> PID 71916 terminates
-> observed no-development-process interval
-> PID 74203

PID 74203
fresh AppCzar
-> independently selects Data Update
-> Data Update runs
-> PID 74203 terminates
-> observed no-development-process interval
-> PID 74930

PID 74930
fresh AppCzar
-> source/import/graph all 138916
-> source/local high-water 155092
-> new messages 0
-> virtual Operating Session
```

Response 53 conservatively called the overall live qualification `AMBIGUOUS` because two requested transient observations were not captured:

1. the human did not directly see whether the `Check Again` button became disabled during its very short pending interval;
2. the intermediate Data Update screen disappeared before its exact per-run counts/result copy was recorded.

No contradictory behavior occurred.

Those two observational gaps must be kept explicit, but they must not be silently promoted into architectural failures:

- Prompt 52's deterministic tests already prove the synchronous single-flight guard;
- Data Update's mutation/restart behavior was independently qualified in the earlier live Data Update experiment;
- Response 53 directly observed the architectural facts that matter for cross-coordinator authority: two real process boundaries, no in-process chaining, and a final disposition derived only by a third fresh process.

This task has two purposes:

1. checkpoint and push the qualified/observed Source Access Repair milestone without integrating it to `main`;
2. perform a read-only design audit for the next major boundary: **AppCzar Operating Session**.

Do NOT implement Operating Session in this task.
Do NOT make another coordinator executable.
Do NOT route production startup through AppCzar.
Do NOT delete legacy startup/onboarding code yet.
Do NOT modify real MessageLens data.
Do NOT launch production MessageLens.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Expected before checkpoint:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream: `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`;
- Prompt 52 implementation present and unstaged;
- Response 53 made no source/test changes;
- index empty;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- development FDA entry currently enabled;
- `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` currently unset.

Read Responses 51, 52, and 53 plus the canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Audit the exact Prompt 52 diff before staging

Inventory every tracked and intended untracked Prompt 52 source/test/generated/release-metadata path.

Separate:

1. evaluator FALSE-vs-UNKNOWN correction;
2. Source Access Repair domain/application/presentation;
3. System Settings navigation reuse/wiring;
4. AppCzar startup-harness integration;
5. architecture enforcement/tests;
6. generated files;
7. release metadata;
8. Prompt/Response 52–54 documentation;
9. unrelated pre-existing untracked material.

Do not use broad `git add .`.

No unrelated path may be staged.

---

# 3. Qualification interpretation of Response 53

Perform a bounded evidence review before checkpointing.

## A. Core live coordinator contract

Determine whether Response 53 directly proves:

- conclusive FALSE selected Source Access Repair;
- Source Access Repair made no FDA-state claim;
- opening System Settings was navigation only;
- the visible toggle change alone did not change coordinator semantics;
- one explicit `Check Again` led to the readable/restart path;
- Source Access Repair ended at a real process boundary;
- a new PID independently selected Data Update;
- Data Update ended at a second real process boundary;
- a third PID independently selected virtual Operating Session;
- no stale coordinator state crossed either restart;
- no in-process coordinator chaining occurred.

## B. Uncaptured transient UI observations

Keep these as explicit limitations:

- live visual disabled state of `Check Again` while pending was not captured;
- intermediate Data Update exact screen counts/result copy were not captured.

Determine whether either missing observation is a **BLOCKER** to the Source Access Repair architectural contract, given:

- the single-flight behavior is deterministically covered by Prompt 52 tests;
- Data Update itself already has separate live qualification;
- Response 53 directly observed the real process-boundary behavior.

Do not simply inherit the word `AMBIGUOUS` as a conclusion. Apply the conformance/evidence standard and explain the decision.

Do not rerun the mutation experiment in this task.

---

# 4. Checkpoint strategy

If no BLOCKER or SHOULD FIX is found in the Prompt 52 implementation:

Create one implementation checkpoint for the exact already-validated source/test/generated/release-metadata tree.

Recommended subject:

`feat(startup): add AppCzar source access repair`

The commit body should summarize:

- exact FALSE versus UNKNOWN source-readability semantics;
- Source Access Repair as the second explicit live coordinator;
- read-only Check Again;
- System Settings navigation only;
- no TCC mutation or FDA-state testimony;
- no Ball;
- real process restart after proven readability;
- no coordinator chaining;
- Data Update remains separately isolated;
- production startup unchanged.

Commit Prompt/Response documentation separately if that is the established repository convention.

Do not reconstruct history through risky partial staging.

---

# 5. Push a recovery anchor only

Push the current branch normally after validation.

Do not force push, rebase, merge to `main`, merge a PR, or delete the branch.

Report exact local and remote commits.

---

# 6. Read-only Operating Session architecture audit

Inspect what it would mean for a **fresh healthy AppCzar assessment** to select the real normal application session.

The governing rule is:

> Only a fresh AppCzar assessment may admit an Operating Session.

Operating Session is not a repair step. It is the long-lived jurisdiction in which the user uses MessageLens normally.

Do not implement it yet.

---

# 7. Exact selection contract for Operating Session

Trace the current AppCzar evaluator and identify the exact current facts that produce virtual `Operating Session`.

At minimum audit whether it requires:

- data root admitted;
- current Messages source readable and stable;
- local import store healthy;
- graph healthy;
- overlay safe/readable;
- required attachment archive available;
- source/local count comparison known;
- source/local high-water comparison known;
- no pending source delta;
- no unresolved higher-priority contradiction.

Report the exact current predicate.

Do not invent a new readiness flag.

---

# 8. Operating Session entry must not restore historical semantic state

The first real Operating Session after startup must begin from a neutral, currently valid UI state.

Audit how to guarantee:

```text
sidebar: Conversations
selected conversation: none
selected contact: none
center content: none / neutral
```

or the exact equivalent appropriate to the existing shell.

The earlier clean-slate failure proved that restored SidebarFlow/contact state could project stale semantic content before the rebuilt graph was ready.

Therefore distinguish:

```text
historical user preference
```

from:

```text
current application state
```

Persisted previous navigation may remain as historical preference data, but it must not automatically become the startup Operating state.

Trace:

- `SidebarFlow`;
- serialized navigation/contact preferences;
- cassette rack restoration;
- center-panel projection;
- any window/session restoration hooks.

Recommend the smallest mechanism for a fresh neutral Operating entry.

---

# 9. Audit legacy semantic machinery that the normal shell currently starts

Trace what constructing/admitting the current normal `App` causes to start.

At minimum inspect whether normal shell construction currently activates:

- `StartupApp` leftovers;
- Onboarding Journey/status/gate listeners;
- Environment Readiness projection;
- `OnboardingCenterPanelSyncObserver`;
- pipeline-incident semantic surfaces;
- installation-state providers;
- center-panel sync;
- old completion/recovery listeners;
- background monitors.

For every mechanism classify:

```text
must be absent before AppCzar Operating can go live
safe to remain temporarily but semantically inert
legitimate Operating Session service
```

The purpose is to prevent AppCzar from admitting the shell only for the old semantic authorities to regain control inside it.

---

# 10. Operating Session and ChatDbChangeMonitor

This requires explicit design review.

Today `ChatDbChangeMonitor` can call the shared `LiveGraphUpdateWorker`.

Determine whether that is compatible with the new one-coordinator-at-a-time model.

Evaluate at least these two designs.

## Design A — Operating observes, then restart/reassess

```text
Operating Session
-> observes source advancement
-> does not mutate
-> requests restart
-> fresh AppCzar selects Data Update
```

Advantages:
- all Data Update authority remains centralized in the Data Update coordinator;
- strongest interpretation of “AppCzar approves consequential work.”

Costs:
- a new incoming message can cause a process restart;
- potentially disruptive during normal use.

## Design B — currentness maintenance belongs inside Operating jurisdiction

```text
Operating Session
-> monitor observes source advancement
-> Operating Session invokes LiveGraphUpdateWorker as an internal worker
-> jurisdiction remains Operating
```

Advantages:
- normal live-update UX;
- no restart for ordinary incoming messages.

Risks:
- must not accidentally recreate a second semantic Data Update authority;
- failure semantics must be explicit;
- startup Data Update and in-session update worker roles must remain understandable.

Recommend one design from the existing architecture and project goals.

Do not implement either in Prompt 54.

---

# 11. Define what ends an Operating Session

Audit events that should end or invalidate Operating jurisdiction.

Examples:

- source access lost;
- archive volume disappears;
- graph/store contradiction discovered;
- user requests Start Fresh/reset;
- attachment archive configuration changes;
- unrecoverable monitor/update failure;
- normal user quit.

For each, answer whether Operating should:

- continue safely;
- surface a bounded same-session issue;
- request restart for fresh AppCzar;
- invoke a separate coordinator only after restart.

Avoid in-process top-level coordinator chaining.

---

# 12. Operating Session must own normal navigation, not startup history

Once admitted, same-session user navigation is legitimate.

Define the boundary:

```text
fresh AppCzar
-> Operating Session starts with neutral navigation
-> user navigates
-> SidebarFlow/session state becomes authoritative for that session
```

Persisting navigation as a preference may remain for historical or optional UX purposes, but it must not classify or preselect the next fresh session unless a future explicit product decision reintroduces that behavior.

Recommend whether the old durable navigation preference should eventually be:

- deleted;
- retained as history only;
- retained behind an explicit `Restore last view` user action;
- retained for non-semantic visual preferences only.

Do not change it yet.

---

# 13. Audit current contact/display resolver initialization

The earlier clean-slate qualification exposed an immutable `displayIdentityResolverProvider` created while the graph was empty, producing fallback `contact <id>` names until provider recreation.

Determine whether fresh Operating entry after AppCzar's graph-health proof mechanically prevents that stale initialization.

If yes, prove the provider-construction order/currentness dependency.

If no, identify the remaining fix required before Operating Session can be qualified.

Default: report only.

---

# 14. Window restoration versus semantic restoration

Separate harmless window-level preferences from semantic app state.

Examples likely safe:

- window size;
- window position;
- column widths;
- appearance.

Examples requiring scrutiny:

- selected contact;
- selected conversation;
- center content;
- readiness panel;
- onboarding panel;
- last coordinator/disposition.

Produce an explicit keep/demote/delete recommendation.

---

# 15. Operating Session implementation plan

Without editing code, provide a concrete future implementation plan answering:

1. exact AppCzar predicate selecting Operating Session;
2. exact executable seam;
3. how the legacy `App` shell will be reused;
4. how fresh neutral navigation is forced;
5. which legacy startup/readiness listeners must be disabled/removed first;
6. whether `ChatDbChangeMonitor` remains, changes role, or is temporarily disabled;
7. what services initialize only after Operating admission;
8. what failures request restart;
9. how Start Fresh/reset is exposed within Operating without reviving Journey authority;
10. how tests prove no historical navigation/readiness state can choose startup content;
11. how production startup can remain unchanged during development qualification;
12. what human qualification sequence will prove the shell opens cleanly.

---

# 16. Validation before checkpoint

Before committing Prompt 52 implementation, run:

1. evaluator tests;
2. Source Access Repair tests;
3. Data Update regressions;
4. process-restarter tests;
5. AppCzar host/mapping tests;
6. architecture suite;
7. analyzer;
8. full deterministic Flutter suite;
9. `git diff --check`;
10. `git diff --cached --check`;
11. formatting/generated consistency.

If staging changes the qualified tree, explain and revalidate.

---

# 17. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

The Response 53 observational limitations must be explicitly classified rather than hidden.

Do not create code merely to make the report say PASS.

If either limitation reveals a true product/architecture defect, STOP before commit/push.

---

# 18. Required response

Create Response 54 and report:

1. baseline verification;
2. exact Prompt 52 diff inventory;
3. intended versus unrelated files;
4. Response 53 core live-contract evidence review;
5. classification of the missed Check Again disabled-state observation;
6. classification of the missed intermediate Data Update detail observation;
7. qualification verdict for Source Access Repair;
8. validation results;
9. Project Conformance verdict;
10. BLOCKER findings;
11. SHOULD FIX findings;
12. implementation checkpoint commit;
13. documentation checkpoint commit;
14. remote recovery-anchor commit;
15. branch/upstream status;
16. exact Operating Session selection predicate;
17. neutral startup navigation design;
18. legacy shell semantic-authority census;
19. Operating Session / ChatDbChangeMonitor design comparison;
20. recommended live-update design;
21. Operating jurisdiction termination rules;
22. durable navigation-preference recommendation;
23. display-identity resolver audit;
24. window-restoration versus semantic-restoration map;
25. future Operating Session implementation plan;
26. exact Git/worktree/index/submodule state;
27. confirmation no integration to `main` occurred.

Conclude exactly:

`SOURCE ACCESS REPAIR MILESTONE CHECKPOINTED: YES / NO`

`SOURCE ACCESS REPAIR CORE LIVE CONTRACT QUALIFIED: YES / NO`

`RECOVERY ANCHOR PUSHED: YES / NO`

`OPERATING SESSION DESIGN AUDIT COMPLETE: YES / NO`

`READY TO IMPLEMENT APPCZAR OPERATING SESSION: YES / NO`

Then STOP.
