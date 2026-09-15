---
tier: project
scope: build
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: doc
links:
  - ./README.md
  - ../../../macos/Runner/Configs/AppInfo.xcconfig
  - ../../../macos/Runner.xcodeproj/project.pbxproj
  - ../65-DISTRIBUTION/10-render-tester-portal.md
tests: []
---

# macOS FDA Grant Continuity Across Production Builds

## TL;DR

For macOS Full Disk Access to carry over from one shipped `MessageLens.app` to the next, the production build must preserve the app's identity.

The critical invariants are:

1. Keep the bundle identifier at `com.bigbenchsoftware.MessageLens`.
2. Keep release signing tied to the same team and production identity.
3. Ship a real release build, not an ad hoc or debug build.
4. Replace the prior `MessageLens.app` rather than introducing a differently identified app.

If these invariants hold, macOS will usually continue treating the new build as the same app for TCC / Full Disk Access purposes.

## Why This Matters

Users may already have granted Full Disk Access to a previously shipped production build of `MessageLens`. If a new release changes app identity, macOS may no longer apply the old TCC grant to the new build. The result is confusing:

1. `MessageLens` may still appear in the Full Disk Access list.
2. The new build may still fail the FDA check.
3. The user may need to remove and re-add the app manually.

For family distribution, manual testing, and ad hoc release sharing, preserving TCC continuity reduces support burden significantly.

## Current Project Invariants

The repository is configured so production builds can preserve FDA continuity
while ordinary development has a distinct identity:

1. Bundle identifier in [macos/Runner/Configs/AppInfo.xcconfig](../../../macos/Runner/Configs/AppInfo.xcconfig): `com.bigbenchsoftware.MessageLens`
2. Release target signing in [macos/Runner.xcodeproj/project.pbxproj](../../../macos/Runner.xcodeproj/project.pbxproj):
   - Team: `FQHT2QP3NE`
   - Release signing identity: `Developer ID Application`
3. Debug/Profile identity:
   - bundle: `com.bigbenchsoftware.MessageLens.development`
   - product: `MessageLens Development`
   - archive environment: development
4. Production archive authority is not inferred from Release mode. Native
   bootstrap must validate expected production signing.

Do not change these casually.

## Single-Instance Execution Authority

MessageLens establishes archive-scoped application-instance authority in native
macOS bootstrap before creating the Flutter engine. The authority combines:

1. same-bundle running-application detection, so a duplicate can activate the
   already running app; and
2. an application-lifetime advisory lock beneath the canonical root declared
   by the native environment/archive claim.

Only the process holding that authority may proceed into Flutter and open
application databases. A second ordinary launch exits before providers start.
The operating system releases the advisory lock when the process exits or
crashes, so a stale lock file does not block a later launch.

The native claim is then validated by Dart before any persistent provider is
constructed. Development and production have different roots and locks. Two
processes may coexist only when they own different admitted archives; two
processes may not own the same writable archive. Signing identity and Full Disk
Access remain separate concerns: possession of FDA never grants archive or
operation authority.

## Development And Production Commands

- `flutter run -d macos` and Profile builds are development identity.
- A raw local Release build is production-shaped but must fail closed if it is
  not signed with the expected production identity.
- `tool/build_and_notarize.sh` is the production distribution entry point.
- `tool/verify_macos_archive_identity.sh` verifies environment, bundle,
  product, signing, and entitlements before an artifact is described as
  production.

Do not launch an unreviewed Release artifact against the production archive.
The existing production archive has not yet completed marker adoption.

## Required Production-Build Contract

When an agent or developer is asked to “do a production build”, that request must imply all of the following:

1. Build the macOS app with the `Release` configuration.
2. Preserve bundle id `com.bigbenchsoftware.MessageLens`.
3. Preserve signing team `FQHT2QP3NE`.
4. Preserve production signing with `Developer ID Application`.
5. Do not deliver an ad hoc signed build as a production artifact.
6. Do not substitute a debug app for the production build.

## Verification Checklist After Building

Before handing off a production build, verify:

1. The built app bundle identifier is still `com.bigbenchsoftware.MessageLens`.
2. The app is signed as a production build, not ad hoc.
3. The release signing identity matches the expected production setup.
4. The app name remains `MessageLens.app`.
5. `tool/verify_macos_archive_identity.sh --environment production` accepts the
   final signed artifact.
6. The packaged `Info.plist` version/build matches the intended
   `pubspec.yaml` release metadata.
7. The final stapled artifact's SHA-256 is recorded. A later tester-portal
   publication must verify that exact hash and must not silently rebuild it.

If these checks are not confirmed, do not describe the artifact as a production build.

Runtime support evidence reads package identity and version/build from the
installed app bundle through `PackageInfo.fromPlatform()`. It must not fall back
to a stale checked-in release number. This diagnostic rule strengthens
traceability but does not replace bundle-ID, team, designated-requirement,
notarization, or Full Disk Access continuity checks.

## User-Facing Expectation

If the production build preserves the same identity, the normal user experience should be:

1. Replace the old `MessageLens.app` with the new one.
2. Launch the app.
3. Existing Full Disk Access should continue to apply.

If macOS does not honor the prior grant, the fallback recovery is:

1. Remove `MessageLens` from Full Disk Access.
2. Add it again.
3. Relaunch the app.

This fallback should be the exception, not the planned path.

## INVIOLATE RULES

1. NEVER change the production bundle identifier without explicitly acknowledging that prior FDA grants may stop carrying over.
2. NEVER hand off a debug or ad hoc signed macOS app as a production build.
3. ALWAYS verify release signing identity before claiming that a build should preserve FDA continuity.
4. ALWAYS treat “production build” as including app-identity continuity, not just successful compilation.
5. NEVER move single-instance admission after Flutter/database startup; the
   exclusion must exist before writable providers can be constructed.
6. NEVER treat a matching bundle identifier as sufficient production archive
   authority; build metadata, signing, canonical root, and marker must agree.
