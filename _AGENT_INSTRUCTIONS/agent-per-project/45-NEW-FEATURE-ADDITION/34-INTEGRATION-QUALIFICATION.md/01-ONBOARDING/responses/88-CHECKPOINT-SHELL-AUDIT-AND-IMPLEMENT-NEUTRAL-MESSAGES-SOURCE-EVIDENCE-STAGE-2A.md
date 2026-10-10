# Response 88 — Checkpoint Shell Audit and Implement Neutral Messages Source Evidence (Stage 2A)

Date: 2026-10-10

Scope: checkpoint the completed Response 87 audit, then implement only the
neutral current-Apple-Messages source-evidence boundary required by Message
History Coverage and Historical Archives. No application was built, launched,
installed, or signed. No real Apple Messages, Contacts, MessageLens database,
WD development root, Toshiba archive, or production archive was accessed.

## 1. Baseline and Response 87 documentation checkpoint

The source baseline matched Prompt 88 before work began:

- branch: `fix/onboarding-import-stuck-state`;
- pre-checkpoint `HEAD` and upstream:
  `53a695706e483ea6064da2376f4e0edf1ba7f973`;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- Response 86 implementation
  `4a8b549e65bf16416065797aeaebde062f8558fd` and documentation
  `53a695706e483ea6064da2376f4e0edf1ba7f973` were ancestors;
- only one worktree used the Feature 34 branch.

Prompt 87 and Response 87 were staged by exact path, checked with
`git diff --cached --check`, committed alone as
`05160796274577cbb3c7d92beafe4d6322105a6e`
(`docs(appczar): audit production-safe operating shell`), and pushed at `0/0`
before source edits. The source-only baseline manifest is outside the worktree
at `/private/tmp/messagelens-prompt88-source-baseline-manifest.md`.

## 2. Git, upstream, submodule, and worktree inventory

After the implementation checkpoint and push:

- branch: `fix/onboarding-import-stuck-state`;
- `HEAD` and upstream:
  `ef95447d1f4e6659dccf16e4d916b4bd4bfd4824`;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at the required pinned commit;
- four total repository worktrees exist, and exactly one—the permitted primary
  worktree—uses `fix/onboarding-import-stuck-state`.

Known unrelated untracked files remained untouched. Prompt 88 remained
untracked until the final documentation-only checkpoint described in section
29.

## 3. Existing Onboarding-named Messages providers

Before extraction, `fullDiskAccessProvider` constructed
`MacosFullDiskAccess` from `chatDbSourceProbeReaderProvider.readMaxRowId`.
`MacosFullDiskAccess.messagesDatabasePath` owned the default
`$HOME/Library/Messages/chat.db` construction. The keep-alive compatibility
providers were and remain:

- `onboardingFullDiskAccessProvider`, projecting
  `fullDiskAccessProvider.canReadMessagesDatabase()`;
- `onboardingMessagesDatabasePathProvider`, projecting
  `fullDiskAccessProvider.messagesDatabasePath`.

Those providers remain available to legacy Onboarding. Settings no longer
imports or consumes either one.

## 4. Current path, canonicalization, reader, and policy

The pre-existing Onboarding path construction was extracted unchanged into
`ProbeCurrentMessagesSourceEvidenceReader.defaultMacosMessagesDatabasePath`:
it reads `Platform.environment['HOME']`, preserves the existing
`/Users/unknown` fallback, and appends `Library/Messages/chat.db`.

No new canonicalization rule was added. The selected path is passed literally
to the existing `SqliteChatDbSourceProbeReader.readMaxRowId` boundary, which
performs the bounded read-only filesystem/SQLite probe and returns the maximum
message row identity. A supplied symlink path remains a supplied symlink path;
the trusted reader's behavior is preserved. Archive-root native/Dart
canonicalization is a separate authority and was not changed.

## 5. Message History Coverage call graph

The current call graph is:

```text
messageHistoryCoverageReportProvider
  -> dbMaintenanceLockProvider
  -> currentMessagesSourceEvidenceProvider
       -> currentMessagesSourceEvidenceReaderProvider
       -> ProbeCurrentMessagesSourceEvidenceReader
       -> existing chatDbSourceProbeReaderProvider.readMaxRowId
  -> messageHistoryCoverageRepositoryProvider
  -> MessageHistoryCoverageRepository.readEvidence(exact sourcePath)
  -> reconcileMessageHistoryCoverage
  -> existing report/card/export presentation
```

Maintenance locking, provider caching, retry invalidation, no-history
reconciliation, error logging, and user-facing failure text are unchanged.
The repository is not opened when neutral evidence is non-readable.

## 6. Historical Archives call graph

Historical Archives now obtains only the current-live-source path through
`currentMessagesSourcePathProvider`. The panel model watches that projection,
and the workflow notifier reads it again at the existing import and removal
guards. Candidate donors still come from the existing folder chooser,
inspection, registry, lineage, provenance, and source-scoped archive services.

```text
currentMessagesSourcePathProvider
  -> neutral reader.sourcePath (no database read)
  -> panel live-source identity display/guard
  -> import/remove live-source refusal guard

selected historical donor
  -> existing inspector/lineage/registry specialists
  -> existing human authorization
  -> ArchiveMutationCoordinator
  -> existing import/removal/recovery specialist
```

No donor selection, inspection, provenance, protected-material distinction,
path-failure handling, or mutation edge was moved into the neutral module.

## 7. AppCzar source reader and evaluator separation

AppCzar remains unchanged. `SqliteAppCzarObservationReader.readSource()` still
uses the already supplied `_messagesDatabasePath`, takes its two bounded
samples in an isolate, and produces `AppCzarSourceObservation`. The evaluator
still owns TRUE/FALSE/UNKNOWN startup facts and the seven-jurisdiction
disposition.

The new neutral boundary is not an AppCzar observer and does not select a
jurisdiction. This deliberate separation preserves AppCzar's stable two-sample
meaning while extracting the former Onboarding path/probe seam for legacy
Onboarding and the two Settings consumers.

## 8. Chosen neutral module and reuse rationale

The new module is `lib/essentials/messages_source/`. It contains:

- `CurrentMessagesSourceEvidence` and its literal read condition;
- `CurrentMessagesSourceEvidenceReader`;
- `ProbeCurrentMessagesSourceEvidenceReader`;
- generated Riverpod providers for the reader, lazy path projection, and
  bounded evidence read;
- one small feature-level provider barrel.

This is a true extraction/thin adapter: the former Onboarding default path
logic moved inward, and the existing `chatDbSourceProbeReaderProvider` remains
the actual low-level reader. No SQLite query, source selection, or access
classification was copied into Settings.

## 9. Typed read-only semantics

`CurrentMessagesSourceReadCondition` has four literal states:

- `readable`: the existing bounded probe returned `maxRowId`;
- `accessDenied`: and only this state, when the existing probe reports
  `ChatDbSourceProbeFailureKind.accessDenied`;
- `unavailable`: the other known typed probe failures (missing source,
  filesystem read failure, SQLite open failure, absent expected schema, or
  query failure);
- `unknown`: an unexpected, unclassified exception.

The evidence preserves source path, optional maximum row id, typed failure
kind, original error, and stack trace. It does not claim FDA is disabled,
ready, installed, current, repairable, or importable.

## 10. Path cache, change, and identity handling

The reader stores a resolver callback, not a resolved path. `sourcePath` calls
the resolver each time. `read()` resolves exactly once for that observation
and binds the returned result to that same path. No keep-alive path claim,
timer, or stale permission cache was introduced. Tests switch a reader between
two temporary databases and prove the second observation uses the new path and
identity.

## 11. Legacy Onboarding compatibility adapter

`MacosFullDiskAccess` remains the legacy `FullDiskAccess` implementation, but
it now delegates inward to `CurrentMessagesSourceEvidenceReader`.
`messagesDatabasePath` projects `reader.sourcePath`; source inspection projects
the neutral typed result back to the legacy three-state
`MessagesSourceAccessResult`. Existing error logging and System Settings
navigation remain in Onboarding. The neutral module never imports Onboarding,
so no reverse dependency or cycle exists.

## 12. Message History Coverage change and parity

Coverage replaced its reads of `onboardingFullDiskAccessProvider` and
`onboardingMessagesDatabasePathProvider` with one bounded read of
`currentMessagesSourceEvidenceProvider`. A readable result passes its exact
bound path to the unchanged repository. Access-denied, unavailable, and
unknown results retain the same existing user-visible failure guidance and do
not open coverage stores.

The report algorithm, source identity, counts, cards, actions, exports,
maintenance behavior, cache/refresh behavior, and failure rendering are
unchanged. No source count or startup disposition is derived for AppCzar.

## 13. Historical Archives change and parity

The workflow replaced three uses of
`onboardingMessagesDatabasePathProvider` with
`currentMessagesSourcePathProvider`: panel construction, import live-source
guard, and removal live-source guard. That projection is path-only and does
not eagerly read Apple Messages.

All donor identities, registry facts, lineage admission, protected-material
rules, confirmation steps, mutation coordinator calls, cancellation, retry,
and activity presentation are unchanged. The required later Operating
drain/restart treatment after historical mutation remains a Stage 2E item.

## 14. Mutation and provenance noninterference

The neutral API exposes no write method, database handle, archive capability,
mutation token, provider for a MessageLens data root, or coordinator action.
Coverage continues to be diagnostic/read-only. Historical mutation still
requires its existing typed specialist state, human authorization, and
`ArchiveMutationCoordinator`. Current-live path evidence cannot authorize an
import, removal, recovery, adoption, relocation, attachment repair, or reset.

## 15. Architecture and forbidden-import tripwires

The architecture suite now proves that:

- both Settings consumers import `messages_source`, not Onboarding source
  providers;
- legacy Onboarding delegates to the neutral reader;
- the neutral module imports none of Journey, Onboarding gate/operation,
  Environment Readiness, AppCzar evaluator/coordinator, support export,
  archive mutation, or database-writer authority;
- no neutral file starts a timer, legacy monitor, graph update, attachment
  sweep, import, `App`, or `StartupApp`;
- platform environment access moved from the former Onboarding implementation
  to the neutral infrastructure reader;
- existing production activation, startup composition, AppCzar census,
  mutation-edge, adoption-gate, and forbidden-import tripwires still pass.

The test avoids asserting incidental internal filenames and checks the
substantive dependency boundary instead.

## 16. Focused neutral-reader tests

Focused tests prove readable path/max-row preservation, literal access denial,
all known unavailable failure kinds, genuine controlled UNKNOWN, missing-file
noncreation, trusted symlink behavior, per-observation path re-resolution, and
provider laziness. The complete directly affected focused group passed 83/83.

## 17. Coverage feature results

The dedicated Coverage resolver file passed 8/8. It includes exact source
identity forwarding, cache behavior, maintenance non-opening, maintenance
refresh, repository failure rendering, and a loop proving access-denied,
unavailable, and unknown evidence never opens the coverage repository. The
same file also passed in the 83-test focused group and full suite.

## 18. Historical Archives feature results

The dedicated Historical Archives workflow/provider file passed 56/56. It
retains current-source refusal, donor/provenance/lineage handling, missing
source and read-failure behavior, protected distinctions, import/removal
authorization, lifecycle cancellation, and typed progress ownership. It also
passed in the focused group, cross-boundary matrix, and full suite.

## 19. Onboarding and AppCzar regression results

Onboarding readiness and `MacosFullDiskAccess` adapter tests passed in the
83-test focused group. The broader AppCzar evaluator, Source Access Repair,
Operating currentness, source-scoped import, graph/archive import, startup
composition, inactive production eligibility, adoption execution, and
adoption-architecture matrix passed 251/251. No AppCzar production source or
evaluator file changed.

## 20. Operating currentness and monitor noninitialization

Source inspection and architecture tests prove the neutral providers have no
timer or monitor dependency and construct no app root. Reading the path
projection does not perform a source read; reading evidence performs exactly
one bounded call. Existing Operating currentness tests pass. The legacy
`chatDbChangeMonitorProvider` remains present only in the untouched legacy app
root and is neither read nor initialized by the new seam.

## 21. Production selector and disabled activation

The 251-test cross-boundary matrix and 394-test architecture suite preserve:

```text
official admitted production identity -> eligible TRUE
ProductionAppCzarActivation -> always disabled
production root -> StartupApp
recognized development identity -> AppCzarStartupHarness
AppCzar census -> 6 top-level + 1 admitted Operating
```

`main.dart`, production eligibility, disabled activation, process restarter,
archive admission, signature validation, and adoption gate were not edited.

## 22. Architecture suite

`flutter test test/architecture/forbidden_imports_test.dart` passed 394/394.
The first local draft of the new tripwire contained an incidental literal-path
assertion that collided with existing Historical Archives explanatory copy;
that brittle assertion was removed before checkpointing. The final substantive
boundary test and all existing architecture rules pass.

## 23. Analyzer

`flutter analyze` completed with zero issues. Two constructor style notices and
import ordering in the new code were corrected before the clean run.

## 24. Full Flutter suite

The deterministic full `flutter test` suite passed 3,173 tests with one
intentional qualification-harness skip and zero failures. Existing Drift
multiple-database diagnostic warnings appeared but did not represent test
failures or new behavior.

## 25. Generation, formatting, and diff hygiene

`dart run build_runner build --delete-conflicting-outputs` completed and
checked 1,785 generated actions. Generated Riverpod output is committed with
its sources. Formatting the 18 intended handwritten/generated Dart paths
reported zero further changes. `git diff --check` and
`git diff --cached --check` passed. The implementation checkpoint contains
exactly 21 source/test/generated files (724 insertions, 99 deletions).

`pubspec.yaml`, `pubspec.lock`, `CHANGELOG.md`, entitlements, signing, bundle
identity, and release metadata are unchanged.

## 26. Project Conformance

`PROJECT CONFORMANCE: PASS` for Stage 2A. There is one neutral source-evidence
truth for the two rewired Settings consumers and legacy Onboarding adapter;
the pre-existing AppCzar two-sample startup observer remains deliberately
separate and unchanged. No new startup authority, currentness owner, eager
pre-admission I/O, source/archive mutation, historical authority, production
activation, production restart, signing change, or development behavior was
introduced.

## 27. Findings

- `BLOCKER: 0`
- `SHOULD FIX: 0`

No stop gate was encountered.

## 28. Implementation checkpoint and push

The exact implementation checkpoint is
`ef95447d1f4e6659dccf16e4d916b4bd4bfd4824`, subject
`refactor(source): share neutral Messages source evidence`. It was pushed
normally to `origin/fix/onboarding-import-stuck-state`; local and upstream were
`0/0` afterward.

## 29. Prompt/Response 88 documentation checkpoint and push

Prompt 88 and this Response 88 are the only files in the final
documentation-only checkpoint. They are staged by exact path and checked
before commit. Because a Git commit cannot contain its own recursively derived
object id, the exact documentation commit hash and successful push are
reported in the terminal handoff immediately after Git creates that commit.

## 30. Final Git, index, worktree, and submodule state

Immediately before the documentation-only checkpoint, tracked implementation
state and index were clean at the pushed implementation commit. The final
handoff records the post-documentation `HEAD`, upstream parity, clean tracked
worktree/index, unchanged four-worktree inventory, and clean shared submodule.
All unrelated untracked artifacts remain untouched.

## 31. Stage 2B readiness

Stage 2B is ready to begin as a separate reviewed prompt. The needed dependency
is now present: support/Environment evidence can consume neutral source
evidence without importing Onboarding source authority. Stage 2B must still
preserve its own evidence boundaries and cannot infer startup disposition from
this module.

## 32. Stage 2C Start Fresh open question

Before Stage 2C implementation, architecture review must decide whether
voluntary Start Fresh is an Operating-owned command occurrence (or another
explicitly allowed in-jurisdiction lifecycle) rather than an eighth top-level
AppCzar disposition. User-initiated Start Fresh must not be conflated with
system-selected Local Data Repair. Stage 2A does not resolve this question and
does not add a jurisdiction.

## 33. Production-identity rehearsal readiness

Not ready. Stage 2B through Stage 2E dependency closure, parity, and lifecycle
work remain outstanding. No production-identity build, launch, rehearsal,
installation, signing, TCC, restart, or archive operation was performed.

## 34. Production cutover readiness

Not authorized. Production AppCzar activation remains unconditionally off,
official production continues to select legacy `StartupApp`, and development
AppCzar composition is unchanged.

RESPONSE 87 AUDIT CHECKPOINTED: YES
NEUTRAL CURRENT-MESSAGES SOURCE EVIDENCE IMPLEMENTED: YES
COVERAGE NO LONGER DEPENDS ON ONBOARDING SOURCE AUTHORITY: YES
HISTORICAL ARCHIVES NO LONGER DEPENDS ON ONBOARDING SOURCE AUTHORITY: YES
EXISTING SOURCE READ / KNOWN FALSE / UNKNOWN SEMANTICS PRESERVED: YES
NO ADDITIONAL CURRENTNESS WORKER OR SEMANTIC OWNER INTRODUCED: YES
HISTORICAL AND ATTACHMENT MUTATION AUTHORITY UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION REMAINS UNCONDITIONALLY OFF: YES
PRODUCTION STILL USES LEGACY STARTUPAPP: YES
DEVELOPMENT APPCZAR COMPOSITION UNCHANGED: YES
PROJECT CONFORMANCE: PASS
READY FOR STAGE 2B: YES
READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
