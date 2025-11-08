import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

void main() {
  late OverlayDatabase db;

  setUp(() {
    db = OverlayDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('virtual participants DAO', () {
    test('creates participant inside overlay id band', () async {
      final participant = await db.createVirtualParticipant(
        displayName: 'Example Contact',
      );

      expect(participant.id, greaterThanOrEqualTo(1000000000));
      expect(participant.displayName, equals('Example Contact'));
      expect(participant.shortName, equals('EC'));
      expect(participant.createdAtUtc, isNotEmpty);
      expect(participant.updatedAtUtc, isNotEmpty);
    });

    test('ids are monotonically increasing', () async {
      final first = await db.createVirtualParticipant(
        displayName: 'First Person',
      );
      final second = await db.createVirtualParticipant(
        displayName: 'Second Person',
      );

      expect(second.id, greaterThan(first.id));
    });

    test('short name falls back gracefully for single token names', () async {
      final participant = await db.createVirtualParticipant(
        displayName: 'Plato',
      );

      expect(participant.shortName, equals('PL'));
    });

    test('short name handles emoji names', () async {
      final participant = await db.createVirtualParticipant(
        displayName: '😀 Friend',
      );

      expect(participant.shortName, equals('😀F'));
    });

    test('created rows are returned alphabetically', () async {
      await db.createVirtualParticipant(displayName: 'Charlie');
      await db.createVirtualParticipant(displayName: 'Alice');
      await db.createVirtualParticipant(displayName: 'Bob');

      final rows = await db.getVirtualParticipants();
      expect(
        rows.map((row) => row.displayName),
        orderedEquals(['Alice', 'Bob', 'Charlie']),
      );
    });

    test('delete removes participant by id', () async {
      final participant = await db.createVirtualParticipant(
        displayName: 'Disposable Contact',
      );

      final deleted = await db.deleteVirtualParticipant(participant.id);
      expect(deleted, equals(1));

      final remaining = await db.getVirtualParticipants();
      expect(remaining, isEmpty);
    });

    test('trimmed display name must not be empty', () {
      expect(
        () => db.createVirtualParticipant(displayName: '   '),
        throwsArgumentError,
      );
    });
  });
}
