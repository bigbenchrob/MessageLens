/// Tooltip Configuration
///
/// Global defaults for tooltip behavior. These can be adjusted based on
/// user feedback or OS conventions.
///
/// ## Future Enhancements
///
/// - Per-tooltip delay overrides
/// - Animation configuration
/// - Positioning preferences
abstract final class TooltipConfig {
  /// Default delay before showing tooltip on hover.
  ///
  /// macOS convention is approximately 500-700ms. We use 500ms as a reasonable
  /// default that shows quickly but doesn't feel intrusive.
  static const Duration defaultShowDelay = Duration(milliseconds: 500);

  /// Duration tooltip remains visible after mouse leaves.
  ///
  /// Short delay prevents flicker if user briefly moves mouse away.
  static const Duration defaultHideDelay = Duration(milliseconds: 100);

  /// Duration for tooltip to stay visible after appearing.
  ///
  /// Long duration allows reading longer tooltips without rushing.
  static const Duration defaultDisplayDuration = Duration(seconds: 4);

  /// Maximum width for tooltip content.
  ///
  /// Prevents overly wide tooltips; text wraps within this constraint.
  static const double maxWidth = 200.0;
}
