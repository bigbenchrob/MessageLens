# MessageLens Feature 34
## Response 45 — Build Direct-Launch AppCzar FDA Experiment

## 1. Baseline verification — PASS

- Worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`.
- Branch: `fix/onboarding-import-stuck-state`.
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`.
- Prompt 32 + Prompt 35 + Prompt 44 accumulated changes are present.
- Tracked diff SHA-256 remains exactly the Response 44 value:
  `953b2c31773d49ce8589497c1ce725b72c0034e9e8f070e7ca6c76b1d75e1ed0`.
- AppCzar production/test manifest SHA-256 remains exactly the Response 44
  value:
  `45d3820d9965aa349681b5de819a2c313b026af66739c1f85a09a17dff0a7338`.
- Index: empty.
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.
- `git diff --check`: PASS.
- The only untracked addition since Response 44 before this response was Prompt
  45 itself. There was no additional source or test drift.

## 2. Already-running development process

A development instance was already running before this build:

- app PID: `860`;
- executable:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development`;
- app parent PID: `547`;
- parent: the Flutter tool running `flutter run --machine` against
  `/Users/rob/Development/FlutterProjects/remember_every_text/lib/main.dart`;
- parent start: `2026-10-01 12:12:17 -0700`;
- app start: `2026-10-01 12:12:27 -0700`.

Neither process was signalled, killed, relaunched, or otherwise controlled.
The human must quit the current development app and stop that VS Code run
normally before the Finder experiment. Otherwise macOS may reactivate the
existing VS Code-launched process instead of creating the intended direct
LaunchServices process.

## 3. Exact build path

Build command:

```text
env PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  /Users/rob/Development/flutter/bin/flutter build macos --debug --no-pub
```

Build result: PASS.

- Bundle:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- Executable:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development`

## 4. Exact build identity and hashes

- Product/bundle name: `MessageLens Development`.
- Bundle identifier: `com.bigbenchsoftware.MessageLens.development`.
- Version/build: `0.2.129+147`.
- Archive environment: `development`.
- Build identity: `developmentDebug`.
- Signing: ad hoc Debug; no TeamIdentifier.
- Executable timestamp: `2026-10-01 12:29:25 -0700`.
- Executable SHA-256:
  `ffb17772c05785aadb09b8ed54143a4ef1d7ea1c42810341c15a6406a1aecbe1`.
- App.framework binary timestamp: `2026-10-01 12:29:24 -0700`.
- App.framework binary SHA-256:
  `7da6a1244f5ef6129f34b070409c89b29d9961117dbca0bc8b73b82f51d07a52`.
- Aggregate App.framework regular-file SHA-256:
  `b9d730ec7f5bc65052fb71f102604cebf5e7dd954c74f6bd998c327bcdeaf1e3`.
- Debug Dart kernel timestamp: `2026-10-01 11:56:02 -0700`.
- Debug Dart kernel SHA-256:
  `bf9d55ce41aa4fb811399a8df5180bcf5a75a72443dedcf99e83ed577896bcad`.
- Info.plist SHA-256:
  `138baf6395904cc1c61c9626b64415962b1f1cc8d92c30aa272478e963655689`.
- Aggregate bundle regular-file SHA-256:
  `cbacd569b14c109a15756e64e5800076cdf086a7be90e2ac35e14f404e051186`.
- Branch/HEAD at build:
  `fix/onboarding-import-stuck-state` at
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`.
- Accumulated tracked diff SHA-256 at build:
  `953b2c31773d49ce8589497c1ce725b72c0034e9e8f070e7ca6c76b1d75e1ed0`.

## 5. Source and tests unchanged

No source, test, generated, project, build-identity, or release-metadata file
was edited in Prompt 45. The exact tracked-diff and AppCzar-manifest hashes
match Response 44 before and after the build. The build produced no unexpected
tracked/generated churn. No tests were rerun because this task prohibited
source/test changes and the exact already-qualified source was unchanged.

## 6. App launch confirmation

This task did not launch MessageLens Development. The only app process after
the build remained the same pre-existing PID 860 with the same VS Code
`flutter run` parent. Production MessageLens was not launched or touched.

No real archive, MessageLens database, Apple Messages database, or production
data was inspected or modified by this build/handoff task.

## 7. Temporary launchd environment command

After quitting the existing development app and stopping its VS Code run
normally, the human should run exactly:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
```

This command was not executed by the agent.

## 8. Finder bundle to double-click

In Finder, double-click exactly:

```text
/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app
```

Do not use VS Code, `flutter run`, or an already-running development instance
for this experiment.

With the temporary launchd environment in place, the direct LaunchServices
process should satisfy the existing exact WD development-root gate and open the
AppCzar harness without changing the bundle or source.

## 9. Cleanup command

After recording the result and quitting the directly launched app normally,
run exactly:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

This command was not executed by the agent.

## 10. Bounded interpretation of outcomes

### Outcome A — Messages source unreadable

This would support the hypothesis that the VS Code/debug responsibility chain
was providing effective source access while the app's visible FDA toggle was
off. It would not, by itself, identify precisely which ancestor or macOS
authorization rule supplied that access.

### Outcome B — Messages source readable

This would establish that the direct LaunchServices-launched development
process can currently read the Messages source even while the visible FDA
toggle is off. It would not establish that FDA is enabled, nor explain which
macOS permission mechanism permits the read.

In both cases, the Fair-Witness result is limited to:

`Messages source is currently readable / unreadable from this process.`

The experiment must record the AppCzar FDA row, Messages readability,
source count/high-water if present, diagnosis, and virtual coordinator. No
coordinator should be run.

## 11. Exact Git/worktree/index/submodule state

- Branch: `fix/onboarding-import-stuck-state`.
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`.
- Tracked worktree: the same 32 modified entries reported by Response 44.
- Tracked diff SHA-256:
  `953b2c31773d49ce8589497c1ce725b72c0034e9e8f070e7ca6c76b1d75e1ed0`.
- Index: empty.
- Untracked files after this response: 88 — the Response 44 inventory, Prompt
  45, and this Response 45.
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.
- Nothing was staged, committed, pushed, merged, or rebased.
- All unrelated untracked files remain untouched.

DIRECT-LAUNCH APPCZAR FDA EXPERIMENT BUILD READY: YES
