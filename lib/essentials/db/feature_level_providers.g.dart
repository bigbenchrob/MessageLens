// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sqfliteImportDatabaseHash() =>
    r'55e2769da44f8cff1a868a496a7715a3080047d4';

/// Provides access to the Sqflite-powered import ledger database.
///
/// Copied from [sqfliteImportDatabase].
@ProviderFor(sqfliteImportDatabase)
final sqfliteImportDatabaseProvider =
    FutureProvider<SqfliteImportDatabase>.internal(
      sqfliteImportDatabase,
      name: r'sqfliteImportDatabaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sqfliteImportDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SqfliteImportDatabaseRef = FutureProviderRef<SqfliteImportDatabase>;
String _$driftWorkingDatabaseHash() =>
    r'3613c1038f790c70d828f01cc238b88b6f78c735';

/// Provides access to the Drift projection database used by the UI.
///
/// Copied from [driftWorkingDatabase].
@ProviderFor(driftWorkingDatabase)
final driftWorkingDatabaseProvider = FutureProvider<WorkingDatabase>.internal(
  driftWorkingDatabase,
  name: r'driftWorkingDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driftWorkingDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DriftWorkingDatabaseRef = FutureProviderRef<WorkingDatabase>;
String _$overlayDatabaseHash() => r'af7bedb84580f233fac919c553fd2df670e3e30c';

/// Provides access to the overlay database for user preferences and customizations.
///
/// Copied from [overlayDatabase].
@ProviderFor(overlayDatabase)
final overlayDatabaseProvider = FutureProvider<OverlayDatabase>.internal(
  overlayDatabase,
  name: r'overlayDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$overlayDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OverlayDatabaseRef = FutureProviderRef<OverlayDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
