# 54 — Sidebar Cassette Spec System

How the sidebar composes and displays a vertical stack of multi-feature cassette cards.

## Key Idea

The sidebar is a **managed stack** of cassettes. Each cassette is described by a
`CassetteSpec`, which wraps a feature-specific inner spec. The system:

1. Maintains an ordered list of specs (the **rack**)
2. Resolves each spec to a `SidebarCassetteCardViewModel` via feature coordinators
3. Wraps each view model in the appropriate card chrome
4. Renders the stack

Features own the content. Essentials owns the stack, chrome, and composition.

## Documents

| File | Purpose |
|---|---|
| [00-cassette-system-architecture.md](00-cassette-system-architecture.md) | Full architecture: rack state, cascade, coordinator dispatch, card chrome |
| [INVIOLATE_RULES.md](INVIOLATE_RULES.md) | Non-negotiable rules for the cassette system |

## Key Code Locations

| Component | Path |
|---|---|
| `CassetteSpec` sealed class | `lib/essentials/sidebar/domain/entities/cassette_spec.dart` |
| Rack state provider | `lib/essentials/sidebar/application/cassette_rack_state_provider.dart` |
| App-level coordinator | `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart` |
| Cascade topology | `lib/essentials/sidebar/domain/entities/cascade/` |
| Card view model | `lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart` |
| Card widgets | `lib/essentials/sidebar/presentation/view/` |
| Sidebar barrel | `lib/essentials/sidebar/feature_level_providers.dart` |

## Prerequisite Reading

- [52 — Feature Handling of X-Surface Specs](../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/) for the general coordinator → resolver → widget_builder pattern


