# MessageLens Feature 34
## 62 — Forensic Audit the Real Attachment-Coverage Deficit and Design Attachment Archive Repair

Response 61 did not reach Operating Session Stage Two.

That is **not** evidence that Stage Two failed.

Fresh AppCzar correctly reconstructed a separate durable prerequisite failure:

```text
Messages source          readable/stable
source messages          138,956
local import             138,935
local graph              138,935
archive root             available
required attachment coverage
                         incomplete
uncovered required       13,841
new source messages      21
```

Fresh AppCzar therefore refused Operating and selected the still-virtual
Attachment Archive Repair disposition.

This is exactly the Fair-Witness behavior Prompt 59 was intended to create.

The new task is **not** to start copying 13,841 attachments.

First determine what those 13,841 uncovered requirements actually mean.

Important distinction:

> `uncovered` means the current graph requires durable archive coverage for an
> attachment identity and the current archive evidence does not prove that
> coverage.

It does **not** by itself mean:

- the payload is physically missing;
- the source payload is unavailable;
- the archive file was deleted;
- the attachment is lost;
- 13,841 copies are required.

Some may already exist physically but lack durable object records. Some may
still be available from the Messages source. Some may reflect an older archive
contract. Some may expose a defect in the new required-set definition. The
audit must distinguish these possibilities from current facts.

This task is primarily **read-only forensic analysis plus repair design**.

Do NOT implement Attachment Archive Repair yet unless the audit proves a tiny,
mechanically safe correction to the coverage definition itself.

Do NOT mutate the real archive.
Do NOT copy, delete, rename, move, or hash real payload bytes.
Do NOT create missing archive records.
Do NOT start Data Update manually.
Do NOT weaken the AppCzar coverage gate.
Do NOT change the unstaged Stage Two implementation.
Do NOT stage, commit, push, merge, or rebase.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Expected:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`
- Prompt 60 Stage Two implementation present and unstaged;
- index empty;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- no MessageLens Development process running;
- development launch environment unset;
- development FDA entry left enabled by the human after Prompt 61.

Read:

- Response 58;
- Response 59;
- Response 60;
- Response 61;
- attachment archive service/adoption/relocation code;
- `ReadOnlyAppCzarAttachmentCoverageProbe`;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

Before any forensic query, verify the Prompt 60 tracked diff hash/inventory has
not changed since Response 60.

---

# 2. Protect the unstaged Stage Two implementation

Prompt 60 is pending human qualification and must remain byte-for-byte intact.

Record:

- every tracked Stage Two modified path;
- every new Stage Two source/test/generated path;
- tracked diff SHA-256;
- complete porcelain inventory.

During Prompt 62:

- do not edit any Stage Two path;
- do not run broad generation that rewrites Stage Two files unless necessary for
  read-only audit validation;
- if any Stage Two file changes, STOP AND REPORT.

---

# 3. Reproduce the 13,841 coverage deficit read-only

Using the same production-shaped read-only probe and exact admitted development
archive identity, reproduce the current coverage observation against the real
development data.

The audit may read:

- development graph/import/overlay SQLite stores;
- current archive metadata/object records;
- archive filesystem metadata;
- live `chat.db` attachment metadata where current Full Disk Access permits it.

It may **not** read attachment payload bytes unless a later section explicitly
requires a tiny bounded sample and the human separately authorizes that.

Do not hash real archive payloads.

Report the exact current counts:

```text
required
covered
missing
unverifiable
coverage condition
archive scope identity
archive generation
```

If the number differs from 13,841 because ordinary source data changed, report
the current number. Do not force it back to 13,841.

---

# 4. Partition the uncovered set by factual reason

For every uncovered required compatibility key, classify it into a mutually
exclusive current-evidence bucket where possible.

At minimum distinguish:

1. **No durable `archived_attachments` record**
2. **Durable record exists but referenced archive file is absent**
3. **Durable record exists but current file size disagrees**
4. **Durable record exists but path is unsafe/unverifiable**
5. **Conflicting duplicate durable records**
6. **Archive scope/generation mismatch**
7. **Required graph identity is itself ambiguous**
8. **Other / currently unclassifiable**

Produce counts for every bucket.

Do not collapse all 13,841 into `missing`.

---

# 5. For the "no durable record" population, determine physical reality

This is likely the dominant category, but do not assume.

For uncovered keys with no durable object record, perform a bounded metadata-only
forensic search to determine whether an apparently corresponding payload may
already exist in the current archive outside the `archived_attachments` index.

Use existing archive layout/naming conventions only.

Do not recursively scan/hash 39 GB blindly.

Prefer:

- existing manifests/indexes;
- deterministic path derivation if one exists;
- bounded filesystem metadata lookup;
- archive-relative naming conventions already encoded in production code.

Classify the no-record population into:

```text
A. no record; matching physical archive candidate exists
B. no record; no matching archive candidate found
C. no record; physical correspondence cannot be established safely
```

If the archive layout does not permit deterministic correspondence without
payload inspection, say so.

A physical candidate does **not** count as coverage unless the current durable
contract can prove identity. This audit is diagnostic only.

---

# 6. Determine whether source payloads are still currently available

For the uncovered required set, use only current source metadata/path
observations to determine whether the original live Messages attachment payload
is presently available.

Do not copy it.

Classify uncovered requirements as:

```text
source payload currently available
source payload currently absent
source payload path present but unreadable/unverifiable
source evidence unavailable/unknown
```

Report counts.

This matters because repair may be:

- metadata reconciliation only;
- fresh preservation from source;
- impossible automatically from current source;
- diagnostic/manual recovery.

Do not infer that absence from the current Messages source means permanent loss.

---

# 7. Partition by graph/source age and provenance

Determine whether the deficit is concentrated in a historical range.

For uncovered requirements, report distributions using privacy-safe aggregates:

- message source ROWID range;
- attachment ROWID range;
- message year/month buckets;
- whether the graph row predates the archive-preservation feature or known
  attachment-archive activation;
- whether the attachment was imported before/after the current archive adoption
  or relocation milestones, if this is reconstructible from durable facts.

Do not expose contact names, message text, or private filenames.

The purpose is to answer:

> Are these 13,841 mostly old attachments that were never entered into the
> durable archive-record system, or are current preservation operations failing
> broadly?

---

# 8. Audit whether the Prompt 59 required universe is too broad

This is a critical possibility.

Re-read the exact preservation contract and compare it to the whole-graph
coverage query.

Ask:

- Does the automatic archive contract truly require **every** conventional live
  attachment relationship in the current graph to have durable archive coverage?
- Or does it require coverage only for attachments after a particular policy
  activation/adoption boundary?
- Did the pre-existing attachment archive intentionally contain only a subset?
- Are there attachment classes that are valid graph attachments but were never
  intended to be archived?
- Does `attachment_archive_enabled` have historical policy semantics that the
  current whole-graph query is ignoring?
- Are source rows that predate archive activation nonetheless preservation-
  required under the product contract?

Do not weaken the query simply because the count is large.

But if source proves the required-universe definition in Prompt 59 overstates
the actual preservation contract, that is a BLOCKER in Prompt 59 and must be
reported before any repair design.

The repair must fix the definition, not manufacture records for non-required
objects.

---

# 9. Audit existing archive record coverage statistics

Produce privacy-safe totals for:

- total current graph attachment relationships;
- total conventional live required relationships;
- total durable `archived_attachments` records;
- total required keys with records;
- total records not currently required by the graph;
- total orphan archive records if determinable;
- total physical archive files represented by records;
- duplicate compatibility keys, if any.

This gives context for whether 13,841 is "almost everything", "a historical
tail", or "a narrow mismatch".

---

# 10. Determine exact repair classes

From current evidence, derive repair classes.

Examples:

## Class 1 — already physically preserved, durable record missing

Potential repair:

```text
verify physical candidate against current source/object identity
-> write factual durable object record
```

Only valid if identity can be proven without guesswork.

## Class 2 — source payload currently available, archive payload absent

Potential repair:

```text
copy with existing preservation writer
-> verify
-> atomic install
-> durable object record
```

## Class 3 — durable record exists, archive payload missing/wrong

Potential repair:

```text
re-preserve from current source if available
```

## Class 4 — source payload unavailable and archive identity not provable

Potential repair:

```text
manual/historical archive recovery
or bounded diagnostic state
```

## Class 5 — false requirement caused by coverage-contract error

Potential repair:

```text
correct the factual required-set definition
```

Do not assume these exact classes; derive the actual set from source.

---

# 11. Design Attachment Archive Repair as a bounded coordinator

Without implementing it, define the next coordinator's jurisdiction.

Selection:

```text
attachmentCoverageComplete == FALSE
```

only when current AppCzar evidence conclusively proves incomplete coverage.

UNKNOWN remains Diagnostic Review.

The coordinator may:

- recompute the current uncovered set;
- partition by repair class;
- automatically repair only classes with provable current identity and a safe
  existing writer;
- present human action for non-automatic classes;
- use the existing archive mutation Ball/capability for writes;
- publish factual current progress;
- end at a real process restart.

It may NOT:

- treat a remembered previous deficit count as current;
- clear a global failure flag;
- fabricate object identity;
- infer a physical archive file belongs to a graph attachment from filename
  similarity alone;
- chain to Data Update or Operating in-process.

After repair:

```text
restart
-> fresh AppCzar
-> fresh coverage observation
```

Fresh facts determine whether Operating can be admitted.

---

# 12. Decide whether repair should be one coordinator or sub-operations

The deficit may contain multiple factual repair classes.

Recommend whether `Attachment Archive Repair` should internally own typed
sub-operations such as:

```text
reconcile existing physical payload evidence
preserve available source payloads
report unrecoverable/unverifiable requirements
```

These may be worker steps inside one coordinator.

Do not create separate top-level coordinators unless the source-grounded audit
proves separate jurisdictions are necessary.

---

# 13. Progress semantics

Design only factual progress, for example:

```text
Checking attachment coverage…
13,841 required payloads need attention

Already present, verifying identity    N
Available from Messages                N
Source payload unavailable             N
Unverifiable                           N

Preserving                             X / Y
Verifying coverage                     ...
```

Do not say:

- repairing archive successfully;
- all attachments safe;
- recovery complete;

until current evidence literally proves those statements.

The final coordinator success condition is **not** its own worker result.

It is:

```text
bounded repair work finished
-> restart
-> fresh AppCzar coverage TRUE
```

---

# 14. Mutation authority and concurrency

Any real repair will use existing archive mutation authority.

Design:

```text
Attachment Archive Repair
-> one admitted repair occurrence
-> one typed archive-mutation tenure/capability at a time
-> existing payload-preservation writer
-> object record commit
```

No direct filesystem write outside the established archive service.

No metadata-only reconciliation record may be written unless current object
identity and payload evidence are proven.

Do not implement in Prompt 62.

---

# 15. Performance and batching design

13,841 potential requirements is large enough to require bounded work.

Recommend:

- keyset/bounded batches;
- no whole-payload memory accumulation;
- bounded metadata queries;
- bounded filesystem checks;
- bounded progress publication;
- cancellation/quit drain behavior.

Do not reintroduce durable semantic "resume state" merely to optimize a rare
repair.

If repair is interrupted, the next fresh coordinator should recompute the
remaining uncovered set from reality.

Object-level archive records already committed remain facts.

This gives natural resumability without a Journey cursor.

---

# 16. Human intervention design

For any class not automatically repairable, specify the exact human-facing
evidence and action.

Examples might include:

- reconnect a historical volume;
- locate an old archive root;
- permit access to a source path;
- accept that some payload cannot currently be recovered.

Do not design destructive "ignore missing" controls in this task.

If product policy may eventually allow explicitly excluding an unrecoverable
attachment from the preservation contract, treat that as a separate user-authored
fact/policy decision requiring its own design review.

---

# 17. FDA toggle anomaly

Prompt 61 again observed the development FDA toggle changing from human-visible
ON before launch to OFF after launch.

Do not let this derail the attachment audit.

Record it as a separate unresolved environment/tooling issue.

Source Access Repair handled the resulting source-readability failure correctly.

Unless the audit finds it causally relevant to attachment coverage, do not
investigate it in Prompt 62.

---

# 18. No real mutation

This prompt must remain read-only on real data.

Allowed:

- SELECT/query-only database access;
- filesystem metadata/stat/lstat;
- path existence/type checks;
- privacy-safe aggregate counts;
- bounded metadata comparisons.

Forbidden:

- copy;
- move;
- delete;
- rename;
- chmod/chown;
- payload hash reads on real archive unless separately authorized;
- insert/update/delete in real stores;
- attachment repair execution.

Use temp fixtures for any test requiring mutation.

---

# 19. Tests / validation for audit utilities only

If small read-only forensic utilities/tests are needed, keep them isolated and
do not alter production semantics.

Prefer existing production readers/probes.

If no code changes are required, do not create code merely to generate the
report.

Run only the validation appropriate to any actual code changes.

Prompt 60 Stage Two implementation must remain unchanged.

---

# 20. Project Conformance classification

This is an audit/design task, not an implementation milestone.

Report:

- whether Prompt 59 coverage definition is valid as written;
- whether the 13,841 deficit is a real coverage deficit;
- whether it is repairable automatically in whole or in part;
- whether any BLOCKER exists before implementing Attachment Archive Repair;
- whether Stage Two can remain pending unchanged.

Do not claim `PROJECT CONFORMANCE: PASS` for a repair that has not been
implemented.

---

# 21. Required response

Create Response 62 and report:

1. baseline verification;
2. proof Prompt 60 Stage Two tree remained unchanged;
3. exact current coverage counts;
4. uncovered-set reason partition;
5. no-record physical-candidate partition;
6. current source-payload availability partition;
7. temporal/source-range distribution;
8. audit of whether Prompt 59 required universe is valid;
9. current archive-record statistics;
10. exact meaning of the 13,841 deficit;
11. automatic repair classes;
12. manual/unverifiable repair classes;
13. whether any uncovered requirements appear physically already preserved;
14. whether any uncovered requirements are no longer available from current
    source;
15. Attachment Archive Repair selection contract;
16. proposed bounded coordinator jurisdiction;
17. proposed internal repair sub-operations;
18. final-success/restart semantics;
19. mutation-authority design;
20. batching/performance design;
21. interruption/natural-resume design;
22. human-intervention requirements;
23. FDA-toggle anomaly disposition;
24. privacy/read-only audit confirmation;
25. any code/test changes made solely for audit;
26. validation results, if code changed;
27. BLOCKER findings;
28. SHOULD FIX findings;
29. exact Git/worktree/index/submodule state;
30. readiness to implement Attachment Archive Repair;
31. readiness to rerun Prompt 61 after repair.

Conclude exactly:

`PROMPT 59 REQUIRED ATTACHMENT UNIVERSE VALID: YES / NO / NEEDS CORRECTION`

`REAL ATTACHMENT COVERAGE DEFICIT CONFIRMED: YES / NO / PARTIAL`

`DEFICIT AUTOMATICALLY REPAIRABLE IN WHOLE: YES / NO / UNKNOWN`

`ATTACHMENT ARCHIVE REPAIR DESIGN READY: YES / NO`

`OPERATING STAGE TWO TREE REMAINS INTACT: YES / NO`

`READY TO IMPLEMENT ATTACHMENT ARCHIVE REPAIR: YES / NO`

Then STOP.
