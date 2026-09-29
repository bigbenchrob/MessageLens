# MessageLens Clean-Slate Integrated Qualification
## 04 — Resolve Canonical Onboarding Authority Contradiction and Resume Forensic Audit

Prompt 03 stopped correctly on a material contradiction in canonical onboarding
documentation.

The contradiction is now resolved by human decision:

> **Journey-only presentation governs.**

The direct-snapshot sentence in:

`_AGENT_INSTRUCTIONS/agent-per-project/25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md`

is obsolete architectural drift and must not govern the forensic audit.

The governing model is:

```text
operation execution
       |
       v
durable operation evidence
       |
       v
OnboardingJourneyCoordinator
       |
       v
authoritative OnboardingJourneyState
       |
       v
presentation
```

Presentation may display detailed progress, but the progress must be validated
and projected through the Journey-owned state before presentation consumes it.

There is no canonical exception allowing `OnboardingOperationSnapshot` to
independently control onboarding presentation.

This task has two stages:

1. correct the contradictory canonical documentation;
2. resume and complete the previously stopped forensic audit.

Do NOT implement production-code fixes.
Do NOT change tests except if a documentation-validation mechanism itself
requires factual reference updates.
Do NOT regenerate code.
Do NOT launch MessageLens Development.
Do NOT repeat Start Fresh or import.
Do NOT access production data or attachment archives.

---

# 1. Re-establish the clean baseline

Verify:

- current branch remains `fix/onboarding-import-stuck-state`;
- HEAD remains the integrated baseline:
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- local/remote `main` remain at the same commit;
- tracked worktree and index are clean;
- shared-instructions submodule remains clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- the preserved WIP patch still exists outside the working tree and is not
  applied;
- canonical Feature 34 records 07 and 09 remain restored at their tracked root
  locations;
- qualification prompts/responses remain untracked/untouched.

STOP if the clean baseline has changed materially.

---

# 2. Correct the canonical contradiction

Edit only the canonical onboarding documentation necessary to remove the
contradiction.

At minimum correct the sentence in:

`25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md`

that currently says:

> Presentation consumes `OnboardingOperationSnapshot`; it does not calculate work
> by inspecting repositories.

Replace it with wording that preserves the intended distinction:

- repositories/services perform work;
- durable operation evidence records bounded operation facts;
- the Journey Coordinator validates/interprets current-operation evidence;
- presentation consumes coordinator-owned Journey projection;
- presentation does not independently infer Journey meaning from repositories or
  directly from the durable snapshot.

Do not rewrite unrelated sections.

Do not erase historical rationale.

If adjacent text now becomes misleading because it assumes direct snapshot
consumption, correct only the minimum necessary surrounding wording.

---

# 3. Reconcile the canonical onboarding set

Review the relevant canonical onboarding documents together, especially:

- onboarding overview;
- `10-onboarding-gate.md`;
- `20-environment-readiness.md`;
- `30-import-migration-coordination.md`;
- Journey Coordinator documentation;
- any document defining Trip/Step/presentation ownership.

Confirm they now agree on all of these statements:

1. Journey Coordinator is sole Journey-semantic authority.
2. Operation snapshot is durable evidence, not Journey navigation/presentation
   authority.
3. Presentation does not combine independent facts beside Journey state to decide
   onboarding meaning.
4. Detailed operation progress remains possible through a Journey-owned
   projection.
5. Evidence producers may fail/dispose without preventing Journey publication of
   failure/retry state.

If another material contradiction is found, STOP AND REPORT rather than silently
rewriting a larger documentation set.

---

# 4. Add an explicit canonical invariant

Where the existing onboarding canonical documentation most naturally defines
authority, add a concise invariant equivalent to:

> **Evidence may be distributed. Journey authority may not be.**
>
> Only `OnboardingJourneyCoordinator` determines user-visible onboarding state
> and what happens next. Durable operation snapshots and other providers supply
> evidence to the coordinator; presentation consumes the coordinator-owned
> Journey projection.

Do not create a new generic framework document merely for this sentence if an
appropriate canonical authority section already exists.

---

# 5. Documentation-only validation

Run:

- documentation/reference validation appropriate to the changed files;
- `git diff --check`;
- inspect the exact diff.

Do not commit yet unless repository instructions require documentation
checkpointing before the audit resumes.

If a commit is required, use a documentation-only commit with a narrow message,
for example:

`docs(onboarding): restore journey-only presentation authority`

Do not include qualification prompts/responses or unrelated files.

---

# 6. Resume Prompt 03 forensic audit

After the canonical contradiction is removed and validated, resume the full
forensic work from Prompt 03.

Do not restart from assumptions.

Complete all previously unperformed sections:

- production authority inventory;
- Journey write-path tracing;
- presentation side-door tracing;
- `OnboardingOperationSnapshot` field/use classification;
- stale-result/operation-identity analysis;
- failure-ownership analysis;
- deterministic replay/test audit;
- required vs actual state-flow graphs;
- Git-history drift chronology;
- architecture tripwire/allowlist audit;
- concrete analogous state-authority patterns elsewhere;
- correction boundary and phased plan.

The existing response file:

`01-ONBOARDING/responses/03-ONBOARDING-AUTHORITY-FORENSIC-AUDIT.md`

should be replaced or extended into the completed forensic audit record while
preserving a brief note that the earlier stop gate was resolved by the explicit
human decision recorded here.

Do not create a second competing response-03 file.

---

# 7. Historical drift analysis requirement

The completed forensic audit must now answer explicitly:

- when the direct-snapshot presentation rule entered canonical documentation;
- whether production code preceded the documentation or vice versa;
- which local problem the direct-snapshot path was intended to solve;
- whether tests were added that encoded it;
- whether later changes increased its semantic authority;
- whether the contradiction with Journey-only documents was visible at the time.

Classify historical claims as:

- VERIFIED HISTORY
- STRONGLY SUPPORTED INFERENCE
- UNKNOWN

Do not retrofit motives that Git/docs do not support.

---

# 8. Do not implement the fix yet

Even after the forensic audit completes:

- do not apply the preserved WIP patch;
- do not modify onboarding production code;
- do not modify onboarding tests;
- do not start a new implementation phase.

The next step after a complete audit will be a separately reviewed correction
design based on the evidence.

---

# Final report

Report:

1. clean baseline result;
2. exact canonical documentation changed;
3. exact authority wording established;
4. whether the canonical onboarding set now agrees;
5. documentation validation result;
6. whether a documentation-only commit was required/performed;
7. completed forensic-audit path;
8. exact number of Journey-semantic influencers found;
9. exact number of presentation side doors found;
10. operation-identity conclusion;
11. failure-ownership conclusion;
12. historical drift summary;
13. tests/tripwires that encoded or missed the violation;
14. analogous project-wide patterns found;
15. proposed correction boundary;
16. open human decisions;
17. any new stop gate.

Conclude exactly:

`CANONICAL ONBOARDING AUTHORITY CONTRADICTION RESOLVED: YES / NO`

and, if YES:

`ONBOARDING AUTHORITY FORENSIC AUDIT COMPLETE: YES / NO`

and, if that is YES:

`SAFE TO DESIGN ONBOARDING AUTHORITY CORRECTION: YES / NO`

Then STOP.
