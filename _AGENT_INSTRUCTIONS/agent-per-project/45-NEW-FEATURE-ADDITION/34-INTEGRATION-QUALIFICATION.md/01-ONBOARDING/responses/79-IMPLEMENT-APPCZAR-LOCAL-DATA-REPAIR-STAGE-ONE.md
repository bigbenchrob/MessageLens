# MessageLens Feature 34
## Response 79 — Implement AppCzar Local Data Repair Stage One

Date: 2026-10-07

## 1. Baseline verification

Work began in the primary worktree on
`fix/onboarding-import-stuck-state`. HEAD and upstream were synchronized at
`1af1c53a8264cfc87a63eaeaf4e46136e877247a`; the tracked worktree and index
were clean after the required Prompt/Response 78 checkpoint. Prompt 77 commit
`3fd20ffd2d26a0305e92948bf7b1c5cada0c9798` was in ancestry. The shared
instructions submodule was clean at
`95326f515ef4719f155ce6e223990398daad6311`, and the primary worktree was the
only Feature 34 worktree.

The external baseline manifest is
`/private/tmp/messagelens-prompt79-baseline-20261007.md`, SHA-256
`73f3f311fb60506a5c67758891b7cfef9a7e16197bee5f389913d15f4a7dbda9`.

## 2. Prompt 78 / Response 78 documentation checkpoint

Prompt 78 and Response 78 were checkpointed alone and pushed as:

`1af1c53a8264cfc87a63eaeaf4e46136e877247a docs(onboarding): audit local data repair`

That checkpoint records Onboarding human qualification PASS, Local Data Repair
VIRTUAL ONLY, five implementation blockers, zero unresolved SHOULD FIX
findings, and production cutover NOT YET.

## 3. Pre-change execution census

- Data Update: executable top-level coordinator.
- Source Access Repair: executable top-level coordinator.
- Attachment Archive Repair: executable top-level coordinator.
- Onboarding: executable top-level coordinator.
- Operating Session: executable admitted session.
- Local Data Repair: virtual only.
- Diagnostic Review: virtual only.

## 4. Response 78 controlling findings

The five controlling gaps were: no schema-wide reconstructibility witness;
corrupt/unsupported evidence could reach the repair frontier; no caller-held
Local Data Repair mutation operation; no strict physical postcondition; and
unclassified retired files were included in broad reset mechanics. Stage One
therefore implements only `rebuildableLiveOnlyPartial`, automatically after a
fresh TRUE proof. All protected, retired, divergent, corrupt, or unknown
classes remain non-mutating.

## 5. Repair-safety observation design

`AppCzarLocalDataRepairSafetyObservation` is current, snapshot-free, read-only,
and bound to the admitted root, archive instance UUID, attachment archive scope
identity/generation, source fingerprint, evidence fingerprint, exact reset
footprint, and consequential row counts. The SQLite reader runs off the UI
isolate, opens sources read-only, uses bounded pages, and is shared by the
AppCzar observation path and the executor's immediate revalidation.

## 6. Exact repair-class taxonomy

The typed conditions are:

- `rebuildableLiveOnlyPartial`: the sole executable class;
- `protectedMaterialPresent`: known protected/non-live or graph material;
- `sourceFactMissing`: known current-source anti-difference;
- `retiredArtifactsPresent`: explicitly named but unclassified residue;
- `unsupportedOrCorrupt`: local evidence cannot support the safe class;
- `unknown`: unavailable, unstable, or insufficient evidence.

Only the first condition can make `mayResetDerivedStores` TRUE.

## 7. Schema-wide reset-footprint inventory

The exact active physical footprint is `macos_import_ss.db` and
`working_ss.db`, including their WAL/SHM sidecars. The import proof inventories
the exact schema tables: source registry, import batches, messages, handles,
chats, chat-message joins, chat-handle joins, contacts, contact channels,
attachments, and message-attachment joins. Retired databases are outside the
Stage One deletion footprint.

## 8. Schema-wide reconstructibility algorithm

The algorithm validates archive binding, rejects retired artifacts, proves the
graph empty for this narrow class, verifies exact import/source schemas,
captures stable source evidence, validates exact live source inventory,
foreign keys, lineage, packed identities, and relationship targets, then runs
paged local-minus-current-source comparisons for every source-backed domain.
It repeats source/import/graph stability observations before publishing one
aggregate TRUE result. Any known anti-difference is FALSE; any unreadable or
unstable evidence is UNKNOWN.

## 9. Messages-domain comparison

Messages are compared in deterministic pages using the strongest existing
stable identity pair, source ROWID plus GUID. A missing current source row or
identity difference produces `sourceFactMissing`; unreadability or source
change produces UNKNOWN. Count or MAX(ROWID) is never used as deletion
authority.

## 10. Chat, handle, and relationship comparison

Handles use source ROWID plus handle ID; chats use source ROWID plus GUID.
Chat-message rows compare join ROWID, chat ID, and message ID. Chat-handle rows
compare the exact source pair. Local target existence, packed identity, and
lineage checks precede source comparison.

## 11. Attachment metadata and join comparison

Attachment metadata uses source ROWID plus GUID. Message-attachment joins use
the exact message/attachment source IDs. The proof reads metadata only; it does
not scan payload bytes or traverse the durable attachment archive.

## 12. Contacts and enrichment comparison

The exact current AddressBook database selected by the typed Contacts
prerequisite is opened read-only. Contact names, organization, projected
creation time, and normalized email/phone channel facts are compared against
the same extracted projection helpers used by the importer. Invalid, absent,
or unstable required Contacts evidence fails closed.

## 13. Source registry, ledger, and provenance comparison

The source registry must contain exactly the canonical live Messages and live
AddressBook identities. Import batches and every destructive-domain row must
have the expected live lineage. Foreign-key, packed-key, and relationship
target checks make contradictory ledger evidence non-executable.

## 14. Graph reconstructibility proof

Stage One conservatively requires the current graph to contain no
consequential rows. A nonempty graph, unsupported schema, or unreadable graph
blocks repair. The graph is inspected again after the import/source proof so a
change during observation becomes UNKNOWN. This avoids claiming a graph fact
is derived when that proposition has not been independently proved.

## 15. Boundedness and performance

All row comparisons use deterministic 200-row pages or bounded indexed
existence queries; no unbounded key corpus, rich-text blob corpus, archive
payload scan, or archive traversal is used. The 450-message multi-page fixture
passed. The complete ten-test safety-reader file, including a deliberate
two-second source-instability observation, completed in 4.15 seconds wall time
on this machine.

## 16. Protected non-live / historical rule

Any noncanonical or non-live source identity, batch, or row lineage makes
whole-store automatic reset unavailable. Local Data Repair never invokes or
borrows historical-source removal authority.

## 17. Corrupt / unsupported UNKNOWN rule

Unreadable or unstable sources produce UNKNOWN. Unsupported/corrupt local
stores are non-executable and route to Diagnostic Review; reset is never used
to discover their contents.

## 18. Retired-artifact rule

Presence of `macos_import.db`, `working.db`, or their sidecars produces
`retiredArtifactsPresent`. Stage One neither classifies nor deletes them. The
Local Data Repair lower reset entry point explicitly excludes retired cleanup
files.

## 19. Exact repair-safety proposition

TRUE requires the narrow selected class, complete archive/root binding, exact
known reset footprint, consequential derived facts, canonical live-only
inventory, readable and stable current sources, schema-wide anti-difference
success, an empty/derived graph boundary, and no corrupt, unsupported, retired,
protected, conflicting, or unknown evidence.

## 20. AppCzar frontier / evaluator change

AppCzar gained one read-only fact,
`localDataRepairMayResetDerivedStores`. Consequential incomplete state selects
Local Data Repair only when that fact is TRUE. Protected, unhealthy,
unsupported, retired, false, and unknown cases select Diagnostic Review.
AppCzar itself performs no mutation.

## 21. Pre-mutation revalidation and binding

The executor performs a fresh safety read before Ball acquisition, requires an
exact binding match with the selected observation, checks that the occurrence
is still admitted, and rechecks archive scope identity/generation inside the
capability callback. Any mismatch returns stale evidence and triggers drain and
restart for fresh AppCzar assessment without mutation.

## 22. Mutation-operation type

`ArchiveMutationOperation.localDataRepair` is the new explicit typed operation.
`MessageDataResetService` requires that capability for its Local Data Repair
entry point.

## 23. One-Ball authority path

There is exactly one `runWithCapability(localDataRepair)` edge, owned by the
specialist executor. The lower reset mechanics receive the callback-local
capability and do not acquire a nested tenure or self-authorize.

## 24. Consent-policy implementation

Response 78 chose automatic repair only for the freshly proved
`rebuildableLiveOnlyPartial` class because confirmation cannot make UNKNOWN
safe. No consent is persisted, and no other class can mutate.

## 25. Start Fresh separation

Local Data Repair does not import Journey, Advanced Start Fresh, Start Fresh
presentation, or Start Fresh semantics. It calls only the narrow active-derived
lower reset mechanics and then restarts for fresh AppCzar ownership.

## 26. Historical-source-removal separation

The coordinator has no historical removal import, operation, or handoff.
Historical/non-live evidence blocks automatic whole-store reset.

## 27. Reset lower-mechanics reuse / extraction

`MessageDataResetService` now has a capability-requiring
`resetActiveDerivedDataForLocalDataRepair` entry point. It reuses database
closure, explicit active-file deletion, provider invalidation, and reopening
mechanics, but passes `includeRetired: false` and requires the physical proof
boundary.

## 28. Physical reset-postcondition design

Before deletion, the filesystem store records SHA-256-backed top-level evidence
for every entry outside the exact active database families. After deletion it
requires every active base/WAL/SHM target to be absent and the complete
preserved top-level evidence map to match exactly. A surviving target or any
collateral change is a terminal failure.

## 29. Exact preservation assertions

Tests prove preservation of `user_overlays.db`, `presence.db`, archive marker
and UUID evidence, attachment configuration, attachment archive directory and
payload sentinel, retired artifacts, unrelated root sentinels, and external
Messages/Contacts/historical donor fingerprints. The archive is not recursively
hashed.

## 30. Success terminal

Successful lower reset plus physical postcondition returns through the one
capability, releases Ball, closes action admission, and requests one real
restart. It does not claim semantic repair success or hand off to Onboarding in
the same process.

## 31. Mutation / postcondition failure terminal

If mutation may have begun, reset or postcondition failure causes no in-process
retry and no success claim. The controller drains, allows Ball release, and
restarts for fresh disk-grounded AppCzar assessment. A pre-mutation refusal is
reported factually and performs no deletion.

## 32. `stopAndDrain()` behavior

Ordinary exit closes admission synchronously, advances publication generation,
suppresses stale callbacks, and awaits the exact active proof/mutation future.
It does not schedule a restart. Repair class, proof, progress, and consent do
not survive process death.

## 33. Presentation semantics

The Local Data Repair screen uses literal phases: revalidating current repair
safety, resetting the exact two active derived stores, restart requested, and
factual failure. It does not claim interruption history, disposability before
proof, zero-loss, semantic success, or a future Onboarding outcome.

## 34. Development host integration

The development AppCzar coordinator host has one explicit Local Data Repair
branch and one lifecycle host that drains on exit. No generic coordinator
dispatcher was introduced. Production composition remains legacy and
unchanged.

## 35. Post-change execution census

- Data Update: executable top-level coordinator.
- Source Access Repair: executable top-level coordinator.
- Attachment Archive Repair: executable top-level coordinator.
- Onboarding: executable top-level coordinator.
- Local Data Repair: executable top-level coordinator.
- Operating Session: executable admitted session.
- Diagnostic Review: virtual only.

## 36. Reconstructibility focused tests

Disposable tests cover the exact one-message partial fixture, source deletion,
unreadability, mid-proof source change, the 450-row paged case, exact schema
inventory, attachment anti-difference, Contacts projection, graph blocking,
and retired residue. All passed.

## 37. Protected-source tests

Non-live source inventory, contradictory lineage, unknown inventory, retired
artifacts, graph-only facts, and unavailable source evidence all prevent TRUE
repair authority. All passed.

## 38. Reset-postcondition tests

Tests cover active bases and WAL/SHM deletion; overlay, Presence, marker,
configuration, archive payload, retired file, unrelated sentinel, and external
source preservation; surviving-target failure; collateral-change failure; and
same-size preserved-content change detection. All passed.

## 39. Authority and lifecycle tests

Tests prove exact-disposition admission, fresh revalidation before mutation,
stale binding refusal, archive rebinding refusal, one released typed tenure,
post-admission restart, pre-mutation no-restart failure, ordinary drain without
restart, stale publication suppression, and factual/retryable restart failure.
All passed.

## 40. Safety-class tests

The executable live-only class, protected material, missing source fact,
retired residue, unsupported/corrupt evidence, and UNKNOWN evidence are covered
in reader/evaluator/controller tests. Only the exact live-only class executes.

## 41. Existing coordinator regressions

The focused AppCzar, Onboarding, reset, and specialist regression set passed
129 tests. The full deterministic suite also covered Data Update, Source Access
Repair, Attachment Archive Repair, Operating Session, and archive authority /
composition behavior.

## 42. Historical-source and Start Fresh regressions

Start Fresh and Onboarding reset-service tests were updated only for the new
typed interface and passed. Historical workflow behavior remained unchanged
and passed in the full suite. Local Data Repair excludes retired and historical
deletion authority.

## 43. Architecture result

The AppCzar architecture and forbidden-import suites passed 424 tests. Their
census now enforces five executable top-level coordinators, one admitted
Operating session, virtual-only Diagnostic Review, one Local Data Repair
mutation edge, and separation from Journey, Start Fresh, historical removal,
and durable cursor state.

## 44. Analyzer result

`flutter analyze`: PASS, zero issues.

## 45. Full Flutter-suite result

`flutter test`: PASS, `+3102 ~1`, all tests passed (one existing harness skip).

## 46. Diff, format, and generated hygiene

`dart format` was applied to intended Dart files. Riverpod generation completed
successfully (`build_runner` wrote 26 outputs). `git diff --check` and
`git diff --cached --check` passed. No unrelated untracked artifact was staged.

## 47. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`. Destructive repair depends on current schema-wide
proof; provenance alone is insufficient; protected/unknown evidence fails
closed; AppCzar remains read-only; one specialist owns one typed Ball; the
allow-listed physical footprint and preservation postcondition are enforced;
Start Fresh and historical-removal semantics remain separate; and production
routing is unchanged.

## 48. BLOCKER findings

BLOCKER: 0. All five Response 78 implementation blockers are resolved for the
narrow Stage One class. No stop gate was encountered.

## 49. SHOULD FIX findings

SHOULD FIX: 0. No required conformance correction remains in this checkpoint.

## 50. Implementation checkpoint commit

`ceb12fef80b51c8cc340cca196d5e427419f084f`

Subject: `feat(startup): add source-grounded local data repair`

The commit contains 33 intended production, generated, test, architecture,
release-metadata, and changelog files. It was pushed normally.

## 51. Documentation checkpoint commit

Prompt 79 and this Response 79 form the narrow documentation checkpoint. Its
final commit hash is reported in the post-commit handoff because a commit
cannot contain its own hash.

## 52. Pushed recovery anchor

The Prompt/Response 78 recovery anchor is pushed at `1af1c53a`. The
implementation checkpoint is pushed at `ceb12fef`. The documentation
checkpoint is pushed normally after this response is committed; no force push,
rebase, or squash is used.

## 53. Exact build identity, path, and hashes

The exact artifact was built from implementation commit `ceb12fef` with
`flutter build macos --debug --no-pub` and was not launched.

- bundle path:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- product/display/executable: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- environment/build identity: `development` / `developmentDebug`
- version/build: `0.2.142 (160)`
- executable SHA-256:
  `639a3036283fb447402d2e10295d57b9a0d6feb2fdc110f0a927555b963d203a`
- `App.framework/App` SHA-256:
  `5b2fffe9e2f0bf9f62667ebc87b0f16e634932fd1f30a9f01c8da6e922e3346f`

## 54. Final Git / worktree / index / submodule state

At implementation checkpoint, HEAD and upstream were synchronized at
`ceb12fef80b51c8cc340cca196d5e427419f084f`; tracked worktree and index were
clean, with only Prompt 79 and known unrelated untracked artifacts remaining.
The shared-instructions submodule remained clean at
`95326f515ef4719f155ce6e223990398daad6311`. The exact post-documentation HEAD
and synchronization state are reported in the final handoff.

No real WD data root, Toshiba archive, real database, or real archive
configuration was accessed or modified. The development app was not launched.

## 55. Isolated Local Data Repair human-qualification readiness

**YES.** Automated implementation and qualification are complete. The next
task may use only fresh disposable fixtures for the four Prompt 79 classes. No
human live success is claimed yet.

## 56. Diagnostic Review milestone readiness

**NO executable milestone is included here.** Diagnostic Review remains the
truthful virtual destination for corrupt, unsupported, conflicting, or UNKNOWN
repair safety. A separate bounded design/implementation milestone is required.

## 57. Production AppCzar cutover readiness

**NO.** Local Data Repair still requires isolated human qualification, and
Diagnostic Review remains virtual. Production AppCzar routing was not changed.

`SCHEMA-WIDE CURRENT RECONSTRUCTIBILITY IS PROVEN BEFORE RESET: YES`

`LIVE PROVENANCE ALONE CAN AUTHORIZE LOCAL DATA RESET: NO`

`PROTECTED NON-LIVE/HISTORICAL DATA BLOCKS WHOLE-STORE RESET: YES`

`CORRUPT OR UNKNOWN REPAIR SAFETY FAILS CLOSED: YES`

`LOCAL DATA REPAIR USES EXACTLY ONE TYPED BALL TENURE: YES`

`RESET POSTCONDITION PROVES ONLY THE AUTHORIZED PHYSICAL FOOTPRINT CHANGED: YES`

`EXECUTABLE APPCZAR LOCAL DATA REPAIR IMPLEMENTED: YES`

`DIAGNOSTIC REVIEW REMAINS VIRTUAL: YES`

`PROJECT CONFORMANCE: PASS`

`READY FOR ISOLATED LOCAL DATA REPAIR HUMAN QUALIFICATION: YES`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`
