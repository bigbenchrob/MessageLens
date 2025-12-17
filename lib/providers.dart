// Unnecessary core/dart imports removed

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:sqflite/sqflite.dart';

import 'config/colors.dart';
import 'core/util/paths_helper.dart';

//import 'features/folders/domain/failures/folder_find_failure.dart';

part 'providers.g.dart';

///***************************************************************** */
///*
///*       Define providers that are:
///*
///*            (1) initialized asynchronously or
///*            (2) used by multiple features.
///*
///***************************************************************** */

// Platform brightness provider for initializing dark mode
@riverpod
Brightness platformBrightness(Ref ref) {
  // This will be overridden in main.dart with the actual platform brightness
  return Brightness.light;
}

/// The asynchronous provider of the [SharedPreferences] instance.
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// The asynchronous provider of [PathsHelper].
@riverpod
Future<PathsHelper> pathsHelper(Ref ref) async {
  return PathsHelper.asyncInstance;
}

/// Cache the index of the page selected in the sidebar
/// so that it can be accessed by the ChatRouterDelegate
@riverpod
class SelectedPageIndex extends _$SelectedPageIndex {
  @override
  int build() {
    return 0;
  }

  // ignore: use_setters_to_change_properties
  void setIndex(int index) {
    state = index;
  }
}

/// Dark mode provider that automatically initializes from platform brightness
/// and provides methods to toggle dark mode
@riverpod
class IsDarkMode extends _$IsDarkMode {
  @override
  bool build() {
    // Initialize from platform brightness
    // ignore: avoid_manual_providers_as_generated_provider_dependency
    final brightness = ref.watch(platformBrightnessProvider);
    return brightness == Brightness.dark;
  }

  void toggle() {
    state = !state;
  }

  // Prefer a method for write operations; consumers should read state via the provider.
  // ignore: use_setters_to_change_properties
  void setEnabled({required bool enabled}) {
    state = enabled;
  }

  void checkToggle(Brightness brightness) {
    final shouldBeDark = brightness == Brightness.dark;
    if (state != shouldBeDark) {
      toggle();
    }
  }
}

/// Temporary override for app theme mode while iterating on theming.
///
/// Defaults to `ThemeMode.system`, and can be toggled by UI (toolbar button).
@riverpod
class SwitchableDarkMode extends _$SwitchableDarkMode {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }

  void cycle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }
}

@riverpod
bool darkModeRefresher(Ref ref) {
  return ref.watch(isDarkModeProvider);
}

@riverpod
class ColorWatcher extends _$ColorWatcher {
  /// Hold the cached value of bool dark mode in state so build()
  /// will be retriggered if that changes and can be easily
  /// accessed by getColor()
  @override
  bool build() {
    return ref.watch(darkModeRefresherProvider);
  }

  Color fetch(String colorKey) {
    final darkMode = state;
    const errorColor = Colors.red;

    Color? color;
    if (darkMode) {
      final item = NamedDarkColors.values.firstWhereOrNull(
        (element) => element.name == colorKey,
      );
      color = item?.color;
    } else {
      final item = NamedLightColors.values.firstWhereOrNull(
        (element) => element.name == colorKey,
      );
      color = item?.color;
    }

    return color ?? errorColor;
  }
}

@riverpod
class SelectedScreenTag extends _$SelectedScreenTag {
  @override
  String build() {
    return 'home';
  }

  // ignore: use_setters_to_change_properties
  void setTag(String tag) {
    state = tag;
  }
}
