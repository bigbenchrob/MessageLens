import '../../conversation_graph/application/monitor/chat_db_source_probe_reader.dart';

enum CurrentMessagesSourceReadCondition {
  readable,
  accessDenied,
  unavailable,
  unknown,
}

final class CurrentMessagesSourceEvidence {
  const CurrentMessagesSourceEvidence._({
    required this.sourcePath,
    required this.condition,
    this.maxRowId,
    this.failureKind,
    this.error,
    this.stackTrace,
  });

  const CurrentMessagesSourceEvidence.readable({
    required String sourcePath,
    required int maxRowId,
  }) : this._(
         sourcePath: sourcePath,
         condition: CurrentMessagesSourceReadCondition.readable,
         maxRowId: maxRowId,
       );

  const CurrentMessagesSourceEvidence.failed({
    required this.sourcePath,
    required this.condition,
    required this.error,
    required this.stackTrace,
    this.failureKind,
  }) : assert(condition != CurrentMessagesSourceReadCondition.readable),
       maxRowId = null;

  final String sourcePath;
  final CurrentMessagesSourceReadCondition condition;
  final int? maxRowId;
  final ChatDbSourceProbeFailureKind? failureKind;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isReadable =>
      condition == CurrentMessagesSourceReadCondition.readable;
}
