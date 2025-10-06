import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'application/migration/new_ledger_to_working_migration_service.dart';

part 'feature_level_providers.g.dart';

/// Provides the clean, simplified ledger-to-working database migration orchestrator.
///
/// This service follows the new participant-handle architecture:
/// - Participants are people (from AddressBook)
/// - Handles are communication endpoints (from chat.db)
/// - Services belong to chats, not participants
/// - handle_to_participant links them with confidence tracking
@riverpod
NewLedgerToWorkingMigrationService ledgerToWorkingMigrationService(Ref ref) {
  return NewLedgerToWorkingMigrationService(ref: ref);
}
