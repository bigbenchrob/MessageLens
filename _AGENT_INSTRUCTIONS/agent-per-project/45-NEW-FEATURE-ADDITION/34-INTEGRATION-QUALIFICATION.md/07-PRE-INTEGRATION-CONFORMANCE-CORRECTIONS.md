# Pre-integration Project Conformance Corrections

Date: 2026-09-23

## Scope and branch sequence

The accepted findings in the Feature 31 and Feature 33 accumulated-delta
audits were corrected without rewriting reviewed history:

1. `feature/attachment-archive-relocation` was corrected from reviewed tip
   `2c8bbaae5da30300dda8d4e9e3eaef57e353cea4` and checkpointed at
   `1693ce58`;
2. that corrected ancestry was carried forward by a normal no-fast-forward
   merge into `feature/environment-summary` at `3a08e969`; and
3. Feature 33's architecture tripwire and qualification record were corrected
   on top of that merge.

No squash, rebase, cherry-pick, push, or merge into `main` was performed.

## F31-B1 and F33-B1 — shared Settings boundary

The two Settings findings were resolved as one bounded architecture change.
The application `ViewSpecCoordinator` now returns the data-only
`SettingsPanelRenderDescriptor`. The shared Settings presentation
`SettingsPanelRenderRouter` is the terminal edge that selects and constructs
`AttachmentArchivePanel` and `EnvironmentSummaryPanel`.

Unrelated legacy Settings variants continue through their existing resolvers;
there was no broad panel migration. Feature public seams and provider/read-model
ownership remain unchanged, and Settings presentation acquired no feature
authority.

## F31-B2 — remediation filesystem ownership

`AttachmentArchiveAdoptionService` no longer imports `dart:io` or validates,
resolves, constructs, sizes, or opens retained-source files. It coordinates
through the narrow `AttachmentArchiveRemediationSourceReader` port, whose only
read operation requires the exact transaction-bound
`AttachmentArchiveRemediationAuthority`.

The filesystem verifier implements that port and owns canonical source
identity validation, exact-path inspection, symlink and special-entry
rejection, regular-file and expected-size validation, streamed opening, and
typed unavailable/changed/unreadable failures. The application retains
transaction identity, the remediation set, authority issuance, sequencing,
hash obligation, and outcome semantics. The port exposes no arbitrary relative
or absolute path read capability.

## F31-S1 — sidebar retirement

The unreachable Attachment Archive sidebar cassette variant, coordinator
branch and arguments, payload, resolver, supplemental widget, rendering route,
sidebar intents, dispatcher cases, obsolete generated artifact, and
sidebar-only tests were removed. The live Settings navigation entry still
selects the center-panel workflow, and stable-topology coverage continues to
require no Attachment Archive sidebar child workspace.

## Tripwires and generated code

Architecture coverage now:

- rejects Flutter/widget/presentation dependencies and panel construction in
  the new Settings application path;
- requires the shared presentation render edge and public Environment seam;
- scans the attachments application layer for direct `dart:io` imports, with
  only the two exact reviewed pre-existing exceptions; and
- proves remediation has no arbitrary-path capability and preserves exact,
  streamed infrastructure-owned reads.

Riverpod and Freezed output was regenerated normally. Obsolete generated files
were deleted only with their retired sources.

## Safety and scope

No schema, migration, native, Xcode, package-dependency, user-facing workflow,
production-adoption gate, startup, onboarding, or archive-location change was
made. Validation uses disposable fixtures only. Neither real MessageLens
database nor either real attachment archive was accessed or modified, and the
application was not launched.

## Validation and final audit

Validation used disposable fixtures only:

- Feature 31 focused matrix: 293 tests passed on the corrected Feature 31
  branch;
- Feature 33 focused matrix: 115 tests passed after the corrected ancestry was
  merged;
- complete architecture suite: 487 tests passed;
- `flutter analyze --no-pub`: no issues;
- complete repository suite: 2,606 tests passed with the one existing
  qualification skip in a serial run;
- Riverpod/Freezed generation: completed normally and left no uncommitted
  generated-file change;
- formatting and `git diff --check`: passed;
- documentation/reference checks: the new descriptor, render edge, port,
  retired sidebar paths, qualification records, changelog, and version agree;
  and
- shared instructions submodule: unchanged and clean at
  `95326f515ef4719f155ce6e223990398daad6311`.

The first parallel full-suite run had one attachment recovery-hint assertion
fail amid unrelated database-heavy tests. The exact test passed immediately in
isolation, and the complete serial suite passed, so no product change was made
for that test-process interference.

The Feature 31 audit used `main` as its base and the corrected Feature 31 tip as
its result. F31-B1, F31-B2, and F31-S1 are resolved with zero remaining BLOCKER
or SHOULD FIX findings.

`FEATURE 31 PROJECT CONFORMANCE: PASS`

The Feature 33 audit used corrected Feature 31 as its feature-specific base and
the final Feature 33 worktree as its result. F33-B1 is resolved with zero
remaining BLOCKER or SHOULD FIX findings.

`FEATURE 33 PROJECT CONFORMANCE: PASS`

No OPTIONAL finding remains from either correction audit. No mandatory stop
gate was encountered.
