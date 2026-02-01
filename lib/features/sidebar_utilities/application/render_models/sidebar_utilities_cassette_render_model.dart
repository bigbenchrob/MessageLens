import 'sidebar_utilities_cassette_content.dart';

/// Widget-free payload returned by the application coordinator.
///
/// - Contains chrome decisions (title/isNaked)
/// - Contains an explicit content intent that presentation can render
class SidebarUtilitiesCassetteRenderModel {
  final String title;
  final bool isNaked;
  final SidebarUtilitiesCassetteContent content;

  const SidebarUtilitiesCassetteRenderModel({
    required this.title,
    required this.isNaked,
    required this.content,
  });
}
