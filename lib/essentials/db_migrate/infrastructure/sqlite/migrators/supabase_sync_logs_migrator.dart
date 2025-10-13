import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class SupabaseSyncLogsMigrator extends BaseTableMigrator {
  const SupabaseSyncLogsMigrator();

  @override
  String get name => 'supabase_sync_logs';

  @override
  List<String> get dependsOn => const ['supabase_sync_state'];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    throw UnimplementedError('SupabaseSyncLogsMigrator.validatePrereqs');
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    throw UnimplementedError('SupabaseSyncLogsMigrator.copy');
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    throw UnimplementedError('SupabaseSyncLogsMigrator.postValidate');
  }
}
