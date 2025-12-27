import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';

/// Diagnostic utilities for troubleshooting migration issues
class MigrationDiagnostics {
  const MigrationDiagnostics();

  /// Check the state of both databases and report potential issues
  Future<Map<String, dynamic>> diagnose({
    required SqfliteImportDatabase importDb,
    required WorkingDatabase workingDb,
  }) async {
    final report = <String, dynamic>{};

    // Check import database
    final importSqlite = await importDb.database;
    report['import_db_path'] = importSqlite.path;
    report['import_db_open'] = importSqlite.isOpen;

    try {
      final importMessageCount = await importSqlite.rawQuery(
        'SELECT COUNT(*) as count FROM messages',
      );
      report['import_messages'] = importMessageCount.first['count'];
    } catch (e) {
      report['import_messages_error'] = e.toString();
    }

    try {
      final importAttachmentCount = await importSqlite.rawQuery(
        'SELECT COUNT(*) as count FROM attachments',
      );
      report['import_attachments'] = importAttachmentCount.first['count'];
    } catch (e) {
      report['import_attachments_error'] = e.toString();
    }

    // Check working database
    try {
      final workingMessageCount = await workingDb
          .customSelect('SELECT COUNT(*) as count FROM messages')
          .get();
      report['working_messages'] = workingMessageCount.first.data['count'];
    } catch (e) {
      report['working_messages_error'] = e.toString();
    }

    try {
      final workingAttachmentCount = await workingDb
          .customSelect('SELECT COUNT(*) as count FROM attachments')
          .get();
      report['working_attachments'] =
          workingAttachmentCount.first.data['count'];
    } catch (e) {
      report['working_attachments_error'] = e.toString();
    }

    // Check for attached databases
    try {
      final attached = await workingDb
          .customSelect('PRAGMA database_list')
          .get();
      final attachedNames = attached
          .map((row) => row.data['name'] as String?)
          .where((name) => name != null && name != 'main' && name != 'temp')
          .toList();
      report['attached_databases'] = attachedNames;
    } catch (e) {
      report['attached_databases_error'] = e.toString();
    }

    // Check projection state
    try {
      final projectionState = await workingDb
          .customSelect('SELECT * FROM projection_state')
          .get();
      if (projectionState.isNotEmpty) {
        report['projection_state'] = projectionState.first.data;
      }
    } catch (e) {
      report['projection_state_error'] = e.toString();
    }

    // Check for foreign key violations
    try {
      final fkCheck = await workingDb
          .customSelect('PRAGMA foreign_key_check')
          .get();
      report['foreign_key_violations'] = fkCheck.length;
      if (fkCheck.isNotEmpty) {
        report['foreign_key_violations_sample'] = fkCheck
            .take(5)
            .map((row) => row.data)
            .toList();
      }
    } catch (e) {
      report['foreign_key_check_error'] = e.toString();
    }

    return report;
  }

  /// Print a human-readable diagnostic report
  String formatReport(Map<String, dynamic> report) {
    final buffer = StringBuffer();
    buffer.writeln('=== Migration Diagnostics ===');
    buffer.writeln('');

    buffer.writeln('Import Database:');
    buffer.writeln('  Path: ${report['import_db_path']}');
    buffer.writeln('  Open: ${report['import_db_open']}');
    buffer.writeln(
      '  Messages: ${report['import_messages'] ?? report['import_messages_error']}',
    );
    buffer.writeln(
      '  Attachments: ${report['import_attachments'] ?? report['import_attachments_error']}',
    );
    buffer.writeln('');

    buffer.writeln('Working Database:');
    buffer.writeln(
      '  Messages: ${report['working_messages'] ?? report['working_messages_error']}',
    );
    buffer.writeln(
      '  Attachments: ${report['working_attachments'] ?? report['working_attachments_error']}',
    );
    buffer.writeln('');

    if (report.containsKey('attached_databases')) {
      buffer.writeln('Attached Databases: ${report['attached_databases']}');
      buffer.writeln('');
    }

    if (report.containsKey('projection_state')) {
      buffer.writeln('Projection State:');
      final state = report['projection_state'] as Map<String, dynamic>;
      state.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
      buffer.writeln('');
    }

    if (report.containsKey('foreign_key_violations')) {
      final count = report['foreign_key_violations'] as int;
      buffer.writeln('Foreign Key Violations: $count');
      if (count > 0 && report.containsKey('foreign_key_violations_sample')) {
        buffer.writeln('Sample violations:');
        final samples = report['foreign_key_violations_sample'] as List;
        for (final sample in samples) {
          buffer.writeln('  $sample');
        }
      }
      buffer.writeln('');
    }

    buffer.writeln('=== End Diagnostics ===');
    return buffer.toString();
  }
}
