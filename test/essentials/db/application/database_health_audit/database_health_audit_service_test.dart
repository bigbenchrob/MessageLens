import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_models.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_report_writer.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_service.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_database_keys.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_query_layer.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_runtime_environment.dart';

void main() {
  group('DatabaseHealthAuditService', () {
    test('reports authoritative injected application metadata', () async {
      final report = await _buildService(
        hasFullDiskAccess: true,
        queryLayers: const [],
      ).buildPhase1Report();

      expect(report.app, _testAppInfo);
      expect(
        report.environment.diagnosticNotes,
        contains(
          'Build metadata is read from the running application package.',
        ),
      );
    });

    test(
      'uses injected full disk access state in environment report',
      () async {
        final service = _buildService(
          hasFullDiskAccess: false,
          queryLayers: const [],
        );

        final report = await service.buildPhase1Report();

        expect(report.environment.hasFullDiskAccess, isFalse);
      },
    );

    test(
      'curates source-scoped graph databases in the health report',
      () async {
        final service = _buildService(
          hasFullDiskAccess: true,
          queryLayers: <DatabaseHealthQueryLayer>[
            _FakeHealthQueryLayer(
              databaseKey: databaseHealthKeySourceScopedImport,
              role: databaseHealthRoleSourceScopedImportLedger,
            ),
            _FakeHealthQueryLayer(
              databaseKey: databaseHealthKeyConversationGraph,
              role: databaseHealthRoleConversationGraph,
            ),
          ],
        );

        final report = await service.buildPhase1Report();

        expect(
          report.tableInventory,
          contains(
            isA<TableInventoryEntry>()
                .having(
                  (entry) => entry.databaseKey,
                  'databaseKey',
                  databaseHealthKeySourceScopedImport,
                )
                .having((entry) => entry.tableName, 'tableName', 'messages'),
          ),
        );
        expect(
          report.tableInventory,
          contains(
            isA<TableInventoryEntry>()
                .having(
                  (entry) => entry.databaseKey,
                  'databaseKey',
                  databaseHealthKeyConversationGraph,
                )
                .having(
                  (entry) => entry.tableName,
                  'tableName',
                  'contact_to_handle',
                ),
          ),
        );
        expect(
          report.relationshipChecks.map((check) => check.checkKey),
          contains('contact_to_handle_to_handles_by_ss_id'),
        );
        expect(
          report.invariantChecks.map((check) => check.checkKey),
          contains('graph_contact_handle_edges_should_reference_rows'),
        );
        expect(report.errors, isEmpty);
      },
    );

    test(
      'treats retired macos import database as cleanup inventory only',
      () async {
        final service = _buildService(
          hasFullDiskAccess: true,
          queryLayers: <DatabaseHealthQueryLayer>[
            _FakeHealthQueryLayer(
              databaseKey: databaseHealthKeyRetiredMacosImport,
              role: databaseHealthRoleRetiredMacosImportCleanup,
            ),
          ],
        );

        final report = await service.buildPhase1Report();
        final retiredCleanupTables = report.tableInventory
            .where(
              (entry) =>
                  entry.databaseKey == databaseHealthKeyRetiredMacosImport,
            )
            .map((entry) => entry.tableName)
            .toSet();

        expect(
          retiredCleanupTables,
          containsAll(<String>{'historical_archive_sources'}),
        );
        expect(retiredCleanupTables, isNot(contains('schema_migrations')));
        expect(retiredCleanupTables, isNot(contains('messages')));
        expect(retiredCleanupTables, isNot(contains('import_batches')));
        expect(
          report.tableInventory
              .singleWhere(
                (entry) =>
                    entry.databaseKey == databaseHealthKeyRetiredMacosImport &&
                    entry.tableName == 'historical_archive_sources',
              )
              .notes,
          contains(
            'Retired archive-source cleanup rows; active archive-source metadata lives in overlay.',
          ),
        );
        expect(
          report.relationshipChecks
              .where(
                (check) =>
                    check.databaseKey == databaseHealthKeyRetiredMacosImport,
              )
              .map((check) => check.checkKey),
          isEmpty,
        );
        expect(
          report.summary.overallStatus,
          DatabaseHealthStatus.notApplicable,
        );
        expect(report.summary.tableCount, 0);
        expect(report.summary.warningCount, 0);
        expect(
          report.summary.headlineFindings,
          isNot(contains('retired_macos_import.schema_migrations is empty')),
        );
        expect(report.invariantChecks, isEmpty);
        expect(report.errors, isEmpty);
      },
    );

    test('treats retired working database as cleanup inventory only', () async {
      final service = _buildService(
        hasFullDiskAccess: true,
        queryLayers: <DatabaseHealthQueryLayer>[
          _FakeHealthQueryLayer(
            databaseKey: databaseHealthKeyRetiredWorking,
            role: databaseHealthRoleRetiredWorkingCleanup,
          ),
        ],
      );

      final report = await service.buildPhase1Report();
      final retiredWorkingTables = report.tableInventory
          .where(
            (entry) => entry.databaseKey == databaseHealthKeyRetiredWorking,
          )
          .map((entry) => entry.tableName)
          .toSet();

      expect(
        retiredWorkingTables,
        containsAll(<String>{
          'recovered_unlinked_messages',
          'recovered_unlinked_attachments',
        }),
      );
      expect(retiredWorkingTables, isNot(contains('schema_migrations')));
      expect(retiredWorkingTables, isNot(contains('messages')));
      expect(retiredWorkingTables, isNot(contains('chats')));
      expect(retiredWorkingTables, isNot(contains('global_message_index')));
      expect(retiredWorkingTables, isNot(contains('projection_state')));
      expect(
        report.relationshipChecks
            .where(
              (check) => check.databaseKey == databaseHealthKeyRetiredWorking,
            )
            .map((check) => check.checkKey),
        contains('recovered_unlinked_attachments_to_messages_by_guid'),
      );
      expect(report.summary.tableCount, 0);
      final retiredRecoveredRelationship = report.relationshipChecks
          .where(
            (check) => check.databaseKey == databaseHealthKeyRetiredWorking,
          )
          .singleWhere(
            (check) =>
                check.checkKey ==
                'recovered_unlinked_attachments_to_messages_by_guid',
          );
      expect(
        retiredRecoveredRelationship.notes,
        contains(
          'Retired recovered-message cleanup check; ordinary attachment edges are graph-owned.',
        ),
      );
      expect(
        report.relationshipChecks
            .where(
              (check) => check.databaseKey == databaseHealthKeyRetiredWorking,
            )
            .map((check) => check.checkKey),
        isNot(contains('messages_to_chats')),
      );
      expect(report.invariantChecks.map((check) => check.checkKey), isEmpty);
      expect(
        report.invariantChecks.map((check) => check.checkKey),
        isNot(contains('working_messages_should_have_chat_linkage')),
      );
      expect(report.errors, isEmpty);
    });

    test(
      'does not inventory a retired database when its file is absent',
      () async {
        final service = _buildService(
          hasFullDiskAccess: true,
          queryLayers: <DatabaseHealthQueryLayer>[
            _FakeHealthQueryLayer(
              databaseKey: databaseHealthKeyRetiredWorking,
              role: databaseHealthRoleRetiredWorkingCleanup,
              fileExists: false,
            ),
          ],
        );

        final report = await service.buildPhase1Report();

        expect(
          report.databases.single.databaseKey,
          databaseHealthKeyRetiredWorking,
        );
        expect(report.databases.single.accessible, isFalse);
        expect(report.databases.single.readOnlyOpenSucceeded, isFalse);
        expect(report.tableInventory, isEmpty);
        expect(report.relationshipChecks, isEmpty);
        expect(report.invariantChecks, isEmpty);
        expect(report.errors, isEmpty);
      },
    );
  });
}

DatabaseHealthAuditService _buildService({
  required bool hasFullDiskAccess,
  required List<DatabaseHealthQueryLayer> queryLayers,
}) {
  return DatabaseHealthAuditService(
    appInfo: _testAppInfo,
    hasFullDiskAccess: hasFullDiskAccess,
    queryLayers: queryLayers,
    runtimeEnvironment: const _FakeRuntimeEnvironment(),
    reportWriter: const _FakeReportWriter(),
  );
}

const _testAppInfo = DatabaseHealthAppInfo(
  name: 'MessageLens Test',
  bundleId: 'com.bigbenchsoftware.MessageLens.test',
  version: '9.8.7',
  buildNumber: '654',
  buildChannel: 'test',
);

class _FakeRuntimeEnvironment implements DatabaseHealthRuntimeEnvironment {
  const _FakeRuntimeEnvironment();

  @override
  DatabaseHealthRuntimeEnvironmentSnapshot read() {
    return const DatabaseHealthRuntimeEnvironmentSnapshot(
      platform: 'test',
      platformVersion: 'test-version',
      timezone: 'test-zone',
    );
  }
}

class _FakeReportWriter implements DatabaseHealthAuditReportWriter {
  const _FakeReportWriter();

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    return '$outputDirectoryPath/database_health.json';
  }
}

class _FakeHealthQueryLayer extends DatabaseHealthQueryLayer {
  _FakeHealthQueryLayer({
    required this.databaseKey,
    required this.role,
    this.fileExists = true,
  });

  @override
  final String databaseKey;

  @override
  final String role;

  final bool fileExists;

  @override
  String get databasePath => '/tmp/$databaseKey.db';

  @override
  Future<bool> databaseFileExists() async => fileExists;

  @override
  Future<List<Map<String, Object?>>> query(String sql) async {
    if (!fileExists) {
      throw StateError('Fake database file is absent');
    }
    final normalized = sql.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized == 'SELECT 1 AS ok') {
      return <Map<String, Object?>>[
        <String, Object?>{'ok': 1},
      ];
    }
    if (normalized == 'SELECT 1 AS c') {
      return <Map<String, Object?>>[
        <String, Object?>{'c': 1},
      ];
    }
    if (normalized == 'PRAGMA user_version') {
      return <Map<String, Object?>>[
        <String, Object?>{'user_version': 1},
      ];
    }
    if (normalized.startsWith('SELECT name FROM sqlite_master')) {
      return _tablesFor(
        databaseKey,
      ).map((table) => <String, Object?>{'name': table}).toList();
    }
    if (normalized.startsWith('PRAGMA table_info')) {
      return const <Map<String, Object?>>[];
    }
    if (normalized.startsWith('SELECT COUNT(*) AS c')) {
      return <Map<String, Object?>>[
        <String, Object?>{'c': 0},
      ];
    }
    if (normalized.startsWith('SELECT CASE WHEN EXISTS')) {
      return <Map<String, Object?>>[
        <String, Object?>{'c': 0},
      ];
    }
    if (normalized.startsWith('SELECT SUM(CASE')) {
      return <Map<String, Object?>>[
        <String, Object?>{
          'null_count': 0,
          'non_null_count': 0,
          'distinct_count': 0,
        },
      ];
    }
    throw UnsupportedError('Unexpected fake health query: $normalized');
  }

  List<String> _tablesFor(String key) {
    return switch (key) {
      databaseHealthKeyRetiredMacosImport => const <String>[
        'historical_archive_sources',
      ],
      databaseHealthKeyRetiredWorking => const <String>[
        'recovered_unlinked_messages',
        'recovered_unlinked_attachments',
      ],
      databaseHealthKeySourceScopedImport => const <String>[
        'source_registry',
        'import_batches',
        'messages',
        'handles',
        'chats',
        'chat_to_message',
        'chat_to_handle',
        'contacts',
        'contact_channels',
        'attachments',
        'message_to_attachment',
      ],
      databaseHealthKeyConversationGraph => const <String>[
        'messages',
        'handles',
        'canonical_handles',
        'handle_aliases',
        'chats',
        'chat_to_message',
        'chat_to_handle',
        'contacts',
        'contact_to_handle',
        'attachments',
        'message_to_attachment',
      ],
      _ => const <String>[],
    };
  }
}
