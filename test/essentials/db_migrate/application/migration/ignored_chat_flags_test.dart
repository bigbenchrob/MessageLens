import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_import/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/feature_level_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'ignored handles and chats propagate to working database flags',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('ledger_test');
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      final ledger = SqfliteImportDatabase(
        databaseDirectory: tempDir.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      addTearDown(() async {
        await ledger.deleteDatabaseFile();
      });

      final workingDb = WorkingDatabase(NativeDatabase.memory());
      await workingDb.customStatement('PRAGMA foreign_keys = ON');
      addTearDown(() async {
        await workingDb.close();
      });

      final batchId = await ledger.insertImportBatch(
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      final ignoredHandleId = await ledger.insertHandle(
        id: 1,
        service: 'iMessage',
        rawIdentifier: 'ignored@example.com',
        batchId: batchId,
      );
      await ledger.flagHandleAsIgnored(ignoredHandleId);

      final activeHandleId = await ledger.insertHandle(
        id: 2,
        service: 'iMessage',
        rawIdentifier: 'active@example.com',
        batchId: batchId,
      );

      final ignoredChatId = await ledger.insertChat(
        id: 1,
        guid: 'chat-ignored-handle',
        service: 'iMessage',
        batchId: batchId,
      );

      final explicitIgnoredChatId = await ledger.insertChat(
        id: 2,
        guid: 'chat-explicit-ignore',
        service: 'iMessage',
        batchId: batchId,
      );
      await ledger.flagChatAsIgnored(explicitIgnoredChatId);

      await ledger.insertChatParticipant(
        chatId: ignoredChatId,
        handleId: ignoredHandleId,
        role: 'member',
      );

      await ledger.insertChatParticipant(
        chatId: explicitIgnoredChatId,
        handleId: activeHandleId,
        role: 'member',
      );

      final container = ProviderContainer(
        overrides: [
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
          sqfliteImportDatabaseProvider.overrideWith((ref) async => ledger),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(ledgerToWorkingMigrationServiceProvider);

      final result = await service.runMigration();
      expect(result.success, isTrue);

      final migratedChats = await workingDb
          .select(workingDb.workingChats)
          .get();
      final chatsById = {for (final chat in migratedChats) chat.id: chat};

      final ignoredChat = chatsById[ignoredChatId];
      expect(ignoredChat, isNotNull);
      expect(ignoredChat!.isIgnored, isTrue);

      final explicitIgnoredChat = chatsById[explicitIgnoredChatId];
      expect(explicitIgnoredChat, isNotNull);
      expect(explicitIgnoredChat!.isIgnored, isTrue);

      final linkRows = await workingDb.select(workingDb.chatToHandle).get();
      final ignoredChatLink = linkRows.singleWhere(
        (link) => link.chatId == ignoredChatId,
      );
      expect(ignoredChatLink.isIgnored, isTrue);

      final explicitChatLink = linkRows.singleWhere(
        (link) => link.chatId == explicitIgnoredChatId,
      );
      expect(explicitChatLink.isIgnored, isTrue);
    },
  );
}
