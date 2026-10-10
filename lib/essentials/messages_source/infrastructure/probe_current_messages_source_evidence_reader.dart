import 'dart:io';

import '../../conversation_graph/application/monitor/chat_db_source_probe_reader.dart';
import '../application/current_messages_source_evidence_reader.dart';
import '../domain/current_messages_source_evidence.dart';

typedef CurrentMessagesSourcePathResolver = String Function();
typedef CurrentMessagesSourceReadProbe = int Function(String sourcePath);

final class ProbeCurrentMessagesSourceEvidenceReader
    implements CurrentMessagesSourceEvidenceReader {
  ProbeCurrentMessagesSourceEvidenceReader({
    required CurrentMessagesSourceReadProbe sourceReadProbe,
    CurrentMessagesSourcePathResolver? sourcePathResolver,
  }) : _sourceReadProbe = sourceReadProbe,
       _sourcePathResolver =
           sourcePathResolver ?? defaultMacosMessagesDatabasePath;

  final CurrentMessagesSourceReadProbe _sourceReadProbe;
  final CurrentMessagesSourcePathResolver _sourcePathResolver;

  static String defaultMacosMessagesDatabasePath() {
    final home = Platform.environment['HOME'] ?? '/Users/unknown';
    return '$home/Library/Messages/chat.db';
  }

  @override
  String get sourcePath => _sourcePathResolver();

  @override
  CurrentMessagesSourceEvidence read() {
    final observedPath = sourcePath;
    try {
      return CurrentMessagesSourceEvidence.readable(
        sourcePath: observedPath,
        maxRowId: _sourceReadProbe(observedPath),
      );
    } on ChatDbSourceProbeException catch (error, stackTrace) {
      final condition = error.kind == ChatDbSourceProbeFailureKind.accessDenied
          ? CurrentMessagesSourceReadCondition.accessDenied
          : CurrentMessagesSourceReadCondition.unavailable;
      return CurrentMessagesSourceEvidence.failed(
        sourcePath: observedPath,
        condition: condition,
        failureKind: error.kind,
        error: error,
        stackTrace: stackTrace,
      );
    } on Object catch (error, stackTrace) {
      return CurrentMessagesSourceEvidence.failed(
        sourcePath: observedPath,
        condition: CurrentMessagesSourceReadCondition.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
