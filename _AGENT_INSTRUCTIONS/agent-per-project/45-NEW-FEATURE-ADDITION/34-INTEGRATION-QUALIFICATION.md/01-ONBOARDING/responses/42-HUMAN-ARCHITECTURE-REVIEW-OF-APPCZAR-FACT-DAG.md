# MessageLens Feature 34
## Response 42 — Human Architecture Review of the AppCzar Fact DAG

Date: 2026-10-01

## 1. Executive human-review verdict

Response 41 has the correct authority model but gives AppCzar too much
specialist knowledge. F00–F26 mixes three different things:

- facts AppCzar needs to select the next jurisdiction;
- evidence a specialist needs to produce one launch-level fact; and
- checks needed only after a coordinator already owns the app.

The control model becomes human-scale when only the first category remains in
the launch DAG. The second category belongs in typed, inspectable specialist
reports. The third belongs inside the selected coordinator.

The reviewed model has nine launch facts rather than 27. It uses no numeric or
domain priority list. Selection follows three mechanical rules:

1. incoherent evidence cannot authorize any substantive coordinator;
2. a proven threat to irreducible/preserved data is a protection veto;
3. otherwise a finding is selectable only when its coordinator's declared
   safety and observation prerequisites are satisfied.

This produces the desired mixed-failure results without pretending that mere
unavailability is corruption. It also removes `OK` as a coordinator terminal:
a foreground coordinator remains alive for the entire user interaction and
ends only by requesting a process restart. Normal process exit is app lifecycle,
not a semantic coordinator result.

This is a design review only. It does not authorize implementation.

## 2. Is F00–F26 too large for AppCzar?

Yes.

The individual archive configuration, transaction, volume, identity and access
nodes are specialist evidence. So are the separate import schema, graph schema,
cross-store coherence and reconstruction nodes. Presence health, Contacts
reachability and attachment backlog do not need to select launch jurisdiction
under the recommendations below.

Removing those nodes from AppCzar does not hide them. Each specialist returns a
typed report whose constituent observations, status and reasons are visible to
diagnostics and tests. AppCzar consumes only the report conclusion needed to
select jurisdiction. The specialist cannot select a coordinator.

## 3. Proposed reduced launch DAG

The proposed launch DAG has these nine facts. The identifiers are documentation
labels, not priorities.

| ID | Fair-Witness fact | Purpose |
|---|---|---|
| A0 | `CurrentAssessmentEvidenceIsCoherentAndStable` | Prevent a mixed-revision or contradictory sample from authorizing work. |
| A1 | `ConfiguredDataFolderCanCurrentlyBeSafelyInspected` | Admit the canonical root and installation identity before app-store inspection. |
| A2 | `LaunchCriticalPreservedDataHasNoCurrentSafetyConflict` | Report whether current evidence exposes a corruption, identity, transaction or provenance hazard in launch-critical preserved data. |
| A3 | `CurrentMessagesSourceCanCurrentlyBeInspected` | State whether the current Messages source can be inspected now; the reason may be missing FDA. |
| A4 | `LocalMessageDataCanCurrentlyBeSafelyInterpreted` | State whether the local import/graph material can be classified without guessing or risking protected material. |
| A5 | `ACompleteLocalMessageDatasetCurrentlyExists` | Distinguish a complete usable local dataset from an absent/incomplete one. |
| A6 | `IncompleteLocalMessageDataContainsProtectedNonLiveMaterial` | On the incomplete branch only, prevent automatic disposal of historical/non-live material. |
| A7 | `CompleteLocalMessageDatasetIsCompatibleWithCurrentSource` | On the complete branch only, distinguish compatible live-source lineage from divergence. |
| A8 | `ThisLocalMessageDatasetIsSafeAndUsableForBrowsing` | Positive proof for the Operating mapping; it does not claim every optional resource is available. |

The graph is:

```text
A0  current assessment evidence coherent and stable

A1  configured data folder safely inspectable
 +-- A2  launch-critical preserved data has no current safety conflict
 +-- A4  local message data safely interpretable
      +-- A5  complete local message dataset exists
           +-- when FALSE: A6 protected non-live material is present

A3  current Messages source can currently be inspected

A3 TRUE + A5 TRUE
 +-- A7  complete local dataset is compatible with current source

A0 TRUE + A1 TRUE + A2 TRUE + A3 TRUE
 + A4 TRUE + A5 TRUE + A7 TRUE
 +-- A8  local message dataset is safe and usable for browsing
```

Typed specialist reports remain transparent below A2 and A4:

```text
PreservationSafetyReport
  overlay safety
  archive configuration/transaction safety
  archive identity safety when observable

LocalMessageDataReport
  import-store readability/integrity
  graph-store readability/integrity
  cross-store coherence
  completeness
  current source inventories represented
  protected-source provenance findings
```

Those report fields are evidence, not additional AppCzar control nodes. A report
cannot collapse an inconclusive field into success. Any required inconclusive
field makes its launch fact UNKNOWN.

FDA remains an explicit raw observation and a useful UI row, but AppCzar needs
only A3 to choose jurisdiction. The source report retains `missing FDA` as A3's
reason so Onboarding or source-access presentation can give the correct remedy.

## 4. Facts moved down into coordinators

The following Response 41 nodes move below AppCzar:

| Response 41 detail | New owner |
|---|---|
| F03 Presence-store safety | Presence feature/session; it must fail closed for its own mutations. |
| F04 archive configuration structure | Archive preservation inspector and preservation coordinator. |
| F05 archive transaction settlement | Archive preservation inspector and preservation coordinator. |
| F06 archive volume presence | Archive feature/Operating degradation evidence; it is not a launch blocker by itself. |
| F07 archive identity details | Archive preservation inspector; only a proven safety conflict contributes to A2. |
| F08 archive access mode | Archive feature; unsafe identity contributes to A2, mere unavailability/read-only access produces degradation. |
| F09 FDA as a separate selector node | Source observation reason and startup UI; A3 is the jurisdiction-relevant fact. |
| F10–F11 source query/stability mechanics | Current-source inspector, which produces A3 plus coherent source evidence. |
| F12–F16 import/graph substructure | Local-message-data inspector, which produces A4/A5 and a detailed report. |
| F18–F20 protected-source mechanics | Local inspector; only the final conditional fact A6 remains in AppCzar. |
| F21 reconstruction sufficiency | Onboarding coordinator immediately before it authorizes allow-listed cleanup/rebuild. |
| F22 comparison mechanics | Source/local comparison specialist. |
| F23 lineage mechanics | Comparison specialist; only A7 remains in AppCzar. |
| F24 source delta/currentness | Operating session under the recommended ordinary-delta policy. |
| F25 attachment pending work | Operating archive service or an already-selected Update flow; not launch authority. |

F02 is represented within the A2 preservation report rather than retained as a
standalone launch node. F17 becomes A5. F26 is narrowed and renamed as A8.

## 5. Final independent-root selection rule

The final rule is **hard safety before knowability, then declared action
prerequisites**. It is mechanical and has no numeric priority.

Response 41's six-domain order is not fully implied by the DAG. It combines a
real safety invariant with product policy and then treats every preservation
condition—including mere volume absence—as though it were a safety threat. In
that form it is an arbitrary priority list in domain-language disguise.

The candidate principles compare as follows:

- **Preservation-first** is correct only for a proven threat to preserved data.
  It is too broad when “preservation” includes safe unavailability.
- **Knowability-first** is useful after safety is established, but it is unsafe
  as the first rule because missing FDA must not pre-empt a corrupt overlay or
  wrong archive identity.
- **Hard safety before knowability** is the selected rule. It distinguishes a
  protection hazard from an unavailable resource, then lets explicit action
  prerequisites expose the observation deficiency that must be resolved.
- No fourth domain order is needed. Ancestor dominance, same-jurisdiction
  collapse and action prerequisites settle the remaining cases.

### Coherence gate

If A0 is FALSE, select `CurrentAssessmentEvidenceIsContradictoryOrUnstable`.
If required evidence remains inconclusive with no safe selectable finding,
select `RequiredCurrentEvidenceIsInconclusive`.

### Protection veto

If current evidence proves that a proposed next action could use, overwrite,
discard or misaddress irreducible/preserved data, select the single composite
preservation finding. The payload is a stable, typed set of all proven
protection findings.

The veto includes, for example:

- corrupt/unsupported overlay data;
- malformed or contradictory archive configuration;
- an unsettled archive-location transaction;
- a present archive with the wrong identity;
- incomplete local data containing protected non-live material; or
- local import material whose provenance cannot be safely classified before a
  proposed cleanup.

It does **not** include:

- an external archive volume that is simply absent;
- access that is temporarily unavailable but safely blocks archive I/O;
- a corrupt rebuildable graph when protected material is not at risk; or
- an ordinary compatible source delta.

### Declared action prerequisites

With no protection veto, a finding is selectable only if the mapped
coordinator can safely act from current evidence. Repairing/rebuilding a
rebuildable graph requires the current source to be inspectable. Therefore a
missing source-access prerequisite remains the selected finding; the graph
finding is visible but not yet actionable.

A1 TRUE is an action prerequisite for every substantive coordinator except the
diagnostic and data-folder recovery coordinators. Thus an unsafe/unadmitted data
folder mechanically selects data-folder recovery even if an independent source
probe also reports unavailable.

An actionable ancestor still dominates its descendants. Findings in the same
jurisdiction collapse into one typed selected finding. If the remaining graph
closes positively, A8 selects Operating.

This is smaller than Response 41's root-domain order. It is a safety rule plus
explicit preconditions, not a disguised priority list.

## 6. FDA missing plus archive volume absent

Result: select the source-observation finding, contextualized by whether A5 is
TRUE or FALSE.

- A5 FALSE: `NoCompleteLocalDatasetAndCurrentMessagesSourceCannotBeInspected`
  maps to Onboarding.
- A5 TRUE: `ACompleteLocalDatasetExistsButCurrentMessagesSourceCannotBeInspected`
  maps to source access.

An absent archive volume is a safe unavailability, not a preservation threat.
It remains visible as degraded archive evidence and cannot pre-empt the source
finding. Archive reads/writes remain fail-closed with no fallback.

## 7. FDA missing plus overlay corrupt

Result: select the composite preservation-safety finding and the preservation
coordinator.

The corrupt overlay is irreducible user intent. It is a proven hard safety
condition, so it invokes the protection veto before source knowability. The
coordinator remains alive for diagnosis/user choice and may not infer that the
overlay is disposable.

## 8. FDA missing plus graph corrupt

Result: select the source-observation finding first.

The graph is rebuildable derived data, not preserved data. The local-data report
may already show that it is corrupt, but a rebuild/repair coordinator is not
actionable until the current source is inspectable and protected import
provenance is known. Missing FDA therefore blocks the repair action by an
explicit prerequisite rather than by priority.

If the local report also shows that protected historical material is at risk,
that separate protection finding invokes the protection veto instead.

## 9. Archive unavailable plus graph corrupt

Result: select local-data recovery, assuming current source inspection and
protected-material safety are established.

Archive unavailability is degraded availability. It does not authorize a
fallback archive and does not pre-empt repair of rebuildable local data. If the
archive evidence is unsafe rather than merely unavailable—for example, a wrong
present identity—the protection veto selects preservation instead.

## 10. Multiple preservation failures

Result: exactly one selected preservation finding and exactly one preservation
coordinator.

The finding carries a deterministic set of typed causes, sorted by stable
resource identity for presentation/testing only. Sorting does not define action
priority. The coordinator presents the entire set, admits at most one safe
mutation at a time, and requests RESTART after any jurisdiction-changing
mutation. Fresh AppCzar evidence then determines what remains.

## 11. Final coordinator lifetime model

The app root is always in exactly one of these ownership conditions:

```text
AppCzar is assessing
OR
one selected coordinator is alive and owns the foreground session
```

User interaction is a phase inside the selected coordinator. It is not a
terminal result and not a second authority.

An Onboarding coordinator remains alive while:

- its Journey shows or changes steps;
- System Settings is foreground;
- the user chooses among Journey actions;
- a worker runs;
- an error is shown;
- the user cancels a sub-action; or
- the Journey waits for a currently unavailable prerequisite.

The same rule applies to preservation, source-access, diagnostic and recovery
coordinators. A coordinator must not disappear while its Journey or foreground
surface still semantically owns the experience.

## 12. Final meaning of `OK`

`OK` should have no top-level coordinator meaning.

Exporting logs, cancelling a dialog, declining a repair or returning from
System Settings completes an inner action; it does not terminate the owning
coordinator. Normal browsing is the continuing Operating session, not an `OK`
terminal. Normal app quit is process lifecycle, not a semantic result.

The coordinator host needs only one semantic signal:

```text
RESTART_REQUESTED
```

It is emitted only after AppCzar-relevant reality may have changed. The old
coordinator and all its workers/tenures must terminate before relaunch.

## 13. Coordinator classes from which `OK` can be removed

Remove top-level `OK` from all coordinator classes:

- Onboarding;
- source access;
- preservation recovery;
- local-data recovery;
- historical/protected-data handling;
- diagnostic;
- data update, if that separate coordinator remains after product policy; and
- Operating.

Bounded inner commands may return `completed`, `cancelled`, `failed` or
`noChange`, but those are command results consumed only by their still-live
coordinator. They are not coordinator terminals and never feed AppCzar.

## 14. `Disposition` terminology

Simplify `Disposition` to `SelectedFinding` (or, in code,
`SelectedAppFinding`).

The rename is functional, not aesthetic:

- “disposition” suggests a policy decision or prescribed action;
- the object must remain a descriptive current finding;
- the positive browsing-ready case is not an “actionable problem”; and
- “selected finding” preserves the distinction from the many coexisting facts
  while remaining plain English.

The reviewed pipeline is:

```text
observations -> facts -> one SelectedFinding -> one coordinator
```

## 15. Fair-Witness naming corrections

These Response 41 names remain sound:

- `CurrentAssessmentEvidenceIsCoherentAndStable`;
- `ConfiguredDataFolderCanCurrentlyBeSafelyInspected`;
- `NoCompleteLocalDatasetAndCurrentMessagesSourceCannotBeInspected`;
- `ACompleteLocalDatasetExistsButCurrentMessagesSourceCannotBeInspected`;
- `LocalDerivedStoresCannotCurrentlyBeSafelyInterpreted`; and
- `IncompleteLocalDatasetContainsProtectedNonLiveMaterial`.

Recommended corrections:

| Response 41 name | Review | Replacement |
|---|---|---|
| `CurrentEvidenceIsInsufficientForAUniqueDisposition` | Mentions selector mechanics and jargon rather than the evidence. | `RequiredCurrentEvidenceIsInconclusive` |
| `OneOrMorePreservedMessageLensStoresCannotCurrentlyBeSafelyUsed` | Conflates unsafe, unavailable and inaccessible. | `LaunchCriticalPreservedDataHasCurrentSafetyConflicts` with typed causes |
| `LocalDatasetAndCurrentSourceDoNotHaveCompatibleLineage` | “Lineage” can invite a historical story beyond current identities. | `CompleteLocalMessageDatasetIsNotCompatibleWithCurrentSource` |
| `ThisHealthyLocalInstallationHasPendingKnownSourceWork` | “Healthy” conflicts with “pending”; “work” encodes an action. | Remove from launch under the recommended Operating-owned delta policy; otherwise use `CompleteLocalMessageDatasetIsCompatibleWithButBehindCurrentSource`. |
| `AttachmentArchiveHasNoPendingKnownSourceWork` | Describes inferred work rather than the visible relationship. | Coordinator-local `KnownEligibleSourceAttachmentsArePresentInConfiguredArchive`. |
| `ThisAppearsToBeAHealthyCurrentInstallation` | Claims the whole installation is healthy while Contacts, Presence and external archive availability may be unproven. | `ThisLocalMessageDatasetIsSafeAndUsableForBrowsing` |

`CurrentEvidenceIsContradictoryOrUnstable` remains fair-witness language because
it describes the admitted sample, not how it became unstable.

## 16. Final healthy-installation predicate

The Response 41 whole-installation predicate is too strong for the recommended
product boundaries. The positive Operating proof should be A8:

```text
ThisLocalMessageDatasetIsSafeAndUsableForBrowsing =
  A0 evidence coherent/stable
  AND A1 canonical data folder safely inspectable
  AND A2 no current launch-critical preserved-data safety conflict
  AND A3 current Messages source inspectable
  AND A4 local message data safely interpretable
  AND A5 complete local message dataset exists
  AND A7 complete local dataset compatible with current source
```

A8 does not require:

- current Contacts reachability;
- Presence health;
- an external archive volume to be connected;
- zero ordinary monotonic source delta; or
- zero attachment catch-up work.

Those omissions are deliberate product-boundary recommendations, not claims
that the optional resources are healthy. Their current conditions remain
visible and their mutations remain fail-closed.

If the product retains the broader name
`ThisAppearsToBeAHealthyCurrentInstallation`, then every omitted resource would
have to be proven healthy. The simpler and more truthful choice is the narrower
A8 name.

## 17. Contacts launch-policy recommendation

Recommendation: Contacts is coordinator-local/feature-local, not launch-level.

Onboarding tests current Contacts access when it needs to import Contacts.
Operating may show Contacts as unavailable or stale without losing safe message
browsing. Contacts failure must not manufacture a remembered onboarding state
or prevent AppCzar from selecting A8.

This is a product choice because the product could declare Contacts essential
to all operation. Nothing in the authority architecture requires that choice.

## 18. Presence launch-policy recommendation

Recommendation: Presence is feature-local, not launch-level.

Presence must protect its own durable state and fail closed for destructive
repair. A Presence problem can disable/degrade presence-dependent UI and expose
a focused repair path. It need not prevent safe browsing of a complete,
compatible message dataset.

If product requirements establish that Presence contains launch-critical,
irreducible state used by every session, its safety conclusion must join A2.
That is a product policy decision; it should not survive in AppCzar merely
because the current implementation happens to initialize Presence early.

## 19. Archive availability Operating-policy recommendation

Recommendation: a safely configured external archive that is currently absent
or inaccessible does not block Operating.

The archive row shows `Unavailable`; attachment reads report unavailable; all
archive writes fail closed; and no internal/default fallback is permitted.
Operating can still browse message and contact data that does not require the
payload volume.

By contrast, malformed configuration, an unsettled location transaction, a
wrong present identity or evidence of archive corruption is `Unsafe/Ambiguous`
and participates in the A2 protection veto. Availability and safety must never
share one FALSE value.

## 20. Source-delta Operating-policy recommendation

Recommendation: Operating absorbs ordinary monotonic source deltas, including a
tiny launch-observed delta.

A complete local dataset that is compatible with the current source is safe to
browse. Operating may perform routine incremental synchronization under Ball
tenure while showing current progress. It does not create or select another
coordinator.

Incompatible/divergent source identity remains an A7 failure and maps to
local-data recovery. A future product requirement for a blocking migration or
non-routine update may justify a separate selected finding, but ordinary count
or high-water advance does not.

This recommendation removes F24/F25 and the ordinary data-update coordinator
from launch authority. If product instead requires every observed delta to
finish before browsing, currentness must return as one explicit launch fact;
that is a policy choice, not an architectural necessity.

## 21. Incomplete-build rule confirmation

Confirmed.

AppCzar needs only enough current evidence to determine:

- local message data is safely interpretable or is unsafe/ambiguous;
- a complete local dataset exists or does not;
- an incomplete dataset contains protected non-live material or does not; and
- the current source can or cannot be inspected.

It does not reconstruct how partial data arose. No operation UUID, generation,
stage, page/batch cursor, recovery disposition, completion callback or durable
success flag participates.

After Onboarding is selected, Onboarding must freshly prove reconstruction
sufficiency immediately before allow-listed deletion/rebuild. Only rebuildable
live-derived stores may be removed. Overlay, Presence, archive configuration,
archive payloads and protected non-live source material remain outside cleanup.

## 22. Repeated-failure ownership confirmation

Confirmed with one wording refinement:

- Onboarding exclusively reads `consecutive_initial_build_attempts`;
- it atomically increments immediately before a fresh rebuild actually begins;
- AppCzar never reads the counter;
- no Journey step or launch finding is persisted from it;
- after fresh AppCzar evidence selects A8, the newly created Operating
  coordinator clears the counter without consulting its value; and
- failure to clear is logged but cannot revoke the already selected Operating
  jurisdiction.

This is not a semantic handoff. The counter affects only Onboarding's local
retry UX. A8 is established independently from current stores/source evidence.

## 23. Final startup UI fact list

The smallest useful startup list is:

```text
Checking MessageLens…

✓ Data folder             safely admitted
✓ Preserved data          no current safety conflict
✓ Full Disk Access        available
✓ Messages source         138,832 messages
✓ MessageLens data        complete; 138,822 messages
  New messages            10; will update after opening
✕ Attachment archive     unavailable; attachment access paused
```

Rules:

- `Full Disk Access` is a useful source observation even though A3 is the
  selector fact.
- `Preserved data` expands into typed resource findings only when needed.
- `MessageLens data` is the A4/A5 summary; import/graph/FTS subchecks belong in
  expandable diagnostics.
- `New messages` is informational under the recommended Operating-delta policy.
- `Attachment archive` explicitly distinguishes `Unavailable` from `Unsafe`.
- Contacts and Presence do not appear unless a selected coordinator currently
  needs them or the user opens diagnostics.
- UNKNOWN always shows the current blocking/inconclusive reason.
- Presentation projects admitted reports/facts and cannot select a finding.

## 24. Property-test changes

Retain the Response 41 properties for permutation independence, totality,
determinism, UNKNOWN preservation, acyclicity, ancestor dominance, historical
material protection, no historical-state influence, exhaustive mapping and no
same-process semantic feedback.

Revise/add these properties:

1. **Reduced-node closure:** only A0–A8 may affect selected finding; changing any
   coordinator-local report detail without changing its admitted conclusion
   cannot change selection.
2. **Report transparency:** an aggregate launch fact retains every typed failing
   or inconclusive constituent; no report implementation can turn UNKNOWN into
   TRUE.
3. **Availability/safety separation:** archive absent/access-denied and archive
   identity/configuration conflict produce distinct results; unavailability
   never invokes the protection veto.
4. **Protection veto:** any proven protected-data hazard prevents selection of a
   coordinator whose action could touch the affected data.
5. **Action-prerequisite gating:** FDA/source unavailable plus corrupt
   rebuildable graph selects source access regardless of discovery order.
6. **Mixed-root fixtures:** the five combinations in Sections 6–10 produce the
   exact selected findings stated there under every observation permutation.
7. **Same-jurisdiction collapse:** multiple preservation findings yield one
   selected finding/coordinator with a stable complete cause set.
8. **Non-blocking degradation:** toggling only safe archive availability,
   Contacts availability or Presence availability cannot change A8 or the
   selected coordinator.
9. **Ordinary-delta metamorphism:** advancing the compatible current source by a
   monotonic ordinary delta does not change the Operating selection; divergence
   does.
10. **Coordinator tenure:** while a coordinator's Journey/user interaction is
    mounted, the coordinator has not terminated.
11. **No-OK terminal:** the top-level coordinator-result type contains no `OK`
    variant; only a restart request can return to the process host.
12. **Restart exclusivity:** no fresh AppCzar instance is constructed until the
    old coordinator, workers and Ball tenure are gone.

The old Response 41 test expecting FDA FALSE plus archive-volume FALSE to select
preservation must be replaced. It now selects the contextual source finding
because archive absence is not a safety conflict.

## 25. One-page whiteboard model

```text
LAUNCH
  |
  v
AppCzar starts empty and observes current reality
  |
  v
Nine TRUE / FALSE / UNKNOWN facts close as a dependency graph
  |
  +-- evidence contradictory or required evidence inconclusive?
  |      -> one Diagnostic coordinator
  |
  +-- proven threat to preserved/irreducible data?
  |      -> one Preservation coordinator with all typed findings
  |
  +-- otherwise, which finding has all safety/action prerequisites?
         source unavailable + no complete data -> Onboarding
         source unavailable + complete data    -> Source Access
         local data unsafe/incompatible        -> Local Data Recovery
         no complete data; no protected history -> Onboarding
         safe complete compatible dataset      -> Operating

Exactly one SelectedFinding -> exactly one coordinator
  |
  v
The coordinator stays alive through every Journey/user/waiting phase
  |
  +-- inner action cancelled/no change -> same coordinator continues
  |
  +-- AppCzar-relevant reality changed -> RESTART_REQUESTED
                                           |
                                           v
                                    old owner terminates
                                           |
                                           v
                                    fresh process / fresh AppCzar

No history fills UNKNOWN. No coordinator selects another coordinator.
No normal coordinator terminal called OK. Ball remains mutation tenure only.
```

## 26. Response 40 deletion direction

Response 40's deletion/demotion direction remains intact:

- delete the historical installation semantic classifier;
- delete the Environment semantic readiness classifier;
- delete durable operation snapshots and resume/reconciliation authority;
- do not persist Journey position or semantic failure state;
- remove automatic navigation restoration from launch meaning;
- remove readiness/incident-center synchronization as authority;
- remove completion/success handoffs into top-level presentation; and
- keep Ball/track orthogonal to application meaning.

The reduced reports must replace old authorities, not be layered beside them.
No old classifier, snapshot or callback may feed A0–A8.

## 27. Remaining true product decisions

The architecture is settled independently of four product-policy choices. This
review recommends answers, but product ownership should record them explicitly
before implementation gates are approved:

1. **Contacts:** recommended coordinator/feature-local, not launch-blocking.
2. **Presence:** recommended feature-local with fail-closed protected mutation;
   add it to A2 only if product declares it launch-critical irreducible state.
3. **External archive availability:** recommended degraded Operating when safely
   unavailable; unsafe/ambiguous archive evidence remains launch-blocking.
4. **Ordinary compatible source delta:** recommended Operating-owned incremental
   synchronization; only incompatibility/divergence blocks Operating.

The exact repeated-failure copy/actions after the configured threshold is also a
UX policy, but it does not alter the launch DAG.

## 28. Is the architecture simpler than Response 41?

Yes.

The control vocabulary is now:

```text
one assessment
nine launch facts
one coherence gate
one protection veto
declared action prerequisites
one SelectedFinding
one coordinator
one semantic terminal: RESTART_REQUESTED
```

Specialist complexity still exists where the data requires it, but it no longer
expands AppCzar's state space. The whiteboard model explains mixed failures
without six root-domain priorities, 27 launch facts, or an ambiguous `OK`.

## 29. Exact Git/worktree/index/submodule state

At the start of Prompt 42, before this response was created:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- index: empty;
- tracked worktree: exactly the pre-existing 29 Prompt 32 + Prompt 35 modified
  files;
- accumulated tracked diff SHA-256:
  `88dd2190a8c989fcf7d1bbab5af49ff646b02a132ea423286353c6207c56f5be`;
- Prompt 39 path/implementation: absent;
- Prompt 40/Response 40 and Prompt 41/Response 41: present and untracked;
- Prompt 42: present and untracked;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- MessageLens was not launched;
- no database, archive, configuration, build artifact, index entry, commit or
  branch was changed.

After this response was created and validated:

- tracked modified-file count remained 29;
- tracked diff SHA-256 remained
  `88dd2190a8c989fcf7d1bbab5af49ff646b02a132ea423286353c6207c56f5be`;
- index path count remained zero;
- untracked file count became 69, consisting of the previously known untracked
  files, Prompt 42 and this Response 42;
- tracked `git diff --check` passed;
- Response 42 contains 30 required numbered sections and five required verdicts;
- Response 42 standalone trailing-whitespace check passed; and
- the shared-instructions submodule remained clean at the recorded commit.

## 30. Confirmation nothing was modified

No source, test, generated file, tracked instruction, existing response,
database, real archive, attachment payload, archive configuration, production
data, build artifact, index entry, commit, branch or submodule was modified.

MessageLens Development was not launched. No reset, onboarding, import, archive
operation, Prompt 39 implementation or AppCzar implementation was performed.

The only filesystem addition made for Prompt 42 is this untracked Response 42
architecture-review document in the requested `responses/` folder.

`APPCZAR FACT-DAG HUMAN REVIEW COMPLETE: YES`

`LAUNCH DAG REDUCED TO HUMAN-SCALE: YES`

`INDEPENDENT-ROOT SELECTION RULE IS MECHANICAL: YES`

`COORDINATOR LIFETIME MODEL IS UNAMBIGUOUS: YES`

`READY TO DESIGN IMPLEMENTATION GATES: YES`
