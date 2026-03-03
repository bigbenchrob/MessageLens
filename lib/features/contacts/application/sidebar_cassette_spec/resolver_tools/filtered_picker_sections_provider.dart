import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'favorite_contacts_provider.dart';
import 'grouped_contacts_provider.dart';
import 'picker_filter_mode_provider.dart';
import 'unified_picker_sections_provider.dart';

part 'filtered_picker_sections_provider.g.dart';

/// Produces picker sections filtered by the current [PickerFilterMode].
///
/// - **all**: Every contact grouped A–Z (no RECENTS / FAVORITES headers).
/// - **favouritesOnly**: Only favourites, still grouped A–Z.
///
/// Recents tracking continues behind the scenes via
/// [unifiedPickerSectionsProvider] and [recentContactsProvider].
@riverpod
Future<UnifiedPickerSections> filteredPickerSections(Ref ref) async {
  final mode = ref.watch(pickerFilterProvider);
  final grouped = await ref.watch(groupedContactsProvider.future);
  final favorites = await ref.watch(favoriteContactsProvider.future);

  final allFavoriteIds = <int>{
    for (final entry in favorites) entry.contact.participantId,
  };

  final sections = <PickerSection>[];
  final alphabeticalLetters = <String>[];

  for (final letter in grouped.availableLetters) {
    final contacts = grouped.groups[letter];
    if (contacts == null || contacts.isEmpty) {
      continue;
    }

    final filtered = switch (mode) {
      PickerFilterMode.all => contacts,
      PickerFilterMode.favouritesOnly => contacts
          .where((c) => allFavoriteIds.contains(c.participantId))
          .toList(growable: false),
    };

    if (filtered.isNotEmpty) {
      alphabeticalLetters.add(letter);
      sections.add(
        PickerSection(
          key: letter,
          label: letter,
          contacts: filtered,
          type: PickerSectionType.alphabetical,
        ),
      );
    }
  }

  return UnifiedPickerSections(
    sections: sections,
    alphabeticalLetters: alphabeticalLetters,
    alphabeticalStartIndex: 0,
    allFavoriteIds: allFavoriteIds,
  );
}
