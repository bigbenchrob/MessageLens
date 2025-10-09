// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MigrationReport _$MigrationReportFromJson(Map<String, dynamic> json) =>
    _MigrationReport(
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      tables: (json['tables'] as List<dynamic>)
          .map((e) => TableReport.fromJson(e as Map<String, dynamic>))
          .toList(),
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MigrationReportToJson(_MigrationReport instance) =>
    <String, dynamic>{
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt.toIso8601String(),
      'tables': instance.tables,
      'warnings': instance.warnings,
    };

_TableReport _$TableReportFromJson(Map<String, dynamic> json) => _TableReport(
  table: json['table'] as String,
  rowsCopied: (json['rowsCopied'] as num).toInt(),
  rowsUpdated: (json['rowsUpdated'] as num?)?.toInt() ?? 0,
  rowsSkipped: (json['rowsSkipped'] as num?)?.toInt() ?? 0,
  notes:
      (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$TableReportToJson(_TableReport instance) =>
    <String, dynamic>{
      'table': instance.table,
      'rowsCopied': instance.rowsCopied,
      'rowsUpdated': instance.rowsUpdated,
      'rowsSkipped': instance.rowsSkipped,
      'notes': instance.notes,
    };
