# MessageLens Feature 34
## Response 30 — Resume Clean-Slate Onboarding Qualification

## 1. Checkpoint and remote verification — PASS

The qualification checkpoint is intact:

- branch: `fix/onboarding-import-stuck-state`;
- local HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- local remote-tracking ref:
  `origin/fix/onboarding-import-stuck-state = 9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- independent `git ls-remote` result:
  `refs/heads/fix/onboarding-import-stuck-state = 9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`.

No tracked byte has drifted from the checkpoint.

## 2. Repository and submodule state — PASS

- tracked worktree: clean;
- index: empty;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- pre-response untracked census: 46 paths, comprising the 44 known
  Category 4 paths, Prompt 30, and Response 29;
- none of those paths was deleted, staged, or modified by this task.

This Response 30 is intentionally the only new untracked path produced by the
task. No source, generated file, test, release metadata, native project file,
or runtime configuration was changed.

## 3. Canonical qualification records read

The following records were read in full before runtime inspection or build:

- `00-PREPARATION/01-CLEAN_SLATE_QUALIFICATION.md`;
- `00-PREPARATION/02-VERIFY-QUIESCENCE-AND-PREPARE-SNAPSHOT.md`;
- `00-PREPARATION/02-VERIFY-QUIESCENCE-AND-PREPARE-SNAPSHOT-RESPONSE.md`;
- `00-PREPARATION/03-CREATE-AND-VERIFY-DEVELOPMENT-SNAPSHOT.md`;
- `00-PREPARATION/04-RERUN-AND-VERIFY-DEVELOPMENT-SNAPSHOT.md`;
- `00-PREPARATION/04-RERUN-AND-VERIFY-DEVELOPMENT-SNAPSHOT-RESPONSE.md`;
- `00-PREPARATION/05-BUILD-AND-VERIFY-INTEGRATED-DEVELOPMENT-APP.md`;
- `00-PREPARATION/05-BUILD-AND-VERIFY-INTEGRATED-DEVELOPMENT-APP-RESPONSE.md`;
- `00-PREPARATION/06-FIRST-INTEGRATED-LAUNCH-AND-PRE-RESET-VERIFICATION.md`;
- `00-PREPARATION/07-SIMPLIFIED-FIRST-LAUNCH-AND-START-FRESH.md`;
- `01-ONBOARDING/01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`;
- `01-ONBOARDING/02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`;
- Response 29.

The controlling simplified procedure says:

- the former development snapshot is not a prerequisite and must not be
  investigated or recreated;
- the application's bounded **Start Fresh** operation is the approved reset
  mechanism;
- the human drives the GUI;
- manual database deletion or an invented filesystem reset is prohibited;
- `user_overlays.db`, user intent, archive configuration, and both attachment
  archives must be preserved.

## 4. Development state inspection

The admitted development root exists at:

`/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`

Its archive identity remains:

- environment: `development`;
- archive instance UUID:
  `e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5`.

The rebuildable derived stores contain no imported application data:

| Store | Evidence |
|---|---:|
| source-scoped import messages | 0 |
| source-scoped import import batches | 0 |
| source-scoped import chats | 0 |
| source-scoped import contacts | 0 |
| source-scoped import attachments | 0 |
| Conversation Graph messages | 0 |
| Conversation Graph chats | 0 |
| Conversation Graph contacts | 0 |
| Conversation Graph attachments | 0 |
| Conversation Graph FTS rows | 0 |

The last import, graph-projection, and migration result settings are empty.

However, the durable operation evidence is not idle. It retains the exact
failure from the original qualification:

- status: `failed`;
- operation ID: `9113680a-1af0-48ef-aa47-3cbf1e31e5c3`;
- kind: `initialImport`;
- stage: `messageDataBuild`;
- recovery disposition: `retryFromSafeBoundary`;
- failure: the Riverpod `!_didChangeDependency` assertion originally under
  investigation.

Under `MessageLensInstallationStateClassifier`, empty derived stores plus that
failed retryable operation record classify as **resumable**, not **virgin**.
Consequently, this is not yet a genuine canonical clean slate.

## 5. Selected clean-slate mechanism and stop gate

The only selected mechanism is the documented bounded **Start Fresh** action.
It is eligible from the current resumable installation and, when invoked by the
human, is designed to:

- reset the durable operation evidence to idle;
- clear prior import/graph failure evidence;
- reset only rebuildable derived message data;
- verify the installation as `virgin`;
- preserve `user_overlays.db`, user intent, archive identity, archive
  configuration, and attachment archives.

It has not been invoked in this task because doing so requires the human GUI
action expressly reserved by the canonical procedure. No manual substitute was
used.

This is the preflight stop gate: the development installation cannot truthfully
be reported as clean-slate before the human performs Start Fresh.

## 6. External development attachment archive

The development configuration remains exactly:

- mode: `custom_external`;
- active archive:
  `/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive`;
- volume: `Toshiba_manual_bu`;
- write policy: `active_archive`;
- bookmark length: 1,736 bytes.

The Toshiba archive therefore remains involved as the configured active
development attachment archive. The retained WD archive remains present but is
not active or fallback under the established qualification record.

Only path/type existence and stored configuration metadata were checked. No
attachment payload was traversed, hashed, copied, or modified. Abandoned
relocation artifacts were not inspected or changed.

## 7. Checkpointed development build — PASS

The prior development bundle was the September 23 build and therefore did not
contain checkpoint `9171c9c`. The established development build procedure was
rerun:

```text
/Users/rob/Development/flutter/bin/flutter clean
/Users/rob/Development/flutter/bin/flutter pub get --offline
env PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  /Users/rob/Development/flutter/bin/flutter build macos --debug --no-pub
```

The build succeeded. The initial sandboxed invocation was unable to update the
Flutter SDK cache and performed no build; the same reviewed commands were then
run with the required filesystem permission.

Verified artifact:

- app:
  `build/macos/Build/Products/Debug/MessageLens Development.app`;
- executable:
  `build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development`;
- product/display name: `MessageLens Development`;
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- version/build: `0.2.128+146`;
- archive environment: `development`;
- build identity: `developmentDebug`;
- architecture: arm64;
- signing: ad hoc Debug, no TeamIdentifier;
- executable modification time: `2026-09-29 13:26:22 -0700`;
- executable SHA-256:
  `7b9a8b504168ca54a49155524653f4b42a111367abe489f7137d14bb6ad2d7f8`;
- Debug App framework modification time: `2026-09-29 13:26:20 -0700`;
- Debug App framework SHA-256:
  `93bdffe26fec7042576e4403d276a5ecf9046eec3666b156c2e1ada645b03b5f`.

The build began and ended with HEAD fixed at checkpoint `9171c9c`, an empty
index, and no tracked diff. It produced no tracked/generated-source churn.

MessageLens Development was not launched. No Flutter `run` process owns this
project, and no process held a file under the development root after the build.

## 8. Production isolation — PASS

Production MessageLens was not launched, signalled, inspected for application
data, rebuilt, replaced, or modified. No production database or production
archive was accessed.

## 9. Human GUI checklist after the stop gate is acknowledged

The next safe human action is the canonical reset itself:

1. Launch **MessageLens Development** using the repository's VS Code
   `MessageLens Development (Debug)` configuration. It supplies:
   `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT=/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`.
2. In `Settings -> Environment`, verify only the four canonical facts:
   - version/build `0.2.128+146`;
   - exact WD development data root;
   - exact Toshiba archive, connected/read-write;
   - archive UUID `e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5`.
3. Use `Settings -> Reset message data...` and invoke **Start Fresh**. Do not
   use Complete Erase and do not delete files manually.
4. Confirm Start Fresh completes and normal Onboarding appears. At that point
   the installation must be `virgin`, the prior failed operation evidence must
   be idle/cleared, and Toshiba must remain the active archive.
5. Stop and report that observation before treating the import qualification as
   begun if exact clean-slate verification is desired.
6. Proceed through Onboarding normally, satisfying the Messages/FDA and Contacts
   prerequisites shown by the Journey.
7. Reach **Import My Messages** and start the import.
8. Observe that the Journey remains coherent while the import owns the
   archive-mutation Ball. Its self-owned aggregate `maintenanceInProgress`
   evidence must not reject or strand the command.
9. Allow import and graph work to reach the next legitimate Journey state.
10. Confirm Browsing-ready copy appears only when the Journey authorizes it and
    that the modal advances or dismisses appropriately.

## 10. Exact formerly failing transition to watch

The critical transition is:

```text
Import My Messages
-> initialImport / messageDataBuild begins
-> command retains its admitted archive-mutation tenure despite its own
   maintenanceInProgress evidence
-> progress/evidence is accepted by OnboardingJourneyCoordinator
-> graph/readiness work advances
-> Journey alone publishes the next user-visible state
```

The following old contradiction must not recur:

- Journey stuck in a `buildingGraph`-type phase;
- permanently non-dismissible modal;
- visually complete progress while no work advances;
- **Browsing data ready** while Journey still says building;
- no failure/retry state after a real failure;
- indefinite waiting with contradictory state.

## 11. Preflight result

Repository, remote, submodule, build, development-root identity, archive
configuration, and production-isolation gates all pass.

The clean-slate data gate does not pass yet: the old failed Onboarding operation
record remains, so the installation is safely resumable but not virgin. The
canonical human Start Fresh action is required; no noncanonical reset was
performed.

FEATURE 34 CLEAN-SLATE ONBOARDING PREFLIGHT: FAIL

READY FOR HUMAN GUI QUALIFICATION: NO
