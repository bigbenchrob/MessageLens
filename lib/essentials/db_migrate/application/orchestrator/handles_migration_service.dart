import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../db_importers/application/debug_settings_provider.dart';
import '../../../search/feature_level_providers.dart';
import '../../domain/base_table_migrator.dart';
import '../../domain/entities/db_migration_result.dart';
import '../../domain/states/db_migration_progress.dart';
import '../../domain/states/table_migration_progress.dart';
import '../../domain/value_objects/db_migration_stage.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';
import '../diagnostics/migration_diagnostics.dart';
import '../migrators/attachments_migrator.dart';
import '../migrators/chat_to_handle_migrator.dart';
import '../migrators/chats_migrator.dart';
import '../migrators/handle_to_participant_migrator.dart';
import '../migrators/handles_migrator.dart';
import '../migrators/message_read_marks_migrator.dart';
import '../migrators/messages_migrator.dart';
import '../migrators/participants_migrator.dart';
import '../migrators/reaction_counts_migrator.dart';
import '../migrators/reactions_migrator.dart';
import '../migrators/read_state_migrator.dart';
import './migration_orchestrator.dart';

class HandlesMigrationService {
  HandlesMigrationService({required this.ref});

  final Ref ref;

  static const String _logContext = 'HandlesMigrationService';
  static const HandlesMigrator _handlesMigrator = HandlesMigrator();
  static const ChatsMigrator _chatsMigrator = ChatsMigrator();
  static const ChatToHandleMigrator _chatToHandleMigrator =
      ChatToHandleMigrator();
  static const ParticipantsMigrator _participantsMigrator =
      ParticipantsMigrator();
  static const HandleToParticipantMigrator _handleToParticipantMigrator =
      HandleToParticipantMigrator();
  static const MessagesMigrator _messagesMigrator = MessagesMigrator();
  static const AttachmentsMigrator _attachmentsMigrator = AttachmentsMigrator();
  static const ReactionsMigrator _reactionsMigrator = ReactionsMigrator();
  static const ReactionCountsMigrator _reactionCountsMigrator =
      ReactionCountsMigrator();
  static const MessageReadMarksMigrator _messageReadMarksMigrator =
      MessageReadMarksMigrator();
  static const ReadStateMigrator _readStateMigrator = ReadStateMigrator();

  Future<DbMigrationResult> run({
    void Function(DbMigrationProgress progress)? onProgress,
    TableMigrationProgressCallback? onTableProgress,
    bool incrementalMode = false,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final importDatabase = await ref.watch(
      sqfliteImportDatabaseProvider.future,
    );
    final workingDatabase = await ref.watch(
      driftWorkingDatabaseProvider.future,
    );

    final context = MigrationContext(
      importDb: importDatabase,
      workingDb: workingDatabase,
      log: debugSettings.logProgress,
      incrementalMode: incrementalMode,
    );

    final migrators = <BaseTableMigrator>[
      _handlesMigrator,
      _chatsMigrator,
      _chatToHandleMigrator,
      _participantsMigrator,
      _handleToParticipantMigrator,
      _messagesMigrator,
      _attachmentsMigrator,
      _reactionsMigrator,
      _reactionCountsMigrator,
      _messageReadMarksMigrator,
      _readStateMigrator,
    ];

    final orchestrator = MigrationOrchestrator(migrators);

    final overrides = await _snapshotHandleOverrides(workingDatabase);
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final handleOverrides = await _snapshotHandleToParticipantOverrides(
      overlayDb,
    );

    const basePhaseWeights = <TableMigrationPhase, double>{
      TableMigrationPhase.validatePrereqs: 0.2,
      TableMigrationPhase.copy: 0.5,
      TableMigrationPhase.postValidate: 0.15,
    };
    final phaseWeights = <TableMigrationPhase, double>{
      for (final entry in basePhaseWeights.entries)
        entry.key: entry.value / migrators.length,
    };

    var completedWeight = 0.15; // after preparation/clearing

    void emitProgress(DbMigrationStage stage, double progress, String message) {
      onProgress?.call(
        DbMigrationProgress(
          stage: stage,
          overallProgress: progress.clamp(0.0, 1.0),
          message: message,
        ),
      );
    }

    DbMigrationProgress progressForTableEvent(
      TableMigrationProgressEvent event,
    ) {
      final phaseLabel = switch (event.phase) {
        TableMigrationPhase.validatePrereqs =>
          'Validating ${event.displayName}',
        TableMigrationPhase.copy => 'Copying ${event.displayName}',
        TableMigrationPhase.postValidate =>
          'Post-validating ${event.displayName}',
      };

      final phaseWeight = phaseWeights[event.phase] ?? 0.0;
      final resolvedStage = event.stage ?? _stageForTable(event.tableName);
      var progressValue = completedWeight;
      switch (event.status) {
        case TableMigrationStatus.started:
          progressValue += phaseWeight * 0.1;
          break;
        case TableMigrationStatus.succeeded:
          completedWeight += phaseWeight;
          progressValue = completedWeight;
          break;
        case TableMigrationStatus.failed:
          break;
      }

      final normalized = min(progressValue, 0.9);
      return DbMigrationProgress(
        stage: resolvedStage,
        overallProgress: normalized,
        message: phaseLabel,
      );
    }

    try {
      emitProgress(
        DbMigrationStage.preparingSources,
        0.05,
        'Preparing identity + message migration',
      );

      // Run diagnostics before migration to help troubleshoot issues
      if (debugSettings.logProgress == print) {
        const diagnostics = MigrationDiagnostics();
        final report = await diagnostics.diagnose(
          importDb: importDatabase,
          workingDb: workingDatabase,
        );
        final formatted = diagnostics.formatReport(report);
        debugSettings.logProgress('\n$formatted');
      }

      emitProgress(
        DbMigrationStage.clearingWorking,
        0.15,
        incrementalMode
            ? 'Preparing incremental migration'
            : 'Clearing identity/message projections',
      );

      await orchestrator.run(
        context,
        onTableProgress: (event) {
          final progressUpdate = progressForTableEvent(event);
          onProgress?.call(progressUpdate);
          onTableProgress?.call(event);
        },
      );

      // Rebuild indexes AFTER all messages are migrated
      // This prevents O(N²) trigger firing during bulk message insert
      emitProgress(DbMigrationStage.indexing, 0.92, 'Building message indexes');
      await workingDatabase.rebuildGlobalMessageIndex();
      await workingDatabase.rebuildMessageIndex();
      await workingDatabase.rebuildContactMessageIndex();

      // Now create the triggers AFTER indexes are built
      await workingDatabase.createMessageIndexTriggers();

      final searchIndexOrchestrator = ref.read(searchIndexOrchestratorProvider);
      await searchIndexOrchestrator.rebuildAll();

      await _restoreHandleOverrides(workingDatabase, overrides);
      await _restoreHandleToParticipantOverrides(
        workingDatabase,
        handleOverrides,
      );

      emitProgress(
        DbMigrationStage.completed,
        1.0,
        'Identity + message migration completed successfully',
      );

      final handlesCount = await _handlesMigrator.count(
        context.workingDb,
        'handles_canonical',
      );
      final chatsCount = await _chatsMigrator.count(context.workingDb, 'chats');
      final chatMembershipCount = await _chatToHandleMigrator.count(
        context.workingDb,
        'chat_to_handle',
      );
      final participantsCount = await _participantsMigrator.count(
        context.workingDb,
        'participants',
      );
      final participantLinksCount = await _handleToParticipantMigrator.count(
        context.workingDb,
        'handle_to_participant',
      );
      final messagesCount = await _messagesMigrator.count(
        context.workingDb,
        'messages',
      );
      final attachmentsCount = await _attachmentsMigrator.count(
        context.workingDb,
        'attachments',
      );
      final reactionsCount = await _reactionsMigrator.count(
        context.workingDb,
        'reactions',
      );
      final latestBatch = await _latestBatchId(await importDatabase.database);

      debugSettings.logProgress(
        '$_logContext: projected chat memberships=$chatMembershipCount '
        'participant links=$participantLinksCount',
      );

      return DbMigrationResult(
        batchId: latestBatch ?? 0,
        success: true,
        identitiesProjected: handlesCount,
        identityHandleLinksProjected: participantLinksCount,
        chatsProjected: chatsCount,
        participantsProjected: participantsCount,
        messagesProjected: messagesCount,
        attachmentsProjected: attachmentsCount,
        reactionsProjected: reactionsCount,
      );
    } catch (error, stackTrace) {
      debugSettings.logError('$_logContext: migration failed: $error');
      debugSettings.logProgress(stackTrace.toString());

      emitProgress(
        DbMigrationStage.completed,
        1.0,
        'Identity + message migration failed: $error',
      );

      return DbMigrationResult(
        batchId: 0,
        success: false,
        error: 'Identity + message migration failed: $error',
      );
    }
  }

  DbMigrationStage _stageForTable(String tableName) {
    switch (tableName) {
      case 'handles':
        return DbMigrationStage.migratingIdentities;
      case 'chats':
      case 'chat_to_handle':
      case 'participants':
      case 'handle_to_participant':
        return DbMigrationStage.migratingChats;
      case 'messages':
      case 'message_read_marks':
      case 'read_state':
        return DbMigrationStage.migratingMessages;
      case 'attachments':
        return DbMigrationStage.migratingAttachments;
      case 'reactions':
      case 'reaction_counts':
        return DbMigrationStage.migratingReactions;
      default:
        return DbMigrationStage.migratingIdentities;
    }
  }

  Future<Map<int, _HandleOverride>> _snapshotHandleOverrides(
    WorkingDatabase db,
  ) async {
    // Read from handles_canonical (was 'handles' before v17)
    final rows = await db
        .customSelect(
          'SELECT id, is_visible, is_blacklisted FROM handles_canonical',
        )
        .get();
    if (rows.isEmpty) {
      return const <int, _HandleOverride>{};
    }

    final overrides = <int, _HandleOverride>{};
    for (final row in rows) {
      final id = row.data['id'] as int?;
      if (id == null) {
        continue;
      }
      final isVisible = (row.data['is_visible'] as int?) == 1;
      final isBlacklisted = (row.data['is_blacklisted'] as int?) == 1;
      overrides[id] = _HandleOverride(
        isVisible: isVisible,
        isBlacklisted: isBlacklisted,
      );
    }
    return overrides;
  }

  Future<void> _restoreHandleOverrides(
    WorkingDatabase db,
    Map<int, _HandleOverride> overrides,
  ) async {
    if (overrides.isEmpty) {
      return;
    }

    await db.batch((batch) {
      overrides.forEach((id, override) {
        batch.update(
          db.handlesCanonical,
          HandlesCanonicalCompanion(
            isVisible: Value(override.isVisible),
            isBlacklisted: Value(override.isBlacklisted),
          ),
          where: (tbl) => tbl.id.equals(id),
        );
      });
    });
  }

  Future<int?> _latestBatchId(Database db) async {
    final rows = await db.query(
      'import_batches',
      columns: <String>['id'],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['id'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }
}

class _HandleOverride {
  const _HandleOverride({required this.isVisible, required this.isBlacklisted});

  final bool isVisible;
  final bool isBlacklisted;
}

class _HandleToParticipantOverride {
  const _HandleToParticipantOverride({
    required this.handleId,
    required this.participantId,
  });

  final int handleId;
  final int participantId;
}

/// Snapshot handle-to-participant overrides from overlay DB
Future<List<_HandleToParticipantOverride>>
_snapshotHandleToParticipantOverrides(OverlayDatabase db) async {
  final rows = await db.getAllHandleOverrides();
  return rows
      .where((row) => row.participantId != null)
      .map(
        (row) => _HandleToParticipantOverride(
          handleId: row.handleId,
          participantId: row.participantId!,
        ),
      )
      .toList();
}

/// Restore handle-to-participant overrides after migration
/// These are user-defined manual links that take precedence over AddressBook
Future<void> _restoreHandleToParticipantOverrides(
  WorkingDatabase db,
  List<_HandleToParticipantOverride> overrides,
) async {
  if (overrides.isEmpty) {
    return;
  }

  // Delete existing AddressBook links for these handles
  // (Manual overrides take precedence)
  final handleIds = overrides.map((o) => o.handleId).toList();
  for (final handleId in handleIds) {
    await (db.delete(db.handleToParticipant)
          ..where((tbl) => tbl.handleId.equals(handleId))
          ..where((tbl) => tbl.source.equals('addressbook')))
        .go();
  }

  // Insert manual override links with source='user_manual'
  for (final override in overrides) {
    await db
        .into(db.handleToParticipant)
        .insert(
          HandleToParticipantCompanion.insert(
            handleId: override.handleId,
            participantId: override.participantId,
            confidence: const Value(1.0),
            source: const Value('user_manual'),
          ),
        );
  }
}
