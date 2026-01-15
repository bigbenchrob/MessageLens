---
tier: project
scope: ui-feature
owner: agent-per-project
last_reviewed: 2026-01-14
source_of_truth: doc
links:
  - ./PROPOSAL.md
tests: []
---

# App Mode Toggle UI — Implementation Checklist

This checklist breaks the proposal into discrete, reviewable steps. Each step is independently testable and should be committed separately.

---

## Stage 1: Create the Segmented Control Widget

- [ ] **1.1** Create `lib/essentials/navigation/presentation/widgets/app_mode_segment.dart`.
  - Define `AppModeSegment` widget that wraps `CupertinoSlidingSegmentedControl<SidebarMode>` (or a custom build if styling demands).
  - Accept current mode and `onModeChanged` callback.
  - Style segments to match toolbar icon sizing (≈ 18–20 px icons, ≈ 38 px height).
  - Selected segment: filled background, accent color icon.
  - Unselected segment: transparent background, muted icon.

- [ ] **1.2** Write a minimal widget test for `AppModeSegment` verifying:
  - Correct segment is visually selected given initial mode.
  - Tapping unselected segment invokes callback with new mode.

---

## Stage 2: Integrate Segmented Control into Toolbar

- [ ] **2.1** In `macos_app_shell.dart`, replace the two `MacosIconButton` widgets (Messages + Settings) with `AppModeSegment`.
  - Watch `activeSidebarModeProvider` for current mode.
  - On segment change, call `ref.read(activeSidebarModeProvider.notifier).setMode(newMode)`.
  - Preserve existing navigation side-effects (e.g., clearing center panel on settings switch).

- [ ] **2.2** Remove or relocate the dark-mode toggle icon so it does not visually compete with the mode segment.
  - Candidate locations: toolbar trailing actions, a future "Appearance" settings cassette.

- [ ] **2.3** Run `dart analyze` and `flutter test` to ensure no regressions.

---

## Stage 3: Integrate SidebarMode into ThemeColors (Compound State)

- [ ] **3.1** In `theme_colors.dart`, change `ThemeColors` state from `Brightness` to `(Brightness, SidebarMode)`:
  ```dart
  @override
  (Brightness, SidebarMode) build() {
    final brightness = _resolveBrightness();
    final mode = ref.watch(activeSidebarModeProvider);
    return (brightness, mode);
  }
  ```

- [ ] **3.2** Add helper getters:
  ```dart
  bool get isDark => state.$1 == Brightness.dark;
  bool get isSettingsMode => state.$2 == SidebarMode.settings;
  ```

- [ ] **3.3** Update `resolvePair` and any other methods that reference `state` to use `state.$1` for brightness.

- [ ] **3.4** Run code generation (`dart run build_runner build --delete-conflicting-outputs`) to regenerate the provider.

- [ ] **3.5** Fix any compile errors in existing call sites (most should be transparent since `isDark` API is preserved).

---

## Stage 4: Add Mode-Aware Surface Tint

- [ ] **4.1** In `Surfaces` class, define mode-aware content-control colors:
  ```dart
  Color get _settingsContentControl =>
      _r(const ColorPair(Color(0xFFEEF1F4), Color(0xFF282C2E)));

  Color get contentControl => _t.isSettingsMode
      ? _settingsContentControl
      : _r(const ColorPair(Color(0xFFF2F4F6), Color(0xFF2A2D2F)));
  ```

- [ ] **4.2** Remove explicit `activeSidebarModeProvider` watches from `PanelStackSurface` and similar widgets—they now get mode-awareness for free via `themeColorsProvider`.

- [ ] **4.3** Verify visually in both light and dark modes that the tint shift is perceptible but not jarring.

---

## Stage 5: (Optional) Add Mode Label

- [ ] **5.1** In the title bar or toolbar leading area, add a small `Text` widget showing the current mode:
  ```
  MODE · MESSAGES
  ```
  Use `typography.controlLabel` styling.

- [ ] **5.2** Make this label toggleable via a debug flag or environment variable so it can be hidden in release builds.

---

## Stage 6: Documentation & Cleanup

- [ ] **6.1** Update `60-NAVIGATION/navigation-overview.md` to mention the segmented control as the mode-switch mechanism.

- [ ] **6.2** Add a screenshot or ASCII diagram to this folder showing the final UI.

- [ ] **6.3** Archive or remove `seed.txt` once the feature is shipped and documented.

---

## Acceptance Criteria

1. Segmented control clearly indicates active mode; inactive segment is visually recessive.
2. Sidebar surface tint differs perceptibly between modes.
3. All existing toolbar actions (Chats, Contacts, Import, Search) continue to work.
4. `dart analyze` passes with zero warnings.
5. Widget test for `AppModeSegment` passes.

---

## Open Questions (resolve before Stage 2)

1. Does `macos_ui` provide a styled segmented control, or do we need a custom build?
2. Should the dark-mode toggle move to Settings immediately, or stay in toolbar for now?
