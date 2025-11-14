import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/global_timeline_controller.dart';

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

  Future<void> seedMessages(int count) async {
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-global')));

    for (var i = 0; i < count; i++) {
      await db.into(db.workingMessages).insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-$i',
              chatId: chatId,
              sentAtUtc: Value('2024-01-01T0${i % 10}:00:00Z'),
            ),
          );
    }

    await db.rebuildGlobalMessageIndex();
  }

  test('initial load returns first page', () async {
    await seedMessages(5);

    final provider = globalTimelineControllerProvider(pageSize: 2);
    final state = await container.read(provider.future);

    expect(state.totalCount, 5);
    expect(state.items.length, 2);
    expect(state.hasMoreAfter, isTrue);
    expect(state.hasMoreBefore, isFalse);
  });

  test('loadMoreAfter appends additional entries', () async {
    await seedMessages(5);

    final provider = globalTimelineControllerProvider(pageSize: 2);
    await container.read(provider.future);

    final notifier = container.read(provider.notifier);
    await notifier.loadMoreAfter();

    final state = container.read(provider).value;
    expect(state?.items.length, 4);
    expect(state?.hasMoreAfter, isTrue);

    await notifier.loadMoreAfter();
    final finalState = container.read(provider).value;
    expect(finalState?.items.length, 5);
    expect(finalState?.hasMoreAfter, isFalse);
  });

  test('loadMoreBefore prepends entries when starting near end', () async {
    await seedMessages(5);

    final provider = globalTimelineControllerProvider(
      pageSize: 2,
      startAfterOrdinal: 2,
    );
    await container.read(provider.future);

    final notifier = container.read(provider.notifier);
    final initial = container.read(provider).value;
    expect(initial?.hasMoreBefore, isTrue);

    await notifier.loadMoreBefore();

    final updated = container.read(provider).value;
    expect(updated?.items.first.ordinal, 1);
    expect(updated?.items.length, 4);
    expect(updated?.hasMoreBefore, isTrue);

    await notifier.loadMoreBefore();
    final fullState = container.read(provider).value;
    expect(fullState?.items.first.ordinal, 0);
    expect(fullState?.hasMoreBefore, isFalse);
  });

  test('refresh reloads initial cursor window', () async {
    await seedMessages(5);

    final provider = globalTimelineControllerProvider(pageSize: 2);
    await container.read(provider.future);

    final notifier = container.read(provider.notifier);
    await notifier.loadMoreAfter();
    expect(container.read(provider).value?.items.length, 4);

    await notifier.refresh();
    final refreshed = container.read(provider).value;
    expect(refreshed?.items.length, 2);
    expect(refreshed?.hasMoreAfter, isTrue);
  });

  test('loadMoreAfter ignores calls when no more data', () async {
    await seedMessages(2);

    final provider = globalTimelineControllerProvider(pageSize: 2);
    await container.read(provider.future);

    final notifier = container.read(provider.notifier);
    await notifier.loadMoreAfter();

    final state = container.read(provider).value;
    expect(state?.items.length, 2);
    expect(state?.hasMoreAfter, isFalse);
  });
}
