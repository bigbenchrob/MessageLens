# 30 - Essentials

Essentials contains app-level systems that coordinate surfaces, durable flow,
shared infrastructure, and shell behavior. It is not a dumping ground for
feature logic.

This folder is currently a high-level entry point, not yet a full subsystem
doc set.

For spec-driven surface work, read this folder together with
[`../42-SPEC-SYSTEM/`](../42-SPEC-SYSTEM/). The canonical pipeline is:

```text
Spec → Coordinator → Resolver → Payload / ViewModel → Rendering
```

## TL;DR

Essentials owns app orchestration. Features provide domain content and approved
feature-owned spec interpretation.

Essentials owns:

* global flow state and app mode
* sidebar cassette rack projection and topology dispatch
* panel stacks, panel surface orchestration, and sidebar parking
* typed Onboarding Journey coordination, durable operation/recovery truth,
  onboarding overlay lifecycle, and readiness-panel sync
* shared graph search service and evidence selection infrastructure
* app shell, window state, logging, database infrastructure, source-scoped
  import, conversation graph build, retired-file diagnostic boundaries,
  and shared cross-cutting services

Features must not take ownership of app-level orchestration, global flow state,
panel stack policy, sidebar topology, shared chrome, or cross-surface
reconciliation.

## Current Essentials Structure

Current `lib/essentials/` top-level areas include:

| Area | Current responsibility |
| --- | --- |
| `navigation/` | App shell, active sidebar mode, center/right panel stacks, `ViewSpec` routing, sidebar parking, panel host widgets. |
| `sidebar/` | `CassetteSpec`, stable cassette rack projection, ephemeral cassette projection, topology dispatch, cassette payload resolution, shared sidebar rendering. |
| `search/` | Shared graph message search service, evidence selection, and retired search bridge handling where explicitly documented. |
| `onboarding/` | Sole typed Journey coordination, Full Disk Access/readiness evidence, persisted operation stage/substage and recovery truth, onboarding overlay lifecycle, and preservation-safe reset/recovery orchestration. |
| `presence/` | Generic Schedule, Trip, Step, routing, checkpoint, run, trace, and persistence machinery. It does not semantically own workflows merely because their definitions are stored in `presence.db`. |
| `db/` | Centralized physical database providers, app database filename registry, and database infrastructure. |
| `source_scoped_import/` | Production source-scoped import semantics, ledger schema, frozen-window/keyset-paged message import, byte-bounded `ss_id` rich-text enrichment, and Historical Archives source ingestion; physical DB provider construction remains in `db/`. |
| `conversation_graph/` | Production graph projection/build/read semantics for the conversation graph projection; physical graph DB provider construction remains in `db/`. |
| Retired `db_importers/` | Removed. Source-scoped importers live in `source_scoped_import/`; live `chat.db` monitoring and graph lifecycle work live in `conversation_graph/`; retired-file diagnostics live in `db/`. |
| Retired `db_migrate/` | Retired projection cleanup context only; no active app provider or service. |
| `logging/` | Application logging and diagnostic export support. |
| `window_state/` | Window persistence and platform window-management services. |
| `config/`, `debug/`, `services/`, `tooltips/`, `contacts/` | Shared app infrastructure and smaller cross-cutting systems. |

Do not infer feature ownership from an import path alone. Some feature-specific
content is routed through essentials because essentials owns the surface.
Path location alone does not determine architectural ownership; some
contact-related logic is shared infrastructure while other contact-related
logic remains feature-owned.

The current generic Boolean Test boundary is recorded in the
[`Presence TestStep consolidation audit`](../45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md).
Presence persists opaque Agent identities and generic Test routing; workflow
owners supply concrete Agents through application composition.

## Global Flow State

`sidebar/application/sidebar_flow_state_provider.dart` is the current durable
flow-state owner for the messages/sidebar flow.

It records durable semantic state such as:

* active top menu branch
* chosen contact
* selected handle
* persistent settings context
* optional scroll target
* regular vs recovered message scope

It also projects flow-managed center-panel specs through
`SidebarFlowState.projectedCenterSpec`.

Rules:

* Durable flow meaning belongs in semantic state, not rendered widgets.
* Do not reconstruct durable meaning by scanning built sidebar widgets.
* Do not treat the cassette rack as the source of durable truth.
* When flow changes, incompatible center/right panel content must cease to be
  effective. Stored panel state may remain available for later restoration;
  visibility and downstream projections must derive from effective state.
* Transient settings actions must not be stored in persistent flow state.

## Sidebar Topology And Cassette Rack

The sidebar is a specialization of the spec system.

Current shape:

* `CassetteSpec` is the essentials-owned top-level sidebar spec.
* Feature-owned inner specs are wrapped by `CassetteSpec` variants.
* `CassetteRackState` owns the stable ordered rack per `SidebarMode`.
* `cascade/` owns pure parent-to-child topology.
* `EphemeralCassetteProjection` appends temporary cassette projections after
  the stable rack.
* `RenderableSidebarCassetteSpec` combines stable and ephemeral projection for
  resolution.
* `CassetteWidgetCoordinator` resolves specs into `SidebarCassettePayload`.
* `sidebar_cassette_render_router.dart` performs the terminal widget rendering
  from resolved payloads.

Topology must answer only:

```text
current spec + minimal durable context -> next spec or null
```

It must not procedurally rebuild whole branches, infer state from rendered
widgets, read repositories, watch providers, or perform UI work.

Stable and ephemeral projection are separate:

* Stable rack state represents reconstructable sidebar projection.
* Ephemeral projection represents temporary action flows such as settings
  actions.
* Visible order is stable cassettes first, then ephemeral cassettes.
* Ephemeral behavior must not leak into stable rack or global flow state.

Essentials owns shared sidebar chrome, sectioning, render-kind routing,
placement constraints, expansion behavior, and pinned controls. Features may
provide payload data and approved body content inside that envelope.

## Panel Stack And Panel Content Orchestration

`navigation/domain/entities/view_spec.dart` defines the current top-level
panel navigation currency:

* `ViewSpec.messages`
* `ViewSpec.conversations`
* `ViewSpec.settings`
* `ViewSpec.environmentReadiness`
* `ViewSpec.onboarding`

`PanelsViewState` owns center/right panel stacks per `SidebarMode`.
`panel_widget_providers.dart` derives effective center/right panel stacks,
projects flow-managed center content from `SidebarFlowState`, parks the sidebar
for sidebar-independent specs, and hides incompatible right-panel content.

Stored and effective panel state are intentionally different. A stored spec
records a request that may remain useful after temporary navigation. The
effective stack contains only stored specs compatible with the current flow or
investigation. Callers must not delete stored specs merely to repair missing
compatibility derivation.

Panel rules:

* Panel state stores `ViewSpec`, not arbitrary widgets.
* Flow-managed messages panels are projections of global flow state.
* Environment readiness and onboarding specs are explicitly
  sidebar-independent and can park the normal sidebar. Other system flows
  should declare sidebar independence explicitly in their current spec model.
* Right-panel content is subordinate to center-panel compatibility.
* Panel visibility and message anchors must consume effective panel state, not
  the raw stored stack.
* Features may interpret their approved inner specs, but essentials owns panel
  stack policy and cross-surface reconciliation.

### Legacy/current-state panel boundary

Current `PanelCoordinator` and some feature view-spec coordinators still return
widgets synchronously. This is a current implementation and migration boundary,
not an approved pattern for new work.

New panel work must preserve the canonical data boundary:

* coordinators route specs and return structured data, payloads, or view models
* feature resolution remains distinguishable from widget construction
* rendering remains terminal and downstream
* no new widget-returning coordinator pattern should be introduced or spread

When changing existing panel code, preserve runtime behavior unless the task
explicitly includes migrating the panel coordinator boundary.

## Search Ownership

Search infrastructure is essentials-owned.

Current essentials search responsibilities:

* `SearchService` searches global, contact, conversation, handle, saved, and
  tagged graph message scopes.
* Search selection returns graph `message_ss_id` evidence scopes.
* Search reads graph evidence through the conversation graph/search boundaries
  and merges overlay user intent where applicable.

Feature responsibilities are narrower:

* `features/messages` owns timeline UI/search query state for message views and
  calls the essentials search service.
* `features/messages` owns the opaque generation identifying the current
  Search All Messages investigation. Query mutations, AND/OR changes, and
  month browsing advance that generation.
* contacts-specific picker filtering remains feature-local where it is not the
  shared message search/indexing system.

Search-created subordinate presentations carry that investigation identity as
opaque provenance. Generic navigation may compare the identity for equality
when deriving effective panel state, but it must not understand query text,
search modes, heatmaps, or result structure. Conversations may carry the
identity on an excerpt request but does not generate or interpret it.

Do not create a separate feature-level message search infrastructure that
competes with `lib/essentials/search`.

## Onboarding Ownership

Onboarding lifecycle is essentials-owned.

Current essentials onboarding responsibilities:

* `OnboardingJourneyCoordinator` is the sole authority that selects and
  advances the typed Onboarding Episode.
* `OnboardingGate` is a read-only compatibility projection and action
  forwarding seam; it is not a second state-transition authority.
* `OnboardingOverlay` owns the blocking overlay lifecycle for graph build,
  reimport, completion, and recovery.
* `OnboardingCenterPanelSyncObserver` synchronizes FDA/user-action onboarding
  states into the center panel with `ViewSpec.environmentReadiness`.
* `OnboardingOperationSnapshot` persists exact stage/substage, aggregate
  progress, interruption, failure, and recovery evidence across launches.

Presence is a separate essential. It owns how workflow definitions are stored,
assembled, executed, routed, checkpointed, and traced. It does not own the
business meaning of onboarding, archive ingestion, or future workflows.
* `OnboardingStatus` and environment reports remain compatibility/coarse
  classification vocabularies. They do not erase exact interrupted substage
  evidence.

The `features/environment_readiness` feature owns readiness panel content for
the approved `EnvironmentReadinessSpec`. It does not own the onboarding gate,
app shell overlay policy, active sidebar mode, or panel stack orchestration.

## Essentials vs Feature Boundaries

Essentials may:

* define top-level specs such as `CassetteSpec` and `ViewSpec`
* own app mode, global flow state, panel stacks, sidebar racks, shared chrome,
  and shell behavior
* route top-level specs to feature-owned coordinators
* reconcile sidebar, panel, onboarding, and related surfaces
* provide shared infrastructure such as search, logging, database providers,
  source-scoped import, graph build, retired storage cleanup/diagnostic
  boundaries, and window state

Features may:

* define feature-owned inner specs
* interpret their approved spec variants
* resolve domain data and return payloads/view models
* render terminal feature content inside essentials-owned surface contracts
* keep local UI state that does not compete with durable app flow

Features must not:

* own global flow state or active app mode
* own cassette rack topology or panel stack policy
* introduce new widget-returning coordinator patterns
* mutate cross-surface state outside approved essentials APIs
* bypass `ViewSpec` for panel navigation
* bypass `CassetteSpec` and payload resolution for sidebar content
* smuggle rendering callbacks, `BuildContext`, `WidgetRef`, controllers, or
  widgets through payloads/view models

## Cross-Surface Coordination Rules

For any work touching sidebar, panels, onboarding, settings, or search-driven
navigation, use the canonical spec architecture:

* [`../42-SPEC-SYSTEM/README.md`](../42-SPEC-SYSTEM/README.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/10-cross-surface-model.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/10-cross-surface-model.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

If older docs describe a feature owning app-level orchestration, a panel
coordinator returning widgets as the desired pattern, or a sidebar rack acting
as durable truth, treat that wording as legacy/transitional unless current code
and canonical architecture explicitly confirm it.
