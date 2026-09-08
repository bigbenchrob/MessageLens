Here is a prompt I would give Codex:

```text
Create a new feature-planning folder:

29-CONVERSATION-HEATMAP

This feature addresses a navigation gap in MessageLens: long conversations currently rely too heavily on scrolling, even though conversation rows already contain compact heat-map glyphs that communicate temporal activity.

The intended interaction is now sufficiently clear that this task should begin with a focused audit and implementation plan, not speculative redesign.

Core product direction

In conversation-list contexts, keep the existing compact conversation heat-map glyph for unselected conversations.

When a conversation is selected, replace its compact glyph with the existing full year × month heat-map representation already used on the Contact / All Messages page:

2016  □ □ □ □ □ □ □ □ □ □ □ □
2017  □ □ □ □ □ □ □ □ □ □ □ □
...
2026  □ □ □ □ □ □ □ □ □ □ □ □

The selected conversation’s title, metadata, and expanded heat map should sit on a subtle persistent selected-state background so it is immediately obvious which conversation is currently being displayed in the message pane.

The expanded heat map is not a new visualization. It should reuse, as far as practical, the existing full heat-map visual language and implementation.

Primary navigation behaviour

Clicking a populated month in the expanded conversation heat map should navigate the message pane to the first message belonging to that conversation in that month.

The heat map therefore serves as coarse temporal navigation:

- heat map: jump to a month
- scrolling: local movement within nearby messages
- search: semantic navigation
- Show in conversation: precise message navigation

The compact glyph remains primarily informational. The expanded heat map becomes interactive.

The same interaction model should be investigated for all conversation-list contexts where the compact conversation heat-map glyph is shown, including:
- the main Conversations page
- Conversations mode within a Contact’s messages page

Do not assume both contexts are implemented identically; audit first.

Selected-state behaviour

There is currently no sufficiently durable visual indication in the conversation list showing which conversation is driving the message pane.

The selected conversation should gain a subtle background treatment encompassing:
- conversation title
- title metadata / counts / dates
- expanded heat map

Avoid introducing an unrelated selection marker if the background treatment can solve this clearly.

Audit before proposing edits

Perform a read-only investigation first.

Identify:

1. The widget(s), models, providers, and state responsible for:
   - compact conversation heat-map glyphs
   - full Contact-page year × month heat maps
   - conversation selection
   - message-pane navigation / scroll positioning
   - Show in conversation / exact-message jumping, if relevant

2. Whether the full year × month heat-map implementation can be reused directly, extracted into a shared widget, or adapted with minimal duplication.

3. How message lists are currently loaded:
   - fully materialized vs virtualized/lazy
   - sorted ascending or descending
   - whether jumping to an arbitrary historical message is already supported
   - whether there is an existing anchor/index/message-ID navigation mechanism

4. How to resolve:
   conversation + year + month
   → first message in that month
   → position in the rendered message stream

5. Whether month counts or month boundaries are already available in conversation data, or whether a new query/provider is required.

6. Current selected-conversation state handling in both relevant list contexts.

7. Existing heat-map tests and message-navigation tests that can be extended.

8. Accessibility / pointer-target implications:
   - expanded cells should be comfortably clickable
   - tooltip/semantic text should identify month/year and preferably message count
   - empty months should not appear actionable

Important UX invariants

- Unselected rows retain the existing compact glyph.
- Selecting a conversation expands that same temporal information into the full year × month map.
- Do not invent a third heat-map visual language.
- The selected conversation remains visually identifiable even after the user has scrolled the message pane.
- January–December remain fixed horizontal columns.
- Years remain vertical rows.
- Existing activity colours and count-to-colour semantics must remain authoritative.
- Empty months remain visually distinct from populated months.
- Clicking a populated month navigates to the first message in that month for that conversation.
- Selecting a month must not silently alter filtering or conversation membership.
- Search, recovered-message behaviour, conversation filtering, and Show in conversation must remain unchanged unless a shared navigation primitive is intentionally reused.
- Existing unrelated worktree changes must be preserved.
- Avoid broad refactors.

Questions the audit should answer explicitly

- Is the current full Contact heat map already a reusable widget, or is its logic entangled with that page?
- Can conversation heat-map navigation reuse an existing message-jump API?
- If the target month’s first message is not currently loaded, what is the least invasive way to load/position it?
- Should the currently visible month receive a selected outline, or should that be deferred to a later enhancement?
- Should selecting a different conversation collapse the previous one immediately?
- Does row expansion create any layout/scroll problems in the sidebar?
- Is there any reason the selected heat map should differ between the main Conversations page and Contact → Conversations mode?

Planning deliverables

Create the 29-CONVERSATION-HEATMAP folder following the project’s existing feature-folder conventions.

Start with documentation only.

Produce the appropriate planning/audit files used by neighbouring feature folders, including at minimum:

- problem statement
- current architecture findings
- UX behaviour
- assumptions
- hard invariants
- proposed implementation scope
- out-of-scope items
- risks
- test plan
- phased implementation plan

Where useful, reference exact source files, classes, providers, and tests found during the audit.

Do not implement production changes yet unless the repository’s established feature-folder workflow explicitly requires a tiny preparatory edit.

At the end, report:

1. files created in 29-CONVERSATION-HEATMAP
2. architecture findings
3. recommended implementation approach
4. any unresolved decisions that genuinely require Rob’s input
5. expected production files likely to change in the implementation phase
6. git status, including unrelated pre-existing changes
```

I’d particularly want Codex to investigate the **jump-to-month mechanics before touching the UI**. The visual change looks straightforward; the thing most likely to contain hidden complexity is getting from “March 2018” to the correct place in a potentially virtualized 27,000-message conversation without abusing scrolling or loading the entire corpus.
