Here is **Prompt 98**, ready to copy into your Feature 34 prompts folder.

Save it as:

`98-CHECKPOINT-ATTACHMENTS-EXTRACTION-AND-AUDIT-CANONICAL-RELATIONSHIP-SOURCE-PROJECTIONS.md`

This is deliberately **audit-only**. The purpose is to establish the actual relationship-import architecture before deciding what can safely be extracted.

---

# MessageLens — Feature 34
## Prompt 98 — Checkpoint Attachments Extraction and Audit Canonical Relationship Source Projections

### Milestone

Read-only architectural audit of source-scoped relationship importers, following the five qualified canonical source-projection extractions.

### Governing status

The following canonical source projections have been extracted, characterized against their actual production writers, validated, committed, and pushed:

1. Contacts — Response 93
2. Messages — Response 94
3. Handles — Response 95
4. Chats — Response 96
5. Attachments — Response 97

The next potential extraction concerns the relationships connecting these records.

**A complete populated import/Conversation Graph/FTS reconstruction-equivalence witness does not exist.**

Consequently:

- Destructive Operating-owned Start Fresh remains **BLOCKED**.
- Production AppCzar activation remains **OFF**.
- Stage 2C and production-cutover work remain unauthorized.

This prompt must not attempt to lift those restrictions.

### Governing principle

> A relationship is reconstructible only when its identity, both endpoints, source provenance, omission behavior, and persistence semantics can be reproduced from current authoritative evidence using the same canonical transformations as the production importer.

Do not assume that a relationship is pure merely because its persisted representation contains two identifiers.

---

## 1. Preflight and Git baseline

Work only in:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- Branch: `fix/onboarding-import-stuck-state`
- HEAD/upstream synchronized (`0 ahead / 0 behind`)
- Tracked working tree clean
- Index clean
- Shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`
- Exactly one worktree on the Feature 34 branch
- All unrelated untracked files preserved

Verify that the following implementation checkpoints are ancestors of HEAD:

```text
a36feac8a48d1702aad5830076157830d6efb975
    Contacts projection

d77d08c6c55e18ade47983fb959b8023c893283c
    Messages projection

ae6aa6496e9dd98378c61be1aa7d7984d7207f4c
    Handles projection

10732e2986c5e40f7d097f35e2d12daff663fc4f
    Chats projection

417a7ef1b24b12991649edc978bd3d0326a6720a
    Attachments projection
```

Determine whether Prompt 97 and Response 97 have already been committed and pushed together.

If they have, verify their documentation checkpoint without duplicating it.

If they have not, create **only** the narrow Prompt 97/Response 97 documentation checkpoint and push normally before continuing.

Do not stage unrelated files.

Record the resulting baseline HEAD and upstream relationship.

---

## 2. Read governing documentation

Read the applicable global project instructions and canonical Project Conformance standard.

Read:

- Response 91 — Stage 2C implementation stop
- Response 92 — reconstruction-equivalence audit
- Responses 93–97 — canonical source-projection extractions
- Current source-scoped import architecture
- Current relationship importers and their tests
- Current import database schema
- Current Conversation Graph projection boundaries
- Existing source identity and canonical key utilities

Use the current implementation as the authority for actual behavior.

Earlier documentation may establish intent but must not override contradictory current source evidence.

---

## 3. Audit scope

Identify every production relationship-import path connecting the source-scoped records.

At minimum investigate:

```text
chat ↔ message
chat ↔ handle
message ↔ attachment
```

Also identify any additional relationship table or importer currently participating in source-scoped import.

For each relationship family, establish:

1. Source query and selected columns.
2. Query ordering and paging behavior.
3. Source relationship identity.
4. Source registry and source ID binding.
5. Endpoint identity construction.
6. Endpoint lookup or resolution requirements.
7. Missing-endpoint behavior.
8. Duplicate relationship behavior.
9. Transaction boundaries.
10. Batch allocation and lineage.
11. Persisted table and column inventory.
12. Insert, ignore, update, or conflict policy.
13. Progress reporting.
14. Anomaly and omission accounting.
15. Error propagation and rollback behavior.
16. Source closure and cleanup.
17. Current test coverage.

Do not infer these behaviors from schema names alone.

Trace the actual production execution paths.

---

## 4. Distinguish source facts from derived relationships

For each relationship, determine whether its endpoints originate from:

- Raw source database identifiers.
- Deterministic source-scoped packed identities.
- Existing import-ledger lookups.
- Canonicalized handle identities.
- Conversation Graph identities.
- Previously persisted relationship rows.
- Other stateful resolution mechanisms.

Identify the exact authority for each transformation.

A source-scoped relationship must not silently become a graph-level relationship during extraction.

Preserve the distinction between:

```text
source relationship
```

and:

```text
derived Conversation Graph relationship
```

---

## 5. Classify transformation purity

For each relationship importer, divide its behavior into three categories.

### A. Pure deterministic transformation

Operations that depend only on explicit source facts and existing canonical pure utilities.

Potential examples include:

- Source-scoped identity packing.
- Deterministic endpoint ID construction.
- Existing scalar conversions.
- Construction of the persisted relationship row.

These are candidates for extraction.

### B. Stateful resolution

Operations requiring current database or importer state.

Potential examples include:

- Endpoint existence checks.
- Source-registry lookup.
- Association resolution.
- Existing-row reconciliation.
- Missing-endpoint recovery.

These must remain with the current owner unless a separate architectural decision authorizes their relocation.

### C. Mutation and lifecycle

Operations involving:

- Source I/O.
- Database transactions.
- Ledger inserts.
- Duplicate suppression.
- Batch creation.
- Progress publication.
- Error handling.
- Worker lifecycle.

These remain importer-owned.

Do not classify an operation as pure merely because it can be rewritten as a helper function.

---

## 6. Source-grounded reconstruction analysis

For each relationship family, answer:

**Can the current authoritative source reproduce the exact relationship that the production importer persisted?**

Consider:

- Both endpoints still existing.
- One endpoint having disappeared.
- Source relationships removed since the original import.
- Historical/non-live source provenance.
- Duplicate source relationships.
- Missing or malformed endpoint identities.
- Orphaned imported records.
- Differences between source-row identity and graph identity.
- Changes in canonical handle interpretation.

Distinguish:

```text
relationship originally imported from live source
```

from:

```text
relationship demonstrably reconstructible
from current live source now
```

The former does not establish the latter.

Do not implement a reconstruction witness in this audit.

---

## 7. Characterization feasibility

For each relationship importer, determine whether the actual production writer can be exercised using:

- A synthetic `ReadOnlySourceDatabase`.
- A disposable source-scoped `ImportDatabase`.
- Existing fixture APIs.
- Existing canonical identity utilities.

Identify the smallest fixture that would characterize:

- Complete persisted relationship rows.
- Endpoint identities.
- Duplicate handling.
- Missing endpoints.
- Anomalous source records.
- Transaction rollback.
- Progress events.
- Incremental reruns.
- Source lifecycle.

Determine whether existing tests already provide part of this evidence.

Do not create or modify tests during Prompt 98.

---

## 8. Architecture risks

Investigate whether extraction could accidentally:

- Introduce a second endpoint-resolution authority.
- Duplicate packed-ID logic.
- Change missing-endpoint policy.
- Change relationship uniqueness.
- Move database lookups into a supposedly pure function.
- Change transaction boundaries.
- Alter importer ordering or paging.
- Change anomaly accounting.
- Alter graph canonicalization.
- Affect historical-source provenance.
- Change attachment coverage or archive-repair evidence.
- Introduce unbounded relationship scans.
- Change the seven AppCzar jurisdictions.
- Broaden mutation authority.

For each identified risk, propose a specific mechanical test or architecture assertion.

---

## 9. Recommend the next extraction

Using the audit findings, select **one** narrowly bounded relationship-transformation family for Prompt 99.

Prefer the candidate with:

- Clear deterministic row formation.
- Minimal stateful endpoint resolution.
- Existing canonical identity utilities.
- An actual-writer characterization seam.
- Small production source scope.
- Strong existing regression coverage.
- Low risk of changing graph semantics.

Do not automatically select the simplest-looking schema.

Explain why the chosen family is the safest first extraction.

Also provide a recommended dependency order for the remaining relationship families.

---

## 10. Required Prompt 99 design

Produce a concrete implementation design for the selected relationship family.

Specify:

1. Exact production files permitted to change.
2. Proposed pure projection module.
3. Typed input and output contract.
4. Existing canonical utilities to reuse.
5. Stateful operations that remain importer-owned.
6. Pre-extraction actual-writer characterization.
7. Frozen persisted-row expectations.
8. Anomaly and omission parity requirements.
9. Transaction and progress parity requirements.
10. Direct projection tests.
11. AST/dependency architecture enforcement.
12. Required regression suites.
13. Project Conformance requirements.
14. Git checkpoint sequence.
15. Stop gates.

Do not implement Prompt 99 during this task.

---

## 11. Hard exclusions

Prompt 98 is an **audit and design task only**.

Do not:

- Modify production source.
- Modify tests.
- Modify generated files.
- Change schemas or migrations.
- Extract any projection.
- Implement a reconstruction witness.
- Change source readers.
- Modify graph projectors.
- Change FTS.
- Modify rich-text enrichment.
- Change attachment payload/archive handling.
- Change AppCzar.
- Change Start Fresh.
- Change production composition.
- Build, install, or launch MessageLens.
- Access real Messages or Contacts databases.
- Access real MessageLens databases.
- Inspect or modify real attachment archives.
- Access the WD development archive or Toshiba archive.
- Change macOS permissions, bookmarks, or environment settings.

The only authorized repository mutation is the narrow Prompt 97/Response 97 documentation checkpoint if it is still required, followed by creation of an untracked Response 98.

A source-only external baseline manifest is permitted.

---

## 12. Validation and conformance

Because this is audit-only, do not run the full Flutter test suite or analyzer merely to repeat already-qualified evidence.

Validate the audit through:

- Actual source inspection.
- Schema inspection.
- Importer call-graph reconstruction.
- Existing test inspection.
- Git ancestry and status verification.
- Source dependency analysis.
- Explicit comparison against Responses 92–97.

Run the canonical Project Conformance audit for the proposed architecture.

Report:

```text
PROJECT CONFORMANCE: PASS / FAIL

BLOCKER: <count>

SHOULD FIX: <count>
```

A design PASS means the proposed extraction is architecturally feasible.

It does not mean the extraction has been implemented or tested.

---

## 13. Required Response 98

Create:

`98-CHECKPOINT-ATTACHMENTS-EXTRACTION-AND-AUDIT-CANONICAL-RELATIONSHIP-SOURCE-PROJECTIONS.md`

in the Feature 34 `01-ONBOARDING/responses/` directory.

Report:

1. Baseline branch, HEAD, upstream, index, worktree, and submodule.
2. Prompt 97/Response 97 documentation checkpoint.
3. Exact relationship importer inventory.
4. Source SQL and ordering for each family.
5. Source identity and endpoint identity construction.
6. Complete persisted relationship schema inventories.
7. Stateful endpoint lookup and resolution ownership.
8. Duplicate and missing-endpoint behavior.
9. Transaction and batch behavior.
10. Progress and anomaly behavior.
11. Error and rollback behavior.
12. Source closure behavior.
13. Source-scoped versus graph relationship distinction.
14. Pure transformation candidates.
15. Non-pure stateful dependencies.
16. Current reconstructibility limitations.
17. Actual-writer characterization feasibility.
18. Existing regression coverage.
19. Architecture risks and proposed enforcement.
20. Recommended first extraction.
21. Recommended remaining extraction order.
22. Exact Prompt 99 implementation design.
23. Project Conformance verdict.
24. BLOCKER and SHOULD FIX findings.
25. Final Git and untracked-file state.
26. Readiness for Prompt 99.
27. Explicit continued prohibition of destructive Start Fresh and production activation.

Conclude exactly:

```text
ATTACHMENTS EXTRACTION CHECKPOINTED: YES / NO

RELATIONSHIP IMPORTER INVENTORY COMPLETE: YES / NO

SOURCE-SCOPED AND GRAPH RELATIONSHIP AUTHORITIES DISTINGUISHED: YES / NO

PURE RELATIONSHIP TRANSFORMATION CANDIDATES IDENTIFIED: YES / NO

STATEFUL ENDPOINT RESOLUTION REMAINS WITH EXISTING OWNERS: YES / NO

ACTUAL-WRITER CHARACTERIZATION FEASIBLE FOR SELECTED FAMILY: YES / NO

FIRST RELATIONSHIP EXTRACTION SELECTED: <family / NONE>

FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO

PROJECT CONFORMANCE: PASS / FAIL

READY FOR PROMPT 99 IMPLEMENTATION: YES / NO

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
```

Then **STOP**.

Do not begin the relationship extraction until Response 98 has been reviewed and a separate implementation prompt has been approved.

---

This preserves the approach that has worked across the previous five extractions: **establish the existing authority and observable behavior first, then extract only what can be proven equivalent.**