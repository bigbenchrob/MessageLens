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
      final country = row['country'] as String?;
      final lastSeenUtc = row['last_seen_utc'] as String?;
      final isIgnored = (row['is_ignored'] as int?) == 1;
      final sourceBatchId = row['batch_id'] as int?;

      if (handleId == null || rawIdentifier == null) {
        continue;
      }

      await workingDb
          .into(workingDb.workingHandles)
          .insert(
            WorkingHandlesCompanion.insert(
              id: Value(handleId), // Preserve chat.db ROWID
              handleId: rawIdentifier,
              normalizedIdentifier: Value(normalizedIdentifier),
              service: Value(service),
              isIgnored: Value(isIgnored),
              isValid: Value(!isIgnored),
              isBlacklisted: Value(isIgnored),
              country: Value(country),
              lastSeenUtc: Value(lastSeenUtc),
              batchId: Value(sourceBatchId),
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
      final createdAtUtc = row['created_at_utc'] as String?;
      final updatedAtUtc = row['updated_at_utc'] as String?;
      final chatIsExplicitlyIgnored = (row['is_ignored'] as int?) == 1;

      if (chatId == null || guid == null) {
        continue;
      }

      // Find chat participant handles (may be multiple)
      final participantRows = await importDb.query(
        'chat_to_handle',
        where: 'chat_id = ?',
        whereArgs: [chatId],
        orderBy: 'handle_id ASC',
      );

      if (participantRows.isEmpty) {
        continue;
      }

      final validParticipants = <_ChatHandleLink>[];

      for (final participantRow in participantRows) {
        final candidateHandleId = participantRow['handle_id'] as int?;
        if (candidateHandleId == null) {
          continue;
        }

        final handleExists = await (workingDb.select(
          workingDb.workingHandles,
        )..where((h) => h.id.equals(candidateHandleId))).getSingleOrNull();

        if (handleExists == null) {
          continue;
        }

        validParticipants.add(
          _ChatHandleLink(
            handleId: candidateHandleId,
            role: (participantRow['role'] as String?) ?? 'member',
            addedAtUtc: participantRow['added_at_utc'] as String?,
            isIgnored: handleExists.isIgnored,
          ),
        );
      }

      if (validParticipants.isEmpty) {
        // No valid handles were associated with this chat for the current batch
        continue;
      }

      final hasActiveParticipants = validParticipants.any(
        (participant) => !participant.isIgnored,
      );
      final effectiveChatIgnored =
          chatIsExplicitlyIgnored || !hasActiveParticipants;

      await workingDb
          .into(workingDb.workingChats)
          .insert(
            WorkingChatsCompanion.insert(
              id: Value(chatId), // Preserve chat.db ROWID
              service: Value(service ?? 'Unknown'),
              guid: guid,
              isGroup: Value(isGroup),
              createdAtUtc: Value(createdAtUtc),
              updatedAtUtc: Value(updatedAtUtc),
              isIgnored: Value(effectiveChatIgnored),
            ),
            mode: InsertMode.insertOrReplace,
          );

      for (final participant in validParticipants) {
        await workingDb
            .into(workingDb.chatToHandle)
            .insert(
              ChatToHandleCompanion.insert(
                chatId: chatId,
                handleId: participant.handleId,
                role: Value(participant.role),
                addedAtUtc: Value(participant.addedAtUtc),
                isIgnored: Value(participant.isIgnored || effectiveChatIgnored),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

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
      final textContent = row['text'] as String?;
      final sentAtUtc = row['date_utc'] as String?;
      final deliveredAtUtc = row['date_delivered_utc'] as String?;
      final readAtUtc = row['date_read_utc'] as String?;
      final isFromMe = (row['is_from_me'] as int?) == 1;
      final itemType = row['item_type'] as String?;
      final isSystemMessage = (row['is_system_message'] as int?) == 1;
      final errorCode = row['error_code'] as int?;
      final associatedMessageGuid = row['associated_message_guid'] as String?;
      final threadOriginatorGuid = row['thread_originator_guid'] as String?;
      final payloadJson = row['payload_json'] as String?;
      final batchIdValue = row['batch_id'] as int?;
      final balloonBundleId = row['balloon_bundle_id'] as String?;
      final reactionCarrier = itemType == 'reaction-carrier';

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
              deliveredAtUtc: Value(deliveredAtUtc),
              readAtUtc: Value(readAtUtc),
              isFromMe: Value(isFromMe),
              itemType: Value(itemType),
              isSystemMessage: Value(isSystemMessage),
              errorCode: Value(errorCode),
              associatedMessageGuid: Value(associatedMessageGuid),
              threadOriginatorGuid: Value(threadOriginatorGuid),
              payloadJson: Value(payloadJson),
              batchId: Value(batchIdValue),
              reactionCarrier: Value(reactionCarrier),
              balloonBundleId: Value(balloonBundleId),
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
      final isOrganization = (row['is_organization'] as int?) == 1;
      final createdAtUtc = row['created_at_utc'] as String?;
      final updatedAtUtc = row['updated_at_utc'] as String?;
      final sourceRecordId = row['source_record_id'] as int?;

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
        isOrganization: isOrganization,
        createdAtUtc: createdAtUtc,
        updatedAtUtc: updatedAtUtc,
        sourceRecordId: sourceRecordId,
      );

      contactsById[contactId] = contact;

      // Load phone numbers for this contact
      final phoneRows = await importDb.query(
        'contact_phone_email',
        where: 'contact_id = ? AND kind = ?',
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
        where: 'contact_id = ? AND kind = ?',
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
      final normalizedHandle = (handle.normalizedIdentifier?.isNotEmpty == true)
          ? handle.normalizedIdentifier
          : _normalizeHandle(handle.handleId);
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
                givenName: Value(contact.firstName),
                familyName: Value(contact.lastName),
                organization: Value(contact.organization),
                isOrganization: Value(contact.isOrganization),
                createdAtUtc: Value(contact.createdAtUtc),
                updatedAtUtc: Value(contact.updatedAtUtc),
                sourceRecordId: Value(contact.sourceRecordId),
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
              isIgnored: Value(true),
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
    this.isOrganization = false,
    this.createdAtUtc,
    this.updatedAtUtc,
    this.sourceRecordId,
  });
  final int id; // AddressBook Z_PK
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? organization;
  final bool isOrganization;
  final String? createdAtUtc;
  final String? updatedAtUtc;
  final int? sourceRecordId;
}

class _ChatHandleLink {
  const _ChatHandleLink({
    required this.handleId,
    required this.role,
    required this.addedAtUtc,
    required this.isIgnored,
  });

  final int handleId;
  final String role;
  final String? addedAtUtc;
  final bool isIgnored;
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
