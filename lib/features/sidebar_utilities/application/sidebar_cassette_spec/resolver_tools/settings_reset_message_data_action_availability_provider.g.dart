// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_reset_message_data_action_availability_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsResetMessageDataActionAvailableHash() =>
    r'4c4b3fd8ce244b09b0034476e6ec08472e2c0dd6';

/// Controls whether the Settings root exposes the advanced message-data reset
/// entry point.
///
/// Existing compositions keep the action by default. A composition whose
/// reset authority is not admitted can override this policy at its root.
///
/// Copied from [settingsResetMessageDataActionAvailable].
@ProviderFor(settingsResetMessageDataActionAvailable)
final settingsResetMessageDataActionAvailableProvider =
    AutoDisposeProvider<bool>.internal(
      settingsResetMessageDataActionAvailable,
      name: r'settingsResetMessageDataActionAvailableProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsResetMessageDataActionAvailableHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsResetMessageDataActionAvailableRef =
    AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
