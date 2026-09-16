import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import '../../../archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../db/app_database_files.dart';
import '../../../db/application/read_only_sql_guard.dart';
import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/health/graph_health_report.dart';
import '../../application/health/graph_health_repository.dart';

class SqliteGraphHealthRepository implements GraphHealthRepository {
  const SqliteGraphHealthRepository({
    required this.graphDatabase,
    this.overlayDatabase,
    this.attachmentArchiveDirectory,
    this.attachmentArchiveUnavailableReason,
    this.historicalMessageLensDataFolderPath,
    this.recoveredMessagesFolderPath,
    this.recoveredMessagesAttachmentsFolderName = 'Attachments',
  });

  final ConversationGraphDatabase graphDatabase;
  final OverlayDatabase? overlayDatabase;
  final String? attachmentArchiveDirectory;
  final String? attachmentArchiveUnavailableReason;
  final String? historicalMessageLensDataFolderPath;
  final String? recoveredMessagesFolderPath;
  final String recoveredMessagesAttachmentsFolderName;

  @override
  Future<GraphHealthReport> readHealthReport({
    bool includeFileAudits = false,
    bool includeRecoveryAudit = false,
  }) async {
    final shouldIncludeFileAudits = includeFileAudits || includeRecoveryAudit;
    final archiveHealth = await _readArchiveHealth(
      includeFileAudits: shouldIncludeFileAudits,
    );
    final recoveryAudit =
        includeRecoveryAudit &&
            archiveHealth.physicalAuditStatus ==
                GraphArchivePhysicalAuditStatus.completed
        ? await _readAttachmentRecoveryAudit(
            currentAvailableArchiveKeys:
                archiveHealth.currentAvailableArchiveKeys,
          )
        : const _AttachmentRecoveryAudit.skipped();
    return GraphHealthReport(
      messageCount: await _count('SELECT COUNT(*) FROM messages'),
      chatCount: await _count('SELECT COUNT(*) FROM chats'),
      handleCount: await _count('SELECT COUNT(*) FROM handles'),
      canonicalHandleCount: await _count(
        'SELECT COUNT(*) FROM canonical_handles',
      ),
      handleAliasCount: await _count('SELECT COUNT(*) FROM handle_aliases'),
      contactCount: await _count('SELECT COUNT(*) FROM contacts'),
      attachmentCount: await _count('SELECT COUNT(*) FROM attachments'),
      archiveFileAuditIncluded: shouldIncludeFileAudits,
      archivePhysicalAuditStatus: archiveHealth.physicalAuditStatus,
      archivePhysicalAuditIssue: archiveHealth.physicalAuditIssue,
      archiveRecordCount: archiveHealth.archiveRecordCount,
      attachmentsWithArchiveRecordCount:
          archiveHealth.attachmentsWithArchiveRecordCount,
      attachmentsMissingArchiveRecordCount:
          archiveHealth.attachmentsMissingArchiveRecordCount,
      archiveFilesAvailableCount: archiveHealth.archiveFilesAvailableCount,
      archiveFilesMissingCount: archiveHealth.archiveFilesMissingCount,
      archiveRecordsWithoutGraphAttachmentCount:
          archiveHealth.archiveRecordsWithoutGraphAttachmentCount,
      attachmentRecoveryAuditIncluded: includeRecoveryAudit,
      historicalArchiveAvailable: recoveryAudit.historicalArchiveAvailable,
      historicalArchiveRecordCount: recoveryAudit.historicalArchiveRecordCount,
      historicalArchiveFilesAvailableCount:
          recoveryAudit.historicalArchiveFilesAvailableCount,
      historicalArchiveFilesMissingCount:
          recoveryAudit.historicalArchiveFilesMissingCount,
      attachmentsRecoverableFromHistoricalArchiveCount:
          recoveryAudit.attachmentsRecoverableFromHistoricalArchiveCount,
      recoveredMessagesSourceAvailable:
          recoveryAudit.recoveredMessagesSourceAvailable,
      recoveredMessagesAttachmentKeyCount:
          recoveryAudit.recoveredMessagesAttachmentKeyCount,
      attachmentsRecoverableFromRecoveredMessagesCount:
          recoveryAudit.attachmentsRecoverableFromRecoveredMessagesCount,
      attachmentsRecoverableFromBothRecoverySourcesCount:
          recoveryAudit.attachmentsRecoverableFromBothRecoverySourcesCount,
      attachmentsStillMissingFromKnownRecoverySourcesCount:
          recoveryAudit.attachmentsStillMissingFromKnownRecoverySourcesCount,
      dryRunAlreadyAvailableInCurrentArchiveCount:
          recoveryAudit.dryRunAlreadyAvailableInCurrentArchiveCount,
      dryRunWouldCopyFromHistoricalArchiveCount:
          recoveryAudit.dryRunWouldCopyFromHistoricalArchiveCount,
      dryRunWouldCopyFromRecoveredMessagesCount:
          recoveryAudit.dryRunWouldCopyFromRecoveredMessagesCount,
      dryRunWouldArchiveFromCurrentSourcePathCount:
          recoveryAudit.dryRunWouldArchiveFromCurrentSourcePathCount,
      dryRunStillMissingEverywhereCount:
          recoveryAudit.dryRunStillMissingEverywhereCount,
      dryRunStillMissingPluginPayloadCandidateCount:
          recoveryAudit.dryRunStillMissingPluginPayloadCandidateCount,
      missingAttachmentSamples: recoveryAudit.missingAttachmentSamples,
      chatToMessageEdgeCount: await _count(
        'SELECT COUNT(*) FROM chat_to_message',
      ),
      chatToHandleEdgeCount: await _count(
        'SELECT COUNT(*) FROM chat_to_handle',
      ),
      messageToAttachmentEdgeCount: await _count(
        'SELECT COUNT(*) FROM message_to_attachment',
      ),
      contactToHandleEdgeCount: await _count(
        'SELECT COUNT(*) FROM contact_to_handle',
      ),
      orphanMessageCount: await _count('''
        SELECT COUNT(*)
        FROM messages m
        LEFT JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
        WHERE ctm.message_ss_id IS NULL
      '''),
      chatsWithZeroMessagesCount: await _count('''
        SELECT COUNT(*)
        FROM chats c
        LEFT JOIN chat_to_message ctm ON ctm.chat_ss_id = c.ss_id
        WHERE ctm.chat_ss_id IS NULL
      '''),
      chatsWithZeroHandlesCount: await _count('''
        SELECT COUNT(*)
        FROM chats c
        LEFT JOIN chat_to_handle cth ON cth.chat_ss_id = c.ss_id
        WHERE cth.chat_ss_id IS NULL
      '''),
      attachmentsWithoutMessageEdgeCount: await _count('''
        SELECT COUNT(*)
        FROM attachments a
        LEFT JOIN message_to_attachment mta
          ON mta.attachment_ss_id = a.ss_id
        WHERE mta.attachment_ss_id IS NULL
      '''),
      messagesMissingSenderCanonicalHandleCount: await _count('''
        SELECT COUNT(*)
        FROM messages m
        LEFT JOIN handle_aliases ha
          ON ha.handle_ss_id = m.sender_handle_ss_id
        WHERE m.sender_handle_ss_id IS NOT NULL
          AND m.sender_canonical_handle_ss_id IS NULL
          AND ha.canonical_handle_ss_id IS NULL
      '''),
      handlesWithoutCanonicalAliasCount: await _count('''
        SELECT COUNT(*)
        FROM handles h
        LEFT JOIN handle_aliases ha ON ha.handle_ss_id = h.ss_id
        WHERE ha.handle_ss_id IS NULL
      '''),
      contactsWithoutHandlesCount: await _count('''
        SELECT COUNT(*)
        FROM contacts c
        LEFT JOIN contact_to_handle cth ON cth.contact_id = c.contact_id
        WHERE cth.contact_id IS NULL
      '''),
      chatToMessageEdgesMissingChatCount: await _count('''
        SELECT COUNT(*)
        FROM chat_to_message ctm
        LEFT JOIN chats c ON c.ss_id = ctm.chat_ss_id
        WHERE c.ss_id IS NULL
      '''),
      chatToMessageEdgesMissingMessageCount: await _count('''
        SELECT COUNT(*)
        FROM chat_to_message ctm
        LEFT JOIN messages m ON m.ss_id = ctm.message_ss_id
        WHERE m.ss_id IS NULL
      '''),
      chatToHandleEdgesMissingChatCount: await _count('''
        SELECT COUNT(*)
        FROM chat_to_handle cth
        LEFT JOIN chats c ON c.ss_id = cth.chat_ss_id
        WHERE c.ss_id IS NULL
      '''),
      chatToHandleEdgesMissingHandleCount: await _count('''
        SELECT COUNT(*)
        FROM chat_to_handle cth
        LEFT JOIN handles h ON h.ss_id = cth.handle_ss_id
        WHERE h.ss_id IS NULL
      '''),
      messageToAttachmentEdgesMissingMessageCount: await _count('''
        SELECT COUNT(*)
        FROM message_to_attachment mta
        LEFT JOIN messages m ON m.ss_id = mta.message_ss_id
        WHERE m.ss_id IS NULL
      '''),
      messageToAttachmentEdgesMissingAttachmentCount: await _count('''
        SELECT COUNT(*)
        FROM message_to_attachment mta
        LEFT JOIN attachments a ON a.ss_id = mta.attachment_ss_id
        WHERE a.ss_id IS NULL
      '''),
      contactToHandleEdgesMissingContactCount: await _count('''
        SELECT COUNT(*)
        FROM contact_to_handle cth
        LEFT JOIN contacts c ON c.contact_id = cth.contact_id
        WHERE c.contact_id IS NULL
      '''),
      contactToHandleEdgesMissingHandleCount: await _count('''
        SELECT COUNT(*)
        FROM contact_to_handle cth
        LEFT JOIN handles h ON h.ss_id = cth.handle_ss_id
        WHERE h.ss_id IS NULL
      '''),
    );
  }

  Future<int> _count(String sql) async {
    final rows = await graphDatabase.selectRows('SELECT ($sql) AS count');
    final value = rows.single['count'];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return 0;
  }

  Future<_ArchiveHealth> _readArchiveHealth({
    required bool includeFileAudits,
  }) async {
    final overlayDb = overlayDatabase;
    if (overlayDb == null) {
      return _ArchiveHealth.empty(
        physicalAuditStatus: includeFileAudits
            ? attachmentArchiveDirectory == null
                  ? GraphArchivePhysicalAuditStatus.deferredRootUnavailable
                  : GraphArchivePhysicalAuditStatus.completed
            : GraphArchivePhysicalAuditStatus.notRequested,
        physicalAuditIssue: includeFileAudits
            ? attachmentArchiveUnavailableReason
            : null,
      );
    }

    final archiveRows = await overlayDb.customSelect('''
      SELECT message_guid, import_attachment_id, archive_relative_path
      FROM archived_attachments
      ''').get();
    final archiveByKey = <ArchiveCompatibilityKey, String>{};
    for (final row in archiveRows) {
      final messageGuid = row.read<String>('message_guid');
      final archiveCompatibilityAttachmentId = row.read<int>(
        'import_attachment_id',
      );
      final archiveRelativePath = row.read<String>('archive_relative_path');
      archiveByKey[ArchiveCompatibilityKey.fromStoredTuple(
            messageGuid: messageGuid,
            importAttachmentId: archiveCompatibilityAttachmentId,
          )] =
          archiveRelativePath;
    }

    final attachmentRows = await graphDatabase.selectRows('''
      SELECT
        a.ss_id AS attachment_ss_id,
        m.guid AS message_guid
      FROM attachments a
      LEFT JOIN message_to_attachment mta ON mta.attachment_ss_id = a.ss_id
      LEFT JOIN messages m ON m.ss_id = mta.message_ss_id
      ''');

    final matchedArchiveKeys = <ArchiveCompatibilityKey>{};
    final attachmentsWithArchiveRecord = <int>{};
    var attachmentsMissingArchiveRecordCount = 0;

    for (final row in attachmentRows) {
      final attachmentSsId = _readInt(row['attachment_ss_id']);
      final messageGuid = row['message_guid'];
      if (messageGuid is! String || messageGuid.isEmpty) {
        attachmentsMissingArchiveRecordCount += 1;
        continue;
      }
      final key = ArchiveCompatibilityKey.fromLiveAttachmentSsId(
        messageGuid: messageGuid,
        attachmentSsId: attachmentSsId,
      );
      if (archiveByKey.containsKey(key)) {
        matchedArchiveKeys.add(key);
        attachmentsWithArchiveRecord.add(attachmentSsId);
      } else {
        attachmentsMissingArchiveRecordCount += 1;
      }
    }

    var archiveFilesAvailableCount = 0;
    var archiveFilesMissingCount = 0;
    final currentAvailableArchiveKeys = <ArchiveCompatibilityKey>{};
    final archiveDirectory = attachmentArchiveDirectory;
    if (includeFileAudits &&
        archiveDirectory != null &&
        archiveDirectory.isNotEmpty) {
      for (final entry in archiveByKey.entries) {
        final relativePath = entry.value;
        if (_archiveRegularFileExists(
          archiveDirectoryPath: archiveDirectory,
          archiveRelativePath: relativePath,
        )) {
          archiveFilesAvailableCount += 1;
          currentAvailableArchiveKeys.add(entry.key);
        } else {
          archiveFilesMissingCount += 1;
        }
      }
    }

    final physicalAuditStatus = !includeFileAudits
        ? GraphArchivePhysicalAuditStatus.notRequested
        : archiveDirectory == null || archiveDirectory.isEmpty
        ? GraphArchivePhysicalAuditStatus.deferredRootUnavailable
        : GraphArchivePhysicalAuditStatus.completed;

    return _ArchiveHealth(
      archiveRecordCount: archiveByKey.length,
      currentArchiveKeys: archiveByKey.keys.toSet(),
      currentAvailableArchiveKeys: currentAvailableArchiveKeys,
      attachmentsWithArchiveRecordCount: attachmentsWithArchiveRecord.length,
      attachmentsMissingArchiveRecordCount:
          attachmentsMissingArchiveRecordCount,
      archiveFilesAvailableCount: archiveFilesAvailableCount,
      archiveFilesMissingCount: archiveFilesMissingCount,
      archiveRecordsWithoutGraphAttachmentCount:
          archiveByKey.length - matchedArchiveKeys.length,
      physicalAuditStatus: physicalAuditStatus,
      physicalAuditIssue:
          physicalAuditStatus ==
              GraphArchivePhysicalAuditStatus.deferredRootUnavailable
          ? attachmentArchiveUnavailableReason ??
                'The attachment archive root is unavailable.'
          : null,
    );
  }

  Future<_AttachmentRecoveryAudit> _readAttachmentRecoveryAudit({
    required Set<ArchiveCompatibilityKey> currentAvailableArchiveKeys,
  }) async {
    final graphAttachmentKeys = await _readGraphAttachmentKeys();
    final currentSource = await _readCurrentSourceAttachmentKeys();
    final unarchivedGraphAttachmentKeys = graphAttachmentKeys.difference(
      currentAvailableArchiveKeys,
    );
    final historicalArchive = await _readHistoricalArchiveKeys();
    final recoveredMessages = _readRecoveredMessagesAttachmentKeys();
    final currentArchiveRecordKeys = await _readCurrentArchiveRecordKeys();

    final historicalRecoverable = unarchivedGraphAttachmentKeys.intersection(
      historicalArchive.availableKeys,
    );
    final recoveredMessagesRecoverable = unarchivedGraphAttachmentKeys
        .intersection(recoveredMessages.availableKeys);
    final bothRecoverable = historicalRecoverable.intersection(
      recoveredMessagesRecoverable,
    );
    final anyRecoverable = <ArchiveCompatibilityKey>{
      ...historicalRecoverable,
      ...recoveredMessagesRecoverable,
    };
    final remainingAfterHistorical = unarchivedGraphAttachmentKeys.difference(
      historicalRecoverable,
    );
    final wouldCopyFromRecoveredMessages = remainingAfterHistorical
        .intersection(recoveredMessages.availableKeys);
    final remainingAfterRecovered = remainingAfterHistorical.difference(
      wouldCopyFromRecoveredMessages,
    );
    final wouldArchiveFromCurrentSource = remainingAfterRecovered.intersection(
      currentSource.availableKeys,
    );
    final missingEverywhere = remainingAfterRecovered.difference(
      wouldArchiveFromCurrentSource,
    );
    final missingSamples = await _readMissingAttachmentSamples(
      missingKeys: missingEverywhere,
      historicalArchiveKeys: historicalArchive.allKeys,
      recoveredMessagesKeys: recoveredMessages.allKeys,
      currentArchiveRecordKeys: currentArchiveRecordKeys,
    );

    return _AttachmentRecoveryAudit(
      historicalArchiveAvailable: historicalArchive.available,
      historicalArchiveRecordCount: historicalArchive.recordCount,
      historicalArchiveFilesAvailableCount:
          historicalArchive.filesAvailableCount,
      historicalArchiveFilesMissingCount: historicalArchive.filesMissingCount,
      attachmentsRecoverableFromHistoricalArchiveCount:
          historicalRecoverable.length,
      recoveredMessagesSourceAvailable: recoveredMessages.available,
      recoveredMessagesAttachmentKeyCount: recoveredMessages.recordCount,
      attachmentsRecoverableFromRecoveredMessagesCount:
          recoveredMessagesRecoverable.length,
      attachmentsRecoverableFromBothRecoverySourcesCount:
          bothRecoverable.length,
      attachmentsStillMissingFromKnownRecoverySourcesCount:
          unarchivedGraphAttachmentKeys.length - anyRecoverable.length,
      dryRunAlreadyAvailableInCurrentArchiveCount: graphAttachmentKeys
          .intersection(currentAvailableArchiveKeys)
          .length,
      dryRunWouldCopyFromHistoricalArchiveCount: historicalRecoverable.length,
      dryRunWouldCopyFromRecoveredMessagesCount:
          wouldCopyFromRecoveredMessages.length,
      dryRunWouldArchiveFromCurrentSourcePathCount:
          wouldArchiveFromCurrentSource.length,
      dryRunStillMissingEverywhereCount: missingEverywhere.length,
      dryRunStillMissingPluginPayloadCandidateCount: missingEverywhere
          .intersection(currentSource.pluginPayloadKeys)
          .length,
      missingAttachmentSamples: missingSamples,
    );
  }

  Future<_CurrentSourceAttachmentKeys>
  _readCurrentSourceAttachmentKeys() async {
    final rows = await graphDatabase.selectRows('''
      SELECT DISTINCT
        a.ss_id AS attachment_ss_id,
        m.guid AS message_guid,
        a.filename,
        a.transfer_name,
        a.uti
      FROM attachments a
      JOIN message_to_attachment mta ON mta.attachment_ss_id = a.ss_id
      JOIN messages m ON m.ss_id = mta.message_ss_id
      WHERE m.guid IS NOT NULL
        AND m.guid != ''
      ''');
    final availableKeys = <ArchiveCompatibilityKey>{};
    final pluginPayloadKeys = <ArchiveCompatibilityKey>{};
    for (final row in rows) {
      final messageGuid = row['message_guid'];
      if (messageGuid is! String || messageGuid.isEmpty) {
        continue;
      }
      final attachmentSsId = _readInt(row['attachment_ss_id']);
      final key = ArchiveCompatibilityKey.fromLiveAttachmentSsId(
        messageGuid: messageGuid,
        attachmentSsId: attachmentSsId,
      );
      final filename = row['filename'] as String?;
      if (_localFileExists(filename)) {
        availableKeys.add(key);
      }
      final transferName = row['transfer_name'];
      final uti = row['uti'];
      if ((transferName is String &&
              transferName.toLowerCase().endsWith('pluginpayloadattachment')) ||
          (uti is String && uti.startsWith('dyn.'))) {
        pluginPayloadKeys.add(key);
      }
    }
    return _CurrentSourceAttachmentKeys(
      availableKeys: availableKeys,
      pluginPayloadKeys: pluginPayloadKeys,
    );
  }

  Future<Set<ArchiveCompatibilityKey>> _readCurrentArchiveRecordKeys() async {
    final overlayDb = overlayDatabase;
    if (overlayDb == null) {
      return const <ArchiveCompatibilityKey>{};
    }
    final rows = await overlayDb.customSelect('''
      SELECT message_guid, import_attachment_id
      FROM archived_attachments
      ''').get();
    return {
      for (final row in rows)
        ArchiveCompatibilityKey.fromStoredTuple(
          messageGuid: row.read<String>('message_guid'),
          importAttachmentId: row.read<int>('import_attachment_id'),
        ),
    };
  }

  Future<List<MissingAttachmentRecoverySample>> _readMissingAttachmentSamples({
    required Set<ArchiveCompatibilityKey> missingKeys,
    required Set<ArchiveCompatibilityKey> historicalArchiveKeys,
    required Set<ArchiveCompatibilityKey> recoveredMessagesKeys,
    required Set<ArchiveCompatibilityKey> currentArchiveRecordKeys,
  }) async {
    if (missingKeys.isEmpty) {
      return const <MissingAttachmentRecoverySample>[];
    }

    final rows = await graphDatabase.selectRows('''
      SELECT DISTINCT
        a.ss_id AS attachment_ss_id,
        m.guid AS message_guid,
        a.filename,
        a.mime_type,
        a.uti
      FROM attachments a
      JOIN message_to_attachment mta ON mta.attachment_ss_id = a.ss_id
      JOIN messages m ON m.ss_id = mta.message_ss_id
      WHERE m.guid IS NOT NULL
        AND m.guid != ''
      ORDER BY a.ss_id ASC
      ''');

    final samples = <MissingAttachmentRecoverySample>[];
    for (final row in rows) {
      if (samples.length >= 20) {
        break;
      }
      final attachmentSsId = _readInt(row['attachment_ss_id']);
      final messageGuid = row['message_guid'];
      if (messageGuid is! String || messageGuid.isEmpty) {
        continue;
      }
      final key = ArchiveCompatibilityKey.fromLiveAttachmentSsId(
        messageGuid: messageGuid,
        attachmentSsId: attachmentSsId,
      );
      if (!missingKeys.contains(key)) {
        continue;
      }
      final archiveCompatibilityAttachmentId =
          key.archiveCompatibilityAttachmentId;
      final filename = row['filename'] as String?;
      samples.add(
        MissingAttachmentRecoverySample(
          attachmentSsId: attachmentSsId,
          archiveMessageGuid: messageGuid,
          archiveCompatibilitySourceRowId: archiveCompatibilityAttachmentId,
          filename: filename,
          mimeType: row['mime_type'] as String?,
          uti: row['uti'] as String?,
          currentSourcePathExists: _localFileExists(filename),
          historicalArchiveKeyExists:
              historicalArchiveKeys.contains(key) ||
              currentArchiveRecordKeys.contains(key),
          recoveredMessagesKeyExists: recoveredMessagesKeys.contains(key),
          attemptedRecoveredPath: _recoveredAttachmentCandidatePath(
            messagesFolderPath: recoveredMessagesFolderPath,
            filename: filename,
          ),
        ),
      );
    }

    return samples;
  }

  Future<Set<ArchiveCompatibilityKey>> _readGraphAttachmentKeys() async {
    final rows = await graphDatabase.selectRows('''
      SELECT DISTINCT
        a.ss_id AS attachment_ss_id,
        m.guid AS message_guid
      FROM attachments a
      JOIN message_to_attachment mta ON mta.attachment_ss_id = a.ss_id
      JOIN messages m ON m.ss_id = mta.message_ss_id
      WHERE m.guid IS NOT NULL
        AND m.guid != ''
      ''');
    return {
      for (final row in rows)
        if (row['message_guid'] case final String messageGuid)
          ArchiveCompatibilityKey.fromLiveAttachmentSsId(
            messageGuid: messageGuid,
            attachmentSsId: _readInt(row['attachment_ss_id']),
          ),
    };
  }

  Future<_ExternalArchiveKeys> _readHistoricalArchiveKeys() async {
    final dataFolderPath = historicalMessageLensDataFolderPath;
    if (dataFolderPath == null || dataFolderPath.isEmpty) {
      return const _ExternalArchiveKeys.unavailable();
    }

    final overlayFile = File(
      appDatabasePath(
        AppDatabaseFile.overlay,
        databaseDirectory: dataFolderPath,
      ),
    );
    final archiveDirectory = Directory('$dataFolderPath/attachment_archive');
    if (!overlayFile.existsSync() || !archiveDirectory.existsSync()) {
      return const _ExternalArchiveKeys.unavailable();
    }

    final overlayDb = sqlite3.sqlite3.open(
      overlayFile.path,
      mode: sqlite3.OpenMode.readOnly,
    );
    try {
      overlayDb.execute('PRAGMA query_only = ON;');
      overlayDb.execute('PRAGMA busy_timeout = 3000;');
      const sql = '''
        SELECT message_guid, import_attachment_id, archive_relative_path
        FROM archived_attachments
        ''';
      assertReadOnlySql(
        sql,
        boundary: 'Historical archive metadata keys query',
      );
      final rows = overlayDb.select(sql);
      final availableKeys = <ArchiveCompatibilityKey>{};
      final allKeys = <ArchiveCompatibilityKey>{};
      var filesMissingCount = 0;
      for (final row in rows) {
        final messageGuid = row['message_guid'];
        final archiveCompatibilityAttachmentId = row['import_attachment_id'];
        final relativePath = row['archive_relative_path'];
        if (messageGuid is! String ||
            archiveCompatibilityAttachmentId is! int ||
            relativePath is! String) {
          continue;
        }
        final key = ArchiveCompatibilityKey.fromStoredTuple(
          messageGuid: messageGuid,
          importAttachmentId: archiveCompatibilityAttachmentId,
        );
        allKeys.add(key);
        if (_archiveRegularFileExists(
          archiveDirectoryPath: archiveDirectory.path,
          archiveRelativePath: relativePath,
        )) {
          availableKeys.add(key);
        } else {
          filesMissingCount += 1;
        }
      }
      return _ExternalArchiveKeys(
        available: true,
        recordCount: rows.length,
        allKeys: allKeys,
        availableKeys: availableKeys,
        filesAvailableCount: availableKeys.length,
        filesMissingCount: filesMissingCount,
      );
    } finally {
      overlayDb.dispose();
    }
  }

  _RecoveredMessagesKeys _readRecoveredMessagesAttachmentKeys() {
    final messagesFolderPath = recoveredMessagesFolderPath;
    if (messagesFolderPath == null || messagesFolderPath.isEmpty) {
      return const _RecoveredMessagesKeys.unavailable();
    }

    final chatDbFile = File('$messagesFolderPath/chat.db');
    final attachmentsDirectory = Directory(
      '$messagesFolderPath/$recoveredMessagesAttachmentsFolderName',
    );
    if (!chatDbFile.existsSync() || !attachmentsDirectory.existsSync()) {
      return const _RecoveredMessagesKeys.unavailable();
    }

    final db = sqlite3.sqlite3.open(
      chatDbFile.path,
      mode: sqlite3.OpenMode.readOnly,
    );
    try {
      db.execute('PRAGMA query_only = ON;');
      db.execute('PRAGMA busy_timeout = 3000;');
      const sql = '''
        SELECT
          m.guid AS message_guid,
          a.ROWID AS import_attachment_id,
          a.filename AS filename
        FROM message_attachment_join maj
        JOIN message m ON m.ROWID = maj.message_id
        JOIN attachment a ON a.ROWID = maj.attachment_id
        WHERE m.guid IS NOT NULL
          AND m.guid != ''
      ''';
      assertReadOnlySql(
        sql,
        boundary: 'Recovered Messages attachment key query',
      );
      final resultSet = db.select(sql);
      final availableKeys = <ArchiveCompatibilityKey>{};
      final allKeys = <ArchiveCompatibilityKey>{};
      for (final row in resultSet) {
        final messageGuid = row['message_guid'];
        final archiveCompatibilityAttachmentId = row['import_attachment_id'];
        final filename = row['filename'];
        if (messageGuid is! String ||
            archiveCompatibilityAttachmentId is! int) {
          continue;
        }
        final key = ArchiveCompatibilityKey.fromStoredTuple(
          messageGuid: messageGuid,
          importAttachmentId: archiveCompatibilityAttachmentId,
        );
        allKeys.add(key);
        if (_recoveredAttachmentFileExists(
          messagesFolderPath: messagesFolderPath,
          filename: filename is String ? filename : null,
        )) {
          availableKeys.add(key);
        }
      }
      return _RecoveredMessagesKeys(
        available: true,
        recordCount: resultSet.length,
        allKeys: allKeys,
        availableKeys: availableKeys,
      );
    } finally {
      db.dispose();
    }
  }

  bool _recoveredAttachmentFileExists({
    required String messagesFolderPath,
    required String? filename,
  }) {
    final candidate = _recoveredAttachmentCandidatePath(
      messagesFolderPath: messagesFolderPath,
      filename: filename,
    );
    return candidate != null && _regularFileExists(candidate);
  }

  String? _recoveredAttachmentCandidatePath({
    required String? messagesFolderPath,
    required String? filename,
  }) {
    if (messagesFolderPath == null ||
        messagesFolderPath.isEmpty ||
        filename == null ||
        filename.isEmpty) {
      return null;
    }
    const marker = '/Library/Messages/Attachments/';
    final markerIndex = filename.indexOf(marker);
    if (markerIndex >= 0) {
      final relativePath = filename.substring(markerIndex + marker.length);
      return '$messagesFolderPath/$recoveredMessagesAttachmentsFolderName/'
          '$relativePath';
    }
    if (filename.startsWith('~/Library/Messages/Attachments/')) {
      final relativePath = filename.substring(
        '~/Library/Messages/Attachments/'.length,
      );
      return '$messagesFolderPath/$recoveredMessagesAttachmentsFolderName/'
          '$relativePath';
    }
    if (filename.startsWith('Attachments/')) {
      final relativePath = filename.substring('Attachments/'.length);
      return '$messagesFolderPath/$recoveredMessagesAttachmentsFolderName/'
          '$relativePath';
    }
    return filename;
  }

  static bool _localFileExists(String? pathHint) {
    if (pathHint == null || pathHint.isEmpty) {
      return false;
    }
    final path = _expandHome(pathHint);
    return File(path).existsSync();
  }

  static bool _archiveRegularFileExists({
    required String archiveDirectoryPath,
    required String archiveRelativePath,
  }) {
    final rootPath = path.normalize(path.absolute(archiveDirectoryPath));
    final candidatePath = path.normalize(
      path.absolute(path.join(rootPath, archiveRelativePath)),
    );
    if (!path.isWithin(rootPath, candidatePath)) {
      return false;
    }
    return _regularFileExists(candidatePath);
  }

  static bool _regularFileExists(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.file;
  }

  static String _expandHome(String path) {
    if (!path.startsWith('~/')) {
      return path;
    }
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      return path;
    }
    return '$home/${path.substring(2)}';
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return 0;
  }
}

class _ArchiveHealth {
  const _ArchiveHealth({
    required this.archiveRecordCount,
    required this.currentArchiveKeys,
    required this.currentAvailableArchiveKeys,
    required this.attachmentsWithArchiveRecordCount,
    required this.attachmentsMissingArchiveRecordCount,
    required this.archiveFilesAvailableCount,
    required this.archiveFilesMissingCount,
    required this.archiveRecordsWithoutGraphAttachmentCount,
    required this.physicalAuditStatus,
    required this.physicalAuditIssue,
  });

  const _ArchiveHealth.empty({
    required this.physicalAuditStatus,
    required this.physicalAuditIssue,
  }) : archiveRecordCount = 0,
       currentArchiveKeys = const <ArchiveCompatibilityKey>{},
       currentAvailableArchiveKeys = const <ArchiveCompatibilityKey>{},
       attachmentsWithArchiveRecordCount = 0,
       attachmentsMissingArchiveRecordCount = 0,
       archiveFilesAvailableCount = 0,
       archiveFilesMissingCount = 0,
       archiveRecordsWithoutGraphAttachmentCount = 0;

  final int archiveRecordCount;
  final Set<ArchiveCompatibilityKey> currentArchiveKeys;
  final Set<ArchiveCompatibilityKey> currentAvailableArchiveKeys;
  final int attachmentsWithArchiveRecordCount;
  final int attachmentsMissingArchiveRecordCount;
  final int archiveFilesAvailableCount;
  final int archiveFilesMissingCount;
  final int archiveRecordsWithoutGraphAttachmentCount;
  final GraphArchivePhysicalAuditStatus physicalAuditStatus;
  final String? physicalAuditIssue;
}

class _ExternalArchiveKeys {
  const _ExternalArchiveKeys({
    required this.available,
    required this.recordCount,
    required this.allKeys,
    required this.availableKeys,
    required this.filesAvailableCount,
    required this.filesMissingCount,
  });

  const _ExternalArchiveKeys.unavailable()
    : available = false,
      recordCount = 0,
      allKeys = const <ArchiveCompatibilityKey>{},
      availableKeys = const <ArchiveCompatibilityKey>{},
      filesAvailableCount = 0,
      filesMissingCount = 0;

  final bool available;
  final int recordCount;
  final Set<ArchiveCompatibilityKey> allKeys;
  final Set<ArchiveCompatibilityKey> availableKeys;
  final int filesAvailableCount;
  final int filesMissingCount;
}

class _RecoveredMessagesKeys {
  const _RecoveredMessagesKeys({
    required this.available,
    required this.recordCount,
    required this.allKeys,
    required this.availableKeys,
  });

  const _RecoveredMessagesKeys.unavailable()
    : available = false,
      recordCount = 0,
      allKeys = const <ArchiveCompatibilityKey>{},
      availableKeys = const <ArchiveCompatibilityKey>{};

  final bool available;
  final int recordCount;
  final Set<ArchiveCompatibilityKey> allKeys;
  final Set<ArchiveCompatibilityKey> availableKeys;
}

class _CurrentSourceAttachmentKeys {
  const _CurrentSourceAttachmentKeys({
    required this.availableKeys,
    required this.pluginPayloadKeys,
  });

  final Set<ArchiveCompatibilityKey> availableKeys;
  final Set<ArchiveCompatibilityKey> pluginPayloadKeys;
}

class _AttachmentRecoveryAudit {
  const _AttachmentRecoveryAudit({
    required this.historicalArchiveAvailable,
    required this.historicalArchiveRecordCount,
    required this.historicalArchiveFilesAvailableCount,
    required this.historicalArchiveFilesMissingCount,
    required this.attachmentsRecoverableFromHistoricalArchiveCount,
    required this.recoveredMessagesSourceAvailable,
    required this.recoveredMessagesAttachmentKeyCount,
    required this.attachmentsRecoverableFromRecoveredMessagesCount,
    required this.attachmentsRecoverableFromBothRecoverySourcesCount,
    required this.attachmentsStillMissingFromKnownRecoverySourcesCount,
    required this.dryRunAlreadyAvailableInCurrentArchiveCount,
    required this.dryRunWouldCopyFromHistoricalArchiveCount,
    required this.dryRunWouldCopyFromRecoveredMessagesCount,
    required this.dryRunWouldArchiveFromCurrentSourcePathCount,
    required this.dryRunStillMissingEverywhereCount,
    required this.dryRunStillMissingPluginPayloadCandidateCount,
    required this.missingAttachmentSamples,
  });

  const _AttachmentRecoveryAudit.skipped()
    : historicalArchiveAvailable = false,
      historicalArchiveRecordCount = 0,
      historicalArchiveFilesAvailableCount = 0,
      historicalArchiveFilesMissingCount = 0,
      attachmentsRecoverableFromHistoricalArchiveCount = 0,
      recoveredMessagesSourceAvailable = false,
      recoveredMessagesAttachmentKeyCount = 0,
      attachmentsRecoverableFromRecoveredMessagesCount = 0,
      attachmentsRecoverableFromBothRecoverySourcesCount = 0,
      attachmentsStillMissingFromKnownRecoverySourcesCount = 0,
      dryRunAlreadyAvailableInCurrentArchiveCount = 0,
      dryRunWouldCopyFromHistoricalArchiveCount = 0,
      dryRunWouldCopyFromRecoveredMessagesCount = 0,
      dryRunWouldArchiveFromCurrentSourcePathCount = 0,
      dryRunStillMissingEverywhereCount = 0,
      dryRunStillMissingPluginPayloadCandidateCount = 0,
      missingAttachmentSamples = const <MissingAttachmentRecoverySample>[];

  final bool historicalArchiveAvailable;
  final int historicalArchiveRecordCount;
  final int historicalArchiveFilesAvailableCount;
  final int historicalArchiveFilesMissingCount;
  final int attachmentsRecoverableFromHistoricalArchiveCount;
  final bool recoveredMessagesSourceAvailable;
  final int recoveredMessagesAttachmentKeyCount;
  final int attachmentsRecoverableFromRecoveredMessagesCount;
  final int attachmentsRecoverableFromBothRecoverySourcesCount;
  final int attachmentsStillMissingFromKnownRecoverySourcesCount;
  final int dryRunAlreadyAvailableInCurrentArchiveCount;
  final int dryRunWouldCopyFromHistoricalArchiveCount;
  final int dryRunWouldCopyFromRecoveredMessagesCount;
  final int dryRunWouldArchiveFromCurrentSourcePathCount;
  final int dryRunStillMissingEverywhereCount;
  final int dryRunStillMissingPluginPayloadCandidateCount;
  final List<MissingAttachmentRecoverySample> missingAttachmentSamples;
}
