import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/feature_level_providers.dart' as db_providers;
import 'domain/i_repositories/workbench_query_repository.dart';
import 'infrastructure/repositories/sqflite_workbench_query_repository.dart';

part 'feature_level_providers.g.dart';

/// Provides the repository used by the workbench to inspect the import
/// database. The concrete implementation will be wired to the shared
/// SqfliteImportDatabase instance supplied by the database essentials module.
@riverpod
Future<WorkbenchQueryRepository> workbenchQueryRepository(Ref ref) async {
  final database = await ref.watch(
    db_providers.sqfliteImportDatabaseProvider.future,
  );
  return SqfliteWorkbenchQueryRepository(database: database);
}
