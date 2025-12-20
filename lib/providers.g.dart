// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$platformBrightnessHash() =>
    r'10acf764fbcc7d0e82e155478ef189c0127e851a';

///***************************************************************** */
///*
///*       Define providers that are:
///*
///*            (1) initialized asynchronously or
///*            (2) used by multiple features.
///*
///***************************************************************** */
///
/// Copied from [platformBrightness].
@ProviderFor(platformBrightness)
final platformBrightnessProvider = AutoDisposeProvider<Brightness>.internal(
  platformBrightness,
  name: r'platformBrightnessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$platformBrightnessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlatformBrightnessRef = AutoDisposeProviderRef<Brightness>;
String _$sharedPreferencesHash() => r'6c03b929f567eb6f97608f6208b95744ffee3bfd';

/// The asynchronous provider of the [SharedPreferences] instance.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
      sharedPreferences,
      name: r'sharedPreferencesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sharedPreferencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$pathsHelperHash() => r'5252def1042151aa97852715b35adf65a0a9bb1c';

/// The asynchronous provider of [PathsHelper].
///
/// Copied from [pathsHelper].
@ProviderFor(pathsHelper)
final pathsHelperProvider = AutoDisposeFutureProvider<PathsHelper>.internal(
  pathsHelper,
  name: r'pathsHelperProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pathsHelperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PathsHelperRef = AutoDisposeFutureProviderRef<PathsHelper>;
String _$darkModeRefresherHash() => r'd674ea31b0f64126c2a783f8301bd1b9d1562722';

/// See also [darkModeRefresher].
@ProviderFor(darkModeRefresher)
final darkModeRefresherProvider = AutoDisposeProvider<bool>.internal(
  darkModeRefresher,
  name: r'darkModeRefresherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$darkModeRefresherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DarkModeRefresherRef = AutoDisposeProviderRef<bool>;
String _$selectedPageIndexHash() => r'bc30c0eceb040c96c3ea8a896d47b53a9a8cd951';

/// Cache the index of the page selected in the sidebar
/// so that it can be accessed by the ChatRouterDelegate
///
/// Copied from [SelectedPageIndex].
@ProviderFor(SelectedPageIndex)
final selectedPageIndexProvider =
    AutoDisposeNotifierProvider<SelectedPageIndex, int>.internal(
      SelectedPageIndex.new,
      name: r'selectedPageIndexProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedPageIndexHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedPageIndex = AutoDisposeNotifier<int>;
String _$isDarkModeHash() => r'20b40248c1ab2b582c992259abf0337a871c4024';

/// Dark mode provider that automatically initializes from platform brightness
/// and provides methods to toggle dark mode
///
/// Copied from [IsDarkMode].
@ProviderFor(IsDarkMode)
final isDarkModeProvider =
    AutoDisposeNotifierProvider<IsDarkMode, bool>.internal(
      IsDarkMode.new,
      name: r'isDarkModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isDarkModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IsDarkMode = AutoDisposeNotifier<bool>;
String _$switchableDarkModeHash() =>
    r'a6a6949ba4e7cfc5d9aaf03151601a351b7373c8';

/// Temporary override for app theme mode while iterating on theming.
///
/// Defaults to `ThemeMode.system`, and can be toggled by UI (toolbar button).
///
/// Copied from [SwitchableDarkMode].
@ProviderFor(SwitchableDarkMode)
final switchableDarkModeProvider =
    AutoDisposeNotifierProvider<SwitchableDarkMode, ThemeMode>.internal(
      SwitchableDarkMode.new,
      name: r'switchableDarkModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$switchableDarkModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SwitchableDarkMode = AutoDisposeNotifier<ThemeMode>;
String _$colorWatcherHash() => r'bdb6660517426c40c71112b3874c3b07c7955325';

/// See also [ColorWatcher].
@ProviderFor(ColorWatcher)
final colorWatcherProvider =
    AutoDisposeNotifierProvider<ColorWatcher, bool>.internal(
      ColorWatcher.new,
      name: r'colorWatcherProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$colorWatcherHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ColorWatcher = AutoDisposeNotifier<bool>;
String _$selectedScreenTagHash() => r'13990b5b8869a55e383a49cfddb56116dceb9499';

/// See also [SelectedScreenTag].
@ProviderFor(SelectedScreenTag)
final selectedScreenTagProvider =
    AutoDisposeNotifierProvider<SelectedScreenTag, String>.internal(
      SelectedScreenTag.new,
      name: r'selectedScreenTagProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedScreenTagHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedScreenTag = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
