# MessageLens Feature 34
## Response 34 — Forensic Audit of Start Fresh No-Visible-Completion Failure

## Verdict

Start Fresh **did execute**. One admitted execution reset the rebuildable
message stores, cleared durable operation/failure evidence, passed virgin-state
verification, and requested the Onboarding refresh. The installation is now
virgin.

The human did not see that successful completion because repeated taps on the
visually inert red action created overlapping authorization/action flows. At
least three accepted action requests reached Start Fresh execution:

1. one request held mutation authority and completed the reset;
2. one overlapping request was denied while that first request held the same
   authority; and
3. one later request reached the service after the reset and was rejected
   because the installation was already virgin.

Those overlapping requests also created newer presentation occurrences and,
potentially, stacked indistinguishable authorization dialogs. A successful
older occurrence is deliberately forbidden from replacing a newer occurrence.
The concurrency rule is sound for stale results but, without single-flight
request admission, it allowed a duplicate request to obscure the successful
reset.

The bounded human reset review therefore **FAILS**, even though the durable
reset itself succeeded. A human-visible, single-request completion path has not
been qualified.

---

## 1. Running target verification

The first forensic capture was taken at
`2026-09-30T13:37:59-0700` (`2026-09-30T20:37:59Z`). No
`MessageLens Development` process was running then or at the closing capture
at `2026-09-30T13:47:06-0700`. Consequently there was no live development PID,
executable path, working directory, or parent process left to record, and the
app was not still doing work.

A production process was visible in the process-name census. It was excluded
immediately; its files, logs, databases, and runtime state were not opened or
inspected.

The tested development artifact still exists at:

```text
/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app
```

with executable:

```text
/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development
```

Its fingerprints still exactly match the Prompt 33 handoff:

| Artifact | SHA-256 |
|---|---|
| executable | `50718b614cb4b788bd4db971b4c57f1390a4b002a610f061a46340ab34cadab6` |
| App framework | `a27e2e95b5d473a4cfd37cb8a02adedb114c38870675aa4aaec88ad49a4b371e` |

The launch log independently records
`archive_environment=development` and `build_identity=developmentDebug` at
`2026-09-30T20:27:59.553507Z`. Prompt 34 supplies the prior live-path
verification from Prompt 33. Because the process had exited before this audit,
that exact path could not be re-read from a live process. There is no evidence
that the Feature 35 binary was under test.

Repository identity remained:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- Prompt 32 source fingerprints: unchanged from the build handoff.

---

## 2. Preserved live-evidence boundary

Before any SQLite open or log-content search, the following metadata was
captured. The development app had already stopped, so this is a stable
post-run boundary rather than a moving live-app boundary.

| Evidence | Size | Modification time | Inode | SHA-256 / state |
|---|---:|---|---:|---|
| `application_logs/app.log` | 494,690 | `2026-09-30T13:33:15-0700` | 430755 | `fa1fabfe054484e26f5a69ebb0c522fe3b3a65322ca8a638572b5d78275433f5` |
| `macos_import_ss.db` | — | — | — | **absent** |
| `working_ss.db` | 131,072 | `2026-09-30T13:32:45-0700` | 434356 | `423af6b01500a343e072c82e9b7525bde3d1bfe91eb0b1190a8e00b13c6797b9` |
| `user_overlays.db` | 2,035,712 | `2026-09-30T13:33:06-0700` | 227329 | `ebfd38600e343b4ad2b6b4c90766d033768bc532d56c55ed3c00a0d025024f94` |
| `presence.db` | 163,840 | `2026-09-30T13:32:44-0700` | 254381 | `887217e2596480f45817e86a4f398bd1ae3a75140c0efbeedc200b2d72497d82` |

No database WAL or SHM sidecar was present.

Every SQLite connection used `mode=ro&immutable=1` and began with
`PRAGMA query_only=ON`. There was no checkpoint, temp table, schema mutation,
vacuum, migration, or application write helper. A closing metadata/hash capture
was byte-for-byte identical to the opening capture. `PRAGMA quick_check` on
`user_overlays.db` returned `ok`.

No attachment payload directory was traversed.

---

## 3. Exact reset log window

The application does not log entry into the Settings reset panel or entry into
the red-button callback. The narrowest reconstructable window starts with the
last panel-navigation activity before the reset attempts at
`2026-09-30T20:30:05.929026Z` and ends with the last Start Fresh failure at
`2026-09-30T20:33:15.937193Z`.

The source-proven reset sequence is:

| UTC timestamp | Source | Evidence |
|---|---|---|
| `20:32:43.447976` | `AdvancedStartFresh` | An overlapping request was denied: `onboarding-start-fresh requested startFresh while onboarding-start-fresh held startFresh`. This proves another Start Fresh request already held mutation authority. |
| `20:32:43.831911` | `presence.db` | Required-sources schedule run 20 was created from the beginning. This is the durable effect of `supersedeRunFromBeginning(6)` inside the admitted Start Fresh operation. |
| `20:32:43.842492` | `MessageDataResetService` | `Reset Message Data requested`. |
| `20:32:43.842689` | `MessageDataResetService` | Source-scoped import database close began. |
| `20:32:43.843498` | `MessageDataResetService` | Conversation Graph database close began. |
| `20:32:44.074289` | `MessageDataResetService` | Both `macos_import_ss.db` and `working_ss.db` were deleted. |
| `20:32:44.075239` | `MessageDataResetService` | Providers were invalidated and both derived files were confirmed absent. |
| `20:32:44.075288` | `MessageDataResetService` | `Derived message data reset complete`; overlay, preferences, and attachment archive reported preserved. |
| `20:32:44.720511` | `OnboardingCenterPanelSyncController` | Onboarding status became `awaitingUserAction`; the readiness center panel was requested. This is downstream of successful full virgin verification and refresh. |
| `20:32:44.783467` | `PanelStackSurface` | The readiness panel was built in the center surface. |
| `20:32:44.823938` | `presence.db` | Required-sources run 20 began its first trip. |
| `20:33:06.847522` | `AttachmentArchiveService` | Empty-graph sweep observed zero attachments and cursor zero; no payload inspection is implied by this audit. |
| `20:33:15.937193` | `AdvancedStartFresh` | A later accepted request reached `StartFreshService`, which rejected `completedInstallationAdvancedReset` because the current installation was already `virgin`. |

There is no reset failure, virgin-verification failure, `PlatformDispatcher`
error, provider-disposal assertion, or uncaught exception in this interval.

---

## 4. Number of red-button requests and current-state reads

The exact pointer-tap count is not recoverable because the callback entry,
current-state read, authorization push/result, and presentation occurrence are
not logged with request IDs.

The durable/log/source lower bounds are nevertheless conclusive:

- **red-button action callback invocations:** at least **3**;
- **accepted authorization results:** at least **3**;
- **preparing presentation occurrences:** at least **3**;
- **initial bounded current-state reads:** at least **3**;
- **additional bounded failure-classification reads:** at least **2**;
- **total bounded action-layer current-state reads initiated:** at least **5**;
- **full service validation reads:** at least **4**: one before each of the
  three service attempts and one post-reset virgin verification for the
  successful attempt.

The two failure stacks both pass through
`SidebarActionDispatcher.dispatch` and
`SettingsActionListActions.selectActionCallback`, not the retry path. Each
therefore came from a separate red-action request. The successful admitted
execution is the third proven request. Every such execution can occur only
after its own authorization future returns `true`.

Additional taps may have been superseded before service invocation, cancelled,
or left behind another authorization route. The current implementation does
not retain enough evidence to distinguish those cases. Later requests were not
coalesced: one was authority-denied and one independently ran far enough to be
rejected as already virgin.

The confirmation page cannot be assigned to a particular request because the
authorization routes and presentation occurrences have no shared logged
identity.

---

## 5. Cause of the delay before confirmation

The red action does not transition to any busy state before it awaits
`readInstallationState()`.

That read uses `SqliteMessageLensInstallationEvidenceReader.readBounded`, which
runs in an isolate and sequentially inspects:

1. overlay;
2. source-scoped import;
3. Conversation Graph, including FTS readability;
4. presence.

For the import and graph databases it performs targeted table probes and full
`messages` counts; the graph read also counts chats and chat-message edges.
The same launch's nearby startup inspection recorded approximately 2.434
seconds for the import database and 2.222 seconds for the graph database, with
5.561 seconds total startup validation. The red-action path lacks start/end
telemetry, so the exact tap-to-dialog duration cannot be measured, but the
several-second report is consistent with this bounded evidence read.

During that await, `SettingsActionList` renders the action as a plain
`GestureDetector`. It has no hover/pressed/busy rendering, it does not observe
the action provider's asynchronous state, and it remains enabled. The
presentation does not enter `preparing` until **after** authorization is
accepted.

Classification:

- the bounded evidence work is legitimate;
- its exact performance is insufficiently instrumented and merits a bounded
  performance check;
- the lack of immediate acknowledgement/disable is a confirmed UX defect;
- allowing further requests during that silent interval is a functional
  concurrency defect, not merely polish.

---

## 6. Start Fresh invocation and mutation-authority verdict

Authorization acceptance is not logged directly, but is source-proven for at
least three requests: `AdvancedStartFreshActionImpl` cannot call the service
until `requestAuthorization()` has returned `true`.

At least three service attempts occurred:

1. **Successful admitted request.** It acquired
   `ArchiveMutationOperation.startFresh` as owner
   `onboarding-start-fresh`, reset the operation snapshot and failure evidence,
   superseded the presence schedule, deleted derived stores, passed full virgin
   verification, and refreshed Onboarding.
2. **Overlapping denied request.** At `20:32:43.447976Z`, archive mutation
   admission failed because request 1 already held the same exclusive tenure.
3. **Late request.** At `20:33:15.937193Z`, the service's fresh full validation
   classified the installation as virgin and rejected the completed-installation
   entry point before requesting mutation authority.

Archive-mutation authority was therefore acquired exactly once for the reset
that mutated durable state. One additional authority request was denied. The
late virgin request did not reach authority acquisition.

The reset capability is also source-proven: the message-data reset reached
`resetDerivedDataForStartFresh`, which requires an active
`ArchiveMutationOperation.startFresh` capability before deletion.

---

## 7. Durable reset state after the click

The current durable Onboarding operation snapshot is:

```text
status: idle
operation_id: null
process_session_id: null
kind: null
current_stage: null
current_substage: null
completed_stages: []
failure: null
progress_revision: 0
```

All three bounded pipeline-failure settings are empty:

- `onboarding_last_import_result`;
- `onboarding_last_graph_projection_result`;
- historical `onboarding_last_migration_result`.

Current derived-store evidence is:

- `macos_import_ss.db`: absent;
- `working_ss.db`: valid schema, recreated empty;
- graph `messages`: 0;
- graph `chats`: 0;
- graph `contacts`: 0;
- graph `handles`: 0;
- graph `chat_to_message`: 0;
- graph `attachments`: 0;
- graph `message_to_attachment`: 0.

Immediately before reset, the log recorded 138,811 import messages and 138,811
graph messages. The difference from Response 31's approximately 138,802 is
explained by live updates before this reset and is not material to the reset
verdict.

Required-sources presence run 20 was created at
`2026-09-30T20:32:43.831911Z` and began its first trip at
`20:32:44.823938Z`, confirming the reset's schedule-restart step.

This is **completed destructive mutation with successful virgin verification**,
not a partial reset. The late error itself records the fresh post-reset
classifier result:

```text
virgin: No consequential MessageLens import has begun; any derived stores are
valid and empty.
```

---

## 8. Preservation-scope verification

`user_overlays.db` exists, opens read-only at schema version 8, and returns
`ok` from `PRAGMA quick_check`.

The two bounded favourite intents requested by Prompt 34 remain present and
true:

| Contact | Participant ID | `is_favorited` |
|---|---:|---:|
| Claire | `17592186044433` | 1 |
| Rusung | `17592186044472` | 1 |

No unrelated favourite history was inspected.

The canonical development archive identity remains:

- environment: `development`;
- archive instance UUID: `e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5`;
- manifest modification time: `2026-07-27T12:39:44-0700`;
- manifest SHA-256:
  `38bda84016a88d2aee2930e470d31535f9c67db5b5397cf480c9c98803899082`.

The attachment-location setting remains:

- mode: `custom_external`;
- path metadata:
  `/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive`;
- volume: `Toshiba_manual_bu`;
- write policy: `active_archive`;
- bookmark present: yes (length 1,736; bytes not emitted).

The relocation-current record remains operation
`5c20c87a-c6d6-4489-8887-ae629301884f`, with modification time
`2026-09-17T12:10:45-0700` and SHA-256
`ac3334c824e08c0ecadd7bc5e3f4d0ee29385c861becf9b0d60fcae21b557b98`.

No attachment payload was inspected. The old configuration/identity timestamps
and current values demonstrate that Start Fresh did not replace or rewrite
them.

---

## 9. Post-authorization presentation/currentness trace

For a single request, the intended path is:

```text
fresh bounded classification
-> authorization dialog accepted
-> presentation.beginPreparing() creates occurrence N
-> wait for one presentation frame
-> StartFreshService is awaited
-> service verifies virgin and refreshes Onboarding
-> showVerifiedVirgin(expectedOccurrence: N)
-> overlay shows “Starting Onboarding”
-> Journey leaves normal-application ownership
-> overlay dismisses on the reconciliation frame
```

The confirmation dialog remains visible while the action is waiting for human
authorization. After acceptance, the preparing overlay is intended to replace
it and remain while the service runs.

The actual repeated-request path broke visible ownership:

- every accepted request independently calls `beginPreparing()`, incrementing
  the global presentation occurrence;
- `showVerifiedVirgin` and `showFailure` silently ignore an older occurrence;
- the action checks currentness before service start, but once service work has
  begun it cannot prevent a later request from superseding its presentation;
- multiple calls to `showDialog` are not coalesced, so visually identical
  authorization routes can be stacked;
- after one dialog is popped, another identical dialog can remain above the
  operation overlay, making the accepted click appear to do nothing;
- the successful request's `showVerifiedVirgin` can be suppressed by a newer
  occurrence even though its durable mutation succeeded;
- the newer request can then surface an already-virgin failure behind any
  remaining modal route.

The log proves that Onboarding itself reached `awaitingUserAction` and built the
readiness panel at `20:32:44.720511Z`–`20:32:44.783467Z`. The failure was
therefore presentation of a completed transition, not failure to refresh the
Journey.

`StartFreshService` does invalidate installation, scheduler, environment, and
gate providers after verified success. The advanced action and presentation
providers are keep-alive. No provider-disposal or invalidation exception was
logged. The relevant currentness hazard is the newer presentation occurrence,
not owner disposal.

---

## 10. Prompt 32 automated coverage gaps

| Required scenario | Current coverage |
|---|---|
| Authorization accepted and the real `StartFreshService` async path awaited through UI | **No.** Provider/widget tests use `_RecordingStartFreshService`; service tests exercise `StartFreshServiceImpl` separately with fake reset/validator dependencies. |
| Visible in-progress feedback after Start Fresh acceptance | **Partial.** A single-request widget test verifies `Preparing a fresh start` before a fake service completes. |
| Immediate feedback while the pre-authorization current-state read is slow | **No.** No test holds the current-state reader pending and asserts busy/disabled UI. |
| Successful completion transitions to normal Onboarding | **Partial.** A fake service is completed and the test manually advances the gate to `awaitingUserAction`; the real refresh chain is not exercised. |
| Multiple rapid red-button taps while current-state reads are pending | **No.** |
| Exactly one authorization route and one service call under repeated taps | **No.** |
| Service success while a newer request/occurrence exists | **Misaligned coverage.** The action test intentionally allows two services and expects the newer one to succeed; it does not cover an older destructive success followed by a newer authority/ineligibility failure. |
| Service completion while presentation/Journey ownership changes | **Partial.** Manual occurrence and Journey transition tests exist, but not the real duplicate-request race. |
| Stacked authorization dialogs | **No.** |

The existing stale-occurrence tests validate that old async results cannot
overwrite newer presentation. They do not validate that a destructive action
is single-flight. In this run, the stale-result protection hid a real success
because duplicate destructive requests were admitted far enough to create
newer occurrences.

---

## 11. Separate UX classifications

### A. Red Reset button appears dead for several seconds

**Confirmed UX defect and functional concurrency trigger.** The bounded read is
legitimate, but no immediate phase, hover/press/busy treatment, disable, or
single-flight guard is installed before it. The user is invited to tap again,
and every tap can start another state read and authorization flow.

### B. Start Fresh receives a click but has no visible transition

**Confirmed presentation/concurrency defect after successful execution.** The
service completed and established virgin state, but duplicate accepted flows
created competing occurrences and authorization routes. The readiness panel was
built behind that presentation conflict.

These are related through repeated input but are distinct defects.

---

## 12. BLOCKER findings

1. **Advanced Start Fresh is not single-flight.** Repeated red-action taps can
   produce multiple current-state reads, multiple modal authorization routes,
   multiple accepted action occurrences, and multiple service attempts for one
   human intent.
2. **Successful destructive completion can be visually lost.** A newer
   duplicate occurrence can suppress `showVerifiedVirgin` from the request that
   actually completed the mutation.
3. **The interaction stays enabled and visually inert during the slow
   pre-authorization read.** This directly caused the duplicate requests in the
   human review.
4. **The qualified path did not visibly reach normal Onboarding.** The bounded
   human reset review cannot pass, and the full clean-slate import qualification
   remains blocked.

## 13. SHOULD FIX findings

1. Add request/occurrence identifiers and timestamps at callback entry,
   bounded-read start/end, authorization requested/accepted/cancelled,
   service start/end, and presentation outcome. The exact tap/dialog count is
   otherwise unrecoverable.
2. Measure the bounded current-state reader stages on the red-action path. The
   nearby evidence suggests several seconds are spent in serial import/graph
   inspection; any optimization must preserve fresh durable classification.
3. Use a control with explicit hover, pressed, busy, and disabled semantics
   rather than a bare destructive-text `GestureDetector`.

---

## 14. Recommended next correction

Make the advanced action request single-flight from the first tap through final
completion/cancellation:

1. synchronously claim one action occurrence before starting the bounded state
   read;
2. publish an immediate `checking availability`/busy phase and disable the red
   action;
3. coalesce or ignore later taps while that occurrence is active;
4. allow at most one authorization route;
5. keep the same occurrence from classification through authorization,
   mutation, verification, and Journey handoff;
6. ensure a verified destructive success cannot be replaced by a duplicate
   request failure;
7. restore idle interaction only after cancel or a terminal visible outcome;
8. add the missing race, slow-read feedback, stacked-dialog prevention, and
   real refresh-chain tests listed above.

This correction should remain inside the existing action/presentation
authority. It should not create a second onboarding or mutation authority, and
it should continue to rely on the archive mutation coordinator for the actual
exclusive mutation tenure.

---

## 15. Qualification impact

The reset panel's one-selection menu behavior passed. The red action eventually
opened authorization. The underlying Start Fresh operation completed and
established virgin state with the promised preservation scope.

The bounded human review still **FAILS** because one user-intent path did not
remain single, the interaction encouraged duplicate requests, and successful
completion was not visible. The full clean-slate Onboarding import
qualification remains blocked pending correction, validation, rebuild, and a
repeat bounded human review.

---

## 16. Git, worktree, index, and submodule state

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- upstream: `origin/fix/onboarding-import-stuck-state` at the same checkpoint;
- Prompt 32 tracked correction: still present and unstaged (21 modified tracked
  files);
- Prompt 32 new implementation/tests: still untracked (3 files);
- index: empty;
- `git diff --check`: PASS;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- all pre-existing unrelated untracked files: untouched;
- Prompt 32 source fingerprints and Prompt 33 build fingerprints: unchanged.

No source, test, generated file, existing prompt/response, database, log,
archive configuration, or attachment payload was modified by this audit. No
GUI control was clicked, the app was not relaunched, and Start Fresh was not
run again. The only filesystem addition is this required Response 34 record.

START FRESH POST-CONFIRMATION FORENSIC AUDIT COMPLETE: YES

START FRESH ACTUALLY EXECUTED: YES

VIRGIN STATE ESTABLISHED: YES

BOUNDED HUMAN RESET REVIEW: FAIL
