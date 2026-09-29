# MessageLens Feature 34 / Feature 35
## 23 — Repeat Human Architectural Review After Inner-I/O and Coherence Correction

Prompt 22 reports that the two Prompt 21 BLOCKER findings and all four remaining architecture-enforcement SHOULD FIX findings are resolved.

This task is a **read-only repeated architectural review before checkpoint**.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Review the actual current accumulated Onboarding diff.

The governing invariants remain:

> **Evidence may be distributed. Journey authority may not be.**

> **The Ball proves exclusive tenure. Domain capability proves what the current owner may do while holding that Ball. Diagnostics prove neither.**

> **No protected I/O may start after capability/resource authority becomes stale.**

> **A side-effect decision must be based on one coherent current evidence set, not a mixture of mutable evidence from different revisions.**

---

# 1. Read the governing records

Read in full:

- `21-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-ONBOARDING-TENURE-CORRECTION.md`
- `22-CORRECT-INNER-IO-AND-EVIDENCE-COHERENCE.md`
- `20-CORRECT-ONBOARDING-TENURE-REVIEW-FINDINGS.md`
- `19-HUMAN-ARCHITECTURAL-REVIEW-ONBOARDING-TENURE-CORRECTION.md`
- `18-IMPLEMENT-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`
- the complete current accumulated Onboarding implementation delta;
- relevant Feature 35 authority/audit records.

Inspect especially:

- `onboarding_environment_report_provider.dart`;
- `onboarding_failure_store.dart`;
- `overlay_onboarding_failure_storage.dart`;
- `attachment_archive_location_provider.dart`;
- `attachment_archive_location_controller.dart`;
- their complete tests;
- `onboarding_journey_coordinator_provider_test.dart`;
- `onboarding_journey_authority_architecture_test.dart`.

Spot-check `onboarding_journey_coordinator_provider.dart` to confirm Prompt 22 left the previously accepted command semantics unchanged.

---

# 2. Baseline and preservation gate

Verify:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked delta: 55 modified / 2 deleted;
- shared submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check` passes.

Verify the Prompt 22 baseline manifest:

`/private/tmp/messagelens-onboarding-prompt22-baseline.ETdg87/MANIFEST.json`

SHA-256:

`e1520edb5c864ac7118aee582d68379fad6d7e2245bcfbb5d7633cb37a775b0d`

and recheck the prior Prompt 20/18/reconstruction/pre-merge/collision-backup manifests.

If unrelated bytes changed after Prompt 22, STOP AND REPORT.

---

# 3. Review the exact protected-I/O checkpoint interface

Inspect the callback/interface introduced for admitted protected evidence reads.

Confirm:

- capability remains owned by the admitted Environment reader;
- specialists receive only a proof-checkpoint callback or equivalent bounded interface;
- no specialist stores capability/tenure;
- no specialist publishes authority state;
- no specialist learns Journey semantics;
- no ambient current-Ball lookup was introduced;
- the callback proves both exact operation capability and the correct existing archive resource admission.

Report any place where proof responsibility has migrated into failure storage or attachment-location state rather than remaining caller-supplied.

---

# 4. Review failure-storage source path at the actual I/O boundary

Trace `OverlayOnboardingFailureStorage.loadSourceImportFailureEntry` through overlay database acquisition, admission checkpoint, and the actual `readOverlaySetting`.

Require:

```text
proof/resource valid
-> await DB/store acquisition
-> proof/resource revalidated
-> protected setting read
```

Confirm:

- no protected read starts after authority/resource withdrawal;
- checkpoint exceptions remain fail-closed and are not swallowed as corrupt/unreadable evidence;
- the production default still calls the real overlay setting read;
- test injection does not alter production semantics.

Any inner await followed by protected work without renewed proof is a BLOCKER.

---

# 5. Review graph-failure primary and historical fallback

Trace both:

- current graph-failure key;
- historical fallback key.

Confirm each key path independently re-proves authority/resource admission before its protected read.

For fallback specifically prove:

```text
primary returns null
-> admission re-proved
-> historical acquisition begins
-> admission re-proved before protected read
```

There must be no path where a stale primary result allows historical protected I/O to begin under stale authority.

---

# 6. Review attachment-location one-shot admitted read

Inspect the new one-shot attachment evidence reader.

Confirm it:

- does not read or publish ambient attachment-location provider state;
- acquires the settings store under proof;
- re-proves after acquisition;
- constructs only local state/controller needed for this read;
- performs the protected setting read under proof;
- re-proves before returning;
- does not retain capability or caller-relative state.

The ordinary ambient attachment-location provider must retain its existing semantics for non-admitted consumers.

---

# 7. Review bookmark resolution and refreshed-metadata write

Trace the custom-bookmark path.

Require:

```text
admission current
-> await bookmark resolution
-> admission re-proved
-> if metadata refresh must be persisted:
       admission current
       -> protected settings write
       -> admission re-proved
```

Confirm a capability/resource-policy change while bookmark resolution is suspended prevents the refreshed write from starting.

Also confirm legitimate bookmark-refresh behavior is preserved when authority is still valid.

---

# 8. Review whether the existing resource action is actually appropriate

Prompt 22 reports that `ArchiveMutationResourceAction.openPersistentArchiveStore` correctly covers all overlay/settings I/O.

Inspect this claim in source.

Confirm failure-overlay reads, attachment location setting reads, and refreshed bookmark setting writes are semantically within the existing persistent-store resource policy.

Verify no operation is being shoehorned into an unrelated resource action merely to avoid adding one.

If the existing action is too broad/narrow for one of these operations, report a BLOCKER.

---

# 9. Review the bounded full-material double-collection strategy

Inspect the coherence algorithm exactly.

Prompt 22 reports:

- one sample contains source failure, graph failure, attachment location, and Contacts evidence;
- two consecutive equal samples establish stability;
- one mismatch triggers exactly one retry;
- a second mismatch fails closed.

Confirm:

- there is no unbounded retry/spin;
- comparison is deterministic;
- the first sample cannot leak into the final report if the second differs;
- after a second mismatch no evaluator/side-effect report is produced;
- the retry itself remains under current capability/resource proof.

---

# 10. Review material fingerprints for semantic completeness

Inspect each equality/fingerprint.

For failure evidence, confirm comparison includes all evaluator-relevant fields: phase, batch ID, message, recorded timestamp, and any other field that can alter failure/reset semantics.

For attachment location, confirm full immutable location-state comparison covers everything that can alter evaluator behavior.

For Contacts, confirm the fingerprint uses the exact evaluator-relevant outcome, not mutable object identity: availability plus selected physical source path or failure message.

Look for omitted fields that could make two semantically different samples compare equal.

Any such omission is a BLOCKER.

---

# 11. Review the final coherence boundary

After the final matching material sample, Prompt 22 reports no further await.

Inspect this exact path.

Confirm the code synchronously rereads:

- FDA;
- Messages source path;
- canonical data root;
- graph build state;
- live-update state;
- maintenance;
- developer overrides;
- database probe reader;
- any other command-relevant synchronous fact.

Then confirm:

- persistent-store admission is re-proved;
- graph-connection admission is re-proved;
- the shared evaluator runs synchronously;
- no await occurs before the report returns.

A mutable fact read before the final material await without a revision check is a BLOCKER.

---

# 12. Review reset-driving failure currentness

This was Prompt 21 BLOCKER 2.

Construct the exact sequence:

```text
sample A sees failure state X
-> later evidence changes
-> failure entry changes/clears/appears
-> sample B sees ?
```

Confirm the equality/retry protocol guarantees the returned report reflects the current stable failure evidence or fails closed.

Inspect the specific reset-driving fields used by the evaluator.

No mixed-revision reset decision may be possible.

---

# 13. Review protected-I/O withdrawal tests at the real boundary

Inspect the failure-storage tests.

Confirm the recording point is the actual injected protected setting read, not a higher-level method counter.

For each tested withdrawal:

- capability lost during DB acquisition;
- stronger resource denial during DB acquisition;

require:

- protected setting read count remains zero;
- Future fails for proof/resource reason;
- no later fallback/probe runs.

Apply the same scrutiny to graph primary and historical fallback.

---

# 14. Review attachment-location withdrawal tests

Inspect the tests for:

- settings-store acquisition withdrawal;
- bookmark-resolution withdrawal;
- stronger resource policy during bookmark resolution.

Confirm actual protected setting-read/write counters remain zero after withdrawal.

Ensure tests model production control flow closely enough that they would fail if the inner checkpoint were removed.

---

# 15. Review mixed-revision tests

Inspect tests for:

- source failure changed during later await;
- graph failure changed;
- failure cleared;
- reset-driving failure newly appears;
- second consecutive mismatch.

Confirm they exercise the real double-sample algorithm.

The second-mismatch test should prove bounded fail-closed behavior, including the reported exact observation count where appropriate.

---

# 16. Re-review real self-maintenance Journey tests for regression

Prompt 22 should not weaken Prompt 20's real-loop fixture.

For initial import, reimport, Continue Setup, and automatic recovery confirm:

- real registry;
- real coordinator;
- real global Environment provider;
- real `maintenanceInProgress` emission;
- Journey ingestion;
- admitted coherent evidence;
- exact command-specific boundary.

The coherence changes must not accidentally cause these tests to bypass the real global feedback path.

---

# 17. Review command semantics remain unchanged

Confirm `onboarding_journey_coordinator_provider.dart` is byte-identical to the Prompt 22 baseline.

Spot-check the previously accepted command ordering:

```text
positive global handoff
-> runWithCapability
-> coherent admitted evidence
-> exact late command-specific predicate/current binding
-> immediate begin/resume/reset
```

No new await may have appeared after the final semantic guard.

---

# 18. Review protected-I/O architecture enforcement

Inspect analyzer-AST enforcement over the actual production specialists.

Confirm it reaches:

- `OverlayOnboardingFailureStorage`;
- source read;
- graph current-key read;
- graph historical fallback;
- attachment one-shot reader;
- `AttachmentArchiveLocationController`;
- bookmark refresh write.

The rule must fail if a protected read/write is moved after an await without the approved renewed checkpoint.

Inspect the synthetic mutation proving that specific evasion.

Avoid accepting a test that merely counts checkpoint invocations without tying them to protected operations.

---

# 19. Review command-boundary control-flow enforcement

Inspect the strengthened mutation-boundary audit.

For each side effect:

- initial `begin`;
- reimport `begin`;
- continuation `resume`;
- automatic-recovery `begin`;
- `resetDerivedData`;

confirm architecture validation proves the required rejecting guard dominates the invocation, terminates the unsafe branch, contains the required semantic/currentness/binding conjunction, and has no intervening await.

Inspect the virtual mutation where the real guard is moved before an await and a dummy nearby predicate remains.

It must fail for the right reason.

---

# 20. Review critical-test realism enforcement

Inspect the architecture rule for `_JourneyFixture.create`.

Confirm that in real-feedback mode it mechanically proves:

- global Environment provider is not overridden;
- archive coordinator provider is not overridden;
- exclusive-authority registry provider is not overridden;
- real aggregate maintenance observation is retained/asserted.

Inspect the synthetic helper mutations that ignore the flag or replace an authority.

The real repository and virtual fixtures must use the same policy logic.

---

# 21. Review root-aware semantic/evidence traversal

Inspect `_transitiveLocalDependencies` and real root/trusted-boundary setup.

Confirm:

- root is traversed before `stopAt` applies to descendants;
- semantic roots are not themselves trusted stop nodes;
- `shellPath` is traversed;
- legitimate coordinator boundaries still stop traversal where intended;
- the real repository and mutation tests use the same trusted-boundary configuration.

Inspect the exact virtual path:

```text
shell
-> wrapper
-> raw conversation-graph barrel/controller
```

and confirm it fails.

---

# 22. Re-review semantic root / raw graph evidence census

Confirm:

- `OnboardingStatus` remains a semantic marker;
- status-only consumers are found;
- raw graph controller and barrel remain in the evidence census;
- wrapper/configuration transitive paths remain visible;
- no presentation/semantic side door can reach raw graph evidence outside the Journey authority boundary.

---

# 23. Review accumulated delta / reuse / authority ownership

Audit the complete accumulated Onboarding repair delta.

Look for:

- duplicate readiness policy;
- duplicate authority;
- callback/proof logic duplicated inconsistently across specialists;
- new public proof APIs;
- capability retained beyond invocation;
- stale old outer helper no longer needed;
- dead compatibility code;
- test-only hooks leaking to production;
- attachment-location production behavior changed beyond proof checkpoints.

Do not perform aesthetic cleanup.

Classify only concrete findings.

---

# 24. Persistence / migration / restart

Reconfirm:

- schema migration: none;
- persisted snapshot migration: none;
- existing operation records remain readable;
- startup reconciliation unchanged;
- ordinary interrupted import remains explicit Continue Setup;
- automatic resume absent;
- no capability/tenure serialization;
- no presentation change.

---

# 25. Validation evidence

Prompt 22 reports:

- Environment tests: 27 passed;
- failure-storage tests: 12 passed;
- attachment-location tests: 24 passed;
- real feedback Journey group: 4 passed;
- Journey coordinator: 60 passed;
- archive coordinator: 17 passed;
- generic Feature 35 registry: 23 passed;
- Feature 35 architecture: 42 passed;
- operation-snapshot architecture: 11 passed;
- virgin-boundary architecture: 6 passed;
- Start Fresh architecture: 7 passed;
- complete architecture: 554 passed;
- analyzer: clean;
- full Flutter suite: 2,743 passed / 0 failed / 1 intentional skip;
- `git diff --check`: PASS;
- Project Conformance: PASS;
- BLOCKER: 0;
- SHOULD FIX: 0.

Do not rerun the full suite for ceremony.

Run narrow tests only if source inspection exposes a specific unresolved question.

---

# 26. Required response

Create the next sequential response in the Feature 34 Onboarding responses folder.

Report:

1. baseline/preservation verdict;
2. protected-I/O checkpoint-interface verdict;
3. source failure-storage verdict;
4. graph primary/fallback verdict;
5. attachment one-shot evidence verdict;
6. bookmark-refresh write verdict;
7. resource-action semantic-fit verdict;
8. double-collection coherence verdict;
9. fingerprint-completeness verdict;
10. final coherence-boundary verdict;
11. reset-driving failure currentness verdict;
12. failure-storage withdrawal-test verdict;
13. attachment withdrawal-test verdict;
14. mixed-revision-test verdict;
15. real self-maintenance regression verdict;
16. command-semantics unchanged verdict;
17. protected-I/O architecture verdict;
18. command-boundary architecture verdict;
19. test-realism architecture verdict;
20. root-aware traversal verdict;
21. semantic-root/raw-graph census verdict;
22. accumulated-delta/reuse/authority verdict;
23. persistence/migration/restart verdict;
24. concrete BLOCKER findings;
25. concrete SHOULD FIX findings;
26. OPTIONAL findings;
27. narrow tests rerun, if any;
28. exact Git status;
29. preservation-artifact verification;
30. checkpoint recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`POST-PROMPT-22 ONBOARDING HUMAN ARCHITECTURAL REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO CHECKPOINT ONBOARDING CORRECTION: YES / NO`

Then STOP.
