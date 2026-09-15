# Onboarding Journey Coordinator

## Purpose

`OnboardingJourneyCoordinator` is the single authority that selects the active
Onboarding Episode. It combines coherent prerequisite evidence, durable
operation truth, and explicit human intent into one typed Journey state.

The filename is retained for stable documentation links. `OnboardingGate` is
now only a read-only `OnboardingStatus` compatibility projection for established
presentation and action seams. It cannot assign Journey state.

> **Invariant:** A probe, widget, dialog, focus callback, animation, Presence
> Schedule, or operation snapshot may publish evidence or intent. None may
> select or advance an Onboarding Episode.

## Ownership

```text
Environment and source probes
        -> coherent prerequisite evidence

Durable operation snapshot
        -> admitted operation truth

Human actions
        -> typed intent

OnboardingJourneyCoordinator
        -> exactly one active OnboardingJourneyState

Environment Readiness / operation overlay / navigation
        -> presentation of that state
```

The coordinator owns transition decisions. It does not own source import,
Conversation Graph construction, preservation storage, or archive mutation
admission. Those operations remain with their existing services and execute
only under `ArchiveMutationCoordinator`.

## Typed Episode Model

The sealed Journey state has these Episodes:

| Episode | Completion predicate |
|---|---|
| checking prerequisites | one current coherent evidence snapshot exists |
| establishing Messages access | a fresh snapshot proves protected Messages access |
| confirming local Message history | the user accepts the currently observed local history, or fresh evidence proves it sufficient |
| establishing Contacts access | fresh evidence proves the required local Contacts source is readable |
| ready to import | all prerequisite predicates in one evidence revision are satisfied |
| recovering derived data | admitted reset of rebuildable stores completes |
| preparing import | admitted import preparation completes |
| building local data | source import and graph projection complete |
| verifying durable readiness | canonical post-operation verification succeeds |
| operation failed | a typed operation or readiness failure is observed |
| ready to start | durable readiness has been proved; terminal acknowledgement remains |
| normal application | the human acknowledges the terminal Episode |
| reimporting | admitted reimport work is active |
| reimport ready | reimport completion has been verified |

`OnboardingStatus` remains a compatibility presentation vocabulary. It is not
the Journey model and is never a second transition authority.

## Coherent Evidence

`OnboardingPrerequisiteEvidence` carries:

- a monotonically increasing process-local revision;
- an observation time;
- one complete `OnboardingEnvironmentReport`.

All blocker selection for an Episode comes from that one report. Presentation
must not combine FDA from one observation with Contacts, history, or database
readiness from another.

Invalidating an old asynchronous inspection retires its provider occurrence.
Late completion from that occurrence cannot replace the newer report. Journey
occurrence and evidence revision are presentation/coordination identities, not
durable source identity.

## Blocker Priority

The environment report applies actual dependency order before the coordinator
selects an Episode:

1. admitted maintenance;
2. protected Messages access;
3. local Messages source availability and history sufficiency;
4. required local Contacts availability;
5. app-owned import and graph readiness.

Provider completion order never chooses the visible blocker.

## Transition Rules

Commanded workflow transitions pass through one explicit transition policy.
The principal first-run path is:

```text
checking
  -> Messages access
  -> local-history confirmation when needed
  -> Contacts access when needed
  -> ready to import
  -> recovering derived data when needed
  -> preparing import
  -> building local data
  -> verifying durable readiness
  -> ready to start
  -> normal application
```

Authoritative evidence may move backward before import. For example, revoking
FDA invalidates `readyToImport` and returns to Messages access. A focus event or
button press cannot make that transition without new evidence.

Operation failure may move an active operation to the typed failed Episode.
Retry begins only through an allowed human intent and normal mutation
admission. Impossible shortcuts such as FDA blocker to completion, import to
normal application, or terminal completion back to a prerequisite are rejected.

## Human Actions

Widgets express intent through action providers. The coordinator validates the
intent against the current typed state:

- **Open System Settings** opens the FDA pane but does not advance.
- **Re-check** requests fresh prerequisite evidence but does not advance by
  itself.
- **Use This Local History** is accepted only in the local-history Episode.
- **Import My Messages** executes only from `OnboardingReadyToImport`.
- terminal **OK** executes only after durable completion and releases normal
  application ownership.

Hiding an invalid control is presentation hygiene. The coordinator guard is
the application-layer authority.

## FDA And Lifecycle Semantics

Opening System Settings, losing focus, regaining focus, relaunching, or
dismissing a modal is not FDA proof. Those events may request a fresh check.
Only a coherent report that can read the protected source completes the FDA
Episode.

The old “Welcome back” progression and production prerequisite Presence host
have been removed. The required-sources Schedule remains only as laboratory and
historical fixture material; production startup does not mount or consult it.

## Contacts And Local History

Contacts remains required because the current import pipeline unconditionally
uses local Contacts data. Guidance states that operational fact. It does not
claim that opening Contacts, waiting, or checking an iPhone completes the
predicate.

MessageLens can inspect only local Messages evidence. It may suggest checking
Messages in iCloud when local history appears sparse, but cannot claim that
iCloud synchronization is complete. A user may explicitly accept the observed
local history for the current process Journey; this does not rewrite source
facts.

## Operation And Completion Authority

The authority chain remains:

```text
ArchiveMutationCoordinator -> whether mutation may run
OnboardingOperationSnapshot -> what admitted work is doing
import/graph stores          -> what durable work completed
Journey Coordinator         -> which Episode follows
```

Operation completion alone cannot produce `readyToStart`. The coordinator
publishes the internal verifying state, runs the canonical durable completion
verifier, records the proof, and only then publishes terminal readiness.

The typed verifying state is a mandatory mechanical gate, not a separate
human Journey node. The canonical human path is:

```text
Messages -> History -> Contacts -> Ready -> Import -> Start
```

While verification is active, the human path remains on Import and Start is
future. Only successful durable proof completes Import and makes Start current.
Verification failure remains an Onboarding-owned typed failure and cannot
expose Start.

Terminal readiness does not reveal the normal application. Human
acknowledgement changes the Journey to normal application, after which the
canonical sidebar is released.

## Startup, Start Fresh, And Resume

Startup reaches Onboarding through the coordinator's read-only Gate projection.
No startup widget independently selects readiness, import, or normal mode.

Start Fresh owns preservation-safe reset execution. After it proves virgin
installation state, it requests fresh prerequisite evidence. The coordinator
selects the first truthful Episode; Start Fresh does not navigate directly to
one.

On a new process, durable operation reconciliation classifies interrupted work.
The operation snapshot remains evidence and never becomes a Journey navigator.

### Exact interruption evidence

`OnboardingOperationSnapshot` persists the operation kind, stage, exact
substage, aggregate progress, anomaly totals, status, and normalized recovery
disposition. Source-import observations map message work to
`importingMessages`, `extractingRichText`, and `persistingRichText`; relationship
and graph projection units remain individually named.

A running snapshot from a prior process is reconciled as interrupted. When it
retains an exact incomplete substage, that evidence remains resumable even if
coarser database/environment evidence is classified as
`graphProjectionFailed`. Presentation names the persisted substage and offers
`Continue Setup`; it must not collapse the evidence to a generic graph failure
or infer progress from database row counts.

Committed source-message and rich-text pages remain durable, so continuation
replays at most the unfinished bounded unit. See the canonical import contract
in
[`12-bounded-message-import-and-rich-text-enrichment.md`](../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md).

## Presentation Ownership

Environment Readiness renders prerequisite Episodes in the center panel.
`OnboardingOverlay` renders admitted recovery, import, verification, failure,
and terminal operation Episodes. Navigation synchronizes the coordinator's
compatibility status with existing ViewSpecs and sidebar ownership.

A pipeline-incident surface may not replace an active first-run Episode.
Presence may render other Journeys, but it cannot assign Onboarding state or
navigate production prerequisite progression.

## Preservation Safety

Every reset and recovery operation may delete only the explicit rebuildable
derived-store allow-list. Overlay/user intent, Presence history, archive
identity, preferences, diagnostics, and `attachment_archive/` remain outside
that boundary. See
[`ATTACHMENT-PRESERVATION-INVARIANT.md`](ATTACHMENT-PRESERVATION-INVARIANT.md).

No supported Onboarding or recovery operation can replace the complete archive
root. Start Fresh and automatic recovery remain enumerated derived-store
mutations. The obsolete Complete Erase transaction is recognized only by a
temporary fail-closed startup compatibility seam, which may remove that one
unchanged journal file in proven-safe stale states and cannot resume erasure or
replace archive identity.

## Diagnostics

The coordinator exposes a bounded non-PII diagnostic snapshot containing:

- active Episode and occurrence;
- evidence revision, environment state, and blocker kind;
- operation status;
- supplied installation classification;
- last transition reason.

Normal support bundles separately include `onboarding_operation.json` with
status, kind, stage/substage, timestamps, aggregate progress, anomaly totals,
and normalized failure/recovery facts. That export omits operation/process
UUIDs, source row IDs, content, and paths.

## Key Files

| File | Responsibility |
|---|---|
| `application/onboarding_journey_coordinator_provider.dart` | sole Journey transition authority and operation orchestration |
| `domain/onboarding_journey_state.dart` | sealed Episodes, coherent evidence, transition policy, diagnostic model |
| `application/onboarding_gate_provider.dart` | read-only compatibility status and forwarding action seam |
| `application/onboarding_environment_report_provider.dart` | coherent prerequisite facts |
| `domain/onboarding_operation_snapshot.dart` | durable operation identity, stage, progress, and failure truth |
| `application/onboarding_durable_completion_verifier_provider.dart` | canonical post-operation proof |
| `presentation/onboarding_overlay.dart` | operational and terminal presentation |
| `features/environment_readiness/` | prerequisite Episode presentation |
