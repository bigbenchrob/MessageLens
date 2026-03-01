import 'dart:async';

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
import '../../domain/states/table_migration_progress.dart';
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

typedef MigrationExecutionPlanCallback =
    void Function(List<MigratorStep> steps);

class HandlesMigrationService {
  HandlesMigrationService({required this.ref});

  final Ref ref;

  static const String _logContext = 'HandlesMigrationService';
  static final HandlesMigrator _handlesMigrator = HandlesMigrator();
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

  /// Names of synthetic (non-orchestrated) post-migration steps.
  static const String _rebuildIndexesStep = 'rebuild_indexes';
  static const String _rebuildSearchStep = 'rebuild_search';
  static const String _restoreOverridesStep = 'restore_overrides';

  Future<DbMigrationResult> run({
    MigrationExecutionPlanCallback? onExecutionPlan,
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

    final context = MigrationContextSqlite(
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

    // Communicate the execution plan to the UI before running.
    // The plan includes orchestrated migrators plus post-migration steps.
    final orchestratorSteps = orchestrator.executionOrder();
    final postStepBase = orchestratorSteps.length;
    final allSteps = <MigratorStep>[
      ...orchestratorSteps,
      MigratorStep(
        index: postStepBase,
        name: _rebuildIndexesStep,
        displayName: 'Rebuild Indexes',
      ),
      MigratorStep(
        index: postStepBase + 1,
        name: _rebuildSearchStep,
        displayName: 'Rebuild Search',
      ),
      MigratorStep(
        index: postStepBase + 2,
        name: _restoreOverridesStep,
        displayName: 'Restore Overrides',
      ),
    ];
    onExecutionPlan?.call(allSteps);

    final overrides = await _snapshotHandleOverrides(workingDatabase);
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final handleOverrides = await _snapshotHandleToParticipantOverrides(
      overlayDb,
    );

    try {
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

      await orchestrator.run(context, onTableProgress: onTableProgress);

      // --- Post-orchestrator synthetic steps ---

      // Rebuild indexes
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildIndexesStep,
        'Rebuild Indexes',
        TableMigrationPhase.validatePrereqs,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildIndexesStep,
        'Rebuild Indexes',
        TableMigrationPhase.copy,
        TableMigrationStatus.started,
      );
      await Future<void>.delayed(Duration.zero);

      await workingDatabase.rebuildGlobalMessageIndex();
      await workingDatabase.rebuildMessageIndex();
      await workingDatabase.rebuildContactMessageIndex();
      await workingDatabase.createMessageIndexTriggers();

      _emitSyntheticEvent(
        onTableProgress,
        _rebuildIndexesStep,
        'Rebuild Indexes',
        TableMigrationPhase.copy,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildIndexesStep,
        'Rebuild Indexes',
        TableMigrationPhase.postValidate,
        TableMigrationStatus.succeeded,
      );

      // Rebuild search indexes
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildSearchStep,
        'Rebuild Search',
        TableMigrationPhase.validatePrereqs,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildSearchStep,
        'Rebuild Search',
        TableMigrationPhase.copy,
        TableMigrationStatus.started,
      );
      await Future<void>.delayed(Duration.zero);

      final searchIndexOrchestrator = ref.read(searchIndexOrchestratorProvider);
      await searchIndexOrchestrator.rebuildAll();

      _emitSyntheticEvent(
        onTableProgress,
        _rebuildSearchStep,
        'Rebuild Search',
        TableMigrationPhase.copy,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildSearchStep,
        'Rebuild Search',
        TableMigrationPhase.postValidate,
        TableMigrationStatus.succeeded,
      );

      // Restore user overrides
      _emitSyntheticEvent(
        onTableProgress,
        _restoreOverridesStep,
        'Restore Overrides',
        TableMigrationPhase.validatePrereqs,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _restoreOverridesStep,
        'Restore Overrides',
        TableMigrationPhase.copy,
        TableMigrationStatus.started,
      );
      await Future<void>.delayed(Duration.zero);

      await _restoreHandleOverrides(workingDatabase, overrides);
      await _restoreHandleToParticipantOverrides(
        workingDatabase,
        handleOverrides,
      );

      _emitSyntheticEvent(
        onTableProgress,
        _restoreOverridesStep,
        'Restore Overrides',
        TableMigrationPhase.copy,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _restoreOverridesStep,
        'Restore Overrides',
        TableMigrationPhase.postValidate,
        TableMigrationStatus.succeeded,
      );

      // Gather final counts for the result
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

      return DbMigrationResult(
        batchId: 0,
        success: false,
        error: 'Identity + message migration failed: $error',
      );
    }
  }

  void _emitSyntheticEvent(
    TableMigrationProgressCallback? onTableProgress,
    String name,
    String displayName,
    TableMigrationPhase phase,
    TableMigrationStatus status,
  ) {
    onTableProgress?.call(
      TableMigrationProgressEvent(
        tableName: name,
        displayName: displayName,
        phase: phase,
        status: status,
      ),
    );
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
