---
tier: project
scope: ui-feature
owner: agent-per-project
last_reviewed: 2026-01-14
source_of_truth: doc
links:
  - ../README.md
  - ./seed.txt
  - ../../70-CASSETTE-CONTENT-CONTROL/03-cassette-card-design-guidelines.md
tests: []
---

# App Mode Toggle UI — Proposal

## Problem Statement

The toolbar currently presents **Messages** and **Settings** as two adjacent icon buttons. Visually they appear as independent actions rather than a binary mode switch. Users cannot immediately tell which mode is active or that selecting one deselects the other.

## Goal

Make the binary nature of `SidebarMode` (messages vs settings) **unambiguously apparent** so that:

1. The active mode is instantly recognizable at a glance.
2. The two options clearly read as mutually exclusive.
3. A subtle environmental cue reinforces the mode without requiring conscious attention.

## Design Principles (from seed.txt)

| Principle | Implication |
|-----------|-------------|
| **Segmented control** | The canonical macOS pattern for exactly-one-of-N mode selection. |
| **State not action** | The control should feel "latched", not momentary. |
| **Secondary cue** | Reinforce mode via a subtle surface/tint shift elsewhere in the UI. |
| **Active = prominent, Inactive = recessive** | Visual weight difference must be obvious. |

## Proposed Solution

### 1. Replace Icon Buttons with a Segmented Control

Swap the two `MacosIconButton` widgets in the toolbar leading area for a single `MacosSegmentedControl` (or a custom equivalent if styling demands it).

```
[ 💬 Messages | ⚙ Settings ]
```

- Selected segment: filled background, primary accent color, heavier icon weight.
- Unselected segment: outline/transparent, muted icon, no hover glow until pointer enters.

This immediately communicates mutual exclusivity and persisted state.

### 2. Introduce a Mode-Aware Surface Tint

Add a very subtle background tint to the sidebar/content-control panel that shifts based on `activeSidebarModeProvider`:

| Mode | Tint Direction |
|------|----------------|
| Messages | Neutral (current `surfaces.contentControl`) |
| Settings | Slightly cooler / flatter (≈ 2–4% hue shift toward blue-gray) |

This is **not** a heavy theme swap—just enough that peripheral vision registers "I'm somewhere different."

Implementation:
- Extend `Surfaces` in `theme_colors.dart` with a `contentControlForMode(SidebarMode)` helper (or two named getters).
- `PanelStackSurface` or the sidebar container widget watches `activeSidebarModeProvider` and picks the appropriate surface.

### 3. Integrate SidebarMode into ThemeColors (Compound State)

Currently `ThemeColors` holds `Brightness` as its state and uses it to resolve `ColorPair` values. To make mode-aware surfaces first-class, we extend the provider state to a **compound record** containing both dimensions:

```dart
@override
(Brightness, SidebarMode) build() {
  final brightness = _resolveBrightness();
  final mode = ref.watch(activeSidebarModeProvider);
  return (brightness, mode);
}

bool get isDark => state.$1 == Brightness.dark;
bool get isSettingsMode => state.$2 == SidebarMode.settings;
```
**Why compound state?**

| Benefit | Explanation |
|---------|-------------|
| Single source of truth | `state` fully describes the appearance context. |
| Automatic rebuilds | Widgets watching the provider rebuild when *either* brightness or mode changes. |
| Explicit API | Helpers like `isSettingsMode` make intent clear at call sites. |

**Surface helper example:**

```dart
class Surfaces {
  Color get contentControl => _t.isSettingsMode
      ? _settingsContentControl
      : _messagesContentControl;
}
```

This removes the need for widgets to watch `activeSidebarModeProvider` separately—`themeColorsProvider` already encapsulates it.

### 4. (Optional) Mode Label in Title Bar

If additional clarity is desired, a small label can appear in the title bar:

```
MODE · MESSAGES
```

This is low-cost and especially helpful during development/debugging. It can be softened or removed later.

---

## Assumptions

- `macos_ui` provides `MacosSegmentedControl` or we can compose one from `CupertinoSlidingSegmentedControl`.
- Subtle tint changes do not require new theme tokens—only minor color derivations.
- `ThemeColors` state will change from `Brightness` to `(Brightness, SidebarMode)`. Existing call sites using `isDark` continue to work; new helpers (`isSettingsMode`) enable mode-aware logic.
- Widgets that currently watch `themeColorsProvider` will automatically rebuild on mode changes once the compound state is in place.

## Hard Invariants

- **No new modes**: This work affects only visual presentation; `SidebarMode` enum stays unchanged.
- **No navigation changes**: Cassette-rack logic and ViewSpec routing remain untouched.
- **Lint compliance**: All edits must pass `dart analyze` (relative imports, const constructors, etc.).
- **Cassette guidelines**: If any cassette chrome is affected, hierarchy rules from `03-cassette-card-design-guidelines.md` apply.

## Risks

| Risk | Mitigation |
|------|------------|
| Segmented control styling clashes with toolbar chrome | Build a lightweight custom widget styled to match existing `MacosIconButton` sizing. |
| Tint shift is too subtle or too jarring | Use a single `ColorPair` with values ≤ 4% luminance/hue delta; tweak post-merge. |
| Accessibility: low-contrast tint | Ensure WCAG AA contrast for all text/icons over tinted surfaces. |

---

## Success Criteria

1. A user glancing at the toolbar can immediately identify the active mode.
2. Switching modes feels like toggling a physical latch, not pressing a momentary button.
3. The sidebar surface provides a passive, subconscious cue that reinforces the mode.
4. No regressions in navigation, cassette rendering, or provider behavior.

---

## Next Steps

See `CHECKLIST.md` for the stepwise implementation plan.
