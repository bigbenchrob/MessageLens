// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_health_audit_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DatabaseHealthAuditOutput _$DatabaseHealthAuditOutputFromJson(
  Map<String, dynamic> json,
) => _DatabaseHealthAuditOutput(
  reportPath: json['report_path'] as String,
  report: DatabaseHealthReport.fromJson(json['report'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DatabaseHealthAuditOutputToJson(
  _DatabaseHealthAuditOutput instance,
) => <String, dynamic>{
  'report_path': instance.reportPath,
  'report': instance.report.toJson(),
};

_DatabaseHealthReport _$DatabaseHealthReportFromJson(
  Map<String, dynamic> json,
) => _DatabaseHealthReport(
  schemaVersion: json['schema_version'] as String,
  generatedAt: json['generated_at'] as String,
  auditVersion: json['audit_version'] as String,
  app: DatabaseHealthAppInfo.fromJson(json['app'] as Map<String, dynamic>),
  environment: DatabaseHealthEnvironmentInfo.fromJson(
    json['environment'] as Map<String, dynamic>,
  ),
  databases: (json['databases'] as List<dynamic>)
      .map((e) => AuditedDatabaseInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  tableInventory: (json['table_inventory'] as List<dynamic>)
      .map((e) => TableInventoryEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  relationshipChecks: (json['relationship_checks'] as List<dynamic>)
      .map((e) => RelationshipCheckResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  invariantChecks: (json['invariant_checks'] as List<dynamic>)
      .map((e) => InvariantCheckResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  messageTextEnrichment: json['message_text_enrichment'] == null
      ? null
      : MessageTextEnrichmentHealth.fromJson(
          json['message_text_enrichment'] as Map<String, dynamic>,
        ),
  summary: HealthReportSummary.fromJson(
    json['summary'] as Map<String, dynamic>,
  ),
  errors:
      (json['errors'] as List<dynamic>?)
          ?.map((e) => HealthReportError.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HealthReportError>[],
);

Map<String, dynamic> _$DatabaseHealthReportToJson(
  _DatabaseHealthReport instance,
) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
  'generated_at': instance.generatedAt,
  'audit_version': instance.auditVersion,
  'app': instance.app.toJson(),
  'environment': instance.environment.toJson(),
  'databases': instance.databases.map((e) => e.toJson()).toList(),
  'table_inventory': instance.tableInventory.map((e) => e.toJson()).toList(),
  'relationship_checks': instance.relationshipChecks
      .map((e) => e.toJson())
      .toList(),
  'invariant_checks': instance.invariantChecks.map((e) => e.toJson()).toList(),
  if (instance.messageTextEnrichment?.toJson() case final value?)
    'message_text_enrichment': value,
  'summary': instance.summary.toJson(),
  'errors': instance.errors.map((e) => e.toJson()).toList(),
};

_MessageTextEnrichmentHealth _$MessageTextEnrichmentHealthFromJson(
  Map<String, dynamic> json,
) => _MessageTextEnrichmentHealth(
  remainingCandidateCount: (json['remaining_candidate_count'] as num).toInt(),
  totalAttributedBodyBytes: (json['total_attributed_body_bytes'] as num)
      .toInt(),
  maximumAttributedBodyBytes: (json['maximum_attributed_body_bytes'] as num)
      .toInt(),
);

Map<String, dynamic> _$MessageTextEnrichmentHealthToJson(
  _MessageTextEnrichmentHealth instance,
) => <String, dynamic>{
  'remaining_candidate_count': instance.remainingCandidateCount,
  'total_attributed_body_bytes': instance.totalAttributedBodyBytes,
  'maximum_attributed_body_bytes': instance.maximumAttributedBodyBytes,
};

_DatabaseHealthAppInfo _$DatabaseHealthAppInfoFromJson(
  Map<String, dynamic> json,
) => _DatabaseHealthAppInfo(
  name: json['name'] as String,
  bundleId: json['bundle_id'] as String,
  version: json['version'] as String,
  buildNumber: json['build_number'] as String?,
  buildChannel: json['build_channel'] as String?,
);

Map<String, dynamic> _$DatabaseHealthAppInfoToJson(
  _DatabaseHealthAppInfo instance,
) => <String, dynamic>{
  'name': instance.name,
  'bundle_id': instance.bundleId,
  'version': instance.version,
  if (instance.buildNumber case final value?) 'build_number': value,
  if (instance.buildChannel case final value?) 'build_channel': value,
};

_DatabaseHealthEnvironmentInfo _$DatabaseHealthEnvironmentInfoFromJson(
  Map<String, dynamic> json,
) => _DatabaseHealthEnvironmentInfo(
  platform: json['platform'] as String,
  platformVersion: json['platform_version'] as String?,
  deviceModel: json['device_model'] as String?,
  timezone: json['timezone'] as String?,
  hasFullDiskAccess: json['has_full_disk_access'] as bool?,
  startupFlags: json['startup_flags'] as Map<String, dynamic>?,
  diagnosticNotes:
      (json['diagnostic_notes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$DatabaseHealthEnvironmentInfoToJson(
  _DatabaseHealthEnvironmentInfo instance,
) => <String, dynamic>{
  'platform': instance.platform,
  if (instance.platformVersion case final value?) 'platform_version': value,
  if (instance.deviceModel case final value?) 'device_model': value,
  if (instance.timezone case final value?) 'timezone': value,
  if (instance.hasFullDiskAccess case final value?)
    'has_full_disk_access': value,
  if (instance.startupFlags case final value?) 'startup_flags': value,
  'diagnostic_notes': instance.diagnosticNotes,
};

_AuditedDatabaseInfo _$AuditedDatabaseInfoFromJson(Map<String, dynamic> json) =>
    _AuditedDatabaseInfo(
      databaseKey: json['database_key'] as String,
      role: json['role'] as String,
      accessible: json['accessible'] as bool,
      readOnlyOpenSucceeded: json['read_only_open_succeeded'] as bool,
      schemaUserVersion: (json['schema_user_version'] as num?)?.toInt(),
      migrationVersion: json['migration_version'],
      error: json['error'] as String?,
    );

Map<String, dynamic> _$AuditedDatabaseInfoToJson(
  _AuditedDatabaseInfo instance,
) => <String, dynamic>{
  'database_key': instance.databaseKey,
  'role': instance.role,
  'accessible': instance.accessible,
  'read_only_open_succeeded': instance.readOnlyOpenSucceeded,
  if (instance.schemaUserVersion case final value?)
    'schema_user_version': value,
  if (instance.migrationVersion case final value?) 'migration_version': value,
  if (instance.error case final value?) 'error': value,
};

_TableInventoryEntry _$TableInventoryEntryFromJson(Map<String, dynamic> json) =>
    _TableInventoryEntry(
      databaseKey: json['database_key'] as String,
      tableName: json['table_name'] as String,
      exists: json['exists'] as bool,
      rowCount: (json['row_count'] as num?)?.toInt(),
      primaryKey: json['primary_key'] == null
          ? null
          : DatabaseHealthPrimaryKeyInfo.fromJson(
              json['primary_key'] as Map<String, dynamic>,
            ),
      importantColumns:
          (json['important_columns'] as List<dynamic>?)
              ?.map(
                (e) => DatabaseHealthImportantColumnSummary.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <DatabaseHealthImportantColumnSummary>[],
      notes:
          (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      error: json['error'] as String?,
    );

Map<String, dynamic> _$TableInventoryEntryToJson(
  _TableInventoryEntry instance,
) => <String, dynamic>{
  'database_key': instance.databaseKey,
  'table_name': instance.tableName,
  'exists': instance.exists,
  if (instance.rowCount case final value?) 'row_count': value,
  if (instance.primaryKey?.toJson() case final value?) 'primary_key': value,
  'important_columns': instance.importantColumns
      .map((e) => e.toJson())
      .toList(),
  'notes': instance.notes,
  if (instance.error case final value?) 'error': value,
};

_DatabaseHealthPrimaryKeyInfo _$DatabaseHealthPrimaryKeyInfoFromJson(
  Map<String, dynamic> json,
) => _DatabaseHealthPrimaryKeyInfo(
  columnName: json['column_name'] as String,
  minValue: (json['min_value'] as num?)?.toInt(),
  maxValue: (json['max_value'] as num?)?.toInt(),
);

Map<String, dynamic> _$DatabaseHealthPrimaryKeyInfoToJson(
  _DatabaseHealthPrimaryKeyInfo instance,
) => <String, dynamic>{
  'column_name': instance.columnName,
  if (instance.minValue case final value?) 'min_value': value,
  if (instance.maxValue case final value?) 'max_value': value,
};

_DatabaseHealthImportantColumnSummary
_$DatabaseHealthImportantColumnSummaryFromJson(Map<String, dynamic> json) =>
    _DatabaseHealthImportantColumnSummary(
      columnName: json['column_name'] as String,
      nullCount: (json['null_count'] as num?)?.toInt(),
      nonNullCount: (json['non_null_count'] as num?)?.toInt(),
      distinctCount: (json['distinct_count'] as num?)?.toInt(),
      omittedForPrivacy: json['omitted_for_privacy'] as bool?,
      notes:
          (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    );

Map<String, dynamic> _$DatabaseHealthImportantColumnSummaryToJson(
  _DatabaseHealthImportantColumnSummary instance,
) => <String, dynamic>{
  'column_name': instance.columnName,
  if (instance.nullCount case final value?) 'null_count': value,
  if (instance.nonNullCount case final value?) 'non_null_count': value,
  if (instance.distinctCount case final value?) 'distinct_count': value,
  if (instance.omittedForPrivacy case final value?)
    'omitted_for_privacy': value,
  'notes': instance.notes,
};

_RelationshipCheckResult _$RelationshipCheckResultFromJson(
  Map<String, dynamic> json,
) => _RelationshipCheckResult(
  checkKey: json['check_key'] as String,
  databaseKey: json['database_key'] as String,
  relationshipType: $enumDecode(
    _$DatabaseHealthRelationshipTypeEnumMap,
    json['relationship_type'],
  ),
  parentTable: json['parent_table'] as String,
  childTable: json['child_table'] as String?,
  joinExpressionDescription: json['join_expression_description'] as String,
  parentRowCount: (json['parent_row_count'] as num?)?.toInt(),
  childRowCount: (json['child_row_count'] as num?)?.toInt(),
  matchedRowCount: (json['matched_row_count'] as num?)?.toInt(),
  unmatchedParentRowCount: (json['unmatched_parent_row_count'] as num?)
      ?.toInt(),
  unmatchedChildRowCount: (json['unmatched_child_row_count'] as num?)?.toInt(),
  matchedPercentage: (json['matched_percentage'] as num?)?.toDouble(),
  unmatchedParentPercentage: (json['unmatched_parent_percentage'] as num?)
      ?.toDouble(),
  unmatchedChildPercentage: (json['unmatched_child_percentage'] as num?)
      ?.toDouble(),
  status: $enumDecode(_$DatabaseHealthStatusEnumMap, json['status']),
  notes:
      (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  error: json['error'] as String?,
);

Map<String, dynamic> _$RelationshipCheckResultToJson(
  _RelationshipCheckResult instance,
) => <String, dynamic>{
  'check_key': instance.checkKey,
  'database_key': instance.databaseKey,
  'relationship_type':
      _$DatabaseHealthRelationshipTypeEnumMap[instance.relationshipType]!,
  'parent_table': instance.parentTable,
  if (instance.childTable case final value?) 'child_table': value,
  'join_expression_description': instance.joinExpressionDescription,
  if (instance.parentRowCount case final value?) 'parent_row_count': value,
  if (instance.childRowCount case final value?) 'child_row_count': value,
  if (instance.matchedRowCount case final value?) 'matched_row_count': value,
  if (instance.unmatchedParentRowCount case final value?)
    'unmatched_parent_row_count': value,
  if (instance.unmatchedChildRowCount case final value?)
    'unmatched_child_row_count': value,
  if (instance.matchedPercentage case final value?) 'matched_percentage': value,
  if (instance.unmatchedParentPercentage case final value?)
    'unmatched_parent_percentage': value,
  if (instance.unmatchedChildPercentage case final value?)
    'unmatched_child_percentage': value,
  'status': _$DatabaseHealthStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  if (instance.error case final value?) 'error': value,
};

const _$DatabaseHealthRelationshipTypeEnumMap = {
  DatabaseHealthRelationshipType.oneToOneExpected: 'one_to_one_expected',
  DatabaseHealthRelationshipType.oneToManyExpected: 'one_to_many_expected',
  DatabaseHealthRelationshipType.joinTableCoverage: 'join_table_coverage',
  DatabaseHealthRelationshipType.existenceCheck: 'existence_check',
};

const _$DatabaseHealthStatusEnumMap = {
  DatabaseHealthStatus.pass: 'pass',
  DatabaseHealthStatus.warning: 'warning',
  DatabaseHealthStatus.fail: 'fail',
  DatabaseHealthStatus.error: 'error',
  DatabaseHealthStatus.notApplicable: 'not_applicable',
};

_InvariantCheckResult _$InvariantCheckResultFromJson(
  Map<String, dynamic> json,
) => _InvariantCheckResult(
  checkKey: json['check_key'] as String,
  severity: $enumDecode(_$DatabaseHealthSeverityEnumMap, json['severity']),
  description: json['description'] as String,
  status: $enumDecode(_$DatabaseHealthStatusEnumMap, json['status']),
  violationCount: (json['violation_count'] as num?)?.toInt(),
  evaluatedRowCount: (json['evaluated_row_count'] as num?)?.toInt(),
  notes:
      (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  error: json['error'] as String?,
);

Map<String, dynamic> _$InvariantCheckResultToJson(
  _InvariantCheckResult instance,
) => <String, dynamic>{
  'check_key': instance.checkKey,
  'severity': _$DatabaseHealthSeverityEnumMap[instance.severity]!,
  'description': instance.description,
  'status': _$DatabaseHealthStatusEnumMap[instance.status]!,
  if (instance.violationCount case final value?) 'violation_count': value,
  if (instance.evaluatedRowCount case final value?)
    'evaluated_row_count': value,
  'notes': instance.notes,
  if (instance.error case final value?) 'error': value,
};

const _$DatabaseHealthSeverityEnumMap = {
  DatabaseHealthSeverity.low: 'low',
  DatabaseHealthSeverity.medium: 'medium',
  DatabaseHealthSeverity.high: 'high',
  DatabaseHealthSeverity.critical: 'critical',
};

_HealthReportSummary _$HealthReportSummaryFromJson(Map<String, dynamic> json) =>
    _HealthReportSummary(
      overallStatus: $enumDecode(
        _$DatabaseHealthStatusEnumMap,
        json['overall_status'],
      ),
      tableCount: (json['table_count'] as num).toInt(),
      relationshipCheckCount: (json['relationship_check_count'] as num).toInt(),
      invariantCheckCount: (json['invariant_check_count'] as num).toInt(),
      passCount: (json['pass_count'] as num).toInt(),
      warningCount: (json['warning_count'] as num).toInt(),
      failCount: (json['fail_count'] as num).toInt(),
      errorCount: (json['error_count'] as num).toInt(),
      headlineFindings:
          (json['headline_findings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$HealthReportSummaryToJson(
  _HealthReportSummary instance,
) => <String, dynamic>{
  'overall_status': _$DatabaseHealthStatusEnumMap[instance.overallStatus]!,
  'table_count': instance.tableCount,
  'relationship_check_count': instance.relationshipCheckCount,
  'invariant_check_count': instance.invariantCheckCount,
  'pass_count': instance.passCount,
  'warning_count': instance.warningCount,
  'fail_count': instance.failCount,
  'error_count': instance.errorCount,
  'headline_findings': instance.headlineFindings,
};

_HealthReportError _$HealthReportErrorFromJson(Map<String, dynamic> json) =>
    _HealthReportError(
      scope: $enumDecode(_$DatabaseHealthErrorScopeEnumMap, json['scope']),
      databaseKey: json['database_key'] as String?,
      tableName: json['table_name'] as String?,
      checkKey: json['check_key'] as String?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$HealthReportErrorToJson(_HealthReportError instance) =>
    <String, dynamic>{
      'scope': _$DatabaseHealthErrorScopeEnumMap[instance.scope]!,
      if (instance.databaseKey case final value?) 'database_key': value,
      if (instance.tableName case final value?) 'table_name': value,
      if (instance.checkKey case final value?) 'check_key': value,
      'message': instance.message,
    };

const _$DatabaseHealthErrorScopeEnumMap = {
  DatabaseHealthErrorScope.databaseOpen: 'database_open',
  DatabaseHealthErrorScope.tableInventory: 'table_inventory',
  DatabaseHealthErrorScope.messageTextEnrichment: 'message_text_enrichment',
  DatabaseHealthErrorScope.relationshipCheck: 'relationship_check',
  DatabaseHealthErrorScope.invariantCheck: 'invariant_check',
  DatabaseHealthErrorScope.phase2Samples: 'phase2_samples',
  DatabaseHealthErrorScope.phase3Snapshot: 'phase3_snapshot',
};
