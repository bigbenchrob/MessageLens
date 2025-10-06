import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../db_import/application/debug_settings_provider.dart';
import '../../domain/entities/db_migration_result.dart';
import '../../domain/states/db_migration_progress.dart';
import '../../domain/value_objects/db_migration_stage.dart';

typedef DbMigrationProgressCallback =
    void Function(DbMigrationProgress progress);

/// Clean, simplified import service following the new participant-handle architecture.
///
/// Architecture principles:
/// - Participants are people (from AddressBook)
/// - Handles are communication endpoints (from chat.db)
/// - Services belong to chats, not participants
/// - handle_to_participant links them with confidence/source tracking
///
/// Import phases:
/// 1. Import handles from chat.db (preserve ROWIDs)
/// 2. Import chats/messages with handle FKs
/// 3. Match handles to AddressBook contacts
/// 4. Create participants (preserve AddressBook Z_PKs)
/// 5. Create handle_to_participant links
/// 6. Validate and blacklist spam handles
class NewLedgerToWorkingMigrationService {
  NewLedgerToWorkingMigrationService({required this.ref});

  final Ref ref;
  static const String _logContext = 'NewLedgerToWorkingMigrationService';

  /// Clears all working database tables for a fresh import.
  /// This is called by the import control UI when users want to clear existing data.
  Future<void> clearWorkingProjection() async {
    final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
    await _clearWorkingDatabase(workingDb);
  }

  Future<DbMigrationResult> runMigration({
    DbMigrationProgressCallback? onProgress,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final ledger = await ref.watch(sqfliteImportDatabaseProvider.future);
    final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

    final importDb = await ledger.database;
    final resultBuilder = _DbMigrationResultBuilder();

    void emit(DbMigrationStage stage, double progress, String message) {
      onProgress?.call(
        DbMigrationProgress(
          stage: stage,
          overallProgress: progress,
          message: message,
        ),
      );
      debugSettings.logProgress('$_logContext: $message');
    }

    try {
      emit(
        DbMigrationStage.preparingSources,
        0.02,
        'Locating latest import batch',
      );

      final batchId = await _fetchLatestBatchId(importDb);
      if (batchId == null) {
        const message = 'Ledger contains no import batches to project';
        debugSettings.logError('$_logContext: $message');
        return _DbMigrationResultBuilder().build(
          success: false,
          error: message,
          batchId: 0,
        );
      }

      emit(
        DbMigrationStage.preparingSources,
        0.05,
        'Clearing existing working data',
      );
      await _clearWorkingDatabase(workingDb);

      emit(
        DbMigrationStage.migratingIdentities,
        0.10,
        'Phase 1: Importing handles from chat.db',
      );
      await _importHandles(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
      );
      // Handles are internal to the migration - no external count tracking needed

      emit(
        DbMigrationStage.migratingChats,
        0.25,
        'Phase 1: Importing chats with handle references',
      );
      final chatResult = await _importChats(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
      );
      resultBuilder.chatsProjected = chatResult.chatCount;

      emit(
        DbMigrationStage.migratingMessages,
        0.40,
        'Phase 1: Importing messages with handle references',
      );
      final messageResult = await _importMessages(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
      );
      resultBuilder.messagesProjected = messageResult.messageCount;

      emit(
        DbMigrationStage.loadingContacts,
        0.60,
        'Phase 2: Loading AddressBook contacts',
      );
      final contactIndex = await _loadContacts(
        importDb: importDb,
        batchId: batchId,
      );

      emit(
        DbMigrationStage.migratingIdentities,
        0.75,
        'Phase 2: Matching handles to contacts and creating participants',
      );
      final participantResult = await _matchAndCreateParticipants(
        workingDb: workingDb,
        contactIndex: contactIndex,
      );
      resultBuilder.participantsProjected = participantResult.participantCount;
      resultBuilder.identityHandleLinksProjected = participantResult.linkCount;

      emit(
        DbMigrationStage.migratingIdentities,
        0.90,
        'Phase 3: Validating handles and filtering spam',
      );
      await _validateAndFilterSpam(workingDb: workingDb);
      // Spam filtering is internal to migration - count not tracked externally

      emit(
        DbMigrationStage.updatingProjectionState,
        0.95,
        'Updating projection state',
      );
      await _updateProjectionState(workingDb: workingDb, batchId: batchId);

      emit(DbMigrationStage.completed, 1.0, 'Migration completed successfully');

      return resultBuilder.build(success: true, batchId: batchId);
    } catch (e, stackTrace) {
      debugSettings.logError('$_logContext: Migration failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return _DbMigrationResultBuilder().build(
        success: false,
        batchId: 0,
        error: 'Migration failed: $e',
      );
    }
  }

  Future<int?> _fetchLatestBatchId(Database importDb) async {
    final result = await importDb.query(
      'import_batches',
      columns: ['id'],
      orderBy: 'id DESC',
      limit: 1,
    );
    return result.isEmpty ? null : result.first['id'] as int?;
  }

  Future<void> _clearWorkingDatabase(WorkingDatabase workingDb) async {
    // Clear all working data to ensure clean import
    await workingDb.customStatement('DELETE FROM handle_to_participant');
    await workingDb.customStatement('DELETE FROM participants');
    await workingDb.customStatement('DELETE FROM reactions');
    await workingDb.customStatement('DELETE FROM attachments');
    await workingDb.customStatement('DELETE FROM messages');
    await workingDb.customStatement('DELETE FROM chats');
    await workingDb.customStatement('DELETE FROM handles');
  }

  /// Phase 1: Import handles from chat.db, preserving ROWIDs
  Future<_HandleImportResult> _importHandles({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    final rows = await importDb.query(
      'handles',
      where: 'batch_id = ?',
      whereArgs: [batchId],
    );

    var handleCount = 0;

    for (final row in rows) {
      final handleId = row['id'] as int?;
      final service = (row['service'] as String?) ?? 'Unknown';
      final rawIdentifier = row['raw_identifier'] as String?;
      final normalizedIdentifier = row['normalized_identifier'] as String?;

      if (handleId == null || rawIdentifier == null) {
        continue;
      }

      // Use normalized identifier if available, otherwise raw identifier
      final handleIdentifier = normalizedIdentifier?.isNotEmpty == true
          ? normalizedIdentifier!
          : rawIdentifier;

      await workingDb
          .into(workingDb.workingHandles)
          .insert(
            WorkingHandlesCompanion.insert(
              id: Value(handleId), // Preserve chat.db ROWID
              handleId: handleIdentifier,
              service: Value(service),
              isValid: const Value(true),
              isBlacklisted: const Value(false),
            ),
            mode: InsertMode.insertOrReplace,
          );

      handleCount++;
    }

    return _HandleImportResult(handleCount: handleCount);
  }

  /// Phase 1: Import chats and determine primary handle from participants
  Future<_ChatImportResult> _importChats({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    final rows = await importDb.query(
      'chats',
      where: 'batch_id = ?',
      whereArgs: [batchId],
    );

    var chatCount = 0;

    for (final row in rows) {
      final chatId = row['id'] as int?;
      final service = row['service'] as String?;
      final guid = row['guid'] as String?;
      final isGroup = (row['is_group'] as int?) == 1;

      if (chatId == null || guid == null) {
        continue;
      }

      // Find the primary handle for this chat from chat_to_handle
      final participantRows = await importDb.query(
        'chat_to_handle',
        where: 'chat_id = ?',
        whereArgs: [chatId],
        limit: 1, // Use first participant as primary handle
      );

      int? primaryHandleId;
      if (participantRows.isNotEmpty) {
        primaryHandleId = participantRows.first['handle_id'] as int?;
      }

      // Skip if no participants or primary handle doesn't exist in working DB
      if (primaryHandleId == null) {
        continue;
      }

      final handleIdValue = primaryHandleId;

      final handleExists = await (workingDb.select(
        workingDb.workingHandles,
      )..where((h) => h.id.equals(handleIdValue))).get();

      if (handleExists.isEmpty) {
        // Skip this chat if the primary handle doesn't exist (was filtered as spam)
        continue;
      }

      await workingDb
          .into(workingDb.workingChats)
          .insert(
            WorkingChatsCompanion.insert(
              id: Value(chatId), // Preserve chat.db ROWID
              service: Value(service ?? 'Unknown'),
              guid: guid,
              isGroup: Value(isGroup),
            ),
            mode: InsertMode.insertOrReplace,
          );

      // Create chat_to_handle relationship for the primary handle
      await workingDb
          .into(workingDb.chatToHandle)
          .insert(
            ChatToHandleCompanion.insert(
              chatId: chatId,
              handleId: primaryHandleId,
            ),
            mode: InsertMode.insertOrIgnore,
          );

      chatCount++;
    }

    return _ChatImportResult(chatCount: chatCount);
  }

  /// Phase 1: Import messages with sender_handle_id foreign keys
  Future<_MessageImportResult> _importMessages({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    final rows = await importDb.query(
      'messages',
      where: 'batch_id = ?',
      whereArgs: [batchId],
    );

    var messageCount = 0;

    for (final row in rows) {
      final messageId = row['id'] as int?;
      final chatId = row['chat_id'] as int?;
      final senderHandleId = row['sender_handle_id'] as int?; // FK to handles
      final guid = row['guid'] as String?;
      final textContent = row['text_content'] as String?;
      final sentAtUtc = row['sent_at_utc'] as String?;
      final isFromMe = (row['is_from_me'] as int?) == 1;

      if (messageId == null || chatId == null || guid == null) {
        continue;
      }

      // Check if the chat exists before inserting the message
      final chatExists = await (workingDb.select(
        workingDb.workingChats,
      )..where((c) => c.id.equals(chatId))).get();

      if (chatExists.isEmpty) {
        // Skip this message if the chat doesn't exist (was filtered out)
        continue;
      }

      // Validate sender handle exists if provided (set to NULL if not)
      var validatedSenderHandleId = senderHandleId;
      if (senderHandleId != null) {
        final handleExists = await (workingDb.select(
          workingDb.workingHandles,
        )..where((h) => h.id.equals(senderHandleId))).get();

        if (handleExists.isEmpty) {
          validatedSenderHandleId = null; // Set to NULL if handle doesn't exist
        }
      }

      await workingDb
          .into(workingDb.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              id: Value(messageId), // Preserve chat.db ROWID
              chatId: chatId,
              senderHandleId: Value(
                validatedSenderHandleId,
              ), // FK to WorkingHandles
              guid: guid,
              textContent: Value(textContent),
              sentAtUtc: Value(sentAtUtc),
              isFromMe: Value(isFromMe),
            ),
            mode: InsertMode.insertOrReplace,
          );

      messageCount++;
    }

    return _MessageImportResult(messageCount: messageCount);
  }

  /// Phase 2: Load AddressBook contacts for matching
  Future<_ContactIndex> _loadContacts({
    required Database importDb,
    required int batchId,
  }) async {
    final contactRows = await importDb.query(
      'contacts',
      where: 'batch_id = ?',
      whereArgs: [batchId],
    );

    final contactsById = <int, _Contact>{};
    final normalizedToContactId = <String, int>{};

    for (final row in contactRows) {
      final contactId = row['id'] as int?; // AddressBook Z_PK
      final firstName = row['given_name'] as String?;
      final lastName = row['family_name'] as String?;
      final organization = row['organization'] as String?;

      if (contactId == null) {
        continue;
      }

      // Build display name from available fields
      final displayName = _buildDisplayName(
        firstName: firstName,
        lastName: lastName,
        organization: organization,
      );

      final contact = _Contact(
        id: contactId,
        displayName: displayName,
        firstName: firstName,
        lastName: lastName,
        organization: organization,
      );

      contactsById[contactId] = contact;

      // Load phone numbers for this contact
      final phoneRows = await importDb.query(
        'contact_phone_email',
        where: 'OWNER_Z_PK = ? AND kind = ?',
        whereArgs: [contactId, 'phone'],
      );

      for (final phoneRow in phoneRows) {
        final phoneNumber = phoneRow['value'] as String?;
        if (phoneNumber?.isNotEmpty == true) {
          final normalized = _normalizePhoneNumber(phoneNumber!);
          if (normalized != null) {
            normalizedToContactId[normalized] = contactId;
          }
        }
      }

      // Load email addresses for this contact
      final emailRows = await importDb.query(
        'contact_phone_email',
        where: 'OWNER_Z_PK = ? AND kind = ?',
        whereArgs: [contactId, 'email'],
      );

      for (final emailRow in emailRows) {
        final email = emailRow['value'] as String?;
        if (email?.isNotEmpty == true) {
          final normalized = _normalizeEmail(email!);
          if (normalized != null) {
            normalizedToContactId[normalized] = contactId;
          }
        }
      }
    }

    return _ContactIndex(
      contactsById: contactsById,
      normalizedToContactId: normalizedToContactId,
    );
  }

  /// Phase 2: Match handles to AddressBook contacts and create participants
  Future<_ParticipantMatchResult> _matchAndCreateParticipants({
    required WorkingDatabase workingDb,
    required _ContactIndex contactIndex,
  }) async {
    final handles = await workingDb.select(workingDb.workingHandles).get();
    final createdParticipants = <int>{};
    var participantCount = 0;
    var linkCount = 0;

    for (final handle in handles) {
      // Try to match handle to AddressBook contact
      final normalizedHandle = _normalizeHandle(handle.handleId);
      final matchedContactId = normalizedHandle != null
          ? contactIndex.normalizedToContactId[normalizedHandle]
          : null;

      // Create participant if matched and not already created
      if (matchedContactId != null &&
          !createdParticipants.contains(matchedContactId)) {
        final contact = contactIndex.contactsById[matchedContactId]!;

        await workingDb
            .into(workingDb.workingParticipants)
            .insert(
              WorkingParticipantsCompanion.insert(
                id: Value(matchedContactId), // Use AddressBook Z_PK
                originalName: contact.displayName,
                displayName: contact.displayName,
                shortName: _buildShortName(contact),
              ),
              mode: InsertMode.insertOrIgnore,
            );

        createdParticipants.add(matchedContactId);
        participantCount++;
      }

      // Create handle-to-participant link if match exists
      if (matchedContactId != null &&
          createdParticipants.contains(matchedContactId)) {
        await workingDb
            .into(workingDb.handleToParticipant)
            .insert(
              HandleToParticipantCompanion.insert(
                handleId: handle.id,
                participantId: matchedContactId,
                confidence: const Value(
                  1.0,
                ), // AddressBook match = perfect confidence
                source: const Value('addressbook'),
              ),
              mode: InsertMode.insertOrIgnore,
            );

        linkCount++;
      }
    }

    return _ParticipantMatchResult(
      participantCount: participantCount,
      linkCount: linkCount,
    );
  }

  /// Phase 3: Validate handles and blacklist spam
  Future<_SpamFilterResult> _validateAndFilterSpam({
    required WorkingDatabase workingDb,
  }) async {
    final handles = await workingDb.select(workingDb.workingHandles).get();
    var blacklistedCount = 0;

    for (final handle in handles) {
      // Check if handle has a participant (meaning it matched AddressBook)
      final hasParticipant =
          await (workingDb.select(workingDb.handleToParticipant)
                ..where((htp) => htp.handleId.equals(handle.id)))
              .getSingleOrNull() !=
          null;

      if (!hasParticipant) {
        // Handle has no participant - validate format
        final isValidFormat = _isValidHandleFormat(handle.handleId);

        if (!isValidFormat) {
          // Mark as blacklisted (spam)
          await (workingDb.update(
            workingDb.workingHandles,
          )..where((h) => h.id.equals(handle.id))).write(
            const WorkingHandlesCompanion(
              isBlacklisted: Value(true),
              isValid: Value(false),
            ),
          );

          blacklistedCount++;
        }
      }
    }

    return _SpamFilterResult(blacklistedCount: blacklistedCount);
  }

  Future<void> _updateProjectionState({
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    // Update projection state to track successful import
    await workingDb
        .into(workingDb.projectionState)
        .insert(
          ProjectionStateCompanion.insert(
            lastImportBatchId: Value(batchId),
            lastProjectedAtUtc: Value(DateTime.now().toUtc().toIso8601String()),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  // Helper methods for normalization and validation

  String _buildDisplayName({
    String? firstName,
    String? lastName,
    String? organization,
  }) {
    final parts = <String>[];
    if (firstName?.isNotEmpty == true) {
      parts.add(firstName!);
    }
    if (lastName?.isNotEmpty == true) {
      parts.add(lastName!);
    }

    if (parts.isNotEmpty) {
      return parts.join(' ');
    }

    if (organization?.isNotEmpty == true) {
      return organization!;
    }

    return 'Unknown Contact';
  }

  String _buildShortName(_Contact contact) {
    if (contact.firstName?.isNotEmpty == true) {
      return contact.firstName!;
    }

    if (contact.organization?.isNotEmpty == true) {
      return contact.organization!;
    }

    return contact.displayName;
  }

  String? _normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digits
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Must have at least 7 digits to be valid
    if (digits.length < 7) {
      return null;
    }

    // Return normalized format
    return '+$digits';
  }

  String? _normalizeEmail(String email) {
    // Basic email validation and normalization
    final normalized = email.toLowerCase().trim();

    // Must contain @ and basic structure
    if (!normalized.contains('@') || normalized.length < 5) {
      return null;
    }

    return normalized;
  }

  String? _normalizeHandle(String handle) {
    // Try phone number normalization first
    final phone = _normalizePhoneNumber(handle);
    if (phone != null) {
      return phone;
    }

    // Try email normalization
    final email = _normalizeEmail(handle);
    if (email != null) {
      return email;
    }

    // Return null if neither format matches
    return null;
  }

  bool _isValidHandleFormat(String handle) {
    // Check if it's a valid phone number or email
    return _normalizePhoneNumber(handle) != null ||
        _normalizeEmail(handle) != null;
  }
}

// Result classes for tracking import progress

class _HandleImportResult {
  const _HandleImportResult({required this.handleCount});
  final int handleCount;
}

class _ChatImportResult {
  const _ChatImportResult({required this.chatCount});
  final int chatCount;
}

class _MessageImportResult {
  const _MessageImportResult({required this.messageCount});
  final int messageCount;
}

class _ParticipantMatchResult {
  const _ParticipantMatchResult({
    required this.participantCount,
    required this.linkCount,
  });
  final int participantCount;
  final int linkCount;
}

class _SpamFilterResult {
  const _SpamFilterResult({required this.blacklistedCount});
  final int blacklistedCount;
}

class _ContactIndex {
  const _ContactIndex({
    required this.contactsById,
    required this.normalizedToContactId,
  });
  final Map<int, _Contact> contactsById;
  final Map<String, int> normalizedToContactId;
}

class _Contact {
  const _Contact({
    required this.id,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.organization,
  });
  final int id; // AddressBook Z_PK
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? organization;
}

class _DbMigrationResultBuilder {
  int chatsProjected = 0;
  int messagesProjected = 0;
  int identitiesProjected = 0;
  int identityHandleLinksProjected = 0;
  int participantsProjected = 0;

  DbMigrationResult build({
    required bool success,
    required int batchId,
    String? error,
  }) {
    return DbMigrationResult(
      success: success,
      error: error,
      batchId: batchId,
      chatsProjected: chatsProjected,
      messagesProjected: messagesProjected,
      identitiesProjected: identitiesProjected,
      identityHandleLinksProjected: identityHandleLinksProjected,
      participantsProjected: participantsProjected,
    );
  }
}
