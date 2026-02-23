import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../../state/contact_picker_filter_provider.dart';
import 'favorite_contacts_provider.dart';
import 'grouped_contacts_provider.dart';

part 'unified_picker_sections_provider.freezed.dart';
part 'unified_picker_sections_provider.g.dart';

/// The kind of section in the unified picker list.
enum PickerSectionType {
  /// User-designated favourites.
  favorites,

  /// Alphabetical A–Z groups.
  alphabetical,
}

/// A single section in the unified picker list.
///
/// All sections share the same visual grammar: identical header styling,
/// identical row styling, identical interaction model. The only difference
/// is the section label text and the ordering logic that produced the list.
@freezed
abstract class PickerSection with _$PickerSection {
  const factory PickerSection({
    /// Unique key for this section (e.g. "RECENTS", "FAVORITES", "A", "B").
    required String key,

    /// Display label shown as the section header.
    required String label,

    /// Contacts in this section.
    required List<ContactSummary> contacts,

    /// The kind of section (for jump-bar offset logic, not for visual treatment).
    required PickerSectionType type,
  }) = _PickerSection;
}

/// The complete unified picker data: all sections plus metadata for the
/// jump bar (which only targets alphabetical sections).
@freezed
abstract class UnifiedPickerSections with _$UnifiedPickerSections {
  const factory UnifiedPickerSections({
    /// All sections in display order: RECENTS, FAVORITES, A, B, C, …
    required List<PickerSection> sections,

    /// Available letters for the jump bar (A–Z subset that has contacts).
    required List<String> alphabeticalLetters,

    /// Index offset: the first alphabetical section's position in [sections].
    /// The jump bar maps letter index → `alphabeticalStartIndex + letterIndex`.
    required int alphabeticalStartIndex,

    /// Participant IDs of all user-designated favourites, regardless of which
    /// section they currently appear in. Used to render a subtle favourite
    /// indicator on rows outside the FAVORITES section.
    required Set<int> allFavoriteIds,
  }) = _UnifiedPickerSections;
}

/// Produces a unified section list for the contact picker.
///
/// When filter mode is `favorites`:
///   - Shows only favorited contacts, alphabetically sorted
///   - No limit on number of favorites
///
/// When filter mode is `all`:
///   - Shows all contacts alphabetically (A-Z sections)
///   - Favorite status preserved in [allFavoriteIds] for star indicators
@riverpod
Future<UnifiedPickerSections> unifiedPickerSections(Ref ref) async {
  final filterMode = ref.watch(contactPickerFilterProvider);

  // Fetch data sources in parallel.
  final results = await (
    ref.watch(favoriteContactsProvider.future),
    ref.watch(groupedContactsProvider.future),
  ).wait;

  final favorites = results.$1;
  final grouped = results.$2;

  // Full set of user-designated favourite IDs (for semantic indicators).
  final allFavoriteIds = <int>{
    for (final entry in favorites) entry.contact.participantId,
  };

  final sections = <PickerSection>[];

  if (filterMode == ContactPickerFilterMode.favorites) {
    // ── FAVORITES MODE: Show only favourites, alphabetically sorted ──
    // Group favorites by first letter of display name
    final favoritesByLetter = <String, List<ContactSummary>>{};
    for (final entry in favorites) {
      final contact = entry.contact;
      final letter = contact.displayName.isNotEmpty
          ? contact.displayName[0].toUpperCase()
          : '#';
      final normalizedLetter =
          RegExp(r'^[A-Z]$').hasMatch(letter) ? letter : '#';
      (favoritesByLetter[normalizedLetter] ??= []).add(contact);
    }

    // Sort letters and build sections
    final sortedLetters = favoritesByLetter.keys.toList()..sort();
    final alphabeticalLetters = <String>[];

    for (final letter in sortedLetters) {
      final contacts = favoritesByLetter[letter]!;
      // Sort contacts within each letter group
      contacts.sort(
        (a, b) => a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        ),
      );
      alphabeticalLetters.add(letter);
      sections.add(
        PickerSection(
          key: letter,
          label: letter,
          contacts: contacts,
          type: PickerSectionType.favorites,
        ),
      );
    }

    return UnifiedPickerSections(
      sections: sections,
      alphabeticalLetters: alphabeticalLetters,
      alphabeticalStartIndex: 0,
      allFavoriteIds: allFavoriteIds,
    );
  }

  // ── ALL MODE: Show all contacts alphabetically ─────────────────────
  final alphabeticalLetters = <String>[];

  for (final letter in grouped.availableLetters) {
    final contacts = grouped.groups[letter];
    if (contacts == null || contacts.isEmpty) {
      continue;
    }

    alphabeticalLetters.add(letter);
    sections.add(
      PickerSection(
        key: letter,
        label: letter,
        contacts: contacts,
        type: PickerSectionType.alphabetical,
      ),
    );
  }

  return UnifiedPickerSections(
    sections: sections,
    alphabeticalLetters: alphabeticalLetters,
    alphabeticalStartIndex: 0,
    allFavoriteIds: allFavoriteIds,
  );
}
