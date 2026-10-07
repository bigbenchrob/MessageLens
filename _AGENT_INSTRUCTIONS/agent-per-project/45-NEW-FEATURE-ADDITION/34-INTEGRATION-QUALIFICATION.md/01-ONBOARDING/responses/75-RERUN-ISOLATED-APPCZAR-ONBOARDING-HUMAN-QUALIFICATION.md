# MessageLens Feature 34
## Response 75 — Rerun Isolated AppCzar Onboarding Human Qualification After Canonical-Root Fix

Date: 2026-10-07

### 1. Exact Git HEAD/upstream state

The qualification began and ended on `fix/onboarding-import-stuck-state` at
`cc5847c1e311ef9b81a3223e1be2388429e4e02b`. The upstream resolves to the
same commit and the ahead/behind result is `0/0`. The tracked worktree and
index were clean before the experiment and remain clean. The shared
instructions submodule remains clean at
`95326f515ef4719f155ce6e223990398daad6311`. Exactly one worktree has the
Feature 34 branch checked out.

Known unrelated untracked files remained untouched. Prompt 75 itself was
already untracked, and this response is intentionally left untracked.

### 2. Prompt 74 implementation ancestry

Both required ancestry checks succeeded:

- Prompt 73 failed-qualification checkpoint:
  `3d06155f9583231253cd49068f93779691ca3bcd`
- Prompt 74 implementation:
  `182d96812dc6c96e14387d5af51c235d41d0de0b`

The only commit after the Prompt 74 implementation is the documentation
checkpoint `cc5847c1`; no later production commit changed the corrected
canonical-root semantics.

### 3. Exact artifact/hash verification

No rebuild occurred. The exact existing artifact was:

- path: `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- product/display/executable: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- version/build: `0.2.140 (158)`
- executable SHA-256:
  `fc884969590b34b358ad9c45c233012f1ca9bbf0a0203cbbad68119414b9f882`
- `App.framework/App` SHA-256:
  `46374aa98731246b1f4758b23dc6cba04848fed35c8066a09021e73035c2fa0c`

The hashes matched Prompt 75 exactly.

### 4. Corrected canonical-root contract reconfirmation

The narrow source audit reconfirmed the Prompt 74 contract:

- `macos/Runner/MainFlutterWindow.swift` method `resolveCanonicalRoot(...)`
  reads `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` only for development and uses
  `Darwin.realpath` to derive the native filesystem-canonical root.
- `lib/essentials/archive_environment/infrastructure/development_archive_root_override_resolver.dart`
  independently derives the Dart expectation with
  `Directory.resolveSymbolicLinksSync()`.
- `lib/main.dart::_admitArchive()` passes the native claim through
  `ArchiveIdentityValidator.validateClaim(...)`, preserving exact-root
  agreement.
- Production override rejection remains unchanged.

The two witnesses remain independently implemented; the correction aligned
their definition of filesystem canonicalization rather than weakening the
comparison.

### 5. Fresh fixture-construction seam

A reviewed external harness at
`/private/tmp/messagelens_prompt73_fixture_builder.dart` used current project
marker/admission and database APIs under the Flutter test runtime. It created
new current-format development markers, fixture-local attachment archives,
and the unsafe witness through the current `ImportDatabase` schema seam. It
did not add or change any project source or test file and did not manually
invent SQLite schema.

The fresh parent is:

`/private/tmp/messagelens-appczar-onboarding-qualification-gaG4s6`

### 6. SAFE fixture absolute/canonical path

The raw and filesystem-canonical SAFE root were identical:

`/private/tmp/messagelens-appczar-onboarding-qualification-gaG4s6/safe-empty`

Before launch it contained the current marker and fixture-local
`attachment_archive/`, with no import database, graph database, consequential
partial row, non-live material, retired derived artifact, or corrupt store.
Its expected typed initial-scope classification was `safeEmpty`.

### 7. SAFE fixture archive identity

- environment: `development`
- marker format: 1
- archive instance UUID: `1a985604-c494-4cc8-b855-2c725942924d`
- attachment archive:
  `/private/tmp/messagelens-appczar-onboarding-qualification-gaG4s6/safe-empty/attachment_archive`

### 8. Proof SAFE fixture isolation

The SAFE and unsafe roots are distinct children of the fresh `/private/tmp`
parent. Neither equals nor is nested within the admitted WD development root.
Neither fixture attachment archive equals the active Toshiba attachment
archive. The fixture tree contained no symlink into another archive.

The real WD and Toshiba locations received only the required simple
existence/path-inequality guards. They were not listed, inspected, copied, or
mutated.

### 9. FDA preflight

The human-visible Full Disk Access toggle for the exact `MessageLens
Development.app` entry was visibly **ON** before launch. It was treated only
as configuration evidence and was not changed. It did not prove that this
process could read the Messages source.

### 10. SAFE launchd raw/canonical value

The authoritative launchd readback before launch was exactly:

`/private/tmp/messagelens-appczar-onboarding-qualification-gaG4s6/safe-empty`

Its expected canonical form was the same string. No development process was
running, the selected root was not the WD root or nested in another
MessageLens root, and its attachment archive was not Toshiba.

### 11. Experiment A PID

The exact artifact direct-launched as PID `57827`.

### 12. Archive-admission result

**PASS.** No `nonCanonicalRoot` alert or other archive-admission alert
appeared. Fixture-local startup telemetry recorded:

- overlay: absent;
- source-scoped import: absent;
- conversation graph: absent;
- presence store: absent;
- installation classification: `virgin`;
- reason: `virginNoConsequentialImport`;
- admission basis: `boundedInspection`;
- admission outcome: `granted`.

This proves the Prompt 74 canonical-root correction reached and passed the
boundary that blocked Prompt 73.

### 13. Fresh AppCzar initial-scope facts

The durable facts were affirmatively safe-empty: the bounded startup reader
found no overlay, import, graph, or presence store and admitted the root as a
virgin installation with no consequential import data. No complete local
dataset existed.

Those facts are the expected basis for AppCzar Onboarding. They do not,
however, prove which presentation held user-visible authority after the
disposition was selected.

### 14. Onboarding selection result

**NO under Prompt 75's required authority criterion.** The human-visible
screen was not `AppCzarOnboardingScreen`. It was the legacy Onboarding overlay
with the six-node Journey rail:

`Messages / History / Contacts / Ready / Import / Start`

and the title:

`MessageLens needs Full Disk Access`

This is the exact presentation vocabulary emitted by
`OnboardingJourneyPath` inside `OnboardingOverlay`. The fixture log also
recorded `OnboardingCenterPanelSyncController` showing the readiness center
panel with `onboardingStatus: awaitingUserAction`.

Current source confirms that the AppCzar harness maps its Onboarding branch to
`AppCzarOnboardingScreen`, which has no Journey rail. It also confirms that
`production_macos_app_shell.dart` independently places `OnboardingOverlay`
when the legacy Journey requires an operation overlay. In this launch that
legacy surface claimed the visible authority and exposed Environment
Readiness semantics, violating Prompt 75 section 8. The required stop gate was
therefore reached.

### 15. Messages prerequisite result

The actual current source observation was conclusively unreadable. The log
reported `accessDenied` and `Operation not permitted` while opening
`/Users/rob/Library/Messages/chat.db`.

The visible UI offered `Open System Settings` and `Re-check`, but those actions
belonged to the legacy Journey overlay, not the required AppCzar Onboarding
surface. `Re-check` was not clicked. The visibly ON FDA toggle was not
relabelled as successful readability, and the read denial was not relabelled
as a statement about the toggle itself.

The required same-AppCzar-Onboarding-occurrence prerequisite behavior is
therefore **NOT QUALIFIED**.

### 16. Contacts prerequisite result

**NOT REACHED.** No typed AppCzar Onboarding Contacts result was presented or
qualified. Legacy background probes are not substituted for the required
typed result.

### 17. Onboarding self-location result

**FAIL / NOT REACHED under the intended authority.** AppCzar's safe-empty
facts were present, but the legacy Journey overlay took the visible
self-location role. No valid `checkingPrerequisites -> satisfied -> one
admitted initial build` transition was observed under AppCzar Onboarding.

### 18. Build-admission behavior

**NOT REACHED.** No initial build was admitted and no user build action was
invoked.

### 19. Visible build stages/progress

**NOT REACHED.** No message import, Contacts import, rich-text extraction,
graph projection, or other initial-build stage appeared.

### 20. Proof existing pipeline was used

**NOT REACHED.** Because no build was admitted, the live experiment cannot
corroborate `ConversationGraphBuildController.runOnce()` or the existing
graph-build mutation tenure.

### 21. Proof no cleanup/reset occurred

No cleanup, reset, Start Fresh, repair, or preservation action was offered or
invoked. No import or graph row was built.

Ordinary startup initialization did create current empty fixture-local import,
graph, and overlay stores and an instance lock, and it recorded a zero-item
attachment sweep plus window state. Those literal consequences are not called
a build or cleanup. `archived_attachments` remained at zero.

### 22. Old Onboarding PID terminal behavior

PID `57827` displayed the legacy Onboarding overlay; it was not a correctly
qualified AppCzar Onboarding occurrence. A normal Apple-event quit was sent.
The command returned macOS error `-128` (`User canceled`), but bounded process
inspection then confirmed PID `57827` was gone. This is an evidence limitation
on the quit acknowledgement, not evidence of a process left running.

### 23. Replacement PID

**NOT REACHED.** No build succeeded and no AppCzar-requested restart occurred.

### 24. Fresh post-build AppCzar disposition

**NOT REACHED.** There was no post-build process or disposition.

### 25. Proof no same-process Operating handoff

No Operating or Conversations workspace appeared and no same-process
completion handoff occurred. The stronger required proof of a successful
build followed by a fresh-process disposition is **NOT REACHED**.

### 26. SAFE fixture durable import/graph result

Bounded read-only inspection after exit found:

- `macos_import_ss.db`: present, schema 10, zero messages, zero attachments,
  zero message/attachment rows, zero import batches; current live chat and
  live Address Book source-registry rows exist as empty ordinary
  initialization;
- `working_ss.db`: present, schema 3, zero messages, zero chats, zero
  chat/message edges, zero attachments, and zero message/attachment rows;
- `user_overlays.db`: present, schema 8, zero archived attachments and eight
  ordinary settings rows consisting of a zero-item attachment-sweep record
  and window state;
- marker UUID remains `1a985604-c494-4cc8-b855-2c725942924d`;
- fixture-local attachment archive remains present.

No real development root was inspected.

### 27. Proof no durable Journey cursor

The three fixture databases contain no table whose name includes `journey`,
`onboard`, or `cursor`. The overlay settings contain only attachment-sweep
evidence and window state; there is no Journey resume/finish cursor. This
corroborates absence of a durable Journey cursor for this stopped run.

### 28. stopAndDrain live corroboration

**NOT REACHED.** The stop gate was reached before build admission, so no
build-success `stopAndDrain`, old-PID/replacement-PID boundary, or second-build
suppression could be observed live. The development process was explicitly
ended only to clean up the failed qualification.

### 29. Unsafe fixture construction method

The same reviewed current marker/admission seam created the unsafe fixture.
The current `ImportDatabase` schema API then inserted one valid message tied
to the registered `live_chat_db` source. No manual schema SQL, graph store,
historical source, or real archive payload was used.

### 30. Unsafe fixture absolute/canonical path

The raw and filesystem-canonical unsafe root were identical:

`/private/tmp/messagelens-appczar-onboarding-qualification-gaG4s6/unsafe-partial`

### 31. Unsafe archive identity

- environment: `development`
- marker format: 1
- archive instance UUID: `e7edd9b5-9723-4152-8c7f-ca75e1941b07`
- fixture-local attachment archive:
  `/private/tmp/messagelens-appczar-onboarding-qualification-gaG4s6/unsafe-partial/attachment_archive`

### 32. Exact consequential partial facts

Before any launch, `macos_import_ss.db` was present at schema 10 with exactly
one message. That message is tied to `live-chat-db` / `live_chat_db`; the
registered live Address Book source has zero messages. No non-live or
historical message exists. The message GUID is
`prompt-73-consequential-partial-message`. The graph database is absent. The
expected typed initial-scope result is `consequentialData`.

The pre-experiment import-store SHA-256 was:

`2a60ef0c3651fa900e63d0f68dd925e1fadcb4df0de9c395be5640c25f911d3e`

### 33. Unsafe launchd raw/canonical value

**NOT REACHED.** The SAFE stop gate prohibited configuring the unsafe
override.

### 34. Experiment B PID

**NOT REACHED.** The unsafe fixture was not launched.

### 35. Unsafe archive-admission result

**NOT REACHED.** No live claim is made from the source prediction alone.

### 36. Unsafe initial-scope classification

**NOT REACHED live.** The fixture's current valid one-message import state is
expected to classify `consequentialData`, but the required human observation
did not occur.

### 37. Local Data Repair / Diagnostic Review result

**NOT REACHED.** Neither virtual disposition was presented for Experiment B.

### 38. Proof Onboarding did not execute

**NOT REACHED.** Because the unsafe fixture was never launched, absence of
execution is not claimed as proof that AppCzar refused Onboarding.

### 39. Proof graph build did not execute

**NOT REACHED live.** The unsafe fixture was never launched. Its graph remains
absent, which proves preservation during the stopped qualification but not a
live refusal.

### 40. Proof cleanup/reset did not execute

**NOT REACHED live.** The fixture was never exposed to the application; no
cleanup or reset command was run.

### 41. Unsafe before/after fingerprint/count result

The unsafe fixture was never launched. Its post-stop import-store SHA-256 is
still:

`2a60ef0c3651fa900e63d0f68dd925e1fadcb4df0de9c395be5640c25f911d3e`

Schema remains 10, message count remains one, that message remains tied to the
live chat source, no non-live message exists, and the graph remains absent.
This proves the stopped procedure did not alter it; it does not qualify a live
AppCzar refusal.

### 42. Optional protected-non-live result

**NOT EXERCISED.** The required SAFE experiment reached a stop gate before
Experiment B.

### 43. Fair-Witness verdict

The qualification remained Fair-Witness:

- the safe-empty scope is positively established by current bounded startup
  evidence;
- the successful canonical-root admission is reported separately from the
  subsequent authority failure;
- the source read is reported literally as `accessDenied`, while the visible
  FDA toggle is reported only as configuration;
- legacy Journey UI and Environment Readiness activity are not mislabeled as
  AppCzar Onboarding evidence;
- no Contacts result, build success, restart, Operating success, or unsafe
  refusal is inferred from absence;
- Prompt 73's failed state is not treated as present authority.

### 44. Errors/warnings/evidence limitations

The blocking defect is a live presentation-authority collision after archive
admission. Safe-empty startup evidence was admitted, but the independent
legacy `OnboardingOverlay` and `OnboardingCenterPanelSyncController` still
claimed the visible surface. This violated Prompt 75's explicit prohibition on
the legacy Journey rail and Environment Readiness semantic authority.

The Messages source was conclusively unreadable for PID `57827` even though
the FDA toggle was visibly ON. That is recorded literally and was not worked
around. Because the visible `Re-check` action belonged to the wrong authority,
it was not exercised.

The normal quit request returned error `-128` even though the process exited.
Experiment B and every build/restart assertion are therefore intentionally
reported as **NOT REACHED**.

### 45. Cleanup result

No MessageLens Development process remains. The launchd override was unset and
authoritative readback is empty. Production PID `801` remains running at
`/Applications/MessageLens.app/Contents/MacOS/MessageLens` and was untouched.
FDA was left in its intended pre-test ON state.

No source or test file was changed, staged, committed, pushed, or rebuilt. Both
fresh disposable fixture roots are preserved under their `/private/tmp`
parent pending review. Neither real archive nor real MessageLens database was
modified.

### 46. Overall Onboarding Stage One human qualification verdict

**FAIL.** Prompt 74's canonical-root correction passed live, but the SAFE
fixture did not produce the required AppCzar-owned Onboarding presentation.
The legacy Journey overlay and Environment Readiness path retained competing
visible authority, so the qualification correctly stopped before build or the
unsafe experiment.

### 47. Recommendation for checkpointing

Do not checkpoint Onboarding human qualification as complete. Preserve this
response as failed live evidence, correct the legacy-overlay/Environment
Readiness authority collision in a separately reviewed step, and rerun the
qualification from fresh fixtures.

### 48. Readiness for Local Data Repair milestone

**NO.** Safe AppCzar Onboarding, its existing build pipeline, its real restart
boundary, and unsafe partial refusal have not all been qualified live.

### 49. Readiness for Diagnostic Review milestone

**NO.** The visible Onboarding authority collision must be corrected and the
two required experiments completed first.

### 50. Readiness for production AppCzar cutover

**NO.** Production was not launched or modified. Development still has a live
parallel-authority defect at the Onboarding presentation boundary.

CORRECTED DISPOSABLE ROOT PASSED ARCHIVE ADMISSION: YES

SAFE EMPTY FIXTURE SELECTED APPCZAR ONBOARDING: NO

INITIAL BUILD USED THE EXISTING PIPELINE: NOT REACHED

INITIAL BUILD ENDED AT A REAL PROCESS BOUNDARY: NOT REACHED

FRESH APPCZAR OWNED THE POST-BUILD DISPOSITION: NOT REACHED

CONSEQUENTIAL PARTIAL FIXTURE WAS REFUSED BY ONBOARDING: NOT REACHED

NO CLEANUP OR BUILD OCCURRED ON CONSEQUENTIAL PARTIAL DATA: NOT REACHED

APPCZAR ONBOARDING HUMAN LIVE QUALIFICATION: FAIL

READY TO CHECKPOINT ONBOARDING HUMAN QUALIFICATION: NO

READY FOR LOCAL DATA REPAIR MILESTONE: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
