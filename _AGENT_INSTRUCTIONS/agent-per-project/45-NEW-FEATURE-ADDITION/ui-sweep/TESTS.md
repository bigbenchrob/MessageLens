# UI Sweep — Test Specification

This document defines validation criteria for the UI sweep feature.

---

## 1. Visual Tests (Manual)

### 1.1 Blur Test

**Purpose**: Verify that only two visual planes are perceptible.

**Procedure**:
1. Launch app in target mode (light/dark)
2. Take full-window screenshot
3. Apply Gaussian blur (radius ~8-12px)
4. Count distinct visual regions

**Pass Criteria**:
- Exactly **two** distinct planes visible:
  - **Plane A** (left): Sidebar / navigation
  - **Plane B** (right): Content area
- No third "surface" visible within either plane
- Blur should NOT reveal:
  - Distinct header region
  - Distinct search region
  - Card boundaries in sidebar

**Modes to Test**:
- [ ] Light mode
- [ ] Dark mode

---

### 1.2 Squint Test

**Purpose**: Verify visual hierarchy reads correctly.

**Procedure**:
1. Launch app with realistic content (contact selected, messages visible)
2. Squint at screen or view from 6+ feet away
3. Note what draws attention first, second, third

**Pass Criteria**:
- **First** (most prominent): Message content
- **Second**: Navigation titles (contact name, headers)
- **Third**: Controls (search bar, buttons)
- **Not prominent**: Metadata (timestamps, counts), UI chrome

**Failure indicators**:
- Sidebar and content compete equally for attention
- Metadata draws focus before content
- Control elements are as prominent as content

**Modes to Test**:
- [ ] Light mode
- [ ] Dark mode

---

### 1.3 Separator Count

**Purpose**: Verify divider minimization.

**Procedure**:
1. Launch app
2. Count all visible hard dividers/borders

**Pass Criteria**:
- **One** hard divider: vertical line between sidebar and content
- **Zero** dividers between:
  - Header and search
  - Search and message list
  - Cassette sections (within sidebar)

**Permitted exceptions**:
- Message row separators (aid scanning)
- List section headers (if semantically meaningful)

---

### 1.4 Spacing Grid Audit

**Purpose**: Verify consistent vertical rhythm.

**Procedure**:
1. Take full-window screenshot
2. Overlay 8px grid in image editor
3. Check alignment of:
   - Panel padding
   - Section gaps
   - Element margins

**Pass Criteria**:
- All major spacing aligns to 8px grid
- No "off-grid" spacing values visible
- Sidebar and content use consistent rhythm

---

## 2. Code Quality Tests (Automated)

### 2.1 Spacing Token Compliance

**Command**:
```bash
grep -rn "EdgeInsets\." lib/ | grep -v "AppSpacing" | grep -v ".g.dart"
```

**Pass Criteria**: No results (all EdgeInsets use AppSpacing tokens)

**Exceptions (document if found)**:
- Third-party package wrappers
- Generated code (`.g.dart`)

---

### 2.2 Typography Token Compliance

**Command**:
```bash
grep -rn "TextStyle(" lib/ | grep -v "theme" | grep -v ".g.dart"
```

**Pass Criteria**: No results (all TextStyle definitions in theme files)

**Exceptions (document if found)**:
- `ThemeTypography` class itself
- Test files

---

### 2.3 Color Inline Compliance

**Command**:
```bash
grep -rn "Color(0x" lib/ | grep -v "theme" | grep -v ".g.dart"
```

**Pass Criteria**: No results (all colors from theme tokens)

**Exceptions (document if found)**:
- `theme_colors.dart` definitions
- Generated code

---

### 2.4 Static Analysis

**Command**:
```bash
flutter analyze
```

**Pass Criteria**: Zero warnings/errors

---

## 3. Functional Regression Tests

### 3.1 Navigation Flow

- [ ] Select contact from picker → sidebar and content update correctly
- [ ] Click heatmap cell → message list filters correctly
- [ ] Search → results appear correctly
- [ ] Clear search → list resets correctly

### 3.2 Selection State

- [ ] Cassette selection visually indicated
- [ ] Contact row selection visually indicated
- [ ] Selection state persists across interactions

### 3.3 Mode Switching

- [ ] Light → Dark → Light: no visual artifacts
- [ ] All colors resolve correctly in both modes
- [ ] No "flash" of wrong colors during transition

---

## 4. Screenshot Archives

Save before/after screenshots for:

| View | Light | Dark |
|------|-------|------|
| Full window | `before-light.png` / `after-light.png` | `before-dark.png` / `after-dark.png` |
| Sidebar only | `sidebar-before-light.png` / `sidebar-after-light.png` | ... |
| Content only | `content-before-light.png` / `content-after-light.png` | ... |

**Storage location**: `_ui_renders/ui-sweep/`

---

## 5. Test Execution Log

| Test | Date | Result | Notes |
|------|------|--------|-------|
| Blur test (light) | | | |
| Blur test (dark) | | | |
| Squint test (light) | | | |
| Squint test (dark) | | | |
| Separator count | | | |
| Spacing grid audit | | | |
| Spacing token grep | | | |
| Typography token grep | | | |
| Color inline grep | | | |
| flutter analyze | | | |
| Navigation flow | | | |
| Selection state | | | |
| Mode switching | | | |

---

## 6. Sign-off Criteria

Feature is complete when:

1. [ ] All manual visual tests pass
2. [ ] All automated code quality tests pass
3. [ ] All functional regression tests pass
4. [ ] Before/after screenshots captured
5. [ ] Test execution log completed
6. [ ] `flutter analyze` returns zero issues
