import '../../domain/base_table_migrator.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

class SupabaseSyncStateMigrator extends BaseTableMigrator {
  const SupabaseSyncStateMigrator();

  @override
  String get name => 'supabase_sync_state';

  @override
  List<String> get dependsOn => const [];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    throw UnimplementedError('SupabaseSyncStateMigrator.validatePrereqs');
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    throw UnimplementedError('SupabaseSyncStateMigrator.copy');
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    throw UnimplementedError('SupabaseSyncStateMigrator.postValidate');
  }
}
