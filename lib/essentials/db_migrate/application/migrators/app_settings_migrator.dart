import '../../domain/base_table_migrator.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

class AppSettingsMigrator extends BaseTableMigrator {
  const AppSettingsMigrator();

  @override
  String get name => 'app_settings';

  @override
  List<String> get dependsOn => const [];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    throw UnimplementedError('AppSettingsMigrator.validatePrereqs');
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    throw UnimplementedError('AppSettingsMigrator.copy');
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    throw UnimplementedError('AppSettingsMigrator.postValidate');
  }
}
