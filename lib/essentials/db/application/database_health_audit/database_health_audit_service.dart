import 'package:collection/collection.dart';

import '../../../services/startup_flags_service.dart';
import 'database_health_audit_models.dart';
import 'database_health_audit_report_writer.dart';
import 'database_health_database_keys.dart';
import 'database_health_query_layer.dart';
import 'database_health_runtime_environment.dart';

const _databaseHealthSchemaVersion = '1.0.0';
const _databaseHealthAuditVersion = 'phase1';

class DatabaseHealthAuditService {
  DatabaseHealthAuditService({
    required DatabaseHealthAppInfo appInfo,
    required bool hasFullDiskAccess,
    required List<DatabaseHealthQueryLayer> queryLayers,
    required DatabaseHealthRuntimeEnvironment runtimeEnvironment,
    required DatabaseHealthAuditReportWriter reportWriter,
  }) : _appInfo = appInfo,
       _hasFullDiskAccess = hasFullDiskAccess,
       _queryLayers = queryLayers,
       _runtimeEnvironment = runtimeEnvironment,
       _reportWriter = reportWriter;

  final DatabaseHealthAppInfo _appInfo;
  final bool _hasFullDiskAccess;
  final List<DatabaseHealthQueryLayer> _queryLayers;
  final DatabaseHealthRuntimeEnvironment _runtimeEnvironment;
  final DatabaseHealthAuditReportWriter _reportWriter;

  Future<DatabaseHealthReport> buildPhase1Report() async {
    final errors = <HealthReportError>[];
    final databases = <AuditedDatabaseInfo>[];
    final tableInventory = <TableInventoryEntry>[];
    final relationshipChecks = <RelationshipCheckResult>[];
    final invariantChecks = <InvariantCheckResult>[];

    for (final layer in _queryLayers) {
      final databaseInfo = await _buildDatabaseInfo(layer, errors);
      databases.add(databaseInfo);
      if (!databaseInfo.accessible || !databaseInfo.readOnlyOpenSucceeded) {
        continue;
      }
      tableInventory.addAll(await _buildTableInventory(layer, errors));
      relationshipChecks.addAll(await _buildRelationshipChecks(layer, errors));
      invariantChecks.addAll(await _buildInvariantChecks(layer, errors));
    }

    final summary = _buildSummary(
      tableInventory: tableInventory,
      relationshipChecks: relationshipChecks,
      invariantChecks: invariantChecks,
      errors: errors,
    );

    return DatabaseHealthReport(
      schemaVersion: _databaseHealthSchemaVersion,
      generatedAt: DateTime.now().toUtc().toIso8601String(),
      auditVersion: _databaseHealthAuditVersion,
      app: _appInfo,
      environment: _buildEnvironmentInfo(),
      databases: databases,
      tableInventory: tableInventory,
      relationshipChecks: relationshipChecks,
      invariantChecks: invariantChecks,
      summary: summary,
      errors: errors,
    );
  }

  Future<DatabaseHealthAuditOutput> writePhase1Report({
    required String outputDirectoryPath,
  }) async {
    final report = await buildPhase1Report();
    final reportPath = await _reportWriter.writeReport(
      outputDirectoryPath: outputDirectoryPath,
      report: report,
    );
    return DatabaseHealthAuditOutput(reportPath: reportPath, report: report);
  }

  DatabaseHealthEnvironmentInfo _buildEnvironmentInfo() {
    final startupFlags = StartupFlagsService.instance.cachedFlags;
    final runtimeEnvironment = _runtimeEnvironment.read();

    return DatabaseHealthEnvironmentInfo(
      platform: runtimeEnvironment.platform,
      platformVersion: runtimeEnvironment.platformVersion,
      timezone: runtimeEnvironment.timezone,
      hasFullDiskAccess: _hasFullDiskAccess,
      startupFlags: <String, dynamic>{
        'option_launch_reset_requested':
            startupFlags.optionLaunchResetRequested,
      },
      diagnosticNotes: const <String>[
        'Phase 1 audits aggregate structure only; no row-level samples are exported.',
        'Build metadata is read from the running application package.',
        'Cross-database overlay relationship diagnostics are intentionally deferred to a later audit phase.',
      ],
    );
  }

  Future<AuditedDatabaseInfo> _buildDatabaseInfo(
    DatabaseHealthQueryLayer layer,
    List<HealthReportError> errors,
  ) async {
    try {
      final exists = await layer.databaseFileExists();
      if (!exists) {
        return AuditedDatabaseInfo(
          databaseKey: layer.databaseKey,
          role: layer.role,
          accessible: false,
          readOnlyOpenSucceeded: false,
          error: 'Database file does not exist.',
        );
      }
      final opened = await layer.ping();
      final schemaUserVersion = await layer.schemaUserVersion();

      return AuditedDatabaseInfo(
        databaseKey: layer.databaseKey,
        role: layer.role,
        accessible: exists,
        readOnlyOpenSucceeded: opened,
        schemaUserVersion: schemaUserVersion,
      );
    } catch (error) {
      final message = error.toString();
      errors.add(
        HealthReportError(
          scope: DatabaseHealthErrorScope.databaseOpen,
          databaseKey: layer.databaseKey,
          message: message,
        ),
      );
      return AuditedDatabaseInfo(
        databaseKey: layer.databaseKey,
        role: layer.role,
        accessible: false,
        readOnlyOpenSucceeded: false,
        error: message,
      );
    }
  }

  Future<List<TableInventoryEntry>> _buildTableInventory(
    DatabaseHealthQueryLayer layer,
    List<HealthReportError> errors,
  ) async {
    final specs =
        _tableSpecsByDatabase[layer.databaseKey] ?? const <AuditTableSpec>[];

    try {
      final actualTables = await layer.listTables();
      final actualSet = actualTables.toSet();
      final expectedNames = specs.map((spec) => spec.tableName).toSet();
      final allTableNames = <String>[
        ...specs.map((spec) => spec.tableName),
        ...actualTables.where((table) => !expectedNames.contains(table)),
      ];

      final entries = <TableInventoryEntry>[];
      for (final tableName in allTableNames) {
        final spec = specs
            .where((candidate) => candidate.tableName == tableName)
            .firstOrNull;
        final exists = actualSet.contains(tableName);
        if (!exists) {
          entries.add(
            TableInventoryEntry(
              databaseKey: layer.databaseKey,
              tableName: tableName,
              exists: false,
              notes: <String>[...?spec?.notes, 'Expected table is missing.'],
            ),
          );
          continue;
        }

        final rowCount = await layer.countRows(tableName);
        final primaryKey = await layer.primaryKeyInfo(tableName);
        final importantColumns = <DatabaseHealthImportantColumnSummary>[];
        for (final columnSpec
            in spec?.importantColumns ?? const <AuditImportantColumnSpec>[]) {
          final summary = await layer.summarizeImportantColumn(
            tableName: tableName,
            spec: columnSpec,
          );
          if (summary != null) {
            importantColumns.add(summary);
          }
        }

        final notes = <String>[
          ...?spec?.notes,
          if (!expectedNames.contains(tableName))
            'Table was discovered via sqlite_master and is not yet curated in the Phase 1 spec.',
          if (rowCount == 0) 'Table is empty.',
        ];

        entries.add(
          TableInventoryEntry(
            databaseKey: layer.databaseKey,
            tableName: tableName,
            exists: true,
            rowCount: rowCount,
            primaryKey: primaryKey,
            importantColumns: importantColumns,
            notes: notes,
          ),
        );
      }

      return entries;
    } catch (error) {
      errors.add(
        HealthReportError(
          scope: DatabaseHealthErrorScope.tableInventory,
          databaseKey: layer.databaseKey,
          message: error.toString(),
        ),
      );
      return <TableInventoryEntry>[];
    }
  }

  Future<List<RelationshipCheckResult>> _buildRelationshipChecks(
    DatabaseHealthQueryLayer layer,
    List<HealthReportError> errors,
  ) async {
    final specs =
        _relationshipSpecsByDatabase[layer.databaseKey] ??
        const <_RelationshipCheckSpec>[];
    final results = <RelationshipCheckResult>[];

    for (final spec in specs) {
      try {
        results.add(await _evaluateRelationshipCheck(layer, spec));
      } catch (error) {
        errors.add(
          HealthReportError(
            scope: DatabaseHealthErrorScope.relationshipCheck,
            databaseKey: layer.databaseKey,
            checkKey: spec.checkKey,
            message: error.toString(),
          ),
        );
        results.add(
          RelationshipCheckResult(
            checkKey: spec.checkKey,
            databaseKey: layer.databaseKey,
            relationshipType: spec.relationshipType,
            parentTable: spec.parentTable,
            childTable: spec.childTable,
            joinExpressionDescription: spec.joinExpressionDescription,
            status: DatabaseHealthStatus.error,
            notes: spec.notes,
            error: error.toString(),
          ),
        );
      }
    }

    return results;
  }

  Future<RelationshipCheckResult> _evaluateRelationshipCheck(
    DatabaseHealthQueryLayer layer,
    _RelationshipCheckSpec spec,
  ) async {
    final parentRowCount = await layer.countRows(spec.parentTable);
    final childRowCount = await layer.countRows(spec.childTable);
    final matchedRowCount = await _countQuery(layer, '''
      SELECT COUNT(*) AS c
      FROM ${_quoted(spec.parentTable)} AS p
      WHERE EXISTS (
        SELECT 1
        FROM ${_quoted(spec.childTable)} AS c
        WHERE ${spec.parentAliasPredicate}
      )
      ''');
    final unmatchedParentRowCount = await _countQuery(layer, '''
      SELECT COUNT(*) AS c
      FROM ${_quoted(spec.parentTable)} AS p
      WHERE NOT EXISTS (
        SELECT 1
        FROM ${_quoted(spec.childTable)} AS c
        WHERE ${spec.parentAliasPredicate}
      )
      ''');
    final unmatchedChildRowCount = await _countQuery(layer, '''
      SELECT COUNT(*) AS c
      FROM ${_quoted(spec.childTable)} AS c
      WHERE NOT EXISTS (
        SELECT 1
        FROM ${_quoted(spec.parentTable)} AS p
        WHERE ${spec.childAliasPredicate}
      )
      ''');

    final status = _statusFromRelationshipCounts(
      matchedRowCount: matchedRowCount,
      unmatchedParentRowCount: unmatchedParentRowCount,
      unmatchedChildRowCount: unmatchedChildRowCount,
      parentRowCount: parentRowCount,
      childRowCount: childRowCount,
    );

    return RelationshipCheckResult(
      checkKey: spec.checkKey,
      databaseKey: layer.databaseKey,
      relationshipType: spec.relationshipType,
      parentTable: spec.parentTable,
      childTable: spec.childTable,
      joinExpressionDescription: spec.joinExpressionDescription,
      parentRowCount: parentRowCount,
      childRowCount: childRowCount,
      matchedRowCount: matchedRowCount,
      unmatchedParentRowCount: unmatchedParentRowCount,
      unmatchedChildRowCount: unmatchedChildRowCount,
      matchedPercentage: _percentageOrNull(matchedRowCount, parentRowCount),
      unmatchedParentPercentage: _percentageOrNull(
        unmatchedParentRowCount,
        parentRowCount,
      ),
      unmatchedChildPercentage: _percentageOrNull(
        unmatchedChildRowCount,
        childRowCount,
      ),
      status: status,
      notes: spec.notes,
    );
  }

  Future<List<InvariantCheckResult>> _buildInvariantChecks(
    DatabaseHealthQueryLayer layer,
    List<HealthReportError> errors,
  ) async {
    final specs =
        _invariantSpecsByDatabase[layer.databaseKey] ??
        const <_InvariantCheckSpec>[];
    final results = <InvariantCheckResult>[];

    for (final spec in specs) {
      try {
        final evaluatedRowCount = await _countQuery(
          layer,
          spec.evaluatedRowCountSql,
        );
        final violationCount = await _countQuery(layer, spec.violationCountSql);
        results.add(
          InvariantCheckResult(
            checkKey: spec.checkKey,
            severity: spec.severity,
            description: spec.description,
            status: _statusFromInvariantCounts(
              violationCount: violationCount,
              evaluatedRowCount: evaluatedRowCount,
            ),
            violationCount: violationCount,
            evaluatedRowCount: evaluatedRowCount,
            notes: spec.notes,
          ),
        );
      } catch (error) {
        errors.add(
          HealthReportError(
            scope: DatabaseHealthErrorScope.invariantCheck,
            databaseKey: layer.databaseKey,
            checkKey: spec.checkKey,
            message: error.toString(),
          ),
        );
        results.add(
          InvariantCheckResult(
            checkKey: spec.checkKey,
            severity: spec.severity,
            description: spec.description,
            status: DatabaseHealthStatus.error,
            notes: spec.notes,
            error: error.toString(),
          ),
        );
      }
    }

    return results;
  }

  HealthReportSummary _buildSummary({
    required List<TableInventoryEntry> tableInventory,
    required List<RelationshipCheckResult> relationshipChecks,
    required List<InvariantCheckResult> invariantChecks,
    required List<HealthReportError> errors,
  }) {
    final activeTableInventory = tableInventory
        .where((entry) => !_isRetiredCleanupDatabaseKey(entry.databaseKey))
        .toList();
    final allStatuses = <DatabaseHealthStatus>[
      ...relationshipChecks.map((check) => check.status),
      ...invariantChecks.map((check) => check.status),
      if (errors.isNotEmpty) DatabaseHealthStatus.error,
      if (activeTableInventory.any((entry) => !entry.exists))
        DatabaseHealthStatus.fail,
      if (activeTableInventory.any(
        (entry) => entry.exists && (entry.rowCount ?? 0) == 0,
      ))
        DatabaseHealthStatus.warning,
    ];

    final headlineFindings = <String>[
      ...activeTableInventory
          .where((entry) => !entry.exists)
          .map((entry) => '${entry.databaseKey}.${entry.tableName} is missing'),
      ...activeTableInventory
          .where((entry) => entry.exists && (entry.rowCount ?? 0) == 0)
          .map((entry) => '${entry.databaseKey}.${entry.tableName} is empty'),
      ...relationshipChecks
          .where((check) => check.status != DatabaseHealthStatus.pass)
          .take(5)
          .map(_headlineForRelationshipCheck),
      ...invariantChecks
          .where(
            (check) =>
                check.status != DatabaseHealthStatus.pass &&
                check.status != DatabaseHealthStatus.notApplicable,
          )
          .take(5)
          .map(_headlineForInvariantCheck),
      ...invariantChecks
          .where((check) => check.status == DatabaseHealthStatus.notApplicable)
          .take(2)
          .map((check) => '${check.checkKey}: phase1 not applicable'),
      ...errors.take(5).map((error) => '${error.scope.name}: ${error.message}'),
    ];

    final passCount = _countStatus(allStatuses, DatabaseHealthStatus.pass);
    final warningCount = _countStatus(
      allStatuses,
      DatabaseHealthStatus.warning,
    );
    final failCount = _countStatus(allStatuses, DatabaseHealthStatus.fail);
    final errorCount = _countStatus(allStatuses, DatabaseHealthStatus.error);

    return HealthReportSummary(
      overallStatus: _overallStatus(allStatuses),
      tableCount: activeTableInventory.length,
      relationshipCheckCount: relationshipChecks.length,
      invariantCheckCount: invariantChecks.length,
      passCount: passCount,
      warningCount: warningCount,
      failCount: failCount,
      errorCount: errorCount,
      headlineFindings: headlineFindings.take(12).toList(),
    );
  }
}

class _RelationshipCheckSpec {
  const _RelationshipCheckSpec({
    required this.checkKey,
    required this.relationshipType,
    required this.parentTable,
    required this.childTable,
    required this.parentAliasPredicate,
    required this.childAliasPredicate,
    required this.joinExpressionDescription,
    this.notes = const <String>[],
  });

  final String checkKey;
  final DatabaseHealthRelationshipType relationshipType;
  final String parentTable;
  final String childTable;
  final String parentAliasPredicate;
  final String childAliasPredicate;
  final String joinExpressionDescription;
  final List<String> notes;
}

class _InvariantCheckSpec {
  const _InvariantCheckSpec({
    required this.checkKey,
    required this.severity,
    required this.description,
    required this.evaluatedRowCountSql,
    required this.violationCountSql,
    this.notes = const <String>[],
  });

  final String checkKey;
  final DatabaseHealthSeverity severity;
  final String description;
  final String evaluatedRowCountSql;
  final String violationCountSql;
  final List<String> notes;
}

Future<int> _countQuery(DatabaseHealthQueryLayer layer, String sql) async {
  final rows = await layer.query(sql);
  final value = rows.first['c'];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.parse(value.toString());
}

bool _isRetiredCleanupDatabaseKey(String databaseKey) {
  return databaseKey == databaseHealthKeyRetiredMacosImport ||
      databaseKey == databaseHealthKeyRetiredWorking;
}

DatabaseHealthStatus _statusFromRelationshipCounts({
  required int matchedRowCount,
  required int unmatchedParentRowCount,
  required int unmatchedChildRowCount,
  required int parentRowCount,
  required int childRowCount,
}) {
  if (unmatchedParentRowCount == 0 && unmatchedChildRowCount == 0) {
    return DatabaseHealthStatus.pass;
  }
  if (matchedRowCount == 0 && (parentRowCount > 0 || childRowCount > 0)) {
    return DatabaseHealthStatus.fail;
  }
  return DatabaseHealthStatus.warning;
}

DatabaseHealthStatus _statusFromInvariantCounts({
  required int violationCount,
  required int evaluatedRowCount,
}) {
  if (evaluatedRowCount == 0) {
    return DatabaseHealthStatus.notApplicable;
  }
  if (violationCount == 0) {
    return DatabaseHealthStatus.pass;
  }
  if (violationCount == evaluatedRowCount) {
    return DatabaseHealthStatus.fail;
  }
  return DatabaseHealthStatus.warning;
}

DatabaseHealthStatus _overallStatus(List<DatabaseHealthStatus> statuses) {
  if (statuses.contains(DatabaseHealthStatus.error)) {
    return DatabaseHealthStatus.error;
  }
  if (statuses.contains(DatabaseHealthStatus.fail)) {
    return DatabaseHealthStatus.fail;
  }
  if (statuses.contains(DatabaseHealthStatus.warning)) {
    return DatabaseHealthStatus.warning;
  }
  if (statuses.contains(DatabaseHealthStatus.pass)) {
    return DatabaseHealthStatus.pass;
  }
  return DatabaseHealthStatus.notApplicable;
}

int _countStatus(
  List<DatabaseHealthStatus> statuses,
  DatabaseHealthStatus status,
) {
  return statuses.where((value) => value == status).length;
}

double? _percentageOrNull(int numerator, int denominator) {
  if (denominator == 0) {
    return null;
  }
  return ((numerator / denominator) * 1000).round() / 10.0;
}

String _headlineForRelationshipCheck(RelationshipCheckResult check) {
  final parentCount = check.parentRowCount ?? 0;
  final childCount = check.childRowCount ?? 0;
  final unmatchedParents = check.unmatchedParentRowCount ?? 0;
  final unmatchedChildren = check.unmatchedChildRowCount ?? 0;
  final parentRate = _formatPercentage(check.unmatchedParentPercentage);
  final childRate = _formatPercentage(check.unmatchedChildPercentage);

  final segments = <String>[];
  if (parentCount > 0 && unmatchedParents > 0) {
    segments.add('$unmatchedParents/$parentCount parent unmatched$parentRate');
  }
  if (childCount > 0 && unmatchedChildren > 0) {
    segments.add('$unmatchedChildren/$childCount child unmatched$childRate');
  }
  if (segments.isEmpty) {
    final matched = check.matchedRowCount ?? 0;
    final matchedRate = _formatPercentage(check.matchedPercentage);
    segments.add('$matched matched$matchedRate');
  }

  return '${check.checkKey}: ${segments.join(', ')}';
}

String _headlineForInvariantCheck(InvariantCheckResult check) {
  final violations = check.violationCount ?? 0;
  final evaluated = check.evaluatedRowCount ?? 0;
  final rate = _formatPercentage(_percentageOrNull(violations, evaluated));
  if (evaluated > 0) {
    return '${check.checkKey}: $violations/$evaluated violations$rate';
  }
  return '${check.checkKey}: $violations violations';
}

String _formatPercentage(double? value) {
  if (value == null) {
    return '';
  }
  return ' (${value.toStringAsFixed(1)}%)';
}

String _quoted(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

const Map<String, List<AuditTableSpec>>
_tableSpecsByDatabase = <String, List<AuditTableSpec>>{
  databaseHealthKeyRetiredMacosImport: <AuditTableSpec>[
    AuditTableSpec(
      tableName: 'historical_archive_sources',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('source_chat_db'),
        AuditImportantColumnSpec('preflight_status_label'),
        AuditImportantColumnSpec('last_import_success'),
        AuditImportantColumnSpec('last_imported_message_count'),
        AuditImportantColumnSpec(
          'source_label',
          omittedForPrivacy: true,
          notes: <String>['Archive source labels are intentionally omitted.'],
        ),
        AuditImportantColumnSpec(
          'folder_path',
          omittedForPrivacy: true,
          notes: <String>['Archive folder paths are intentionally omitted.'],
        ),
      ],
      notes: <String>[
        'Retired archive-source cleanup rows; active archive-source metadata lives in overlay.',
      ],
    ),
  ],
  databaseHealthKeyRetiredWorking: <AuditTableSpec>[
    AuditTableSpec(
      tableName: 'recovered_unlinked_messages',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('sender_handle_id'),
        AuditImportantColumnSpec(
          'text',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
        AuditImportantColumnSpec('has_attachments'),
      ],
      notes: <String>[
        'Retired recovered-message cleanup rows; ordinary evidence lives in the graph.',
      ],
    ),
    AuditTableSpec(
      tableName: 'recovered_unlinked_attachments',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_guid'),
        AuditImportantColumnSpec('import_attachment_id'),
        AuditImportantColumnSpec('local_path'),
      ],
      notes: <String>['Retired recovered-message attachment cleanup rows.'],
    ),
  ],
  databaseHealthKeySourceScopedImport: <AuditTableSpec>[
    AuditTableSpec(tableName: 'source_registry'),
    AuditTableSpec(tableName: 'import_batches'),
    AuditTableSpec(
      tableName: 'messages',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('source_id'),
        AuditImportantColumnSpec('source_rowid'),
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('sender_handle_ss_id'),
        AuditImportantColumnSpec(
          'text',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
        AuditImportantColumnSpec(
          'attributed_body_blob',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
        AuditImportantColumnSpec('raw_item_type'),
        AuditImportantColumnSpec('raw_associated_message_type'),
        AuditImportantColumnSpec('is_system_message'),
      ],
      notes: <String>[
        'Source-scoped import ledger; ss_id preserves source occurrence identity.',
      ],
    ),
    AuditTableSpec(
      tableName: 'handles',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('source_id'),
        AuditImportantColumnSpec('source_rowid'),
        AuditImportantColumnSpec('service'),
      ],
    ),
    AuditTableSpec(
      tableName: 'chats',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('source_id'),
        AuditImportantColumnSpec('source_rowid'),
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('service'),
        AuditImportantColumnSpec('group_id'),
        AuditImportantColumnSpec('original_group_id'),
      ],
    ),
    AuditTableSpec(tableName: 'chat_to_message'),
    AuditTableSpec(tableName: 'chat_to_handle'),
    AuditTableSpec(
      tableName: 'contacts',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('source_id'),
        AuditImportantColumnSpec('source_rowid'),
        AuditImportantColumnSpec(
          'display_name',
          omittedForPrivacy: true,
          notes: <String>['Contact names are intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(
      tableName: 'contact_channels',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('kind'),
        AuditImportantColumnSpec(
          'value',
          omittedForPrivacy: true,
          notes: <String>['Contact channel values are intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(
      tableName: 'attachments',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('source_id'),
        AuditImportantColumnSpec('source_rowid'),
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec(
          'transfer_name',
          omittedForPrivacy: true,
          notes: <String>['Attachment filenames are intentionally omitted.'],
        ),
        AuditImportantColumnSpec('mime_type'),
      ],
    ),
    AuditTableSpec(tableName: 'message_to_attachment'),
  ],
  databaseHealthKeyConversationGraph: <AuditTableSpec>[
    AuditTableSpec(
      tableName: 'messages',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('sender_handle_ss_id'),
        AuditImportantColumnSpec('sender_canonical_handle_ss_id'),
        AuditImportantColumnSpec(
          'text',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
        AuditImportantColumnSpec('semantic_kind'),
        AuditImportantColumnSpec('item_kind'),
        AuditImportantColumnSpec('is_system_message'),
        AuditImportantColumnSpec('is_sparse_artifact'),
      ],
      notes: <String>[
        'Primary source-scoped working graph. ss_id is canonical row identity.',
      ],
    ),
    AuditTableSpec(
      tableName: 'handles',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('service'),
      ],
    ),
    AuditTableSpec(
      tableName: 'canonical_handles',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec(
          'display_handle',
          omittedForPrivacy: true,
          notes: <String>['Handle values are intentionally omitted.'],
        ),
        AuditImportantColumnSpec('alias_count'),
      ],
    ),
    AuditTableSpec(tableName: 'handle_aliases'),
    AuditTableSpec(
      tableName: 'chats',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('service'),
        AuditImportantColumnSpec('is_group'),
      ],
    ),
    AuditTableSpec(tableName: 'chat_to_message'),
    AuditTableSpec(tableName: 'chat_to_handle'),
    AuditTableSpec(
      tableName: 'contacts',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec(
          'display_name',
          omittedForPrivacy: true,
          notes: <String>['Contact names are intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(tableName: 'contact_to_handle'),
    AuditTableSpec(
      tableName: 'attachments',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec(
          'transfer_name',
          omittedForPrivacy: true,
          notes: <String>['Attachment filenames are intentionally omitted.'],
        ),
        AuditImportantColumnSpec('mime_type'),
      ],
    ),
    AuditTableSpec(tableName: 'message_to_attachment'),
  ],
  databaseHealthKeyOverlay: <AuditTableSpec>[
    AuditTableSpec(tableName: 'participant_overrides'),
    AuditTableSpec(tableName: 'chat_overrides'),
    AuditTableSpec(
      tableName: 'message_annotations',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_id'),
        AuditImportantColumnSpec(
          'user_notes',
          omittedForPrivacy: true,
          notes: <String>['User-authored notes are intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(tableName: 'message_user_flags'),
    AuditTableSpec(tableName: 'message_user_tags'),
    AuditTableSpec(tableName: 'handle_to_participant_overrides'),
    AuditTableSpec(tableName: 'virtual_participants'),
    AuditTableSpec(tableName: 'overlay_settings'),
    AuditTableSpec(tableName: 'favorite_contacts'),
    AuditTableSpec(tableName: 'dismissed_handles'),
    AuditTableSpec(tableName: 'handle_visibility_overrides'),
    AuditTableSpec(
      tableName: 'archived_attachments',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_guid'),
        AuditImportantColumnSpec('import_attachment_id'),
        AuditImportantColumnSpec(
          'archive_relative_path',
          omittedForPrivacy: true,
          notes: <String>['Archive path is intentionally omitted.'],
        ),
        AuditImportantColumnSpec(
          'original_local_path',
          omittedForPrivacy: true,
          notes: <String>['Original attachment path is intentionally omitted.'],
        ),
      ],
    ),
  ],
};

const Map<String, List<_RelationshipCheckSpec>>
_relationshipSpecsByDatabase = <String, List<_RelationshipCheckSpec>>{
  databaseHealthKeyRetiredWorking: <_RelationshipCheckSpec>[
    _RelationshipCheckSpec(
      checkKey: 'recovered_unlinked_attachments_to_messages_by_guid',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'recovered_unlinked_attachments',
      childTable: 'recovered_unlinked_messages',
      parentAliasPredicate: 'c.guid = p.message_guid',
      childAliasPredicate: 'p.message_guid = c.guid',
      joinExpressionDescription:
          'recovered_unlinked_attachments.message_guid = recovered_unlinked_messages.guid',
      notes: <String>[
        'Retired recovered-message cleanup check; ordinary attachment edges are graph-owned.',
      ],
    ),
  ],
  databaseHealthKeySourceScopedImport: <_RelationshipCheckSpec>[
    _RelationshipCheckSpec(
      checkKey: 'chat_to_message_to_chats_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_message',
      childTable: 'chats',
      parentAliasPredicate: 'c.ss_id = p.chat_ss_id',
      childAliasPredicate: 'p.chat_ss_id = c.ss_id',
      joinExpressionDescription: 'chat_to_message.chat_ss_id = chats.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_message_to_messages_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_message',
      childTable: 'messages',
      parentAliasPredicate: 'c.ss_id = p.message_ss_id',
      childAliasPredicate: 'p.message_ss_id = c.ss_id',
      joinExpressionDescription:
          'chat_to_message.message_ss_id = messages.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_handle_to_chats_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_handle',
      childTable: 'chats',
      parentAliasPredicate: 'c.ss_id = p.chat_ss_id',
      childAliasPredicate: 'p.chat_ss_id = c.ss_id',
      joinExpressionDescription: 'chat_to_handle.chat_ss_id = chats.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_handle_to_handles_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_handle',
      childTable: 'handles',
      parentAliasPredicate: 'c.ss_id = p.handle_ss_id',
      childAliasPredicate: 'p.handle_ss_id = c.ss_id',
      joinExpressionDescription: 'chat_to_handle.handle_ss_id = handles.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'message_to_attachment_to_messages_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'message_to_attachment',
      childTable: 'messages',
      parentAliasPredicate: 'c.ss_id = p.message_ss_id',
      childAliasPredicate: 'p.message_ss_id = c.ss_id',
      joinExpressionDescription:
          'message_to_attachment.message_ss_id = messages.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'message_to_attachment_to_attachments_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'message_to_attachment',
      childTable: 'attachments',
      parentAliasPredicate: 'c.ss_id = p.attachment_ss_id',
      childAliasPredicate: 'p.attachment_ss_id = c.ss_id',
      joinExpressionDescription:
          'message_to_attachment.attachment_ss_id = attachments.ss_id',
    ),
  ],
  databaseHealthKeyConversationGraph: <_RelationshipCheckSpec>[
    _RelationshipCheckSpec(
      checkKey: 'chat_to_message_to_chats_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_message',
      childTable: 'chats',
      parentAliasPredicate: 'c.ss_id = p.chat_ss_id',
      childAliasPredicate: 'p.chat_ss_id = c.ss_id',
      joinExpressionDescription: 'chat_to_message.chat_ss_id = chats.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_message_to_messages_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_message',
      childTable: 'messages',
      parentAliasPredicate: 'c.ss_id = p.message_ss_id',
      childAliasPredicate: 'p.message_ss_id = c.ss_id',
      joinExpressionDescription:
          'chat_to_message.message_ss_id = messages.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_handle_to_chats_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_handle',
      childTable: 'chats',
      parentAliasPredicate: 'c.ss_id = p.chat_ss_id',
      childAliasPredicate: 'p.chat_ss_id = c.ss_id',
      joinExpressionDescription: 'chat_to_handle.chat_ss_id = chats.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_handle_to_handles_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_handle',
      childTable: 'handles',
      parentAliasPredicate: 'c.ss_id = p.handle_ss_id',
      childAliasPredicate: 'p.handle_ss_id = c.ss_id',
      joinExpressionDescription: 'chat_to_handle.handle_ss_id = handles.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'message_to_attachment_to_messages_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'message_to_attachment',
      childTable: 'messages',
      parentAliasPredicate: 'c.ss_id = p.message_ss_id',
      childAliasPredicate: 'p.message_ss_id = c.ss_id',
      joinExpressionDescription:
          'message_to_attachment.message_ss_id = messages.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'message_to_attachment_to_attachments_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'message_to_attachment',
      childTable: 'attachments',
      parentAliasPredicate: 'c.ss_id = p.attachment_ss_id',
      childAliasPredicate: 'p.attachment_ss_id = c.ss_id',
      joinExpressionDescription:
          'message_to_attachment.attachment_ss_id = attachments.ss_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'contact_to_handle_to_contacts',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'contact_to_handle',
      childTable: 'contacts',
      parentAliasPredicate: 'c.contact_id = p.contact_id',
      childAliasPredicate: 'p.contact_id = c.contact_id',
      joinExpressionDescription:
          'contact_to_handle.contact_id = contacts.contact_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'contact_to_handle_to_handles_by_ss_id',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'contact_to_handle',
      childTable: 'handles',
      parentAliasPredicate: 'c.ss_id = p.handle_ss_id',
      childAliasPredicate: 'p.handle_ss_id = c.ss_id',
      joinExpressionDescription:
          'contact_to_handle.handle_ss_id = handles.ss_id',
    ),
  ],
};

const Map<String, List<_InvariantCheckSpec>>
_invariantSpecsByDatabase = <String, List<_InvariantCheckSpec>>{
  databaseHealthKeySourceScopedImport: <_InvariantCheckSpec>[
    _InvariantCheckSpec(
      checkKey: 'source_scoped_attachment_edges_should_reference_rows',
      severity: DatabaseHealthSeverity.high,
      description:
          'Every source-scoped message_to_attachment row should reference both a message and an attachment.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "message_to_attachment"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "message_to_attachment" AS ma
            WHERE NOT EXISTS (
              SELECT 1 FROM "messages" AS m WHERE m.ss_id = ma.message_ss_id
            )
            OR NOT EXISTS (
              SELECT 1
              FROM "attachments" AS a
              WHERE a.ss_id = ma.attachment_ss_id
            )
          ''',
    ),
  ],
  databaseHealthKeyConversationGraph: <_InvariantCheckSpec>[
    _InvariantCheckSpec(
      checkKey: 'graph_message_attachment_edges_should_reference_rows',
      severity: DatabaseHealthSeverity.high,
      description:
          'Every graph message_to_attachment row should reference both a message and an attachment.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "message_to_attachment"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "message_to_attachment" AS ma
            WHERE NOT EXISTS (
              SELECT 1 FROM "messages" AS m WHERE m.ss_id = ma.message_ss_id
            )
            OR NOT EXISTS (
              SELECT 1
              FROM "attachments" AS a
              WHERE a.ss_id = ma.attachment_ss_id
            )
          ''',
    ),
    _InvariantCheckSpec(
      checkKey: 'graph_chat_handle_edges_should_reference_rows',
      severity: DatabaseHealthSeverity.high,
      description:
          'Every graph chat_to_handle row should reference both a chat and a handle.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "chat_to_handle"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "chat_to_handle" AS ch
            WHERE NOT EXISTS (
              SELECT 1 FROM "chats" AS c WHERE c.ss_id = ch.chat_ss_id
            )
            OR NOT EXISTS (
              SELECT 1 FROM "handles" AS h WHERE h.ss_id = ch.handle_ss_id
            )
          ''',
    ),
    _InvariantCheckSpec(
      checkKey: 'graph_contact_handle_edges_should_reference_rows',
      severity: DatabaseHealthSeverity.high,
      description:
          'Every graph contact_to_handle row should reference both a contact and a handle.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "contact_to_handle"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "contact_to_handle" AS ch
            WHERE NOT EXISTS (
              SELECT 1 FROM "contacts" AS c WHERE c.contact_id = ch.contact_id
            )
            OR NOT EXISTS (
              SELECT 1 FROM "handles" AS h WHERE h.ss_id = ch.handle_ss_id
            )
          ''',
    ),
  ],
  databaseHealthKeyOverlay: <_InvariantCheckSpec>[
    _InvariantCheckSpec(
      checkKey: 'overlay_cross_database_relationship_checks_deferred',
      severity: DatabaseHealthSeverity.low,
      description:
          'Cross-database overlay-to-working relationship checks are intentionally deferred in Phase 1.',
      evaluatedRowCountSql: 'SELECT 0 AS c',
      violationCountSql: 'SELECT 0 AS c',
      notes: <String>[
        'Phase 1 inventories overlay tables but does not execute cross-database relationship checks.',
      ],
    ),
  ],
};
