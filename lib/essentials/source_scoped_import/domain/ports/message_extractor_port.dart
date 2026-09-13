import 'dart:typed_data';

typedef MessageExtractionProgressObserver =
    void Function({
      required int completedWorkCount,
      required int totalWorkCount,
      required int lastCompletedWorkId,
    });

abstract class MessageExtractorPort {
  Future<Map<int, String>> extractAllMessageTexts({int? limit, String? dbPath});

  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByWorkId, {
    MessageExtractionProgressObserver? onProgress,
  });

  Future<bool> isAvailable();

  Future<bool> isBlobExtractionAvailable();
}
