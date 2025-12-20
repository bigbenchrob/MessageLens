# Merge Window Panels: Checklist

## Planning
- [ ] Confirm proposal approval with product owner.
- [ ] Align on fixed navigation column width and color token approach.
- [ ] Audit existing ViewSpec / cassette flows for sidebar dependencies.

## Implementation
- [x] Introduce layout scaffolding that replaces `MacosWindow` sidebars with a fixed left column surface.
- [x] Update navigation providers to target the new layout container.
- [x] Ensure toolbar configuration spans full window width and maintains existing actions.
- [x] Wire theme tokens for the navigation column in both light and dark modes.
- [ ] Remove dead code related to right sidebar orchestration.

## Verification
- [ ] Run automated tests (`flutter test`, relevant unit/widget suites).
- [ ] Perform manual validation in light/dark themes, verifying navigation and content updates remain responsive.
- [ ] Capture screenshots for documentation and release notes.

## Release
- [ ] Update `_AGENT_INSTRUCTIONS/agent-per-project/40-FEATURES/` once shipped.
- [ ] Communicate changes to stakeholders (release notes / changelog entry).
