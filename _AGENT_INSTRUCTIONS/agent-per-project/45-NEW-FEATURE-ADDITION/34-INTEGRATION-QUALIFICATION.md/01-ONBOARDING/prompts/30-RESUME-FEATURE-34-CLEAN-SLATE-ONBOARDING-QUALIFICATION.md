# MessageLens Feature 34
## 30 — Resume Clean-Slate Onboarding Qualification

The accumulated Onboarding correction is now checkpointed and pushed.

Checkpoint:

- branch: `fix/onboarding-import-stuck-state`
- checkpoint commit: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- parent: `276fa1b820b07bf14f41fe216192456b5415e290`
- subject: `fix(onboarding): restore journey authority under exclusive tenure`
- remote recovery branch: `origin/fix/onboarding-import-stuck-state`
- remote SHA: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`

This task resumes the **human Feature 34 clean-slate Onboarding qualification**
that originally exposed the stuck-import defect.

This is a qualification task, not another architecture audit.

Do NOT modify code unless a new qualification failure is first reproduced,
captured, and explicitly approved for investigation.
Do NOT stage or commit.
Do NOT merge to `main`.
Do NOT rebase.
Do NOT alter production MessageLens.
Do NOT access production data.
Do NOT delete or mutate real Messages/Contacts databases or real attachment
archives.

The human operator drives the GUI. Do not automate GUI interaction.

---

# 1. Read the canonical qualification records first

Read in full:

- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/01-CLEAN_SLATE_QUALIFICATION.md`
- the other Feature 34 preparation records needed to understand the established
  development snapshot / Start Fresh procedure;
- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`
- Response 29 checkpoint record.

Do not invent a replacement qualification sequence if the canonical preparation
records already define one.

---

# 2. Verify the qualification baseline

Before launching anything, verify:

- current branch: `fix/onboarding-import-stuck-state`
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- remote recovery branch points to the same SHA;
- index is empty;
- tracked worktree is clean;
- shared-instructions submodule is clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

The known unrelated/pre-existing untracked Category 4 paths may remain present.
Do not delete, stage, modify, or otherwise clean them up.

Response 29 may also remain untracked.

If tracked bytes have drifted from the checkpoint, STOP AND REPORT.

---

# 3. Re-establish the clean-slate development test state

Follow the canonical Feature 34 clean-slate qualification procedure exactly.

Use only the approved **development** application/data environment.

Production MessageLens and production data remain completely off-limits.

If the established procedure uses the previously created development snapshot,
Start Fresh, a development-only reset, or a development application bundle,
reuse that exact mechanism.

Do not invent a new reset procedure.

Before the human launches the app, report exactly:

- which development bundle/build is being qualified;
- which development data state is active;
- whether the state is genuinely clean-slate according to the canonical
  qualification criteria;
- whether any external development attachment archive is involved;
- whether any previous interrupted Onboarding operation record remains.

If clean-slate state cannot be established exactly as documented, STOP AND
REPORT rather than approximating it.

---

# 4. Build only if required by the canonical procedure

If the checkpointed development app must be rebuilt before qualification, do so
using the established Feature 34 development-build procedure.

Do not change source or generated files.

After build, verify the bundle corresponds to checkpoint:

`9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`

If a build step produces unexpected repository churn, restore only
unquestionably generated/tool-created churn and report it.

Do not launch production.

---

# 5. Human qualification boundary

Once preflight is complete, STOP and hand control to the human operator.

The human will launch MessageLens Development and perform the GUI steps.

Do not drive the GUI.

Provide a short human checklist derived from the canonical qualification record.

At minimum, qualification must revisit the exact scenario that originally
failed:

1. begin from genuine clean-slate development state;
2. proceed through Onboarding normally;
3. grant/verify prerequisites as the canonical sequence requires;
4. reach **Import My Messages**;
5. start the import;
6. observe whether the Journey remains coherent while the import owns the
   archive-mutation Ball;
7. verify that self-owned global `maintenanceInProgress` does not strand or
   contradict the Journey;
8. allow import / graph work to proceed to the next legitimate Journey state.

The canonical qualification document governs any additional required steps.

---

# 6. What the human should specifically observe

During the repaired path, the following old failure must **not** recur:

- Journey stuck in a `buildingGraph`-type phase;
- modal permanently non-dismissible;
- progress visually complete while no work advances;
- **Browsing data ready** while Journey still says building;
- no failure/retry state after a real failure;
- indefinite waiting with contradictory state.

The expected architectural behavior is:

```text
external / operation evidence
        |
        v
OnboardingJourneyCoordinator
        |
        v
authoritative Journey state
        |
        v
presentation
```

Operational snapshots and Environment evidence may contribute facts, but must
not independently choose user-visible Onboarding meaning.

---

# 7. Ball / track behavior to verify indirectly

The GUI qualification does not need to expose Ball internals.

What matters behaviorally is:

- the import command may hold the archive-mutation authority;
- its own lock may cause the aggregate Environment report to say maintenance;
- that self-owned maintenance must not make the command reject itself;
- fresh prerequisites must still be honored;
- if a real prerequisite changes, the Journey must transition coherently rather
  than continuing on stale evidence.

Do not add debug UI solely for this qualification.

Use existing logs/diagnostics only if needed to investigate an observed failure.

---

# 8. Qualification result handling

If the repaired scenario succeeds, record the exact human steps, visible Journey
states/transitions, whether import began, whether progress remained coherent,
whether the modal advanced/dismissed appropriately, and whether Browsing-ready
state appeared only when authorized by Journey.

Then continue the remaining canonical clean-slate qualification steps.

If a failure occurs, STOP qualification at the first reproducible contradiction
or error and record:

- exact visible state;
- exact human action immediately before it;
- current Journey state if available through existing diagnostics;
- operation evidence if available through existing diagnostics;
- relevant logs/errors;
- whether waiting changes anything;
- whether retry/dismiss controls exist;
- whether restarting changes the state.

Do not implement a fix in this task.
Do not begin another broad audit.
First produce a bounded failure report for human review.

---

# 9. No architecture re-review before human evidence

Do not run another speculative architecture review before qualification.

The checkpoint is approved.

Only reopen architecture if the human qualification produces a concrete,
reproducible failure that requires explanation.

---

# 10. Required response before GUI handoff

Create the next sequential response in the Feature 34 Onboarding responses
folder.

Report:

1. checkpoint/remote verification;
2. tracked worktree/index/submodule status;
3. canonical qualification documents read;
4. exact development clean-slate mechanism selected;
5. development data-state verification;
6. build/bundle verification, if a rebuild was required;
7. confirmation production remains untouched;
8. exact human GUI checklist;
9. exact formerly failing transition to watch;
10. any preflight stop gate.

Conclude exactly:

`FEATURE 34 CLEAN-SLATE ONBOARDING PREFLIGHT: PASS / FAIL`

If PASS, also conclude:

`READY FOR HUMAN GUI QUALIFICATION: YES / NO`

Then STOP and wait for the human operator's observations.
