# MessageLens Feature 34
## Response 61 — Operating-Owned Live Currentness Qualification

Date: 2026-10-04

The Prompt 61 live-currentness experiment did not reach Operating. Fresh
AppCzar correctly stopped admission because the real development attachment
archive had conclusively incomplete coverage for the current local graph.

This is an independently reconstructed prerequisite failure, not an observed
failure of the unstaged Stage Two currentness implementation. The experiment
was stopped without bypassing the fact, invoking Data Update, changing source
or tests, or modifying either real archive or database.

## 1. Exact artifact/hash verification

Verified before launch:

- bundle:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`;
- product: `MessageLens Development`;
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- version/build: `0.2.135 (153)`;
- executable SHA-256:
  `47f2358cd6dbe4aab1581e95ed466a4dac1c13b51dca73a4a3abd072f8ca12a6`;
- `App.framework` executable SHA-256:
  `ab1a92c090ff168f736ab0e9dde17979449fecff2630f971fc2fe259e0ad1c12`.

No MessageLens Development process was running. The exact WD development root
and Toshiba archive root were both present. The human-visible macOS FDA pane
showed `MessageLens Development.app` enabled before launch.

## 2. Exact launchd development-root value

Set and read back exactly:

`/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`

This was used only as the development root-admission contract.

## 3. Startup AppCzar/coordinator path to Operating

The exact bundle was direct-launched with `/usr/bin/open -n` at approximately
08:11:47. Initial PID: `34976`.

The app opened behind the Codex window, so any earliest assessment frame could
not be observed. When brought forward, it showed fresh AppCzar's qualified
Source Access Repair screen:

- `Current read-only check failed`;
- `macOS denied access to the Messages database`;
- explicit copy that this evidence could not determine whether Full Disk
  Access itself was enabled or disabled.

The human-visible FDA toggle had unexpectedly changed from ON before launch to
OFF after launch. After the human restored it and pressed `Check Again` once,
the existing Source Access Repair boundary restarted the app.

The replacement fresh AppCzar process did not admit Operating. It reconstructed
attachment coverage FALSE and selected virtual Attachment Archive Repair.

## 4. Operating PID before live update

`NOT REACHED`

PID `34976` belonged to Source Access Repair, not Operating. Replacement PID
`36979` belonged to fresh AppCzar assessment/virtual repair presentation, not
Operating.

## 5. Selected navigation state before live update

`NOT REACHED`

No normal workspace was admitted, so no contact, conversation, center panel,
or right panel was selected for the live-update witness.

## 6. Source delta creation method and time

`NOT EXERCISED`

No test message was created. The fresh assessment already reported 21 source
messages ahead of the local dataset, but no delta was deliberately manufactured
or used because attachment coverage blocked Operating first.

## 7. Currentness observation/update timing

`NOT REACHED`

The Operating-owned 15-second observer never started because Operating was not
admitted.

## 8. Compact progress/status actually observed

No Stage Two Operating status was observed. The only directly observed status
was the startup Source Access Repair presentation and the subsequent fresh
AppCzar assessment.

The assessment showed:

- Messages database: `Readable — 138,956 messages`;
- source sample: `Stable`;
- import data: `Healthy — 138,935 messages`;
- conversation data: `Healthy — 138,935 messages`;
- local dataset: `Complete — 138,935 messages`;
- attachment archive: `Available — Toshiba_manual_bu`;
- attachment coverage:
  `Incomplete — 13841 required payloads are not covered`;
- new messages: `21`.

## 9. PID after successful text update

`NOT REACHED`

No text live update ran.

## 10. Whether selected navigation was preserved exactly

`NOT REACHED`

No Operating navigation state existed.

## 11. Whether the new message appeared without navigation/restart

`NOT REACHED`

No test message was created and no Operating live update ran.

## 12. Identity behavior after update

`NOT REACHED`

No normal workspace or post-update identity rendering was exercised.

## 13. Attachment-bearing subtest result

`NOT EXERCISED`

The mandatory text-message test was not reachable, so no attachment-bearing
message was created.

## 14. Post-update fresh-process attachment-coverage result

`NOT REACHED` as a post-update test.

However, the pre-Operating fresh process conclusively reconstructed the real
durable fact:

```text
archive available
coverage incomplete
13,841 required payloads uncovered
```

This evidence must not be conflated with a Stage Two post-update result.

## 15. Fresh Operating admission after durable recheck

`NO`

Fresh AppCzar correctly refused Operating and diagnosed:

`The current attachment archive does not cover every required attachment payload.`

No Attachment Archive Repair executor exists, so there was no approved path to
continue this experiment.

## 16. Source-loss test starting PID/navigation state

`NOT REACHED`

The required healthy Operating session was never established. FDA was not
toggled off during Operating as the Prompt 61 source-loss subtest requires.

## 17. Source-loss issue/status actually observed

`NOT REACHED` for the Operating source-loss test.

The startup Source Access Repair screen did independently and correctly report
conclusive source unreadability without treating that read result as direct FDA
testimony.

## 18. Source-loss restart old/new PID evidence

`NOT REACHED` for an Operating-ending source-loss restart.

Separate startup-repair process evidence was:

- Source Access Repair PID: `34976`, launched 08:11:47;
- replacement fresh AppCzar PID: `36979`, launched 08:19:44;
- the old PID was absent when the replacement assessment was observed.

## 19. Fresh AppCzar / Source Access Repair result

Fresh AppCzar initially selected Source Access Repair when the Messages source
was conclusively unreadable. After the human enabled the visible FDA entry and
pressed `Check Again` once, that process restarted rather than handing off
in-process.

The replacement fresh AppCzar process found the source readable and stable,
then independently selected virtual Attachment Archive Repair because coverage
was FALSE. It did not enter Source Access Repair again and did not admit
Operating.

## 20. Proof no in-process coordinator chaining occurred

Observed PID `34976` owned Source Access Repair. After successful source
re-observation it exited. PID `36979` then owned a completely fresh AppCzar
assessment and selected the coverage disposition. No Source Access Repair to
Attachment Archive Repair handoff occurred inside one process.

## 21. Source-access restoration sequence

The human:

1. restored the `MessageLens Development.app` FDA toggle to ON;
2. returned to PID `34976`;
3. pressed `Check Again` exactly once;
4. allowed the existing qualified restart path.

The replacement process successfully read 138,956 source messages and obtained
two matching bounded samples. That is evidence of current readability, not a
semantic claim about FDA state.

## 22. Final restart/update path back to healthy Operating

`NOT REACHED`

The source-access repair/restart completed, but fresh AppCzar stopped at
attachment coverage FALSE before Data Update or Operating. No attempt was made
to bypass the disposition, manually start Data Update, or alter the archive.

## 23. `stopAndDrain()` real-process corroboration

`NOT REACHED` for Operating shutdown.

The startup Source Access Repair restart did corroborate the established
top-level real-process boundary: the old process disappeared before fresh
AppCzar owned the next disposition. It does not qualify the new Operating
`stopAndDrain()` path, because no Operating occurrence existed.

Deterministic Prompt 60 lifecycle tests remain the only completed proof for an
active Operating observation/mutation drain.

## 24. Fair-Witness verdict

`PASS` for the evidence actually reached.

MessageLens did not overclaim:

- it described a failed read without declaring FDA OFF;
- after restart it used fresh source, local, archive, and coverage evidence;
- archive availability did not override coverage FALSE;
- it did not call 21 newer messages `Current`;
- it did not admit Operating on incomplete coverage;
- it selected no repair coordinator in-process;
- no historical success flag bypassed the durable fact.

The Fair-Witness result is the reason the live-currentness qualification had to
stop.

## 25. Errors, warnings, and evidence limitations

1. The development FDA toggle visibly changed from ON before direct launch to
   OFF after launch. The reason was not investigated in this qualification-only
   task.
2. Because the app initially opened behind Codex, the human could not state
   whether a brief assessment frame appeared before Source Access Repair.
3. The real development archive lacks durable coverage evidence for 13,841
   required payloads, blocking Operating and all Stage Two live tests.
4. A normal AppleScript quit request returned macOS error `-128` (`User
   canceled`), but an immediate process check confirmed PID `36979` had exited.
   No force kill was used.
5. No live-update, navigation-preservation, identity-refresh, attachment-update,
   or Operating source-loss assertion can be inferred from this run.

## 26. Cleanup result

- The final MessageLens Development process exited normally enough that no
  matching process remained.
- No force termination was used.
- The human's last FDA action left the development entry enabled; it was not
  toggled again during cleanup.
- `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` was unset from the host launchd
  domain.
- `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` returned empty.
- No source/test edit, staging, commit, push, merge, or rebase occurred.
- Neither real archive nor any real database was modified by the experiment.

## 27. Qualification verdict

`AMBIGUOUS / NOT REACHED`

The Stage Two live behavior did not fail; it was never admitted. The exact
artifact, launch contract, and startup repair loop worked far enough for fresh
AppCzar to expose a separate durable prerequisite: the real development archive
does not currently cover the admitted local graph.

## 28. Recommendation

Do **not** checkpoint Stage Two on the basis of this human experiment yet, and
do not begin the next AppCzar milestone.

First investigate the real coverage deficit as a separate bounded,
read-only-first task. Determine why 13,841 required payloads lack durable
coverage evidence and design/qualify the still-virtual Attachment Archive
Repair jurisdiction without weakening Operating admission or modifying the
archive ad hoc. Once coverage is legitimately restored and independently
reconstructs TRUE, rerun Prompt 61 unchanged from the direct-launch preflight.

The unstaged Stage Two implementation should remain intact pending that work.

OPERATING-OWNED LIVE CURRENTNESS LIVE QUALIFICATION: AMBIGUOUS

ORDINARY LIVE UPDATE COMPLETED IN THE SAME PID: NOT REACHED

SUCCESSFUL LIVE UPDATE PRESERVED SAME-SESSION NAVIGATION: NOT REACHED

NEW MESSAGE APPEARED WITHOUT NAVIGATION OR RESTART: NOT REACHED

POST-UPDATE FRESH APPCZAR PROVED ATTACHMENT COVERAGE: NOT REACHED

SOURCE ACCESS LOSS ENDED OPERATING AT A REAL PROCESS BOUNDARY: NOT REACHED

FRESH APPCZAR OWNED THE POST-RESTART DISPOSITION: YES
