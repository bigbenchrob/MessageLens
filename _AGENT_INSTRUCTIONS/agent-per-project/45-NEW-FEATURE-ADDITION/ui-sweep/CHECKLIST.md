# UI Sweep — Implementation Checklist

**Branch**: `Ftr.uisweep`  
**Status**: Planning complete — ready for implementation

---

## Phase 1: Foundation

Build the token infrastructure before touching existing widgets.

### 1.1 Spacing Tokens

- [ ] **1.1.1** Create `lib/config/theme/spacing/app_spacing.dart`
  - Define `AppSpacing` abstract class with:
    - Base unit: 8.0
    - Named sizes: `xs`, `sm`, `md`, `lg`, `xl`, `xxl`
    - Semantic aliases: `gutter`, `sectionGap`, `panelPadding`, `cardPadding`, `cassetteGap`

- [ ] **1.1.2** Export from barrel: `lib/config/theme/theme.dart`

### 1.2 Structural Wrappers

- [ ] **1.2.1** Create `lib/config/theme/widgets/sidebar_plane.dart`
  - `SidebarPlane`: sets panel background + right-edge divider
  - ConsumerWidget using `themeColorsProvider`

- [ ] **1.2.2** Create `lib/config/theme/widgets/content_plane.dart`
  - `ContentPlane`: sets unified canvas background
  - ConsumerWidget with no internal divisions

- [ ] **1.2.3** Create `lib/config/theme/widgets/cassette_chrome.dart`
  - `CassetteChrome`: padding + selection state; NO card border/shadow
  - ConsumerWidget with standardized rhythm

- [ ] **1.2.4** Export all wrappers from `lib/config/theme/widgets/theme_widgets.dart`

### 1.3 Verification

- [ ] **1.3.1** Run `flutter analyze` — no new warnings
- [ ] **1.3.2** Create simple test widget using new tokens (can be temporary)
- [ ] **1.3.3** Commit: "feat(ui-sweep): add spacing tokens and structural wrappers"

---

## Phase 2: Sidebar (Plane A)

Unify the sidebar as one navigational instrument.

### 2.1 Root Wrapper

- [ ] **2.1.1** Identify sidebar root widget (likely in `left_sidebar.dart` or similar)
- [ ] **2.1.2** Wrap with `SidebarPlane`
- [ ] **2.1.3** Remove any redundant background color assignments

### 2.2 Contact Selector / Picker

- [ ] **2.2.1** Audit contact picker styling
- [ ] **2.2.2** Ensure horizontal padding matches sidebar standard (`AppSpacing.md`)
- [ ] **2.2.3** Align left edge with other sidebar elements

### 2.3 Cassette Cards

- [ ] **2.3.1** Audit cassette card implementations
- [ ] **2.3.2** Refactor to use `CassetteChrome` (remove card border/shadow)
- [ ] **2.3.3** Verify selection state styling still works
- [ ] **2.3.4** Ensure content-only return (no per-cassette styling decisions)

### 2.4 Heatmap Integration

- [ ] **2.4.1** Locate heatmap widget (likely `heatmap_cassette.dart` or similar)
- [ ] **2.4.2** Remove distinct frame/card treatment
- [ ] **2.4.3** Match sidebar padding (`AppSpacing.md` horizontal)
- [ ] **2.4.4** Align left edge with other elements
- [ ] **2.4.5** Verify heatmap reads as "embedded" not "widget"

### 2.5 Divider Audit

- [ ] **2.5.1** Grep for `Divider` / `Container` with border in sidebar code
- [ ] **2.5.2** Remove internal dividers (between cassettes, etc.)
- [ ] **2.5.3** Keep only the single right-edge divider (from `SidebarPlane`)

### 2.6 Spacing Standardization

- [ ] **2.6.1** Grep for `EdgeInsets` in sidebar code
- [ ] **2.6.2** Replace all custom values with `AppSpacing.*` tokens
- [ ] **2.6.3** Grep for `SizedBox(height:` / `SizedBox(width:` in sidebar code
- [ ] **2.6.4** Replace all custom values with `AppSpacing.*` tokens

### 2.7 Verification

- [ ] **2.7.1** Visual check: sidebar reads as single surface (light mode)
- [ ] **2.7.2** Visual check: sidebar reads as single surface (dark mode)
- [ ] **2.7.3** Blur test: only one sidebar plane visible
- [ ] **2.7.4** Run `flutter analyze` — no new warnings
- [ ] **2.7.5** Commit: "refactor(ui-sweep): unify sidebar as single plane"

---

## Phase 3: Content (Plane B)

Unify header, search, and message list as one canvas.

### 3.1 Root Wrapper

- [ ] **3.1.1** Identify center panel root widget
- [ ] **3.1.2** Wrap with `ContentPlane`
- [ ] **3.1.3** Remove any redundant background color assignments

### 3.2 Header Area

- [ ] **3.2.1** Audit header widget styling
- [ ] **3.2.2** Remove bottom border/divider
- [ ] **3.2.3** Standardize padding to `AppSpacing.*` tokens
- [ ] **3.2.4** Verify typography uses `NavigationTitles` role

### 3.3 Search Area

- [ ] **3.3.1** Audit search bar styling
- [ ] **3.3.2** Remove top and bottom borders/dividers
- [ ] **3.3.3** Implement subtle background tint (≤2% delta) if needed
- [ ] **3.3.4** Ensure tint is continuous with content plane (no card semantics)
- [ ] **3.3.5** Standardize padding to `AppSpacing.*` tokens
- [ ] **3.3.6** Verify typography uses `Controls` role

### 3.4 Message List

- [ ] **3.4.1** Audit message list container styling
- [ ] **3.4.2** Remove top border/divider
- [ ] **3.4.3** Standardize padding to `AppSpacing.*` tokens
- [ ] **3.4.4** Verify message text uses `Content` role
- [ ] **3.4.5** Verify timestamps/metadata use `Metadata` role

### 3.5 Separator Removal

- [ ] **3.5.1** Verify header ↔ search separator is removed
- [ ] **3.5.2** Verify search ↔ list separator is removed
- [ ] **3.5.3** Replace with vertical spacing (`AppSpacing.sectionGap`)

### 3.6 Spacing Standardization

- [ ] **3.6.1** Grep for `EdgeInsets` in center panel code
- [ ] **3.6.2** Replace all custom values with `AppSpacing.*` tokens
- [ ] **3.6.3** Grep for `SizedBox(height:` / `SizedBox(width:` in center panel code
- [ ] **3.6.4** Replace all custom values with `AppSpacing.*` tokens

### 3.7 Verification

- [ ] **3.7.1** Visual check: center panel reads as single canvas (light mode)
- [ ] **3.7.2** Visual check: center panel reads as single canvas (dark mode)
- [ ] **3.7.3** Blur test: only one content plane visible
- [ ] **3.7.4** Run `flutter analyze` — no new warnings
- [ ] **3.7.5** Commit: "refactor(ui-sweep): unify content as single plane"

---

## Phase 4: Typography Audit

Enforce the four-role system across all features.

### 4.1 Inventory

- [ ] **4.1.1** Grep for `TextStyle(` across `lib/`
- [ ] **4.1.2** Document each instance with:
  - File path
  - Current style definition
  - Proposed role mapping

### 4.2 Role Assignment

For each instance from 4.1.1:

- [ ] **4.2.1** Assign to one of: `NavigationTitles`, `Content`, `Metadata`, `Controls`
- [ ] **4.2.2** Identify matching token in `ThemeTypography`
- [ ] **4.2.3** If no matching token exists, propose new token (must fit one of four roles)

### 4.3 Migration

- [ ] **4.3.1** Replace inline `TextStyle(...)` with token references
- [ ] **4.3.2** Run `flutter analyze` after each file
- [ ] **4.3.3** Visual comparison: before/after for each file

### 4.4 Cleanup

- [ ] **4.4.1** Remove unused custom text styles
- [ ] **4.4.2** Verify no orphan `TextStyle(...)` definitions remain
- [ ] **4.4.3** Commit: "refactor(ui-sweep): standardize typography to four roles"

---

## Phase 5: Final Validation

### 5.1 Visual Tests

- [ ] **5.1.1** Blur test (light mode): only two planes visible
- [ ] **5.1.2** Blur test (dark mode): only two planes visible
- [ ] **5.1.3** Squint test: content > navigation > controls
- [ ] **5.1.4** Screenshots: before/after comparison

### 5.2 Code Quality

- [ ] **5.2.1** Grep audit: no raw `EdgeInsets(...)` with non-token values
- [ ] **5.2.2** Grep audit: no raw `TextStyle(...)` definitions
- [ ] **5.2.3** Grep audit: no raw `Color(0x...)` inline
- [ ] **5.2.4** Run full `flutter analyze` — zero warnings

### 5.3 Cross-Mode Testing

- [ ] **5.3.1** Test full app flow in light mode
- [ ] **5.3.2** Test full app flow in dark mode
- [ ] **5.3.3** Test mode switching (light → dark → light)

### 5.4 Documentation

- [ ] **5.4.1** Update `STATUS.md` with completion notes
- [ ] **5.4.2** Move feature folder to `40-FEATURES/ui-sweep/`
- [ ] **5.4.3** Final commit: "feat(ui-sweep): complete visual unification"

---

## Completion Criteria

All boxes checked means:

1. ✅ Two-plane surface model enforced
2. ✅ Single hard divider (sidebar ↔ content)
3. ✅ All spacing uses `AppSpacing.*` tokens
4. ✅ All typography uses four-role system
5. ✅ Blur test passes (both modes)
6. ✅ Squint test passes (content dominant)
7. ✅ Zero `flutter analyze` warnings
