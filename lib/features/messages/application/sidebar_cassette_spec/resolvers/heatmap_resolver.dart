import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../widget_builders/messages_heatmap_widget.dart';

part 'heatmap_resolver.g.dart';

/// Resolves a messages heatmap cassette.
///
/// This resolver produces a [SidebarCassetteCardViewModel] for the calendar
/// heatmap cassette. It decides title/subtitle based on whether the heatmap
/// is contact-scoped or global, then delegates rendering to
/// [MessagesHeatmapWidget].
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Determines which widget builder to use
/// - Does NOT construct widgets itself (delegates to widget builder)
@riverpod
class HeatmapResolver extends _$HeatmapResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the messages heatmap cassette.
  Future<SidebarCassetteCardViewModel> resolve({
    required int? contactId,
    required bool useV2Timeline,
    required int cassetteIndex,
  }) async {
    final isContactScoped = contactId != null;

    return SidebarCassetteCardViewModel(
      title: isContactScoped
          ? 'Click on a square to see messages for that month'
          : 'All messages heatmap',
      subtitle: isContactScoped
          ? null
          : 'Discover peaks and gaps across your entire archive.',
      shouldExpand: false,
      child: MessagesHeatmapWidget(
        contactId: contactId,
        useV2Timeline: useV2Timeline,
      ),
    );
  }
}
