---
tier: feature
scope: message-display-flow-walkthrough
owner: agent-per-project
links:
	- ./DOMAIN_AND_DATA_MAP.md
	- ./INTERACTIONS_AND_NAVIGATION.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: messages
doc_type: walkthrough
status: active
last_updated: 2025-12-24
---

# Message Display Flow Walkthrough (Contact Messages)

This is the *human-readable* walkthrough of how message display works today.
It’s written to answer the question: **“If I open Messages for a contact, what code runs, in what order, and why is it split up this way?”**

This doc is canonical for the **contact messages** path:
- ✅ `MessagesSpec.forContact(...)` is the real implementation.
- ⚠️ Chat-specific message UI was intentionally hard-deleted (stubs may remain in navigation/coordinator).

## Organization

The code is organized around a **central view model** that exposes a small, cohesive API to the view.
Everything else is a helper behind that facade.

Think of the layout like this:

- **View (dumb):** renders a list and binds inputs.
- **View model (coordinator):** owns UI state (search), watches ordinal state, and triggers jumps.
- **Jump/ordinal helper:** computes list size + owns scroll controllers + provides jump helpers.
- **Hydration helper:** turns an `ordinal` into a fully-formed `ChatMessageListItem`.

## Key files & folders

### View

- `lib/features/messages/presentation/view/messages_for_contact_view.dart`

Responsibilities:
- Displays the header, search field, and either:
  - the **ordinal timeline list**, or
  - the **search results list**.
- Delegates navigation behaviors to the VM (`jumpToLatest`, `jumpToMonthForDate`).
- Delegates per-row data loading to the hydration provider.

### View model (the hub)

- `lib/features/messages/presentation/view_model/contact_messages/contact_messages_view_model.dart`

Responsibilities:
- The single place you should look first.
- Owns the `TextEditingController` and the debounce `Timer`.
- Exposes:
  - `ordinal` (AsyncValue of the ordinal/jump state)
  - search-related state (`debouncedQuery`, `searchResults`, `isSearching`)
  - jump methods: `jumpToLatest`, `jumpToMonthKey`, `jumpToMonthForDate`

Why this exists:
- Previously, “how messages work” could feel scattered across many providers.
- The VM is a deliberate *facade* so the view depends on one thing.

### `jump/` folder (ordinal + scrolling + jumps)

- `lib/features/messages/presentation/view_model/contact_messages/jump/contact_messages_ordinal_provider.dart`

Responsibilities:
- Defines the concept of a **skeleton list**:
  - `totalCount` (how many items exist)
  - `ItemScrollController` + `ItemPositionsListener` for `ScrollablePositionedList`
- Implements “jump” behavior:
  - `jumpToLatest()`
  - `jumpToMonth(monthKey)`

Mental model:
- This layer knows *where* to scroll, but does not load message bodies.

### `hydration/` folder (ordinal → message)

- `lib/features/messages/presentation/view_model/contact_messages/hydration/message_by_contact_ordinal_provider.dart`

Responsibilities:
- Given `(contactId, ordinal)`, produce a **fully hydrated** `ChatMessageListItem`.
- Internally maps:
  1) `ordinal` → `messageId` (via the contact-message index)
  2) `messageId` → message joins/projection → `ChatMessageListItem`

Mental model:
- This layer knows *what to render* for a given row.

## Steps in display of a fully hydrated message

This is the “movie” from user action → pixels.

### 1) User opens “Messages for Contact”

Entry point:
- The center panel shows `MessagesForContactView(contactId: ...)`.

First provider read:
- The view watches `contactMessagesViewModelProvider(contactId: ...)`.

### 2) Data retrieval: build the skeleton list (fast)

Goal:
- Get something on screen quickly without loading every message.

Mechanism:
- The view model watches:
  - `contactMessagesOrdinalProvider(contactId: ...)`

That provider returns:
- `totalCount`
- scroll controllers/listeners

UI effect:
- The view builds `ScrollablePositionedList.builder(itemCount: totalCount)`.
- At this point, rows exist by index, but message content is not yet loaded.

### 3) Hydration: as rows come into view, load their message data

Goal:
- Make it *feel* like the full list is already there, while only loading what’s needed.

Mechanism:
- Each list row widget watches:
  - `messageByContactOrdinalProvider(contactId: ..., ordinal: ...)`

That hydration provider performs (conceptually):
- `ordinal → messageId → joins → ChatMessageListItem`

UI effect:
- As you scroll, only the visible ordinals (and a few around them) are hydrated.

### 4) Navigation and jumps: default positioning and later movement

#### Initial positioning

Goal:
- Start the user somewhere sensible.

Mechanism (in `messages_for_contact_view.dart`):
- Post-frame:
  - if `scrollToDate != null`: `vm.jumpToMonthForDate(scrollToDate)`
  - else: `vm.jumpToLatest()`

Why post-frame:
- Avoids list “rebuild quirks” while controllers are attaching.

#### Continuous scrolling

Goal:
- Seamless “infinite list” feel.

Mechanism:
- `ScrollablePositionedList` builds rows on demand.
- Each row independently hydrates via the `messageByContactOrdinalProvider`.

Important considerations:
- **Jitter prevention:** hydration must not radically change row height.
  - Example from earlier fixes: placeholders should use a consistent, fixed height.
  - When a placeholder becomes a rich preview (image/site preview), keeping height stable avoids scroll jump.

### 5) Searching (switches the UI mode)

Goal:
- Search within “messages with this contact”.

Mechanism:
- The search text field uses `vm.searchController`.
- VM debounces input and loads results via:
  - `contactMessageSearchResultsProvider(contactId: ..., query: ...)`

UI effect:
- When `vm.isSearching == true`, the view shows a normal `ListView` of results instead of the ordinal timeline.

## Jumping (heatmap month selection)

Common scenario:
- The user clicks a month in a heatmap / month selector.

Mechanism:
- The UI calls:
  - `vm.jumpToMonthKey('YYYY-MM')`

Under the hood:
- `ContactMessagesViewModel.jumpToMonthKey` delegates to:
  - `contactMessagesOrdinalProvider(...).notifier.jumpToMonth(monthKey)`

Why this is smooth:
- The ordinal provider owns the list scroll controller and can jump by index.
- Hydration then fills in the rows at the destination as they become visible.

## “Where do I look first?” (quick triage)

- **Something wrong with scroll/jumps/count:** start at `contact_messages_ordinal_provider.dart`.
- **A row shows the wrong message / missing data:** start at `message_by_contact_ordinal_provider.dart` and the index data source.
- **Search weirdness / repeated rebuild issues:** start at `contact_messages_view_model.dart` (controller lifecycle + debounce).
- **UI rendering glitches:** start at `messages_for_contact_view.dart` (view should remain mostly dumb).

## Related docs

- Data structures + monthKey format: `./DOMAIN_AND_DATA_MAP.md`
- High-level flows: `./INTERACTIONS_AND_NAVIGATION.md`
- Complete provider list (agent-oriented): `./STATE_AND_PROVIDER_INVENTORY.md`
