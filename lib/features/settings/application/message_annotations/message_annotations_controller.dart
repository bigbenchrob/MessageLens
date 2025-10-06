import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

part 'message_annotations_controller.g.dart';

/// Controller for managing message annotations (tags, starred, notes, etc.)
@riverpod
class MessageAnnotations extends _$MessageAnnotations {
  @override
  Future<MessageAnnotation?> build(int messageId) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    return overlayDb.getMessageAnnotation(messageId);
  }

  /// Toggle starred status for the message
  Future<void> toggleStar() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.toggleMessageStar(messageId);
    await _refresh();
  }

  /// Set archived status
  Future<void> setArchived({required bool archived}) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.setMessageArchived(
      messageId: messageId,
      archived: archived,
    );
    await _refresh();
  }

  /// Add tag(s) to the message
  Future<void> addTags(List<String> tags) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.addMessageTags(messageId, tags);
    await _refresh();
  }

  /// Remove tag(s) from the message
  Future<void> removeTags(List<String> tags) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.removeMessageTags(messageId, tags);
    await _refresh();
  }

  /// Set user notes for the message
  Future<void> setNotes(String? notes) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final trimmed = notes?.trim();
    await overlayDb.setMessageNotes(
      messageId,
      trimmed?.isEmpty ?? true ? null : trimmed,
    );
    await _refresh();
  }

  /// Set priority (1-5, where 5 is highest)
  Future<void> setPriority(int? priority) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.setMessagePriority(messageId, priority);
    await _refresh();
  }

  /// Set reminder date/time
  Future<void> setReminder(DateTime? remindAt) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.setMessageReminder(messageId, remindAt);
    await _refresh();
  }

  /// Delete all annotations for this message
  Future<void> deleteAnnotation() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.deleteMessageAnnotation(messageId);
    await _refresh();
  }

  Future<void> _refresh() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    state = const AsyncLoading<MessageAnnotation?>().copyWithPrevious(state);
    final latest = await overlayDb.getMessageAnnotation(messageId);
    state = AsyncData(latest);
  }
}

/// Provider for getting all starred messages
@riverpod
Future<List<MessageAnnotation>> starredMessages(Ref ref) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return overlayDb.getStarredMessages();
}

/// Provider for getting messages with a specific tag
@riverpod
Future<List<MessageAnnotation>> messagesByTag(Ref ref, String tag) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return overlayDb.getMessagesByTag(tag);
}

/// Provider for getting high priority messages
@riverpod
Future<List<MessageAnnotation>> highPriorityMessages(Ref ref) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return overlayDb.getHighPriorityMessages();
}

/// Provider for getting messages due for reminder
@riverpod
Future<List<MessageAnnotation>> messagesDueForReminder(
  Ref ref,
  DateTime before,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return overlayDb.getMessagesDueForReminder(before);
}
