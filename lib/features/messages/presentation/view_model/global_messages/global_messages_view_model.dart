import '../../../application/use_cases/global_message_timeline_provider.dart';
import '../../../application/use_cases/global_messages_heatmap_provider.dart';

/// Entrypoint facade for "Global Messages" (all messages) display features.
///
/// Today, global message functionality is still implemented as providers under
/// `application/use_cases/`.
///
/// This facade makes it discoverable from the presentation layer:
/// - Timeline data: [globalMessageTimelineProvider]
/// - Heatmap data: [globalMessagesHeatmapProvider]
abstract class GlobalMessagesViewModel {
  const GlobalMessagesViewModel._();
}
