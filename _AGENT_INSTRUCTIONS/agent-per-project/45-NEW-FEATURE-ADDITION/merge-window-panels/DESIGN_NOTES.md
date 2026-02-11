# Merge Window Panels: Design Notes

## Layout Strategy
- Replace the existing `MacosWindow` sidebars with a single `MacosScaffold` that owns two primary regions:
	- **Navigation Column** – a fixed-width `ColoredBox` (or dedicated widget) anchored to the left, hosting the cassette stack.
	- **Content Canvas** – an expanded area that renders the active ViewSpec output.
- Keep the navigation column outside of `MacosScaffold.sidebar` so the toolbar can stretch across both regions.
- Ensure the navigation column width matches the prior sidebar measurements to avoid reworking cassette sizing.

## Theming
- Reuse existing theme tokens where possible (`bbcSidebarBackground`, `bbcPanelBackground`), but introduce derived tokens if a softer visual separation is needed.
- Provide light/dark variants with subtle contrast (e.g., slightly tinted background rather than stark color shifts).

## State Management
- Continue using `cassetteWidgetCoordinatorProvider` (or successor) to drive the sidebar contents.
- Verify that panel ViewSpecs assume a center/right context and adjust any panel routing that referenced `WindowPanel.left`.

## Navigation & Toolbar
- The toolbar will move to the top-level scaffold; confirm toolbar actions that previously targeted center/right still operate correctly.
- Evaluate whether any right-sidebar specific commands need refactoring or removal.

## Risks & Mitigations
- **Risk:** Residual references to right sidebar providers cause runtime exceptions.
	- *Mitigation:* Grep for `WindowPanel.right` and update/remove usage during implementation.
- **Risk:** Theme token adjustments introduce inconsistent backgrounds.
	- *Mitigation:* Validate theming in both modes and add widget tests for key surfaces.
- **Risk:** Layout regression on smaller window sizes.
	- *Mitigation:* Test min/max constraints and add overflow handling if necessary.
