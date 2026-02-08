// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_cassette_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsInfoCassetteCoordinatorHash() =>
    r'17a6695522035fe50ac05645e93ce9b68db180e3';

/// Contacts Info Cassette Coordinator
///
/// Routes [ContactsInfoCassetteSpec] variants to info resolvers.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// The coordinator:
/// - Pattern-matches on the spec
/// - Extracts the info key
/// - Calls the info content resolver
/// - Returns a [SidebarCassetteCardViewModel] with cardType: info
///
/// Copied from [ContactsInfoCassetteCoordinator].
@ProviderFor(ContactsInfoCassetteCoordinator)
final contactsInfoCassetteCoordinatorProvider =
    AutoDisposeNotifierProvider<ContactsInfoCassetteCoordinator, void>.internal(
      ContactsInfoCassetteCoordinator.new,
      name: r'contactsInfoCassetteCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsInfoCassetteCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsInfoCassetteCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
