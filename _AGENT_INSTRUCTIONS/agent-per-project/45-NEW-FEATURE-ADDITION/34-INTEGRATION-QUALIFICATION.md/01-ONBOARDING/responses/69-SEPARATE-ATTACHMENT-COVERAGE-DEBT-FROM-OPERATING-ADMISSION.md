# MessageLens Feature 34
## Response 69 — Separate Attachment Coverage Debt from Operating Admission and Live-Update Success

Date: 2026-10-05

Prompt 69 is complete. Attachment coverage remains a literal preservation fact,
while current repair opportunity is now a separate Fair-Witness fact used for
AppCzar jurisdiction and Operating continuation. No historical exemption,
waiver, grandfathering rule, or debt baseline was introduced.

1. Baseline verification

   - Branch: `fix/onboarding-import-stuck-state`.
   - Starting HEAD/upstream:
     `cb0de75389962ec339ac14ba9a980b01526568a6`, ahead/behind `0/0`.
   - The tracked worktree and index were clean.
   - The shared-instructions submodule was clean at
     `95326f515ef4719f155ce6e223990398daad6311`.
   - Exactly one Feature 34 worktree was active.
   - The known unrelated untracked entries were inventoried and left untouched.
   - External baseline manifest:
     `/private/tmp/messagelens-prompt69-baseline-20261005T181455Z.txt`.
   - Manifest SHA-256:
     `bad8a317dc8874211bfa7cb5277bc8617c2cca74f208351d8ed74e5aa5b2f352`.

2. Response 68 documentation checkpoint

   Prompt 68 and Response 68 were checkpointed before semantic implementation
   as commit `59d6b5c2` with subject
   `docs(feature-34): record bounded repair qualification`. That preserves the
   qualified six-payload repair result as immutable evidence before changing
   Operating admission.

3. Audit of every global-coverage operability gate

   The audit found four relevant decision sites:

   - `AppCzarEvaluator` treated coverage FALSE as unconditional Attachment
     Archive Repair jurisdiction and coverage UNKNOWN as diagnostic.
   - `shouldExecuteAppCzarOperatingSession` required coverage TRUE.
   - `AppCzarOperatingCurrentnessController` required coverage TRUE both at
     Operating admission/currentness evaluation and before and after a live
     update.
   - Attachment Archive Repair accepted the coverage-deficit diagnosis without
     independently requiring actionable current repair evidence.

   Coverage presentation and the coverage reader were also audited. They are
   evidence surfaces, not jurisdiction authorities. Data Update and Source
   Access Repair did not contain an additional global-coverage admission gate.

4. Preserved coverage-complete semantics

   `attachmentCoverageComplete` is unchanged in meaning:

   - TRUE only when every required payload has current durable coverage;
   - FALSE when at least one required payload is conclusively uncovered;
   - UNKNOWN when completeness cannot be established from coherent current
     evidence.

   Source-absent payloads remain in the required universe and therefore keep
   the fact FALSE. No item is marked covered merely to admit Operating.

5. Repair-actionability evidence model

   One shared read-only boundary,
   `AttachmentRepairabilityEvidenceReader`, now combines the canonical
   `RequiredAttachmentEvidenceReader` with current Messages attachment-source
   evidence. It supplies the same bounded partition to AppCzar startup,
   Attachment Archive Repair, and Operating post-update currentness. The
   result carries stable archive binding/generation evidence and the counts for
   covered, source-available, source-absent, source-unknown, record-backed, and
   unsafe/conflicting items. Available batch items remain memory-only and
   bounded to one batch.

6. Source-available, source-absent, and UNKNOWN definitions

   - Source-available: a required uncovered payload has current readable source
     evidence in Messages and can presently be considered for bounded repair.
   - Source-absent: the required payload is conclusively not present at its
     current Messages source; it remains uncovered and required, but automatic
     repair has no current source bytes to preserve.
   - UNKNOWN: the source could not be classified conclusively, the evidence
     changed while being sampled, its binding changed, or unsafe/conflicting
     evidence prevents a literal classification.

7. Derived repair-opportunity proposition

   `attachmentRepairOpportunityPresent` is now a separate fact:

   - TRUE when at least one uncovered payload is currently source-available;
   - FALSE only when current automatic repair opportunity is conclusively
     absent;
   - UNKNOWN for inconclusive, unavailable, changed, unsafe, or conflicting
     repairability evidence.

   Record-backed recovery remains an explicit Repair jurisdiction trigger; it
   is not silently collapsed into the automatic-opportunity proposition.

8. Operating-safe attachment-evidence predicate

   `isOperatingSafe` requires a complete, internally consistent partition;
   zero source-available items; zero source-unknown items; zero record-backed
   recovery items; and zero unsafe/conflicting items. Operating separately
   requires coherent archive identity/generation binding, a known coverage fact
   (TRUE or FALSE), and repair opportunity FALSE. Therefore repair opportunity
   FALSE is necessary in the debt case but is not independently sufficient.

9. Exact fresh AppCzar disposition rules

   - Coverage TRUE plus coherent, operating-safe repairability continues normal
     Operating evaluation.
   - Coverage FALSE plus source-available work selects Attachment Archive
     Repair.
   - Coverage FALSE plus record-backed recovery work selects Attachment Archive
     Repair.
   - Coverage FALSE plus only conclusive source-absent debt may select Operating,
     subject to every other Operating prerequisite.
   - Coverage UNKNOWN, repairability UNKNOWN, an incoherent binding, or
     unsafe/conflicting evidence selects Diagnostic Review.
   - Archive unavailable remains governed by the archive-availability decision
     and cannot accidentally execute coverage Repair.

10. Real-state-shaped evaluator result

    The exact fixture `18,281 required / 4,446 covered / 13,835 uncovered`, with
    `0` source-available, `13,835` source-absent, `0` source-unknown, `0`
    record-backed, and `0` unsafe/conflicting, keeps coverage FALSE, derives
    repair opportunity FALSE, produces the diagnosis
    `operatingWithKnownAttachmentDebt`, and selects the Operating session.

11. Operating debt presentation

    Operating receives the current debt and source-absent counts and presents a
    compact, nonblocking factual status. It says that required attachment
    payloads remain uncovered and are currently absent from Messages. It does
    not say that they are lost, safe, repaired, complete, waived, or exempt.
    Navigation remains available.

12. Attachment Archive Repair selection change

    Repair is no longer selected solely because global coverage is FALSE. It is
    selected only when the fresh partition contains current source-available
    work or record-backed recovery work. The Repair controller also validates
    that the admitted assessment actually contains the repair-opportunity fact,
    preventing source-absent-only debt from entering Repair by stale or partial
    diagnosis.

13. Operating admission-controller change

    Operating no longer requires coverage TRUE. It requires coverage to be
    known, repair opportunity to be FALSE, repairability to be operating-safe,
    and its binding to be coherent, in addition to the existing data-root,
    database, dataset, archive-availability, delta, and source-ahead facts.

14. Stage Two post-live-update semantic change

    The post-update condition now asks whether current attachment evidence
    still permits Operating, rather than whether all historical required
    payloads are covered. It verifies the same archive location, scope,
    generation, coherent coverage/repairability binding, known coverage, and
    operating-safe current partition. Known source-absent historical debt may
    therefore remain visible after a successful live update.

15. Post-update source-available behavior

    If a newly uncovered payload is currently source-available, Operating
    publishes an attachment issue, stops and drains the admitted occurrence,
    and crosses a restart boundary. Fresh AppCzar then owns the jurisdiction
    decision and can select Attachment Archive Repair. Operating does not hand
    off directly.

16. Post-update source-absent-only behavior

    If the fresh partition is coherent and contains only known source-absent
    uncovered debt, Operating returns to idle in the same PID and occurrence.
    The current navigation selection is preserved, and the truthful debt count
    remains visible.

17. Post-update UNKNOWN/conflict behavior

    Source-unknown, changed, incoherent, unsafe, conflicting, or record-backed
    evidence does not return Operating to idle. Operating publishes a fail-
    closed issue, stops and drains, and restarts so fresh AppCzar can select the
    proper jurisdiction. No uncertain item is treated as source-absent.

18. Crash/restart safety analysis

    The design stores no debt admission, waiver, or repair-opportunity memory
    across a process boundary. A crash before completion leaves the durable
    archive and databases as they actually are. Every restart re-reads the
    canonical required universe, current source evidence, archive identity, and
    generation before AppCzar decides again. A live-update occurrence cannot
    retain capability or authorize the next occurrence.

19. Proof no historical debt baseline is used

    Production code and architecture tests contain no historical-debt,
    grandfathering, waiver, exemption, or accepted-baseline state. The decision
    compares no previous count with a current count. Authority is derived only
    from the fresh bounded partition and its coherent current binding.

20. Performance and conditional evaluation

    The complete-coverage fast path performs two bounded summary reads to prove
    stability and does not open the current Messages source or enumerate the
    full partition. When coverage is incomplete, the shared reader retains the
    existing page bound of `75`. For the `18,281`-item real-state shape, one
    pass is `244` pages and the stable read/partition/read sequence is `732`
    bounded required-evidence page reads. Source observations are requested in
    bounded groups of at most `75`, available batch material is capped at one
    batch, and payload bytes are not scanned or hashed by the evidence read.

21. AppCzar evaluator tests

    PASS. Tests cover complete coverage, source-available incomplete coverage,
    source-absent-only debt, UNKNOWN, unsafe/conflicting evidence,
    record-backed recovery, archive unavailability, binding incoherence, and
    the exact `18,281/4,446/13,835` fixture.

22. Repairability-partition tests

    PASS. The new shared-reader suite verifies stable partitioning, source-
    absent items remaining required, complete fast-path behavior, bounded
    available items, source unavailability, sample mismatch, binding change,
    stop behavior, and exact count coherence.

23. Operating admission tests

    PASS. Tests prove that known source-absent debt can be admitted only with a
    FALSE repair-opportunity fact and operating-safe coherent evidence; UNKNOWN,
    actionable, record-backed, conflicting, or binding-incoherent evidence is
    rejected. The navigation-preservation regression also passes.

24. Operating currentness tests

    PASS. Text-only and attachment-bearing same-session updates return to idle
    with source-absent debt and preserve navigation after new payload
    preservation. Source-available, UNKNOWN, binding-change, archive-location,
    stop-and-drain, and restart regressions pass.

25. Repair regressions

    PASS. Bounded consent, one-batch scope, private immutable plan handle,
    exact identity validation, no automatic refill, mutation Ball authority,
    source-absent classification, and controller/screen regressions pass.

26. Prompt 59 coverage regressions

    PASS. Literal coverage completeness, required-universe membership,
    coherent binding, incomplete/unknown classification, and the coverage
    presentation remain intact. The new actionability fact did not weaken the
    Prompt 59 preservation fact.

27. Data Update regressions

    PASS. Data Update controller and presentation regressions passed. Its
    coordinator ownership and restart boundary are unchanged.

28. Source Access Repair regressions

    PASS. Source Access Repair controller and presentation regressions passed.
    Its fresh source observation, FALSE/UNKNOWN distinction, and restart
    boundary are unchanged.

29. Architecture result

    PASS. The full architecture suite passed `595` tests. It enforces the
    singular shared repairability reader, canonical required-evidence SQL
    ownership, exact fact separation, no debt history/waiver/baseline, bounded
    work, and the existing top-level execution census.

30. Analyzer result

    PASS. `flutter analyze` completed with status `0` and
    `No issues found!`.

31. Full Flutter-suite result

    PASS. The deterministic full Flutter suite completed with status `0`:
    `3,019` tests passed, one explicitly skipped qualification harness, and
    zero failures.

32. Diff, format, and generated hygiene

    PASS. The focused regression bundle passed `136` tests. All `25` changed
    Dart files were formatted, the focused bundle was rerun successfully after
    formatting, `git diff --check` passed, and the staged implementation passed
    `git diff --cached --check`. No provider annotation or generated contract
    changed, so no code generation was required and no generated file was left
    stale or modified.

33. Project Conformance verdict

    `PROJECT CONFORMANCE: PASS`. The full Prompt 69 delta was audited against
    the Project Conformance Standard for reuse, architectural placement,
    dependency direction, authority singularity, bounded work, privacy,
    mutation control, state semantics, dead code, testing, generated/dependency
    hygiene, documentation, and user-visible truthfulness.

34. BLOCKER findings

    `0`.

35. SHOULD FIX findings

    `0`. No optional finding requiring a Prompt 69 change remained.

36. Implementation checkpoint commit

    `05651d0c61115b0eda2e294a349d48fe848096a5`
    (`fix(startup): separate attachment debt from operating admission`). The
    commit contains exactly the intended production code, tests, architecture
    enforcement, release metadata, and changelog update.

37. Documentation checkpoint commit

    The documentation checkpoint is the commit containing Prompt 69 and this
    Response 69. Its exact SHA is reported in the final task handoff after that
    commit is created; no implementation file is included in it.

38. Pushed recovery anchor

    The recovery anchor is the documentation checkpoint containing this
    response, pushed normally to
    `origin/fix/onboarding-import-stuck-state`. Its exact SHA and final `0/0`
    branch relationship are reported in the final task handoff after the push.

39. Exact build identity, path, and hashes

    The exact debug development artifact was built and was not launched.

    - Bundle path:
      `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`.
    - Product/display name: `MessageLens Development`.
    - Bundle identifier:
      `com.bigbenchsoftware.MessageLens.development`.
    - Environment/build identity: `development / developmentDebug`.
    - Version/build: `0.2.138 (156)`.
    - Executable: `MessageLens Development`.
    - Signature: ad hoc; TeamIdentifier not set.
    - Executable SHA-256:
      `cb1c42fb711fb58a0c42f80a8cddfc63d89b48cdf2be34d74f115f6790122e02`.
    - `Contents/Frameworks/App.framework/App` SHA-256:
      `defb7399ca9378688fc90acb240bc943d6f0af3b157811ae43edeb81109092ba`.

    Metadata verification passed. The build emitted only the existing
    `volume_controller` unprocessed privacy-manifest warning.

40. Final Git, worktree, index, and submodule state

    The implementation commit is clean. The only intended subsequent tracked
    records are Prompt 69 and this Response 69 for the documentation checkpoint.
    After that checkpoint and normal push, the expected final state is a clean
    tracked worktree and index, a clean shared-instructions submodule at
    `95326f515ef4719f155ce6e223990398daad6311`, upstream ahead/behind `0/0`, one
    Feature 34 worktree, and only the previously known unrelated untracked
    files. The post-push final handoff records the verified state.

    Neither real archive nor any real database was read or modified during
    Prompt 69 implementation, automated validation, checkpointing, or build.
    Production MessageLens was not touched, and the development artifact was
    not launched.

41. Readiness to rerun Operating Stage Two human qualification

    YES. Attachment Archive Repair human qualification remains PASS. Operating
    Stage Two human qualification remains PENDING until the newly built exact
    artifact is direct-launched in the next task and the original live-
    currentness experiment is repeated.

ATTACHMENT COVERAGE COMPLETENESS REMAINS A LITERAL FACT: YES

KNOWN SOURCE-ABSENT COVERAGE DEBT CAN COEXIST WITH OPERATING: YES

CURRENT SOURCE-AVAILABLE UNCOVERED PAYLOADS SELECT REPAIR: YES

UNKNOWN OR CONFLICTING ATTACHMENT EVIDENCE FAILS CLOSED: YES

OPERATING LIVE UPDATE NO LONGER REQUIRES GLOBAL COVERAGE TRUE: YES

OPERATING AUTHORITY USES HISTORICAL DEBT/WAIVER STATE: NO

PROJECT CONFORMANCE: PASS

READY TO RERUN OPERATING STAGE TWO HUMAN QUALIFICATION: YES
