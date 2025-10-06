import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

part 'spam_management_provider.g.dart';

enum SpamFilterStatus { all, blacklisted, valid }

class SpamHandleInfo {
  const SpamHandleInfo({
    required this.id,
    required this.handleId,
    required this.service,
    required this.isBlacklisted,
    required this.isValid,
    required this.chatCount,
  });

  final int id;
  final String handleId;
  final String service;
  final bool isBlacklisted;
  final bool isValid;
  final int chatCount;
}

/// Provider for managing spam/blacklisted handles
@riverpod
Future<List<SpamHandleInfo>> spamHandles(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  // Query all handles with their chat counts
  final query = db.select(db.workingHandles).join([
    // Left join through chat_to_handle to get chat count for each handle
    drift.leftOuterJoin(
      db.chatToHandle,
      db.chatToHandle.handleId.equalsExp(db.workingHandles.id),
    ),
    drift.leftOuterJoin(
      db.workingChats,
      db.workingChats.id.equalsExp(db.chatToHandle.chatId),
    ),
  ]);

  final rows = await query.get();
  final handleChatCounts = <int, int>{};

  // Count chats per handle
  for (final row in rows) {
    final handle = row.readTable(db.workingHandles);
    final chat = row.readTableOrNull(db.workingChats);

    if (chat != null) {
      handleChatCounts[handle.id] = (handleChatCounts[handle.id] ?? 0) + 1;
    } else if (!handleChatCounts.containsKey(handle.id)) {
      handleChatCounts[handle.id] = 0;
    }
  }

  // Get unique handles and build SpamHandleInfo list
  final uniqueHandles = <int, WorkingHandle>{};
  for (final row in rows) {
    final handle = row.readTable(db.workingHandles);
    uniqueHandles[handle.id] = handle;
  }

  final results = uniqueHandles.values.map((handle) {
    return SpamHandleInfo(
      id: handle.id,
      handleId: handle.handleId,
      service: handle.service,
      isBlacklisted: handle.isBlacklisted,
      isValid: handle.isValid,
      chatCount: handleChatCounts[handle.id] ?? 0,
    );
  }).toList();

  // Sort by status (blacklisted first) then by handle
  results.sort((a, b) {
    if (a.isBlacklisted != b.isBlacklisted) {
      return a.isBlacklisted ? -1 : 1; // Blacklisted first
    }
    return a.handleId.compareTo(b.handleId);
  });

  return results;
}

/// Provider for spam management operations
@riverpod
class SpamManagement extends _$SpamManagement {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  /// Block a handle (mark as blacklisted)
  Future<void> blockHandle(int handleId) async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);

    await (db.update(
      db.workingHandles,
    )..where((h) => h.id.equals(handleId))).write(
      const WorkingHandlesCompanion(
        isBlacklisted: Value(true),
        isValid: Value(false),
      ),
    );

    // Refresh the spam handles list
    ref.invalidate(spamHandlesProvider);
  }

  /// Unblock a handle (remove from blacklist)
  Future<void> unblockHandle(int handleId) async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);

    await (db.update(
      db.workingHandles,
    )..where((h) => h.id.equals(handleId))).write(
      const WorkingHandlesCompanion(
        isBlacklisted: Value(false),
        isValid: Value(true),
      ),
    );

    // Refresh the spam handles list
    ref.invalidate(spamHandlesProvider);
  }

  /// Get statistics about spam filtering
  Future<SpamStats> getSpamStats() async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);

    final totalHandles =
        await (db.selectOnly(db.workingHandles)
              ..addColumns([db.workingHandles.id.count()]))
            .getSingle()
            .then((row) => row.read(db.workingHandles.id.count()) ?? 0);

    final blacklistedHandles =
        await (db.selectOnly(db.workingHandles)
              ..addColumns([db.workingHandles.id.count()])
              ..where(db.workingHandles.isBlacklisted.equals(true)))
            .getSingle()
            .then((row) => row.read(db.workingHandles.id.count()) ?? 0);

    final validHandles = totalHandles - blacklistedHandles;

    return SpamStats(
      totalHandles: totalHandles,
      blacklistedHandles: blacklistedHandles,
      validHandles: validHandles,
    );
  }
}

class SpamStats {
  const SpamStats({
    required this.totalHandles,
    required this.blacklistedHandles,
    required this.validHandles,
  });

  final int totalHandles;
  final int blacklistedHandles;
  final int validHandles;

  double get blacklistPercentage =>
      totalHandles > 0 ? (blacklistedHandles / totalHandles) * 100 : 0.0;
}
