The Phase Two audit shows that `PRAGMA quick_check(1)` is overwhelmingly the remaining startup cost, but MessageLens cannot currently skip it on ordinary launches while honestly claiming to preserve the existing per-launch integrity guarantee.

The safe next step is a typed separation of bounded inspection from physical integrity validation, initially preserving current behavior. Moving the physical scan off the admission path requires either an explicit safety-policy change or additional durable validation/quarantine infrastructure.

No files or databases were changed during this audit.

## 1. Current validation flow

Stage One now calls `runApp` early and renders the restricted “Checking databases…” shell. The shell watches the installation-state provider at [main.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/main.dart:442).

The validation sequence is:

| Order | Operation | Scope and result | Cost characteristics |
|---:|---|---|---|
| 1 | Native archive claim and single-instance admission | Establishes environment, canonical root and process authority | Small; before Flutter |
| 2 | Archive marker/admission validation | Validates archive identity | Small; read-only except normal marker bootstrap rules |
| 3 | Legacy erase-journal compatibility | Usually only checks journal absence. If present, invokes the full evidence reader before `runApp` | Normally small; potentially full database cost |
| 4 | Installation provider starts | Obtains admitted root and invokes the SQLite reader | Asynchronous |
| 5 | Worker isolate starts | All database work runs through `Isolate.run` | Protects Flutter isolate, but does not limit duration |
| 6 | Overlay inspection | File existence/size, read-only open, `user_version`, `quick_check`, required-table inventory | Physical scan scales with DB size |
| 7 | Import inspection | Same checks, plus message count and non-live-source count | Import `quick_check` is the largest cost |
| 8 | Graph inspection | Same checks, plus message/chat/edge counts | Graph and FTS shadow storage are scanned physically |
| 9 | Presence inspection | Same checks with Presence required tables | Currently small |
| 10 | Retired-file inventory | Checks whether retired import/working files exist | Small filesystem metadata reads |
| 11 | Operation snapshot | Reopens the overlay read-only and parses the stored onboarding JSON | Small, but malformed JSON can escape as a provider error |
| 12 | Classification | Preservation/derived usability, message-count equality, topology presence, historical sources and operation snapshot | In-memory and effectively constant-time |
| 13 | Persistent initialization | Logger, normal database providers, window restoration and background services | Gated on successful classification |

The SQLite reader is at [sqlite_message_lens_installation_evidence_reader.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart:25). Each connection is opened with `OpenMode.readOnly`, sets `query_only`, and uses a three-second busy timeout.

Important current limitations:

- Required objects are checked only as tables. There is no expected-index validation.
- The required graph tables are `messages`, `chats`, and `chat_to_message`; the FTS table and triggers are not part of startup’s required-object list.
- “Exact reconciliation” currently means exact equality of the two gross message counts. It does not compare message identities or validate every relationship.
- Older schemas from version 1 through the current ceiling are accepted if the required tables exist. Normal provider opening may subsequently migrate them.
- `InstallationDatabaseEvidence.isUsable` conflates readability, schema support and full physical integrity into one Boolean at [message_lens_installation_state.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/domain/message_lens_installation_state.dart:44).

## 2. Cost and risk distribution

Existing real-startup instrumentation measured:

| Database operation | Total | `quick_check` |
|---|---:|---:|
| `user_overlays.db` | 66 ms | 32 ms |
| `macos_import_ss.db` | 7,079 ms | 7,063 ms |
| `working_ss.db` | 5,224 ms | 5,212 ms |
| `presence.db` | 147 ms | 3 ms |
| Overlay snapshot read | 14 ms | — |

Import plus graph `quick_check` consumed 12.275 seconds—97.8% of the 12.554-second provider duration. All four checks consumed approximately 12.310 seconds.

That leaves about 244 milliseconds for file checks, opens, schema inspection, table inventory, all counts and snapshot reading. Exact count reconciliation is therefore not a material cost in the measured archive and should remain unchanged during Stage Two.

There are two qualifications:

- `COUNT(*)` still scales with stored data and is not theoretically constant-time.
- The proposed Tier A is “bounded in work” rather than strictly bounded in wall-clock time. Lock waits can reach three seconds per connection, and `Isolate.run` currently has no application deadline or cancellation mechanism.

## 3. Exact incremental protection from `quick_check`

Opening a database and executing the current targeted queries detect:

- missing and zero-byte files;
- invalid SQLite headers and some malformed database conditions;
- unreadable schema metadata;
- unsupported `user_version`;
- missing required tables;
- corruption encountered in the schema or specific table pages traversed by the count queries;
- import/graph message-count disagreement;
- missing graph population/topology;
- malformed operation evidence.

`quick_check` additionally traverses the database’s B-tree and page-allocation structures. Its incremental value is proactive discovery of latent damage in pages that startup’s small query set never touches, including malformed records, B-tree ordering problems, freelist damage, missing or multiply-owned pages, and certain constraint problems.

The argument `1` limits reported errors, not pages inspected. The scan remains O(N). The [SQLite PRAGMA documentation](https://www.sqlite.org/pragma.html#pragma_quick_check) also states that `quick_check` does not verify UNIQUE constraints or whether index contents agree with table contents. Foreign-key errors require `foreign_key_check`.

It also does not prove:

- cross-database message identity equality;
- foreign-key correctness;
- application-level graph invariants;
- that FTS search results semantically match `messages.text`;
- that every expected FTS trigger or ordinary index exists.

The practical protection lost by skipping it is therefore narrow but significant: early discovery of physical corruption in untouched database pages.

## 4. Callers and assumptions

The full reader currently serves three materially different safety boundaries:

1. **Ordinary startup**

   [message_lens_installation_state_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/application/message_lens_installation_state_provider.dart:12) returns a logical installation state only after all existing databases pass `quick_check`.

2. **Legacy destructive-journal cleanup**

   [legacy_complete_installation_erase_journal_compatibility.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/infrastructure/compatibility/legacy_complete_installation_erase_journal_compatibility.dart:146) uses the same reader. It deletes the obsolete journal only if every existing database is `isUsable` and the archive is coherent.

3. **Start Fresh**

   [start_fresh_service_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/application/start_fresh_service_provider.dart:42) forces a fresh classification immediately before mutation. [start_fresh_service.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/onboarding/application/start_fresh_service.dart:107) invokes the reader again after reset to prove the Virgin contract.

The advanced Start Fresh presentation reuses the cached startup classification, but the service deliberately repeats authoritative validation at the mutation boundary.

Documented and tested assumptions include:

- no installation-state integrity requirement was removed by the prior isolate correction;
- store compatibility includes schema support and integrity;
- failed integrity must never authorize legacy-journal cleanup;
- Start Fresh performs fresh authoritative classification;
- successful `MessageLensInstallationState` currently implies integrity success for every existing store.

Therefore, simply removing `quick_check` from the reader would violate both documented and tested behavior.

The existing database-health audit is not a suitable replacement. Its provider awaits the normal import, graph and overlay database providers at [database_health_audit_service_provider.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/db/feature_level_providers/database_health_audit_service_provider.dart:24). Those providers may create directories, open writable stores and execute migrations. The audit performs broad logical inventory queries and does not run `quick_check`.

## 5. Proposed typed model

The logical installation state—Virgin, resumable, completed, abandoned or remediation-required—should remain separate from proof of database health.

A suitable model is:

```text
StoreBoundedInspection
├── absent
├── accepted(StoreStructuralFacts)
└── rejected(BoundedInspectionFailure)

IntegrityValidation
├── notApplicable(reason)
├── required(targets, reason)
├── inProgress(targets, progress)
├── passed(IntegrityProof)
└── failed(IntegrityFailure)

StartupInstallationValidation
├── boundedInspectionPending
├── boundedInspectionFailed
├── boundedInspectionPassed(candidateState, integrityRequirement)
├── integrityValidationRequired
├── integrityValidationInProgress
├── admitted(candidateState, AdmissionBasis)
└── remediationRequired
```

Typed bounded failures should distinguish at least:

- empty file;
- busy/locked;
- not a database;
- corrupt response encountered by a targeted read;
- general I/O failure;
- unsupported schema;
- missing required object;
- malformed operation snapshot;
- logical reconciliation mismatch.

`AdmissionBasis` should be explicit:

- `noExistingStores`;
- `fullIntegrityValidated(IntegrityProof)`;
- a future `boundedPolicyExemption`, only if such a weaker policy is explicitly approved.

There should be no general `isUsable` Boolean capable of silently treating bounded success as full integrity success.

## 6. Escalation policy

The repository currently contains trustworthy evidence for:

- archive identity and environment;
- schema version;
- required-table presence;
- onboarding running/interrupted/failed/completed state;
- legacy destructive journal presence;
- historical source presence;
- gross import/graph count agreement;
- obvious query/open failures.

It does **not** contain:

- a generic clean-shutdown marker;
- a last-successful-integrity-validation receipt;
- per-database mutation generations;
- a durable generic integrity-failure/quarantine marker;
- proof that database files are unchanged since validation.

Consequently, the minimum policy that preserves current guarantees is:

| Condition | Required action |
|---|---|
| No existing databases | Integrity validation is not applicable; Virgin admission may proceed |
| Any existing database under the current contract | Full integrity validation remains required |
| Future/unsupported schema | Reject directly; `quick_check` cannot make it compatible |
| Missing required structure | Reject or remediate directly; integrity success must not rescue it |
| Busy/locked | Typed contention state and retry; do not label as corruption |
| Older supported schema | Integrity validation before any writable migration |
| Interrupted onboarding or contradictory durable facts | Validate implicated stores before resume/remediation |
| Legacy erase journal | Preserve the existing full, fail-closed check |
| Start Fresh authorization and verification | Preserve full validation at the mutation boundary |
| Explicit user repair/validation request | Validate requested or implicated stores |

This typed split is safe, but by itself it does not speed admission for an existing installation.

A “suspicion-only” policy using only current evidence would be a deliberate guarantee change: latent corruption in an otherwise untouched page could go undetected until that page is later accessed.

The smallest defensible prerequisite for conditional skipping would be:

- an explicit architectural decision that bounded admission is sufficient for ordinary startup;
- a durable validation/quarantine receipt outside the database being vouched for;
- archive identity, schema vector and per-store mutation generation in that receipt;
- invalidation before every app-owned database mutation or replacement;
- durable recording of a failed validation;
- a revocable runtime gate that can stop new writes and background intake if deferred validation fails.

Even that does not provide the exact same protection against out-of-band disk corruption as scanning every page on every launch. Exact preservation of that guarantee inherently requires an O(N) read.

## 7. Admission rules

| Typed state | Admit normal application? | Writable providers/intake? |
|---|---:|---:|
| Bounded inspection pending | No | No |
| Bounded inspection failed | No | No |
| Bounded passed, no existing stores | Yes, as Virgin | Only after admission |
| Integrity required but not started | No | No |
| Integrity in progress | No | No |
| Integrity passed and logical state may continue | Yes | Yes |
| Integrity passed but logical state requires attention | No; remain in restricted shell | No |
| Integrity failed | No; remediation/diagnostics | No |
| Future bounded-policy exemption | Only after explicit policy approval | Only after typed admission |

A background check may be considered “optional” only if admission does not depend on it. If such a check later fails, the app must immediately:

- block new archive mutations and intake;
- persist a quarantine/failure receipt;
- transition to a restricted repair/diagnostic surface;
- avoid automatic repair or deletion.

The current `StartupApp` is effectively one-way after `_startupChoiceResolved`; it cannot reliably reclaim an already-admitted application. Therefore optional post-admission checking is not safe to introduce until a revocable root-level runtime gate exists.

## 8. Minimal future edit scope

For a safe typed split that initially preserves behavior:

- add a narrowly owned validation-state model under `lib/essentials/onboarding/domain/`;
- split the evidence-reader contract into bounded inspection and physical integrity-validation ports;
- split the SQLite implementation so only the integrity adapter contains `PRAGMA quick_check(1)`;
- add an application policy/orchestrator that produces explicit validation transitions;
- update the installation provider to expose those transitions;
- update `StartupApp` to render required/in-progress/failure states;
- update the classifier so it consumes structural/logical facts rather than `integrityOk`;
- keep legacy-journal and Start Fresh paths explicitly dependent on full integrity proof;
- regenerate Riverpod output only where signatures require it;
- update focused onboarding, startup and architecture tests.

Out of scope:

- database schemas or migrations;
- FTS schema, triggers or rebuild behavior;
- import/graph reconciliation semantics;
- database-health support-bundle architecture;
- reset targets;
- attachment preservation;
- user databases.

A durable receipt/quarantine mechanism would be a separate prerequisite stage because it expands persistence and mutation-boundary scope substantially.

## 9. Test plan

Add or adapt coverage for:

- bounded inspection succeeds without executing `quick_check`;
- schema-3 FTS graph remains structurally accepted;
- unsupported future schema is rejected without attempting to “rescue” it;
- missing structure and malformed files produce typed failures;
- exact import/graph count mismatch remains remediation-required;
- pristine Virgin inspection creates no files;
- required integrity produces `required → inProgress → passed/failed`;
- no admission while integrity is required or running;
- integrity success alone cannot override schema/logical failure;
- disposable corruption fixture where bounded reads pass but `quick_check` fails;
- policy spy proving ordinary paths invoke or omit integrity exactly as configured;
- legacy journal cannot be removed without full integrity proof;
- Start Fresh requires full proof before mutation and after reset;
- operation snapshot running/interrupted/failed escalation;
- busy/locked is not classified as corruption;
- database bytes, timestamps and WAL/SHM inventory remain unchanged;
- first Flutter frame continues to show the restricted shell;
- persistent providers and intake remain unreachable before typed admission;
- architecture tripwire ensuring bounded reader source cannot contain `quick_check`;
- architecture tripwire ensuring startup inspection cannot import persistent database providers.

Then run focused onboarding/startup tests, graph database tests, architecture tests, `flutter analyze`, `git diff --check`, a macOS debug build, and direct/Run Without Debugging timing verification.

## 10. Risks and unresolved decisions

- The core unresolved decision is whether the per-launch physical scan is a hard product guarantee or may become periodic/triggered.
- Tier A is not a hard wall-clock bound while it uses three-second SQLite busy waits.
- Exact counts are cheap today but still data-size-sensitive.
- Older accepted schemas create a validation-to-migration boundary needing explicit treatment.
- Splitting `isUsable` will affect many test fixtures even if runtime behavior remains unchanged.
- There is a time-of-check/time-of-use gap between one-off validation connections and normal provider opens.
- Parallel integrity scans could worsen performance on the external volume.
- Generic `quick_check` does not validate FTS semantics or foreign keys.
- Deferred failure handling is unsafe without revocable runtime quarantine.
- Legacy-journal startup can still be slow before the first frame, although only when that obsolete journal exists.

## 11. Recommended sequence

1. Commit Stage One as its own checkpoint before beginning Phase Two implementation.
2. Record the chosen integrity guarantee explicitly.
3. Introduce the typed bounded/integrity/admission model without changing behavior.
4. Split the SQLite bounded reader from the integrity validator.
5. Preserve full validation in ordinary startup, legacy cleanup and Start Fresh for the first refactor commit.
6. Add transition, corruption-fixture and architecture tests.
7. If faster admission is still required, implement the durable receipt/quarantine prerequisite as a separate reviewed stage.
8. Only then authorize a conditional policy and measure the resulting admission time.
9. Leave exact reconciliation and FTS behavior unchanged throughout.

`git diff --check` passes. The shared instructions submodule is clean. The existing Stage One modifications and deliberately untracked files remain untouched. No tests were run because this phase was explicitly a read-only architectural audit.