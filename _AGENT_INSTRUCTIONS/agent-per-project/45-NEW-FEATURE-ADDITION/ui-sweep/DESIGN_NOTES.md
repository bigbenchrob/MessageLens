# UI Sweep — Design Notes

This document defines the token system and structural primitives for the UI sweep.

---

## Existing Foundation

The app already has a well-structured theming system:

| Provider | API | Purpose |
|----------|-----|---------|
| `themeColorsProvider` | `colors.surfaces.*`, `colors.content.*`, `colors.lines.*` | Color resolution |
| `themeTypographyProvider` | `typography.heroTitle`, `typography.body`, etc. | Text styles |

**Key insight**: The tokens exist; the problem is inconsistent application and missing structural wrappers.

---

## 1. Spacing Tokens (`AppSpacing`)

New file: `lib/config/theme/spacing/app_spacing.dart`

```dart
/// Spacing tokens for the UI sweep.
///
/// All layout spacing must use these values. No ad-hoc EdgeInsets or SizedBox.
abstract class AppSpacing {
  const AppSpacing._();

  // Base unit
  static const double unit = 8.0;

  // Named sizes
  static const double xs = 4.0;   // 0.5x (rare, fine adjustments)
  static const double sm = 8.0;   // 1x
  static const double md = 16.0;  // 2x
  static const double lg = 24.0;  // 3x
  static const double xl = 32.0;  // 4x
  static const double xxl = 48.0; // 6x (major section breaks)

  // Semantic aliases
  static const double gutter = md;           // Default between-element gap
  static const double sectionGap = lg;       // Between logical sections
  static const double panelPadding = md;     // Inset from panel edges
  static const double cardPadding = md;      // Internal card padding
  static const double cassetteGap = sm;      // Between cassette items
}
```

### Permitted Multiples

| Multiple | px  | Use case |
|----------|-----|----------|
| 0.5x     | 4   | Fine adjustments only |
| 1x       | 8   | Default small gap |
| 2x       | 16  | Default gutter, panel padding |
| 3x       | 24  | Section breaks |
| 4x       | 32  | Major group separation |
| 6x       | 48  | Panel-level vertical breaks |

### Prohibited Patterns

```dart
// ❌ Never
SizedBox(height: 12)
EdgeInsets.all(10)
Padding(padding: EdgeInsets.symmetric(horizontal: 14))

// ✅ Always
SizedBox(height: AppSpacing.md)
EdgeInsets.all(AppSpacing.md)
Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.md))
```

---

## 2. Typography Role Mapping

The design contract mandates exactly **four typography roles**. Here's how existing `ThemeTypography` styles map:

| Role | Token | Examples |
|------|-------|----------|
| **Navigation Titles** | `heroTitle`, `controlValue`, `cassetteCardTitle` | Contact names, section headers |
| **Primary Content** | `body` | Message text, long-form content |
| **Metadata** | `heroMeta`, `vizMeta`, `caption`, `cassetteCardSubtitle` | Timestamps, counts, descriptions |
| **Controls** | `controlLabel`, `pickerSectionLabel` | Buttons, filters, labels |

### Enforcement Rule

Feature widgets must use tokens from one of these four roles:

```dart
// ❌ Never
Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))

// ✅ Always
Text('Title', style: typography.cassetteCardTitle)
```

---

## 3. Structural Wrappers

New files in `lib/config/theme/widgets/`:

### `SidebarPlane`

Owns Plane A (navigation) styling:

```dart
/// Plane A: Navigation surface.
///
/// Provides:
/// - Consistent background color
/// - Single divider on right edge
/// - Standard panel padding
class SidebarPlane extends ConsumerWidget {
  const SidebarPlane({
    required this.child,
    this.showDivider = true,
    super.key,
  });

  final Widget child;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaces.panel,
        border: showDivider
            ? Border(
                right: BorderSide(
                  color: colors.lines.contentControlDivider,
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: child,
    );
  }
}
```

### `ContentPlane`

Owns Plane B (content) styling:

```dart
/// Plane B: Content surface.
///
/// Provides:
/// - Single continuous background (no internal divisions)
/// - Standard content padding
class ContentPlane extends ConsumerWidget {
  const ContentPlane({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: child,
    );
  }
}
```

### `CassetteChrome`

Replaces per-cassette card styling:

```dart
/// Cassette content wrapper.
///
/// Provides:
/// - Consistent padding and rhythm
/// - Selection/hover states
/// - NO card borders or shadows
class CassetteChrome extends ConsumerWidget {
  const CassetteChrome({
    required this.child,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final Widget child;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    final bgColor = isSelected ? colors.surfaces.selected : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      ),
    );
  }
}
```

---

## 4. Color Palette (Current)

### Plane A — Navigation (Sidebar)

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `surfaces.panel` | `#F6F7F8` | `#232627` | Sidebar background |
| `lines.contentControlDivider` | `gray5 @ 18%` | `gray5 @ 40%` | Right-edge divider |

### Plane B — Content

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `surfaces.canvas` | `gray6` = `#E7EAEC` | `gray6` = `#2E3233` | Unified content bg |
| `surfaces.contentControl` | `#F2F4F6` / `#EEF1F4` | `#2A2D2F` / `#282C2E` | Mode-aware content control |

### Text Hierarchy

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `content.textPrimary` | `gray1` = `#1E1F20` | `#E0E1E1` | Headlines, primary |
| `content.textSecondary` | `gray3` = `#5B6062` | `#C8CDCF` | Body text |
| `content.textTertiary` | `gray4` = `#7F8587` | `#ABB0B2` | Metadata, hints |

---

## 5. Divider Inventory

### Currently Exist (audit needed)

The following dividers likely exist in the codebase. Most should be removed:

| Location | Action |
|----------|--------|
| Header ↔ Search | **REMOVE** — use spacing |
| Search ↔ Message list | **REMOVE** — use spacing |
| Sidebar ↔ Content | **KEEP** — only hard divider |
| Between cassette sections | **KEEP** if semantically meaningful, else remove |
| Message row separators | **KEEP** — aids scanning |

---

## 6. Enforcement Checklist

When reviewing or writing feature widgets:

- [ ] Uses `AppSpacing.*` for all padding/margins
- [ ] Uses `typography.*` for all text styles
- [ ] Uses `colors.*` for all colors
- [ ] Does NOT use raw `EdgeInsets(...)` with custom values
- [ ] Does NOT use raw `TextStyle(...)` with custom values
- [ ] Does NOT use raw `Color(0x...)` inline

---

## 7. Implementation Phases

### Phase 1: Foundation

1. Create `AppSpacing` class
2. Create `SidebarPlane`, `ContentPlane`, `CassetteChrome` wrappers
3. Export from theme barrel file

### Phase 2: Sidebar (Plane A)

1. Wrap sidebar root with `SidebarPlane`
2. Refactor cassettes to use `CassetteChrome` (remove card visuals)
3. Unify heatmap styling (same padding, no distinct frame)
4. Audit all spacing → convert to `AppSpacing.*`

### Phase 3: Content (Plane B)

1. Wrap center panel with `ContentPlane`
2. Remove header ↔ search divider
3. Remove search ↔ message-list divider
4. Audit all spacing → convert to `AppSpacing.*`

### Phase 4: Typography Audit

1. Grep for raw `TextStyle(...)` usage
2. Map each to one of the four roles
3. Replace with token reference
4. Remove unused custom styles

### Phase 5: Validation

1. Blur test (screenshot)
2. Squint test (screenshot)
3. Spacing grep audit (no raw values)
4. Typography grep audit (no raw styles)

---

## References

- [ui-design-contract.md](ui-design-contract.md) — Non-negotiable rules
- [seed.txt](seed.txt) — Original problem analysis
- [theme_colors.dart](../../../../lib/config/theme/colors/theme_colors.dart) — Color tokens
- [theme_typography.dart](../../../../lib/config/theme/theme_typography.dart) — Typography tokens
