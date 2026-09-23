// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistent_database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceScopedImportDatabaseHash() =>
    r'f9ee435abe842cfa98a2a39ad9e4f6d7be43488c';

/// Provides access to the source-scoped import ledger database.
///
/// Copied from [sourceScopedImportDatabase].
@ProviderFor(sourceScopedImportDatabase)
final sourceScopedImportDatabaseProvider =
    FutureProvider<ImportDatabase>.internal(
      sourceScopedImportDatabase,
      name: r'sourceScopedImportDatabaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sourceScopedImportDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SourceScopedImportDatabaseRef = FutureProviderRef<ImportDatabase>;
String _$driftConversationGraphDatabaseHash() =>
    r'181aa94822154dca36ad7981d5e372050abc60b9';

/// Provides access to the source-scoped conversation graph projection database.
///
/// Copied from [driftConversationGraphDatabase].
@ProviderFor(driftConversationGraphDatabase)
final driftConversationGraphDatabaseProvider =
    FutureProvider<ConversationGraphDatabase>.internal(
      driftConversationGraphDatabase,
      name: r'driftConversationGraphDatabaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$driftConversationGraphDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DriftConversationGraphDatabaseRef =
    FutureProviderRef<ConversationGraphDatabase>;
String _$overlayDatabaseHash() => r'47a4f090a9f10bcfab4c2e0e59182bb77441a838';

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
String _$presenceDatabaseHash() => r'b7cca137453c25d8db29a1f3fbb110ec61cc5ab5';

/// Provides the durable Schedule/Trip experiment database.
///
/// Copied from [presenceDatabase].
@ProviderFor(presenceDatabase)
final presenceDatabaseProvider = FutureProvider<PresenceDatabase>.internal(
  presenceDatabase,
  name: r'presenceDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$presenceDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PresenceDatabaseRef = FutureProviderRef<PresenceDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
