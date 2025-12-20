import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import '../theme.dart';
import 'app_dropdown_menu.dart';
import 'app_primary_button.dart';

export 'app_dropdown_menu.dart';
export 'app_primary_button.dart';

/// Catalog of reusable widgets that adhere to the shared app theme.
abstract class AppThemeWidgets {
  const AppThemeWidgets._();

  /// Shared dropdown menu widget used throughout the app.
  static Widget dropdownMenu<T>({
    required List<T> options,
    required T selectedOption,
    required ValueChanged<T> onSelected,
    required String Function(T value) optionLabelBuilder,
    String? leadingLabel,
    AppDropdownItemBuilder<T>? itemBuilder,
    bool Function(T a, T b)? equals,
    EdgeInsetsGeometry outerPadding = const EdgeInsets.symmetric(vertical: 2.0),
    EdgeInsetsGeometry panelMargin = const EdgeInsets.only(top: 6.0),
    EdgeInsetsGeometry triggerPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 10.0,
    ),
    EdgeInsetsGeometry itemPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 10.0,
    ),
    BorderRadius triggerBorderRadius = const BorderRadius.all(
      Radius.circular(8.0),
    ),
    BorderRadius panelBorderRadius = const BorderRadius.all(
      Radius.circular(10.0),
    ),
    Duration animationDuration = const Duration(milliseconds: 140),
    Curve animationCurve = Curves.easeOut,
    bool expandToWidth = true,
    bool showDividers = true,
    bool showSelectionCheckmark = true,
    double trailingIconSize = 14,
    IconData closedIcon = CupertinoIcons.chevron_down,
    IconData openIcon = CupertinoIcons.chevron_up,
    ValueChanged<bool>? onMenuVisibilityChanged,
  }) {
    return AppDropdownMenu<T>(
      options: options,
      selectedOption: selectedOption,
      onSelected: onSelected,
      optionLabelBuilder: optionLabelBuilder,
      leadingLabel: leadingLabel,
      itemBuilder: itemBuilder,
      equals: equals,
      outerPadding: outerPadding,
      panelMargin: panelMargin,
      triggerPadding: triggerPadding,
      itemPadding: itemPadding,
      triggerBorderRadius: triggerBorderRadius,
      panelBorderRadius: panelBorderRadius,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      expandToWidth: expandToWidth,
      showDividers: showDividers,
      showSelectionCheckmark: showSelectionCheckmark,
      trailingIconSize: trailingIconSize,
      closedIcon: closedIcon,
      openIcon: openIcon,
      onMenuVisibilityChanged: onMenuVisibilityChanged,
    );
  }

  /// Primary action button used throughout the app.
  ///
  /// Mirrors the style used by the “Choose new contact” button in the contacts
  /// hero cassette: regular control size, padded label, and the app primary
  /// color.
  static Widget primaryButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
    ControlSize controlSize = ControlSize.regular,
    EdgeInsetsGeometry padding = const EdgeInsets.only(
      left: 14,
      right: 14,
      top: 7,
      bottom: 9,
    ),
    Widget? leading,
  }) {
    final textStyle = AppTheme.typography(context).body.copyWith(
      color: AppTheme.onPrimaryColor(context),
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );

    final child = leading == null
        ? Text(label, style: textStyle)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 8),
              Text(label, style: textStyle),
            ],
          );

    return AppPrimaryButton(
      controlSize: controlSize,
      onPressed: onPressed,
      child: DefaultTextStyle.merge(
        style: textStyle,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
