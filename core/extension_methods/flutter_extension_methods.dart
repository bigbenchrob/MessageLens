// import 'package:flutter/material.dart';

// extension BuildContextExtensions on BuildContext {
//   ThemeData get theme => Theme.of(this);

//   TextTheme get textTheme => theme.textTheme;

//   ColorScheme get colorScheme => theme.colorScheme;

//   DefaultTextStyle get defaultTextStyle => DefaultTextStyle.of(this);

//   MediaQueryData get mediaQuery => MediaQuery.of(this);

//   NavigatorState get navigator => Navigator.of(this);

//   FocusScopeNode get focusScope => FocusScope.of(this);

//   ScaffoldState get scaffold => Scaffold.of(this);

//   ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
// }

// extension MaterialStateHelpers on Iterable<WidgetState> {
//   bool get isHovered => contains(WidgetState.hovered);
//   bool get isFocused => contains(WidgetState.focused);
//   bool get isPressed => contains(WidgetState.pressed);
//   bool get isDragged => contains(WidgetState.dragged);
//   bool get isSelected => contains(WidgetState.selected);
//   bool get isScrolledUnder => contains(WidgetState.scrolledUnder);
//   bool get isDisabled => contains(WidgetState.disabled);
//   bool get isError => contains(WidgetState.error);
// }

// extension IterableExtensions on Iterable {
//   bool containsAny(Iterable<Object?> other) => other.any((e) => contains(e));
// }

// extension IterableMaterialStateExtensions on Iterable<WidgetState> {
//   bool containsAny(Iterable<WidgetState> other) =>
//       other.any((e) => contains(e));
// }
