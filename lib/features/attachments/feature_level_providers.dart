import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

part 'feature_level_providers.g.dart';

// =============================================================================
// PLACEHOLDER SPECS - Replace with actual Freezed specs when implemented
// =============================================================================

/// Placeholder for AttachmentsSpec (ViewSpec for center panel).
/// Replace with: import '../../essentials/navigation/domain/entities/features/attachments_spec.dart';
typedef AttachmentsSpec = void;

/// Placeholder for AttachmentsCassetteSpec (sidebar cassettes in messages mode).
/// Replace with: import '../../essentials/sidebar/domain/entities/features/attachments_cassette_spec.dart';
typedef AttachmentsCassetteSpec = void;

/// Placeholder for AttachmentsSettingsSpec (sidebar cassettes in settings mode).
/// Replace with: import '../../essentials/sidebar/domain/entities/features/attachments_settings_spec.dart';
typedef AttachmentsSettingsSpec = void;

// =============================================================================
// COORDINATORS
// =============================================================================

/// Coordinator that maps [AttachmentsSpec] to rendered widgets for the center panel.
@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a widget for the given [AttachmentsSpec].
  Widget buildForSpec(AttachmentsSpec spec) {
    // TODO: Implement when AttachmentsSpec is defined
    return _buildPlaceholder('Attachments view coming soon');
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

/// Coordinator that maps [AttachmentsCassetteSpec] to cassette widgets.
@riverpod
class FeatureCassetteSpecCoordinator extends _$FeatureCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a cassette view model for the given [AttachmentsCassetteSpec].
  SidebarCassetteCardViewModel buildForSpec(AttachmentsCassetteSpec spec) {
    // TODO: Implement when AttachmentsCassetteSpec is defined
    return const SidebarCassetteCardViewModel(
      title: 'Attachments',
      subtitle: 'Coming soon',
      child: SizedBox.shrink(),
    );
  }
}

/// Coordinator that maps [AttachmentsSettingsSpec] to cassette widgets.
@riverpod
class SettingsCassetteSpecCoordinator
    extends _$SettingsCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a cassette view model for the given [AttachmentsSettingsSpec].
  SidebarCassetteCardViewModel buildForSpec(AttachmentsSettingsSpec spec) {
    // TODO: Implement when AttachmentsSettingsSpec is defined
    return const SidebarCassetteCardViewModel(
      title: 'Attachment Settings',
      subtitle: 'Coming soon',
      child: SizedBox.shrink(),
    );
  }
}
