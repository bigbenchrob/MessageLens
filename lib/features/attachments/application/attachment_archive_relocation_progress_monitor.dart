import 'dart:async';

import '../domain/entities/attachment_archive_relocation.dart';
import 'attachment_archive_relocation_service.dart';

typedef AttachmentArchiveRelocationProgressListener =
    void Function(AttachmentArchiveRelocationProgress progress);
typedef AttachmentArchiveRelocationProgressErrorListener =
    void Function(Object error, StackTrace stackTrace);

/// Polls the durable journal while one relocation command owns the workflow.
///
/// This monitor never mutates relocation state. It only projects already
/// durable journal progress into the Settings workflow while the engine runs.
final class AttachmentArchiveRelocationProgressMonitor {
  AttachmentArchiveRelocationProgressMonitor({
    required AttachmentArchiveRelocationService service,
    Duration interval = const Duration(milliseconds: 150),
  }) : _service = service,
       _interval = interval;

  final AttachmentArchiveRelocationService _service;
  final Duration _interval;

  Timer? _timer;
  bool _refreshInFlight = false;
  int _generation = 0;

  void start({
    required String operationId,
    required AttachmentArchiveRelocationProgressListener onProgress,
    required AttachmentArchiveRelocationProgressErrorListener onError,
  }) {
    stop();
    final generation = _generation;
    _timer = Timer.periodic(_interval, (_) {
      if (_refreshInFlight) {
        return;
      }
      _refreshInFlight = true;
      unawaited(
        _refresh(
          operationId: operationId,
          generation: generation,
          onProgress: onProgress,
          onError: onError,
        ),
      );
    });
  }

  void stop() {
    _generation += 1;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _refresh({
    required String operationId,
    required int generation,
    required AttachmentArchiveRelocationProgressListener onProgress,
    required AttachmentArchiveRelocationProgressErrorListener onError,
  }) async {
    try {
      final progress = await _service.readProgress(operationId);
      if (generation == _generation) {
        onProgress(progress);
      }
    } on Object catch (error, stackTrace) {
      if (generation == _generation) {
        onError(error, stackTrace);
      }
    } finally {
      _refreshInFlight = false;
    }
  }
}
