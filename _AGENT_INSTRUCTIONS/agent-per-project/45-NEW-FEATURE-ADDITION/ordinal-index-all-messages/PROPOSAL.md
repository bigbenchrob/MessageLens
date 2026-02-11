# Feature Proposal: Ordinal Index Global Message Timeline

## Summary
Enable a new global timeline view that lets users scroll or jump through every message they have sent or received, ordered strictly by the message ordinal maintained in `working.db`. The experience should reuse the existing ordinal index strategy so only lightweight identifiers are fetched up front while full message payloads stream in as the user scrolls.

## Problem Statement
The current UI allows paging within a chat or participant slice, but there is no way to browse all messages chronologically across conversations. Power users have requested a single timeline that keeps performance characteristics identical to chat-level timelines even when paging through hundreds of thousands of messages.

## Goals
- Surface a "All Messages" timeline powered by the `message_index` ordinal ordering.
- Maintain lazy loading semantics: fetch only ordinal keys until tiles become visible, then hydrate details on demand.
- Provide navigation affordances (e.g., jump to date, drill into parent chat) that align with the ViewSpec navigation system.
- Reuse existing Drift, repository, and provider patterns without violating database access rules.

## Non-Goals
- Changing the underlying import or migration pipeline.
- Modifying per-chat or per-participant timelines beyond shared functionality.
- Redesigning the macOS shell layout.

## Success Metrics
- Timeline renders within the same performance budget as chat timelines (initial load <150 ms on production data snapshot).
- Scrolling through 10k+ messages does not block the UI thread nor manifest GC jank.
- Code adheres to documented Riverpod and database provider rules; lint clean.

## Dependencies
- `working.db` table `messages` and `message_index` covering `(sent_at_utc, message_guid)`.
- Existing message hydration services and caches in the messages feature.
- Navigation ViewSpec infrastructure for routing to a new `MessagesSpec.globalTimeline` variant.

## Risks
- Index drift: if `message_index` columns differ from expectations, we may need a migration.
- Increased load on message hydration providers; caching policy might need refinement.
- UI density: presenting messages without chat context could overwhelm users without careful design.

## Open Questions
1. Should the timeline support filtering (direction, attachment presence) in v1 or later?
2. How should keyboard navigation behave compared with chat timelines?
3. Do we need analytics or user telemetry to monitor adoption?

## Next Steps
1. Validate current schema and confirm `message_index` ordering columns.
2. Draft detailed design notes covering DAO changes, providers, and UI structure.
3. Review proposal with stakeholders; incorporate feedback before implementation.
