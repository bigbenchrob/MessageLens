import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../essentials/db/shared/handle_identifier_utils.dart';
import '../../../contacts/infrastructure/repositories/handles_for_contact_provider.dart';
import '../../../contacts/infrastructure/repositories/participant_merge_utils.dart';

part 'recovered_unlinked_messages_provider.g.dart';

class RecoveredUnlinkedMessageItem {
  const RecoveredUnlinkedMessageItem({
    required this.id,
    required this.guid,
    required this.senderHandleId,
    this.contactName,
    this.rawItemType,
    this.rawAssociatedMessageType,
    required this.semanticKind,
    required this.isSparseArtifact,
    required this.isFromMe,
    required this.isInferred,
    required this.senderLabel,
    required this.service,
    required this.text,
    required this.sentAt,
    required this.itemType,
    required this.hasAttachments,
    required this.attachmentCount,
    required this.attachmentNames,
  });

  final int id;
  final String guid;
  final int? senderHandleId;
  final String? contactName;
  final int? rawItemType;
  final int? rawAssociatedMessageType;
  final String semanticKind;
  final bool isSparseArtifact;
  final bool isFromMe;
  final bool isInferred;
  final String senderLabel;
  final String service;
  final String text;
  final DateTime? sentAt;
  final String itemType;
  final bool hasAttachments;
  final int attachmentCount;
  final List<String> attachmentNames;
}

@riverpod
Stream<List<RecoveredUnlinkedMessageItem>> recoveredUnlinkedMessages(
  Ref ref, {
  int? contactId,
}) async* {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final displayNameOverrides = await displayNameOverridesMap(overlayDb);
  final scopedHandleIds = contactId == null
      ? null
      : (await ref.watch(
          handlesForContactProvider(contactId: contactId).future,
        )).map((handle) => handle.handleId).toSet();
  final scopedRawIdentifiers =
      scopedHandleIds == null || scopedHandleIds.isEmpty
      ? null
      : (await (db.select(db.handlesCanonical)..where(
                  (table) =>
                      table.id.isIn(scopedHandleIds.toList(growable: false)),
                ))
                .get())
            .map((handle) => _normalizedIdentifierKey(handle.rawIdentifier))
            .toSet();
  final contactNameByHandleId = await _loadContactNameByHandleId(
    db: db,
    displayNameOverrides: displayNameOverrides,
  );

  DateTime? parseUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
  }

  final query = db.select(db.recoveredUnlinkedMessages)
    ..orderBy([
      (table) => drift.OrderingTerm(
        expression: table.sentAtUtc,
        mode: drift.OrderingMode.asc,
      ),
      (table) => drift.OrderingTerm(
        expression: table.id,
        mode: drift.OrderingMode.asc,
      ),
    ]);

  yield* query.watch().asyncMap((rows) async {
    final items = <_RecoveredCandidateItem>[];

    for (final row in rows) {
      final senderHandleId = row.senderHandleId;
      final senderHandleMatches =
          scopedHandleIds != null &&
          senderHandleId != null &&
          scopedHandleIds.contains(senderHandleId);
      final senderAddressMatches =
          scopedRawIdentifiers != null &&
          scopedRawIdentifiers.contains(
            _normalizedIdentifierKey(row.senderAddress),
          );
      final isDirectMatch =
          contactId == null || senderHandleMatches || senderAddressMatches;

      final hasText = row.textContent?.trim().isNotEmpty ?? false;
      final hasSenderAddress = row.senderAddress?.trim().isNotEmpty ?? false;
      final formattedSenderAddress = formatPhoneNumberForDisplay(
        row.senderAddress,
      );
      final attachments = row.hasAttachments
          ? await (db.select(db.recoveredUnlinkedAttachments)..where(
                  (attachment) => attachment.messageGuid.equals(row.guid),
                ))
                .get()
          : const <RecoveredUnlinkedAttachment>[];

      final attachmentNames = attachments
          .map((attachment) => attachment.transferName?.trim())
          .whereType<String>()
          .where((name) => name.isNotEmpty)
          .toList(growable: false);

      items.add(
        _RecoveredCandidateItem(
          item: RecoveredUnlinkedMessageItem(
            id: row.id,
            guid: row.guid,
            senderHandleId: row.senderHandleId,
            contactName: row.senderHandleId == null
                ? null
                : contactNameByHandleId[row.senderHandleId!],
            rawItemType: row.rawItemType,
            rawAssociatedMessageType: row.rawAssociatedMessageType,
            semanticKind: row.semanticKind ?? 'unknown-variant',
            isSparseArtifact: row.isSparseArtifact,
            isFromMe: row.isFromMe,
            isInferred: false,
            senderLabel: row.isFromMe
                ? 'You'
                : hasSenderAddress
                ? formattedSenderAddress
                : 'Unknown Sender',
            service: row.service,
            text: hasText
                ? row.textContent!.trim()
                : _fallbackRecoveredMessageText(
                    semanticKind: row.semanticKind ?? 'unknown-variant',
                  ),
            sentAt: parseUtc(row.sentAtUtc),
            itemType: row.itemType ?? 'unknown',
            hasAttachments: row.hasAttachments,
            attachmentCount: attachments.length,
            attachmentNames: attachmentNames,
          ),
          isDirectMatch: isDirectMatch,
          hasSenderAddress: hasSenderAddress,
        ),
      );
    }

    if (contactId == null) {
      return items.map((entry) => entry.item).toList(growable: false);
    }

    final directMatches = items
        .where((entry) => entry.isDirectMatch)
        .map((entry) => entry.item)
        .toList(growable: false);
    final anchorTimesByService = _buildAnchorTimesByService(directMatches);

    return items
        .where((entry) {
          if (entry.isDirectMatch) {
            return true;
          }

          return _shouldInferForScopedContact(
            item: entry.item,
            hasSenderAddress: entry.hasSenderAddress,
            anchorTimesByService: anchorTimesByService,
          );
        })
        .map((entry) {
          if (entry.isDirectMatch) {
            return entry.item;
          }

          return RecoveredUnlinkedMessageItem(
            id: entry.item.id,
            guid: entry.item.guid,
            senderHandleId: entry.item.senderHandleId,
            contactName: entry.item.contactName,
            rawItemType: entry.item.rawItemType,
            rawAssociatedMessageType: entry.item.rawAssociatedMessageType,
            semanticKind: entry.item.semanticKind,
            isSparseArtifact: entry.item.isSparseArtifact,
            isFromMe: entry.item.isFromMe,
            isInferred: true,
            senderLabel: entry.item.senderLabel,
            service: entry.item.service,
            text: entry.item.text,
            sentAt: entry.item.sentAt,
            itemType: entry.item.itemType,
            hasAttachments: entry.item.hasAttachments,
            attachmentCount: entry.item.attachmentCount,
            attachmentNames: entry.item.attachmentNames,
          );
        })
        .toList(growable: false);
  });
}

String _fallbackRecoveredMessageText({required String semanticKind}) {
  return switch (semanticKind) {
    'sparse-artifact' => '(Sparse artifact: no preserved text or payload)',
    'edited-or-unsent' => '(No plain text content; summary metadata preserved)',
    'balloon-or-app' =>
      '(No plain text content; app or balloon payload preserved)',
    'associated' => '(Associated message carrier without plain text)',
    'attachment-only' => '(No text content)',
    'rich-text' => '(No plain text content)',
    _ => '(No preserved content)',
  };
}

Future<Map<int, String>> _loadContactNameByHandleId({
  required WorkingDatabase db,
  required Map<int, String> displayNameOverrides,
}) async {
  final query = db.select(db.handleToParticipant).join([
    drift.innerJoin(
      db.workingParticipants,
      db.workingParticipants.id.equalsExp(db.handleToParticipant.participantId),
    ),
  ]);

  final rows = await query.get();
  final contactNameByHandleId = <int, String>{};

  for (final row in rows) {
    final handleLink = row.readTable(db.handleToParticipant);
    final participant = row.readTable(db.workingParticipants);
    final overrideName = displayNameOverrides[participant.id]?.trim();
    final defaultName = participant.displayName.trim();
    final resolvedName = overrideName != null && overrideName.isNotEmpty
        ? overrideName
        : defaultName;

    if (resolvedName.isEmpty || isPlaceholderDisplayName(resolvedName)) {
      continue;
    }

    contactNameByHandleId.putIfAbsent(handleLink.handleId, () => resolvedName);
  }

  return contactNameByHandleId;
}

String _normalizedIdentifierKey(String? value) {
  return value?.trim().toLowerCase() ?? '';
}

Map<String, List<int>> _buildAnchorTimesByService(
  List<RecoveredUnlinkedMessageItem> directMatches,
) {
  final result = <String, List<int>>{};

  for (final item in directMatches) {
    final sentAt = item.sentAt;
    if (sentAt == null) {
      continue;
    }

    result
        .putIfAbsent(item.service, () => <int>[])
        .add(sentAt.millisecondsSinceEpoch);
  }

  for (final times in result.values) {
    times.sort();
  }

  return result;
}

bool _shouldInferForScopedContact({
  required RecoveredUnlinkedMessageItem item,
  required bool hasSenderAddress,
  required Map<String, List<int>> anchorTimesByService,
}) {
  if (!item.isFromMe || item.senderHandleId != null || hasSenderAddress) {
    return false;
  }

  final sentAt = item.sentAt;
  if (sentAt == null) {
    return false;
  }

  final anchorTimes = anchorTimesByService[item.service];
  if (anchorTimes == null || anchorTimes.isEmpty) {
    return false;
  }

  return _isWithinInferenceWindow(
    targetMillis: sentAt.millisecondsSinceEpoch,
    sortedAnchorMillis: anchorTimes,
  );
}

bool _isWithinInferenceWindow({
  required int targetMillis,
  required List<int> sortedAnchorMillis,
}) {
  const inferenceWindow = Duration(minutes: 5);
  final maxDeltaMillis = inferenceWindow.inMilliseconds;

  var low = 0;
  var high = sortedAnchorMillis.length;

  while (low < high) {
    final mid = low + ((high - low) ~/ 2);
    if (sortedAnchorMillis[mid] < targetMillis) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }

  if (low < sortedAnchorMillis.length &&
      (sortedAnchorMillis[low] - targetMillis).abs() <= maxDeltaMillis) {
    return true;
  }

  if (low > 0 &&
      (sortedAnchorMillis[low - 1] - targetMillis).abs() <= maxDeltaMillis) {
    return true;
  }

  return false;
}

class _RecoveredCandidateItem {
  const _RecoveredCandidateItem({
    required this.item,
    required this.isDirectMatch,
    required this.hasSenderAddress,
  });

  final RecoveredUnlinkedMessageItem item;
  final bool isDirectMatch;
  final bool hasSenderAddress;
}
