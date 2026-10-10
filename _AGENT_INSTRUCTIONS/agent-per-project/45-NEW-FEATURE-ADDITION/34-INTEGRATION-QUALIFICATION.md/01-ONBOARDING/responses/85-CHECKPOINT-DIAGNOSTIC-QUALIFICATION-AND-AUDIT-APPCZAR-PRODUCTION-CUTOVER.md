# MessageLens Feature 34
## Response 85 — Checkpoint Diagnostic Review Qualification and Audit the Whole-Repository AppCzar Production Cutover

Date: 2026-10-10

Scope: whole-repository, source-grounded production-cutover audit and design only. No production or development app was built, launched, debugged, terminated, or reconfigured for this response. No real MessageLens archive, attachment archive, Apple Messages database, Contacts database, bookmark, marker, UUID, or application permission was read or changed.

## 1. Baseline Git and source provenance

The audit was performed in:

`/Users/rob/Development/FlutterProjects/remember_every_text`

The resolved baseline is:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `bef7f2bf94c46c0322a49418a3431f7ef16fd6cd`;
- upstream: `origin/fix/onboarding-import-stuck-state` at the same commit;
- ahead/behind: `0/0`;
- HEAD subject: `docs(app-czar): record bounded diagnostic qualification`;
- merge base with `main`: `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- `main...HEAD`: `0/43`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`;
- Feature 34 worktrees: exactly one, the primary worktree above.

A fresh external read-only baseline manifest was created at:

`/private/tmp/messagelens-prompt85-read-only-baseline-20261010T142154Z.md`

It contains source/Git provenance only. It contains no observations from a real production or development data root.

Sources inspected include the requested prior Feature 34 prompts/responses, the canonical Project Conformance standard, archive/onboarding safety rules, database-location and signing/FDA-continuity documentation, current Dart and macOS startup source, current AppCzar source, current legacy startup/Journey source, packaging configuration, and current tests. No test name was treated as evidence without checking its assertions.

Registered worktrees at audit time were:

| Path | Branch | HEAD |
|---|---|---|
| `/Users/rob/Development/FlutterProjects/remember_every_text` | `fix/onboarding-import-stuck-state` | `bef7f2bf94c46c0322a49418a3431f7ef16fd6cd` |
| `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35` | `feature/exclusive-authority-tenure` | `09b1c767cc01410da5799273206e2ab2a4d3b283` |
| `/Users/rob/Development/FlutterProjects/remember_every_text-main` | `main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f` |
| `/Users/rob/Development/FlutterProjects/remember_every_text.worktrees/gradle-fix-flutter-projects` | `agents/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37` |

## 2. Prompt 84 / Response 84 checkpoint

Prompt 84 and Response 84 were checkpointed together, and only together, before this audit:

- commit: `bef7f2bf94c46c0322a49418a3431f7ef16fd6cd`;
- subject: `docs(app-czar): record bounded diagnostic qualification`;
- files: the Prompt 84 record and Response 84 record only;
- upstream: pushed normally to `origin/fix/onboarding-import-stuck-state`;
- current local/upstream relationship: `0/0`.

The checkpoint preserves this result without strengthening it:

```text
Diagnostic Review human live qualification:
    PASS — REVISED BOUNDED SCOPE

Observed live:
    A: corrupt active import, stable 96 seconds, no repair
    B: required source fact missing, known reconstructibility FALSE
    C: protected non-live material, no removal/reset
    R: one human restart, distinct old/new PIDs, no retry loop
    Q: Quit, no relaunch during 98-second observation
    protected fixture files unchanged

Not observed live:
    genuine Messages-source UNKNOWN
    all original Prompt 83 classes

Previously automated:
    all 22 Diagnostic frontiers

Production AppCzar cutover:
    NOT AUTHORIZED
```

## 3. Diagnostic human qualification and remaining gap

The bounded Diagnostic Review human qualification is a PASS for the revised scope. It proved that selected unsafe evidence is presented as a frozen bounded occurrence; corrupt, protected, or source-inconsistent fixtures were not repaired; a user-requested reassessment crossed one real process boundary; Quit did not relaunch during the observation interval; and protected fixture files were unchanged.

The result does not prove a live genuinely `UNKNOWN` Messages-source occurrence. That frontier is covered by automated evaluator/controller tests but was not manufactured for human testing because doing so safely would have risked interference with real data or OS state. The audit therefore carries forward exactly:

```text
Diagnostic Review human live qualification:
    PASS — REVISED BOUNDED SCOPE

Genuine Messages-source UNKNOWN human live qualification:
    NOT EXERCISED

All original Prompt 83 classes human live-qualified:
    NO
```

This gap is not silently waived. It is a future qualification item and a rollout risk input.

## 4. Current development and production execution census

The development AppCzar composition has seven unambiguous owners:

| Jurisdiction | Current status | Explicit host/owner |
|---|---|---|
| Data Update | executable top-level coordinator | `AppCzarDataUpdateController` / `AppCzarDataUpdateScreen` |
| Source Access Repair | executable top-level coordinator | `AppCzarSourceAccessController` / `AppCzarSourceAccessScreen` |
| Attachment Archive Repair | executable top-level coordinator | `AppCzarAttachmentArchiveRepairController` / lifecycle host/screen |
| Onboarding | executable top-level coordinator | `AppCzarOnboardingController` / lifecycle host/screen |
| Local Data Repair | executable top-level coordinator | `AppCzarLocalDataRepairController` / lifecycle host/screen |
| Diagnostic Review | executable top-level coordinator | `AppCzarDiagnosticReviewController` / lifecycle host/screen |
| Operating Session | executable admitted session | `AppCzarOperatingSessionController` / `AppCzarOperatingSessionApp` |

`AppCzarStartupHarness` contains explicit branches. Operating admission is checked first as the admitted shell. The assessment host then checks completed Diagnostic Review, Local Data Repair, Data Update, Onboarding, Source Access Repair, and Attachment Archive Repair controllers explicitly. There is no `execute(coordinatorEnum)` dispatcher, no virtual-only disposition, and no legacy Journey provider imported into the AppCzar composition. Architecture tests assert the exact host census, exact coordinator construction edges, forbidden semantic imports, and one disposition-to-host mapping.

The remaining live gap is genuine Messages-source `UNKNOWN`; all evaluator frontiers have automated coverage, but that one frontier is not human-live-qualified.

Production follows the unchanged legacy path:

```text
native archive claim
  -> Dart archive admission
  -> admitted production identity
  -> AppCzarDevelopmentCompositionPolicy returns false
  -> MessageLensStartupPresentation.legacyStartup
  -> StartupApp
  -> App / MacosAppShell
  -> legacy installation/Journey/Environment Readiness handoffs
```

Production does not enter AppCzar because `AppCzarDevelopmentCompositionPolicy.admits()` accepts only an already-admitted official development identity. `ArchiveBuildIdentity.productionRelease` is explicitly rejected. That is current source behavior, not a runtime inference.

## 5. Native/bootstrap to user-visible owner call graph

The current call graph is:

1. `MainFlutterWindow.awakeFromNib()` invokes `MessageLensNativeArchiveClaimResolver.resolve()` before Flutter startup. The resolver reads the configured environment/build identity, exact bundle identifier, exact product name, and production-signature result. It resolves the root with POSIX `realpath` semantics.
2. Native archive-identity failure is shown by `MessageLensNativeArchiveAdmissionFailurePresenter` before Dart or AppCzar exists. No coordinator can recover that failure in-process.
3. Native constructs the root-scoped `MessageLens.instance.lock`; `MessageLensSingleInstanceAuthority.claim()` combines the file lock with matching-running-application checks. A second same-installation process is not admitted as an independent writer.
4. Native exposes its immutable claim over the archive-identity method channel.
5. Dart `_admitArchive()` independently resolves the expected canonical root, requires exact native/Dart path agreement, validates the archive marker/environment/instance UUID contract, and constructs `ArchiveAccessAuthority`. The `/tmp` versus `/private/tmp` correction retained independent witnesses while aligning both on filesystem reality.
6. `main()` creates one `ProviderContainer`, overriding the admitted authority/root and root-scoped evidence seams. Persistent startup initialization happens only after admission. Pre-admission persistent logging is intentionally prohibited.
7. `AppCzarDevelopmentCompositionPolicy.admits(authority)` answers only whether this already-admitted process belongs to the development AppCzar composition. It does not admit the archive and does not grant any mutation.
8. `_selectMessageLensStartupPresentation()` selects `AppCzarStartupHarness` only when that policy is true. Otherwise it constructs `StartupApp`.
9. `AppCzarStartupHarness` obtains one bounded assessment, projects one exact disposition, and exposes exactly one coordinator host or the admitted Operating shell.
10. Any AppCzar action whose postcondition changes startup facts drains its owner and calls the restarter. The old PID exits before `/usr/bin/open -n` opens the exact current `.app`; the replacement process repeats native claim, lock, Dart admission, and fresh AppCzar assessment. There is no in-process coordinator handoff.

Four questions remain separate:

```text
archive admission
    Is this root/marker/application identity valid enough to construct authority?

composition selection
    Which process-wide semantic-control architecture mounts?

operation authorization
    Does this exact owner hold the typed Ball for this exact mutation now?

AppCzar disposition
    Which top-level jurisdiction follows from fresh current evidence?
```

The minimal future production seam is therefore not an adoption gate. It is an explicit production AppCzar composition *eligibility and activation* decision evaluated only after immutable production `ArchiveAccessAuthority` exists. Eligibility should recognize the exact official production identity; activation should remain separately false by default until later authorization. No operation capability follows from either decision.

## 6. Root, identity, marker, and independent canonicalization contract

Source establishes these identities:

- production bundle identifier: `com.bigbenchsoftware.MessageLens`;
- production product: `MessageLens`;
- production build identity: `productionRelease`;
- production default root: `~/Library/Application Support/com.bigbenchsoftware.MessageLens`;
- development bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- development product: `MessageLens Development`;
- development build identities: debug/profile/release development variants;
- development root override: permitted only for recognized development builds and required to be an existing absolute writable directory;
- production root override: prohibited.

Native and Dart do not trust one another's spelling. Native uses `realpath`; Dart resolves filesystem symbolic links; their canonical strings must agree exactly. The admitted marker/environment/UUID then binds the root to one archive instance. An error in native identity, root, signature, canonicalization, process lock, marker, or Dart agreement occurs before AppCzar and fails closed.

The marker/UUID is archive identity, not semantic Journey state. Existing-install marker facts and first-run marker creation rules are governed by archive admission. This audit did not inspect any real marker and makes no claim about the actual production marker or UUID.

All root-derived resource providers must derive from the admitted authority/root: active databases, attachment configuration, location/bookmark evidence, journals/receipts, logs, and process lock. A production composition change can be logically zero-mutation: the same admitted root, marker, UUID, and provider container can select a different semantic composition without moving, adopting, replacing, resetting, or re-identifying any physical archive.

That is a design possibility, not proof that every real production root is currently compatible. First-install and upgrade/migration cases still require controlled production-like fixtures and later human authorization.

## 7. Development versus production composition policy

The current policy is deliberately development-only:

```text
already-admitted authority
AND environment == development
AND recognized development build identity
AND exact development bundle ID
AND exact development product name
    -> AppCzar development composition
```

Physical root and archive UUID do not decide whether the development process uses AppCzar. That correction allows disposable valid development roots to exercise the same semantic architecture as the qualified WD development root.

Production currently evaluates false and selects legacy startup. A future production policy should be additive and explicit:

```text
already-admitted authority
AND exact official production environment/build/bundle/product/signature
    -> production AppCzar eligible

eligible
AND separately compiled/configured production activation == true
    -> AppCzar composition
```

The first narrow implementation should add eligibility and the inactive selector seam only. It must leave activation false, production routing legacy, and every mutation policy unchanged.

## 8. Separate WD attachment-adoption mutation gate

`attachmentArchiveAdoptionExecutionEnabledProvider` is an operation-specific safety gate. It requires the exact authorized development root and archive UUID used by the attachment-adoption qualification. It answers whether that one dangerous adoption workflow may execute; it does not answer which process-wide composition owns semantics.

The architecture tests already forbid using this provider in the AppCzar composition selector. Production cutover must preserve that separation. The gate must not be reused, generalized, or broadened to make production AppCzar eligible. Production adoption remains disabled unless separately designed, implemented, and authorized later.

## 9. Startup, first-run, existing-install, and upgrade case matrix

| Case | Evidence available before selection | Expected current AppCzar jurisdiction | Permitted action | Production-specific untested assumption |
|---|---|---|---|---|
| Genuinely virgin admitted production root | admitted identity/marker state; safe-empty scope; readable/stable source or literal source condition; Contacts prerequisite when required | Onboarding when all required facts are conclusive; Diagnostic if source/scope evidence is unknown | bounded graph/import construction and typed attachment preservation under Onboarding; otherwise none | first-run production marker/root creation and notarized/FDA behavior have not been rehearsed |
| Valid healthy empty current derived stores | safe-empty scope, no protected/non-live/retired material, source and Contacts facts | Onboarding | build first derived dataset; preserve only under coordinator Balls | production-scale duration and interruption recovery unmeasured |
| Complete coherent/current local dataset | healthy import/graph/overlay/archive, stable source, no actionable delta | Operating | normal browsing plus Operating-owned bounded currentness | hidden legacy consumers must first be excluded from production AppCzar shell |
| Established dataset, source currently unreadable | conclusive read denial, otherwise bounded local facts | Source Access Repair | explain, open settings, fresh `readSource()` on Check Again; restart after changed evidence | real production TCC/FDA transition and modal behavior unqualified |
| Source ahead | stable source count/high-water ahead of coherent local state | Data Update | bounded importer/projector/preservation workers, drain, restart | production-root migration and interruption behavior needs fixtures/rehearsal |
| Attachment archive unavailable | known unavailable binding/location | Attachment Archive Repair | bounded human repair/navigation according to exact evidence; no invented coverage | external-volume reconnect/bookmark behavior under installed production build unqualified |
| Attachment archive read-only | known read-only state plus coverage/actionability facts | Operating only if no write/action is currently required and all other facts permit it; otherwise Attachment Archive Repair or Diagnostic according to literal evaluator facts | read-only browsing or explicit repair guidance; no writes without Ball | real read-only external filesystem combinations not live-qualified |
| Archive binding incoherent or moving | identity/generation/lease/journal observations | Diagnostic when unsafe/unknown/conflicting; Attachment Archive Repair only for a defined repairable condition | no inferred adoption/relocation; only existing typed recovery action if selected | interrupted relocation combinations require dedicated production-like cases |
| Complete dataset with known source-absent attachment debt | coverage false, actionability conclusively false, zero unknown/conflict/recovery | Operating | truthful debt card; normal operation; no claim of completeness | production-scale evidence latency unmeasured |
| Source-available uncovered attachments | coverage false and actionability true | Attachment Archive Repair | one exact human-confirmed batch, maximum 75; restart/reassess | real production archive write/TCC/volume failure behavior unqualified |
| Consequential live-only partial, proven reconstructible | partial scope plus exact Local Data Repair safety true | Local Data Repair | one typed derived-store reset only, verified postcondition, restart | production-like schema/provenance variants require tests |
| Consequential partial not proven reconstructible | safety false or unknown, protected data, missing source fact, binding mismatch | Diagnostic Review | read-only frozen report, restart or Quit only | none may be automatically converted to repair |
| Protected historical/non-live sources | initial scope detects protected material | Diagnostic Review | no deletion/reset; separate future review | production registry/donor diversity not exhaustively rehearsed |
| Retired/unsupported/corrupt stores | unhealthy/retired observations | Diagnostic Review | no automatic cleanup | upgrade matrix and recovery tooling still unspecified |
| Overlay/Presence/preferences/bookmark configuration | read-only scope/health evidence; protected-state presence | normally preserved; Diagnostic if they make safety unknown/unhealthy | no automatic deletion; ordinary Operating command surfaces must be retained/rewired | legacy semantic records may coexist and must not regain authority |
| Source `UNKNOWN` or unstable/conflicting | literal unknown or two bounded samples fail to agree | Diagnostic Review | frozen evidence, one explicit restart or Quit | genuine source-UNKNOWN is not human-live-qualified |
| Native/Dart admission error | native claim/canonical paths/marker/UUID before AppCzar | no AppCzar jurisdiction | fail-closed archive admission surface, then Quit | recovery UX is outside current coordinators |

No extra disposition is needed. An evaluator result that cannot support a specialized coordinator goes to Diagnostic Review.

## 10. Production data-family and preservation inventory

| Data family | Owner/current role | Assessment behavior | Permitted writer | Preservation requirement |
|---|---|---|---|---|
| `macos_import_ss.db` plus WAL/SHM | active source-scoped import ledger, schema 10 | bounded read-only health/count/high-water/provenance inspection | Onboarding, Data Update; Local Data Repair may delete only after exact proof | derived, but reset only under exact typed repair or explicit Start Fresh |
| `working_ss.db` plus WAL/SHM | active conversation graph/FTS projection, schema 3 | bounded read-only health/topology/coverage inspection | Onboarding, Data Update/projector; Local Data Repair under proof | derived, but not disposable merely because incomplete |
| `user_overlays.db` plus WAL/SHM | user intent, favorites, labels, settings, attachment metadata/registry, schema 8 | bounded read-only health and specialist evidence | overlay-specific repositories/actions only | protected; never graph/import reset and never dual-written |
| `presence.db` plus WAL/SHM | schedule/test/presence history, schema 9 | bounded health/presence evidence where relevant | Presence feature only | protected; not a Local Data Repair/Start Fresh target |
| archive marker/environment/UUID | immutable admitted archive identity | native/Dart admission, not coordinator mutation | archive bootstrap/explicit identity mechanisms only | never rewritten for composition selection |
| attachment archive or custom external payload root | irreplaceable preservation payloads | location, availability, binding, generation, lease, coverage/actionability reads | typed archive writer/repair/adoption/recovery only | never cache-cleaned, reset, bulk-moved, or overwritten by cutover |
| bookmarks/location configuration | external-root authorization and binding | restore/validate bounded evidence | typed settings/location workflow | preserve exact binding; no implicit fallback/adoption |
| adoption/relocation journals, checkpoints, receipts | operation recovery evidence | read only to classify/recover exact operation | owning typed operation | do not erase as obsolete startup semantics |
| historical-source registry/identity/donor relationships | user/authenticity and provenance state | inspected for protected/non-live scope | explicit historical-source actions only | no automatic deletion or reinterpretation |
| preferences/navigation/settings | session/product choices | legacy shell currently restores selected state | specific settings/navigation owners | retain user choices; rewire for Operating before legacy removal |
| logs/support records | diagnostics | bounded/logging policy | logging/support owners | privacy-aware; no pre-admission persistent diagnostics |
| retired `macos_import.db` / `working.db` and migration artifacts | diagnostic/legacy material, no central active providers | initial-scope bounded inspection | no automatic startup writer | presence can make scope non-empty/protected/unsupported; never silently clean |

AppCzar assessment repositories must use read-only probes and close one-off handles before returning. Missing files must not be created by an assessment. Central persistent database providers may open, create, or migrate files when a selected worker or Operating feature actually consumes them; therefore production cutover tests must demonstrate that the new shell does not eagerly consume those providers before classification.

## 11. Migrations, FTS, historical and retired-state consequences

Current active schema expectations are import 10, graph 3, overlay 8, and Presence 9. Import and graph are derived products; overlay and Presence are independent protected stores. FTS is part of the derived graph/search projection and must remain consistent with graph construction, not rebuilt by consulting overlay state.

The audit found no authority for a composition selector to migrate or clean a store. Migration belongs to the owning database provider once a selected capability legitimately opens that store. This means a future production-like fixture matrix must cover:

- every supported prior active schema to current schema;
- current schema with WAL/SHM sidecars;
- absent database versus corrupt/non-database file;
- legacy rows and retired files coexisting with current files;
- FTS row/topology invariants after Onboarding/Data Update;
- overlay intent and attachment metadata surviving all derived rebuilds;
- Presence history surviving all message repair/update flows;
- opening a newer schema with an older rollback binary.

There is no positive evidence yet that every historical production schema can pass first AppCzar launch without provider-triggered migration side effects. Consequently, automatic production routing is blocked until production-like migration tests exist. Obsolete semantic Journey rows may remain as historical records; their mere presence is not authorization and is not a cleanup mandate.

## 12. Legacy Journey, Environment, and `StartupApp` ownership inventory

| Legacy element | Current authority/reachability | Cutover classification |
|---|---|---|
| `StartupApp` in `lib/main.dart` | production composition owner; watches installation state and constructs old startup/normal app route | KEEP PRODUCTION FOR NOW; REMOVE ONLY AFTER QUALIFICATION |
| installation classifier / `messageLensInstallationStateProvider` | decides legacy installation/startup state | KEEP PRODUCTION FOR NOW, then REMOVE ONLY AFTER all callers are replaced |
| Journey Trip/Step/Episode, gate/action context, compatibility status | old semantic progression and commands | DEMOTE TO HISTORY where durable evidence is useful; REMOVE semantic authority only after qualification |
| Environment Readiness report/projector/action bridge | legacy cross-surface readiness presentation/actions | REWIRE current factual displays to AppCzar evidence or Operating-owned facts; remove authority edges later |
| `OnboardingOverlay` | legacy Journey presentation/terminal state | REMOVE ONLY AFTER AppCzar production Onboarding is active and qualified |
| sidebar-visibility owner | Journey-dependent visibility/navigation | REWIRE to composition/Operating state or neutral session state |
| center-sync observer/controller | responds to Journey/Environment changes | REWIRE or remove; it must not select semantics under AppCzar |
| durable operation snapshots | evidence for operation progress/recovery | KEEP FACT/WORKER; never restore Journey conclusions |
| recovery/reconciliation/failure history | operation evidence and support diagnostics | KEEP FACT/WORKER or DEMOTE TO HISTORY; no semantic startup vote |
| pipeline incident center takeover/completion handoffs | legacy pipeline/UI coordination | REWIRE to exact AppCzar owner or remove after worker equivalence |
| Start Fresh command | explicit advanced user command, distinct from automatic repair | REWIRE into an authorized Operating/settings command surface before legacy UI removal |
| historical-source removal | explicit user command over protected provenance | REWIRE separately; never merge into Local Data Repair |
| Presence schedule/history | independent protected feature data | KEEP FACT/WORKER; remove Journey interpretation only |
| persistent navigation preferences | ordinary user session state | KEEP FACT/SESSION and provide neutral Operating restoration |
| support/export features | some consume legacy Journey/snapshot reports | REWIRE to bounded current AppCzar occurrence plus historical evidence, with privacy review |
| generic `App` ambient workers | includes `chatDbChangeMonitorProvider` reachability | REWIRE/REMOVE from AppCzar production shell to prevent a second updater/authority |
| launch flags/FDA experiment route | development/experiment behavior | KEEP separately scoped; never use as production activation |

The correct retirement sequence is consumer-first. Hiding Journey UI is not enough. Every provider watcher, action bridge, observer, support exporter, and background worker must stop being reachable from the AppCzar production composition before the old semantic authority is deleted.

## 13. Hidden legacy consumers and ambient-worker reachability

The principal hidden-production risk is shared code mounted beneath the normal `App` shell. `App.build()` currently watches `chatDbChangeMonitorProvider`. Legacy Environment/Onboarding reporting also consumes that monitor. If a future AppCzar Operating shell reused those trees without a reachability audit, the monitor could coexist with Operating currentness and become a second import trigger or second statement about what state the app is in.

Other reachability that must be closed or rewired includes:

- `StartupApp` watching `messageLensInstallationStateProvider`;
- `OnboardingOverlay` and advanced reset UI watching Journey state;
- Environment Readiness panels/actions watching Journey/environment reports;
- center-panel synchronization responding to Journey conclusions;
- support bundle export consuming durable operation/Journey snapshots;
- sidebar restoration and reset controls currently conditionally disabled for development AppCzar rather than supplied by a neutral AppCzar-safe owner;
- old completion/failure handoffs that can still alter presentation after a worker finishes.

These are authority edges even when no legacy window is visible. Production cutover must be proven by dependency/import/reachability tests, not by appearance.

## 14. Seven-jurisdiction lifecycle and authority matrix

| Owner | Selection evidence | Actions / Ball | Lifecycle and restart | Human evidence |
|---|---|---|---|---|
| Data Update | established coherent local data; readable stable source ahead; no higher-precedence unsafe condition | existing importer/projector and attachment-preservation actions under exact typed mutation tenure | single flight, drain; postcondition stops; development restarter; fresh reassessment | live development update qualified, including same semantic route after restart |
| Source Access Repair | conclusive source readability `FALSE`; `UNKNOWN` is Diagnostic | open System Settings is navigation only; Check Again uses the same fresh source reader; no permission-state memory | success means only readable source; drain/restart immediately; no delta decision | OFF/ON development FDA sequence qualified; OS state itself not inferred |
| Attachment Archive Repair | archive/coverage actionability exact, or record-backed recovery; rejects source-absent-only debt and unknown/conflict | exact coherent batch, at most 75, human confirmation, typed archive resource actions, binding/generation checks | one batch per confirmation; drain/restart; no overwrite/fallback | real development archive batch qualified; production not exercised |
| Onboarding | safe empty, source/Contacts/binding facts conclusive, no protected consequential state | build import/graph and bounded preservation under Onboarding-owned Balls | progress owner, drain/restart after construction; no Journey authority | isolated disposable development qualification passed |
| Local Data Repair | consequential partial data plus exact `rebuildableLiveOnlyPartial` safety proof | one typed `localDataRepair` Ball deletes only enumerated derived stores; postcondition verifies | drain/reset/restart; stale binding/generation fails closed | four-fixture human matrix qualified: only exact safe class repairable |
| Diagnostic Review | any unowned unsafe, unknown, conflicting, corrupt, protected, or unsupported evidence | no mutation Ball; frozen projection; one explicit reassessment restart; ordinary Quit | no auto-retry and no evidence reread in occurrence; stop/drain before exit | revised bounded scope PASS; genuine source UNKNOWN not live exercised |
| Operating Session | complete coherent state or truthful source-absent debt with no actionable/unknown/conflicting condition | normal UI plus same-PID bounded currentness and typed update/preservation work; no global Ball | 15-second cadence, no overlap; same-jurisdiction update stays in PID; changed jurisdiction drains/restarts | Stage One and Stage Two development live qualifications passed |

All current restart calls resolve through `appCzarProcessRestarterProvider`, which constructs `MacosDevelopmentProcessRestarter`. The source authorization is `AppCzarDevelopmentCompositionPolicy`, so every coordinator restart intentionally fails in production today. Stale callbacks are bounded by owner single-flight/generation/binding checks; a stopped/drained owner must not retain a mutation capability.

## 15. Production restarter limitation and proposed seam

`MacosDevelopmentProcessRestarter` derives the current `.app` from `Platform.resolvedExecutable`, starts detached `/bin/sh`, waits with `kill -0` until the old PID exits, and then executes `/usr/bin/open -n "$bundlePath"`. It terminates the current process only after the detached waiter is started. Its constructor requires `developmentExecutionEnabled`, and the provider derives that value from the development composition policy.

It is therefore deliberately not production-compatible and not production-qualified. Removing that guard would be unsafe.

A future production restarter should be a separate explicit implementation or policy-bound factory that requires:

- an already-admitted official production `ArchiveAccessAuthority`;
- an active, explicitly authorized production AppCzar composition;
- exact current bundle/product/build identity and executable-to-bundle derivation;
- the same admitted root/process-lock identity;
- a single-flight restart request from the current owner;
- old PID exit before exact current installed bundle launch;
- launch failure logging that does not fabricate success or loop;
- no development/production cross-launch and no search for an arbitrary installed app.

Quit must remain ordinary exit with no waiter. This seam needs automated tests and a disposable production-identity-aware human rehearsal. Current Diagnostic restart evidence used a development build and does not qualify production.

## 16. Operating currentness and startup Data Update boundary

Startup Data Update owns a source-ahead condition discovered by fresh AppCzar assessment. It performs the bounded update, stops, and restarts so the next process reclassifies the entire world.

Operating owns ongoing currentness only after admission. Its qualified contract is:

- a 15-second bounded observation cadence;
- no overlapping cycles;
- current source count/high-water read and stable/coherent comparison;
- update through the existing importer/projector workers under Operating-owned tenure;
- `messageDataVersion` increment and UI refresh after successful same-session update;
- current navigation/session preserved when jurisdiction remains Operating;
- attachment coverage/actionability re-evaluated after update;
- historical source-absent attachment debt may remain truthfully visible when actionability is conclusively false;
- a newly available uncovered attachment, source denial, source unknown, archive loss, conflict, or other jurisdiction change causes drain/restart, not an in-process coordinator handoff.

The qualified development observation also showed user-facing refresh latency on the order of a polling cycle plus update work, not instantaneous delivery. That is expected evidence, not a production performance guarantee.

Before production activation, the generic `chatDbChangeMonitorProvider` and any legacy importer trigger must be unreachable from the AppCzar shell. Otherwise AppCzar currentness would not be the sole updater/semantic owner.

## 17. Attachment archive, relocation, coverage, and adoption risks

The attachment archive is preservation data, never a cache. Current evidence separates:

- archive availability and binding;
- complete payload coverage;
- current automatic repair opportunity;
- source-absent historical debt;
- source-evidence unavailable;
- record-backed recovery;
- unsafe/conflicting evidence.

Coverage `FALSE` remains false when payloads are source-absent. Operating is permitted only when actionability is conclusively false and every other admission fact is safe. It displays the debt; it does not grandfather, exempt, or relabel it complete.

Physical mutation paths are narrowly owned:

1. Onboarding/Data Update/Operating may preserve newly referenced payloads only under their exact current typed mutation tenure.
2. Attachment Archive Repair may copy one displayed, human-confirmed, coherent batch of no more than 75 source-available payloads.
3. Record-backed recovery may restore only evidence-backed payloads under its typed recovery action.
4. Archive adoption may bind an existing archive only through its separate, currently development-authorized root/UUID gate.
5. Archive location/relocation/recovery may act only through existing typed location/journal/lease actions and explicit user authorization.

All paths require containment, regular-file/source checks, no-overwrite/integrity behavior, coherent archive instance/generation, and callback-local capability tenure. No cutover step may adopt, relocate, bulk-copy, fallback to another archive, or mutate payloads merely to make assessment green.

External bookmark restoration and volume availability are facts. A disconnected volume must not silently select an internal fallback. An interrupted relocation journal or retained source is operation evidence to be handled by the owning recovery path, not an invitation for startup cleanup.

## 18. Destructive repair, Start Fresh, and historical-source distinction

Local Data Repair has one executable class: `rebuildableLiveOnlyPartial`. Its proof requires, together:

- stable current Messages source;
- source-scope and binding equality;
- source-scoped import-schema anti-difference/provenance proof;
- required current source facts present;
- graph empty/incomplete in the exact reconstructible shape;
- no protected non-live or historical sources;
- no retired/unsupported/corrupt material;
- Contacts reconstruction prerequisite when needed;
- the current exact safety observation and one `localDataRepair` Ball.

The action deletes only the enumerated rebuildable import/graph stores and verifies the physical postcondition before restart. It does not delete overlay, Presence, archive, marker/UUID, bookmark/configuration, historical registry, or user preferences.

Corrupt, retired, unknown, historical, protected, missing-source, or binding-mismatched cases remain Diagnostic. There is no “probably rebuildable” branch.

Start Fresh is a different explicit advanced user command. It intentionally rebuilds selected derived message/conversation data while preserving user-authored and archive state. Historical-source removal is another separate explicit command over provenance data. Their current legacy presentation may be the only product route to those commands. A future production AppCzar Operating/settings surface must retain or deliberately reauthorize those commands before legacy UI is retired. Neither command may be imported into Local Data Repair, triggered automatically, or removed by accident.

## 19. Diagnostic Review design and coverage gap

Diagnostic Review captures the completed AppCzar assessment generation once, projects bounded factual cards, and does not continuously refresh. It does not read evidence again, hold a mutation Ball, execute a repair, automatically retry, or delegate to Journey. “Try Assessment Again” means stop/drain and one real process restart; Quit exits without a replacement.

The UI can expose technical paths, counts, schema errors, and bounded reasons needed to explain the jurisdiction. Production activation therefore needs a privacy review of copied/exported diagnostics and path disclosure. Diagnostic currently does not inherit the legacy support exporter; that is safer than silently coupling it, but support/export parity must be designed explicitly.

Coverage remains:

```text
Diagnostic Review human live qualification:
    PASS — REVISED BOUNDED SCOPE

Genuine Messages-source UNKNOWN human live qualification:
    NOT EXERCISED

All original Prompt 83 classes human live-qualified:
    NO
```

Automated tests cover all 22 Diagnostic frontiers, frozen generation, no reread, no mutation, one restart, and Quit. For the first later disposable production-identity rehearsal, automated coverage plus the bounded human PASS is acceptable only if the rehearsal itself cannot touch real data and unknown remains fail-closed. Before actual production activation, the gap must be explicitly reviewed; a further safe constrained observation is preferable if one can be produced without an unsafe injector. The existing stop gate remains in force.

## 20. Production signing, bundle, TCC, entitlement, and update path

The macOS project specifies the production bundle `com.bigbenchsoftware.MessageLens`, product `MessageLens`, Developer ID Application signing, team `FQHT2QP3NE`, hardened runtime, and non-sandboxed entitlements appropriate to the existing architecture. The development product/bundle are separate. Release documentation requires keeping the production bundle identifier and release signing identity stable so macOS Full Disk Access grants can carry across shipped builds.

Source cannot prove that a particular machine's TCC database will preserve FDA after an update. That requires an installed, correctly signed/notarized artifact and human observation. VS Code/direct development launches are not substitutes: their binary identity, path, signing, and TCC behavior differ.

The current restarter opens the exact current app bundle derived from the executable, which is preferable to looking up a product name. A future production seam must preserve that property and validate the admitted production identity. It must not launch `MessageLens Development.app`, an older installed copy, or a build in another worktree.

Distribution/notarization remains governed by the release pipeline; this audit did not execute it. The production process lock prevents a second writer for the same admitted root, but installation replacement while a process is running, OS “Quit & Reopen” prompts, launch failure, and competing signed builds require staged human qualification.

## 21. Recovery, rollback, backups, and schema compatibility limitations

No production backup or restore was performed. Before actual production authorization there must be a separately approved, verified recovery method that covers the admitted root, overlay, Presence, archive marker/UUID/configuration, journals/receipts, and any external attachment root without casually copying live WAL-backed databases.

Rollback has two independent layers:

- **composition rollback:** keep a source-controlled activation switch/release gate capable of routing a still-compatible binary back to legacy startup;
- **binary rollback:** reinstall a previously signed/notarized production binary only if every database and metadata schema remains readable by that binary.

The second is not guaranteed. Once a newer binary migrates overlay, Presence, import, graph, or configuration schema, an older binary may be unsafe. No plan may “roll back” by restoring stale derived/user databases over newer live state. Every future migration must declare forward and backward compatibility, backup preconditions, and a version gate that fails closed before opening an unsupported store.

Coordinator journals and receipts provide operation recovery, not whole-installation rollback. Attachment payload mutations are preservation actions and cannot be undone by replacing databases. Production rollout therefore needs a release-specific recovery matrix and human stop gate.

## 22. Startup performance and offline/failure containment

AppCzar assessment uses bounded specialist reads: root/identity facts, initial-scope inventory, source count/high-water and two-sample stability, database health/schema/counts, graph topology/FTS-related evidence, overlay condition, archive availability/binding/generation, attachment coverage/actionability when graph facts permit, Contacts only when the selected scope needs it, and Local Data Repair safety only for consequential partial data.

Known bounds include two source samples, one bounded retry on mismatch, one assessment generation per occurrence, non-overlapping 15-second Operating cycles, and maximum 75-item human archive-repair batches. A coverage-complete fast path avoids re-reading every source attachment path solely to prove no repair opportunity.

Not measured for an actual production-root deployment:

- startup latency with the real production database sizes and storage medium;
- worst-case read-only health/FTS/topology checks;
- the 18K+ required-attachment universe under production disk/volume conditions;
- external-volume disconnection during an evidence read;
- slow or unavailable network-backed external media;
- FDA/TCC prompt and denial timing in a signed production process;
- migration time from every historical schema;
- detached restarter launch failure and process-lock contention;
- user-visible timeout/cancel/recovery behavior for a probe that never returns promptly.

Current screens remain responsive enough to show restricted assessment progress in qualified development cases, but screenshots also recorded long spinner intervals. Production hardening should add per-probe timing/timeout/failure classification, cancellation on drain, and privacy-safe diagnostics without converting timeouts to false facts.

Offline or unavailable resources must remain `UNKNOWN` or the exact known unavailable state. They must not be interpreted as empty, resettable, complete, or repaired.

## 23. Repository-wide tests and missing categories

| Area | Existing source-verified coverage | Missing before activation / rehearsal |
|---|---|---|
| Static architecture | forbidden imports, one semantic owner, read-only assessment infrastructure, exact mutation edges, no generic dispatcher | production AppCzar shell reachability proving all Journey/ambient updater edges absent |
| Coordinator census | explicit host branches and all seven owners | production composition host census under inactive/active selector states |
| Startup selection | development official identity admitted independent of physical dev root; production remains legacy | production eligibility, activation default-off, and exact identity/signature mismatch tests |
| Canonical root/identity | native/Dart canonicalization vectors, marker/root identity, production override rejection | installed production-like root and process-lock rehearsal |
| Fact logic | evaluator TRUE/FALSE/UNKNOWN frontiers, precedence, source denial/unknown, attachment debt/actionability, corrupt/protected cases | production-like fixtures spanning every supported historical schema and journal/config combination |
| Process restart | development old/new PID boundary for qualified coordinators and Diagnostic | production identity-constrained restarter tests and signed installed-app human rehearsal |
| Operating currentness | 15-second cadence, no overlap, same-session update/navigation, attachment reread, cross-jurisdiction restart | proof that legacy monitor/importer is absent in production AppCzar shell; production TCC/volume loss |
| User intent | overlay/graph separation architecture tests; reset preservation assertions | upgrade/migration tests with real-shaped overlay, Presence, preferences, bookmarks, registry |
| Migrations | individual database migration tests and schema constants | whole-root version matrix, WAL/SHM, partial migration interruption, old-binary compatibility gates |
| Diagnostic | all 22 automated frontiers, frozen/no-reread/no-mutation, restart/Quit; revised human PASS | genuine source-UNKNOWN human-live qualification if safely possible; support/privacy review |
| Packaging/signing | static Xcode/release configuration | build, codesign/notarization verification, FDA continuity, update and rollback human rehearsal |
| Negative/protected cases | Local Data Repair four-class matrix, repair stale binding/conflict/unknown tests | production-root analogues, external filesystem permission/read-only/disconnect matrix |

No tests were run for this audit. Existing recorded test results remain evidence for their checkpoints; this response does not refresh them.

Tests required before production route activation include: selector default-off and exact production eligibility; no AppCzar before archive authority; adoption gate independence; production shell import/reachability; one currentness writer; neutral navigation/settings/explicit-command ownership; production restarter/quit; whole-root migration fixtures; startup provider non-creation; protected-state preservation; external archive loss/read-only/moving; failure/timeout containment; and rollback version gating.

Separately authorized staged human tests are required for signed product identity, FDA continuity, installed-app restart/Quit, process lock, first-run/upgrade roots, external-volume interruption, packaging/notarization/update, and recovery procedures.

## 24. Future dependency-ordered implementation stages

### Stage 1 — inactive production composition eligibility seam

Scope: generalize the already-admitted official-app composition decision so exact production identity can be recognized as *eligible*, while a separate production activation remains false by default. Keep `_selectMessageLensStartupPresentation()` routing production to `StartupApp`. Add static/selector tests. Do not add restart, mutation, migration, or UI behavior.

Stop gate: any design that evaluates before `ArchiveAccessAuthority`, consults a physical root/UUID as the global selector, or broadens an operation gate.

Recovery anchor: one narrow source/test commit; production behavior unchanged.

### Stage 2 — production-safe shell dependency closure

Scope: identify and rewire normal Operating capabilities: neutral navigation restoration, settings, support/export, Start Fresh and historical-source commands, while eliminating ambient Journey/currentness/import authority from the AppCzar shell. Keep production activation false.

Stop gate: any shared widget/provider implicitly watches Journey or starts a second updater.

### Stage 3 — production identity-constrained restart/Quit

Scope: implement a production restarter authorized only by admitted production AppCzar composition, exact current bundle, current PID, and root/process identity. Keep production activation false. Test old-PID exit, detached launch failure, single flight, exact bundle, and no cross-launch.

Stop gate: inability to bind the exact installed bundle or to fail closed without a loop.

### Stage 4 — whole-root migration and preservation qualification

Scope: disposable production-shaped fixtures for virgin, healthy established, source denied/ahead, historical, corrupt, retired, external archive unavailable/read-only/moving, journals, overlay, Presence, preferences, bookmarks, and schema upgrades. Verify assessment creates nothing and selected workers preserve protected state.

Stop gate: unsupported schema, implicit provider creation/migration before classification, or unverifiable rollback.

### Stage 5 — legacy authority retirement readiness

Scope: remove/demote legacy semantic providers only after reachability tests prove no AppCzar production consumer remains. Preserve operation evidence/history and explicit user commands. Production activation still false until review.

Stop gate: any required product command or support/recovery path exists only in the removed tree.

### Stage 6 — disposable production-identity-aware rehearsal

Scope: a separately authorized signed/staged artifact and disposable non-real-data root. Exercise admission, first assessment, each safely constructible jurisdiction, restart/Quit, process lock, update, external-volume failure, and reinstall/update identity. Never point at the real production root.

Stop gate: TCC identity ambiguity, another production process, any real-root resolution, or inability to restore the staged artifact.

### Stage 7 — backup/recovery and rollout plan

Scope: verify a live-consistent, user-approved production backup/recovery procedure; declare schema compatibility and rollback gates; prepare release/notarization and observability plan. No cutover yet.

### Stage 8 — explicit actual-production go/no-go

Scope: human review of all evidence, exact installed artifact hashes/signature, root/marker identity, backup, stop/rollback plan, and permissions. Only a new explicit authorization may activate production AppCzar.

The stages must remain separate checkpoints. A giant selector-plus-retirement-plus-release change is not acceptable.

## 25. Future disposable and staged human qualification

The first production-identity-aware rehearsal is not ready today. Its preconditions are Stages 1–4: inactive selector seam, closed shell dependencies, production restarter, and whole-root fixture coverage.

When ready, use a disposable absolute root with a marker/UUID produced by the approved fixture builder, a signed product whose identity is intentionally distinguishable from the real installed production app unless macOS/TCC semantics require an explicitly isolated machine/account, and manifests before/after every case. Required observations include:

- archive admission precedes AppCzar;
- one process lock owner;
- exact production-like identity selects AppCzar only under the rehearsal activation;
- no real production or development root is resolved;
- each selected owner matches fresh evidence;
- protected files and payloads remain byte-identical unless the exact case authorizes one bounded mutation;
- restart yields a distinct PID and fresh assessment;
- Quit yields no replacement;
- update/reinstall preserves intended TCC identity when applicable;
- failed launch, disconnected archive, and unsupported schema fail closed.

Genuine source `UNKNOWN` should be included only if a safe, truthful fixture or system boundary can produce it. Otherwise record the automated-only gap again and stop rather than inject a false condition.

## 26. Future actual-production human-authorization gate

No actual production action may begin until a new prompt identifies and a human confirms:

- exact release commit, artifact hash, bundle ID, team/signing certificate, notarization result, entitlements, and installed path;
- production process quiescence and single-instance status;
- exact admitted production root/marker/UUID by an authorized preflight mechanism;
- live-consistent backup and independently tested recovery procedure;
- schema/version compatibility and rollback limits;
- external attachment archive/location/bookmark status without changing it;
- FDA/TCC plan and human-visible OS prompts;
- go/no-go owner, stop conditions, observation window, and rollback/recovery decision tree;
- explicit authorization to activate production AppCzar.

That future authorization must not authorize attachment adoption, relocation, reset, or cleanup unless separately enumerated.

## 27. Ranked unresolved risk register

| Rank | Gate | Affected authority/resource | Observed fact | Unknown / potential impact | Minimum safe closure | Prevents |
|---:|---|---|---|---|---|---|
| 1 | BLOCKER | production semantic owner | production currently mounts `StartupApp`; no production AppCzar selector exists | direct cutover would be an unreviewed architecture change | inactive eligibility/activation seam and tests | rehearsal and cutover |
| 2 | BLOCKER | process lifecycle | current restarter is development-authorized only | production restart could fail, cross-launch, duplicate, or loop | exact production restarter/quit implementation and tests | rehearsal and cutover |
| 3 | BLOCKER | sole semantic/currentness owner | legacy Journey consumers and `chatDbChangeMonitorProvider` remain reachable in shared normal shell | double updater/writer or contradictory state | production AppCzar shell reachability closure | rehearsal and cutover |
| 4 | BLOCKER | user commands/support | Start Fresh, historical removal, support/export, navigation/settings have legacy presentation dependencies | commands could disappear or reintroduce Journey authority | explicit neutral rewiring with authority tests | cutover; some paths block rehearsal |
| 5 | BLOCKER | protected databases | whole-root upgrade/migration compatibility not qualified | silent migration, discard, or old-binary incompatibility | disposable schema/version matrix and fail-closed gates | rehearsal and cutover |
| 6 | BLOCKER | signing/TCC/install | no signed production AppCzar artifact has been installed/restarted | FDA loss, wrong binary, OS modal, process collision | staged signed production-identity-aware rehearsal | actual cutover |
| 7 | BLOCKER | recovery | no release-specific verified production backup/restore and rollback matrix | irreversible user/overlay/archive loss or unusable rollback | authorized backup/recovery rehearsal and schema gates | actual cutover |
| 8 | BLOCKER | production data diversity | no real-root inspection authorized and production-like cases are incomplete | historical/retired/journal/external combinations may select unexpectedly | expanded disposable production-shaped fixtures | rehearsal and cutover |
| 9 | SHOULD FIX / FUTURE QUALIFICATION | Diagnostic source evidence | genuine Messages-source UNKNOWN not human-live-qualified | user-facing behavior seen only in automated tests | safe constrained observation if feasible; otherwise explicit rollout risk acceptance | actual cutover review, not narrow seam |
| 10 | SHOULD FIX | startup performance | long spinner intervals and 18K+ attachment scans not production-measured | poor startup, apparent hang, volume churn | timings, bounds/timeouts/cancellation, production-shaped performance fixture | cutover |
| 11 | SHOULD FIX | diagnostic privacy/support | AppCzar Diagnostic has technical details but no legacy exporter parity | sensitive paths or inadequate support evidence | privacy-reviewed bounded exporter/design | cutover quality |
| 12 | SHOULD FIX | navigation/session UX | neutral restoration differs between legacy and development AppCzar | lost selection/preferences after restart | AppCzar-owned restoration tests | cutover quality |
| 13 | FUTURE QUALIFICATION | OS/filesystem edge cases | volume loss, read-only media, TCC prompts, launch failures are partly automated/development-only | OS-version-specific behavior | staged matrix on supported macOS versions | actual cutover |
| 14 | FUTURE QUALIFICATION | rollback observation | zero-PID interval was inferred, not directly observed in one Diagnostic run | limited forensic certainty | process-log/instrumented staged restart | actual cutover evidence |

## 28. Readiness for the next narrow implementation

YES. The source architecture supports a small, reviewable, behavior-inactive change: recognize exact already-admitted production identity as eligible for an AppCzar composition while leaving production activation false and legacy routing unchanged. That step can add tests for ordering and separation without touching a root, app installation, restarter, database, archive, or permission.

This readiness does not imply readiness to turn the selector on.

## 29. Readiness for staged production-identity rehearsal

NO. The production restarter does not exist, the production AppCzar shell still has unresolved legacy/currentness dependencies, the whole-root migration matrix is incomplete, and no staged signed artifact/recovery plan is qualified.

## 30. Readiness for actual production cutover

NO. Production still selects legacy startup by design. Cutover has not been implemented or authorized. Signing/TCC/update behavior, backup/recovery, schema rollback, external archive cases, and actual production human preflight remain open.

## 31. Project Conformance audit/design verdict

`PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)`

The proposed staged design preserves:

- one semantic owner per composition;
- archive admission before composition choice;
- immutable admitted root/identity;
- strict development/production identity separation;
- operation-specific root/UUID/Ball authority independent from composition eligibility;
- no move, replacement, adoption, reset, or payload mutation at cutover;
- no protected historical, overlay, Presence, or attachment deletion;
- current bounded evidence rather than restored Journey conclusions;
- real process restart and fresh assessment when launch facts change;
- callback-local typed mutation tenure;
- no duplicate updater/worker before activation;
- no production routing change in Prompt 85;
- explicit retention of the genuine-source-UNKNOWN live gap.

The verdict applies to the audit and proposed dependency order. It is not a verdict that the current repository is ready for production activation.

## 32. BLOCKER findings

1. Production has no inactive eligibility/activation seam and still selects legacy startup.
2. The only AppCzar process restarter is intentionally development-only.
3. Legacy Journey/environment consumers and the generic ambient chat-db monitor are not yet proven unreachable from a future production AppCzar shell.
4. Required normal-product commands and support/navigation capabilities still depend on legacy presentation or providers.
5. Whole-root migrations, historical schemas, retired files, WAL/SHM, journals, and old-binary compatibility have not been qualified as one production-like system.
6. Signed/notarized production identity, FDA continuity, install/update, process-lock, restart/Quit, and OS modal behavior have not been rehearsed.
7. Production backup/recovery and schema-aware rollback are not established.
8. Production-shaped first-run, established, historical, corrupt, and external archive scenarios are not yet exhaustive.

## 33. SHOULD FIX findings

1. Add probe timing, timeout/cancellation, and bounded failure telemetry; long all-spinner windows need a truthful restricted-state UX.
2. Measure startup and attachment-actionability cost with production-shaped, non-real data, including an 18K+ required-payload universe.
3. Design a privacy-reviewed AppCzar support/export report without importing Journey authority.
4. Restore navigation/preferences under an AppCzar-owned neutral session boundary.
5. Instrument the later staged restart to observe old PID exit, launch attempt, new PID, and process-lock acquisition directly.
6. Seek a safe human observation of genuine source `UNKNOWN` if possible; otherwise retain the explicit automated-only limitation.

## 34. Untouched source, build, and real-data assertions

During this audit:

- no production, development, test, generated, native, entitlement, release, or packaging source was edited;
- no release metadata was edited;
- no tests, analyzers, code generators, builds, installers, notarization tools, or launch commands were run;
- no MessageLens process was launched, debugged, terminated, or reconfigured;
- no Full Disk Access, TCC, bookmark, preference, launch flag, or environment variable was changed;
- no real production/development MessageLens SQLite database was opened or queried;
- no Apple Messages or Contacts database was opened or queried;
- no WD or Toshiba archive was scanned;
- no attachment payload, archive marker, UUID, location configuration, journal, receipt, or database was copied, moved, deleted, reset, migrated, or changed;
- no branch was switched, merged, rebased, squashed, or force-pushed.

The only repository write made by the audit is this untracked Response 85 record, as authorized. The only external write is the read-only provenance manifest under `/private/tmp`.

## 35. Final Git, worktree, and submodule state

Final state after creating this response:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream: `bef7f2bf94c46c0322a49418a3431f7ef16fd6cd` / same;
- ahead/behind: `0/0`;
- tracked worktree: clean;
- index: clean;
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`;
- registered worktrees: the four recorded in Section 1;
- Feature 34 worktrees: exactly one;
- Prompt 85 and Response 85: untracked and unstaged for review;
- all pre-existing unrelated untracked paths: untouched.

The known unrelated untracked paths remain the existing `.vscode/settings.json`, screenshot, Feature 26/30/31 prompt/response artifacts, Feature 34 `00-PREPARATION/`, and `message_lens_S3_backup_updated.zsh`, together with Prompt 85 and this Response 85.

## 36. Recommended exact next narrow prompt

Recommended title:

`86-IMPLEMENT-PRODUCTION-APPCZAR-COMPOSITION-ELIGIBILITY-SEAM-WITHOUT-ACTIVATING-PRODUCTION.md`

Recommended scope:

1. start from the reviewed Prompt 85/Response 85 checkpoint;
2. add a typed policy that evaluates only an already-admitted `ArchiveAccessAuthority` and recognizes exact official production environment/build/bundle/product/signature as *eligible* for AppCzar;
3. retain the existing development composition behavior;
4. add a separate production activation input whose production default is `false`;
5. keep `_selectMessageLensStartupPresentation()` selecting legacy startup for production while activation is false;
6. prove with tests that no composition policy runs before archive admission, no physical root/UUID selects the global architecture, and `attachmentArchiveAdoptionExecutionEnabledProvider` remains absent from composition logic;
7. make no restarter, coordinator, database, archive, UI, signing, entitlement, release, or installed-app change;
8. stop for human architectural review before any production activation or staged artifact work.

DIAGNOSTIC REVIEW HUMAN QUALIFICATION CHECKPOINTED: YES
DIAGNOSTIC REVIEW GENUINE SOURCE UNKNOWN HUMAN LIVE QUALIFIED: NO
ALL SEVEN APPCZAR JURISDICTIONS HAVE EXECUTABLE DEVELOPMENT OWNERS: YES
PRODUCTION CURRENTLY SELECTS LEGACY STARTUP: YES
PRODUCTION APPCZAR CUTOVER HAS BEEN IMPLEMENTED: NO
PRODUCTION ROOT/IDENTITY AND MUTATION AUTHORITY REMAIN SEPARATE: YES
LEGACY SEMANTIC AUTHORITY ELIMINATION IS FULLY AUDITED: YES
PRODUCTION RESTART/QUIT PATH IS QUALIFIED: NO
PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)
READY FOR NEXT NARROW PRODUCTION-CUTOVER IMPLEMENTATION: YES
READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
