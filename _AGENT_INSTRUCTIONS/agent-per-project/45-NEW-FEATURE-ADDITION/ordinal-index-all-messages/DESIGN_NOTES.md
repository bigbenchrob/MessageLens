# Design Notes — Ordinal Index All Messages

## Architectural Direction
- Reuse the existing `message_index` for deterministic ordering; avoid loading full rows until hydration.
- DAO layer should expose both forward and backward pagination using keyset semantics (`WHERE (sent_at_utc, message_guid) > (?, ?)` etc.).
- Application service translates cursor requests into DAO calls and maps results into lightweight DTOs containing message identifiers, timestamps, and chat identifiers for follow-up hydration.
- Presentation layer consumes the DTOs via a generated Riverpod provider family, deferring full message fetch to the existing message detail cache/providers.

## Navigation Integration
- Add `MessagesSpec.globalTimeline()` and update the panel coordinator to render the new timeline widget.
- Consider a secondary ViewSpec for jump-to-date interactions if complexity rises.
- Surface the feature through the existing "Show messages from" affordance by adding an "All Messages" option that launches the same global timeline used after choosing a contact.

## UI Considerations
- Use a virtualized list (e.g., `ListView.builder`) paired with hooks to request the next page when the user nears list ends.
- Provide metadata chips (chat title, direction arrow) so users recognize context.
- Include affordances for quick jumps (first, last, go to date) without blocking the main scroll path.

## Performance & Caching
- Ensure DAO queries respect limit sizes tuned for the index (default 100 ordinals per page, adjustable).
- Hydration layer should reuse existing caches to avoid duplicate fetches when users jump from global timeline into chat view.
- Monitor memory by disposing of off-screen ordinals; rely on Riverpod autoDispose where appropriate.

## Open Technical Tasks
- Verify if additional composite indexes are needed for jump filters (direction/date boundaries).
- Determine whether timeline should preload adjacent page to smooth fast scroll.
- Define analytics events (optional) to measure feature usage.
