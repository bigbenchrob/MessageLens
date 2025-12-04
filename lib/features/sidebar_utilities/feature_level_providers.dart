import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/sidebar_utility_cassette_spec.dart';
import './application/cassette_builders/top_chat_menu_builder_provider.dart';

part 'feature_level_providers.g.dart';

/// Coordinator that maps [MessagesSpec] to rendered widgets for the center panel.
@riverpod
class UtilityCassetteCoordinator extends _$UtilityCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a widget for the given [spec].  This method pattern‑matches
  /// on the variant of [SidebarUtilityCassetteSpec] and delegates to
  /// appropriate builders.
  Widget buildForSpec(SidebarUtilityCassetteSpec spec) {
    return spec.when(
      topChatMenu: (chosenMenuIndex) {
        // Use the top chat menu builder to create the widget.  Note that
        // the builder expects the full spec; we pass it directly.
        return ref.read(topChatMenuBuilderProvider(spec));
      },
    );
  }
}
