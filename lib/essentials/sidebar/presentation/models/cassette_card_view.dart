import 'package:flutter/widgets.dart';

/// Presentation data for rendering a cassette inside the sidebar card shell.
class CassetteCardView {
  const CassetteCardView({
    required this.title,
    this.subtitle,
    required this.child,
  });

  /// Display title shown in the sidebar card header.
  final String title;

  /// Optional descriptive text shown below the title.
  final String? subtitle;

  /// The cassette content widget rendered inside the card.
  final Widget child;
}
