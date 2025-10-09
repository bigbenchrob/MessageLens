import '../../../../domain_driven_development/result.dart';
import '../../domain/failures/migration_exception.dart';
import '../../domain/failures/migration_failure.dart';
import './migration_report.dart';

Future<Result<MigrationReport, MigrationFailure>> runMigration() async {
  final start = DateTime.now();
  try {
    // … run orchestrator & collect per-table stats …
    final report = MigrationReport(
      startedAt: start,
      endedAt: DateTime.now(),
      tables: [
        const TableReport(table: 'handles', rowsCopied: 1234),
        const TableReport(table: 'chats', rowsCopied: 567),
      ],
    );
    return Result.success(report);
  } on MigrationException catch (e) {
    return Result.failure(MigrationFailure.fromException(e));
  } catch (e) {
    return Result.failure(MigrationFailure.unknown(message: e.toString()));
  }
}
