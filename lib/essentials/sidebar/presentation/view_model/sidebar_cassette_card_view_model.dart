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

  /// Full-bleed navigation control for "back to previous state" actions.
  /// Uses [SidebarNavigationCard] with a subtle tinted strip.
  /// The child widget owns all internal padding, typography, and interaction.
  sidebarNavigation,
}

/// Layout style for [SidebarCassetteCard] horizontal rails.
///
/// Controls margin, padding, and title gaps without changing card structure.
/// Use this when differences are mainly about horizontal insets and breathing
/// room, not structural/behavioral changes.
enum SidebarCardLayoutStyle {
  /// Standard layout with generous horizontal insets (32pt total).
  /// Suitable for most cassettes with moderate content density.
  standard,

  /// Dense layout for space-sensitive lists (12pt horizontal inset).
  /// Use when horizontal space is at a premium (e.g., scrollable lists
  /// with metadata, action overlays, or long text content).
  listDense,

  /// Width-aligned with naked/control items (16pt horizontal inset).
  /// Use when a non-naked card (needing shouldExpand or title slots)
  /// must match the horizontal width of naked cards above it.
  controlAligned,
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
    this.layoutStyle = SidebarCardLayoutStyle.standard,
    this.infoBodyText,
    this.infoAction,
    this.isControl = false,
    this.isNaked = false,
    bool? shouldExpand,
  }) : shouldExpand = shouldExpand ?? false;

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

  /// Layout style controlling horizontal rails (margin/padding/gaps).
  ///
  /// Defaults to [SidebarCardLayoutStyle.standard] with generous insets.
  /// Use [SidebarCardLayoutStyle.listDense] for space-sensitive lists.
  final SidebarCardLayoutStyle layoutStyle;

  /// Body text for info cards ([CassetteCardType.info]).
  ///
  /// When [cardType] is [CassetteCardType.info], this text is rendered as the
  /// main explanatory content of the [SidebarInfoCard].
  final String? infoBodyText;

  /// Optional escape-hatch action widget for info cards.
  ///
  /// When [cardType] is [CassetteCardType.info] and this is non-null,
  /// the action is rendered at the bottom of the [SidebarInfoCard]
  /// as a footnote-action (mutually exclusive with [footerText]).
  final Widget? infoAction;

  /// Whether this cassette is primarily a control surface (vs content).
  /// Control cassettes should be visually de-emphasized in the sidebar.
  final bool isControl;

  /// Whether this cassette should render "naked" - with only horizontal margin
  /// to align edges with cards, but no padding, border, background, or shadow.
  /// Use for dropdown menus and other controls that should align flush with
  /// cassette card edges.
  final bool isNaked;

  /// Whether this cassette should expand to fill available vertical space.
  ///
  /// Defaults to `false` — cards take their intrinsic height unless the
  /// resolver explicitly opts in with `shouldExpand: true` (e.g. scrollable
  /// lists that should fill the remaining sidebar space).
  final bool shouldExpand;
}
