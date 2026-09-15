# Tester Archive Import Memory Remediation — Phase 4 and Release Qualification

Date: 2026-09-13

Status: Phase 4 is complete. The locally available packaged-process,
automated, versioning, production-signing, and notarization work is complete.
Final release sign-off is **held**, not failed, because this workstation is a
24 GB Mac and therefore cannot satisfy the plan's separate low-memory Mac
target gate. The original-tester retry is intentionally not started. A later
publication step placed the exact qualified artifact on the tester portal
without rebuilding; that publication did not close the low-memory gate.

## Executive decision

Nothing observed in Phase 4 or local release qualification contradicts the
Phases 0–3 diagnosis or the bounded-memory remediation. The production import
coordinators retain their explicit record and byte bounds, the packaged
150,000-candidate run plateaus, and an actual `SIGKILL`/relaunch matrix
converges at all seven required boundaries without changing the overlay or
attachment-preservation sentinels.

MessageLens `0.2.111+129` was built through the production distribution
path with the canonical bundle identifier, Developer ID signing, hardened
runtime, Apple notarization, and a stapled ticket. The resulting DMG has not
been installed or launched. At the time this qualification report was first
written, it had not been published; the chronological publication addendum in
section 10 records the later no-rebuild deployment.

This is a valid locally qualified and subsequently published tester candidate,
but it is not the final low-memory/tester-retry sign-off. The remaining gates
are:

1. repeat the 123,561-or-larger packaged run on the intended low-memory Mac
   under ordinary concurrent-app load and establish the final numerical
   ceiling there; and
2. after separate authorization, have the original tester retry without broad
   Application Support deletion and collect the post-run support bundle.

## 1. Checkpoint audit-trail reconciliation

The checkpoint bookkeeping is now explicit in
`12-IMPLEMENTATION-AND-QUALIFICATION-CHECKPOINT.md`:

1. the seven implementation/test commits run from `adea9531` through
   `d82cbc4b`;
2. `21a1b172907a3a263587bc21b22fbcf574c27a5b` is the eighth commit,
   `docs(import): record remediation checkpoint`; and
3. `3fdd44c5` records that clarification.

There was no missing implementation commit and no uncommitted checkpoint
content. Nothing has been pushed.

## 2. Phase 4 implementation

### Recovery-stage evidence — `d976e9a3`

- The persisted `OnboardingOperationSnapshot` is included in Environment
  Readiness reporting.
- A genuinely interrupted operation remains resumable even when the older
  coarse installation classification is `graphProjectionFailed`.
- The onboarding surface names the actual persisted substage, including
  `extractingRichText` and `persistingRichText`, and offers `Continue Setup`.
- Diagnostic-report headers include normalized operation status, stage,
  substage, and aggregate progress.
- Normal support bundles contain `onboarding_operation.json`, which includes
  the persisted status/stage/substage, aggregate progress, anomaly totals, and
  normalized recovery facts.
- The operation artifact omits operation and process UUIDs, source row IDs,
  content, and paths.

An injected interrupted-rich-text snapshot was verified to report
`status: interrupted`, `substage: extractingRichText`, and
`24000 / 123561` work units while omitting its UUID and source-row identity.

### Authoritative build metadata — `beb2643e`

- Stale checked-in fallback version/build values were removed from the health
  audit.
- `databaseHealthAuditServiceProvider` obtains app name, bundle identifier,
  version, and build number from `PackageInfo.fromPlatform()`.
- The build channel is derived from the actual Dart release/profile/debug
  mode.
- `package_info_plus` is now a declared direct dependency.

The packaged production Info.plist independently confirms:

- bundle identifier: `com.bigbenchsoftware.MessageLens`;
- version: `0.2.111`; and
- build: `129`.

### Privacy-safe pending-enrichment diagnostics — `fc73ec33`

Database-health schema `1.1.0` adds `message_text_enrichment` with:

- remaining candidate count;
- aggregate attributed-body bytes; and
- largest attributed-body byte count.

One SQLite aggregate query computes these values. It does not materialize a
BLOB or message value into Dart and exports no content. A query failure is
typed as `message_text_enrichment` and does not suppress the remainder of the
health report.

The operator contract is updated in
`12-DATABASE-HEALTH-AUDIT/10-support-bundle-integration.md`.

## 3. Actual packaged-process interruption/relaunch rehearsal

Commit `fdf54fcd` adds a qualification-only packaged worker and harness. The
worker is built as a macOS Profile application, invokes the production
`MessageImporter`, `MessageRichTextEnricher`, relationship importer, and graph
projector, and uses only disposable synthetic SQLite databases.

The worker refuses to run unless it receives the exact qualification token
`synthetic-disposable-archive` and every data path is beneath a system
temporary directory. It cannot select or open the production MessageLens
archive. The process was terminated with operating-system `SIGKILL` (exit
`-9`), then the same packaged executable was relaunched against the same
durable synthetic files.

The interruption fixture contained 2,501 messages with 500-record pages.

| Interruption boundary | Durable state immediately after `SIGKILL` | Work on relaunch | Final state |
|---|---|---|---|
| Before first source-page commit | 0 messages, 0 relationships, empty graph | 2,501 messages imported | 2,501 messages, 1 relationship, 2,501 graph messages |
| After multiple source-page commits | 1,000 messages, 0 relationships, empty graph | Remaining 1,501 messages imported | Same complete final state |
| Before relationship import | 2,501 messages, 0 relationships, empty graph | 0 messages replayed; relationship/projection completed | Same complete final state |
| Before graph-projection commit | 2,501 messages, 1 relationship, empty graph | 0 messages replayed; projection completed | Same complete final state |
| During decoder page | 500 rich-text rows durable | Remaining 2,001 candidates processed | 2,501 enriched; 0 pending |
| After decoder, before persistence | 500 rich-text rows durable | Remaining 2,001 candidates processed | 2,501 enriched; 0 pending |
| After rich-text persistence | 1,000 rich-text rows durable | Remaining 1,501 candidates processed | 2,501 enriched; 0 pending |

Every case retained committed work and replayed no more than the interrupted
bounded unit. Overlay and `attachment_archive/` sentinel bytes were unchanged
after every relaunch. Relationships and graph projection converged. No source
fact was lost.

The packaged harness uses non-controlling observation callbacks at the page
boundaries. They are null in normal application construction and cannot alter
production behavior unless the qualification worker explicitly supplies them.

## 4. Packaged memory qualification

The same packaged Profile executable ran the production rich-text coordinator
and import ledger in a separate process. The parent sampled that process's RSS
with `ps`; fixture preparation occurred outside the measured process.

| Candidates | Peak RSS | Page count | Samples | Elapsed |
|---:|---:|---:|---:|---:|
| 25,000 | 144,320 KiB | 50 | 21 | 709 ms |
| 150,000 | 150,080 KiB | 300 | 81 | 3,717 ms |

The six-fold corpus increase added only 5,760 KiB, or 4.0%, to peak RSS. The
150,000-candidate bucket maxima were:

`[130960, 143648, 145024, 145312, 146784, 147440, 148448, 148992, 149424, 150080] KiB`

That shape is a narrow plateau rather than archive-proportional growth. The
run completed with no application-memory alert and corroborates the Phase 0–3
`flutter_tester` measurement in a packaged macOS process.

### Numerical-ceiling status

This machine is an Apple M4 Mac mini with 24 GB of memory, running macOS
26.6.2 (25G83). It is not the plan's low-memory target Mac.

A **provisional host-only observation line** of 192 MiB (196,608 KiB) would be
31.0% above the measured 150,000-candidate peak. It is not adopted as the
release ceiling because the plan requires the ceiling and ordinary-load
headroom to be established on the intended low-memory hardware. No simulated
process limit can substitute for macOS system-wide memory-pressure behavior on
that target.

Accordingly:

- packaged plateau gate on the available host: **passed**;
- 123,561-or-larger completion without a memory alert on this host: **passed**;
- final low-memory target-Mac gate: **not run / remains required**; and
- Phase 0–3 conclusion: **not contradicted**.

## 5. Automated and native command gates

The final code state produced these results:

- recovery/onboarding diagnostics: 24 focused tests passed;
- overlay/provider preservation coverage: 26 focused tests passed;
- build-metadata and aggregate diagnostics: 17 focused tests passed;
- importer/enricher observation-boundary coverage: 28 focused tests passed;
- combined focused import/graph/architecture command: 423 tests passed;
- complete Flutter suite: 2,285 tests passed and one qualification-worker test
  intentionally skipped in direct-test mode because its parent harness owns
  execution;
- `cargo fmt --check`: passed;
- Rust decoder tests: 8 passed;
- `cargo clippy --all-targets --all-features -- -D warnings`: passed; and
- release-mode Rust decoder build: passed.

`flutter analyze` reports no errors, no warnings, and no remediation-introduced
findings. It exits nonzero because the repository retains two baseline
informational findings in `packages/macos_ui_patched`:

- `unnecessary_library_name`; and
- `unintended_html_in_doc_comment`.

This is the same analyzer baseline recorded at the Phases 0–3 checkpoint.

The macOS release build completed with existing dependency/platform warnings
from `file_selector_macos`, `media_kit_video`, `volume_controller`, and the
current AppDelegate deployment-target/Swift-mode combination. None was a
signing, packaging, or notarization failure.

## 6. Version, signing, notarization, and artifact

Commit `a539cceb` prepares `0.2.111+129` and adds the tester-visible
`CHANGELOG.md` entry covering bounded import/enrichment, decoder containment,
recovery, and diagnostics.

The release decoder was first rebuilt with `cargo build --release`. The
repository's distribution command then ran:

```text
./tool/build_and_notarize.sh --artifact-only
```

Results:

- Flutter Release build: passed (`MessageLens.app`, approximately 108 MB);
- production archive identity metadata: passed;
- canonical bundle identifier: `com.bigbenchsoftware.MessageLens`;
- canonical archive root contract:
  `~/Library/Application Support/com.bigbenchsoftware.MessageLens`;
- Developer ID signing and hardened runtime: passed;
- signing team/FDA continuity contract: preserved;
- DMG creation: passed;
- Apple notary submission: `3f8e6a74-898a-45de-8ecb-0a2aff2f4139`;
- Apple status: `Accepted`, status code `0`, summary `Ready for distribution`,
  issues `null`;
- notarization ticket staple and validation: passed;
- strict recursive verification of the app inside a read-only mounted copy of
  the DMG: passed;
- designated requirement: satisfied; and
- Gatekeeper assessment: accepted, source `Notarized Developer ID`.

Final local artifact:

- path: `/Users/rob/Desktop/MessageLens-latest.dmg`;
- size: 47,921,437 bytes; and
- SHA-256:
  `5f2313eb8526b23981396f376552259ba924d69d3d9336097f52538c34039e35`.

The final hash differs from Apple's pre-staple upload hash because stapling the
ticket modifies the DMG after notarization.

The `--artifact-only` exit occurred before tester-portal build, metadata
update, or publication. The application was not installed or launched, so the
production archive and existing Full Disk Access relationship were not
touched during qualification.

### Verification-environment note

An initial post-build `codesign` recheck inside the restricted agent sandbox
reported a false `invalid signature` result because the sandbox could not use
the normal macOS code-signing trust services. This was treated as a stop signal
and investigated before proceeding. The identical app inside the DMG then
passed strict recursive `codesign`, Gatekeeper, and stapler verification when
those commands were given normal macOS security-service access. Apple's
accepted/no-issues notarization record lists the same arm64 and x86_64 app code
directory hashes. No artifact was rebuilt or altered to bypass the check.

## 7. Release acceptance matrix

| Criterion | Result | Evidence / remaining work |
|---|---|---|
| No whole-corpus production import/enrichment read | Passed | Keyset/count/high-water architecture and tripwires remain green |
| Decoder calls and writes obey explicit row/byte bounds | Passed | Focused tests, packaged page counts, native 8 MiB boundary |
| 150,000-candidate memory plateau | Passed locally | 150,080 KiB packaged peak; 4.0% growth for 6x corpus |
| Low-memory target Mac, ordinary concurrent load | **Pending** | Available host has 24 GB; must not be represented as low-memory qualification |
| Actual process death retains checkpoints | Passed | Seven `SIGKILL`/relaunch cases |
| First-run, historical, incremental source identity | Passed in automated/packaged synthetic coverage | Original historical archive retry intentionally pending |
| Anomalous records remain visible/accounted | Passed | Fidelity tests and row-local decoder behavior |
| Relationships and graph converge after resume | Passed | Packaged final counts reconcile at all boundaries |
| Overlay and attachment archive unchanged | Passed | Byte sentinels unchanged in all packaged cases |
| Real build/stage/privacy-safe support evidence | Passed | Runtime package metadata, operation artifact, aggregate-only health query |
| Test/analyzer/Rust gates | Passed with recorded analyzer baseline | 2,285 Flutter tests; 8 Rust tests; two baseline analyzer infos only |
| Version/bundle/signing/notarization/FDA continuity | Passed | `0.2.111+129`, canonical bundle ID, accepted and stapled DMG |

## 8. Deviations and problems

1. **Low-memory hardware unavailable.** This is the only uncompleted local
   release-qualification gate. It prevents final release sign-off but does not
   contradict the measured plateau.
2. **Packaged qualification uses a guarded Profile worker target.** It is a
   real `.app` process using the production coordinators and actual SQLite
   durability, but it intentionally does not launch the production GUI or
   point at production data. This keeps the rehearsal repeatable and preserves
   the real archive.
3. **Analyzer baseline.** The analyzer command retains two informational
   findings in the vendored macOS UI patch and therefore does not return zero.
   There are no errors, warnings, or new findings.
4. **Build warnings.** Existing third-party deprecation/ownership and
   deployment-target warnings remain non-blocking; the build, signature,
   Gatekeeper, and notarization gates all passed.
5. **Sandboxed signing false negative.** This was resolved by rerunning the
   same checks with required macOS trust-service access. The accepted Apple log
   has no issues, and no workaround weakened verification.

No release-qualification evidence contradicted the Phases 0–3 diagnosis,
resource-bound conclusions, source-fidelity guarantees, source scoping,
overlay independence, or attachment-preservation invariant.

## 9. Qualification stop boundary and handoff

Qualification work stopped before contacting or involving the original tester.
At that checkpoint the notarized DMG was local only. The owner later authorized
tester-portal publication as a separate distribution action, but did not
authorize the original tester retry or disposition the low-memory target-Mac
gate.

When authorized later, the tester procedure in the remediation plan remains
unchanged: no broad Application Support deletion, no attachment-archive
mutation, resume through the application's offered recovery path, and collect
a fresh support bundle after completion.

## 10. Publication addendum — 2026-09-13

The already-qualified notarized candidate was published to the Render tester
portal without invoking a rebuild, re-sign, re-notarization, version change, or
artifact mutation.

- version/build: `0.2.111+129`;
- final DMG size: 47,921,437 bytes;
- qualified and published SHA-256:
  `5f2313eb8526b23981396f376552259ba924d69d3d9336097f52538c34039e35`;
- portal repository:
  `https://github.com/bigbenchrob/message-lens-site.git`;
- publishing branch: `main`, tracking `origin/main`;
- publication commit:
  `1fd49d33c719b797d598c4ab4294899884377732` (`publish MessageLens 0.2.111 tester build`);
- public site: `https://message-lens-site.onrender.com/`;
- public artifact:
  `https://message-lens-site.onrender.com/assets/downloads/MessageLens-latest.dmg`;
- tester metadata: Production tester build / Beta / macOS, with
  `requiresDataReset: false` (`Not required`).

The Desktop candidate and portal copy both matched the recorded final hash and
size. Portal changes were limited to the DMG, `latest-build.json`,
`tester-changelog.json`, the source landing page, and its generated page.
Tester notes described the bounded import/enrichment architecture, durable
continuation, decoder containment, exact recovery reporting, and privacy-safe
diagnostics.

This publication is distribution evidence only. It does **not** satisfy the
still-outstanding low-memory target-Mac qualification, and the original tester
was not involved.

## 11. Git status at the qualification report checkpoint

- Worktree: `/private/tmp/messagelens-tester-import-memory-remediation`
- Branch: `codex/tester-archive-import-memory-remediation`
- Starting HEAD: `c2f546dc99eb50c66233ef94ddb0e70c7d77990e`
- Last implementation/release-metadata commit before this report:
  `a539cceb`
- This report and the support-bundle operator-document update are committed
  separately under `docs(import): record phase 4 release qualification`.
- Generated build/test outputs were restored or removed after qualification.
- Final post-commit status for the app repository: clean.
- App-repository push status at that checkpoint: not pushed. The later portal
  publication commit was pushed in the separate tester-portal repository.

The exact final HEAD is intentionally not embedded in the commit that contains
this document, because a Git commit cannot contain its own stable hash. Use
`git log -1 --format=%H` for the authoritative value; the completion report
that accompanies this document records it explicitly.
