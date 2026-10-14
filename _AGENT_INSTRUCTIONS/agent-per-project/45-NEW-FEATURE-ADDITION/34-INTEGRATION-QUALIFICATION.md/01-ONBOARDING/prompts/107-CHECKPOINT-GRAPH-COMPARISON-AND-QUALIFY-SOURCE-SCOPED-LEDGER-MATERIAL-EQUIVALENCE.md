# MessageLens — Feature 34
## Prompt 107 — Checkpoint Graph Comparison and Qualify Source-Scoped Import-Ledger Material Equivalence

**Milestone:** Test-only, disposable, bidirectional source-scoped import-ledger material comparison. **No production implementation or reconstruction witness.**

### Governing status

Responses 93–101 qualified eight canonical source/relationship projections; Response 103 qualified the per-record rich-text semantic projection; Responses 105–106 qualified disposable production graph replay and an 11-table material comparator. Those are narrow proofs, not proof that an arbitrary populated installation is reconstructible. Destructive Operating-owned Start Fresh / Stage 2C remains BLOCKED; production AppCzar activation remains OFF. Seven AppCzar jurisdictions remain unchanged.

### 1. Preflight and documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text`. Verify branch `fix/onboarding-import-stuck-state`, actual HEAD, upstream synchronization `0/0`, clean tracked tree/index, clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`, one worktree on this branch, and preserve all unrelated untracked files. Verify implementation ancestry for eight source projections, rich text, graph replay `d364df01374abad9e1f8832fa04d70ed237715ff`, and graph comparison `1c1f8f62b1af73991b2317aac869dbc411557594`.

Verify whether Prompt 106 and Response 106 have already been checkpointed and pushed. If so, record their exact documentation commit and do not duplicate it. Otherwise checkpoint and push **only those two documents**, without staging anything unrelated, before source edits. Capture an external source/test-only baseline manifest. Read global instructions, canonical Project Conformance standard, Responses 91–92, 98, 102, 104–106, and actual import schema, source registry, importer tests, and existing graph comparator. STOP on any material baseline contradiction.

### 2. Audit the ledger before editing

From the actual source-scoped ImportDatabase schema (not prior prose), inventory every persisted table, column, declared type, nullability, primary/unique identity, foreign key, and index relevant to material identity. Include `source_registry`, `import_batches`, five scalar entity families plus `contact_channels`, and the three relationship tables. Confirm actual schema version. Distinguish material facts, operational provenance, and truly ephemeral data **field by field**; do not silently exclude a timestamp, batch, source occurrence, or metadata field. Source registry identity and referential coherence are consequential even when a batch timestamp is not reproducible byte-for-byte.

Identify whether all rows can be read safely through existing disposable ledger APIs or bounded read-only SQL, and where a full scan would be unbounded. Inventory the qualified pure projection contracts and existing importer-owned omissions, local-account resolution, endpoint proof, uniqueness, and batch behavior. Do not create a second source parser, importer, registry allocator, or semantic authority.

### 3. Pre-edit actual comparator characterization

Before editing the existing test-only comparator/harness, characterize its current equality/difference behavior using only disposable synthetic ImportDatabase fixtures. Freeze baseline expected/observed rows, identity ordering, and diagnostics. Record any existing limitations literally. If the current harness cannot be reused safely without production changes, STOP and report; do not broaden scope.

### 4. Implement test-only ledger comparison

Prefer a narrowly named ledger material manifest/comparator under `test/essentials/source_scoped_import/.../reconstruction/` and tests beside it. Reuse the test-only graph comparator's design where practical, but do not create a generic production framework. Limit changes to new or existing **test-only** files strictly needed for this comparison; do not touch `lib/`, Rust, macOS, schema/migrations, generated files, providers, AppCzar, archive, reset, dependencies, release metadata, or graph production code.

For every ledger table, declare the complete schema columns and identity contract, and mechanically compare against disposable production-schema `PRAGMA table_info`, `PRAGMA index_list/index_info`, and foreign keys where applicable. Explicitly state which columns are compared byte/value-exactly and which operational fields require separate coherent-provenance validation; do not equate ignored fields with reconstructibility. A schema addition must fail until explicitly classified.

Implement **bidirectional** deterministic comparison: expected missing from observed, unexpected observed rows, changed field values, duplicate/invalid identity evidence, absent-field versus SQL NULL, cross-source packed identity mismatches, and inconsistent source-registry/batch references. Sort by declared identities, preserve stable field-level diagnostics, bound diagnostic count and value length without hiding total mismatch counts, and never turn incomplete evidence into equality. The comparator must return data/evidence only, no TRUE reset eligibility, no mutation Ball, no AppCzar fact or coordinator.

### 5. Synthetic test matrix

Exercise at least:

- Independent equal disposable ledger material and changed material values.
- Missing, extra, and changed rows for **every** persisted family, including contacts/channels and all three joins.
- Raw relationship ROWID preservation for Chat–Message versus endpoint-tuple uniqueness for the other joins.
- Source registry ID, kind/key, and occurrence changes; identical visible content with different packed IDs.
- Import batch membership, missing batch, stale batch reference, and operational timestamp classification.
- Null/empty/whitespace/Unicode text, raw attributed-body bytes, enriched text distinction, and anomaly-preserving records.
- Source-scoped duplicate identities and enforced uniqueness; in-memory duplicate evidence where actual schema rejects duplicates.
- Missing endpoint and historical/non-live source counterexamples, including protected provenance that cannot be reconstructed from current live source.
- Null versus absent field, deterministic ordering, diagnostics truncation, and schema drift tripwires.
- No real source database or archive access and no user content in test logs.

Use fixed synthetic source registry IDs, source rows, and batches. Reuse qualified canonical projection functions for expected deterministic values where feasible, not handwritten alternate normalization. Where importer admission or stateful decisions are required, label them as explicit fixture facts, not as independently proven reconstructibility.

### 6. Validation and stop gates

Run focused characterization before edits; focused comparator tests after edits; relevant existing source-scoped identity/schema/architecture regressions; complete architecture suite and `flutter analyze`; formatting, generated consistency, `git diff --check`, and exact-file staged hygiene. Run the full Flutter suite only if governing instructions require it for this bounded test-only milestone. Report unique counts, intermediate failures, retries, and exact commands. No app build, installation, launch, live data, or real archive access.

STOP if exact schema coverage cannot be established, a comparator must read an admitted root, a second importer/source interpretation would be necessary, source-registry or batch semantics are guessed, material differences are suppressed, the test-only scope would expand into production, or conformance/required tests fail. Restore exploratory tracked changes on a stop and report the literal blocker.

### 7. Checkpoints and Response 107

If and only if all gates pass, commit and push **only** the authorized test-only implementation files. Create Response 107 in the Feature 34 `01-ONBOARDING/responses/` folder. Separately checkpoint and push Prompt 107/Response 107, reporting the final documentation hash in the handoff. Preserve unrelated untracked material and submodule state. No force push/rebase/squash.

Response 107 must include exact baseline/checkpoints; full ledger schema/identity manifest; material-versus-operational field classification; pre-edit characterization; comparison algorithm and bounded diagnostics; test vectors and outcomes; source registry/batch/provenance constraints; exact test/file inventory and conformance; remaining FTS, protected-reference, coherent observation, and resource gaps; final Git state; and next narrowly justified milestone.

Conclude exactly:

`GRAPH MATERIAL COMPARISON CHECKPOINTED: YES / NO`

`LEDGER MATERIAL SCHEMA AND IDENTITIES COMPLETELY INVENTORIED: YES / NO`

`BIDIRECTIONAL LEDGER MATERIAL ANTI-DIFFERENCES QUALIFIED IN DISPOSABLE TESTS: YES / NO`

`SOURCE REGISTRY AND BATCH PROVENANCE PRESERVED AS CONSEQUENTIAL: YES / NO`

`COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then STOP. Do not start a production witness, FTS repair, protected-reference checker, reset, or cutover in this task.
