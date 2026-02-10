# Merge Window Panels: Proposal

## Summary
Merge the current multi-panel macOS window into a simplified layout that always displays a single persistent left navigation area and one primary content canvas. The redesign replaces the existing `MacosWindow` sidebars with a custom fixed-width column so the toolbar spans the full window while preserving sidebar-driven navigation for contacts, messages, settings, and import flows.

## Goals
- Deliver a single-window experience that feels cohesive and reduces competing color planes.
- Keep the left navigation column permanently visible and non-resizable while maintaining current navigation capabilities.
- Allow the MacosScaffold toolbar to stretch across the full window width.
- Introduce subtle light/dark theming cues so the navigation column remains visually distinct without heavy contrast.

## Non-Goals
- No redesign of feature-specific content panes beyond what is required to fit the new layout.
- No overhaul of navigation data flows or cassette widget orchestration at this stage.
- No additional window management (multi-window, pop-outs) changes beyond removing right sidebar usage.

## Dependencies & Constraints
- Must continue honoring existing Riverpod navigation and cassette state providers for the left column.
- The replacement layout should leverage macOS-native styling through `macos_ui` where possible.
- Maintain compatibility with dark and light modes using the established theme token system.
- Ensure accessibility baseline (keyboard navigation, VoiceOver exposure) is not regressed.

## Open Questions
- Do we need a responsive breakpoint for very narrow window widths, or will the fixed column width remain constant?
- Should the toolbar controls incorporate any sidebar-specific actions now that the toolbar spans the full width?
- Are there analytics or logging adjustments required to reflect the simplified layout?

## Next Steps
Pending user confirmation of this proposal, proceed to detailed planning (`CHECKLIST.md`, `DESIGN_NOTES.md`, `TESTS.md`) before touching production code.
