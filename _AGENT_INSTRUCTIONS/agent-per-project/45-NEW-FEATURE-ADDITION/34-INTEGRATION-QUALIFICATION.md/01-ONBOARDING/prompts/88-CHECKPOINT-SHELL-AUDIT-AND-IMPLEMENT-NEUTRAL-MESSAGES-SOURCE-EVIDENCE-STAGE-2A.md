# MessageLens — Feature 34
## 88 — Checkpoint Production-Safe Shell Audit; Implement Neutral Current-Messages Source Evidence (Stage 2A Only)

Response 87 completed a read-only audit of production-safe Operating-shell dependency closure. The result was **PASS (audit/design scope)**. It found that `MessageLensWorkspaceShell` and the ordinary browsing/navigation components are reusable; the production `StartupApp`/`App` wrapper, Journey/Environment consumers, and ambient `chatDbChangeMonitorProvider` are not acceptable under production AppCzar. Production AppCzar activation remains **unconditionally OFF**.

The next dependency is deliberately narrow:

> **Extract or reuse exactly one source-neutral, read-only current-Apple-Messages path/readability evidence boundary and make Message History Coverage and Historical Archives use it without depending on Onboarding startup authority.**

Do not build a second fact system. Do not reinterpret Full Disk Access. Do not change who selects startup jurisdiction. Do not create an eighth AppCzar jurisdiction.

This is **Stage 2A only**. Stage 2B support/Environment evidence, Stage 2C voluntary Start Fresh design, Stage 2D shell composition, Stage 2E parity/lifecycle closure, Stage 2F rehearsal, production restarter, and production activation are all outside this prompt.

### Absolute prohibitions

- DO NOT enable production AppCzar. Its activation must remain unconditionally false.
- DO NOT change production startup: official production must still select `StartupApp`.
- DO NOT change development AppCzar coordinator selection, source-access semantics, or existing seven-jurisdiction census.
- DO NOT construct `App`, `StartupApp`, Journey, Environment Readiness, or the legacy monitor from any new neutral seam.
- DO NOT introduce a second Messages source-path resolver or an independent FDA/readiness authority.
- DO NOT change import, graph, archive, historical-source mutation, coverage, repair, adoption, relocation, or Start Fresh operations.
- DO NOT access a real MessageLens archive or SQLite store, Apple Messages/Contacts data, active WD development root, or Toshiba archive.
- DO NOT build, launch, install, or sign a MessageLens application; do not change release metadata, entitlements, bundle identities, or TCC.
- DO NOT touch unrelated worktrees or untracked artifacts.

---

# 1. Baseline and exact permitted worktree

Use only:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- HEAD/upstream synchronized `0/0`;
- tracked worktree and index clean;
- one Feature 34 worktree;
- shared-instructions submodule clean and pinned at `95326f515ef4719f155ce6e223990398daad6311`;
- Response 86 implementation `4a8b549e65bf16416065797aeaebde062f8558fd` and documentation `53a695706e483ea6064da2376f4e0edf1ba7f973` in ancestry.

Expected pre-checkpoint HEAD is `53a695706e483ea6064da2376f4e0edf1ba7f973`. Resolve the actual HEAD from Git; do not assume no one has changed the repository.

Read fully:

- Prompt 87 and Response 87;
- Response 85 production-cutover audit;
- Response 86 inactive eligibility implementation;
- the canonical `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md` and project/agent guardrails;
- current source path/readability providers and their tests;
- Message History Coverage presentation/provider/repository;
- Historical Archives panel/workflow model and specialist repositories;
- AppCzar source-readability observer, Source Access Repair, and Onboarding prerequisite reader;
- production and development composition entry points;
- test/architecture rules for forbidden imports and currentness authority.

Create an external, source-only baseline manifest. Do not read real message or archive data.

STOP if the source differs materially from Response 87's ownership inventory.

---

# 2. Checkpoint Prompt 87 / Response 87 before source edits

Prompt 87 was audit-only and its Prompt/Response documents remain untracked.

Create a narrow documentation-only commit containing exactly Prompt 87 and Response 87. Stage their exact paths; **do not use `git add .`**. Run staged-diff and `git diff --cached --check`. Push normally and record the exact commit and upstream parity before touching implementation files.

Preserve accurately:

```text
Stage 2 Operating-shell dependency closure: AUDITED ONLY
Stage 2A neutral source evidence: NOT YET IMPLEMENTED
production activation: UNCONDITIONALLY OFF
production startup: legacy StartupApp
legacy ambient currentness monitor: STILL PRESENT IN LEGACY ROOT
staged production-identity rehearsal: NOT READY
production cutover: NOT AUTHORIZED
PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)
```

No force-push, rebase, squash, merge, branch switch, or unrelated staging.

---

# 3. Current-path/source dependency census before design

Source-trace and report the **exact symbols and runtime edges**, not guessed names, for:

1. The currently authoritative filesystem location of Apple's Messages `chat.db` for this product/runtime.
2. Any native/Dart canonicalization or path identity logic used for read-only Messages access.
3. The existing low-level source reader that distinguishes readable, known denied/unavailable, unstable, and unknown results.
4. The current Onboarding-named Messages path provider and any reader it wraps.
5. Every Message History Coverage usage: file path, read attempt, FDA/permission message, selected source, no-history path, caching/refresh, and error rendering.
6. Every Historical Archives usage: current-live-source identity/path, donor selection, inspection, import/remove/recovery prerequisites, path failure handling, and mutations delegated to specialists.
7. The exact `AppCzarSourceObservation` and Source Access Repair reader dependencies.
8. Any other Onboarding-named provider that these two feature entry points pull into their provider graph (directly or transitively).

Distinguish *path resolution* from *actual read outcome*. A filesystem path's existence, a Settings FDA toggle, and a source-read outcome are different facts. A known denied/unavailable read is not `UNKNOWN` merely because a path exists.

Identify whether an existing neutral lower-level reader can be directly reused. Prefer extraction/relocation or a thin neutral adapter over copying logic.

STOP AND REPORT if the proposed neutral boundary cannot be made without changing the current AppCzar fact meaning or introducing another independently authoritative source locator.

---

# 4. Minimal neutral boundary: one implementation, multiple consumers

Create the smallest named seam consistent with current repository style, in a source-neutral area (for example under `lib/essentials/messages_source/` or an existing lower-level source environment module; let the source architecture decide).

The boundary may expose:

- the currently configured/canonical current Messages source location, if established;
- the literal bounded read result using existing typed source semantics, **only when the consumer actually needs a read**;
- explicit unavailable/denied/unknown/unsupported outcomes without reinterpretation;
- enough identity/binding to avoid silently switching between stale source paths.

The boundary MUST:

- delegate to or extract the existing authoritative source resolver/reader rather than implement another;
- be read-only, lazy, and bounded;
- not eagerly open databases merely because a panel or provider is declared;
- not create a database when it does not exist;
- never write to Apple Messages or MessageLens stores;
- never infer FDA off from a read denial;
- preserve existing source path canonicalization and errors;
- not subscribe to a timer/monitor or start an import;
- not select an AppCzar jurisdiction or carry old Journey status;
- have no archive mutation capability or provider dependency on an unrelated MessageLens data root;
- remain usable inside the existing production **legacy** app and inside AppCzar without changing either composition's authority.

Do not add a new public `ready`, `installed`, `needsRepair`, `canImport`, or `currentness` verdict. This is source evidence, not another classifier.

If consumers need differently shaped projections, use pure adapters over the **same** neutral fact source. Do not fork the underlying reader or cache stale permission claims.

---

# 5. Rewire Message History Coverage only at its source dependency

Replace the coverage feature's direct or transitive Onboarding path/read dependency with the new neutral boundary.

Preserve:

- existing UI, actions, cards, counts, and user-facing words unless one is literally untrue;
- existing source identity and coverage algorithm;
- existing source-read error handling, retry affordance, and disabled state;
- existing path canonicalization and lifecycle/disposal behavior;
- its existing authority (diagnostic/reporting), with no graph import or attachment-preservation mutation;
- the same external Messages source and no fallback to an alternate path.

Avoid loading all messages, deriving a new source-count/high-water truth for AppCzar, or reusing an Onboarding gate as a convenience dependency.

Before/after parity tests should cover readable source, known access denied/unavailable, genuinely unknown as a **unit-test typed observation only**, non-existent source, changing source path/identity, and panel-level failure rendering where current semantics support them. Use temporary fixtures/fakes and deterministic providers, never real chat data.

If the old provider needs to remain for legacy Onboarding, it may become a compatibility adapter **in the Onboarding layer** delegating inward to the neutral provider. The neutral provider must never import outward into Onboarding.

---

# 6. Rewire Historical Archives only at its source dependency

Replace the Historical Archives panel/workflow model's source-path/readability dependency on Onboarding with the **same** neutral boundary.

Retain its existing:

- historical source registry, provenance, donor identities, and protected-material distinctions;
- historical selection/inspection/display behavior;
- import, removal, recovery, authorization, and mutation capabilities;
- human confirmation and preservation rules;
- exact current/live Messages source resolution semantics;
- existing cancellation/retry/lifecycle behavior.

Do not move the historical import/remove worker or register a new AppCzar coordinator. Historical management remains an Operating-visible specialist workflow under the eventual neutral shell; it is not automatically invoked by AppCzar.

Evidence change after a historical-source mutation may eventually require an Operating-owned drain/restart; **do not add that lifecycle rewire in Stage 2A**. Record it as the Stage 2E dependency and retain current production legacy behavior unchanged.

Test the historically important cases: current-source location available, known denied/unavailable, source path change, historical donor distinct from live source, a protected non-live donor, no source, and source-read error. Preserve the existing mutation call graph in tests: the neutral source reader must not be able to authorize a historical import/removal action.

---

# 7. Do not silently change AppCzar's assessment authority

AppCzar currently owns the bounded source-readability and source-sampling facts used to select Source Access Repair, Onboarding, Data Update, Operating, or Diagnostic Review.

If the existing AppCzar reader already uses the lower-level neutral source mechanism, leave it unchanged. If extraction can eliminate duplicate low-level path code without a meaning change, demonstrate exact before/after fact parity with tests first. **Default: do not change AppCzar observer/evaluator wiring in this task.**

Preserve strictly:

- TRUE/FALSE/UNKNOWN distinction;
- literal known `accessDenied` versus genuine `UNKNOWN`;
- two-sample currentness/stability semantics;
- no retrospective “FDA is disabled” inference;
- no new source polling, provider auto-initialization, or same-process reclassification;
- no new route into Local Data Repair or any other mutation coordinator.

A source-neutral *observation* provider may be consumed by multiple features, but AppCzar remains the sole owner of the *startup disposition*.

---

# 8. Production, development, and mutation invariants

After this change, prove:

```text
production eligible == TRUE for official admitted production identity
production activation.isEnabled == FALSE (there is no enabled state)
production root == StartupApp

development recognized identities == AppCzarStartupHarness
AppCzar coordinator census == 6 top-level + 1 admitted Operating
```

Explicitly leave unchanged:

- `ProductionAppCzarActivation` and production eligibility policy;
- `main.dart` composition selection and admitted-provider overrides;
- native/Dart archive claim, production-signature validation, root/marker/UUID;
- `MacosDevelopmentProcessRestarter` and restart provider;
- `ArchiveMutationCoordinator` operations/Ball;
- WD/UUID-specific attachment-adoption gate;
- Start Fresh and historical-source mutation semantics;
- source/graph import/update and `chatDbChangeMonitorProvider` (it remains legacy-only; Stage 2D/2E will close AppCzar production reachability).

No new singleton startup observer, source timer, or process global may be created.

---

# 9. Mechanical architecture tripwires

Update or add architecture tests sufficient to prove:

1. Message History Coverage and Historical Archives import/use the neutral source seam, not the Onboarding source-path/readiness provider.
2. The new neutral module does **not** import Journey, Onboarding gate/operation controller, Environment Readiness, AppCzar coordinator/evaluator, support export, database-writer, or archive mutation authority.
3. Exactly one low-level canonical Messages source resolution implementation exists for the two rewired features; no duplicate hard-coded `chat.db` path in them.
4. No neutral source provider starts a timer, graph update, attachment sweep, or import.
5. Legacy Onboarding compatibility delegates to neutral facts if retained; no reverse dependency/cycle.
6. Historical import/remove mutation edges and typed capabilities remain the same; the neutral seam only contributes source evidence.
7. Production disabled activation, admission-first selection, development policy, and adoption-gate separation remain enforced.
8. AppCzar host census, mutation-edge counts, and forbidden-import rules remain unchanged.
9. No `App`/legacy chat monitor or a second AppCzar currentness controller can be constructed *because the neutral provider was read*.

Use source-aware import/reachability assertions and runtime fake-provider construction tests where possible. Do not enforce brittle internal file names merely for convenience if the substantive boundary can be tested directly.

---

# 10. Focused source-evidence parity tests

Use only synthetic source fixtures, isolated temporary SQLite databases if essential, and fakes. Do not open the real Messages or MessageLens database.

Required assertions:

- canonical path and existing source-selection precedence are unchanged;
- readable source result preserved;
- known denied/unavailable preserves its exact literal state;
- `UNKNOWN` remains `UNKNOWN` in controlled unit tests; no attempt to fabricate a live UNKNOWN;
- nonexistent/corrupt source remains factual and no new file is created;
- canonical/symlink path behavior matches current trusted reader;
- source path or identity change does not continue using an old cached value;
- `Message History Coverage` receives exactly the former supported evidence and no new startup semantics;
- `Historical Archives` keeps its existing donor/provenance separation;
- neither feature imports/initializes Onboarding/Journey action providers;
- neither starts the legacy monitor or AppCzar Operating currentness;
- no mutation capability is requested by source reads.

If the existing test fixtures cannot safely express a case, use a pure fake/typed observation; never alter global OS permissions or production data.

---

# 11. Regression and validation matrix

Run at least:

1. new neutral source reader/resolver tests;
2. Message History Coverage feature/provider/widget tests;
3. Historical Archives feature/provider/workflow tests;
4. Onboarding source-prerequisite tests;
5. AppCzar Source Access Repair and evaluator source/readability tests;
6. AppCzar Operating currentness tests;
7. source-scoped import/graph tests affected by the changed dependencies;
8. historical mutation authority regression tests;
9. startup composition / inactive production eligibility tests;
10. exact attachment-adoption gate tests;
11. full architecture/forbidden-import suite;
12. `flutter analyze` with zero issues;
13. full deterministic `flutter test` suite (report passes/skips);
14. formatting, generated-code consistency, `git diff --check`, and staged-diff check.

Do **not** run a human/live integration test or build/install/launch a MessageLens app in this prompt. Do not change `pubspec.yaml`, release metadata, signing, entitlements, or app bundle identity unless a hard compilation necessity arises; if so, STOP and report first.

---

# 12. Checkpoint and push only if validation passes

When and only when the source/test changes pass the gates:

1. stage the exact intended source/test/generated files by path;
2. audit `git diff --cached --stat` and every staged file against the scope;
3. run `git diff --cached --check`;
4. create one narrow implementation checkpoint, suggested subject:

   `refactor(source): share neutral Messages source evidence`

5. push the implementation commit normally;
6. create Response 88 and checkpoint Prompt 88/Response 88 only, per Feature 34 documentation convention;
7. push the documentation checkpoint normally;
8. leave all unrelated untracked files, other worktrees, and the shared submodule untouched.

Do not call the change a completed production shell or a production cutover.

---

# 13. Stage 2C architectural question to record, not resolve here

Response 87 calls for an “AppCzar-owned Start Fresh coordinator.” Before Stage 2C implementation, a separate design decision must resolve whether this is an **Operating-owned command occurrence** (or another explicitly allowed in-jurisdiction lifecycle) rather than an eighth top-level AppCzar disposition.

**Do not add an eighth AppCzar jurisdiction as a side effect of Stage 2A.** Do not conflate voluntary user-initiated Start Fresh with system-selected Local Data Repair. Merely record this review item for the later Stage 2C prompt.

---

# 14. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with `BLOCKER: 0` and `SHOULD FIX: 0` **for this narrow implementation scope**.

Verify explicitly:

- one source of truth for current Messages path/read evidence;
- no new semantic startup authority;
- neutral evidence reused rather than reimplemented;
- path/read/UNKNOWN behavior unchanged;
- no new I/O or provider initialization before admission;
- no source or archive mutation;
- no historical-source authority change;
- legacy production behavior unchanged;
- development AppCzar behavior unchanged;
- no production activation/restart/signing change;
- no second currentness monitor in the neutral seam;
- future Stage 2 backlog remains distinct.

If implementation reveals that source selection, reader identity, or caller behavior **cannot** be preserved without changing startup semantics, STOP AND REPORT instead of expanding scope. An honest partial result is preferable to unreviewed feature regression.

---

# 15. Required Response 88

Create `88-CHECKPOINT-SHELL-AUDIT-AND-IMPLEMENT-NEUTRAL-MESSAGES-SOURCE-EVIDENCE-STAGE-2A.md` under the appropriate Feature 34 `01-ONBOARDING/responses/` folder and report:

1. exact baseline and Prompt/Response 87 documentation checkpoint;
2. current Git HEAD/upstream/submodule/worktree inventory;
3. exact existing Onboarding-named Messages path/read providers;
4. exact current Messages path/canonicalization reader and policy;
5. exact Message History Coverage usage/call graph;
6. exact Historical Archives usage/call graph;
7. AppCzar source reader/evaluator sharing or separation;
8. chosen neutral module and why it is a true reuse/extraction;
9. read-only typed evidence semantics including known false versus unknown;
10. source-path cache/change/identity handling;
11. old Onboarding compatibility adapter, if retained;
12. Message History Coverage changes and parity;
13. Historical Archives changes and parity;
14. mutation/source-provenance noninterference;
15. architecture/forbidden import tripwires;
16. focused neutral-reader tests;
17. coverage-feature test results;
18. historical-feature test results;
19. Onboarding and AppCzar regression results;
20. Operating currentness/legacy-monitor noninitialization proof;
21. production legacy selector/disabled-activation tests;
22. architecture suite results;
23. analyzer result;
24. full Flutter suite results;
25. generated/format/diff hygiene;
26. Project Conformance audit result;
27. BLOCKER and SHOULD FIX findings;
28. implementation checkpoint hash and push;
29. Prompt 88/Response 88 documentation checkpoint hash and push;
30. final Git/worktree/index/submodule state;
31. exact Stage 2B dependency readiness;
32. Stage 2C Start Fresh jurisdiction-design open question;
33. staged production-identity rehearsal readiness;
34. actual production-cutover readiness.

Conclude exactly:

```text
RESPONSE 87 AUDIT CHECKPOINTED: YES / NO
NEUTRAL CURRENT-MESSAGES SOURCE EVIDENCE IMPLEMENTED: YES / NO
COVERAGE NO LONGER DEPENDS ON ONBOARDING SOURCE AUTHORITY: YES / NO
HISTORICAL ARCHIVES NO LONGER DEPENDS ON ONBOARDING SOURCE AUTHORITY: YES / NO
EXISTING SOURCE READ / KNOWN FALSE / UNKNOWN SEMANTICS PRESERVED: YES / NO
NO ADDITIONAL CURRENTNESS WORKER OR SEMANTIC OWNER INTRODUCED: YES / NO
HISTORICAL AND ATTACHMENT MUTATION AUTHORITY UNCHANGED: YES / NO
PRODUCTION APPCZAR ACTIVATION REMAINS UNCONDITIONALLY OFF: YES / NO
PRODUCTION STILL USES LEGACY STARTUPAPP: YES / NO
DEVELOPMENT APPCZAR COMPOSITION UNCHANGED: YES / NO
PROJECT CONFORMANCE: PASS / FAIL
READY FOR STAGE 2B: YES / NO
READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
```

Then STOP. Do not start Stage 2B, Stage 2C, a shell refactor, a production restarter, or any production activation.
