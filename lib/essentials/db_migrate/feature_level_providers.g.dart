// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ledgerToWorkingMigrationServiceHash() =>
    r'3ea72b97988fd1b8e237753102cd2af1342c4a55';

/// Provides the clean, simplified ledger-to-working database migration orchestrator.
///
/// This service follows the new participant-handle architecture:
/// - Participants are people (from AddressBook)
/// - Handles are communication endpoints (from chat.db)
/// - Services belong to chats, not participants
/// - handle_to_participant links them with confidence tracking
///
/// Copied from [ledgerToWorkingMigrationService].
@ProviderFor(ledgerToWorkingMigrationService)
final ledgerToWorkingMigrationServiceProvider =
    AutoDisposeProvider<NewLedgerToWorkingMigrationService>.internal(
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
    AutoDisposeProviderRef<NewLedgerToWorkingMigrationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
