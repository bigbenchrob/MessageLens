import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/handles_info_cassette_spec.dart';

part 'info_content_resolver.g.dart';

/// Surface-agnostic resolved information content for the Handles feature.
///
/// For now this is plain text + optional title + optional footnote.
/// Later, if needed, this can be replaced by a shared model that supports
/// rich text, links, actions, etc.
///
/// IMPORTANT: Keep this payload UI-surface agnostic:
/// - no padding
/// - no card type decisions
/// - no widget building
class HandlesInfoContent {
  final String? title;
  final String body;
  final String? footnote;

  const HandlesInfoContent({required this.body, this.title, this.footnote});
}

/// Resolves Handles informational keys into surface-agnostic content.
///
/// This is the single source of truth for "what does this info key mean?".
///
/// - May evolve to query repositories (e.g., counts, dynamic hints)
/// - May become async when it needs feature data
@riverpod
class HandlesInfoContentResolver extends _$HandlesInfoContentResolver {
  @override
  void build() {
    // No state yet. This resolver is invoked imperatively via methods below.
  }

  /// Resolve an info key into surface-agnostic content.
  ///
  /// Keep UI concerns out of here (no card chrome, no widgets). Just meaning and content.
  Future<HandlesInfoContent> resolve(HandlesInfoKey key) async {
    switch (key) {
      case HandlesInfoKey.strayEmailsExplanation:
        return const HandlesInfoContent(
          body:
              'These are messages from email addresses that do not '
              'belong to a contact in your address book.',
        );

      case HandlesInfoKey.strayPhoneNumbersExplanation:
        return const HandlesInfoContent(
          body:
              'These are messages from phone numbers that do not '
              'belong to a contact in your address book.',
        );
    }
  }
}
