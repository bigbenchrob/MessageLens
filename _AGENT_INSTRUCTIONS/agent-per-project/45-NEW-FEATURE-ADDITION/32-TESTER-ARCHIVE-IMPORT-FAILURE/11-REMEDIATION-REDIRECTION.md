Here’s a Codex-ready prompt that turns the assessment into authorization while preserving the safeguards.



Please proceed with implementation of the tester archive-import memory remediation described in:

- `00-REPORTED-EPISODE-EVIDENCE-AND-DIAGNOSIS.md`
- `10-REMEDIATION-IMPLEMENTATION-AND-VERIFICATION-PLAN.md`

I have reviewed the diagnosis and plan. I agree that this is a genuine release-blocking architectural defect.

The evidence does not prove that MessageLens was the sole or largest consumer of memory when macOS displayed the system-wide application-memory warning. Do not overstate that causal claim. However, the evidence very strongly locates the interrupted operation in attributed-body rich-text extraction, and source inspection conclusively demonstrates an unbounded whole-corpus working-set design.

The governing invariant for this remediation is:

**Memory use must be bounded by the configured unit of work, not by the size of the source archive.**

Please proceed with Phases 0–2 substantially as proposed.

In particular:

- Bound the initial source-message import rather than fixing only the rich-text stage. Although source-message import completed during the tester episode, it has the same corpus-sized scaling defect and should not remain as the next likely failure point.
- Freeze a stable source high-water mark for each import run and use keyset pagination. Messages arriving above that boundary belong to the next incremental run.
- Replace `m.*` with the exact source projection required by the importer while preserving all source evidence required by later stages.
- Bound transactions and page-local association state.
- Replace whole-corpus rich-text candidate materialization with count + keyset-page semantics.
- Do not use `OFFSET` pagination on the changing enrichment predicate.
- Use `ss_id`, or an equivalently explicit source-scoped work identity, throughout all-sources enrichment. Do not use bare `source_rowid` as a globally unique key.
- Bound decoder work both by candidate count and cumulative attributed-body payload size.
- Persist successful enrichment after each bounded page/sub-page so completed work becomes a durable checkpoint.
- Ensure interruption can require replay of at most the uncommitted bounded unit rather than the entire corpus.
- Preserve cumulative and monotonic progress reporting across pages.
- Explicitly release page-local collections before proceeding to the next page.

Treat the proposed values such as 500 records and approximately 8 MiB as initial, injectable engineering policies rather than architectural constants. Profiling may justify changing them. The invariant is that the bounds are explicit, testable, and demonstrated to be safe.

Preserve the fidelity rules in the plan. In particular, an empty, malformed, oversized, unexpected, or undecodable attributed body must never cause its source message to disappear. Decode failure is a row-local anomaly. The source message, relationships, graph representation, and other source evidence must remain available.

Do not use permanent suppression of difficult records as a mechanism for making the candidate set shrink.

Also preserve all attachment/archive and overlay invariants. Do not delete the broad Application Support root, mutate `attachment_archive/`, or involve overlay intent in import/projection recovery.

### Phase 3 is mandatory before release

After implementing the bounded-memory architecture, perform the proposed single-record decoder investigation.

The existing small-blob probe is useful negative evidence against a simple native per-call leak, but it does not establish that a single malformed, deeply nested, very large, or otherwise pathological typedstream cannot cause disproportionate native allocation, recursion, CPU use, panic, or process termination.

Exercise the decoder with the malformed/large synthetic corpus described in the plan.

If a single record can violate the defined resource budget, add explicit parser limits or worker-process isolation as appropriate. Such a record must become an explicit row-local decode-unavailable anomaly rather than being dropped.

Do not assume that successful corpus paging by itself proves the Rust decoder safe.

### Memory qualification is a release gate

Unit tests demonstrating page bounds are necessary but insufficient.

Run the production-scale synthetic fixture with at least 150,000 rich-text candidates and measure process resident memory independently.

The expected memory profile is a bounded sawtooth/plateau associated with processing pages. Memory must not grow monotonically in proportion to total candidate count.

This test is important because apparently page-local code can still retain earlier pages accidentally through references elsewhere. The process-level measurement is what demonstrates that the architectural invariant is actually being achieved.

Also retain the interruption/recovery qualification in the plan. Inject termination at the specified boundaries and demonstrate that:

- committed work survives;
- at most one bounded unit must be replayed;
- no source records disappear;
- anomalies remain accounted for;
- topology and graph construction eventually complete;
- overlay state is unaffected; and
- attachment archive contents are untouched.

### Keep ancillary corrections separate

The support bundle currently cannot reliably establish the installed version/build because its health output can use stale checked-in fallback values. That should be corrected, but keep it as the separate diagnostic/recovery work described in Phase 4 rather than mixing it into the bounded-memory core commits.

Likewise, improving the coarse `graphProjectionFailed` recovery classification so it identifies the actual interrupted substage is valuable, but should remain a separately reviewable change.

### Implementation discipline

Create the dedicated feature branch and establish the Phase 0 baseline before changing production behavior.

Keep the bounded-memory implementation localized to the surfaces identified in the plan unless investigation demonstrates that another architectural boundary genuinely needs modification.

Add the specified focused tests and architecture tripwires. In particular, include tests that make regression to:

- whole-corpus message reads,
- whole-corpus enrichment reads,
- `m.*`,
- `OFFSET` candidate pagination,
- non-source-scoped enrichment identity, or
- corpus-sized decoder calls

difficult to reintroduce accidentally.

Do not weaken existing fidelity, idempotence, source-scoping, graph, provider, overlay, or attachment-preservation invariants to make the new implementation easier.

Run all focused, architecture, analyzer, full Flutter, and applicable Rust gates specified in the plan.

Do not push anything.

### Checkpoint

Implement Phases 0–2 and perform the Phase 3 investigation.

Then stop for review before proceeding with Phase 4/release packaging.

At that checkpoint, report:

1. branch and starting HEAD;
2. commits made, with each concern separated appropriately;
3. exact production architecture changes;
4. paging/high-water and checkpoint semantics;
5. source-scoped identity handling;
6. tests added and their results;
7. measured baseline versus remediated memory behaviour, including peak RSS and whether a plateau was demonstrated;
8. interruption/recovery results;
9. Phase 3 hostile/single-record decoder findings and whether Rust hardening was required;
10. any deviations from `10-REMEDIATION-IMPLEMENTATION-AND-VERIFICATION-PLAN.md`, with reasons;
11. remaining work for Phase 4 and release qualification; and
12. final `git status`.

If implementation evidence contradicts any assumption in the remediation plan, stop and explain the contradiction rather than silently adapting around it.

This gives Codex implementation authority but puts the review boundary before the ancillary diagnostics and release work.
