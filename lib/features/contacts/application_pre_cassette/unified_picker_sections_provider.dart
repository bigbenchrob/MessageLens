import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/repositories/contacts_list_repository.dart';
import '../infrastructure/repositories/recent_contacts_repository.dart';
import 'favorite_contacts_provider.dart';
import 'grouped_contacts_provider.dart';

part 'unified_picker_sections_provider.freezed.dart';
part 'unified_picker_sections_provider.g.dart';

/// The kind of section in the unified picker list.
enum PickerSectionType {
  /// Most recently accessed contacts.
  recents,

  /// User-designated favourites (excluding those already in RECENTS).
  favorites,

  /// Alphabetical A–Z groups (excluding RECENTS and FAVORITES).
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

/// Maximum number of recent contacts shown in the picker.
const int kMaxRecents = 3;

/// Maximum number of favourite contacts shown in the picker.
const int kMaxFavorites = 7;

/// Produces a unified section list for the contact picker by merging
/// recents, favourites, and alphabetical groups into a single flat
/// list of identically-styled sections.
///
/// **Precedence (hard invariant — see RECENTS-FAVORITES.md):**
///   RECENTS > FAVORITES > ALPHABETICAL
///
/// A contact appears in exactly one section. Recents outrank favourites,
/// favourites outrank alphabetical. Favourite *status* is preserved in
/// [UnifiedPickerSections.allFavoriteIds] for semantic indicators.
@riverpod
Future<UnifiedPickerSections> unifiedPickerSections(Ref ref) async {
  // Fetch all three data sources in parallel.
  final results = await (
    ref.watch(favoriteContactsProvider.future),
    ref.watch(recentContactsProvider.future),
    ref.watch(groupedContactsProvider.future),
  ).wait;

  final favorites = results.$1;
  final recents = results.$2;
  final grouped = results.$3;

  // Build a lookup of all contacts by participant ID for recents resolution.
  final allContactsById = <int, ContactSummary>{};
  for (final contacts in grouped.groups.values) {
    for (final contact in contacts) {
      allContactsById[contact.participantId] = contact;
    }
  }

  // Full set of user-designated favourite IDs (for semantic indicators).
  final allFavoriteIds = <int>{
    for (final entry in favorites) entry.contact.participantId,
  };

  // Track which participant IDs have already been placed in a section.
  final placed = <int>{};

  final sections = <PickerSection>[];

  // ── 1. RECENTS (highest precedence) ────────────────────────────────
  final recentContacts = recents
      .take(kMaxRecents)
      .map((r) => allContactsById[r.participantId])
      .whereType<ContactSummary>()
      .toList(growable: false);

  if (recentContacts.isNotEmpty) {
    sections.add(
      PickerSection(
        key: 'RECENTS',
        label: 'RECENTS',
        contacts: recentContacts,
        type: PickerSectionType.recents,
      ),
    );
    for (final c in recentContacts) {
      placed.add(c.participantId);
    }
  }

  // ── 2. FAVORITES (excludes contacts already in RECENTS) ────────────
  final favoriteContacts = favorites
      .where((entry) => !placed.contains(entry.contact.participantId))
      .take(kMaxFavorites)
      .map((entry) => entry.contact)
      .toList(growable: false);

  if (favoriteContacts.isNotEmpty) {
    sections.add(
      PickerSection(
        key: 'FAVORITES',
        label: 'FAVORITES',
        contacts: favoriteContacts,
        type: PickerSectionType.favorites,
      ),
    );
    for (final c in favoriteContacts) {
      placed.add(c.participantId);
    }
  }

  // ── 3. ALPHABETICAL (excludes RECENTS + FAVORITES) ─────────────────
  final alphabeticalStartIndex = sections.length;
  final alphabeticalLetters = <String>[];

  for (final letter in grouped.availableLetters) {
    final contacts = grouped.groups[letter];
    if (contacts == null || contacts.isEmpty) {
      continue;
    }

    final filtered = contacts
        .where((c) => !placed.contains(c.participantId))
        .toList(growable: false);

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
    alphabeticalStartIndex: alphabeticalStartIndex,
    allFavoriteIds: allFavoriteIds,
  );
}
