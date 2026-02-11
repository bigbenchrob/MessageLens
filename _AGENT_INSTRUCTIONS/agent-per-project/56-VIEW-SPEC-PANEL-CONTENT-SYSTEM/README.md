# 56 — View Spec Panel Content System

How the center and right panels display feature-owned content driven by sealed ViewSpec types.

## Key Idea

A `ViewSpec` is a sealed type describing what should appear in a panel. The system:

1. Maintains a **panel stack** per `WindowPanel` (center, right) — supporting tabbed/pushed pages
2. Routes the active page's `ViewSpec` to the owning feature's coordinator
3. The feature returns a `Widget` synchronously
4. The panel surface renders the widget

Unlike sidebar cassettes (which return a view model for the system to wrap in chrome),
view specs return **full widgets** — the feature owns most of the rendering.

## Documents

| File | Purpose |
|---|---|
| [00-view-spec-panel-architecture.md](00-view-spec-panel-architecture.md) | Full architecture: ViewSpec, PanelStack, PanelCoordinator, feature dispatch |
| [INVIOLATE_RULES.md](INVIOLATE_RULES.md) | Non-negotiable rules for the panel content system |

## Key Code Locations

| Component | Path |
|---|---|
| `ViewSpec` sealed class | `lib/essentials/navigation/domain/entities/view_spec.dart` |
| Feature spec classes | `lib/essentials/navigation/domain/entities/features/` |
| `MessagesSpec` (feature-owned) | `lib/features/messages/domain/spec_classes/messages_view_spec.dart` |
| Panel stack model | `lib/essentials/navigation/domain/entities/panel_stack.dart` |
| Panel state provider | `lib/essentials/navigation/application/panels_view_state_provider.dart` |
| Panel coordinator | `lib/essentials/navigation/application/panel_coordinator_provider.dart` |
| Panel widget providers | `lib/essentials/navigation/application/panel_widget_providers.dart` |
| Navigation barrel | `lib/essentials/navigation/feature_level_providers.dart` |

## Prerequisite Reading

- [52 — Feature Handling of X-Surface Specs](../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/) for the general coordinator → resolver → widget_builder pattern


