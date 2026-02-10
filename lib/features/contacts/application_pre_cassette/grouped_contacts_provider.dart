import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../infrastructure/repositories/contacts_list_repository.dart';

part 'grouped_contacts_provider.freezed.dart';
part 'grouped_contacts_provider.g.dart';

/// Immutable representation of contacts bucketed by group key.
@freezed
abstract class GroupedContacts with _$GroupedContacts {
  const factory GroupedContacts({
    required Map<String, List<ContactSummary>> groups,
    required Map<String, int> letterCounts,
    required List<String> availableLetters,
  }) = _GroupedContacts;
}

const _alphabet = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#',
];

@riverpod
Future<GroupedContacts> groupedContacts(GroupedContactsRef ref) async {
  final contacts = await ref.watch(
    contactsListRepositoryProvider(
      spec: const ContactsListSpec.alphabetical(),
    ).future,
  );

  final grouped = <String, List<ContactSummary>>{};

  for (final contact in contacts) {
    final key = _deriveGroupKey(contact.displayName);
    grouped.putIfAbsent(key, () => []).add(contact);
  }

  // Ensure determinism: sort each bucket by display name then short name.
  for (final entry in grouped.entries) {
    entry.value.sort((a, b) {
      final nameCompare = compareAsciiLowerCase(a.displayName, b.displayName);
      if (nameCompare != 0) {
        return nameCompare;
      }
      return compareAsciiLowerCase(a.shortName, b.shortName);
    });
  }

  final availableLetters = _alphabet
      .where((letter) => grouped.containsKey(letter))
      .toList(growable: false);

  final letterCounts = Map<String, int>.fromEntries(
    grouped.entries.map((entry) => MapEntry(entry.key, entry.value.length)),
  );

  return GroupedContacts(
    groups: grouped,
    letterCounts: letterCounts,
    availableLetters: availableLetters,
  );
}

/// Derives the A-Z or # group key from a display name.
String _deriveGroupKey(String displayName) {
  final trimmed = displayName.trim();
  if (trimmed.isEmpty) {
    return '#';
  }
  final first = trimmed[0].toUpperCase();
  final codeUnit = first.codeUnitAt(0);
  // A=65, Z=90
  if (codeUnit >= 65 && codeUnit <= 90) {
    return first;
  }
  return '#';
}

@riverpod
Future<Map<String, int>> groupedContactLetterCounts(
  GroupedContactLetterCountsRef ref,
) async {
  final grouped = await ref.watch(groupedContactsProvider.future);
  return grouped.letterCounts;
}
