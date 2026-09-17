import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

enum AttachmentArchiveSettingsWorkflowView {
  currentLocation,
  preparingReview,
  preflightReview,
  preflightFailure,
  copying,
  verifying,
  finalizing,
  activating,
  paused,
  cancelled,
  failed,
  completed,
}

final class AttachmentArchiveSettingsStatusLine {
  const AttachmentArchiveSettingsStatusLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

final class AttachmentArchiveSettingsCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const AttachmentArchiveSettingsCassettePayload({
    this.workflowView = AttachmentArchiveSettingsWorkflowView.currentLocation,
    this.statusLines = const [],
    this.actions = const [],
    this.cassetteIndex = 0,
    super.title = 'Attachment Archive',
    super.bodyText =
        'Images from your Messages are automatically archived to protect '
        'against iCloud eviction. Archived images remain available even '
        'when the originals are no longer on this Mac.',
    super.role = SidebarCassetteRole.action,
    super.topSpacing = 0,
    super.footnote,
  });

  final AttachmentArchiveSettingsWorkflowView workflowView;
  final List<AttachmentArchiveSettingsStatusLine> statusLines;
  final List<SidebarActionDescriptor> actions;
  final int cassetteIndex;
}
