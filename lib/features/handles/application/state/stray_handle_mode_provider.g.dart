// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stray_handle_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strayHandleModeSettingHash() =>
    r'184c6b59e5d3f3aec39dc71756f55981e16122f8';

/// Provides and controls the current stray handle triage mode.
///
/// This is a global state provider that the mode switcher cassette writes to
/// and the stray handles list cassette reads from. Keeping them separate allows
/// the mode switcher to have child cassettes for additional filtering/sorting.
///
/// Copied from [StrayHandleModeSetting].
@ProviderFor(StrayHandleModeSetting)
final strayHandleModeSettingProvider =
    NotifierProvider<StrayHandleModeSetting, StrayHandleMode>.internal(
      StrayHandleModeSetting.new,
      name: r'strayHandleModeSettingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$strayHandleModeSettingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StrayHandleModeSetting = Notifier<StrayHandleMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
