import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/messages/application/use_cases/global_message_timeline_provider.dart';

void main() {
  late WorkingDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = WorkingDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');

    container = ProviderContainer(
      overrides: [driftWorkingDatabaseProvider.overrideWith((ref) async => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> seedMessages() async {
    final chatA = await db
        .into(db.workingChats)
        .insert(WorkingChatsCompanion.insert(guid: 'chat-a'));
    final chatB = await db
        .into(db.workingChats)
        .insert(WorkingChatsCompanion.insert(guid: 'chat-b'));

    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-1',
            chatId: chatA,
            sentAtUtc: const Value('2024-01-01T09:00:00Z'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-2',
            chatId: chatB,
            sentAtUtc: const Value('2024-01-01T10:00:00Z'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-3',
            chatId: chatA,
            sentAtUtc: const Value('2024-01-01T11:00:00Z'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-4',
            chatId: chatB,
            sentAtUtc: const Value('2024-01-01T12:00:00Z'),
          ),
        );

    await db.rebuildGlobalMessageIndex();
  }

  test('returns empty page when no messages exist', () async {
    final page = await container.read(globalMessageTimelineProvider().future);

    expect(page.totalCount, 0);
    expect(page.items, isEmpty);
    expect(page.hasMoreBefore, isFalse);
    expect(page.hasMoreAfter, isFalse);
  });

  test('fetches first page with default limit', () async {
    await seedMessages();

    final page = await container.read(
      globalMessageTimelineProvider(pageSize: 2).future,
    );

    expect(page.totalCount, 4);
    expect(page.items.map((e) => e.ordinal), [0, 1]);
    expect(page.hasMoreBefore, isFalse);
    expect(page.hasMoreAfter, isTrue);
  });

  test('fetches page after cursor', () async {
    await seedMessages();

    final page = await container.read(
      globalMessageTimelineProvider(startAfterOrdinal: 1, pageSize: 2).future,
    );

    expect(page.items.map((e) => e.ordinal), [2, 3]);
    expect(page.hasMoreBefore, isTrue);
    expect(page.hasMoreAfter, isFalse);
  });

  test('fetches page before cursor in ascending order', () async {
    await seedMessages();

    final page = await container.read(
      globalMessageTimelineProvider(endBeforeOrdinal: 3, pageSize: 2).future,
    );

    expect(page.items.map((e) => e.ordinal), [1, 2]);
    expect(page.hasMoreBefore, isTrue);
    expect(page.hasMoreAfter, isTrue);
  });

  test('throws when both cursors are provided', () async {
    await seedMessages();

    expect(
      () => container.read(
        globalMessageTimelineProvider(
          startAfterOrdinal: 1,
          endBeforeOrdinal: 2,
        ).future,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
