// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_maintenance_lock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dbMaintenanceLockHash() => r'0cfaa12dce253237c1872e907a0acd7b04ae271d';

/// Global maintenance lock used to temporarily suppress reads that would
/// re-open databases while destructive maintenance operations are running.
///
/// This is intentionally simple: UI/features can watch this and either show a
/// placeholder or avoid triggering DB provider creation.
///
/// Copied from [DbMaintenanceLock].
@ProviderFor(DbMaintenanceLock)
final dbMaintenanceLockProvider =
    AutoDisposeNotifierProvider<DbMaintenanceLock, bool>.internal(
      DbMaintenanceLock.new,
      name: r'dbMaintenanceLockProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dbMaintenanceLockHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DbMaintenanceLock = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
