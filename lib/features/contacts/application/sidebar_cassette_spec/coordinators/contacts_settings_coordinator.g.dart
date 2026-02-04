// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_settings_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsSettingsCoordinatorHash() =>
    r'4b26d0ecdf4713f0dcf979b3c60e295c89b89db7';

/// Coordinator for ContactsSettingsSpec variants.
///
/// This coordinator routes settings spec variants to their resolvers.
/// It follows the cross-surface spec system rules:
/// - Routes only (no business logic)
/// - Calls exactly one resolver per spec variant
/// - Returns Future<SidebarCassetteCardViewModel>
///
/// Copied from [ContactsSettingsCoordinator].
@ProviderFor(ContactsSettingsCoordinator)
final contactsSettingsCoordinatorProvider =
    AutoDisposeNotifierProvider<ContactsSettingsCoordinator, void>.internal(
      ContactsSettingsCoordinator.new,
      name: r'contactsSettingsCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsSettingsCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsSettingsCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
