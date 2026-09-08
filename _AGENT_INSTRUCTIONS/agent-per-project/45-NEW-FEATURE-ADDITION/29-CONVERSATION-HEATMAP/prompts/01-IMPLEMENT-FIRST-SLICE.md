```text
Proceed with the first implementation slice of Feature 29:

_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/29-CONVERSATION-HEATMAP/

Treat the completed Feature 29 planning package as authoritative. Read at minimum:

- PROPOSAL.md
- DESIGN_NOTES.md
- CHECKLIST.md
- TESTS.md
- seed.md

Implement the feature described there, following the documented reuse-first architecture and existing project conventions.

The central principle is:

THIS IS PRIMARILY COMPOSITION OF EXISTING MECHANISMS, NOT A NEW HEATMAP OR NAVIGATION SYSTEM.

Required behaviour

In both Conversation-list contexts:

1. Main Conversations
2. Contact -> Messages -> Conversations

preserve the existing compact Conversation heatmap glyph for unselected Conversations.

When a Conversation is selected:

- replace the compact glyph region with the existing full year × month heatmap presentation;
- retain the existing Conversation title, metadata, actions, summary, tags, etc.;
- use the existing selected-card background/border treatment around the complete expanded card;
- make populated month cells navigable;
- keep empty and pre-start months inert;
- selecting another Conversation must immediately collapse the previous card and expand the newly selected one.

Clicking a populated month must navigate the existing complete Conversation stream to the FIRST message in that month. It must not filter the Conversation or create a month-specific message view.

Reuse requirements

1. Renderer

Reuse `CalendarHeatmapTimelineWidget`.

Do NOT create another full heatmap renderer.

Use the existing renderer directly or through the thinnest Conversation-owned adapter required by dependency boundaries.

Do not embed `MessageHeatmapContent` wholesale; the planning audit established that its summary/legend/hint/cassette composition is not appropriate inside a Conversation Card.

Prefer adapting existing `ConversationSignatureMonth` data into the existing `CalendarHeatmapTimelineData` presentation contract.

Do not extract or relocate shared domain types merely to avoid a small adapter.

If Conversations cannot legally consume the renderer through the current Messages public seam, try the narrowest appropriate public export first. Move a render-only primitive/DTO to a neutral shared location only if architecture checks demonstrate that the narrow export is inappropriate.

Do not undertake a broad heatmap architecture refactor.

2. Month resolution

Reuse:

`MessageEvidenceTimelineSkeleton.indexForMonth()`

Do NOT create another month-to-message resolver, SQL query, repository method, binary search, paging mechanism, or parallel month-navigation model.

Because the audit found that `indexForMonth()` has a latest-item fallback when no month matches, verify that the returned skeleton entry actually belongs to the requested month before dispatching navigation.

A stale/no-match result should remain inert and diagnosable. It must never silently jump to the latest message.

3. Message positioning

Reuse the existing exact-message anchor path and existing indexed timeline jump.

The intended pipeline is:

ConversationSignatureMonth adapter
→ CalendarHeatmapTimelineWidget
→ populated month click
→ existing Conversation evidence skeleton
→ indexForMonth()
→ verify returned entry belongs to requested month
→ obtain existing message ID
→ existing branch-aware exact-message anchor action
→ ConversationMessagesView
→ existing MessageEvidenceTimelineView positioning
→ ScrollablePositionedList indexed jump

Do not estimate pixel offsets or incrementally scroll through messages.

Do not hydrate the complete message corpus. Preserve the existing lightweight-skeleton + lazy-row-hydration architecture.

4. Selection state

The main Conversations list already propagates `isSelected` into `ConversationSignatureCard`.

Contact -> Conversations currently does not.

Align Contact -> Conversations with the existing flow-owned selected Conversation state and shared `ConversationSignatureCard` selection contract.

Do not create local expansion state or a second selection registry.

Expansion should be derived from the one authoritative selected Conversation ID.

5. Branch preservation

Month navigation must preserve the user's current navigation context.

In particular, clicking a month from Contact -> Conversations must remain in that Contact-derived branch.

Do not route Contact-derived month navigation through an action that switches the user to the main Conversations branch.

Reuse or minimally extend the existing branch-aware Conversation selection/anchor actions.

6. Activity semantics

Preserve the existing authoritative heatmap semantics:

- January through December fixed horizontal columns
- years as vertical rows
- existing `MonthIntensity` classification
- existing `activityHeatmapColorForMessageCount()` colour authority
- existing sparse-dot/activity-fill grammar
- existing distinction between empty and not-yet-started months

Do not create new colour thresholds or a Conversation-specific heatmap palette.

7. Accessibility

Reuse the renderer rather than solving accessibility through a separate widget.

For populated cells, provide useful tooltip/semantic information including month, year, and message count.

Evaluate whether the existing 12–14 px visual cells can retain their visual size while receiving a larger transparent hit target.

Empty/pre-start cells must not advertise navigation.

Preserve keyboard/focus behaviour where applicable and add it if the reused interactive renderer requires it under existing project accessibility conventions.

Explicitly deferred

Do NOT implement continuous visible-month synchronization/outline in this slice.

The renderer may already support `selectedMonthKey`, but do not introduce new message-pane -> Conversation-list scroll synchronization merely to populate it.

Do NOT add:

- an internal heatmap scroller;
- an arbitrary maximum expanded-card height;
- month filtering;
- multi-month selection;
- persisted month selection;
- a new navigation subsystem;
- broad Messages/Conversations domain extraction.

First test the natural variable-height list behaviour.

Implementation discipline

Before editing, inspect the current worktree and re-read the relevant production files identified in the planning package. Confirm that the code still matches the audit assumptions.

Preserve ALL unrelated worktree changes.

Make the smallest coherent implementation.

Do not perform broad formatting, cleanup, renaming, or opportunistic refactoring.

Keep graph, overlay, archive, import, database, recovered-message, Search, and Show in conversation semantics unchanged.

Testing

Follow TESTS.md and extend the existing focused tests identified in DESIGN_NOTES.md.

At minimum prove:

- unselected card retains compact glyph;
- selected card displays the existing full heatmap renderer;
- only one Conversation expands;
- Contact -> Conversations receives the same selected presentation;
- populated month click resolves to the first message in that month;
- empty/pre-start cells are inert;
- a no-match/stale skeleton result cannot fall through to the latest message;
- exact-message anchor navigation is reused;
- main Conversations month navigation remains in its branch;
- Contact-derived month navigation remains in its Contact branch;
- arbitrary historical navigation uses indexed positioning;
- message rows remain lazily hydrated;
- existing Search, recovered-message, Show in conversation, and ordinary Conversation-selection behaviour remain intact;
- existing heatmap colour/intensity semantics remain unchanged.

Run the appropriate focused tests, architecture checks, analyzer/static checks, and `git diff --check` according to project instructions.

Manually reason about or validate the two layout concerns identified in the audit:

- a long selected Conversation expanding dynamically in the main list;
- a long selected Conversation inside the Contact list's constrained viewport.

Do not add scrolling/capping machinery merely because these are theoretical risks. Add complexity only if testing demonstrates a concrete failure.

Documentation

Update the Feature 29 planning/checklist documents to accurately record what was implemented, tests run, deviations from the proposed architecture, and anything intentionally deferred.

Follow project rules regarding changelog/version/release metadata. Do not assume a bump is required; inspect the repository instructions and act accordingly.

Stop and ask Rob before proceeding if implementation evidence requires any of the following:

- a second heatmap renderer;
- a second month resolver;
- a new database/repository query;
- broad relocation of heatmap/domain types;
- substantial changes to sidebar navigation architecture;
- changing Conversation membership/filter semantics;
- a materially different UI between the two Conversation-list contexts.

Otherwise, carry the approved implementation slice through to completion.

At completion report:

1. concise description of the resulting UX;
2. production files changed;
3. tests added/updated and results;
4. architecture/static-check results;
5. whether `CalendarHeatmapTimelineWidget` was reused directly or what minimal seam/adapter was required;
6. confirmation that `indexForMonth()` and the existing exact-message anchor path remain the navigation authorities;
7. any implementation discoveries or deferred follow-ups;
8. documentation updated;
9. `git diff --check` result;
10. full git status, clearly distinguishing Feature 29 changes from unrelated pre-existing changes.

Do not commit unless the project instructions explicitly require it.
```