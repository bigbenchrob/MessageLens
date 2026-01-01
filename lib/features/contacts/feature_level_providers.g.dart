// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsCassetteCoordinatorHash() =>
    r'ff4cb17cb4dad9207bbc954f86bbc74b6995a28b';

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
    r'8b3d82191ae3ca4d7078524fa28157db7e606230';

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
