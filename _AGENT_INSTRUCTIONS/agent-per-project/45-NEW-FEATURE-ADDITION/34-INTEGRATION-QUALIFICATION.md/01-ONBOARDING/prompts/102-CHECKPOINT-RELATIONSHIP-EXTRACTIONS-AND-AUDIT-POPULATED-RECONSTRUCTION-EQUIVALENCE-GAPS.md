# MessageLens — Feature 34
## Prompt 102 — Checkpoint Relationship Extractions and Audit Populated Reconstruction-Equivalence Gaps

**Mode:** Read-only architecture and evidence audit. **No implementation.**

### Governing purpose

Responses 93–101 report eight characterization-first, qualified canonical source-scoped projections: Contacts, Messages, Handles, Chats, Attachments, Chat–Message, Chat–Handle, and Message–Attachment. Those narrowly proven transformations do **not** establish that a populated import ledger, Conversation Graph, FTS, and associated protected state can be reconstructed from authoritative evidence **now**.

Destructive Operating-owned Start Fresh / Stage 2C remains **BLOCKED**. Production AppCzar activation remains **OFF**. The seven AppCzar jurisdictions must remain unchanged. This prompt cannot lift those restrictions.

> The question is not whether a fresh database can be built. It is whether the current installation's entire consequential state can be reconstructed without losing or orphaning protected information, using the same authoritative transformations as production writers.

### 1. Repository preflight and documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text`.

1. Verify the actual branch `fix/onboarding-import-stuck-state`, current HEAD, synchronized upstream (`0 ahead / 0 behind`), clean tracked worktree and index, and shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`.
2. Inventory registered worktrees and all existing untracked files. Preserve them without modification.
3. Verify the eight source-projection implementation checkpoints in ancestry, including Message–Attachment implementation `b788c07e0bfead2e67f47027ff43fdf50423f494`. Verify the earlier seven from Responses 93–100 rather than guessing hashes.
4. Determine whether Prompt 101 and Response 101 have already been committed and pushed together. If yes, record their exact documentation checkpoint and do not duplicate it. If not, checkpoint and push **only** those two records before auditing; do not stage unrelated files.
5. Record the resulting baseline HEAD/upstream and optionally capture a source-only manifest outside the repository. Stop on any material preflight contradiction.
6. Read applicable global project instructions, the canonical Project Conformance standard, Responses 90–92 and Responses 93–101, and the current production source. Current code governs observed behavior; historical documentation is evidence of intent and prior qualification, not a replacement for source inspection.

### 2. Inventory the complete consequential footprint

Source-trace the exact active derived-store footprint a future Operating-owned Start Fresh would remove or invalidate. Inventory all import tables, source registries, graph tables, FTS/index tables, relationship rows, rich-text materialization, and all references into those stores.

Separately identify protected historical/non-live material, user overlays (notes, tags, favourites, other authored state), Presence, archive marker/identity, attachment metadata versus archived payloads, journals/receipts, bookmarks/configuration, and external references. Do not assume any of these may be deleted or recreated.

For each domain, record: source of truth; authoritative source availability now; current production writer; persisted schema and identities; effects of a reset; protected dependents; and evidence needed for reconstructibility. Distinguish exact material equivalence from operational batch/timestamp metadata; do not invent permissible differences.

### 3. Audit all eight shared source projections

For each of the eight families:

- Trace the concrete production writer call edge and typed projection input/output.
- Identify all consequential decisions **outside** the pure projection: source identity and registration, endpoint admission, missing-endpoint omission, local-account reconciliation, source selection, batching, uniqueness, anomalies, and persistence.
- Determine whether a future read-only witness can reuse the exact transformation without importing a database writer or mutation capability.
- Identify both missing and extra persisted-row anti-differences, source/provenance mismatch, and live versus historical-source counterexamples.
- Distinguish exact source-ledger relationships from derived graph topology; the graph may discard raw join identity and provenance.

Do not interpret the eight successful parity extractions as a complete reconstruction witness.

### 4. Rich-text enrichment and decoder boundary

Trace the production attributed-body/typedstream path, including Rust decoder, raw bytes, decoded/enriched fields, persisted columns, anomaly/failure policy, version/platform dependencies, ordering, and stateful reads or writes. Determine which deterministic transformations, if any, could be shared and how their actual production output would first be characterized. Address byte-exact versus semantic equivalence explicitly. Do not decode real user messages or change the decoder/enricher.

### 5. Conversation Graph and canonical identities

Inventory actual graph tables, columns, constraints, projectors, source-ledger inputs, message classification, group/participant derivation, canonical handles and aliases, contact-to-handle matching, cross-source/historical provenance, incremental versus full build behavior, and user-overlay references.

Classify each consequential transformation as (a) already pure/shared, (b) stateful but potentially reproducible with explicit evidence, or (c) presently unproven. Identify material differences that would make a reset unsafe. Graph row counts or topology alone are not sufficient proof of source provenance or reconstruction equivalence.

### 6. FTS and derived index

Trace FTS schema, tokenizer/configuration, triggers or writers, raw/enriched text inputs, row identity, rebuild and incremental-update semantics, and query-relevant equivalence. Determine what read-only evidence and disposable comparisons could prove expected index contents without mutating the live index. Do not run live FTS rebuilds.

### 7. Protected and irreconstructible evidence

Identify concrete cases of historical/non-live source material, disappeared live rows or joins, missing attachment payloads, orphaned graph/overlay references, unavailable rich-text decoding, and source instability during a scan.

For each case, state whether current evidence would establish:

- **TRUE:** every required material domain is proved reconstructible and protected state is preserved;
- **FALSE:** a known source absence, difference, or protected dependency blocks reset;
- **UNKNOWN:** unreadable, unstable, incomplete, unsupported, or conflicting evidence prevents a conclusion.

Do not turn UNKNOWN into permission to delete. Archive coverage proves payload availability, not source relationship provenance.

### 8. Future read-only populated witness

Propose the smallest bounded, source-grounded witness that reuses actual production transformations without introducing a second semantic authority. Address:

- consistent source observations and instability detection;
- exact archive/source/occurrence binding;
- bounded scans/paging and memory/performance limits;
- bidirectional missing/extra anti-differences;
- material versus operational field comparisons;
- graph and FTS equivalence;
- preservation of historical and user-authored references;
- typed TRUE/FALSE/UNKNOWN evidence and diagnostic presentation;
- fresh revalidation immediately before any eventual destructive action.

The witness must not acquire a mutation Ball, perform reset, create an AppCzar evaluator or coordinator, or confer destructive eligibility during this audit.

### 9. Evidence gaps and next milestone

Create a matrix for each domain showing existing production source/tests, qualified evidence, missing proof, minimal synthetic/disposable characterization, architecture enforcement, performance risks, and stop gates.

Recommend **one** narrowly bounded Prompt 103 milestone. Specify why it comes first, permitted files, pre-edit characterization, parity and architecture tests, full validation expectations, and explicit stop gates. Do not assume that another pure-function extraction is automatically the correct next step.

Give a dependency-ordered roadmap separating (1) any further shared transformations, (2) complete populated read-only witness, (3) adversarial and human qualification, (4) Operating-owned Start Fresh, and (5) later production-safe shell and cutover work. None of those later stages is authorized by this prompt.

### 10. Hard prohibitions

Apart from the conditional narrow Prompt 101/Response 101 documentation checkpoint and an untracked Response 102, make **no repository writes**. No source, test, schema, generated, release, dependency, or packaging edits. No builds, app launches, installed-app operations, live Apple Messages/Contacts or MessageLens database reads, WD/Toshiba archive access, attachment payload operations, S3 operations, TCC/FDA/bookmark/environment changes, destructive resets, or production activation.

Do not rerun the full Flutter suite or analyzer merely to repeat already qualified evidence. Do not stage or commit Prompt 102/Response 102; that belongs to a later authorized checkpoint.

### 11. Required Response 102

Create `102-CHECKPOINT-RELATIONSHIP-EXTRACTIONS-AND-AUDIT-POPULATED-RECONSTRUCTION-EQUIVALENCE-GAPS.md` in Feature 34 `01-ONBOARDING/responses/`, leaving it untracked for review.

Report: exact Git baseline and checkpoint; destructive-footprint/protected-state inventory; eight writer/projection edges and remaining stateful behavior; rich-text/graph/FTS gaps; historical/overlay/Presence/archive preservation; known FALSE/UNKNOWN counterexamples; proposed bounded witness and consistency model; test-gap matrix; exact Prompt 103 design; Project Conformance verdict and BLOCKER/SHOULD FIX counts; final Git/untracked preservation; and continuing prohibitions.

Conclude exactly:

```
EIGHT SOURCE-SCOPED PROJECTIONS CHECKPOINTED: YES / NO
POPULATED RECONSTRUCTION FOOTPRINT INVENTORIED: YES / NO
RICH-TEXT, GRAPH, AND FTS EQUIVALENCE GAPS IDENTIFIED: YES / NO
PROTECTED AND HISTORICAL DATA BOUNDARIES IDENTIFIED: YES / NO
COMPLETE READ-ONLY POPULATED WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO
PROJECT CONFORMANCE (AUDIT/DESIGN): PASS / FAIL
READY FOR NARROW PROMPT 103: YES / NO
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
```

Then **STOP**. Do not begin Prompt 103 or any implementation in this task.
