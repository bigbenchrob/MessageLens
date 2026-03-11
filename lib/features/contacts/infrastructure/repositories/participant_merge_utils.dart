import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

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
            ..where(participantColumn.isNotNull())
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

/// Handle counts grouped by virtual_participant_id (overlay overrides only).
Future<Map<int, int>> overlayHandleCountsByVirtualParticipant(
  OverlayDatabase db,
) async {
  final vpColumn = db.handleToParticipantOverrides.virtualParticipantId;
  final countExpression = db.handleToParticipantOverrides.handleId.count();

  final rows =
      await (db.selectOnly(db.handleToParticipantOverrides)
            ..where(vpColumn.isNotNull())
            ..addColumns([vpColumn, countExpression])
            ..groupBy([vpColumn]))
          .get();

  final handleCounts = <int, int>{};

  for (final row in rows) {
    final vpId = row.read(vpColumn);
    if (vpId == null) {
      continue;
    }
    handleCounts[vpId] = row.read(countExpression) ?? 0;
  }

  return handleCounts;
}

/// Map of participantId → Set<handleId> from overlay overrides
/// (real participants only, not virtual).
Future<Map<int, Set<int>>> overlayHandleIdsByParticipant(
  OverlayDatabase db,
) async {
  final overrides = await db.getAllHandleOverrides();
  final map = <int, Set<int>>{};

  for (final override in overrides) {
    final pid = override.participantId;
    if (pid == null) {
      continue;
    }
    map.putIfAbsent(pid, () => <int>{}).add(override.handleId);
  }

  return map;
}

/// Map of virtualParticipantId → Set<handleId> from overlay overrides.
Future<Map<int, Set<int>>> overlayHandleIdsByVirtualParticipant(
  OverlayDatabase db,
) async {
  final overrides = await db.getAllHandleOverrides();
  final map = <int, Set<int>>{};

  for (final override in overrides) {
    final vpId = override.virtualParticipantId;
    if (vpId == null) {
      continue;
    }
    map.putIfAbsent(vpId, () => <int>{}).add(override.handleId);
  }

  return map;
}

Future<Map<int, ParticipantOverride>> participantOverridesById(
  OverlayDatabase db,
) async {
  final rows = await db.select(db.participantOverrides).get();
  return {for (final row in rows) row.participantId: row};
}

/// Returns participantId → display name for all participants with a
/// non-empty `displayNameOverride` in the overlay database.
Future<Map<int, String>> displayNameOverridesMap(OverlayDatabase db) async {
  final rows = await db.select(db.participantOverrides).get();
  final map = <int, String>{};
  for (final row in rows) {
    final name = row.displayNameOverride?.trim();
    if (name != null && name.isNotEmpty) {
      map[row.participantId] = name;
    }
  }
  return map;
}

bool isPlaceholderDisplayName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return true;
  }
  return trimmed.toLowerCase() == 'unknown contact';
}
