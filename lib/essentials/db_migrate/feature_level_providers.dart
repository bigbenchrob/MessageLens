import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'application/migration/ledger_to_working_migration_service.dart';
import 'application/orchestrator/handles_migration_service.dart';

part 'feature_level_providers.g.dart';

/// Provides the direct ledger-to-working database migration orchestrator.
///
/// This service trusts the latest import batch and mirrors its data into the
/// working Drift schema without recomputing joins or indexes.
@riverpod
LedgerToWorkingMigrationService ledgerToWorkingMigrationService(Ref ref) {
  return LedgerToWorkingMigrationService(ref: ref);
}

/// Provides the new orchestrator-backed handles migration pipeline.
@riverpod
HandlesMigrationService handlesMigrationService(Ref ref) {
  return HandlesMigrationService(ref: ref);
}
