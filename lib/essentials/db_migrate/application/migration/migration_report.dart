import 'package:freezed_annotation/freezed_annotation.dart';

part 'migration_report.freezed.dart';
part 'migration_report.g.dart'; // only if you want JSON

@freezed
abstract class MigrationReport with _$MigrationReport {
  const factory MigrationReport({
    required DateTime startedAt,
    required DateTime endedAt,
    required List<TableReport> tables, // per-table stats
    @Default([]) List<String> warnings, // non-fatal notes
  }) = _MigrationReport;

  const MigrationReport._();

  Duration get duration => endedAt.difference(startedAt);
  int get totalRowsCopied => tables.fold(0, (sum, t) => sum + t.rowsCopied);
  bool get isEmpty => tables.isEmpty;

  // JSON support (optional)
  factory MigrationReport.fromJson(Map<String, dynamic> json) =>
      _$MigrationReportFromJson(json);
}

@freezed
abstract class TableReport with _$TableReport {
  const factory TableReport({
    required String table,
    required int rowsCopied,
    @Default(0) int rowsUpdated,
    @Default(0) int rowsSkipped,
    @Default([]) List<String> notes,
  }) = _TableReport;

  // JSON (optional)
  factory TableReport.fromJson(Map<String, dynamic> json) =>
      _$TableReportFromJson(json);
}
