import '../entities/workbench_query_models.dart';

/// Repository abstraction for executing developer-focused import database queries
/// from the workbench. Implementations are responsible for resolving the
/// underlying data source (currently the macOS import ledger database).
abstract class WorkbenchQueryRepository {
  Future<WorkbenchQueryResult> runQuery({
    required WorkbenchQueryKind kind,
    required WorkbenchQueryRequest request,
  });
}
