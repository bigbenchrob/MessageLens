# MessageLens Feature 34
## 38 — Forensic Audit of Mechanical-Impossibility Failure and Lazy Contact Resolution

This supersedes a contact-name-only investigation.

The current clean-slate qualification exposed two related but distinct symptoms:

## A. Mechanical-Impossibility failure

The established architectural invariant is:

> Center-panel content is a direct projection of current sidebar state.
> Nothing needs to issue a separate “Clear center panel” command.

Therefore incompatible/stale center-panel content should be mechanically
unrepresentable when sidebar state changes.

Human observations:

- Start Fresh had previously completed and the development installation had been
  verified `virgin`;
- on a subsequent app launch, stale center-panel content was visible even though
  the installation had been expected to contain no consequential rebuilt
  message data;
- the stale center-panel content persisted while switching between
  **Conversations** and **Contacts** sidebar modes;
- this persisted across app opening, so it cannot be dismissed as one widget
  merely surviving the prior reset in memory.

This raises two serious possibilities that must be distinguished:

1. the center panel has an independent retained/persisted state path that is not
   mechanically constrained by current sidebar state; or
2. sidebar state itself is restoring a stale selection/reference and the center
   panel is faithfully projecting that stale state.

A third possibility is that the virgin classifier and the UI are reading
different stores/roots or different notions of “available data.”

## B. Lazy contact-name resolution clue

Immediately after clean-slate import:

- the Favourites picker showed the two preserved favourites;
- both appeared as fallback labels of the form
  `contact 17592186044...`
  instead of their human names.

Then the human clicked a phone-number row in the contact picker.

After that one interaction:

- the correct contact name appeared in the hero card;
- the correct contact name appeared in the message-list header;
- returning to the picker, the favourite names were now also displayed
  correctly.

This is a crucial clue.

It strongly suggests that the contact-name data was not irretrievably lost.
Instead, some selection-driven path likely caused one or more of:

- lazy identity hydration;
- provider invalidation;
- cache population;
- canonical participant/contact resolution;
- graph/contact lookup;
- sidebar/center projection refresh;
- remount of a stale picker projection.

The audit must determine exactly which.

This task is a **read-only architecture + runtime forensic audit**.

Do NOT run Start Fresh.
Do NOT import again.
Do NOT add/remove favourites.
Do NOT edit Contacts.
Do NOT modify source/tests.
Do NOT stage/commit/push.
Do NOT mutate SQLite.
Do NOT access production data.
Do NOT traverse attachment payloads.
Do NOT drive the GUI further unless explicitly instructed by the human.

---

# 1. Preserve current evidence first

Before reading databases/log content, record:

- current time;
- whether MessageLens Development is running;
- PID;
- exact executable path;
- process working directory;
- parent process if relevant;
- development log path, size, mtime, SHA-256;
- relevant development SQLite paths, sizes, mtimes, WAL/SHM state, and main-file
  hashes where practical.

Use read-only SQLite only:

- `mode=ro`;
- `immutable=1` where safe;
- `PRAGMA query_only=ON`;
- no checkpoint;
- no temp table;
- no migration;
- no vacuum;
- no write-capable application helper.

Clearly separate the preserved capture from any later writes by the running app.

---

# 2. Verify the exact qualification build

Confirm the running/last-run development artifact belongs to:

`/Users/rob/Development/FlutterProjects/remember_every_text`

and contains the accumulated Prompt 32 + Prompt 35 correction.

Do not rely on version/build alone.

Record branch/HEAD and the accumulated source/diff fingerprint.

If the wrong worktree/build was used, STOP AND REPORT.

---

# 3. Reconstruct the exact state timeline

Build a timeline covering:

1. successful Start Fresh from the prior review;
2. verified virgin state;
3. next app launch;
4. any stale center-panel content visible before import;
5. clean-slate Onboarding import start;
6. import/graph/durable completion;
7. first visit to Contacts/Favourites showing fallback `contact <id>`;
8. phone-number selection;
9. hero-card/header name restoration;
10. return to picker with names now correct.

Use logs, durable evidence, and human observation.

Do not blur pre-import virgin-state symptoms with post-import picker symptoms.

---

# 4. Mechanical-Impossibility invariant: trace the intended architecture

Source-trace the center-panel ownership model.

Identify:

- canonical sidebar state model(s);
- Conversations sidebar selection state;
- Contacts sidebar selection state;
- sidebar-mode state;
- center-panel projection/resolver;
- any persistent/restored selection state;
- any transient/ephemeral center-panel projection;
- any navigation coordinator or cassette coordinator involved;
- any state retained independently inside center-panel widgets/providers.

Produce the intended dependency graph, for example:

```text
sidebar mode
+ sidebar selection
+ allowed projection state
        ↓
center-panel resolver
        ↓
center-panel content
```

Then identify every actual source path by which center-panel content can appear.

The key question:

> Is the center panel truly a pure/current projection of sidebar state, or can it
> retain/restore content independently?

---

# 5. Prove how stale center content survived a sidebar-mode change

The human reports the same stale center content remained while switching between
Conversations and Contacts sidebar modes.

Trace the exact source behavior for such a switch.

Determine:

- what state value changes;
- what providers/resolvers invalidate;
- what center-panel projection should result;
- whether the existing center content is intentionally retained;
- whether a “no selection” or incompatible selection state still leaves the old
  panel mounted;
- whether an identity-equality or keying bug prevents remount;
- whether a stable cassette/widget shell owns stale child content;
- whether a cached provider returns the old projection;
- whether a persisted selection is common to both modes.

Do not accept “the UI should clear” as proof. Show the exact source mechanism
that should make incompatible content unrepresentable, and identify why it did
not.

---

# 6. Determine whether the virgin installation actually had accessible message content

This is a separate high-severity question.

Using preserved Response 34/35 evidence and current logs where possible,
determine what the app could have been rendering immediately after the verified
virgin reset and on the next launch.

Check read-only:

- source/import database existence;
- graph database row counts at the relevant timestamp if reconstructable;
- any surviving legacy/alternate graph DB;
- any source-message DB or direct Messages-source browsing path;
- cached in-memory content impossible across process restart;
- persisted presentation payloads containing message IDs/contact IDs;
- restored sidebar selection IDs;
- any separate search/index/cache store capable of hydrating stale message
  content;
- whether startup can restore a selection before graph readiness.

Answer precisely:

> Was actual stale message content available from a durable store while the
> classifier said `virgin`, or was a stale *selection/projection* restored and
> later hydrated from newly rebuilt data?

If the historical exact state cannot be reconstructed, say so and identify the
strongest source-supported alternatives.

---

# 7. Audit the virgin classifier versus UI data admissibility

Trace what `virgin` means mechanically.

Identify exactly which stores and conditions the installation classifier checks.

Then identify which stores/providers the center-panel content can read.

Compare the sets.

Produce:

```text
Virgin classifier considers:
- ...

Center panel can read:
- ...
```

If the center panel can render consequential content from a store not included
in virgin classification, that is a serious source-of-truth mismatch.

If not, explain how stale content could have appeared despite empty classified
stores.

---

# 8. Contact-name fallback: trace the exact first broken layer

For only the two known favourite participant IDs:

- Claire: `17592186044433`
- Rusung: `17592186044472`

Trace:

1. overlay favourite intent;
2. graph contact/participant row;
3. human-readable display name;
4. contact-to-handle links;
5. chat-to-handle links;
6. canonical identity mapping;
7. shared contact/display-name resolver;
8. picker projection;
9. hero-card resolver;
10. message-list header resolver.

Determine whether those three presentation surfaces use:

- the same provider/resolver instance;
- related providers backed by the same cache;
- different lookup paths.

---

# 9. Explain why clicking a phone number fixed every name surface

This is the highest-value clue for the contact issue.

Source-trace the phone-number selection action.

Determine exactly what it triggers:

- selection mutation;
- navigation;
- contact enrichment;
- graph lookup;
- canonicalization;
- lazy repository read;
- provider invalidation;
- message-data version read/bump;
- cache write;
- resolver population;
- widget remount.

Then determine which of those changes explains:

```text
picker: fallback name
-> click phone number
-> hero/header: correct name
-> return to picker
-> picker: correct name
```

The explanation must identify the exact state/provider/cache transition.

Do not merely say “the cache refreshed.”

---

# 10. Determine whether selection is improperly acting as initialization

A robust Contacts system should not require selecting a contact in order for
that contact’s display identity to become available to other views.

Check whether:

- a provider is lazily initialized only by the hero/message view;
- the picker consumes a weaker fallback projection;
- a repository cache is populated only by the selected-contact path;
- graph-backed names exist but are not exposed until selected;
- a provider family requires one consumer to prime another;
- missing invalidation after graph completion leaves fallback values cached.

Classify whether this is:

- legitimate lazy loading with incorrect invalidation;
- accidental initialization side effect;
- cache-coherence bug;
- provider-dependency bug;
- projection-layer bug;
- another source-proven category.

---

# 11. Look for a common root between the two symptoms

Do not assume the center-panel Mechanical-Impossibility failure and contact-name
lazy-resolution failure are independent.

Specifically inspect whether both involve:

- retained selection state;
- provider-family keys;
- cassette projection identity;
- sidebar coordinator state;
- graph/message-data version invalidation;
- provider invalidation after graph rebuild;
- selection-driven hydration;
- stale projection retained across mode switches.

Report:

- common root proven;
- common enabling mechanism but separate defects;
- independent defects;
- insufficient evidence.

---

# 12. Existing architecture tests versus observed behavior

Identify existing tests or architecture rules that are supposed to prove:

> center-panel content flows mechanically from sidebar state and requires no
> explicit Clear command.

Determine why they did not catch this runtime state.

At minimum answer:

- what invariant they actually enforce;
- whether they enforce structural dependency only;
- whether they test mode switches;
- whether they test no-selection state;
- whether they test app restart/restored state;
- whether they test virgin graph state;
- whether they test stale selection IDs;
- whether they test projection identity/remount behavior.

Similarly inspect contact/picker tests for:

- favourite names immediately after graph rebuild;
- display identity before any contact selection;
- graph-completion invalidation;
- selection-driven cache priming.

Do not add tests yet.

---

# 13. Severity and qualification impact

Keep four verdicts distinct:

1. original stuck-Onboarding/self-denial defect;
2. durable clean-slate import completion;
3. contact display-name coherence;
4. sidebar-to-center Mechanical-Impossibility conformance.

Even if import completed correctly, overall qualification cannot PASS if center
content can violate the sidebar projection invariant.

Treat any proven durable-content access while classified virgin as a BLOCKER.

Treat any proven independent center-panel state path that defeats Mechanical
Impossibility as a BLOCKER.

---

# 14. No implementation

Do not fix anything in this task.

The next correction must be based on:

- exact center-panel state ownership;
- exact stale-content survival path;
- exact virgin/UI store mismatch if any;
- exact phone-selection-driven name-repair mechanism;
- exact missing regression tests.

Do not start another broad architecture rewrite unless the evidence proves the
existing Mechanical-Impossibility design is structurally false.

---

# 15. Required response

Create Response 38 and report:

1. running/build verification;
2. preserved evidence boundary;
3. exact human-observation timeline;
4. intended sidebar -> center dependency graph;
5. every actual center-panel content source;
6. Conversations -> Contacts mode-switch state trace;
7. stale center-content survival explanation;
8. virgin classifier store/condition census;
9. center-panel readable-store census;
10. virgin-vs-UI admissibility comparison;
11. whether consequential message content was durably available while virgin;
12. Claire identity/name trace;
13. Rusung identity/name trace;
14. exact picker fallback source path;
15. exact phone-number selection action path;
16. exact mechanism that restored hero/header names;
17. exact mechanism that subsequently restored picker names;
18. whether selection is improperly serving as initialization;
19. provider/cache/invalidation findings;
20. common-root analysis between Mechanical-Impossibility and name symptoms;
21. existing Mechanical-Impossibility test gap;
22. existing contact/picker test gap;
23. original stuck-Onboarding defect verdict;
24. durable clean-slate import verdict;
25. contact-name regression verdict;
26. Mechanical-Impossibility verdict;
27. overall clean-slate qualification verdict;
28. BLOCKER findings;
29. SHOULD FIX findings;
30. recommended bounded correction(s);
31. exact Git/worktree/index/submodule state;
32. confirmation nothing was modified.

Conclude exactly:

`MECHANICAL-IMPOSSIBILITY FORENSIC AUDIT COMPLETE: YES / NO`

`CENTER-PANEL STATE VIOLATION EXPLAINED: YES / NO / PARTIAL`

`CONTACT LAZY-RESOLUTION REGRESSION EXPLAINED: YES / NO / PARTIAL`

`ORIGINAL STUCK-ONBOARDING DEFECT REPRODUCED: YES / NO / AMBIGUOUS`

`CORRECTED CLEAN-SLATE ONBOARDING QUALIFICATION: PASS / FAIL / AMBIGUOUS`

Then STOP.
