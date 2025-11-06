---
feature: search
doc_type: testing-monitoring
owner: @rob
status: draft
last_updated: 2025-11-06
---

# Testing & Monitoring — Search

## Automated Coverage Targets
- Unit: query parser, ranking heuristics, filter logic.
- Integration: index rebuild pipeline from import delta to queryable state.
- Widget: search UI interactions, keyboard shortcuts, result navigation.

## Test Data Requirements
- Curated corpus with known relevance expectations.
- Edge cases: emoji, diacritics, multi-language text, very long messages.
- Datasets representing both sparse and dense chat histories.

## Monitoring & Telemetry
- Query latency metrics with alerting on P95/P99 regressions.
- Index freshness timestamps and rebuild success/failure counts.
- Error logging for failed navigation conversions.

## Manual Verification Checklist
- Queries return expected top results for curated corpus.
- Filters (date range, participant) produce consistent subsets.
- Navigation to chat/message from search maintains user context.

## TODO
- Establish baseline performance targets for macOS release hardware.
- Integrate telemetry dashboards once indexing backend is chosen.
