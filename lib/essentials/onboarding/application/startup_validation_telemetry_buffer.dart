import '../../archive_environment/domain/archive_build_identity.dart';
import '../../archive_environment/domain/archive_environment.dart';
import '../domain/startup_validation_telemetry.dart';

typedef StartupValidationTelemetryEventSink =
    void Function(StartupValidationTelemetryEvent event);

final class StartupValidationTelemetryBuffer
    implements StartupValidationTelemetrySnapshotSource {
  final List<StartupValidationTelemetryEvent> _events =
      <StartupValidationTelemetryEvent>[];
  var _nextValidationId = 1;
  var _flushedEventCount = 0;

  int beginValidation({
    required ArchiveEnvironment? archiveEnvironment,
    required ArchiveBuildIdentity? buildIdentity,
  }) {
    final validationId = _nextValidationId++;
    record(
      StartupValidationTelemetryEvent.validationStarted(
        validationId: validationId,
        occurredAtUtc: DateTime.now().toUtc(),
        archiveEnvironment: archiveEnvironment,
        buildIdentity: buildIdentity,
      ),
    );
    return validationId;
  }

  void record(StartupValidationTelemetryEvent event) {
    _events.add(event);
  }

  void flushTo(StartupValidationTelemetryEventSink sink) {
    while (_flushedEventCount < _events.length) {
      sink(_events[_flushedEventCount]);
      _flushedEventCount++;
    }
  }

  @override
  StartupValidationTelemetrySnapshot snapshot() {
    return StartupValidationTelemetrySnapshot(events: _events);
  }
}
