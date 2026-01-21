import 'package:flutter/widgets.dart';

/// The type of card container to render for a cassette.
///
/// Used by [CassetteWidgetCoordinator] to select the appropriate wrapper.
enum CassetteCardType {
  /// Standard cassette card with title, subtitle, section, footer slots.
  /// Supports both full cards and "naked" mode for plain controls.
  standard,

  /// Soft informational card for explanatory text.
  /// Uses [SidebarInfoCard] with tinted background, optional title/footnote.
  /// When this type is used, [infoBodyText] provides the card body content.
  info,
}

/// Presentation data for rendering a cassette inside the sidebar card shell.
class SidebarCassetteCardViewModel {
  const SidebarCassetteCardViewModel({
    required this.title,
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    required this.child,
    this.cardType = CassetteCardType.standard,
    this.infoBodyText,
    this.isControl = false,
    this.isNaked = false,
    bool? shouldExpand,
  }) : shouldExpand = shouldExpand ?? !isControl;

  /// Display title shown in the sidebar card header.
  final String title;

  /// Optional descriptive text shown below the title.
  final String? subtitle;

  final String? sectionTitle;
  final String? footerText;

  /// The cassette content widget rendered inside the card.
  ///
  /// For [CassetteCardType.standard], this is the interactive body content.
  /// For [CassetteCardType.info], this is ignored; use [infoBodyText] instead.
  final Widget child;

  /// The type of card container to use for this cassette.
  ///
  /// Defaults to [CassetteCardType.standard] which uses [SidebarCassetteCard].
  /// Use [CassetteCardType.info] for explanatory cards using [SidebarInfoCard].
  final CassetteCardType cardType;

  /// Body text for info cards ([CassetteCardType.info]).
  ///
  /// When [cardType] is [CassetteCardType.info], this text is rendered as the
  /// main explanatory content of the [SidebarInfoCard].
  final String? infoBodyText;

  /// Whether this cassette is primarily a control surface (vs content).
  /// Control cassettes should be visually de-emphasized in the sidebar.
  final bool isControl;

  /// Whether this cassette should render "naked" - with only horizontal margin
  /// to align edges with cards, but no padding, border, background, or shadow.
  /// Use for dropdown menus and other controls that should align flush with
  /// cassette card edges.
  final bool isNaked;

  /// Whether this cassette should expand to fill available vertical space.
  /// Defaults to true for content cassettes, false for control cassettes.
  final bool shouldExpand;
}
