import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'application/orchestrator/handles_migration_service.dart';

part 'feature_level_providers.g.dart';

/// Provides the orchestrator-backed migration pipeline for identities,
/// chats, messages, and related tables.
@riverpod
HandlesMigrationService handlesMigrationService(Ref ref) {
  return HandlesMigrationService(ref: ref);
}
