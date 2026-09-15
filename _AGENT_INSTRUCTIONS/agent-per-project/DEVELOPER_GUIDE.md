---
tier: project
scope: developer-guide
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: doc
links:
  - ./00-START-HERE.md
  - ./01-PROJECT/05-CURRENT-STATE.md
  - ./01-PROJECT/02-architecture-overview.md
  - ./00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md
  - ./40-FEATURES/conversations/README.md
  - ./40-FEATURES/search/INTERACTIONS_AND_NAVIGATION.md
  - ./55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - ./95-WALK-UI-TREE/README.md
  - ./20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md
tests: []
---

# MessageLens Developer's Guide

This is the document to read before working on MessageLens.

It is not a reference manual. It is not a map of every file. It is the mental
model you need before the architecture, UI, and data pipeline start making
sense.

## What MessageLens Is

MessageLens is a personal archive and investigation tool for Apple Messages.

It is not trying to be another chat client. Apple Messages already owns the live
messaging experience. MessageLens is concerned with a different problem:

> How do you understand years of personal communication as evidence, memory,
> relationship history, and recoverable data?

That difference matters. A normal messaging app is optimized for what just
happened. MessageLens is optimized for what happened over time.

The product needs to answer questions like:

- Who was I talking to?
- Which conversation did this message belong to?
- What was happening around this message?
- Which relationships have persisted, faded, revived, or changed shape?
- What message evidence can still be recovered when Apple's local attachment
  cache has been evicted?

The app therefore treats messages as evidence and conversations as historical
objects. The UI is not just a list of bubbles. It is a set of lenses onto a
large personal graph.

## The Most Important Idea

MessageLens is built around derivation.

Source data comes from Apple databases and files. MessageLens imports and
projects that source data into graph form. User intent lives separately in an
overlay database. The UI reads typed projections from those systems.

When something looks wrong, the right fix is usually:

```text
fix derivation, invalidation, ownership, or projection
```

The wrong fix is usually:

```text
add an imperative repair command that patches the visible symptom
```

This principle explains many architectural choices in the project. The app is
meant to remain deterministic under pressure. If the center panel shows stale
content, do not bolt on a "clear" command. Ask why the panel could derive an
invalid view from the current flow state. If a widget needs a name, do not
format a raw handle locally. Ask which identity resolver should have supplied
the display label.

The Architectural Constitution names this the
[Mechanical Impossibility Principle](./00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md#the-mechanical-impossibility-principle):
whenever practical, make an invalid state unable to exist instead of relying on
every caller to detect or clean it up. It is a preference grounded in repeated
project experience, not a claim that imperative cleanup is never necessary.

## The Product Phase Right Now

The current phase is:

```text
Ship MessageLens.
```

The graph migration is no longer the protagonist. The graph system has earned
the right to become infrastructure. New work should now be judged by whether it
moves the product closer to release or improves an active UI/UX walkthrough.

This does not mean architecture no longer matters. It means architecture work
needs a product reason. Hardening, cleanup, tripwire expansion, and
reorganization should normally wait unless they directly unblock release
readiness, archive/recovery correctness, onboarding, data integrity,
user-visible correctness, or an approved UI-walk task.

## The User Experience Vision

The user should experience MessageLens as a calm evidence-reading environment.

The major surfaces are organized around lenses:

- a sidebar selects scope and navigation context
- the center panel presents message evidence or conversation records
- the right panel can show a compatible secondary lens, such as the original
  conversation around a search result

The app should feel coherent across these surfaces. A message should feel like
the same kind of message whether it was reached from Contacts, Conversations,
Search, or a recovered-message view. A Conversation should feel like the same
Conversation wherever it appears.

The UI is currently being reviewed through the `95-WALK-UI-TREE` process. That
process is deliberate: discuss one surface, document the review, plan the
changes, implement the agreed slice, verify, and move on. Do not turn a UI
review into a broad architecture cleanup unless the review reveals a true
ownership problem.

## The Core Mental Model

Think of MessageLens as five cooperating layers:

```text
Apple source reality
-> source-scoped import
-> graph projection
-> overlay intent merge
-> spec-driven UI lenses
```

Each layer has a different job.

Apple source reality is what exists in `chat.db`, AddressBook, and the Messages
attachments folder. It is external, messy, incomplete, and not under our
control.

Source-scoped import preserves source facts with stable provenance. It should
not decide final user meaning.

Import scale must not determine process memory. Message copy freezes a
source-row high-water mark and commits keyset pages; attributed-body enrichment
uses its own frozen `ss_id` frontier, metadata-only pages, byte-bounded BLOB
subpages, and a resource-limited native decoder. Their durable frontiers are
separate. The source-scoped `ss_id` carried from selection through persistence
is the identity that makes that separation safe. See
`./20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md`.

Graph projection turns source facts into the app's ordinary working graph:
messages, handles, contacts, conversations, topology, and evidence paths.

Overlay intent stores what the user decides: favourites, display-name
overrides, dismissals, manual links, visibility decisions, archive metadata, and
other app-owned state. Overlay is not a projection. It must survive rebuilds.

The UI should read typed scopes, specs, payloads, and view models. It should not
query databases directly, reconstruct graph topology, or decide semantic policy
inside widgets.

## Data Flow

The ordinary app-facing data path is:

```text
chat.db / AddressBook
-> macos_import_ss.db
-> working_ss.db
-> graph read models
-> Message Evidence Spine
-> overlay intent merge
```

The old `macos_import.db` and `working.db` files are retired compatibility and
diagnostic storage. They are not ordinary app authorities. Do not add new
features that depend on them as live sources of truth.

The physical database providers are centralized under the database essential.
Feature code should consume named providers, repositories, or semantic services.
It should not construct long-lived database instances for itself.

Raw SQL is not automatically wrong. Raw SQL in a named infrastructure
repository can be acceptable when it is quarantined behind a typed method. Raw
SQL in presentation, application coordinators, or widgets is usually an
ownership failure.

## Conversations, Messages, Contacts, and Identity

These words are easy to blur. Do not blur them.

A **Message** is an evidence record. It belongs in the Message Evidence Spine
once the app has decided to show it.

A **Conversation** is a canonical graph entity. It can appear in the
Conversation browser, Contact pages, Favourites, Search context panels,
Discovery views, and future Working Sets. These are different lenses onto the
same Conversation, not local copies.

A **Contact** is app-known identity derived from AddressBook and graph topology,
possibly refined by overlay user intent. A contact is not merely a string from
AddressBook and not merely a handle.

A **Handle** is an endpoint: a phone number, email, or source identifier. Handles
are important, but they are not people. A known contact should be displayed by
the user-approved display identity, not by a raw handle, except in explicitly
handle-focused workflows.

The identity rule is semantic:

> The resolver answers "what should the user see?", not "which database row owns
> this string?"

For known people, user display-name override wins. Then app-known contact
identity. Then imported AddressBook display name. Raw handle is fallback, not
the primary label for a known person.

The local user is the important exception to that ordinary precedence. When a
canonical handle is marked `is_me`, MessageLens speaks in the first person:
`Me` in participant titles and lists, `me` in prose-like message metadata, and
`self` for a Conversation containing only the user. Imported personal names
and local endpoints remain provenance, not ordinary relationship labels. This
is resolved centrally from graph identity; widgets must never infer it by
matching a name.

## One Conversation

There is only one Conversation.

This principle is more than wording. It affects UI, overlay state, and feature
ownership. If the user favourites a Conversation in one place, the same
Conversation should appear favourited everywhere. If a Conversation Card appears
in the sidebar and in a right-side excerpt panel, those are manifestations of
the same graph entity.

This is why Conversation presentation belongs to `features/conversations`.
Messages can render message evidence inside a Conversation lens. Search can
request a Conversation excerpt around a hit. But Search does not own the
Conversation panel, and Messages does not own the Conversation Card.

## Message Evidence

The Message Evidence Spine is the canonical path for showing messages.

Different surfaces can select different message scopes:

- all messages from a contact
- one handle for a contact
- a conversation
- global search results
- a bounded conversation excerpt around a search hit
- recovered-message pools
- future themes, tags, or working sets

Those scopes may differ in how they select messages and how they explain the
scope in the header. Once the app means "show these messages as evidence", the
rendering path should converge.

The spine preserves the full logical message universe for timeline-like scopes.
It builds a lightweight skeleton first, then hydrates visible rows and media
near the viewport.

The crucial rule is:

```text
pagination is not timeline navigation
```

A latest-500 batch is not equivalent to a timeline. Heatmaps, month jumps,
match navigation, and anchor scrolling need a full lightweight skeleton even
when message bodies and attachments hydrate lazily.

Source-specific scopes are allowed. Source-specific message renderers are not.

## Search, Browse, and Discovery

MessageLens distinguishes modes of interaction.

Search is for finding something already known. The user has a term, a person, a
date, or a clue and wants evidence.

Within Search All Messages, the current investigation is primary state. A
selected result and its right-side Conversation excerpt are subordinate to the
particular investigative episode that created them. The excerpt may remain
stored while the user temporarily navigates elsewhere, but it renders only
while its opaque originating identity remains compatible with the current
investigation. Query edits, mode changes, and month browsing therefore do not
issue imperative panel cleanup: effective presentation is derived from
compatibility.

Browse is for navigating a collection the user broadly understands, such as
Contacts or Conversations.

Discovery is for surfacing information the user did not know to ask for. Dormant
conversations, oldest-starting conversations, longest-running spans, and future
seasonal or rekindled views belong here.

Conversation organization modes are internally called Conversation Lenses. The
UI should usually say "Organize by", not "Lens". A lens is more than a sort
order: it changes ordering and emphasizes the value that explains why an item is
where it is. Orange highlighting means "this is the comparison value for the
current lens"; it does not inherently mean warning, date, or recency.

MessageLens should eliminate confusion but preserve curiosity.

## Graph Architecture

The graph exists because the source data is not shaped like the user's mental
model.

Apple stores raw messages, handles, chats, attachment rows, and joins. The user
thinks in people, conversations, evidence, context, and history. The graph is
the bridge.

`essentials/conversation_graph` owns graph projection, graph facts, source-scoped
identity, build lifecycle, and graph read primitives. It should not own
user-facing Conversation widgets.

`features/conversations` owns user-facing Conversation identity presentation:
cards, timeline glyphs, favourites, collections, and excerpt panels.

That split is intentional. The graph tells us what is true about topology. The
feature tells the user what a Conversation is.

## Overlay Philosophy

The overlay database stores user intent and app-owned durable state. It is
separate from source import and graph projection.

This separation is non-negotiable:

- import does not consult overlay
- graph projection does not consult overlay
- user actions do not write to graph projection tables
- providers and read models merge graph facts with overlay intent at read time
- overlay wins on conflict

This prevents a class of bugs where rebuildable projection data accidentally
absorbs user decisions and later loses them during rebuild.

If a user renames a contact, favourites a Conversation, dismisses an unknown
handle, or writes archive metadata, that belongs in overlay-backed state, not in
source-scoped projection tables.

## Attachment Archive and Recovery

Apple treats the Messages attachments folder as a cache. MessageLens cannot
trust it as a durable store.

That is why MessageLens maintains an app-owned attachment archive. The live
Messages attachment path is an ingestion source. The MessageLens archive is the
display source when archive mode is enabled.

Recovery is about attachment reachability, not preserving the old legacy
database shape. Historical `chat.db` backups and matching attachment folders can
be used to map source relationships and recover files. Retired
`macos_import.db` and `working.db` are not meant to become permanent reference
databases.

The critical path is:

```text
graph identity
-> source identity
-> archive/recovery location
-> attachment retrieval
```

Do not solve archive problems by making ordinary app behavior depend again on
retired legacy databases.

## UI Architecture

MessageLens uses specs to move intent across surfaces.

The canonical pipeline is:

```text
Spec -> Coordinator -> Resolver -> Payload / ViewModel -> Rendering
```

Specs describe intent. Coordinators route. Resolvers interpret. Payloads and
view models carry typed data. Rendering builds widgets at the edge.

Do not use widgets as state. Do not have a feature construct another feature's
UI. Do not have a widget query a database to decide meaning. Do not mutate
another panel directly because it is visually convenient.

Stored panel state is not automatically visible panel state. Navigation derives
an effective stack from current flow and investigation compatibility. A stored
presentation may survive temporary incompatibility for restoration, but an
incompatible presentation must never remain effective. Fix the compatibility
rule rather than scattering `clear`, `close`, or `dismiss` commands.

The sidebar is navigation and scope selection. The center panel is the primary
evidence surface. The right panel is a secondary compatible lens when needed.

The current UI walk is also establishing a shared page rhythm: panels should
feel like coordinated workspaces, not unrelated columns. This is design work,
but it rests on the same architectural principle: the page owns layout grammar;
components own their presentation within that grammar.

## Where New Functionality Should Live

Start by asking what kind of responsibility the work has.

If it is app-level orchestration, panel routing, sidebar topology, database
provider construction, global flow state, graph lifecycle, or shared search
infrastructure, it probably belongs under `essentials`.

If it is user-facing domain content for a business concept, it probably belongs
under `features`.

If it is user-facing Conversation presentation, it belongs in
`features/conversations`.

If it is message evidence rendering, evidence scopes, row hydration, headers,
attachments inside message rows, or timeline behavior, it belongs in
`features/messages` and should flow through the Message Evidence Spine.

If it is source graph facts, projection, topology, or build lifecycle, it
belongs in `essentials/conversation_graph`.

If it is durable user intent, it belongs in overlay-backed services and should
be merged at read time.

If it is a new UI/UX change, start with the UI-walk process. Review the surface,
write or update the review document, create an action plan, implement the agreed
slice, and verify.

## How New Features Should Be Added

The `45-NEW-FEATURE-ADDITION` folder is the project's working notebook.

Use it for self-contained feature packages: proposals, design notes,
architectural rationale, implementation plans, checklists, tests, experiments,
and retrospectives.

Do not treat it as the canonical description of how the app currently works.
Many of its documents are historical because successful ideas were later
promoted into canonical architecture, feature, database, or UI docs.

When adding a feature:

1. Identify the owner: essential, feature, database, UI surface, or archive
   system.
2. Check the canonical docs for that owner.
3. If the work is exploratory or substantial, create a focused plan under
   `45-NEW-FEATURE-ADDITION`.
4. Keep implementation scoped to the agreed plan.
5. When a concept becomes settled, promote the durable rule into its canonical
   owner document instead of leaving it only in the notebook.

## Common Mistakes To Avoid

Do not add a feature-local message renderer. Add or reuse a
`MessageEvidenceScope` and enter the shared evidence spine.

Do not make Search own Conversation UI. Search can request a Conversation
excerpt. Conversations renders the Conversation lens. Messages renders the
message rows.

Do not store user intent in graph projection tables. Put it in overlay and merge
at read time.

Do not treat raw handles as contact identity. Handles are endpoint metadata.

Do not build a one-off database provider inside a feature. Use centralized
database providers or named repository boundaries.

Do not import a feature's own `feature_level_providers.dart` from inside that
same feature. Public provider seams are for external consumers.

Do not fix stale UI by adding imperative clearing or repair calls. Fix the state
derivation that allowed stale content to exist.

Do not infer current architecture from an old proposal in
`45-NEW-FEATURE-ADDITION`. Check whether the concept has a canonical owner.

Do not continue hardening because it is interesting. In the current phase, ask
whether it helps ship.

## How To Read The Documentation

After this guide, read:

1. `00-START-HERE.md` for the current documentation map.
2. `01-PROJECT/05-CURRENT-STATE.md` for the current phase and active ownership.
3. `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md` for the
   non-negotiable architecture rules.
4. `01-PROJECT/02-architecture-overview.md` for the high-level code ownership
   map.
   V
   Use `DOCUMENTATION_OWNERSHIP_AUDIT.md` when you are unsure which document owns a
   concept.

Use `45-NEW-FEATURE-ADDITION/INDEX.md` and
`55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md` before treating documents
in those large historical folders as current guidance.

## Final Orientation

MessageLens is at its best when architecture and product reinforce each other.

The architecture exists because the product needs durable personal evidence,
recoverable media, stable identity, source provenance, and calm navigation
across years of messages. The UI exists to let the user understand that
evidence without having to know the machinery underneath.

When contributing, preserve that relationship.

Do not make the architecture the protagonist.
Do not make the UI a pile of local exceptions.

Build the next piece so that the user sees a clearer lens onto the same
underlying graph.
