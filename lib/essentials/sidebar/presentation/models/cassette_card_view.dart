import 'package:flutter/widgets.dart';

/// Presentation data for rendering a cassette inside the sidebar card shell.
class CassetteCardView {
  const CassetteCardView({
    required this.title,
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    required this.child,
    this.isControl = false,
    bool? shouldExpand,
  }) : shouldExpand = shouldExpand ?? !isControl;

  /// Display title shown in the sidebar card header.
  final String title;

  /// Optional descriptive text shown below the title.
  final String? subtitle;

  final String? sectionTitle;
  final String? footerText;

  /// The cassette content widget rendered inside the card.
  final Widget child;

  /// Whether this cassette is primarily a control surface (vs content).
  /// Control cassettes should be visually de-emphasized in the sidebar.
  final bool isControl;

  /// Whether this cassette should expand to fill available vertical space.
  /// Defaults to true for content cassettes, false for control cassettes.
  final bool shouldExpand;
}
