# MessageLens Feature 34
## 91 — Checkpoint Start Fresh Audit and Implement Operating-Owned Start Fresh (Stage 2C)

Response 90 completed the Stage 2C source-grounded audit and design. Its verdict is:

```text
Start Fresh is an explicit Operating-owned user command.
It is NOT an eighth AppCzar disposition.

Existing legacy StartFreshService is NOT safe to transplant.
Stage 2C requires a narrower authority, preservation, and restart path.

PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)
READY FOR STAGE 2C IMPLEMENTATION: YES
PRODUCTION APPCZAR ACTIVATION: OFF
```

This prompt implements **only Stage 2C** using Response 90 as the controlling design. Do not broaden the task to production shell construction (Stage 2D), production process restart, signed application rehearsal, whole-root migration, or actual cutover.

**First read Response 90 in its entirety**, together with Response 85, Response 87, Response 89, the current source, and the Project Conformance standard. Its exact audit of the Start Fresh deletion footprint, preservation requirements, authority boundaries, and cancellation/restart rules is normative. If its proposed implementation contradicts current source evidence, STOP rather than silently reinterpret the audit.

The governing rule is:

> An admitted Operating Session may execute a voluntary, human-confirmed reset of its **exact active derived import and graph stores** only after fresh current evidence proves that **every consequential fact it would discard is reconstructible now**, every protected resource will be preserved, the currentness worker is quiescent, and one typed `startFresh` mutation tenure has been obtained. The old process proves only the physical result; a replacement process gives the next semantic answer.

No human consent can substitute for that evidence.

---

# 1. Nonnegotiable scope

Implement one AppCzar Operating-local Start Fresh command with:

- a reusable Settings row/action dispatcher;
- one exact, process-local, occurrence-bound command controller;
- reversible same-Operating currentness suspension **only before mutation**;
- complete fresh reset-safety/anti-difference evidence over the actual deletion footprint;
- process-local plan and exact human confirmation;
- immediate source/scope/plan revalidation;
- exactly one callback-local `ArchiveMutationOperation.startFresh` Ball;
- a capability-requiring, **active-only** lower reset worker;
- fail-hard provider close and exact physical preservation postcondition;
- drain, Ball release, and existing qualified development process restart;
- one fresh AppCzar assessment in the replacement process;
- complete focused, architecture, and regression tests.

Do NOT:

- add an eighth top-level jurisdiction or a second evaluator;
- enter or import Journey, Environment Readiness, Onboarding operation status, legacy Start Fresh presentation, or durable semantic snapshots;
- call legacy `StartFreshService` as the semantic coordinator;
- reuse automatic `Local Data Repair` classification as user Reset permission;
- delete any retired `macos_import.db` / `working.db` or their sidecars;
- clear or rewrite `user_overlays.db`, `presence.db`, marker/UUID, attachment archive, bookmarks/location, journals, historical registry, preferences, logs, operation snapshots, or failure records;
- run reset if any current source-backed fact needed for reconstruction is absent, unreadable, divergent, or UNKNOWN;
- use a consent waiver to override protection or uncertainty;
- call `MessageDataResetService`'s self-authorizing reset entry;
- acquire a second Ball or permit a second currentness/import worker;
- hand off from Operating to Onboarding/Diagnostic in the same PID;
- broaden the WD/UUID-specific adoption gate or development process-restarter authorization;
- change production startup/composition selection, activate production AppCzar, or touch real WD/Toshiba/production archives;
- launch, install, or exercise a real app or real reset in this implementation prompt.

If a complete safe implementation cannot be established, **STOP AND REPORT with the partial verified implementation and precise missing proof**, rather than leaving a permissive reset path in the app.

---

# 2. Git baseline and documentation checkpoint

Work only in the primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- HEAD and upstream synchronized `0/0`;
- tracked worktree and index clean;
- one Feature 34 worktree;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- known unrelated untracked files untouched;
- Stage 2B implementation `3c5a5774aeea20d32587e00c0b75d046043ba9fb` in ancestry;
- Prompt/Response 89 documentation checkpoint `0c2ce29c17b44afb36790d675f5e0b364ab5cc2e` in ancestry.

Before source work, checkpoint **only Prompt 90 and Response 90** into one narrow documentation commit and push normally. If already checkpointed, record the exact existing commit and do not duplicate it.

Create an external Git/source baseline manifest. No real-root, real Messages, or archive probes.

No force push, rebase, squash, unrelated staging, or worktree modification.

---

# 3. Verify the seven-jurisdiction and selection boundary

Require the exact pre-change census:

```text
Data Update                    top-level
Source Access Repair           top-level
Attachment Archive Repair      top-level
Onboarding                     top-level
Local Data Repair              top-level
Diagnostic Review              top-level
Operating Session              admitted session
```

`ProductionAppCzarActivation` is unconditionally disabled, and the official production app still uses legacy `StartupApp`.

Stage 2C adds **no AppCzar disposition**. It is an explicit user-command occurrence that exists only while the selected AppCzar composition is Operating and the exact Operating occurrence is current.

Development AppCzar keeps all six specialist branches and current Operating presentation. Legacy production Start Fresh remains routed through the old product path until a separately authorized cutover.

---

# 4. Source census and reuse-first plan

Before editing, source-trace:

1. normal Settings Reset Message Data specification and action-list single-flight;
2. Settings dispatcher and `advancedStartFreshActionProvider`;
3. `AppCzarOperatingSessionController` and exact occurrence identity;
4. `AppCzarOperatingCurrentnessController` and its 15-second active-flight drain;
5. `AppCzarOperatingSessionApp` and the existing currentness status host;
6. `ArchiveMutationCoordinator` / `ArchiveMutationOperation.startFresh`;
7. `MessageDataResetService`, provider close, file-store target list, and `includeRetired` options;
8. the Local Data Repair source-grounded reconstructibility observer;
9. the Local Data Repair physical witness/postcondition implementation;
10. `user_overlays.db`, `presence.db`, attachment archive configuration, journals, historical registry and message/attachment references;
11. existing `appCzarProcessRestarterProvider` and exact development-only guard;
12. architecture tripwires for seven owners and one typed Ball.

Produce an explicit reuse/extraction table in Response 91. Do not duplicate imported SQL, FTS metadata readers, source scanners, or reset logic simply to put them under new class names.

Do not let lower reset services import AppCzar or presentation packages.

---

# 5. Separate invitation to prepare from authority to delete

The Settings **Reset message data…** action may become available only when:

```text
selected composition = admitted AppCzar
AND selected top-level disposition = Operating Session
AND exact current Operating occurrence is admitted
AND Operating command admission is open
AND development process restarter remains qualified for that process
```

The row/button is **not** proof of reconstructibility.

The actual destructive decision must be made only after:

```text
claim one command occurrence
-> synchronously bar new Operating currentness work
-> await existing currentness/update/preservation flights
-> collect fresh bounded proof
-> present exact plan and consent
-> revalidate every relevant source/scope/fingerprint
-> obtain typed mutation Ball
```

The other six top-level jurisdictions must never construct, display as executable, or invoke this command—even through a stale Settings callback. A stale Operating occurrence cannot authorize action in a replacement process.

---

# 6. Reversible Operating-local currentness barrier

Do **not** use a terminal-only `stopAndDrain()` as a reversible pause unless its current contract demonstrably supports resumption. Implement the narrowest explicit Operating-local API, conceptually:

```text
suspendForExclusiveUserCommand()
    synchronously blocks future observation/update admission
    cancels/suspends the 15-second scheduler
    invalidates stale publication epochs
    awaits the exact active bounded observer / LiveGraphUpdateWorker /
      attachment-preservation flight
    returns an occurrence-bound suspension lease

resumeFromCommand(lease)
    permitted ONLY before any mutation began
    permitted ONLY for same admitted Operating occurrence
    permitted ONLY after no conflict / stale evidence
    restores exactly one currentness scheduler

completeTerminalCommand(lease)
    leaves admission closed permanently
    drains for real restart or quit
```

Use the repository's established names and lifecycle patterns. No new process-wide lock hierarchy and no persistent pause flag.

**Order matters:** worker flight drains **before** requesting the Start Fresh Ball. Never acquire a Ball and then await an updater that needs that Ball. Never register the Start Fresh command's own Future as an active currentness flight; prevent self-await/deadlock.

A cancel/preflight refusal before mutation may safely resume the *same* current Operating occurrence, but only if current facts and scope still permit it. If the jurisdiction itself becomes uncertain or stale, drain/restart rather than resume under an old assessment.

Once a destructive operation may have begun, currentness never resumes in the old PID.

---

# 7. Exact reset deletion footprint

The only candidate deletion targets are the active MessageLens-derived families:

```text
macos_import_ss.db
macos_import_ss.db-wal
macos_import_ss.db-shm
working_ss.db
working_ss.db-wal
working_ss.db-shm
```

No other file is an authorized target. In particular **exclude**, including when present:

```text
macos_import.db
macos_import.db-wal
macos_import.db-shm
working.db
working.db-wal
working.db-shm
user_overlays.db (and sidecars)
presence.db (and sidecars)
archive marker / instance UUID
attachment_archive or configured external payload root
bookmarks / location configuration
adoption/relocation journals and receipts
historical-source registry / provenance
automatic failure/operation evidence and logs
preferences and window/navigation state
```

As Response 90 requires: the **presence of retired derived residue blocks Start Fresh entirely**, instead of deleting it, because its possible unique provenance is not currently proven expendable.

Use `MessageDataResetService`'s audited exact basename/path/symlink safeguards and the Local Data Repair protected-witness verification. Do not transplant `includeRetired: true` or current legacy `StartFreshService` semantic cleanup.

---

# 8. Complete current reconstructibility — not provenance-only

The command is user-requested but **is still destructive**. Therefore human consent is necessary but insufficient.

Implement one aggregate, current, bounded, source-grounded proof that **every consequential fact erased by the active store deletion** is reproducible from authoritative current sources under the importer/projector's present semantics.

At minimum cover every populated source-scoped import schema family in the actual code:

- canonical live Messages and AddressBook source identities;
- source registry, batches, lineage, cursors and imported material metadata;
- messages (stable row identity plus GUID and material source fields as required by current importer);
- chats and handles;
- chat-message and chat-handle joins;
- contacts and contact channels / enrichments;
- attachment metadata and message-attachment joins;
- rich-text reconstruction inputs and any derived-only source fields;
- any other consequential active import tables discovered by schema inventory;
- all populated graph domain tables, including message/chat/handle/attachment/edge topology, FTS projection, and any graph-only facts;
- user-overlays-to-graph reference integrity and any preserved identity/provenance mapping needed after reconstruction.

Stage 2C is **not** allowed to infer a populated graph is reconstructible because its import DB exists or because all message ROWIDs still exist. Local Data Repair's narrow positive proof required an **empty** graph; a normal Operating graph is populated. You must establish a separate or safely extended proof of graph projection rebuildability, exact source-to-import/graph lineage, and absence of unique graph-only facts. Reuse common bounded readers, but do not weaken the existing Local Data Repair rule to accommodate this command.

Prefer stable, paginated local-minus-current-source comparisons and indexed membership queries. Use the actual importer projection semantics; check source identity/generation and source stability before and after the proof. No unbounded corpus of message rows/attachment payloads or source text, and no bulk scanning of archived payload bytes.

Facts that merely *originated* from live Apple Messages could have since disappeared; `source_id == live_chat_db`, count/high-water comparisons, and historical import success are not sufficient.

If any currently populated table or preserved cross-reference lacks a reliable reconstruction argument, the aggregate proof must be FALSE/UNKNOWN; **STOP implementation if no safely useful positive class can be proven**. Do not ship a command with a bypass, permissive count heuristic, or claim that “verified live source” proves the whole footprint.

---

# 9. Attachment source-absent debt and preservation

A current Operating Session may legitimately display historical attachment debt that is source-absent and non-actionable. That is **not sufficient for Start Fresh**.

Reject a reset if:

- any required local attachment fact/reference cannot be reconstructed from current authoritative metadata;
- any graph-to-attachment / overlay-to-attachment identity relationship could be orphaned by regeneration;
- any source-absent attachment reference relies uniquely on existing import/graph records;
- attachment archive binding, coverage, or actionability is UNKNOWN/conflicting;
- there is a current source-available uncovered attachment requiring specialist work;
- archive relocation/adoption or recovery evidence is pending or incoherent.

Preserve archive payloads and configuration without traversal or mutation. No waiver of source-absent debt; no “attachment archive is a cache” assumption.

---

# 10. Protected historical, retired, corrupt, and unknown blockers

Refuse Start Fresh with a literal, specific reason if any of these are known or cannot be conclusively excluded:

- non-live/historical source registry, imported rows, or donor lineage;
- incomplete/corrupt/unsupported active import or graph evidence;
- explicitly named retired active predecessor databases/sidecars;
- unknown source identity, missing current source fact, changed source sample;
- unavailable/unstable Contacts evidence needed to reconstruct current projection;
- conflicting overlay/Presence/attachments/location/journal/lease evidence;
- uninspectable protected file or unverifiable preservation witness;
- changed root/UUID/generation/scope or another currentness/mutation flight.

`FALSE` and `UNKNOWN` are distinct. A human confirmation cannot convert either into TRUE.

Operating-owned refusal **does not directly select Diagnostic Review**. If the Operating jurisdiction itself is no longer defensible, close/drain and ask a fresh process to assess. A harmless known refusal may stay in the existing Operating occurrence only if current admission is still proven and currentness safely resumes.

---

# 11. Process-local plan and immutable consent

Implement a typed plan, conceptually `OperatingStartFreshResetPlan`, containing only the exact observable proof and binding needed:

- Operating occurrence/generation and command sequence;
- admitted root, archive UUID, archive location identity/generation;
- source identity and stable sampling witness;
- all consequential import/graph reconstruction evidence or its trustworthy bounded digest;
- protected/retired/historical inventory and preservation witness digest;
- attachment coverage/reference reconstruction condition;
- affected DB basenames and their sidecars;
- relevant `messageDataVersion`, Ball release/generation fence, and worker-drain generation;
- capture time and consent digest.

No durable plan, confirmation, attempt count, cursor, or resumption state.

The confirmation must display exactly what would be deleted and what will be preserved, and state that MessageLens restarts and **fresh AppCzar chooses the next jurisdiction**. Do not promise the next screen will be Onboarding or “nothing will be lost.”

User consent binds to the exact displayed plan digest only. A stale callback cannot confirm a different plan, and confirmation does not grant mutation authority on its own.

---

# 12. Last-moment pre-mutation revalidation

Immediately after the human confirmation and before any Ball admission, re-prove the current destructive-safety predicate and compare the relevant fingerprints/bindings against the accepted plan.

Inside the callback-local mutation scope, independently verify the immutable admitted archive/scope generation and current command occurrence before physical mutation begins.

On any mismatch:

```text
NO deletion
-> release/suppress pending action
-> exact same-Operating resume only if it remains safely admitted
   otherwise stop/drain and request a fresh process assessment
```

Never silently recompute a changed plan under an old confirmation. Never let the user approve an old digest after source or archive facts change.

The proof is bounded current evidence, not a claim that externally mutable Apple source data is frozen for all time. If source instability makes reconstruction uncertain at the destructive boundary, fail closed.

---

# 13. Exactly one typed mutation Ball

Reuse existing typed operation:

`ArchiveMutationOperation.startFresh`

Preferred source-grounded path:

```text
current Operating occurrence / one user command
-> currentness barrier and proof
-> exact confirmation
-> fresh revalidation
-> ArchiveMutationCoordinator.runWithCapability(startFresh)
-> callback-local exact capability
-> lower active-only reset worker
-> physical postcondition
-> return / release Ball
-> terminal drain
-> existing AppCzar development restarter
-> fresh native + Dart admission
-> fresh AppCzar
```

No reset worker self-authorization; no independent nested Ball; no reuse of `ArchiveMutationOperation.localDataRepair`; no mutation capability in Settings presentation. Currentness must be drained before Ball acquisition.

This is an **Operating-internal command**. Do not add its name to `AppCzarVirtualCoordinator` or the top-level host census.

---

# 14. Extract an active-only lower reset worker

Source-trace current `MessageDataResetService` and Local Data Repair's reset/postcondition and implement the smallest safe shared lower mechanics.

The new capability-requiring entry should be conceptually equivalent to:

```text
resetActiveDerivedDataForOperatingStartFresh(
  exact startFresh capability,
  exact current Operating reset plan
)
```

It must:

1. verify the exact callback-local `startFresh` capability and plan;
2. accept only the two active derived families/sidecars;
3. require no retired artifact in the current admissible plan and use `includeRetired: false`;
4. capture/prove protected witnesses before mutation;
5. **fail hard** if either affected active DB provider cannot close; no deletion may follow an unproven close;
6. delete only the enumerated targets through existing trusted file-store mechanics;
7. invalidate appropriate graph/import providers and message-data generation only within authorized mechanics;
8. verify every authorized target is absent;
9. verify all preserved top-level witnesses, marker/UUID/location/binding, and retired entries are unchanged;
10. return an exact **physical** terminal result, never a semantic “virgin”/“Onboarding” result.

Don't silently change the already-qualified behavior of Local Data Repair or legacy production Start Fresh. If the strict close contract requires refactoring, preserve existing callers' semantics behind explicit APIs and tests. If that cannot be done without broad changes, STOP.

The witness must not recursively hash a real attachment archive; isolated fixture payload sentinels suffice for authorized tests. Do not claim all external bytes were independently read without doing so.

---

# 15. Success/failure/restart terminals

## Cancel or refusal before mutation

If no deletion could have begun:

- release command admission;
- show literal reason;
- do not invoke reset or restarter;
- allow same-Operating currentness resume only after exact currentness/session fact proof;
- ordinary Quit drains without relaunch.

## Success after mutation

```text
exact physical postcondition PASS
-> Ball released
-> stopAndDrain exact Operating occurrence
-> request one qualified development process restart
-> old PID exits
-> fresh PID performs archive admission and AppCzar assessment
```

The old process cannot claim that the dataset is semantically “virgin” or that Onboarding will follow.

## Failure after mutation may have begun

- do not retry reset in-process;
- do not resume Operating or source monitor;
- release the one Ball;
- drain and request one real restart for fresh physical assessment;
- if restart scheduling fails, show a terminal fail-closed state directing the user to Quit and manually relaunch;
- do not run a second restarter automatically.

Quit during mutation waits for exact Ball tenure/future to settle; never terminate the process mid-mutation as a user-visible success path.

---

# 16. UI and Settings routing

Reuse the existing Settings row, description, dispatcher/spec, and action-list single-flight UX. Avoid cloning a Settings system.

Provide a narrow composition/occurrence-aware command adapter so:

```text
legacy production composition (activation OFF)
    -> existing legacy AdvancedStartFreshAction, unchanged

AppCzar Operating in the officially admitted development composition
    -> new Operating-owned Start Fresh command

any other AppCzar jurisdiction
    -> action unavailable / no command admission
```

Do not route to legacy Start Fresh when an AppCzar command is unavailable. A stale Settings resolver must never leak into Journey.

Mount a small Operating-local host for preparation, proof, confirmation, progress, cancellation, and terminal messages, next to the existing Operating currentness status host. Disable ordinary browsing/provider-triggered affected DB work while the exclusive command barrier is held, and prevent background provider creation after the strict close.

Use exact factual copy. Confirmed protection and reconstruction should be spelled narrowly; errors may describe missing source rows, protected historical material, or unavailable evidence without blame or inferred failure history.

Never mount `AdvancedStartFreshOverlayHost`, legacy Journey, or Environment Readiness.

---

# 17. Process restarter and production guard

Use the already qualified, existing `appCzarProcessRestarterProvider`, authorized for official development AppCzar composition only. No generic `Process.start`, direct `/usr/bin/open`, or new restart daemon in this command.

Do NOT broaden `AppCzarDevelopmentCompositionPolicy`, create a production restarter, or enable the production composition.

Production remains:

```text
ProductionAppCzarActivation.disabled
-> StartupApp
-> existing legacy production Reset action
```

A synthetic production-eligible authority may be used only in source-only tests. No real production app install/launch.

---

# 18. Focused constructive tests — positive eligibility

Use only temporary synthetic source/MessageLens/attachment fixtures and project schema APIs. Test at minimum:

1. complete, coherent **populated** import + graph with all affected imported material and graph facts provably reconstructible from the current synthetic Messages/Contacts sources;
2. populated chat/handle/join/attachment/FTS families included in the proof, not ignored;
3. exact source registry, provenance and projected foreign-key/identity equality;
4. graph-to-overlay and graph-to-attachment identity references have no unique loss;
5. every active reset file/sidecar appears in the authorized plan when present;
6. one current Operating session can produce one exact confirmation plan;
7. confirmation authorizes only the identical plan/digest;
8. no private message bodies/attachment bytes exposed in UI/logs;
9. bounded page sizes and stable source before/after sample;
10. no source/graph database creation by a read-only preflight.

A positive fixture that populates only one message and leaves graph absent is NOT enough for Stage 2C. If complete-Operating positive reconstructibility cannot be demonstrated, STOP: do not ship a permissive button or reset.

---

# 19. Focused refusal / negative fixtures

Test, separately and with before/after byte/hash preservation:

- message imported from live source but no longer in current source;
- source-key/GUID mismatch with matching or greater count/high-water;
- chat/handle/join mismatch;
- attachment metadata/join mismatch;
- non-reconstructible rich-text/enrichment fact;
- graph-only consequential fact or inconsistent FTS projection;
- overlay saved identity/reference that would be stranded;
- known source-absent attachment debt;
- current uncovered attachment repair opportunity;
- unknown/conflicting coverage, binding, lease, journal or location;
- historical/non-live source registry or donor;
- retired base/WAL/SHM anywhere in the audited set;
- corrupt/unreadable import, graph, overlay or Presence;
- unsupported schema; missing/unstable source or Contacts observation;
- stale source read, root identity/UUID, archive location generation, graph generation, mutation fence, or Operating occurrence;
- human confirmation from replaced/stale command;
- double-click and cancel during evidence reads;
- mutation authority refused;
- failure to close either affected provider;
- partial deletion, surviving sidecar, collateral protected-witness change, or postcondition failure;
- restart scheduling failure after mutation.

No refused case may delete anything. For a failure **after mutation begins**, verify terminal drain/restart without in-process repair retry.

---

# 20. Concurrency and lifecycle tests

At minimum prove:

1. exactly one currentness scheduler exists under Operating;
2. closing the command barrier synchronously prevents the next 15-second tick and any new update/preservation flight;
3. an already-running live update/attachment preservation finishes before Ball request;
4. the command does not await itself through `stopAndDrain()`;
5. cancel/pre-mutation refusal resumes one scheduler only for the same safe Operating occurrence;
6. stale/mismatched occurrence cannot resume, mutate, or publish;
7. no currentness cycle resumes after any deletion may have begun;
8. exact one typed startFresh Ball tenure, no nested tenure;
9. failure before deletion has no restart unless current jurisdiction became unsafe;
10. successful reset and post-admission failure both release Ball and then restart once;
11. OS Quit before confirmation drains normally; during mutation awaits tenure;
12. restart scheduling failure leaves restricted terminal state, no duplicate restarter;
13. no same-PID transition into Onboarding/Diagnostic;
14. legacy `chatDbChangeMonitorProvider` and Journey are never constructed below the AppCzar Operating Start Fresh host;
15. Settings stale/double-dispatched action never gets a second dialog, reset, or provider graph.

---

# 21. Legacy and architecture regression safeguards

Require source-level tripwires for:

- seven-and-only-seven top-level AppCzar dispositions;
- Start Fresh as an Operating-local command, not AppCzar evaluator input;
- no Operating Start Fresh import of Journey, StartupApp, Onboarding operation, Environment Readiness, support telemetry, legacy monitor, old Advanced Start Fresh action, or legacy reset semantic service;
- no mutation/capability in Settings presentation;
- lower reset worker independent of AppCzar/Settings/UI;
- exactly one `startFresh` Ball edge for the new command;
- no use of self-authorizing reset entry and no retired cleanup;
- no old process Onboarding handoff;
- production disabled activation / legacy route / development-only restarter preserved;
- adoption root/UUID operation gate remains narrow and untouched;
- Stage 2A and 2B support/source evidence remain read-only and non-authorizing;
- Historical Archives and Attachment Archive Repair authorities remain separate;
- existing Local Data Repair reconstructibility and postconditions not weakened.

Do not solve architecture failures by excluding tests or widening forbidden-import allowlists without demonstrating the specific safe edge.

---

# 22. Validation and build policy

After implementation run:

- exact new plan/reconstructibility focused tests;
- Settings dispatcher and legacy Start Fresh regressions;
- currentness suspension/concurrency/restart tests;
- reset-service active/retired/preservation tests;
- Local Data Repair regression suite;
- AppCzar evaluator/coordinator/Operating suites;
- Stage 2A Coverage and Historical Archives;
- Stage 2B Send Logs and Environment Summary;
- archive admission, location/adoption/relocation, typed authority tests;
- complete architecture/forbidden-import suite;
- `flutter analyze`;
- complete deterministic `flutter test`;
- Riverpod/generated consistency;
- Dart formatting and `git diff --check` / `git diff --cached --check`;
- canonical Project Conformance audit.

If a user-facing development AppCzar Reset action is now enabled, advance version/build per project policy and build the exact debug **MessageLens Development** artifact for subsequent separate isolated qualification. **Do not launch** or exercise the destructive command here. Report exact path, bundle/build identity, executable SHA-256 and App.framework SHA-256.

No real database/archive source; no production build or install; no FDA/TCC changes. Native testing only if native source/contract actually changes, which is not expected.

Conformance target:

```text
PROJECT CONFORMANCE: PASS
BLOCKER: 0
SHOULD FIX: 0
```

---

# 23. Implementation checkpoints and source hygiene

After passing validation:

1. stage only intended Stage 2C implementation/source/generated/tests/release metadata;
2. commit one narrow implementation checkpoint;
3. push normally as a recovery anchor;
4. record exact implementation tree, test counts, build identity;
5. checkpoint Prompt 91 and Response 91 documentation only, according to the existing feature convention;
6. push normally;
7. verify clean tracked worktree/index, upstream `0/0`, pinned shared submodule, and unrelated untracked files untouched.

Recommended implementation subject:

`feat(startup): add Operating-owned AppCzar Start Fresh`

If implementation stops at a safety gate, report honestly, preserve useful isolated tests/work if appropriate, and **do not claim executable Stage 2C**. Do not commit a permissive partial reset path.

---

# 24. Next-stage qualification (plan only)

A separate Prompt 92 or subsequent qualification must use fresh disposable archives, source fixtures, and the exact verified development artifact, covering:

- one complete/current, populated Operating graph and current-source reconstructibility TRUE;
- one explicit human confirmation, one exact active reset and physical postcondition;
- protected overlay/Presence/marker/archive/bookmark/journal/retired/attachment witnesses unchanged;
- a real old-PID/new-PID boundary and fresh AppCzar selection;
- cancel/no-mutation/no-restart;
- missing current source row, protected history, retired/corrupt/unknown evidence refusal;
- source-absent attachment debt refusal;
- an update/currentness flight already running before the command, proving drain-before-Ball;
- quit and restart-failure behavior;
- no Journey/legacy worker, no other top-level jurisdiction, no production activation.

Do not create/run these human fixtures in Prompt 91. Do not access the real WD development data or Toshiba payload archive.

---

# 25. Stop gates

STOP AND REPORT immediately if:

- exact current graph/import/overlay reconstructibility cannot be proved across the complete active deletion footprint;
- positive proof relies only on live provenance, message counts, high-water, or a graph-empty fixture that could never be admitted as Operating;
- any protected historical, retired, Presence, overlay, location, archive, attachment, journal, or operation-evidence content would be deleted or rewritten;
- a source-absent required attachment reference would be lost;
- any unknown or stale fact would require a consent override;
- currentness cannot be synchronously barred and its active work drained **before** Ball acquisition;
- provider close can fail and deletion still continue;
- an independent second Ball is necessary;
- legacy StartFreshService/Journey/Onboarding needs to own the new command;
- the only successful terminal would depend on an in-process Onboarding handoff;
- any source change requires enabling production AppCzar or broadening the development restarter/adoption gate;
- a source/test/build run would touch real MessageLens roots or Apple Messages outside permitted temp fixture sources;
- conformance cannot reach PASS with BLOCKER 0 and SHOULD FIX 0.

If the safer result is to implement the **read-only plan/refusal UI only**, do not call that full Stage 2C success. Report the exact incomplete boundary and propose a small follow-up milestone.

---

# 26. Required Response 91

Create Response 91 and report:

1. exact Git baseline/ancestry/branch/submodule/worktree;
2. Prompt 90 / Response 90 docs checkpoint commit and push;
3. current seven-jurisdiction census and production-disabled selector;
4. exact legacy Settings dispatch and Start Fresh dependency graph;
5. reuse/extraction table (not reinvention);
6. selected Operating occurrence and command admission predicate;
7. reversible currentness-suspension API and single scheduler invariant;
8. active-flight drain-before-Ball proof;
9. deadlock/self-await prevention;
10. exact populated-graph reconstructibility strategy;
11. complete active import table/domain inventory;
12. graph/FTS and overlay-reference proof;
13. Contacts/source membership and identity/generation proof;
14. attachment metadata, debt and archive-reference safety;
15. protected/retired/historical/unknown rejection matrix;
16. exact plan and consent digest binding;
17. immediately pre-Ball revalidation and callback-local scope check;
18. exactly one typed `startFresh` capability tenure;
19. lower reset extraction and active-only deletion inventory;
20. provider close fail-hard proof;
21. exact protected physical witness and reset postcondition;
22. refusal/cancel terminal and safe currentness resume;
23. success terminal, Ball release, drain and restart;
24. partial-mutation/postcondition-failure terminal;
25. restart-failure terminal and manual quit guidance;
26. Settings row/dispatcher/legacy fallback separation;
27. one Operating-local UI/lifecycle host;
28. no Journey, old monitor, or additional startup authority;
29. production default-off and development-only restarter proof;
30. positive constructive **populated Operating graph** tests;
31. missing-source, missing-attachment, protected/retired/corrupt/UNKNOWN test results;
32. concurrent currentness update/drain/cancel/stale tests;
33. capability/worker/postcondition failure tests;
34. legacy Start Fresh, Stage 2A/2B, seven-jurisdiction regressions;
35. complete architecture and forbidden-import result;
36. full Flutter and analyzer results;
37. generated/format/diff hygiene;
38. Project Conformance, BLOCKER/SHOULD FIX findings;
39. implementation commit and pushed recovery anchor;
40. Prompt 91/Response 91 documentation checkpoint;
41. exact development artifact path/version/hashes (if built);
42. final Git/upstream/index/worktree/submodule state;
43. readiness for **separate disposable** Stage 2C human qualification;
44. readiness for Stage 2D production-safe shell;
45. readiness for signed production rehearsal and actual cutover.

Conclude exactly:

```text
START FRESH IS OPERATING-OWNED AND IS NOT AN EIGHTH JURISDICTION: YES / NO
EXACT POPULATED DERIVED FOOTPRINT IS PROVEN RECONSTRUCTIBLE BEFORE RESET: YES / NO
PROTECTED NON-LIVE, RETIRED, SOURCE-ABSENT, AND UNKNOWN FACTS BLOCK RESET: YES / NO
OPERATING CURRENTNESS DRAINS BEFORE START FRESH BALL: YES / NO
CANCEL BEFORE MUTATION CAN SAFELY RESUME ONLY THE SAME OPERATING OCCURRENCE: YES / NO
START FRESH USES EXACTLY ONE CALLBACK-LOCAL TYPED BALL: YES / NO
ACTIVE-ONLY RESET HAS FAIL-HARD CLOSE AND PHYSICAL PRESERVATION POSTCONDITION: YES / NO
START FRESH ENDS AFTER MUTATION WITH REAL RESTART AND FRESH APPCZAR: YES / NO
LEGACY PRODUCTION START FRESH REMAINS UNCHANGED: YES / NO
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO
PROJECT CONFORMANCE: PASS / FAIL
STAGE 2C IMPLEMENTED: YES / NO
READY FOR ISOLATED STAGE 2C HUMAN QUALIFICATION: YES / NO
READY FOR STAGE 2D PRODUCTION-SAFE SHELL CONSTRUCTION: YES / NO
READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
```

Then STOP.
