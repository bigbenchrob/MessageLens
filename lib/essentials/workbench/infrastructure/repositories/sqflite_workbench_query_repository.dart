import 'dart:typed_data';

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../domain/entities/workbench_query_models.dart';
import '../../domain/i_repositories/workbench_query_repository.dart';
import '../data_sources/local/workbench_query_sql_builder.dart';

class SqfliteWorkbenchQueryRepository implements WorkbenchQueryRepository {
  SqfliteWorkbenchQueryRepository({
    required SqfliteImportDatabase database,
    WorkbenchQuerySqlBuilder? sqlBuilder,
  }) : _database = database,
       _sqlBuilder = sqlBuilder ?? WorkbenchQuerySqlBuilder();

  final SqfliteImportDatabase _database;
  final WorkbenchQuerySqlBuilder _sqlBuilder;

  @override
  Future<WorkbenchQueryResult> runQuery({
    required WorkbenchQueryKind kind,
    required WorkbenchQueryRequest request,
  }) async {
    final statement = _sqlBuilder.buildStatement(kind: kind, request: request);

    final db = await _database.database;
    final rows = await db.rawQuery(statement.sql, statement.parameters);

    final mappedRows = rows
        .map(
          (row) => WorkbenchResultRow(
            kind: kind,
            cells: row.entries
                .map(
                  (entry) => WorkbenchResultCell(
                    label: entry.key,
                    displayValue: _stringifyValue(entry.value),
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    return WorkbenchQueryResult(
      request: request,
      kind: kind,
      rows: mappedRows,
      totalCount: request.offset + mappedRows.length,
    );
  }

  String _stringifyValue(Object? value) {
    if (value == null) {
      return 'null';
    }
    if (value is Uint8List) {
      return 'BLOB(${value.lengthInBytes})';
    }
    return '$value';
  }
}
