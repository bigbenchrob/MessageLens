abstract class MessageExtractorPort {
  Future<Map<int, String>> extractAllMessageTexts({int? limit, String? dbPath});
  Future<bool> isAvailable();
}
