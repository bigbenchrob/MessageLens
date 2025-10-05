import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/settings/application/message_annotations/message_annotations_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late OverlayDatabase testDb;

  setUp(() {
    // Create in-memory database for testing
    testDb = OverlayDatabase(NativeDatabase.memory());

    container = ProviderContainer(
      overrides: [overlayDatabaseProvider.overrideWith((ref) async => testDb)],
    );
  });

  tearDown(() async {
    await testDb.close();
    container.dispose();
  });

  group('MessageAnnotations Controller', () {
    test('initially returns null for unannotated message', () async {
      final annotation = await container.read(
        messageAnnotationsProvider(1).future,
      );
      expect(annotation, isNull);
    });

    test('toggleStar creates and updates starred status', () async {
      final notifier = container.read(messageAnnotationsProvider(1).notifier);

      // First toggle - should star the message
      await notifier.toggleStar();
      var annotation = await container.read(
        messageAnnotationsProvider(1).future,
      );
      expect(annotation?.isStarred, isTrue);

      // Second toggle - should unstar
      await notifier.toggleStar();
      annotation = await container.read(messageAnnotationsProvider(1).future);
      expect(annotation?.isStarred, isFalse);
    });

    test('setArchived updates archived status', () async {
      final notifier = container.read(messageAnnotationsProvider(2).notifier);

      await notifier.setArchived(true);
      var annotation = await container.read(
        messageAnnotationsProvider(2).future,
      );
      expect(annotation?.isArchived, isTrue);

      await notifier.setArchived(false);
      annotation = await container.read(messageAnnotationsProvider(2).future);
      expect(annotation?.isArchived, isFalse);
    });

    test('addTags and removeTags manage tags correctly', () async {
      final notifier = container.read(messageAnnotationsProvider(3).notifier);

      // Add tags
      await notifier.addTags(['receipt', 'important']);
      var annotation = await container.read(
        messageAnnotationsProvider(3).future,
      );
      expect(annotation?.tags, contains('receipt'));
      expect(annotation?.tags, contains('important'));

      // Add more tags (no duplicates)
      await notifier.addTags(['important', 'work']);
      annotation = await container.read(messageAnnotationsProvider(3).future);
      expect(annotation?.tags, contains('work'));
      // Should only have one 'important'
      expect('important'.allMatches(annotation!.tags!).length, equals(1));

      // Remove tags - need to refresh provider
      await notifier.removeTags(['receipt']);

      // Force refresh the provider by reading directly from database
      final afterRemove = await testDb.getMessageAnnotation(3);
      expect(afterRemove?.tags, isNot(contains('receipt')));
      expect(afterRemove?.tags, contains('important'));
      expect(afterRemove?.tags, contains('work'));
    });

    test('setNotes updates user notes', () async {
      final notifier = container.read(messageAnnotationsProvider(4).notifier);

      await notifier.setNotes('This is important info');
      var annotation = await container.read(
        messageAnnotationsProvider(4).future,
      );
      expect(annotation?.userNotes, equals('This is important info'));

      // Clear notes
      await notifier.setNotes(null);
      annotation = await container.read(messageAnnotationsProvider(4).future);
      expect(annotation?.userNotes, isNull);
    });

    test('setPriority validates and sets priority', () async {
      final notifier = container.read(messageAnnotationsProvider(5).notifier);

      await notifier.setPriority(5);
      var annotation = await container.read(
        messageAnnotationsProvider(5).future,
      );
      expect(annotation?.priority, equals(5));

      // Test validation
      expect(() => notifier.setPriority(6), throwsA(isA<ArgumentError>()));
      expect(() => notifier.setPriority(0), throwsA(isA<ArgumentError>()));
    });

    test('setReminder sets reminder timestamp', () async {
      final notifier = container.read(messageAnnotationsProvider(6).notifier);
      final reminderTime = DateTime(2025, 12, 31, 10, 30);

      await notifier.setReminder(reminderTime);
      final annotation = await container.read(
        messageAnnotationsProvider(6).future,
      );
      expect(annotation?.remindAt, isNotNull);
      expect(
        annotation?.remindAt,
        equals(reminderTime.toUtc().toIso8601String()),
      );
    });

    test('deleteAnnotation removes all annotations', () async {
      final notifier = container.read(messageAnnotationsProvider(7).notifier);

      // Create annotation with multiple properties
      await notifier.toggleStar();
      await notifier.addTags(['test']);
      await notifier.setNotes('Test note');

      var annotation = await container.read(
        messageAnnotationsProvider(7).future,
      );
      expect(annotation, isNotNull);

      // Delete
      await notifier.deleteAnnotation();
      annotation = await container.read(messageAnnotationsProvider(7).future);
      expect(annotation, isNull);
    });
  });

  group('Overlay Database Direct Methods', () {
    test('getStarredMessages returns only starred messages', () async {
      // Star some messages
      await testDb.toggleMessageStar(100);
      await testDb.toggleMessageStar(101);
      await testDb.toggleMessageStar(102);
      // Unstar one
      await testDb.toggleMessageStar(101);

      final starred = await testDb.getStarredMessages();
      expect(starred.length, equals(2));
      expect(starred.map((m) => m.messageId), containsAll([100, 102]));
    });

    test('getMessagesByTag filters by tag correctly', () async {
      await testDb.addMessageTags(200, ['receipt', 'work']);
      await testDb.addMessageTags(201, ['receipt', 'personal']);
      await testDb.addMessageTags(202, ['work']);

      final receipts = await testDb.getMessagesByTag('receipt');
      expect(receipts.length, equals(2));
      expect(receipts.map((m) => m.messageId), containsAll([200, 201]));

      final work = await testDb.getMessagesByTag('work');
      expect(work.length, equals(2));
      expect(work.map((m) => m.messageId), containsAll([200, 202]));
    });

    test('getHighPriorityMessages returns priority >= 4', () async {
      await testDb.setMessagePriority(300, 5);
      await testDb.setMessagePriority(301, 4);
      await testDb.setMessagePriority(302, 3);
      await testDb.setMessagePriority(303, 1);

      final highPriority = await testDb.getHighPriorityMessages();
      expect(highPriority.length, equals(2));
      expect(highPriority.map((m) => m.messageId), containsAll([300, 301]));
    });

    test(
      'getMessagesDueForReminder returns messages due before time',
      () async {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final nextWeek = now.add(const Duration(days: 7));

        await testDb.setMessageReminder(400, tomorrow);
        await testDb.setMessageReminder(401, nextWeek);
        await testDb.setMessageReminder(
          402,
          now.subtract(const Duration(days: 1)),
        );

        // Check for reminders due in next 3 days
        final due = await testDb.getMessagesDueForReminder(
          now.add(const Duration(days: 3)),
        );
        expect(due.length, equals(2));
        expect(due.map((m) => m.messageId), containsAll([400, 402]));
      },
    );
  });

  group('Provider Functions', () {
    test('starredMessagesProvider returns starred messages', () async {
      await testDb.toggleMessageStar(500);
      await testDb.toggleMessageStar(501);

      final starred = await container.read(starredMessagesProvider.future);
      expect(starred.length, equals(2));
      expect(starred.map((m) => m.messageId), containsAll([500, 501]));
    });

    test('messagesByTagProvider filters by tag', () async {
      await testDb.addMessageTags(600, ['important']);
      await testDb.addMessageTags(601, ['important', 'urgent']);

      final messages = await container.read(
        messagesByTagProvider('important').future,
      );
      expect(messages.length, equals(2));
      expect(messages.map((m) => m.messageId), containsAll([600, 601]));
    });

    test('highPriorityMessagesProvider returns high priority', () async {
      await testDb.setMessagePriority(700, 5);
      await testDb.setMessagePriority(701, 2);

      final highPriority = await container.read(
        highPriorityMessagesProvider.future,
      );
      expect(highPriority.length, equals(1));
      expect(highPriority.first.messageId, equals(700));
    });
  });

  group('Schema Migration', () {
    test('database has correct schema version', () {
      expect(testDb.schemaVersion, equals(2));
    });

    test('can create annotation with all fields', () async {
      final messageId = 999;
      await testDb.toggleMessageStar(messageId);
      await testDb.setMessageArchived(messageId, true);
      await testDb.addMessageTags(messageId, ['test', 'migration']);
      await testDb.setMessageNotes(messageId, 'Migration test note');
      await testDb.setMessagePriority(messageId, 4);
      await testDb.setMessageReminder(messageId, DateTime(2025, 12, 31));

      final annotation = await testDb.getMessageAnnotation(messageId);
      expect(annotation, isNotNull);
      expect(annotation?.isStarred, isTrue);
      expect(annotation?.isArchived, isTrue);
      expect(annotation?.tags, contains('test'));
      expect(annotation?.userNotes, equals('Migration test note'));
      expect(annotation?.priority, equals(4));
      expect(annotation?.remindAt, isNotNull);
    });
  });
}
