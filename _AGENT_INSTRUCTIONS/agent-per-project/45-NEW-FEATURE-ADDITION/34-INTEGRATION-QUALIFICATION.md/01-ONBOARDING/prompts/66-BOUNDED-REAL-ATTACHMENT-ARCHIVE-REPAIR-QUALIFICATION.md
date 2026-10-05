# MessageLens Feature 34
## 66 — Bounded Real Attachment Archive Repair Qualification

Response 65 successfully reconciled Operating Stage Two and Attachment Archive Repair into the primary worktree.

The combined development artifact is:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected identity:

- product: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- version/build: `0.2.136 (154)`
- executable SHA-256:
  `8a8c662910f533c5926a4fe27cbadf1d69fc14236e8733d59855163175498b8b`
- App.framework SHA-256:
  `11d546ce0b53a3f40f3ffce8683346b1446e5ef8e70ec980077a4d32426ad29d`

Both implementations are automated-test qualified but human-live qualification remains pending.

This task performs the **first bounded real qualification of Attachment Archive Repair**.

This is explicitly a two-stage human-gated experiment:

```text
Stage A
observe and classify real current evidence
NO archive mutation

human reviews exact current partition

Stage B
only after explicit human authorization
perform ONE bounded repair batch
then stop and reassess from fresh durable facts
```

Do NOT authorize the entire real deficit.
Do NOT repair all available attachments.
Do NOT weaken the coverage gate.
Do NOT modify source/test code during this qualification.
Do NOT launch production MessageLens.

---

# 1. Repository and artifact preflight

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch: `fix/onboarding-import-stuck-state`;
- clean tracked worktree/index;
- upstream ahead/behind `0/0`;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- only the expected unrelated untracked files remain;
- only one active Feature 34 development worktree.

Verify the exact development artifact hashes above.

If any artifact hash differs, STOP AND REPORT.

Do not rebuild before the first qualification launch. The first run must use the exact Response 65 artifact.

---

# 2. Human-visible environment preflight

Before launch, verify:

1. WD development-data volume is mounted:
   `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`
2. Toshiba active attachment archive is mounted:
   `/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive`
3. no `MessageLens Development` process is currently running;
4. the human-visible macOS Full Disk Access pane shows the exact development app enabled.

Because the development FDA toggle has changed unexpectedly in earlier qualifications, record its visible state before launch without treating the toggle itself as MessageLens evidence.

---

# 3. Set the exact development AppCzar launch contract

Run:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
```

Verify:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

returns exactly:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

This is development-root admission only.

---

# 4. Source-audit the real mutation confirmation boundary before launch

Before launching, inspect only the current source code to answer:

1. What exact human action authorizes real Attachment Archive Repair mutation?
2. What is the maximum number of attachment items one confirmation can admit?
3. Can one confirmation automatically chain multiple mutation batches?
4. Can the coordinator continue automatically through all currently available items after one confirmation?
5. Is there an item-count or byte-count bound visible before confirmation?
6. Can the qualification restrict the first real mutation to exactly one bounded batch?

Report the exact answer before any real mutation.

## Mandatory safety gate

The first human qualification may authorize **one bounded batch only**.

If one human confirmation can initiate an unbounded/full-population repair, or can automatically chain indefinitely through every currently available item, STOP before launch-time mutation and report the control design.

Do not alter code in this qualification prompt.

A fixed production batch of up to approximately 100 items is acceptable for the first qualification if that is the implemented bound.

---

# 5. Direct-launch the exact combined artifact

Launch:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record PID.

Allow fresh AppCzar to classify current reality.

Possible legitimate initial paths include:

```text
Source Access Repair
-> human restores source access
-> Check Again
-> real restart
-> fresh AppCzar

Data Update
-> bounded startup update
-> real restart
-> fresh AppCzar

Attachment Archive Repair
-> qualification target
```

Do not manually select or invoke a coordinator.

Continue only when fresh AppCzar independently selects Attachment Archive Repair for:

```text
archive available
AND attachment coverage FALSE
```

If archive unavailable or coverage UNKNOWN is shown instead, STOP and report the fresh evidence.

---

# 6. Stage A — observe repair without mutation

On first arrival at Attachment Archive Repair:

**DO NOT confirm repair yet.**

Allow its read-only current classification to settle.

Record every privacy-safe count actually shown, including where available:

```text
required payloads
covered
need attention

available from Messages
source currently absent
source evidence unavailable / unknown
record-backed recovery needed
unsafe / conflicting evidence
```

Also record:

- current PID;
- archive label/scope shown, if visible;
- whether source evidence is readable;
- whether the repair screen remains stable without starting mutation;
- whether any repair began automatically.

Expected:

> No real archive mutation occurs merely because the coordinator was selected.

If any payload copy or archive-record write begins before explicit human confirmation, STOP immediately and report FAIL.

---

# 7. Compare Stage A to the forensic baseline

The previous forensic baseline was:

```text
required     18,281
covered       4,440
uncovered    13,841
```

Do not require exact equality because source data may have changed.

Instead report:

- current required count;
- current covered count;
- current uncovered count;
- current automatic/source-available count;
- current source-absent count;
- current UNKNOWN/unverifiable count.

Explain differences only from current evidence.

Do not call an uncovered item lost.

Do not infer Apple eviction where the coordinator reports only absence or UNKNOWN.

---

# 8. HARD HUMAN STOP before real mutation

At this point STOP execution and present the Stage A partition to the human.

Ask for explicit authorization in this form:

> `Authorize one bounded real Attachment Archive Repair batch of up to N items?`

where `N` is the exact implemented maximum established in Section 4.

Do not continue from this prompt until the human explicitly authorizes that batch.

Do not treat the original instruction to run Prompt 66 as authorization for real archive mutation.

---

# 9. Stage B — one authorized real repair batch

Only after explicit human authorization:

1. record current PID and current repair counts;
2. activate the normal product repair confirmation exactly once;
3. allow exactly one bounded repair batch;
4. do not click a second confirmation;
5. do not manually manipulate source files or archive files;
6. do not navigate away unless required by the product.

Observe factual progress only.

Record:

- batch item limit;
- items examined;
- items actually source-available;
- items attempted;
- payloads newly preserved;
- skipped/manual/absent/UNKNOWN counts;
- failed count;
- any bytes/progress actually shown;
- whether the same PID remains active;
- whether one Ball/mutation occurrence completes cleanly;
- whether repair stops accepting new work after the bounded batch;
- whether a second batch starts automatically without another human action.

## Mandatory fail gate

If a second mutation batch begins automatically without another explicit human confirmation, STOP after the currently admitted atomic operation drains and report FAIL.

---

# 10. Verify durable effects from facts, not worker result

After the one bounded batch settles, require a fresh current coverage read.

Record:

```text
required before / after
covered before / after
uncovered before / after
UNKNOWN before / after
```

For successful newly preserved objects, require that:

- the durable object record exists;
- referenced archive payload exists;
- path is safe/regular;
- recorded size matches current payload metadata;
- the object disappears from the fresh uncovered set.

Do not rely on the worker's "success" return as the qualification fact.

Do not hash the entire archive.

Use the product's normal fresh verification.

---

# 11. Expected outcome when coverage remains FALSE

Given the large historical deficit, coverage will probably remain FALSE after one small batch.

If so, expected behavior is:

```text
fresh coverage still FALSE
-> remain in Attachment Archive Repair
-> show updated factual partition
-> NO automatic restart loop
-> NO Operating admission
-> NO automatic second repair batch
```

This is a PASS condition.

The human may later authorize more batches in a separate task.

Do not attempt to clear all 13,841 items in this qualification.

---

# 12. Coverage TRUE edge case

If reality unexpectedly reaches coverage TRUE after the authorized batch:

```text
coverage TRUE
-> repair stopAndDrain()
-> real process restart
-> fresh AppCzar
```

Only fresh AppCzar may then admit Operating.

Record old/new PIDs and process boundary.

Do not continue directly into the Prompt 61 live-currentness experiment in this task.

---

# 13. Source access loss / UNKNOWN during repair

If Messages source access becomes conclusively unreadable during repair:

```text
stop new repair admission
-> drain active writer/Ball
-> real restart
-> fresh AppCzar
-> Source Access Repair if still FALSE
```

If source evidence is UNKNOWN:

- do not call it denied;
- drain/restart for fresh AppCzar;
- fresh Diagnostic Review may result.

No in-process coordinator chaining.

---

# 14. Quit/drain qualification after the bounded batch

Once the one authorized batch is settled and no mutation is active:

1. request a normal application quit;
2. verify the process exits cleanly;
3. confirm no repair progress from the old occurrence continues afterward.

Do not intentionally quit in the middle of a payload write on the real archive for this first qualification.

The deterministic tests remain the governing proof of mid-write `stopAndDrain()` behavior.

This live test only corroborates clean coordinator shutdown after real mutation.

---

# 15. Fresh-process reconstruction check

Direct-launch the exact same artifact once more while the development-root environment remains set.

Fresh AppCzar must reconstruct the new durable facts.

Expected if coverage remains FALSE:

```text
fresh AppCzar
-> archive available
-> coverage FALSE, but with improved covered/uncovered counts if repairs landed
-> fresh Attachment Archive Repair
```

Verify that:

- improvement survives process death;
- no repair cursor/status had to be restored;
- already repaired objects are not offered as uncovered again;
- no historical "repair succeeded" flag is required.

Then quit normally.

---

# 16. Fair-Witness checks

Across both Stage A and Stage B confirm:

- no item is called lost merely because source bytes are absent;
- no source UNKNOWN is called absent or denied;
- no archive availability claim substitutes for coverage;
- no worker result substitutes for fresh durable verification;
- no repair completion claim occurs while coverage remains FALSE;
- no Operating admission occurs while coverage remains FALSE;
- no top-level coordinator handoff occurs in-process;
- real restart is used only when jurisdiction changes.

---

# 17. Cleanup

At the end:

1. leave the development FDA entry enabled;
2. confirm no MessageLens Development process remains;
3. run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

4. verify `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty;
5. do not alter source/test code;
6. do not stage/commit/push anything as part of the qualification itself.

The real archive mutations produced by the one explicitly authorized batch are expected qualification effects and must not be manually undone.

---

# 18. Qualification verdict

A PASS does **not** require the entire archive to become complete.

A PASS means the real product demonstrated:

```text
fresh AppCzar selected repair from current facts
-> read-only partition happened before mutation
-> human explicitly authorized one bounded batch
-> only proven source-available objects were mutated
-> payload-before-record durability held
-> fresh coverage reconstructed the effects
-> unresolved items remained factual
-> no restart loop
-> no hidden second batch
-> fresh process recovered state entirely from durable/current facts
```

If no currently source-available item exists, mutation qualification is `NOT REACHED`, but the read-only repair coordinator may still PASS its Stage A qualification.

---

# 19. Required response

Create Response 66 and report:

1. exact repository/artifact preflight;
2. exact artifact/hash verification;
3. human-visible FDA state before launch;
4. exact launchd development-root value;
5. source-audited mutation confirmation boundary;
6. exact maximum items admitted by one confirmation;
7. whether one confirmation can chain multiple batches;
8. initial fresh AppCzar path;
9. Attachment Archive Repair selection evidence;
10. Stage A PID;
11. Stage A required/covered/uncovered counts;
12. Stage A source-available/source-absent/UNKNOWN partition;
13. proof no mutation occurred before explicit confirmation;
14. exact human authorization received;
15. Stage B batch bound;
16. Stage B progress actually observed;
17. items attempted/newly preserved/skipped/failed;
18. proof no hidden second batch started;
19. fresh post-batch coverage counts;
20. durable object/payload verification result;
21. coverage FALSE/TRUE terminal behavior;
22. whether restart occurred;
23. no-restart-loop result;
24. source-access behavior if encountered;
25. clean quit/drain corroboration;
26. fresh-process reconstruction result;
27. proof repaired objects remained covered after restart;
28. proof no durable semantic repair cursor was needed;
29. Fair-Witness verdict;
30. errors/warnings/evidence limitations;
31. cleanup result;
32. qualification verdict;
33. recommendation for the next bounded repair step;
34. readiness to rerun Prompt 61.

Conclude exactly:

`ATTACHMENT ARCHIVE REPAIR STAGE A READ-ONLY QUALIFICATION: PASS / FAIL / NOT REACHED`

`EXPLICIT HUMAN AUTHORIZATION PRECEDED REAL ARCHIVE MUTATION: YES / NO / NOT REACHED`

`ONE CONFIRMATION ADMITTED ONLY ONE BOUNDED REPAIR BATCH: YES / NO / NOT REACHED`

`REAL REPAIR MUTATED ONLY CURRENTLY PROVEN SOURCE-AVAILABLE ITEMS: YES / NO / NOT REACHED`

`FRESH COVERAGE RECONSTRUCTED THE REPAIR EFFECTS: YES / NO / NOT REACHED`

`UNRESOLVED COVERAGE REMAINED FACTUAL WITHOUT RESTART LOOP: YES / NO / NOT REACHED`

`ATTACHMENT ARCHIVE REPAIR HUMAN LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`READY TO AUTHORIZE ANOTHER BOUNDED REPAIR BATCH: YES / NO`

`READY TO RERUN OPERATING STAGE TWO PROMPT 61: YES / NO`

Then STOP.
