# MessageLens Feature 34
## Response 93 — Contacts Source Projection Extraction

### 1. Baseline and scope

The implementation began on fix/onboarding-import-stuck-state at
7d4f33de7495f34e28fa4ad079e1d0bcf6bd99e5, synchronized with upstream.
The shared-instructions submodule was clean at
95326f515ef4719f155ce6e223990398daad6311. There was one worktree on this
Feature 34 branch. The Stage 2C safety-stop
0da40b75d4f6aca972d7ac745a41079c4bc6d479 was verified in ancestry.

Only the Contacts source projection, its production consumer, a
characterization test, direct projection tests, and one AST architecture test
were changed. No real source, archive, database, donor, installed app, build,
or rehearsal was accessed.

### 2. Prior audit checkpoint

Prompt 92 and Response 92 were checkpointed and pushed before source editing:

7d4f33de7495f34e28fa4ad079e1d0bcf6bd99e5
docs(appczar): record reconstruction equivalence audit

Their binding conclusion remains unchanged: populated reconstruction
equivalence is NOT PROVEN, destructive Operating Start Fresh remains blocked,
and production AppCzar activation remains off.

### 3. Pre-edit writer path

The pre-edit production path was:

    synthetic or AddressBook source rows
      -> ContactImporter source queries, ordering, transaction, and progress
      -> contact_source_projection normalization helpers
      -> source-scoped contact/contact-channel ledger inserts

The importer queried contacts in Z_PK ASC, emails in
ZOWNER ASC, ZADDRESS ASC, and phones in ZOWNER ASC, ZFULLNUMBER ASC.
Those queries, their order, paging shape, source registration, batch creation,
transaction boundary, progress publication, exception path, and insertion API
remain importer-owned and unchanged.

### 4. Persisted row inventory

    contacts:
      ss_id, source_id, source_rowid, display_name, first_name, last_name,
      organization, created_at_utc, batch_id

    contact_channels:
      source_id, source_contact_rowid, contact_ss_id, kind, value, label,
      batch_id

Database uniqueness and insertIgnore decisions remain in the ledger writer;
the pure projection neither queries nor predicts database constraints.

### 5. Existing authorities retained

- SourceScopedRowKey.pack remains the sole packed source-identity authority.
- DateConverter.appleToIsoString remains the sole Apple creation-time
  conversion authority.
- readTrimmedContactSourceText, buildContactDisplayName, and the existing
  normalizeHandleIdentifier path remain the normalization authorities.
- Invalid contact primary keys omit contacts. Invalid channel owners,
  non-imported owners, and absent normalized channel values omit channels.
  These are now explicit typed decisions, not new policy.
- Email lowers its existing trimmed primary-or-fallback value. Phone retains
  its existing normalized-number-or-trimmed-raw fallback behavior. Labels
  retain their existing trimming behavior.

### 6. Pre-extraction characterization

Before production source editing, the actual ContactImporter was exercised
through a synthetic ReadOnlySourceDatabase opener, not through a handwritten
mapping. The fixture covers names, an organization-only contact, unknown
fields, an invalid key, an otherwise channel-free contact, Apple dates,
multiple channels, duplicate ledger outcomes, orphan and invalid owners,
blank/fallback values, labels, and full progress observations.

The captured contact row maps, in source-row order, were:

    101: Ada M Lovelace / Ada / Lovelace / Engine Society /
         2001-01-01T00:00:01.000Z / batch 1
    102: Analytical Engines / null / null / Analytical Engines / null / batch 1
    103: Unknown Contact / null / null / null / null / batch 1
    104: Channel Free / Channel / Free / null / null / batch 1

Each row also asserted its exact source_id, source_rowid, and
SourceScopedRowKey.pack value. The persisted channel maps, in physical
insertion order, were:

    101 email ada@example.com        label home
    101 email normalized@example.com label normalized
    101 phone 6045550100             label mobile
    101 phone extension only         label work
    102 phone 125055501019           label null

All five channel rows asserted source ID, owner row ID, packed contact ID,
kind, value, label, and batch ID. The duplicate email and duplicate phone are
still ignored by the ledger; orphan/invalid owners and missing channel values
are omitted. The expected observable result remains four inserted contacts,
five inserted channels, one omitted contact, one unavailable-enrichment
contact, and five omitted channels. Progress begins and ends for each of the
three existing work units with the same final anomaly counts.

batch_id is deterministically 1 in the in-memory fixture. The operational
started_at_utc is deliberately not treated as a fixed clock value: the test
asserts only that it is present and UTC. finished_at_utc and notes remain null
at this importer boundary. No other temporal metadata was introduced.

### 7. Canonical pure boundary

contact_source_projection.dart now contains exactly the small typed boundary:

    projectSourceContact(...) -> ContactSourceProjectionResult
    projectSourceContactChannel(...) -> ContactChannelSourceProjectionResult

The results are immutable projected rows or typed omissions. Projected rows
provide immutable ledger-value maps; omissions carry the exact source-grounded
reason. Inputs are explicit raw values plus source ID, batch ID, kind, and
imported owner context. The file remains synchronous and has only three
imports: DateConverter, canonical handle utilities, and SourceScopedRowKey.

### 8. Production use and behavioral preservation

ContactImporter has one call to projectSourceContact and one call to
projectSourceContactChannel in each existing email and phone route. It no
longer owns a duplicate contact, email, phone, packed-key, or channel-row
formation branch. It still owns all source I/O, transaction and ledger
mutation, ordering, counts, progress, source/batch lineage, and errors.

The unchanged characterization runs after extraction against the production
writer and asserts the exact same contact/channel maps, omission counts,
queries, insertion order, and progress maps. The before/after parity verdict
is PASS, including the anomalous and omitted records.

### 9. Direct and mechanical evidence

The direct projection test covers every contact and channel persisted column,
immutable output maps, organization and unknown-name fallback, invalid primary
keys, normalized/fallback emails, normalized/raw/fallback phones, labels,
typed omissions, and irrelevant-versus-material context.

The AST architecture test proves that the projection has the bounded pure
dependency surface, invokes the existing key/timestamp/handle authorities, has
no async/clock behavior, does not import the importer, and that the importer
uses the shared projections exactly once for contacts and once each for email
and phone without retaining the former duplicated branches.

No graph contact, canonical-handle, protected-reference, Start Fresh,
Onboarding, Data Update, historical import, Stage 2A/2B, archive/adoption, or
AppCzar production-selector source was edited. The existing seven-jurisdiction
AppCzar census remains unchanged; official production continues to select
legacy StartupApp and production AppCzar activation remains off.

### 10. Validation

| Validation | Result |
| --- | --- |
| Baseline actual importer characterization, before extraction | PASS |
| Focused importer + direct projection + architecture tests | +14, PASS |
| Source-scoped import, DateConverter, graph contact/handle, and Local Data Repair safety group | +159, PASS |
| Onboarding, Data Update, AppCzar and all jurisdiction groups | +597, PASS |
| Archive/historical/environment/attachment group | +770, PASS |
| Complete architecture suite | +617, PASS |
| flutter analyze | PASS — no issues |
| Full deterministic flutter test | +3194 ~1, PASS |
| dart format on all five changed Dart files | PASS — 0 files changed |
| Unstaged and staged git diff --check | PASS |

The grouped test counts overlap and must not be summed. The single full-suite
result is the repository-wide count: 3,194 executed and one documented skip.
No Riverpod/build-runner output was required; formatting confirmed that no
generated file changed.

### 11. Conformance, checkpoints, and next boundary

Project Conformance is PASS.

    BLOCKER: 0
    SHOULD FIX: 0

The implementation checkpoint was created and pushed:

a36feac8a48d1702aad5830076157830d6efb975
refactor(import): extract canonical Contacts source projection

This response and Prompt 93 are being checkpointed separately as documentation
only. At response creation, the implementation worktree/index was clean; only
the known unrelated untracked artifacts plus these two Prompt 93 documentation
paths remained untracked. The shared submodule remained clean and all other
worktrees were untouched.

The next permissible action is a separately reviewed, equally narrow message
source-projection extraction. A full populated reconstruction witness remains
unimplemented. Destructive Stage 2C, Stage 2D/rehearsal, and production cutover
remain out of scope and unauthorized.

RESPONSE 92 AUDIT CHECKPOINTED: YES

PRE-EXTRACTION WRITER OUTPUT CHARACTERIZED BEFORE EDITS: YES

CANONICAL CONTACT/CHANNEL SOURCE PROJECTION IS PURE AND SHARED: YES

PRODUCTION CONTACT IMPORTER USES ONE CANONICAL TRANSFORMATION PATH: YES

CONTACT/CHANNEL PERSISTED OUTPUT AND OMISSION PARITY: PASS

CONTACT SOURCE PROJECTION EXTRACTION IMPLEMENTED: YES

FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS

READY FOR NEXT NARROW EXTRACTION: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
