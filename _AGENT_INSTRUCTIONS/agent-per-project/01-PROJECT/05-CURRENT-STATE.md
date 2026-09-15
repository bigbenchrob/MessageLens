---
tier: project
scope: current-state
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: doc
links:
  - ./02-architecture-overview.md
  - ../40-FEATURES/README.md
  - ../55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md
  - ../95-WALK-UI-TREE/README.md
  - ../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md
  - ../65-DISTRIBUTION/10-render-tester-portal.md
  - ../45-NEW-FEATURE-ADDITION/32-TESTER-ARCHIVE-IMPORT-FAILURE/13-PHASE-4-AND-RELEASE-QUALIFICATION.md
tests: []
---

# Current State

This document is a short orientation snapshot for agents entering the project.
It does not replace the subsystem docs. It identifies which architectural
direction is current and which older terms should be treated as historical.

## Project Phase

MessageLens is now in a product-shipping and UI/UX walk phase.

The graph migration is no longer the primary objective. The graph architecture
has become infrastructure that supports the product. New work should be judged
primarily by whether it advances release readiness, archive/recovery
correctness, onboarding, readiness evaluation, user-visible correctness, or the
active UI walk.

Do not perform opportunistic architecture hardening merely because a cleaner
internal shape is possible. Defer hardening unless it directly unblocks a
release, data-integrity, archive/recovery, onboarding, readiness, or UI-walk
goal.

## Current Data Spine

The ordinary app-facing data path is:

```text
chat.db / AddressBook
-> macos_import_ss.db
-> working_ss.db
-> graph read models
-> Message Evidence Spine
-> overlay intent merge
```

Retired `macos_import.db` and `working.db` files are transitional cleanup and
diagnostic inventory only. They are not ordinary app authorities. If remaining
archive/recovery work needs information that historically lived in those files,
that information should be migrated, exported, or explicitly rejected through
the retained-storage plan rather than re-establishing legacy database
authority.

Source-scoped message ingestion no longer materializes a whole eligible corpus.
Each run freezes a source-row high-water mark, imports keyset pages in bounded
transactions, and continues from the greatest durably committed source row.
Attributed-body enrichment is a separate bounded stage: it freezes an eligible
`ss_id` high-water mark, pages metadata without BLOBs, fetches byte-bounded
subpages, and persists decoded text against the same source-scoped identity.
Malformed, empty, or oversized records remain represented and diagnosable; one
record must not turn archive size into process memory growth. The complete
contract is in
`../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md`.

Onboarding persists the exact import/projection substage separately from its
coarser readiness classification. After interruption it can therefore offer
`Continue Setup` at the durable frontier instead of treating every interrupted
graph build as an indistinguishable failure.

## Current Feature Ownership

`features/conversations` is the canonical user-facing Conversation feature.
It owns Conversation identity presentation: Conversation cards, timeline
signature glyphs, Favourites/Core Favourite affordances, Conversation
collections, and Conversation excerpt panels.

`essentials/conversation_graph` owns graph projection, graph facts, graph read
primitives, and lifecycle/build infrastructure. It must not become the owner of
user-facing Conversation widgets.

`features/messages` owns message evidence presentation: message evidence
scopes, timeline skeleton/hydration behavior, message headers, message rows,
attachment evidence rendering, and message-search-in-scope controls. It may
consume Conversation presentation, but it must not define Conversation cards or
Conversation identity UI.

`essentials/search` owns shared graph search infrastructure and evidence
selection. `features/messages` owns Search All Messages query/mode interaction
and the opaque generation identifying its current investigation. Search can
request a Conversation excerpt around a message, but the Conversation feature
renders the Conversation panel and only carries the originating investigation
identity as opaque provenance.

Older `chats` terminology is historical. Current user-facing work should use
Conversation terminology unless a document is explicitly describing legacy or
source database concepts.

## Message Evidence Spine

MessageLens now has one canonical message evidence surface. Different sources
may produce different `MessageEvidenceScope` values, but source-specific scopes
must converge on the same skeleton, hydration, search, attachment evidence, and
row rendering path.

Hard rules:

- Source-specific scopes are allowed; source-specific evidence presentation is
  not.
- Timeline-like scopes preserve the full selected logical message universe even
  when row hydration and media loading are windowed.
- Pagination is not timeline navigation.

## Conversation Identity

There is only one Conversation.

A Conversation may appear in the Conversation browser, Contact pages, Search
results, Favourites, Discovery views, or a right-side excerpt panel, but those
are lenses onto the same graph entity. User actions on the Conversation, such
as toggling Favourite, should affect the same Conversation everywhere.

Local-account identity is also a graph fact. At startup, the source-scoped
graph lifecycle reconciles historical Apple Messages account and incoming
destination evidence against canonical handles, then projects only changed
`is_me` annotations. This does not reimport messages. Conversation read models
use that fact to identify self-conversations; presentation must not guess from
names or message direction. The shared display resolver now applies this fact
across ordinary Conversation, Contact, handle, and message-evidence read
models, using `Me` for participants, `me` in prose metadata, and `self` for a
self-only relationship.

## Search Investigation Compatibility

Search All Messages separates stored subordinate context from effective
presentation. Query edits, query clearing, AND/OR changes, and heatmap month
browsing advance an opaque `SearchInvestigationId`. Conversation excerpts
opened from Search retain the identity that created them.

Generic navigation derives whether the stored excerpt is effective by checking
that Search All Messages is active and the originating identity still equals
the current identity. It does not interpret Search values. Temporary navigation
away and back can therefore restore unchanged context, while a new
investigation makes old context ineffective without deleting it.

The end sidebar, selected-message anchor, and Conversation excerpt visibility
must consume effective panel state. Do not clear these imperatively from query,
mode, or heatmap actions.

## UI Walk

The active UI/UX review process lives in `../95-WALK-UI-TREE/`.

The UI walk is product work, not architecture cleanup. It should improve
clarity, discoverability, consistency, and workflow while preserving existing
architecture unless the review explicitly identifies an ownership or
presentation boundary problem.

The current layout direction includes:

- sidebar as navigation and scope selection
- center panel as message/conversation evidence
- right panel as compatible secondary lens, such as a Conversation excerpt
- page-level vertical rhythm using shared column bands where appropriate
- Conversation Lenses and `Organize by` terminology for conversation browsing

## Current Tester Distribution State

`0.2.111+129` is the currently published tester build. The portal received the
already-qualified, notarized DMG without rebuilding; the published bytes retain
SHA-256
`5f2313eb8526b23981396f376552259ba924d69d3d9336097f52538c34039e35`.
This is publication evidence, not a completed low-memory hardware gate. The
ordinary-load run on the intended low-memory target Mac remains outstanding,
and the original incident reporter has not performed the retry.

See `../65-DISTRIBUTION/10-render-tester-portal.md` for publication evidence and
`../45-NEW-FEATURE-ADDITION/32-TESTER-ARCHIVE-IMPORT-FAILURE/13-PHASE-4-AND-RELEASE-QUALIFICATION.md`
for the qualification boundary.

## When A Bug Appears

Fix derivation, invalidation, ownership, or projection.

Do not add imperative repair logic unless the review explicitly accepts it as a
temporary compatibility bridge with removal criteria.
