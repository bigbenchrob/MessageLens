# Dark Mode Menu Theming Guide  
_For MessageLens_

---

## Overview

Dark mode hierarchy depends primarily on **luminance contrast**, not hue contrast.

In light mode, selection works because:
- Background contrast changes
- Text contrast changes
- Accent color reinforces state

In dark mode, hue differences alone are insufficient.  
If luminance contrast collapses, hierarchy collapses.

> Dark mode is not “inverted light mode.”  
> It is “hierarchy built with light.”

---

# Core Principles

## 1. Prioritize Luminance Over Hue

Important elements must be **brighter**, not just more colorful.

If two elements share similar brightness values, the eye will not perceive hierarchy — even if their colors differ.

---

## 2. Selected State Requires Value Separation

A selected row must be:

- Visibly lighter than its parent surface
- High-contrast in text
- Reinforced with accent (but not dependent on it)

If selection disappears in grayscale, it will feel weak in dark mode.

---

## 3. Accent Color Is Reinforcement, Not Primary Contrast

In dark mode:

- Do **not** rely on blue text to communicate selection
- Use bright text (white/high-emphasis) for primary readability
- Use accent color for checkmarks, indicators, or subtle reinforcement

Blue-on-dark often reduces perceived contrast.

---

## 4. Icons Must Maintain Value Hierarchy

In dark mode:

| Element Type | Relative Brightness |
|--------------|--------------------|
| Primary text | Brightest |
| Accent indicator | Equal to or slightly below primary text |
| Secondary text | Dimmer than primary |
| Icons (secondary) | Same as secondary text |
| Dividers | Slightly lighter than background |
| Selected surface | Lighter than parent surface |

---

# Implementation Guidelines for Menus

## Selected Row (Dark Mode)

**Background**
- 6–10% lighter than panel background
- Must visibly separate in grayscale

**Text**
- High-emphasis white (not accent color)

**Checkmark**
- Accent blue
- Same brightness as primary text or slightly lower

**Hover State**
- +3% brightness from selected background

---

## Unselected Rows

**Background**
- Same as panel surface

**Text**
- Secondary or primary text depending on importance

---

## Chevron / Disclosure Indicator

Problem: Disappears when using accent blue on similar-value background.

Solution:

- Use `iconSecondary` token instead of accent
- Ensure it is brighter than the background
- Avoid mid-blue on dark-grey combinations

Optional refinement:
- Place chevron on subtle elevated surface
- Increase opacity 10–15%

---

# Grayscale Test

Convert the UI to grayscale.

If hierarchy disappears:
- Increase luminance delta between surfaces
- Increase brightness of primary text
- Reduce reliance on hue shifts

---

# App-Wide Theme Token Refactor

To apply this consistently, introduce semantic tokens.

---

## Surface Tokens

```dart
surfacePrimary      // main panel background
surfaceSecondary    // nested panel or grouped sections
surfaceElevated     // hover / subtle elevation
surfaceSelected     // selected menu row
surfaceHover        // hover state for non-selected rows
dividerColor```

Dark Mode Rules
	•	surfaceSelected must be lighter than surfacePrimary
	•	surfaceHover must be slightly lighter than surfacePrimary
	•	dividerColor must be lighter than surfacePrimary but dimmer than text

⸻

Text Tokens

textPrimary
textSecondary
textTertiary
textOnSelected
textAccent

Dark Mode Rules
	•	textPrimary = brightest readable text
	•	textOnSelected = same as textPrimary
	•	Do NOT use textAccent for primary readability
	•	textSecondary = visibly dimmer than primary

⸻

Icon Tokens

iconPrimary
iconSecondary
iconAccent

Dark Mode Rules
	•	iconPrimary = same brightness as textPrimary
	•	iconSecondary = same as textSecondary
	•	iconAccent = used only for state indicators

⸻

State Tokens

menuSelectedBackground
menuHoverBackground
menuActiveIndicatorColor

These should map internally to semantic surface tokens rather than hard-coded colors.

⸻

Target Luminance Relationships (Dark Mode)

Example structure:

Token                    Relative Luminance
surfacePrimary                 12%
surfaceSelected                18–22%
surfaceHover                   15–17%
textPrimary                    85–100%
textSecondary                  60–70%
dividerColor                   20–25%


Summary Rules
	1.	Selection must be lighter, not just bluer.
	2.	Text must carry hierarchy through brightness.
	3.	Accent color reinforces state but does not define contrast.
	4.	If it fails in grayscale, it fails in dark mode.
	5.	Encode hierarchy into semantic tokens, not individual components.

⸻

Final Goal

In dark mode, the selected row should:
	•	Clearly lift from the panel surface
	•	Have the brightest text in the menu
	•	Use accent only as reinforcement
	•	Remain unmistakable even without color

Dark mode hierarchy = controlled light distribution.