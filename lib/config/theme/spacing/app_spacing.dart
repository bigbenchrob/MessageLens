/// Spacing tokens for the UI sweep.
///
/// All layout spacing must use these values. No ad-hoc EdgeInsets or SizedBox
/// with custom values.
///
/// ## Usage
///
/// ```dart
/// // Padding
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.md),
///   child: content,
/// )
///
/// // Gaps
/// SizedBox(height: AppSpacing.lg)
///
/// // Semantic usage
/// EdgeInsets.symmetric(
///   horizontal: AppSpacing.panelPadding,
///   vertical: AppSpacing.sectionGap,
/// )
/// ```
///
/// ## Grid System
///
/// Base unit: 8pt
/// - Visual groupings use 16pt, 24pt, 32pt multiples
/// - One-off spacing values are prohibited
library;

import 'package:flutter/widgets.dart';

/// Design system spacing tokens.
///
/// All named values are multiples of the 8pt base unit.
abstract final class AppSpacing {
  const AppSpacing._();

  // ---------------------------------------------------------------------------
  // Base unit
  // ---------------------------------------------------------------------------

  /// The fundamental spacing unit (8pt).
  static const double unit = 8.0;

  // ---------------------------------------------------------------------------
  // Named sizes
  // ---------------------------------------------------------------------------

  /// Extra-small: 4pt (0.5x) — fine adjustments only.
  static const double xs = 4.0;

  /// Small: 8pt (1x) — tight spacing.
  static const double sm = 8.0;

  /// Medium: 16pt (2x) — default spacing.
  static const double md = 16.0;

  /// Large: 24pt (3x) — section breaks.
  static const double lg = 24.0;

  /// Extra-large: 32pt (4x) — major group separation.
  static const double xl = 32.0;

  /// Extra-extra-large: 48pt (6x) — panel-level vertical breaks.
  static const double xxl = 48.0;

  // ---------------------------------------------------------------------------
  // Semantic aliases
  // ---------------------------------------------------------------------------

  /// Default gap between sibling elements.
  static const double gutter = md;

  /// Gap between logical sections.
  static const double sectionGap = lg;

  /// Inset from panel edges.
  static const double panelPadding = md;

  /// Internal card/container padding.
  static const double cardPadding = md;

  /// Gap between cassette items in sidebar.
  static const double cassetteGap = sm;

  // ---------------------------------------------------------------------------
  // EdgeInsets helpers
  // ---------------------------------------------------------------------------

  /// Standard panel insets (horizontal + vertical).
  static const EdgeInsets panelInsets = EdgeInsets.all(panelPadding);

  /// Horizontal-only panel insets.
  static const EdgeInsets panelInsetsHorizontal = EdgeInsets.symmetric(
    horizontal: panelPadding,
  );

  /// Vertical-only panel insets.
  static const EdgeInsets panelInsetsVertical = EdgeInsets.symmetric(
    vertical: panelPadding,
  );

  /// Standard card insets.
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  /// Section gap as vertical padding.
  static const EdgeInsets sectionGapVertical = EdgeInsets.symmetric(
    vertical: sectionGap,
  );
}
