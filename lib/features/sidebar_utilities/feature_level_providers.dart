import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/sidebar_utility_cassette_spec.dart';
import '../../essentials/sidebar/presentation/models/cassette_card_view.dart';
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
  CassetteCardView buildForSpec(SidebarUtilityCassetteSpec spec) {
    return spec.when(
      topChatMenu: (selectedChoice) {
        final content = ref.read(topChatMenuBuilderProvider(spec));
        return CassetteCardView(title: '', child: content, isControl: true);
      },
    );
  }
}
