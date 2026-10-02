# MessageLens Feature 34
## 46 — Correct AppCzar Fair-Witness Testimony and Status Semantics

The visible AppCzar harness has now been exercised against the same development
installation in two real launch conditions:

1. launched through VS Code while the visible MessageLens Development FDA toggle
   was OFF: the process could still read `chat.db`;
2. launched directly through Finder/LaunchServices with the visible FDA toggle
   OFF: the process could not read `chat.db`;
3. launched directly again after restoring the visible FDA toggle: the process
   could once again read `chat.db` and independently diagnosed a healthy current
   installation.

This experiment proved two things.

First:

> **Message source readability is directly observable. “Full Disk Access is
> enabled” is not currently directly observable by AppCzar.**

The existing AppCzar row:

`Full Disk Access = TRUE/FALSE`

is therefore too strong and violates the Fair Witness rule. AppCzar currently
derives that statement from whether the Messages source can be opened. Those are
not the same proposition.

Second:

> **Truth value and health/status meaning are not the same thing.**

The current row:

`New source messages present = FALSE`

is literally correct when there are no new messages, but rendering it as a red
error makes a healthy condition look broken.

This task corrects those two epistemic/presentation defects while preserving the
visible development AppCzar harness.

Do NOT give AppCzar coordinator-execution authority yet.
Do NOT replace production startup.
Do NOT run Onboarding, import, reset, repair, or update.
Do NOT mutate real development data.
Do NOT stage, commit, or push.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- HEAD/upstream `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- accumulated Prompt 32 + Prompt 35 + Prompt 44 changes present;
- Prompt 45 made no source/test changes;
- index empty;
- shared-instructions submodule clean.

Read Responses 44 and 45 and the current AppCzar implementation before editing.

Create a fresh external baseline manifest.

---

# 2. Elevate the Fair Witness law to a hard code/test invariant

Adopt this exact principle:

> **Every statement MessageLens makes about current state must be literally true,
> currently provable, and no stronger than the evidence supports.**

This applies to:

- AppCzar fact names;
- AppCzar diagnosis names;
- AppCzar screen copy;
- coordinator-selection reasons;
- diagnostic logs produced from AppCzar facts.

No “you know what I mean” shorthand.

No inference disguised as observation.

No historical narrative substituted for a present fact.

---

# 3. Remove the false equivalence between FDA and source readability

Audit the current implementation of:

- the observation currently used for FDA;
- the `Full Disk Access` fact/row;
- the Messages-source-readable fact/row;
- source-access diagnosis selection.

Correct the model so AppCzar testifies only to what it can directly prove.

Preferred observable proposition:

```text
The current Messages source can be read by this process.
```

or an equally literal equivalent.

If `chat.db` opens and required bounded source queries succeed:

```text
Messages source readable = TRUE
```

If current access is conclusively denied/unavailable:

```text
Messages source readable = FALSE
```

If the probe is inconclusive:

```text
Messages source readable = UNKNOWN
```

Do **not** state:

```text
Full Disk Access = TRUE
```

or:

```text
Full Disk Access = FALSE
```

unless a separate authoritative macOS API is found that literally reports that
exact setting for the responsible process identity. Do not add such an API in
this task merely to preserve the old row.

The source-access coordinator may later explain that FDA is a likely/normal
remedy. AppCzar itself should not testify to FDA state unless it actually
observes FDA state.

---

# 4. Collapse redundant source-access rows where appropriate

The current screen has both:

- `Full Disk Access`;
- `Messages database readable`.

After removing the unsupported FDA proposition, review whether only one
source-access row is needed.

Prefer one clear user-facing row such as:

```text
Messages database
Readable — 138,823 messages
```

or, when unavailable:

```text
Messages database
Cannot currently be read
```

If a separate technical source-probe fact is genuinely needed internally, keep
it internal or behind a development disclosure.

Do not duplicate the same evidence under two labels.

---

# 5. Truth is not health

Do not render:

```text
TRUE  -> green
FALSE -> red
UNKNOWN -> gray
```

as a generic UI rule.

That conflates logical truth with desirability.

Examples:

```text
NewSourceMessagesArePresent = FALSE
```

can be healthy.

```text
GraphIsCorrupt = FALSE
```

would also be healthy.

Conversely:

```text
ProtectedNonLiveMaterialIsPresent = TRUE
```

may be important without being an error.

Introduce the smallest pure presentation mapping needed to distinguish:

- healthy/expected;
- attention/problem;
- neutral/informational;
- unknown/pending.

This presentation significance must have **zero influence** on fact evaluation or
coordinator selection.

Do not let UI color become semantic authority.

---

# 6. Prefer value-oriented user-facing rows

Where a raw Boolean proposition is awkward for humans, display the directly
useful value instead of the Boolean.

Examples:

Instead of:

```text
New source messages present        FALSE
```

prefer something like:

```text
New messages                         0
```

or:

```text
Source and MessageLens are current
Source high-water 154999; local high-water 154999
```

while internal diagnostics may still retain:

```text
NewSourceMessagesArePresent = FALSE
```

Similarly, user-facing rows may show counts, schema/health summaries, or
availability values rather than raw TRUE/FALSE labels when that is clearer and
equally literal.

Keep the development screen transparent, but not misleading.

---

# 7. Separate observation, fact, and presentation text

For each AppCzar screen row, make it mechanically traceable to:

```text
current observation(s)
-> pure fact/value
-> pure presentation
```

Presentation may rephrase but may not strengthen.

Example:

```text
Observation:
chat.db opened read-only; bounded count = 138823; high-water = 154999

Fact:
CurrentMessagesSourceIsReadable = TRUE

Presentation:
Messages database
Readable — 138,823 messages; high-water 154999
```

If the observation cannot support a statement, the presentation cannot contain
it.

Add focused tests that compare presentation copy against fact/evidence shape.

---

# 8. Preserve current diagnosis behavior

The direct-launch FDA-off experiment produced the useful diagnosis:

> The current Messages source cannot be inspected with the available access.

That is acceptable Fair-Witness language because it describes the observed
condition without asserting why.

Preserve or improve that diagnosis.

The virtual coordinator may remain:

`Source Access Repair`

because coordinator naming describes the action domain, not an AppCzar factual
claim.

Do not rename the coordinator to `FDA Repair` unless the coordinator itself
later establishes that FDA is the actual remediation target.

---

# 9. Preserve the healthy reciprocal experiment

With source access restored, the same installation currently produces:

- source count 138,823;
- source high-water 154999;
- import count 138,823;
- local high-water 154999;
- graph count 138,823;
- overlay healthy;
- archive available;
- source/local comparison known;
- no new source messages.

The diagnosis:

> This appears to be a healthy current MessageLens installation.

is intentionally cautious (`appears to be`) and is acceptable if the current
minimum evidence truly proves every requirement of the harness's healthy
classification.

Keep it unless source inspection shows it claims more than the current facts
establish.

---

# 10. Add provenance affordance for development use

The human has explicitly found value in seeing the evaluation rather than an
opaque state transition.

Add a compact development-only disclosure per row or per assessment that can
show the exact basis of a fact without overwhelming the default screen.

Examples:

```text
Messages database
Readable — 138,823 messages

Details:
Opened chat.db read-only.
Count = 138823.
High-water = 154999.
```

```text
Source versus local
Current

Details:
Source high-water = 154999.
Local live-import high-water = 154999.
```

Do not expose private message text/contact content.

Do not show provider names/SQL by default.

If this materially complicates the UI, implement a single bottom `Assessment
details` disclosure instead of per-row disclosure.

---

# 11. Re-run the real two-direction source-access experiment after correction

After implementation and validation, build the exact development artifact and
hand it to the human.

Do not launch it automatically.

The human will repeat:

## A. Direct launch with visible FDA toggle OFF

Expected AppCzar testimony:

- no statement asserting FDA ON/OFF;
- Messages source unreadable or unavailable if that remains the observed direct
  launch behavior;
- downstream source comparison facts UNKNOWN;
- healthy local dataset facts may remain TRUE;
- diagnosis selects source-access issue;
- virtual coordinator = Source Access Repair.

## B. Direct launch after visible FDA toggle restored

Expected testimony:

- no FDA row;
- Messages source readable with current count/high-water;
- source/local comparison known;
- healthy diagnosis if all current facts agree;
- virtual coordinator = Operating Session.

The contrast should be explainable entirely from current observations.

---

# 12. Preserve read-only harness isolation

AppCzar remains diagnostic-only.

It still may not:

- instantiate a coordinator;
- mutate SQLite;
- start monitors;
- import;
- reset;
- repair;
- acquire Ball tenure;
- transition to normal application UI.

Keep architecture tripwires.

---

# 13. Tests

At minimum add/adjust tests proving:

1. source-readable TRUE does not produce the text `Full Disk Access`;
2. source-unreadable FALSE does not produce the text `Full Disk Access disabled`;
3. source-readability diagnosis remains deterministic;
4. `NewSourceMessagesArePresent = FALSE` is not rendered as an error;
5. raw TRUE/FALSE do not directly determine UI color/tone;
6. healthy no-delta state presents as healthy/current;
7. new-message delta > 0 presents as actionable/update information;
8. UNKNOWN source values remain visibly unknown with a literal reason;
9. presentation cannot claim source count/high-water when unavailable;
10. provenance/details reflect only evidence present in the assessment;
11. observation-order independence remains intact;
12. virtual coordinator still cannot execute.

---

# 14. Validation

Run:

1. focused AppCzar evaluator tests;
2. focused presentation semantics tests;
3. direct source-access fixture tests;
4. architecture isolation tests;
5. complete architecture suite;
6. analyzer;
7. full Flutter suite because startup/presentation production source changes;
8. `git diff --check`;
9. format/generated consistency.

Do not launch production.

---

# 15. Project Conformance

Require PASS for:

- Fair Witness law encoded/tested;
- no unsupported FDA assertion;
- source readability stated literally;
- truth separated from presentation significance;
- no healthy FALSE shown as an error merely because it is FALSE;
- observations/facts/presentation remain separate;
- diagnosis remains descriptive;
- one virtual coordinator only;
- no execution authority;
- production startup unchanged;
- real development data untouched.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 16. Leave unstaged for human experiment

Do not stage, commit, or push.

Build the corrected development artifact.

Provide exact bundle path/hash handoff and STOP.

---

# 17. Required response

Create Response 46.

Report:

1. baseline verification;
2. exact unsupported FDA inference source;
3. FDA-row removal/correction;
4. final literal source-readability fact;
5. duplicate-row simplification;
6. truth-vs-significance presentation design;
7. `New source messages = 0` presentation result;
8. healthy-current presentation result;
9. source-unavailable presentation result;
10. diagnosis wording result;
11. virtual coordinator result;
12. provenance/details design;
13. observation/fact/presentation separation proof;
14. focused evaluator tests;
15. focused presentation tests;
16. source-access tests;
17. architecture result;
18. analyzer result;
19. full Flutter-suite result;
20. diff/format/generated hygiene;
21. Project Conformance verdict;
22. BLOCKER findings;
23. SHOULD FIX findings;
24. exact build identity/path/hashes;
25. exact Git/worktree/index/submodule state;
26. readiness for repeated direct-launch OFF/ON experiment.

Conclude exactly:

`FAIR-WITNESS TESTIMONY CORRECTED: YES / NO`

`UNSUPPORTED FDA ASSERTION REMOVED: YES / NO`

`TRUTH AND HEALTH PRESENTATION SEPARATED: YES / NO`

`VISIBLE APPCZAR READY FOR REPEATED ACCESS EXPERIMENT: YES / NO`

Then STOP.
