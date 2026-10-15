# MessageLens — Feature 34
## Response 110 — Checkpoint Observation Envelope and Qualify Protected-Reference Equivalence

Date: 2026-10-15

## Result

Prompt 110 is complete.

The already-qualified bounded observation envelope remained unchanged. A
separate, test-only protected-reference reader/comparator now qualifies how
protected overlay intent resolves against independently constructed disposable
graph and source-ledger worlds. It distinguishes exact overlay material,
resolved target identity, archive compatibility resolution, source-occurrence
provenance, and attachment payload coverage. It publishes evidence only and
does not grant mutation, reset, repair, or AppCzar jurisdiction authority.

No production source, generated source, schema, dependency, release metadata,
native code, archive, provider, AppCzar evaluator, coordinator, or reset code
changed.

## Baseline and checkpoints

Preflight established:

- branch: `fix/onboarding-import-stuck-state`
- starting HEAD: `b2121dd761bc404fe16fec30e5885f424f514669`
- upstream relationship: synchronized `0/0`
- tracked worktree and index: clean
- only one worktree on this branch
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- required implementation commit
  `281d7e01161ac779f281c397bac5c626a9eb320b`: present in ancestry
- Prompt 109/Response 109: already checkpointed and pushed by
  `b2121dd761bc404fe16fec30e5885f424f514669`; not duplicated
- untracked material: inventoried and preserved

The implementation checkpoint contains exactly the two authorized test files:

- commit: `89aa7317b52f704689cdcecc36f81f0f31e46554`
- subject: `test(onboarding): qualify protected reference equivalence`
- pushed to: `origin/fix/onboarding-import-stuck-state`
- upstream relationship after push: synchronized `0/0`

## Authoritative schema inventory

The qualification uses the current production schema constants and requires an
exact match before interpreting any reference:

- overlay schema: version 8
- conversation graph schema: version 3
- source-scoped import ledger schema: version 10

The reader inventories all 16 current overlay reference/material tables. Their
actual namespaces and resolution rules are:

| Overlay table | Stored identity | Qualified interpretation |
| --- | --- | --- |
| `participant_overrides` | `participant_id` | direct/compatible graph contact identity |
| `chat_overrides` | `chat_id` | direct/canonical graph conversation identity |
| `message_annotations` | `message_id` | direct/canonical graph message identity |
| `message_intent_overlays` | `message_ss_id` | direct/canonical graph message identity |
| `message_intent_tags` | `message_ss_id`, `tag_normalized` | graph message plus overlay-local normalized tag |
| `message_user_flags` | `message_guid` | exact, uniquely resolved message GUID fallback |
| `message_user_tags` | `message_guid`, `tag_normalized` | exact unique GUID plus overlay-local normalized tag |
| `conversation_tags` | `id` | overlay-local tag identity only |
| `conversation_tag_assignments` | `conversation_id`, `tag_id` | graph conversation plus overlay-local tag ID |
| `handle_to_participant_overrides` | `handle_id` plus one target column | canonical handle bridged to graph contact, overlay virtual participant, or explicit reviewed-unlinked state |
| `virtual_participants` | `id` | overlay-local virtual-participant namespace only |
| `overlay_settings` | `key` | overlay-local setting identity only |
| `favorite_contacts` | `participant_id` | direct/compatible graph contact identity |
| `handle_visibility_overrides` | `handle_id` | canonical graph handle identity |
| `dismissed_handles` | `normalized_handle` | production-normalized canonical handle resolution |
| `archived_attachments` | `message_guid`, `import_attachment_id` | exact unique message GUID plus unscoped attachment ROWID admitted only as a live-source compatibility tuple |

The graph inventory is bounded and reads only identity material needed by these
contracts: contacts, chats, messages/GUIDs, raw handles, canonical handles,
handle aliases, attachments, and message-to-attachment relationships. The
source ledger contributes the source registry so packed identifiers compare by
their exact source key and kind, not merely by an integer that could be
reallocated.

## Pre-edit production interpretation

The existing production utilities remained the semantic authorities:

- `contactIdentityKeyVariants` for compatible contact keys
- `canonicalConversationEvidenceId` for conversation identity
- `canonicalMessageEvidenceId` for message identity
- `handleIdentityKeyVariants` for handle keys
- `normalizeHandleIdentifier` for normalized handle comparison
- `SourceScopedRowKey` and the source registry for packed identity/provenance
- `ArchiveCompatibilityKey` for archived-attachment compatibility
- `liveChatDbSourceId` for the admitted live attachment occurrence

No fallback was invented where production supplied no unambiguous contract.

### GUID fallback

Message GUID fallback is exact and succeeds only for one graph message. No
case-folding or other normalization is applied. Zero matches are a known
contradiction. Multiple matches, including a historical/live collision, are
UNKNOWN. An empty GUID is UNKNOWN because the identity field is absent.

### Handle normalization and representative selection

Raw handle keys use the production compatible-key variants, then resolve
through the graph's canonical representative. Normalized strings use the
production handle normalizer and must identify one canonical representative.
Multiple representatives are UNKNOWN; a changed unique representative is a
known rebound contradiction.

### Virtual-participant bridges

Graph contacts and overlay-local virtual participants remain separate
namespaces. A bridge may name one graph participant, one overlay virtual
participant, or the explicit reviewed-unlinked state. Naming both is UNKNOWN;
naming neither without the explicit state or using a graph-like ID as a virtual
participant is a contradiction. Virtual participant IDs are never treated as
graph contact keys.

### Archived-attachment compatibility

The stored tuple remains `(message_guid, import_attachment_id)`. The GUID must
resolve uniquely, and the unscoped attachment ROWID is packed with
`liveChatDbSourceId`. Both live graph endpoints and their relationship must be
present and supported by `ArchiveCompatibilityKey`. An identically numbered
historical attachment cannot satisfy the tuple. Compatibility/provenance is
reported separately from payload coverage.

## Test-only implementation

Added:

- `test/essentials/app_czar/application/reconstruction/protected_reference_equivalence.dart`
- `test/essentials/app_czar/application/reconstruction/protected_reference_equivalence_test.dart`

`ProtectedReferenceEquivalenceReader` accepts only caller-supplied disposable
production-schema overlay, graph, and ledger handles. It never resolves an
application root, opens a live source/archive, obtains a provider-owned
database, or writes to a supplied database.

Limits are explicit and deterministic:

- maximum 128 rows per inspected table
- maximum 256 KiB of canonical overlay material
- maximum 32 diagnostics

Every overlay row value is losslessly canonicalized for comparison, including
binary values encoded from their exact bytes. This proves equality of logical
overlay row material; it does not claim physical SQLite file-page identity.

Diagnostics contain only stable table/category tokens. They do not include
GUIDs, handles, notes, paths, or other protected content.

## Evidence semantics

The helper publishes only `TRUE`, `FALSE`, or `UNKNOWN` evidence.

- `TRUE`: the dimension was assessed and the independently constructed worlds
  agree.
- `FALSE`: coherent evidence establishes a missing, extra, rebound, dangling,
  or otherwise contradictory reference.
- `UNKNOWN`: a required identity or lookup is ambiguous or a required
  observation cannot be qualified.

Known contradictions dominate the aggregate result so they remain visible
even when another reference is UNKNOWN. Globally unavailable observations—an
unsupported schema, unreadable source, unqualified production lookup, or
resource-bound breach—mark the affected comparison dimensions unassessed and
UNKNOWN. They do not manufacture empty-world missing/extra contradictions.

The comparison keeps five dimensions explicit:

1. `overlayIntentMaterial`
2. `targetIdentity`
3. `compatibilityResolution`
4. `sourceOccurrenceProvenance`
5. `attachmentPayloadCoverage`

Payload coverage remains deliberately UNKNOWN and unassessed because this
milestone qualifies reference identity, not preserved payload bytes. None of
the first four dimensions implies the fifth.

## Synthetic qualification results

The 12 focused tests qualified all ten required Prompt 110 categories:

- all supported direct contact, chat, message, canonical-handle, conversation,
  virtual, local, and archive-compatible references agree across independent
  expected and observed worlds
- missing, extra, rebound, dangling, and packed source-registry reallocation
  remain FALSE and visible
- GUID zero/case-change/changed-target cases are literal contradictions;
  multiple and historical/live collisions are UNKNOWN
- normalized-handle representative changes are not normalized away and
  competing representatives are UNKNOWN
- archived attachments are live-source scoped and historical row-ID collisions
  cannot satisfy compatibility
- virtual-participant and overlay-local tag IDs remain in their own namespaces
- a known chat contradiction remains reported beside an ambiguous handle
  fallback
- missing identity fields, unsupported overlay schema, unreadable graph,
  unqualified lookup semantics, row limit, and byte limit produce UNKNOWN
- diagnostics are deterministic, bounded, and non-content-leaking, while the
  overlay material before and after observation is unchanged
- disposable handles and directories are released/deleted after success,
  failure, and cancellation

Expected and observed graph/ledger material is independently allocated. The
fixtures use only temporary directories and synthetic database contents.

## Isolation and cleanup evidence

- source/graph/overlay inputs: caller-supplied disposable handles only
- production/development databases: not opened
- real attachment archives: not opened
- overlay user intent: not mutated or dropped
- test writes: confined to synthetic fixtures used to establish known cases
- cleanup order: close every supplied handle, then delete its disposable root
- cleanup attempted on success, failure, and cancellation
- cleanup failures: surfaced rather than swallowed
- application launch: none

## Validation

### Focused qualification

```text
/Users/rob/Development/flutter/bin/flutter test \
  test/essentials/app_czar/application/reconstruction/protected_reference_equivalence_test.dart \
  --reporter compact
```

Result: **PASS — 12 passed, 0 failed**.

### Relevant regressions

The bounded AppCzar, operating-session, graph-replay, source-ledger material,
archive compatibility, and contact/handle/message identity regression set was
run.

Result: **PASS — 244 passed, 0 failed**.

### Architecture

```text
/Users/rob/Development/flutter/bin/flutter test \
  test/architecture/forbidden_imports_test.dart --reporter compact
```

Result: **PASS — 394 passed, 0 failed**.

### Static analysis and formatting

```text
/Users/rob/Development/flutter/bin/flutter analyze
```

Result: **PASS — no issues found**.

Targeted `dart analyze` of both new files also passed with no issues.

```text
/Users/rob/Development/flutter/bin/dart format --output=none \
  --set-exit-if-changed <both Prompt 110 test files>
```

Result: **PASS — 2 files formatted, 0 changed**.

`git diff --cached --check` passed for the implementation checkpoint. No
generator input or generated output changed, so a code-generation run was not
applicable. The full Flutter suite was skipped because the governing Project
Conformance standard does not require it for this bounded two-file test-only
milestone; the focused, relevant regression, architecture, and full-analyzer
gates all passed.

### Interruptions and retries

An initial broad regression process lost its attributable completion result
when its execution cell was interrupted. No success or failure was inferred.
The exact regression set was rerun with a captured exit status and passed as
reported. Its first sandboxed retry could not update Flutter's SDK cache stamp
and supplied no code result; the authorized rerun passed. The final sandboxed
format/analyze attempt encountered the same cache restriction and supplied no
result; the authorized rerun passed. An earlier focused run exposed that a
globally unavailable observation could be compared as an empty world. The
test-only comparator was corrected to fail that case UNKNOWN, and the final
focused result above is attributable to the committed implementation.

## Project Conformance audit

- reuse before invention: PASS; current production identity, normalization,
  compatibility, schema, and source-key utilities are reused
- architecture/layering: PASS; both files are test-only and add no production
  dependency or authority
- single source of truth: PASS; production resolvers remain authoritative and
  the helper only reports qualification evidence
- schema and database access: PASS; exact schema versions are required and all
  handles are caller-supplied disposable databases
- protected material: PASS; no supplied row is written, removed, or hidden
- bounded work and diagnostics: PASS
- deterministic cleanup: PASS
- generated/dependency/release consistency: PASS; none changed
- architecture BLOCKER findings: 0
- architecture SHOULD FIX findings: 0
- optional findings affecting this proof: 0

The seven AppCzar jurisdictions are unchanged, and production AppCzar
activation remains disabled.

## Remaining literal gaps

- FTS reconstruction/material equivalence is not qualified here.
- The coherent populated-source observation envelope and this protected-
  reference comparator remain separate test-only components; no combined
  populated reconstruction witness exists.
- Production-scale resource behavior is not qualified by the fixed synthetic
  fixture.
- Protected-operation, reset, repair, and mutation authority are not
  implemented or authorized by this evidence.
- Physical attachment payload coverage is not assessed.
- No AppCzar policy or production composition consumes this helper.
- This milestone does not authorize destructive Operating Start Fresh or
  production AppCzar cutover.

OBSERVATION ENVELOPE CHECKPOINTED: YES

PROTECTED-REFERENCE SCHEMA AND PRODUCTION RESOLUTION INVENTORIED: YES

DISPOSABLE PROTECTED-REFERENCE EQUIVALENCE QUALIFIED: YES

HISTORICAL/LIVE AND FALLBACK AMBIGUITY PRESERVED: YES

OVERLAY USER INTENT MUTATED: NO

COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS

READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
