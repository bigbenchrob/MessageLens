import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../essentials/sidebar/domain/entities/features/messages_cassette_spec.dart';
import '../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'application/cassette_builders/global_timeline_view_builder_provider.dart';
import 'application/cassette_builders/messages_for_handle_view_builder_provider.dart';
import 'application/cassette_builders/messages_heatmap_cassette_builder_provider.dart';
import 'presentation/view/global_timeline_v2_view.dart';
import 'presentation/view/handle_lens_view.dart';
import 'presentation/view/messages_for_contact_view.dart';

export 'infrastructure/repositories/messages_repository_provider.dart';

part 'feature_level_providers.g.dart';

// =============================================================================
// PLACEHOLDER SPECS - Replace with actual Freezed specs when implemented
// =============================================================================

/// Placeholder for MessagesSettingsSpec (sidebar cassettes in settings mode).
/// Replace with: import '../../essentials/sidebar/domain/entities/features/messages_settings_spec.dart';
typedef MessagesSettingsSpec = void;

// =============================================================================
// COORDINATORS
// =============================================================================

/// Coordinator that maps [MessagesSpec] to rendered widgets for the center panel.
@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  Widget buildForSpec(MessagesSpec spec) {
    return spec.when(
      forChat: (chatId) =>
          _buildComingSoon('Messages for chat ($chatId) view is coming soon.'),
      forContact: (contactId, scrollToDate) => MessagesForContactView(
        contactId: contactId,
        scrollToDate: scrollToDate,
      ),
      recent: (limit) =>
          _buildComingSoon('Recent $limit messages view is coming soon.'),
      globalTimeline: () => ref.read(globalTimelineViewBuilderProvider),
      forHandle: (handleId) =>
          ref.read(messagesForHandleViewBuilderProvider(handleId)),
      handleLens: (handleId) => HandleLensView(handleId: handleId),
      forChatInDateRange: (chatId, startDate, endDate) {
        return _buildComingSoon(
          'Messages for chat ($chatId) in date range view is coming soon.',
        );
      },
      globalTimelineV2: (scrollToDate) =>
          GlobalTimelineV2View(scrollToDate: scrollToDate),
    );
  }

  Widget _buildComingSoon(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

/// Coordinator that maps [MessagesCassetteSpec] to cassette widgets.
@riverpod
class FeatureCassetteSpecCoordinator extends _$FeatureCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  SidebarCassetteCardViewModel buildForSpec(
    MessagesCassetteSpec spec, {
    required int cassetteIndex,
  }) {
    return spec.when(
      heatMap: (contactId, useV2Timeline) => ref.read(
        messagesHeatmapCassetteBuilderProvider(
          contactId: contactId,
          useV2Timeline: useV2Timeline,
        ),
      ),
    );
  }
}

/// Coordinator that maps [MessagesSettingsSpec] to cassette widgets.
@riverpod
class SettingsCassetteSpecCoordinator
    extends _$SettingsCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a cassette view model for the given [MessagesSettingsSpec].
  SidebarCassetteCardViewModel buildForSpec(MessagesSettingsSpec spec) {
    // TODO: Implement when MessagesSettingsSpec is defined
    return const SidebarCassetteCardViewModel(
      title: 'Message Settings',
      subtitle: 'Coming soon',
      child: SizedBox.shrink(),
    );
  }
}
