# Cross-Surface Spec System — Single Source of Truth (Authoritative)

This document defines the non-negotiable rules governing the Cross-Surface Spec System.
These rules exist to eliminate ambiguity, prevent ad-hoc solutions, and make automated
agents incapable of “creatively” re-interpreting the architecture during migration.

Any new code or refactor that violates these rules is incorrect by definition.

================================================================
1. PURPOSE
================================================================

The Cross-Surface Spec System exists to:

• Coordinate navigation and sidebar composition across multiple features
• Preserve strict ownership boundaries between essentials and features
• Ensure all feature logic resolves to a single, uniform payload
• Eliminate wrapper types, hybrid flows, and implicit state passing
• Support async resolution without architectural branching

This system is explicitly designed to be boring, explicit, and uniform.

================================================================
2. DEFINITIONS (TERMS ARE PRECISE)
================================================================

CassetteSpec
  A sealed specification describing what cassette should appear.
  May wrap a feature-specific spec.

FeatureCassetteSpec
  A sealed specification owned by a feature. Interpreted only by that feature’s coordinator.
  FeatureCassetteSpec is domain data: a declarative description of intent.

Coordinator
  A routing function whose only job is to:
    • Pattern-match a spec
    • Extract payload values
    • Call the appropriate resolver
    • Return a Future<SidebarCassetteCardViewModel>

Resolver
  A stateless decision-making function that:
    • Receives explicit parameters
    • Performs domain lookups / logic
    • Constructs and returns SidebarCassetteCardViewModel
    • Performs no routing
    • Owns no UI assembly logic

Widget Builder
  A dumb constructor that:
    • Receives fully-decided inputs
    • Assembles widgets
    • Never interprets specs
    • Never makes branching decisions

SidebarCassetteCardViewModel
  The single, canonical payload returned from a feature to the sidebar system.
  This is the ONLY object that crosses the feature → essentials boundary.

================================================================
3. THE SINGLE CROSS-LAYER CONTRACT (ABSOLUTE)
================================================================

Feature-level coordinators MUST return:

  Future<SidebarCassetteCardViewModel>

This is the ONLY value that may cross from a feature into the essentials/sidebar layer.

No alternative return types are permitted.
No wrapper types are permitted.
No tuples, records, results, or metadata carriers are permitted.

If additional data is required, it MUST be added as a field on
SidebarCassetteCardViewModel itself.

================================================================
4. COORDINATOR RESPONSIBILITIES (STRICT)
================================================================

A feature coordinator:

• Receives a FeatureCassetteSpec
• Pattern-matches on that spec
• Extracts payload parameters
• Calls exactly ONE resolver
• Returns the resolver’s Future<SidebarCassetteCardViewModel>

The coordinator:

• MUST NOT perform IO
• MUST NOT construct widgets
• MUST NOT build view models itself
• MUST NOT pass specs beyond this layer
• MUST NOT return widgets or widget builders

The coordinator is a router — nothing more.

================================================================
5. RESOLVER CONTRACT (NO WIGGLE ROOM)
================================================================

Resolvers are implemented as Riverpod-annotated Notifier classes.

A resolver:

• Is invoked explicitly by the coordinator
• Receives all required inputs as parameters
• Returns Future<SidebarCassetteCardViewModel>
• Owns all decision-making for that cassette
• Determines which widget builder is used (declared via the view model)

Resolvers MUST NOT:

• Accept a spec object
• Read a spec from shared state
• Be parameterized via provider families
• Require pre-initialization or setter calls
• Return widgets, builders, or partial results
• Reach back into coordinators or routing logic

Resolvers are explicit, stateless decision functions.

================================================================
6. ASYNC BEHAVIOR & LOADING (OPTION 1 — SIMPLE, MANDATED)
================================================================

Initial loading MUST be represented solely by the pending
Future<SidebarCassetteCardViewModel>.

• Pending Future  = “loading”
• Completed Future = realized cassette

SidebarCassetteCardViewModel MUST represent only realized cassette content.

Therefore, the view model MUST NOT contain:
• isLoading flags
• loading variants
• skeleton-only states
• partial or placeholder content

The sidebar system MAY display generic chrome or placeholders while awaiting the Future,
but MUST NOT infer semantic meaning from loading.

================================================================
7. ERROR AND EMPTY STATES
================================================================

All error and empty states MUST be explicitly encoded inside SidebarCassetteCardViewModel.

Resolvers MUST NOT:
• Throw errors across the boundary
• Return null
• Return alternate payload types

All failure representation is content, not control flow.

================================================================
8. OWNERSHIP SUMMARY (ABSOLUTE)
================================================================

Essentials / Sidebar owns:
• Cassette stack topology
• Cassette ordering
• Chrome and layout
• Calling feature coordinators

Features own:
• FeatureCassetteSpec definitions (domain)
• Coordinators
• Resolvers
• View model construction
• Widget builders

No ownership overlaps are permitted.

================================================================
9. CANONICAL FEATURE COORDINATOR CONTRACT
================================================================

PURPOSE
A feature coordinator is a routing function. It exists solely to translate a FeatureCassetteSpec
into a Future<SidebarCassetteCardViewModel> by delegating to resolvers.

REQUIRED FUNCTION SIGNATURE
Every feature coordinator MUST expose a single public entry point:

  Future<SidebarCassetteCardViewModel> build(FeatureCassetteSpec spec)

No additional public methods are permitted.

ONLY PERMITTED CONTROL FLOW
The coordinator MUST:

1. Receive a FeatureCassetteSpec
2. Pattern-match the spec
3. Extract payload parameters
4. Call exactly ONE resolver
5. Return the resolver’s Future<SidebarCassetteCardViewModel>

COORDINATORS MAY NOT
• Call multiple resolvers
• Compose or merge Futures
• Inspect or modify view models
• Perform conditional logic beyond spec pattern-matching
• Pass specs to resolvers
• Hold references to widget builders
• Import presentation-layer widgets
• Reach into infrastructure implementations

ASYNC RULE (NON-NEGOTIABLE)
All coordinators MUST return Futures. No sync pathways. No placeholders.

================================================================
10. CANONICAL RESOLVER CONTRACT
================================================================

REQUIRED FORM
Every resolver MUST be implemented as a Riverpod-annotated Notifier class.

Naming convention (mandatory):
• Annotated class:   ContactChooserResolver
• Generated provider: contactChooserResolverProvider
• File name:         contact_chooser_resolver_provider.dart

ONLY PERMITTED PUBLIC API
Each resolver MUST expose exactly ONE public method:

  Future<SidebarCassetteCardViewModel> resolve(...)

No additional public methods are permitted.

EXPLICIT PARAMETER PASSING (MANDATED)
All data required to build the cassette MUST be passed explicitly to resolve(...).

Resolvers MUST NOT:
• Accept a spec object
• Read a spec from shared state
• Use provider families to bind inputs
• Depend on call order or mutable initialization

STATELESSNESS REQUIREMENT
Resolvers MUST be stateless across calls. No caching inputs. No parameter storage in fields.

DEPENDENCIES
Resolvers MAY depend on repositories and services via abstractions.
Resolvers MUST NOT depend on widgets, coordinators, or essentials/sidebar state.

================================================================
11. SidebarCassetteCardViewModel — Semantics & Ownership
================================================================

PURPOSE
SidebarCassetteCardViewModel is the SINGLE authoritative payload returned from features
to the sidebar system. It describes a realized cassette.

SINGLE CROSS-BOUNDARY PAYLOAD (ABSOLUTE)
SidebarCassetteCardViewModel is:
• The ONLY object returned by resolvers
• The ONLY object returned by feature coordinators
• The ONLY object consumed by the sidebar cassette system

REQUIRED SEMANTIC CATEGORIES
The view model MUST fully encode:

A) Identity
   • Stable cassette identity
   • Feature ownership

B) Presentation Semantics
   • Title / subtitle / footer text
   • Visual emphasis and hierarchy
   • Whether the cassette is expandable
   • Whether the cassette is interactive

C) Content Description
   • Which widget builder must be used
   • All inputs required by that builder

D) State Representation
   • Normal content
   • Empty state
   • Error state

WIDGET BUILDER SELECTION
The resolver decides. The view model declares. The widget builder obeys.

IMMUTABILITY
SidebarCassetteCardViewModel MUST be immutable and MUST NOT contain:
• callbacks
• mutable collections
• BuildContext
• closures/lambdas
• feature specs
• navigation logic
• routing instructions
• widgets
• references to coordinators/resolvers
• execution/loading state

EXTENSIBILITY RULE (MANDATORY)
If the system needs “one more piece of information”, add a field to SidebarCassetteCardViewModel.
Do NOT introduce wrappers. Do NOT introduce parallel view models.

================================================================
12. FEATURE-LEVEL FOLDER SCAFFOLD & OWNERSHIP RULES
================================================================

Feature root structure (mandatory):

featureName/
  domain/
  application/
  infrastructure/
  presentation/
  feature_level_providers.dart

No additional top-level folders are permitted.

----------------------------------------------------------------
12.1 Spec classes live in DOMAIN (MANDATORY)
----------------------------------------------------------------

All feature surface specs MUST live in the domain layer:

featureName/
  domain/
    spec_classes/
      <feature>_cassette_spec.dart
      <feature>_tooltip_spec.dart            (future)
      <feature>_<other_surface>_spec.dart    (future)

Rules:
• Spec classes are pure domain data
• They MUST NOT import application, infrastructure, or presentation code
• Each surface gets exactly one spec file per feature; do not create per-case spec files

----------------------------------------------------------------
12.2 Application layer — sidebar cassette support (MANDATORY)
----------------------------------------------------------------

All sidebar-related feature logic MUST live under:

featureName/
  domain/
    spec_classes/
      contacts_cassette_spec.dart
      contacts_tooltip_spec.dart

  application/
    sidebar_cassette_spec/
      coordinators/
      resolvers/
      resolver_tools/
      widget_builders/

  infrastructure/
  presentation/

  feature_level_providers.dart

Meanings:

coordinators/
  • feature-level coordinator(s)
  • routes FeatureCassetteSpec → resolver calls
  • no IO, no widget construction, no business logic

resolvers/
  • riverpod Notifier resolvers
  • one resolve(...) method
  • explicit parameters
  • returns Future<SidebarCassetteCardViewModel>

resolver_tools/
  • shared pure helper functions for resolvers
  • no Riverpod, no widgets, no routing

widget_builders/
  • dumb widget assembly only
  • accepts fully-decided inputs
  • never interprets specs, never performs IO

----------------------------------------------------------------
12.3 Domain layer ownership
----------------------------------------------------------------

Domain contains:
• feature-specific enums
• text key enums
• entities, value objects, rules
• spec_classes (above)

Domain MUST NOT depend on application/infrastructure/presentation.

----------------------------------------------------------------
12.4 Infrastructure layer ownership
----------------------------------------------------------------

Infrastructure contains:
• repository implementations
• database access
• external service adapters

Repositories:
• are injected into resolvers via abstractions
• must not expose UI or spec concepts

----------------------------------------------------------------
12.5 Presentation layer ownership
----------------------------------------------------------------

Presentation contains:
• widgets, styles, layout primitives

Presentation MUST NOT import coordinators or resolvers.

================================================================
13. feature_level_providers.dart (BARREL FILE) — PUBLIC API ONLY
================================================================

Each feature MUST expose a single barrel file:

featureName/
  feature_level_providers.dart

This file is the ONLY public entry point for the feature.

It MUST export:
• FeatureCassetteSpec definitions (domain/spec_classes)
• Feature coordinator(s)
• Domain enums required by callers

It MUST NOT export:
• Resolver implementations
• Resolver tools
• Widget builders
• Infrastructure details

VISIBILITY RULE (ABSOLUTE)
Code outside a feature MAY import only:

featureName/feature_level_providers.dart

Any other import path is a violation.

================================================================
14. COMMON FAILURE MODES & EXPLICITLY BANNED ANTI-PATTERNS
================================================================

The following are explicitly forbidden:

1) Wrapper transport objects
   • Result/Response/Payload wrappers
   • WidgetWithMetadata, CassetteBuildResult, etc.
   Correct fix: add fields to SidebarCassetteCardViewModel.

2) Passing specs into resolvers
   Correct fix: coordinators extract payload values and pass explicitly.

3) Provider families / implicit binding
   Correct fix: explicit parameters to resolve(...).

4) Mutable resolver initialization
   • setX/init/configure before resolve()
   Correct fix: resolve(...) must accept all required parameters.

5) Coordinators doing “a little bit more”
   • IO, combining futures, inspecting view models, choosing builders, catching errors
   Correct fix: move logic into resolvers.

6) Returning widgets or builders across the boundary
   Correct fix: only SidebarCassetteCardViewModel crosses the boundary.

7) AsyncValue/execution state leakage
   Correct fix: pending Future = loading; realized VM = content.

8) Partial/placeholder view models
   Correct fix: return complete, realized view model only.

9) Sidebar inference logic
   • runtime type checks, inferred expandability, inferred state
   Correct fix: resolver declares; sidebar renders.

10) Feature cross-talk
   • importing another feature’s coordinator/resolver
   Correct fix: extract shared domain/application services, not coordinators/resolvers.

================================================================
15. MIGRATION CHECKLIST — LEGACY → SIDEBAR CASSETTE ARCHITECTURE
================================================================

Follow this procedure in order. No shortcuts.

1) Identify the feature boundary
   • confirm domain/application/infrastructure/presentation exist

2) Create required folder scaffold
   • application/sidebar_cassette_spec/{coordinators,resolvers,resolver_tools,widget_builders}
   • domain/spec_classes/

3) Define FeatureCassetteSpec in domain/spec_classes
   • minimal explicit payloads only

4) Create resolvers first
   • Notifier class
   • single resolve(...) method
   • explicit parameters
   • returns Future<SidebarCassetteCardViewModel>
   • errors/empty encoded as view model content (no throwing across boundary)

5) Create widget builders
   • assemble widgets only
   • no specs, no IO, no decisions

6) Create the feature coordinator
   • build(spec) routes spec → exactly one resolver call per case
   • returns resolver Future directly

7) Verify async behavior
   • pending Future = loading
   • no loading flags in view models
   • no partial view models

8) Remove legacy paths
   • delete old sidebar logic, wrappers, adapters

9) Create feature_level_providers.dart
   • export spec(s), coordinator(s), required domain enums only

10) Verify ownership boundaries
   • essentials imports only feature_level_providers.dart
   • no cross-feature imports
   • coordinators import no widgets
   • widget builders import no specs

11) Delete “temporary” code
   • no transitional adapters, no TODO-based architecture

12) Final validation questions (all must be “yes”)
   • each cassette originates from FeatureCassetteSpec
   • each spec case maps to exactly one resolver
   • each resolver returns exactly one view model
   • SidebarCassetteCardViewModel is the only boundary payload
   • loading is represented only by a pending Future

================================================================
16. FINAL RULE
================================================================

If a piece of code requires explanation to justify why it does not follow these rules,
it is wrong.

If a migration “needs” an exception, the migration strategy is wrong.

These contracts are not guidelines.
They are architectural law.