import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/feature_level_providers.dart';

part 'info_content_resolver.g.dart';

/// Feature-local keys for informational/guidance content owned by the Contacts feature.
///
/// Notes:
/// - These keys are NOT UI-surface specific (not "cassette", not "tooltip").
/// - They represent *meaning* that may be rendered in multiple surfaces.
// enum ContactsInfoKey { favouritesVsRecents }

/// Surface-agnostic resolved information content.
///
/// For now this is plain text + optional title.
/// Later, if needed, this can be replaced by a shared model (recommended) that supports
/// rich text, links, actions, etc.
///
/// IMPORTANT: Keep this payload UI-surface agnostic:
/// - no padding
/// - no card type decisions
/// - no widget building
class InfoContent {
  final String? title;
  final String body;

  const InfoContent({required this.body, this.title});
}

/// Resolves Contacts informational keys into surface-agnostic content.
///
/// This is the single source of truth for "what does this info key mean?".
///
/// - May evolve to query repositories (e.g., counts, dynamic hints)
/// - May become async when it needs feature data
@riverpod
class InfoContentResolver extends _$InfoContentResolver {
  @override
  void build() {
    // No state yet. This resolver is invoked imperatively via methods below.
  }

  /// Resolve an info key into surface-agnostic content.
  ///
  /// Keep UI concerns out of here (no card chrome, no widgets). Just meaning and content.
  Future<InfoContent> resolve(ContactsInfoKey key) async {
    switch (key) {
      case ContactsInfoKey.favouritesVsRecents:
        return const InfoContent(
          title: 'Favourites vs Recents',
          body:
              'Recent contacts are strictly those you have chosen recently. '
              'Favourites are set by you and remain until you change them.',
        );
    }
  }
}
