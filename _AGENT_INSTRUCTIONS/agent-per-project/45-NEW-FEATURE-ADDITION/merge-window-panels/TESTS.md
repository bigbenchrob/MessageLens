# Merge Window Panels: Test Plan

## Automated Tests
- [ ] Widget test covering the new scaffold to ensure navigation column and content canvas render together.
- [ ] Golden tests for light and dark themes verifying subtle sidebar tinting.
- [ ] Provider-level tests confirming cassette state still maps to expected widgets without right sidebar dependencies.

## Manual Validation
- [ ] Exercise navigation flows (contacts, messages, settings, import) verifying content updates correctly.
- [ ] Resize the window within supported bounds to confirm layout stability and non-resizable sidebar behavior.
- [ ] Toggle light/dark mode via toolbar control and confirm surfaces maintain intended contrast.

## Regression Coverage
- [ ] Run `flutter test --plain-name "contacts"` to ensure pre-existing sidebar cassette tests pass.
- [ ] Smoke test import workflows to ensure progress panels appear in the main canvas.
