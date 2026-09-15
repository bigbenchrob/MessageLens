import 'package:freezed_annotation/freezed_annotation.dart';

part 'database_health_audit_models.freezed.dart';
part 'database_health_audit_models.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum DatabaseHealthStatus { pass, warning, fail, error, notApplicable }

@JsonEnum(fieldRename: FieldRename.snake)
enum DatabaseHealthSeverity { low, medium, high, critical }

@JsonEnum(fieldRename: FieldRename.snake)
enum DatabaseHealthRelationshipType {
  oneToOneExpected,
  oneToManyExpected,
  joinTableCoverage,
  existenceCheck,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum DatabaseHealthErrorScope {
  databaseOpen,
  tableInventory,
  messageTextEnrichment,
  relationshipCheck,
  invariantCheck,
  phase2Samples,
  phase3Snapshot,
}

@freezed
abstract class DatabaseHealthAuditOutput with _$DatabaseHealthAuditOutput {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory DatabaseHealthAuditOutput({
    required String reportPath,
    required DatabaseHealthReport report,
  }) = _DatabaseHealthAuditOutput;

  factory DatabaseHealthAuditOutput.fromJson(Map<String, dynamic> json) =>
      _$DatabaseHealthAuditOutputFromJson(json);
}

@freezed
abstract class DatabaseHealthReport with _$DatabaseHealthReport {
  @JsonSerializable(
    explicitToJson: true,
    fieldRename: FieldRename.snake,
    includeIfNull: false,
  )
  const factory DatabaseHealthReport({
    required String schemaVersion,
    required String generatedAt,
    required String auditVersion,
    required DatabaseHealthAppInfo app,
    required DatabaseHealthEnvironmentInfo environment,
    required List<AuditedDatabaseInfo> databases,
    required List<TableInventoryEntry> tableInventory,
    required List<RelationshipCheckResult> relationshipChecks,
    required List<InvariantCheckResult> invariantChecks,
    MessageTextEnrichmentHealth? messageTextEnrichment,
    required HealthReportSummary summary,
    @Default(<HealthReportError>[]) List<HealthReportError> errors,
  }) = _DatabaseHealthReport;

  factory DatabaseHealthReport.fromJson(Map<String, dynamic> json) =>
      _$DatabaseHealthReportFromJson(json);
}

@freezed
abstract class MessageTextEnrichmentHealth with _$MessageTextEnrichmentHealth {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MessageTextEnrichmentHealth({
    required int remainingCandidateCount,
    required int totalAttributedBodyBytes,
    required int maximumAttributedBodyBytes,
  }) = _MessageTextEnrichmentHealth;

  factory MessageTextEnrichmentHealth.fromJson(Map<String, dynamic> json) =>
      _$MessageTextEnrichmentHealthFromJson(json);
}

@freezed
abstract class DatabaseHealthAppInfo with _$DatabaseHealthAppInfo {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory DatabaseHealthAppInfo({
    required String name,
    required String bundleId,
    required String version,
    String? buildNumber,
    String? buildChannel,
  }) = _DatabaseHealthAppInfo;

  factory DatabaseHealthAppInfo.fromJson(Map<String, dynamic> json) =>
      _$DatabaseHealthAppInfoFromJson(json);
}

@freezed
abstract class DatabaseHealthEnvironmentInfo
    with _$DatabaseHealthEnvironmentInfo {
  @JsonSerializable(
    explicitToJson: true,
    fieldRename: FieldRename.snake,
    includeIfNull: false,
  )
  const factory DatabaseHealthEnvironmentInfo({
    required String platform,
    String? platformVersion,
    String? deviceModel,
    String? timezone,
    bool? hasFullDiskAccess,
    Map<String, dynamic>? startupFlags,
    @Default(<String>[]) List<String> diagnosticNotes,
  }) = _DatabaseHealthEnvironmentInfo;

  factory DatabaseHealthEnvironmentInfo.fromJson(Map<String, dynamic> json) =>
      _$DatabaseHealthEnvironmentInfoFromJson(json);
}

@freezed
abstract class AuditedDatabaseInfo with _$AuditedDatabaseInfo {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory AuditedDatabaseInfo({
    required String databaseKey,
    required String role,
    required bool accessible,
    required bool readOnlyOpenSucceeded,
    int? schemaUserVersion,
    Object? migrationVersion,
    String? error,
  }) = _AuditedDatabaseInfo;

  factory AuditedDatabaseInfo.fromJson(Map<String, dynamic> json) =>
      _$AuditedDatabaseInfoFromJson(json);
}

@freezed
abstract class TableInventoryEntry with _$TableInventoryEntry {
  @JsonSerializable(
    explicitToJson: true,
    fieldRename: FieldRename.snake,
    includeIfNull: false,
  )
  const factory TableInventoryEntry({
    required String databaseKey,
    required String tableName,
    required bool exists,
    int? rowCount,
    DatabaseHealthPrimaryKeyInfo? primaryKey,
    @Default(<DatabaseHealthImportantColumnSummary>[])
    List<DatabaseHealthImportantColumnSummary> importantColumns,
    @Default(<String>[]) List<String> notes,
    String? error,
  }) = _TableInventoryEntry;

  factory TableInventoryEntry.fromJson(Map<String, dynamic> json) =>
      _$TableInventoryEntryFromJson(json);
}

@freezed
abstract class DatabaseHealthPrimaryKeyInfo
    with _$DatabaseHealthPrimaryKeyInfo {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory DatabaseHealthPrimaryKeyInfo({
    required String columnName,
    int? minValue,
    int? maxValue,
  }) = _DatabaseHealthPrimaryKeyInfo;

  factory DatabaseHealthPrimaryKeyInfo.fromJson(Map<String, dynamic> json) =>
      _$DatabaseHealthPrimaryKeyInfoFromJson(json);
}

@freezed
abstract class DatabaseHealthImportantColumnSummary
    with _$DatabaseHealthImportantColumnSummary {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory DatabaseHealthImportantColumnSummary({
    required String columnName,
    int? nullCount,
    int? nonNullCount,
    int? distinctCount,
    bool? omittedForPrivacy,
    @Default(<String>[]) List<String> notes,
  }) = _DatabaseHealthImportantColumnSummary;

  factory DatabaseHealthImportantColumnSummary.fromJson(
    Map<String, dynamic> json,
  ) => _$DatabaseHealthImportantColumnSummaryFromJson(json);
}

@freezed
abstract class RelationshipCheckResult with _$RelationshipCheckResult {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory RelationshipCheckResult({
    required String checkKey,
    required String databaseKey,
    required DatabaseHealthRelationshipType relationshipType,
    required String parentTable,
    String? childTable,
    required String joinExpressionDescription,
    int? parentRowCount,
    int? childRowCount,
    int? matchedRowCount,
    int? unmatchedParentRowCount,
    int? unmatchedChildRowCount,
    double? matchedPercentage,
    double? unmatchedParentPercentage,
    double? unmatchedChildPercentage,
    required DatabaseHealthStatus status,
    @Default(<String>[]) List<String> notes,
    String? error,
  }) = _RelationshipCheckResult;

  factory RelationshipCheckResult.fromJson(Map<String, dynamic> json) =>
      _$RelationshipCheckResultFromJson(json);
}

@freezed
abstract class InvariantCheckResult with _$InvariantCheckResult {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory InvariantCheckResult({
    required String checkKey,
    required DatabaseHealthSeverity severity,
    required String description,
    required DatabaseHealthStatus status,
    int? violationCount,
    int? evaluatedRowCount,
    @Default(<String>[]) List<String> notes,
    String? error,
  }) = _InvariantCheckResult;

  factory InvariantCheckResult.fromJson(Map<String, dynamic> json) =>
      _$InvariantCheckResultFromJson(json);
}

@freezed
abstract class HealthReportSummary with _$HealthReportSummary {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory HealthReportSummary({
    required DatabaseHealthStatus overallStatus,

    /// Count of active app-health tables only. Retired cleanup tables may appear
    /// in detailed inventory but must not inflate the top-level health summary.
    required int tableCount,
    required int relationshipCheckCount,
    required int invariantCheckCount,
    required int passCount,
    required int warningCount,
    required int failCount,
    required int errorCount,
    @Default(<String>[]) List<String> headlineFindings,
  }) = _HealthReportSummary;

  factory HealthReportSummary.fromJson(Map<String, dynamic> json) =>
      _$HealthReportSummaryFromJson(json);
}

@freezed
abstract class HealthReportError with _$HealthReportError {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory HealthReportError({
    required DatabaseHealthErrorScope scope,
    String? databaseKey,
    String? tableName,
    String? checkKey,
    required String message,
  }) = _HealthReportError;

  factory HealthReportError.fromJson(Map<String, dynamic> json) =>
      _$HealthReportErrorFromJson(json);
}
