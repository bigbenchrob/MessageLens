import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'application/migration/newest_ledger_to_working_migration_service.dart';

part 'feature_level_providers.g.dart';

/// Provides the direct ledger-to-working database migration orchestrator.
///
/// This service trusts the latest import batch and mirrors its data into the
/// working Drift schema without recomputing joins or indexes.
@riverpod
NewestLedgerToWorkingMigrationService ledgerToWorkingMigrationService(Ref ref) {
  return NewestLedgerToWorkingMigrationService(ref: ref);
}
