# Response 80 — Isolated AppCzar Local Data Repair Human Qualification

Date: 2026-10-09

Result: **PASS**

## Required report

1. **Exact Git HEAD/upstream state.** The qualification ran on
   `fix/onboarding-import-stuck-state` at
   `c736840c7b64591bfbac3c157087e14ba286f959`. The configured upstream was
   `origin/fix/onboarding-import-stuck-state`, with ahead/behind `0/0`.
   Tracked worktree and index were clean before the qualification and remained
   clean afterward. The shared-instructions submodule remained clean at
   `95326f515ef4719f155ce6e223990398daad6311`.

2. **Prompt 79 implementation ancestry.** The Stage One implementation commit
   `ceb12fef80b51c8cc340cca196d5e427419f084f` (`feat(startup): add
   source-grounded local data repair`) is an ancestor of the qualified HEAD.

3. **Prompt/Response 79 documentation checkpoint.** Commit
   `c736840c7b64591bfbac3c157087e14ba286f959` (`docs(startup): record local
   data repair implementation`) is the Prompt/Response 79 documentation
   checkpoint and was the exact qualification HEAD.

4. **Exact artifact/hash verification.** The only launched artifact was
   `build/macos/Build/Products/Debug/MessageLens Development.app`, version
   `0.2.142 (160)`, bundle identifier
   `com.bigbenchsoftware.MessageLens.development`. Its executable SHA-256 was
   `639a3036283fb447402d2e10295d57b9a0d6feb2fdc110f0a927555b963d203a`;
   `App.framework/Versions/A/App` SHA-256 was
   `5b2fffe9e2f0bf9f62667ebc87b0f16e634932fd1f30a9f01c8da6e922e3346f`.
   No rebuild occurred during Prompt 80.

5. **Stage One source reconfirmation.** Read-only source review reconfirmed that
   only `rebuildableLiveOnlyPartial` can authorize execution; the coordinator
   re-reads and reclassifies current evidence immediately before requesting one
   callback-local `ArchiveMutationOperation.localDataRepair` Ball; the reset
   enumerates only the active import and graph derived stores; and all FALSE or
   UNKNOWN safety classifications route to virtual Diagnostic Review. Archive,
   marker, overlay, presence, and preferences are outside the reset footprint.

6. **Qualification-observer method.** A fixture-only shell observer sampled
   the exact development executable PID and the existence/inode/size/mtime of
   the disposable active-store files at approximately 150 ms intervals. It
   also recorded immutable marker, root-sentinel, and archive-sentinel hashes.
   It did not inspect or mutate a real MessageLens archive. Automated authority
   tests remain the formal one-Ball proof; the observer and existing app log
   provide live corroboration only.

7. **Fixture parent and isolation proof.** The primary fixture parent was
   `/private/tmp/messagelens-prompt80-qualification-5HQcVP3A`; the successful
   fresh A retry used
   `/private/tmp/messagelens-prompt80-A-retry-EiiwlDIg`. Raw and canonical
   parent paths agreed. Every archive marker declared `development`; each root
   had a unique UUID and its own archive and root sentinels. No fixture path was
   under the WD or Toshiba roots.

8. **Current-source fixture-construction seam.** A temporary Dart test harness
   used the current schema APIs and the Prompt 79 safety evaluator. It performed
   two matching bounded read-only samples of Apple Messages, selected one row
   by source identity, stored only ROWID/GUID-derived identity evidence, and did
   not read private message text. The construction sample contained `139094`
   messages with high-water ROWID `155270`; selected GUID evidence was retained
   only as SHA-256
   `1194b868530878a88d106baa0d5a07bf0e0b506f4b04838be1fd8d55e30ed983`.

9. **FDA/source preflight.** The user confirmed MessageLens Development FDA was
   ON. The first A launch nevertheless produced a source-unreadable result and
   did not mutate its fixture; that attempt was discarded as qualification
   evidence. A fresh A-only fixture was then built from a successful bounded
   source read and qualified. Later B, C, and D launches each visibly reported
   the Messages source readable and stable. FDA was left in its intended ON
   state.

10. **Fixture A raw/canonical path and UUID.** Raw and canonical root were both
    `/private/tmp/messagelens-prompt80-A-retry-EiiwlDIg/A-reconstructible-live-only-partial`.
    Archive UUID was `7bb81f71-036e-4bfa-9de2-dece905b68e1`.

11. **Fixture A populated-domain inventory.** Before launch: import DB present;
    graph absent; source registry `2`; import batches `1`; messages `1`; handles,
    chats, graph edges, contacts, channels, attachments, and message-attachment
    links all `0`; overlay and presence absent. Import SHA-256 was
    `0f4f9ceff542d0af7f7933c3eeb1861d6c8875de015afbc094e3626a50c45d6d`.

12. **Fixture A expected safety evidence.** The current evaluator classified
    the fresh fixture `rebuildableLiveOnlyPartial`, returned
    `mayResetDerivedStores == true`, found exactly the two canonical live
    sources, and found no protected, retired, corrupt, unsupported, or
    source-missing fact.

13. **Experiment A initial PID.** The executable Local Data Repair process was
    PID `81643`.

14. **Experiment A AppCzar disposition.** AppCzar selected executable Local
    Data Repair and started it automatically. The presentation advanced too
    quickly to preserve a screenshot of the label, but the exact reset service
    log and immediate physical reset/restart identify the selected executable
    jurisdiction; no legacy Journey or user-confirmed reset surface appeared.

15. **Experiment A revalidation result.** PASS. The fixture was freshly proven
    `rebuildableLiveOnlyPartial`, and the qualified production path requires a
    second schema-wide source comparison immediately before Ball admission.
    The destructive callback then executed. No consent, provenance-only fact,
    historical intent, or stale cursor could authorize that callback.

16. **Experiment A mutation-start evidence.** The existing fixture-local app
    log recorded one `MessageDataResetService` “Reset Message Data requested”
    at `2026-10-08T16:11:44.089481Z`, followed by the source-scoped import and
    graph close attempts and the enumerated deletion.

17. **Experiment A exact physical reset footprint.** The observer saw the
    import DB present under PID `81643`, then both import and graph absent at
    `2026-10-08T16:11:44.330946Z`. The graph was already absent before reset.
    The service log reported one deleted file: the fixture's
    `macos_import_ss.db`; retired cleanup count was `0`. No broad root deletion
    occurred.

18. **Experiment A postcondition result.** PASS. The service log recorded
    `sourceScopedImportDbExistsAfterReset: false` and
    `conversationGraphDbExistsAfterReset: false`. The observer independently
    sampled the same physical absence before the replacement process recreated
    derived data.

19. **Experiment A preservation-witness result.** PASS. Marker SHA-256 remained
    `7623c6f213e90691d535ab936ba6315f7f106cc65b2ec24ca22ff0a3558e4db3`;
    root sentinel remained
    `45c4e5f40d1fb442a08f41e7950e22ee8aa49986431360cde1e1d255c9572a72`;
    archive sentinel remained
    `9d50bc1f495d0c5f5d9b50d1fe631043bdeff1952ecfb44c0e358b5128a14b96`.
    The log explicitly named overlay, preferences, and attachment archive as
    preserved.

20. **Experiment A Ball/log corroboration.** Exactly one reset-request log
    entry and one observer transition from import-present to both derived stores
    absent were observed. No overlapping or second Local Data Repair mutation
    appeared. The callback-local Ball tenure and release-before-restart remain
    formally proven by the Prompt 79 automated authority tests.

21. **Experiment A old PID/restart boundary.** PID `81643` disappeared and PID
    `82061` replaced it after the reset. The 150 ms observer did not capture an
    empty-PID sample between them, so no unsampled duration is claimed; the PID
    replacement itself is conclusive evidence of a real process boundary.

22. **Experiment A replacement PID.** PID `82061` was the first replacement
    process. It began with both active derived stores absent and then recreated
    them through the initial-build jurisdiction.

23. **Experiment A fresh AppCzar disposition.** Fresh AppCzar in the
    replacement process selected Onboarding/initial construction. After that
    build completed and restarted, PID `93116` ran a new AppCzar assessment and
    selected Attachment Archive Repair based on the newly built current facts.

24. **Proof no same-process Onboarding handoff.** The reset ran in PID `81643`;
    the first observed derived-store creation occurred under PID `82061`.
    Therefore Onboarding did not begin inside the Local Data Repair process.

25. **Subsequent Onboarding build/result.** The replacement process created a
    full import DB and graph, then restarted into PID `93116`. Fresh AppCzar
    later displayed an exact Attachment Archive Repair batch. It was not
    authorized or clicked. This later jurisdiction did not alter the already
    observed reset postcondition.

26. **Fixture B construction.** Root
    `/private/tmp/messagelens-prompt80-qualification-5HQcVP3A/B-live-provenance-source-fact-missing`,
    UUID `dc062752-d942-4574-a0bf-16fb78d31343`, contained one consequential
    import message, one batch, exactly the two canonical live source records,
    and no graph. Initial import SHA-256 was
    `0af49ca2b0eb81ccbeb713f8c39edbe92c3e3c0ecfbd2975cb8f7cee13495354`.

27. **Fixture B source-missing proof.** Its local live-provenance message used
    fixture-only ROWID `100155270`, which was conclusively absent from the
    current source whose visible high-water was `155288`. The evaluator returned
    `sourceFactMissing` and `mayResetDerivedStores == false`; provenance alone
    was not treated as reconstructibility.

28. **Experiment B AppCzar class/disposition.** AppCzar displayed: “Partial
    local data is protected, unsupported, or not proven reconstructible.” It
    selected `Diagnostic Review` and stated “Diagnostic only. No coordinator
    has been started.” No executable repair control was presented.

29. **Experiment B no-mutation proof.** The app was observed after assessment,
    then quit normally. No reset/build surface appeared, no graph was created,
    and no coordinator began.

30. **Fixture B before/after hash/count result.** PASS. Import, marker, root
    sentinel, and archive sentinel hashes were unchanged. Import counts remained
    messages `1`, source registry `2`, import batches `1`; graph remained absent.

31. **Fixture C construction/protected-source facts.** Root
    `/private/tmp/messagelens-prompt80-qualification-5HQcVP3A/C-protected-historical-material`,
    UUID `96f1b3f6-4801-4a3f-9a8b-feb7df58ad4f`, contained the two canonical live
    sources plus source key
    `prompt80-protected-historical:C-protected-historical-material`, kind
    `historical_messages_archive`, label `Prompt 80 protected historical
    source`. Counts were messages `1`, sources `3`, batches `1`; graph absent.
    The evaluator returned `protectedMaterialPresent` and
    `mayResetDerivedStores == false`.

32. **Experiment C class/disposition.** AppCzar again displayed the protected /
    unsupported / not-proven-reconstructible diagnosis and selected virtual
    `Diagnostic Review`; no coordinator started.

33. **Experiment C no-mutation proof.** No Local Data Repair, historical-source
    removal, graph construction, or other mutation began. The app was quit
    normally after the stable diagnostic result.

34. **Fixture C before/after result.** PASS. Import SHA-256 remained
    `0ef4eba3c31e90e5fdf7a022f827c57e3ac854d7bfee20db8f2898f620ec236c`;
    marker remained
    `e539411abf9b6f0054935f10387c1188c6cca64141c91ffdfac47338a578b1eb`;
    root and archive sentinels remained
    `ab079b598fc3174345c2aa64e613baf445f203bcd005b44341be9cc788b2c614`
    and
    `3c7730e8621270a9ea964e55e53593673cc102d0b60f4945740bba41de9e46c1`.
    Counts stayed `1/3/1`, the historical source row remained, and graph stayed
    absent.

35. **Fixture D corruption/unsupported construction.** Root
    `/private/tmp/messagelens-prompt80-qualification-5HQcVP3A/D-corrupt-unknown-safety`,
    UUID `a0d05256-4484-448f-a3b0-3935e16ca030`, contained a 49-byte deliberately
    non-SQLite active import file and no graph. Read-only `PRAGMA user_version`
    failed with SQLite code `26`, “file is not a database.” The evaluator class
    was `unknown`, with `mayResetDerivedStores == false`.

36. **Experiment D Diagnostic Review result.** PASS. AppCzar reported Initial
    construction scope `Unhealthy`, import data `Needs attention`, and the exact
    code-26 bounded-health-read failure. Diagnosis was “Existing protected,
    retired, unsupported, or unhealthy MessageLens data requires separate
    review.” Coordinator was `Diagnostic Review`, followed by “Diagnostic only.
    No coordinator has been started.”

37. **Experiment D no-mutation proof.** No executable repair action was offered
    or started. The corrupt store was not deleted to discover its contents; no
    graph was created. The app was quit normally.

38. **Fixture D before/after result.** PASS. Import SHA-256 remained
    `f08690de32b6eddbfe8374d5a4be44ffdb6ab96c5a8159a83765dbb63ae032d0`;
    marker remained
    `6e73edf805f42ab9b596ec13c0e90f2c75090057787360424d814c795812d20e`;
    root and archive sentinels remained
    `aefb025cf7b773faef6f6d492625c731a75395aedbaf0ef4b760d9fc45903aa6`
    and
    `49718a9f40a282cc091f9a9961c00ef25b1151bd8fa40867d6597bb0013c344b`.
    File size/mtime remained `49` / `1791462617`; graph remained absent. The
    zero-byte instance lock is harmless launch evidence and was the only added
    fixture-local artifact.

39. **Fair-Witness verdict.** PASS. Reconstructibility TRUE came from bounded
    current-source comparison, not provenance. Source-missing remained known
    FALSE; protected history remained protected; corrupt/unknown remained
    non-disposable. Only the exact TRUE class mutated. Physical reset was
    distinguished from subsequent semantic repair, and fresh AppCzar—not an old
    cursor, consent, failure story, or the repair process—selected what followed.

40. **Errors/warnings/evidence limitations.** The all-fixture helper ended with
    a harmless zsh `status` reserved-variable error after its Dart test had
    already passed and written the manifest. The initial A attempt was rejected
    because the process could not read the source and caused no mutation; a
    fresh A fixture was used. During successful A, the reset log warned that its
    pre-reset provider-close attempt found persistent stores unavailable during
    maintenance, but the enumerated delete and postcondition succeeded. The
    observer did not sample an empty interval between PIDs `81643` and `82061`
    and cannot inspect hidden Ball tenure; those claims are limited accordingly.

41. **Cleanup result.** Every MessageLens Development process is gone;
    `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty; the observer is stopped;
    FDA remains in the user-confirmed intended ON state. Production MessageLens
    was not launched or touched. No real MessageLens archive/database was
    modified. All disposable fixtures and the A observer log remain preserved
    in `/private/tmp`. Source/tests were not changed, staged, or committed;
    known unrelated untracked files remain untouched.

42. **Overall Local Data Repair human qualification verdict.** PASS. The exact
    safe live-only partial class executed one bounded automatic reset, passed
    physical postconditions, crossed a real process boundary, and returned
    semantic control to fresh AppCzar; each of the three negative classes failed
    closed without mutation.

43. **Recommendation for qualification checkpoint.** YES. Checkpoint Prompt 80
    and this response only after review; do not include unrelated untracked
    files or any `/private/tmp` fixture artifact.

44. **Readiness for Diagnostic Review milestone.** YES. The three distinct
    non-executable conditions all converged on the intended virtual Diagnostic
    Review boundary with concrete, preserved evidence suitable for designing
    that milestone.

45. **Readiness for production AppCzar cutover.** NO. This qualification closes
    the Local Data Repair human milestone; it does not constitute the remaining
    Diagnostic Review implementation/qualification or full production cutover
    qualification.

RECONSTRUCTIBLE LIVE-ONLY PARTIAL DATA SELECTED EXECUTABLE LOCAL DATA REPAIR: YES

SCHEMA-WIDE RECONSTRUCTIBILITY WAS REVALIDATED BEFORE MUTATION: YES

AUTHORIZED PHYSICAL RESET POSTCONDITION PASSED: YES

LOCAL DATA REPAIR ENDED AT A REAL PROCESS BOUNDARY: YES

FRESH APPCZAR OWNED THE POST-REPAIR DISPOSITION: YES

LIVE PROVENANCE WITH A MISSING CURRENT SOURCE FACT WAS NOT RESET: YES

PROTECTED NON-LIVE/HISTORICAL DATA WAS NOT RESET: YES

CORRUPT OR UNKNOWN REPAIR SAFETY REACHED DIAGNOSTIC REVIEW WITHOUT MUTATION: YES

APPCZAR LOCAL DATA REPAIR HUMAN LIVE QUALIFICATION: PASS

READY TO CHECKPOINT LOCAL DATA REPAIR HUMAN QUALIFICATION: YES

READY FOR DIAGNOSTIC REVIEW MILESTONE: YES

READY FOR PRODUCTION APPCZAR CUTOVER: NO
