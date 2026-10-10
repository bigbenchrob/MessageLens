# Response 89 — Checkpoint Stage 2A and Implement Source-Neutral Support and Environment Evidence (Stage 2B)

Date: 2026-10-10

Scope: verify the completed Stage 2A checkpoint, then implement only the
source-neutral presentation-evidence seam needed by Send Logs and Environment
Summary. No application was built, launched, installed, signed, or rehearsed.
No real Apple Messages, Contacts, MessageLens database, WD development root,
Toshiba archive, production archive, or development archive was accessed.

## 1. Baseline Git state, ancestry, worktree, and submodule

The verified source baseline was:

- branch: `fix/onboarding-import-stuck-state`;
- pre-implementation `HEAD` and upstream:
  `0f697d6fc5de22266afb579435b4fc03bcdc8a05`;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- Stage 2A implementation
  `ef95447d1f4e6659dccf16e4d916b4bd4bfd4824` was in ancestry;
- four repository worktrees existed, with exactly one worktree using the
  Feature 34 branch.

The source baseline manifest was kept outside the worktree at
`/private/tmp/messagelens-prompt89-source-baseline-manifest.md`. Known
unrelated untracked files were not changed or staged.

## 2. Prompt 88/Response 88 documentation checkpoint

Prompt 88 and Response 88 were already committed and pushed together at
`0f697d6fc5de22266afb579435b4fc03bcdc8a05`, subject
`docs(appczar): record neutral source evidence stage 2a`. No duplicate
checkpoint was created.

## 3. Before-change support call graph

Before Stage 2B, invoking Settings **Send Logs…** followed this graph:

```text
Settings action dispatch
  -> diagnosticReportExporterProvider
  -> onboardingOperationControllerProvider.future
  -> startupValidationTelemetryProvider
  -> SupportBundleDiagnosticReportExporter
  -> LogExportService
  -> SupportBundleExportService
       -> existing diagnostic and pipeline logs
       -> startup_validation.json
       -> optional onboarding_operation.json
       -> existing database-health report/error artifact
```

The direct construction of `onboardingOperationControllerProvider` made the
support command compositionally dependent on legacy Onboarding/Journey even
when AppCzar already owned startup semantics.

## 4. Before-change Environment Summary call graph

Before Stage 2B, `environmentSummaryProvider` directly imported
`startupValidationTelemetryProvider`, used `ref.exists`, and scanned its
events in reverse for the latest `admissionDecided` event. It projected
legacy installation-state and admission-basis fields into
`EnvironmentTechnicalSummary`, then the formatter and panel displayed those
legacy fields. AppCzar had no composition-appropriate startup projection.

## 5. Legacy authority and ambient-construction audit

The audit found two legacy-specific inputs: startup-validation telemetry and
the durable onboarding-operation controller. They remain valid evidence for
`StartupApp`, but they are not AppCzar authorities. Direct consumers now
depend only on the neutral presentation seam. The only adapter that imports
those providers is the isolated `StartupApp` adapter. AppCzar construction and
support invocation do not initialize either legacy controller.

## 6. Exporter mechanics and privacy inventory

The existing export mechanics were retained: flush current logs, create a
timestamped bundle inside the configured log directory, include current and
previous diagnostic logs, copy bounded known pipeline audit logs, request the
existing database-health diagnostic, reject unsafe/out-of-bundle artifacts,
and return the resulting attachment list to the existing share/export UI.

The existing privacy floor remains: no raw `.db`, `.db-wal`, or `.db-shm`
files; no row sampling; no automatic export; no default write to an attachment
archive root; and no weakening of bundle-local path checks.

## 7. Evidence classification and provenance

`StartupPresentationEvidence` is immutable, display-only evidence. It records
an explicit composition, availability, provenance, observation scope, and
composition-specific fields. `StartupApp` evidence is scoped to the latest
already-recorded startup admission decision. AppCzar evidence is scoped to one
completed assessment generation. The model cannot select a coordinator,
authorize mutation, start an assessment, or grant admission.

## 8. Typed neutral support-evidence design

`StartupSupportEvidence` contains the neutral presentation plus a bounded list
of recursively immutable typed JSON artifacts. Artifact names come from the
closed `StartupSupportArtifactKind` enum. The composition router selects
`StartupApp` or AppCzar using an explicit top-level composition input; it does
not inspect archive root, UUID, environment, or build predicates.

## 9. Typed Environment startup-evidence design

`EnvironmentTechnicalSummary` now holds `StartupPresentationEvidence` rather
than legacy installation enums. `StartupApp` renders the established
installation state and admission basis. AppCzar renders the selected
disposition, exact assessment generation, and TRUE/FALSE/UNKNOWN counts from
the completed generation. Availability, provenance, and observation scope are
also included in technical output.

## 10. Reuse/extraction diff versus duplication

The change extracted only composition-specific evidence adaptation. It did
not duplicate the support exporter, Environment evidence repositories,
AppCzar evaluator, source reader, startup classifier, database-health audit,
Settings dispatcher, or UI layout. Existing exporter and Environment
presentation mechanics consume the new typed projection.

## 11. Legacy Send Logs parity

In `StartupApp`, the adapter still obtains startup-validation telemetry and
the current onboarding-operation snapshot. Its artifacts retain the prior
filenames and aggregate fields, including progress, anomaly counts, and
failure category/recovery disposition. Operation IDs, row IDs, content, and
paths remain omitted. The Settings command and exporter UI are unchanged.

## 12. AppCzar Send Logs isolation and invocation boundary

In AppCzar composition, support evidence reads only the supplied
`AppCzarAssessmentState` when that state already contains a completed
assessment. The adapter does not read or construct
`appCzarAssessmentControllerProvider`, an evaluator, an observation reader,
Journey, or the onboarding-operation controller. It never starts an
assessment. Support invocation is therefore a projection of already-completed
evidence, not a startup operation.

## 13. Export scope, bounds, redaction, and destination

At most three distinct startup artifacts are written, each with a fixed typed
filename and a 256 KiB encoded limit. Oversized evidence is replaced by a
small explicit unavailable artifact. AppCzar exports at most 32 facts and only
fact ID, label, and TRUE/FALSE/UNKNOWN truth, plus generation and disposition.
Fact detail, diagnosis detail, roots, archive identities, record identifiers,
content, and capabilities are omitted. The destination remains the existing
timestamped support-bundle directory under the log directory.

## 14. User-visible export failure semantics

The existing export/share flow and thrown-failure behavior are unchanged.
Database-health generation failures continue to produce a bounded error
artifact while the rest of the bundle succeeds. Unsafe report paths are still
rejected. Startup evidence that exceeds its bound is represented as
unavailable rather than silently truncated into misleading evidence.

## 15. Legacy Environment Summary parity

`StartupApp` continues to show the same startup installation state and startup
admission basis sourced from the latest recorded admission decision. Existing
installation, data-folder, attachment, message, contacts, database, FTS,
maintenance, copy-summary, loading, error, and visual behavior remain intact.

## 16. AppCzar Environment frozen assessment semantics

AppCzar Environment Summary presents one frozen completed assessment
generation and its selected disposition. Fact truth is counted without
reinterpretation: FALSE remains FALSE and UNKNOWN remains UNKNOWN. No legacy
installation/admission rows appear in AppCzar composition, and no AppCzar
fact detail is exposed through the neutral model.

## 17. Absent/no-assessment facts

When no completed AppCzar assessment is available, the projection is explicitly
`unavailable` with the reason that no completed assessment is available in
this process. It does not run an evaluator, probe a source, synthesize a
healthy state, or fall back to legacy Journey evidence. Missing StartupApp
admission evidence is likewise explicit rather than inferred.

## 18. Stage 2A source-evidence noninterference

The entire `lib/essentials/messages_source` tree was unchanged. Baseline hashes
for Stage 2A readers/providers and their critical Coverage/Historical Archives
consumers remained identical. No source path, probe, currentness worker,
historical mutation boundary, or attachment authority changed.

## 19. Settings action dispatch after changes

The sidebar Settings dispatcher is byte-identical to baseline
(`840b3604502cf26213f6de236f4c586e109dc78391759871bc5c14e6489d3bf7`).
**Send Logs…** still resolves the same `DiagnosticReportExporter` and invokes
the same explicit user action. Only the provider's startup-evidence dependency
is now composition-neutral.

## 20. Provider construction and throwing-probe evidence

Provider tests establish that AppCzar composition with no supplied completed
snapshot produces explicit unavailable evidence while both
`appCzarAssessmentControllerProvider` and
`onboardingOperationControllerProvider` remain unconstructed before and after
presentation and support reads. A completed supplied snapshot projects one
generation without private detail. Recursive immutability is also tested.

## 21. Forbidden imports and mutation edges

Architecture tests require support and Environment consumers to import only
the neutral seam; require the AppCzar adapter to avoid Onboarding, controller,
evaluator, observation-reader, path, archive-identity, and detail dependencies;
and isolate legacy imports to the `StartupApp` adapter. No
`ArchiveMutationCoordinator.runWithCapability` edge, timer, polling loop,
import worker, graph updater, attachment sweep, or new source monitor was
introduced.

## 22. Startup and production activation noninterference

Startup selection remains outside the presentation seam. `main.dart` supplies
the already-selected composition and only exposes an AppCzar snapshot if its
controller already exists and is complete. The production activation constant
remains exactly `ProductionAppCzarActivation.disabled`; official production
still selects legacy `StartupApp`. Restart, archive admission, adoption gate,
signing, release identity, and startup disposition logic are unchanged.

## 23. Focused support/privacy tests

The exact focused Stage 2B set, including support assembly/export/privacy and
the new neutral evidence provider tests, passed 46 tests. After lint cleanup,
the focused evidence/support/Environment rerun passed 56 tests. Export tests
cover raw database rejection, outside-bundle rejection, symlink rejection,
legacy artifacts, aggregate operation evidence, fixed filenames, and bounded
AppCzar evidence.

## 24. Focused Environment Summary tests

Environment actions, formatter, provider, and panel suites passed within the
focused runs. Added tests prove AppCzar generation/disposition/truth counts,
absence of legacy startup rows, explicit unavailable evidence, and retained
StartupApp formatting and panel behavior.

## 25. Coverage/Historical Archives regressions

The Stage 2A messages-source, Message History Coverage, and Historical Archives
tests passed in the 283-test source/Settings/Environment regression group.
Their source files and architecture tripwires remained unchanged.

## 26. AppCzar/Operating regressions

All AppCzar directories plus Onboarding, attachments, and archive-environment
regressions passed: 1,082 tests. Existing Drift multiple-database warnings
were diagnostic only and did not fail the run.

## 27. StartupApp/Journey/Start Fresh regressions

Legacy startup, Onboarding, Journey, and Start Fresh tests passed in the
focused groups and full suite. Stage 2B changes presentation dependencies only;
they do not alter Journey semantic authority or Start Fresh behavior.

## 28. Archive/adoption authority regressions

Archive admission, archive-environment, attachment location/adoption, and
mutation-authority regressions passed. Attachment adoption execution remains
independently gated; no root, UUID, capability, or archive write policy was
broadened.

## 29. Architecture suite

The complete architecture/forbidden-import suite passed 614 tests. It includes
the new startup-presentation architecture constraints and retained Stage 2A,
historical authority, mutation-edge, production-default-off, and official
production-route tripwires.

## 30. Full Flutter suite

The full deterministic Flutter suite completed successfully with 3,182 tests
passed and one pre-existing skipped qualification test. It used temporary or
in-memory fixtures only. No real user data was read or modified.

## 31. Analyzer, generator, format, and diff hygiene

- Riverpod/build-runner generation completed successfully in 47 seconds.
- Generated changes were limited to the providers changed or added here.
- `flutter analyze` completed with **No issues found**.
- Final focused provider rerun after the last nullable-cast correction passed
  3 tests.
- `dart format` reported no remaining changes.
- unstaged and cached `git diff --check` passed.
- no release metadata bump was made because this is a bounded internal
  composition refactor with no separately authorized release artifact.

## 32. Project Conformance

`PROJECT CONFORMANCE: PASS`

- `BLOCKER: 0`
- `SHOULD FIX: 0`

Fair-Witness truth, provenance, one semantic authority per composition,
read-only projection, exporter privacy/bounding, legacy parity, non-eager
construction, mutation/adoption separation, production default-off, and
source/release/build noninterference all passed. No stop gate was encountered.

## 33. Implementation commit, push, and diff inventory

The bounded implementation is
`3c5a5774aeea20d32587e00c0b75d046043ba9fb`, subject
`refactor(startup): decouple support and environment evidence from onboarding`.
It contains 25 production, generated, architecture-test, and focused-test files
(1,244 insertions and 146 deletions) and was pushed to
`origin/fix/onboarding-import-stuck-state`. No Prompt, response, release
metadata, unrelated untracked file, shared-submodule pointer, or other
worktree content was included.

## 34. Documentation checkpoint, push, and recovery anchor

Prompt 89 and this Response 89 are the only intended files in the final
documentation checkpoint. They are staged by exact path and checked before
commit and push. A commit cannot contain its own recursively derived object
ID, so the exact documentation commit hash and successful push are reported in
the terminal handoff immediately after Git creates that recovery anchor.

## 35. Final Git, index, worktree, and submodule state

Before the documentation-only checkpoint, tracked implementation state and the
index were clean at the pushed implementation commit with upstream divergence
`0/0`. The final handoff records post-documentation `HEAD`, upstream parity,
clean tracked worktree/index, the unchanged worktree inventory, the clean
shared submodule, and the remaining known unrelated untracked files.

## 36. Readiness for Stage 2C review

Ready. Stage 2B provides the neutral presentation boundary needed to review
voluntary Start Fresh ownership without importing legacy startup authority
into AppCzar. Stage 2C remains a separate prompt and authorization.

## 37. Readiness for Stage 2D shell construction

Not yet. Stage 2C ownership review and implementation must occur first, then
Stage 2D may address neutral production-safe shell construction under its own
scope and stop gates.

## 38. Staged production-identity rehearsal readiness

Not ready. Stage 2C through Stage 2E dependency closure, shell construction,
parity, and lifecycle work remain. No production-identity artifact was built,
installed, launched, signed, or rehearsed.

## 39. Actual production cutover readiness

Not authorized. Production AppCzar activation remains unconditionally off and
official production continues to select legacy `StartupApp`.

## 40. Separate Start Fresh ownership question

Stage 2C must decide and enforce whether voluntary Start Fresh is an
Operating-owned explicit command occurrence. It must not become an eighth
top-level AppCzar jurisdiction, inherit Local Data Repair's automatic
authorization, or gain an independent startup/readiness authority. No Start
Fresh code changed in Stage 2B.

RESPONSE 88 STAGE 2A CHECKPOINT VERIFIED: YES

SEND LOGS REUSES EXISTING EXPORT MECHANICS WITHOUT APPCZAR JOURNEY DEPENDENCY: YES

ENVIRONMENT SUMMARY PRESENTS APPCZAR FACTS WITHOUT LEGACY STARTUP AUTHORITY: YES

LEGACY SETTINGS AND SUPPORT BEHAVIOR IS PRESERVED: YES

NO SECOND EVALUATOR, SOURCE MONITOR, OR MUTATION OWNER INTRODUCED: YES

SUPPORT PRIVACY AND BOUNDING ARE PRESERVED: YES

STAGE 2A SOURCE EVIDENCE AND HISTORICAL AUTHORITY ARE UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS UNCONDITIONALLY OFF: YES

PRODUCTION STILL SELECTS LEGACY STARTUPAPP: YES

PROJECT CONFORMANCE: PASS

STAGE 2B IMPLEMENTED: YES

READY FOR STAGE 2C REVIEW: YES

READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO

PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
