import 'package:drift/drift.dart';

import '../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

Future<Map<int, int>> workingHandleCountsByParticipant(
  WorkingDatabase db,
) async {
  final participantColumn = db.handleToParticipant.participantId;
  final countExpression = db.handleToParticipant.handleId.count();

  final rows =
      await (db.selectOnly(db.handleToParticipant)
            ..addColumns([participantColumn, countExpression])
            ..groupBy([participantColumn]))
          .get();

  final handleCounts = <int, int>{};

  for (final row in rows) {
    final participantId = row.read(participantColumn);
    if (participantId == null) {
      continue;
    }
    handleCounts[participantId] = row.read(countExpression) ?? 0;
  }

  return handleCounts;
}

Future<Map<int, int>> overlayHandleCountsByParticipant(
  OverlayDatabase db,
) async {
  final participantColumn = db.handleToParticipantOverrides.participantId;
  final countExpression = db.handleToParticipantOverrides.handleId.count();

  final rows =
      await (db.selectOnly(db.handleToParticipantOverrides)
            ..addColumns([participantColumn, countExpression])
            ..groupBy([participantColumn]))
          .get();

  final handleCounts = <int, int>{};

  for (final row in rows) {
    final participantId = row.read(participantColumn);
    if (participantId == null) {
      continue;
    }
    handleCounts[participantId] = row.read(countExpression) ?? 0;
  }

  return handleCounts;
}

Future<Map<int, Set<int>>> overlayHandleIdsByParticipant(
  OverlayDatabase db,
) async {
  final overrides = await db.getAllHandleOverrides();
  final map = <int, Set<int>>{};

  for (final override in overrides) {
    map
        .putIfAbsent(override.participantId, () => <int>{})
        .add(override.handleId);
  }

  return map;
}

Future<Map<int, ParticipantOverride>> participantOverridesById(
  OverlayDatabase db,
) async {
  final rows = await db.select(db.participantOverrides).get();
  return {for (final row in rows) row.participantId: row};
}

bool isPlaceholderDisplayName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return true;
  }
  return trimmed.toLowerCase() == 'unknown contact';
}
