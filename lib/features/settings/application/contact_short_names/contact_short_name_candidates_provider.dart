import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';

part 'contact_short_name_candidates_provider.g.dart';

final _alphabeticPattern = RegExp(r'[A-Za-z]');

class SettingsContactIdentity {
  const SettingsContactIdentity({
    required this.identityId,
    required this.displayName,
    required this.normalizedAddress,
    required this.service,
  });

  final int identityId;
  final String? displayName;
  final String? normalizedAddress;
  final String? service; // Made nullable to handle participants without handles
}

class SettingsContactEntry {
  const SettingsContactEntry({
    required this.contactKey,
    required this.displayName,
    required this.identities,
  });

  final String contactKey;
  final String displayName;
  final List<SettingsContactIdentity> identities;
}

String _deriveDisplayName(Iterable<SettingsContactIdentity> identities) {
  String? fallbackDisplayName;
  String? fallbackHandle;

  bool looksLikePersonName(String value) {
    return _alphabeticPattern.hasMatch(value);
  }

  for (final identity in identities) {
    final name = identity.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      if (looksLikePersonName(name)) {
        return name;
      }
      fallbackDisplayName ??= name;
    }

    final handle = identity.normalizedAddress?.trim();
    if (handle != null && handle.isNotEmpty && fallbackHandle == null) {
      fallbackHandle = handle;
    }
  }

  if (fallbackDisplayName != null) {
    return fallbackDisplayName;
  }

  if (fallbackHandle != null) {
    return fallbackHandle;
  }

  return 'Unknown Contact';
}

@riverpod
Future<List<SettingsContactEntry>> contactShortNameCandidates(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final rows =
      await (db.select(db.workingParticipants)..orderBy([
            (tbl) => drift.OrderingTerm(expression: tbl.displayName),
            (tbl) => drift.OrderingTerm(expression: tbl.id),
          ]))
          .get();

  final groups = <String, List<SettingsContactIdentity>>{};

  for (final participant in rows) {
    // Query handles for this participant through handle_to_participant
    final handleLinks =
        await (db.select(db.handleToParticipant).join([
              drift.innerJoin(
                db.workingHandles,
                db.workingHandles.id.equalsExp(db.handleToParticipant.handleId),
              ),
            ])..where(
              db.handleToParticipant.participantId.equals(participant.id),
            ))
            .get();

    // Always use participant ID as the key (matches overlay database format)
    final key = 'participant:${participant.id}';

    // Create identity entries for each handle associated with this participant
    for (final linkRow in handleLinks) {
      final handle = linkRow.readTable(db.workingHandles);

      final participantEntry = SettingsContactIdentity(
        identityId: participant.id,
        displayName: participant.displayName,
        normalizedAddress: handle.handleId,
        service: handle.service,
      );

      groups
          .putIfAbsent(key, () => <SettingsContactIdentity>[])
          .add(participantEntry);
    }

    // If participant has no handles, still create an entry
    if (handleLinks.isEmpty) {
      final participantEntry = SettingsContactIdentity(
        identityId: participant.id,
        displayName: participant.displayName,
        normalizedAddress: null,
        service: null,
      );

      groups
          .putIfAbsent(key, () => <SettingsContactIdentity>[])
          .add(participantEntry);
    }
  }

  final entries = groups.entries.map((entry) {
    final displayName = _deriveDisplayName(entry.value);
    return SettingsContactEntry(
      contactKey: entry.key,
      displayName: displayName,
      identities: List<SettingsContactIdentity>.unmodifiable(entry.value),
    );
  }).toList();

  // Sort with real names (containing letters) before phone numbers/emails
  entries.sort((a, b) {
    final aHasLetters = _alphabeticPattern.hasMatch(a.displayName);
    final bHasLetters = _alphabeticPattern.hasMatch(b.displayName);

    // Check if it's a short numeric identifier (4-10 digits, likely spam)
    final shortNumericPattern = RegExp(r'^\+?[0-9]{4,10}$');
    final aIsShortNumeric = shortNumericPattern.hasMatch(a.displayName);
    final bIsShortNumeric = shortNumericPattern.hasMatch(b.displayName);

    // Priority order:
    // 1. Real names (has letters, not short numeric)
    // 2. Long phone numbers (11+ digits, legitimate contacts)
    // 3. Short numeric identifiers (4-10 digits, spam)

    // Both are short numeric spam - sort by display name
    if (aIsShortNumeric && bIsShortNumeric) {
      return a.displayName.compareTo(b.displayName);
    }

    // One is short numeric spam - push it to bottom
    if (aIsShortNumeric) {
      return 1; // a goes to bottom
    }
    if (bIsShortNumeric) {
      return -1; // b goes to bottom
    }

    // Neither is short numeric spam - prioritize names with letters
    if (aHasLetters && !bHasLetters) {
      return -1; // a (has letters) comes before b (no letters)
    }
    if (!aHasLetters && bHasLetters) {
      return 1; // b (has letters) comes before a (no letters)
    }

    // Both have letters or both are long phone numbers - sort alphabetically
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });
  return entries;
}
