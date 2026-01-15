// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsCassetteCoordinatorHash() =>
    r'27e75fa16c9a0284fbff76f27e7acde4a0615b88';

/// Coordinator that maps [ContactsCassetteSpec] to cassette widgets.
///
/// Copied from [ContactsCassetteCoordinator].
@ProviderFor(ContactsCassetteCoordinator)
final contactsCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<ContactsCassetteCoordinator, void>.internal(
      ContactsCassetteCoordinator.new,
      name: r'contactsCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsCassetteCoordinator = AutoDisposeNotifier<void>;
String _$contactsSettingsCassetteCoordinatorHash() =>
    r'5800e6395e3bbe2cf12b8ad4a357c979cfefe8bf';

/// Coordinator that maps [ContactsSettingsSpec] to cassette widgets.
///
/// This separates the "Settings" concerns from the main operational views
/// of the Contacts feature.
///
/// Copied from [ContactsSettingsCassetteCoordinator].
@ProviderFor(ContactsSettingsCassetteCoordinator)
final contactsSettingsCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<
      ContactsSettingsCassetteCoordinator,
      void
    >.internal(
      ContactsSettingsCassetteCoordinator.new,
      name: r'contactsSettingsCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsSettingsCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsSettingsCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
