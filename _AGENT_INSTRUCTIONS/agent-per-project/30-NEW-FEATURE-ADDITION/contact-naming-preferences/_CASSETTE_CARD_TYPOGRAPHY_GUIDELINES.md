# Cassette Card Typography & Hierarchy Guidelines

## Purpose

This document defines the **visual hierarchy and typography rules** for cassette cards,
with particular focus on **option groups** (radio buttons, toggles, menu choices).

The goal is to ensure:
- Clear hierarchy
- Calm, native macOS feel
- Selected state clarity without visual noise
- Consistency with Apple Human Interface Guidelines

These rules should be coordinated with the app’s typography theme system.

---

## Core Hierarchy Principles

### 1. Section headers define *scope*, not content
- Section headers describe *what kind* of choices follow.
- Options are always **visually subordinate** to their section header.

Hierarchy must never imply that options are peers of the section title.

---

### 2. Selected state is emphasized; unselected states recede
- The user’s current choice should feel **settled and stable**
- Unselected options should remain readable but visually quieter
- The selection indicator (radio/check) should *reinforce*, not carry, meaning

---

## Typography Roles (Relative Importance)

From highest to lowest emphasis **within a cassette card**:

1. Cassette title (if present)
2. Section header
3. **Selected option**
4. Unselected options
5. Explanatory / helper / footer text

---

## Required Typography Relationships

### Section Header
- Purpose: define category / grouping
- Visual treatment:
  - Weight: Medium or Semibold
  - Size: **equal to or slightly larger than unselected options**
  - Color: primary or high-contrast secondary
- Must never be visually dominated by options beneath it

---

### Option Labels (General)
- Purpose: present available choices
- Visual treatment:
  - Weight: Regular
  - Size: **one step smaller than section header**
  - Line height must preserve comfortable tap/click targets

---

### Selected Option
- Purpose: communicate current state at a glance
- Visual treatment:
  - Same size as other options
  - Increased emphasis via:
    - Slightly heavier weight OR
    - Higher contrast color OR
    - Subtle background highlight
- Selection must remain obvious even if indicator icon is ignored

---

### Unselected Options
- Purpose: remain available without competing for attention
- Visual treatment:
  - Regular weight
  - Reduced contrast (secondary text color)
  - Do NOT reduce opacity below ~60% for interactive elements

---

### Helper / Explanatory Text
- Purpose: explain behavior, not drive interaction
- Visual treatment:
  - Smallest size in the cassette
  - Low contrast
  - Should never visually compete with options or headers

---

## Explicit Anti-Patterns (Do Not Do)

- ❌ Options larger or louder than their section header
- ❌ All options rendered with equal visual weight
- ❌ Relying solely on radio/check indicators for selection clarity
- ❌ Large size jumps between selected and unselected options
- ❌ Using opacity so low that options appear disabled

---

## Apple HIG Alignment Notes

These rules align with macOS and iOS patterns observed in:
- System Settings
- Sidebar lists
- Radio groups
- Segmented controls

Apple consistently:
- Emphasizes the selected state
- De-emphasizes alternatives
- Uses contrast and weight before size
- Preserves calm, stable layouts

---

## Implementation Guidance for Typography Theme

When mapping these rules into the typography system:

- Define **distinct semantic styles**:
  - `cassetteSectionHeader`
  - `cassetteOption`
  - `cassetteOptionSelected`
  - `cassetteHelperText`

- Avoid hard-coding font sizes in widgets
- All hierarchy decisions should flow from theme tokens
- Selected vs unselected emphasis should be achievable via theme overrides alone

---

## Visual Litmus Test

If the cassette is collapsed to show only the selected option:
- It should still feel correct
- It should not feel louder than its section header
- The hierarchy should remain legible at a glance

If this holds true, the typography is correctly balanced.

---

End of document.