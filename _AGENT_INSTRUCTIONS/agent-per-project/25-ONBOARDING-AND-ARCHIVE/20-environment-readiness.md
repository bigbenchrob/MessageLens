# Environment Readiness Evaluation

## Purpose

Environment Readiness gathers and presents truthful prerequisite evidence for
Onboarding. It does not select the active Episode, navigate, complete a
prerequisite, or authorize import.

`OnboardingJourneyCoordinator` is the sole Journey authority. The Environment
Readiness feature consumes the coordinator's current coherent evidence and
renders the corresponding center-panel Episode.

## Ownership

```text
Onboarding environment probes
    -> OnboardingEnvironmentReport

OnboardingJourneyCoordinator
    -> typed OnboardingJourneyState

EnvironmentReadinessSurface provider
    -> presentation model for that state

EnvironmentReadinessPanelView
    -> rendering and typed user intent
```

The panel never watches independent prerequisite facts alongside Journey state.
Its Details disclosure uses the same evidence revision that selected the
Episode, preventing mixed-time FDA, Messages, Contacts, and app-store evidence.

## Evidence Evaluation

The canonical report evaluates:

1. archive mutation/maintenance state;
2. protected Messages database readability;
3. local Messages source presence and bounded history plausibility;
4. local Contacts database readability required by the current pipeline;
5. source-scoped import and Conversation Graph readiness;
6. prior typed operation failures requiring recovery.

During admitted maintenance, the report states maintenance truth and does not
open the import or graph stores as an unrelated observer.

## Report States

| State | Meaning |
|---|---|
| `maintenanceInProgress` | an admitted mutation owns protected derived stores |
| `permissionBlocked` | protected Messages access is not proved |
| `sourceUnavailable` | a required local source cannot be read |
| `sourceSparseOrUnsynced` | local Messages history appears unexpectedly small |
| `readyToImport` | prerequisite evidence is sufficient and derived stores need construction |
| `importFailed` | a prior source import failed |
| `graphProjectionFailed` | a prior graph build failed |
| `ready` | canonical durable application data is populated |

Import progress is operation truth, not a report state.

The report therefore carries the persisted `OnboardingOperationSnapshot`
alongside this coarse classification. An exact interrupted substage takes part
in durable reconciliation: for example, an interruption while
`extractingRichText` or `persistingRichText` remains safely resumable even when
partial graph evidence yields `graphProjectionFailed`. The details/operation
surface must present the exact snapshot rather than converting it to a generic
projection failure.

## Guided Episode Projection

The feature projects one calm surface at a time:

- checking;
- one blocker;
- ready to import;
- operation failure/retry;
- completed installation details when deliberately opened.

Successful checks recede under **Details**. The primary action remains visible
without turning the page into a diagnostic dashboard.

Typed actions express intent only:

- open FDA Settings;
- re-check;
- accept the currently observed local history;
- begin import;
- send a diagnostic report.

The action boundary forwards those intents to Onboarding. The coordinator
decides whether they are valid for the current Episode.

## FDA Semantics

The Full Disk Access Episode is completed only by a fresh report proving the
protected source readable. Opening System Settings, focus return, modal
dismissal, or relaunch may trigger a re-check but never marks FDA complete.

## Contacts Semantics

The current pipeline requires readable local Contacts data for names and
relationship context. Environment Readiness reports that requirement directly.
It does not claim that opening Contacts, checking another device, or waiting is
proof. Only fresh local evidence changes the Episode.

## Local History Semantics

MessageLens observes only history stored on this Mac. A sparse-history Episode
may suggest checking Messages in iCloud, but it cannot assert synchronization
state. **Use This Local History** is an explicit human acceptance of the current
observation and is valid only while that Episode owns the Journey.

## Navigation Boundary

`OnboardingCenterPanelSyncObserver` projects the coordinator's compatibility
status into `ViewSpec.environmentReadiness`. It does not derive prerequisite
truth. Active first-run Journey content outranks unrelated pipeline-incident
presentation. When the terminal Episode is acknowledged, normal application
ownership resumes and the readiness panel clears through existing navigation
policy.

## Invariants

1. Environment Readiness never assigns an Episode.
2. Widgets never infer import readiness.
3. One surface consumes one coherent evidence revision.
4. Re-check requests evidence; it does not advance.
5. Provider completion order cannot choose blocker priority.
6. Operation snapshot is operation truth, not navigation authority.
7. Maintenance reporting does not open protected derived stores.
8. Presentation copy states only what local evidence can prove.
9. Exact persisted interruption evidence is not discarded merely because the
   environment classification is coarser.
