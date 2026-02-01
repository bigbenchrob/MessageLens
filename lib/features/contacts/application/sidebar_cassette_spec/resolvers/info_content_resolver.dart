import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/entities/features/contacts_info_cassette_spec.dart';

part 'info_content_resolver.g.dart';

/// Resolved content for a contacts info card.
class ContactsInfoContent {
  final String? title;
  final String body;

  const ContactsInfoContent({this.title, required this.body});
}

/// Resolves info card content for [ContactsInfoKey] values.
///
/// This resolver maps semantic keys to the actual text content displayed
/// in info cards. This keeps the text owned by the feature while allowing
/// the essentials layer to request it via keys.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (the info key)
/// - Returns resolved content (not view models or widgets)
/// - Owns the meaning of each key
@riverpod
class ContactsInfoContentResolver extends _$ContactsInfoContentResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the content for a given info key.
  Future<ContactsInfoContent> resolve(ContactsInfoKey key) async {
    switch (key) {
      case ContactsInfoKey.favouritesVsRecents:
        return const ContactsInfoContent(
          body:
              'Contacts are ordered by message frequency. '
              'Favorites marked in macOS Contacts appear at the top.',
        );
    }
  }
}
