# Phase 3 — Polish & Bulk Operations (Deferred)

> **Status:** Not started
> **Depends on:** Phase 2 (core review flow working)

## Objective

Quality-of-life improvements once the core stray-handle review flow is proven and in use.

## Candidate Items

These are not committed — they will be prioritized based on real usage feedback.

### Bulk Operations
- **Bulk dismiss:** Select multiple handles and dismiss all at once.
- **"Dismiss all with < N messages":** One-tap cleanup for low-signal handles.
- **Bulk spam quarantine:** If `is_blacklisted` becomes useful, allow bulk-flagging handles as spam with consequences (e.g., excluded from future imports, hidden from all views).

### Discovery Aids
- **Stray handle count badge:** Show unreviewed count on the StrayHandlesSpec sidebar cassette.
- **Suggested matches:** Fuzzy matching of handle phone/email values against existing contact fields. Surface "Did you mean...?" suggestions in the Handle Lens.

### List Management
- **Sorting options:** By recency, by message count, alphabetical by handle value.
- **Filtering:** Hide reviewed handles, show only phone numbers, show only emails.

### Semantics
- **reviewed_at refinements:** Determine whether reviewed_at should reset when new messages arrive for a previously-reviewed handle.
- **is_ignored / is_blacklisted / is_visible:** Decide whether to wire these fields or drop them from the schema entirely.

## Exit Criteria

To be defined when items are promoted from candidate to committed.
