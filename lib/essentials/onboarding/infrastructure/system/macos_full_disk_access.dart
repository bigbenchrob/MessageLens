import 'dart:io';

import '../../../messages_source/application/current_messages_source_evidence_reader.dart';
import '../../../messages_source/domain/current_messages_source_evidence.dart';
import '../../application/full_disk_access.dart';

class MacosFullDiskAccess implements FullDiskAccess {
  const MacosFullDiskAccess({
    required CurrentMessagesSourceEvidenceReader sourceEvidenceReader,
    void Function(Object error, StackTrace stackTrace)? onReadFailure,
  }) : _sourceEvidenceReader = sourceEvidenceReader,
       _onReadFailure = onReadFailure;

  final CurrentMessagesSourceEvidenceReader _sourceEvidenceReader;
  final void Function(Object error, StackTrace stackTrace)? _onReadFailure;

  @override
  String get messagesDatabasePath => _sourceEvidenceReader.sourcePath;

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() {
    final evidence = _sourceEvidenceReader.read();
    final error = evidence.error;
    final stackTrace = evidence.stackTrace;
    if (error != null && stackTrace != null) {
      _onReadFailure?.call(error, stackTrace);
    }
    return switch (evidence.condition) {
      CurrentMessagesSourceReadCondition.readable =>
        MessagesSourceAccessResult.readable,
      CurrentMessagesSourceReadCondition.accessDenied =>
        MessagesSourceAccessResult.accessDenied,
      CurrentMessagesSourceReadCondition.unavailable ||
      CurrentMessagesSourceReadCondition.unknown =>
        MessagesSourceAccessResult.unavailable,
    };
  }

  @override
  bool canReadMessagesDatabase() {
    return inspectMessagesSourceAccess() == MessagesSourceAccessResult.readable;
  }

  @override
  Future<void> openSettings() async {
    await Process.run('open', [
      'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles',
    ]);
  }
}
