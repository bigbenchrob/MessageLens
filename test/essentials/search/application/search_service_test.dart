import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/search/feature_level_providers.dart';
import 'package:remember_this_text/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late WorkingDatabase db;
  late SharedPreferences prefs;
  late ProviderContainer container;

  ProviderContainer createContainer({bool enableFts = false}) {
    final overrides = <Override>[
      driftWorkingDatabaseProvider.overrideWith((ref) async => db),
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ];
    if (enableFts) {
      overrides.add(useFtsSearchByDefaultProvider.overrideWith((ref) => true));
    }
    return ProviderContainer(overrides: overrides);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = WorkingDatabase(NativeDatabase.memory());
    prefs = await SharedPreferences.getInstance();
    container = createContainer();
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  test('searchChatMessageIds returns matching message IDs', () async {
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-1')));

    final msgId1 = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-1',
            chatId: chatId,
            textContent: const Value('Hello Modular Search'),
            sentAtUtc: const Value('2024-01-01T00:00:00Z'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-2',
            chatId: chatId,
            textContent: const Value('Other content'),
            sentAtUtc: const Value('2024-01-01T00:10:00Z'),
          ),
        );

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchChatMessageIds(
      chatId: chatId,
      query: 'modular',
    );

    expect(resultIds, hasLength(1));
    expect(resultIds.first, equals(msgId1));
  });

  test('searchContactMessageIds returns results via contact index', () async {
    const contactId = 1;
    await db
        .into(db.workingParticipants)
        .insert(
          const WorkingParticipantsCompanion(
            id: Value(contactId),
            originalName: Value('Test User'),
            displayName: Value('Test User'),
            shortName: Value('Test'),
          ),
        );
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-2')));
    final messageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-contact',
            chatId: chatId,
            textContent: const Value('Contact specific search'),
            sentAtUtc: const Value('2024-01-02T00:00:00Z'),
          ),
        );
    await db
        .into(db.contactMessageIndex)
        .insert(
          ContactMessageIndexCompanion.insert(
            contactId: contactId,
            ordinal: 0,
            messageId: messageId,
            monthKey: '2024-01',
            sentAtUtc: const Value('2024-01-02T00:00:00Z'),
          ),
        );

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchContactMessageIds(
      contactId: contactId,
      query: 'specific',
    );

    expect(resultIds, hasLength(1));
    expect(resultIds.first, equals(messageId));
  });

  test('fts multi-term search returns matching IDs', () async {
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-fts')));
    final msgId1 = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'fts-1',
            chatId: chatId,
            textContent: const Value('hello world modular indexing'),
            sentAtUtc: const Value('2024-01-03T00:00:00Z'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'fts-2',
            chatId: chatId,
            textContent: const Value('hello'),
            sentAtUtc: const Value('2024-01-02T00:00:00Z'),
          ),
        );

    final ftsContainer = createContainer(enableFts: true);
    final service = ftsContainer.read(searchServiceProvider);

    final resultIds = await service.searchChatMessageIds(
      chatId: chatId,
      query: 'hello world',
    );

    expect(resultIds, hasLength(1));
    expect(resultIds.first, equals(msgId1));
    ftsContainer.dispose();
  });

  test('fts search respects contact filter', () async {
    const contactId = 99;
    await db
        .into(db.workingParticipants)
        .insert(
          const WorkingParticipantsCompanion(
            id: Value(contactId),
            originalName: Value('Contact FTS'),
            displayName: Value('Contact FTS'),
            shortName: Value('Contact'),
          ),
        );
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-contact')));
    final firstId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'contact-fts',
            chatId: chatId,
            textContent: const Value('searchable term contact'),
            sentAtUtc: const Value('2024-01-04T00:00:00Z'),
          ),
        );
    await db
        .into(db.contactMessageIndex)
        .insert(
          ContactMessageIndexCompanion.insert(
            contactId: contactId,
            ordinal: 0,
            messageId: firstId,
            monthKey: '2024-01',
            sentAtUtc: const Value('2024-01-04T00:00:00Z'),
          ),
        );

    final ftsContainer = createContainer(enableFts: true);
    final service = ftsContainer.read(searchServiceProvider);
    final resultIds = await service.searchContactMessageIds(
      contactId: contactId,
      query: 'searchable term',
    );
    expect(resultIds, hasLength(1));
    expect(resultIds.first, equals(firstId));
    ftsContainer.dispose();
  });
}
