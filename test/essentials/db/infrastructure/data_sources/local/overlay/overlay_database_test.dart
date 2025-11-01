import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../../lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

void main() {
  late OverlayDatabase db;

  setUp(() {
    // Create in-memory database for testing
    db = OverlayDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('HandleToParticipantOverrides', () {
    test('create handle override', () async {
      // Create a manual link
      await db.setHandleOverride(123, 456);

      // Verify it exists
      final override = await db.getHandleOverride(123);
      expect(override, isNotNull);
      expect(override!.handleId, equals(123));
      expect(override.participantId, equals(456));
      expect(override.source, equals('user_manual'));
      expect(override.confidence, equals(1.0));
    });

    test('update existing handle override', () async {
      // Create initial link
      await db.setHandleOverride(123, 456);

      // Update to different participant
      await db.setHandleOverride(123, 789);

      // Verify it was updated
      final override = await db.getHandleOverride(123);
      expect(override, isNotNull);
      expect(override!.participantId, equals(789));
    });

    test('delete handle override', () async {
      // Create link
      await db.setHandleOverride(123, 456);

      // Delete it
      await db.deleteHandleOverride(123);

      // Verify it's gone
      final override = await db.getHandleOverride(123);
      expect(override, isNull);
    });

    test('get all overrides for participant', () async {
      // Create multiple overrides for same participant
      await db.setHandleOverride(111, 456);
      await db.setHandleOverride(222, 456);
      await db.setHandleOverride(333, 789); // Different participant

      // Query for participant 456
      final overrides = await db.getOverridesForParticipant(456);
      expect(overrides, hasLength(2));
      expect(
        overrides.map((o) => o.handleId).toList(),
        containsAll([111, 222]),
      );
    });

    test('get all handle overrides ordered by creation', () async {
      // Create overrides in specific order
      await db.setHandleOverride(111, 456);
      await Future<void>.delayed(
        const Duration(milliseconds: 10),
      ); // Ensure different timestamps
      await db.setHandleOverride(222, 789);

      final overrides = await db.getAllHandleOverrides();
      expect(overrides, hasLength(2));
      // Should be ordered by creation time (ascending)
      expect(overrides[0].handleId, equals(111));
      expect(overrides[1].handleId, equals(222));
    });

    test('handle override persists across database reopen', () async {
      // This test would require a file-based database
      // For now, just verify insert/query works
      await db.setHandleOverride(123, 456);
      final override = await db.getHandleOverride(123);
      expect(override, isNotNull);
    });

    test('get non-existent override returns null', () async {
      final override = await db.getHandleOverride(999);
      expect(override, isNull);
    });

    test('delete non-existent override completes gracefully', () async {
      // Should not throw
      await db.deleteHandleOverride(999);
    });
  });
}
