# MessageLens Feature 35
## 03 — Human Architectural Review Before Exclusive Authority Tenure Checkpoint

Feature 35 Prompt 02 reports a complete implementation of the approved generic
exclusive-authority tenure primitive with `ArchiveMutationCoordinator` as the
first and only production adopter.

This task is a **read-only human architectural review of the actual unstaged
Feature 35 diff**.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT merge, rebase, cherry-pick, or push.
Do NOT touch the frozen Onboarding worktree.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- `responses/02-IMPLEMENT-EXCLUSIVE-AUTHORITY-TENURE.md`
- all canonical architecture/conformance records cited by Audit 01;
- the complete current Feature 35 unstaged diff.

The governing model is:

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

The purpose is to decide whether Feature 35 may be checkpointed as a stable,
known-good architectural foundation before it is integrated into `main` and
used by the frozen Onboarding correction.

---

# 1. Baseline and isolation

Verify the Feature 35 worktree and branch:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`
- branch:
  `feature/exclusive-authority-tenure`
- HEAD/base:
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream:
  `origin/main`
- index: empty

Confirm that the Feature 35 tracked/untracked implementation delta contains only
the approved generic primitive, archive-adapter changes, generated output,
tests, and Feature 35 prompt/response records.

Re-verify the frozen Onboarding worktree remains untouched:

- branch: `fix/onboarding-import-stuck-state`
- HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- index empty;
- frozen tracked delta and intended untracked files preserved;
- preservation bundle hashes unchanged;
- parked patch unchanged and unapplied.

If either worktree has unrelated tracked changes or the frozen Onboarding
preservation state differs, STOP AND REPORT.

---

# 2. Review the generic registry as an authority primitive

Inspect the actual implementation of `ExclusiveAuthorityRegistry`.

Confirm that its responsibility is exactly:

- one live tenure per typed authority key;
- opaque occurrence-unique tenure creation;
- exact-current proof;
- explicit re-entry with that exact tenure;
- exact-scope release;
- stale/released/wrong-key/wrong-registry/disposed rejection;
- bounded non-authoritative diagnostics.

It must not contain:

- archive operation policy;
- checkpoint policy;
- database/resource policy;
- Onboarding state;
- retry/wait/timeout policy;
- presentation semantics;
- FDA/Contacts/recovery semantics.

Report any domain policy that leaked into the generic layer.

---

# 3. Review the typed key boundary

Inspect `ExclusiveAuthorityKey`.

Confirm:

- production has exactly one current key: `archiveMutation`;
- arbitrary callers cannot construct a new production key;
- no string-based key factory exists;
- diagnostic names do not participate in proof;
- the test-only second key cannot leak into ordinary production use.

Pay particular attention to how the `@visibleForTesting` second key is exposed.
Confirm that production code cannot accidentally adopt it merely because Dart
visibility is advisory.

If the architecture test relies only on naming/comment convention to prevent
production use of that key, classify whether this is sufficient or a SHOULD FIX.

---

# 4. Review Tenure opacity and proof identity

Inspect `ExclusiveAuthorityTenure`.

Confirm:

- ordinary callers cannot construct one;
- proof does not depend on visible occurrence number, timestamp, label, or value
  equality;
- no public/private-field combination permits reconstruction of proof;
- no serialization or copy/revival path exists;
- tenure from another registry/container fails;
- released tenure stays dead forever;
- registry reconstruction cannot revive an old tenure even if diagnostic
  occurrence counters repeat.

Check equality/hash behavior explicitly.

There must be no path by which:

```text
same key + same visible occurrence + same label
```

can become equivalent to:

```text
same live Ball
```

---

# 5. Review acquisition mechanical impossibility

Trace `runExclusive`.

Confirm:

1. free/held determination occurs before the admitted action starts;
2. a free key receives one new tenure;
3. a foreign claimant cannot begin protected work;
4. denial does not consume a new occurrence;
5. the admitted action receives the exact tenure that the registry records as
   current;
6. the registry cannot report a second live tenure for the same key.

This is the central mechanical invariant:

> **If you are not holding the Ball, you cannot enter the protected track.**

There must be no check-then-await gap between deciding the key is free and
establishing current tenure.

---

# 6. Review explicit re-entry

Trace `runReentrant`.

Confirm:

- exact current tenure is required;
- re-entry does not create Ball 2;
- hold/scope count increases under the same tenure;
- wrong/stale/foreign tenure is denied before nested action starts;
- nested scope release cannot release the outer scope;
- outer scope release cannot invalidate a still-live explicitly admitted
  re-entrant scope;
- final scope release kills the tenure exactly once.

Pay special attention to the reported test:

> outer completion with an active explicitly re-entrant child preserves the
> Ball until the last scope completes.

Inspect the implementation mechanics behind that claim.

Ensure this does not rely on an unsafe unawaited-Future pattern where authority
outlives the intended structural lifetime accidentally.

If explicit re-entrant child tenure may intentionally outlive the outer action,
the code must make that lifetime mechanically deliberate and correctly counted.

---

# 7. Review release/finally semantics

Inspect all cleanup paths.

Confirm:

- outer success releases exactly its scope;
- outer failure releases exactly its scope and preserves the original failure;
- re-entrant success/failure releases only the nested scope;
- stale/double internal release cannot decrement or clear newer tenure;
- final release makes old proof immediately invalid;
- denied callers cannot influence hold count or release;
- registry disposal revokes live tenures without allowing later scope cleanup to
  corrupt a reconstructed/new registry.

Look for any release logic based on counters alone rather than exact scope
identity.

---

# 8. Review registry/provider lifecycle

Inspect Riverpod/provider ownership.

Confirm:

- registry is keep-alive for the intended provider-container lifetime;
- provider rebuild/disposal semantics cannot create two registries claiming the
  same process-local authority simultaneously;
- disposal invalidates all tenure from that registry;
- stale async callbacks into the disposed registry fail closed;
- tests using multiple containers prove registry identity separation rather than
  accidentally sharing global/static authority.

There should be no global mutable singleton outside the intended provider
lifecycle.

---

# 9. Review diagnostics as non-authority

Inspect the diagnostic state/read model.

Confirm diagnostics expose only bounded information such as:

- key;
- occupied/free;
- occurrence number;
- owner label;
- timestamps;
- hold count;
- denial/release metadata.

Confirm diagnostics do **not** expose:

- tenure object;
- private registry identity;
- private tenure identity;
- scope identity;
- serializable proof;
- a method that converts diagnostics back into tenure.

Search production code for consumers of diagnostic occurrence, label, or
`isHeld`.

No such consumer may use diagnostics to authorize protected work.

---

# 10. Review exception semantics

Inspect generic denial/proof exceptions.

Confirm:

- foreign/busy acquisition is distinguishable from invalid proof;
- exception payloads contain no secret proof material;
- owner labels are diagnostics only;
- exceptions do not reveal private identity;
- archive adapter translates generic admission/proof failures appropriately
  without exposing generic policy to established archive callers.

Do not require elaborate exception hierarchy beyond what actual callers need.

---

# 11. Review ArchiveMutationCoordinator adaptation

Inspect the complete adapter diff.

Confirm the extraction removed only generic live-tenure mechanics.

`ArchiveMutationCoordinator` must still own:

- `ArchiveMutationOperation`;
- checkpoint requirements;
- archive environment/instance diagnostics;
- operation-strength aggregation;
- archive nested scopes;
- `ArchiveMutationResourceAction`;
- graph/database reopen policy;
- resource admission;
- private archive Zone;
- `ArchiveMutationCapability`.

There must not now be two competing sources of truth for archive occupancy.

The archive active-scope map may remain for archive-domain scope/policy, but
must not independently decide whether some new foreign owner gets the track.

That decision belongs only to the generic registry.

---

# 12. Review private Zone propagation

Inspect the archive Zone integration.

Confirm:

- the Zone remains private to `ArchiveMutationCoordinator`;
- the Zone carries the exact current generic tenure plus archive-specific scope/
  operation context;
- same-owner descendants re-enter by presenting the exact tenure to the generic
  registry;
- foreign code cannot forge or discover the Zone context;
- provider construction still observes intended requesting lineage;
- generic registry does not inspect the archive Zone;
- there is no public ambient `currentBall` path.

Explicit delegation must remain the generic rule; private Zone translation is an
archive-domain adapter detail.

---

# 13. Review ArchiveMutationCapability grounding

Trace capability construction and validation.

Confirm a capability proves both:

```text
generic registry:
    exact current Archive Mutation tenure

AND

archive coordinator:
    exact active archive scope
    exact ArchiveMutationOperation
    current private Zone lineage
    coordinator lifecycle
```

A capability must fail after:

- archive scope release;
- final generic tenure release;
- coordinator disposal;
- stale callback after later reacquisition;
- wrong operation;
- wrong Zone lineage.

Generic tenure alone must not grant archive resource access.

---

# 14. Review stale-callback and reacquisition behavior

Trace this concrete sequence in source and tests:

```text
Ball 1 acquired
-> archive capability 1 issued
-> all Ball 1 scopes released
-> Ball 2 acquired for same key / same diagnostic owner label if desired
-> stale callback retains Ball/capability 1
-> stale callback attempts proof/resource use/release
```

Confirm mechanically:

- Ball 1 is denied;
- capability 1 is denied;
- Ball 2 remains live and unchanged;
- hold count for Ball 2 is unchanged;
- stale cleanup cannot clear Ball 2.

This is one of the most important reasons Feature 35 exists.

---

# 15. Review concurrency assumptions honestly

The registry is process/isolate-local and intentionally has no queue.

Confirm source and tests do not imply unsupported semantics such as:

- cross-isolate tenure;
- cross-process tenure;
- FIFO fairness;
- starvation prevention;
- timeout;
- pre-emption;
- forced cancellation;
- durable/persisted authority.

Check comments and API names for claims broader than the implementation.

---

# 16. Review the architecture tripwire

Inspect `test/architecture/exclusive_authority_architecture_test.dart`.

Confirm it mechanically enforces the intended rules rather than merely checking
today's filenames.

At minimum verify proof for:

- generic layer domain ignorance;
- private tenure construction;
- closed typed production keys;
- no serialization;
- no public release;
- no ambient current-tenure lookup;
- archive mutation as sole production adopter/key;
- diagnostics not proof;
- labels/occurrence not proof;
- no presentation/workflow use of tenure;
- native single-instance authority separation.

Check whether the test-only second key can accidentally become a second
production key without the architecture test noticing.

Report any important rule represented only by comment/naming convention rather
than a mechanical test.

---

# 17. Review the tests as proof, not just green counts

Inspect the generic 21-case suite and archive regression tests.

Confirm the tests actually reach their claimed boundaries.

Pay particular attention to:

- foreign denial before action start;
- same-tenure re-entry;
- child outliving outer scope;
- stale Ball 1 while Ball 2 is live;
- stale internal release;
- foreign registry;
- disposal;
- equal labels;
- detached callbacks;
- exact archive capability invalidation.

Concurrency/currentness proof should use deterministic barriers/completers, not
sleep timing.

Report any test whose setup bypasses the real mechanism it claims to prove.

---

# 18. Diff-shape and scope sanity

Inspect the complete Feature 35 diff for:

- duplicate tenure logic left in archive coordinator;
- unnecessary generic framework machinery;
- speculative second adopters;
- broad convenience barrels;
- public APIs wider than the audit approved;
- unrelated generated churn;
- unrelated archive refactors;
- Onboarding changes;
- Environment Readiness/presentation changes;
- schema/persisted-format/native changes;
- privacy or data-safety changes.

This is not an invitation to aesthetic cleanup.

Report only concrete architecture/scope findings.

---

# 19. Validation scope

Prompt 02 already reports:

- primitive suite: 21 passed;
- archive coordinator: 16 passed;
- resource admission + Feature 35 architecture: 18 passed;
- architecture suite: 497 passed;
- focused downstream archive consumers: 98 passed;
- analyzer: clean;
- full Flutter suite: 2,639 passed / 1 intentional skip;
- generation: clean;
- `git diff --check`: passed;
- Project Conformance: PASS.

Do not rerun the full suite merely for ceremony.

Run only narrow tests if source inspection exposes a specific unresolved
question.

---

# 20. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/03-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`

Report:

1. baseline/isolation verdict;
2. generic registry responsibility verdict;
3. typed-key verdict;
4. tenure opacity/proof verdict;
5. acquisition verdict;
6. re-entry/hold-lifetime verdict;
7. release/finally verdict;
8. provider-lifecycle verdict;
9. diagnostics verdict;
10. exception verdict;
11. archive-adapter ownership verdict;
12. private-Zone verdict;
13. archive-capability verdict;
14. stale-callback/reacquisition verdict;
15. concurrency-semantics verdict;
16. architecture-tripwire verdict;
17. test-quality verdict;
18. diff/scope verdict;
19. concrete BLOCKER findings;
20. concrete SHOULD FIX findings;
21. OPTIONAL findings;
22. narrow tests rerun, if any;
23. exact Feature 35 Git status;
24. frozen Onboarding verification;
25. checkpoint recommendation.

Use the established severity vocabulary:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`FEATURE 35 HUMAN ARCHITECTURAL REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO CHECKPOINT FEATURE 35 EXCLUSIVE AUTHORITY TENURE: YES / NO`

Then STOP.
