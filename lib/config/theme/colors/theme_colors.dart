// lib/config/theme_colors.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/navigation/application/sidebar_mode_provider.dart';
import '../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../providers.dart'
    show platformBrightnessProvider, switchableDarkModeProvider;

part 'theme_colors.g.dart';

/// Compound state type for ThemeColors: (brightness, sidebar mode).
typedef ThemeColorsState = (Brightness, SidebarMode);

/// Organized collection of theme color tokens.
/// Each token is defined as an immutable light/dark pair ([ColorPair]).
/// The [ThemeColors] provider resolves tokens based on the current brightness.
///
/// **CRITICAL: Correct Usage Pattern for Reactive Rebuilds**
///
/// To ensure widgets rebuild when the theme changes (light/dark mode switch),
/// you MUST watch the provider's state, then read the notifier:
///
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   // Watch the Brightness state - triggers rebuilds on theme changes
///   ref.watch(themeColorsProvider);
///   // Read the notifier instance - provides access to color methods
///   final colors = ref.read(themeColorsProvider.notifier);
///
///   // Now use colors.surfaces.canvas, colors.globals.gray.one, etc.
/// }
/// ```
///
/// **Why this pattern is required:**
/// - `ref.watch(themeColorsProvider.notifier)` watches the notifier INSTANCE,
///   which never changes - this will NOT trigger rebuilds on theme changes.
/// - `ref.watch(themeColorsProvider)` watches the STATE (Brightness), which
///   DOES change and triggers rebuilds.
/// - `ref.read(themeColorsProvider.notifier)` then provides access to the
///   ThemeColors instance with all its color resolution methods.
///
/// **DO NOT USE** (this will not rebuild on theme changes):
/// ```dart
/// final colors = ref.watch(themeColorsProvider.notifier); // ❌ Wrong!
/// ```
///
/// The provider's state is [Brightness], which triggers rebuilds when light/dark
/// mode changes. The notifier provides the color resolution API.

/// Immutable light/dark pair.
class ColorPair {
  const ColorPair(this.light, this.dark);

  final Color light;
  final Color dark;

  Color resolve(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// ============================================================================
/// Flow: ThemeColors provider
/// -------------------------------
/// 1. Define color tokens as ColorPair pairs (light/dark).
/// 2. Create ThemeColors Riverpod provider that resolves tokens based on
///    current brightness (system or user-selected).
/// 3. Organize tokens into semantic groups (globals, surfaces, content, etc.).
/// 4. Use ThemeColors provider throughout the app for consistent theming.
///
/// Each semantic class is intialized with a reference to ThemeColors (_t),
/// allowing it to resolve individual tokens as needed:
///
///   (1) Call methods like _t.grayOne, _t.brandHighlight(), etc.
///   (2) Access _t.isDark to determine current brightness
///    (3) Use _t.resolvePair() to resolve ColorPair pairs
/// ============================================================================

// ---------------------------------------------------------------------------
// Shared semantic color groups
//
// These groups are intended to be the *main* palette most widgets draw from,
// providing harmony across the app. Only create widget-specific palettes
// (e.g. CassetteCard) when a component truly needs multiple unique tokens.
// ---------------------------------------------------------------------------

/// Global, reusable primitives (grays + brand highlights).
class Globals {
  const Globals(this._t);

  final ThemeColors _t;

  GrayGlobals get gray => GrayGlobals(_t);
  BrandGlobals get brand => BrandGlobals(_t);
}

class GrayGlobals {
  const GrayGlobals(this._t);
  final ThemeColors _t;

  Color get one => _t.grayOne;
  Color get two => _t.grayTwo;
  Color get three => _t.grayThree;
  Color get four => _t.grayFour;
  Color get five => _t.grayFive;
  Color get six => _t.graySix;
}

class BrandGlobals {
  const BrandGlobals(this._t);
  final ThemeColors _t;

  Color get primary => _t.brandHighlight(BrandHighlight.primary);
  Color get secondary => _t.brandHighlight(BrandHighlight.secondary);

  /// A softer accent for background tints / atmosphere (not “actionable”).
  ///
  /// If you later add `BrandHighlight.tertiary`, you can wire this directly.
  Color get tertiary => _t.brandHighlight(BrandHighlight.tertiary);
}

/// Semantic surface fills (backgrounds and control fills).
class Surfaces {
  const Surfaces(this._t);
  final ThemeColors _t;

  Color _r(ColorPair p) => _t.resolvePair(p);

  /// Window/app background.
  Color get canvas => _t.globals.gray.six;

  /// Sidebar / inspector panel background.
  Color get panel => _r(const ColorPair(Color(0xFFF6F7F8), Color(0xFF232627)));

  // -- Mode-aware content control surfaces --

  /// Messages mode: neutral gray-ish background.
  Color get _messagesContentControl =>
      _r(const ColorPair(Color(0xFFF2F4F6), Color(0xFF2A2D2F)));

  /// Settings mode: slightly cooler/blue-gray tint to distinguish context.
  Color get _settingsContentControl =>
      _r(const ColorPair(Color(0xFFEEF1F4), Color(0xFF282C2E)));

  /// Content control panel background (left column holding cassette rack).
  ///
  /// Holds a dynamic hierarchy of widgets (cassette rack) that respond to user
  /// inputs by offering new options for displaying content in the central area.
  /// Automatically adjusts tint based on sidebar mode (messages vs settings).
  Color get contentControl =>
      _t.isSettingsMode ? _settingsContentControl : _messagesContentControl;

  /// Default surface for grouped content (cards, groups).
  Color get surface =>
      _r(const ColorPair(Color(0xFFFFFFFF), Color(0xFF2A2D2E)));

  /// Slightly elevated surface (popovers, sheets).
  Color get surfaceRaised =>
      _r(const ColorPair(Color(0xFFFFFFFF), Color(0xFF323638)));

  /// Fill for interactive controls (buttons, chips, inputs).
  Color get control =>
      _r(const ColorPair(Color(0xFFF2F3F5), Color(0xFF3A3E40)));

  /// Muted/disabled control fill.
  Color get controlMuted => _t.globals.gray.six;

  /// Hover fill (use over [surface]/[control]).
  Color get hover => _r(const ColorPair(Color(0x0A000000), Color(0x14FFFFFF)));

  /// Pressed fill (use over [surface]/[control]).
  Color get pressed =>
      _r(const ColorPair(Color(0x14000000), Color(0x1FFFFFFF)));

  /// Subtle selected row/tile background.
  ///
  /// Intentionally derived from the primary accent to feel "related" without
  /// competing with foreground selection indicators.
  Color get selected =>
      _t.accents.primary.withValues(alpha: _t.isDark ? 0.22 : 0.12);
}

/// Text + icon content colors.
class ContentColors {
  const ContentColors(this._t);
  final ThemeColors _t;

  Color get textPrimary => _t.globals.gray.one;
  Color get textSecondary => _t.globals.gray.three;
  Color get textSecondaryQuiet => textSecondary.withValues(alpha: 0.55);
  Color get textTertiary => _t.globals.gray.four;
  Color get textDisabled =>
      _t.globals.gray.five.withValues(alpha: _t.isDark ? 0.65 : 0.7);

  Color get iconPrimary => textPrimary;
  Color get iconSecondary => textSecondary;
  Color get iconDisabled => textDisabled;
}

/// Dividers and borders.
class Lines {
  const Lines(this._t);
  final ThemeColors _t;

  Color _base() => _t.globals.gray.five;

  Color get divider => _base().withValues(alpha: _t.isDark ? 0.55 : 0.6);

  /// Quieter divider for subtle UI elements (e.g., inactive mode toggle outline).
  Color get dividerQuiet => _base().withValues(alpha: _t.isDark ? 0.40 : 0.55);

  Color get borderSubtle => _base().withValues(alpha: _t.isDark ? 0.40 : 0.45);
  Color get border => _base().withValues(alpha: _t.isDark ? 0.65 : 0.70);
  Color get borderStrong =>
      _t.globals.gray.four.withValues(alpha: _t.isDark ? 0.85 : 0.85);

  /// Vertical divider for content control panel (more subtle than standard divider).
  Color get contentControlDivider =>
      _base().withValues(alpha: _t.isDark ? 0.40 : 0.18);

  /// A "layered" border recipe often useful for dropdowns/popovers.
  BorderLayers get dropdown => BorderLayers(outer: border, inner: borderSubtle);
}

/// Border recipe (outer + inner) for components that want a "layered" outline.
class BorderLayers {
  const BorderLayers({required this.outer, required this.inner});
  final Color outer;
  final Color inner;
}

/// Accent usage (semantic), backed by brand primitives.
class Accents {
  const Accents(this._t);
  final ThemeColors _t;

  Color get primary => _t.globals.brand.primary;
  Color get secondary => _t.globals.brand.secondary;
  Color get tertiary => _t.globals.brand.tertiary;

  /// Focus ring ink (usually primary accent with alpha).
  Color get focusRing => primary.withValues(alpha: _t.isDark ? 0.55 : 0.45);

  /// Foreground selection indicator (e.g. active tab underline).
  Color get selection => primary;
}

/// Shadows and scrims.
class Overlays {
  const Overlays(this._t);
  final ThemeColors _t;

  Color _r(ColorPair p) => _t.resolvePair(p);

  /// Modal background scrim.
  Color get scrim => _r(const ColorPair(Color(0x59000000), Color(0x73000000)));

  /// Generic shadow color (used with blur/spread to create elevation).
  Color get shadow => _r(const ColorPair(Color(0x1F000000), Color(0x33000000)));
}

/// Semantic button-state tokens for consistent button appearance everywhere.
///
/// Covers primary (accent-coloured), secondary (neutral), and destructive
/// buttons in both enabled and disabled states.
class ButtonColors {
  const ButtonColors(this._t);
  final ThemeColors _t;

  Color _r(ColorPair p) => _t.resolvePair(p);

  // -- Primary (accent) --------------------------------------------------

  /// Enabled primary button background (brand accent).
  Color get primaryBackground => _t.accents.primary;

  /// Enabled primary button text (always white on accent).
  Color get primaryForeground =>
      _r(const ColorPair(Color(0xFFFFFFFF), Color(0xFFFFFFFF)));

  /// Disabled primary button background — still identifiable as the action
  /// button but clearly muted.
  Color get primaryBackgroundDisabled =>
      _t.accents.primary.withValues(alpha: _t.isDark ? 0.25 : 0.35);

  /// Disabled primary button text.
  Color get primaryForegroundDisabled => _r(
    const ColorPair(Color(0xFFFFFFFF), Color(0xFFFFFFFF)),
  ).withValues(alpha: _t.isDark ? 0.40 : 0.55);

  // -- Secondary (neutral) ------------------------------------------------

  /// Enabled secondary button background.
  Color get secondaryBackground => _t.surfaces.control;

  /// Enabled secondary button text.
  Color get secondaryForeground => _t.content.textPrimary;

  /// Disabled secondary button background.
  Color get secondaryBackgroundDisabled =>
      _r(const ColorPair(Color(0xFFE7EAEC), Color(0xFF383C3E)));

  /// Disabled secondary button text.
  Color get secondaryForegroundDisabled =>
      _r(const ColorPair(Color(0xFFA8AEB0), Color(0xFF6B7072)));

  // -- Destructive --------------------------------------------------------

  /// Destructive button text (enabled).
  Color get destructiveForeground =>
      _r(const ColorPair(Color(0xFFFF3B30), Color(0xFFFF453A)));

  /// Destructive button border (enabled).
  Color get destructiveBorder => _r(
    const ColorPair(Color(0xFFFF3B30), Color(0xFFFF453A)),
  ).withValues(alpha: 0.30);
}

/// Interactive hint tokens for subtle hover/focus affordances.
///
/// Use these for "text-as-control" patterns where the primary content
/// (e.g., a name, title) is clickable but should not look like a button.
///
/// ## Usage Pattern
///
/// ```dart
/// final hints = colors.interactiveHints;
///
/// // Background lift on hover
/// final bgColor = isHovered
///     ? hints.backgroundLift
///     : Colors.transparent;
///
/// // Icon contrast: subtle at rest, visible on hover
/// final iconColor = textPrimary.withValues(
///   alpha: isHovered ? hints.iconActiveAlpha : hints.iconRestAlpha,
/// );
/// ```
///
/// ## Geometry Recommendations (pair with these colors)
/// - Padding: horizontal 6px, vertical 5px (asymmetric for breathing room)
/// - Corner radius: 6px (soft, matches card language)
/// - Negative margin: -6px horizontal to offset padding visually
/// - Transition duration: 120ms
/// Muted initial-letter badge for contact rows.
/// Neutral grays only — no per-contact color coding.
class ContactBadge {
  ContactBadge(this._t);
  final ThemeColors _t;

  /// Circle background: textTertiary at 12% alpha.
  Color get background => _t.content.textTertiary.withValues(alpha: 0.12);

  /// Letter foreground: full textTertiary.
  Color get foreground => _t.content.textTertiary;
}

class InteractiveHints {
  const InteractiveHints(this._t);
  final ThemeColors _t;

  /// Subtle background lift for text-as-control hover state.
  ///
  /// A neutral tint (5% of textPrimary) that provides visual feedback
  /// without competing with the card's own shape language.
  Color get backgroundLift => _t.content.textPrimary.withValues(alpha: 0.05);

  /// Icon alpha at rest (de-emphasized, hint only).
  ///
  /// Use 25% for auto-generated content, 40% if user has customized.
  double get iconRestAlpha => 0.25;

  /// Icon alpha at rest when user has overridden/customized the value.
  ///
  /// Slightly more visible to hint that customization exists.
  double get iconRestAlphaOverridden => 0.40;

  /// Icon alpha on hover/focus (clearly visible).
  double get iconActiveAlpha => 0.90;

  /// Recommended corner radius for hover backgrounds.
  double get cornerRadius => 6.0;

  /// Recommended horizontal padding for hover hitbox.
  double get paddingHorizontal => 6.0;

  /// Recommended vertical padding for hover hitbox.
  double get paddingVertical => 5.0;

  // -- Favorite star (hero card) ----------------------------------------

  /// Filled-star color when favorited and at rest (muted, non-competing).
  ///
  /// Uses the warm amber from the system star glyph at reduced saturation
  /// so it reads as "active but secondary" next to the display name.
  Color get starFavoritedResting =>
      const Color(0xFFFFC107).withValues(alpha: 0.55);

  /// Filled-star color when favorited and hovered (crisp feedback).
  Color get starFavoritedHover =>
      const Color(0xFFFFC107).withValues(alpha: 0.90);
}

enum GrayTone {
  one,
  two,
  three,
  four,
  five,
  six;

  static const Map<GrayTone, ColorPair> _palette = {
    GrayTone.one: ColorPair(Color(0xFF1E1F20), Color(0xFFE0E1E1)),
    GrayTone.two: ColorPair(Color(0xFF343638), Color(0xFFDADEE0)),
    GrayTone.three: ColorPair(Color(0xFF5B6062), Color(0xFFC8CDCF)),
    GrayTone.four: ColorPair(Color(0xFF7F8587), Color(0xFFABB0B2)),
    GrayTone.five: ColorPair(Color(0xFFA8AEB0), Color(0xFF424647)),
    GrayTone.six: ColorPair(Color(0xFFE7EAEC), Color(0xFF2E3233)),
  };

  ColorPair get pair => _palette[this]!;
}

/// Brand/accent highlight tokens.
enum BrandHighlight {
  primary,
  secondary,
  tertiary;

  static const Map<BrandHighlight, ColorPair> _palette = {
    BrandHighlight.primary: ColorPair(Color(0xFF007AFF), Color(0xFF0A84FF)),
    BrandHighlight.secondary: ColorPair(Color(0xFF5AC8FA), Color(0xFF64D2FF)),
    // Soft accent (atmosphere / subtle emphasis)
    BrandHighlight.tertiary: ColorPair(Color(0xFF64748B), Color(0xFF94A3B8)),
  };

  ColorPair get pair => _palette[this]!;
}

/// Semantic tokens for cassette card components.
enum CassetteCard {
  background,
  titleText,
  subtitleText,
  divider,
  shadow;

  static const Map<CassetteCard, ColorPair> _palette = {
    CassetteCard.background: ColorPair(Color(0xFFFFFFFF), Color(0xFF2E3233)),
    CassetteCard.titleText: ColorPair(Color(0xFF1E1F20), Color(0xFFE0E1E1)),
    CassetteCard.subtitleText: ColorPair(Color(0xFF7F8587), Color(0xFFABB0B2)),
    CassetteCard.divider: ColorPair(Color(0xFFA8AEB0), Color(0xFF424647)),
    CassetteCard.shadow: ColorPair(Color(0x1F000000), Color(0x33000000)),
  };

  ColorPair get pair => _palette[this]!;
}

/// Semantic tokens for iMessage-style chat bubbles.
enum MessageBubble {
  /// Sent (blue) bubble background.
  sentBg,

  /// Received (gray) bubble background.
  receivedBg,

  /// Text on sent (blue) bubble — always high contrast on blue.
  sentText,

  /// Text on received (gray) bubble — flips for dark mode.
  receivedText,

  /// Search highlight background on sent (blue) bubble.
  sentHighlight,

  /// Search highlight background on received (gray) bubble.
  receivedHighlight,

  /// Dark strip behind the domain label in link previews.
  linkBanner,

  /// Text on the link banner strip.
  linkBannerText,

  /// Metadata line below bubbles (sender · timestamp).
  metadata;

  static const Map<MessageBubble, ColorPair> _palette = {
    MessageBubble.sentBg: ColorPair(Color(0xFF0A84FF), Color(0xFF0A84FF)),
    MessageBubble.receivedBg: ColorPair(Color(0xFFE9E9EB), Color(0xFF3A3A3C)),
    MessageBubble.sentText: ColorPair(Color(0xFFFFFFFF), Color(0xFFFFFFFF)),
    MessageBubble.receivedText: ColorPair(Color(0xFF000000), Color(0xFFFFFFFF)),
    MessageBubble.sentHighlight: ColorPair(
      Color(0xFF0056B3),
      Color(0xFF4DA3FF),
    ),
    MessageBubble.receivedHighlight: ColorPair(
      Color(0xFFB3D7FF),
      Color(0xFF1A4D80),
    ),
    MessageBubble.linkBanner: ColorPair(Color(0xFF1C1C1E), Color(0xFF48484A)),
    MessageBubble.linkBannerText: ColorPair(
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
    ),
    MessageBubble.metadata: ColorPair(Color(0xFF6E6E73), Color(0xFF98989D)),
  };

  ColorPair get pair => _palette[this]!;
}

/// Semantic tokens for dropdown menu components.
///
/// Dark mode design: Selection is communicated through luminance,
/// not hue. Selected rows are brighter surfaces with high-emphasis
/// white text. Accent color reinforces state via checkmarks and
/// indicators but does not carry primary contrast.
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
enum DropdownMenu {
  /// Selected row background — must visibly lift from panel surface.
  selectedBg,

  /// Selected row text — high-emphasis, brightest in the menu.
  selectedText,

  /// Checkmark / selection indicator — accent reinforcement.
  checkmark,

  /// Chevron icon color.
  chevronIcon,

  /// Chevron pill background.
  chevronBg;

  static const Map<DropdownMenu, ColorPair> _palette = {
    // Light: 16% accent blue on white. Dark: visible luminance lift.
    DropdownMenu.selectedBg: ColorPair(
      Color(0x290A84FF), // ~16% blue on white
      Color(0xFF454A4C), // confident lift from surfaceRaised 0xFF323638
    ),
    // Light: accent blue. Dark: high-emphasis white (luminance > hue).
    DropdownMenu.selectedText: ColorPair(Color(0xFF007AFF), Color(0xFFFFFFFF)),
    // Checkmark: accent in both modes, but brighter in dark.
    DropdownMenu.checkmark: ColorPair(Color(0xFF007AFF), Color(0xFF4DA6FF)),
    // Chevron icon: accent in light, secondary content in dark.
    DropdownMenu.chevronIcon: ColorPair(
      Color(0xFF007AFF),
      Color(0xFFC8CDCF), // matches gray.three dark
    ),
    // Chevron pill: visible tint in both modes.
    DropdownMenu.chevronBg: ColorPair(
      Color(0x1F007AFF), // 12% blue on white
      Color(0x33C8CDCF), // 20% gray on dark control
    ),
  };

  ColorPair get pair => _palette[this]!;
}

/// Semantic tokens for “info cards” (explanatory copy, empty-state help, etc.)
///
/// Visual intent:
/// - Present in the cassette flow, but lighter than data/control cards.
/// - No shadow. Soft surface tint. Calm ink.
/// - Optional “terminology” ink for app-specific terms (e.g., “stray emails”).
enum InfoCard {
  /// Soft background surface for explanatory cards.
  background,

  /// Optional hairline border for separation (very subtle).
  border,

  /// Primary informational ink (lead sentence, headings if any).
  textPrimary,

  /// Secondary informational ink (body copy).
  textSecondary,

  /// Tertiary / hint ink (footnotes like “Coming soon”).
  textTertiary,

  /// Terminology emphasis ink (for app-specific terms).
  termInk;

  static const Map<InfoCard, ColorPair> _palette = {
    // Light: warm near-white that lifts off the cool gray sidebar (~F2F4F6).
    // Dark: slightly lifted from the panel to read as a distinct "soft surface".
    // Intent: clearly a card, but softer than white data cards.
    InfoCard.background: ColorPair(Color(0xFFFAF9F7), Color(0xFF3A3F41)),

    // Subtle hairline; intended to be used sparingly.
    InfoCard.border: ColorPair(Color(0x33A8AEB0), Color(0x33424647)),

    // These align with your grayscale ink intent.
    InfoCard.textPrimary: ColorPair(Color(0xFF343638), Color(0xFFDADEE0)),
    InfoCard.textSecondary: ColorPair(Color(0xFF5B6062), Color(0xFFB0B5B7)),
    InfoCard.textTertiary: ColorPair(Color(0xFF7F8587), Color(0xFFABB0B2)),

    // Terminology: deliberately *not* your BrandHighlight blue.
    // Uses an “amber/orange” that can become part of the app’s lexicon.
    InfoCard.termInk: ColorPair(Color(0xFFB86A00), Color(0xFFFFB340)),
  };

  ColorPair get pair => _palette[this]!;
}

@riverpod
class ThemeColors extends _$ThemeColors {
  @override
  ThemeColorsState build() {
    final brightness = _resolveBrightness();
    final mode = ref.watch(activeSidebarModeProvider);
    return (brightness, mode);
  }

  /// Current brightness (light or dark).
  Brightness get brightness => state.$1;

  /// Current sidebar mode (messages or settings).
  SidebarMode get sidebarMode => state.$2;

  Color gray(GrayTone tone) => tone.pair.resolve(brightness);
  Color brandHighlight(BrandHighlight tone) => tone.pair.resolve(brightness);
  Color cassetteCard(CassetteCard tone) => tone.pair.resolve(brightness);
  Color messageBubble(MessageBubble tone) => tone.pair.resolve(brightness);
  Color dropdownMenu(DropdownMenu tone) => tone.pair.resolve(brightness);

  /// Resolve an InfoCard token for the current brightness.
  Color infoCard(InfoCard tone) => tone.pair.resolve(brightness);

  // Convenience getters for gray tones
  Color get grayOne => gray(GrayTone.one);
  Color get grayTwo => gray(GrayTone.two);
  Color get grayThree => gray(GrayTone.three);
  Color get grayFour => gray(GrayTone.four);
  Color get grayFive => gray(GrayTone.five);
  Color get graySix => gray(GrayTone.six);

  /// Resolve a raw [ColorPair] pair against the current brightness.
  Color resolvePair(ColorPair pair) => pair.resolve(brightness);

  /// True when the current brightness is dark.
  bool get isDark => brightness == Brightness.dark;

  /// True when the sidebar is in settings mode.
  bool get isSettingsMode => sidebarMode == SidebarMode.settings;

  /// True when the sidebar is in messages mode.
  bool get isMessagesMode => sidebarMode == SidebarMode.messages;

  // -------------------------------------------------------------------------
  // Shared semantic color groups (preferred API)
  // -------------------------------------------------------------------------

  Globals get globals => Globals(this);
  Surfaces get surfaces => Surfaces(this);
  ContentColors get content => ContentColors(this);
  Lines get lines => Lines(this);
  Accents get accents => Accents(this);
  Overlays get overlays => Overlays(this);
  ButtonColors get buttons => ButtonColors(this);
  InteractiveHints get interactiveHints => InteractiveHints(this);
  ContactBadge get contactBadge => ContactBadge(this);

  Brightness _resolveBrightness() {
    if (ref.exists(switchableDarkModeProvider)) {
      final themeMode = ref.watch(switchableDarkModeProvider);
      if (themeMode == ThemeMode.dark) {
        return Brightness.dark;
      }
      if (themeMode == ThemeMode.light) {
        return Brightness.light;
      }
      // fall through to system below when ThemeMode.system
    }

    return ref.watch(platformBrightnessProvider);
  }
}
