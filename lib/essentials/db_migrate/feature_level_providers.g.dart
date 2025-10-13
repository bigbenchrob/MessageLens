// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ledgerToWorkingMigrationServiceHash() =>
    r'97256f55f01ae226558bfae24b269cef11a56e17';

/// Provides the direct ledger-to-working database migration orchestrator.
///
/// This service trusts the latest import batch and mirrors its data into the
/// working Drift schema without recomputing joins or indexes.
///
/// Copied from [ledgerToWorkingMigrationService].
@ProviderFor(ledgerToWorkingMigrationService)
final ledgerToWorkingMigrationServiceProvider =
    AutoDisposeProvider<LedgerToWorkingMigrationService>.internal(
      ledgerToWorkingMigrationService,
      name: r'ledgerToWorkingMigrationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ledgerToWorkingMigrationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LedgerToWorkingMigrationServiceRef =
    AutoDisposeProviderRef<LedgerToWorkingMigrationService>;
String _$handlesMigrationServiceHash() =>
    r'6a6cd47e82fc373a499e265eb0719f900de26537';

/// Provides the new orchestrator-backed handles migration pipeline.
///
/// Copied from [handlesMigrationService].
@ProviderFor(handlesMigrationService)
final handlesMigrationServiceProvider =
    AutoDisposeProvider<HandlesMigrationService>.internal(
      handlesMigrationService,
      name: r'handlesMigrationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handlesMigrationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HandlesMigrationServiceRef =
    AutoDisposeProviderRef<HandlesMigrationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
