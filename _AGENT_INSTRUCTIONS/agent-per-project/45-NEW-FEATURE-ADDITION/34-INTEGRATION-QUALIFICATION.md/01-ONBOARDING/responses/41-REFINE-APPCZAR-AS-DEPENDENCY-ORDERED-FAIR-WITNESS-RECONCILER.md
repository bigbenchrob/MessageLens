# MessageLens Feature 34
## Response 41 — Refine AppCzar as a Dependency-Ordered Fair-Witness Reconciler

Date: 2026-10-01

## 1. Executive refinement summary

Response 40's deletion direction remains correct, but its five umbrella
conditions were too coarse. AppCzar should not build one giant semantic answer
called Onboarding, Updating, Remediating, Operating, or Cannot Determine.

The refined whiteboard model is:

```text
current observations
  -> dependency-ordered TRUE / FALSE / UNKNOWN facts
  -> zero or more factual deficiencies
  -> exactly one descriptive disposition
  -> exactly one coordinator
```

AppCzar is a Fair Witness. It says only what present evidence establishes. It
may truthfully know that FDA is absent and that a local graph is healthy while
leaving current source inventory and graph currentness UNKNOWN. It does not turn
those facts into the historical story “FDA was revoked” or “an update was
interrupted.”

Several factual deficiencies may coexist. They are not competing states and do
not start several coordinators. AppCzar evaluates a version-controlled dependency
DAG, computes its actionable frontier, applies one small deterministic domain
rule, creates one disposition, and uses one exhaustive mapping to select one
coordinator.

The refinement preserves the important Response 40 conclusions:

- no durable Journey cursor;
- no cross-session import/graph/rich-text resume;
- incomplete live-source builds are disposable only when reconstruction is
  proven safe;
- historical/non-live sources, overlay, Presence, archive configuration and
  attachment payloads remain protected;
- completion changes AppCzar-relevant facts and therefore ends in restart;
- only a fresh process can reach the healthy-installation disposition;
- persisted navigation and historical semantic conclusions remain deletion
  targets;
- Feature 35's Ball remains mutation tenure, not application meaning.

The result is more precise than Response 40 without introducing another
authority. Observations and facts are pure evidence. Only the disposition has
top-level control significance.

## 2. Final Fair Witness rule

> **AppCzar reports only what current evidence directly establishes. It does
> not fill in the historical story.**

Consequences:

1. Every fact name is present-tense and descriptive.
2. A missing prerequisite produces UNKNOWN downstream, not a guessed FALSE.
3. No old value substitutes for a current UNKNOWN.
4. A current mismatch does not say how it arose.
5. A current source-access failure does not say access was revoked.
6. Partial derived stores do not prove an operation was interrupted.
7. A healthy graph with an unreadable source is healthy internally, while its
   currentness is UNKNOWN.
8. Diagnostics may list historical logs separately, but historical material
   cannot alter the fact graph or disposition.

Good:

```text
Full Disk Access is currently unavailable.
This local graph is internally healthy.
Current source inventory is UNKNOWN because the source cannot be inspected.
Whether this graph matches the current source is UNKNOWN.
```

Not permitted:

```text
Full Disk Access was revoked.
Onboarding was interrupted.
The graph fell ten messages behind.
The last import failed, therefore the installation is broken now.
```

Future tests should compare fact values and evidence reasons, never historical
narratives inferred from them.

## 3. Observation / Fact / Disposition / Coordinator distinction

| Layer | Meaning | Lifetime | May coexist? | May control top-level UI? |
|---|---|---|---|---|
| Observation | A raw result from an OS, filesystem, database, marker, source, or archive probe | One AppCzar assessment | Yes | No |
| Fact/finding | A pure TRUE/FALSE/UNKNOWN proposition derived from observations and prerequisite facts | One AppCzar assessment | Yes | No |
| Disposition | The one descriptive actionable result selected from the closed fact graph | Until the selected coordinator terminates | Exactly one | Yes |
| Coordinator | The one semantic owner mapped exhaustively from the disposition | One coordinator occurrence | Exactly one | Yes |

Observations include values and failure reasons. For example, a source probe can
return a readable source fingerprint, explicit access denial, bounded sampling
instability, or an inconclusive I/O failure.

Facts contain no coordinator names and perform no I/O. They are deterministic
functions of an immutable observation set and prerequisite facts.

A disposition describes current reality, such as
`ACompleteLocalDatasetExistsButTheCurrentMessagesSourceCannotBeInspected`. It
does not say “run remediation.”

The separate mapping says that this disposition is handled by the source-access
coordinator. Changing the mapping cannot change the facts, and changing a fact
cannot directly mount presentation.

## 4. Three-valued semantics

Every fact has exactly one value:

```text
TRUE     current evidence establishes the proposition
FALSE    current evidence establishes its negation
UNKNOWN  current evidence establishes neither
```

UNKNOWN includes:

- a prerequisite is FALSE or UNKNOWN;
- a required observation has not completed;
- a probe failed without proving either side;
- a conditional branch is not applicable in this evidence set;
- bounded sampling did not produce a stable current value.

UNKNOWN is never actionable. It carries a reason so the UI can say, for
example, “waiting for source comparison; Messages access is unavailable.”

The evaluator uses strict dependency gating rather than treating facts as
ordinary Boolean expressions:

- a node evaluates only when its declared prerequisites are sufficiently known;
- a known FALSE ancestor is the actionable boundary; descendants blocked by it
  remain UNKNOWN;
- independent branches continue even when another branch is blocked;
- a conditional child whose applicability condition is FALSE remains
  `UNKNOWN(not applicable)` and is omitted from the required closure;
- a complete assessment may contain many TRUE values, several FALSE values, and
  many justified UNKNOWN values.

Example:

```text
FullDiskAccessIsCurrentlyAvailable             = FALSE
CurrentMessagesSourceIsReadable                = UNKNOWN(blocked by FDA)
CurrentMessageSourceInventoryIsStableAndKnown  = UNKNOWN(blocked by source)
ThisCompleteLocalDatasetIsCurrentWithSource    = UNKNOWN(blocked by comparison)
```

No previous source count or graph-currentness answer may fill those UNKNOWNs.

## 5. Concrete MessageLens dependency DAG

### 5.1 Raw observation set

The minimum raw launch observations are:

1. root admission, canonical root, marker, environment, build and archive
   instance identity;
2. fresh FDA/access result;
3. bounded `chat.db` reachability plus a coherent live-source fingerprint;
4. bounded source-scoped import schema, integrity, counts, cursor and source
   inventory;
5. bounded Conversation Graph schema, integrity, counts, topology and FTS;
6. bounded overlay schema/integrity;
7. bounded Presence schema/integrity if Presence remains launch-level;
8. attachment archive configuration, location, volume, identity, required
   access and pending adoption transaction;
9. current source-versus-derived message coverage and eligible attachment
   coverage when their prerequisites permit comparison;
10. revision/fingerprint evidence proving that observations combined in one
    sample did not change incompatibly during assessment.

Contacts is deliberately not in the launch DAG in this proposed concrete
version. Onboarding and update work inspect Contacts when they need it. Section
21 records this as a product decision.

### 5.2 DAG shape

```text
CurrentAssessmentEvidenceIsCoherentAndStable

ConfiguredDataFolderCanCurrentlyBeSafelyInspected
  ├─ ThisOverlayStoreIsSafeToUseOrCreate
  │    ├─ AttachmentArchiveConfigurationIsStructurallyValid
  │    │    └─ ConfiguredAttachmentArchiveVolumeIsCurrentlyPresent
  │    │         └─ ConfiguredAttachmentArchiveIdentityMatches
  │    │              └─ ConfiguredAttachmentArchiveSupportsRequiredAccess
  │    └─ AttachmentArchiveConfigurationTransactionIsSettled
  ├─ ThisPresenceStoreIsSafeToUseOrCreate          [product-policy node]
  ├─ ThisImportStoreCanCurrentlyBeSafelyInspected
  │    ├─ ThisImportStoreIsInternallyConsistentOrAbsent
  │    └─ ProtectedNonLiveSourceMaterialIsPresent
  └─ ThisGraphStoreCanCurrentlyBeSafelyInspected
       └─ ThisGraphStoreIsInternallyConsistentOrAbsent

ThisImportStoreIsInternallyConsistentOrAbsent
  + ThisGraphStoreIsInternallyConsistentOrAbsent
    └─ ThisImportAndGraphPairIsInternallyCoherent
         └─ ACompleteLocalMessageDatasetCurrentlyExists
              └─ IncompleteDerivedDataCurrentlyExists       [when FALSE]
                   + ProtectedNonLiveSourceMaterialIsPresent
                     └─ IncompleteDerivedDataContainsOnlyLiveSourceMaterial

FullDiskAccessIsCurrentlyAvailable
  └─ CurrentMessagesSourceIsReadable
       └─ CurrentMessageSourceInventoryIsStableAndKnown
            ├─ IncompleteLiveOnlyDataCanBeRebuiltFromCurrentSource
            └─ CurrentSourceCanBeComparedWithCompleteLocalDataset
                 └─ CurrentSourceAndLocalDatasetHaveCompatibleLineage
                      └─ ThisCompleteLocalDatasetIsCurrentWithKnownSource

CurrentMessageSourceInventoryIsStableAndKnown
  + ConfiguredAttachmentArchiveSupportsRequiredAccess
  + ACompleteLocalMessageDatasetCurrentlyExists
    └─ AttachmentArchiveHasNoPendingKnownSourceWork

all required safety, health, source, lineage, currentness facts TRUE
  └─ ThisAppearsToBeAHealthyCurrentInstallation
```

The graph is version-controlled program logic. Databases and OS adapters provide
observations only. No dependency, fact value, disposition, or edge belongs in a
mutable database table.

### 5.3 Node contract

The identifiers below label graph nodes; their numbering is for this document,
not priority.

| ID | Plain-English name / proposed code name | Kind | Prerequisites | TRUE | FALSE | UNKNOWN propagation | FALSE actionable / possible disposition |
|---|---|---|---|---|---|---|---|
| F00 | Current assessment evidence is coherent and stable / `CurrentAssessmentEvidenceIsCoherentAndStable` | Derived fact over observation revisions | Required probes attempted to their current dependency frontier | Samples used together have compatible revisions and no invariant contradiction | A bounded resample changed again or observations assert an impossible combination | While sampling is incomplete or a probe is merely inconclusive | Yes: `CurrentEvidenceIsContradictoryOrUnstable` -> diagnostic mapping |
| F01 | Configured data folder can currently be safely inspected / `ConfiguredDataFolderCanCurrentlyBeSafelyInspected` | Direct fact from bootstrap admission | None | Canonical root, environment/build identity and marker admission are valid and inspectable | Current root is absent, wrong, unsafe, or positively rejected | Admission failed inconclusively or is still pending | Yes: `ConfiguredDataFolderCannotCurrentlyBeSafelyInspected` |
| F02 | This overlay store is safe to use or create / `ThisOverlayStoreIsSafeToUseOrCreate` | Derived from bounded overlay observation | F01 TRUE | Store is absent and safely creatable, or present/readable/supported/integrity-valid | Existing preserved store is corrupt, unsupported, or structurally invalid | Root blocked, contention, or inconclusive I/O | Yes: preserved-data safety disposition |
| F03 | This Presence store is safe to use or create / `ThisPresenceStoreIsSafeToUseOrCreate` | Derived from bounded Presence observation | F01 TRUE and top-level Presence policy enabled | Store is absent and safely creatable, or present/readable/supported/integrity-valid | Existing preserved store is corrupt, unsupported, or structurally invalid | Root blocked, policy branch inactive, contention, or inconclusive I/O | Yes only if Presence is top-level: preserved-data safety disposition |
| F04 | Attachment archive configuration is structurally valid / `AttachmentArchiveConfigurationIsStructurallyValid` | Derived from current configuration | F01 TRUE, F02 TRUE | Default/uninitialized configuration is safely representable, or configured custom identity/bookmark is well-formed | Configuration is malformed, contradictory, or names a forbidden root | Overlay/configuration cannot be read | Yes: preserved-data safety disposition |
| F05 | Attachment archive configuration transaction is settled / `AttachmentArchiveConfigurationTransactionIsSettled` | Direct/derived from specialist transaction evidence | F02 TRUE | No pending transaction exists, or the recorded transaction is terminal and coherent | Current durable transaction evidence says configuration/adoption is incomplete | Transaction record cannot be read or interpreted conclusively | Yes: preserved-data safety disposition |
| F06 | Configured attachment archive volume is currently present / `ConfiguredAttachmentArchiveVolumeIsCurrentlyPresent` | Direct location fact | F04 TRUE | The configured external volume/root is present; a fresh default location is available under the admitted root | The configured required volume/root is currently absent | Configuration is not applicable, probe is inconclusive, or configuration is UNKNOWN | Yes: preserved-data safety disposition |
| F07 | Configured attachment archive identity matches / `ConfiguredAttachmentArchiveIdentityMatches` | Derived from configured and observed identity | F06 TRUE | Existing marker/instance identity matches; or a never-initialized default has no conflicting identity | A present root belongs to another instance or contradicts configuration | Marker/identity cannot be read conclusively | Yes: preserved-data safety disposition |
| F08 | Configured attachment archive supports required access / `ConfiguredAttachmentArchiveSupportsRequiredAccess` | Direct/derived access fact | F07 TRUE | Current archive access satisfies the active preservation policy | It is read-only/unwritable when writes are required, or required reads are denied | Access probe is inconclusive | Yes: preserved-data safety disposition |
| F09 | Full Disk Access is currently available / `FullDiskAccessIsCurrentlyAvailable` | Direct OS/source fact | None | Fresh evaluation establishes required access | Fresh evaluation establishes access is absent | Platform adapter cannot determine access | Yes, but disposition depends on F17 (complete dataset present or absent) |
| F10 | Current Messages source is readable / `CurrentMessagesSourceIsReadable` | Direct source fact | F09 TRUE | Current `chat.db` can be opened read-only and required source objects can be queried | Source is positively missing, unreadable, or structurally unsupported despite FDA | F09 is not TRUE or probe failure is inconclusive | Yes, with the same F17-dependent source disposition |
| F11 | Current message-source inventory is stable and known / `CurrentMessageSourceInventoryIsStableAndKnown` | Derived from bounded source samples | F10 TRUE | Count/high-water/source fingerprint is obtained and stable across the admitted sample | One bounded retry still produces a different material source fingerprint | Source is blocked or a query fails without a conclusive value | Yes when FALSE: contradictory/unstable evidence; UNKNOWN may lead to insufficient-evidence disposition |
| F12 | This import store can currently be safely inspected / `ThisImportStoreCanCurrentlyBeSafelyInspected` | Direct bounded database fact | F01 TRUE | Store is absent or can be read under a supported schema | Existing store is corrupt, unsupported, or cannot be safely interpreted | Root blocked, contention, or inconclusive I/O | Yes: local-derived-data safety disposition; auto-delete forbidden because source inventory inside may be unknown |
| F13 | This graph store can currently be safely inspected / `ThisGraphStoreCanCurrentlyBeSafelyInspected` | Direct bounded database fact | F01 TRUE | Store is absent or can be read under a supported schema | Existing store is corrupt, unsupported, or cannot be safely interpreted | Root blocked, contention, or inconclusive I/O | Yes: local-derived-data safety disposition |
| F14 | This import store is internally consistent or absent / `ThisImportStoreIsInternallyConsistentOrAbsent` | Derived integrity fact | F12 TRUE | Absent/valid-empty, or present with valid required objects, counts, cursor and source registry | A readable store has internal logical/integrity failure | F12 not TRUE or deeper check inconclusive | Yes: local-derived-data disposition unless a protected-material fact dominates |
| F15 | This graph store is internally consistent or absent / `ThisGraphStoreIsInternallyConsistentOrAbsent` | Derived integrity fact | F13 TRUE | Absent/valid-empty, or present with valid topology/FTS/integrity | A readable store has invalid topology, FTS, counts, or physical integrity | F13 not TRUE or deeper check inconclusive | Yes: local-derived-data disposition |
| F16 | This import and graph pair is internally coherent / `ThisImportAndGraphPairIsInternallyCoherent` | Derived cross-store fact | F14 TRUE, F15 TRUE | Both are absent/empty, or present facts reconcile by canonical identity/count/topology | One is partial/missing relative to the other, or their current material facts disagree | Either prerequisite not TRUE | No by itself; F17–F21 determine safe action |
| F17 | A complete local message dataset currently exists / `ACompleteLocalMessageDatasetCurrentlyExists` | Derived fact | F12–F16 sufficiently known | A non-empty import/graph pair is healthy, coherent and usable | Current safe observations establish absence, valid emptiness, or incompleteness | Store safety/health is UNKNOWN | Conditionally. It becomes Onboarding-eligible only after the incomplete/protected branch is resolved |
| F18 | Protected non-live source material is present / `ProtectedNonLiveSourceMaterialIsPresent` | Direct/derived inventory fact | F12 TRUE | Current import inventory contains at least one non-live source | Current readable inventory contains none, or store is absent | Import inventory cannot safely be read | No. TRUE is not itself a deficiency; it constrains disposal |
| F19 | Incomplete derived data currently exists / `IncompleteDerivedDataCurrentlyExists` | Derived fact | F17 FALSE, F12/F13 TRUE | Consequential partial import/graph data is present | No consequential derived data is present | F17 is not FALSE or store inventory is inconclusive | No; it selects the empty-versus-partial sub-branch |
| F20 | Incomplete derived data contains only live-source material / `IncompleteDerivedDataContainsOnlyLiveSourceMaterial` | Derived protection fact | F19 TRUE, F18 known | F18 is FALSE; no protected non-live source is present | F18 is TRUE; automatic disposal could destroy protected history | F18 UNKNOWN or branch inactive | Yes when FALSE: `IncompleteLocalDatasetContainsProtectedNonLiveMaterial` |
| F21 | Incomplete live-only data can be rebuilt from the current source / `IncompleteLiveOnlyDataCanBeRebuiltFromCurrentSource` | Derived safety fact | F20 TRUE, F10 TRUE, F11 TRUE | Current source evidence is sufficient to reconstruct the live-derived stores | Current known source lacks required reconstructible material | Any prerequisite is not TRUE | FALSE is actionable; TRUE authorizes only the later Onboarding worker's allow-listed cleanup, not AppCzar mutation |
| F22 | Current source can be compared with the complete local dataset / `CurrentSourceCanBeComparedWithCompleteLocalDataset` | Derived comparison fact | F17 TRUE, F11 TRUE, F16 TRUE | Canonical live-source identity/cursor/coverage exists on both sides | Required lineage/provenance is missing or incompatible for a valid comparison | Any prerequisite is not TRUE | Yes when FALSE: local-derived-data disposition |
| F23 | Current source and local dataset have compatible lineage / `CurrentSourceAndLocalDatasetHaveCompatibleLineage` | Derived relationship fact | F22 TRUE | They match or the current source is monotonically ahead of the canonical live slice | Local data is ahead, divergent, or identity-incompatible with the current source | F22 not TRUE | Yes: `LocalDatasetAndCurrentSourceDoNotHaveCompatibleLineage` |
| F24 | This complete local dataset is current with the known source / `ThisCompleteLocalDatasetIsCurrentWithKnownSource` | Derived currentness fact | F23 TRUE | Canonical current-source coverage equals the local live-source coverage | The current source is monotonically ahead | F23 not TRUE | Yes: pending-source-work disposition |
| F25 | Attachment archive has no pending known-source work / `AttachmentArchiveHasNoPendingKnownSourceWork` | Derived currentness fact | F08 TRUE, F11 TRUE, F17 TRUE | No currently eligible source attachment remains unpreserved | One or more currently eligible attachments await preservation | Any prerequisite not TRUE or eligibility cannot be established | Yes: pending-source-work disposition |
| F26 | This appears to be a healthy current installation / `ThisAppearsToBeAHealthyCurrentInstallation` | Final derived fact | F00–F08 safety requirements TRUE; F17 TRUE; F09–F11 TRUE; F22–F25 TRUE; optional F03 policy satisfied | Every required current safety, health, lineage and currentness proposition is proven | A complete closed graph proves all prerequisites but at least one is FALSE | Any required fact is UNKNOWN | TRUE creates healthy-installation disposition; FALSE is not separately actionable because its frontier facts already are |

### 5.4 Disposition set and exhaustive coordinator mapping

Disposition names remain coordinator-free.

| Descriptive disposition | Selecting evidence | Coordinator mapping |
|---|---|---|
| `CurrentEvidenceIsContradictoryOrUnstable` | F00 FALSE or F11 FALSE | Diagnostic coordinator |
| `CurrentEvidenceIsInsufficientForAUniqueDisposition` | Fixed point has no actionable FALSE, healthy is not TRUE, and one or more required facts remain UNKNOWN | Diagnostic coordinator |
| `ConfiguredDataFolderCannotCurrentlyBeSafelyInspected` | F01 FALSE | Data-folder recovery coordinator |
| `OneOrMorePreservedMessageLensStoresCannotCurrentlyBeSafelyUsed` | Actionable FALSE among F02–F08 or top-level F03; includes a deterministic sorted finding set | Preservation recovery coordinator |
| `NoCompleteLocalDatasetAndCurrentMessagesSourceCannotBeInspected` | F09/F10 actionable FALSE and F17 FALSE with no higher safety issue | Onboarding coordinator |
| `ACompleteLocalDatasetExistsButCurrentMessagesSourceCannotBeInspected` | F09/F10 actionable FALSE and F17 TRUE with no higher safety issue | Source-access coordinator |
| `LocalDerivedStoresCannotCurrentlyBeSafelyInterpreted` | Actionable FALSE among F12–F16/F22 without protected-material disposition | Local-data recovery coordinator |
| `IncompleteLocalDatasetContainsProtectedNonLiveMaterial` | F20 FALSE | Historical-source protection coordinator |
| `NoCompleteLocalMessageDatasetCurrentlyExists` | F17 FALSE; empty branch, or partial branch has passed the protected-material actionability guard | Onboarding coordinator |
| `LocalDatasetAndCurrentSourceDoNotHaveCompatibleLineage` | F23 FALSE | Local-data recovery coordinator |
| `ThisHealthyLocalInstallationHasPendingKnownSourceWork` | F24 FALSE and/or F25 FALSE | Data-update coordinator |
| `ThisAppearsToBeAHealthyCurrentInstallation` | F26 TRUE | Operating session coordinator |

The mapping is exhaustive over dispositions and is the only place coordinator
types appear.

## 6. UNKNOWN propagation

UNKNOWN propagation follows five rules:

1. **Blocked prerequisite:** if a node requires a TRUE prerequisite and that
   prerequisite is FALSE or UNKNOWN, the node is UNKNOWN with that prerequisite
   as its reason.
2. **Inconclusive probe:** a read error that proves neither proposition yields
   UNKNOWN, not FALSE.
3. **Conditional branch:** if an applicability fact is FALSE, child facts are
   `UNKNOWN(not applicable)` and do not prevent closure.
4. **Instability:** a bounded source/revision mismatch makes the explicit
   stability fact FALSE; dependent values are UNKNOWN. No older sample is used.
5. **Independent progress:** an UNKNOWN source branch does not stop overlay,
   Presence, archive, import, or graph observations that are safe and independent.

The evaluator reaches a fixed point when no UNKNOWN node can become known from
the observations already present. At that point:

- actionable FALSE facts may still yield a unique disposition;
- justified inapplicable UNKNOWN facts are ignored;
- required UNKNOWN facts with no actionable predecessor yield
  `CurrentEvidenceIsInsufficientForAUniqueDisposition`;
- F00/F11 instability yields the explicit contradictory/unstable disposition.

This allows AppCzar to act on a proven missing archive volume even while source
currentness is UNKNOWN, but it never calls the installation healthy until every
required healthy fact is TRUE.

## 7. Actionable-frontier definition

A fact is on the actionable frontier when all of the following are true:

1. its value is FALSE;
2. its node contract marks FALSE as actionable;
3. every prerequisite needed to understand that FALSE is sufficiently known;
4. no actionable FALSE ancestor must be corrected first;
5. every declared safety guard for that action is resolved;
6. the fact belongs to an applicable branch;
7. F00 has not already established contradiction/instability.

The safety-guard clause is essential. F17 FALSE (“no complete dataset”) is not
yet Onboarding-actionable when partial data exists until F18–F20 establish
whether protected non-live material is present. If F20 is FALSE, historical
protection is the frontier; Onboarding cleanup is mechanically unavailable.

The frontier is a set, not a winner. Disposition selection consumes the complete
set only after DAG closure. Future tests can calculate the frontier directly and
assert its members without mounting UI or providers.

## 8. Deterministic independent-root tie proposal

The smallest adequate rule is a named domain order, justified by safety and
knowability rather than numeric scoring:

```text
1. evidence coherence
2. data-folder and preserved-data safety
3. current source observability
4. local derived-dataset viability
5. source/archive currentness
6. healthy current installation
```

Within this rule:

- an actionable ancestor dominates its descendants;
- proven contradiction/instability dominates because no combined assessment is
  trustworthy;
- preservation safety dominates access and rebuilding because MessageLens must
  not operate or delete while irreducible data is at risk;
- source-observation deficiencies dominate rebuild/currentness because fixing
  them makes the downstream source branch knowable;
- local-dataset viability dominates currentness because only a viable baseline
  can be compared or updated;
- graph-behind and pending-attachment findings collapse into one pending-known-
  source-work disposition and one data-update coordinator.

Independent findings in the same preserved-data domain collapse into the single
descriptive disposition
`OneOrMorePreservedMessageLensStoresCannotCurrentlyBeSafelyUsed`. Its payload is
a stable, name-sorted set of factual findings, not a priority score. One
preservation coordinator displays the set and performs only one admitted action
at a time. Dependency dominance still handles related findings—for example, an
unreadable overlay precedes archive configuration derived from that overlay.

Example:

```text
FDA unavailable                         FALSE
configured archive volume present       FALSE
overlay safe                             TRUE

frontier domains = preserved-data safety + source observability
selected domain   = preserved-data safety
disposition       = OneOrMorePreservedMessageLensStoresCannotCurrentlyBeSafelyUsed
coordinator       = preservation recovery coordinator
```

After that coordinator changes the archive condition it returns `RESTART`.
Fresh AppCzar can then select the source-access/Onboarding disposition. No two
coordinators run concurrently.

## 9. Descriptive naming rules and examples

Fact names:

- are complete present-tense propositions;
- name the object being observed;
- include “current/currently/this” where it prevents historical ambiguity;
- say “can be inspected,” “is internally healthy,” “matches,” or “is present,”
  not “failed,” “interrupted,” “recovered,” or “resumed”;
- never name a coordinator, Journey, or UI;
- never encode priority.

Disposition names:

- describe the selected current condition;
- may combine a deficiency with the contextual fact required to choose a
  jurisdiction;
- never contain `Onboarding`, `Update`, `Remediation`, coordinator names, or an
  inferred historical verb;
- carry factual findings as payload, not a story.

Preferred:

```text
FullDiskAccessIsCurrentlyAvailable
ThisGraphStoreIsInternallyConsistentOrAbsent
CurrentMessageSourceInventoryIsStableAndKnown
ACompleteLocalDatasetExistsButCurrentMessagesSourceCannotBeInspected
ThisHealthyLocalInstallationHasPendingKnownSourceWork
CurrentEvidenceIsInsufficientForAUniqueDisposition
```

Rejected:

```text
FDAWasRevoked
OnboardingWasInterrupted
InstallFailed
NeedsRemediation
Updating
ResumeImport
```

Diagnostics should use the same language: “current source inventory is UNKNOWN
because FDA is unavailable,” not “source check failed after previous success.”

## 10. Revised Response 40 state-table mapping

| Response 40 term | Refined role |
|---|---|
| `ASSESSING` | Process/UI phase while AppCzar owns attention and exposes observations/facts. It is not a disposition. |
| `ONBOARDING` | Coordinator jurisdiction only. It is selected by descriptive dispositions such as `NoCompleteLocalMessageDatasetCurrentlyExists` or `NoCompleteLocalDatasetAndCurrentMessagesSourceCannotBeInspected`. |
| `UPDATING` | Data-update coordinator only. It is selected by `ThisHealthyLocalInstallationHasPendingKnownSourceWork`. |
| `REMEDIATING` | Deleted as an umbrella state. Specific descriptive dispositions map to data-folder, preservation, source-access, historical-protection, or local-data recovery coordinators. |
| `OPERATING` | Operating session coordinator/jurisdiction only. It is selected solely by `ThisAppearsToBeAHealthyCurrentInstallation`. |
| `CANNOT_DETERMINE` | Replaced by two descriptive dispositions: contradictory/unstable evidence, or insufficient evidence for a unique disposition. Both map to the diagnostic coordinator. |
| `COORDINATOR RUNNING` | Foreground attention mode, not a fact or disposition. |
| `USER` | Foreground attention mode within the already selected coordinator, not a second authority. |

The refined model therefore has many coexisting facts, one disposition, and one
coordinator—not one monolithic “app state.”

## 11. One-disposition / one-coordinator rule

AppCzar must produce exactly one disposition object. The exhaustive mapping must
produce exactly one coordinator factory. A disposition cannot contain or
construct that factory itself.

Mechanical shape:

```text
ObservationSet
  -> PureFactGraphEvaluator
  -> DispositionSelector
  -> AppDisposition
  -> exhaustive CoordinatorMapping
  -> one CoordinatorHost
```

The app root can hold either:

- an active AppCzar assessment; or
- one selected coordinator host.

It cannot hold both. A coordinator may run a Journey, wait for a user, invoke
workers, or acquire Ball tenure. It cannot call the disposition selector, create
another coordinator, or return an AppDisposition.

Multiple actionable deficiencies remain visible as facts, but only the selected
disposition's one coordinator may act. Concurrent coordinators are structurally
impossible.

## 12. Restart as the epistemic boundary

Restart remains a knowledge boundary, not merely a UI transition.

```text
initial build completes
  -> coordinator returns RESTART
  -> process restarts
  -> new observations
  -> new fact graph
  -> ThisAppearsToBeAHealthyCurrentInstallation
  -> Operating session coordinator
```

```text
Start Fresh completes
  -> current coordinator returns RESTART
  -> process restarts
  -> no complete local dataset is observed
  -> NoCompleteLocalMessageDatasetCurrentlyExists
  -> Onboarding coordinator
```

The same applies after archive repair, FDA repair on an established dataset,
local-data repair, launch-time catch-up, and historical-source protection work.
No callback, snapshot, worker result, or coordinator state can feed back into the
same AppCzar occurrence and produce Operating.

`OK` remains legal only when the selected jurisdiction is still valid: waiting
for the user, exporting logs, declining an action, or normal Operating work that
does not invalidate launch-level facts.

## 13. Journey self-location

AppCzar selects the Onboarding coordinator through a descriptive disposition. It
does not choose a Trip or Step.

Each Onboarding occurrence reruns current Messages access, history sufficiency,
Contacts readiness, and build prerequisites. The Journey derives its own current
Trip/Step in memory and remains the sole authority for Onboarding presentation.

Waiting for FDA fits naturally:

- the disposition selected Onboarding because no complete local dataset exists;
- the Journey's current FDA test determines its present step;
- returning from System Settings reruns that test;
- advancing within the same Onboarding jurisdiction does not require AppCzar;
- completing a build changes launch facts and therefore requires restart.

No durable Journey cursor, old episode, or Presence readiness run is consulted.

## 14. Interrupted-build rule

Response 40's rule is unchanged:

- live batch/page/high-water/rich-text/graph progress is memory-only;
- bounded database transactions remain permitted for live safety;
- the next process never resumes a previous progress cursor;
- a provably incomplete live-only derived build is allow-list deleted and rebuilt
  from the beginning;
- F18–F21 prevent automatic cleanup until protected non-live material is absent
  and current reconstruction evidence is sufficient;
- archive payloads, overlay, Presence, configuration/identity and adoption
  transaction evidence remain outside derived cleanup;
- attachment replay must be idempotent and preservation-safe.

The Fair Witness language is important: AppCzar says “incomplete live-only data
is present.” It does not say “the previous import was interrupted.”

## 15. Repeated-failure fact ownership

AppCzar should not read `consecutive_initial_build_attempts` at all. This makes
its exclusion from classification mechanical rather than conventional.

Ownership:

- the Onboarding coordinator reads the count to decide whether retry is
  automatic or requires explicit user choice;
- immediately before a fresh build begins, Onboarding atomically increments it;
- the Operating session coordinator clears it without reading it after a fresh
  AppCzar has selected the healthy-current-installation disposition;
- failure to clear is logged but cannot revoke Operating;
- ordinary logs retain detail; no attempt ledger or operation snapshot is added.

The counter therefore affects only Onboarding retry policy. It cannot influence
facts, frontier, disposition, Journey position, or coordinator mapping.

## 16. Startup assessment UI

The startup surface projects observations and fact values directly:

```text
Checking MessageLens…

✓ Data folder                  safely admitted
✕ Full Disk Access             currently unavailable
? Messages database            waiting for Full Disk Access
? Source inventory             current value unknown
✓ Local graph                  internally healthy; 138,822 messages
? Graph currentness            waiting for source comparison
✓ Overlay                      safe
✕ Attachment archive          configured volume unavailable
```

UI rules:

1. Each row comes from one observation or fact node.
2. TRUE uses a factual success label; FALSE uses the established negation;
   UNKNOWN shows `?` plus its dependency/inconclusive reason.
3. Downstream facts never render a success/failure before prerequisites permit
   evaluation.
4. Independent rows may complete concurrently and in any order.
5. The selected disposition is not published until the evaluator reaches its
   fixed point.
6. If several deficiencies exist, all remain visible, but only the selected
   disposition is labelled “MessageLens needs this first.”
7. The UI cannot choose the disposition from visible rows.
8. No percentage is shown unless a real probe exposes a measurable total.
9. The normal app tree does not exist during assessment.
10. Historical logs/navigation may appear only in a separate diagnostic section
    and have no edge into the DAG.

The current bounded inspection and archive/source probe presentation can be
reused. The old Environment readiness classifier and imperative center-panel
sync remain deletion targets.

## 17. Disposition-selection algorithm

The complete algorithm fits on one page:

1. Start a new immutable assessment occurrence with no previous semantic state.
2. Observe independent roots concurrently where safe. Root admission still
   precedes app-database access.
3. Record every observation with its current revision/fingerprint and factual
   failure reason.
4. Evaluate every fact whose declared prerequisites are sufficiently known.
5. Assign UNKNOWN—not FALSE—when evidence or a prerequisite is unavailable.
6. If material observations changed, perform one bounded coherent resample. A
   second change makes the stability fact FALSE.
7. Repeat pure fact evaluation until no additional fact can become known.
8. If evidence is contradictory/unstable, select that descriptive disposition.
9. Otherwise compute all actionable FALSE frontier facts, including declared
   safety guards.
10. If the frontier is non-empty, apply the fixed domain rule:
    preservation safety, then source observability, then local-dataset viability,
    then currentness. Ancestors dominate descendants; same-domain preservation
    findings collapse into one disposition.
11. Use contextual known facts only to choose the descriptive variant—for
    example, source unavailable with or without a complete local dataset.
12. If no deficiency is actionable and F26 is TRUE, select
    `ThisAppearsToBeAHealthyCurrentInstallation`.
13. If no deficiency is actionable, healthy is not TRUE, and a required fact is
    UNKNOWN, select `CurrentEvidenceIsInsufficientForAUniqueDisposition`.
14. Assert in development and check in production that exactly one disposition
    was produced.
15. Map it through the one exhaustive disposition-to-coordinator mapping.

No step depends on probe completion order, provider initialization order, widget
mount order, set iteration order, or the first failure observed.

## 18. Property/invariant test plan

Design the evaluator as pure program logic so these tests require no Flutter UI
or real database:

1. **Permutation property:** for every fixture evidence set, deliver observations
   in every permutation; final facts/frontier/disposition are identical.
2. **Totality property:** every coherent complete or explicitly inconclusive
   evidence set yields exactly one disposition.
3. **Determinism property:** repeated evaluation of the same immutable evidence
   yields equal fact graph, frontier, disposition and coordinator mapping.
4. **UNKNOWN preservation:** removing a prerequisite observation turns dependent
   facts UNKNOWN; it never copies a prior value or becomes FALSE.
5. **Dependency gating:** no node evaluator runs before its declared
   prerequisites are sufficiently known.
6. **Acyclic graph:** construction rejects cycles; a topological walk visits each
   active node once per evaluation closure.
7. **Ancestor dominance:** an actionable FALSE ancestor removes descendants from
   the frontier.
8. **Historical-material guard:** incomplete data plus non-live material cannot
   produce Onboarding cleanup or a disposable-build result.
9. **Independent-root tie:** FDA FALSE plus archive-volume FALSE always produces
   the preserved-data disposition, regardless of observation order.
10. **Same-domain collapse:** two independent preservation findings produce one
    preservation disposition and one coordinator.
11. **Currentness direction:** source-ahead produces pending-work; local-ahead or
    divergent lineage produces local-data recovery, never update.
12. **Stable sampling:** one mismatch triggers exactly one resample; a second
    mismatch produces contradictory/unstable evidence.
13. **Blacklist metamorphism:** adding/changing persisted Journey, operation,
    failure, sidebar, contact or panel history cannot change any fact.
14. **Attempt-counter exclusion:** every possible counter value produces the same
    AppCzar facts/disposition for identical observations.
15. **Mapping exhaustiveness:** every disposition maps to exactly one coordinator
    and no coordinator appears in fact/disposition packages.
16. **No feedback:** coordinator result types cannot be consumed by the active
    AppCzar evaluator; architecture tests enforce forbidden imports.
17. **Fresh-launch construction:** only the process-launch composition root can
    create a new AppCzar assessment occurrence.
18. **Operating proof:** the Operating coordinator is reachable only from the
    healthy-current-installation disposition.
19. **UI projection:** row symbols/text are a pure projection of fact value and
    reason; presentation cannot recompute facts.
20. **Scenario table:** all Section 19 scenarios are fixed fixtures with exact
    fact/frontier/disposition expectations.

Architecture enforcement should use AST/import boundaries rather than regex
heuristics where constructor/import authority matters.

## 19. Fourteen-scenario walkthrough

### 1. First launch, FDA absent

```text
observations -> admitted root; safe preservation stores; no complete dataset; FDA absent
facts        -> F09 FALSE; F10/F11/F22–F25 UNKNOWN; F17 FALSE; empty-data branch safe
frontier     -> source observability, contextualized by F17 FALSE
disposition  -> NoCompleteLocalDatasetAndCurrentMessagesSourceCannotBeInspected
coordinator  -> Onboarding coordinator
terminal     -> OK while waiting/choosing; RESTART after a completed build
```

### 2. FDA absent and archive volume absent

```text
observations -> FDA absent; configured archive volume absent; other safety facts known
facts        -> F09 FALSE; F06 FALSE; source descendants UNKNOWN
frontier     -> preserved-data safety + source observability
disposition  -> OneOrMorePreservedMessageLensStoresCannotCurrentlyBeSafelyUsed
coordinator  -> preservation recovery coordinator
terminal     -> RESTART after archive condition changes; fresh launch then addresses FDA
```

### 3. FDA absent and a healthy established graph exists

```text
observations -> FDA absent; import/graph complete and internally coherent
facts        -> F09 FALSE; F17 TRUE; source inventory/currentness UNKNOWN
frontier     -> source observability, contextualized by F17 TRUE
disposition  -> ACompleteLocalDatasetExistsButCurrentMessagesSourceCannotBeInspected
coordinator  -> source-access coordinator
terminal     -> OK while waiting/exporting; RESTART after access changes
```

### 4. Graph healthy but current source is ahead

```text
observations -> safety and source probes healthy; comparable source has later canonical coverage
facts        -> F17/F22/F23 TRUE; F24 FALSE; other required facts TRUE
frontier     -> currentness
disposition  -> ThisHealthyLocalInstallationHasPendingKnownSourceWork
coordinator  -> data-update coordinator
terminal     -> RESTART after catch-up
```

### 5. Graph unhealthy and source reachable

```text
observations -> source readable/stable; graph integrity/topology conclusively unhealthy
facts        -> F15 FALSE; complete/currentness facts UNKNOWN
frontier     -> local derived-dataset viability
disposition  -> LocalDerivedStoresCannotCurrentlyBeSafelyInterpreted
coordinator  -> local-data recovery coordinator
terminal     -> RESTART after an explicitly safe repair/rebuild
```

### 6. Partial live-only graph/import

```text
observations -> readable partial stores; no non-live sources; current source readable/stable
facts        -> F17 FALSE; F19 TRUE; F20 TRUE; F21 TRUE
frontier     -> no complete local dataset, with disposal safety established
disposition  -> NoCompleteLocalMessageDatasetCurrentlyExists
coordinator  -> Onboarding coordinator
terminal     -> allow-list rebuild from zero, then RESTART
```

### 7. Graph/import contains protected non-live historical-source material

```text
observations -> F18 TRUE

if local dataset is otherwise complete/coherent/current:
facts        -> protected material TRUE but no deficiency; F26 may be TRUE
frontier     -> empty
disposition  -> ThisAppearsToBeAHealthyCurrentInstallation
coordinator  -> Operating session coordinator
terminal     -> OK

if the dataset is incomplete and cleanup would be required:
facts        -> F17 FALSE; F19 TRUE; F20 FALSE
frontier     -> protected historical material
disposition  -> IncompleteLocalDatasetContainsProtectedNonLiveMaterial
coordinator  -> historical-source protection coordinator
terminal     -> RESTART after separately authorized safe resolution
```

The mere presence of history is not a failure; it only blocks unsafe disposal.

### 8. Archive unavailable while source and graph are healthy

```text
observations -> configured archive volume absent; source/local dataset otherwise healthy
facts        -> F06 FALSE; F07/F08/F25 UNKNOWN
frontier     -> preserved-data safety
disposition  -> OneOrMorePreservedMessageLensStoresCannotCurrentlyBeSafelyUsed
coordinator  -> preservation recovery coordinator
terminal     -> RESTART after availability changes
```

### 9. Overlay corrupt

```text
observations -> existing overlay positively fails supported integrity
facts        -> F02 FALSE; archive-configuration descendants UNKNOWN
frontier     -> preserved-data safety; overlay ancestor dominates archive descendants
disposition  -> OneOrMorePreservedMessageLensStoresCannotCurrentlyBeSafelyUsed
coordinator  -> preservation recovery coordinator
terminal     -> OK for diagnostics/quit; RESTART after any safe repair
```

### 10. Source changes during assessment

```text
observations -> material source fingerprint changes after the one bounded resample
facts        -> F11 FALSE; dependent comparison/currentness UNKNOWN; F00 FALSE
frontier     -> evidence coherence
disposition  -> CurrentEvidenceIsContradictoryOrUnstable
coordinator  -> diagnostic coordinator
terminal     -> OK for logs/quit; RESTART for a fresh assessment
```

### 11. Import process was killed halfway

```text
observations -> partial live-only derived stores; current source sufficient; no operation history consumed
facts        -> F17 FALSE; F19/F20/F21 TRUE
frontier     -> no complete local dataset
disposition  -> NoCompleteLocalMessageDatasetCurrentlyExists
coordinator  -> Onboarding coordinator, with attempt policy applied locally
terminal     -> full rebuild then RESTART
```

AppCzar does not claim the process was killed; it sees only current partial data.

### 12. Import completed but process died before any completion callback

```text
observations -> complete coherent import/graph, stable matching source, healthy preservation facts
facts        -> all healthy prerequisites TRUE; F26 TRUE
frontier     -> empty
disposition  -> ThisAppearsToBeAHealthyCurrentInstallation
coordinator  -> Operating session coordinator
terminal     -> OK; old callback/success flag is irrelevant
```

### 13. Start Fresh completes

```text
observations -> current process returns RESTART; fresh launch sees safe empty derived stores
facts        -> F17 FALSE; F19 FALSE; source branch evaluated independently
frontier     -> no complete local dataset (or source observability first if unavailable)
disposition  -> NoCompleteLocalMessageDatasetCurrentlyExists when source is readable
coordinator  -> Onboarding coordinator
terminal     -> RESTART after a new build
```

### 14. Contradictory facts or no unique disposition

```text
observations -> invariant contradiction, unstable required sample, or required evidence remains inconclusive
facts        -> F00 FALSE, or fixed point with no actionable frontier and F26 UNKNOWN
frontier     -> evidence coherence, or empty with required UNKNOWN
disposition  -> CurrentEvidenceIsContradictoryOrUnstable
                OR CurrentEvidenceIsInsufficientForAUniqueDisposition
coordinator  -> diagnostic coordinator
terminal     -> OK for logs/quit; RESTART for fresh assessment; never mutate or guess Operating
```

## 20. Changes to Response 40 deletion/demotion map

The DAG refinement does not rescue any old semantic mechanism.

| Response 40 target | Response 41 effect |
|---|---|
| Historical installation classifier | Still delete. Replace with pure facts plus disposition selector, not a second classifier layered above it. |
| Environment readiness classifier | Still delete. Reuse only low-level observers; Environment state cannot be a DAG input. |
| Durable operation snapshot | Still delete. The fact graph observes stores, never operation history. |
| Resume/reconciliation state | Still delete. Partial live-only facts select full rebuild. |
| Persisted Journey position | Still absent/delete. Journey self-locates. |
| Persisted navigation | Still delete/ignore. It is blacklisted from observations. |
| Persisted semantic failure rows | Still delete as authority; logs only. |
| Completion handoffs | Still delete. Facts can change only across restart for top-level selection. |
| Umbrella `ONBOARDING/UPDATING/REMEDIATING/OPERATING/CANNOT_DETERMINE` state enum | Do not create it. Keep coordinator/session concepts and descriptive dispositions instead. |
| Startup validation/readiness UI | Replace with direct observation/fact projection; do not add a new independent readiness provider. |
| Feature 35 Ball | Retain unchanged as mutation tenure; absent from DAG. |

The only new conceptual artifacts are:

- an immutable observation set;
- a pure version-controlled fact DAG;
- a pure actionable-frontier/disposition selector;
- one exhaustive disposition-to-coordinator mapping.

They replace several existing semantic authorities and durable conclusions. They
must not be added while the old classifiers continue to control production.

## 21. Remaining product decisions

### Architecture necessities

These are not optional:

- observations, facts, dispositions and coordinators remain separate;
- every fact is TRUE/FALSE/UNKNOWN;
- UNKNOWN never borrows history;
- dependencies and tie rules live in version-controlled code;
- discovery order is irrelevant;
- exactly one disposition/coordinator results;
- preservation dominates unsafe cleanup;
- only fresh launch can select the healthy-installation disposition;
- no durable Journey/import cursor returns.

### Product decisions

1. **Contacts reachability.** Proposed answer: coordinator-local. Onboarding and
   update work test Contacts when needed; established Operating is not blocked
   solely because live Contacts cannot currently be read.
2. **Presence health.** Proposed conservative answer: launch-level while Presence
   remains preserved durable user state. If product chooses feature-local
   degradation, remove F03 from F26 but keep its preservation/repair boundary.
3. **Source delta policy.** Proposed initial answer: every launch-observed message
   or attachment delta selects the foreground data-update coordinator. Operating
   may absorb changes detected after its session begins.
4. **Independent-root tie rule.** Proposed final answer: evidence coherence,
   preserved-data safety, source observability, local-dataset viability,
   currentness. Same-domain preservation findings collapse into one serial
   disposition. No numeric score.
5. **Repeated-failure choice.** Product must choose exact copy/actions after more
   than three attempts. Architecture recommendation: explain, package/send logs,
   quit, and offer only an explicit user-requested retry.

Only the Presence and Contacts choices alter which nodes are required for F26.
None justifies historical state or concurrent coordinators.

## 22. DAG-introduced implementation risks

1. **Accidental second authority.** A “fact provider” could become another global
   readiness classifier. Facts must remain pure values inside one assessment.
2. **Cycle risk.** Contextual dispositions must not be encoded as back-edges from
   source facts to dataset facts. The graph constructor needs cycle enforcement.
3. **UNKNOWN versus not applicable.** Both use UNKNOWN truth but require distinct
   reasons so an inactive conditional branch does not block healthy closure.
4. **Premature actionability.** F17 FALSE must remain guarded until historical
   source safety is known for partial stores.
5. **Observation coherence.** Concurrent probes can produce incompatible
   revisions; bounded resampling must be explicit and finite.
6. **Gross-count comparison.** Counts alone cannot establish lineage/currentness.
   Canonical source identity/high-water/coverage rules remain required.
7. **Historical-source inventory unreadable.** Corrupt import storage cannot be
   presumed live-only and deleted.
8. **Archive conditionality.** A never-initialized default archive is not the
   same as a configured external archive becoming unavailable.
9. **Composite preservation disposition.** Its finding set must be stable and
   factual; its coordinator must serialize work and restart after any change.
10. **Mapping drift.** Disposition and coordinator additions must fail compilation
    or tests until the exhaustive mapping is updated.
11. **UI inference.** Presentation must not independently combine fact rows into
    its own disposition.
12. **Probe cost.** Bounded launch checks must remain fast; deeper integrity work
    should be triggered by present evidence, never skipped due an old ready flag.
13. **Root bootstrap.** Safe archive-root admission still precedes database
    inspection and must not itself grow into a parallel semantic classifier.
14. **Attempt counter mutation.** Clearing it after healthy selection must not
    affect the already selected Operating jurisdiction if the write fails.
15. **Restart reliability.** A coordinator must terminate before relaunch so no
    old worker/tenure survives into the new assessment.
16. **Migration overlap.** Running old classifiers and the new selector together
    would recreate multiple authorities. Each migration gate must delete or
    disconnect the superseded path.

## 23. Is this simpler than Response 40?

Yes.

It introduces more explicit factual propositions than Response 40's five labels,
but facts are not semantic authorities and do not form a cross-product state
machine. They are pure, dependency-ordered statements that can coexist.

Response 40's umbrella `REMEDIATING` condition hid unrelated reasons and required
implicit priority to pick a UI. Response 41 makes the evidence and priority rule
visible while retaining exactly one control result. It also eliminates the need
to force a complete environment story when some current facts are legitimately
UNKNOWN.

The control vocabulary is now:

```text
one assessment phase
one pure fact DAG
one actionable frontier
one disposition
one exhaustive mapping
one coordinator
two coordinator terminals: OK or RESTART
```

That is simpler to explain, test, and enforce than either the current system or
Response 40's monolithic condition predicates.

## 24. Prompt 39 remains superseded

Yes. Prompt 39 remains superseded and unimplemented. The local Response 38 fixes
remain intentionally unimplemented. Hidden navigation restoration is still a
deletion target, and display-identity currentness remains an Operating-generation
concern rather than a reason to patch the current startup state machinery.

## 25. Exact Git/worktree/index/submodule state

At the start of Prompt 41, before this response was created:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- index: empty;
- tracked worktree: exactly 29 Prompt 32 + Prompt 35 modified files;
- accumulated tracked diff SHA-256:
  `88dd2190a8c989fcf7d1bbab5af49ff646b02a132ea423286353c6207c56f5be`;
- Response 40: present and read in full;
- Prompt 39 path/implementation: absent;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- Prompt 41: untracked and present;
- final untracked-path count: 67, including Prompt 41 and this new Response 41;
- tracked `git diff --check`: passed;
- Response 41 standalone whitespace check: passed;
- required numbered sections: 26;
- required concluding verdicts: five;
- index and tracked baseline: unchanged by the read-only audit;
- the only path added by the Prompt 41 response work: this Response 41 file.

## 26. Confirmation nothing was modified

No source, test, generated file, database, archive configuration, attachment
payload, real archive, production data, build artifact, tracked instruction,
index entry, commit, branch, or submodule was modified.

MessageLens Development was not launched. Start Fresh and import were not run.
No Prompt 39 or AppCzar implementation occurred.

The only filesystem change made for Prompt 41 is this Response 41 architecture
document in the requested `responses/` folder.

`FAIR-WITNESS APPCZAR REFINEMENT COMPLETE: YES`

`APP DISPOSITION IS DEPENDENCY-DETERMINISTIC: YES`

`DISCOVERY ORDER CAN AFFECT DISPOSITION: NO`

`MULTIPLE ACTIONABLE DEFICIENCIES CAN RUN CONCURRENTLY: NO`

`READY FOR HUMAN REVIEW OF THE FACT DAG: YES`
